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

if(CMTOOLS_CPPLINT_INCLUDED)
	return()
endif()
set(CMTOOLS_CPPLINT_INCLUDED ON)

include(${CMAKE_CURRENT_LIST_DIR}/./../utility/cmtools-args.cmake)
include(${CMAKE_CURRENT_LIST_DIR}/./../utility/cmtools-env.cmake)

# ! cmtools_target_enable_cpplint Enable include-what-you-use checks on the given target
#
# cmtools_target_enable_cpplint(
#   [TARGET <target>]
# )
#
# \param:TARGET TARGET The target to configure
#
function(cmtools_target_enable_cpplint)
    cmake_parse_arguments(ARGS "" "TARGET" "" ${ARGN})
    cmtools_required_arguments(FUNCTION cmtools_target_enable_cpplint PREFIX ARGS FIELDS TARGET)
    cmtools_ensure_targets(FUNCTION cmtools_target_enable_cpplint TARGETS ${ARGS_TARGET}) 

    if (NOT CMTOOLS_ENABLE_CPPLINT)
        return()
    endif()

    cmtools_find_program(NAME CPPLINT_PROGRAM PROGRAM cpplint)
    set_property(TARGET ${ARGS_TARGET} PROPERTY CMAKE_CXX_CPPLINT ${CPPLINT_PROGRAM})
    set_property(TARGET ${ARGS_TARGET} PROPERTY CMAKE_C_CPPLINT ${CPPLINT_PROGRAM})
    message(STATUS "[cmtools] Target ${ARGS_TARGET}: enabling extension cpplint")
endfunction()