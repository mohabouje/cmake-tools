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

cmt_disable_logger()
include(${CMAKE_CURRENT_LIST_DIR}/./../third_party/dependency-graph.cmake)
cmt_enable_logger()

# Functions summary:
# - cmt_project_dependency_graph

# ! cmt_project_dependency_graph Builds a dependency graph of the active code targets using the `dot` application
#
# cmt_project_dependency_graph(
#   [OUTPUT_DIR <output>] # Default: ${CMAKE_CURRENT_BINARY_DIR} 
# )
#
# \param:OUTPUT_DIR OUTPUT_DIR The output directory where the generated files will be stored.
#
macro(cmt_project_dependency_graph)
    cmake_parse_arguments(_PDG_ARGS "" "OUTPUT_DIR" "" ${ARGN})
    cmt_default_argument(FUNCTION cmt_generate_project_dependency_graph PREFIX _PDG_ARGS FIELDS OUTPUT VALUE ${CMAKE_CURRENT_BINARY_DIR})
    if (CMT_ENABLE_DEPENDENCY_GRAPH)
        set(BUILD_DEP_GRAPH ON)
        cmt_find_program(NAME DOT_PROGRAM PROGRAM dot)
        gen_dep_graph("png" TARGET_NAME dependency-graph-${PROJECT_NAME}  OUTPUT_DIR ${_PDG_ARGS_OUTPUT_DIR} ADD_TO_DEP_GRAPH)
        cmt_log("Generating a dependency graph for the project ${PROJECT_NAME}")
    endif()
endmacro()