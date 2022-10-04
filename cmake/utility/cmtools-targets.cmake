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

include(${CMAKE_CURRENT_LIST_DIR}/cmtools-env.cmake)
include(${CMAKE_CURRENT_LIST_DIR}/cmtools-fsystem.cmake)
include(${CMAKE_CURRENT_LIST_DIR}/cmtools-compiler.cmake)
include(${CMAKE_CURRENT_LIST_DIR}/./../tools/cmtools-cotire.cmake)
include(CheckIPOSupported)

# Functions summary:
# - cmt_append_to_target_property
# - cmt_target_add_compile_definitions
# - cmt_target_add_compiler_options
# - cmt_target_add_c_compiler_options
# - cmt_target_add_cxx_compiler_options
# - cmt_target_add_linker_options
# - cmt_target_add_c_linker_options
# - cmt_target_add_cxx_linker_options
# - cmt_target_add_compiler_option
# - cmt_target_add_c_compiler_option
# - cmt_target_add_cxx_compiler_option
# - cmt_target_add_linker_option
# - cmt_target_add_c_linker_option
# - cmt_target_add_cxx_linker_option
# - cmt_target_set_standard
# - cmt_target_set_output_directory
# - cmt_target_set_output_directories
# - cmt_target_set_runtime_output_directory
# - cmt_target_set_library_output_directory
# - cmt_target_set_archive_output_directory
# - cmt_target_configure_gcc_compiler_optimization_options
# - cmt_target_configure_clang_compiler_optimization_options
# - cmt_target_configure_mvsc_compiler_optimization_options
# - cmt_target_configure_compiler_optimization_options
# - cmt_target_set_runtime
# - cmt_target_enable_warnings_as_errors
# - cmt_target_enable_all_warnings
# - cmt_target_enable_effective_cxx_warnings
# - cmt_target_enable_generation_header_dependencies
# - cmt_target_disable_warnings
# - cmt_target_set_ide_directory
# - cmt_target_source_group
# - cmt_interface_target_generate_headers_target

# ! cmt_append_to_target_property 
# Append arguments to a target property
#
# cmt_append_to_target_property(
#   TARGET
#   PROPERTY
#   <appen1> <append2> ...
# )
#
# \input TARGET Specifies the target to which the property will be appended.
# \input PROPERTY Specifies the property to be appended.
# \input List of properties to be appended.
#
function(cmt_append_to_target_property TARGET PROPERTY)
    cmake_parse_arguments(ARGS "" "" "" ${ARGN})
	cmt_ensure_target(${TARGET})
	get_target_property(PROPERTY_VALUE ${TARGET} ${PROPERTY})
	if(NOT PROPERTY_VALUE)
		set(PROPERTY_VALUE "")
	endif()
	set(PROPERTY_VALUE "${PROPERTY_VALUE} ${ARGS_UNPARSED_ARGUMENTS}")
	set_target_properties(${TARGET} PROPERTIES ${PROPERTY} "${PROPERTY_VALUE}")
endfunction()


# ! cmt_target_add_compile_definition
# Add a private compile definition to the target for the specified configs.
#
# cmt_target_add_compile_definition(
#   TARGET
#   DEFINITION
#   [COMPILER <compiler>]
#   [CONFIG <config1> <config2>...]
# )
#
# \input TARGET Target to add flag
# \input Definition to add
# \group CONFIG Configs for the property to change (Debug Release RelWithDebInfo MinSizeRel)
#
function(cmt_target_add_compile_definition TARGET DEFINITION)
    cmake_parse_arguments(ARGS "" "COMPILER" "CONFIG" ${ARGN})
	cmt_ensure_target(${TARGET})

	if (DEFINED ARGS_COMPILER)
        cmt_define_compiler()
        if (NOT ${CMT_COMPILER} STREQUAL ${ARGS_COMPILER})
            return()
        endif()
    endif()

	if (DEFINED ARGS_CONFIG)
    	foreach(config ${ARGS_CONFIG})
			cmt_ensure_config(${ARGS_CONFIG})
			string(TOUPPER ${config} config)
			target_compile_definitions(${TARGET} PRIVATE "$<$<CONFIG:${config}>:${DEFINITION}>")
		endforeach()
	else()
		target_compile_definitions(${TARGET} PRIVATE "${DEFINITION}")
	endif()
endfunction()


# ! cmt_target_add_compiler_option
# Add a flag to the compiler arguments of the target for the specified language and configs.
# Add the flag only if the compiler support it (checked with CHECK_<LANG>_COMPILER_FLAG).
#
# cmt_target_add_compiler_option(
#   TARGET
#   OPTION
#   [LANG <lang>]
#   [COMPILER <compiler>]
#   [CONFIG <config1> <config2>...]
# )
#
# \input TARGET Target to add flag
# \input Compiler flag to add
# \param LANG Language of the flag (C|CXX)
# \param COMPILER Compiler to check the flag (GCC|CLANG|MSVC)
# \group CONFIG Configs for the property to change (Debug Release RelWithDebInfo MinSizeRel)
#
function(cmt_target_add_compiler_option TARGET OPTION)
    cmake_parse_arguments(ARGS "" "LANG;COMPILER" "CONFIG" ${ARGN})
    cmt_ensure_target(${TARGET}) 

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
		cmt_check_compiler_option(has${OPTION} OPTION ${OPTION} LANG ${lang})
		if(has${OPTION})
			if (DEFINED ARGS_CONFIG)
				foreach(config ${ARGS_CONFIG})
					cmt_ensure_config(${config})
					string(TOUPPER ${config} config)
					target_compile_options(${TARGET} PRIVATE "$<$<AND:$<COMPILE_LANGUAGE:${lang}>,$<CONFIG:${config}>>:${OPTION}>")
				endforeach()
			else()
				target_compile_options(${TARGET} PRIVATE "$<$<COMPILE_LANGUAGE:${lang}>:${OPTION}>")
			endif()
		else()
			cmt_debug("${TARGET}: flag ${OPTION} was reported as unsupported by ${lang} compiler and was not added")
		endif()
	endforeach()
