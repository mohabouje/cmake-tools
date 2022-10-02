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

include(${CMAKE_CURRENT_LIST_DIR}/cmtools-clang-format.cmake)
include(${CMAKE_CURRENT_LIST_DIR}/cmtools-clang-tidy.cmake)
include(${CMAKE_CURRENT_LIST_DIR}/cmtools-iwyu.cmake)
include(${CMAKE_CURRENT_LIST_DIR}/cmtools-lizard.cmake)
include(${CMAKE_CURRENT_LIST_DIR}/cmtools-codechecker.cmake)
include(${CMAKE_CURRENT_LIST_DIR}/cmtools-cppcheck.cmake)
include(${CMAKE_CURRENT_LIST_DIR}/cmtools-cpplint.cmake)

function (cmt_target_enable_static_analysis TARGET)
    cmake_parse_arguments (CHECKS "" "" "TOOLS" ${ARGN})
    cmt_required_arguments(CHECKS "" "" "TOOLS")
    cmt_ensure_target(TARGET ${TARGET})

    set(SUPPORTED_TOOLS "cppcheck" "clang-tidy" "iwyu" "cpplint" "ccache" "lizard" "codechecker")
    foreach (TOOL ${CHECKS_TOOLS})
        string(TOUPPER ${TOOL} TOOL)
        string(REGEX REPLACE "-" "_" TOOL ${TOOL})
        if (TOOL STREQUAL "CPPCHECK")
            cmt_target_enable_cppcheck(${TARGET})
        elseif (TOOL STREQUAL "CPPLINT")
            cmt_target_enable_cpplint(${TARGET})
        elseif (TOOL STREQUAL "CLANG_TIDY")
            cmt_target_enable_clang_tidy(${TARGET})
        elseif (TOOL STREQUAL "IWYU")
            cmt_target_enable_iwyu(${TARGET})
        elseif (TOOL STREQUAL "CCACHE")
            cmt_target_enable_ccache(${TARGET})
        elseif (TOOL STREQUAL "CODECHECKER")
            cmt_target_enable_codechecker(${TARGET})
        elseif (TOOL STREQUAL "LIZARD")
            cmt_target_enable_lizard(${TARGET})
        else()
            message(FATAL_ERROR "Unknown tool ${TOOL}")
        endif()
    endforeach ()
endfunction ()