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

include(${CMAKE_CURRENT_LIST_DIR}/./../modules/cmtools-args.cmake)
include(${CMAKE_CURRENT_LIST_DIR}/./../modules/cmtools-env.cmake)
include(${CMAKE_CURRENT_LIST_DIR}/./../modules/cmtools-finder.cmake)

# Functions summary:
# - cmt_find_clang_tidy
# - cmt_target_generate_clang_tidy
# - cmt_target_enable_clang_tidy

# ! cmt_find_clang_tidy
# Try to find the clang-tidy executable.
# If the executable is not found, the function will throw an error.
#
# cmt_find_clang_tidy(
#   EXECUTABLE
# )
#
# \output EXECUTABLE The path to the clang-tidy executable.
# \output CLANG_TIDY_FOUND - True if the executable is found, false otherwise.
# \param BIN_SUBDIR - The subdirectory where the executable is located.
# \group NAMES - The name of the executable.
#
function (cmt_find_clang_tidy EXECUTABLE)
    cmt_parse_arguments(ARGS "" "BIN_SUBDIR" "NAMES" ${ARGN})
    cmt_default_argument(ARGS NAMES "clang-tidy;")
    cmt_default_argument(ARGS BIN_SUBDIR bin)

    cmt_cache_get_tool(CLANG_TIDY EXECUTABLE_FOUND EXECUTABLE_PATH EXECUTABLE_VERSION)
    if (${EXECUTABLE_FOUND})
        set(${EXECUTABLE} ${EXECUTABLE_PATH} PARENT_SCOPE)
        return()
    endif()

    foreach (CLANG_TIDY_EXECUTABLE_NAME ${ARGS_NAMES})
         cmt_find_tool_executable (${CLANG_TIDY_EXECUTABLE_NAME}
                                  CLANG_TIDY_EXECUTABLE
                                  PATHS ${CLANG_TIDY_SEARCH_PATHS}
                                  PATH_SUFFIXES "${ARGS_BIN_SUBDIR}")
        if (CLANG_TIDY_EXECUTABLE)
            break()
        endif()
    endforeach()

    cmt_report_not_found_if_not_quiet (clang-tidy CLANG_TIDY_EXECUTABLE
        "The 'clang-tidy' executable was not found in any search or system paths.\n"
        "Please adjust CLANG_TIDY_SEARCH_PATHS to the installation prefix of the 'clang-tidy' executable or install clang-tidy")

    if (CLANG_TIDY_EXECUTABLE)
        set (CLANG_TIDY_VERSION_HEADER "LLVM version ")
        cmt_find_tool_extract_version("${CLANG_TIDY_EXECUTABLE}"
                                      CLANG_TIDY_VERSION
                                      VERSION_ARG --version
                                      VERSION_HEADER
                                      "${CLANG_TIDY_VERSION_HEADER}"
                                      VERSION_END_TOKEN "\n")
    endif()

    cmt_check_and_report_tool_version(clang-tidy
                                      "${CLANG_TIDY_VERSION}"
                                      REQUIRED_VARS
                                      CLANG_TIDY_EXECUTABLE
                                      CLANG_TIDY_VERSION)

    cmt_cache_set_tool(CLANG_TIDY TRUE ${CLANG_TIDY_EXECUTABLE} ${CLANG_TIDY_VERSION})
    set (EXECUTABLE ${CLANG_TIDY_EXECUTABLE} PARENT_SCOPE)
endfunction()

# ! cmt_target_generate_clang_tidy
# Enable include-what-you-use in all targets.
#
# cmt_enable_clang_tidy()
#
macro(cmt_enable_clang_tidy)
    cmt_ensure_target(${TARGET})

    if (CMT_ENABLE_IWYU)
        cmt_find_clang_tidy(EXECUTABLE)
        set(CMAKE_CXX_INCLUDE_CLANG_TIDY ${EXECUTABLE})
        set(CMAKE_C_INCLUDE_CLANG_TIDY ${EXECUTABLE})
    endif()

endmacro()


# ! cmt_target_enable_clang_tidy
# Enable clang-tidy checks on the given target
#
# cmt_target_use_clang_tidy(
#   TARGET
# )
#
# \input TARGET The target to enable clang-tidy checks for.
#
function(cmt_target_enable_clang_tidy TARGET)
    cmt_ensure_target(${TARGET})

    if (NOT CMT_ENABLE_CLANG_TIDY)
        return()
    endif()

    cmt_find_clang_tidy(EXECUTABLE)
    set_property(TARGET ${TARGET} PROPERTY CMAKE_CXX_INCLUDE_CLANG_TIDY ${EXECUTABLE})
    set_property(TARGET ${TARGET} PROPERTY CMAKE_C_INCLUDE_CLANG_TIDY ${EXECUTABLE})
endfunction()

# ! cmt_target_generate_clang_tidy
# Generates a new target that compiles with clang_tidy
#
# cmt_target_generate_clang_tidy(
#   TARGET
# )
#
# \input TARGET The target to configure
#
function(cmt_target_generate_clang_tidy TARGET)
    cmt_parse_arguments(ARGS "ALL;DEFAULT" "SUFFIX;GLOBAL" "" ${ARGN})
    cmt_default_argument(ARGS SUFFIX "clang-tidy")
    cmt_default_argument(ARGS GLOBAL "clang-tidy")
    cmt_ensure_target(${TARGET})
    
    if (NOT CMT_ENABLE_CCACHE)
        return()
    endif()

    cmt_find_clang_tidy(EXECUTABLE)

    set(TARGET_NAME ${TARGET}-${ARGS_SUFFIX})
    cmt_target_create_mirror(${TARGET} ${ARGS_SUFFIX})
    cmt_target_enable_clang_tidy(${TARGET_NAME})
    cmt_forward_arguments(ARGS "ALL;DEFAULT" "" "" REGISTER_ARGS)
    cmt_target_register_in_group(${TARGET_NAME} ${ARGS_GLOBAL} ${REGISTER_ARGS})
endfunction()