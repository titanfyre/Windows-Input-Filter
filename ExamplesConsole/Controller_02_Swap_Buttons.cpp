#include "InputFilter.h"
#include <iostream>
#include <string_view>
#include <system_error>
#include <algorithm>
#include <cmath>
using namespace InputFilter;
void Change(Hid_State& state) {
    for (std::size_t i = 0; i + 1 < state.buttons.size();) {
        auto& a = state.buttons[i]; auto& b = state.buttons[i + 1];
        if (a.report_id == b.report_id && a.link_collection == b.link_collection && a.usage_page == b.usage_page) {
            std::swap(a.pressed, b.pressed); i += 2;
        } else ++i; // Do not pair buttons from different collections; preserve an odd last button.
    }
}
void Change(IC_NATIVE_GAMEPAD_STATE& state, bool gip) {
    // A/B, X/Y, LB/RB, Back/Start, LS/RS, Up/Down, Left/Right. Guide/reserved bits are preserved.
    constexpr unsigned xusb[] = {12,13,14,15,8,9,5,4,6,7,0,1,2,3}, gips[] = {4,5,6,7,12,13,3,2,14,15,8,9,10,11};
    const auto* bits = gip ? gips : xusb; const auto original = state.buttons;
    for (unsigned i = 0; i < 14; i += 2) {
        const auto a = 1u << bits[i], b = 1u << bits[i + 1];
        state.buttons = static_cast<std::uint16_t>((state.buttons & ~(a | b)) | ((original & a) ? b : 0) | ((original & b) ? a : 0));
    }
}

int main(int argc, char** argv) try {
    std::cout << "Swap controller buttons in pairs: 1/2, 3/4, and so on. Supports all controller families.\n"
                 "Run one example at a time as administrator. Close this window or press Ctrl+C to stop.\n" << std::flush;
    if (argc == 2 && std::string_view(argv[1]) == "--help") return 0;
    if (argc != 1) throw std::invalid_argument("Run without arguments, or use --help.");
    Status(); // Read-only check: this edition's installed driver must respond.
    const auto init = Initialize();
    if (!init.ready) {
        std::cerr << "Initialization failed. Error: " << init.error << ". Restart required: " << init.reboot_required << "\n";
        return 1;
    }
    DWORD consoleMode = 0; // Avoid Quick Edit pausing capture in the classic Windows console.
    if (GetConsoleMode(GetStdHandle(STD_INPUT_HANDLE), &consoleMode))
        SetConsoleMode(GetStdHandle(STD_INPUT_HANDLE), (consoleMode | ENABLE_EXTENDED_FLAGS) & ~ENABLE_QUICK_EDIT_MODE);
    for (;;) {
        auto inputs = Receive(INFINITE); // Wait for a batch; the library owns the capture.
        for (auto& input : inputs) {
            if (auto* hid = input.Get<HidEvent>()) Change(hid->state);
            else if (auto* xinput = input.Get<XInputEvent>()) Change(xinput->state, false);
            else if (auto* xinputHid = input.Get<XInputHidEvent>()) Change(xinputHid->state);
            else if (auto* gip = input.Get<GipEvent>()) Change(gip->state, true);
        }
        const auto sent = Submit(inputs); // Forward every unblocked entry, including other device types.
        if (!sent) throw std::system_error(sent.error, std::system_category(), "Submit");
    }
} catch (const std::system_error& error) {
    std::cerr << "Driver error: " << error.code().value() << ". Install this edition with InputFilterSetup.exe, restart if requested, and run as administrator.\n";
    return 1;
} catch (const std::exception& error) {
    std::cerr << error.what() << '\n';
    return 1;
}
