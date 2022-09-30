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

include(${CMAKE_CURRENT_LIST_DIR}/cmtools-args.cmake)
include(${CMAKE_CURRENT_LIST_DIR}/cmtools-env.cmake)

cmt_disable_logger()
include(${CMAKE_CURRENT_LIST_DIR}/./../third_party/ucm.cmake)
cmt_enable_logger()

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

function(cmt_check_compiler_option RESULT)
    cmake_parse_arguments(ARGS "" "OPTION;LANG" "" ${ARGN})
	cmt_required_arguments(ARGS "" "OPTION;LANG" "")
    if(${ARGS_LANG} STREQUAL "C")
        enable_language(C)
        include(CheckCCompilerFlag)
        cmt_disable_logger()
        CHECK_C_COMPILER_FLAG(${ARGS_OPTION} RESULT)
        cmt_enable_logger()
    elseif(${ARGS_LANG} STREQUAL "CXX")
        enable_language(CXX)
        include(CheckCXXCompilerFlag)
        cmt_disable_logger()
        CHECK_CXX_COMPILER_FLAG(${ARGS_OPTION} RESULT)
        cmt_enable_logger()
    else()
        cmt_warn("Unsuported language: ${ARGS_LANG}, compiler flag ${ARGS_OPTION} not added")
    endif()
    if (NOT CMT_ENABLE_COMPILER_OPTION_CHECKS)
        set(${RESULT} ON PARENT_SCOPE)
    endif()
    set(${RESULT} ${RESULT} PARENT_SCOPE)
endfunction()

function(cmt_check_linker_option RESULT)
    cmake_parse_arguments(ARGS "" "OPTION;LANG" "" ${ARGN})
	cmt_required_arguments(ARGS "" "OPTION;LANG" "")
    if(${ARGS_LANG} STREQUAL "C")
        enable_language(C)
        include(CheckLinkerFlag)
        cmt_disable_logger()
        CHECK_LINKER_FLAG(C ${ARGS_OPTION} ${RESULT})
        cmt_enable_logger()
    elseif(${ARGS_LANG} STREQUAL "CXX")
        enable_language(CXX)
        include(CheckLinkerFlag)
        cmt_disable_logger()
        CHECK_LINKER_FLAG(CXX ${ARGS_OPTION} ${RESULT})
        cmt_enable_logger()
    else()
        cmt_warn("Unsuported language: ${ARGS_LANG}, compiler flag ${ARGS_OPTION} not added")
    endif()
    if (NOT CMT_ENABLE_LINKER_OPTION_CHECKS)
        set(${RESULT} ON PARENT_SCOPE)
    endif()
    set(${RESULT} ${RESULT} PARENT_SCOPE)
endfunction()

# ! cmt_add_compiler_option
# Add a flag to the compiler depending on the specific configuration
#
# cmt_add_compiler_option(
#   OPTION
#   [LANG <lang>]
#   [COMPILER <compiler>]
#   [CONFIG <config> <config>...]
# )
#
# \input OPTION Linker flag to add
# \param LANG Language of the flag (C|CXX)
# \param COMPILER Compiler to add the flags to
# \group CONFIG Configs for the property to change (Debug Release RelWithDebInfo MinSizeRel)
#
macro(cmt_add_compiler_option OPTION)
    cmake_parse_arguments(ARGS "" "COMPILER;LANG" "CONFIG" ${ARGN})
	
    macro(cmt_add_compiler_option_check_)
        if (DEFINED ARGS_LANG)
            cmt_ensure_lang(${ARGS_LANG})
            set(LANGUAGES ${ARGS_LANG})
        else()
            set(LANGUAGES "CXX" "C")
        endif()

        foreach (lang ${LANGUAGES})
            cmt_check_compiler_option(has${OPTION} OPTION ${OPTION} LANG ${lang})
            if(has${OPTION})
                if (DEFINED ARGS_CONFIG)
                    foreach(config ${ARGS_CONFIG})
                        cmt_ensure_config(${config})
                        ucm_add_flags(${lang} ${OPTION} CONFIG ${config})
                    endforeach()
                else()
                    ucm_add_flags(${lang} ${OPTION})
                endif()
            else()
                cmt_log("Flag ${OPTION} was reported as unsupported by ${lang} compiler and was not added")
            endif()
        endforeach()
    endmacro()

    if (DEFINED ARGS_COMPILER)
        cmt_define_compiler()
        if (${CMT_COMPILER} STREQUAL ${ARGS_COMPILER})
            cmt_add_compiler_option_check_()
        endif()
    else()
        cmt_add_compiler_option_check_()
    endif()

