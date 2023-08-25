#include <stdarg.h>
#include <stdbool.h>
#include <stdint.h>
#include <stdlib.h>

char *rust_greeting(const char *to);

void rust_greeting_free(char *s);

const unsigned char *process_raw_data(const unsigned char *from);

const unsigned char *process_raw_data_with_len(const unsigned char *from, int len);

void async_callback(void *context, void (*callback)(void *context, int arg1, int arg2));

void my_request(void *context,
                   const unsigned char *req_bytes,
                   int bytes_length,
                   void (*callback)(void *context, const unsigned char *res_bytes));