endfunction()

# ! cmt_target_add_c_compiler_option
# Add a flag to C the compiler arguments of the target for the specified language and configs.
# Add the flag only if the compiler support it (checked with CHECK_C_COMPILER_FLAG).
#
# cmt_target_add_c_compiler_option(
#   TARGET
#   OPTION
#   [COMPILER <compiler>]
#   [CONFIG <config1> <config2>...]
# )
#
# \input TARGET Target to add flag
# \input Compiler flag to add
# \param COMPILER Compiler to check the flag (GCC|CLANG|MSVC)
# \group CONFIG Configs for the property to change (Debug Release RelWithDebInfo MinSizeRel)
#
macro(cmt_target_add_c_compiler_option TARGET OPTION)
	cmt_target_add_compiler_option(${TARGET} ${OPTION} LANG C ${ARGN})
endmacro()

# ! cmt_target_add_cxx_compiler_option
# Add a flag to C the compiler arguments of the target for the specified language and configs.
# Add the flag only if the compiler support it (checked with CHECK_C_COMPILER_FLAG).
# cmt_target_add_cxx_compiler_option(
#   TARGET
#   OPTION
#   [COMPILER <compiler>]
#   [CONFIG <config1> <config2>...]
# )
#
# \input TARGET Target to add flag
# \input Compiler flag to add
# \param COMPILER Compiler to check the flag (GCC|CLANG|MSVC)
# \group CONFIG Configs for the property to change (Debug Release RelWithDebInfo MinSizeRel)
#
macro(cmt_target_add_cxx_compiler_option TARGET OPTION)
	cmt_target_add_compiler_option(${TARGET} ${OPTION} LANG CXX ${ARGN})
endmacro()

# ! cmt_target_add_compiler_options
# Add flags to the compiler arguments of the target for the specified language and configs.
# Add the flags only if the compiler support it (checked with CHECK_<LANG>_COMPILER_FLAG).
#
# cmt_target_add_compiler_options(
#   TARGET
#   <option1> <option2>...
#   [LANG <lang>]
#   [COMPILER <compiler>]
#   [CONFIG <config1> <config2>...]
# )
#
# \input TARGET Target to add flag
# \input List of compiler flags to add
# \param LANG Language of the flag (C|CXX)
# \param COMPILER Compiler to check the flag (GCC|CLANG|MSVC)
# \group CONFIG Configs for the property to change (Debug Release RelWithDebInfo MinSizeRel)
#
function(cmt_target_add_compiler_options TARGET)
    cmake_parse_arguments(ARGS "" "LANG" "CONFIG" ${ARGN})
    cmt_ensure_targets(${TARGET}) 

	# TODO: use arguments forwarding instead of complex parsing
	# TODO: ensure that it's a list
	set(OPTIONS ${ARGS_UNPARSED_ARGUMENTS})
    if (DEFINED ARGS_COMPILER)
        cmt_define_compiler()
        if (NOT ${CMT_COMPILER} STREQUAL ${ARGS_COMPILER})
            return()
        endif()
    endif()

	if (DEFINED ARGS_LANG)
	    cmt_ensure_lang(${ARGS_LANG})
		if (DEFINED ARGS_CONFIG)
			foreach (option ${OPTIONS})
				cmt_target_add_compiler_option(${TARGET} LANG ${ARGS_LANG} CONFIG ${ARGS_CONFIG} ${option})
			endforeach()
		else()
			foreach (option ${OPTIONS})
				cmt_target_add_compiler_option(${TARGET} LANG ${ARGS_LANG} ${option})
			endforeach()
		endif()
	else()
		if (DEFINED ARGS_CONFIG)
			foreach (option ${OPTIONS})
				cmt_target_add_compiler_option(${TARGET} CONFIG ${ARGS_CONFIG} ${option})
			endforeach()
		else()
			foreach (option ${OPTIONS})
				cmt_target_add_compiler_option(${TARGET} ${option})
			endforeach()
		endif()
	endif()

endfunction()

# ! cmt_target_add_c_compiler_options
# Add a flag to C the compiler arguments of the target for the specified language and configs.
# Add the flag only if the compiler support it (checked with CHECK_C_COMPILER_FLAG).
#
# cmt_target_add_c_compiler_options(
#   TARGET
#   <option1> <option2>...
#   [COMPILER <compiler>]
#   [CONFIG <config1> <config2>...]
# )
#
# \input TARGET Target to add flag
# \input List of compiler flags to add
# \param COMPILER Compiler to check the flag (GCC|CLANG|MSVC)
# \group CONFIG Configs for the property to change (Debug Release RelWithDebInfo MinSizeRel)
#
macro(cmt_target_add_c_compiler_options TARGET)
	cmt_target_add_compiler_options(${TARGET} LANG C ${ARGN})
endmacro()

# ! cmt_target_add_cxx_compiler_options Add a flag to C the compiler arguments of the target for the specified language and configs.
# Add the flag only if the compiler support it (checked with CHECK_C_COMPILER_FLAG).
#
# cmt_target_add_cxx_compiler_options(
#   TARGET
#   <option1> <option2>...
#   [COMPILER <compiler>]
#   [CONFIG <config1> <config2>...]
# )
#
# \input TARGET Target to add flag
# \input List of compiler flags to add
# \param COMPILER Compiler to check the flag (GCC|CLANG|MSVC)
# \group CONFIG Configs for the property to change (Debug Release RelWithDebInfo MinSizeRel)
#
macro(cmt_target_add_cxx_compiler_options TARGET)
	cmt_target_add_compiler_options(${TARGET} LANG CXX ${ARGN})
endmacro()


