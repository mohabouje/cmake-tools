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

if(CMTOOLS_ENVIRONMENT_INCLUDED)
	return()
endif()
set(CMTOOLS_ENVIRONMENT_INCLUDED ON)

include(${CMAKE_CURRENT_LIST_DIR}/cmtools-args.cmake)


# Functions summary:
# - cmtools_set_default_build_type
# - cmtools_set_build_type
# - cmtools_define_archichecture
# - cmtools_define_os
# - cmtools_define_compiler

# ! cmtools_set_default_build_type Sets the default build type for the current project
# It makes sure that the build type is set to one of the following values:
# - Debug
# - Release
# - RelWithDebInfo
# - MinSizeRel
#
# cmtools_set_default_build_type(
#   [CONFIG <config>]
# )
#
# \param:CONFIG CONFIG The configuration to be used.
#
function(cmtools_set_default_build_type)
    cmake_parse_arguments(CHECK "" "CONFIG" "" ${ARGN})
	cmtools_required_arguments(FUNCTION cmtools_set_build_type PREFIX ARGS FIELDS CONFIG)
    cmtools_choice_arguments(FUNCTION cmtools_set_build_type PREFIX ARGS CHOICE ARGS_CONFIG OPTIONS Debug Release RelWithDebInfo MinSizeRel)
	set(CMTOOLS_DEFAULT_BUILD_TYPE ${ARGS_CONFIG} CACHE STRING "Set the default build type." FORCE PARENT_SCOPE)
endfunction()

# ! cmtools_set_build_type Sets the build type for the current project
# It makes sure that the build type is set to one of the following values:
# - Debug
# - Release
# - RelWithDebInfo
# - MinSizeRel
#
# cmtools_set_build_type(
#   [CONFIG <config>]
# )
#
# \param:CONFIG CONFIG The configuration to be used.
#
function(cmtools_set_build_type)
	cmtools_define_build_type(${ARGN})
	if(NOT CMAKE_BUILD_TYPE)
		set(CMAKE_BUILD_TYPE ${CMTOOLS_DEFAULT_BUILD_TYPE} CACHE STRING "Choose the type of build." FORCE PARENT_SCOPE)
	endif()
endfunction()


#! cmtools_define_archichecture Defines the architecture variables
# It defines the variable CMTOOLS_ARCHITECTURE to one of the following values:
# - 32BIT
# - 64BIT
# - UNKNOWN
#
# cmtools_define_archichecture()
#
macro(cmtools_define_archichecture)	
	if(${CMAKE_SIZEOF_VOID_P} EQUAL 4)
		set(CMTOOLS_ARCHITECTURE "32BIT")
	elseif(${CMAKE_SIZEOF_VOID_P} EQUAL 8)
		set(CMTOOLS_ARCHITECTURE "64BIT")
	else()
		set(CMTOOLS_ARCHITECTURE "UNKNOWN")
	endif()
endmacro()

#! cmtools_define_compiler Defines the compiler variables
# It defines the variable CMTOOLS_COMPILER to one of the following values:
# - CLANG
# - GCC
# - MSVC
# - UNKNOWN
#
# cmtools_define_compiler()
#
macro(cmtools_define_compiler)
	if(CMAKE_CXX_COMPILER_ID MATCHES "Clang")
		set(CMTOOLS_COMPILER "CLANG")
	elseif(CMAKE_CXX_COMPILER_ID MATCHES "GNU")
		set(CMTOOLS_COMPILER "GCC")
	elseif(CMAKE_CXX_COMPILER_ID MATCHES "MSVC")
		set(CMTOOLS_COMPILER "MSVC")
	else()
		set(CMTOOLS_COMPILER "UNKNOWN")
	endif()
endmacro()

#! cmtools_define_compiler Defines the OS variables
# It defines the variable CMTOOLS_OS to one of the following values:
# - UNIX
# - WINDOWS
# - MACOS
# - FREEBSD
# - IOS
# - ANDROID
# - CUNKNOWN
# Each variable is set to ON if the architecture is the same as the variable name.
#
# cmtools_define_compiler()
#
macro(cmtools_define_os)
	if(${CMAKE_SYSTEM_NAME} STREQUAL "Windows")
		set(CMTOOLS_OS ON "WINDOWS")
	elseif(${CMAKE_SYSTEM_NAME} STREQUAL "Linux")
		if(ANDROID)
			set(CMTOOLS_OS "ANDROID")
		else()
			set(CMTOOLS_OS "LINUX")
		endif()
	elseif(CMAKE_SYSTEM_NAME MATCHES "^k?FreeBSD$")
		set(CMTOOLS_OS_FREEBSD "FREEBSD")
	elseif(${CMAKE_SYSTEM_NAME} STREQUAL "Darwin")
		if(IOS)
			set(CMTOOLS_OS_IOS "IOS")
		else()
			set(CMTOOLS_OS_MACOSX "MACOS")
		endif()
	elseif(${CMAKE_SYSTEM_NAME} STREQUAL "Android")
		set(CMTOOLS_OS_ANDROID "ANDROID")
	else()
		set(CMTOOLS_OS_UNKNOW "UNKNOWN")
	endif()
endmacro()