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

if(CMT_COMPILER_INCLUDED)
	return()
endif()
set(CMT_COMPILER_INCLUDED ON)

include(${CMAKE_CURRENT_LIST_DIR}/cmtools-args.cmake)
include(${CMAKE_CURRENT_LIST_DIR}/cmtools-env.cmake)

include(${CMAKE_CURRENT_LIST_DIR}/./../third_party/ucm.cmake)

# Functions summary:
# - cmt_add_compiler_options
# - cmt_add_c_compiler_options
# - cmt_add_cxx_compiler_options
# - cmt_add_compiler_option
# - cmt_add_c_compiler_option
# - cmt_add_cxx_compiler_option
# - cmt_add_linker_options
# - cmt_add_c_linker_options
# - cmt_add_cxx_linker_options
# - cmt_add_linker_option
# - cmt_add_c_linker_option
# - cmt_add_cxx_linker_option
# - cmt_enable_warnings_as_errors
# - cmt_enable_all_warnings
# - cmt_enable_effective_cxx_warnings
# - cmt_enable_generation_header_dependencies
# - cmt_configure_gcc_compiler_options
# - cmt_configure_clang_compiler_options
# - cmt_configure_msvc_compiler_options
# - cmt_configure_compiler_options

# ! cmt_add_compiler_option Add a flag to the compiler depending on the specific configuration
#
# cmt_add_compiler_option(
#   [LANG <lang>]
#   [COMPILER <compiler>]
#   [CONFIG <config> <config>...]
#   [OPTION <option>]
# )
#
# \paramLANG LANG Language of the flag (C|CXX)
# \paramOPTION OPTION Compiler flag to add
# \groupCONFIG CONFIG Configs for the property to change (Debug Release RelWithDebInfo MinSizeRel)
#
function(cmt_add_compiler_option)
    cmake_parse_arguments(ARGS "" "OPTION;COMPILER;LANG" "CONFIG" ${ARGN})
	cmt_required_arguments(FUNCTION cmt_add_compiler_option PREFIX ARGS FIELDS OPTION)

    if (DEFINED ARGS_COMPILER)
        cmt_define_compiler()
        if (NOT ${CMT_COMPILER} STREQUAL ${ARGS_COMPILER})
            return()
        endif()
    endif()

    if (DEFINED ARGS_LANG)
	    cmt_ensure_lang(${ARGS_LANG})
		set(LANGUAGES ${ARGS_LANG})
	else()
		set(LANGUAGES "CXX" "C")
	endif()

    foreach (lang ${LANGUAGES})
        if(${lang} STREQUAL "C")
            enable_language(C)
            include(CheckCCompilerFlag)
            CHECK_C_COMPILER_FLAG(${ARGS_OPTION} has${ARGS_OPTION})
        elseif(${lang} STREQUAL "CXX")
            enable_language(CXX)
            include(CheckCXXCompilerFlag)
            CHECK_CXX_COMPILER_FLAG(${ARGS_OPTION} has${ARGS_OPTION})
        else()
            message(WARNING "[cmt] Unsuported language: ${lang}, compiler flag ${ARGS_OPTION} not added")
            return()
        endif()

        if(has${ARGS_OPTION})
            if (DEFINED ARGS_CONFIG)
                foreach(__config ${ARGS_CONFIG})
                    ucm_add_flags(${lang} ${ARGS_OPTION} CONFIG ${__config})
                endforeach()
            else()
                ucm_add_flags(${lang} ${ARGS_OPTION})
            endif()
        else()
            message(STATUS "[cmt] Flag \"${ARGS_OPTION}\" was reported as unsupported by ${lang} compiler and was not added")
        endif()
    endforeach()
endfunction()

function(cmt_add_c_compiler_option)
    cmt_add_compile_option(LANG C ${ARGN})
endfunction()

function(cmt_add_cxx_compiler_option)
    cmt_add_compiler_option(LANG CXX ${ARGN})
endfunction()

function(cmt_add_debug_compiler_option)
    cmt_add_compile_option(${ARGN} CONFIG Debug)
endfunction()

function(cmt_add_release_compiler_option)
    cmt_add_compiler_option(${ARGN} CONFIG Release)
endfunction()