# ! cmt_target_add_linker_option
# Add flags to the linker arguments of the target for the specified language and configs.
# Add the flags only if the linker support it (checked with CHECK_<LANG>_COMPILER_FLAG).
#
# cmt_target_add_linker_option(
#   TARGET
#   OPTION
#   [LANG <lang>]
#   [COMPILER <compiler>]
#   [CONFIG <config1> <config2>...]
# )
#
# \input TARGET Target to add flag
# \input Linker flag to add
# \param LANG Language of the flag (C|CXX)
# \param COMPILER Compiler to check the flag (GCC|CLANG|MSVC)
# \group CONFIG Configs for the property to change (Debug Release RelWithDebInfo MinSizeRel)
#
function(cmt_target_add_linker_option TARGET OPTION)
    cmake_parse_arguments(ARGS "" "LANG;COMPILER" "CONFIG" ${ARGN})
    cmt_ensure_target(${TARGET}) 

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
		cmt_check_linker_option(has${OPTION} OPTION ${OPTION} LANG ${lang})
		if(has${OPTION})
			if (DEFINED ARGS_CONFIG)
				foreach(config ${ARGS_CONFIG})
					cmt_ensure_config(${config})
					string(TOUPPER ${config} config)
					target_link_options(${TARGET} PRIVATE "$<$<AND:$<COMPILE_LANGUAGE:${lang}>,$<CONFIG:${config}>>:${OPTION}>")
				endforeach()
			else()
				target_link_options(${TARGET} PRIVATE "$<$<COMPILE_LANGUAGE:${lang}>:${OPTION}>")
			endif()
		else()
			cmt_debug("${TARGET}: flag ${OPTION} was reported as unsupported by ${lang} linker and was not added")
		endif()
	endforeach()
endfunction()

# ! cmt_target_add_linker_option
# Add flags to the C linker arguments of the target for the specified language and configs.
# Add the flags only if the linker support it (checked with CHECK_C_COMPILER_FLAG).
#
# cmt_target_add_linker_option(
#   TARGET
#   OPTION
#   [LANG <lang>]
#   [COMPILER <compiler>]
#   [CONFIG <config1> <config2>...]
# )
#
# \input TARGET Target to add flag
# \input Linker flag to add
# \param COMPILER Compiler to check the flag (GCC|CLANG|MSVC)
# \group CONFIG Configs for the property to change (Debug Release RelWithDebInfo MinSizeRel)
#
macro(cmt_target_add_c_linker_option TARGET OPTION)
	cmt_target_add_linker_option(${TARGET} ${OPTION} LANG C ${ARGN})
endmacro()

# ! cmt_target_add_linker_option
# Add flags to the CXX linker arguments of the target for the specified language and configs.
# Add the flags only if the linker support it (checked with CHECK_CXX_COMPILER_FLAG).
# cmt_target_add_linker_option(
#   TARGET
#   OPTION
#   [LANG <lang>]
#   [COMPILER <compiler>]
#   [CONFIG <config1> <config2>...]
# )
#
# \input TARGET Target to add flag
# \input Linker flag to add
# \param COMPILER Compiler to check the flag (GCC|CLANG|MSVC)
# \group CONFIG Configs for the property to change (Debug Release RelWithDebInfo MinSizeRel)
#
macro(cmt_target_add_cxx_linker_option TARGET OPTION)
	cmt_target_add_linker_option(${TARGET} ${OPTION} LANG CXX ${ARGN})
endmacro()

# ! cmt_target_add_linker_optionss 
# Add flags to the linker arguments of the target for the specified language and configs.
# Add the flags only if the linker support it (checked with CHECK_<LANG>_COMPILER_FLAG).
#
# cmt_target_add_linker_options(
#   TARGET
#   <option1> <option2>...
#   [LANG <lang>]
#   [COMPILER <compiler>]
#   [CONFIG <config1> <config2>...]
# )
#
# \input TARGET Target to add flag
# \input List of linker flags to add
# \param LANG Language of the flag (C|CXX)
# \param COMPILER Compiler to check the flag (GCC|CLANG|MSVC)
# \group CONFIG Configs for the property to change (Debug Release RelWithDebInfo MinSizeRel)
#
function(cmt_target_add_linker_options TARGET)
    cmake_parse_arguments(ARGS "" "LANG;COMPILER" "CONFIG" ${ARGN})
    cmt_ensure_target(${TARGET}) 

	# TODO: use arguments forwarding instead of complex parsing
	# TODO: ensure that it's a list
	set(OPTIONS ${ARGS_UNPARSED_ARGUMENTS})

    if (DEFINED ARGS_COMPILER)
        cmt_define_compiler()
        if (NOT ${CMT_COMPILER} STREQUAL ${ARGS_COMPILER})
            return()
        endif()
    endif()

	if (DEFINED ARGS_LANG)
	    cmt_ensure_lang(${ARGS_LANG})
		if (DEFINED ARGS_CONFIG)
			foreach (option ${OPTIONS})
				cmt_target_add_linker_option(${TARGET} LANG ${ARGS_LANG} CONFIG ${ARGS_CONFIG} ${option})
			endforeach()
		else()
			foreach (option ${OPTIONS})
				cmt_target_add_linker_option(${TARGET} LANG ${ARGS_LANG} ${option})
			endforeach()
		endif()
	else()
		if (DEFINED ARGS_CONFIG)
			foreach (option ${OPTIONS})
				cmt_target_add_linker_option(${TARGET} CONFIG ${ARGS_CONFIG} ${option})
			endforeach()
		else()
			foreach (option ${OPTIONS})
				cmt_target_add_linker_option(${TARGET} ${option})
			endforeach()
		endif()
	endif()

endfunction()

# ! cmt_target_add_linker_option Add flags to the C linker arguments of the target for the specified language and configs.
# Add the flags only if the linker support it (checked with CHECK_C_COMPILER_FLAG).
#
# cmt_target_add_linker_option(
#   TARGET
#   <option1> <option2>...
#   [LANG <lang>]
#   [COMPILER <compiler>]
#   [CONFIG <config1> <config2>...]
# )
#
# \input TARGET Target to add flag
# \input List of linker flags to add
# \param COMPILER Compiler to check the flag (GCC|CLANG|MSVC)
# \group CONFIG Configs for the property to change (Debug Release RelWithDebInfo MinSizeRel)
#
macro(cmt_target_add_c_linker_options TARGET)
	cmt_target_add_linker_options(${TARGET} LANG C ${ARGN})
