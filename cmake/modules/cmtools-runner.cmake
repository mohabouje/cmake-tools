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
# - cmt_run_tool_on_source
# - cmt_run_tool_on_target

# ! cmt_run_tool_on_target
#
# Run an external tool on each source file for TARGET. 
# All of the target's C and C++ sources are extracted from its definition and the
# specified COMMAND is run on each of them. 
#
# cmt_run_tool_on_target(
#   TARGET
#   TOOL_NAME
#   <SKIP_GENERATED>
#   <SKIP_HEADERS>
#   [WORKING_DIRECTORY <working_directory>]
#   [DEPENDENCIES <dependencies>...] 
#   [COMMAND <command>...]
# )
#
# \input    TARGET The target to run the tool for.
# \input    TOOL_NAME The name of the tool. 
# \param    WORKING_DIRECTORY The working directory for the tool.
# \option   SKIP_GENERATED Skip generated sources.
# \groups   DEPENDENCIES Targets and sources running this tool DEPENDENCIES on.
# \groups   COMMAND The command to run to invoke this tool. @SOURCE@ is replaced with the source file path.
#
function (cmt_target_custom_command_for_tool TARGET TOOL_NAME)
    cmt_parse_arguments(ARGS "SKIP_GENERATED;SKIP_HEADERS;SINGLE_FILE;PRE_BUILD;PRED_LINK;POST_BUILD" "WORKING_DIRECTORY" "DEPENDENCIES;COMMAND" ${ARGN})
	cmt_required_arguments(ARGS "" "" "COMMAND")
    cmt_default_argument(ARGS WORKING_DIRECTORY "${CMAKE_PROJECT_SOURCE_DIR}")
    cmt_ensure_target(${TARGET})

    cmt_forward_arguments(ARGS "SKIP_GENERATED;SKIP_HEADERS" "" "" TARGET_SOURCES_ARGS)
    cmt_target_sources(${TARGET} FILTERED_SOURCES ${TARGET_SOURCE_ARGS})

    cmt_forward_arguments(ARGS "PRE_BUILD;PRED_LINK;POST_BUILD" "" "" ADD_CUSTOM_COMMAND_ARGS)
    if (${ARGS_SINGLE_FILE})
        foreach (SOURCE ${FILTERED_SOURCES})
            string (CONFIGURE "${ARGS_COMMAND}" CONFIGURED_COMMAND @ONLY)
            add_custom_command (TARGET ${TARGET}
                                ${ADD_CUSTOM_COMMAND_ARGS}
                                COMMAND ${CONFIGURED_COMMAND}
                                COMMENT "Running ${TOOL_NAME} on source file ${SOURCE} from target ${TARGET}"
                                WORKING_DIRECTORY "${ARGS_WORKING_DIRECTORY}"
                                VERBATIM)
        endforeach()
    else()
        set(SOURCES ${FILTERED_SOURCES})
        string (CONFIGURE "${ARGS_COMMAND}" CONFIGURED_COMMAND @ONLY)
        add_custom_command (TARGET ${TARGET}
                            ${ADD_CUSTOM_COMMAND_ARGS}
                            COMMAND ${CONFIGURED_COMMAND}
                            COMMENT "Running ${TOOL_NAME} on target ${TARGET}"
                            WORKING_DIRECTORY "${ARGS_WORKING_DIRECTORY}"
                            VERBATIM)
    endif()
endfunction()


function(cmt_target_custom_target_for_tool TARGET TOOL_NAME)
    cmt_parse_arguments(ARGS "SKIP_GENERATED;SKIP_HEADERS;ALL;DEFAULT" "SUFFIX;GLOBAL;WORKING_DIRECTORY" "DEPENDENCIES;COMMAND;ADDITIONAL_FILES" ${ARGN})
    cmt_required_arguments(ARGS "" "" "COMMAND")
    cmt_default_argument(ARGS WORKING_DIRECTORY "${CMAKE_PROJECT_SOURCE_DIR}")
    cmt_default_argument(ARGS SUFFIX ${TOOL_NAME})
    cmt_default_argument(ARGS GLOBAL ${TOOL_NAME})
    cmt_ensure_target(${TARGET})

    cmt_forward_arguments(ARGS "SKIP_GENERATED;SKIP_HEADERS" "" "" TARGET_SOURCES_ARGS)
    cmt_target_sources(${TARGET} FILTERED_SOURCES ${TARGET_SOURCE_ARGS})

    set(TARGET_NAME "${TARGET}_${ARGS_SUFFIX}")
    if (TARGET ${TARGET_NAME})
        cmt_fatal("${TARGET_NAME} already exists")
    endif()

    set(SOURCES ${FILTERED_SOURCES})
    string (CONFIGURE "${ARGS_COMMAND}" CONFIGURED_COMMAND @ONLY)
    add_custom_target (${TARGET_NAME}
            SOURCES ${SOURCES} ${ARGS_ADDITIONAL_FILES}
            COMMAND ${CONFIGURED_COMMAND}
            COMMENT "Running ${TOOL_NAME} in all files of target ${TARGET}"
            WORKING_DIRECTORY "${ARGS_WORKING_DIRECTORY}"
            DEPENDS ${ARGS_DEPENDENCIES}
            VERBATIM)
    add_dependencies( ${TARGET_NAME} ${TARGET})
    add_custom_command(TARGET ${TARGET_NAME} POST_BUILD
            COMMAND ;
            COMMENT "Execution of ${TOOL_NAME} for target ${TARGET} completed.")

    cmt_forward_arguments(ARGS "ALL;DEFAULT" "" "" REGISTER_ARGS)
    cmt_target_register_in_group(${TARGET_NAME} ${ARGS_GLOBAL} ${REGISTER_ARGS})
endfunction()