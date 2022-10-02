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

include(FindDoxygen)

include(${CMAKE_CURRENT_LIST_DIR}/./../utility/cmtools-args.cmake)
include(${CMAKE_CURRENT_LIST_DIR}/./../utility/cmtools-env.cmake)

# Functions summary:
# - cmt_find_dot
# - cmt_find_latex
# - cmt_find_doxygen
# - cmt_generate_doxygen_documentation


# Functions summary:
# - cmt_dependency_graph

# ! cmt_find_dot
# Try to find the dot executable.
# If the executable is not found, the function will throw an error.
#
# cmt_find_dot(
#   EXECUTABLE
# )
#
# \output EXECUTABLE The path to the dot executable.
# \param BIN_SUBDIR - The subdirectory where the executable is located.
# \group NAMES - The name of the executable.
#
function (cmt_find_dot EXECUTABLE)
    cmake_parse_arguments(ARGS "" "BIN_SUBDIR" "NAMES" ${ARGN})
    cmt_default_argument(ARGS NAMES "dot;")
    cmt_default_argument(ARGS BIN_SUBDIR bin)

    cmt_cache_get_tool(DOT EXECUTABLE_FOUND EXECUTABLE_PATH EXECUTABLE_VERSION)
    if (${EXECUTABLE_FOUND})
        set(${EXECUTABLE} ${EXECUTABLE_PATH} PARENT_SCOPE)
        return()
    endif()

    foreach (DOT_EXECUTABLE_NAME ${ARGS_NAMES})
         cmt_find_tool_executable (${DOT_EXECUTABLE_NAME}
                                  DOT_EXECUTABLE
                                  PATHS ${DOT_SEARCH_PATHS}
                                  PATH_SUFFIXES "${ARGS_BIN_SUBDIR}")
        if (DOT_EXECUTABLE)
            break()
        endif()
    endforeach()

    cmt_report_not_found_if_not_quiet (dot DOT_EXECUTABLE
        "The 'dot' executable was not found in any search or system paths.\n"
        "Please adjust DOT_SEARCH_PATHS to the installation prefix of the 'dot' executable or install dot")

    # if (DOT_EXECUTABLE)
    #     set (DOT_VERSION_HEADER "dot - graphviz version ")
    #     cmt_find_tool_extract_version("${DOT_EXECUTABLE}"
    #                                   DOT_VERSION
    #                                   VERSION_ARG -V
    #                                   VERSION_HEADER
    #                                   "${DOT_VERSION_HEADER}"
    #                                   VERSION_END_TOKEN ")")
    # endif()
    set(DOT_VERSION "Unknown")
    cmt_check_and_report_tool_version(dot
                                      "${DOT_VERSION}"
                                      REQUIRED_VARS
                                      DOT_EXECUTABLE
                                      DOT_VERSION)
    cmt_cache_set_tool(DOT TRUE ${DOT_EXECUTABLE} ${DOT_VERSION})
    set (EXECUTABLE ${DOT_EXECUTABLE} PARENT_SCOPE)
endfunction()

