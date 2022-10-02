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

include(CheckIPOSupported)

# Functions summary:
# - cmt_enable_lto
# - cmt_target_enable_lto

# !cmt_enable_lto
# Checks for, and enables IPO/LTO for all following targets
#
# WARNING: Running with GCC seems to have no effect
#
# \option REQUIRED - If this is passed in, CMake configuration will fail with an error if LTO/IPO is not supported
#
macro(cmt_enable_lto)
    cmake_parse_arguments(LTO "REQUIRED" "" "" ${ARGN})
    check_ipo_supported(RESULT RESULT OUTPUT OUTPUT)
    if (RESULT)
        set(CMAKE_INTERPROCEDURAL_OPTIMIZATION ON)
    else()
        if(DEFINED LTO_REQUIRED)
            cmt_fatal("LTO not supported, but listed as REQUIRED: ${OUTPUT}")
        else()
            cmt_warn("LTO not supported: ${OUTPUT}")
        endif()
    endif()
endmacro()

# ! cmt_target_enable_lto
# Checks for, and enables IPO/LTO for the specified target
#
# cmt_target_enable_lto(
#   TARGET
# )
#
# \input TARGET The target to enable link-time-optimization
# \option REQUIRED - If this is passed in, CMake configuration will fail with an error if LTO/IPO is not supported
#
function(cmt_target_enable_lto TARGET)
    cmake_parse_arguments(LTO "REQUIRED" "" "" ${ARGN})
    cmt_ensure_target(${TARGET})
    check_ipo_supported(RESULT RESULT OUTPUT OUTPUT)
    if (RESULT)
        set_property(TARGET ${TARGET} PROPERTY INTERPROCEDURAL_OPTIMIZATION ON)
    else()
        if(DEFINED  LTO_REQUIRED)
            cmt_fatal("LTO not supported, but listed as REQUIRED: ${OUTPUT}")
        else()
            cmt_warn("LTO not supported: ${OUTPUT}")
        endif()
    endif()
endfunction()


