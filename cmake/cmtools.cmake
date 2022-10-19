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
include (FetchContent)

# Global options to control the build system
option(CMT_ENABLE_LTO                   	"Enable the integration of lto into the build system"	OFF)
option(CMT_ENABLE_COMPILER_OPTION_CHECKS    "Enable checks in compiler options"     				ON)
option(CMT_ENABLE_LINKER_OPTION_CHECKS      "Enable checks in linker options"       				ON)

macro(cmt_include_all path)
	file(GLOB_RECURSE files "${path}/*.cmake")
	foreach(file ${files})
		include(${file})
	endforeach()
endmacro()


function(cmt_fetch_cmake_module_from_github USER PROJECT)
	cmake_parse_arguments(ARG "" "" "PATH" ${ARGN})
	if (NOT ARGS_PATH)
		set(ARGS_PATH "cmake")
	endif()

	set(TARGET_NAME "${USER}-${PROJECT}")
	set(TARGET_GIT "https://github.com/${USER}/${PROJECT}.git")
	set(TARGET_DIR "${CMAKE_CURRENT_BINARY_DIR}/github/${PROJECT}")
	cmt_get_global_property(CMT_${TARGET_NAME}_POPULATED POPULATED)


	if(NOT POPULATED AND NOT EXISTS ${TARGET_DIR})
		cmt_log("Fetching ${USER}/${PROJECT} from GitHub")
		FetchContent_Declare(
				${TARGET_NAME}
				GIT_REPOSITORY ${TARGET_GIT}
				SOURCE_DIR ${TARGET_DIR}
		)
		FetchContent_Populate(${TARGET_NAME})
	endif()

	cmt_set_global_property(CMT_${TARGET_NAME}_POPULATED TRUE)
	set(CMAKE_MODULE_PATH "${TARGET_DIR}/${ARGS_PATH}" ${CMAKE_MODULE_PATH})
	cmt_logger_set_scoped_context(WARNING ${PROJECT})
	file(GLOB_RECURSE CMAKE_FILES "${TARGET_DIR}/${ARGS_PATH}/*.cmake")
	foreach(CMAKE_FILE ${CMAKE_FILES})
		include(${CMAKE_FILE})
	endforeach()
	cmt_logger_reset_scoped_context()
endfunction()

function(cmt_fetch_dependencies)
	cmt_fetch_cmake_module_from_github(sakra cotire PATH "CMake")
	cmt_fetch_cmake_module_from_github(onqtam ucm)
	cmt_fetch_cmake_module_from_github(sbellus json-cmake PATH "")

	set(ENABLE_COVERAGE ON)
	cmt_fetch_cmake_module_from_github(RWTH-HPC CMake-codecov)
endfunction()

function(cmt_setup)
	cmt_fetch_dependencies()
endfunction()

cmt_include_all(${CMAKE_CURRENT_LIST_DIR}/modules)
cmt_include_all(${CMAKE_CURRENT_LIST_DIR}/tools)
cmt_include_all(${CMAKE_CURRENT_LIST_DIR}/cxx)
