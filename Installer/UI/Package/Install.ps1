. (Join-Path $PSScriptRoot 'Common.ps1')
$code=1;$logged=$false;$bindingStarted=$false;$stagingStarted=$false;$existingPackages=@()
try {
    Assert-Administrator
    $payload=Join-Path $PSScriptRoot 'Payload'
    Assert-InputFilterPayload $payload|Out-Null
    Assert-InputFilterUsbPackage $payload
    Get-InputFilterWindowsTool 'pnputil.exe'|Out-Null
    Get-InputFilterWindowsTool 'sc.exe'|Out-Null
    Enter-InputFilterOperation
    Assert-InputFilterInstallationBoundary
    Start-InputFilterLog 'install';$logged=$true
    Set-InputFilterPhase 'Snapshot original Windows device bindings'
    $baseline=Save-InputFilterBaseline
    $baseline.PendingUninstall=$false;$baseline.FinalizeAttempts=0;Write-InputFilterState $baseline
    $helper=Join-Path $payload 'InputFilterExample.exe'
    $script:InputFilterBeforeSetup=Get-InputFilterSetupState $helper
    $existingPackages=@(Get-InputFilterPackages|ForEach-Object Driver)
    Set-InputFilterPhase 'Prepare protected recovery'
    Remove-InputFilterFinalCleanup
    Install-InputFilterRecovery
    Set-InputFilterPhase 'Stage Microsoft-signed driver packages'
    $stagingStarted=$true
    foreach($name in @('WindowsInputFilterKeyboard.inf','WindowsInputFilterMouse.inf','WindowsInputFilterControl.inf')){Add-InputFilterPackage (Join-Path $payload $name)}
    Set-InputFilterPhase 'Associate supported device instances'
    $bindingStarted=$true
    $code=Invoke-InputFilterSetupHelper $helper @('--install',$payload)
    if($code -notin @(0,3010)){throw ('Device association failed: '+$code)}
    if($code -eq 0){
        if((Invoke-InputFilterSetupHelper $helper @('--status') 20000) -ne 0){throw 'Driver API did not respond after installation.'}
        Set-InputFilterPhase 'Initialize supported input interfaces'
        $code=Initialize-WindowsInputFilterControllers $helper
        if($code -notin @(0,3010)){throw ('Input interface initialization failed: '+$code)}
    }
    if($script:InputFilterNeedsReboot){$code=3010}
    Set-InputFilterPhase 'Verify Windows device startup'
    $code=Wait-InputFilterSetupDevices $helper $script:InputFilterBeforeSetup -RestartRequested:($code -eq 3010)
    Set-InputFilterPendingControllers $code (Get-FileHash -LiteralPath (Join-Path $payload 'WindowsInputFilter.sys') -Algorithm SHA256).Hash
    Get-InputFilterPackages|Select-Object Driver,OriginalFileName|ConvertTo-Json|Set-Content -LiteralPath (Join-Path (Get-InputFilterDataRoot) 'packages.json') -Encoding UTF8
    Complete-InputFilterOperation $code
    Write-Host 'Installation verified. Physical input passes through until an application opens capture.'
}catch{
    $code=if($logged){Write-InputFilterFailure $_}else{Write-Host $_.Exception.ToString();if($script:InputFilterLastExitCode -notin @(0,3010)){$script:InputFilterLastExitCode}else{1}}
    $safeToRemove=$false
    if($script:InputFilterProcessTimedOut){
        Write-Host 'A setup command exceeded its deadline. Binding rollback and package deletion are deferred; recovery and operation evidence are retained. Restart Windows normally, then retry.'
    }elseif($bindingStarted){
        try{
            Write-Host 'Restoring Windows input bindings after the failed installation...'
            $restore=Invoke-InputFilterSetupHelper $helper @('--restore')
            if($restore -eq 0){
                $remaining=Get-InputFilterSetupState $helper
                $safeToRemove=@($remaining.devices).Count -eq 0
            }
            if(!$safeToRemove){Write-Host ('Restoration is incomplete or needs a restart (code '+$restore+'). Driver packages and recovery files are retained.')}
        }catch{Write-Host ('Restoration failed; driver packages and recovery are retained: '+$_.Exception.Message)}
    }else{$safeToRemove=$true}
    if($stagingStarted -and $safeToRemove){
        try{foreach($package in (Get-InputFilterPackages|Where-Object {$_.Driver -notin $existingPackages})){Remove-InputFilterPackage $package.Driver}}
        catch{Write-Host ('Owned package cleanup is pending: '+$_.Exception.Message)}
    }
}finally{
    try{if($logged){Stop-Transcript|Out-Null}}finally{Exit-InputFilterOperation}
}
exit $code