# ! cmt_add_compiler_options Add flags to the compiler depending on the specific configuration
#
# cmt_add_compiler_options(
#   [LANG <lang>]
#   [COMPILER <compiler>]
#   [CONFIG <config> <config>...]
#   [OPTIONS <option1> <option2>...]
# )
#
# \paramLANG LANG Language of the flag (C|CXX)
# \groupOPTIONS OPTIONS Compiler flags to add
# \groupCONFIG CONFIG Configs for the property to change (Debug Release RelWithDebInfo MinSizeRel)
#
function(cmt_add_compiler_options)
    cmake_parse_arguments(ARGS "" "LANG;COMPILER" "CONFIG;OPTIONS" ${ARGN})
	cmt_required_arguments(FUNCTION cmt_add_compiler_options PREFIX ARGS FIELDS OPTIONS)

    if (DEFINED ARGS_COMPILER)
        cmt_define_compiler()
        if (NOT ${CMT_COMPILER} STREQUAL ${ARGS_COMPILER})
            return()
        endif()
    endif()

	if (DEFINED ARGS_LANG)
	    cmt_ensure_lang(${ARGS_LANG})
		if (DEFINED ARGS_CONFIG)
			cmt_ensure_config(${ARGS_CONFIG})
			foreach (option ${ARGS_OPTIONS})
				cmt_add_compiler_option(LANG ${ARGS_LANG} CONFIG ${ARGS_CONFIG} OPTION ${option})
			endforeach()
		else()
			foreach (option ${ARGS_OPTIONS})
				cmt_add_compiler_option(LANG ${ARGS_LANG} OPTION ${option})
			endforeach()
		endif()
	else()
		if (DEFINED ARGS_CONFIG)
			cmt_ensure_config(${ARGS_CONFIG})
			foreach (option ${ARGS_OPTIONS})
				cmt_add_compiler_option(CONFIG ${ARGS_CONFIG} OPTION ${option})
			endforeach()
		else()
			foreach (option ${ARGS_OPTIONS})
				cmt_add_compiler_option(OPTION ${option})
			endforeach()
		endif()
	endif()
endfunction()

function(cmt_add_c_compiler_options)
    cmt_add_compiler_options(LANG C ${ARGN})
endfunction()

function(cmt_add_cxx_compiler_options)
    cmt_add_compiler_options(LANG CXX ${ARGN})
endfunction()

function(cmt_add_debug_compiler_options)
    cmt_add_compiler_options(${ARGN} CONFIG Debug)
endfunction()

function(cmt_add_release_compiler_options)
    cmt_add_compiler_options(${ARGN} CONFIG Release)
endfunction()

# ! cmt_add_linker_option Add a flag to the linker depending on the specific configuration
#
# cmt_add_linker_option(
#   [LANG <lang>]
#   [COMPILER <compiler>]
#   [CONFIG <config> <config>...]
#   [OPTION <option>]
# )
#
# \paramLANG LANG Language of the flag (C|CXX)
# \paramOPTION OPTION Linker flag to add
# \groupCONFIG CONFIG Configs for the property to change (Debug Release RelWithDebInfo MinSizeRel)
#
function(cmt_add_linker_option)
    cmake_parse_arguments(ARGS "" "LANG;OPTION;COMPILER" "CONFIG" ${ARGN})
	cmt_required_arguments(FUNCTION cmt_add_compiler_option PREFIX ARGS FIELDS OPTION)

    if (DEFINED ARGS_COMPILER)
        cmt_define_compiler()
        if (NOT ${CMT_COMPILER} STREQUAL ${ARGS_COMPILER})
            return()
        endif()
    endif()

    if (DEFINED ARGS_LANG)
	    cmt_ensure_lang(${ARGS_LANG})
		set(LANGUAGES ${ARGS_LANG})
	else()
		set(LANGUAGES "CXX" "C")
	endif()

    foreach (lang ${LANGUAGES})
        if(${lang} STREQUAL "C")
            enable_language(C)
            include(CheckCCompilerFlag)
            CHECK_C_COMPILER_FLAG(${ARGS_OPTION} has${ARGS_OPTION})
        elseif(${lang} STREQUAL "CXX")
            enable_language(CXX)
            include(CheckCXXCompilerFlag)
            CHECK_CXX_COMPILER_FLAG(${ARGS_OPTION} has${ARGS_OPTION})
        else()
            message(WARNING "[cmt] Unsuported language: ${lang}, linker flag ${ARGS_OPTION} not added")
            return()
        endif()

        if(has${ARGS_OPTION})
            if (DEFINED ARGS_CONFIG)
			    cmt_ensure_config(${ARGS_CONFIG})
                foreach(config ${ARGS_CONFIG})
                    ucm_add_linker_flags(${lang} ${ARGS_OPTION} CONFIG ${config})
                endforeach()
            else()
                ucm_add_linker_flags(${lang} ${ARGS_OPTION})
            endif()
        else()
            message(STATUS "[cmt] Flag \"${ARGS_OPTION}\" was reported as unsupported by ${ARGS_LANG} compiler and was not added")
        endif()
    endforeach()
