/*!
  \file
  \brief Softwaretrace common header file.
 */


#if !defined (__SWTRCOMMON_H__)
#define __SWTRCOMMON_H__


#if defined (__FreeBSD__) || defined (__linux__)
#define SWTRLIB_CURRENT_OS_SUPPORTED 1
#else
#error "Unsupported Operating System"
#endif 

#endif