endmacro()

macro(cmt_add_c_compiler_option OPTION)
    cmt_add_compile_option(${OPTION} ${ARGN} LANG C)
endmacro()

macro(cmt_add_cxx_compiler_option OPTION)
    cmt_add_compiler_option(${OPTION} ${ARGN} LANG CXX)
endmacro()

macro(cmt_add_debug_compiler_option OPTION)
    cmt_add_compiler_option(${OPTION} ${ARGN} CONFIG Debug)
endmacro()

macro(cmt_add_release_compiler_option OPTION)
    cmt_add_compiler_option(${OPTION} ${ARGN} CONFIG Release)
endmacro()

# ! cmt_add_compiler_options
# Add flags to the compiler depending on the specific configuration
#
# cmt_add_compiler_options(
#   <option1> <option2>...
#   [LANG <lang>]
#   [COMPILER <compiler>]
#   [CONFIG <config> <config>...]
# )
#
# \input OPTIONS Compiler flags to add
# \param LANG LANG Language of the flag (C|CXX)
# \param COMPILER Compiler to add the flags to
# \group CONFIG Configs for the property to change (Debug Release RelWithDebInfo MinSizeRel)
#
macro(cmt_add_compiler_options)
    cmake_parse_arguments(ARGS "" "COMPILER;LANG" "CONFIG" ${ARGN})

    # TODO: use arguments forwarding instead of so many ifdefs

    set(ARGS_OPTIONS ${ARGS_UNPARSED_ARGUMENTS})
    macro(cmt_add_compiler_options_check_)
        if (DEFINED ARGS_LANG)
            cmt_ensure_lang(${ARGS_LANG})
            if (DEFINED ARGS_CONFIG)
                foreach (option ${ARGS_OPTIONS})
                    cmt_add_compiler_option(${option} LANG ${ARGS_LANG} CONFIG ${ARGS_CONFIG})
                endforeach()
            else()
                foreach (option ${ARGS_OPTIONS})
                    cmt_add_compiler_option(${option} LANG ${ARGS_LANG})
                endforeach()
            endif()
        else()
            if (DEFINED ARGS_CONFIG)
                foreach (option ${ARGS_OPTIONS})
                    cmt_add_compiler_option(${option} CONFIG ${ARGS_CONFIG})
                endforeach()
            else()
                foreach (option ${ARGS_OPTIONS})
                    cmt_add_compiler_option(${option})
                endforeach()
            endif()
        endif()
    endmacro()

    if (DEFINED ARGS_COMPILER)
        cmt_define_compiler()
        if (${CMT_COMPILER} STREQUAL ${ARGS_COMPILER})
            cmt_add_compiler_options_check_()
        endif()
    else()
        cmt_add_compiler_options_check_()
    endif()
endmacro()

macro(cmt_add_c_compiler_options)
    cmt_add_compiler_options(${ARGN} LANG C)
endmacro()

macro(cmt_add_cxx_compiler_options)
    cmt_add_compiler_options(${ARGN} LANG CXX)
endmacro()

macro(cmt_add_debug_compiler_options)
    cmt_add_compiler_options(${ARGN} CONFIG Debug)
endmacro()

macro(cmt_add_release_compiler_options)
    cmt_add_compiler_options(${ARGN} CONFIG Release)
endmacro()