endfunction()

function(cmt_set_c_linker_option)
    cmt_add_linker_option(LANG C ${ARGN})
endfunction()

function(cmt_set_cxx_linker_option)
    cmt_add_linker_option(LANG CXX ${ARGN})
endfunction()

function(cmt_set_debug_linker_option)
    cmt_add_linker_option(${ARGN} CONFIG Debug)
endfunction()

function(cmt_set_release_linker_option)
    cmt_add_linker_option(${ARGN} CONFIG Release)
endfunction()

# ! cmt_add_linker_options Add flags to the linker depending on the specific configuration
#
# cmt_add_linker_options(
#   [LANG <lang>]
#   [COMPILER <compiler>]
#   [CONFIG <config> <config>...]
#   [OPTIONS <option1> <option2>...]
# )
#
# \paramLANG LANG Language of the flag (C|CXX)
# \groupOPTIONS OPTIONS Linker flags to add
# \groupCONFIG CONFIG Configs for the property to change (Debug Release RelWithDebInfo MinSizeRel)
#
function(cmt_add_linker_options)
    cmake_parse_arguments(ARGS "" "LANG;COMPILER" "CONFIG;OPTIONS" ${ARGN})
	cmt_required_arguments(FUNCTION cmt_add_linker_options PREFIX ARGS FIELDS OPTIONS LANG)
    cmt_choice_arguments(FUNCTION cmt_add_linker_options PREFIX ARGS CHOICE LANG OPTIONS "CXX" "C" )

    if (DEFINED ARGS_COMPILER)
        cmt_define_compiler()
        if (NOT ${CMT_COMPILER} STREQUAL ${ARGS_COMPILER})
            return()
        endif()
    endif()

	if (DEFINED ARGS_LANG)
	    cmt_choice_arguments(FUNCTION cmt_add_linker_options PREFIX ARGS CHOICE LANG OPTIONS "CXX" "C" )
		if (DEFINED ARGS_CONFIG)
			cmt_ensure_config(${ARGS_CONFIG})
			foreach (option ${ARGS_OPTIONS})
				cmt_add_linker_option(LANG ${ARGS_LANG} CONFIG ${ARGS_CONFIG} OPTION ${option})
			endforeach()
		else()
			foreach (option ${ARGS_OPTIONS})
				cmt_add_linker_option(LANG ${ARGS_LANG} OPTION ${option})
			endforeach()
		endif()
	else()
		if (DEFINED ARGS_CONFIG)
			cmt_ensure_config(${ARGS_CONFIG})
			foreach (option ${ARGS_OPTIONS})
				cmt_add_linker_option(CONFIG ${ARGS_CONFIG} OPTION ${option})
			endforeach()
		else()
			foreach (option ${ARGS_OPTIONS})
				cmt_add_linker_option(OPTION ${option})
			endforeach()
		endif()
	endif()
endfunction()

function(cmt_set_c_linker_options)
    cmt_add_linker_options(LANG C ${ARGN})
endfunction()

function(cmt_set_cxx_linker_options)
    cmt_add_linker_options(LANG CXX ${ARGN})
endfunction()

function(cmt_set_debug_linker_options)
    cmt_add_linker_options(${ARGN} CONFIG Debug)
endfunction()

function(cmt_set_release_linker_option)
    cmt_add_linker_options(${ARGN} CONFIG Release)
endfunction()

