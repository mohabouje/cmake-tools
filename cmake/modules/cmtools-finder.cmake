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
# furnished to do so, subject to the following conditions                       #
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

include (CMakeParseArguments)
include (FindPackageHandleStandardArgs)
include (FindPackageMessage)

# ! print_if_not_quiet
#
# Print a message as specified as part of ARGN as long as ${PREFIX}_FIND_QUIETLY is not set
#
# \input PREFIX The package prefix passed to find_package for this module
# \group MSG Message to print
# \group DEPENDS Variables, which when changed, the message should be re-displayed
#
function (cmt_print_if_not_quiet PREFIX)
    cmt_parse_arguments (PRINT_IF_NOT_QUIET "" "" "MSG;DEPENDS" ${ARGN})
    string (REPLACE ";" " " MSG "${PRINT_IF_NOT_QUIET_MSG}")
    set (DEPEND_VARS_STRING "")
    foreach (DEPEND_VAR ${DEPENDS})
        set (DEPEND_VARS_STRING "${DEPEND_VARS_STRING}[${${DEPEND_VAR}}]")
    endforeach()
    if (DEPEND_VARS_STRING)
        find_package_message(${PREFIX} "${MSG}" "${DEPEND_VARS_STRING}")
    else()
        if (NOT ${PREFIX}_FIND_QUIETLY)
            cmt_fatal("${MSG}")
        endif()
    endif()
endfunction()

# ! report_not_found_if_not_quiet
#
# If ${PREFIX}_FIND_QUIETLY is not set, print the error message as
# specified in ARGN if the variable named VARIABLE is not set.
#
# \input PREFIX The package prefix passed to find_package for this module
# \input VARIABLE The name of the variable to test
#
function (cmt_report_not_found_if_not_quiet PREFIX VARIABLE)
    if (NOT ${VARIABLE})
        cmt_print_if_not_quiet (${PREFIX} MSG ${ARGN})
    endif()
endfunction()

function (_find_tool_executable_in_custom_paths EXECUTABLE_TO_FIND PATH_RETURN)
    cmt_parse_arguments (FIND_TOOL_EXECUTABLE_CUSTOM_PATHS "" "" "PATHS;PATH_SUFFIXES" ${ARGN})
    unset (PATH_TO_EXECUTABLE CACHE)
    find_program (PATH_TO_EXECUTABLE
                  ${EXECUTABLE_TO_FIND}
                  PATHS ${FIND_TOOL_EXECUTABLE_CUSTOM_PATHS_PATHS}
                  PATH_SUFFIXES
                  ${FIND_TOOL_EXECUTABLE_CUSTOM_PATHS_PATH_SUFFIXES}
                  NO_DEFAULT_PATH)

    if (PATH_TO_EXECUTABLE)
        set (${PATH_RETURN} "${PATH_TO_EXECUTABLE}" PARENT_SCOPE)
        unset (PATH_TO_EXECUTABLE CACHE)
    endif()
endfunction()

function (_find_tool_executable_in_system_paths EXECUTABLE_TO_FIND PATH_RETURN)
    unset (PATH_TO_EXECUTABLE CACHE)
    find_program (PATH_TO_EXECUTABLE ${EXECUTABLE_TO_FIND})
    if (PATH_TO_EXECUTABLE)
        set (${PATH_RETURN} "${PATH_TO_EXECUTABLE}" PARENT_SCOPE)
    endif()
endfunction()

# !cmt_find_tool_executable
#
# Finds the executable EXECUTABLE_TO_FIND and places the result in PATH_RETURN
#
# \input EXECUTABLE_TO_FIND The name of the executable to find
# \output PATH_RETURN A variable to place the full path when found
# \group CUSTOM_PATHS Paths to search first before searching system paths
# \group PATH_SUFFIXES Suffixes on each installation root (eg, bin)
function (cmt_find_tool_executable EXECUTABLE_TO_FIND PATH_RETURN)
    cmt_parse_arguments (FIND_TOOL_EXECUTABLE "" "" "CUSTOM_PATHS;PATH_SUFFIXES" ${ARGN})

    unset (PATH_TO_EXECUTABLE CACHE)
    if (FIND_TOOL_EXECUTABLE_CUSTOM_PATHS)
        set (PATHS ${FIND_TOOL_EXECUTABLE_CUSTOM_PATHS})
        set (PATH_SUFFIXES ${FIND_TOOL_EXECUTABLE_PATH_SUFFIXES})
        _find_tool_executable_in_custom_paths (${EXECUTABLE_TO_FIND}
                                                   PATH_TO_EXECUTABLE
                                                   PATHS
                                                   ${PATHS}
                                                   PATH_SUFFIXES
                                                   ${PATH_SUFFIXES})
    endif()

    if (NOT PATH_TO_EXECUTABLE)
        _find_tool_executable_in_system_paths (${EXECUTABLE_TO_FIND}
                                                   PATH_TO_EXECUTABLE)
    endif()

    if (PATH_TO_EXECUTABLE)
        set (${PATH_RETURN} "${PATH_TO_EXECUTABLE}" PARENT_SCOPE)
    endif()