# ! cmt_add_linker_option
# Add a flag to the linker depending on the specific configuration
#
# cmt_add_linker_option(
#   OPTION
#   [LANG <lang>]
#   [COMPILER <compiler>]
#   [CONFIG <config> <config>...]
# )
#
# \input OPTION Linker flag to add
# \param LANG Language of the flag (C|CXX)
# \param COMPILER Compiler to add the flags to
# \group CONFIG Configs for the property to change (Debug Release RelWithDebInfo MinSizeRel)
#
macro(cmt_add_linker_option OPTION)
    cmake_parse_arguments(ARGS "" "COMPILER;LANG" "CONFIG" ${ARGN})

    macro(cmt_add_linker_option_check_)
        if (DEFINED ARGS_LANG)
            cmt_ensure_lang(${ARGS_LANG})
            set(LANGUAGES ${ARGS_LANG})
        else()
            set(LANGUAGES "CXX" "C")
        endif()

        foreach (lang ${LANGUAGES})
            cmt_check_linker_option(has${OPTION} OPTION ${OPTION} LANG ${lang})
            if(has${OPTION})
                if (DEFINED ARGS_CONFIG)
                    foreach(config ${ARGS_CONFIG})
                        cmt_ensure_config(${config})
                        ucm_add_linker_flags(${lang} ${OPTION} CONFIG ${config})
                    endforeach()
                else()
                    ucm_add_linker_flags(${lang} ${OPTION})
                endif()
            else()
                cmt_log("Flag ${OPTION} was reported as unsupported by ${ARGS_LANG} linker and was not added")
            endif()
        endforeach()
    endmacro()


    if (DEFINED ARGS_COMPILER)
        cmt_define_compiler()
        if (${CMT_COMPILER} STREQUAL ${ARGS_COMPILER})
            cmt_add_linker_option_check_()
        endif()
    else()
        cmt_add_linker_option_check_()
    endif()

endmacro()

macro(cmt_set_c_linker_option OPTION)
    cmt_add_linker_option(${OPTION} ${ARGN} LANG C)
endmacro()

macro(cmt_set_cxx_linker_option OPTION)
    cmt_add_linker_option(${OPTION} ${ARGN} LANG CXX)
endmacro()

macro(cmt_set_debug_linker_option OPTION)
    cmt_add_linker_option(${OPTION} ${ARGN} CONFIG Debug)
endmacro()

macro(cmt_set_release_linker_option OPTION)
    cmt_add_linker_option(${OPTION} ${ARGN} CONFIG Release)
endmacro()

# ! cmt_add_linker_options Add flags to the linker depending on the specific configuration
#
# cmt_add_linker_options(
#   <option1> <option2>...
#   [LANG <lang>]
#   [COMPILER <compiler>]
#   [CONFIG <config> <config>...]
# )
#
# \input OPTIONS Linker flags to add
# \param LANG Language of the flag (C|CXX)
# \param COMPILER Compiler to add the flags to
# \group CONFIG Configs for the property to change (Debug Release RelWithDebInfo MinSizeRel)
#
macro(cmt_add_linker_options)
    cmake_parse_arguments(ARGS "" "LANG;COMPILER" "CONFIG" ${ARGN})

    # TODO: use arguments forwarding instead of so many ifdefs
    set(ARGS_OPTIONS ${ARGS_UNPARSED_ARGUMENTS})
    macro(cmt_add_linker_options_check_)
        if (DEFINED ARGS_LANG)
            cmt_ensure_argument_choice(FUNCTION cmt_add_linker_options PREFIX ARGS CHOICE LANG OPTIONS "CXX" "C" )
            if (DEFINED ARGS_CONFIG)
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
                foreach (option ${ARGS_OPTIONS})
                    cmt_add_linker_option(CONFIG ${ARGS_CONFIG} OPTION ${option})
                endforeach()
            else()
                foreach (option ${ARGS_OPTIONS})
                    cmt_add_linker_option(${option})
                endforeach()
            endif()
        endif()
    endmacro()


    if (DEFINED ARGS_COMPILER)
        cmt_define_compiler()
        if (${CMT_COMPILER} STREQUAL ${ARGS_COMPILER})
            cmt_add_linker_options_check_()
        endif()
    else()
        cmt_add_linker_options_check_()
    endif()
endmacro()

