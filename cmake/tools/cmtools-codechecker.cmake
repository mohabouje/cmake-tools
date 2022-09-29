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

if(CMT_CODECHECKER_INCLUDED)
	return()
endif()
set(CMT_CODECHECKER_INCLUDED ON)

include(${CMAKE_CURRENT_LIST_DIR}/./../utility/cmtools-args.cmake)
include(${CMAKE_CURRENT_LIST_DIR}/./../utility/cmtools-env.cmake)

set(MESSAGE_QUIET ON)
include(${CMAKE_CURRENT_LIST_DIR}/./../third_party/codechecker.cmake)
unset(MESSAGE_QUIET)

# Functions summary:
# - cmt_target_generate_codechecker

# ! cmt_target_generate_codechecker Generate a codechecker target for the target.
# The generated target lanch codechecker on all the target sources in the specified working directory.
#
# cmt_target_generate_codechecker(
#   [TARGET <target>]
# )
#
# \param:TARGET TARGET The target to configure
#
function(cmt_target_generate_codechecker)
    cmake_parse_arguments(ARGS "" "TARGET" "" ${ARGN})
    cmt_required_arguments(FUNCTION cmt_target_generate_codechecker PREFIX ARGS FIELDS TARGET)

    if (NOT CMT_ENABLE_CODECHECKER)
        return()
    endif()

    cmt_find_program(NAME CODECHECKER_PROGRAM PROGRAM codechecker)
    codechecker(TARGET ${ARGS_TARGET})
    message(STATUS "[cmt] Target ${ARGS_TARGET}: generate target to run codechecker")
endfunction()