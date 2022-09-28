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

if(CMTOOLS_SANITIZERS_INCLUDED)
	return()
endif()
set(CMTOOLS_SANITIZERS_INCLUDED ON)

include(${CMAKE_CURRENT_LIST_DIR}/./../utility/cmtools-args.cmake)
include(${CMAKE_CURRENT_LIST_DIR}/./../utility/cmtools-env.cmake)

set(MESSAGE_QUIET ON)
include(${CMAKE_CURRENT_LIST_DIR}/./../third_party/sanitizers.cmake)
unset(MESSAGE_QUIET)

# Functions summary:
# - cmtools_target_enable_sanitizers
# - cmtools_target_enable_address_sanitizer
# - cmtools_target_enable_leak_sanitizer
# - cmtools_target_enable_thread_sanitizer
# - cmtools_target_enable_memory_sanitizer
# - cmtools_target_enable_ub_sanitizer
# - cmtools_target_enable_cti_sanitizer
# - cmtools_target_enable_mto_sanitizer

# ! cmtools_target_enable_sanitizers Enable sanitiziers checks on the given target
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
# cmtools_target_use_sanitizers(
#   [TARGET <target>]
#   [SANITIZER <sanitizer>]
# )
#
# \param:TARGET TARGET The target to configure
#
function(cmtools_target_enable_sanitizer)
    cmake_parse_arguments(ARGS "" "TARGET;SANITIZER" "" ${ARGN})
    cmtools_required_arguments(FUNCTION cmtools_target_use_sanitizers PREFIX ARGS FIELDS TARGET SANITIZER)
    cmtools_choice_arguments(FUNCTION cmtools_target_use_sanitizers PREFIX ARGS CHOICE SANITIZER OPTIONS "ASAN" "AUBSAN" "CFISAN" "LSAN" "MSAN" "MWOSAN" "TSAN" "UBSAN")
    cmtools_ensure_targets(FUNCTION cmtools_target_use_sanitizers TARGETS ${ARGS_TARGET})

    if (NOT CMTOOLS_ENABLE_SANITIZERS)
        return()
    endif()

    set(SANITIZER ${ARGS_SANITIZER})
    enable_sanitizers(TARGET ${ARGS_TARGET})
    message(STATUS "[cmtools] Target ${ARGS_TARGET}: enabling extension ${SANITIZER} sanitizer")
endfunction()

# ! cmtools_target_enable_address_sanitizer Enable memory-sanitizier checks on the given target
#
# cmtools_target_enable_address_sanitizer(
#   [TARGET <target>]
# )
#
# \param:TARGET TARGET The target to configure
#
function(cmtools_target_enable_address_sanitizer)
    cmake_parse_arguments(ARGS "" "TARGET" "" ${ARGN})
    cmtools_required_arguments(FUNCTION cmtools_target_use_sanitizers PREFIX ARGS FIELDS TARGET)
    cmtools_target_enable_sanitizer(TARGET ${ARGS_TARGET} SANITIZER "ASAN")
endfunction()

# ! cmtools_target_enable_memory_sanitizer Enable address-sanitizier checks on the given target
#
# cmtools_target_enable_memory_sanitizer(
#   [TARGET <target>]
# )
#
# \param:TARGET TARGET The target to configure
#
function(cmtools_target_enable_memory_sanitizer)
    cmake_parse_arguments(ARGS "" "TARGET" "" ${ARGN})
    cmtools_required_arguments(FUNCTION cmtools_target_use_sanitizers PREFIX ARGS FIELDS TARGET)
    cmtools_target_enable_sanitizer(TARGET ${ARGS_TARGET} SANITIZER "MSAN")
endfunction()

# ! cmtools_target_enable_thread_sanitizer Enable thread-sanitizier checks on the given target
#
# cmtools_target_enable_thread_sanitizer(
#   [TARGET <target>]
# )
#
# \param:TARGET TARGET The target to configure
#
function(cmtools_target_enable_thread_sanitizer)
    cmake_parse_arguments(ARGS "" "TARGET" "" ${ARGN})
    cmtools_required_arguments(FUNCTION cmtools_target_use_sanitizers PREFIX ARGS FIELDS TARGET)
    cmtools_target_enable_sanitizer(TARGET ${ARGS_TARGET} SANITIZER "TSAN")
endfunction()

# ! cmtools_target_enable_thread_sanitizer Enable undefined-behavior sanitizer checks on the given target
#
# cmtools_target_enable_ub_sanitizer(
#   [TARGET <target>]
# )
#
# \param:TARGET TARGET The target to configure
#
function(cmtools_target_enable_ub_sanitizer)
    cmake_parse_arguments(ARGS "" "TARGET" "" ${ARGN})
    cmtools_required_arguments(FUNCTION cmtools_target_use_sanitizers PREFIX ARGS FIELDS TARGET)
    cmtools_target_enable_sanitizer(TARGET ${ARGS_TARGET} SANITIZER "UBSAN")
endfunction()

# ! cmtools_target_enable_cfi_sanitizer Enable control-flow-integrity sanitizer checks on the given target
#
# cmtools_target_enable_cfi_sanitizer(
#   [TARGET <target>]
# )
#
# \param:TARGET TARGET The target to configure
#
function(cmtools_target_enable_cfi_sanitizer)
    cmake_parse_arguments(ARGS "" "TARGET" "" ${ARGN})
    cmtools_required_arguments(FUNCTION cmtools_target_use_sanitizers PREFIX ARGS FIELDS TARGET)
    cmtools_target_enable_sanitizer(TARGET ${ARGS_TARGET} SANITIZER "CFISAN")
endfunction()

# ! cmtools_target_enable_leak_sanitizer Enable leak sanitizer checks on the given target
#
# cmtools_target_enable_leak_sanitizer(
#   [TARGET <target>]
# )
#
# \param:TARGET TARGET The target to configure
#
function(cmtools_target_enable_leak_sanitizer)
    cmake_parse_arguments(ARGS "" "TARGET" "" ${ARGN})
    cmtools_required_arguments(FUNCTION cmtools_target_use_sanitizers PREFIX ARGS FIELDS TARGET)
    cmtools_target_enable_sanitizer(TARGET ${ARGS_TARGET} SANITIZER "LISAN")
endfunction()

# ! cmtools_target_enable_mto_sanitizer Enable memory-track-origin sanitizer checks on the given target
#
# cmtools_target_enable_mto_sanitizer(
#   [TARGET <target>]
# )
#
# \param:TARGET TARGET The target to configure
#
function(cmtools_target_enable_mto_sanitizer)
    cmake_parse_arguments(ARGS "" "TARGET" "" ${ARGN})
    cmtools_required_arguments(FUNCTION cmtools_target_use_sanitizers PREFIX ARGS FIELDS TARGET)
    cmtools_target_enable_sanitizer(TARGET ${ARGS_TARGET} SANITIZER "MWOSAN")
endfunction()