# ! cmt_set_runtime 
# Set all targets run-time: determine if the targets should be linked statically
# or dynamically to the run-time library.
#
# MSVC infos: https://docs.microsoft.com/en-us/cpp/build/reference/md-mt-ld-use-run-time-library
# GCC infos: https://gcc.gnu.org/onlinedocs/gcc/Link-Options.html
#
# cmt_set_runtime(
#   STATIC | DYNAMIC
# )
#
# \paramSTATIC STATIC If present, set static run-time
# \paramDYNAMIC DYNAMIC If present, set dynamic run-time
function(cmt_set_runtime)
    ucm_set_runtime(${ARGN})
endfunction()

# ! cmt_print_flags Prints all compiler flags for all configurations
#
# cmt_print_flags()
#
function(cmt_print_flags)
    ucm_print_flags()
endfunction()


# ! cmt_enable_all_warnings Enable all warnings for the major compilers in the target
#
# cmt_enable_all_warnings()
#
function(cmt_enable_all_warnings)
    cmt_define_compiler()
    if (CMT_COMPILER MATCHES "CLANG")
        cmt_add_compiler_options(OPTIONS -Wall -Wextra -Wpedantic -Weverything)
    elseif (CMT_COMPILER MATCHES "GNU")
        cmt_add_compiler_options(OPTIONS -Wall -Wextra -Wpedantic)
    elseif (CMT_COMPILER MATCHES "MSVC")
        cmt_add_compiler_options(OPTIONS /W4)
    else()
        message(WARNING "[cmt] Unsupported compiler (${CMAKE_CXX_COMPILER_ID}), warnings not enabled")
    endif()
endfunction()

# ! cmt_enable_effective_cxx_warnings Enable all warnings for the major compilers in the target
#
# cmt_enable_effective_cxx_warnings()
#
function(cmt_enable_effective_cxx_warnings)
    cmt_define_compiler()
    if (${CMT_COMPILER} STREQUAL "CLANG")
        cmt_add_compiler_option(OPTION -Weffc++)
    elseif (${CMT_COMPILER}  STREQUAL "GNU")
        cmt_add_compiler_option(OPTION -Weffc++)
    else()
        message(WARNING "Cannot enable effective c++ check on non gnu/clang compiler.")
    endif()
endfunction()

# ! cmt_disable_warnings Disable warnings for all targets
#
# cmt_disable_warnings()
#
function(cmt_disable_warnings)
	cmt_define_compiler()
	if(NOT (${CMT_COMPILER}  STREQUAL "CLANG" 
			OR ${CMT_COMPILER}  STREQUAL "GCC" 
			OR ${CMT_COMPILER}  STREQUAL "MVSC"))
		message(WARNING "[cmt] Unsupported compiler (${CMAKE_CXX_COMPILER_ID}), warnings not disabled for ${ARGS_TARGET}")
		return()
	endif()

    if (${CMT_COMPILER}  STREQUAL "MVSC")
        cmt_add_compiler_option(OPTION /W0)
    elseif(${CMT_COMPILER}  STREQUAL "GCC")
        cmt_add_compiler_option(OPTION --no-warnings)
    elseif(${CMT_COMPILER}  STREQUAL "CLANG")
        cmt_add_compiler_option(OPTION -Wno-everything)
    endif()
	message(STATUS "[cmt] ${ARGS_TARGET}: disabled warnings")
endfunction()

# ! cmt_enable_warnings_as_errors Treat warnings as errors
#
# cmt_enable_warnings_as_errors()
#
function(cmt_enable_warnings_as_errors)
    cmt_define_compiler()
    if (CMT_COMPILER MATCHES "CLANG")
        cmt_add_compiler_options(OPTIONS -Werror)
    elseif (CMT_COMPILER MATCHES "GNU")
        cmt_add_compiler_options(OPTIONS -Werror)
    elseif (CMT_COMPILER MATCHES "MSVC")
        cmt_add_compiler_options(OPTIONS /WX)
    else()
        message(WARNING "[cmt] Unsupported compiler (${CMAKE_CXX_COMPILER_ID}), warnings not enabled")
    endif()
endfunction()

# ! cmt_enable_generation_header_dependencies Generates .d files with header dependencies
#
# cmt_enable_generation_header_dependencies()
#
function(cmt_enable_generation_header_dependencies)
    cmt_define_compiler()
    if (${CMT_COMPILER}  STREQUAL "CLANG")
        cmt_add_compiler_option(OPTION -MD)
    elseif (${CMT_COMPILER}  STREQUAL "GNU")
        cmt_add_compiler_option(OPTION -MD)
    else()
        message(WARNING "Cannot generate header dependency on non GCC/Clang compilers.")
    endif()
