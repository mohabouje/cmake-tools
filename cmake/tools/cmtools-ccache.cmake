##################################################################################
# MIT License                                                                    #
#                                                                                #
# Copyright (c) 2022 Mohammed Boujemaoui Boulaghmoudi                            #
#                                                                                #
# Permission is hereby granted, free of charge, to any person obtaining a copy   #
# of this software and associated documentation files (the "Software"), to deal  #
# in the Software without restriction, including without limitation the rights   #
# to use, copy, modify, merge, publish, distribute, sublicense, and/or sell      #
# copies of the Software, and to permit persons to whom the Software is          #
# furnished to do so, subject to the following conditions:                       #
#                                                                                #
# The above copyright notice and this permission notice shall be included in all #
# copies or substantial portions of the Software.                                #
#                                                                                #
# THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR     #
# IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,       #
# FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE    #
# AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER         #
# LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,  #
# OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE  #
# SOFTWARE.                                                                      #
##################################################################################

include_guard(GLOBAL)

include(${CMAKE_CURRENT_LIST_DIR}/./../utility/cmtools-args.cmake)
include(${CMAKE_CURRENT_LIST_DIR}/./../utility/cmtools-env.cmake)
include(${CMAKE_CURRENT_LIST_DIR}/./../utility/cmtools-env.cmake)


# Functions summary:
# - cmt_target_use_ccache

# ! cmt_find_ccache
# Try to find the ccache executable.
# If the executable is not found, the function will throw an error.
#
# cmt_find_ccache(
#   EXECUTABLE
# )
#
# \output EXECUTABLE The path to the ccache executable.
# \param BIN_SUBDIR - The subdirectory where the executable is located.
# \group NAMES - The name of the executable.
#
function (cmt_find_ccache EXECUTABLE)
    cmake_parse_arguments(ARGS "" "BIN_SUBDIR" "NAMES" ${ARGN})
    cmt_default_argument(ARGS NAMES "ccache;")
    cmt_default_argument(ARGS BIN_SUBDIR bin)

    cmt_cache_get_tool(CCACHE EXECUTABLE_FOUND EXECUTABLE_PATH EXECUTABLE_VERSION)
    if (${EXECUTABLE_FOUND})
        set(${EXECUTABLE} ${EXECUTABLE_PATH} PARENT_SCOPE)
        return()
    endif()

    foreach (CCACHE_EXECUTABLE_NAME ${ARGS_NAMES})
         cmt_find_tool_executable (${CCACHE_EXECUTABLE_NAME}
                                  CCACHE_EXECUTABLE
                                  PATHS ${CCACHE_SEARCH_PATHS}
                                  PATH_SUFFIXES "${ARGS_BIN_SUBDIR}")
        if (CCACHE_EXECUTABLE)
            break()
        endif()
    endforeach()

    cmt_report_not_found_if_not_quiet (ccache CCACHE_EXECUTABLE
        "The 'ccache' executable was not found in any search or system paths.\n"
        "Please adjust CCACHE_SEARCH_PATHS to the installation prefix of the 'ccache' executable or install ccache")

    if (CCACHE_EXECUTABLE)
        set (CCACHE_VERSION_HEADER "ccache version ")
        cmt_find_tool_extract_version("${CCACHE_EXECUTABLE}"
                                      CCACHE_VERSION
                                      VERSION_ARG --version
                                      VERSION_HEADER
                                      "${CCACHE_VERSION_HEADER}"
                                      VERSION_END_TOKEN "\n")
    endif()

    cmt_check_and_report_tool_version(ccache
                                      "${CCACHE_VERSION}"
                                      REQUIRED_VARS
                                      CCACHE_EXECUTABLE
                                      CCACHE_VERSION)

    cmt_cache_set_tool(CCACHE TRUE ${CCACHE_EXECUTABLE} ${CCACHE_VERSION})
    set (EXECUTABLE ${CCACHE_EXECUTABLE} PARENT_SCOPE)
endfunction()

# ! cmt_target_generate_ccache\
# Enable include-what-you-use in all targets.
#
# cmt_enable_ccache()
#
macro(cmt_enable_ccache)
    cmt_ensure_target(${TARGET})

    if (CMT_ENABLE_IWYU)
        cmt_find_ccache(EXECUTABLE)
        set(C_COMPILER_LAUNCHER ${EXECUTABLE})
        set(CXX_COMPILER_LAUNCHER ${EXECUTABLE})
    endif()

endmacro()

# ! cmt_target_use_ccache
# Enable ccache use on the given target
#
# cmt_target_use_ccache(
#   TARGET
# )
#
# \input TARGET The target to configure
#
function(cmt_target_enable_ccache TARGET)
    cmt_ensure_target(${TARGET}) 
    
    if (NOT CMT_ENABLE_CCACHE)
        return()
    endif()
    
    cmt_find_ccache(EXECUTABLE)
    set_target_properties(${TARGET} PROPERTIES C_COMPILER_LAUNCHER "${EXECUTABLE}")
    set_target_properties(${TARGET} PROPERTIES CXX_COMPILER_LAUNCHER "${EXECUTABLE}")
endfunction()


# ! cmt_target_generate_ccache
# Generates a new target that compiles with ccache
#
# cmt_target_generate_ccache(
#   TARGET
# )
#
# \input TARGET The target to configure
#
function(cmt_target_generate_ccache TARGET)
    cmake_parse_arguments(ARGS "" "SUFFIX;GLOBAL" "" ${ARGN})
    cmt_default_argument(ARGS SUFFIX "ccache")
    cmt_default_argument(ARGS GLOBAL "ccache")
    cmt_ensure_target(${TARGET})
    
    if (NOT CMT_ENABLE_CCACHE)
        return()
    endif()

    cmt_find_ccache(EXECUTABLE)

    set(TARGET_NAME ${TARGET}-${ARGS_SUFFIX})
    cmt_create_mirrored_build_target(${TARGET} ${ARGS_SUFFIX})
    cmt_target_enable_ccache(${TARGET_NAME})
    cmt_target_register(${TARGET_NAME} ${ARGS_GLOBAL})
endfunction()