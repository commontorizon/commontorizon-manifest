#!/usr/bin/env pwsh

# suppress warnings that we need to use
param()

$ErrorActionPreference = "Stop"
[Diagnostics.CodeAnalysis.SuppressMessageAttribute(
    'PSUseDeclaredVarsMoreThanAssignments', "Internal PS variable"
)]
$PSNativeCommandUseErrorActionPreference = $true

$workspaceFolder = $pwd.Path

# generate the os_list_imagingutility.json
$_os_list_imagingutility = [PSCustomObject]@{
    "os_list" = @(
        [PSCustomObject]@{
            "name" = "TorizonCore v6.2.0"
            "description" = "TorizonCore v6.2.0 for Raspberry Pi"
            "icon" = "https://docs.toradex.com/111487-torizon.png"
            "subitems" = @()
        },
        [PSCustomObject]@{
            "name" = "Raspberry Pi 4 EEPROM boot recovery"
            "description" = "Raspberry Pi 4 EEPROM boot recovery"
            "icon" = "icons/ic_build_48px.svg"
            "subitems" = @(
                [PSCustomObject]@{
                    "name" = "Raspberry Pi 4 EEPROM boot recovery"
                    "description" = "Use this only if advised to do so"
                    "icon" = "https://downloads.raspberrypi.org/raspios_armhf/Raspberry_Pi_OS_(32-bit).png"
                    "url" = "https://github.com/raspberrypi/rpi-eeprom/releases/download/v2020.09.03-138a1/rpi-boot-eeprom-recovery-2020-09-03-vl805-000138a1.zip"
                    "contains_multiple_files" = $true
                    "extract_size" = 722892
                    "image_download_size" = 298096
                    "release_date" = "2020-09-14"
                }
            )
        }
    )
}

# now the interesting part
function _do_stuff ($machine) {
    # first we need to convert .wic.bz to .img
    bmaptool `
        copy `
        "${workspaceFolder}/../labs/workdir/torizon/build-torizon-upstream/deploy/images/${machine}/torizon-core-docker-dev-${machine}.wic.bz2" `
    ./tmp/torizon-core-docker-dev-${machine}.img

    # get the .img size in bytes
    $size = (Get-Item "./tmp/torizon-core-docker-dev-${machine}.img").Length

    # get the sha256sum from the .img
    $sha256sum = Get-FileHash `
        -Path "./tmp/torizon-core-docker-dev-${machine}.img" `
        -Algorithm SHA256 `
            | Select-Object -ExpandProperty Hash

    # now we compress it to .zip
    zip `
        "./tmp/torizon-core-docker-dev-${machine}.img.zip" `
        "./tmp/torizon-core-docker-dev-${machine}.img"

    # now get the compressed file size
    $zipSize = (Get-Item "./tmp/torizon-core-docker-dev-${machine}.img.zip").Length

    # date of the release in format YYYY-MM-DD
    $releaseDate = (Get-Item "./tmp/torizon-core-docker-dev-${machine}.img")
    $releaseDate = $releaseDate.LastWriteTime.ToString("yyyy-MM-dd")

    # add it to the os_list_imagingutility.json
    $_os_list_imagingutility.os_list[0].subitems += [PSCustomObject]@{
        "name" = "TorizonCore v6.2.0"
        "description" = "TorizonCore v6.2.0 for ${machine}"
        "icon" = "https://docs.toradex.com/111487-torizon.png"
        "url" = "file:///tmp/torizon-core-docker-dev-${machine}.img.zip"
        "extract_size" = $size
        "extract_sha256" = "${sha256sum}"
        "image_download_size" = $zipSize
        "release_date" = "${releaseDate}"
    }
}

# mount the tmpfs
mkdir -p ./tmp
rm -rf ./tmp/*
sudo mount -t tmpfs -o size=10G tmpfs ./tmp

# for Raspberry Pi 4B
_do_stuff "raspberrypi4-64"
# for Raspberry Pi 3B
_do_stuff "raspberrypi3-64"

# dump the json file
$_os_list_imagingutility `
    | ConvertTo-Json -Depth 100 `
        | Out-File "./tmp/os_list_imagingutility.json"