macro(cmt_set_c_linker_options)
    cmt_add_linker_options(LANG C ${ARGN})
endmacro()

macro(cmt_set_cxx_linker_options)
    cmt_add_linker_options(LANG CXX ${ARGN})
endmacro()

macro(cmt_set_debug_linker_options)
    cmt_add_linker_options(${ARGN} CONFIG Debug)
endmacro()

macro(cmt_set_release_linker_option)
    cmt_add_linker_options(${ARGN} CONFIG Release)
endmacro()

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
macro(cmt_set_runtime)
    ucm_set_runtime(${ARGN})
endmacro()

# ! cmt_enable_all_warnings Enable all warnings for the major compilers in the target
#
# cmt_enable_all_warnings()
#
macro(cmt_enable_all_warnings)
    cmt_define_compiler()
    if (CMT_COMPILER MATCHES "CLANG")
        cmt_add_compiler_options(-Wall -Wextra -Wpedantic -Weverything)
    elseif (CMT_COMPILER MATCHES "GNU")
        cmt_add_compiler_options(-Wall -Wextra -Wpedantic)
    elseif (CMT_COMPILER MATCHES "MSVC")
        cmt_add_compiler_options(/W4)
    else()
        cmt_warn("Unsupported compiler (${CMAKE_CXX_COMPILER_ID}), warnings not enabled")
    endif()
endmacro()

# ! cmt_enable_effective_cxx_warnings Enable all warnings for the major compilers in the target
#
# cmt_enable_effective_cxx_warnings()
#
macro(cmt_enable_effective_cxx_warnings)
    cmt_define_compiler()
    if (${CMT_COMPILER} STREQUAL "CLANG")
        cmt_add_compiler_option(-Weffc++)
    elseif (${CMT_COMPILER}  STREQUAL "GNU")
        cmt_add_compiler_option(-Weffc++)
    else()
        cmt_warn("Cannot enable effective c++ check on non gnu/clang compiler.")
    endif()
endmacro()

# ! cmt_disable_warnings Disable warnings for all targets
#
# cmt_disable_warnings()
#
macro(cmt_disable_warnings)
	cmt_define_compiler()
    if (${CMT_COMPILER}  STREQUAL "MVSC")
        cmt_add_compiler_option(/W0)
    	cmt_log("${ARGS_TARGET}: mvsc disabled warnings")
    elseif(${CMT_COMPILER}  STREQUAL "GCC")
        cmt_add_compiler_option(--no-warnings)
    	cmt_log("${ARGS_TARGET}: gcc disabled warnings")
    elseif(${CMT_COMPILER}  STREQUAL "CLANG")
        cmt_add_compiler_option(-Wno-everything)
    	cmt_log("${ARGS_TARGET}: clang disabled warnings")
    else()
		cmt_warn("Unsupported compiler (${CMAKE_CXX_COMPILER_ID}), warnings not disabled for ${ARGS_TARGET}")
    endif()
endmacro()

# ! cmt_enable_warnings_as_errors Treat warnings as errors
#
# cmt_enable_warnings_as_errors()
#
macro(cmt_enable_warnings_as_errors)
    cmt_define_compiler()
    if (CMT_COMPILER MATCHES "CLANG")
        cmt_add_compiler_options(-Werror)
    elseif (CMT_COMPILER MATCHES "GNU")
        cmt_add_compiler_options(-Werror)
    elseif (CMT_COMPILER MATCHES "MSVC")
        cmt_add_compiler_options(/WX)
    else()
        cmt_warn("Unsupported compiler (${CMAKE_CXX_COMPILER_ID}), warnings not enabled")
    endif()
endmacro()

# ! cmt_enable_generation_header_dependencies Generates .d files with header dependencies
#
# cmt_enable_generation_header_dependencies()
#
macro(cmt_enable_generation_header_dependencies)
    cmt_define_compiler()
    if (${CMT_COMPILER}  STREQUAL "CLANG")
        cmt_add_compiler_option(-MD)
    elseif (${CMT_COMPILER}  STREQUAL "GNU")
        cmt_add_compiler_option(-MD)
    else()
        cmt_warn("Cannot generate header dependency on non GCC/Clang compilers.")
    endif()