endmacro()

# ! cmt_target_add_linker_options Add flags to the CXX linker arguments of the target for the specified language and configs.
# Add the flags only if the linker support it (checked with CHECK_CXX_COMPILER_FLAG).
#
# cmt_target_add_linker_option(
#   TARGET
#   <option1> <option2>...
#   [LANG <lang>]
#   [COMPILER <compiler>]
#   [CONFIG <config1> <config2>...]
# )
#
# \input TARGET Target to add flag
# \input List of linker flags to add
# \param COMPILER Compiler to check the flag (GCC|CLANG|MSVC)
# \group CONFIG Configs for the property to change (Debug Release RelWithDebInfo MinSizeRel)
#
macro(cmt_target_add_cxx_linker_options TARGET)
	cmt_target_add_linker_options(${TARGET} LANG CXX ${ARGN})
endmacro()


# ! cmt_target_set_standard 
# ASet the target language standard to use, also set the standard as required and disable compiler extensions.
#
# cmt_target_set_standard(
#   <REQUIRED> 
#   <EXTENSIONS>
#   TARGET
#   [C <c_std>] (90|99|11|17|23)
#   [CXX <cxx_std>] (98|11|14|17|20|23)
# )
#
# \input  TARGET Target to set standards
# \param  C C standard to use
# \param  CXX CXX standard to use
# \option REQUIRED Set the standard as required
# \option EXTENSIONS Set the standard with compiler extensions
#
function(cmt_target_set_standard TARGET)
    cmake_parse_arguments(ARGS "REQUIRED;EXTENSIONS" "C;CXX" "" ${ARGN})
	cmt_ensure_on_of_argument(ARGS C CXX)
    cmt_ensure_target(${TARGET}) 

	if (DEFINED ARGS_C)
		cmt_ensure_argument_choice(ARGS C 90 99 11 17 23)
		#target_compile_features(${TARGET} PUBLIC c_std_${ARGS_C})
		#target_compile_options(${TARGET} PUBLIC "$<$<COMPILE_LANGUAGE:C>:${ARGS_C}>")
		set_target_properties(
			${TARGET} PROPERTIES
			C_STANDARD ${ARGS_C}
			C_STANDARD_REQUIRED DEFINED ARGS_REQUIRED
			C_EXTENSIONS DEFINED ARGS_EXTENSIONS
		)
	endif()

	if (DEFINED ARGS_CXX)
		cmt_ensure_argument_choice(ARGS CXX 98 11 14 17 20 23)
		#target_compile_features(${TARGET} PUBLIC cxx_std_${ARGS_CXX})
		#target_compile_options(${TARGET} PUBLIC "$<$<COMPILE_LANGUAGE:CXX>:${ARGS_CXX}>")
		set_target_properties(
			${TARGET} PROPERTIES
			CXX_STANDARD ${ARGS_CXX}
			CXX_STANDARD_REQUIRED DEFINED ARGS_REQUIRED
			CXX_EXTENSIONS DEFINED ARGS_EXTENSIONS
		)
	endif()

endfunction()

# ! cmt_target_set_output_directory 
# Set the target language standard to use, also set the standard as required and disable compiler extensions.
#
# cmt_target_set_output_directory(
#   TARGET
#   [RUNTIME <runtime_directory>]
#   [LIBRARY <library_directory>]
#   [ARCHIVE <archive_directory>]
#   [DIRECTORY <directory>] (if not defined, it uses this values for runtime, library and archive output directory)
# )
#
# \input TARGET Target to set output directories
# \param RUNTIME Runtime output directory
# \param LIBRARY Library output directory
# \param ARCHIVE Archive output directory
# \param DIRECTORY By default, used for the ones not provided
#
function(cmt_target_set_output_directory TARGET)
    cmake_parse_arguments(ARGS "" "RUNTIME;LIBRARY;ARCHIVE;DIRECTORY" "" ${ARGN})
	cmt_ensure_on_of_argument(ARGS RUNTIME LIBRARY ARCHIVE DIRECTORY)
	cmt_default_argument(ARGS RUNTIME ${ARGS_DIRECTORY})
	cmt_default_argument(ARGS LIBRARY ${ARGS_DIRECTORY})
	cmt_default_argument(ARGS ARCHIVE ${ARGS_DIRECTORY})
    cmt_ensure_target(${TARGET}) 

	foreach(type IN ITEMS RUNTIME LIBRARY ARCHIVE)
		if (NOT ${ARGS_${type}} STREQUAL "")
			set_target_properties(${TARGET} PROPERTIES ${type}_OUTPUT_DIRECTORY ${ARGS_${type}})
			foreach(mode IN ITEMS DEBUG RELWITHDEBINFO RELEASE)
				set_target_properties(${TARGET} PROPERTIES ${type}_OUTPUT_DIRECTORY_${mode} ${ARGS_${type}})
			endforeach()
		endif()
	endforeach()
endfunction()

# ! cmt_target_set_output_directories 
# Set the target runtime, library and archive output directory to classic folders build/bin and build/bin.
#
# cmt_target_set_output_directories(
#   TARGET
# )
#
# \input TARGET Target to set output directories
#
macro(cmt_target_set_output_directories TARGET)
	cmt_target_set_output_directory(
		${TARGET}
		RUNTIME "${CMAKE_CURRENT_BINARY_DIR}/build/bin"
		LIBRARY "${CMAKE_CURRENT_BINARY_DIR}/build/lib"
		ARCHIVE "${CMAKE_CURRENT_BINARY_DIR}/build/lib"
	)
endmacro()

