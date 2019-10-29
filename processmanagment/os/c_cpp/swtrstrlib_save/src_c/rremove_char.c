#include <string.h>
#include "swtrstrlib.h"

int swtrstrlib_right_remove_char(char *inbuf, char remove_char) {
  int result = SWTRSTRLIB_SUCCESS;
  char *look_ptr = NULL;
  size_t len = 0;
  if ((inbuf != NULL) && (remove_char != SWTRSTRLIB_STRING_TERMINATOR_C)) {
    look_ptr = inbuf;
    look_ptr += strlen(inbuf);
    look_ptr--;
    while (look_ptr != inbuf) {
      if (*(look_ptr) == remove_char) {
	*(look_ptr) = SWTRSTRLIB_STRING_TERMINATOR_C;
      } else {
	  break;
      }
      look_ptr--;
    }
  }
  else {
    result = SWTRSTRLIB_FAILURE;
  }
  return result;
};
