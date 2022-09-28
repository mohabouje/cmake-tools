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

if(CMTOOLS_COVERAGE_INCLUDED)
	return()
endif()
set(CMTOOLS_COVERAGE_INCLUDED ON)

include(${CMAKE_CURRENT_LIST_DIR}/./../utility/cmtools-args.cmake)
include(${CMAKE_CURRENT_LIST_DIR}/./../utility/cmtools-env.cmake)

set(MESSAGE_QUIET ON)
include(${CMAKE_CURRENT_LIST_DIR}/./../third_party/coverage.cmake)
unset(MESSAGE_QUIET)

# Functions summary:
# - cmtools_target_generate_coverage
# - cmtools_project_coverage

# ! cmtools_target_generate_coverage Generate a code coverage report for the target.
# The generated target lanch lcov on all the target sources in the specified working directory.
#
# cmtools_target_generate_coverage(
#   [TARGET <target>]
# )
#
# \param:TARGET TARGET The target to configure
#
function(cmtools_target_generate_coverage)
    cmake_parse_arguments(ARGS "" "TARGET" "DEPENDENCIES" ${ARGN})
    cmtools_required_arguments(FUNCTION cmtools_target_generate_coverage PREFIX ARGS FIELDS TARGET DEPENDENCIES)

    if (NOT CMTOOLS_ENABLE_COVERAGE)
        return()
    endif()

    set(CODE_COVERAGE ON)
    target_code_coverage(${ARGS_TARGET} OBJECTS ${ARGS_DEPENDENCIES} AUTO ALL)
    message(STATUS "[cmtools] Target ${ARGS_TARGET}: generating coverage for dependencies: ${ARGS_DEPENDENCIES}")
endfunction()


# ! cmtools_project_coverage Generate code coverage for all the targets.
#
function(cmtools_project_coverage)
    if (NOT CMTOOLS_ENABLE_COVERAGE)
        return()
    endif()

    set(CODE_COVERAGE ON)
    add_code_coverage_all_targets()
     message(STATUS "[cmtools] Generating a code-coverage report for the project ${PROJECT_NAME}")
endfunction()