# ! cmt_target_set_runtime_output_directory 
# Set the target runtime output directory.
#
# cmt_target_set_runtime_output_directory(
#   TARGET
#   DIRECTORY
# )
#
# \input TARGET Target to set output directories
# \input DIRECTORY Runtime output directory
#
function(cmt_target_set_runtime_output_directory TARGET DIRECTORY)
	cmt_target_set_output_directory(${TARGET} RUNTIME ${DIRECTORY})
endfunction()

# ! cmt_target_set_library_output_directory 
# Set the target library output directory.
#
# cmt_target_set_library_output_directory(
#   TARGET
#   DIRECTORY
# )
#
# \input TARGET Target to set output directories
# \input DIRECTORY Runtime output directory
#
function(cmt_target_set_library_output_directory TARGET DIRECTORY)
	cmt_target_set_output_directory(${TARGET} RUNTIME ${DIRECTORY})
endfunction()

# ! cmt_target_set_archive_output_directory 
# Set the target archive output directory.
#
# cmt_target_set_archive_output_directory(
#   TARGET
#   DIRECTORY
# )
#
# \input TARGET Target to set output directories
# \input DIRECTORY Runtime output directory
#
function(cmt_target_set_archive_output_directory TARGET DIRECTORY)
	cmt_target_set_output_directory(${TARGET} RUNTIME ${DIRECTORY})
endfunction()


# ! cmt_target_configure_gcc_compiler_optimization_options 
# Configure gcc compile oprions for the target like debug informations, optimisation...
#
# cmt_target_configure_gcc_compiler_optimization_options(
#   TARGET
# )
#
# \input TARGET Target to configure
#
function(cmt_target_configure_gcc_compiler_optimization_options TARGET)
	cmt_ensure_target(${TARGET})
	cmt_define_compiler()
	if (NOT CMT_COMPILER MATCHES "GCC")
		cmt_warn("cmt_target_configure_gcc_compiler_optimization_options: target ${TARGET} is not a gcc target")
		return()
	endif()

	cmt_target_add_compiler_option(${TARGET} "-g3" CONFIG Debug RelWithDebInfo)
	cmt_target_add_compiler_option(${TARGET} "-O0" CONFIG Debug)
	cmt_target_add_compiler_option(${TARGET} "-O2" CONFIG RelWithDebInfo)
	cmt_target_add_compiler_option(${TARGET} "-O3" CONFIG Release)
	cmt_target_add_compile_definition(${TARGET} NDEBUG CONFIG Release)
	cmt_debug("Target ${TARGET}: configured gcc options")
endfunction()

# ! cmt_target_configure_clang_compiler_optimization_options 
# Configure clang compile oprions for the target like debug informations, optimisation...
#
# cmt_target_configure_clang_compiler_optimization_options(
#   TARGET
# )
#
# \input TARGET Target to configure
#
function(cmt_target_configure_clang_compiler_optimization_options TARGET)
	cmt_ensure_target(${TARGET})
	cmt_define_compiler()
	if (NOT CMT_COMPILER MATCHES "CLANG")
		cmt_warn("cmt_target_configure_clang_compiler_optimization_options: target ${TARGET} is not a clang target")
		return()
	endif()

	cmt_target_add_compiler_option(${TARGET} -g3 CONFIG Debug RelWithDebInfo)
	cmt_target_add_compiler_option(${TARGET} -O0 CONFIG Debug)
	cmt_target_add_compiler_option(${TARGET} -O2 CONFIG RelWithDebInfo)
	cmt_target_add_compiler_option(${TARGET} -O3 CONFIG Release)
	cmt_target_add_compile_definition(${TARGET} NDEBUG CONFIG Release)
	cmt_debug("Target ${TARGET}: configured clang options")
endfunction()

# ! cmt_target_configure_mvsc_compiler_optimization_options 
# Configure MVSC compile oprions for the target like debug informations, optimisation...
#
# cmt_target_configure_mvsc_compiler_optimization_options(
#   TARGET
# )
#
# \input TARGET Target to configure
#
function(cmt_target_configure_mvsc_compiler_optimization_options TARGET)
	cmt_ensure_target(${TARGET})
	cmt_define_compiler()
	if (NOT CMT_COMPILER MATCHES "MVSC")
		cmt_warn("cmt_target_configure_mvsc_compiler_optimization_options: target ${TARGET} is not a msvc target")
		return()
	endif()

	cmt_target_add_compiler_options(${TARGET} /utf-8 /MP)
	cmt_target_add_compiler_options(${TARGET} /Zi /DEBUG:FULL CONFIG Debug RelWithDebInfo)
	cmt_target_add_compiler_options(${TARGET} /Od /RTC1 CONFIG Debug)
	cmt_target_add_compiler_options(${TARGET} /O2 CONFIG RelWithDebInfo)
	cmt_target_add_compiler_options(${TARGET} /Ox /Qpar CONFIG Release)
	cmt_target_add_linker_options(${TARGET} /INCREMENTAL:NO /OPT:REF /OPT:ICF /MANIFEST:NO CONFIG Release RelWithDebInfo)
	cmt_target_add_compile_definition(${TARGET} NDEBUG CONFIG Release)
	cmt_debug("Target ${TARGET}: configured msvc options")
endfunction()

# ! cmt_target_configure_compiler_optimization_options 
# Configure compile options for the target like debug information, optimisation...
#
# cmt_target_configure_compiler_optimization_options(
#   TARGET
# )
#
# \input TARGET Target to configure
#
function(cmt_target_configure_compiler_optimization_options TARGET)
	cmt_ensure_target(${TARGET})
	cmt_define_compiler()
	if (CMT_COMPILER MATCHES "MVSC")
		cmt_target_configure_mvsc_compiler_optimization_options(${TARGET})
	elseif(CMT_COMPILER MATCHES "GCC")
		cmt_target_configure_gcc_compiler_optimization_options(${TARGET})
	elseif(CMT_COMPILER MATCHES "CLANG")
		cmt_target_configure_clang_compiler_optimization_options(${TARGET})
	else()
		cmt_warn("Unsupported compiler (${CMAKE_CXX_COMPILER_ID}), compile options not configured")
	endif()
endfunction()