endmacro()


# ! cmt_configure_gcc_compiler_options 
# Configure gcc compile oprions for the target like debug informations, optimisation...
#
# cmt_configure_gcc_compiler_options()
#
macro(cmt_configure_gcc_compiler_options)
	cmt_define_compiler()
	if (CMT_COMPILER MATCHES "GCC")
		cmt_add_compiler_option("-g3" CONFIG Debug RelWithDebInfo)
        cmt_add_compiler_option("-O0" CONFIG Debug)
        cmt_add_compiler_option("-O2" CONFIG RelWithDebInfo)
        cmt_add_compiler_option("-O3" CONFIG Release)
        # TODO: implement cmt_add_compile_definition
        # cmt_add_compile_definition(DEFINITION "NDEBUG" CONFIG Release)
        cmt_log("Configured gcc options for all targets")	
    else()
        cmt_warn("cmt_configure_gcc_compiler_options: target ${ARGS_TARGET} is not a gcc target")
    endif()
endmacro()

# ! cmt_configure_clang_compiler_options 
# Configure clang compile oprions for the target like debug informations, optimisation...
#
# cmt_configure_clang_compiler_options()
#
macro(cmt_configure_clang_compiler_options)
	cmt_define_compiler()
	if (CMT_COMPILER MATCHES "CLANG")
        cmt_add_compiler_option(-g3 CONFIG Debug RelWithDebInfo)
        cmt_add_compiler_option(-O0 CONFIG Debug)
        cmt_add_compiler_option(-O2 CONFIG RelWithDebInfo)
        cmt_add_compiler_option(-O3 CONFIG Release)

        # TODO: implement cmt_add_compile_definition
        # cmt_add_compile_definition(DEFINITION "NDEBUG" CONFIG Release)
        cmt_log("Configured clang options for all targets")
    else()
		cmt_warn("cmt_configure_clang_compiler_options: target ${ARGS_TARGET} is not a clang target")
    endif()
endmacro()

# ! cmt_configure_msvc_compiler_options 
# Configure MVSC compile oprions for the target like debug informations, optimisation...
#
# cmt_configure_msvc_compiler_options()
#
macro(cmt_configure_msvc_compiler_options target)
	cmt_define_compiler()
	if (NOT CMT_COMPILER MATCHES "MVSC")
        cmt_add_compiler_options(/utf-8 /MP)
        cmt_add_compiler_options(/Zi /DEBUG:FULL CONFIG Debug RelWithDebInfo)
        cmt_add_compiler_options(/Od /RTC1 CONFIG Debug)
        cmt_add_compiler_options(/O2 CONFIG RelWithDebInfo)
        cmt_add_compiler_options(/Ox /Qpar CONFIG Release)
        cmt_add_linker_options(/INCREMENTAL:NO /OPT:REF /OPT:ICF /MANIFEST:NO CONFIG Release RelWithDebInfo)
        # TODO: implement cmt_add_compile_definition
        # cmt_add_compile_definition(DEFINITION "NDEBUG" CONFIG Release)
	    cmt_log("Configured mvsc options for all targets")
    else()
		cmt_warn("cmt_configure_msvc_compiler_options: target ${ARGS_TARGET} is not a msvc target")
		return()
	endif()
endmacro()

# ! cmt_configure_compiler_options 
# Configure compile options for all targets like debug information, optimisation...
#
# cmt_configure_compiler_options()
#
macro(cmt_configure_compiler_options)
	cmt_define_compiler()
	if (CMT_COMPILER MATCHES "MVSC")
		cmt_configure_msvc_compiler_options(${ARGN})
	elseif(CMT_COMPILER MATCHES "GCC")
		cmt_configure_gcc_compiler_options(${ARGN})
	elseif(CMT_COMPILER MATCHES "CLANG")
		cmt_configure_clang_compiler_options(${ARGN})
	else()
		cmt_warn("Unsupported compiler (${CMAKE_CXX_COMPILER_ID}), compile options not configured")
	endif()
