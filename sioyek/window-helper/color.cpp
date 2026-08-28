#include <windows.h>
#include <dwmapi.h>
#include <string>

#pragma comment(lib, "dwmapi.lib")

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

    // Make the remaining Windows caption strip white
    constexpr DWORD DWMWA_CAPTION_COLOR = 35;
    constexpr DWORD white = RGB(255, 255, 255);

    DwmSetWindowAttribute(
        sioyek_window,
        DWMWA_CAPTION_COLOR,
        &white,
        sizeof(white)
    );

    return 0;
}
