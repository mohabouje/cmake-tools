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
include(${CMAKE_CURRENT_LIST_DIR}/./../third_party/iwyu.cmake)
cmt_enable_logger()

# Functions summary:
# - cmt_target_generate_iwyu
# - cmt_target_enable_iwyu

# ! cmt_target_generate_iwyu\
# Generate a include-what-you-use target for the target.
# The generated target lanch include-what-you-use on all the target sources in the specified working directory.
#
# cmt_target_generate_iwyu(
#   TARGET
# )
#
# \input TARGET The target to generate the include-what-you-use target for.
#
function(cmt_target_generate_iwyu TARGET)
    cmt_ensure_target(${TARGET})

    if (NOT CMT_ENABLE_IWYU)
        return()
    endif()

    cmt_find_program(IWYU_PROGRAM include-what-you-use ALIAS iwyu)
    iwyu(TARGET ${TARGET})
    cmt_log("Target ${TARGET}: generate target to run include-what-you-use")
endfunction()


# ! cmt_target_enable_iwyu
# Enable include-what-you-use checks on the given target
#
# cmt_target_use_iwyu(
#   <target>
# )
#
# \input TARGET The target to configure
#
function(cmt_target_enable_iwyu TARGET)
    cmt_ensure_target(${TARGET})

    if (NOT CMT_ENABLE_IWYU)
        return()
    endif()

    cmt_find_program(IWYU_PROGRAM include-what-you-use ALIAS iwyu)
    set_property(TARGET ${TARGET} PROPERTY CMAKE_CXX_INCLUDE_WHAT_YOU_USE ${IWYU_PROGRAM})
    set_property(TARGET ${TARGET} PROPERTY CMAKE_C_INCLUDE_WHAT_YOU_USE ${IWYU_PROGRAM})
    cmt_log("Target ${TARGET}: enabling extension include-what-you-use")
endfunction()