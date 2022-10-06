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

# cmt_run_tool_on_source:
#
# Run an external tool on a source file during TARGET. All of the
# target's C and C++ sources are extracted from its definition and the
# specified COMMAND is run on each of them. The string @SOURCE@ is replaced
# with the source file name in the arguments for COMMAND.
#
#
# cmt_run_tool_on_source(
#   TARGET
#   TOOL_NAME
#   [WORKING_DIRECTORY <working_directory>]
#   [DEPENDENCIES <dependencies>...]   
#   [COMMAND <command>...]
# )
#
# \input    TARGET The target to run the tool for.
# \input    TOOL_NAME The name of the tool. 
# \input    SOURCE The source file to check.
# \param    WORKING_DIRECTORY The working directory for the tool.
# \groups   DEPENDENCIES Targets and sources running this tool DEPENDENCIES on.
# \groups   COMMAND The command to run to invoke this tool. @SOURCE@ is replaced with the source file path.
#
function (cmt_run_tool_on_source TARGET SOURCE TOOL_NAME)

    cmt_parse_arguments(ARGS "" "WORKING_DIRECTORY;STAMPFILE_DIRECTORY" "COMMAND;DEPENDENCIES" ${ARGN})
    cmt_default_argument(ARGS WORKING_DIRECTORY "${CMAKE_SOURCE_DIR}")
    cmt_default_argument(ARGS STAMPFILE_DIRECTORY "${CMAKE_CURRENT_BINARY_DIR}/.stampfiles")
	cmt_required_arguments(ARGS ""  "" "COMMAND")

    # Replace @SOURCE@ with SOURCE in ARGS_COMMAND here
    string (CONFIGURE "${ARGS_COMMAND}" COMMAND @ONLY)

    # Get the basename of the file, used for the comment and stamp.
    get_filename_component (SRCNAME "${SOURCE}" NAME)
    set (TOOLING_SIG "stamp")
    set (STAMPFILE_NAME "${SRCNAME}.${TOOL_NAME}.${TOOLING_SIG}")
    set (STAMPFILE_PATH "${STAMPFILE_DIRECTORY}/${STAMPFILE_NAME}")
    set (COMMENT "Running ${TOOL_NAME} in source ${SRCNAME}")


    # Get all the sources on this target and make the new check depend on the
    # generated ones. The reason being that the source that we are checking
    # might include a header file which is also generated and it will need to
    # be generated first. If the source includes that header file
    # that header file doesn't exist, then the build will fail.
    cmt_target_generated_sources(${TARGET} TARGET_GENERATED_SOURCES)
    set (TARGET_SOURCES_TO_GENERATE "${SOURCE}")
    foreach (TARGET_SOURCE ${TARGET_GENERATED_SOURCES})
        string (FIND "${TARGET_SOURCE}" "${TOOLING_SIG}" SIG_IDX REVERSE)
        string (LENGTH "${TARGET_SOURCE}" TARGET_SOURCE_LEN)

        if (NOT SIG_IDX EQUAL -1)
            math (EXPR SIG_SIZE "${TARGET_SOURCE_LEN} - ${SIG_IDX}")
        else()
            set (SIG_SIZE 0)
        endif()

        # Exclude any
        if (SIG_IDX EQUAL -1 OR NOT SIG_SIZE EQUAL 5)
            list (APPEND TARGET_SOURCES_TO_GENERATE "${TARGET_SOURCE}")
        endif()
    endforeach()

    add_custom_command (OUTPUT ${STAMPFILE}
                        COMMAND ${COMMAND}
                        COMMAND "${CMAKE_COMMAND}" -E touch "${STAMPFILE_PATH}"
                        DEPENDS ${TARGET_SOURCES_TO_GENERATE}
                                ${ARGS_DEPENDENCIES}
                        ${ARGS_WORKING_DIRECTORY}
                        COMMENT ${COMMENT}
                        VERBATIM)

    # Add the stampfile both to the SOURCES of TARGET  but also to the OBJECT_DEPENDENCIES of any source files.
    # On older CMake versions editing SOURCES post-facto for a linkable target was a no-op.
    set_property (TARGET ${TARGET}
                  APPEND PROPERTY SOURCES ${STAMPFILE})
    set_property (SOURCE "${SOURCE}"
                  APPEND PROPERTY OBJECT_DEPENDENCIES ${STAMPFILE})

endfunction()


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
function (cmt_run_tool_on_target TARGET TOOL_NAME)
    cmt_parse_arguments(ARGS "SKIP_GENERATED;SKIP_HEADERS" "WORKING_DIRECTORY" "DEPENDENCIES;COMMAND" ${ARGN})
	cmt_required_arguments(ARGS "" "" "COMMAND")
    cmt_ensure_target(${TARGET})

    cmt_forward_arguments(ARGS "SKIP_GENERATED;SKIP_HEADERS" "" "" TARGET_SOURCES_ARGS)
    cmt_target_sources(${TARGET} FILTERED_SOURCES ${TARGET_SOURCE_ARGS})


    cmt_forward_arguments (ARGS "" "WORKING_DIRECTORY" "DEPENDENCIES;COMMAND" RUN_ON_SOURCE_FORWARD)

    # For each source file, add a new custom command which runs our tool and generates a stampfile, 
    # depending on the generation of the source file.
    foreach (SOURCE ${FILTERED_SOURCES})
        cmt_run_tool_on_source (${TARGET} "${SOURCE}" ${TOOL_NAME} ${RUN_ON_SOURCE_FORWARD})
    endforeach()
endfunction()