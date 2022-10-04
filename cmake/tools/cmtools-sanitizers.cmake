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

include(${CMAKE_CURRENT_LIST_DIR}/./../modules/cmtools-args.cmake)
include(${CMAKE_CURRENT_LIST_DIR}/./../modules/cmtools-env.cmake)

# Functions summary:
# - cmt_target_enable_sanitizer
# - cmt_target_enable_address_sanitizer
# - cmt_target_enable_leak_sanitizer
# - cmt_target_enable_thread_sanitizer
# - cmt_target_enable_memory_sanitizer
# - cmt_target_enable_ub_sanitizer
# - cmt_target_enable_cti_sanitizer
# - cmt_target_enable_mto_sanitizer


## cmt_target_enable_sanitizers
# Enable the specified sanitizers in the specified build modes for the specified target on compilers
# that support the sanitizers.
# Incompatibilities: ThreadSanitizer cannot be combined with AddressSanitizer and LeakSanitizer
# Value -> sanitizer correspondence:
# - ASAN:   AddressSanitizer
# - TSAN:  	ThreadSanitizer
# - LSAN:	LeakSanitizer
# - UBSAN:	UndefinedBehaviorSanitizer
# - MSAN: 	MemorySanitizer
# - AUBSAN: AddressSanitizer + UndefinedBehaviorSanitizer
# - MWOSAN: Memory-Track-Origins + MemorySanitizer
# - CFISAN:	Control-Flow Integrity
# 
# cmt_target_add_linker_option(
#   <ASAN> <TSAN> <LSAN> <UBSAN> <MSAN> ...
#   TARGET
#   [CONFIG <config1> <config2>...]
# )
#
# \input TARGET Target to add flag
# \group CONFIG Configs for the property to change (Debug Release RelWithDebInfo MinSizeRel)
# \option One or more of the sanitizers listed above
#
function(cmt_target_enable_sanitizer TARGET)
 	cmt_parse_arguments(ARGS "ASAN;TSAN;LSAN;UBSAN;MSAN;CFISAN;AUBSAN;MWOSAN" "" "CONFIG" ${ARGN})
	cmt_ensure_on_of_argument(ARGS ASAN TSAN LSAN UBSAN MSAN AUBSAN MWOSAN CFISAN)

	# Incompatibilities documented at:
	# https://gcc.gnu.org/onlinedocs/gcc/Instrumentation-Options.html#Instrumentation-Options
	if (ARGS_TSAN AND ARGS_ASAN)
		cmt_fatal("ThreadSanitizer and AddressSanitizer cannot be combined")
	endif()
	if (ARGS_TSAN AND ARGS_LSAN)
		cmt_fatal("ThreadSanitizer and LeakSanitizer cannot be combined")
	endif()

	cmt_define_compiler()
	if (NOT (${CMT_COMPILER}  STREQUAL "CLANG" 
			OR ${CMT_COMPILER}  STREQUAL "GCC"))
		# Sanitizers supported only by gcc and clang
		return()
	endif()


	set(flags)
	if (ARGS_ASAN)
		list(APPEND flags "-fsanitize=address")
		list(APPEND flags "-fno-omit-frame-pointer")
		list(APPEND flags "-fno-optimize-sibling-calls")
	endif()

	if (ARGS_TSAN)
		list(APPEND flags "-fsanitize=thread")
	endif()

	if (ARGS_LSAN)
		list(APPEND flags "-fsanitize=leak")
	endif()

	if (ARGS_UBSAN AND ${CMT_COMPILER}  STREQUAL "GCC")
		list(APPEND flags "-fsanitize=undefined")
		list(APPEND flags "-fsanitize=nullability")
	endif()

	if (ARGS_AUBSAN AND ${CMT_COMPILER}  STREQUAL "GCC")
		list(APPEND flags "-fsanitize=undefined")
		list(APPEND flags "-fsanitize=nullability")
		list(APPEND flags "-fsanitize=address")
		list(APPEND flags "-fno-omit-frame-pointer")
		list(APPEND flags "-fno-optimize-sibling-calls")
	endif()
	
	if (ARGS_MSAN AND ${CMT_COMPILER}  STREQUAL "CLANG")
		list(APPEND flags "-fsanitize=memory")
	endif()

	if (ARGS_MWOSAN AND ${CMT_COMPILER}  STREQUAL "CLANG")
		list(APPEND flags "-fsanitize=memory")
		list(APPEND flags "-fsanitize-memory-track-origins")
	endif()

	if (ARGS_CFISAN)
		list(APPEND flags "-fsanitize=cfi")
	endif()

	foreach(flag ${flags})
		foreach(lang IN ITEMS C CXX)
			if(DEFINED ARGS_CONFIG)
				cmt_target_add_compiler_options(${TARGET} ${flag} CONFIG ${ARGS_CONFIG})
				cmt_target_add_linker_options(${TARGET} ${flag} CONFIG ${ARGS_CONFIG})
			else()
				cmt_target_add_compiler_options(${TARGET} ${flag})
				cmt_target_add_linker_options(${TARGET} ${flag})
			endif()
		endforeach()
	endforeach()
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
    cmt_target_enable_sanitizer(${TARGET} ASAN)
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
    cmt_target_enable_sanitizer(${TARGET} MSAN)
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
    cmt_target_enable_sanitizer(${TARGET} TSAN)
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
    cmt_target_enable_sanitizer(${TARGET} UBSAN)
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
    cmt_target_enable_sanitizer(${TARGET} CFISAN)
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
    cmt_target_enable_sanitizer(${TARGET} LISAN)
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
    cmt_target_enable_sanitizer(${TARGET} MWOSAN)
endfunction()