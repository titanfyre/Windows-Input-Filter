# Windows Input Filter — Windows Kernel Filter Driver for Keyboard, Mouse and Gamepad

Receive, edit and forward **keyboard, mouse and compatible HID/XInput/GIP controller input** with a native **C++17 two-file SDK**.
Windows 10 1709+ / Windows 11 x64. The library manages the capture session and
automatically selects the right transport when you submit an input batch.

<!-- full-version-contact:start -->
> [!IMPORTANT]
> **Get the full version without demo restrictions**
>
> **Discord username: `titancsa`**
>
> Open Discord, choose **Friends > Add Friend**, enter **`titancsa`**, then send a direct message. Ask for the **full version without the demo time limit**, and mention **Windows Input Filter**.
>
> Tell me whether you need personal use, business integration or OEM redistribution, and ask for pricing and license / activation instructions.
<!-- full-version-contact:end -->

**Demo 0.1.0.0 — Microsoft-signed kernel driver.** One hour per Windows kernel boot. Use the matching driver, SDK and installers from this edition.

[Download demo ZIP](https://github.com/titanfyre/Windows-Input-Filter/releases/download/v0.1.0.0/Windows-Input-Filter-0.1.0.0-Demo.zip) · [UI installer](https://github.com/titanfyre/Windows-Input-Filter/releases/download/v0.1.0.0/InputFilterSetup.exe) · [Console installer](https://github.com/titanfyre/Windows-Input-Filter/releases/download/v0.1.0.0/InputFilterSetupConsole.exe) · [SDK + source](https://github.com/titanfyre/Windows-Input-Filter/releases/download/v0.1.0.0/Windows-Input-Filter-0.1.0.0-SDK.zip)

[API](docs/API.md) · [Build](docs/BUILD.md) · [Installation](docs/INSTALLATION.md) ·
[Compatibility](docs/COMPATIBILITY.md) · [Examples](Examples/Console/README.md)

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

## Install the driver

Open **InputFilterSetup.exe**, accept the administrator prompt and choose
**Install / reinstall**. Restart when requested. Console automation uses
`InputFilterSetupConsole.exe /install` or `/uninstall`.

The service is `WindowsInputFilter`. Setup only owns this edition's packages, bindings,
recovery service and protected directories. Overlapping original and new input
editions must be uninstalled, followed by a Windows restart, before switching.
The keyboard/mouse-only and gamepad-only editions may coexist. Run one capture
application per edition at a time.

## Build the SDK and examples

Demo/evaluation driver source is available; see [driver/README.md](driver/README.md) for
build instructions and separate evaluation-source terms. Those terms apply to
Titan-authored driver code. Third-party source licenses and existing application/SDK
licenses remain applicable. Full/commercial implementation and private signing or
activation material are excluded.

```powershell
.\Build.ps1 -Target SDK
.\Build.ps1 -Target ExamplesConsole
.\Build.ps1 -Target ExamplesUI
```

Requires Visual Studio 2022 C++ tools, CMake and the Windows SDK. Builds do not
install or capture devices. Installer source is included; its recovery components
are supplied as precompiled user-mode binaries. Demo driver source and its build/license notes are documented in [driver/README.md](driver/README.md). Full/commercial driver implementation, PDBs and private signing/test material are excluded. Installer builds require this
edition's matching signed payload and retain Microsoft signature checks.

## Origin and licensing

This is an independently packaged derivative of the existing Interceptor
implementation, with a new API and product identity. The MIT copyright and
permission notices and the original Interception acknowledgment are retained in
`LICENSE` and `licenses/NOTICE`. This is not an official Microsoft product.

User-mode source: MIT. Prebuilt kernel packages: separate demo terms in
`licenses/BINARY-LICENSE.txt`. For commercial licensing contact **titancsa** on
Discord. Use only on systems you are authorized to control. The software is
provided as-is; the author is not responsible for unlawful use or resulting
damage, to the extent permitted by applicable law. Signing does not guarantee
compatibility with every device, game or other installed driver.

<!-- central-sdk-packages:start -->
## Paquets et installation

Les sources, licences, guides API et exemples sont regroupes dans [le depot SDK dedie](https://github.com/TitanCSA/sdk-packages/tree/main/projects/Windows-Input-Filter). Choisis le paquet a installer puis execute sa commande dans son dossier.

| Paquet | Registre | Disponibilite | Installation / utilisation |
| --- | --- | --- | --- |
| `windows-input-filter` | vcpkg | Registre TitanCSA disponible (configuration ci-dessous) | `vcpkg install windows-input-filter:x64-windows` |
| `windows-input-filter` | Conan | Registre TitanCSA disponible (configuration ci-dessous) | `conan install --requires=windows-input-filter/0.1.0 -r titancsa --build=missing -s compiler.cppstd=17` |
| `Windows-Input-Filter.Native` | NuGet | Publie et verifie | `Install-Package Windows-Input-Filter.Native -Version 0.1.0` |
| `WindowsInputFilter.SDK` | NuGet | Publie et verifie | `dotnet add package WindowsInputFilter.SDK --version 1.0.0` |
| `windows_input_filter` | PyPI | Pas encore disponible / validation en cours | Commande prevue apres publication : `python -m pip install windows-input-filter==1.0.0` |
| `windows-input-filter` | Conda | Canal TitanCSA disponible ; acceptation conda-forge encore en attente | `conda install --override-channels -c https://raw.githubusercontent.com/TitanCSA/sdk-packages/089bc73095aa8eda89bacbe10d0b9e58394b0207/conda-channel -c conda-forge windows-input-filter` |
| `windows_input_filter` | crates.io | Publie et verifie | `cargo add windows-input-filter@1.0.0` |
| `windows_input_filter` | npm | Pas encore disponible / validation en cours | Commande prevue apres publication : `npm install windows-input-filter@1.0.0` |
| `io.github.titancsa:windows-input-filter` | Maven Central | Publie et verifie | `io.github.titancsa:windows-input-filter:1.0.0 (pom.xml / Gradle)` |
| `com.github.titanfyre:Windows-Input-Filter` | JitPack | Publie et verifie | `com.github.titanfyre:Windows-Input-Filter:java-sdk-v1.0.0 (avec le depot JitPack)` |
| `github.com/titanfyre/Windows-Input-Filter/Windows-Input-Filter-Go-modules` | Go Modules | Publie et verifie | `go get github.com/titanfyre/Windows-Input-Filter/Windows-Input-Filter-Go-modules@v1.0.0` |
| `github.com/titanfyre/Windows-Input-Filter/Windows-Input-Filter-Go-modules` | pkg.go.dev | Publie et verifie | `Documentation : https://pkg.go.dev/github.com/titanfyre/Windows-Input-Filter/Windows-Input-Filter-Go-modules@v1.0.0` |
| `windows_input_filter` | PowerShell Gallery | Publie et verifie | `Install-Module WindowsInputFilter -RequiredVersion 1.0.0 -Scope CurrentUser` |
| `windows_input_filter` | pub.dev | Publie et verifie | `dart pub add windows_input_filter:1.0.0` |
| `windows_input_filter` | RubyGems | Publie et verifie | `gem install windows-input-filter -v 1.0.0` |
| `windows_input_filter` | Packagist | Pas encore disponible / validation en cours | Commande prevue apres publication : `composer require titancsa/windows-input-filter:1.0.0` |

Pour vcpkg et Conan, configure d abord le registre TitanCSA avec [le guide complet](https://github.com/TitanCSA/sdk-packages/tree/main/projects/Windows-Input-Filter/README.md). Le guide explique aussi Maven/Gradle, les prerequis et le chargement des DLL. Les pilotes/applications du produit sont installes separement. Les commandes marquees prevues ne sont pas encore disponibles.

Les anciens imports Go et versions JitPack gardent leurs tags. Pour les anciennes archives SDK, utilise [les liens de remplacement](https://github.com/TitanCSA/sdk-packages/blob/main/release-assets/URL-MIGRATION.json).
<!-- central-sdk-packages:end -->
