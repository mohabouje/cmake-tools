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

# ! cmt_find_codechecker
# Try to find the codechecker executable.
# If the executable is not found, the function will throw an error.
#
# cmt_find_codechecker(
#   EXECUTABLE
#   CODECHECKER_FOUND
# )
#
# \output EXECUTABLE The path to the codechecker executable.
# \output CODECHECKER_FOUND - True if the executable is found, false otherwise.
# \param BIN_SUBDIR - The subdirectory where the executable is located.
# \group NAMES - The name of the executable.
#
function (cmt_find_codechecker EXECUTABLE)
    cmt_parse_arguments(ARGS "" "BIN_SUBDIR" "NAMES" ${ARGN})
    cmt_default_argument(ARGS NAMES "codechecker;")
    cmt_default_argument(ARGS BIN_SUBDIR bin)

    cmt_cache_get_tool(CODECHECKER EXECUTABLE_FOUND EXECUTABLE_PATH EXECUTABLE_VERSION)
    if (${EXECUTABLE_FOUND})
        set(${EXECUTABLE} ${EXECUTABLE_PATH} PARENT_SCOPE)
        return()
    endif()

    foreach (CODECHECKER_EXECUTABLE_NAME ${ARGS_NAMES})
         cmt_find_tool_executable (${CODECHECKER_EXECUTABLE_NAME}
                                  CODECHECKER_EXECUTABLE
                                  PATHS ${CODECHECKER_SEARCH_PATHS}
                                  PATH_SUFFIXES "${ARGS_BIN_SUBDIR}")
        if (CODECHECKER_EXECUTABLE)
            break()
        endif()
    endforeach()

    cmt_report_not_found_if_not_quiet (codechecker CODECHECKER_EXECUTABLE
        "The 'codechecker' executable was not found in any search or system paths.\n"
        "Please adjust CODECHECKER_SEARCH_PATHS to the installation prefix of the 'codechecker' executable or install codechecker")

    if (CODECHECKER_EXECUTABLE)
        set (CODECHECKER_VERSION_HEADER "Base package version | ")
        cmt_find_tool_extract_version("${CODECHECKER_EXECUTABLE}"
                                      CODECHECKER_VERSION
                                      VERSION_ARG version
                                      VERSION_HEADER
                                      "${CODECHECKER_VERSION_HEADER}"
                                      VERSION_END_TOKEN "                                  \n")
    endif()

    cmt_check_and_report_tool_version(codechecker
                                      "${CODECHECKER_VERSION}"
                                      REQUIRED_VARS
                                      CODECHECKER_EXECUTABLE
                                      CODECHECKER_VERSION)
    cmt_cache_set_tool(CODECHECKER ${CODECHECKER_EXECUTABLE} ${CODECHECKER_VERSION})
    set (${EXECUTABLE} ${CODECHECKER_EXECUTABLE} PARENT_SCOPE)
endfunction()

# Functions summary:
# - cmt_target_generate_codechecker

# ! cmt_target_generate_codechecker
# Generate a codechecker target for the target.
# The generated target lanch codechecker on all the target sources in the specified working directory.
#
# cmt_target_generate_codechecker(
#   TARGET
#   [GLOBAL target]
#   <CTU>
#   [ADDITIONAL_OPTIONAL_REPORTS dir1 [dir2] ...]
#   [SKIP arg1 [arg2] ...]
#   [ARGS arg1 [arg2] ...]
# )
#
# \input TARGET Target to analyse. Will set codechecker target name in consequences.
# \param GLOBAL  Create a global codechecker target instead of a per-target one, should
#       be prefered to cover a whole project.
# \option CTU Disable cross translation unit analysis.
# \groupADDITIONAL_OPTIONAL_REPORTS]
#       Specify other analysis reports, generated by tools supported by the
#       report-converter program. Enable report export from those tools with
#       the CODECHECKER_REPORT option.
# \groupSKIP Specify files to analyse regarding the codechecker skipfile syntax.
# \group ARGS Specify 'codechecker analyze' command line arguments.
#
function(cmt_target_generate_codechecker TARGET)
	cmt_parse_arguments(ARGS "CTU;ALL;DEFAULT" "GLOBAL;SUFFIX" "SKIP;ARGS;ADDITIONAL_OPTIONAL_REPORTS" ${ARGN})
    cmt_default_argument(ARGS SUFFIX "codechecker")
    cmt_default_argument(ARGS GLOBAL "codechecker")
    cmt_ensure_target(${TARGET})

	if (NOT CMT_ENABLE_STATIC_ANALYSIS )
		return()
	endif()

    if (NOT CMT_ENABLE_CODECHECKER)
        return()
    endif()

    cmt_find_codechecker(EXECUTABLE)
	cmt_fatal("Not implemented")
endfunction()
