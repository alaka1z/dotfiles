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
    const uint WS_CAPTION = 0x00C00000;

    const uint SWP_NOZORDER     = 0x0004;
    const uint SWP_NOACTIVATE   = 0x0010;
    const uint SWP_FRAMECHANGED = 0x0020;

    const string HiddenProperty = "TexPressoTitlebarHidden";
    const string StyleProperty  = "TexPressoOriginalStyle";

    [DllImport("user32.dll")]
    static extern bool EnumWindows(EnumWindowsProc callback, IntPtr lParam);

    [DllImport("user32.dll", CharSet = CharSet.Unicode)]
    static extern int GetWindowText(
        IntPtr hWnd,
        StringBuilder text,
        int count
    );

    [DllImport("user32.dll")]
    static extern int GetWindowLong(IntPtr hWnd, int index);

    [DllImport("user32.dll")]
    static extern int SetWindowLong(IntPtr hWnd, int index, int value);

    [DllImport("user32.dll")]
    static extern bool GetWindowRect(IntPtr hWnd, out RECT rect);

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

    [DllImport("user32.dll", CharSet = CharSet.Unicode)]
    static extern bool SetProp(IntPtr hWnd, string name, IntPtr value);

    [DllImport("user32.dll", CharSet = CharSet.Unicode)]
    static extern IntPtr GetProp(IntPtr hWnd, string name);

    [DllImport("user32.dll", CharSet = CharSet.Unicode)]
    static extern IntPtr RemoveProp(IntPtr hWnd, string name);

    static IntPtr FindWindow() {
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

    public static void Toggle() {
        IntPtr hWnd = FindWindow();

        if (hWnd == IntPtr.Zero) {
            throw new Exception("No TeXpresso window found");
        }

        RECT rect;
        GetWindowRect(hWnd, out rect);

        int width = rect.Right - rect.Left;
        int height = rect.Bottom - rect.Top;

        int style = GetWindowLong(hWnd, GWL_STYLE);
        bool hidden = GetProp(hWnd, HiddenProperty) != IntPtr.Zero;

        uint newStyle;

        if (!hidden) {
            SetProp(hWnd, StyleProperty, new IntPtr(style));
            SetProp(hWnd, HiddenProperty, new IntPtr(1));

            newStyle = unchecked((uint)style) & ~WS_CAPTION;
        }
        else {
            IntPtr original = GetProp(hWnd, StyleProperty);

            newStyle = original != IntPtr.Zero
                ? unchecked((uint)original.ToInt32())
                : unchecked((uint)style) | WS_CAPTION;

            RemoveProp(hWnd, HiddenProperty);
            RemoveProp(hWnd, StyleProperty);
        }

        SetWindowLong(
            hWnd,
            GWL_STYLE,
            unchecked((int)newStyle)
        );

        SetWindowPos(
            hWnd,
            IntPtr.Zero,
            rect.Left,
            rect.Top,
            width,
            height,
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
