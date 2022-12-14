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
# - cmt_target_generate_cppcheck

# ! cmt_find_cppcheck
# Try to find the cppcheck executable.
# If the executable is not found, the function will throw an error.
#
# cmt_find_cppcheck(
#   EXECUTABLE
# )
#
# \output EXECUTABLE The path to the cppcheck executable.
# \param BIN_SUBDIR - The subdirectory where the executable is located.
# \group NAMES - The name of the executable.
#
function (cmt_find_cppcheck EXECUTABLE)
    cmt_parse_arguments(ARGS "" "BIN_SUBDIR" "NAMES" ${ARGN})
    cmt_default_argument(ARGS NAMES "cppcheck;")
    cmt_default_argument(ARGS BIN_SUBDIR bin)

    cmt_cache_get_tool(CPPCHECK EXECUTABLE_FOUND EXECUTABLE_PATH EXECUTABLE_VERSION)
    if (${EXECUTABLE_FOUND})
        set(${EXECUTABLE} ${EXECUTABLE_PATH} PARENT_SCOPE)
        return()
    endif()

    foreach (CPPCHECK_EXECUTABLE_NAME ${ARGS_NAMES})
         cmt_find_tool_executable (${CPPCHECK_EXECUTABLE_NAME}
                                  CPPCHECK_EXECUTABLE
                                  PATHS ${CPPCHECK_SEARCH_PATHS}
                                  PATH_SUFFIXES "${ARGS_BIN_SUBDIR}")
        if (CPPCHECK_EXECUTABLE)
            break()
        endif()
    endforeach()

    cmt_report_not_found_if_not_quiet (cppcheck CPPCHECK_EXECUTABLE
        "The 'cppcheck' executable was not found in any search or system paths.\n"
        "Please adjust CPPCHECK_SEARCH_PATHS to the installation prefix of the 'cppcheck' executable or install cppcheck")

    if (CPPCHECK_EXECUTABLE)
        set (CPPCHECK_VERSION_HEADER "Cppcheck ")
        cmt_find_tool_extract_version("${CPPCHECK_EXECUTABLE}"
                                      CPPCHECK_VERSION
                                      VERSION_ARG --version
                                      VERSION_HEADER
                                      "${CPPCHECK_VERSION_HEADER}"
                                      VERSION_END_TOKEN "\n")
    endif()

    cmt_check_and_report_tool_version(cppcheck
                                      "${CPPCHECK_VERSION}"
                                      REQUIRED_VARS
                                      CPPCHECK_EXECUTABLE
                                      CPPCHECK_VERSION)
    cmt_cache_set_tool(CPPCHECK ${CPPCHECK_EXECUTABLE} ${CPPCHECK_VERSION})
    set (${EXECUTABLE} ${CPPCHECK_EXECUTABLE} PARENT_SCOPE)
endfunction()

# ! cmt_target_generate_cppcheck
# Enable include-what-you-use in all targets.
#
# cmt_enable_cppcheck()
#
function(cmt_enable_cppcheck)
    if (NOT CMT_ENABLE_STATIC_ANALYSIS )
        return()
    endif()

    if (NOT CMT_ENABLE_CPPCHECK)
        return()
    endif()

    cmt_find_cppcheck(EXECUTABLE)
    set(CMAKE_CXX_CPPCHECK ${EXECUTABLE} PARENT_SCOPE)
    set(CMAKE_C_CPPCHECK ${EXECUTABLE} PARENT_SCOPE)
endfunction()

# ! cmt_target_enable_cppcheck
# Enable include-what-you-use checks on the given target
#
# cmt_target_enable_cppcheck(
#   TARGET
# )
#
# \input TARGET The target to enable the cppcheck checks for.
#
function(cmt_target_enable_cppcheck TARGET)
    cmt_ensure_target(${TARGET})

    if (NOT CMT_ENABLE_STATIC_ANALYSIS )
        return()
    endif()

    if (NOT CMT_ENABLE_CPPCHECK)
        return()
    endif()

    cmt_find_cppcheck(EXECUTABLE)
    cmt_target_set_property(${TARGET} CXX_CPPCHECK ${EXECUTABLE})
    cmt_target_set_property(${TARGET} C_CPPCHECK ${EXECUTABLE})
    cmt_debug("Enable cppcheck checks for target ${TARGET}")
endfunction()

# ! cmt_target_generate_cppcheck
# Generates a new target that compiles with cppcheck
#
# cmt_target_generate_cppcheck(
#   TARGET
# )
#
# \input TARGET The target to configure
#
function(cmt_target_generate_cppcheck TARGET)
    cmt_parse_arguments(ARGS "ALL;DEFAULT" "SUFFIX;GLOBAL" "" ${ARGN})
    cmt_default_argument(ARGS SUFFIX "cppcheck")
    cmt_default_argument(ARGS GLOBAL "cppcheck")
    cmt_ensure_target(${TARGET})

    if (NOT CMT_ENABLE_STATIC_ANALYSIS )
        return()
    endif()

    if (NOT CMT_ENABLE_CPPCHECK)
        return()
    endif()

    cmt_find_cppcheck(EXECUTABLE)

    set(TARGET_NAME ${TARGET}_${ARGS_SUFFIX})
    cmt_target_create_mirror(${TARGET} ${ARGS_SUFFIX})
    cmt_target_enable_cppcheck(${TARGET_NAME})
    cmt_forward_arguments(ARGS "ALL;DEFAULT" "" "" REGISTER_ARGS)
    cmt_target_register_in_group(${TARGET_NAME} ${ARGS_GLOBAL} ${REGISTER_ARGS})
endfunction()