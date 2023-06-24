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

$_build_dir = $settings.build_dir

# change the TDX_IMAGE = value in local.conf
sed -i "/TDX_IMAGE = `".*`"/c\TDX_IMAGE = `"$_image`"" `
    /workdir/torizon/$_build_dir/conf/local.conf

# check if we need to enable the TDX_DEBUG
if ($_image.ToString().Contains("-dev")) {
    sed -i '/#TDX_DEBUG ?= "0"/c\TDX_DEBUG = "1"' `
        /workdir/torizon/$_build_dir/conf/local.conf
} else {
    sed -i '/TDX_DEBUG = "1"/c\#TDX_DEBUG ?= "0"' `
        /workdir/torizon/$_build_dir/conf/local.conf
}

# write the settings back to the file
$settings | ConvertTo-Json -Depth 100 | Out-File $settingsFile
