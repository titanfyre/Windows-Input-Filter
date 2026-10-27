# C++ API

The complete API is declared in `InputFilter/InputFilter.h`. Compile the paired CPP once.

| Function | Purpose |
| --- | --- |
| `Initialize()` | Associate supported devices using installed packages. Elevated; reports ready, reboot_required and error. |
| `Receive(timeout, stopEvent)` | Return a move-only `Batch` of `Event` objects. Automatically opens the capture session. |
| `Submit(events)` | Submit a batch, event or typed container; returns accepted count and Windows error. |
| `Devices()` | Current device list and capture-scoped string tokens. |
| `Inspect(device.token)` | Read details for the exact current device. |
| `Snapshot()` | Capture/device/trial status snapshot. |
| `Descriptor(token)` | Descriptor/metadata information applicable to the device family. |
| `ReportDescriptor(token)` | Raw HID report descriptor when available; non-applicable families are reported explicitly. |

Use `event.Get<KeyboardEvent>()`, `event.Get<MouseEvent>()`, `event.Get<HidEvent>()`,
`event.Get<XInputEvent>()`, `event.Get<XInputHidEvent>()`, or `event.Get<GipEvent>()`
for families included in this edition. It returns null for another type. Keyboard
and mouse events expose their payload as `.state`; controller state is decoded.
Family convenience readers are `ReadKeyboard`, `ReadMouse`, `ReadHid`, `ReadXInput`,
`ReadXInputHid`, `ReadGip` and `ReadGipRaw` where applicable. Device ID and consume
arguments are optional. Do not mix multiple readers while holding a live batch.

No caller-owned global context or explicit create/destroy step is required. The
library retains source identity when submitting; do not construct guessed device
tokens. Tokens identify the current capture, not a permanently enrolled machine.

## Optional status queries

`Status()`, `Capabilities()` and `TrialStatus()` query the loaded driver without
starting capture. `Availability(token)` reports a current device's readiness.
`CloseCapture()` explicitly releases the automatic capture after readers/batches
finish; the next input operation can reopen it, without resetting the demo.
