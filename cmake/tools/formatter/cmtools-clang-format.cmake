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
# - cmt_target_generate_clang_format(target [STYLE style] [WORKING_DIRECTORY work_dir])

# ! cmt_find_clang_format
# Try to find the clang_format executable.
# If the executable is not found, the function will throw an error.
#
# cmt_find_clang_format(
#   EXECUTABLE
# )
#
# \output EXECUTABLE The path to the clang-format executable.
# \param BIN_SUBDIR - The subdirectory where the executable is located.
# \group NAMES - The name of the executable.
#
function (cmt_find_clang_format EXECUTABLE)
    cmt_parse_arguments(ARGS "" "BIN_SUBDIR" "NAMES" ${ARGN})
    cmt_default_argument(ARGS NAMES "clang-format;")
    cmt_default_argument(ARGS BIN_SUBDIR bin)

    cmt_cache_get_tool(CLANG_FORMAT EXECUTABLE_FOUND EXECUTABLE_PATH EXECUTABLE_VERSION)
    if (${EXECUTABLE_FOUND})
        set(${EXECUTABLE} ${EXECUTABLE_PATH} PARENT_SCOPE)
        return()
    endif()

    foreach (CLANG_FORMAT_EXECUTABLE_NAME ${ARGS_NAMES})
         cmt_find_tool_executable (${CLANG_FORMAT_EXECUTABLE_NAME}
                                  CLANG_FORMAT_EXECUTABLE
                                  PATHS ${CLANG_FORMAT_SEARCH_PATHS}
                                  PATH_SUFFIXES "${ARGS_BIN_SUBDIR}")
        if (CLANG_FORMAT_EXECUTABLE)
            break()
        endif()
    endforeach()

    cmt_report_not_found_if_not_quiet (clang-format CLANG_FORMAT_EXECUTABLE
        "The 'clang-format' executable was not found in any search or system paths.\n"
        "Please adjust CLANG_FORMAT_SEARCH_PATHS to the installation prefix of the 'clang-format' executable or install clang-format")

    if (CLANG_FORMAT_EXECUTABLE)
        set (CLANG_FORMAT_VERSION_HEADER "clang-format version ")
        cmt_find_tool_extract_version("${CLANG_FORMAT_EXECUTABLE}"
                                      CLANG_FORMAT_VERSION
                                      VERSION_ARG --version
                                      VERSION_HEADER
                                      "${CLANG_FORMAT_VERSION_HEADER}"
                                      VERSION_END_TOKEN "\n")
    endif()
	cmt_check_and_report_tool_version(clang-format
									  "${CLANG_FORMAT_VERSION}"
								      REQUIRED_VARS
									  CLANG_FORMAT_EXECUTABLE
								      CLANG_FORMAT_VERSION)

    cmt_cache_set_tool(CLANG_FORMAT ${CLANG_FORMAT_EXECUTABLE} ${CLANG_FORMAT_VERSION})
    set (${EXECUTABLE} ${CLANG_FORMAT_EXECUTABLE} PARENT_SCOPE)
endfunction()

# ! cmt_target_enable_clang_format
# Enables a PRE_BUILD step to format the source code of the target using clang-format.
# The generated target lunch clang-format on all the target sources with the specified style
# in the specified working directory (${CMAKE_CURRENT_SOURCE_DIR} by default}).
#
# cmt_target_generate_clang_format(
#   TARGET
#   [STYLE <style>] ('file' style by default)
#   [WORKING_DIRECTORY <work_dir>] (${PROJECT_SOURCE_DIR} by default}).
# )
#
# \param:TARGET TARGET The target to configure
# \param:STYLE STYLE The clang-format style (file, LLVM, Google, Chromium, Mozilla, WebKit)
# \param:WORKING_DIRECTORY WORKING_DIRECTORY The clang-format working directory
#
function(cmt_target_enable_clang_format TARGET)
    cmt_parse_arguments(ARGS "" "STYLE;WORKING_DIRECTORY" "" ${ARGN})
    cmt_default_argument(ARGS STYLE "file")
    cmt_default_argument(ARGS WORKING_DIRECTORY ${PROJECT_SOURCE_DIR})
    cmt_ensure_target(${TARGET})

    if (NOT CMT_ENABLE_CLANG_FORMAT)
        return()
    endif()

    cmt_find_clang_format(CLANG_FORMAT_EXECUTABLE)

    set(TARGET_NAME "${TARGET}_${ARGS_SUFFIX}")
    if (TARGET ${TARGET_NAME})
        cmt_fatal("${TARGET_NAME} already exists")
    endif()

    set(CLANG_FORMAT_COMMAND ${CLANG_FORMAT_EXECUTABLE} -style=${ARGS_STYLE} -i @SOURCES@)
    cmt_forward_arguments(ARGS "" "WORKING_DIRECTORY" "DEPENDENCIES" FORWARD_ARGS)
    cmt_target_custom_command_for_tool(${TARGET} "clang-format" PRE_BUILD COMMAND ${CLANG_FORMAT_COMMAND} ${FORWARD_ARGS})
endfunction()


# ! cmt_target_generate_clang_format
# Generate a format target for the target (clang-format-${TARGET}).
# The generated target lunch clang-format on all the target sources with the specified style
# in the specified working directory (${CMAKE_CURRENT_SOURCE_DIR} by default}).
#
# cmt_target_generate_clang_format(
#   TARGET
#   [STYLE <style>] ('file' style by default)
#   [WORKING_DIRECTORY <work_dir>] (${PROJECT_SOURCE_DIR} by default}).
# )
#
# \param:TARGET TARGET The target to configure
# \param:STYLE STYLE The clang-format style (file, LLVM, Google, Chromium, Mozilla, WebKit)
# \param:WORKING_DIRECTORY WORKING_DIRECTORY The clang-format working directory
#
function(cmt_target_generate_clang_format TARGET)
    cmt_parse_arguments(ARGS "ALL;DEFAULT;" "STYLE;WORKING_DIRECTORY;GLOBAL;SUFFIX" "ADDITIONAL_FILES;DEPENDENCIES" ${ARGN})
    cmt_default_argument(ARGS STYLE "file")
    cmt_default_argument(ARGS WORKING_DIRECTORY ${PROJECT_SOURCE_DIR})
    cmt_default_argument(ARGS SUFFIX "clang-format")
    cmt_default_argument(ARGS GLOBAL "clang-format")
    cmt_ensure_target(${TARGET}) 

    if (NOT CMT_ENABLE_CODE_FORMATTING)
        return()
    endif()

	if (NOT CMT_ENABLE_CLANG_FORMAT)
    	return()
	endif()

	cmt_find_clang_format(CLANG_FORMAT_EXECUTABLE)

	set(TARGET_NAME "${TARGET}_${ARGS_SUFFIX}")
	if (TARGET ${TARGET_NAME})
		cmt_fatal("${TARGET_NAME} already exists")
	endif()

    set(CLANG_FORMAT_COMMAND ${CLANG_FORMAT_EXECUTABLE} -style=${ARGS_STYLE} -i @SOURCES@ ${ARGS_ADDITIONAL_FILES})
    cmt_forward_arguments(ARGS "ALL;DEFAULT" "SUFFIX;GLOBAL;WORKING_DIRECTORY" "ADDITIONAL_FILES;DEPENDENCIES" FORWARDED_ARGS)
    cmt_target_custom_target_for_tool(${TARGET} "clang-format" COMMAND ${CLANG_FORMAT_COMMAND} ${FORWARDED_ARGS})
endfunction()