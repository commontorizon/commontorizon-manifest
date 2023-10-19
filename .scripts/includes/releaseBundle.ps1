
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
        $_imgPath = "torizon-core-common-docker-dev-$($machine.machine).img"
        bmaptool copy $_wicPath $_imgPath
        # compress the .img
        Write-Host "Compressing torizon-core-common-docker-dev-$($machine.machine).img ..."
        7z a -tzip -bsp1 `
            /releases/torizon-core-common-docker-dev-$tag-$($machine.machine).zip `
            $_imgPath
        # clean the .img
        rm $_imgPath

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
