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

if(CMTOOLS_COTIRE_INCLUDED)
	return()
endif()
set(CMTOOLS_COTIRE_INCLUDED ON)

include(${CMAKE_CURRENT_LIST_DIR}/./../utility/cmtools-args.cmake)
include(${CMAKE_CURRENT_LIST_DIR}/./../utility/cmtools-env.cmake)
include(${CMAKE_CURRENT_LIST_DIR}/./../third_party/cotire.cmake)

# Functions summary:
# - cmtools_target_enable_cotire

# ! cmtools_target_enable_cotire Enable cotire compilation boost on the given target
#
# cmtools_target_enable_cotire(
#   [TARGET <target>]
# )
#
# \param:TARGET TARGET The target to configure
#
function(cmtools_target_enable_cotire)
    cmake_parse_arguments(ARGS "" "TARGET" "" ${ARGN})
    cmtools_required_arguments(FUNCTION cmtools_target_generate_cotire PREFIX ARGS FIELDS TARGET)
    cmtools_ensure_targets(FUNCTION cmtools_target_generate_cotire TARGETS ${ARGS_TARGET}) 
    cotire(${ARGS_TARGET})
    message(STATUS "[cmtools] Target ${ARGS_TARGET}: enabled cotire")
endfunction()

