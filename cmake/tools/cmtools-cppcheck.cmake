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

include(${CMAKE_CURRENT_LIST_DIR}/cmtools-runner.cmake)

# Functions summary:
# - cmt_target_generate_cppcheck

# ! cmt_find_cppcheck
# Try to find the cppcheck executable.
# If the executable is not found, the function will throw an error.
#
# cmt_find_cppcheck(
#   EXECUTABLE
#   EXECUTABLE_FOUND
# )
#
# \output EXECUTABLE The path to the cppcheck executable.
# \output EXECUTABLE_FOUND - True if the executable is found, false otherwise.
# \param BIN_SUBDIR - The subdirectory where the executable is located.
# \group NAMES - The name of the executable.
#
function (cmt_find_cppcheck EXECUTABLE EXECUTABLE_FOUND)
    cmake_parse_arguments(ARGS "" "BIN_SUBDIR" "NAMES" ${ARGN})
    cmt_default_argument(ARGS NAMES "cppcheck;")
    cmt_default_argument(ARGS BIN_SUBDIR bin)

    foreach (CPPCHECK_EXECUTABLE_NAME ${ARGS_NAMES})
         cmt_find_tool_executable (${CPPCHECK_EXECUTABLE_NAME}
                                  CPPCHECK_EXECUTABLE
                                  PATHS ${CPPCHECK_SEARCH_PATHS}
                                  PATH_SUFFIXES "${ARGS_BIN_SUBDIR}")
        if (CPPCHECK_EXECUTABLE)
            break ()
        endif ()
    endforeach ()

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
    set (EXECUTABLE ${CPPCHECK_EXECUTABLE} PARENT_SCOPE)
endfunction ()

# ! cmt_target_generate_cppcheck
# Enable include-what-you-use in all targets.
#
# cmt_project_enable_cppcheck()
#
macro(cmt_project_enable_cppcheck)
    cmt_ensure_target(${TARGET})

    if (CMT_ENABLE_IWYU)
        cmt_find_cppcheck(EXECUTABLE _)
        set(CMAKE_CXX_CPPCHECK ${EXECUTABLE})
        set(CMAKE_C_CPPCHECK ${EXECUTABLE})
    endif()

endmacro()

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
    if (NOT CMT_ENABLE_CPPCHECK)
        return()
    endif()

    cmt_find_cppcheck(EXECUTABLE _)
    set_property(TARGET ${TARGET} PROPERTY CMAKE_CXX_CPPCHECK ${EXECUTABLE})
    set_property(TARGET ${TARGET} PROPERTY CMAKE_C_CPPCHECK ${EXECUTABLE})
endfunction()