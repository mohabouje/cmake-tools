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
include(${CMAKE_CURRENT_LIST_DIR}/./../third_party/coverage.cmake)
cmt_enable_logger()

# Functions summary:
# - cmt_target_generate_coverage
# - cmt_project_coverage

# ! cmt_target_generate_coverage
# Generate a code coverage report for the target.
# The generated target lanch lcov on all the target sources in the specified working directory.
#
# cmt_target_generate_coverage(
#   TARGET
#   [DEPENDENCIES dependencies...]
# )
#
# \input TARGET The target to generate the coverage report for.
# \group DEPENDENCIES The dependencies of the target.
#
function(cmt_target_generate_coverage TARGET)
    cmake_parse_arguments(ARGS "" "" "DEPENDENCIES" ${ARGN})

    if (NOT CMT_ENABLE_COVERAGE)
        return()
    endif()

    set(CODE_COVERAGE ON)
    target_code_coverage(${TARGET} OBJECTS ${ARGS_DEPENDENCIES} AUTO ALL)
    cmt_log("Target ${TARGET}: generating coverage for dependencies: ${ARGS_DEPENDENCIES}")
endfunction()


# ! cmt_project_coverage
# Generate code coverage for all the targets.
#
macro(cmt_project_coverage)
    if (CMT_ENABLE_COVERAGE)
        set(CODE_COVERAGE ON)
        add_code_coverage_all_targets()
        cmt_log("Generating a code-coverage report for the project ${PROJECT_NAME}")
    endif()
endmacro()
