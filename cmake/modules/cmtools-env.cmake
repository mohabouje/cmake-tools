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

set(CMT_DEFAULT_BUILD_TYPE Debug CACHE STRING "Set the default build type." FORCE)
mark_as_advanced(CMT_DEFAULT_BUILD_TYPE)

# Functions summary:
# - cmt_set_default_build_type
# - cmt_set_build_type
# - cmt_define_architecture
# - cmt_define_os
# - cmt_define_compiler

# ! cmt_set_build_type
# Sets the build type for the current project
# It makes sure that the build type is set to one of the following values:
# - Debug
# - Release
# - RelWithDebInfo
# - MinSizeRel
# - Coverage
#
# cmt_set_build_type(
#   BUILD_TYPE
# )
#
# \input BUILD_TYPE The default build type
#
macro(cmt_set_build_type BUILD_TYPE)
	cmt_ensure_choice(${BUILD_TYPE} Debug Release RelWithDebInfo MinSizeRel Coverage)
	set(CMAKE_BUILD_TYPE ${BUILD_TYPE} CACHE STRING "Choose the type of build." FORCE)
endmacro()

# ! cmt_set_default_build_type
# If no build type was provided, It sets the build type for the current project to the default build type
# The default build type is set to CMT_DEFAULT_BUILD_TYPE variable which is set to Debug by default.
#
# cmt_set_default_build_type()
#
macro(cmt_set_default_build_type BUILD_TYPE)
	cmt_ensure_choice(${BUILD_TYPE} Debug Release RelWithDebInfo MinSizeRel Coverage)
	if (NOT CMAKE_BUILD_TYPE)
		cmt_warning("No build type selected, using default configuration: ${CMT_DEFAULT_BUILD_TYPE}")
		cmt_set_build_type(${CMT_DEFAULT_BUILD_TYPE})
	endif()
endmacro()

# ! cmt_set_default_generator
# Set a default generator if none was specified
#
# cmt_set_default_build_type( GENERATOR )
#
# \input  GENERATOR : The default generator to use if none was specified
#
macro(cmt_set_default_generator GENERATOR)
	set(CMAKE_GENERATOR ${GENERATOR} CACHE INTERNAL "" FORCE)
endmacro()

#! cmt_define_architecture
# Defines the architecture variables
# It defines the variable CMT_ARCHITECTURE to one of the following values:
# - X86
# - ARM
# - UNKNOWN
#
# cmt_define_architecture()
#
macro(cmt_define_architecture)
	if (CMAKE_SYSTEM_PROCESSOR MATCHES "(x86)|(X86)|(amd64)|(AMD64)")
		set(CMT_ARCHITECTURE "X86")
	elseif(CMAKE_SYSTEM_PROCESSOR STREQUAL "arm")
		set(CMT_ARCHITECTURE "ARM")
	elseif(CMAKE_SYSTEM_PROCESSOR STREQUAL "arm64")
		set(CMT_ARCHITECTURE "ARM64")
	else()
		set(CMT_ARCHITECTURE "UNKNOWN")
	endif()
endmacro()

#! cmt_define_compiler
# Defines the compiler variables
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
		set(CMT_COMPILER "CLANG")
	elseif(CMAKE_CXX_COMPILER_ID MATCHES "GNU")
		set(CMT_COMPILER "GCC")
	elseif(CMAKE_CXX_COMPILER_ID MATCHES "MSVC")
		set(CMT_COMPILER "MSVC")
	else()
		set(CMT_COMPILER "UNKNOWN")
	endif()
endmacro()

