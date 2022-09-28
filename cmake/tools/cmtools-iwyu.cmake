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

if(CMTOOLS_IWYU_INCLUDED)
	return()
endif()
set(CMTOOLS_IWYU_INCLUDED ON)

include(${CMAKE_CURRENT_LIST_DIR}/./../utility/cmtools-args.cmake)
include(${CMAKE_CURRENT_LIST_DIR}/./../utility/cmtools-env.cmake)

set(MESSAGE_QUIET ON)
include(${CMAKE_CURRENT_LIST_DIR}/./../third_party/iwyu.cmake)
unset(MESSAGE_QUIET)

# Functions summary:
# - cmtools_target_generate_iwyu
# - cmtools_target_enable_iwyu

# ! cmtools_target_generate_iwyu Generate a include-what-you-use target for the target.
# The generated target lanch include-what-you-use on all the target sources in the specified working directory.
#
# cmtools_target_generate_iwyu(
#   [TARGET <target>]
# )
#
# \param:TARGET TARGET The target to configure
#
function(cmtools_target_generate_iwyu)
    cmake_parse_arguments(ARGS "" "TARGET" "" ${ARGN})
    cmtools_required_arguments(FUNCTION cmtools_target_generate_iwyu PREFIX ARGS FIELDS TARGET)

    if (NOT CMTOOLS_ENABLE_IWYU)
        return()
    endif()

    cmtools_find_program(NAME IWYU_PROGRAM PROGRAM include-what-you-use ALIAS iwyu)
    iwyu(TARGET ${ARGS_TARGET})
    message(STATUS "[cmtools] Target ${ARGS_TARGET}: generate target to run include-what-you-use")
endfunction()


# ! cmtools_target_enable_iwyu Enable include-what-you-use checks on the given target
#
# cmtools_target_use_iwyu(
#   [TARGET <target>]
# )
#
# \param:TARGET TARGET The target to configure
#
function(cmtools_target_enable_iwyu)
    cmake_parse_arguments(ARGS "" "TARGET" "" ${ARGN})
    cmtools_required_arguments(FUNCTION cmtools_target_use_iwyu PREFIX ARGS FIELDS TARGET)
    cmtools_ensure_targets(FUNCTION cmtools_target_use_iwyu TARGETS ${ARGS_TARGET}) 

    if (NOT CMTOOLS_ENABLE_IWYU)
        return()
    endif()

    cmtools_find_program(NAME IWYU_PROGRAM PROGRAM include-what-you-use ALIAS iwyu)
    set_property(TARGET ${ARGS_TARGET} PROPERTY CMAKE_CXX_INCLUDE_WHAT_YOU_USE ${IWYU_PROGRAM})
    set_property(TARGET ${ARGS_TARGET} PROPERTY CMAKE_C_INCLUDE_WHAT_YOU_USE ${IWYU_PROGRAM})
    message(STATUS "[cmtools] Target ${ARGS_TARGET}: enabling extension include-what-you-use")
endfunction()