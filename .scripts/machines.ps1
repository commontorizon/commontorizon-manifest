# suppress warnings that we need to use
[Diagnostics.CodeAnalysis.SuppressMessageAttribute(
    'PSAvoidOverwritingBuiltInCmdlets', ""
)]
[Diagnostics.CodeAnalysis.SuppressMessageAttribute(
    'PSAvoidUsingWriteHost', ""
)]
[Diagnostics.CodeAnalysis.SuppressMessageAttribute(
    'PSAvoidUsingInvokeExpression', ""
)]
[Diagnostics.CodeAnalysis.SuppressMessageAttribute(
    'PSAvoidUsingPositionalParameters', ""
)]
[Diagnostics.CodeAnalysis.SuppressMessageAttribute(
    'PSAvoidGlobalVars', ""
)]
param()

$ErrorActionPreference = "Stop"

$_machine = $args[0]

# read the machines.json file
$machinesFile = Join-Path $PSScriptRoot "../.vscode/machines.json"

# search by the argument that is the machine name
$machine = `
    Get-Content $machinesFile | `
    ConvertFrom-Json | `
    Where-Object { $_.machine.Equals($_machine) }

# rewrite the settings json setting the machine properties
if ($null -ne $machine) {
    $settingsFile = Join-Path $PSScriptRoot "../.vscode/settings.json"
    $settings = Get-Content $settingsFile | ConvertFrom-Json

    $settings.machine = $machine.machine
    $settings.image = $machine.image
    $settings.distro = $machine.distro
    $settings.build_dir = $machine.build_dir
    $settings.image_format = $machine.image_format

    # write the settings back to the file
    $settings | ConvertTo-Json -Depth 100 | Out-File $settingsFile
}
