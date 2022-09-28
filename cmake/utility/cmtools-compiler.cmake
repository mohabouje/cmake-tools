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

if(CMT_COMPILER_INCLUDED)
	return()
endif()
set(CMT_COMPILER_INCLUDED ON)

include(${CMAKE_CURRENT_LIST_DIR}/cmtools-args.cmake)
include(${CMAKE_CURRENT_LIST_DIR}/cmtools-dev.cmake)
include(${CMAKE_CURRENT_LIST_DIR}/cmtools-env.cmake)

# Functions summary:
# - cmt_target_enable_all_warnings
# - cmt_target_enable_all_warnings
# - cmt_target_enable_generation_header_dependencies

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
    if (CMT_COMPILER MATCHES "Clang")
        target_compile_options(${ARGS_TARGET} PRIVATE -Wall -Wextra -Wpedantic -Werror)
    elseif (CMT_COMPILER MATCHES "GNU")
        target_compile_options(${ARGS_TARGET} PRIVATE -Wall -Wextra -Wpedantic -Werror)
    elseif (CMT_COMPILER MATCHES "MSVC")
        target_compile_options(${ARGS_TARGET} PRIVATE /W4 /WX)
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
        target_compile_options(${ARGS_TARGET} PRIVATE -Weffc++)
    elseif (${CMT_COMPILER}  STREQUAL "GNU")
        target_compile_options(${ARGS_TARGET} PRIVATE -Weffc++)
    else()
        message(WARNING "Cannot enable effective c++ check on non gnu/clang compiler.")
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
        target_compile_options(${ARGS_TARGET} PRIVATE -MD)
    elseif (${CMT_COMPILER}  STREQUAL "GNU")
        target_compile_options(${ARGS_TARGET} PRIVATE -MD)
    else()
        message(WARNING "Cannot generate header dependency on non GCC/Clang compilers.")
    endif()
endfunction()