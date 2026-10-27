. (Join-Path $PSScriptRoot 'Common.ps1')
$code=1;$logged=$false
try {
    Assert-Administrator
    $payload=Join-Path $PSScriptRoot 'Payload'
    $mode=Assert-InputFilterPayload $payload
    Assert-InputFilterUsbPackage $payload
    Enter-InputFilterOperation;Start-InputFilterLog 'association';$logged=$true
    $payload=Join-Path $PSScriptRoot 'Payload'
    $helper=Join-Path $payload 'InputFilterExample.exe'
    $mode=Assert-InputFilterPayload $payload
    Set-InputFilterPhase 'Snapshot devices before association'
    Save-InputFilterBaseline|Out-Null
    $script:InputFilterBeforeSetup=Get-InputFilterSetupState $helper
    Set-InputFilterPhase 'Associate supported device instances'
    # Bind using INF files already present in the Driver Store; do not stage or
    # upgrade the bundled driver and do not import certificates in this command.
    $packages=@(Get-InputFilterPackages)
    $paths=@()
    foreach($name in @('WindowsInputFilterKeyboard.inf','WindowsInputFilterMouse.inf','WindowsInputFilterControl.inf')) {
        $package=$packages | Where-Object { [IO.Path]::GetFileName($_.OriginalFileName) -eq $name } |
            Sort-Object { [version]$_.Version } -Descending | Select-Object -First 1
        if(!$package -or !(Test-Path -LiteralPath $package.OriginalFileName)) { throw 'Pilote absent du magasin Windows. Executer Installer.bat une premiere fois.' }
        $paths+= $package.OriginalFileName
    }
    $code=Initialize-WindowsInputFilterControllers $helper
    Set-InputFilterPhase 'Verify Windows device startup'
    $code=Wait-InputFilterSetupDevices $helper $script:InputFilterBeforeSetup -RestartRequested:($code -eq 3010)
    Set-InputFilterPendingControllers $code (Get-FileHash -LiteralPath (Join-Path $payload 'WindowsInputFilter.sys') -Algorithm SHA256).Hash
    Complete-InputFilterOperation $code
    Write-Host 'Association terminee. Les pilotes tiers sont laisses en place.'
    if($code -eq 3010) { Write-Host 'Windows demande un redemarrage pour terminer.' }
} catch {$code=if($logged){Write-InputFilterFailure $_}else{Write-Host $_.Exception.ToString();if($script:InputFilterLastExitCode -notin @(0,3010)){$script:InputFilterLastExitCode}else{1}}}
finally {try{if($logged){Stop-Transcript|Out-Null}}finally{Exit-InputFilterOperation}}
exit $code
