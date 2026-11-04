#pragma once
// Build identity and immutable family boundary for this separate product.
// This header is also directly testable outside the kernel.
#define IC_PRODUCT_SERVICE L"WindowsInputFilter"
#define IC_PRODUCT_XUSB_HID_PARENT_VALUE L"WindowsInputFilterXusbHidParent"
#define IC_PRODUCT_XUSB_PARENT_VALUE L"WindowsInputFilterXusbParent"
#define IC_PRODUCT_CONTROL_HWID L"ROOT\\WindowsInputFilterControl"
#define IC_PRODUCT_NT_DEVICE L"\\Device\\WindowsInputFilter"
#define IC_PRODUCT_DOS_DEVICE L"\\DosDevices\\WindowsInputFilter"
#define IC_PRODUCT_TRIAL_SLOT 0u
#define IC_PRODUCT_TRIAL_KEY L"\\Registry\\Machine\\HARDWARE\\WindowsInputFilterTrial"
#ifndef IC_PRODUCT_INPUT_MASK
#define IC_PRODUCT_INPUT_MASK 3u
#endif
#ifndef IC_PRODUCT_CONTROLLER_MASK
#define IC_PRODUCT_CONTROLLER_MASK 15u
#endif
#ifndef IC_PRODUCT_HAS_KEYBOARD_MOUSE
#define IC_PRODUCT_HAS_KEYBOARD_MOUSE 1
#endif
#ifndef IC_PRODUCT_HAS_CONTROLLERS
#define IC_PRODUCT_HAS_CONTROLLERS 1
#endif
#define IC_PRODUCT_STREAM_MASK (IC_PRODUCT_INPUT_MASK | (IC_PRODUCT_CONTROLLER_MASK << 2))
#define IC_PRODUCT_HID_GUID {0xbec49f9a,0x46e0,0x578c,{0xba,0xdc,0x9e,0xa0,0x9b,0xfc,0xb0,0xfc}}
#define IC_PRODUCT_XUSB_GUID {0xeea76270,0x5fe6,0x5658,{0x99,0x7e,0x7e,0x7c,0xf9,0x04,0xd1,0x6a}}
#define IC_PRODUCT_XINPUTHID_GUID {0xca443fc3,0x59a7,0x545c,{0x85,0x4e,0xfe,0x4d,0xbd,0x8b,0x88,0xf5}}
#define IC_PRODUCT_GIP_GUID {0x79dc66c6,0xd2bd,0x588f,{0xa1,0x62,0xcc,0x1a,0x2b,0xc4,0x65,0x12}}
#define IC_PRODUCT_XUSB_MIRROR_GUID {0xc6c7d86b,0xbaa0,0x5704,{0xb8,0x85,0x8a,0xef,0x9f,0x65,0xb1,0x03}}
static __inline int IcProductTypeAllowed(unsigned int type) {
    return type>=1 && type<=6 && (IC_PRODUCT_STREAM_MASK & (1u<<(type-1)))!=0;
}
static __inline int IcProductCreateMasksAllowed(unsigned int input,unsigned int controllers) {
    return !(input & ~IC_PRODUCT_INPUT_MASK) && !(controllers & ~IC_PRODUCT_CONTROLLER_MASK);
}
// Function numbers are the pointer-free protocol's CTL_CODE function field.
// Unknown/common functions keep the normal control dispatch validation.
static __inline int IcProductIoctlFunctionAllowed(unsigned int fn) {
    switch(fn) {
    case 0xA01:case 0xA03:case 0xA07:
        return (IC_PRODUCT_INPUT_MASK & 1u)!=0;
    case 0xA02:case 0xA04:case 0xA08:
        return (IC_PRODUCT_INPUT_MASK & 2u)!=0;
    case 0xA09:case 0xA0A:case 0xA0B:case 0xA0C:case 0xA0D:
        return (IC_PRODUCT_CONTROLLER_MASK & 1u)!=0;
    case 0xA10:case 0xA11:case 0xA12:case 0xA13:case 0xA14:case 0xA15:
        return (IC_PRODUCT_CONTROLLER_MASK & 2u)!=0;
    case 0xA17:case 0xA18:case 0xA19:case 0xA1A:case 0xA1B:
        return (IC_PRODUCT_CONTROLLER_MASK & 4u)!=0;
    case 0xA20:case 0xA21:case 0xA22:case 0xA23:case 0xA24:case 0xA25:
    case 0xA29:case 0xA2A:case 0xA2B:
        return (IC_PRODUCT_CONTROLLER_MASK & 8u)!=0;
    case 0xA30:case 0xA31:case 0xA32:case 0xA33:
        return IC_PRODUCT_HAS_CONTROLLERS;
    default:return 1;
    }
}

