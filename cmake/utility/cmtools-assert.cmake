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

include(${CMAKE_CURRENT_LIST_DIR}/cmtools-logger.cmake)

# Functions summary:
# - cmt_ensure_choice
# - cmt_ensure_target


# ! cmt_ensure_choice
# This function check if the variable contain one of the choices
#
# cmt_ensure_choice(
#   VARIABLE
#   [OPTIONS option, ...]
# )
#
# \input VARIABLE The variable to check
# \group OPTIONS List of choices
#
function(cmt_ensure_choice VARIABLE)
    cmt_parse_arguments (ARGS "" "" "" ${ARGN})
    foreach(arg ${ARGS_UNPARSED_ARGUMENTS})
        if (${VARIABLE} STREQUAL ${arg})
            return()
        endif()
    endforeach()
    cmt_fatal("Argument ${${VARIABLE}} is not one of the following choices: ${ARGS_UNPARSED_ARGUMENTS}")
endfunction()


# ! cmt_ensure_target : Checks if the list of targets exist and are valid
#
# cmt_ensure_target(
#   TARGET
# )
#
# \input TARGET Target to check
#
function(cmt_ensure_target TARGET)
    if(NOT TARGET ${TARGET})
        cmt_fatal("${TARGET} is not a valid target.")
    endif()
endfunction()