endmacro()

# ! cmt_print_compiler_options 
# Prints the compiler options for all targets
#
# cmt_print_compiler_options()
#
function(cmt_print_compiler_options)
    cmake_parse_arguments(ARGS "" "LANG" "CONFIG" ${ARGN})
	cmt_required_arguments(ARGS "" "LANG" "")
    cmt_ensure_lang(${ARGS_LANG})

    cmt_log("Global Compiler Options:")

	macro(cmt_print_list title list)
		if (NOT ${list})
			return()
		endif()

		cmt_status("  > ${title}:")
		foreach(element ${${list}})
			cmt_log("    - ${element}")
		endforeach()
	endmacro()


    cmt_print_list("CMAKE_${ARGS_LANG}_FLAGS" CMAKE_${ARGS_LANG}_FLAGS)
    if(NOT DEFINED ARGS_CONFIG)
        string(TOUPPER ${CMAKE_BUILD_TYPE} config)
        cmt_print_list("CMAKE_${ARGS_LANG}_FLAGS_${config}" CMAKE_${ARGS_LANG}_FLAGS_${config})
    else()
        foreach(config ${ARGS_CONFIG})
            cmt_ensure_config(${config})
            string(TOUPPER ${config} config)
            cmt_print_list("CMAKE_${ARGS_LANG}_FLAGS_${config}" CMAKE_${ARGS_LANG}_FLAGS_${config})
        endforeach()
    endif()
endfunction()

# ! cmt_print_linker_options 
# Prints the linker options for all targets
#
# cmt_print_linker_options()
#
function(cmt_print_linker_options)
    cmake_parse_arguments(ARGS "" "" "CONFIG" ${ARGN})

    cmt_log("Global Linker Options:")

	macro(cmt_print_list title list)
		if (NOT ${list})
			return()
		endif()

		cmt_status("  > ${title}:")
		foreach(element ${${list}})
			cmt_log("    - ${element}")
		endforeach()
	endmacro()


    cmt_print_list("CMAKE_EXE_LINKER_FLAGS" CMAKE_EXE_LINKER_FLAGS)
    cmt_print_list("CMAKE_SHARED_LINKER_FLAGS" CMAKE_SHARED_LINKER_FLAGS)
    cmt_print_list("CMAKE_MODULE_LINKER_FLAGS" CMAKE_MODULE_LINKER_FLAGS)
    cmt_print_list("CMAKE_STATIC_LINKER_FLAGS" CMAKE_STATIC_LINKER_FLAGS)

    if(NOT DEFINED ARGS_CONFIG)
        string(TOUPPER ${CMAKE_BUILD_TYPE} config)
        cmt_print_list("CMAKE_EXE_LINKER_FLAGS_${config}" CMAKE_EXE_LINKER_FLAGS_${config})
        cmt_print_list("CMAKE_SHARED_LINKER_FLAGS_${config}" CMAKE_SHARED_LINKER_FLAGS_${config})
        cmt_print_list("CMAKE_MODULE_LINKER_FLAGS_${config}" CMAKE_MODULE_LINKER_FLAGS_${config})
        cmt_print_list("CMAKE_STATIC_LINKER_FLAGS_${config}" CMAKE_STATIC_LINKER_FLAGS_${config})
    else()
        foreach(config ${ARGS_CONFIG})
            cmt_ensure_config(${config})
            string(TOUPPER ${config} config)
            cmt_print_list("CMAKE_EXE_LINKER_FLAGS_${config}" CMAKE_EXE_LINKER_FLAGS_${config})
            cmt_print_list("CMAKE_SHARED_LINKER_FLAGS_${config}" CMAKE_SHARED_LINKER_FLAGS_${config})
            cmt_print_list("CMAKE_MODULE_LINKER_FLAGS_${config}" CMAKE_MODULE_LINKER_FLAGS_${config})
            cmt_print_list("CMAKE_STATIC_LINKER_FLAGS_${config}" CMAKE_STATIC_LINKER_FLAGS_${config})
        endforeach()
    endif()
endfunction()