# ! cmt_find_doxygen
# Try to find the doxygen executable.
# If the executable is not found, the function will throw an error.
#
# cmt_find_doxygen(
#   EXECUTABLE
# )
#
# \output EXECUTABLE The path to the doxygen executable.
# \param BIN_SUBDIR - The subdirectory where the executable is located.
# \group NAMES - The name of the executable.
#
function (cmt_find_doxygen EXECUTABLE)
    cmake_parse_arguments(ARGS "" "BIN_SUBDIR" "NAMES" ${ARGN})
    cmt_default_argument(ARGS NAMES "doxygen;")
    cmt_default_argument(ARGS BIN_SUBDIR bin)

    cmt_cache_get_tool(DOXYGEN EXECUTABLE_FOUND EXECUTABLE_PATH EXECUTABLE_VERSION)
    if (${EXECUTABLE_FOUND})
        set(${EXECUTABLE} ${EXECUTABLE_PATH} PARENT_SCOPE)
        return()
    endif()

    foreach (DOXYGEN_EXECUTABLE_NAME ${ARGS_NAMES})
         cmt_find_tool_executable (${DOXYGEN_EXECUTABLE_NAME}
                                  DOXYGEN_EXECUTABLE
                                  PATHS ${DOXYGEN_SEARCH_PATHS}
                                  PATH_SUFFIXES "${ARGS_BIN_SUBDIR}")
        if (DOXYGEN_EXECUTABLE)
            break()
        endif()
    endforeach()

    cmt_report_not_found_if_not_quiet (doxygen DOXYGEN_EXECUTABLE
        "The 'doxygen' executable was not found in any search or system paths.\n"
        "Please adjust DOXYGEN_SEARCH_PATHS to the installation prefix of the 'doxygen' executable or install doxygen")

    if (DOXYGEN_EXECUTABLE)
        cmt_find_tool_extract_version("${DOXYGEN_EXECUTABLE}"
                                      DOXYGEN_VERSION
                                      VERSION_ARG --version)
    endif()
    cmt_check_and_report_tool_version(doxygen
                                      "${DOXYGEN_VERSION}"
                                      REQUIRED_VARS
                                      DOXYGEN_EXECUTABLE
                                      DOXYGEN_VERSION)
    cmt_cache_set_tool(DOXYGEN TRUE ${DOXYGEN_EXECUTABLE} ${DOXYGEN_VERSION})
    set (EXECUTABLE ${DOXYGEN_EXECUTABLE} PARENT_SCOPE)
endfunction()

# ! cmt_find_latex
# Try to find the latex executable.
# If the executable is not found, the function will throw an error.
#
# cmt_find_latex(
#   EXECUTABLE
# )
#
# \output EXECUTABLE The path to the latex executable.
# \param BIN_SUBDIR - The subdirectory where the executable is located.
# \group NAMES - The name of the executable.
#
function (cmt_find_latex EXECUTABLE)
    cmake_parse_arguments(ARGS "" "BIN_SUBDIR" "NAMES" ${ARGN})
    cmt_default_argument(ARGS NAMES "latex;")
    cmt_default_argument(ARGS BIN_SUBDIR bin)

    cmt_cache_get_tool(LATEX EXECUTABLE_FOUND EXECUTABLE_PATH EXECUTABLE_VERSION)
    if (${EXECUTABLE_FOUND})
        set(${EXECUTABLE} ${EXECUTABLE_PATH} PARENT_SCOPE)
        return()
    endif()

    foreach (LATEX_EXECUTABLE_NAME ${ARGS_NAMES})
         cmt_find_tool_executable (${LATEX_EXECUTABLE_NAME}
                                  LATEX_EXECUTABLE
                                  PATHS ${LATEX_SEARCH_PATHS}
                                  PATH_SUFFIXES "${ARGS_BIN_SUBDIR}")
        if (LATEX_EXECUTABLE)
            break()
        endif()
    endforeach()

    cmt_report_not_found_if_not_quiet (latex LATEX_EXECUTABLE
        "The 'latex' executable was not found in any search or system paths.\n"
        "Please adjust LATEX_SEARCH_PATHS to the installation prefix of the 'latex' executable or install latex")

    if (LATEX_EXECUTABLE)
        set (LATEX_VERSION_HEADER "latex version ")
        cmt_find_tool_extract_version("${LATEX_EXECUTABLE}"
                                      LATEX_VERSION
                                      VERSION_ARG --version
                                      VERSION_HEADER
                                      "${LATEX_VERSION_HEADER}"
                                      VERSION_END_TOKEN "\n")
    endif()

    cmt_check_and_report_tool_version(latex
                                      "${LATEX_VERSION}"
                                      REQUIRED_VARS
                                      LATEX_EXECUTABLE
                                      LATEX_VERSION)

    cmt_cache_set_tool(LATEX TRUE ${LATEX_EXECUTABLE} ${LATEX_VERSION})
    set (EXECUTABLE ${LATEX_EXECUTABLE} PARENT_SCOPE)
endfunction()


