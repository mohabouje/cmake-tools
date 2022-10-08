
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

# ! cmt_yacg_configure
# Generate all protocols from the standard folder
#
# cmt_yacg_configure()
#
function(cmt_yacg_configure)
    cmt_parse_arguments(ARGS "" "SCHEMA;INSTALL_DIR" "" ${ARGN})
    cmt_default_argument(ARGS SCHEMA "${PROJECT_SOURCE_DIR}/schema")
    cmt_default_argument(ARGS INSTALL_DIR "${CMAKE_CURRENT_BINARY_DIR}/.yacg")

    cmt_log("Generating protocols from ${ARGS_SCHEMA} to ${ARGS_INSTALL_DIR}")

    find_package(PythonInterp REQUIRED)
    execute_process(COMMAND ${PYTHON_EXECUTABLE} ${PROJECT_SOURCE_DIR}/yacg/yacg.py --schema-path ${ARGS_SCHEMA} --root-path ${ARGS_INSTALL_DIR}
            WORKING_DIRECTORY ${PROJECT_SOURCE_DIR}
            RESULT_VARIABLE EXECUTION_RETURN_CODE
            OUTPUT_VARIABLE EXECUTION_OUTPUT)
    if(NOT ${EXECUTION_RETURN_CODE} EQUAL 0)
        file(GLOB_RECURSE YACG_FILES ${PROJECT_SOURCE_DIR}/yacgdeps/*)
        file (REMOVE ${YACG_FILES})
        cmt_fatal("YACG failed with code ${EXECUTION_RETURN_CODE}: ${YACG_OUTPUT}")
    endif()

    macro(subdirlist result curdir)
        file(GLOB children RELATIVE ${curdir} ${curdir}/*)
        set(dirlist "")
        foreach(child ${children})
            if(IS_DIRECTORY ${curdir}/${child})
                list(APPEND dirlist ${child})
            endif()
        endforeach()
        set(${result} ${dirlist})
    endmacro()
    
    subdirlist(YACG_DEPENDENCIES  ${PROJECT_SOURCE_DIR}/yacgdeps)
    foreach(dependency ${YACG_DEPENDENCIES})
        add_subdirectory(${ARGS_INSTALL_DIR}/${dependency})
    endforeach()
endfunction()