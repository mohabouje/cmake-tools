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

# Functions summary:
# - cmt_target_use_cpplint

# ! cmt_find_cpplint
# Try to find the cpplint executable.
# If the executable is not found, the function will throw an error.
#
# cmt_find_cpplint(
#   EXECUTABLE
# )
#
# \output EXECUTABLE The path to the cpplint executable.
# \param BIN_SUBDIR - The subdirectory where the executable is located.
# \group NAMES - The name of the executable.
#
function (cmt_find_cpplint EXECUTABLE)
    cmake_parse_arguments(ARGS "" "BIN_SUBDIR" "NAMES" ${ARGN})
    cmt_default_argument(ARGS NAMES "cpplint;")
    cmt_default_argument(ARGS BIN_SUBDIR bin)

    cmt_cache_get_tool(CPPLINT EXECUTABLE_FOUND EXECUTABLE_PATH EXECUTABLE_VERSION)
    if (${EXECUTABLE_FOUND})
        set(${EXECUTABLE} ${EXECUTABLE_PATH} PARENT_SCOPE)
        return()
    endif()


    foreach (CPPLINT_EXECUTABLE_NAME ${ARGS_NAMES})
         cmt_find_tool_executable (${CPPLINT_EXECUTABLE_NAME}
                                  CPPLINT_EXECUTABLE
                                  PATHS ${CPPLINT_SEARCH_PATHS}
                                  PATH_SUFFIXES "${ARGS_BIN_SUBDIR}")
        if (CPPLINT_EXECUTABLE)
            break()
        endif()
    endforeach()

    cmt_report_not_found_if_not_quiet (cpplint CPPLINT_EXECUTABLE
        "The 'cpplint' executable was not found in any search or system paths.\n"
        "Please adjust CPPLINT_SEARCH_PATHS to the installation prefix of the 'cpplint' executable or install cpplint")

    if (CPPLINT_EXECUTABLE)
        set (CPPLINT_VERSION_HEADER "Cpplint fork (https://github.com/cpplint/cpplint)\ncpplint ")
        cmt_find_tool_extract_version("${CPPLINT_EXECUTABLE}"
                                      CPPLINT_VERSION
                                      VERSION_ARG --version
                                      VERSION_HEADER
                                      "${CPPLINT_VERSION_HEADER}"
                                      VERSION_END_TOKEN "\n")
    endif()

    cmt_check_and_report_tool_version(cpplint
                                      "${CPPLINT_VERSION}"
                                      REQUIRED_VARS
                                      CPPLINT_EXECUTABLE
                                      CPPLINT_VERSION)
    cmt_cache_set_tool(CPPLINT TRUE ${CPPLINT_EXECUTABLE} ${CPPLINT_VERSION})
    set (EXECUTABLE ${CPPLINT_EXECUTABLE} PARENT_SCOPE)
endfunction()

# ! cmt_target_generate_cpplint
# Enable include-what-you-use in all targets.
#
# cmt_enable_cpplint()
#
macro(cmt_enable_cpplint)
    cmt_ensure_target(${TARGET})

    if (CMT_ENABLE_IWYU)
        cmt_find_cpplint(EXECUTABLE)
        set(CMAKE_CXX_CPPLINT ${EXECUTABLE})
        set(CMAKE_C_CPPLINT ${EXECUTABLE})
    endif()

endmacro()

# ! cmt_target_enable_cpplint
# Enable include-what-you-use checks on the given target
#
# cmt_target_enable_cpplint(
#   TARGET
# )
#
# \input TARGET The target to enable the cpplint checks
#
function(cmt_target_enable_cpplint TARGET)
    cmt_ensure_target(${TARGET})

    if (NOT CMT_ENABLE_CPPLINT)
        return()
    endif()

    cmt_find_cpplint(EXECUTABLE)
    set_property(TARGET ${TARGET} PROPERTY CMAKE_CXX_CPPLINT ${EXECUTABLE})
    set_property(TARGET ${TARGET} PROPERTY CMAKE_C_CPPLINT ${EXECUTABLE})
endfunction()

# ! cmt_target_generate_cpplint
# Generates a new target that compiles with cpplint
#
# cmt_target_generate_cpplint(
#   TARGET
# )
#
# \input TARGET The target to configure
#
function(cmt_target_generate_cpplint TARGET)
    cmake_parse_arguments(ARGS "ALL;DEFAULT;" "SUFFIX;GLOBAL" "" ${ARGN})
    cmt_default_argument(ARGS SUFFIX "cpplint")
    cmt_default_argument(ARGS GLOBAL "cpplint")
    cmt_ensure_target(${TARGET})
    
    if (NOT CMT_ENABLE_CCACHE)
        return()
    endif()

    cmt_find_cpplint(EXECUTABLE)

    set(TARGET_NAME ${TARGET}-${ARGS_SUFFIX})
    cmt_create_mirrored_build_target(${TARGET} ${ARGS_SUFFIX})
    cmt_target_enable_cpplint(${TARGET_NAME})
    cmt_forward_arguments(ARGS "ALL;DEFAULT" "" "" REGISTER_ARGS)
    cmt_target_register(${TARGET_NAME} ${ARGS_GLOBAL} ${REGISTER_ARGS})
endfunction()