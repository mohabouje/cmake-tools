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

cmt_disable_logger()
include(${CMAKE_CURRENT_LIST_DIR}/./../third_party/lizard.cmake)
cmt_enable_logger()

# Functions summary:
# - cmt_target_generate_lizard
# - cmt_find_lizard

# ! cmt_find_lizard
# Try to find the lizard executable.
# If the executable is not found, the function will throw an error.
#
# cmt_find_lizard(
#   EXECUTABLE
#   EXECUTABLE_FOUND
# )
#
# \output EXECUTABLE The path to the lizard executable.
# \output EXECUTABLE_FOUND - True if the executable is found, false otherwise.
# \param BIN_SUBDIR - The subdirectory where the executable is located.
# \group NAMES - The name of the executable.
#
function (cmt_find_lizard EXECUTABLE EXECUTABLE_FOUND)
    cmake_parse_arguments(ARGS "" "BIN_SUBDIR" "NAMES" ${ARGN})
    cmt_default_argument(ARGS NAMES "lizard")
    cmt_default_argument(ARGS BIN_SUBDIR bin)

    foreach (LIZARD_EXECUTABLE_NAME ${ARGS_NAMES})
         cmt_find_tool_executable (${LIZARD_EXECUTABLE_NAME}
                                  LIZARD_EXECUTABLE
                                  PATHS ${LIZARD_SEARCH_PATHS}
                                  PATH_SUFFIXES "${ARGS_BIN_SUBDIR}")
        if (LIZARD_EXECUTABLE)
            break ()
        endif ()
    endforeach ()

    cmt_report_not_found_if_not_quiet (lizard LIZARD_EXECUTABLE
        "The 'lizard' executable was not found in any search or system paths.\n"
        "Please adjust LIZARD_SEARCH_PATHS to the installation prefix of the 'lizard' executable or install lizard")

    # if (LIZARD_EXECUTABLE)
    #     set (LIZARD_VERSION_HEADER "Lizard command line interface 64-bit")
    #     cmt_find_tool_extract_version("${LIZARD_EXECUTABLE}"
    #                                   LIZARD_VERSION
    #                                   VERSION_ARG -V
    #                                   VERSION_HEADER
    #                                   "${LIZARD_VERSION_HEADER}"
    #                                   VERSION_END_TOKEN "by Y.Collet & P.Skibinski (Oct 29 2021)")
    # endif()
    set(LIZARD_VERSION "Unknown")
    cmt_check_and_report_tool_version(lizard
                                      "${LIZARD_VERSION}"
                                      REQUIRED_VARS
                                      LIZARD_EXECUTABLE
                                      LIZARD_VERSION)
    set (EXECUTABLE ${LIZARD_EXECUTABLE} PARENT_SCOPE)
endfunction ()

# ! cmt_target_generate_lizard
# Generate a lizard target for the target.
# The generated target lanch lizard on all the target sources in the specified working directory.
#
# cmt_target_generate_lizard(
#   TARGET
# )
#
# \input TARGET The target to generate the lizard target for.
#
function(cmt_target_generate_lizard TARGET)
    cmt_ensure_target(${TARGET})
    if (NOT CMT_ENABLE_LIZARD)
        return()
    endif()

    cmt_find_lizard(EXECUTABLE _)
    lizard(TARGET ${TARGET})
    cmt_log("Target ${TARGET}: generate target to run lizard")
endfunction()