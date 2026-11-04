#pragma once
#include "InputFilterProtocol.h"
static __inline int IcValidKeyboard(const IC_KEYBOARD_INPUT* k) {
    return !k->reserved && !k->padding && !k->state.reserved && k->state.make_code<=127 &&
        !(k->state.flags&~7u) && (k->state.flags&6u)!=6u;
}
static __inline int IcValidMouse(const IC_MOUSE_INPUT* m) {
    return !m->reserved && !(m->state.flags&~0x0Bu) && !(m->state.button_flags&~0x0FFFu) &&
        (m->state.button_flags&0x0C00u)!=0x0C00u;
}
