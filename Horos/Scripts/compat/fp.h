/*
 * Shim for the libpng copies bundled with VTK and ITK (pngpriv.h).
 *
 * pngpriv.h includes the classic Mac OS <fp.h> whenever TARGET_OS_MAC is defined,
 * which current macOS SDKs always define. <fp.h> no longer exists; <math.h> provides
 * everything libpng needs from it.
 */
#include <math.h>
