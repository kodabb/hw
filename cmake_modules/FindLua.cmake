# Find liblua
#
# Once done this will define
#  LUA_FOUND - system has Lua
#  LUA_INCLUDE_DIR - the Lua include directory
#  LUA_LIBRARY - The library needed to use Lua
# Copyright (c) 2013, Vittorio Giovara <vittorio.giovara@gmail.com>
#
# Distributed under the OSI-approved BSD License (the "License");
# see accompanying file Copyright.txt for details.
#
# This software is distributed WITHOUT ANY WARRANTY; without even the
# implied warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.
# See the License for more information.

include(FindPackageHandleStandardArgs)

find_path(LUA_INCLUDE_DIR lua.h
                          PATHS /usr/include /usr/local/include /usr/pkg/include
                          PATH_SUFFIXES lua5.2 lua52)
find_library(LUA_LIBRARY NAMES lua52 lua5.2 lua-5.2 lua
                         PATHS /lib /usr/lib /usr/local/lib /usr/pkg/lib)

find_package_handle_standard_args(Lua DEFAULT_MSG LUA_LIBRARY LUA_INCLUDE_DIR)
mark_as_advanced(LUA_INCLUDE_DIR LUA_LIBRARY)
