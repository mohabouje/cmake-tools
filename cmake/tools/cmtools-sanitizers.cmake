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
include(${CMAKE_CURRENT_LIST_DIR}/./../third_party/sanitizers.cmake)
cmt_enable_logger()

# Functions summary:
# - cmt_target_enable_sanitizers
# - cmt_target_enable_address_sanitizer
# - cmt_target_enable_leak_sanitizer
# - cmt_target_enable_thread_sanitizer
# - cmt_target_enable_memory_sanitizer
# - cmt_target_enable_ub_sanitizer
# - cmt_target_enable_cti_sanitizer
# - cmt_target_enable_mto_sanitizer

# ! cmt_target_enable_sanitizers
# Enable sanitiziers checks on the given target
# The supported sanitizers are:
# - ASAN
# - AUBSAN
# - CFISAN
# - LSAN
# - MSAN
# - MWOSAN
# - TSAN
# - UBSAN
#
# cmt_target_use_sanitizers(
#   TARGET
#   [SANITIZER <sanitizer>]
# )
#
# \input TARGET The target to enable the sanitizers
# \param SANITIZER The sanitizer to enable.
#
function(cmt_target_enable_sanitizer TARGET)
    cmake_parse_arguments(ARGS "" "SANITIZER" "" ${ARGN})
    cmt_required_arguments(ARGS "" "SANITIZER" "")
    cmt_ensure_argument_choice(ARGS SANITIZER OPTIONS "ASAN" "AUBSAN" "CFISAN" "LSAN" "MSAN" "MWOSAN" "TSAN" "UBSAN")
    cmt_ensure_target(${TARGET})

    if (NOT CMT_ENABLE_SANITIZERS)
        return()
    endif()

    set(SANITIZER ${ARGS_SANITIZER})
    enable_sanitizers(TARGET ${TARGET})
    cmt_log("Target ${TARGET}: enabling extension ${SANITIZER} sanitizer")
endfunction()

# ! cmt_target_enable_address_sanitizer
# Enable memory-sanitizier checks on the given target
#
# cmt_target_enable_address_sanitizer(
#   TARGET
# )
#
# \input TARGET The target to enable the sanitizers
#
function(cmt_target_enable_address_sanitizer TARGET)
    cmt_target_enable_sanitizer(${TARGET} SANITIZER "ASAN")
endfunction()

# ! cmt_target_enable_memory_sanitizer Enable address-sanitizier checks on the given target
#
# cmt_target_enable_memory_sanitizer(
#   TARGET
# )
#
# \input TARGET The target to enable the sanitizers
#
function(cmt_target_enable_memory_sanitizer TARGET)
    cmt_target_enable_sanitizer(${TARGET} SANITIZER "MSAN")
endfunction()

# ! cmt_target_enable_thread_sanitizer Enable thread-sanitizier checks on the given target
#
# cmt_target_enable_thread_sanitizer(
#   TARGET
# )
#
# \input TARGET The target to enable the sanitizers
#
function(cmt_target_enable_thread_sanitizer TARGET)
    cmt_target_enable_sanitizer(${TARGET} SANITIZER "TSAN")
endfunction()

# ! cmt_target_enable_thread_sanitizer Enable undefined-behavior sanitizer checks on the given target
#
# cmt_target_enable_ub_sanitizer(
#   TARGET
# )
#
# \input TARGET The target to enable the sanitizers
#
function(cmt_target_enable_ub_sanitizer TARGET)
    cmt_target_enable_sanitizer(${TARGET} SANITIZER "UBSAN")
endfunction()

# ! cmt_target_enable_cfi_sanitizer Enable control-flow-integrity sanitizer checks on the given target
#
# cmt_target_enable_cfi_sanitizer(
#   TARGET
# )
#
# \input TARGET The target to enable the sanitizers
#
function(cmt_target_enable_cfi_sanitizer)
    cmt_target_enable_sanitizer(${TARGET} SANITIZER "CFISAN")
endfunction()

# ! cmt_target_enable_leak_sanitizer Enable leak sanitizer checks on the given target
#
# cmt_target_enable_leak_sanitizer(
#   TARGET
# )
#
# \input TARGET The target to enable the sanitizers
#
function(cmt_target_enable_leak_sanitizer TARGET)
    cmt_target_enable_sanitizer(${TARGET} SANITIZER "LISAN")
endfunction()

# ! cmt_target_enable_mto_sanitizer Enable memory-track-origin sanitizer checks on the given target
#
# cmt_target_enable_mto_sanitizer(
#   TARGET
# )
#
# \input TARGET The target to enable the sanitizers
#
function(cmt_target_enable_mto_sanitizer TARGET)
    cmt_target_enable_sanitizer(${TARGET} SANITIZER "MWOSAN")
endfunction()