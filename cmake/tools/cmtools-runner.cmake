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
include(${CMAKE_CURRENT_LIST_DIR}/./../utility/cmtools-sources.cmake)

# Functions summary:
# - cmt_run_tool_on_source
# - cmt_target_run_tool
# - cmt_target_add_compilation_dbS

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

    cmake_parse_arguments(RUN_TOOL_ON_SOURCE "" "WORKING_DIRECTORY" "COMMAND;DEPENDENCIES" ${ARGN})
	cmt_required_arguments(FUNCTION cmt_run_tool_on_source PREFIX RUN_COMMAND FIELDS COMMAND)

    # Replace @SOURCE@ with SOURCE in RUN_TOOL_ON_SOURCE_COMMAND here
    string (CONFIGURE "${RUN_TOOL_ON_SOURCE_COMMAND}" COMMAND @ONLY)

    # Get the basename of the file, used for the comment and stamp.
    get_filename_component (SRCNAME "${SOURCE}" NAME)
    set (TOOLING_SIG "stamp")
    set (STAMPFILE "${CMAKE_CURRENT_BINARY_DIR}/${SRCNAME}.${TOOL}.${TOOLING_SIG}")
    set (COMMENT "Analyzing ${SRCNAME} with ${TOOL}")

    if (DEFINED RUN_TOOL_ON_SOURCE_WORKING_DIRECTORY)
        set (WORKING_DIRECTORY_OPTION
             WORKING_DIRECTORY "${RUN_TOOL_ON_SOURCE_WORKING_DIRECTORY}")
    endif ()

    # Get all the sources on this target and make the new check depend on the
    # generated ones. The reason being that the source that we are checking
    # might include a header file which is also generated and it will need to
    # be generated first. If the source includes that header file
    # that header file doesn't exist, then the build will fail.
    get_property (ALL_TARGET_SOURCES TARGET "${TARGET}" PROPERTY SOURCES)
    set (TARGET_SOURCES_TO_GENERATE "${SOURCE}")
    foreach (TARGET_SOURCE ${ALL_TARGET_SOURCES})
        get_property (SOURCE_IS_GENERATED
                      SOURCE "${TARGET_SOURCE}"
                      PROPERTY GENERATED)
        if (SOURCE_IS_GENERATED)
            string (FIND "${TARGET_SOURCE}" "${TOOLING_SIG}" SIG_IDX REVERSE)
            string (LENGTH "${TARGET_SOURCE}" TARGET_SOURCE_LEN)

            if (NOT SIG_IDX EQUAL -1)
                math (EXPR SIG_SIZE "${TARGET_SOURCE_LEN} - ${SIG_IDX}")
            else ()
                set (SIG_SIZE 0)
            endif ()

            # Exclude any
            if (SIG_IDX EQUAL -1 OR NOT SIG_SIZE EQUAL 5)
                list (APPEND TARGET_SOURCES_TO_GENERATE "${TARGET_SOURCE}")
            endif ()
        endif ()
    endforeach ()

    add_custom_command (OUTPUT ${STAMPFILE}
                        COMMAND ${COMMAND}
                        COMMAND "${CMAKE_COMMAND}" -E touch "${STAMPFILE}"
                        DEPENDS ${TARGET_SOURCES_TO_GENERATE}
                                ${RUN_TOOL_ON_SOURCE_DEPENDENCIES}
                        ${WORKING_DIRECTORY_OPTION}
                        COMMENT ${COMMENT}
                        VERBATIM)

    # Add the stampfile both to the SOURCES of TARGET  but also to the OBJECT_DEPENDENCIES of any source files.
    # On older CMake versions editing SOURCES post-facto for a linkable target was a no-op.
    set_property (TARGET ${TARGET}
                  APPEND PROPERTY SOURCES ${STAMPFILE})
    set_property (SOURCE "${SOURCE}"
                  APPEND PROPERTY OBJECT_DEPENDENCIES ${STAMPFILE})

endfunction ()


