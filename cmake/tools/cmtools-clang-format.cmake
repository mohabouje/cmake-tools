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

if (CMT_CLANG_FORMAT_INCLUDED)
	return()
endif()
set(CMT_CLANG_FORMAT_INCLUDED ON)

include(${CMAKE_CURRENT_LIST_DIR}/./../utility/cmtools-env.cmake)
include(${CMAKE_CURRENT_LIST_DIR}/./../utility/cmtools-lists.cmake)
include(${CMAKE_CURRENT_LIST_DIR}/./../utility/cmtools-fsystem.cmake)

# Functions summary:
# - cmt_target_generate_clang_format(target [STYLE style] [WORKING_DIRECTORY work_dir])


# ! cmt_target_generate_clang_format Generate a format target for the target (clang-format-${TARGET}).
# The generated target lanch clang-format on all the target sources with the specified style 
# in the specified working directory (${CMAKE_CURRENT_SOURCE_DIR} by default}).
#
# cmt_target_generate_clang_format(
#   [TARGET <target>]
#   [STYLE <style>] ('file' style by default)
#   [WORKING_DIRECTORY <work_dir>] (${CMAKE_CURRENT_SOURCE_DIR} by default}).
# )
#
# \param:TARGET TARGET The target to configure
# \param:STYLE STYLE The clang-format style (file, LLVM, Google, Chromium, Mozilla, WebKit)
# \param:WORKING_DIRECTORY WORKING_DIRECTORY The clang-format working directory
#
function(cmt_target_generate_clang_format)
    cmake_parse_arguments(ARGS "" "TARGET" "STYLE;WORKING_DIRECTORY" ${ARGN})
    cmt_required_arguments(FUNCTION cmt_target_generate_clang_format PREFIX ARGS FIELDS TARGET)
    cmt_ensure_targets(FUNCTION cmt_target_generate_clang_format TARGETS ${ARGS_TARGET}) 
    cmt_default_argument(FUNCTION cmt_target_generate_clang_format PREFIX ARGS FIELDS STYLE VALUE "file")
    cmt_default_argument(FUNCTION cmt_target_generate_clang_format PREFIX ARGS FIELDS WORKING_DIRECTORY VALUE ${CMAKE_CURRENT_SOURCE_DIR})

	if (NOT CMT_ENABLE_CLANG_FORMAT)
    	return()
	endif()

	set(FORMAT_TARGET "clang-format-${ARGS_TARGET}")
	if (TARGET ${FORMAT_TARGET})
		message(FATAL_ERROR "${FORMAT_TARGET} already exists")
	endif()

    cmt_find_program(NAME CLANG_FORMAT_PROGRAM PROGRAM clang-format)
	get_property(FORMAT_TARGET_SOURCES TARGET ${ARGS_TARGET} PROPERTY SOURCES)
	add_custom_target(
		${FORMAT_TARGET}
		COMMAND "${CLANG_FORMAT_PROGRAM}" -style=${ARGS_STYLE} -i ${FORMAT_TARGET_SOURCES}
		WORKING_DIRECTORY "${ARGS_WORKING_DIRECTORY}"
		VERBATIM
	)

    # TODO: verify if this is required
    # cmt_target_set_ide_folder(${FORMAT_TARGET} "format")
	message(STATUS "[cmtools] Target ${ARGS_TARGET}: generate target to run clang-format")
endfunction()