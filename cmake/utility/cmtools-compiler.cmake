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

if(CMTOOLS_COMPILER_INCLUDED)
	return()
endif()
set(CMTOOLS_COMPILER_INCLUDED ON)

include(${CMAKE_CURRENT_LIST_DIR}/cmtools-args.cmake)
include(${CMAKE_CURRENT_LIST_DIR}/cmtools-dev.cmake)
include(${CMAKE_CURRENT_LIST_DIR}/cmtools-env.cmake)



option(ENABLE_ALL_WARNINGS "Compile with all warnings for the major compilers"
       OFF)
option(ENABLE_EFFECTIVE_CXX "Enable Effective C++ warnings" OFF)
option(GENERATE_DEPENDENCY_DATA "Generates .d files with header dependencies"
       OFF)

# ! cmtools_target_enable_all_warnings Enable all warnings for the major compilers in the target
#
# cmtools_target_enable_all_warnings(
#   [TARGET <target>]
# )
#
# \param:TARGET TARGET The target to configure
#
function(cmtools_target_enable_all_warnings)
    cmake_parse_arguments(ARGS "" "TARGET" "" ${ARGN})
    cmtools_required_arguments(FUNCTION cmtools_target_enable_all_warnings PREFIX ARGS FIELDS TARGET)
    cmtools_ensure_targets(FUNCTION cmtools_target_enable_all_warnings TARGETS ${ARGS_TARGET}) 

    cmtools_define_compiler()
    if (CMTOOLS_COMPILER MATCHES "Clang")
        target_compile_options(${PROJECT_NAME} PRIVATE -Wall -Wextra -Wpedantic -Werror)
    elseif (CMTOOLS_COMPILER MATCHES "GNU")
        target_compile_options(${PROJECT_NAME} PRIVATE -Wall -Wextra -Wpedantic -Werror)
    elseif (CMTOOLS_COMPILER MATCHES "MSVC")
        target_compile_options(${PROJECT_NAME} PRIVATE /W4 /WX)
    endif()
endmacro()


# ! cmtools_target_enable_all_warnings Enable all warnings for the major compilers in the target
#
# cmtools_target_enable_all_warnings(
#   [TARGET <target>]
# )
#
# \param:TARGET TARGET The target to configure
#
function(cmtools_target_enable_effective_cxx_warnings)
    cmake_parse_arguments(ARGS "" "TARGET" "" ${ARGN})
    cmtools_required_arguments(FUNCTION cmtools_target_enable_effective_cxx_warnings PREFIX ARGS FIELDS TARGET)
    cmtools_ensure_targets(FUNCTION cmtools_target_enable_effective_cxx_warnings TARGETS ${ARGS_TARGET}) 

    cmtools_define_compiler()
    if (CMTOOLS_COMPILER MATCHES "Clang")
        target_compile_options(${PROJECT_NAME} PRIVATE -Weffc++)
    elseif (CMTOOLS_COMPILER MATCHES "GNU")
        target_compile_options(${PROJECT_NAME} PRIVATE -Weffc++)
    else()
        message(WARNING "Cannot enable effective c++ check on non gnu/clang compiler.")
    endif()
endmacro()

# ! cmtools_target_generate_dependency_data Generates .d files with header dependencies
#
# cmtools_target_generate_dependency_data(
#   [TARGET <target>]
# )
#
# \param:TARGET TARGET The target to configure
#
function(cmtools_target_generate_header_dependencies)
    cmake_parse_arguments(ARGS "" "TARGET" "" ${ARGN})
    cmtools_required_arguments(FUNCTION cmtools_target_generate_dependency_data PREFIX ARGS FIELDS TARGET)
    cmtools_ensure_targets(FUNCTION cmtools_target_generate_dependency_data TARGETS ${ARGS_TARGET}) 

    cmtools_define_compiler()
    if (CMTOOLS_COMPILER MATCHES "Clang")
        target_compile_options(${PROJECT_NAME} PRIVATE -MD)
    elseif (CMTOOLS_COMPILER MATCHES "GNU")
        target_compile_options(${PROJECT_NAME} PRIVATE -MD)
    else()
        message(WARNING "Cannot generate header dependency on non GCC/Clang compilers.")
    endif()
endmacro()