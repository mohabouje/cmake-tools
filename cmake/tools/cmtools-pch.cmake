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
include(${CMAKE_CURRENT_LIST_DIR}/./../third_party/cmake-precompiled-header/PrecompiledHeader.cmake)
cmt_enable_logger()

# Functions summary:
# - cmt_target_add_precompiled_headers

# ! cmt_target_add_precompiled_headers 
# Adds precompiled headers to the target.
#
# cmt_target_add_precompiled_headers(
#   <FORCEINCLUDE>
#   TARGET
#   [HEADERS <header1> <header2> ...]
# )
#
# \input TARGET The target to configure
# \group HEADERS The list of headers to include
# \option FORCEINCLUDE Force the inclusion of the headers
#
function(cmt_target_add_precompiled_headers TARGET)
    cmake_parse_arguments(ARGS "FORCEINCLUDE" "" "HEADERS" ${ARGN})
    cmt_required_arguments(ARGS "" "" "HEADERS")
    cmt_ensure_targets(${TARGET}) 

    if (NOT CMT_ENABLE_PCH)
        return()
    endif()

    cmt_forward_options(ARGS "FORCEINCLUDE" "" "" ADD_PRECOMPILED_HEADER)
    foreach (HEADER ${ARGS_HEADERS})
        add_precompiled_header(${TARGET} ${HEADER} ${ADD_PRECOMPILED_HEADER})
    endforeach()
endfunction()