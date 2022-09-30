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
# - cmt_target_configure_gcc_compiler_options
# - cmt_target_configure_clang_compiler_options
# - cmt_target_configure_msvc_compiler_options
# - cmt_target_configure_compiler_options
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
#   [TARGET <target>]
#   [PROPERTY <property>]
#   [PROPERTIES <appen1> <append2> ...]
# )
#
# \param:TARGET TARGET Specifies the target to which the property will be appended.
# \param:PROPERTY PROPERTY Specifies the property to be appended.
# \param:PROPERTIES PROPERTIES Specifies the values to be appended to the property.
#
function(cmt_append_to_target_property)
    cmake_parse_arguments(ARGS "" "TARGET;PROPERTY" "PROPERTIES" ${ARGN})
    cmt_required_arguments(FUNCTION cmt_append_to_target_property PREFIX ARGS FIELDS TARGET PROPERTY PROPERTIES)

	get_target_property(EXISTING_PROPERTIES ${ARGS_TARGET} ${ARGS_PROPERTY})
	if (EXISTING_PROPERTIES)
		set(EXISTING_PROPERTIES "${EXISTING_PROPERTIES} ${ARGS_PROPERTIES}")
	endif()
	set_target_properties(${ARGS_TARGET} PROPERTIES ${ARGS_PROPERTY} ${EXISTING_PROPERTIES})
endfunction()


# ! cmt_target_add_compile_definition Add a private compile definition to the target for the specified configs.
#
# cmt_target_add_compile_definition(
#   [TARGET <target>]
#   [DEFINITION <definition>]
#   [COMPILER <compiler>]
#   [CONFIG <config1> <config2>...]
# )
#
# \paramTARGET TARGET Target to add flag
# \paramDEFINITION DEFINITION Definition to add
# \groupCONFIG CONFIG Configs for the property to change (Debug Release RelWithDebInfo MinSizeRel)
function(cmt_target_add_compile_definition)
    cmake_parse_arguments(ARGS "" "TARGET;DEFINITION;COMPILER" "CONFIG" ${ARGN})
	cmt_required_arguments(FUNCTION cmt_target_add_compile_definition PREFIX ARGS FIELDS TARGET DEFINITION)
    cmt_ensure_targets(FUNCTION cmt_target_add_compile_definition TARGETS ${ARGS_TARGET}) 

	if (DEFINED ARGS_COMPILER)
        cmt_define_compiler()
        if (NOT ${CMT_COMPILER} STREQUAL ${ARGS_COMPILER})
            return()
        endif()
    endif()

	if (DEFINED ARGS_CONFIG)
        cmt_choice_arguments(FUNCTION cmt_add_compiler_options PREFIX ARGS CHOICE CONFIG OPTIONS "Debug" "Release" "RelWithDebInfo" "MinSizeRel" )
    	foreach(config ${ARGS_CONFIG})
			string(TOUPPER ${config} config)
			target_compile_definitions(${ARGS_TARGET} PRIVATE "$<$<CONFIG:${config}>:${ARGS_DEFINITION}>")
		endforeach()
	else()
		target_compile_definitions(${ARGS_TARGET} PRIVATE "${ARGS_DEFINITION}")
	endif()
endfunction()


# ! cmt_target_add_compiler_option Add a flag to the compiler arguments of the target for the specified language and configs.
# Add the flag only if the compiler support it (checked with CHECK_<LANG>_COMPILER_FLAG).
#
# cmt_target_add_compiler_option(
#   [LANG <lang>]
#   [TARGET <target>]
#   [OPTION <option>]
#   [COMPILER <compiler>]
#   [CONFIG <config1> <config2>...]
# )
#
# \paramTARGET TARGET Target to add flag
# \paramLANG LANG Language of the flag (C|CXX)
# \paramOPTION OPTION Compiler flag to add
# \groupCONFIG CONFIG Configs for the property to change (Debug Release RelWithDebInfo MinSizeRel)
function(cmt_target_add_compiler_option)
    cmake_parse_arguments(ARGS "" "TARGET;LANG;OPTION;COMPILER" "CONFIG" ${ARGN})
	cmt_required_arguments(FUNCTION cmt_target_add_compiler_option PREFIX ARGS FIELDS TARGET OPTION)
    cmt_ensure_targets(FUNCTION cmt_target_add_compiler_option TARGETS ${ARGS_TARGET}) 

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
		cmt_check_compiler_option(has${ARGS_OPTION} OPTION ${ARGS_OPTION} LANG ${lang})
		if(has${ARGS_OPTION})
			if (DEFINED ARGS_CONFIG)
				foreach(config ${ARGS_CONFIG})
					cmt_ensure_config(${config})
					string(TOUPPER ${config} config)
					target_compile_options(${ARGS_TARGET} PRIVATE "$<$<AND:$<COMPILE_LANGUAGE:${lang}>,$<CONFIG:${config}>>:${ARGS_OPTION}>")
				endforeach()
			else()
				target_compile_options(${ARGS_TARGET} PRIVATE "$<$<COMPILE_LANGUAGE:${lang}>:${ARGS_OPTION}>")
			endif()
		else()
			cmt_log("${ARGS_TARGET}: flag ${ARGS_OPTION} was reported as unsupported by ${lang} compiler and was not added")
		endif()
	endforeach()
endfunction()

# ! cmt_target_add_c_compiler_option Add a flag to C the compiler arguments of the target for the specified language and configs.
# Add the flag only if the compiler support it (checked with CHECK_C_COMPILER_FLAG).
#
# cmt_target_add_c_compiler_option(
#   [TARGET <target>]
#   [OPTION <option>]
#   [COMPILER <compiler>]
#   [CONFIG <config1> <config2>...]
# )
#
# \paramTARGET TARGET Target to add flag
# \paramOPTION OPTION Compiler flag to add
# \groupCONFIG CONFIG Configs for the property to change (÷ RelWithDebInfo MinSizeRel)
macro(cmt_target_add_c_compiler_option)
	cmt_target_add_compiler_option(LANGUAGE C ${ARGN})
endmacro()

# ! cmt_target_add_cxx_compiler_option Add a flag to C the compiler arguments of the target for the specified language and configs.
# Add the flag only if the compiler support it (checked with CHECK_C_COMPILER_FLAG).
# cmt_target_add_cxx_compiler_option(
#   [TARGET <target>]
#   [OPTION <option>]
#   [COMPILER <compiler>]
#   [CONFIG <config1> <config2>...]
# )
#
# \paramTARGET TARGET Target to add flag
# \paramOPTION OPTION Compiler flag to add
# \groupCONFIG CONFIG Configs for the property to change (Debug Release RelWithDebInfo MinSizeRel)
macro(cmt_target_add_cxx_compiler_option)
	cmt_target_add_compiler_option(LANGUAGE CXX ${ARGN})
endmacro()

