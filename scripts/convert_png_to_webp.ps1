Get-ChildItem -Filter *.png | ForEach-Object {
    cwebp.exe -q 80 $_.FullName -o ($_.FullName -replace '\.png$', '.webp')
}
