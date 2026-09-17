$source = "$HOME\.config\glazewm\config.yaml"
$target = "$env:LOCALAPPDATA\glazewm\config.yaml"
$colors = "$env:TEMP\theme-sync-colors"

if (-not (Test-Path $colors)) {
    exit
}

$foreground = (Get-Content $colors)[1]

$content = Get-Content $source -Raw

$content = $content -replace `
    "color:\s*'#[0-9a-fA-F]{6}'\s*# theme-sync",
    "color: '$foreground' # theme-sync"

New-Item `
    -ItemType Directory `
    -Path (Split-Path $target) `
    -Force |
    Out-Null

Set-Content `
    -Path $target `
    -Value $content `
    -NoNewline

glazewm command wm-reload-config | Out-Null
