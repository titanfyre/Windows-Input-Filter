. (Join-Path $PSScriptRoot 'Common.ps1')
$code=1;$logged=$false
try {
    Assert-Administrator;Enter-InputFilterOperation
    Import-InputFilterRecoveryAssembly
    $state=Read-InputFilterState
    if(!$state -or $state.PendingUninstall -or !$state.ControllerAssociation){$code=0}
    else {
        Start-InputFilterLog 'complete-association';$logged=$true
        $payload=Join-Path $PSScriptRoot 'Payload'
        Assert-InputFilterPayload $payload|Out-Null
        Assert-InputFilterUsbPackage $payload
        $expected=(Get-FileHash -LiteralPath (Join-Path $payload 'WindowsInputFilter.sys') -Algorithm SHA256).Hash
        if($state.ControllerAssociation.DriverSHA256 -cne $expected){throw 'Un autre paquet a demande cette association. Reouvrir son installeur ; aucune association modifiee.'}
        $boot=(Get-CimInstance Win32_OperatingSystem).LastBootUpTime.ToUniversalTime().ToString('o')
        if(!$state.ControllerAssociation.Pending -and $state.ControllerAssociation.UsbMigrationVerified){$code=0}
        elseif($state.ControllerAssociation.Pending -and $state.ControllerAssociation.Boot -eq $boot){
            Write-Host 'Windows doit redemarrer avant la suite des associations. Aucun peripherique redemarre par ce script.';$code=3010
        } else {
            $driver=Get-CimInstance Win32_SystemDriver -Filter "Name='WindowsInputFilter'"
            $driverPath=[string]$driver.PathName
            if($driverPath.StartsWith('\SystemRoot\',[StringComparison]::OrdinalIgnoreCase)){$driverPath=Join-Path $env:WINDIR $driverPath.Substring(12)}
            $driverPath=$driverPath -replace '^\\\?\?\\',''
            if(!$driver -or $driver.State -ne 'Running' -or (Get-FileHash -LiteralPath $driverPath -Algorithm SHA256).Hash -cne $expected){throw 'Le pilote attendu ne fonctionne pas apres redemarrage. Association differee conservee.'}
            $helper=Join-Path $payload 'InputFilterExample.exe'
            if((Invoke-InputFilterSetupHelper $helper @('--status')) -ne 0){throw 'API du pilote indisponible apres redemarrage.'}
            # Include devices first connected after the initial installation
            # in the same protected restoration journal before editing filters.
            Set-InputFilterPhase 'Resume pending device association'
            $state=Save-InputFilterBaseline
            $script:InputFilterBeforeSetup=Get-InputFilterSetupState $helper
            # Finish only the deferred input associations. Do not repeat mapper
            # installation or rebind the root control endpoint on every launch.
            # Older installers could clear Pending when an older loaded backend
            # silently skipped XUSB. Missing proof requires verification again,
            # even when that journal currently says Pending=false.
            $state.ControllerAssociation.Pending=$true
            $state.ControllerAssociation|Add-Member -NotePropertyName UsbMigrationVerified -NotePropertyValue $false -Force
            Write-InputFilterState $state
            try{$code=Initialize-WindowsInputFilterControllers $helper}
            catch{$state.ControllerAssociation.LastError=1;Write-InputFilterState $state;throw}
            Set-InputFilterPhase 'Verify Windows device startup'
            $code=Wait-InputFilterSetupDevices $helper $script:InputFilterBeforeSetup -RestartRequested:($code -eq 3010)
            $state=Read-InputFilterState
            $state.ControllerAssociation.Pending=($code -ne 0)
            $state.ControllerAssociation.UsbMigrationVerified=($code -eq 0)
            $state.ControllerAssociation.Boot=$boot
            $state.ControllerAssociation.LastError=if($code -in @(0,3010)){0}else{$code}
            Write-InputFilterState $state
            if($code -notin @(0,3010)){throw ('Association des manettes en echec : '+$code)}
            Write-Host $(if($code -eq 0){'Associations completed with the loaded USB backend. Verify capture in diagnostics.'}else{'Association remains pending. Restart Windows normally and reopen this installer to finish loading the driver or controller filters.'})
        }
    }
    if($logged){Complete-InputFilterOperation $code}
}catch{$code=if($logged){Write-InputFilterFailure $_}else{Write-Host $_.Exception.ToString();if($script:InputFilterLastExitCode -notin @(0,3010)){$script:InputFilterLastExitCode}else{1}}}
finally{try{if($logged){Stop-Transcript|Out-Null}}finally{Exit-InputFilterOperation}}
exit $code