# ! cmt_target_add_compiler_options Add flags to the compiler arguments of the target for the specified language and configs.
# Add the flags only if the compiler support it (checked with CHECK_<LANG>_COMPILER_FLAG).
#
# cmt_target_add_compiler_options(
#   [LANG <lang>]
#   [TARGET <target>]
#   [COMPILER <compiler>]
#   [OPTIONS <option1> <option2>...]
#   [CONFIG <config1> <config2>...]
# )
#
# \paramTARGET TARGET Target to add flag
# \paramLANG LANG Language of the flag (C|CXX)
# \groupOPTIONs OPTIONs Compiler flags to add
# \groupCONFIG CONFIG Configs for the property to change (Debug Release RelWithDebInfo MinSizeRel)
function(cmt_target_add_compiler_options)
    cmake_parse_arguments(ARGS "" "TARGET;LANG" "CONFIG;OPTIONS" ${ARGN})
	cmt_required_arguments(FUNCTION cmt_target_add_compiler_options PREFIX ARGS FIELDS TARGET OPTIONS)
    cmt_ensure_targets(FUNCTION cmt_target_add_compiler_options TARGETS ${ARGS_TARGET}) 

    if (DEFINED ARGS_COMPILER)
        cmt_define_compiler()
        if (NOT ${CMT_COMPILER} STREQUAL ${ARGS_COMPILER})
            return()
        endif()
    endif()

	if (DEFINED ARGS_LANG)
	    cmt_ensure_lang(${ARGS_LANG})
		if (DEFINED ARGS_CONFIG)
			foreach (option ${ARGS_OPTIONS})
				cmt_target_add_compiler_option(TARGET ${ARGS_TARGET} LANG ${ARGS_LANG} CONFIG ${ARGS_CONFIG} OPTION ${option})
			endforeach()
		else()
			foreach (option ${ARGS_OPTIONS})
				cmt_target_add_compiler_option(TARGET ${ARGS_TARGET} LANG ${ARGS_LANG} OPTION ${option})
			endforeach()
		endif()
	else()
		if (DEFINED ARGS_CONFIG)
			foreach (option ${ARGS_OPTIONS})
				cmt_target_add_compiler_option(TARGET ${ARGS_TARGET} CONFIG ${ARGS_CONFIG} OPTION ${option})
			endforeach()
		else()
			foreach (option ${ARGS_OPTIONS})
				cmt_target_add_compiler_option(TARGET ${ARGS_TARGET} OPTION ${option})
			endforeach()
		endif()
	endif()

endfunction()

# ! cmt_target_add_c_compiler_options Add a flag to C the compiler arguments of the target for the specified language and configs.
# Add the flag only if the compiler support it (checked with CHECK_C_COMPILER_FLAG).
#
# cmt_target_add_c_compiler_options(
#   [TARGET <target>]
#   [COMPILER <compiler>]
#   [OPTIONS <option1> <option2>...]
#   [CONFIG <config1> <config2>...]
# )
#
# \paramTARGET TARGET Target to add flag
# \groupOPTIONs OPTIONs Compiler flags to add
# \groupCONFIG CONFIG Configs for the property to change (Debug Release RelWithDebInfo MinSizeRel)
macro(cmt_target_add_c_compiler_options)
	cmt_target_add_compiler_options(LANGUAGE C ${ARGN})
endmacro()

# ! cmt_target_add_cxx_compiler_options Add a flag to C the compiler arguments of the target for the specified language and configs.
# Add the flag only if the compiler support it (checked with CHECK_C_COMPILER_FLAG).
#
# cmt_target_add_cxx_compiler_options(
#   [TARGET <target>]
#   [COMPILER <compiler>]
#   [OPTIONS <option1> <option2>...]
#   [CONFIG <config1> <config2>...]
# )
#
# \paramTARGET TARGET Target to add flag
# \paramOPTION OPTION Compiler flag to add
# \groupCONFIG CONFIG Configs for the property to change (Debug Release RelWithDebInfo MinSizeRel)
macro(cmt_target_add_cxx_compiler_options)
	cmt_target_add_compiler_options(LANGUAGE CXX ${ARGN})
endmacro()


# ! cmt_target_add_linker_option Add flags to the linker arguments of the target for the specified language and configs.
# Add the flags only if the linker support it (checked with CHECK_<LANG>_COMPILER_FLAG).
#
# cmt_target_add_linker_option(
#   [LANG <lang>]
#   [TARGET <target>]
#   [COMPILER <compiler>]
#   [OPTION <option>]
#   [CONFIG <config1> <config2>...]
# )
#
# \paramTARGET TARGET Target to add flag
# \paramLANG LANG Language of the flag (C|CXX)
# \paramOPTION OPTION Linker flag to add
# \groupCONFIG CONFIG Configs for the property to change (Debug Release RelWithDebInfo MinSizeRel)
function(cmt_target_add_linker_option)
    cmake_parse_arguments(ARGS "" "TARGET;LANG;OPTION;COMPILER" "CONFIG" ${ARGN})
	cmt_required_arguments(FUNCTION cmt_target_add_linker_option PREFIX ARGS FIELDS TARGET OPTION)
    cmt_ensure_targets(FUNCTION cmt_target_add_linker_option TARGETS ${ARGS_TARGET}) 

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
		cmt_check_linker_option(has${ARGS_OPTION} OPTION ${ARGS_OPTION} LANG ${lang})
		if(has${ARGS_OPTION})
			if (DEFINED ARGS_CONFIG)
				cmt_choice_arguments(FUNCTION cmt_add_compiler_options PREFIX ARGS CHOICE CONFIG OPTIONS "Debug" "Release" "RelWithDebInfo" "MinSizeRel" )
				foreach(config ${ARGS_CONFIG})
					cmt_ensure_config(${config})
					string(TOUPPER ${config} config)
					target_link_options(${ARGS_TARGET} PRIVATE "$<$<AND:$<COMPILE_LANGUAGE:${lang}>,$<CONFIG:${config}>>:${ARGS_OPTION}>")
				endforeach()
			else()
				target_link_options(${ARGS_TARGET} PRIVATE "$<$<COMPILE_LANGUAGE:${lang}>:${ARGS_OPTION}>")
			endif()
		else()
			cmt_log("${ARGS_TARGET}: flag ${ARGS_OPTION} was reported as unsupported by ${lang} linker and was not added")
		endif()
	endforeach()
endfunction()

# ! cmt_target_add_linker_option Add flags to the C linker arguments of the target for the specified language and configs.
# Add the flags only if the linker support it (checked with CHECK_C_COMPILER_FLAG).
#
# cmt_target_add_linker_option(
#   [TARGET <target>]
#   [OPTION <option>]
#   [COMPILER <compiler>]
#   [CONFIG <config1> <config2>...]
# )
#
# \paramTARGET TARGET Target to add flag
# \paramOPTION OPTION Linker flag to add
# \groupCONFIG CONFIG Configs for the property to change (Debug Release RelWithDebInfo MinSizeRel)
macro(cmt_target_add_c_linker_option)
	cmt_target_add_linker_option(LANGUAGE C ${ARGN})
endmacro()

