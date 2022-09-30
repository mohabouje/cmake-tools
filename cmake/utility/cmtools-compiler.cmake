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

macro(cmt_check_compiler_option result)
    cmake_parse_arguments(ARGS "" "OPTION;LANG" "" ${ARGN})
	cmt_required_arguments(FUNCTION cmt_check_compiler_option PREFIX ARGS FIELDS OPTION LANG)
    if(${ARGS_LANG} STREQUAL "C")
        enable_language(C)
        include(CheckCCompilerFlag)
        cmt_disable_logger()
        CHECK_C_COMPILER_FLAG(${ARGS_OPTION} has${ARGS_OPTION})
        cmt_enable_logger()
    elseif(${ARGS_LANG} STREQUAL "CXX")
        enable_language(CXX)
        include(CheckCXXCompilerFlag)
        cmt_disable_logger()
        CHECK_CXX_COMPILER_FLAG(${ARGS_OPTION} has${ARGS_OPTION})
        cmt_enable_logger()
    else()
        cmt_warn("Unsuported language: ${ARGS_LANG}, compiler flag ${ARGS_OPTION} not added")
    endif()
    if (CMT_IGNORE_COMPILER_OPTION_CHECKS)
        set(has${ARGS_OPTION} ON)
    endif()
endmacro()

macro(cmt_check_linker_option result)
    cmake_parse_arguments(ARGS "" "OPTION;LANG" "" ${ARGN})
	cmt_required_arguments(FUNCTION cmt_check_compiler_option PREFIX ARGS FIELDS OPTION LANG)
    if(${ARGS_LANG} STREQUAL "C")
        enable_language(C)
        include(CheckLinkerFlag)
        cmt_disable_logger()
        CHECK_LINKER_FLAG(C ${ARGS_OPTION} ${result})
        cmt_enable_logger()
    elseif(${ARGS_LANG} STREQUAL "CXX")
        enable_language(CXX)
        include(CheckLinkerFlag)
        cmt_disable_logger()
        CHECK_LINKER_FLAG(CXX ${ARGS_OPTION} ${result})
        cmt_enable_logger()
    else()
        cmt_warn("Unsuported language: ${ARGS_LANG}, compiler flag ${ARGS_OPTION} not added")
    endif()
    if (CMT_IGNORE_LINKER_OPTION_CHECKS)
        set(has${ARGS_OPTION} ON)
    endif()
endmacro()

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
macro(cmt_add_compiler_option)
    cmake_parse_arguments(ARGS "" "OPTION;COMPILER;LANG" "CONFIG" ${ARGN})
	cmt_required_arguments(FUNCTION cmt_add_compiler_option PREFIX ARGS FIELDS OPTION)

    macro(cmt_add_compiler_option_check_)
        if (DEFINED ARGS_LANG)
            cmt_ensure_lang(${ARGS_LANG})
            set(LANGUAGES ${ARGS_LANG})
        else()
            set(LANGUAGES "CXX" "C")
        endif()

        foreach (lang ${LANGUAGES})
            cmt_check_compiler_option(has${ARGS_OPTION} OPTION ${ARGS_OPTION} LANG ${lang})
            if(has${ARGS_OPTION})
                if (DEFINED ARGS_CONFIG)
                    foreach(config ${ARGS_CONFIG})
                        cmt_ensure_config(${config})
                        ucm_add_flags(${lang} ${ARGS_OPTION} CONFIG ${config})
                    endforeach()
                else()
                    ucm_add_flags(${lang} ${ARGS_OPTION})
                endif()
            else()
                cmt_log("Flag ${ARGS_OPTION} was reported as unsupported by ${lang} compiler and was not added")
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

macro(cmt_add_c_compiler_option)
    cmt_add_compile_option(LANG C ${ARGN})
endmacro()

macro(cmt_add_cxx_compiler_option)
    cmt_add_compiler_option(LANG CXX ${ARGN})
