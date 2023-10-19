
# generate the os_list_imagingutility.json
$Global:_os_list_imagingutility = [PSCustomObject]@{
    "os_list" = @(
        [PSCustomObject]@{
            "name" = "Torizon OS $($env:COMMON_TORIZON_VERSION)"
            "description" = "Torizon OS $($env:COMMON_TORIZON_VERSION) for Raspberry Pi"
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

function releaseBundle ($machine, $tag) {
    # go to the yocto deploy dir if it's exist
    if (
        -not (Test-Path /workdir/torizon/build-torizon/deploy/images/$($machine.machine))
    ) {
        Write-Host -ForegroundColor DarkYellow `
            "No deploy dir found for $($machine.machine), returning ..."
        return
    }

    Set-Location /workdir/torizon/build-torizon/deploy/images/$($machine.machine)

    if (
        $null -ne $machine.dump_image -and
        $machine.dump_image -eq $true 
    ) {
        # for the raspberry pies we need to create a .img from the .wic
        Write-Host "Creating .img from torizon-core-common-docker-dev-$($machine.machine).$($machine.machine).$($machine.image_format) ..."
        # deference the link
        $_wicPath = readlink torizon-core-common-docker-dev-$($machine.machine).$($machine.image_format)
        # create the .img
        $_imgPath = "torizon-core-common-docker-dev-$tag-$($machine.machine).img"
        bmaptool copy $_wicPath $_imgPath
        # compress the .img
        Write-Host "Compressing torizon-core-common-docker-dev-$tag-$($machine.machine).img ..."
        7z a -tzip -bsp1 `
            /releases/torizon-core-common-docker-dev-$tag-$($machine.machine).zip `
            $_imgPath

        # get the .img size in bytes
        $_imgSize = (Get-Item "torizon-core-common-docker-dev-$tag-$($machine.machine).img").Length
        # get the size of the .zip
        $_zipSize = (Get-Item "/releases/torizon-core-common-docker-dev-$tag-$($machine.machine).zip").Length

        # date of the release in format YYYY-MM-DD
        $releaseDate = (Get-Item "torizon-core-common-docker-dev-$tag-$($machine.machine).img")
        $releaseDate = $releaseDate.LastWriteTime.ToString("yyyy-MM-dd")

        # get the sha256sum from the .img
        $sha256sum = Get-FileHash `
            -Path "torizon-core-common-docker-dev-$tag-$($machine.machine).img" `
            -Algorithm SHA256 `
                | Select-Object -ExpandProperty Hash
        # set it to lowercase, Raspberry Pi Imager needs it
        $sha256sum = $sha256sum.ToLower()

        # clean the .img
        rm $_imgPath

        # add it to the os_list_imagingutility.json
        $Global:_os_list_imagingutility.os_list[0].subitems += [PSCustomObject]@{
            "name" = "Torizon OS $tag"
            "description" = "TorizonCore $tag for $($machine.machine)"
            "icon" = "https://docs.toradex.com/111487-torizon.png"
            "url" = "https://github.com/commontorizon/meta-common-torizon/releases/download/$tag/torizon-core-common-docker-dev-$tag-$($machine.machine).zip"
            "extract_size" = $_imgSize
            "extract_sha256" = "$sha256sum"
            "image_download_size" = $_zipSize
            "release_date" = "$releaseDate"
        }

        Set-Location -
        return
    } else {
        # create the zip from the .wic file
        Write-Host "Compressing torizon-core-common-docker-dev-$($machine.machine).$($machine.machine).$($machine.image_format) ..."
        # deference the link
        $_wicPath = readlink torizon-core-common-docker-dev-$($machine.machine).$($machine.image_format) 
        7z a -tzip -bsp1 `
            /releases/torizon-core-common-docker-dev-$tag-$($machine.machine).zip `
            $_wicPath
    }

    if (
        $machine.bmap -eq $true
    ) {
        Write-Host "Compressing torizon-core-common-docker-dev-$($machine.machine).wic.bmap ..."
        # deference the link
        $_bmapPath = readlink torizon-core-common-docker-dev-$($machine.machine).wic.bmap
        7z u -tzip -bsp1 `
            /releases/torizon-core-common-docker-dev-$tag-$($machine.machine).zip `
            $_bmapPath
    }

    if (
        $null -ne $machine.firmware
    ) {
        Write-Host "Compressing firmware $($machine.machine) ..."
        7z u -tzip -bsp1 `
            /releases/torizon-core-common-docker-dev-$tag-$($machine.machine).zip `
            $machine.firmware
    }

    Set-Location -
    return
}
