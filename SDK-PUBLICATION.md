# SDK publication status

Current source layout and registry coverage. A GitHub download is distinct from publication on a central registry.

| Target | Status | Package / documentation |
| --- | --- | --- |
| CPP/vcpkg | published_custom_registry | windows-input-filter |
| CPP/conan | public_recipe_builds_locally |  [Source](packaging/native/) |
| CPP/nuget | paused_pending_owner_email_confirmation | Windows-Input-Filter.Native |
| NET/nuget | built_verified_publication_on_hold_by_owner | WindowsInputFilter.SDK [Source](Windows-Input-Filter-NET-nuget/) |
| Python/pypi | built_fixture_and_production_verified | windows-input-filter [Source](Windows-Input-Filter-Python-pypi/) |
| Python/conda-forge | built_tested_requires_official_review | windows-input-filter [Source](packaging/conda/) |
| Rust/cargo | published_install_verified | [windows-input-filter](https://crates.io/crates/windows-input-filter) [Source](Windows-Input-Filter-Rust-cargo/) |
| JavaScript/npm | awaiting_browser_publication_authentication | [windows-input-filter](https://www.npmjs.com/package/windows-input-filter) [Source](Windows-Input-Filter-JavaScript-npm/) |
| Java/maven | published_install_verified | [windows-input-filter](https://central.sonatype.com/artifact/io.github.titancsa/windows-input-filter/1.0.0) [Source](Windows-Input-Filter-Java-maven/) |
| Java/jitpack | published_install_verified | [windows-input-filter](https://jitpack.io/#titanfyre/Windows-Input-Filter/java-sdk-v1.0.0) [Source](Windows-Input-Filter-Java-maven/) |
| Go/modules | published_install_verified | [windows-input-filter](https://pkg.go.dev/github.com/titanfyre/Windows-Input-Filter/Windows-Input-Filter-Go-modules@v1.0.0) [Source](Windows-Input-Filter-Go-modules/) |
| Go/pkg-go-dev | indexed_verified | [Documentation](https://pkg.go.dev/github.com/titanfyre/Windows-Input-Filter/Windows-Input-Filter-Go-modules@v1.0.0) |
| PowerShell/gallery | published_install_verified | [WindowsInputFilter](https://www.powershellgallery.com/packages/WindowsInputFilter/1.0.0) [Source](Windows-Input-Filter-PowerShell-gallery/) |
| Dart/pub-dev | published_install_verified | [windows_input_filter](https://pub.dev/packages/windows_input_filter) [Source](Windows-Input-Filter-Dart-pub-dev/) |
| Ruby/rubygems | published_install_verified | [windows-input-filter](https://rubygems.org/gems/windows-input-filter) [Source](Windows-Input-Filter-Ruby-rubygems/) |
| PHP/packagist | composer_source_and_tag_published | [titancsa/windows-input-filter](https://packagist.org/packages/titancsa/windows-input-filter) |

Native SDK source and CMake/Conan/vcpkg/NuGet recipes share [`packaging/native`](packaging/native/LAYOUT.md). Previous release archives and tags remain unchanged.

Application and driver prerequisites and original licensing remain those documented by each SDK. No driver installer is bundled with these source packages.
