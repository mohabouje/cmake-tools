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

if(CMT_ENVIRONMENT_INCLUDED)
	return()
endif()
set(CMT_ENVIRONMENT_INCLUDED ON)

include(${CMAKE_CURRENT_LIST_DIR}/cmtools-args.cmake)


# Functions summary:
# - cmt_set_default_build_type
# - cmt_set_build_type
# - cmt_define_archichecture
# - cmt_define_os
# - cmt_define_compiler

# ! cmt_set_default_build_type Sets the default build type for the current project
# It makes sure that the build type is set to one of the following values:
# - Debug
# - Release
# - RelWithDebInfo
# - MinSizeRel
# - Coverage
#
# cmt_set_default_build_type(
#   [CONFIG <config>]
# )
#
# \param:CONFIG CONFIG The configuration to be used.
#
function(cmt_set_default_build_type)
    cmake_parse_arguments(CHECK "" "CONFIG" "" ${ARGN})
	cmt_required_arguments(FUNCTION cmt_set_build_type PREFIX ARGS FIELDS CONFIG)
    cmt_choice_arguments(FUNCTION cmt_set_build_type PREFIX ARGS CHOICE CONFIG OPTIONS Debug Release RelWithDebInfo MinSizeRel Coverage)
	set(CMT_DEFAULT_BUILD_TYPE ${ARGS_CONFIG} CACHE STRING "Set the default build type." FORCE PARENT_SCOPE)
endfunction()

# ! cmt_set_build_type Sets the build type for the current project
# It makes sure that the build type is set to one of the following values:
# - Debug
# - Release
# - RelWithDebInfo
# - MinSizeRel
# - Coverage
#
# cmt_set_build_type(
#   [CONFIG <config>]
# )
#
# \param:CONFIG CONFIG The configuration to be used.
#
function(cmt_set_build_type)
	cmt_define_build_type(${ARGN})
	if(NOT CMAKE_BUILD_TYPE)
		set(CMAKE_BUILD_TYPE ${CMT_DEFAULT_BUILD_TYPE} CACHE STRING "Choose the type of build." FORCE PARENT_SCOPE)
	endif()
endfunction()


#! cmt_define_archichecture Defines the architecture variables
# It defines the variable CMT_ARCHITECTURE to one of the following values:
# - 32BIT
# - 64BIT
# - UNKNOWN
#
# cmt_define_archichecture()
#
macro(cmt_define_archichecture)	
	if(${CMAKE_SIZEOF_VOID_P} EQUAL 4)
		set(CMT_ARCHITECTURE "32BIT")
	elseif(${CMAKE_SIZEOF_VOID_P} EQUAL 8)
		set(CMT_ARCHITECTURE "64BIT")
	else()
		set(CMT_ARCHITECTURE "UNKNOWN")
	endif()
endmacro()

#! cmt_define_compiler Defines the compiler variables
# It defines the variable CMT_COMPILER to one of the following values:
# - CLANG
# - GCC
# - MSVC
# - UNKNOWN
#
# cmt_define_compiler()
#
macro(cmt_define_compiler)
	if((CMAKE_CXX_COMPILER_ID MATCHES "Clang" OR CMAKE_CXX_COMPILER_ID MATCHES "AppleClang"))
		set(CMT_COMPILER "CLANG" PARENT_SCOPE)
	elseif(CMAKE_CXX_COMPILER_ID MATCHES "GNU")
		set(CMT_COMPILER "GCC" PARENT_SCOPE)
	elseif(CMAKE_CXX_COMPILER_ID MATCHES "MSVC")
		set(CMT_COMPILER "MSVC" PARENT_SCOPE)
	else()
		set(CMT_COMPILER "UNKNOWN" PARENT_SCOPE)
	endif()
endmacro()

#! cmt_define_compiler Defines the OS variables
# It defines the variable CMT_OS to one of the following values:
# - UNIX
# - WINDOWS
# - MACOS
# - FREEBSD
# - IOS
# - ANDROID
# - CUNKNOWN
# Each variable is set to ON if the architecture is the same as the variable name.
#
# cmt_define_compiler()
#
macro(cmt_define_os)
	if(${CMAKE_SYSTEM_NAME} STREQUAL "Windows")
		set(CMT_OS ON "WINDOWS")
	elseif(${CMAKE_SYSTEM_NAME} STREQUAL "Linux")
		if(ANDROID)
			set(CMT_OS "ANDROID")
		else()
			set(CMT_OS "LINUX")
		endif()
	elseif(CMAKE_SYSTEM_NAME MATCHES "^k?FreeBSD$")
		set(CMT_OS_FREEBSD "FREEBSD")
	elseif(${CMAKE_SYSTEM_NAME} STREQUAL "Darwin")
		if(IOS)
			set(CMT_OS_IOS "IOS")
		else()
			set(CMT_OS_MACOSX "MACOS")
		endif()
	elseif(${CMAKE_SYSTEM_NAME} STREQUAL "Android")
		set(CMT_OS_ANDROID "ANDROID")
	else()
		set(CMT_OS_UNKNOW "UNKNOWN")
	endif()
endmacro()

