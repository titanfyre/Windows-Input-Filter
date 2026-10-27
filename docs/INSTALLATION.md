# Windows Input Filter: installation

Version 0.1.0.0 requires a matching Microsoft-signed package. Until it returns,
SDK and example builds are available, but installer downloads are pending. Do
not reuse an earlier driver/catalog under the new identity or disable signature
enforcement.

When available, run `InputFilterSetup.exe` as administrator and choose Install /
reinstall. Restart when requested. Console automation uses
`InputFilterSetupConsole.exe /install` or `/uninstall`.

This edition's service is `WindowsInputFilter`. Setup refuses overlapping original/new
input editions and stale filters. Complete their uninstall and restart first.
The keyboard/mouse-only and gamepad-only editions may coexist. The installer
does not remove another product's service or data.

The UI starts observation automatically. Stop or close it to release capture.
One hour after first capture, demo expiry also releases capture to passthrough.
