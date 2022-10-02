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

set (IWYU_EXIT_STATUS_WRAPPER
     "${CMAKE_CURRENT_LIST_DIR}/internal/cmtools-iwyu-exit.cmake")
set (_IWYU_LIST_DIR "${CMAKE_CURRENT_LIST_DIR}")


# Functions summary:
# - cmt_target_generate_iwyu
# - cmt_target_enable_iwyu

# ! cmt_find_iwyu
# Try to find the include-what-you-use executable.
# If the executable is not found, the function will throw an error.
#
# cmt_find_iwyu(
#   EXECUTABLE
#   EXECUTABLE_FOUND
# )
#
# \output EXECUTABLE The path to the include-what-you-use executable.
# \output EXECUTABLE_FOUND - True if the executable is found, false otherwise.
# \param BIN_SUBDIR - The subdirectory where the executable is located.
# \group NAMES - The name of the executable.
#
function (cmt_find_iwyu EXECUTABLE EXECUTABLE_FOUND)
    cmake_parse_arguments(ARGS "" "BIN_SUBDIR" "NAMES" ${ARGN})
    cmt_default_argument(ARGS NAMES "include-what-you-use;iwyu")
    cmt_default_argument(ARGS BIN_SUBDIR bin)

    foreach (IWYU_EXECUTABLE_NAME ${ARGS_NAMES})
         cmt_find_tool_executable (${IWYU_EXECUTABLE_NAME}
                                  IWYU_EXECUTABLE
                                  PATHS ${IWYU_SEARCH_PATHS}
                                  PATH_SUFFIXES "${ARGS_BIN_SUBDIR}")
        if (IWYU_EXECUTABLE)
            break ()
        endif ()
    endforeach ()

    cmt_report_not_found_if_not_quiet (include-what-you-use IWYU_EXECUTABLE
        "The 'include-what-you-use' executable was not found in any search or system paths.\n"
        "Please adjust IWYU_SEARCH_PATHS to the installation prefix of the 'include-what-you-use' executable or install include-what-you-use")

    if (IWYU_EXECUTABLE)
        set (IWYU_VERSION_HEADER "clang version ")
        cmt_find_tool_extract_version("${IWYU_EXECUTABLE}"
                                      IWYU_VERSION
                                      VERSION_ARG --version
                                      VERSION_HEADER
                                      "${IWYU_VERSION_HEADER}"
                                      VERSION_END_TOKEN "\n")
    endif()

    cmt_check_and_report_tool_version(include-what-you-use
                                      "${IWYU_VERSION}"
                                      REQUIRED_VARS
                                      IWYU_EXECUTABLE
                                      IWYU_VERSION)
    set (EXECUTABLE ${IWYU_EXECUTABLE} PARENT_SCOPE)
endfunction ()

# ! cmt_target_generate_iwyu\
# Enable include-what-you-use in all targets.
#
# cmt_enable_iwyu()
#
macro(cmt_enable_iwyu)
    cmt_ensure_target(${TARGET})

    if (NOT CMT_ENABLE_IWYU)
        cmt_find_iwyu(EXECUTABLE _)
        set(CMAKE_CXX_INCLUDE_WHAT_YOU_USE ${EXECUTABLE})
        set(CMAKE_C_INCLUDE_WHAT_YOU_USE ${EXECUTABLE})
    endif()

endmacro()


# ! cmt_target_enable_iwyu
# Enable include-what-you-use checks on the given target
#
# cmt_target_use_iwyu(
#   <target>
# )
#
# \input TARGET The target to configure
#
function(cmt_target_enable_iwyu TARGET)
    cmt_ensure_target(${TARGET})

    if (NOT CMT_ENABLE_IWYU)
        return()
    endif()

    cmt_find_iwyu(EXECUTABLE _)
    set_property(TARGET ${TARGET} PROPERTY CMAKE_CXX_INCLUDE_WHAT_YOU_USE ${EXECUTABLE})
    set_property(TARGET ${TARGET} PROPERTY CMAKE_C_INCLUDE_WHAT_YOU_USE ${EXECUTABLE})
endfunction()