endfunction()


# ! cmt_configure_gcc_compiler_options 
# Configure gcc compile oprions for the target like debug informations, optimisation...
#
# cmt_configure_gcc_compiler_options()
#
function(cmt_configure_gcc_compiler_options)
	cmt_define_compiler()
	if (NOT CMT_COMPILER MATCHES "GCC")
		message(WARNING "cmt_configure_gcc_compiler_options: target ${ARGS_TARGET} is not a gcc target")
		return()
	endif()

	cmt_add_compiler_option(OPTION "-g3" CONFIG Debug RelWithDebInfo)
	cmt_add_compiler_option(OPTION "-O0" CONFIG Debug)
	cmt_add_compiler_option(OPTION "-O2" CONFIG RelWithDebInfo)
	cmt_add_compiler_option(OPTION "-O3" CONFIG Release)
	cmt_add_compile_definition(DEFINITION "NDEBUG" CONFIG Release)
	message(STATUS "[cmt] ${target}: configured gcc options")
endfunction()

# ! cmt_configure_clang_compiler_options 
# Configure clang compile oprions for the target like debug informations, optimisation...
#
# cmt_configure_clang_compiler_options()
#
function(cmt_configure_clang_compiler_options)
	cmt_define_compiler()
	if (NOT CMT_COMPILER MATCHES "CLANG")
		message(WARNING "cmt_configure_clang_compiler_options: target ${ARGS_TARGET} is not a clang target")
		return()
	endif()

	cmt_add_compiler_option(OPTION -g3 CONFIG Debug RelWithDebInfo)
	cmt_add_compiler_option(OPTION -O0 CONFIG Debug)
	cmt_add_compiler_option(OPTION -O2 CONFIG RelWithDebInfo)
	cmt_add_compiler_option(OPTION -O3 CONFIG Release)

    # TODO: implement cmt_add_compile_definition
	# cmt_add_compile_definition(DEFINITION "NDEBUG" CONFIG Release)
	message(STATUS "[cmt] ${target}: configured clang options")
endfunction()

# ! cmt_configure_msvc_compiler_options 
# Configure MVSC compile oprions for the target like debug informations, optimisation...
#
# cmt_configure_msvc_compiler_options()
#
function(cmt_configure_msvc_compiler_options target)
	cmt_define_compiler()
	if (NOT CMT_COMPILER MATCHES "MVSC")
		message(WARNING "cmt_configure_msvc_compiler_options: target ${ARGS_TARGET} is not a msvc target")
		return()
	endif()

	cmt_add_compiler_options(OPTIONS /utf-8 /MP)
	cmt_add_compiler_options(OPTIONS /Zi /DEBUG:FULL CONFIG Debug RelWithDebInfo)
	cmt_add_compiler_options(OPTIONS /Od /RTC1 CONFIG Debug)
	cmt_add_compiler_options(OPTIONS /O2 CONFIG RelWithDebInfo)
	cmt_add_compiler_options(OPTIONS /Ox /Qpar CONFIG Release)
	cmt_add_linker_options(OPTIONS /INCREMENTAL:NO /OPT:REF /OPT:ICF /MANIFEST:NO CONFIG Release RelWithDebInfo)
	cmt_add_compile_definition(DEFINITION NDEBUG CONFIG Release)
	message(STATUS "[cmt] ${target}: configured msvc options")
endfunction()

# ! cmt_configure_compiler_options 
# Configure compile options for the target like debug information, optimisation...
#
# cmt_configure_compiler_options()
#
function(cmt_configure_compiler_options)
	cmt_define_compiler()
	if (CMT_COMPILER MATCHES "MVSC")
		cmt_configure_msvc_compiler_options(${ARGN})
	elseif(CMT_COMPILER MATCHES "GCC")
		cmt_configure_gcc_compiler_options(${ARGN})
	elseif(CMT_COMPILER MATCHES "CLANG")
		cmt_configure_clang_compiler_options(${ARGN})
	else()
		message(WARNING "[cmt] Unsupported compiler (${CMAKE_CXX_COMPILER_ID}), compile options not configured")
	endif()
endfunction()
