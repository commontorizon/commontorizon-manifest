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
    "bitbake.pathToEnvScript": "`${workspaceFolder}/.vscode/setup-env",
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

# update the env setup settings
$settings =
    Get-Content /workspaces/commontorizon-manifest/.vscode/settings.json `
        | ConvertFrom-Json -Depth 100

# generate a new setup-env
Write-Output @"
#!/bin/bash

export DISTRO=$($settings.distro)
export MACHINE=$($settings.machine)
export IMAGE=$($settings.image)
export BBDIR=$($settings.build_dir)

# call the environment setup script
## TODO: this will work only into the devcontainer
cd /workdir/torizon
source setup-environment `$1

"@ | Out-File ./.vscode/setup-env

chmod +x ./.vscode/setup-env