#! cmt_define_os
# Defines the OS variables
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
		set(CMT_OS "WINDOWS")
	elseif(${CMAKE_SYSTEM_NAME} STREQUAL "Linux")
		if(ANDROID)
			set(CMT_OS "ANDROID")
		else()
			set(CMT_OS "LINUX")
		endif()
	elseif(CMAKE_SYSTEM_NAME MATCHES "^k?FreeBSD$")
		set(CMT_OS "FREEBSD")
	elseif(${CMAKE_SYSTEM_NAME} STREQUAL "Darwin")
		if(IOS)
			set(CMT_OS "IOS")
		else()
			set(CMT_OS "MACOS")
		endif()
	elseif(${CMAKE_SYSTEM_NAME} STREQUAL "Android")
		set(CMT_OS "ANDROID")
	else()
		set(CMT_OS "UNKNOWN")
	endif()
endmacro()

#! cmt_define_standard_cxx_library
# Defines the architecture variables
# It defines the variable CMT_ARCHITECTURE to one of the following values:
# - libstdc++
# - libc++
# - UNKNOWN
#
# cmt_define_architecture()
#
macro(cmt_define_standard_cxx_library)
	cmt_define_os()
	if (${CMT_OS} STREQUAL "MACOS")
		set(CMT_CXX_STANDARD_LIB "libc++")
	else()
		set(CMT_CXX_STANDARD_LIB "libstdc++")
	endif()
endmacro()


#! cmt_define_cxx_compiler_version
#
macro(cmt_define_cxx_compiler_version)
	set(CMT_CXX_COMPILER_VERSION ${CMAKE_CXX_COMPILER_VERSION})
endmacro()

#! cmt_define_c_compiler_version
#
macro(cmt_define_c_compiler_version)
	set(CMT_C_COMPILER_VERSION ${CMAKE_C_COMPILER_VERSION})
endmacro()

#! cmt_find_program
# Simple wrapper around find_program to make it easier to use. 
# It fails if the program is not found.
#
macro(cmt_find_program)
	find_program(${ARGN} REQUIRED)
endmacro()

#! cmt_set_cpp_standard
# Sets the C++ standard for the current project
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
#   STANDARD
#   [REQUIRED <required>] (Default: ON)
#   [EXTENSIONS <extensions>] (Default: OFF)
# )
#
# \input STANDARD The C++ standard
# \param REQUIRED If the standard is required
# \param EXTENSIONS If the compiler extensions are allowed
#
macro(cmt_set_cpp_standard STANDARD)
    cmt_parse_arguments(_CPP_FP_CHECK "" "REQUIRED;EXTENSIONS" "" ${ARGN})
    cmt_ensure_choice(${STANDARD} 98 11 14 17 20 23)
	cmt_default_argument(_CPP_FP_CHECK EXTENSION OFF)
	cmt_default_argument(_CPP_FP_CHECK REQUIRED ON)

	set(CMAKE_CXX_STANDARD ${STANDARD} CACHE STRING "Set the C++ standard to use." FORCE)
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
#   STANDARD
#   [REQUIRED <required>] (Default: ON)
#   [EXTENSIONS <extensions>] (Default: OFF)
# )
#
# \input STANDARD The C standard
# \param REQUIRED If the standard is required
# \param EXTENSIONS If the compiler extensions are allowed
#
macro(cmt_set_c_standard STANDARD)
    cmt_parse_arguments(_C_FP_CHECK "" "REQUIRED;EXTENSIONS" "" ${ARGN})
    cmt_ensure_choice(${STANDARD} 98 11 17 23)
	cmt_default_argument(_C_FP_CHECK FIELD EXTENSION OFF)
	cmt_default_argument(_C_FP_CHECK FIELD REQUIRED ON)

	set(CMAKE_C_STANDARD ${STANDARD} CACHE STRING "Set the C standard to use." FORCE)
	set(CMAKE_C_STANDARD_REQUIRED ${_C_FP_CHECK_REQUIRED} CACHE BOOL "Set the C standard to required." FORCE)
	set(CMAKE_C_EXTENSIONS ${_C_FP_CHECK_EXTENSIONS} CACHE BOOL "Set the C standard to use extensions." FORCE)
endmacro()

