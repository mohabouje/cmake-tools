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
# - cmt_target_generate_clang_build_analyzer
#

# ! cmt_find_clang_build_analyzer
# Try to find the clang-build-analyzer executable.
# If the executable is not found, the function will throw an error.
#
# cmt_find_clang_build_analyzer(
#   EXECUTABLE
# )
#
# \output EXECUTABLE The path to the clang-build-analyzer executable.
# \param BIN_SUBDIR - The subdirectory where the executable is located.
# \group NAMES - The name of the executable.
#
function (cmt_find_clang_build_analyzer EXECUTABLE)
    cmt_parse_arguments(ARGS "" "BIN_SUBDIR" "NAMES" ${ARGN})
    cmt_default_argument(ARGS NAMES "clang-build-analyzer;")
    cmt_default_argument(ARGS BIN_SUBDIR bin)

    cmt_cache_get_tool(CLANG_BUILD_ANALYZER EXECUTABLE_FOUND EXECUTABLE_PATH EXECUTABLE_VERSION)
    if (${EXECUTABLE_FOUND})
        set(${EXECUTABLE} ${EXECUTABLE_PATH} PARENT_SCOPE)
        return()
    endif()

    foreach (CLANG_BUILD_ANALYZER_EXECUTABLE_NAME ${ARGS_NAMES})
         cmt_find_tool_executable (${CLANG_BUILD_ANALYZER_EXECUTABLE_NAME}
                                  CLANG_BUILD_ANALYZER_EXECUTABLE
                                  PATHS ${CLANG_BUILD_ANALYZER_SEARCH_PATHS}
                                  PATH_SUFFIXES "${ARGS_BIN_SUBDIR}")
        if (CLANG_BUILD_ANALYZER_EXECUTABLE)
            break()
        endif()
    endforeach()

    cmt_report_not_found_if_not_quiet (clang-build-analyzer CLANG_BUILD_ANALYZER_EXECUTABLE
        "The 'clang-build-analyzer' executable was not found in any search or system paths.\n"
        "Please adjust CLANG_BUILD_ANALYZER_SEARCH_PATHS to the installation prefix of the 'clang-build-analyzer' executable or install clang-build-analyzer")

    if (CLANG_BUILD_ANALYZER_EXECUTABLE)
        set (CLANG_BUILD_ANALYZER_VERSION_HEADER "LLVM version ")
        cmt_find_tool_extract_version("${CLANG_BUILD_ANALYZER_EXECUTABLE}"
                                      CLANG_BUILD_ANALYZER_VERSION
                                      VERSION_ARG --version
                                      VERSION_HEADER
                                      "${CLANG_BUILD_ANALYZER_VERSION_HEADER}"
                                      VERSION_END_TOKEN "\n")
    endif()

    cmt_check_and_report_tool_version(clang-build-analyzer
                                      "${CLANG_BUILD_ANALYZER_VERSION}"
                                      REQUIRED_VARS
                                      CLANG_BUILD_ANALYZER_EXECUTABLE
                                      CLANG_BUILD_ANALYZER_VERSION)

    cmt_cache_set_tool(CLANG_BUILD_ANALYZER ${CLANG_BUILD_ANALYZER_EXECUTABLE} ${CLANG_BUILD_ANALYZER_VERSION})
    set (EXECUTABLE ${CLANG_BUILD_ANALYZER_EXECUTABLE} PARENT_SCOPE)
endfunction()

# ! cmt_target_generate_clang_build_analyzer
# Enable clang-build-analyzer checks on the given target
#
# cmt_target_generate_clang_build_analyzer(
#   TARGET
# )
#
# \input TARGET The target to configure
#
function(cmt_target_generate_clang_build_analyzer TARGET)
    cmt_parse_arguments(ARGS "ALL;DEFAULT" "SUFFIX;GLOBAL;BINARY_DIR" "" ${ARGN})
    cmt_default_argument(ARGS SUFFIX "clang-build-analyzer")
    cmt_default_argument(ARGS GLOBAL "${PROJECT}-clang-build-analyzer")
    cmt_default_argument(ARGS BINARY_DIR "${CMAKE_CURRENT_BINARY_DIR}")
    cmt_ensure_target(${TARGET})

    if (NOT CMT_ENABLE_CLANG_BUILD_ANALYZER)
        return()
    endif()

    cmt_define_compiler()
    if (NOT ${CMT_COMPILER} STREQUAL "CLANG")
        return()
    endif()

    cmt_find_clang_build_analyzer(CLANG_BUILD_ANALYZER_EXECUTABLE)

    set(TARGET_NAME "${TARGET}-${ARGS_SUFFIX}")
    set(TARGET_DIR "${ARGS_BINARY_DIR}/CMakeFiles/${TARGET}_build_analyzer.dir" )

    target_compile_options(${TARGET} PRIVATE -ftime-trace)

    add_custom_target(${TARGET_NAME}
        COMMENT "${TARGET_NAME} Clang build statistics"
        COMMAND ${CLANG_BUILD_ANALYZER_EXECUTABLE} --all
                "${ARGS_BINARY_DIR}/CMakeFiles/${TARGET}.dir"
                "${TARGET_DIR}/build_analysis"
        COMMAND ${CLANG_BUILD_ANALYZER_EXECUTABLE} --analyze
                "${TARGET_DIR}/build_analysis"
        BYPRODUCTS
                "${TARGET_DIR}/build_analysis"
    )
    cmt_target_wire_dependencies(${TARGET} ${ARGS_SUFFIX})
    add_dependencies(${TARGET_NAME} ${TARGET})
    cmt_forward_arguments(ARGS "ALL;DEFAULT" "" "" REGISTER_ARGS)
    cmt_target_register_in_group(${TARGET_NAME} ${ARGS_GLOBAL} ${REGISTER_ARGS})
endfunction()
