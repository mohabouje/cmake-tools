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
include(${CMAKE_CURRENT_LIST_DIR}/./../third_party/coverage.cmake)
cmt_enable_logger()

# ! cmt_find_
# Try to find the lcov executable.
# If the executable is not found, the function will throw an error.
#
# cmt_find_lcov(
#   EXECUTABLE
#   EXECUTABLE_FOUND
# )
#
# \output EXECUTABLE The path to the lcov executable.
# \output EXECUTABLE_FOUND - True if the executable is found, false otherwise.
# \param BIN_SUBDIR - The subdirectory where the executable is located.
# \group NAMES - The name of the executable.
#
function (cmt_find_lcov EXECUTABLE EXECUTABLE_FOUND)
    cmake_parse_arguments(ARGS "" "BIN_SUBDIR" "NAMES" ${ARGN})
    cmt_default_argument(ARGS NAMES "lcov")
    cmt_default_argument(ARGS BIN_SUBDIR bin)

    foreach (LCOV_EXECUTABLE_NAME ${ARGS_NAMES})
         cmt_find_tool_executable (${LCOV_EXECUTABLE_NAME}
                                  LCOV_EXECUTABLE
                                  PATHS ${LCOV_SEARCH_PATHS}
                                  PATH_SUFFIXES "${ARGS_BIN_SUBDIR}")
        if (LCOV_EXECUTABLE)
            break ()
        endif ()
    endforeach ()

    cmt_report_not_found_if_not_quiet (lcov LCOV_EXECUTABLE
        "The 'lcov' executable was not found in any search or system paths.\n"
        "Please adjust LCOV_SEARCH_PATHS to the installation prefix of the 'lcov' executable or install lcov")

    if (LCOV_EXECUTABLE)
        set (LCOV_VERSION_HEADER "LLVM version ")
        cmt_find_tool_extract_version("${LCOV_EXECUTABLE}"
                                      LCOV_VERSION
                                      VERSION_ARG --version
                                      VERSION_HEADER
                                      "${LCOV_VERSION_HEADER}"
                                      VERSION_END_TOKEN "\n")
    endif()

    cmt_check_and_report_tool_version(lcov
                                      "${LCOV_VERSION}"
                                      REQUIRED_VARS
                                      LCOV_EXECUTABLE
                                      LCOV_VERSION)
    set (EXECUTABLE ${LCOV_EXECUTABLE} PARENT_SCOPE)
endfunction ()

# ! cmt_find_genhtml
# Try to find the genhtml executable.
# If the executable is not found, the function will throw an error.
#
# cmt_find_genhtml(
#   EXECUTABLE
#   EXECUTABLE_FOUND
# )
#
# \output EXECUTABLE The path to the genhtml executable.
# \output EXECUTABLE_FOUND - True if the executable is found, false otherwise.
# \param BIN_SUBDIR - The subdirectory where the executable is located.
# \group NAMES - The name of the executable.
#
function (cmt_find_genhtml EXECUTABLE EXECUTABLE_FOUND)
    cmake_parse_arguments(ARGS "" "BIN_SUBDIR" "NAMES" ${ARGN})
    cmt_default_argument(ARGS NAMES "genhtml")
    cmt_default_argument(ARGS BIN_SUBDIR bin)

    foreach (GENHTML_EXECUTABLE_NAME ${ARGS_NAMES})
         cmt_find_tool_executable (${GENHTML_EXECUTABLE_NAME}
                                  GENHTML_EXECUTABLE
                                  PATHS ${GENHTML_SEARCH_PATHS}
                                  PATH_SUFFIXES "${ARGS_BIN_SUBDIR}")
        if (GENHTML_EXECUTABLE)
            break ()
        endif ()
    endforeach ()

    cmt_report_not_found_if_not_quiet (genhtml GENHTML_EXECUTABLE
        "The 'genhtml' executable was not found in any search or system paths.\n"
        "Please adjust GENHTML_SEARCH_PATHS to the installation prefix of the 'genhtml' executable or install genhtml")

    if (GENHTML_EXECUTABLE)
        set (GENHTML_VERSION_HEADER "LCOV version ")
        cmt_find_tool_extract_version("${GENHTML_EXECUTABLE}"
                                      GENHTML_VERSION
                                      VERSION_ARG --version
                                      VERSION_HEADER
                                      "${GENHTML_VERSION_HEADER}"
                                      VERSION_END_TOKEN "\n")
    endif()

    cmt_check_and_report_tool_version(genhtml
                                      "${GENHTML_VERSION}"
                                      REQUIRED_VARS
                                      GENHTML_EXECUTABLE
                                      GENHTML_VERSION)
    set (EXECUTABLE ${GENHTML_EXECUTABLE} PARENT_SCOPE)
endfunction ()

