# CMake script to help improve cross-platform usage of lua-bz2
# Partly an experiment... a lua rock will be soon
cmake_minimum_required(VERSION 2.6)
project(lua-bz2)

include(FindBZip2)
include(FindLua51)

add_library(bz2 MODULE lbz.c)

set_target_properties(bz2
	PROPERTIES PREFIX "")

include_directories(${BZIP2_INCLUDE_DIR} ${LUA_INCLUDE_DIR})

target_link_libraries(bz2 ${BZIP2_LIBRARIES})
IF(WIN32) #Win32 needs to link against lua...
	target_link_libraries(bz2 ${LUA_LIBRARIES})
ENDIF(WIN32)
