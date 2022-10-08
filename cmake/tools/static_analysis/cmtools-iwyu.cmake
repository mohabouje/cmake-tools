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
# - cmt_target_generate_iwyu
# - cmt_target_enable_iwyu

# ! cmt_find_iwyu
# Try to find the include-what-you-use executable.
# If the executable is not found, the function will throw an error.
#
# cmt_find_iwyu(
#   EXECUTABLE
# )
#
# \output EXECUTABLE The path to the include-what-you-use executable.
# \param BIN_SUBDIR - The subdirectory where the executable is located.
# \group NAMES - The name of the executable.
#
function (cmt_find_iwyu EXECUTABLE)
    cmt_parse_arguments(ARGS "" "BIN_SUBDIR" "NAMES" ${ARGN})
    cmt_default_argument(ARGS NAMES "include-what-you-use;iwyu")
    cmt_default_argument(ARGS BIN_SUBDIR bin)

    cmt_cache_get_tool(IWYU EXECUTABLE_FOUND EXECUTABLE_PATH EXECUTABLE_VERSION)
    if (${EXECUTABLE_FOUND})
        set(${EXECUTABLE} ${EXECUTABLE_PATH} PARENT_SCOPE)
        return()
    endif()

    foreach (IWYU_EXECUTABLE_NAME ${ARGS_NAMES})
         cmt_find_tool_executable (${IWYU_EXECUTABLE_NAME}
                                  IWYU_EXECUTABLE
                                  PATHS ${IWYU_SEARCH_PATHS}
                                  PATH_SUFFIXES "${ARGS_BIN_SUBDIR}")
        if (IWYU_EXECUTABLE)
            break()
        endif()
    endforeach()

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
    cmt_cache_set_tool(IWYU ${IWYU_EXECUTABLE} ${IWYU_VERSION})
    set (${EXECUTABLE} ${IWYU_EXECUTABLE} PARENT_SCOPE)
endfunction()

# ! cmt_target_generate_iwyu\
# Enable include-what-you-use in all targets.
#
# cmt_enable_iwyu()
#
function(cmt_enable_iwyu)

    if (NOT CMT_ENABLE_STATIC_ANALYSIS )
        return()
    endif()

    if (NOT CMT_ENABLE_IWYU)
        return()
    endif()

    cmt_find_iwyu(EXECUTABLE)
    set(CMAKE_CXX_INCLUDE_WHAT_YOU_USE ${EXECUTABLE} PARENT_SCOPE)
    set(CMAKE_C_INCLUDE_WHAT_YOU_USE ${EXECUTABLE} PARENT_SCOPE)

endfunction()


# ! cmt_target_enable_iwyu
# Enable include-what-you-use checks on the given target
#
# cmt_target_use_iwyu(
#   TARGET
# )
#
# \input TARGET The target to configure
#
function(cmt_target_enable_iwyu TARGET)
    cmt_ensure_target(${TARGET})

    if (NOT CMT_ENABLE_STATIC_ANALYSIS )
        return()
    endif()

    if (NOT CMT_ENABLE_IWYU)
        return()
    endif()

    cmt_find_iwyu(EXECUTABLE)
    cmt_target_set_property(${TARGET} CXX_INCLUDE_WHAT_YOU_USE ${EXECUTABLE})
    cmt_target_set_property(${TARGET} C_INCLUDE_WHAT_YOU_USE ${EXECUTABLE})
    cmt_log("Enable include-what-you-use checks on target ${TARGET}")
endfunction()

# ! cmt_target_generate_iwyu
# Generates a new target that compiles with iwyu
#
# cmt_target_generate_iwyu(
#   TARGET
# )
#
# \input TARGET The target to configure
#
function(cmt_target_generate_iwyu TARGET)
    cmt_parse_arguments(ARGS "ALL;DEFAULT;" "SUFFIX;GLOBAL" "" ${ARGN})
    cmt_default_argument(ARGS SUFFIX "iwyu")
    cmt_default_argument(ARGS GLOBAL "iwyu")
    cmt_ensure_target(${TARGET})

    if (NOT CMT_ENABLE_STATIC_ANALYSIS )
        return()
    endif()

    if (NOT CMT_ENABLE_IWYU)
        return()
    endif()

    cmt_find_iwyu(EXECUTABLE)

    set(TARGET_NAME ${TARGET}_${ARGS_SUFFIX})
    cmt_target_create_mirror(${TARGET} ${ARGS_SUFFIX})
    cmt_target_enable_iwyu(${TARGET_NAME})
    cmt_forward_arguments(ARGS "ALL;DEFAULT" "" "" REGISTER_ARGS)
    cmt_target_register_in_group(${TARGET_NAME} ${ARGS_GLOBAL} ${REGISTER_ARGS})
endfunction()