# ! cmt_target_configure_gcc_compiler_coverage_options 
# Configure the compiler options to generate coverage informations
#
# cmt_target_configure_gcc_compiler_coverage_options(
#   TARGET
# )
#
# \input TARGET Target to configure
#
function(cmt_target_configure_gcc_compiler_coverage_options TARGET)
	cmt_ensure_target(${TARGET})
	cmt_define_compiler()
	if (NOT CMT_COMPILER MATCHES "GCC")
		cmt_warn("cmt_target_configure_gcc_compiler_coverage_options: target ${TARGET} is not a gcc target")
		return()
	endif()

	if (CMT_ENABLE_COVERAGE OR CMT_ENABLE_PROFILING)
		cmt_target_add_compiler_option(${TARGET} -g -O0)
    endif ()

    if (CMT_ENABLE_COVERAGE)
		cmt_target_add_compiler_option(${TARGET} -ftest-coverage -fprofile-arcs)
		cmt_target_add_linker_option(${TARGET} -fprofile-arcs -lgcov)
    endif ()

endfunction()

# ! cmt_target_configure_clang_compiler_coverage_options 
# Configure the compiler options to generate coverage informations
#
# cmt_target_configure_clang_compiler_coverage_options(
#   TARGET
# )
#
# \input TARGET Target to configure
#
function(cmt_target_configure_clang_compiler_coverage_options TARGET)
	cmt_ensure_target(${TARGET})
	cmt_define_compiler()
	if (NOT CMT_COMPILER MATCHES "CLANG")
		cmt_warn("cmt_target_configure_clang_compiler_coverage_options: target ${TARGET} is not a clang target")
		return()
	endif()

	if (CMT_ENABLE_COVERAGE OR CMT_ENABLE_PROFILING)
		cmt_target_add_compiler_option(${TARGET} -g -O0)
    endif ()

    if (CMT_ENABLE_COVERAGE)
		cmt_target_add_compiler_option(${TARGET} -fprofile-instr-generate -fcoverage-mapping)
		cmt_target_add_linker_option(${TARGET} -fprofile-instr-generate -fcoverage-mapping)
    endif ()
endfunction()

# ! cmt_target_configure_mvsc_compiler_coverage_options 
# Configure the compiler options to generate coverage informations
#
# cmt_target_configure_mvsc_compiler_coverage_options(
#   TARGET
# )
#
# \input TARGET Target to configure
#
function(cmt_target_configure_mvsc_compiler_coverage_options TARGET)
	cmt_ensure_target(${TARGET})
	cmt_define_compiler()
	if (NOT CMT_COMPILER MATCHES "MVSC")
		cmt_warn("cmt_target_configure_mvsc_compiler_coverage_options: target ${TARGET} is not a msvc target")
		return()
	endif()

	cmt_fatal("cmt_target_configure_mvsc_compiler_coverage_options: not implemented")
endfunction()


# ! cmt_target_configure_compiler_coverage_options 
# Configure the compiler options to generate coverage informations
#
# cmt_target_configure_compiler_coverage_options(
#   TARGET
# )
#
# \input TARGET Target to configure
#
function(cmt_target_configure_compiler_coverage_options TARGET)
	cmt_ensure_target(${TARGET})
	cmt_define_compiler()
	if (CMT_COMPILER MATCHES "MVSC")
		cmt_target_configure_mvsc_compiler_coverage_options(${TARGET})
	elseif(CMT_COMPILER MATCHES "GCC")
		cmt_target_configure_gcc_compiler_coverage_options(${TARGET})
	elseif(CMT_COMPILER MATCHES "CLANG")
		cmt_target_configure_clang_compiler_coverage_options(${TARGET})
	else()
		cmt_warn("Unsupported compiler (${CMAKE_CXX_COMPILER_ID}), compile options not configured")
	endif()
endfunction()

# ! cmt_target_set_runtime 
# Set target run-time: determine if the target should be linked statically
# or dynamically to the run-time library.
#
# MSVC infos: https://docs.microsoft.com/en-us/cpp/build/reference/md-mt-ld-use-run-time-library
# GCC infos: https://gcc.gnu.org/onlinedocs/gcc/Link-Options.html
#
# cmt_target_set_runtime(
#   <STATIC> 
#   <DYNAMIC>
#   TARGET
# )
#
# \input TARGET Target to configure
# \option STATIC If present, set static run-time
# \option DYNAMIC If present, set dynamic run-time
#
function(cmt_target_set_runtime TARGET)
	cmake_parse_arguments(ARGS "STATIC;DYNAMIC" "" "" ${ARGN})
	cmt_ensure_on_of_argument(ARGS STATIC DYNAMIC)
	cmt_ensure_target(${TARGET})

	cmt_define_compiler()
	if(runtime STREQUAL "STATIC")
		if (CMT_COMPILER MATCHES "MVSC")
			cmt_target_add_linker_option(${TARGET} /MTd CONFIG Debug)
			cmt_target_add_linker_option(${TARGET} /MT CONFIG Release RelWithDebInfo)
		elseif(CMT_COMPILER MATCHES "GCC")
			cmt_target_add_linker_option(${TARGET} LANG CXX -static-libstdc++)
			cmt_target_add_linker_option(${TARGET} LANG CXX -static-libgcc)
			cmt_target_add_linker_option(${TARGET} LANG C -static-libgcc)
		elseif(CMT_COMPILER MATCHES "CLANG")
			cmt_target_add_linker_option(${TARGET} LANG CXX -static-libstdc++)
			cmt_target_add_linker_option(${TARGET} LANG CXX -static-libgcc)
			cmt_target_add_linker_option(${TARGET} LANG C -static-libgcc)
		else()
			cmt_warn("Unsupported compiler (${CMAKE_CXX_COMPILER_ID}), run-time library not forced to static link")
			return()
		endif()
		cmt_debug("${TARGET}: set static run-time")
	elseif(runtime STREQUAL "DYNAMIC")
		if (CMT_COMPILER MATCHES "MVSC")
			cmt_target_add_linker_option(${TARGET}  /MDd CONFIG Debug)
			cmt_target_add_linker_option(${TARGET}  /MD CONFIG Release RelWithDebInfo)
		elseif(CMT_COMPILER MATCHES "GCC")
			# dynamic by default
		elseif(CMT_COMPILER MATCHES "CLANG")
			# dynamic by default
		else()
			cmt_warn("Unsupported compiler (${CMAKE_CXX_COMPILER_ID}), run-time library not forced to static link")
			return()
		endif()
	endif()
