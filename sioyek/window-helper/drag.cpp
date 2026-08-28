#include <windows.h>
#include <string>

static HWND sioyek_window = nullptr;
static HANDLE sioyek_process = nullptr;
static HHOOK mouse_hook = nullptr;

static bool dragging = false;
static POINT drag_start{};
static RECT window_start{};

static bool key_down(int key)
{
    return (GetAsyncKeyState(key) & 0x8000) != 0;
}

BOOL CALLBACK find_sioyek_window(HWND hwnd, LPARAM)
{
    if (!IsWindowVisible(hwnd)) {
        return TRUE;
    }

    DWORD process_id = 0;
    GetWindowThreadProcessId(hwnd, &process_id);

    HANDLE process = OpenProcess(
        PROCESS_QUERY_LIMITED_INFORMATION | SYNCHRONIZE,
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
            sioyek_process = process;

            return FALSE;
        }
    }

    CloseHandle(process);

    return TRUE;
}

LRESULT CALLBACK mouse_hook_callback(
    int code,
    WPARAM w_param,
    LPARAM l_param
)
{
    if (code < 0) {
        return CallNextHookEx(
            mouse_hook,
            code,
            w_param,
            l_param
        );
    }

    const auto* mouse =
        reinterpret_cast<MSLLHOOKSTRUCT*>(l_param);

    if (
        w_param == WM_LBUTTONDOWN &&
        !dragging &&
        key_down(VK_CONTROL) &&
        key_down(VK_SHIFT)
    ) {
        HWND hovered = WindowFromPoint(mouse->pt);

        if (hovered) {
            hovered = GetAncestor(hovered, GA_ROOT);
        }

        if (hovered == sioyek_window) {
            dragging = true;
            drag_start = mouse->pt;

            GetWindowRect(
                sioyek_window,
                &window_start
            );

            return 1;
        }
    }

    if (
        w_param == WM_MOUSEMOVE &&
        dragging
    ) {
        const int x =
            window_start.left +
            mouse->pt.x -
            drag_start.x;

        const int y =
            window_start.top +
            mouse->pt.y -
            drag_start.y;

        SetWindowPos(
            sioyek_window,
            nullptr,
            x,
            y,
            0,
            0,
            SWP_NOSIZE |
            SWP_NOZORDER |
            SWP_NOACTIVATE
        );

        return CallNextHookEx(
            mouse_hook,
            code,
            w_param,
            l_param
        );
    }

    if (
        w_param == WM_LBUTTONUP &&
        dragging
    ) {
        dragging = false;

        return 1;
    }

    return CallNextHookEx(
        mouse_hook,
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

    if (!sioyek_window || !sioyek_process) {
        return 0;
    }

    mouse_hook = SetWindowsHookExW(
        WH_MOUSE_LL,
        mouse_hook_callback,
        instance,
        0
    );

    if (!mouse_hook) {
        CloseHandle(sioyek_process);

        return 1;
    }

    MSG message{};

    while (true) {
        const DWORD result = MsgWaitForMultipleObjects(
            1,
            &sioyek_process,
            FALSE,
            INFINITE,
            QS_ALLINPUT
        );

        if (result == WAIT_OBJECT_0) {
            break;
        }

        if (result != WAIT_OBJECT_0 + 1) {
            break;
        }

        while (
            PeekMessageW(
                &message,
                nullptr,
                0,
                0,
                PM_REMOVE
            )
        ) {
            if (message.message == WM_QUIT) {
                goto cleanup;
            }

            TranslateMessage(&message);
            DispatchMessageW(&message);
        }
    }

cleanup:

    UnhookWindowsHookEx(mouse_hook);
    CloseHandle(sioyek_process);

    return 0;
}
