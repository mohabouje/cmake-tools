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

# Functions summary:
# - cmt_target_generate_lizard
# - cmt_find_lizard

# ! cmt_find_lizard
# Try to find the lizard executable.
# If the executable is not found, the function will throw an error.
#
# cmt_find_lizard(
#   EXECUTABLE
# )
#
# \output EXECUTABLE The path to the lizard executable.
# \param BIN_SUBDIR - The subdirectory where the executable is located.
# \group NAMES - The name of the executable.
#
function (cmt_find_lizard EXECUTABLE)
    cmake_parse_arguments(ARGS "" "BIN_SUBDIR" "NAMES" ${ARGN})
    cmt_default_argument(ARGS NAMES "lizard")
    cmt_default_argument(ARGS BIN_SUBDIR bin)

    cmt_cache_get_tool(LIZARD EXECUTABLE_FOUND EXECUTABLE_PATH EXECUTABLE_VERSION)
    if (${EXECUTABLE_FOUND})
        set(${EXECUTABLE} ${EXECUTABLE_PATH} PARENT_SCOPE)
        return()
    endif()

    foreach (LIZARD_EXECUTABLE_NAME ${ARGS_NAMES})
         cmt_find_tool_executable (${LIZARD_EXECUTABLE_NAME}
                                  LIZARD_EXECUTABLE
                                  PATHS ${LIZARD_SEARCH_PATHS}
                                  PATH_SUFFIXES "${ARGS_BIN_SUBDIR}")
        if (LIZARD_EXECUTABLE)
            break()
        endif()
    endforeach()

    cmt_report_not_found_if_not_quiet (lizard LIZARD_EXECUTABLE
        "The 'lizard' executable was not found in any search or system paths.\n"
        "Please adjust LIZARD_SEARCH_PATHS to the installation prefix of the 'lizard' executable or install lizard")

    # if (LIZARD_EXECUTABLE)
    #     set (LIZARD_VERSION_HEADER "")
    #     cmt_find_tool_extract_version("${LIZARD_EXECUTABLE}"
    #                                   LIZARD_VERSION
    #                                   VERSION_ARG -V
    #                                   VERSION_HEADER
    #                                   "${LIZARD_VERSION_HEADER}"
    #                                   VERSION_END_TOKEN "\n")
    # endif()

    set(LIZARD_VERSION "Unknown")
    cmt_check_and_report_tool_version(lizard
                                      "${LIZARD_VERSION}"
                                      REQUIRED_VARS
                                      LIZARD_EXECUTABLE
                                      LIZARD_VERSION)
    cmt_cache_set_tool(LIZARD TRUE ${LIZARD_EXECUTABLE} ${LIZARD_VERSION})
    set (EXECUTABLE ${LIZARD_EXECUTABLE} PARENT_SCOPE)
endfunction()

# ! cmt_target_generate_lizard
# Generate a lizard target for the target.
# The generated target lanch lizard on all the target sources in the specified working directory.
#
# cmt_target_generate_lizard(
#   TARGET
#   <STATIC_ERROR>
#   [SUFFIX <SUFFIX>] # The suffix of the target. Default: lizard
#   [GLOBAL <GLOBAL>] # The global target to which the target will be added. Default: lizard
#   [ADDITIONAL_FILES <file> ...]
#   [ADDITIONAL_ARGS <arg> ...]
# )
#
# \input TARGET The target to generate the lizard target for.
# \option STATIC_ERROR The error to be thrown if the target is not found.
# \param SUFFIX The suffix of the target. Default: lizard
# \param GLOBAL The global target to which the target will be added. Default: lizard
# \group ADDITIONAL_FILES Additional files to be added to the lizard target.
# \group ADDITIONAL_ARGS Additional arguments to be passed to the lizard target.
#
function(cmt_target_generate_lizard TARGET)
	cmake_parse_arguments(ARGS "STATIC_ERROR" "SUFFIX;GLOBAL" "ADITIONAL_FILES;ADDITIONAL_ARGS" ${ARGN})
    cmt_default_argument(ARGS SUFFIX "lizard")
    cmt_default_argument(ARGS GLOBAL "lizard")
    cmt_ensure_target(${TARGET})
    
    if (NOT CMT_ENABLE_LIZARD)
        return()
    endif()

    cmt_find_lizard(LIZARD_EXECUTABLE)
    cmt_strip_extraneous_sources(${TARGET} SOURCES)

    set(ALL_ARGS)
	foreach(ARG ${ARGS_ADDITIONAL_ARGS})
		list(APPEND ALL_ARGS ${ARG} )
	endforeach()

	if (DEFINED ARGS_STATIC_ERROR )
		set( LIZARD_ERROR 1 )
	else()
		set( LIZARD_ERROR 0 )
	endif()

    set(TARGET_NAME "${TARGET}-${ARGS_SUFFIX}")
	if (TARGET ${TARGET_NAME})
		cmt_fatal("${TARGET_NAME} already exists")
	endif()

    add_custom_target(
        ${TARGET_NAME}
        SOURCES ${SOURCES} ${ARGS_ADDITIONAL_FILES}
        COMMENT "Running lizard on ${TARGET}"
        COMMAND ${LIZARD_EXECUTABLE} ${ALL_ARGS} ${SOURCES} ${ARGS_ADDITIONAL_FILES} || exit ${LIZARD_ERROR}
    )

    add_dependencies( ${TARGET_NAME} ${TARGET})
    add_custom_command( TARGET ${TARGET_NAME} POST_BUILD
      COMMAND ;
      COMMENT "Lizard checks for target ${TARGET} completed."
    )
    cmt_wire_mirrored_build_target_dependencies(${TARGET} ${ARGS_SUFFIX})
    cmt_target_register(${TARGET_NAME} ${ARGS_GLOBAL})

endfunction()

