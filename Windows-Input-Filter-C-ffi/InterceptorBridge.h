#ifndef WINDOWS_INPUT_FILTER_BRIDGE_H
#define WINDOWS_INPUT_FILTER_BRIDGE_H
#include <stdint.h>
#ifdef IC_BRIDGE_EXPORTS
#define WINDOWS_INPUT_FILTER_API __declspec(dllexport)
#else
#define WINDOWS_INPUT_FILTER_API __declspec(dllimport)
#endif
#ifdef __cplusplus
extern "C" {
#endif
/* Windows x64, cdecl, natural alignment. Never free borrowed pointers.
   Receive views remain valid until the next receive or close. Copy data before
   another thread calls either. Every function catches C++ exceptions. */
enum {
    WINDOWS_INPUT_FILTER_KEYBOARD = 1,
    WINDOWS_INPUT_FILTER_MOUSE = 2,
    WINDOWS_INPUT_FILTER_HID = 3,
    WINDOWS_INPUT_FILTER_XINPUT = 4,
    WINDOWS_INPUT_FILTER_XINPUTHID = 5,
    WINDOWS_INPUT_FILTER_GIP = 6
};
enum {
    WINDOWS_INPUT_FILTER_STATE = 0,
    WINDOWS_INPUT_FILTER_AXIS = 1,
    WINDOWS_INPUT_FILTER_TRIGGER = 2,
    WINDOWS_INPUT_FILTER_HAT = 3,
    WINDOWS_INPUT_FILTER_VALUE = 4,
    WINDOWS_INPUT_FILTER_BUTTON = 5,
    WINDOWS_INPUT_FILTER_BINARY = 6,
    WINDOWS_INPUT_FILTER_REPORT = 7
};
enum {
    WINDOWS_INPUT_FILTER_NORMALIZED = 1,
    WINDOWS_INPUT_FILTER_RELATIVE = 2,
    WINDOWS_INPUT_FILTER_HAS_NULL = 4,
    WINDOWS_INPUT_FILTER_IS_NULL = 8,
    WINDOWS_INPUT_FILTER_IS_TRIGGER = 16,
    WINDOWS_INPUT_FILTER_READ_ONLY = 32
};
#pragma pack(push, 8)
typedef struct windows_input_filter_error {
    uint32_t code, accepted;
    char message[768];
} windows_input_filter_error;
typedef struct windows_input_filter_field {
    const char *name;
    int64_t value, minimum, maximum, physical_minimum, physical_maximum;
    double normalized;
    uint32_t group, index, usage_page, usage, collection, report_id, data_index, element;
    uint32_t flags, units, units_exponent, bit_size;
    uint8_t *data;
    uint32_t length, reserved;
} windows_input_filter_field;
typedef struct windows_input_filter_event {
    uint32_t kind, blocked;
    uint64_t sequence, timestamp;
    const char *token;
    windows_input_filter_field *fields;
    uint32_t field_count, decode_error, decode_complete, parser_status, device, reserved;
} windows_input_filter_event;
typedef struct windows_input_filter_batch {
    uint64_t id;
    uint32_t count, reserved;
    windows_input_filter_event *events;
} windows_input_filter_batch;
typedef struct windows_input_filter_device {
    uint32_t kind, id;
    uint16_t vid, pid, usage_page, usage;
    const char *token;
    const char *name;
    const char *hardware_id;
} windows_input_filter_device;
typedef struct windows_input_filter_devices {
    uint32_t count, reserved;
    const windows_input_filter_device *items;
} windows_input_filter_devices;
typedef struct windows_input_filter_blob {
    uint32_t applicable, format, length, reserved;
    const uint8_t *data;
} windows_input_filter_blob;
typedef struct windows_input_filter_init {
    uint32_t ready, reboot_required, associated, already_associated, skipped, reserved;
} windows_input_filter_init;
typedef struct windows_input_filter_info {
    uint32_t installed, active, trial_state, input_mask, controller_mask, device_count, queued,
        last_reset;
    uint64_t remaining_ms, timestamp_frequency, generation;
} windows_input_filter_info;
#pragma pack(pop)
WINDOWS_INPUT_FILTER_API const char* windows_input_filter_product_name(void);
WINDOWS_INPUT_FILTER_API uint32_t windows_input_filter_input_mask(void);
WINDOWS_INPUT_FILTER_API uint32_t windows_input_filter_controller_mask(void);
WINDOWS_INPUT_FILTER_API uint32_t windows_input_filter_version(void);
/* sizeof: 1 field, 2 event, 3 batch, 4 device, 5 error, 6 info. */
WINDOWS_INPUT_FILTER_API uint32_t windows_input_filter_sizeof(uint32_t type);
/* Open is lazy: no driver capture, installation, timer or worker thread. */
WINDOWS_INPUT_FILTER_API uint32_t windows_input_filter_open(uint64_t *session, windows_input_filter_error *error);
WINDOWS_INPUT_FILTER_API uint32_t windows_input_filter_close(uint64_t session, windows_input_filter_error *error);
WINDOWS_INPUT_FILTER_API uint32_t windows_input_filter_initialize(uint64_t session, windows_input_filter_init *result, windows_input_filter_error *error);
WINDOWS_INPUT_FILTER_API uint32_t windows_input_filter_info_get(uint64_t session, windows_input_filter_info *result, windows_input_filter_error *error);
WINDOWS_INPUT_FILTER_API uint32_t windows_input_filter_devices_get(uint64_t session, const windows_input_filter_devices **result, windows_input_filter_error *error);
/* timeout in milliseconds, UINT32_MAX means infinite. Cancel returns empty. */
WINDOWS_INPUT_FILTER_API uint32_t windows_input_filter_receive(uint64_t session, uint32_t timeout, const windows_input_filter_batch **result,
                             windows_input_filter_error *error);
/* Counts inferred from ticket. Retry forwards only the unaccepted remainder. */
WINDOWS_INPUT_FILTER_API uint32_t windows_input_filter_send(uint64_t session, uint64_t ticket, windows_input_filter_error *error);
WINDOWS_INPUT_FILTER_API uint32_t windows_input_filter_discard(uint64_t session, uint64_t ticket, windows_input_filter_error *error);
WINDOWS_INPUT_FILTER_API uint32_t windows_input_filter_cancel(uint64_t session, windows_input_filter_error *error);
/* Native HID report: report=1; common descriptor: report=0. */
WINDOWS_INPUT_FILTER_API uint32_t windows_input_filter_descriptor(uint64_t session, const char *token, uint32_t report,
                                windows_input_filter_blob *result, windows_input_filter_error *error);
/* Synthetic input: kind and capture token select an existing source. Named
   STATE fields plus REPORT bytes use the same representation as receive.
   Input and field counts belong only to this low-level FFI; wrappers infer them. */
WINDOWS_INPUT_FILTER_API uint32_t windows_input_filter_inject(uint64_t session, const windows_input_filter_event *inputs, uint32_t count,
                            windows_input_filter_error *error);
#ifdef __cplusplus
}
static_assert(sizeof(windows_input_filter_field) == 120 && sizeof(windows_input_filter_event) == 64 && sizeof(windows_input_filter_batch) == 24,
              "C ABI layout");
static_assert(sizeof(windows_input_filter_device) == 40 && sizeof(windows_input_filter_error) == 776 && sizeof(windows_input_filter_info) == 56,
              "C ABI layout");
#endif
#endif