endfunction()

# !cmt_find_tool_extract_version
#
# Runs the tool and fetches its version, placing the result into VERSION_RETURN
#
# \input TOOL_EXECUTABLE The path to the tool
# \output VERSION_RETURN A variable to place the full version when detected
# \group VERSION_ARG Argument to pass to the tool when running it to fetch its version.
# \group VERSION_HEADER Text that comes before the version number.
# \group VERSION_END_TOKEN Text that comes after the version number.
#
function (cmt_find_tool_extract_version TOOL_EXECUTABLE VERSION_RETURN)

    cmt_parse_arguments (FIND_TOOL "" "VERSION_ARG;VERSION_HEADER;VERSION_END_TOKEN" "" ${ARGN})
    execute_process (COMMAND "${TOOL_EXECUTABLE}"
                     ${FIND_TOOL_VERSION_ARG}
                     OUTPUT_VARIABLE TOOL_VERSION_OUTPUT)

    if (FIND_TOOL_VERSION_HEADER)
        string (FIND "${TOOL_VERSION_OUTPUT}" "${FIND_TOOL_VERSION_HEADER}" FIND_TOOL_VHEADER_LOC)
        string (LENGTH "${FIND_TOOL_VERSION_HEADER}" FIND_TOOL_VHEADER_SIZE)
        math (EXPR FIND_TOOL_VERSION_START "${FIND_TOOL_VHEADER_LOC} + ${FIND_TOOL_VHEADER_SIZE}")
        string (SUBSTRING "${TOOL_VERSION_OUTPUT}" ${FIND_TOOL_VERSION_START} -1 FIND_TOOL_VERSION_TO_END)
    else()
        set (FIND_TOOL_VERSION_TO_END ${TOOL_VERSION_OUTPUT})
    endif()

    if (FIND_TOOL_VERSION_END_TOKEN)
        string (FIND "${FIND_TOOL_VERSION_TO_END}" "${FIND_TOOL_VERSION_END_TOKEN}" FIND_TOOL_RETURN_LOC)
        string (SUBSTRING "${FIND_TOOL_VERSION_TO_END}" 0 ${FIND_TOOL_RETURN_LOC} FIND_TOOL_VERSION)
    else()
        set (FIND_TOOL_VERSION ${FIND_TOOL_VERSION_TO_END})
    endif()

    if (NOT FIND_TOOL_VERSION)
        cmt_fatal("Failed to find tool version by executing ${TOOL_EXECUTABLE} ${FIND_TOOL_VERSION_ARG} "
                "and splicing between the header '${FIND_TOOL_VERSION_HEADER}' and footer "
                "'${FIND_TOOL_VERSION_END_TOKEN}'. The output to  scan was ${TOOL_VERSION_OUTPUT}")
    endif()

    # Strip out any \n
    string (REPLACE "\n" "" FIND_TOOL_VERSION "${FIND_TOOL_VERSION}")
    set (${VERSION_RETURN} ${FIND_TOOL_VERSION} PARENT_SCOPE)
endfunction()

