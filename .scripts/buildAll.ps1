# suppress warnings that we need to use
param()

$errorActionPreference = "Stop"
[Diagnostics.CodeAnalysis.SuppressMessageAttribute(
    'PSUseDeclaredVarsMoreThanAssignments', "Internal PS variable"
)]
$PSNativeCommandUseErrorActionPreference = $true

# sync the files
git fetch origin
git reset --hard origin/kirkstone

# sync the layers
Set-Location ..
# run the repo-sync script
./.vscode/tasks.ps1 run repo-sync

# get the machines
$machines = Get-Content -Raw -Path ./.vscode/machines.json | `
    ConvertFrom-Json -Depth 100

foreach ($machine in $machines) {
    # Apalis and Verdin are optional machines
    if (
        -not $machine.machine.Contains("verdin") -and
        -not $machine.machine.Contains("apalis")
    ) {
        Write-Host -ForegroundColor Blue `
            "`n`n Configuring and Building for $($machine.machine) `n`n"
        # - Configure Machine and Image
        ./.vscode/tasks.ps1 run 37 $machine.machine $machine.image
        # - Clean
        ./.vscode/tasks.ps1 run bitbake-clean-torizonCore-container
        # - Build
        ./.vscode/tasks.ps1 run build-container
    }
}
