#include <windows.h>
#include <string>

static HWND sioyek_window = nullptr;

// Find the visible top-level window owned by sioyek.exe
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

int WINAPI wWinMain(
    HINSTANCE,
    HINSTANCE,
    PWSTR,
    int
)
{
    EnumWindows(find_sioyek_window, 0);

    if (!sioyek_window) {
        return 0;
    }

    // Restore maximize support after Sioyek removes its title bar
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

    // Force Windows to recalculate the frame after changing the window style
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

    return 0;
}
