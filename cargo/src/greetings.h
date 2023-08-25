#include <stdint.h>

const char *rust_greeting(const char *to);
void rust_greeting_free(char *);
const uint8_t *process_raw_data(const uint8_t *from);
const uint8_t *process_raw_data_with_len(const uint8_t *from, const int len);
void my_request(void *context,
                   const unsigned char *req_bytes,
                   int bytes_length,
                   void (*callback)(void *context, const unsigned char *res_bytes));
void async_callback(void *context, void(*callback)(void *context, int arg1, int arg2));

