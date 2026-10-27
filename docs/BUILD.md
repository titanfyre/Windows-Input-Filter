# Build

Use Windows x64, Visual Studio 2022 C++ tools, CMake and a Windows SDK.
`Build.ps1 -Target SDK` builds the two-file SDK. `ExamplesConsole` and `ExamplesUI`
build their respective examples. Build output is ignored by Git. No driver is
installed by building. Driver source and kernel/PDB/signing authoring tools are
private. Installer builds additionally need the matching signed payload and the
precompiled recovery files supplied with the final demo package.