# ! cmt_generate_doxygen_documentation
# This function is intended as a convenience for adding a target for generating documentation with Doxygen. 
#
function(cmt_generate_doxygen_documentation TARGET)
    cmake_parse_arguments(ARGS "HTML;MAN" "PROJECT_NAME;PROJECT_NUMBER;PROJECT_DESCRIPTION;BINARY_DIR;SOURCE_DIR" "" ${ARGN})
    cmt_default_argument(ARGS BINARY_DIR "${CMAKE_BINARY_DIR}/doxygen")
    cmt_default_argument(ARGS SOURCE_DIR ${CMAKE_SOURCE_DIR})
    cmt_default_argument(ARGS PROJECT_NAME ${PROJECT_NAME})
    cmt_default_argument(ARGS PROJECT_NUMBER ${PROJECT_VERSION})
    cmt_default_argument(ARGS PROJECT_DESCRIPTION ${PROJECT_DESCRIPTION})

    if (NOT CMT_ENABLE_DOXYGEN)
        return()
    endif()

    set(DOXYGEN_OUTPUT_DIRECTORY ${ARGS_BINARY_DIR})
    set(DOXYGEN_PROJECT_NAME ${ARGS_PROJECT_NAME})
    set(DOXYGEN_PROJECT_NUMBER ${ARGS_PROJECT_NUMBER})
    set(DOXYGEN_PROJECT_BRIEF ${ARGS_PROJECT_DESCRIPTION})

    if (${CMT_ENABLE_DOXYGEN_GRAPHVIZ})
        cmt_find_dot(DOT_EXECUTABLE)
        set(DOXYGEN_HAVE_DOT TRUE)
    else()
        set(DOXYGEN_HAVE_DOT FALSE)
    endif()

    if (${CMT_ENABLE_DOXYGEN_LATEX}) 
        cmt_find_latex(LATEX_EXECUTABLE)
        set(DOXYGEN_GENERATE_LATEX TRUE)
    else()
        set(DOXYGEN_GENERATE_LATEX FALSE)
    endif()

    if (DEFINED ARGS_HTML)
        set(DOXYGEN_GENERATE_HTML YES)
    endif()

    if (DEFINED ARGS_MAN)
        set(DOXYGEN_GENERATE_MAN YES)
    endif()
    
    doxygen_add_docs(
        ${TARGET}
        ${ARGS_SOURCE_DIR}
        COMMENT "Generating documentation for ${ARGS_PROJECT_NAME}..."
    )

endfunction()


# ! cmt_generate_dependency_graph
# Builds a dependency graph of the active code targets using the `dot` application
#
# cmt_generate_dependency_graph(
#   TARGET
#   [OUTPUT_DIR <output>] # Default: ${CMAKE_CURRENT_BINARY_DIR}/graphviz
# )
#
# \input TARGET -The target that triggers the dependency graph generation.
# \param OUTPUT_DIR The output directory where the generated files will be stored.
#
macro(cmt_generate_dependency_graph TARGET)
    cmake_parse_arguments(ARGS "" "OUTPUT_DIR;OUTPUT_TYPE" "" ${ARGN})
    cmt_default_argument(ARGS OUTPUT_DIR "${CMAKE_CURRENT_BINARY_DIR}/graphviz")
    cmt_default_argument(ARGS OUTPUT_TYPE "pdf")

    if (TARGET ${TARGET})
        cmt_fatal("Target ${TARGET} already exists")
    endif()

    if (NOT CMT_ENABLE_GRAPHVIZ)
        return()
    endif()

    cmt_find_dot(DOT_EXECUTABLE)

    add_custom_target(
      ${TARGET}
      COMMAND ${CMAKE_COMMAND} ${CMAKE_SOURCE_DIR}
              --graphviz=${CMAKE_CURRENT_BINARY_DIR}/graphviz/${TARGET}.dot
      COMMAND
        ${DOT_EXECUTABLE} -T${ARGS_OUTPUT_TYPE}
        ${CMAKE_CURRENT_BINARY_DIR}/graphviz/${TARGET}.dot -o
        ${ARGS_OUTPUT_DIR}/${TARGET}.${ARGS_OUTPUT_TYPE})


    add_custom_command( TARGET ${TARGET} POST_BUILD
      COMMAND ;
      COMMENT "Dependency graph for ${TARGET} generated and located at ${ARGS_OUTPUT_DIR}/${TARGET}.${ARGS_OUTPUT_TYPE}"
    )
endmacro()