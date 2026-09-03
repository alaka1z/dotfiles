Add-Type @"
using System;
using System.Text;
using System.Diagnostics;
using System.Runtime.InteropServices;

public static class TexPressoReturn {
    public delegate bool EnumWindowsProc(IntPtr hWnd, IntPtr lParam);

    [StructLayout(LayoutKind.Sequential)]
    public struct RECT {
        public int Left;
        public int Top;
        public int Right;
        public int Bottom;
    }

    const int SW_SHOW = 5;
    const uint WM_CLOSE = 0x0010;

    const uint SWP_NOZORDER   = 0x0004;
    const uint SWP_NOACTIVATE = 0x0010;

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
    static extern bool GetWindowRect(
        IntPtr hWnd,
        out RECT rect
    );

    [DllImport("user32.dll")]
    static extern bool SetWindowPos(
        IntPtr hWnd,
        IntPtr hWndInsertAfter,
        int X,
        int Y,
        int cx,
        int cy,
        uint flags
    );

    [DllImport("user32.dll")]
    static extern bool ShowWindow(
        IntPtr hWnd,
        int nCmdShow
    );

    [DllImport("user32.dll")]
    static extern bool SetForegroundWindow(IntPtr hWnd);

    [DllImport("user32.dll")]
    static extern bool PostMessage(
        IntPtr hWnd,
        uint msg,
        IntPtr wParam,
        IntPtr lParam
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

    public static IntPtr FindVisibleSioyek() {
        foreach (var process in Process.GetProcessesByName("sioyek")) {
            uint targetPid = (uint)process.Id;
            IntPtr result = IntPtr.Zero;

            EnumWindows((hWnd, lParam) => {
                uint pid;
                GetWindowThreadProcessId(hWnd, out pid);

                if (
                    pid == targetPid &&
                    IsWindowVisible(hWnd)
                ) {
                    result = hWnd;
                    return false;
                }

                return true;
            }, IntPtr.Zero);

            if (result != IntPtr.Zero) {
                return result;
            }
        }

        return IntPtr.Zero;
    }

    public static RECT GetRect(IntPtr hWnd) {
        RECT rect;

        if (!GetWindowRect(hWnd, out rect)) {
            throw new Exception("Could not read Sioyek geometry");
        }

        return rect;
    }

    public static void ShowTexPresso(IntPtr texpresso) {
        ShowWindow(texpresso, SW_SHOW);
        SetForegroundWindow(texpresso);
    }

    public static void ReturnToTexPresso(
        IntPtr texpresso,
        IntPtr sioyek,
        RECT rect
    ) {
        SetWindowPos(
            texpresso,
            IntPtr.Zero,
            rect.Left,
            rect.Top,
            rect.Right - rect.Left,
            rect.Bottom - rect.Top,
            SWP_NOZORDER |
            SWP_NOACTIVATE
        );

        ShowWindow(texpresso, SW_SHOW);
        SetForegroundWindow(texpresso);

        PostMessage(
            sioyek,
            WM_CLOSE,
            IntPtr.Zero,
            IntPtr.Zero
        );
    }
}
"@

$texpresso = [TexPressoReturn]::FindTexPresso()

# Nothing is already running, so leave normal startup to VimtexCompile!
if ($texpresso -eq [IntPtr]::Zero) {
    exit 0
}

$sioyek = [TexPressoReturn]::FindVisibleSioyek()

# TexPresso exists but Sioyek doesn't:
# this includes the "I manually closed Sioyek" recovery case
if ($sioyek -eq [IntPtr]::Zero) {
    [TexPressoReturn]::ShowTexPresso($texpresso)
    exit 0
}

# Returning normally from Sioyek
$rect = [TexPressoReturn]::GetRect($sioyek)

[TexPressoReturn]::ReturnToTexPresso(
    $texpresso,
    $sioyek,
    $rect
)
