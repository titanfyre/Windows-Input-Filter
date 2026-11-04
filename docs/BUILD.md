# Build

Use Windows x64, Visual Studio 2022 C++ tools, CMake and a Windows SDK.
`Build.ps1 -Target SDK` builds the two-file SDK. `ExamplesConsole` and `ExamplesUI`
build their respective examples. Build output is ignored by Git. No driver is
installed by building. Demo driver source and its build/license notes are documented in [driver/README.md](../driver/README.md). Full/commercial driver implementation, private PDBs and signing authoring material are excluded. Installer builds additionally need the matching signed payload and the
precompiled recovery files supplied with the final demo package.
