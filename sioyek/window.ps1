Add-Type @'
using System;
using System.Runtime.InteropServices;

public static class SioyekWindow
{
    [DllImport("user32.dll", SetLastError = true)]
    public static extern int GetWindowLong(
        IntPtr hWnd,
        int nIndex
    );

    [DllImport("user32.dll", SetLastError = true)]
    public static extern int SetWindowLong(
        IntPtr hWnd,
        int nIndex,
        int dwNewLong
    );

    [DllImport("user32.dll", SetLastError = true)]
    public static extern bool SetWindowPos(
        IntPtr hWnd,
        IntPtr hWndInsertAfter,
        int X,
        int Y,
        int cx,
        int cy,
        uint uFlags
    );

    [DllImport("dwmapi.dll")]
    public static extern int DwmSetWindowAttribute(
        IntPtr hwnd,
        int dwAttribute,
        ref int pvAttribute,
        int cbAttribute
    );
}
'@

$process = Get-Process sioyek |
    Where-Object MainWindowHandle -ne 0 |
    Select-Object -First 1

if (-not $process) {
    exit
}

$hwnd = $process.MainWindowHandle

$GWL_STYLE = -16
$WS_MAXIMIZEBOX = 0x00010000
$SWP_FRAMECHANGED = 0x0037

$style = [SioyekWindow]::GetWindowLong($hwnd, $GWL_STYLE)
$style = $style -bor $WS_MAXIMIZEBOX

[void] [SioyekWindow]::SetWindowLong(
    $hwnd,
    $GWL_STYLE,
    $style
)

[void] [SioyekWindow]::SetWindowPos(
    $hwnd,
    [IntPtr]::Zero,
    0, 0, 0, 0,
    $SWP_FRAMECHANGED
)

$DWMWA_CAPTION_COLOR = 35
$white = 0x00FFFFFF

[void] [SioyekWindow]::DwmSetWindowAttribute(
    $hwnd,
    $DWMWA_CAPTION_COLOR,
    [ref] $white,
    4
)
