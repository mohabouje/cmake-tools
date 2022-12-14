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
    cmt_parse_arguments(ARGS "" "BIN_SUBDIR" "NAMES" ${ARGN})
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

     if (LIZARD_EXECUTABLE)
         cmt_find_tool_extract_version("${LIZARD_EXECUTABLE}"
                                       LIZARD_VERSION
                                       VERSION_ARG --version)
     endif()

    cmt_check_and_report_tool_version(lizard
                                      "${LIZARD_VERSION}"
                                      REQUIRED_VARS
                                      LIZARD_EXECUTABLE
                                      LIZARD_VERSION)
    cmt_cache_set_tool(LIZARD ${LIZARD_EXECUTABLE} ${LIZARD_VERSION})
    set (${EXECUTABLE} ${LIZARD_EXECUTABLE} PARENT_SCOPE)
endfunction()

# ! cmt_target_enable_lizard
# Add a PRE_BUILD step to run lizard on the target.
#
# cmt_target_enable_lizard(
#   TARGET
#   <WARNING>
#   [ADDITIONAL_FILES <file> ...]
#   [ADDITIONAL_ARGS <arg> ...]
# )
#
# \input TARGET The target to add the PRE_BUILD step.
# \option WARNING If set the results from lizard will be treated as warnings.
# \group ADDITIONAL_FILES Additional files to be added to the lizard target.
# \group ADDITIONAL_ARGS Additional arguments to be passed to the lizard target.
#
function(cmt_target_enable_lizard TARGET)
    cmt_parse_arguments(ARGS "WARNING" "WORKING_DIRECTORY" "ADDITIONAL_ARGS;ADDITIONAL_FILES;DEPENDENCIES" ${ARGN})
    cmt_default_argument(ARGS SUFFIX "lizard")
    cmt_default_argument(ARGS GLOBAL "lizard")
    cmt_default_argument(ARGS WORKING_DIRECTORY "${CMAKE_PROJECT_SOURCE_DIR}")
    cmt_ensure_target(${TARGET})

    if (NOT CMT_ENABLE_STATIC_ANALYSIS )
        return()
    endif()

    if (NOT CMT_ENABLE_LIZARD)
        return()
    endif()

    cmt_find_lizard(LIZARD_EXECUTABLE)
    cmt_target_sources(${TARGET} SOURCES)

    set(ALL_ARGS)
    foreach(ARG ${ARGS_ADDITIONAL_ARGS})
        list(APPEND ALL_ARGS ${ARG} )
    endforeach()

    if (${WARNING})
        set( LIZARD_ERROR 0 )
    else()
        set( LIZARD_ERROR 1 )
    endif()

    set(LIZARD_COMMAND ${LIZARD_EXECUTABLE} ${ALL_ARGS} --languages cpp --sort cyclomatic_complexity --warnings_only ${ARGS_ADDITIONAL_FILES} @SOURCES@ || exit ${LIZARD_ERROR})
    cmt_forward_arguments(ARGS "" "WORKING_DIRECTORY" "DEPENDENCIES" FORWARD_ARGS)
    cmt_target_custom_command_for_tool(${TARGET} "lizard" PRE_BUILD COMMAND ${LIZARD_COMMAND} ${FORWARD_ARGS})
    cmt_debug("Enable lizard checks for target ${TARGET}")
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
# \option WARNING If set the results from lizard will be treated as warnings.
# \param SUFFIX The suffix of the target. Default: lizard
# \param GLOBAL The global target to which the target will be added. Default: lizard
# \group ADDITIONAL_FILES Additional files to be added to the lizard target.
# \group ADDITIONAL_ARGS Additional arguments to be passed to the lizard target.
#
function(cmt_target_generate_lizard TARGET)
	cmt_parse_arguments(ARGS "WARNING;ALL;DEFAULT" "SUFFIX;GLOBAL;WORKING_DIRECTORY" "ADDITIONAL_ARGS;DEPENDENCIES" ${ARGN})
    cmt_default_argument(ARGS SUFFIX "lizard")
    cmt_default_argument(ARGS GLOBAL "lizard")
    cmt_default_argument(ARGS WORKING_DIRECTORY "${CMAKE_PROJECT_SOURCE_DIR}")
    cmt_ensure_target(${TARGET})

    if (NOT CMT_ENABLE_STATIC_ANALYSIS )
        return()
    endif()

    if (NOT CMT_ENABLE_LIZARD)
        return()
    endif()

    cmt_find_lizard(LIZARD_EXECUTABLE)
    cmt_target_sources(${TARGET} SOURCES)

    set(ALL_ARGS)
	foreach(ARG ${ARGS_ADDITIONAL_ARGS})
		list(APPEND ALL_ARGS ${ARG} )
	endforeach()

	if (${ARGS_WARNING})
		set( LIZARD_ERROR 0 )
	else()
		set( LIZARD_ERROR 1 )
	endif()

    set(LIZARD_COMMAND ${LIZARD_EXECUTABLE} ${ALL_ARGS} --languages cpp --sort cyclomatic_complexity --warnings_only ${ARGS_ADDITIONAL_FILES} @SOURCES@ || exit ${LIZARD_ERROR})
    cmt_forward_arguments(ARGS "WARNING;ALL;DEFAULT" "SUFFIX;GLOBAL;WORKING_DIRECTORY" "ADDITIONAL_ARGS;DEPENDENCIES" FORWARDED_ARGS)
    cmt_target_custom_target_for_tool(${TARGET} "lizard" COMMAND ${LIZARD_COMMAND} ${FORWARDED_ARGS})
endfunction()