#! cmt_find_program Check if a program exists and set the variable to the path
#
# cmt_find_program(
#   [NAME <name>]
#   [PROGRAM <program>]
#   [ALIAS <alias1> <alias2> ...]
#   [COMPONENTS <component1> <component2> ...]
# )
#
macro(cmt_find_program)

    cmake_parse_arguments(_FP_CHECK "" "NAME;PROGRAM" "ALIAS;COMPONENTS" ${ARGN})
	cmt_required_arguments(FUNCTION cmt_find_program PREFIX _FP_CHECK FIELDS NAME PROGRAM)

	if (${_FP_CHECK_NAME})
		return()
	endif()

	find_program(${_FP_CHECK_NAME} ${_FP_CHECK_PROGRAM} NAMES ${_FP_CHECK_ALIAS} COMPONENTS ${_FP_CHECK_COMPONENTS})
    if(NOT ${_FP_CHECK_NAME})
        message(FATAL_ERROR "Could not find the program ${_FP_CHECK_PROGRAM}")
    endif()

endmacro()

#! cmt_set_cpp_standard Sets the C++ standard for the current project
# The C++ standard is set to the value of the variable CMT_CPP_STANDARD.
#
# The value of the standard is set to one of the following values:
# - 98
# - 11
# - 14
# - 17
# - 20
# - 23
#
# cmt_set_cpp_standard(
#   [STANDARD <standard>]
#   [REQUIRED <required>] (Default: ON)
#   [EXTENSIONS <extensions>] (Default: OFF)
# )
macro(cmt_set_cpp_standard)
    cmake_parse_arguments(_CPP_FP_CHECK "" "STANDARD;REQUIRED;EXTENSIONS" "" ${ARGN})
	cmt_required_arguments(FUNCTION cmt_set_cpp_standard PREFIX _CPP_FP_CHECK FIELDS NAME STANDARD)
    cmt_choice_arguments(FUNCTION cmt_set_cpp_standard PREFIX _CPP_FP_CHECK CHOICE STANDARD OPTIONS 98 11 14 17 20 23)
	cmt_default_argument(FUNCTION cmt_set_cpp_standard PREFIX _CPP_FP_CHECK FIELD EXTENSION VALUE OFF)
	cmt_default_argument(FUNCTION cmt_set_cpp_standard PREFIX _CPP_FP_CHECK FIELD REQUIRED VALUE ON)

	set(CMT_CPP_STANDARD ${_CPP_FP_CHECK_STANDARD} CACHE STRING "The C++ standard to use" FORCE)
	set(CMAKE_CXX_STANDARD ${_CPP_FP_CHECK_STANDARD} CACHE STRING "Set the C++ standard to use." FORCE)
	set(CMAKE_CXX_STANDARD_REQUIRED ${_CPP_FP_CHECK_REQUIRED} CACHE BOOL "Set the C++ standard to required." FORCE)
	set(CMAKE_CXX_EXTENSIONS ${_CPP_FP_CHECK_EXTENSIONS} CACHE BOOL "Set the C++ standard to use extensions." FORCE)
endmacro()

#! cmt_set_c_standard Sets the C standard for the current project
# The C++ standard is set to the value of the variable CMT_C_STANDARD.
#
# The value of the standard is set to one of the following values:
# - 98
# - 11
# - 17
# - 23
#
# cmt_set_c_standard(
#   [STANDARD <standard>]
#   [REQUIRED <required>] (Default: ON)
#   [EXTENSIONS <extensions>] (Default: OFF)
# )
macro(cmt_set_c_standard)
    cmake_parse_arguments(_C_FP_CHECK "" "STANDARD;REQUIRED;EXTENSIONS" "" ${ARGN})
	cmt_required_arguments(FUNCTION cmt_set_cpp_standard PREFIX _C_FP_CHECK FIELDS NAME STANDARD)
    cmt_choice_arguments(FUNCTION cmt_set_cpp_standard PREFIX _C_FP_CHECK CHOICE STANDARD OPTIONS 98 11 17 23)
	cmt_default_argument(FUNCTION cmt_set_cpp_standard PREFIX _C_FP_CHECK FIELD EXTENSION VALUE OFF)
	cmt_default_argument(FUNCTION cmt_set_cpp_standard PREFIX _C_FP_CHECK FIELD REQUIRED VALUE ON)

	set(CMT_CPP_STANDARD ${_C_FP_CHECK_STANDARD} CACHE STRING "The C++ standard to use" FORCE)
	set(CMAKE_CXX_STANDARD ${_C_FP_CHECK_STANDARD} CACHE STRING "Set the C++ standard to use." FORCE)
	set(CMAKE_CXX_STANDARD_REQUIRED ${_C_FP_CHECK_REQUIRED} CACHE BOOL "Set the C++ standard to required." FORCE)
	set(CMAKE_CXX_EXTENSIONS ${_C_FP_CHECK_EXTENSIONS} CACHE BOOL "Set the C++ standard to use extensions." FORCE)
endmacro()

#! cmt_ensure_config Checks if the configuration is valid
#
# The following variables are checked:
# - Debug
# - Release
# - RelWithDebInfo
# - MinSizeRel
#
# cmt_ensure_config(config)
#
function(cmt_ensure_config config)
	message(STATUS "Checking configuration ${config}")
	if (NOT "${config}" MATCHES "^(Debug|Release|RelWithDebInfo|MinSizeRel)$")
		message(FATAL_ERROR "The configuration ${config} is not valid")
	endif()
endfunction()

#! cmt_ensure_lang Checks if the language is valid
#
# The following variables are checked:
# - C
# - CXX
#
# cmt_ensure_lang(lang)
#
function(cmt_ensure_lang lang)
	message(STATUS "Checking language ${lang}")
	if (NOT "${lang}" MATCHES "^(C|CXX)$")
		message(FATAL_ERROR "The language ${lang} is not valid")
	endif()
endfunction()