# ! cmt_target_add_linker_option Add flags to the CXX linker arguments of the target for the specified language and configs.
# Add the flags only if the linker support it (checked with CHECK_CXX_COMPILER_FLAG).
# cmt_target_add_linker_option(
#   [TARGET <target>]
#   [OPTION <option>]
#   [COMPILER <compiler>]
#   [CONFIG <config1> <config2>...]
# )
#
# \paramTARGET TARGET Target to add flag
# \paramOPTION OPTION Linker flag to add
# \groupCONFIG CONFIG Configs for the property to change (Debug Release RelWithDebInfo MinSizeRel)
macro(cmt_target_add_cxx_linker_option)
	cmt_target_add_linker_option(LANGUAGE CXX ${ARGN})
endmacro()

# ! cmt_target_add_linker_optionss Add flags to the linker arguments of the target for the specified language and configs.
# Add the flags only if the linker support it (checked with CHECK_<LANG>_COMPILER_FLAG).
#
# cmt_target_add_linker_options(
#   [LANG <lang>]
#   [TARGET <target>]
#   [COMPILER <compiler>]
#   [OPTIONS <option1 <option2>...]
#   [CONFIG <config1> <config2>...]
# )
#
# \paramTARGET TARGET Target to add flag
# \paramLANG LANG Language of the flag (C|CXX)
# \groupOPTIONS OPTIONS Linker flags to add
# \groupCONFIG CONFIG Configs for the property to change (Debug Release RelWithDebInfo MinSizeRel)
function(cmt_target_add_linker_options)
    cmake_parse_arguments(ARGS "" "TARGET;LANG;COMPILER" "CONFIG;OPTIONS" ${ARGN})
	cmt_required_arguments(FUNCTION cmt_target_add_linker_option PREFIX ARGS FIELDS TARGET OPTIONS)
    cmt_ensure_targets(FUNCTION cmt_target_add_linker_option TARGETS ${ARGS_TARGET}) 

    if (DEFINED ARGS_COMPILER)
        cmt_define_compiler()
        if (NOT ${CMT_COMPILER} STREQUAL ${ARGS_COMPILER})
            return()
        endif()
    endif()

	if (DEFINED ARGS_LANG)
	    cmt_ensure_lang(${ARGS_LANG})
		if (DEFINED ARGS_CONFIG)
			foreach (option ${ARGS_OPTIONS})
				cmt_target_add_linker_option(TARGET ${ARGS_TARGET} LANG ${ARGS_LANG} CONFIG ${ARGS_CONFIG} OPTION ${option})
			endforeach()
		else()
			foreach (option ${ARGS_OPTIONS})
				cmt_target_add_linker_option(TARGET ${ARGS_TARGET} LANG ${ARGS_LANG} OPTION ${option})
			endforeach()
		endif()
	else()
		if (DEFINED ARGS_CONFIG)
			foreach (option ${ARGS_OPTIONS})
				cmt_target_add_linker_option(TARGET ${ARGS_TARGET} CONFIG ${ARGS_CONFIG} OPTION ${option})
			endforeach()
		else()
			foreach (option ${ARGS_OPTIONS})
				cmt_target_add_linker_option(TARGET ${ARGS_TARGET} OPTION ${option})
			endforeach()
		endif()
	endif()

endfunction()

# ! cmt_target_add_linker_option Add flags to the C linker arguments of the target for the specified language and configs.
# Add the flags only if the linker support it (checked with CHECK_C_COMPILER_FLAG).
#
# cmt_target_add_linker_option(
#   [TARGET <target>]
#   [OPTIONS <option1> <option2>...]
#   [COMPILER <compiler>]
#   [CONFIG <config1> <config2>...]
# )
#
# \paramTARGET TARGET Target to add flag
# \groupOPTIONS OPTIONS Linker flags to add
# \groupCONFIG CONFIG Configs for the property to change (Debug Release RelWithDebInfo MinSizeRel)
macro(cmt_target_add_c_linker_options)
	cmt_target_add_linker_options(LANGUAGE C ${ARGN})
endmacro()

# ! cmt_target_add_linker_options Add flags to the CXX linker arguments of the target for the specified language and configs.
# Add the flags only if the linker support it (checked with CHECK_CXX_COMPILER_FLAG).
#
# cmt_target_add_linker_option(
#   [TARGET <target>]
#   [OPTIONS <option1> <option2>...]
#   [COMPILER <compiler>]
#   [CONFIG <config1> <config2>...]
# )
#
# \paramTARGET TARGET Target to add flag
# \groupOPTIONS OPTIONS Linker flags to add
# \groupCONFIG CONFIG Configs for the property to change (Debug Release RelWithDebInfo MinSizeRel)
macro(cmt_target_add_cxx_linker_options)
	cmt_target_add_linker_options(LANGUAGE CXX ${ARGN})
endmacro()


