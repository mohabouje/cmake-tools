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

if(CMT_CPPCHECK_INCLUDED)
	return()
endif()
set(CMT_CPPCHECK_INCLUDED ON)

include(${CMAKE_CURRENT_LIST_DIR}/./../utility/cmtools-args.cmake)
include(${CMAKE_CURRENT_LIST_DIR}/./../utility/cmtools-env.cmake)

set(MESSAGE_QUIET ON)
include(${CMAKE_CURRENT_LIST_DIR}/./../third_party/cppcheck.cmake)
unset(MESSAGE_QUIET)

# Functions summary:
# - cmt_target_generate_cppcheck

# ! cmt_target_generate_cppcheck Generate a cppcheck target for the target.
# The generated target lanch cppcheck on all the target sources in the specified working directory.
#
# cmt_target_generate_cppcheck(
#   [TARGET <target>]
# )
#
# \param:TARGET TARGET The target to configure
#
function(cmt_target_generate_cppcheck)
    cmake_parse_arguments(ARGS "" "TARGET" "" ${ARGN})
    cmt_required_arguments(FUNCTION cmt_target_generate_cppcheck PREFIX ARGS FIELDS TARGET)

    if (NOT CMT_ENABLE_CPPCHECK)
        return()
    endif()

    cmt_find_program(NAME CPPCHECK_PROGRAM PROGRAM cppcheck)
    cppcheck(TARGET ${ARGS_TARGET})
    message(STATUS "[cmt] Target ${ARGS_TARGET}: generate target to run cppcheck")
endfunction()


# ! cmt_target_enable_cppcheck Enable include-what-you-use checks on the given target
#
# cmt_target_enable_cppcheck(
#   [TARGET <target>]
# )
#
# \param:TARGET TARGET The target to configure
#
function(cmt_target_enable_cppcheck)
    cmake_parse_arguments(ARGS "" "TARGET" "" ${ARGN})
    cmt_required_arguments(FUNCTION cmt_target_enable_cppcheck PREFIX ARGS FIELDS TARGET)
    cmt_ensure_targets(FUNCTION cmt_target_enable_cppcheck TARGETS ${ARGS_TARGET}) 

    if (NOT CMT_ENABLE_CPPCHECK)
        return()
    endif()

    cmt_find_program(NAME CPPCHECK_PROGRAM PROGRAM cppcheck)
    set_property(TARGET ${ARGS_TARGET} PROPERTY CMAKE_CXX_CPPCHECK ${CPPCHECK_PROGRAM})
    set_property(TARGET ${ARGS_TARGET} PROPERTY CMAKE_C_CPPCHECK ${CPPCHECK_PROGRAM})
    message(STATUS "[cmt] Target ${ARGS_TARGET}: enabling extension cppcheck")
endfunction()