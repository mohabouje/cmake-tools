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

if(CMTOOLS_FILE_SYSTEM_INCLUDED)
	return()
endif()
set(CMTOOLS_FILE_SYSTEM_INCLUDED ON)

include(${CMAKE_CURRENT_LIST_DIR}/cmtools-lists.cmake)


# Functions summary:
# - cmtools_directory_is_empty
# - cmtools_get_files
# - cmtools_get_sources
# - cmtools_get_headers


# ! cmtools_directory_is_empty Check if a directory is empty.
#
# cmtools_directory_is_empty(
#   [NAME <name>]
#   [DIRECTORY <directory> ]
# )
#
# \param:NAME NAME Name of the variable containing the result.
# \param:DIRECTORY DIRECTORY Directory to check.
#
function(cmtools_directory_is_empty)
    cmake_parse_arguments(ARGS "" "NAME;DIRECTORY" "" ${ARGN})
    cmtools_required_arguments(FUNCTION cmtools_filter_list PREFIX ARGS FIELDS NAME DIRECTORY)


	set(TEMPORAL_OUTPUT false)
	get_filename_component(DIRECTORY_PATH ${ARGS_DIRECTORY} REALPATH)
	if(EXISTS "${DIRECTORY_PATH}")
		if(IS_DIRECTORY "${DIRECTORY_PATH}")
			file(GLOB files "${DIRECTORY_PATH}/*")
			list(LENGTH files len)
			if(len EQUAL 0)
				set(TEMPORAL_OUTPUT true)
			endif()
		else()
			set(TEMPORAL_OUTPUT true)
		endif()
	else()
		set(TEMPORAL_OUTPUT true)
	endif()
	set(${ARGS_NAME} ${TEMPORAL_OUTPUT} CACHE STRING "Checking emptiness of ${ARGS_DIRECTORY}" FORCE PARENT_SCOP)
endfunction()

# ! cmtools_get_files Get files with the specified extensions form in the directory
#
# cmtools_get_files(
#	[RECURSIVE]
#   [NAME <name>]
#   [DIRECTORY <directory> ]
#   [EXTENSIONS <extensions1> <extensions2> ...]
# )
#
# \param:NAME NAME Name of the variable containing the result.
# \param:DIRECTORY DIRECTORY Directory to check.
# \param:RECURSIVE RECURSIVE If present, search is recursive
# \param:EXTENSIONS EXTENSIONS Extensions of files to get
#
function(cmtools_get_files output)
    cmake_parse_arguments(ARGS "RECURSIVE" "NAME;DIRECTORY" "EXTENSIONS" ${ARGN})
    cmtools_required_arguments(FUNCTION cmtools_filter_list PREFIX ARGS FIELDS NAME DIRECTORY EXTENSIONS)
	if (ARGS_RECURSIVE)
		set(GLOB_COMMAND GLOB_RECURSE)
	else()
		set(GLOB_COMMAND GLOB)
	endif()

	set(LIST_FILES)
	if(IS_DIRECTORY ${ARGS_DIRECTORY})
		set(PATTERNS)
		foreach(EXTENSION ${ARGS_EXTENSIONS})
			list(APPEND PATTERNS "${ARGS_DIRECTORY}/*${EXTENSION}")
		endforeach()
		file(${GLOB_COMMAND} TEMPORAL_FILES ${PATTERNS})
		list(APPEND LIST_FILES ${TEMPORAL_FILES})
	endif()
	set(${ARGS_NAME} ${LIST_FILES} PARENT_SCOPE)
endfunction()

# ! cmtools_get_sources Get (recursively or not) C and C++ sources files form input directories.
#
# cmtools_get_sources(
#	[RECURSIVE]
#   [NAME <name>]
#   [DIRECTORY <directory> ]
# )
#
# \param:NAME NAME Name of the variable containing the result.
# \param:DIRECTORY DIRECTORY Directory to check.
# \param:RECURSIVE RECURSIVE If present, search is recursive
#
macro(cmtools_get_sources output)
	cmtools_get_files(${ARGN} EXTENSIONS .c .C .c++ .cc .cpp .cxx .h .hh .h++ .hpp .hxx .tpp .txx .tcc)
endmacro()


# ! cmtools_get_headers Get (recursively or not) C and C++ headers files form input directories.
#
# cmtools_get_headers(
#	[RECURSIVE]
#   [NAME <name>]
#   [DIRECTORY <directory> ]
# )
#
# \param:NAME NAME Name of the variable containing the result.
# \param:DIRECTORY DIRECTORY Directory to check.
# \param:RECURSIVE RECURSIVE If present, search is recursive
# \param:EXTENSIONS EXTENSIONS Extensions of files to get
#
macro(cmtools_get_headers)
	cmtools_get_files(${ARGN} EXTENSIONS .h .hh .h++ .hpp .hxx .tpp .txx .tcc)
endmacro()