# ! cmt_find_llvm_cov
# Try to find the llvm-cov executable.
# If the executable is not found, the function will throw an error.
#
# cmt_find_llvm-cov(
#   EXECUTABLE
#   EXECUTABLE_FOUND
# )
#
# \output EXECUTABLE The path to the llvm-cov executable.
# \output EXECUTABLE_FOUND - True if the executable is found, false otherwise.
# \param BIN_SUBDIR - The subdirectory where the executable is located.
# \group NAMES - The name of the executable.
#
function (cmt_find_llvm_cov EXECUTABLE EXECUTABLE_FOUND)
    cmake_parse_arguments(ARGS "" "BIN_SUBDIR" "NAMES" ${ARGN})
    cmt_default_argument(ARGS NAMES "llvm-cov")
    cmt_default_argument(ARGS BIN_SUBDIR bin)

    foreach (LLVM_COV_EXECUTABLE_NAME ${ARGS_NAMES})
         cmt_find_tool_executable (${LLVM_COV_EXECUTABLE_NAME}
                                  LLVM_COV_EXECUTABLE
                                  PATHS ${LLVM_COV_SEARCH_PATHS}
                                  PATH_SUFFIXES "${ARGS_BIN_SUBDIR}")
        if (LLVM_COV_EXECUTABLE)
            break ()
        endif ()
    endforeach ()

    cmt_report_not_found_if_not_quiet (llvm-cov LLVM_COV_EXECUTABLE
        "The 'llvm-cov' executable was not found in any search or system paths.\n"
        "Please adjust LLVM_COV_SEARCH_PATHS to the installation prefix of the 'llvm-cov' executable or install llvm-cov")

    if (LLVM_COV_EXECUTABLE)
        set (LLVM_COV_VERSION_HEADER "LCOV version")
        cmt_find_tool_extract_version("${LLVM_COV_EXECUTABLE}"
                                      LLVM_COV_VERSION
                                      VERSION_ARG --version
                                      VERSION_HEADER
                                      "${LLVM_COV_VERSION_HEADER}"
                                      VERSION_END_TOKEN "\n")
    endif()

    cmt_check_and_report_tool_version(llvm-cov
                                      "${LLVM_COV_VERSION}"
                                      REQUIRED_VARS
                                      LLVM_COV_EXECUTABLE
                                      LLVM_COV_VERSION)
    set (EXECUTABLE ${LLVM_COV_EXECUTABLE} PARENT_SCOPE)
endfunction ()

# ! cmt_find_llvm_profdata
# Try to find the llvm-profdata executable.
# If the executable is not found, the function will throw an error.
#
# cmt_find_llvm-profdata(
#   EXECUTABLE
#   EXECUTABLE_FOUND
# )
#
# \output EXECUTABLE The path to the llvm-profdata executable.
# \output EXECUTABLE_FOUND - True if the executable is found, false otherwise.
# \param BIN_SUBDIR - The subdirectory where the executable is located.
# \group NAMES - The name of the executable.
#
function (cmt_find_llvm_profdata EXECUTABLE EXECUTABLE_FOUND)
    cmake_parse_arguments(ARGS "" "BIN_SUBDIR" "NAMES" ${ARGN})
    cmt_default_argument(ARGS NAMES "llvm-profdata;")
    cmt_default_argument(ARGS BIN_SUBDIR bin)

    foreach (LLVM_PROFDATA_EXECUTABLE_NAME ${ARGS_NAMES})
         cmt_find_tool_executable (${LLVM_PROFDATA_EXECUTABLE_NAME}
                                  LLVM_PROFDATA_EXECUTABLE
                                  PATHS ${LLVM_PROFDATA_SEARCH_PATHS}
                                  PATH_SUFFIXES "${ARGS_BIN_SUBDIR}")
        if (LLVM_PROFDATA_EXECUTABLE)
            break ()
        endif ()
    endforeach ()

    cmt_report_not_found_if_not_quiet (llvm-profdata LLVM_PROFDATA_EXECUTABLE
        "The 'llvm-profdata' executable was not found in any search or system paths.\n"
        "Please adjust LLVM_PROFDATA_SEARCH_PATHS to the installation prefix of the 'llvm-profdata' executable or install llvm-profdata")

    # if (LLVM_PROFDATA_EXECUTABLE)
    #     set (LLVM_PROFDATA_VERSION_HEADER "LLVM version ")
    #     cmt_find_tool_extract_version("${LLVM_PROFDATA_EXECUTABLE}"
    #                                   LLVM_PROFDATA_VERSION
    #                                   VERSION_ARG --version
    #                                   VERSION_HEADER
    #                                   "${LLVM_PROFDATA_VERSION_HEADER}"
    #                                   VERSION_END_TOKEN "\n")
    # endif()

    cmt_check_and_report_tool_version(llvm-profdata
                                      "${LLVM_PROFDATA_VERSION}"
                                      REQUIRED_VARS
                                      LLVM_PROFDATA_EXECUTABLE
                                      LLVM_PROFDATA_VERSION)
    set (EXECUTABLE ${LLVM_PROFDATA_EXECUTABLE} PARENT_SCOPE)
endfunction ()

# ! cmt_target_generate_coverage
# Generate a code coverage report for the target.
# The generated target lanch lcov on all the target sources in the specified working directory.
#
# cmt_target_generate_coverage(
#   TARGET
#   [DEPENDENCIES dependencies...]
# )
#
# \input TARGET The target to generate the coverage report for.
# \group DEPENDENCIES The dependencies of the target.
#
function(cmt_target_generate_coverage TARGET)
    cmake_parse_arguments(ARGS "" "" "DEPENDENCIES" ${ARGN})

    if (NOT CMT_ENABLE_COVERAGE)
        return()
    endif()

    cmt_find_lcov(_ _)
    cmt_find_genhtml(_ _)
    cmt_find_llvm_cov(_ _)
    cmt_find_llvm_profdata(_ _)

    set(CODE_COVERAGE ON)
    target_code_coverage(${TARGET} OBJECTS ${ARGS_DEPENDENCIES} AUTO ALL)
endfunction()


# ! cmt_project_coverage
# Generate code coverage for all the targets.
#
macro(cmt_project_coverage)
    if (CMT_ENABLE_COVERAGE)

        cmt_find_lcov(_ _)
        cmt_find_genhtml(_ _)
        cmt_find_llvm_cov(_ _)
        cmt_find_llvm_profdata(_ _)

        set(CODE_COVERAGE ON)
        add_code_coverage_all_targets()
    endif()
endmacro()
