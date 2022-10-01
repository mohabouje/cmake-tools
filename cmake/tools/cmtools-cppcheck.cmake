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

include(${CMAKE_CURRENT_LIST_DIR}/cmtools-runner.cmake)

cmt_disable_logger()
include(${CMAKE_CURRENT_LIST_DIR}/./../third_party/cppcheck.cmake)
cmt_enable_logger()

# Functions summary:
# - cmt_target_generate_cppcheck

# ! cmt_target_generate_cppcheck
# Generate a cppcheck target for the target.
# The generated target lanch cppcheck on all the target sources in the specified working directory.
#
# cmt_target_generate_cppcheck(
#   TARGET
# )
#
# \input TARGET The target to generate the cppcheck target for.
#
function(cmt_target_generate_cppcheck TARGET)
    cmt_ensure_target(${TARGET})

    if (NOT CMT_ENABLE_CPPCHECK)
        return()
    endif()

    cmt_find_program(CPPCHECK_PROGRAM cppcheck)
    cppcheck(TARGET ${TARGET})
    cmt_log("Target ${TARGET}: generate target to run cppcheck")
endfunction()


# ! cmt_target_enable_cppcheck
# Enable include-what-you-use checks on the given target
#
# cmt_target_enable_cppcheck(
#   TARGET
# )
#
# \input TARGET The target to enable the cppcheck checks for.
#
function(cmt_target_enable_cppcheck TARGET)
    cmt_ensure_target(${TARGET})
    if (NOT CMT_ENABLE_CPPCHECK)
        return()
    endif()

    cmt_find_program(CPPCHECK_PROGRAM cppcheck)
    set_property(TARGET ${TARGET} PROPERTY CMAKE_CXX_CPPCHECK ${CPPCHECK_PROGRAM})
    set_property(TARGET ${TARGET} PROPERTY CMAKE_C_CPPCHECK ${CPPCHECK_PROGRAM})
    cmt_log("Target ${TARGET}: enabling extension cppcheck")
endfunction()


set (CMT_CPPCHECK_COMMON_OPTIONS
     --quiet
     --template
     "{file}:{line}: {severity} {id}: {message}"
     --inline-suppr
     --max-configs=1)
set (_CPPCHECK_LIST_DIR "${CMAKE_CURRENT_LIST_DIR}")

function (__cmt_cppcheck_get_commandline COMMANDLINE_RETURN)
    cmake_parse_arguments(COMMANDLINE "" "LANGUAGE" "OPTIONS" ${ARGN})
    cmt_required_arguments(COMMANDLINE "" "LANGUAGE" "OPTIONS")
    cmt_ensure_argument_choice(COMMANDLINE LANGUAGE C CXX)

    if (${CPPCHECK_VERSION} VERSION_GREATER 1.57)
        if (COMMANDLINE_LANGUAGE STREQUAL "C")
            set (LANGUAGE_OPTION --language=c)
        elseif (COMMANDLINE_LANGUAGE STREQUAL "CXX")
            set (LANGUAGE_OPTION --language=c++ -D__cplusplus)
        endif ()
    endif ()

    set (${COMMANDLINE_RETURN}
         "${CPPCHECK_EXECUTABLE}"
         ${COMMANDLINE_OPTIONS}
         ${LANGUAGE_OPTION}
         ${COMMANDLINE_SOURCES}
         PARENT_SCOPE)
endfunction ()


function (__cmt_cppcheck_add_normal_check_command TARGET SOURCE)
    cmake_parse_arguments (ADD_NORMAL_CHECK "" "LANGUAGE" "OPTIONS;DEPENDENCIES" ${ARGN})
    cmt_required_arguments(COMMANDLINE "" "LANGUAGE" "OPTIONS")
    cmt_ensure_argument_choice(COMMANDLINE LANGUAGE C CXX)
    cmt_ensure_target(${TARGET})

    # Get a commandline
    cmt_forward_options (ADD_NORMAL_CHECK "" "LANGUAGE" "OPTIONS" GET_COMMANDLINE_FORWARD_OPTIONS)
     __cmt_cppcheck_get_commandline (CPPCHECK_COMMAND SOURCES "${SOURCE}" ${GET_COMMANDLINE_FORWARD_OPTIONS})

    # cppcheck (c) and cppcheck (cxx) can both be run on one source
    string (TOLOWER "${ADD_NORMAL_CHECK_LANGUAGE}" LANGUAGE_LOWER)
    cmt_forward_options (ADD_NORMAL_CHECK "" "" "DEPENDENCIES" RUN_TOOL_ON_SOURCE_FORWARD)
    cmt_run_tool_on_source (${TARGET} "${SOURCE}" "cppcheck (${LANGUAGE_LOWER})"
                            COMMAND ${CPPCHECK_COMMAND}
                            ${RUN_TOOL_ON_SOURCE_FORWARD})
endfunction ()


function (__cmt_cppcheck_add_checks_to_target TARGET)
    cmake_parse_arguments (ADD_CHECKS
                           "CHECK_GENERATED"
                           "FORCE_LANGUAGE"
                           "SOURCES;OPTIONS;INCLUDES;DEFINITIONS;CPP_IDENTIFIERS;DEPENDENCIES"
                           ${ARGN})
    cmt_ensure_target(${TARGET})
    
    cmt_forward_options (ADD_CHECKS "" "FORCE_LANGUAGE" "SOURCES;INCLUDES;CPP_IDENTIFIERS" SORT_SOURCES_OPTIONS)
    cmt_sort_sources_to_languages (C_SOURCES CXX_SOURCES HEADERS ${SORT_SOURCES_OPTIONS})

    cmt_forward_options (ADD_CHECKS "" "" "DEPENDENCIES" ADD_NORMAL_CHECK_COMMAND_FORWARD)

    # For C headers, pass --language=c
    foreach (SOURCE ${C_SOURCES})
         __cmt_cppcheck_add_normal_check_command (${TARGET} "${SOURCE}"
                                            OPTIONS
                                            ${ADD_CHECKS_OPTIONS}
                                            LANGUAGE C
                                            ${ADD_NORMAL_CHECK_COMMAND_FORWARD})
    endforeach ()

    # For CXX headers, pass --language=c++ and -D__cplusplus
    foreach (SOURCE ${CXX_SOURCES})
         __cmt_cppcheck_add_normal_check_command (${TARGET} "${SOURCE}"
                                            OPTIONS
                                            ${ADD_CHECKS_OPTIONS}
                                            LANGUAGE CXX
                                            ${ADD_NORMAL_CHECK_COMMAND_FORWARD})
    endforeach ()
