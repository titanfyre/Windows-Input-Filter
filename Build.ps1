param(
 [ValidateSet('All','SDK','Native','ExamplesConsole','ExamplesUI','InstallerUI','InstallerConsole')][string]$Target='All',
 [string]$BuildDirectory
)
$ErrorActionPreference='Stop'
$root=$PSScriptRoot
if(!$BuildDirectory){$BuildDirectory=Join-Path $root 'obj\PublicBuild'}
$BuildDirectory=[IO.Path]::GetFullPath($BuildDirectory)
if(![Environment]::Is64BitProcess){throw 'Use Windows PowerShell x64.'}
& cmake -S $root -B $BuildDirectory -G 'Visual Studio 17 2022' -A x64
if($LASTEXITCODE){throw 'CMake configuration failed.'}
$targets=switch($Target){
 'SDK'{@('InputFilterSDK')}
 'ExamplesConsole'{@(Get-ChildItem -LiteralPath (Join-Path $root 'ExamplesConsole') -Filter '*.cpp' -File | ForEach-Object BaseName)}
 'ExamplesUI'{@('InputFilterViewerBridge')}
 default{@()}
}
$arguments=@('--build',$BuildDirectory,'--config','Release','--parallel','2')
if($targets.Count){$arguments+=@('--target')+$targets}
& cmake @arguments
if($LASTEXITCODE){throw 'Native build failed.'}
if($Target -in @('All','ExamplesUI')){
 & (Join-Path $root 'ExamplesUI\Build.ps1') -BridgePath (Join-Path $root 'bin\Native\InputFilterViewerBridge.dll') -OutputDirectory (Join-Path $root 'bin\ExampleUI') -IntermediateDirectory (Join-Path $BuildDirectory 'ExamplesUI')
}
if($Target -in @('InstallerUI','InstallerConsole')){
 if(!(Test-Path -LiteralPath (Join-Path $root 'InstallerUI\Package\Payload\Signing.json'))){throw 'The matching Microsoft-signed input filter payload must be imported before building an installer. Old Interceptor binaries cannot be reused.'}
 & (Join-Path $root ($Target+'\Build.ps1')) -SkipNative -BuildDirectory $BuildDirectory
}
Write-Host 'Input filter native build completed. Nothing installed or captured.'
if($Target -eq 'All'){Write-Host 'Installer targets require the matching Microsoft-signed payload; SDK and example targets are built.'}
