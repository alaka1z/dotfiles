Add-Type @"
using System;
using System.Text;
using System.Runtime.InteropServices;

public static class TexPressoTitlebar {
    public delegate bool EnumWindowsProc(IntPtr hWnd, IntPtr lParam);

    [StructLayout(LayoutKind.Sequential)]
    public struct RECT {
        public int Left;
        public int Top;
        public int Right;
        public int Bottom;
    }

    const int GWL_STYLE = -16;

    const long WS_CAPTION = 0x00C00000;

    const uint SWP_NOZORDER     = 0x0004;
    const uint SWP_NOACTIVATE   = 0x0010;
    const uint SWP_FRAMECHANGED = 0x0020;

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

    [DllImport("user32.dll", EntryPoint = "GetWindowLongPtrW")]
    static extern IntPtr GetWindowLongPtr(
        IntPtr hWnd,
        int index
    );

    [DllImport("user32.dll", EntryPoint = "SetWindowLongPtrW")]
    static extern IntPtr SetWindowLongPtr(
        IntPtr hWnd,
        int index,
        IntPtr value
    );

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

    static IntPtr FindWindow() {
        IntPtr result = IntPtr.Zero;

        EnumWindows((hWnd, lParam) => {
            var title = new StringBuilder(512);

            GetWindowText(
                hWnd,
                title,
                title.Capacity
            );

            if (title.ToString().StartsWith("TeXpresso")) {
                result = hWnd;
                return false;
            }

            return true;
        }, IntPtr.Zero);

        return result;
    }

    public static void Toggle() {
        IntPtr hWnd = FindWindow();

        if (hWnd == IntPtr.Zero) {
            throw new Exception(
                "No TeXpresso window found"
            );
        }

        RECT rect;

        if (!GetWindowRect(hWnd, out rect)) {
            throw new Exception(
                "Could not read TeXpresso window geometry"
            );
        }

        long style =
            GetWindowLongPtr(
                hWnd,
                GWL_STYLE
            ).ToInt64();

        bool hasCaption =
            (style & WS_CAPTION) != 0;

        long newStyle =
            hasCaption
                ? style & ~WS_CAPTION
                : style | WS_CAPTION;

        SetWindowLongPtr(
            hWnd,
            GWL_STYLE,
            new IntPtr(newStyle)
        );

        SetWindowPos(
            hWnd,
            IntPtr.Zero,
            rect.Left,
            rect.Top,
            rect.Right - rect.Left,
            rect.Bottom - rect.Top,
            SWP_NOZORDER |
            SWP_NOACTIVATE |
            SWP_FRAMECHANGED
        );
    }
}
"@

try {
    [TexPressoTitlebar]::Toggle()
}
catch {
    Write-Error $_
    exit 1
}
