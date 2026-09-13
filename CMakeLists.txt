cmake_minimum_required(VERSION 3.16)
project(raylib-lua C)

set(CMAKE_C_STANDARD 99)
set(CMAKE_C_STANDARD_REQUIRED ON)

# raylib 6.0: set RAYLIB_DIR to the prefix containing include/raylib.h and the library,
# or rely on find_package(raylib) if raylib was installed with CMake.
if(DEFINED ENV{RAYLIB_DIR} AND NOT DEFINED RAYLIB_DIR)
    set(RAYLIB_DIR $ENV{RAYLIB_DIR})
endif()

find_package(raylib 6.0 QUIET)

if(NOT raylib_FOUND)
    if(NOT RAYLIB_DIR)
        set(RAYLIB_DIR "" CACHE PATH "Path to a raylib 6.0 install (include/ + lib/)")
    endif()
    if(RAYLIB_DIR)
        find_path(RAYLIB_INCLUDE_DIR raylib.h HINTS ${RAYLIB_DIR} ${RAYLIB_DIR}/include)
        find_library(RAYLIB_LIBRARY raylib HINTS ${RAYLIB_DIR} ${RAYLIB_DIR}/lib ${RAYLIB_DIR}/lib/raylib)
        if(RAYLIB_INCLUDE_DIR AND RAYLIB_LIBRARY)
            add_library(raylib UNKNOWN IMPORTED)
            set_target_properties(raylib PROPERTIES
                IMPORTED_LOCATION "${RAYLIB_LIBRARY}"
                INTERFACE_INCLUDE_DIRECTORIES "${RAYLIB_INCLUDE_DIR}")
            set(raylib_FOUND TRUE)
        endif()
    endif()
endif()

if(NOT raylib_FOUND)
    message(FATAL_ERROR "raylib 6.0 not found. Install it or pass -DRAYLIB_DIR=/path/to/raylib")
endif()

# Vendored Lua 5.3.3 compiled from source so the host matches the current compiler
# (the prebuilt liblua53.a under src/external/lua/lib is 32-bit MinGW).
set(LUA_SRC_DIR ${CMAKE_SOURCE_DIR}/src/external/lua/src)
set(LUA_SOURCES
    lapi.c lcode.c lctype.c ldebug.c ldo.c ldump.c lfunc.c lgc.c llex.c
    lmem.c lobject.c lopcodes.c lparser.c lstate.c lstring.c ltable.c
    ltm.c lundump.c lvm.c lzio.c
    lauxlib.c lbaselib.c lbitlib.c lcorolib.c ldblib.c liolib.c
    lmathlib.c loslib.c lstrlib.c ltablib.c lutf8lib.c loadlib.c linit.c)
list(TRANSFORM LUA_SOURCES PREPEND ${LUA_SRC_DIR}/)
add_library(lua53 STATIC ${LUA_SOURCES})
target_include_directories(lua53 PUBLIC ${LUA_SRC_DIR})

function(rlua_host target source)
    add_executable(${target} ${source})
    target_include_directories(${target} PRIVATE
        ${CMAKE_SOURCE_DIR}/src
        ${LUA_SRC_DIR})
    target_link_libraries(${target} PRIVATE raylib lua53)
    if(WIN32)
        target_link_libraries(${target} PRIVATE opengl32 gdi32 winmm)
    elseif(UNIX AND NOT APPLE)
        target_link_libraries(${target} PRIVATE m pthread dl)
    endif()
endfunction()

rlua_host(rlualauncher tools/rLuaLauncher/rlualauncher.c)
rlua_host(rlua_tester examples/rlua_tester.c)
rlua_host(rlua_basic examples/basic.c)
