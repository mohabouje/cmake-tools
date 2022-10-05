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
# cmt_ensure_target(TARGET)
#
# \input TARGET Target to check
#
function(cmt_ensure_target TARGET)
    if(NOT TARGET ${TARGET})
        cmt_fatal("${TARGET} is not a valid target.")
    endif()
endfunction()

# ! cmt_ensure_not_target
# Checks if the list of targets exist and throw an error if it does
#
# cmt_ensure_target(TARGET)
#
# \input TARGET Target to check
#
function(cmt_ensure_not_target TARGET)
    if(TARGET ${TARGET})
        cmt_fatal("${TARGET} already exist.")
    endif()
endfunction()

#! cmt_ensure_config
# Checks if the configuration is valid
#
# The following variables are checked:
# - Debug
# - Release
# - RelWithDebInfo
# - MinSizeRel
#
# cmt_ensure_config(BUILD_TYPE)
#
# \input BUILD_TYPE The build type to check
#
function(cmt_ensure_config BUILD_TYPE)
    cmt_ensure_choice(BUILD_TYPE Debug Release RelWithDebInfo MinSizeRel)
endfunction()

#! cmt_ensure_lang Checks if the language is valid
#
# The following variables are checked:
# - C
# - CXX
#
# cmt_ensure_lang(LANGUAGE)
#
# \input LANGUAGE The language to check
function(cmt_ensure_lang LANGUAGE)
    cmt_ensure_choice(LANGUAGE C CXX)
endfunction()