# ! cmt_check_and_report_tool_version
#
# For the package specified by PREFIX, determines if the detected
# VERSION matched the requested version passed to find_package. If not
# and we are not finding quietly, report problems. If the version check
# is satisfied and all REQUIRED_VARS are set, then set each of the
# REQUIRED_VARS in the PARENT_SCOPE
#
# \input  PREFIX The package prefix passed to find_package for this module
# \output VERSION The detected tool version
# \group  REQUIRED_VARS  Required variables, set in parent scope if present
#
macro (cmt_check_and_report_tool_version PREFIX VERSION)
    cmt_parse_arguments (_PSQ_CHECK_${PREFIX} "" "" "REQUIRED_VARS" ${ARGN})
    cmt_required_arguments(_PSQ_CHECK_${PREFIX} "" "" "REQUIRED_VARS")
    string (STRIP "${VERSION}" VERSION)
    cmt_logger_set_scoped_level(WARNING)
    find_package_handle_standard_args (${PREFIX}
                                       FOUND_VAR ${PREFIX}_FOUND
                                       REQUIRED_VARS
                                       ${_PSQ_CHECK_${PREFIX}_REQUIRED_VARS}
                                       VERSION_VAR VERSION)
    cmt_logger_reset_scoped_context()
    if (${PREFIX}_FOUND)
        foreach (VARIABLE ${_PSQ_CHECK_${PREFIX}_REQUIRED_VARS})
            set (${VARIABLE} ${${VARIABLE}} CACHE STRING "" FORCE PARENT_SCOPE)
        endforeach()
    endif()
endmacro()

# ! cmt_find_executable_installation_root
#
# For the path to a TOOL_EXECUTABLE, get the installation prefix
# of that executable and place it in the variable named by INSTALL_ROOT_RETURN
#
# \input TOOL_EXECUTABLE Path to an executable
# \output INSTALL_ROOT_RETURN A variable to place the full path to install root
# \param PREFIX_SUBDIRECTORY A partial path of directories between the executable itself and install root (eg /bin/)
function (cmt_find_executable_installation_root TOOL_EXECUTABLE INSTALL_ROOT_RETURN)
    cmt_parse_arguments (INSTALL_ROOT "" "PREFIX_SUBDIRECTORY" "" ${ARGN})

    get_filename_component (TOOL_EXEC_PATH "${TOOL_EXECUTABLE}" ABSOLUTE)
    get_filename_component (TOOL_EXEC_BASE "${TOOL_EXECUTABLE}" NAME)

    # Strip unsanitized string
    string (STRIP "${TOOL_EXEC_PATH}" TOOL_EXEC_PATH)

    # First get the tool path lengths
    string (LENGTH "${TOOL_EXEC_PATH}" TOOL_EXEC_PATH_LENGTH)
    if (INSTALL_ROOT_PREFIX_SUBDIRECTORY)
        set (PREFIXED_PATH "/${INSTALL_ROOT_PREFIX_SUBDIRECTORY}/")
    endif()
    set (PREFIXED_PATH "${PREFIXED_PATH}${TOOL_EXEC_BASE}")
    string (LENGTH "${PREFIXED_PATH}" TOOL_EXEC_SUBDIR_LENGTH)

    # Then determine how long the prefix is
    math (EXPR TOOL_EXEC_PREFIX_LENGTH "${TOOL_EXEC_PATH_LENGTH} - ${TOOL_EXEC_SUBDIR_LENGTH}")

    # Then we get the prefix substring
    string (SUBSTRING "${TOOL_EXEC_PATH}" 0 ${TOOL_EXEC_PREFIX_LENGTH} TOOL_INSTALL_ROOT)

    set (${INSTALL_ROOT_RETURN} ${TOOL_INSTALL_ROOT} PARENT_SCOPE)

endfunction()

# ! cmt_find_path_in_installation_root
#
# Places the full path to SUBDIRECTORY_TO_FIND in PATH_RETURN if found in
# INSTALL_ROOT
#
# \input INSTALL_ROOT The directory to search for
# \input SUBDIRECTORY_TO_FIND The name of the subdirectory to find
# \output PATH_RETURN A variable to place the full path when found
#
function (cmt_find_path_in_installation_root INSTALL_ROOT SUBDIRECTORY_TO_FIND PATH_RETURN)
    find_path (_PATH ${SUBDIRECTORY_TO_FIND} PATHS ${INSTALL_ROOT} NO_DEFAULT_PATH)
    if (_PATH)
        mark_as_advanced (_PATH)
        set (${PATH_RETURN} "${_PATH}/${SUBDIRECTORY_TO_FIND}" PARENT_SCOPE)
        unset (_PATH CACHE)
    endif()
endfunction()