endfunction ()

# ! cmt_cppcheck_generate_for_sources
#
# Run CPPCheck on the sources as specified in SOURCES, reporting any
# warnings or errors on stderr.
#
# \input  TARGET Target to attach checks to
# \group  SOURCES A list of sources to scan.
# \param  FORCE_LANGUAGE Force all scanned files to be a certain language eg C, CXX
# \group  INCLUDES Include directories to search.
# \group  DEFINITIONS Set compile time definitions.
# \group  CPP_IDENTIFIERS A list of identifiers which indicate that any header file specified in the source list is definitely a C++ header file
# \group  DEPENDENCIES Targets or source files to depend on.
# \option WARN_ONLY Don't error out, just warn on potential problems.
# \option NO_CHECK_STYLE Don't check for style issues.
# \option NO_CHECK_UNUSED Don't check for unused functions.
# \option CHECK_GENERATED Also check generated sources.
# \option CHECK_GENERATED_FOR_UNUSED: Check generated sources later for the unused function check. 
#          This option works independently of the CHECK_GENERATED option.
#
function (cmt_cppcheck_generate_for_sources TARGET)

    # cppcheck_validate (CPPCHECK_AVAILABLE)

    if (NOT CMT_ENABLE_CPPCHECK)
        return()
    endif()

    set (OPTIONAL_OPTIONS  WARN_ONLY NO_CHECK_STYLE NO_CHECK_UNUSED CHECK_GENERATED CHECK_GENERATED_FOR_UNUSED)
    set (SINGLEVALUE_OPTIONS FORCE_LANGUAGE)
    set (MULTIVALUE_OPTIONS INCLUDES DEFINITIONS SOURCES CPP_IDENTIFIERS DEPENDENCIES)
    cmake_parse_arguments (CPPCHECK
                           "${OPTIONAL_OPTIONS}"
                           "${SINGLEVALUE_OPTIONS}"
                           "${MULTIVALUE_OPTIONS}"
                           ${ARGN})


    if (DEFINED ${CPPCHECK_CHECK_GENERATED})
        cmt_filter_out_generated_sources(FILTERED_CHECK_SOURCES
                                         SOURCES ${CPPCHECK_SOURCES})
    endif()


    set (CPPCHECK_OPTIONS ${CMT_CPPCHECK_COMMON_OPTIONS} --enable=performance --enable=portability)

    cmt_add_switch (CPPCHECK_OPTIONS CPPCHECK_WARN_ONLY
                    OFF --error-exitcode=1)
    cmt_add_switch (CPPCHECK_OPTIONS CPPCHECK_NO_CHECK_STYLE
                    OFF --enable=style)
    cmt_add_switch (CPPCHECK_OPTIONS CPPCHECK_NO_CHECK_UNUSED
                    OFF --enable=unusedFunction
                    ON --suppress=unusedStructMember)

    cmt_append_each_to_options_with_prefix (CPPCHECK_OPTIONS -I LIST ${CPPCHECK_INCLUDES})
    cmt_append_each_to_options_with_prefix (CPPCHECK_OPTIONS -D LIST ${CPPCHECK_DEFINITIONS})

    cmt_forward_options (CPPCHECK "" "FORCE_LANGUAGE" "OPTIONS;INCLUDES;DEFINITIONS;CPP_IDENTIFIERS;DEPENDENCIES" ADD_CHECKS_TO_TARGET_FORWARD)
     __cmt_cppcheck_add_checks_to_target (${TARGET}
                                    SOURCES ${FILTERED_CHECK_SOURCES}
                                    ${ADD_CHECKS_TO_TARGET_FORWARD})
endfunction ()

# ! cmt_cppcheck_target_sources
# Run CPPCheck on all the sources for a particular TARGET, reporting any warnings or errors on stderr
#
# \input  TARGET Target to attach checks to
# \param  FORCE_LANGUAGE Force all scanned files to be a certain language eg C, CXX
# \group  INCLUDES Include directories to search.
# \group  DEFINITIONS Set compile time definitions.
# \group  CPP_IDENTIFIERS A list of identifiers which indicate that any header file specified in the source list is definitely a C++ header file
# \group  DEPENDENCIES Targets or source files to depend on.
# \option WARN_ONLY Don't error out, just warn on potential problems.
# \option NO_CHECK_STYLE Don't check for style issues.
# \option NO_CHECK_UNUSED Don't check for unused functions.
# \option CHECK_GENERATED Also check generated sources.
# \option CHECK_GENERATED_FOR_UNUSED: Check generated sources later for the unused function check. 
#          This option works independently of the CHECK_GENERATED option.
#
function (cmt_target_generate_cppcheck_ TARGET)
    cmt_ensure_target(${TARGET})
    cmt_strip_extraneous_sources (${TARGET} FILES_TO_CHECK)
    cmt_cppcheck_generate_for_sources (${TARGET} SOURCES ${FILES_TO_CHECK} ${ARGN})
endfunction ()