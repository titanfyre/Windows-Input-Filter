# Windows Input Filter — Windows Kernel Filter Driver for Keyboard, Mouse and Gamepad

Receive, edit and forward **keyboard, mouse and compatible HID/XInput/GIP controller input** with a native **C++17 two-file SDK**.
Windows 10 1709+ / Windows 11 x64. The library manages the capture session and
automatically selects the right transport when you submit an input batch.

**Demo 0.1.0.0 — Microsoft signing pending.** SDK source, console examples and
the input viewer can be built now. Installable setup EXEs will be published after
the matching Microsoft-signed package returns. Existing signed Interceptor
binaries are not redistributed under this new driver identity.

[API](docs/API.md) · [Build](docs/BUILD.md) · [Installation](docs/INSTALLATION.md) ·
[Compatibility](docs/COMPATIBILITY.md) · [Examples](ExamplesConsole/README.md)

## Receive, change, submit

Compile `InputFilter/InputFilter.cpp` with your application and include
`InputFilter.h`. After installing the matching driver, run as administrator:

```cpp
#include "InputFilter.h"

int main() {
    for (;;) {
        auto events = InputFilter::Receive(1000);
        // Inspect and edit events here.
        if (!InputFilter::Submit(events)) return 1;
    }
}
```

`Receive()` returns a move-only `Batch`. The timeout is a maximum wait when no
input is available, not an extra delay for ready input. Inspect an event using
`event.Get<MouseEvent>()`, `event.Get<KeyboardEvent>()`, `event.Get<HidEvent>()`,
`event.Get<XInputEvent>()`, `event.Get<XInputHidEvent>()` or `event.Get<GipEvent>()`
for the families included in this edition. Unrelated types return null.

Keyboard and mouse payloads use `state`; controller payloads also expose their
decoded `state`. `Submit()` infers the family and count. Finish each batch on its
receiving thread before receiving another. The examples include explanatory
console text and report errors from the installed driver.

## One-hour demo

The allowance starts at the first successful capture and lasts **one hour per
Windows kernel boot**, shared by applications using this edition. Closing or
reopening an application does not reset it. Expiry releases capture and restores
physical input passthrough. Use Windows Restart for a new allowance.

The input projects and Windows Virtual Devices use a shared resident
`DemoSessionClock.sys` with separate edition slots. The original demos retain
their own separate clock identity. No paid Release edition is included here.

## Install when the signed package is available

Open **InputFilterSetup.exe**, accept the administrator prompt and choose
**Install / reinstall**. Restart when requested. Console automation uses
`InputFilterSetupConsole.exe /install` or `/uninstall`.

The service is `WindowsInputFilter`. Setup only owns this edition's packages, bindings,
recovery service and protected directories. Overlapping original and new input
editions must be uninstalled, followed by a Windows restart, before switching.
The keyboard/mouse-only and gamepad-only editions may coexist. Run one capture
application per edition at a time.

## Build the SDK and examples

```powershell
.\Build.ps1 -Target SDK
.\Build.ps1 -Target ExamplesConsole
.\Build.ps1 -Target ExamplesUI
```

Requires Visual Studio 2022 C++ tools, CMake and the Windows SDK. Builds do not
install or capture devices. Installer source is included; its recovery components
are supplied as precompiled user-mode binaries. Kernel source, PDBs and private
signing/build/test material are not published. Installer builds require this
edition's matching signed payload and retain Microsoft signature checks.

## Origin and licensing

This is an independently packaged derivative of the existing Interceptor
implementation, with a new API and product identity. The MIT copyright and
permission notices and the original Interception acknowledgment are retained in
`LICENSE` and `licenses/NOTICE`. This is not an official Microsoft product.

Source: MIT. Prebuilt kernel packages: separate demo terms in
`licenses/BINARY-LICENSE.txt`. For commercial licensing contact **titancsa** on
Discord. Use only on systems you are authorized to control. The software is
provided as-is; the author is not responsible for unlawful use or resulting
damage, to the extent permitted by applicable law. Signing does not guarantee
compatibility with every device, game or other installed driver.
