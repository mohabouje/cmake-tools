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
# - cmt_eunomia_configure

# ! cmt_find_dot
# Try to find the eunomiaexecutable.
# If the executable is not found, the function will throw an error.
#
# cmt_find_dot(
#   EXECUTABLE
# )
#
# \output EXECUTABLE The path to the eunomiaexecutable.
# \param BIN_SUBDIR - The subdirectory where the executable is located.
# \group NAMES - The name of the executable.
#
function (cmt_find_eunomia EXECUTABLE)
    cmt_parse_arguments(ARGS "" "BIN_SUBDIR" "NAMES" ${ARGN})
    cmt_default_argument(ARGS NAMES "eunomia;")
    cmt_default_argument(ARGS BIN_SUBDIR bin)

    cmt_cache_get_tool(EUNOMIA EXECUTABLE_FOUND EXECUTABLE_PATH EXECUTABLE_VERSION)
    if (${EXECUTABLE_FOUND})
        set(${EXECUTABLE} ${EXECUTABLE_PATH} PARENT_SCOPE)
        return()
    endif()

    foreach (EUNOMIA_EXECUTABLE_NAME ${ARGS_NAMES})
        cmt_find_tool_executable (${EUNOMIA_EXECUTABLE_NAME}
                EUNOMIA_EXECUTABLE
                PATHS ${EUNOMIA_SEARCH_PATHS}
                PATH_SUFFIXES "${ARGS_BIN_SUBDIR}")
        if (EUNOMIA_EXECUTABLE)
            break()
        endif()
    endforeach()

    cmt_report_not_found_if_not_quiet (eunomia EUNOMIA_EXECUTABLE
            "The 'dot' executable was not found in any search or system paths.\n"
            "Please adjust EUNOMIA_SEARCH_PATHS to the installation prefix of the 'eunomia' executable or install eunomia")

    # if (EUNOMIA_EXECUTABLE)
    #     set (EUNOMIA_VERSION_HEADER "eunomia- graphviz version ")
    #     cmt_find_tool_extract_version("${EUNOMIA_EXECUTABLE}"
    #                                   EUNOMIA_VERSION
    #                                   VERSION_ARG -V
    #                                   VERSION_HEADER
    #                                   "${EUNOMIA_VERSION_HEADER}"
    #                                   VERSION_END_TOKEN ")")
    # endif()
    set(EUNOMIA_VERSION "Unknown" CACHE STRING "The version of the eunomiaexecutable" FORCE)
    cmt_check_and_report_tool_version(dot
            "${EUNOMIA_VERSION}"
            REQUIRED_VARS
            EUNOMIA_EXECUTABLE
            EUNOMIA_VERSION)
    cmt_cache_set_tool(EUNOMIA ${EUNOMIA_EXECUTABLE} ${EUNOMIA_VERSION})
    set (${EXECUTABLE} ${EUNOMIA_EXECUTABLE} PARENT_SCOPE)
endfunction()

# ! cmt_eunomia_configure : Generates all the config files for the different tools in the config file
#
# cmt_eunomia_configure(
#   [CONFIG_FILE <config_file>]
#   [DESTINATION <destination>]
# )
#
# \param:CONFIG_FILE <config_file> - Path to the Eunomia configuration file
# \param:DESTINATION <destination> - Path to the destination directory
#
macro(cmt_eunomia_configure)
    cmt_parse_arguments(ARGS "" "CONFIG_FILE;WORKING_DIRECTORY" "" ${ARGN})
    cmt_default_argument(ARGS WORKING_DIRECTORY ${PROJECT_SOURCE_DIR})
    cmt_default_argument(ARGS CONFIG_FILE "${PROJECT_SOURCE_DIR}/.eunomiarc")


    cmt_log("Generating eunomia linter configuration... ${ARGS_CONFIG_FILE} installed in ${ARGS_WORKING_DIRECTORY}")
    cmt_find_eunomia(EXECUTABLE)
    execute_process(COMMAND ${EXECUTABLE}
                    --level WARNING
                    --config ${ARGS_CONFIG_FILE}
                    --destination ${ARGS_WORKING_DIRECTORY}
                    RESULT_VARIABLE EXECUTION_RETURN_CODE
                    OUTPUT_VARIABLE EXECUTION_OUTPUT)
    if(NOT ${EXECUTION_RETURN_CODE} EQUAL 0)
        cmt_fatal("Eunomia generation failed with code ${EXECUTION_RETURN_CODE}: ${EXECUTION_OUTPUT}")
    endif()
endmacro()