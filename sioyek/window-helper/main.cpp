#include <windows.h>
#include <dwmapi.h>
#include <string>

#pragma comment(lib, "dwmapi.lib")

static HWND sioyek_window = nullptr;

BOOL CALLBACK find_sioyek_window(HWND hwnd, LPARAM)
{
    if (!IsWindowVisible(hwnd)) {
        return TRUE;
    }

    DWORD process_id = 0;
    GetWindowThreadProcessId(hwnd, &process_id);

    HANDLE process = OpenProcess(
        PROCESS_QUERY_LIMITED_INFORMATION,
        FALSE,
        process_id
    );

    if (!process) {
        return TRUE;
    }

    wchar_t path[MAX_PATH];
    DWORD size = MAX_PATH;

    if (QueryFullProcessImageNameW(process, 0, path, &size)) {
        std::wstring executable(path);

        const auto separator = executable.find_last_of(L"\\/");

        if (separator != std::wstring::npos) {
            executable = executable.substr(separator + 1);
        }

        if (_wcsicmp(executable.c_str(), L"sioyek.exe") == 0) {
            sioyek_window = hwnd;
            CloseHandle(process);
            return FALSE;
        }
    }

    CloseHandle(process);
    return TRUE;
}

LRESULT CALLBACK mouse_hook(
    int code,
    WPARAM w_param,
    LPARAM l_param
)
{
    if (
        code == HC_ACTION &&
        w_param == WM_LBUTTONDOWN &&
        (GetAsyncKeyState(VK_CONTROL) & 0x8000) &&
        (GetAsyncKeyState(VK_SHIFT) & 0x8000)
    ) {
        const auto* mouse =
            reinterpret_cast<MSLLHOOKSTRUCT*>(l_param);

        HWND window = WindowFromPoint(mouse->pt);

        if (window) {
            window = GetAncestor(window, GA_ROOT);
        }

        if (window == sioyek_window) {
            PostMessageW(
                sioyek_window,
                WM_NCLBUTTONDOWN,
                HTCAPTION,
                MAKELPARAM(mouse->pt.x, mouse->pt.y)
            );

            return 1;
        }
    }

    return CallNextHookEx(
        nullptr,
        code,
        w_param,
        l_param
    );
}

int WINAPI wWinMain(
    HINSTANCE instance,
    HINSTANCE,
    PWSTR,
    int
)
{
    EnumWindows(find_sioyek_window, 0);

    if (!sioyek_window) {
        return 0;
    }

    LONG_PTR style = GetWindowLongPtrW(
        sioyek_window,
        GWL_STYLE
    );

    style |= WS_MAXIMIZEBOX;

    SetWindowLongPtrW(
        sioyek_window,
        GWL_STYLE,
        style
    );

    SetWindowPos(
        sioyek_window,
        nullptr,
        0,
        0,
        0,
        0,
        SWP_NOMOVE |
        SWP_NOSIZE |
        SWP_NOZORDER |
        SWP_NOACTIVATE |
        SWP_FRAMECHANGED
    );

    constexpr DWORD caption_color =
        RGB(255, 255, 255);

    DwmSetWindowAttribute(
        sioyek_window,
        35,
        &caption_color,
        sizeof(caption_color)
    );

    HHOOK hook = SetWindowsHookExW(
        WH_MOUSE_LL,
        mouse_hook,
        instance,
        0
    );

    if (!hook) {
        return 0;
    }

    MSG message;

    while (GetMessageW(&message, nullptr, 0, 0) > 0) {
        if (!IsWindow(sioyek_window)) {
            break;
        }

        TranslateMessage(&message);
        DispatchMessageW(&message);
    }

    UnhookWindowsHookEx(hook);

    return 0;
}
