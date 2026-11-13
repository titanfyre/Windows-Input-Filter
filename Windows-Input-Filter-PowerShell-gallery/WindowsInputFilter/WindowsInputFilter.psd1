@{
RootModule = 'WindowsInputFilter.psm1'
ModuleVersion = '1.0.0'
GUID = '96b6e6ac-c058-5524-9768-2e85598a3f19'
Author = 'TitanCSA'
Description = 'Windows x64 Windows-Input-Filter input SDK for PowerShell 7.4+. Driver installed separately.'
PowerShellVersion = '7.4'
CompatiblePSEditions = @('Core')
FunctionsToExport = @('Connect-WindowsInputFilterSDK','Initialize-WindowsInputFilterSDK','Get-WindowsInputFilterSDKInfo','Get-WindowsInputFilterSDKDevice','Receive-WindowsInputFilterSDKInput','Send-WindowsInputFilterSDKBatch','Remove-WindowsInputFilterSDKBatch','Stop-WindowsInputFilterSDKWait','Get-WindowsInputFilterSDKDescriptor','Send-WindowsInputFilterSDKInput','Disconnect-WindowsInputFilterSDK')
CmdletsToExport = @()
VariablesToExport = @()
AliasesToExport = @()
PrivateData = @{ PSData = @{ Tags = @('Windows','SDK','Keyboard','Mouse','Gamepad'); LicenseUri = 'https://github.com/titanfyre/Windows-Input-Filter/blob/main/LICENSE'; ProjectUri = 'https://github.com/titanfyre/Windows-Input-Filter'; ReleaseNotes = 'First PowerShell SDK; docs and native bridge included.' } }
}
