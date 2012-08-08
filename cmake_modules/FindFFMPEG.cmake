# - Try to find libxml++-2.6
# Once done this will define
#
#  FFMPEG_FOUND - system has libxml++
#  FFMPEG_INCLUDE_DIRS - the libxml++ include directory
#  FFMPEG_LIBRARIES - Link these to use libxml++
#  FFMPEG_DEFINITIONS - Compiler switches required for using libxml++
#
#  Copyright (c) 2008 Andreas Schneider <mail@cynapses.org>
#  Modified for other libraries by Lasse Kärkkäinen <tronic>
#  Modified for Hedgewars by Stepik777
#
#  Redistribution and use is allowed according to the terms of the New
#  BSD license.
#

if (FFMPEG_LIBRARIES AND FFMPEG_INCLUDE_DIRS)
  # in cache already
  set(FFMPEG_FOUND TRUE)
else (FFMPEG_LIBRARIES AND FFMPEG_INCLUDE_DIRS)
  # use pkg-config to get the directories and then use these values
  # in the FIND_PATH() and FIND_LIBRARY() calls
  find_package(PkgConfig)
  if (PKG_CONFIG_FOUND)
    pkg_check_modules(_FFMPEG_AVCODEC libavcodec)
    pkg_check_modules(_FFMPEG_AVFORMAT libavformat)
    pkg_check_modules(_FFMPEG_AVUTIL libavutil)
  endif (PKG_CONFIG_FOUND)

  find_path(FFMPEG_AVCODEC_INCLUDE_DIR
    NAMES avcodec.h
    PATHS ${_FFMPEG_AVCODEC_INCLUDE_DIRS} /usr/include /usr/local/include /opt/local/include /sw/include
    PATH_SUFFIXES ffmpeg libavcodec
  )

  find_path(FFMPEG_AVFORMAT_INCLUDE_DIR
    NAMES avformat.h
    PATHS ${_FFMPEG_AVFORMAT_INCLUDE_DIRS} /usr/include /usr/local/include /opt/local/include /sw/include
    PATH_SUFFIXES ffmpeg libavformat
  )

  find_library(FFMPEG_AVCODEC_LIBRARY
    NAMES avcodec
    PATHS ${_FFMPEG_AVCODEC_LIBRARY_DIRS} /usr/lib /usr/local/lib /opt/local/lib /sw/lib
  )

  find_library(FFMPEG_AVFORMAT_LIBRARY
    NAMES avformat
    PATHS ${_FFMPEG_AVFORMAT_LIBRARY_DIRS} /usr/lib /usr/local/lib /opt/local/lib /sw/lib
  )

  find_library(FFMPEG_AVUTIL_LIBRARY
    NAMES avutil
    PATHS ${_FFMPEG_AVUTIL_LIBRARY_DIRS} /usr/lib /usr/local/lib /opt/local/lib /sw/lib
  )

  if (FFMPEG_AVCODEC_LIBRARY AND FFMPEG_AVFORMAT_LIBRARY)
    set(FFMPEG_FOUND TRUE)
  endif (FFMPEG_AVCODEC_LIBRARY AND FFMPEG_AVFORMAT_LIBRARY)

  if (FFMPEG_FOUND)

    set(FFMPEG_INCLUDE_DIR
      ${FFMPEG_AVCODEC_INCLUDE_DIR}
      ${FFMPEG_AVFORMAT_INCLUDE_DIR}
    )

    set(FFMPEG_LIBRARIES
      ${FFMPEG_AVCODEC_LIBRARY}
      ${FFMPEG_AVFORMAT_LIBRARY}
      ${FFMPEG_AVUTIL_LIBRARY}
    )

  endif (FFMPEG_FOUND)

  if (FFMPEG_FOUND)
    if (NOT FFMPEG_FIND_QUIETLY)
      message(STATUS "Found FFMPEG: ${FFMPEG_LIBRARIES}")
    endif (NOT FFMPEG_FIND_QUIETLY)
  else (FFMPEG_FOUND)
    if (FFMPEG_FIND_REQUIRED)
      message(FATAL_ERROR "Could not find FFMPEG libavcodec, libavformat or libswscale")
    endif (FFMPEG_FIND_REQUIRED)
  endif (FFMPEG_FOUND)

endif (FFMPEG_LIBRARIES AND FFMPEG_INCLUDE_DIRS)

