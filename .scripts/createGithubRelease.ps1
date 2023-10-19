# suppress warnings that we need to use
param()

$errorActionPreference = "Stop"
[Diagnostics.CodeAnalysis.SuppressMessageAttribute(
    'PSUseDeclaredVarsMoreThanAssignments', "Internal PS variable"
)]
$PSNativeCommandUseErrorActionPreference = $true


. ./includes/releaseBundle.ps1

# check if the version env is set
if (
    -not $env:COMMON_TORIZON_VERSION
) {
    Write-Host -ForegroundColor Red `
        "COMMON_TORIZON_VERSION env is not set, please set it and try again"
    exit 69
}

$tag = $env:COMMON_TORIZON_VERSION

# get the machines
$machines = Get-Content -Raw -Path ../.vscode/machines.json | `
    ConvertFrom-Json -Depth 100

foreach ($machine in $machines) {
    if (
        -not $machine.machine.Contains("verdin") -and
        -not $machine.machine.Contains("apalis")
    ) {
        Write-Host -ForegroundColor Blue `
            "`n`n Creating bundle for $($machine.machine) `n`n"
        releaseBundle $machine $tag
    }
}

# get the content from the release notes
$_mdURL = "https://raw.githubusercontent.com/commontorizon/Documentation/main/releases/v6.4.0.md"
$releaseNotes = (Invoke-WebRequest -Uri $_mdURL).Content

Write-Host -ForegroundColor Blue `
            "`n`n Uploading for GitHub Common Torizon $($tag) `n`n"

# set the token
if (
    -not (Test-Path ../.key/gh.key)
) {
    Write-Host -ForegroundColor Red `
        "No GitHub token found, please create one and try again"
    exit 69
}

$env:GH_TOKEN = Get-Content ../.key/gh.key

# set the common-torizon repo
Set-Location /workdir/torizon/layers/meta-common-torizon
gh repo set-default commontorizon/meta-common-torizon

# create the release
gh release create --prerelease --target kirkstone `
    $tag `
    -t "Common Torizon $tag" `
    -n $releaseNotes `
    /releases/*.zip

Set-Location -
