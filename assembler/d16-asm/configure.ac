#                                               -*- Autoconf -*-
# Process this file with autoconf to produce a configure script.
AC_PREREQ([2.6])
AC_INIT([d16-asm], [0.1], [mtnolan2640@gmail.com])
AM_INIT_AUTOMAKE([0.1 foreign subdir-objects])
AC_CONFIG_SRCDIR([instruction.c])
AC_CONFIG_HEADERS([config.h])

# Checks for programs.
AC_PROG_CC([gcc clang])
AC_PROG_YACC
AM_PROG_LEX
CFLAGS="$CFLAGS -Wall"
PKG_PROG_PKG_CONFIG
PKG_CHECK_MODULES([GLIB],[glib-2.0 >= 2.24.1])
# Checks for libraries.

# Checks for header files.
AC_CHECK_HEADERS([inttypes.h stdlib.h string.h])

# Checks for typedefs, structures, and compiler characteristics.
AC_TYPE_SIZE_T
AC_TYPE_UINT16_T
AC_TYPE_UINT8_T

# Checks for library functions.
AC_FUNC_MALLOC
AC_CHECK_FUNCS([strdup strtol])

AC_OUTPUT(Makefile)
