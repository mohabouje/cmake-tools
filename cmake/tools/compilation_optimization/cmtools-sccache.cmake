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

# Functions summary:
# - cmt_target_use_sccache

# ! cmt_find_sccache
# Try to find the sccache executable.
# If the executable is not found, the function will throw an error.
#
# cmt_find_sccache(
#   EXECUTABLE
# )
#
# \output EXECUTABLE The path to the sccache executable.
# \param BIN_SUBDIR - The subdirectory where the executable is located.
# \group NAMES - The name of the executable.
#
function (cmt_find_sccache EXECUTABLE)
    cmt_parse_arguments(ARGS "" "BIN_SUBDIR" "NAMES" ${ARGN})
    cmt_default_argument(ARGS NAMES "sccache;")
    cmt_default_argument(ARGS BIN_SUBDIR bin)

    cmt_cache_get_tool(sccache EXECUTABLE_FOUND EXECUTABLE_PATH EXECUTABLE_VERSION)
    if (${EXECUTABLE_FOUND})
        set(${EXECUTABLE} ${EXECUTABLE_PATH} PARENT_SCOPE)
        return()
    endif()

    foreach (SCCACHE_EXECUTABLE_NAME ${ARGS_NAMES})
        cmt_find_tool_executable (${SCCACHE_EXECUTABLE_NAME}
                SCCACHE_EXECUTABLE
                PATHS ${SCCACHE_SEARCH_PATHS}
                PATH_SUFFIXES "${ARGS_BIN_SUBDIR}")
        if (SCCACHE_EXECUTABLE)
            break()
        endif()
    endforeach()

    cmt_report_not_found_if_not_quiet (sccache SCCACHE_EXECUTABLE
            "The 'sccache' executable was not found in any search or system paths.\n"
            "Please adjust SCCACHE_SEARCH_PATHS to the installation prefix of the 'sccache' executable or install sccache")

    if (SCCACHE_EXECUTABLE)
        set (SCCACHE_VERSION_HEADER "sccache ")
        cmt_find_tool_extract_version("${SCCACHE_EXECUTABLE}"
                SCCACHE_VERSION
                VERSION_ARG --version
                VERSION_HEADER
                "${SCCACHE_VERSION_HEADER}"
                VERSION_END_TOKEN "\n")
    endif()

    cmt_check_and_report_tool_version(sccache
            "${SCCACHE_VERSION}"
            REQUIRED_VARS
            SCCACHE_EXECUTABLE
            SCCACHE_VERSION)

    cmt_cache_set_tool(sccache ${SCCACHE_EXECUTABLE} ${SCCACHE_VERSION})
    set (${EXECUTABLE} ${SCCACHE_EXECUTABLE} PARENT_SCOPE)
endfunction()

# ! cmt_target_generate_sccache\
# Enable include-what-you-use in all targets.
#
# cmt_enable_sccache()
#
macro(cmt_enable_sccache)
    if (CMT_ENABLE_SCCACHE)
        cmt_find_sccache(EXECUTABLE)
        set(C_COMPILER_LAUNCHER ${EXECUTABLE})
        set(CXX_COMPILER_LAUNCHER ${EXECUTABLE})
    endif()
endmacro()

# ! cmt_target_use_sccache
# Enable sccache use on the given target
#
# cmt_target_use_sccache(
#   TARGET
# )
#
# \input TARGET The target to configure
#
function(cmt_target_enable_sccache TARGET)
    cmt_ensure_target(${TARGET})

    if (NOT CMT_ENABLE_SCCACHE)
        return()
    endif()

    cmt_find_sccache(EXECUTABLE)
    cmt_target_set_property(${TARGET} C_COMPILER_LAUNCHER ${EXECUTABLE})
    cmt_target_set_property(${TARGET} CXX_COMPILER_LAUNCHER ${EXECUTABLE})
endfunction()


# ! cmt_target_generate_sccache
# Generates a new target that compiles with sccache
#
# cmt_target_generate_sccache(
#   TARGET
# )
#
# \input TARGET The target to configure
#
function(cmt_target_generate_sccache TARGET)
    cmt_parse_arguments(ARGS "ALL;DEFAULT;" "SUFFIX;GLOBAL" "" ${ARGN})
    cmt_default_argument(ARGS SUFFIX "sccache")
    cmt_default_argument(ARGS GLOBAL "sccache")
    cmt_ensure_target(${TARGET})

    if (NOT CMT_ENABLE_SCCACHE)
        return()
    endif()

    cmt_find_sccache(EXECUTABLE)

    set(TARGET_NAME ${TARGET}_${ARGS_SUFFIX})
    cmt_target_create_mirror(${TARGET} ${ARGS_SUFFIX})
    cmt_target_enable_sccache(${TARGET_NAME})

    cmt_forward_arguments(ARGS "ALL;DEFAULT" "" "" REGISTER_ARGS)
    cmt_target_register_in_group(${TARGET_NAME} ${ARGS_GLOBAL} ${REGISTER_ARGS})
endfunction()