# ! cmt_target_run_tool
#
# Run an external tool on each source file for TARGET. 
# All of the target's C and C++ sources are extracted from its definition and the
# specified COMMAND is run on each of them. 
#
# cmt_target_run_tool(
#   TARGET
#   TOOL_NAME
#   <CHECK_GENERATED>
#   [WORKING_DIRECTORY <working_directory>]
#   [DEPENDENCIES <dependencies>...] 
#   [COMMAND <command>...]
# )
#
# \input    TARGET The target to run the tool for.
# \input    TOOL_NAME The name of the tool. 
# \param    WORKING_DIRECTORY The working directory for the tool.
# \option   CHECK_GENERATED Include generated files in the analysis.
# \groups   DEPENDENCIES Targets and sources running this tool DEPENDENCIES on.
# \groups   COMMAND The command to run to invoke this tool. @SOURCE@ is replaced with the source file path.
#
function (cmt_target_run_tool TARGET TOOL_NAME)
    cmake_parse_arguments(RUN_COMMAND "CHECK_GENERATED" "WORKING_DIRECTORY" "DEPENDENCIES;COMMAND" ${ARGN})
	cmt_required_arguments(RUN_COMMAND "" "" "COMMAND")
    cmt_ensure_target(${TARGET})

    cmt_strip_extraneous_sources( ${TARGET} FILTERED_SOURCES)
    if (DEFINED ${RUN_COMMAND_CHECK_GENERATED})
        cmt_filter_out_generated_sources (FILTERED_SOURCES
                                        SOURCES ${HANDLE_CHECK_GENERATED_SOURCES})
    endif()

    cmt_forward_options (RUN_COMMAND "" "WORKING_DIRECTORY" "DEPENDENCIES;COMMAND" RUN_ON_SOURCE_FORWARD)

    # For each source file, add a new custom command which runs our tool and generates a stampfile, 
    # depending on the generation of the source file.
    foreach (SOURCE ${FILTERED_SOURCES})
        cmt_run_tool_on_source (${TARGET} "${SOURCE}" ${TOOL_NAME} ${RUN_ON_SOURCE_FORWARD})
    endforeach ()
endfunction ()


