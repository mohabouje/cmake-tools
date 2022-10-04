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
# - cmt_target_use_mdl

# ! cmt_find_mdl
# Try to find the mdl executable.
# If the executable is not found, the function will throw an error.
#
# cmt_find_mdl(
#   EXECUTABLE
# )
#
# \output EXECUTABLE The path to the mdl executable.
# \param BIN_SUBDIR - The subdirectory where the executable is located.
# \group NAMES - The name of the executable.
#
function (cmt_find_mdl EXECUTABLE)
    cmt_parse_arguments(ARGS "" "BIN_SUBDIR" "NAMES" ${ARGN})
    cmt_default_argument(ARGS NAMES "mdl;")
    cmt_default_argument(ARGS BIN_SUBDIR bin)

    cmt_cache_get_tool(MDL EXECUTABLE_FOUND EXECUTABLE_PATH EXECUTABLE_VERSION)
    if (${EXECUTABLE_FOUND})
        set(${EXECUTABLE} ${EXECUTABLE_PATH} PARENT_SCOPE)
        return()
    endif()

    foreach (MDL_EXECUTABLE_NAME ${ARGS_NAMES})
         cmt_find_tool_executable (${MDL_EXECUTABLE_NAME}
                                  MDL_EXECUTABLE
                                  PATHS ${MDL_SEARCH_PATHS}
                                  PATH_SUFFIXES "${ARGS_BIN_SUBDIR}")
        if (MDL_EXECUTABLE)
            break()
        endif()
    endforeach()

    cmt_report_not_found_if_not_quiet (mdl MDL_EXECUTABLE
        "The 'mdl' executable was not found in any search or system paths.\n"
        "Please adjust MDL_SEARCH_PATHS to the installation prefix of the 'mdl' executable or install mdl")

    if (MDL_EXECUTABLE)
        cmt_find_tool_extract_version("${MDL_EXECUTABLE}"
                                      MDL_VERSION
                                      VERSION_ARG --version)
    endif()

    cmt_check_and_report_tool_version(mdl
                                      "${MDL_VERSION}"
                                      REQUIRED_VARS
                                      MDL_EXECUTABLE
                                      MDL_VERSION)
    cmt_cache_set_tool(MDL ${MDL_EXECUTABLE_FOUND} ${MDL_EXECUTABLE} ${MDL_VERSION})
    set (EXECUTABLE ${MDL_EXECUTABLE} PARENT_SCOPE)
endfunction()