endmacro()

macro(cmt_add_debug_compiler_option)
    cmt_add_compiler_option(${ARGN} CONFIG Debug)
endmacro()

macro(cmt_add_release_compiler_option)
    cmt_add_compiler_option(${ARGN} CONFIG Release)
endmacro()

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
macro(cmt_add_compiler_options)
    cmake_parse_arguments(ARGS "" "LANG;COMPILER" "CONFIG;OPTIONS" ${ARGN})
	cmt_required_arguments(FUNCTION cmt_add_compiler_options PREFIX ARGS FIELDS OPTIONS)

    macro(cmt_add_compiler_options_check_)
        if (DEFINED ARGS_LANG)
            cmt_ensure_lang(${ARGS_LANG})
            if (DEFINED ARGS_CONFIG)
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
                foreach (option ${ARGS_OPTIONS})
                    cmt_add_compiler_option(CONFIG ${ARGS_CONFIG} OPTION ${option})
                endforeach()
            else()
                foreach (option ${ARGS_OPTIONS})
                    cmt_add_compiler_option(OPTION ${option})
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
    cmt_add_compiler_options(LANG C ${ARGN})
endmacro()

macro(cmt_add_cxx_compiler_options)
    cmt_add_compiler_options(LANG CXX ${ARGN})
endmacro()

macro(cmt_add_debug_compiler_options)
    cmt_add_compiler_options(${ARGN} CONFIG Debug)
endmacro()

macro(cmt_add_release_compiler_options)
    cmt_add_compiler_options(${ARGN} CONFIG Release)
endmacro()

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
macro(cmt_add_linker_option)
    cmake_parse_arguments(ARGS "" "LANG;OPTION;COMPILER" "CONFIG" ${ARGN})
	cmt_required_arguments(FUNCTION cmt_add_compiler_option PREFIX ARGS FIELDS OPTION)

    macro(cmt_add_linker_option_check_)
        if (DEFINED ARGS_LANG)
            cmt_ensure_lang(${ARGS_LANG})
            set(LANGUAGES ${ARGS_LANG})
        else()
            set(LANGUAGES "CXX" "C")
        endif()

        foreach (lang ${LANGUAGES})
            cmt_check_linker_option(has${ARGS_OPTION} OPTION ${ARGS_OPTION} LANG ${lang})
            if(has${ARGS_OPTION})
                if (DEFINED ARGS_CONFIG)
                    foreach(config ${ARGS_CONFIG})
                        cmt_ensure_config(${config})
                        ucm_add_linker_flags(${lang} ${ARGS_OPTION} CONFIG ${config})
                    endforeach()
                else()
                    ucm_add_linker_flags(${lang} ${ARGS_OPTION})
                endif()
            else()
                cmt_log("Flag ${ARGS_OPTION} was reported as unsupported by ${ARGS_LANG} linker and was not added")
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

macro(cmt_set_c_linker_option)
    cmt_add_linker_option(LANG C ${ARGN})
endmacro()

macro(cmt_set_cxx_linker_option)
    cmt_add_linker_option(LANG CXX ${ARGN})
endmacro()

macro(cmt_set_debug_linker_option)
    cmt_add_linker_option(${ARGN} CONFIG Debug)
endmacro()

macro(cmt_set_release_linker_option)
    cmt_add_linker_option(${ARGN} CONFIG Release)
