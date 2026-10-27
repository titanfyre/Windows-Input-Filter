param([switch]$Emergency,[switch]$Finalize)
. (Join-Path $PSScriptRoot 'Common.ps1')
$code=1;$logged=$false
try {
    Assert-Administrator;Enter-InputFilterOperation
    if($Finalize){$pending=Read-InputFilterState;if(!$pending -or !$pending.PendingUninstall){Write-Host 'No pending InputFilter cleanup; newer installation preserved.';$code=0;exit 0}}
    Get-InputFilterWindowsTool 'pnputil.exe'|Out-Null
    Get-InputFilterWindowsTool 'sc.exe'|Out-Null
    Start-InputFilterLog 'uninstall';$logged=$true
    Set-InputFilterPhase 'Prepare Windows input restoration'
    $code=Invoke-InputFilterCleanUninstall -Finalize:$Finalize
    Complete-InputFilterOperation $code
    Write-Host 'Windows input restoration processed. Boot settings and pre-existing certificates preserved.'
    if($code -eq 0){
        Stop-Transcript|Out-Null;$logged=$false
        Remove-InputFilterOwnedTree (Get-InputFilterRecoveryRoot) (Join-Path $env:ProgramFiles 'WindowsInputFilter\Recovery')
        $parent=Join-Path $env:ProgramFiles 'WindowsInputFilter'
        if((Test-Path -LiteralPath $parent) -and @(Get-ChildItem -LiteralPath $parent -Force).Count -eq 0){Remove-Item -LiteralPath $parent}
        Remove-InputFilterOwnedTree (Get-InputFilterDataRoot) (Join-Path $env:ProgramData 'WindowsInputFilter')
    } else {Write-Host 'Windows requires a restart. Remaining owned files will be removed automatically after that restart.'}
} catch {$code=if($logged){Write-InputFilterFailure $_}else{Write-Host $_.Exception.ToString();if($script:InputFilterLastExitCode -notin @(0,3010)){$script:InputFilterLastExitCode}else{1}}}
finally {try{if($logged){Stop-Transcript|Out-Null}}finally{Exit-InputFilterOperation}}
if($Emergency -and $code -eq 3010){
    & (Join-Path $env:WINDIR 'System32\shutdown.exe') /r /t 30 /d p:2:4 /c 'InputFilter emergency recovery: restart required to finish restoring Windows input drivers.'
}
exit $code
