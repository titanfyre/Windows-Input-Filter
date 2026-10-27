# Windows Input Filter: installation

Version 0.1.0.0 has a verified matching Microsoft-signed package. The [demo ZIP](https://github.com/titanfyre/Windows-Input-Filter/releases/download/v0.1.0.0/Windows-Input-Filter-0.1.0.0-Demo.zip) contains both installers; the SDK ZIP contains source and the signed binary build inputs. Never rename another edition's driver or disable signature enforcement.

Run `InputFilterSetup.exe` as administrator and choose Install /
reinstall. Restart when requested. Console automation uses
`InputFilterSetupConsole.exe /install` or `/uninstall`.

This edition's service is `WindowsInputFilter`. Setup refuses overlapping original/new
input editions and stale filters. Complete their uninstall and restart first.
The keyboard/mouse-only and gamepad-only editions may coexist. The installer
does not remove another product's service or data.

The UI starts observation automatically. Stop or close it to release capture.
One hour after first capture, demo expiry also releases capture to passthrough.
