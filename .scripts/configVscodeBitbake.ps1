# suppress warnings that we need to use
param()

# check if the folder exists
if (! (Test-Path -Path ./.vscode)) {
    New-Item -ItemType Directory -Path ./.vscode

    # create the settings.json file
    New-Item -ItemType File -Path ./.vscode/settings.json
Write-Output @"
{
    "window.title": "Common Torizon Layers",
    "terminal.integrated.defaultProfile.linux": "bash",
    "bitbake.pathToBuildFolder": "`${workspaceFolder}/../build-torizon",
    "bitbake.pathToEnvScript": "/usr/bin/init-build-env-torizon",
    "bitbake.pathToBitbakeFolder": "`${workspaceFolder}/openembedded-core/bitbake",
    "ctags.disable": true,
    "python.autoComplete.extraPaths": [
        "/workdir/torizon/layers/sources/poky/bitbake/lib",
        "/workdir/torizon/layers/openembedded-core/bitbake/lib"
    ],
    "python.analysis.extraPaths": [
        "/workdir/torizon/layers/sources/poky/bitbake/lib",
        "/workdir/torizon/layers/openembedded-core/bitbake/lib"
    ]
}
"@ | Out-File ./.vscode/settings.json
}

# update the settings.json file
$yoctoSettings =
    Get-Content ./.vscode/settings.json | ConvertFrom-Json -Depth 100
$settings =
    Get-Content /workspaces/commontorizon-manifest/.vscode/settings.json `
        | ConvertFrom-Json -Depth 100

# update the settings
$yoctoSettings."bitbake.machine" = $settings.machine
$yoctoSettings."bitbake.distro" = $settings.distro
$yoctoSettings."bitbake.image" = $settings.image
$yoctoSettings."bitbake.buildPath" = $settings.build_dir

# output the settings.json file
$yoctoSettings | ConvertTo-Json -Depth 100 | Out-File ./.vscode/settings.json