# ! cmt_target_set_standard 
# ASet the target language standard to use, also set the standard as required and disable compiler extensions.
#
# cmt_target_set_standard(
#   REQUIRED | EXTENSIONS
#   [C <c_std>] (90|99|11|17|23)
#   [CXX <cxx_std>] (98|11|14|17|20|23)
#   [TARGET <target>]
# )
#
# \paramTARGET TARGET Target to set standards
# \paramC C C standard to use
# \paramCXX CXX CXX standard to use
function(cmt_target_set_standard)
    cmake_parse_arguments(ARGS "REQUIRED;EXTENSIONS" "TARGET;C;CXX" "" ${ARGN})
	cmt_required_arguments(FUNCTION cmt_target_set_standard PREFIX ARGS FIELDS TARGET)
	cmt_one_of_arguments(FUNCTION cmt_target_set_standard PREFIX ARGS FIELDS C CXX)
    cmt_ensure_targets(FUNCTION cmt_target_set_standard TARGETS ${ARGS_TARGET}) 

	if (DEFINED ARGS_C)
		cmt_choice_arguments(FUNCTION cmt_target_set_standard PREFIX ARGS CHOICE C OPTIONS "90" "99" "11" "17" "23")
		#target_compile_features(${ARGS_TARGET} PUBLIC c_std_${ARGS_C})
		#target_compile_options(${ARGS_TARGET} PUBLIC "$<$<COMPILE_LANGUAGE:C>:${ARGS_C}>")
		set_target_properties(
			${ARGS_TARGET} PROPERTIES
			C_STANDARD ${ARGS_C}
			C_STANDARD_REQUIRED DEFINED ARGS_REQUIRED
			C_EXTENSIONS DEFINED ARGS_EXTENSIONS
		)
	endif()

	if (DEFINED ARGS_CXX)
		cmt_choice_arguments(FUNCTION cmt_target_set_standard PREFIX ARGS CHOICE CXX OPTIONS "98" "11" "14" "17" "20" "23")
		#target_compile_features(${ARGS_TARGET} PUBLIC cxx_std_${ARGS_CXX})
		#target_compile_options(${ARGS_TARGET} PUBLIC "$<$<COMPILE_LANGUAGE:CXX>:${ARGS_CXX}>")
		set_target_properties(
			${ARGS_TARGET} PROPERTIES
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
#   [TARGET <target>]
#   [RUNTIME <runtime_directory>]
#   [LIBRARY <library_directory>]
#   [ARCHIVE <archive_directory>]
#   [DIRECTORY <directory>] (if not defined, it uses this values for runtime, library and archive output directory)
# )
#
# \paramTARGET TARGET Target to set output directories
# \paramRUNTIME RUNTIME Runtime output directory
# \paramLIBRARY LIBRARY Library output directory
# \paramARCHIVE ARCHIVE Archive output directory
# \paramDIRECTORY DIRECTORY By default, used for the ones not provided
function(cmt_target_set_output_directory)
    cmake_parse_arguments(ARGS "" "TARGET;RUNTIME;LIBRARY;ARCHIVE;DIRECTORY" "" ${ARGN})
	cmt_required_arguments(FUNCTION cmt_target_set_output_directory PREFIX ARGS FIELDS TARGET)
	cmt_one_of_arguments(FUNCTION cmt_target_set_output_directory PREFIX ARGS FIELDS RUNTIME LIBRARY ARCHIVE DIRECTORY)
    cmt_ensure_targets(FUNCTION cmt_target_set_output_directory TARGETS ${ARGS_TARGET}) 
	cmt_default_argument(FUNCTION cmt_target_set_output_directory PREFIX ARGS FIELD RUNTIME VALUE ${ARGS_DIRECTORY})
	cmt_default_argument(FUNCTION cmt_target_set_output_directory PREFIX ARGS FIELD LIBRARY VALUE ${ARGS_DIRECTORY})
	cmt_default_argument(FUNCTION cmt_target_set_output_directory PREFIX ARGS FIELD ARCHIVE VALUE ${ARGS_DIRECTORY})

	foreach(type IN ITEMS RUNTIME LIBRARY ARCHIVE)
		if (NOT ${ARGS_${type}} STREQUAL "")
			set_target_properties(${ARGS_TARGET} PROPERTIES ${type}_OUTPUT_DIRECTORY ${ARGS_${type}})
			foreach(mode IN ITEMS DEBUG RELWITHDEBINFO RELEASE)
				set_target_properties(${ARGS_TARGET} PROPERTIES ${type}_OUTPUT_DIRECTORY_${mode} ${ARGS_${type}})
			endforeach()
		endif()
	endforeach()
endfunction()

# ! cmt_target_set_output_directories 
# Set the target runtime, library and archive output directory to classic folders build/bin and build/bin.
#
# cmt_target_set_output_directories(
#   [TARGET <target>]
# )
#
# \paramTARGET TARGET Target to set output directories
macro(cmt_target_set_output_directories)
	cmt_target_set_output_directory(
		${ARGN}
		RUNTIME "${CMAKE_CURRENT_BINARY_DIR}/build/bin"
		LIBRARY "${CMAKE_CURRENT_BINARY_DIR}/build/lib"
		ARCHIVE "${CMAKE_CURRENT_BINARY_DIR}/build/lib"
	)
endmacro()

# ! cmt_target_set_runtime_output_directory 
# Set the target runtime output directory.
#
# cmt_target_set_runtime_output_directory(
#   [TARGET <target>]
#   [DIRECTORY <directory>]
# )
#
# \paramTARGET TARGET Target to configure
# \paramDIRECTORY DIRECTORY Output directory
function(cmt_target_set_runtime_output_directory)
    cmake_parse_arguments(ARGS "" "TARGET;DIRECTORY" "" ${ARGN})
	cmt_required_arguments(FUNCTION cmt_target_set_runtime_output_directory PREFIX ARGS FIELDS TARGET DIRECTORY)
	cmt_target_set_output_directory(${ARGS_TARGET} RUNTIME "${ARGS_DIRECTORY}")
endfunction()

# ! cmt_target_set_library_output_directory 
# Set the target library output directory.
#
# cmt_target_set_library_output_directory(
#   [TARGET <target>]
#   [DIRECTORY <directory>]
# )
#
# \paramTARGET TARGET Target to configure
# \paramDIRECTORY DIRECTORY Output directory
function(cmt_target_set_library_output_directory)
    cmake_parse_arguments(ARGS "" "TARGET;DIRECTORY" "" ${ARGN})
	cmt_required_arguments(FUNCTION cmt_target_set_library_output_directory PREFIX ARGS FIELDS TARGET DIRECTORY)
	cmt_target_set_output_directory(${ARGS_TARGET} LIBRARY "${ARGS_DIRECTORY}")
endfunction()

# ! cmt_target_set_archive_output_directory 
# Set the target archive output directory.
#
# cmt_target_set_archive_output_directory(
#   [TARGET <target>]
#   [DIRECTORY <directory>]
# )
#
# \paramTARGET TARGET Target to configure
# \paramDIRECTORY DIRECTORY Output directory
function(cmt_target_set_archive_output_directory)
    cmake_parse_arguments(ARGS "" "TARGET;DIRECTORY" "" ${ARGN})
	cmt_required_arguments(FUNCTION cmt_target_set_archive_output_directory PREFIX ARGS FIELDS TARGET DIRECTORY)
	cmt_target_set_output_directory(${ARGS_TARGET} ARCHIVE "${ARGS_DIRECTORY}")
endfunction()


# ! cmt_target_configure_gcc_compiler_options 
# Configure gcc compile oprions for the target like debug informations, optimisation...
#
# cmt_target_configure_gcc_compiler_options(
#   [TARGET <target>]
# )
#
# \paramTARGET TARGET Target to configure
function(cmt_target_configure_gcc_compiler_options)
	cmake_parse_arguments(ARGS "" "TARGET" "" ${ARGN})
	cmt_required_arguments(FUNCTION cmt_target_configure_gcc_compiler_options PREFIX ARGS FIELDS TARGET)
	cmt_define_compiler()
	if (NOT CMT_COMPILER MATCHES "GCC")
		cmt_warn("cmt_target_configure_gcc_compiler_options: target ${ARGS_TARGET} is not a gcc target")
		return()
	endif()

	cmt_target_add_compiler_option(TARGET ${ARGS_TARGET} OPTION "-g3" CONFIG Debug RelWithDebInfo)
	cmt_target_add_compiler_option(TARGET ${ARGS_TARGET} OPTION "-O0" CONFIG Debug)
	cmt_target_add_compiler_option(TARGET ${ARGS_TARGET} OPTION "-O2" CONFIG RelWithDebInfo)
	cmt_target_add_compiler_option(TARGET ${ARGS_TARGET} OPTION "-O3" CONFIG Release)
	cmt_target_add_compile_definition(TARGET ${ARGS_TARGET} DEFINITION "NDEBUG" CONFIG Release)
	cmt_log("${ARGS_TARGET}: configured gcc options")
endfunction()

# ! cmt_target_configure_clang_compiler_options 
# Configure clang compile oprions for the target like debug informations, optimisation...
#
# cmt_target_configure_clang_compiler_options(
#   [TARGET <target>]
# )
#
# \paramTARGET TARGET Target to configure
function(cmt_target_configure_clang_compiler_options)
	cmake_parse_arguments(ARGS "" "TARGET" "" ${ARGN})
	cmt_required_arguments(FUNCTION cmt_target_configure_clang_compiler_options PREFIX ARGS FIELDS TARGET)
	cmt_define_compiler()
	if (NOT CMT_COMPILER MATCHES "CLANG")
		cmt_warn("cmt_target_configure_clang_compiler_options: target ${ARGS_TARGET} is not a clang target")
		return()
	endif()

	cmt_target_add_compiler_option(TARGET ${ARGS_TARGET} OPTION -g3 CONFIG Debug RelWithDebInfo)
	cmt_target_add_compiler_option(TARGET ${ARGS_TARGET} OPTION -O0 CONFIG Debug)
	cmt_target_add_compiler_option(TARGET ${ARGS_TARGET} OPTION -O2 CONFIG RelWithDebInfo)
	cmt_target_add_compiler_option(TARGET ${ARGS_TARGET} OPTION -O3 CONFIG Release)
	cmt_target_add_compile_definition(TARGET ${ARGS_TARGET} DEFINITION "NDEBUG" CONFIG Release)
	cmt_log("${ARGS_TARGET}: configured clang options")
endfunction()

# ! cmt_target_configure_msvc_compiler_options 
# Configure MVSC compile oprions for the target like debug informations, optimisation...
#
# cmt_target_configure_msvc_compiler_options(
#   [TARGET <target>]
# )
#
# \paramTARGET TARGET Target to configure
function(cmt_target_configure_msvc_compiler_options target)
	cmake_parse_arguments(ARGS "" "TARGET" "" ${ARGN})
	cmt_required_arguments(FUNCTION cmt_target_configure_clang_compiler_options PREFIX ARGS FIELDS TARGET)
	cmt_define_compiler()
	if (NOT CMT_COMPILER MATCHES "MVSC")
		cmt_warn("cmt_target_configure_msvc_compiler_options: target ${ARGS_TARGET} is not a msvc target")
		return()
	endif()

	cmt_target_add_compiler_options(TARGET ${ARGS_TARGET} OPTIONS /utf-8 /MP)
	cmt_target_add_compiler_options(TARGET ${ARGS_TARGET} OPTIONS /Zi /DEBUG:FULL CONFIG Debug RelWithDebInfo)
	cmt_target_add_compiler_options(TARGET ${ARGS_TARGET} OPTIONS /Od /RTC1 CONFIG Debug)
	cmt_target_add_compiler_options(TARGET ${ARGS_TARGET} OPTIONS /O2 CONFIG RelWithDebInfo)
	cmt_target_add_compiler_options(TARGET ${ARGS_TARGET} OPTIONS /Ox /Qpar CONFIG Release)
	cmt_target_add_linker_options(TARGET ${ARGS_TARGET} OPTIONS /INCREMENTAL:NO /OPT:REF /OPT:ICF /MANIFEST:NO CONFIG Release RelWithDebInfo)
	cmt_target_add_compile_definition(TARGET ${ARGS_TARGET} DEFINITION NDEBUG CONFIG Release)
	cmt_log("${ARGS_TARGET}: configured msvc options")
endfunction()

# ! cmt_target_configure_compiler_options 
# Configure compile options for the target like debug information, optimisation...
#
# cmt_target_configure_compiler_options(
#   [TARGET <target>]
# )
#
# \paramTARGET TARGET Target to configure
function(cmt_target_configure_compiler_options)
	cmt_define_compiler()
	if (CMT_COMPILER MATCHES "MVSC")
		cmt_target_configure_msvc_compiler_options(${ARGN})
	elseif(CMT_COMPILER MATCHES "GCC")
		cmt_target_configure_gcc_compiler_options(${ARGN})
	elseif(CMT_COMPILER MATCHES "CLANG")
		cmt_target_configure_clang_compiler_options(${ARGN})
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
#   STATIC | DYNAMIC
#   [TARGET <target>]
# )
#
# \paramTARGET TARGET Target to configure
# \paramSTATIC STATIC If present, set static run-time
# \paramDYNAMIC DYNAMIC If present, set dynamic run-time
function(cmt_target_set_runtime)
	cmake_parse_arguments(ARGS "STATIC;DYNAMIC" "TARGET" "" ${ARGN})
	cmt_required_arguments(FUNCTION cmt_target_set_runtime PREFIX ARGS FIELDS TARGET)
	cmt_one_of_arguments(FUNCTION cmt_target_set_runtime PREFIX ARGS FIELDS STATIC DYNAMIC)

	cmt_define_compiler()
	if(runtime STREQUAL "STATIC")
		if (CMT_COMPILER MATCHES "MVSC")
			cmt_target_add_linker_option(TARGET ${ARGS_TARGET} OPTION  /MTd CONFIG Debug)
			cmt_target_add_linker_option(TARGET ${ARGS_TARGET} OPTION  /MT CONFIG Release RelWithDebInfo)
		elseif(CMT_COMPILER MATCHES "GCC")
			cmt_target_add_linker_option(TARGET ${ARGS_TARGET} LANG CXX -static-libstdc++)
			cmt_target_add_linker_option(TARGET ${ARGS_TARGET} LANG CXX -static-libgcc)
			cmt_target_add_linker_option(TARGET ${ARGS_TARGET} LANG C -static-libgcc)
		elseif(CMT_COMPILER MATCHES "CLANG")
			cmt_target_add_linker_option(TARGET ${ARGS_TARGET} LANG CXX -static-libstdc++)
			cmt_target_add_linker_option(TARGET ${ARGS_TARGET} LANG CXX -static-libgcc)
			cmt_target_add_linker_option(TARGET ${ARGS_TARGET} LANG C -static-libgcc)
		else()
			cmt_warn("Unsupported compiler (${CMAKE_CXX_COMPILER_ID}), run-time library not forced to static link")
			return()
		endif()
		cmt_log("${ARGS_TARGET}: set static run-time")
	elseif(runtime STREQUAL "DYNAMIC")
		if (CMT_COMPILER MATCHES "MVSC")
			cmt_target_add_linker_option(TARGET ${ARGS_TARGET} OPTION  /MDd CONFIG Debug)
			cmt_target_add_linker_option(TARGET ${ARGS_TARGET} OPTION  /MD CONFIG Release RelWithDebInfo)
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
#   [TARGET <target>]
# )
#
# \param:TARGET TARGET The target to configure
#
function(cmt_target_enable_warnings_as_errors)
    cmake_parse_arguments(ARGS "" "TARGET" "" ${ARGN})
    cmt_required_arguments(FUNCTION cmt_target_enable_warnings_as_errors PREFIX ARGS FIELDS TARGET)
    cmt_ensure_targets(FUNCTION cmt_target_enable_warnings_as_errors TARGETS ${ARGS_TARGET}) 

    cmt_define_compiler()
	if (CMT_COMPILER MATCHES "CLANG")
		cmt_target_add_compiler_option(TARGET ${ARGS_TARGET} OPTION -Werror)
	elseif (CMT_COMPILER MATCHES "GNU")
		cmt_target_add_compiler_option(TARGET ${ARGS_TARGET} OPTION -Werror)
	elseif (CMT_COMPILER MATCHES "MSVC")
		cmt_target_add_compiler_option(TARGET ${ARGS_TARGET} OPTION /WX)
	else()
		cmt_warn("Unsupported compiler (${CMAKE_CXX_COMPILER_ID}), warnings not enabled for target ${ARGS_TARGET}")
	endif()
endfunction()

# ! cmt_target_enable_all_warnings Enable all warnings for the major compilers in the target
#
# cmt_target_enable_all_warnings(
#   [TARGET <target>]
# )
#
# \param:TARGET TARGET The target to configure
#
function(cmt_target_enable_all_warnings)
    cmake_parse_arguments(ARGS "" "TARGET" "" ${ARGN})
    cmt_required_arguments(FUNCTION cmt_target_enable_all_warnings PREFIX ARGS FIELDS TARGET)
    cmt_ensure_targets(FUNCTION cmt_target_enable_all_warnings TARGETS ${ARGS_TARGET}) 

    cmt_define_compiler()
	if (CMT_COMPILER MATCHES "CLANG")
		cmt_target_add_compiler_options(TARGET ${ARGS_TARGET} OPTIONS -Wall -Wextra -Wpedantic)
	elseif (CMT_COMPILER MATCHES "GNU")
		cmt_target_add_compiler_options(TARGET ${ARGS_TARGET}  OPTIONS -Wall -Wextra -Wpedantic -Weverything)
	elseif (CMT_COMPILER MATCHES "MSVC")
		cmt_target_add_compiler_options(TARGET ${ARGS_TARGET} OPTION /W4)
	else()
		cmt_warn("Unsupported compiler (${CMAKE_CXX_COMPILER_ID}), warnings not enabled for target ${ARGS_TARGET}")
	endif()
endfunction()


# ! cmt_target_enable_all_warnings Enable all warnings for the major compilers in the target
#
# cmt_target_enable_all_warnings(
#   [TARGET <target>]
# )
#
# \param:TARGET TARGET The target to configure
#
function(cmt_target_enable_effective_cxx_warnings)
    cmake_parse_arguments(ARGS "" "TARGET" "" ${ARGN})
    cmt_required_arguments(FUNCTION cmt_target_enable_effective_cxx_warnings PREFIX ARGS FIELDS TARGET)
    cmt_ensure_targets(FUNCTION cmt_target_enable_effective_cxx_warnings TARGETS ${ARGS_TARGET}) 

    cmt_define_compiler()
	if (${CMT_COMPILER} STREQUAL "CLANG")
		cmt_target_add_compiler_option(TARGET ${ARGS_TARGET} OPTION -Weffc++)
	elseif (${CMT_COMPILER}  STREQUAL "GNU")
		cmt_target_add_compiler_option(TARGET ${ARGS_TARGET} OPTION -Weffc++)
	else()
		cmt_warn("Cannot enable effective c++ check on non gnu/clang compiler.")
	endif()
endfunction()

# ! cmt_target_enable_generation_header_dependencies Generates .d files with header dependencies
#
# cmt_target_enable_generation_header_dependencies(
#   [TARGET <target>]
# )
#
# \param:TARGET TARGET The target to configure
#
function(cmt_target_enable_generation_header_dependencies)
    cmake_parse_arguments(ARGS "" "TARGET" "" ${ARGN})
    cmt_required_arguments(FUNCTION cmt_target_enable_generation_header_dependencies PREFIX ARGS FIELDS TARGET)
    cmt_ensure_targets(FUNCTION cmt_target_enable_generation_header_dependencies TARGETS ${ARGS_TARGET}) 

    cmt_define_compiler()
	if (${CMT_COMPILER}  STREQUAL "CLANG")
		cmt_target_add_compiler_option(TARGET ${ARGS_TARGET} OPTION  -MD)
	elseif (${CMT_COMPILER}  STREQUAL "GNU")
		cmt_target_add_compiler_option(TARGET ${ARGS_TARGET} OPTION  -MD)
	else()
		cmt_warn("Cannot generate header dependency on non GCC/Clang compilers.")
	endif()
endfunction()


# ! cmt_target_disable_warnings
# Disable warnings for the specified target.
#
# cmt_target_disable_warnings(
#   [TARGET <target>]
# )
#
# \param:TARGET TARGET The target to configure
#
function(cmt_target_disable_warnings)
    cmake_parse_arguments(ARGS "" "TARGET" "" ${ARGN})
    cmt_required_arguments(FUNCTION cmt_target_disable_warnings PREFIX ARGS FIELDS TARGET)
    cmt_ensure_targets(FUNCTION cmt_target_disable_warnings TARGETS ${ARGS_TARGET}) 

	cmt_define_compiler()
	if (${CMT_COMPILER}  STREQUAL "MVSC")
		cmt_target_add_compiler_option(TARGET ${ARGS_TARGET} OPTION /W0)
	elseif(${CMT_COMPILER}  STREQUAL "GCC")
		cmt_target_add_compiler_option(TARGET ${ARGS_TARGET} OPTION --no-warnings)
	elseif(${CMT_COMPILER}  STREQUAL "CLANG")
		cmt_target_add_compiler_option(TARGET ${ARGS_TARGET} OPTION -Wno-everything)
	else()
		cmt_warn("Unsupported compiler (${CMAKE_CXX_COMPILER_ID}), warnings not disabled for ${ARGS_TARGET}")
	endif()
	cmt_log("${ARGS_TARGET}: disabled warnings")
endfunction()

# ! cmt_target_set_ide_directory
# Set target directory for IDEs.
#
# cmt_target_set_ide_folder(
#   [TARGET <target>]
#   [DIRECTORY <directory>]
# )
#
# \param:TARGET TARGET The target to configure
#
function(cmt_target_set_ide_directory)
    cmake_parse_arguments(ARGS "" "TARGET;DIRECTORY" "" ${ARGN})
    cmt_required_arguments(FUNCTION cmt_target_set_ide_directory PREFIX ARGS FIELDS TARGET DIRECTORY)
    cmt_ensure_targets(FUNCTION cmt_target_set_ide_directory TARGETS ${ARGS_TARGET}) 
	set_target_properties(${ARGS_TARGET} PROPERTIES FOLDER ${ARGS_DIRECTORY})
endfunction()

# ! cmt_target_source_group(target root)
# Group sources of target relatively to the specified root to keep structure of source groups
# analogically to the actual files and directories structure in the project.
#
# cmt_target_source_group(
#   [TARGET <target>]
#   [ROOT <root>]
# )
#
# \param:TARGET TARGET The target to configure
# \group:ROOT ROOT The root directory to group sources relatively to
function(cmt_target_source_group)
 	cmake_parse_arguments(ARGS "" "TARGET;ROOT" "" ${ARGN})
    cmt_required_arguments(FUNCTION cmt_target_source_group PREFIX ARGS FIELDS TARGET ROOT)
	get_property(TARGET_SOURCES TARGET ${ARGS_TARGET} PROPERTY SOURCES)
	source_group(TREE ${ARGS_ROOT} FILES ${TARGET_SOURCES})
endfunction()


# ! cmt_interface_target_generate_headers_target
# Generate a "headers" target with the headers of the interface include directories of the given
# interface target as sources.
# The target will be visible in IDEs, enabling to browse headers of the interface / header-only target.
#
# cmt_interface_target_generate_headers_target(
#   [TARGET <target>]
#   [HEADER_TARGET <root>]
# )
#
# \param:TARGET TARGET The target to configure
# \group:HEADER_TARGET HEADER_TARGET Name of the "headers" target to generate
function(cmt_interface_target_generate_headers_target)
 	cmake_parse_arguments(ARGS "" "TARGET;HEADER_TARGET" "" ${ARGN})
    cmt_required_arguments(FUNCTION cmt_target_source_group PREFIX ARGS FIELDS TARGET HEADER_TARGET)

	get_property(TARGET_INCLUDE_DIRECTORIES TARGET ${ARGS_TARGET} PROPERTY INTERFACE_INCLUDE_DIRECTORIES)
	cmt_get_headers(HEADERS RECURSE ${TARGET_INCLUDE_DIRECTORIES})
	add_custom_target(${ARGS_HEADER_TARGET} SOURCES ${HEADERS})
	cmt_log("${ARGS_TARGET}: Generated header target ${ARGS_HEADER_TARGET}")
endfunction()

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
#   ASAN | TSAN | LSAN | UBSAN | MSAN
#   [TARGET <target>]
#   [CONFIG <config1> <config2>...]
# )
#
# \paramTARGET TARGET Target to add flag
# \groupCONFIG CONFIG Configs for the property to change (Debug Release RelWithDebInfo MinSizeRel)
function(cmt_target_enable_sanitizers)
 	cmake_parse_arguments(ARGS "ASAN;TSAN;LSAN;UBSAN;MSAN;CFISAN;AUBSAN;MWOSAN" "TARGET" "CONFIG" ${ARGN})
    cmt_required_arguments(FUNCTION cmt_target_enable_sanitizers PREFIX ARGS FIELDS TARGET)
	cmt_one_of_arguments(FUNCTION cmt_target_enable_sanitizers PREFIX ARGS FIELDS ASAN TSAN LSAN UBSAN MSAN AUBSAN MWOSAN CFISAN)

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
				cmt_target_add_compiler_options(TARGET ${ARGS_TARGET} OPTIONS ${flag} CONFIG ${ARGS_CONFIG})
				cmt_target_add_linker_options(TARGET ${ARGS_TARGET} OPTIONS ${flag} CONFIG ${ARGS_CONFIG})
			else()
				cmt_target_add_compiler_options(TARGET ${ARGS_TARGET} OPTIONS ${flag})
				cmt_target_add_linker_options(TARGET ${ARGS_TARGET} OPTIONS ${flag})
			endif()
		endforeach()
	endforeach()
endfunction()

# ! cmt_target_print_compiler_options
# Print linker options for a target
#
# cmt_target_print_compiler_options(
#   [TARGET <target>]
# 	[CONFIG <config1> <config2>...]
# )
#
# \param:TARGET TARGET The target to configure
# \groupCONFIG CONFIG Configs for the property to change (Debug Release RelWithDebInfo MinSizeRel)
#
function(cmt_target_print_compiler_options)
    cmake_parse_arguments(ARGS "" "TARGET" "CONFIG" ${ARGN})
	cmt_required_arguments(FUNCTION cmt_add_linker_options PREFIX ARGS FIELDS TARGET)
	cmt_required_arguments(FUNCTION cmt_target_disable_warnings PREFIX ARGS FIELDS TARGET)
    cmt_ensure_targets(FUNCTION cmt_target_disable_warnings TARGETS ${ARGS_TARGET})

	cmt_log("Target ${ARGS_TARGET} Compiler Options:")

	macro(cmt_print_list title list)
		cmt_status("  > ${title}:")
		foreach(element ${${list}})
			cmt_log("    - ${element}")
		endforeach()
	endmacro()


	get_target_property(COMPILE_DEFINITIONS ${ARGS_TARGET} COMPILE_DEFINITIONS)
	get_target_property(COMPILE_OPTIONS ${ARGS_TARGET} COMPILE_OPTIONS)
	cmt_print_list("COMPILE_DEFINITIONS" COMPILE_DEFINITIONS)
	cmt_print_list("COMPILE_OPTIONS" COMPILE_OPTIONS)
endfunction()


# ! cmt_target_print_linker_options
# Print compiler options for a target
#
# cmt_target_print_linker_options(
#   [TARGET <target>]
# 	[CONFIG <config1> <config2>...]
# )
#
# \param:TARGET TARGET The target to configure
# \groupCONFIG CONFIG Configs for the property to change (Debug Release RelWithDebInfo MinSizeRel)
#
function(cmt_target_print_linker_options)
    cmake_parse_arguments(ARGS "" "TARGET" "CONFIG" ${ARGN})
	cmt_required_arguments(FUNCTION cmt_target_disable_warnings PREFIX ARGS FIELDS TARGET)
    cmt_ensure_targets(FUNCTION cmt_target_disable_warnings TARGETS ${ARGS_TARGET}) 

	cmt_log("Target ${ARGS_TARGET} Linker Options:")

	macro(cmt_print_list title list)
		if (NOT ${list})
			return()
		endif()

		cmt_status("  > ${title}:")
		foreach(element ${${list}})
			cmt_log("    - ${element}")
		endforeach()
	endmacro()

	get_target_property(LINK_OPTIONS ${ARGS_TARGET} LINK_OPTIONS)
	get_target_property(LINK_FLAGS ${ARGS_TARGET} LINK_FLAGS)
	cmt_print_list("LINK_OPTIONS" LINK_OPTIONS)
	cmt_print_list("LINK_FLAGS" LINK_FLAGS)
    if(NOT DEFINED ARGS_CONFIG)
        string(TOUPPER ${CMAKE_BUILD_TYPE} config)
        get_target_property(LINK_FLAGS_${config} ${ARGS_TARGET} LINK_FLAGS_${config})
		cmt_print_list("LINK_FLAGS_${config}" LINK_FLAGS_${config})
    else()
        foreach(config ${ARGS_CONFIG})
            cmt_ensure_config(${config})
            string(TOUPPER ${config} config)
			get_target_property(LINK_FLAGS_${config} ${ARGS_TARGET} LINK_FLAGS_${config})
			cmt_print_list("LINK_FLAGS_${config}" LINK_FLAGS_${config})
        endforeach()
    endif()
endfunction()


# ! cmt_count_sources
# Counts the number of source files
# cmt_count_sources(
#   [RESULT <result variable>]
#   source1, source2 ...
# )
#
# \paramRESULT RESULT The variable to store the result in
macro(cmt_count_sources)
    cmake_parse_arguments(ARG "" "RESULT" "" ${ARGN})
    cmt_required_arguments(FUNCTION cmt_count_sources PREFIX ARGS FIELDS RESULT)
    set(result 0)
    foreach(SOURCE_FILE ${ARGS_UNPARSED_ARGUMENTS})
        if("${SOURCE_FILE}" MATCHES \\.\(c|C|cc|cp|cpp|CPP|c\\+\\+|cxx|i|ii\)$)
            math(EXPR result "${result} + 1")
        endif()
    endforeach()
    set(${ARGS_RESULT} ${result})
endmacro()

# cmt_add_target
# Adds a target eligible for cotiring - unity build and/or precompiled header
# TYPE could be either STATIC, SHARED, MODULE, INTERFACE or EXECUTABLE
# cmt_add_target(
#   UNITY
#   [TYPE <type>]
#   [NAME <name>]
#   [CPP_PER_UNIT <cpp per unit>]
#   [PCH_FILE <pch file>]
#   [SOURCES <source1> <source2>...]
#   [HEADERS <header1> <header2>...]
#   [UNITY_EXCLUDE <source1> <source2>...]
#
# \paramUNITY UNITY Enable unity build
# \paramTYPE TYPE The type of the target
# \paramNAME NAME The name of the target
# \paramCPP_PER_UNIT CPP_PER_UNIT The number of cpp files per unity unit
# \paramPCH_FILE PCH_FILE The precompiled header file
# \groupSOURCES SOURCES The source files
# \groupHEADERS HEADERS The header files
# \groupUNITY_EXCLUDE UNITY_EXCLUDE The source files to exclude from unity build
function(cmt_add_target)
    cmake_parse_arguments(ARGS "UNITY" "NAME;TYPE;PCH_FILE;CPP_PER_UNITY" "HEADERS;SOURCES;UNITY_EXCLUDED" ${ARGN})
    cmt_required_arguments(FUNCTION cmt_add_target PREFIX ARGS FIELDS NAME TYPE)
	cmt_choice_arguments(FUNCTION cmt_add_target PREFIX ARGS CHOICE TYPE OPTIONS EXECUTABLE STATIC SHARED MODULE INTERFACE)
	cmt_one_of_arguments(FUNCTION cmt_add_target PREFIX ARGS FIELDS HEADERS SOURCES)
	cmt_default_argument(FUNCTION cmt_add_target PREFIX ARGS FIELD CPP_PER_UNITY 100)

    set(DO_UNITY ${CMT_ENABLE_UNITY_BUILD})
	if (NOT ARGS_UNITY)
        set(DO_UNITY OFF)
    endif()
    
    # TODO: Add a mechanism to exclude target from unity
    list(FIND UCM_UNITY_BUILD_EXCLUDE_TARGETS ${ARGS_NAME} is_target_excluded)
    if(NOT ${is_target_excluded} STREQUAL "-1")
        set(DO_UNITY OFF)
    endif()
    
    if (DO_UNITY)
        ucm_count_sources(${ARGS_SOURCES} RESULT NUM_SOURCES)
        if (${NUM_SOURCES} LESS 2)
            set(DO_UNITY OFF)
        endif()
    endif()
    
    set(WANTED_COTIRE ${DO_UNITY})
    
    if(DO_UNITY AND NOT CMT_ENABLE_COTIRE)
        set(DO_UNITY OFF)
    endif()
    
	# Inform the developer that the current target might benefit from a unity build
	if(NOT ARGS_UNITY AND ${CMT_ENABLE_UNITY_BUILD})
		ucm_count_sources(${ARGS_SOURCES} RESULT NUM_SOURCES)
		if( ${num_sources} GREATER 1)
			cmt_warning("Target '${ARGS_NAME}' may benefit from a unity build.\nIt has ${NUM_SOURCES} sources - enable it with UNITY flag")
		endif()
	endif()
    
    # Prepare for the unity build
    set(TARGET_NAME ${ARGS_NAME})
    if (DO_UNITY)
        set(TARGET_NAME ${ARGS_NAME}_ORIGINAL)
        foreach(excluded_file "${ARGS_UNITY_EXCLUDED}")
            set_source_files_properties(${excluded_file} PROPERTIES COTIRE_EXCLUDED TRUE)
        endforeach()
    endif()
    
    # Add the original target
    if (${ARGS_TYPE} STREQUAL "EXECUTABLE")
        add_executable(${TARGET_NAME} ${ARGS_HEADERS} ${ARGS_SOURCES})
    else()
        add_library(${TARGET_NAME} ${ARGS_TYPE} ${ARGS_HEADERS} ${ARGS_SOURCES})
    endif()
    
    if (DO_UNITY)
        if(NOT "${ARGS_PCH_FILE}" STREQUAL "")
            set_target_properties(${TARGET_NAME} PROPERTIES COTIRE_CXX_PREFIX_HEADER_INIT "${ARGS_PCH_FILE}")
        else()
            set_target_properties(${TARGET_NAME} PROPERTIES COTIRE_ENABLE_PRECOMPILED_HEADER FALSE)
        endif()

        set_target_properties(${TARGET_NAME} PROPERTIES COTIRE_UNITY_TARGET_NAME ${ARGS_NAME})
        
        # Call cotire to apply the unity build
        cotire(${TARGET_NAME})
        set_target_properties(clean_cotire PROPERTIES FOLDER "CMakePredefinedTargets")
        
        # Disable the original target and enable the unity one
        get_target_property(unity_target_name ${TARGET_NAME} COTIRE_UNITY_TARGET_NAME)
        set_target_properties(${TARGET_NAME} PROPERTIES EXCLUDE_FROM_ALL 1 EXCLUDE_FROM_DEFAULT_BUILD 1)
        set_target_properties(${unity_target_name} PROPERTIES EXCLUDE_FROM_ALL 0 EXCLUDE_FROM_DEFAULT_BUILD 0)
        
        # Also set the name of the target output as the original one
        set_target_properties(${unity_target_name} PROPERTIES OUTPUT_NAME ${ARGS_NAME})
        set_target_properties(${unity_target_name} PROPERTIES FOLDER "")
        set_target_properties(all_unity PROPERTIES FOLDER "CMakePredefinedTargets")
    elseif(NOT "${ARGS_PCH_FILE}" STREQUAL "")
        set(WANTED_COTIRE TRUE)
		set_target_properties(${TARGET_NAME} PROPERTIES COTIRE_ADD_UNITY_BUILD FALSE)
		set_target_properties(${TARGET_NAME} PROPERTIES COTIRE_CXX_PREFIX_HEADER_INIT "${ARGS_PCH_FILE}")
		cotire(${TARGET_NAME})
		set_target_properties(clean_cotire PROPERTIES FOLDER "CMakePredefinedTargets")
    else()
		cmt_warning("Target '${ARGS_NAME}' has no precompiled header file. Consider adding one with PCH_FILE")
	endif()
endfunction()