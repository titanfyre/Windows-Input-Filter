# Loaded by Common.ps1. No machine mutation occurs just by loading this file.
function Get-InputFilterDataRoot {Join-Path $env:ProgramData 'WindowsInputFilter'}
function Get-InputFilterRecoveryRoot {Join-Path $env:ProgramFiles 'WindowsInputFilter\Recovery'}
function Assert-InputFilterDirectory([string]$Path,[string]$Expected) {
    $full=[IO.Path]::GetFullPath($Path).TrimEnd('\')
    if($full -ine [IO.Path]::GetFullPath($Expected).TrimEnd('\')){throw 'Unexpected InputFilter directory.'}
    $ancestor=$full
    while($ancestor){if(Test-Path -LiteralPath $ancestor){if((Get-Item -LiteralPath $ancestor -Force).Attributes -band [IO.FileAttributes]::ReparsePoint){throw 'InputFilter directory or ancestor is a reparse point.'}};$ancestor=Split-Path -Parent $ancestor}
    return $full
}
function Initialize-InputFilterStorage {
    $path=Assert-InputFilterDirectory (Get-InputFilterDataRoot) (Join-Path $env:ProgramData 'WindowsInputFilter')
    if(Test-Path -LiteralPath $path){$owner=(Get-Acl -LiteralPath $path).GetOwner([Security.Principal.SecurityIdentifier]).Value;if($owner -notin @('S-1-5-18','S-1-5-32-544')){throw 'Existing InputFilter data folder has an untrusted owner.'}}
    $security=New-Object Security.AccessControl.DirectorySecurity
    $security.SetAccessRuleProtection($true,$false)
    foreach($id in @('S-1-5-18','S-1-5-32-544')){
        $sid=New-Object Security.Principal.SecurityIdentifier($id)
        $security.AddAccessRule((New-Object Security.AccessControl.FileSystemAccessRule($sid,'FullControl','ContainerInherit,ObjectInherit','None','Allow')))
    }
    if(!(Test-Path -LiteralPath $path)){[IO.Directory]::CreateDirectory($path,$security)|Out-Null}else{Set-Acl -LiteralPath $path -AclObject $security}
}
function Enter-InputFilterOperation {
    $script:InputFilterOperationOwned=$false
    $security=New-Object Security.AccessControl.MutexSecurity
    foreach($id in @('S-1-5-18','S-1-5-32-544')){$security.AddAccessRule((New-Object Security.AccessControl.MutexAccessRule((New-Object Security.Principal.SecurityIdentifier($id)),'FullControl','Allow')))}
    $familyCreated=$false
    $script:InputFilterFamilyOwned=$false
    $script:InputFilterFamilyOperation=New-Object Threading.Mutex($false,'Global\WindowsInputProjects-Maintenance',[ref]$familyCreated,$security)
    try{$family=$script:InputFilterFamilyOperation.WaitOne(0)}catch [Threading.AbandonedMutexException]{$family=$true}
    if(!$family){$script:InputFilterFamilyOperation.Dispose();$script:InputFilterFamilyOperation=$null;$script:InputFilterLastExitCode=1618;throw 'Another InputFilter edition is performing setup or recovery (Win32 1618). Wait for it to finish.'}
    $script:InputFilterFamilyOwned=$true
    # Serialize with the original editions too; their immutable packages use
    # this maintenance mutex. Holding it does not authorize changing their data.
    $legacyCreated=$false;$script:InputFilterLegacyFamilyOwned=$false
    $script:InputFilterLegacyFamilyOperation=New-Object Threading.Mutex($false,'Global\InterceptorSetup-Maintenance',[ref]$legacyCreated,$security)
    try{$legacy=$script:InputFilterLegacyFamilyOperation.WaitOne(0)}catch [Threading.AbandonedMutexException]{$legacy=$true}
    if(!$legacy){$script:InputFilterLegacyFamilyOperation.Dispose();$script:InputFilterLegacyFamilyOperation=$null;$script:InputFilterLastExitCode=1618;throw 'An original input edition is performing setup or recovery (Win32 1618). Wait for it to finish.'}
    $script:InputFilterLegacyFamilyOwned=$true
    $created=$false
    $script:InputFilterOperation=New-Object Threading.Mutex($false,'Global\WindowsInputFilterSetup-Installation',[ref]$created,$security)
    try{$acquired=$script:InputFilterOperation.WaitOne(0)}catch [Threading.AbandonedMutexException]{$acquired=$true}
    if(!$acquired){$script:InputFilterOperation.Dispose();$script:InputFilterOperation=$null;$script:InputFilterLastExitCode=1618;throw 'Another setup or recovery operation for this product is active (Win32 1618). Wait for that operation to finish before retrying.'}
    $script:InputFilterOperationOwned=$true
}
function Exit-InputFilterOperation {
    try{
        if($script:InputFilterOperation){try{if($script:InputFilterOperationOwned){$script:InputFilterOperation.ReleaseMutex()}}finally{$script:InputFilterOperation.Dispose();$script:InputFilterOperation=$null;$script:InputFilterOperationOwned=$false}}
    }finally{
        if($script:InputFilterLegacyFamilyOperation){try{if($script:InputFilterLegacyFamilyOwned){$script:InputFilterLegacyFamilyOperation.ReleaseMutex()}}finally{$script:InputFilterLegacyFamilyOperation.Dispose();$script:InputFilterLegacyFamilyOperation=$null;$script:InputFilterLegacyFamilyOwned=$false}}
        if($script:InputFilterFamilyOperation){try{if($script:InputFilterFamilyOwned){$script:InputFilterFamilyOperation.ReleaseMutex()}}finally{$script:InputFilterFamilyOperation.Dispose();$script:InputFilterFamilyOperation=$null;$script:InputFilterFamilyOwned=$false}}
    }
}
function Import-InputFilterRecoveryAssembly {
    if(!('InputFilterRecovery.Devices' -as [type])){[Reflection.Assembly]::Load([IO.File]::ReadAllBytes((Join-Path $PSScriptRoot 'Recovery\InputFilterRecovery.exe')))|Out-Null}
}
function Write-InputFilterState($State) {
    $path=Join-Path (Get-InputFilterDataRoot) 'state.json'
    [InputFilterRecovery.Devices]::WriteState($path,($State|ConvertTo-Json -Depth 12))
}
function Read-InputFilterState {
    $path=Join-Path (Get-InputFilterDataRoot) 'state.json'
    if(!(Test-Path -LiteralPath $path)){return $null}
    if((Get-Item -LiteralPath $path -Force).Attributes -band [IO.FileAttributes]::ReparsePoint){throw 'Restoration journal is a reparse point.'}
    $owner=(Get-Acl -LiteralPath $path).GetOwner([Security.Principal.SecurityIdentifier]).Value
    if($owner -notin @('S-1-5-18','S-1-5-32-544')){throw 'Restoration journal has an untrusted owner.'}
    $state=Get-Content -LiteralPath $path -Raw -Encoding UTF8|ConvertFrom-Json
    if($state.Schema -ne 1){throw 'Unsupported InputFilter restoration journal.'}
    return $state
}
function Save-InputFilterBaseline {
    Import-InputFilterRecoveryAssembly
    $state=Read-InputFilterState
    if(!$state){$state=[pscustomobject]@{Schema=1;CreatedUtc=[DateTime]::UtcNow.ToString('o');Devices=@();CertificatesAdded=@();PendingUninstall=$false;FinalizeAttempts=0}}
    $known=@{};foreach($device in $state.Devices){$known[$device.Instance]=$true}
    foreach($device in [InputFilterRecovery.Devices]::Snapshot()){
        if(!$known.ContainsKey($device.Instance)){$state.Devices+= $device;$known[$device.Instance]=$true}
    }
    Write-InputFilterState $state
    return $state
}
function Register-InputFilterCertificateAdds($State,[string]$Thumbprint) {
    foreach($store in @('Root','TrustedPublisher')){
        if(!(Test-Path -LiteralPath ('Cert:\LocalMachine\'+$store+'\'+$Thumbprint))){
            if(!@($State.CertificatesAdded|Where-Object {$_.Store -eq $store -and $_.Thumbprint -eq $Thumbprint}).Count){$State.CertificatesAdded+= [pscustomobject]@{Store=$store;Thumbprint=$Thumbprint}}
        }
    }
    Write-InputFilterState $State
}
function Set-InputFilterPendingControllers([int]$Code,[string]$DriverSHA256) {
    $state=Read-InputFilterState
    if(!$state){throw 'Installation journal missing for controller association.'}
    $pending=[pscustomobject]@{Pending=($Code -eq 3010);UsbMigrationVerified=($Code -eq 0);DriverSHA256=$DriverSHA256;Boot=(Get-CimInstance Win32_OperatingSystem).LastBootUpTime.ToUniversalTime().ToString('o');LastError=0}
    $state|Add-Member -NotePropertyName ControllerAssociation -NotePropertyValue $pending -Force
    Write-InputFilterState $state
    if($pending.Pending){
        Write-Host 'Controller association is pending. Restart Windows normally and reopen this installer.'
        Write-Host 'An upgrade may require two restarts: one to load the new driver, then one to load the migrated controller filters.'
    }
}
function Install-InputFilterRecovery {
    $root=Assert-InputFilterDirectory (Get-InputFilterRecoveryRoot) (Join-Path $env:ProgramFiles 'WindowsInputFilter\Recovery')
    $existing=Get-Service -Name WindowsInputFilterRecovery -ErrorAction SilentlyContinue
    if($existing){
        $image=[string](Get-ItemProperty -LiteralPath 'HKLM:\SYSTEM\CurrentControlSet\Services\InputFilterRecovery' -Name ImagePath).ImagePath
        if($image.Trim('"') -ine (Join-Path $root 'Recovery\InputFilterRecovery.exe')){throw 'A different recovery service already uses this name.'}
        if($existing.Status -ne 'Stopped'){$existing.Stop();$existing.WaitForStatus('Stopped',[TimeSpan]::FromSeconds(35))};$existing.Dispose()
    }
    $security=Get-Acl -LiteralPath (Get-InputFilterDataRoot)
    if(!(Test-Path -LiteralPath $root)){[IO.Directory]::CreateDirectory($root,$security)|Out-Null}else{Set-Acl -LiteralPath $root -AclObject $security}
    foreach($relative in @('Common.ps1','Maintenance.ps1','Lifecycle.ps1','Uninstall.ps1','EmergencyRecover.ps1','FinalizeUninstall.ps1','Recovery\InputFilterRecovery.exe','Recovery\RecoveryBinding.dll','Payload\InputFilterExample.exe')){
        $source=Join-Path $PSScriptRoot $relative;$target=Join-Path $root $relative
        [IO.Directory]::CreateDirectory([IO.Path]::GetDirectoryName($target))|Out-Null
        if([IO.Path]::GetFullPath($source) -ine [IO.Path]::GetFullPath($target)){Copy-Item -LiteralPath $source -Destination $target -Force}
    }
    if(!$existing){New-Service -Name WindowsInputFilterRecovery -DisplayName 'InputFilter emergency recovery' -BinaryPathName ('"'+(Join-Path $root 'Recovery\InputFilterRecovery.exe')+'"') -StartupType Automatic -DependsOn Winmgmt|Out-Null}
    # Automatic start at next boot, never during an installation's mutex hold.
}
function Stop-InputFilterRecovery {
    $service=Get-Service -Name WindowsInputFilterRecovery -ErrorAction SilentlyContinue
    if($service){try{if($service.Status -ne 'Stopped'){$service.Stop();$service.WaitForStatus('Stopped',[TimeSpan]::FromSeconds(35))}}finally{$service.Dispose()}}
}
function Remove-InputFilterRecoveryService {
    Stop-InputFilterRecovery
    if(Test-Path -LiteralPath 'HKLM:\SYSTEM\CurrentControlSet\Services\InputFilterRecovery'){
        $result=Invoke-InputFilterProcess (Get-InputFilterWindowsTool 'sc.exe') @('delete','WindowsInputFilterRecovery') -TimeoutMs 30000
        if($result.ExitCode -notin @(0,1060,1072)){throw ('Recovery service deletion failed: '+$result.ExitCode)}
        $script:InputFilterNeedsReboot=$script:InputFilterNeedsReboot -or $result.ExitCode -eq 1072
    }
}
function Remove-InputFilterOwnedTree([string]$Path,[string]$Expected) {
    $target=Assert-InputFilterDirectory $Path $Expected
    if(!(Test-Path -LiteralPath $target)){return}
    $pending=New-Object Collections.Generic.Stack[string];$pending.Push($target)
    while($pending.Count){foreach($item in Get-ChildItem -LiteralPath $pending.Pop() -Force){
        if($item.Attributes -band [IO.FileAttributes]::ReparsePoint){throw ('Refusing cleanup through reparse point: '+$item.FullName)}
        if($item.PSIsContainer){$pending.Push($item.FullName)}
    }}
    Remove-Item -LiteralPath $target -Recurse -Force
}
function Register-InputFilterFinalCleanup {
    Get-InputFilterFinalCleanupTask|Out-Null
    $root=Get-InputFilterRecoveryRoot
    if(!(Test-Path -LiteralPath (Join-Path $root 'FinalizeUninstall.ps1'))){Install-InputFilterRecovery}
    $action=New-ScheduledTaskAction -Execute (Join-Path $env:WINDIR 'System32\WindowsPowerShell\v1.0\powershell.exe') -Argument ('-NoProfile -NonInteractive -ExecutionPolicy Bypass -File "'+(Join-Path $root 'FinalizeUninstall.ps1')+'"')
    $trigger=New-ScheduledTaskTrigger -AtStartup
    $settings=New-ScheduledTaskSettingsSet -StartWhenAvailable -ExecutionTimeLimit ([TimeSpan]::FromMinutes(10)) -AllowStartIfOnBatteries -DontStopIfGoingOnBatteries
    Register-ScheduledTask -TaskName 'InputFilterCompleteUninstall' -Action $action -Trigger $trigger -Settings $settings -User 'S-1-5-18' -RunLevel Highest -Force|Out-Null
}
function Remove-InputFilterFinalCleanup {
    if(Get-InputFilterFinalCleanupTask){Unregister-ScheduledTask -TaskName InputFilterCompleteUninstall -Confirm:$false}
}
function Get-InputFilterFinalCleanupTask {
    $task=Get-ScheduledTask -TaskName InputFilterCompleteUninstall -ErrorAction SilentlyContinue
    if(!$task){return $null}
    $expectedExecute=Join-Path $env:WINDIR 'System32\WindowsPowerShell\v1.0\powershell.exe'
    $expectedArguments='-NoProfile -NonInteractive -ExecutionPolicy Bypass -File "'+(Join-Path (Get-InputFilterRecoveryRoot) 'FinalizeUninstall.ps1')+'"'
    $isSystem=$false
    try{
        $id=[string]$task.Principal.UserId
        $sid=if($id -match '^S-1-') {New-Object Security.Principal.SecurityIdentifier($id)}else{(New-Object Security.Principal.NTAccount($id)).Translate([Security.Principal.SecurityIdentifier])}
        $isSystem=$sid.Value -eq 'S-1-5-18'
    }catch{$isSystem=$false}
    if(@($task.Actions).Count -ne 1 -or $task.Actions[0].Execute -ine $expectedExecute -or $task.Actions[0].Arguments -cne $expectedArguments -or !$isSystem){throw 'An unrelated scheduled task uses the InputFilter cleanup name; it will not be changed.'}
    return $task
}
function Invoke-InputFilterCleanUninstall([switch]$Finalize) {
    Import-InputFilterRecoveryAssembly
    Stop-InputFilterRecovery
    $state=Read-InputFilterState
    $reboot=$false
    if($state){
        $saved=[InputFilterRecovery.Devices]::Read((ConvertTo-Json -InputObject @($state.Devices) -Depth 10))
        $owned=@{};foreach($current in [InputFilterRecovery.Devices]::Snapshot()){if($current.Service -eq 'WindowsInputFilter'){$owned[$current.Instance]=$true}}
        foreach($device in $saved){if($owned.ContainsKey($device.Instance) -and $device.Service -in @('kbdhid','mouhid')){
            try{$reboot=[InputFilterRecovery.Devices]::RestoreMapper($device,(Join-Path $PSScriptRoot 'Recovery\RecoveryBinding.dll')) -or $reboot}
            catch{Write-Host ('Original binding unavailable; restoring the Windows mapper: '+$device.Instance+'; '+$_.Exception.Message)}
        }}
    }
    Set-InputFilterPhase 'Restore original Windows input bindings'
    $helper=Join-Path $PSScriptRoot 'Payload\InputFilterExample.exe'
    $restore=Invoke-InputFilterSetupHelper $helper @('--restore')
    if($restore -notin @(0,3010)){throw ("Windows input restoration failed ("+$restore+"). Recovery files retained.")}
    $reboot=$reboot -or $restore -eq 3010
    if($state){foreach($device in $saved){[InputFilterRecovery.Devices]::RestoreFilter($device.Instance,$device.Upper);[InputFilterRecovery.Devices]::RestoreFilter($device.Instance,$device.Lower)}}
    $reboot=[InputFilterRecovery.Devices]::CleanClassFilters() -or $reboot
    # Pending devnode restarts are not proof that old stacks stopped using
    # the image. Preserve packages and recovery until a normal Windows boot.
    $owned=Get-InputFilterSetupState $helper
    if($reboot -or @($owned.devices).Count){
        return Set-InputFilterUninstallPending $state -Finalize:$Finalize
    }
    Set-InputFilterPhase 'Remove unbound owned driver packages'
    foreach($package in Get-InputFilterPackages){Remove-InputFilterPackage $package.Driver}
    $reboot=$reboot -or $script:InputFilterNeedsReboot
    $remaining=@(Get-InputFilterPackages)
    $driver=Get-Service -Name WindowsInputFilter -ErrorAction SilentlyContinue
    if($driver){$running=$driver.Status -ne 'Stopped';$driver.Dispose();$delete=Invoke-InputFilterProcess (Get-InputFilterWindowsTool 'sc.exe') @('delete','WindowsInputFilter') -TimeoutMs 30000;if($delete.ExitCode -notin @(0,1060,1072)){throw ('Driver service removal failed: '+$delete.ExitCode)};$reboot=$reboot -or $running -or $delete.ExitCode -eq 1072}
    if($remaining.Count){$reboot=$true}
    if($state){foreach($cert in $state.CertificatesAdded){
        if($cert.Store -notin @('Root','TrustedPublisher') -or $cert.Thumbprint -notmatch '^[A-Fa-f0-9]{40}$'){throw 'Invalid certificate restoration entry.'}
        $path='Cert:\LocalMachine\'+$cert.Store+'\'+$cert.Thumbprint
        if(Test-Path -LiteralPath $path){Remove-Item -LiteralPath $path}
    }}
    Remove-InputFilterRecoveryService
    if($reboot -or $script:InputFilterNeedsReboot){return Set-InputFilterUninstallPending $state -Finalize:$Finalize}
    Remove-InputFilterFinalCleanup
    return 0
}

function Set-InputFilterUninstallPending($State,[switch]$Finalize) {
    if(!$State){$State=[pscustomobject]@{Schema=1;Devices=@();CertificatesAdded=@();PendingUninstall=$true;FinalizeAttempts=0}}
    $State.PendingUninstall=$true
    if($Finalize){
        $State.FinalizeAttempts++
        if($State.FinalizeAttempts -gt 3){Write-InputFilterState $State;throw 'Cleanup is still pending after three boots; recovery state is retained for diagnosis.'}
    }else{$State.FinalizeAttempts=0}
    Write-InputFilterState $State
    Register-InputFilterFinalCleanup
    Write-Host 'Input restoration or package removal requires a restart. Remaining packages and recovery are retained for automatic cleanup after the next normal boot.'
    return 3010
}
