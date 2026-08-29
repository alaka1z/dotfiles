#include <windows.h>
#include <string>

static HWND sioyek_window = nullptr;
static HANDLE sioyek_process = nullptr;
static HHOOK keyboard_hook = nullptr;

static bool toggle_key_active = false;

// Find the visible top-level window owned by sioyek.exe
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

// Toggle maximize when Alt+Enter is pressed inside Sioyek
LRESULT CALLBACK keyboard_hook_callback(
    int code,
    WPARAM w_param,
    LPARAM l_param
)
{
    if (code < 0) {
        return CallNextHookEx(
            keyboard_hook,
            code,
            w_param,
            l_param
        );
    }

    const auto* keyboard =
        reinterpret_cast<KBDLLHOOKSTRUCT*>(l_param);

    const bool is_return =
        keyboard->vkCode == VK_RETURN;

    const bool is_key_down =
        w_param == WM_KEYDOWN ||
        w_param == WM_SYSKEYDOWN;

    const bool is_key_up =
        w_param == WM_KEYUP ||
        w_param == WM_SYSKEYUP;

    const bool alt_down =
        (keyboard->flags & LLKHF_ALTDOWN) != 0;

    if (
        is_return &&
        is_key_down &&
        alt_down &&
        GetForegroundWindow() == sioyek_window
    ) {
        // Ignore key repeat so holding Enter cannot toggle repeatedly
        if (!toggle_key_active) {
            ShowWindow(
                sioyek_window,
                IsZoomed(sioyek_window)
                    ? SW_RESTORE
                    : SW_MAXIMIZE
            );

            toggle_key_active = true;
        }

        return 1;
    }

    if (
        is_return &&
        is_key_up &&
        toggle_key_active
    ) {
        toggle_key_active = false;

        return 1;
    }

    return CallNextHookEx(
        keyboard_hook,
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

    keyboard_hook = SetWindowsHookExW(
        WH_KEYBOARD_LL,
        keyboard_hook_callback,
        instance,
        0
    );

    if (!keyboard_hook) {
        CloseHandle(sioyek_process);

        return 1;
    }

    MSG message{};

    while (true) {
        // Wait for either Sioyek to exit or Windows input to become available
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
    UnhookWindowsHookEx(keyboard_hook);
    CloseHandle(sioyek_process);

    return 0;
}
