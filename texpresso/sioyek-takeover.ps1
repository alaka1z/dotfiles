Add-Type @"
using System;
using System.Text;
using System.Diagnostics;
using System.Runtime.InteropServices;

public static class SioyekTakeover {
    public delegate bool EnumWindowsProc(IntPtr hWnd, IntPtr lParam);

    const int SW_HIDE = 0;

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
    static extern uint GetWindowThreadProcessId(
        IntPtr hWnd,
        out uint processId
    );

    [DllImport("user32.dll")]
    static extern bool IsWindowVisible(IntPtr hWnd);

    [DllImport("user32.dll")]
    static extern bool ShowWindow(
        IntPtr hWnd,
        int nCmdShow
    );

    public static IntPtr FindTexPresso() {
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

        return result;
    }

    public static bool SioyekVisible() {
        foreach (var process in Process.GetProcessesByName("sioyek")) {
            uint targetPid = (uint)process.Id;
            bool found = false;

            EnumWindows((hWnd, lParam) => {
                uint pid;
                GetWindowThreadProcessId(hWnd, out pid);

                if (
                    pid == targetPid &&
                    IsWindowVisible(hWnd)
                ) {
                    found = true;
                    return false;
                }

                return true;
            }, IntPtr.Zero);

            if (found) {
                return true;
            }
        }

        return false;
    }

    public static void HideTexPresso() {
        IntPtr hWnd = FindTexPresso();

        if (hWnd != IntPtr.Zero) {
            ShowWindow(hWnd, SW_HIDE);
        }
    }
}
"@

while (-not [SioyekTakeover]::SioyekVisible()) {
    Start-Sleep -Milliseconds 10
}

[SioyekTakeover]::HideTexPresso()
