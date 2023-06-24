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

$_image = $args[0]

# rewrite the settings json setting the machine properties
$settingsFile = Join-Path $PSScriptRoot "../.vscode/settings.json"
$settings = Get-Content $settingsFile | ConvertFrom-Json

$settings.image = $_image

# write the settings back to the file
$settings | ConvertTo-Json -Depth 100 | Out-File $settingsFile