endfunction()

# ! cmt_target_enable_warnings_as_errors Treats all compiler warnings as errors for the target
#
# cmt_target_enable_warnings_as_errors(
#   TARGET
# )
#
# \input TARGET Target to configure
#
function(cmt_target_enable_warnings_as_errors TARGET)
	cmt_ensure_target(${TARGET})
    cmt_define_compiler()
	if (CMT_COMPILER MATCHES "CLANG")
		cmt_target_add_compiler_option(${TARGET} -Werror)
	elseif (CMT_COMPILER MATCHES "GNU")
		cmt_target_add_compiler_option(${TARGET} -Werror)
	elseif (CMT_COMPILER MATCHES "MSVC")
		cmt_target_add_compiler_option(${TARGET} /WX)
	else()
		cmt_warn("Unsupported compiler (${CMAKE_CXX_COMPILER_ID}), warnings not enabled for target ${TARGET}")
	endif()
endfunction()

# ! cmt_target_enable_all_warnings Enable all warnings for the major compilers in the target
#
# cmt_target_enable_all_warnings(
#   TARGET
# )
#
# \input TARGET Target to configure
#
function(cmt_target_enable_all_warnings TARGET)
    cmt_ensure_target(${TARGET})
    cmt_define_compiler()
	if (CMT_COMPILER MATCHES "CLANG")
		cmt_target_add_compiler_options(${TARGET} -Wall -Wextra -Wpedantic)
	elseif (CMT_COMPILER MATCHES "GNU")
		cmt_target_add_compiler_options(${TARGET} -Wall -Wextra -Wpedantic -Weverything)
	elseif (CMT_COMPILER MATCHES "MSVC")
		cmt_target_add_compiler_options(${TARGET} /W4)
	else()
		cmt_warn("Unsupported compiler (${CMAKE_CXX_COMPILER_ID}), warnings not enabled for target ${TARGET}")
	endif()
endfunction()


# ! cmt_target_enable_all_warnings Enable all warnings for the major compilers in the target
#
# cmt_target_enable_all_warnings(
#   TARGET
# )
#
# \input TARGET Target to configure
#
function(cmt_target_enable_effective_cxx_warnings TARGET)
	cmt_ensure_target(${TARGET})
    cmt_define_compiler()
	if (${CMT_COMPILER} STREQUAL "CLANG")
		cmt_target_add_compiler_option(${TARGET} -Weffc++)
	elseif (${CMT_COMPILER}  STREQUAL "GNU")
		cmt_target_add_compiler_option(${TARGET} -Weffc++)
	else()
		cmt_warn("Cannot enable effective c++ check on non gnu/clang compiler.")
	endif()
endfunction()

# ! cmt_target_enable_generation_header_dependencies Generates .d files with header dependencies
#
# cmt_target_enable_generation_header_dependencies(
#   TARGET
# )
#
# \input TARGET Target to configure
#
function(cmt_target_enable_generation_header_dependencies TARGET)
    cmt_ensure_target(${TARGET}) 
    cmt_define_compiler()
	if (${CMT_COMPILER}  STREQUAL "CLANG")
		cmt_target_add_compiler_option(${TARGET}  -MD)
	elseif (${CMT_COMPILER}  STREQUAL "GNU")
		cmt_target_add_compiler_option(${TARGET}  -MD)
	else()
		cmt_warn("Cannot generate header dependency on non GCC/Clang compilers.")
	endif()
endfunction()

# ! cmt_target_enable_lto
# Checks for, and enables IPO/LTO for the specified target
#
# cmt_target_enable_lto(
#   TARGET
# )
#
# \input TARGET The target to enable link-time-optimization
# \option REQUIRED - If this is passed in, CMake configuration will fail with an error if LTO/IPO is not supported
#
function(cmt_target_enable_lto TARGET)
    cmake_parse_arguments(LTO "REQUIRED" "" "" ${ARGN})
    cmt_ensure_target(${TARGET})
    check_ipo_supported(RESULT IPO_RESULT OUTPUT IPO_OUTPUT LANGUAGES CXX)
    if (IPO_RESULT)
        set_property(TARGET ${TARGET} PROPERTY INTERPROCEDURAL_OPTIMIZATION ON)
    else()
        if(LTO_REQUIRED)
            cmt_fatal("LTO not supported, but listed as REQUIRED: ${IPO_OUTPUT}")
        else()
            cmt_warning("LTO not supported: ${IPO_OUTPUT}")
        endif()
    endif()
endfunction()

# ! cmt_target_disable_warnings
# Disable warnings for the specified target.
#
# cmt_target_disable_warnings(
#   TARGET
# )
#
# \input TARGET Target to configure
#
function(cmt_target_disable_warnings TARGET)
	cmt_ensure_target(${TARGET})
	cmt_define_compiler()
	if (${CMT_COMPILER}  STREQUAL "MVSC")
		cmt_target_add_compiler_option(${TARGET} /W0)
	elseif(${CMT_COMPILER}  STREQUAL "GCC")
		cmt_target_add_compiler_option(${TARGET} --no-warnings)
	elseif(${CMT_COMPILER}  STREQUAL "CLANG")
		cmt_target_add_compiler_option(${TARGET} -Wno-everything)
	else()
		cmt_warn("Unsupported compiler (${CMAKE_CXX_COMPILER_ID}), warnings not disabled for ${TARGET}")
	endif()
	cmt_debug("${TARGET}: disabled warnings")
