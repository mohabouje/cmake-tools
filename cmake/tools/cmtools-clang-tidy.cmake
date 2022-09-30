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
include(${CMAKE_CURRENT_LIST_DIR}/./../third_party/clang-tidy.cmake)
cmt_enable_logger()

# Functions summary:
# - cmt_target_generate_clang_tidy
# - cmt_target_enable_clang_tidy

# ! cmt_target_generate_clang_tidy
# Generate a clang-tidy target for the target.
# The generated target lanch clang-tidy on all the target sources in the specified working directory.
#
# cmt_target_generate_clang_tidy(
#   TARGET
# )
#
# \input TARGET The target to generate the clang-tidy target for.
#
function(cmt_target_generate_clang_tidy TARGET)
    cmt_ensure_target(${TARGET})    
    
    if (NOT CMT_ENABLE_CLANG_TIDY)
        return()
    endif()

    
    cmt_find_program(CLANG_TIDY_PROGRAM clang-tidy)
    clang_tidy(TARGET ${TARGET})
    cmt_log("Target ${TARGET}: generate target to run clang-tidy")
endfunction()


# ! cmt_target_enable_clang_tidy
# Enable clang-tidy checks on the given target
#
# cmt_target_use_clang_tidy(
#   TARGET
# )
#
# \input TARGET The target to enable clang-tidy checks for.
#
function(cmt_target_enable_clang_tidy TARGET)
    cmt_ensure_target(${TARGET})

    if (NOT CMT_ENABLE_CLANG_TIDY)
        return()
    endif()

    cmt_find_program(CLANG_TIDY_PROGRAM clang-tidy)
    set_property(TARGET ${TARGET} PROPERTY CMAKE_CXX_INCLUDE_CLANG_TIDY ${CLANG_TIDY_PROGRAM})
    set_property(TARGET ${TARGET} PROPERTY CMAKE_C_INCLUDE_CLANG_TIDY ${CLANG_TIDY_PROGRAM})
    cmt_log("Target ${TARGET}: enabling extension clang-tidy")
endfunction()