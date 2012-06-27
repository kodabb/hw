#ifndef FLIB_UTIL_H_
#define FLIB_UTIL_H_

#include <stddef.h>
#include <stdarg.h>
#include <stdbool.h>

/**
 * Prints a format string to a newly allocated buffer of the required size.
 * Parameters are like those for printf. Returns NULL on error.
 *
 * Returned buffer must be free()d
 */
char *flib_asprintf(const char *fmt, ...);

/**
 * Exactly as flib_asprintf, but accepts a va_list.
 */
char *flib_vasprintf(const char *fmt, va_list args);

/**
 * Creates a new string (that must be freed) containing all parts
 * joined together, with the specified delimiter between each.
 */
char *flib_join(char **parts, int partCount, const char *delimiter);

/**
 * Return a duplicate of the provided string, or NULL if an error
 * occurs or if str is already NULL.
 *
 * Returned buffer must be free()d
 */
char *flib_strdupnull(const char *str);

/**
 * Return a duplicate of the provided buffer, or NULL if an error
 * occurs or if buf is already NULL or if size is 0.
 *
 * Returned buffer must be free()d
 */
void *flib_bufdupnull(const void *buf, size_t size);

/**
 * Simple malloc wrapper that automatically logs an error if no memory
 * is available. Otherwise behaves exactly like malloc.
 */
void *flib_malloc(size_t size);

/**
 * Simple calloc wrapper that automatically logs an error if no memory
 * is available. Otherwise behaves exactly like calloc.
 */
void *flib_calloc(size_t count, size_t elementsize);

/**
 * Simple realloc wrapper that automatically logs an error if no memory
 * is available. Otherwise behaves exactly like realloc.
 */
void *flib_realloc(void *ptr, size_t size);

/**
 * Replace all non-alphanumeric and non-ascii bytes with escape
 * sequences in the form %XX. Does not modify the original string,
 * but returns a newly allocated one that must be free()d. Returns
 * null on failure or if null was passed as argument.
 *
 * This should work fine with all ASCII-based charsets including UTF-8.
 */
char *flib_urlencode(const char *str);

/**
 * Replace some bytes with escape sequences in the form %XX.
 * Does not modify the original string, but returns a newly allocated
 * one that must be free()d.
 *
 * All bytes for which the predicate function returns true are escaped.
 *
 * Returns null on failure or if null was passed as argument.
 */
char *flib_urlencode_pred(const char *str, bool (*needsEscaping)(char c));

/**
 * Replace escape sequences of the form %XX with their byte values.
 * Does not modify the original string, but returns a newly allocated
 * one that must be free()d. Returns null on failure or if null was
 * passed as argument.
 */
char *flib_urldecode(const char *str);

/**
 * Figure out if the string contains / or \. Useful in routines that
 * construct filenames.
 */
bool flib_contains_dir_separator(const char *str);

int flib_gets(char *str, size_t strlen);

#endif