endfunction()

# ! cmt_target_set_ide_directory
# Set target directory for IDEs.
#
# cmt_target_set_ide_directory(
#   TARGET
#   DIRECTORY
# )
#
# \input TARGET The target to configure
# \input DIRECTORY The directory to set
#
function(cmt_target_set_ide_directory TARGET DIRECTORY)
	cmt_ensure_target(${TARGET})
	set_target_properties(${TARGET} PROPERTIES FOLDER ${DIRECTORY})
endfunction()

# ! cmt_target_source_group(target root)
# Group sources of target relatively to the specified root to keep structure of source groups
# analogically to the actual files and directories structure in the project.
#
# cmt_target_source_group(
#   TARGET
#   ROOT
# )
#
# \input TARGET TARGET The target to configure
# \input ROOT ROOT The root directory to group sources relatively to
#
function(cmt_target_source_group TARGET ROOT)
	cmt_ensure_target(${TARGET})
	get_property(TARGET_SOURCES ${TARGET} PROPERTY SOURCES)
	source_group(TREE ${ROOT} FILES ${TARGET_SOURCES})
endfunction()


# ! cmt_interface_target_generate_headers_target
# Generate a "headers" target with the headers of the interface include directories of the given
# interface target as sources.
# The target will be visible in IDEs, enabling to browse headers of the interface / header-only target.
#
# cmt_interface_target_generate_headers_target(
#   TARGET
#   HEADER_TARGET
# )
#
# \input TARGET The target to configure
# \input HEADER_TARGET Name of the "headers" target to generate
#
function(cmt_interface_target_generate_headers_target TARGET HEADER_TARGET)
	cmt_ensure_target(${TARGET})
	get_property(TARGET_INCLUDE_DIRECTORIES ${TARGET} PROPERTY INTERFACE_INCLUDE_DIRECTORIES)
	cmt_get_headers(HEADERS RECURSE ${TARGET_INCLUDE_DIRECTORIES})
	add_custom_target(${HEADER_TARGET} SOURCES ${HEADERS})
	cmt_debug("${TARGET}: Generated header target ${ARGS_HEADER_TARGET}")
endfunction()

# ! cmt_target_print_compiler_options
# Print linker options for a target
#
# cmt_target_print_compiler_options(
#   TARGET
# 	[CONFIG <config1> <config2>...]
# )
#
# \input TARGET The target to configure
# \group CONFIG Configs for the property to change (Debug Release RelWithDebInfo MinSizeRel)
#
function(cmt_target_print_compiler_options TARGET)
    cmake_parse_arguments(ARGS "" "" "CONFIG" ${ARGN})
    cmt_ensure_target(${TARGET})

	cmt_debug("Target ${TARGET} Compiler Options:")
	macro(cmt_print_list title list)
		cmt_status("  > ${title}:")
		foreach(element ${${list}})
			cmt_debug("    - ${element}")
		endforeach()
	endmacro()


	get_target_property(COMPILE_DEFINITIONS ${TARGET} COMPILE_DEFINITIONS)
	get_target_property(COMPILE_OPTIONS ${TARGET} COMPILE_OPTIONS)
	cmt_print_list("COMPILE_DEFINITIONS" COMPILE_DEFINITIONS)
	cmt_print_list("COMPILE_OPTIONS" COMPILE_OPTIONS)
endfunction()


# ! cmt_target_print_linker_options
# Print compiler options for a target
#
# cmt_target_print_linker_options(
#   TARGET
# 	[CONFIG <config1> <config2>...]
# )
#
# \input TARGET The target to configure
# \group CONFIG Configs for the property to change (Debug Release RelWithDebInfo MinSizeRel)
#
function(cmt_target_print_linker_options TARGET)
    cmake_parse_arguments(ARGS "" "" "CONFIG" ${ARGN})
    cmt_ensure_target(${TARGET}) 

	cmt_debug("Target ${TARGET} Linker Options:")
	macro(cmt_print_list title list)
		if (NOT ${list})
			return()
		endif()

		cmt_status("  > ${title}:")
		foreach(element ${${list}})
			cmt_debug("    - ${element}")
		endforeach()
	endmacro()

	get_target_property(LINK_OPTIONS ${TARGET} LINK_OPTIONS)
	get_target_property(LINK_FLAGS ${TARGET} LINK_FLAGS)
	cmt_print_list("LINK_OPTIONS" LINK_OPTIONS)
	cmt_print_list("LINK_FLAGS" LINK_FLAGS)
    if(NOT DEFINED ARGS_CONFIG)
        string(TOUPPER ${CMAKE_BUILD_TYPE} config)
        get_target_property(LINK_FLAGS_${config} ${TARGET} LINK_FLAGS_${config})
		cmt_print_list("LINK_FLAGS_${config}" LINK_FLAGS_${config})
    else()
        foreach(config ${ARGS_CONFIG})
            cmt_ensure_config(${config})
            string(TOUPPER ${config} config)
			get_target_property(LINK_FLAGS_${config} ${TARGET} LINK_FLAGS_${config})
			cmt_print_list("LINK_FLAGS_${config}" LINK_FLAGS_${config})
        endforeach()
    endif()
endfunction()


function (cmt_target_register TARGET GLOBAL)
	cmake_parse_arguments(ARGS "ALL;DEFAULT" "" "" ${ARGN})
	cmt_ensure_target(${TARGET})

	cmt_boolean(EXCLUDE_FROM_ALL NOT ARGS_ALL)
	cmt_boolean(EXCLUDE_FROM_DEFAULT NOT ARGS_DEFAULT)
	set_target_properties(${TARGET} PROPERTIES EXCLUDE_FROM_ALL ${EXCLUDE_FROM_ALL} EXCLUDE_FROM_DEFAULT_BUILD ${EXCLUDE_FROM_DEFAULT})
	if (NOT TARGET ${GLOBAL})
		add_custom_target(${GLOBAL})
	endif()
	add_dependencies(${GLOBAL} ${TARGET})
endfunction()