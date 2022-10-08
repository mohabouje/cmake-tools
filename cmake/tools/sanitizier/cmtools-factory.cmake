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

# ! cmt_enable_sanitizer
# Generates a new target that compiles with different sanitizers
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
# cmt_enable_sanitizer(
#   <ASAN> <TSAN> <LSAN> <UBSAN> <MSAN> ...
# )
#
# \group CONFIG Configs for the property to change (Debug Release RelWithDebInfo MinSizeRel)
# \option One or more of the sanitizers listed above
#
function(cmt_enable_sanitizer)
    cmt_parse_arguments(ARGS "${CMT_SANITIZER_AVAILABLE}" "" "CONFIG" ${ARGN})

    if (NOT CMT_ENABLE_SANITIZER)
        return()
    endif()

    cmt_forward_arguments(ARGS "${CMT_SANITIZER_AVAILABLE}" "" "CONFIG" COLLECT_ARGS)
    cmt_sanitizer_collect_flags(COMPILER_FLAGS ${COLLECT_ARGS})

    cmt_forward_arguments(ARGS "" "" "CONFIG" FLAG_ARGS)
    foreach(FLAG ${COMPILER_FLAGS})
        cmt_add_compiler_options(${FLAG} ${FLAG_ARGS})
        cmt_add_linker_options(${FLAG} ${FLAG_ARGS})
    endforeach()
endfunction()

# ! cmt_target_enable_sanitizer
# Generates a new target that compiles with different sanitizers
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
#   TARGET
# )
#
# \input TARGET Target to add flag
# \group CONFIG Configs for the property to change (Debug Release RelWithDebInfo MinSizeRel)
# \option One or more of the sanitizers listed above
#
function(cmt_target_enable_sanitizer TARGET)
    cmt_parse_arguments(ARGS "${CMT_SANITIZER_AVAILABLE}" "" "CONFIG" ${ARGN})
    cmt_ensure_target(${TARGET})

    if (NOT CMT_ENABLE_SANITIZER)
        return()
    endif()

    cmt_forward_arguments(ARGS "${CMT_SANITIZER_AVAILABLE}" "" "CONFIG" COLLECT_ARGS)
    cmt_sanitizer_collect_flags(COMPILER_FLAGS ${COLLECT_ARGS})

    cmt_forward_arguments(ARGS "" "" "CONFIG" FLAG_ARGS)
    foreach(FLAG ${COMPILER_FLAGS})
        cmt_target_add_compiler_options(${TARGET} ${FLAG} ${FLAG_ARGS})
        cmt_target_add_linker_options(${TARGET} ${FLAG} ${FLAG_ARGS})
    endforeach()
endfunction()

# ! cmt_target_generate_sanitizer
# Generates a new target that compiles with different sanitizers
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
# cmt_target_generate_sanitizer(
#   <ASAN> <TSAN> <LSAN> <UBSAN> <MSAN> ...
#   TARGET
# )
#
# \input TARGET Target to add flag
# \group CONFIG Configs for the property to change (Debug Release RelWithDebInfo MinSizeRel)
# \option One or more of the sanitizers listed above
#
function(cmt_target_generate_sanitizer TARGET)
    cmt_parse_arguments(ARGS "ALL;DEFAULT;${CMT_SANITIZER_AVAILABLE}" "SUFFIX;GLOBAL" "CONFIG" ${ARGN})
    cmt_default_argument(ARGS SUFFIX "sanitizer")
    cmt_default_argument(ARGS GLOBAL "sanitizer")
    cmt_ensure_target(${TARGET})

    if (NOT CMT_ENABLE_SANITIZER)
        return()
    endif()

    set(TARGET_NAME ${TARGET}_${ARGS_SUFFIX})
    cmt_target_create_mirror(${TARGET} ${ARGS_SUFFIX})

    cmt_forward_arguments(ARGS "${CMT_SANITIZER_AVAILABLE}" "" "CONFIG" SANITIZER_FORWARD_ARGS)
    cmt_target_enable_sanitizer(${TARGET_NAME} ${SANITIZER_FORWARD_ARGS})

    cmt_forward_arguments(ARGS "ALL;DEFAULT" "" "" REGISTER_ARGS)
    cmt_target_register_in_group(${TARGET_NAME} ${ARGS_GLOBAL} ${REGISTER_ARGS})
endfunction()