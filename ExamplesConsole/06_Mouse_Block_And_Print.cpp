#include "InputFilter.h"
#include <iostream>
#include <system_error>
using namespace InputFilter;

int main() try {
    std::cout
        << "Print and block mouse input. Keyboard and controller input keep working.\n"
           "Run one example at a time as administrator. Close this window or press Ctrl+C to stop.\n"
        << std::flush;
    // Check installation and initialize supported devices before capturing.
    Status();
    const auto init = Initialize();
    if (!init.ready) {
        std::cerr << "Initialization failed. Error: " << init.error
                  << ". Restart required: " << init.reboot_required << "\n";
        return 1;
    }
    DWORD consoleMode = 0; // Console only: prevent text selection from blocking console writes.
    if (GetConsoleMode(GetStdHandle(STD_INPUT_HANDLE), &consoleMode)) {
        SetConsoleMode(GetStdHandle(STD_INPUT_HANDLE),
                       (consoleMode | ENABLE_EXTENDED_FLAGS) & ~ENABLE_QUICK_EDIT_MODE);
    }
    for (;;) {
        auto inputs = Receive(INFINITE); // Wait for a batch; the library owns the capture.
        for (auto& input : inputs) {
            if (input.Get<MouseEvent>()) {
                input.blocked = true;
            }
        }
        const auto sent =
            Submit(inputs); // Forward every unblocked entry, including other device types.
        if (!sent) {
            throw std::system_error(sent.error, std::system_category(), "Submit");
        }
        for (auto& input : inputs) {
            if (auto* mouse = input.Get<MouseEvent>()) {
                input.blocked = true; // Other input families are forwarded below.
                std::cout << "Mouse " << mouse->device << ": x=" << mouse->state.x
                          << " y=" << mouse->state.y << " buttons=" << mouse->state.button_flags
                          << " wheel=" << mouse->state.button_data << '\n';
            }
        }
    }
} catch (const std::system_error& error) {
    std::cerr
        << "Driver error: " << error.code().value()
        << ". Install this edition with InputFilterSetup.exe, restart if requested, and run as administrator.\n";
    return 1;
} catch (const std::exception& error) {
    std::cerr << error.what() << '\n';
    return 1;
}
