# Windows-Input-Filter PowerShell SDK

`Install-Module WindowsInputFilter -Scope CurrentUser`

Requires PowerShell 7.4+ on Windows x64. Supported families: keyboard, mouse, hid, xinput, xinputhid, gip. The native product SDK and license/trial behavior are unchanged. No driver is installed on import or construction.

```powershell
Import-Module WindowsInputFilter
$client = Connect-WindowsInputFilterSDK
try { Get-WindowsInputFilterSDKInfo -Client $client }
finally { Disconnect-WindowsInputFilterSDK -Client $client }
```

See [API guide](docs/API.md) and `Get-Command -Module WindowsInputFilter`. The matching driver is installed separately.