# ! cmt_target_add_compilation_db:
# Creates a JSON Compilation Database in relation to the specified TARGET.
#
# cmt_target_add_compilation_db(
#   TARGET
#   CUSTOM_COMPILATION_DB_DIR_RETUR
#   [C_SOURCES <c_sources>...]
#   [CXX_SOURCES <cxx_sources>...]
#   [INTERNAL_INCLUDE_DIRS <internal_include_dirs>...]
#   [EXTERNAL_INCLUDE_DIRS <external_include_dirs>...]
#   [DEFINITIONS <definitions>...]
# )
# \input    TARGET Target to create JSON compilation database for.
# \input    CUSTOM_COMPILATION_DB_DIR_RETURN Variable to store location of compilation database for the specified TARGET
# \group    C_SOURCES C-language sources to include.
# \group    CXX_SOURCES C++-language sources to include.
# \group    INTERNAL_INCLUDE_DIRS Non-system include directories.
# \group    EXTERNAL_INCLUDE_DIRS System include directories.
# \group    DEFINITIONS Extra definitions to set.
function (cmt_target_add_compilation_db TARGET
                                  CUSTOM_COMPILATION_DB_DIR_RETURN)

    cmake_parse_arguments(COMPDB "" "" "C_SOURCES;CXX_SOURCES;INTERNAL_INCLUDE_DIRS;EXTERNAL_INCLUDE_DIRS;DEFINITIONS" ${ARGN})
	cmt_required_arguments(FUNCTION cmt_target_compilation_db PREFIX RUN_COMMAND FIELDS TOOL)
	cmt_ensure_on_of_argument(FUNCTION cmt_target_compilation_db PREFIX COMPDB FIELDS C_SOURCES CXX_SOURCES)


    set (CUSTOM_COMPILATION_DB_DIR "${CMAKE_CURRENT_BINARY_DIR}/${TARGET}_compile_commands/")
    set (COMPILATION_DB_FILE "${CUSTOM_COMPILATION_DB_DIR}/compile_commands.json")

    set (COMPILATION_DB_FILE_CONTENTS
         "[")

    foreach (C_SOURCE ${COMPDB_C_SOURCES})
        list (APPEND SOURCES_LANGUAGES "C,${C_SOURCE}")
    endforeach ()

    foreach (CXX_SOURCE ${COMPDB_CXX_SOURCES})
        list (APPEND SOURCES_LANGUAGES "CXX,${CXX_SOURCE}")
    endforeach ()

    foreach (SOURCE_LANGUAGE ${SOURCES_LANGUAGES})
        string (REPLACE "," ";" SOURCE_LANGUAGE "${SOURCE_LANGUAGE}")
        list (GET SOURCE_LANGUAGE 0 LANGUAGE)
        list (GET SOURCE_LANGUAGE 1 SOURCE)
        get_filename_component (FULL_PATH "${SOURCE}" ABSOLUTE)
        get_filename_component (BASENAME "${SOURCE}" NAME)
        set (COMPILATION_DB_FILE_CONTENTS
             "${COMPILATION_DB_FILE_CONTENTS}\n{\n"
             "\"directory\": \"${CMAKE_CURRENT_BINARY_DIR}\",\n"
             "\"command\": \"")
        unset (COMPILER_COMMAND_LINE)

        # Compiler and language options
        if (LANGUAGE STREQUAL "CXX")
            list (APPEND COMPILER_COMMAND_LINE "\\\"${CMAKE_CXX_COMPILER}\\\"")
            if (CMAKE_CXX_COMPILER_ID STREQUAL "MSVC")
                list (APPEND COMPILER_COMMAND_LINE "--driver-mode=cl")
            else ()
                list (APPEND COMPILER_COMMAND_LINE -x c++)
            endif ()
        elseif (LANGUAGE STREQUAL "C")
            list (APPEND COMPILER_COMMAND_LINE "\\\"${CMAKE_C_COMPILER}\\\"")
            if (CMAKE_CXX_COMPILER_ID STREQUAL "MSVC")
                list (APPEND COMPILER_COMMAND_LINE "--driver-mode=cl")
            endif ()
        endif ()

        # Fake output file etc.
        list (APPEND COMPILER_COMMAND_LINE  -o "CMakeFiles/${TARGET}.dir/${BASENAME}.o" -c "\\\"${FULL_PATH}\\\"")

        # All includes
        set (SYSTEM_INCLUDE_FLAG "-isystem")

        if (LANGUAGE STREQUAL "C" AND CMAKE_CXX_COMPILER_ID STREQUAL "MSVC")
            set (SYSTEM_INCLUDE_FLAG "-I")
        elseif (LANGUAGE STREQUAL "CXX" AND
                CMAKE_CXX_COMPILER_ID STREQUAL "MSVC")
            set (SYSTEM_INCLUDE_FLAG "-I")
        endif ()

        cmt_append_each_to_options_with_prefix (COMPILER_COMMAND_LINE
                                                "${SYSTEM_INCLUDE_FLAG}"
                                                LIST
                                                ${COMPDB_EXTERNAL_INCLUDE_DIRS}
                                                WRAP_IN_QUOTES)
        cmt_append_each_to_options_with_prefix (COMPILER_COMMAND_LINE
                                                -I
                                                LIST
                                                ${COMPDB_INTERNAL_INCLUDE_DIRS}
                                                WRAP_IN_QUOTES)

        # All defines
        cmt_append_each_to_options_with_prefix (COMPILER_COMMAND_LINE
                                                -D
                                                LIST ${COMPDB_DEFINITIONS})

        # CXXFLAGS / CFLAGS
        if (LANGUAGE STREQUAL "CXX")
            list (APPEND COMPILER_COMMAND_LINE ${CMAKE_CXX_FLAGS})
        elseif (LANGUAGE STREQUAL "C")
            list (APPEND COMPILER_COMMAND_LINE ${CMAKE_C_FLAGS})
        endif ()

        get_property (COMPILE_FLAGS TARGET "${TARGET}" PROPERTY COMPILE_FLAGS)
        list (APPEND COMPILER_COMMAND_LINE "${COMPILE_FLAGS}")

        string (REPLACE ";" " " COMPILER_COMMAND_LINE "${COMPILER_COMMAND_LINE}")
        set (COMPILATION_DB_FILE_CONTENTS "${COMPILATION_DB_FILE_CONTENTS}${COMPILER_COMMAND_LINE}")
        set (COMPILATION_DB_FILE_CONTENTS "${COMPILATION_DB_FILE_CONTENTS}\",\n" "\"file\": \"${FULL_PATH}\"\n" "},")
    endforeach ()

    # Get rid of all the semicolons
    string (REPLACE ";" "" COMPILATION_DB_FILE_CONTENTS "${COMPILATION_DB_FILE_CONTENTS}")

    # Take away the last comma
    string (LENGTH "${COMPILATION_DB_FILE_CONTENTS}" COMPILATION_DB_FILE_LENGTH)
    math (EXPR TRIMMED_COMPILATION_DB_FILE_LENGTH "${COMPILATION_DB_FILE_LENGTH} - 1")
    string (SUBSTRING "${COMPILATION_DB_FILE_CONTENTS}" 0  ${TRIMMED_COMPILATION_DB_FILE_LENGTH} COMPILATION_DB_FILE_CONTENTS)

    # Final "]"
    set (COMPILATION_DB_FILE_CONTENTS "${COMPILATION_DB_FILE_CONTENTS}\n]\n")

    # Write out
    file (WRITE "${COMPILATION_DB_FILE}"  ${COMPILATION_DB_FILE_CONTENTS})

    set (${CUSTOM_COMPILATION_DB_DIR_RETURN} "${CUSTOM_COMPILATION_DB_DIR}" PARENT_SCOPE)

endfunction ()