endmacro()

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
macro(cmt_add_linker_options)
    cmake_parse_arguments(ARGS "" "LANG;COMPILER" "CONFIG;OPTIONS" ${ARGN})
	cmt_required_arguments(FUNCTION cmt_add_linker_options PREFIX ARGS FIELDS OPTIONS)


    macro(cmt_add_linker_options_check_)
        if (DEFINED ARGS_LANG)
            cmt_choice_arguments(FUNCTION cmt_add_linker_options PREFIX ARGS CHOICE LANG OPTIONS "CXX" "C" )
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
                    cmt_add_linker_option(OPTION ${option})
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
        cmt_add_compiler_options(OPTIONS -Wall -Wextra -Wpedantic -Weverything)
    elseif (CMT_COMPILER MATCHES "GNU")
        cmt_add_compiler_options(OPTIONS -Wall -Wextra -Wpedantic)
    elseif (CMT_COMPILER MATCHES "MSVC")
        cmt_add_compiler_options(OPTIONS /W4)
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
        cmt_add_compiler_option(OPTION -Weffc++)
    elseif (${CMT_COMPILER}  STREQUAL "GNU")
        cmt_add_compiler_option(OPTION -Weffc++)
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
        cmt_add_compiler_option(OPTION /W0)
    	cmt_log("${ARGS_TARGET}: mvsc disabled warnings")
    elseif(${CMT_COMPILER}  STREQUAL "GCC")
        cmt_add_compiler_option(OPTION --no-warnings)
    	cmt_log("${ARGS_TARGET}: gcc disabled warnings")
    elseif(${CMT_COMPILER}  STREQUAL "CLANG")
        cmt_add_compiler_option(OPTION -Wno-everything)
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
        cmt_add_compiler_options(OPTIONS -Werror)
    elseif (CMT_COMPILER MATCHES "GNU")
        cmt_add_compiler_options(OPTIONS -Werror)
    elseif (CMT_COMPILER MATCHES "MSVC")
        cmt_add_compiler_options(OPTIONS /WX)
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
        cmt_add_compiler_option(OPTION -MD)
    elseif (${CMT_COMPILER}  STREQUAL "GNU")
        cmt_add_compiler_option(OPTION -MD)
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
		cmt_add_compiler_option(OPTION "-g3" CONFIG Debug RelWithDebInfo)
        cmt_add_compiler_option(OPTION "-O0" CONFIG Debug)
        cmt_add_compiler_option(OPTION "-O2" CONFIG RelWithDebInfo)
        cmt_add_compiler_option(OPTION "-O3" CONFIG Release)
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
        cmt_add_compiler_option(OPTION -g3 CONFIG Debug RelWithDebInfo)
        cmt_add_compiler_option(OPTION -O0 CONFIG Debug)
        cmt_add_compiler_option(OPTION -O2 CONFIG RelWithDebInfo)
        cmt_add_compiler_option(OPTION -O3 CONFIG Release)

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
        cmt_add_compiler_options(OPTIONS /utf-8 /MP)
        cmt_add_compiler_options(OPTIONS /Zi /DEBUG:FULL CONFIG Debug RelWithDebInfo)
        cmt_add_compiler_options(OPTIONS /Od /RTC1 CONFIG Debug)
        cmt_add_compiler_options(OPTIONS /O2 CONFIG RelWithDebInfo)
        cmt_add_compiler_options(OPTIONS /Ox /Qpar CONFIG Release)
        cmt_add_linker_options(OPTIONS /INCREMENTAL:NO /OPT:REF /OPT:ICF /MANIFEST:NO CONFIG Release RelWithDebInfo)
        # TODO: implement cmt_add_compile_definition
        # cmt_add_compile_definition(DEFINITION "NDEBUG" CONFIG Release)
	    cmt_log("Configured mvsc options for all targets")
    else()
		cmt_warn("cmt_configure_msvc_compiler_options: target ${ARGS_TARGET} is not a msvc target")
		return()
	endif()
endmacro()

# ! cmt_configure_compiler_options 
# Configure compile options for the target like debug information, optimisation...
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

function(cmt_print_compiler_options)
    cmake_parse_arguments(ARGS "" "LANG" "CONFIG" ${ARGN})
	cmt_required_arguments(FUNCTION cmt_add_linker_options PREFIX ARGS FIELDS LANG)
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


    list(APPEND ${result} CMAKE_${ARGS_LANG}_FLAGS)
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

function(cmt_print_linker_options result)
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