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
# - cmt_target_enable_sanitizer
# - cmt_target_enable_address_sanitizer
# - cmt_target_enable_leak_sanitizer
# - cmt_target_enable_thread_sanitizer
# - cmt_target_enable_memory_sanitizer
# - cmt_target_enable_ub_sanitizer
# - cmt_target_enable_cti_sanitizer
# - cmt_target_enable_mto_sanitizer

set(CMT_SANITIZER_AVAILABLE "ASAN;TSAN;LSAN;UBSAN;MSAN;CFISAN;AUBSAN;MWOSAN")

## cmt_target_enable_sanitizers
# Collect a set of flags to enable sanitizers
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
# cmt_target_enable_sanitizer(
#   <ASAN> <TSAN> <LSAN> <UBSAN> <MSAN> ...
#   SANITIZER_FLAGS
#   [CONFIG <config1> <config2>...]
# )
#
# \output SANITIZER_FLAGS Set of flags to add to the compiler and linker to enable sanitizers
# \group CONFIG Configs for the property to change (Debug Release RelWithDebInfo MinSizeRel)
# \option One or more of the sanitizers listed above
#
function(cmt_sanitizer_collect_flags SANITIZER_FLAGS)
 	cmt_parse_arguments(ARGS "${CMT_SANITIZER_AVAILABLE}" "" "" ${ARGN})
	cmt_ensure_one_of_argument(ARGS ${CMT_SANITIZER_AVAILABLE})

	if (NOT CMT_ENABLE_SANITIZER)
		return()
	endif()

	# Incompatibilities documented at:
	# https://gcc.gnu.org/onlinedocs/gcc/Instrumentation-Options.html#Instrumentation-Options

	if (ARGS_TSAN AND ARGS_ASAN)
		cmt_fatal("ThreadSanitizer and AddressSanitizer cannot be combined")
	endif()

	if (ARGS_TSAN AND ARGS_LSAN)
		cmt_fatal("ThreadSanitizer and LeakSanitizer cannot be combined")
	endif()

	cmt_define_compiler()
	if (NOT (${CMT_COMPILER}  STREQUAL "CLANG"  OR ${CMT_COMPILER}  STREQUAL "GCC"))
		cmt_warning("Sanitizers supported only by gcc and clang")
		return()
	endif()


	set(COMPILER_FLAGS)
	if (ARGS_ASAN)
		list(APPEND COMPILER_FLAGS -fsanitize=address)
		list(APPEND COMPILER_FLAGS -fno-omit-frame-pointer)
		list(APPEND COMPILER_FLAGS -fno-optimize-sibling-calls)
	endif()

	if (ARGS_TSAN)
		list(APPEND COMPILER_FLAGS -fsanitize=thread)
	endif()

	if (ARGS_LSAN)
		list(APPEND COMPILER_FLAGS -fsanitize=leak)
	endif()

	if (ARGS_UBSAN AND ${CMT_COMPILER}  STREQUAL "GCC")
		list(APPEND COMPILER_FLAGS -fsanitize=undefined)
		list(APPEND COMPILER_FLAGS -fsanitize=nullability)
	endif()

	if (ARGS_AUBSAN AND ${CMT_COMPILER}  STREQUAL "GCC")
		list(APPEND COMPILER_FLAGS -fsanitize=undefined)
		list(APPEND COMPILER_FLAGS -fsanitize=nullability)
		list(APPEND COMPILER_FLAGS -fsanitize=address)
		list(APPEND COMPILER_FLAGS -fno-omit-frame-pointer)
		list(APPEND COMPILER_FLAGS -fno-optimize-sibling-calls)
	endif()
	
	if (ARGS_MSAN AND ${CMT_COMPILER}  STREQUAL "CLANG")
		list(APPEND COMPILER_FLAGS -fsanitize=memory)
	endif()

	if (ARGS_MWOSAN AND ${CMT_COMPILER}  STREQUAL "CLANG")
		list(APPEND COMPILER_FLAGS -fsanitize=memory)
		list(APPEND COMPILER_FLAGS -fsanitize-memory-track-origins)
	endif()

	if (ARGS_CFISAN)
		list(APPEND COMPILER_FLAGS -fsanitize=cfi)
	endif()

	set(SANITIZER_FLAGS ${COMPILER_FLAGS} PARENT_SCOPE)
endfunction()