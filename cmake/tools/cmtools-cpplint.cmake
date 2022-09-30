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

# ! cmt_target_enable_cpplint
# Enable include-what-you-use checks on the given target
#
# cmt_target_enable_cpplint(
#   TARGET
# )
#
# \input TARGET The target to enable the cpplint checks
#
function(cmt_target_enable_cpplint TARGET)
    cmt_ensure_target(${ARGS_TARGET})

    if (NOT CMT_ENABLE_CPPLINT)
        return()
    endif()

    cmt_find_program(CPPLINT_PROGRAM cpplint)
    set_property(TARGET ${TARGET} PROPERTY CMAKE_CXX_CPPLINT ${CPPLINT_PROGRAM})
    set_property(TARGET ${TARGET} PROPERTY CMAKE_C_CPPLINT ${CPPLINT_PROGRAM})
    cmt_log("Target ${TARGET}: enabling extension cpplint")
endfunction()