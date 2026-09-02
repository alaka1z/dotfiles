Add-Type @"
using System;
using System.Text;
using System.Runtime.InteropServices;

public static class TexPressoFocus {
    public delegate bool EnumWindowsProc(IntPtr hWnd, IntPtr lParam);

    [DllImport("user32.dll")]
    static extern bool EnumWindows(EnumWindowsProc callback, IntPtr lParam);

    [DllImport("user32.dll", CharSet = CharSet.Unicode)]
    static extern int GetWindowText(
        IntPtr hWnd,
        StringBuilder text,
        int count
    );

    [DllImport("user32.dll")]
    static extern bool SetForegroundWindow(IntPtr hWnd);

    public static bool Focus() {
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
            return false;
        }

        return SetForegroundWindow(result);
    }
}
"@

if (-not [TexPressoFocus]::Focus()) {
    Write-Error "Could not focus TeXpresso"
    exit 1
}
