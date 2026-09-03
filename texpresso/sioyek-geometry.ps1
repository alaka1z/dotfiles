Add-Type @"
using System;
using System.Text;
using System.Runtime.InteropServices;

public static class TexPressoGeometry {
    public delegate bool EnumWindowsProc(IntPtr hWnd, IntPtr lParam);

    [StructLayout(LayoutKind.Sequential)]
    public struct RECT {
        public int Left;
        public int Top;
        public int Right;
        public int Bottom;
    }

    [DllImport("user32.dll")]
    static extern bool EnumWindows(
        EnumWindowsProc callback,
        IntPtr lParam
    );

    [DllImport("user32.dll", CharSet = CharSet.Unicode)]
    static extern int GetWindowText(
        IntPtr hWnd,
        StringBuilder text,
        int count
    );

    [DllImport("user32.dll")]
    static extern bool GetWindowRect(
        IntPtr hWnd,
        out RECT rect
    );

    public static RECT Get() {
        IntPtr result = IntPtr.Zero;

        EnumWindows((hWnd, lParam) => {
            var title = new StringBuilder(512);
            GetWindowText(hWnd, title, title.Capacity);

            if (title.ToString().StartsWith("TeXpresso")) {
                result = hWnd;
                return false;
            }

            return true;
        }, IntPtr.Zero);

        if (result == IntPtr.Zero) {
            throw new Exception("No TeXpresso window found");
        }

        RECT rect;

        if (!GetWindowRect(result, out rect)) {
            throw new Exception("Could not read TeXpresso geometry");
        }

        return rect;
    }
}
"@

$rect = [TexPressoGeometry]::Get()

$width = $rect.Right - $rect.Left
$height = $rect.Bottom - $rect.Top

$config = Join-Path $env:APPDATA "sioyek\auto.config"

if (-not (Test-Path $config)) {
    throw "Sioyek auto.config not found: $config"
}

$content = Get-Content $config -Raw

$size = "single_main_window_size    $width $height"
$move = "single_main_window_move    $($rect.Left) $($rect.Top)"

if ($content -match "(?m)^\s*single_main_window_size\s+.*$") {
    $content = $content -replace `
        "(?m)^\s*single_main_window_size\s+.*$", `
        $size
}
else {
    $content += "`r`n$size"
}

if ($content -match "(?m)^\s*single_main_window_move\s+.*$") {
    $content = $content -replace `
        "(?m)^\s*single_main_window_move\s+.*$", `
        $move
}
else {
    $content += "`r`n$move"
}

Set-Content `
    -Path $config `
    -Value $content `
    -Encoding utf8NoBOM
