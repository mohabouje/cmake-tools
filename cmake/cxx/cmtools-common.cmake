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

macro(__cmt_cxx_map_argument MAP_NAME)
    cmt_parse_arguments(_MAPPING_ARGS "" "" "INTERFACE;PRIVATE;PUBLIC" ${ARGN})
    set(${MAP_NAME}_INTERFACE ${_MAPPING_ARGS_INTERFACE} PARENT_SCOPE)
    set(${MAP_NAME}_PRIVATE ${_MAPPING_ARGS_PRIVATE} PARENT_SCOPE)
    set(${MAP_NAME}_PUBLIC ${_MAPPING_ARGS_PUBLIC} PARENT_SCOPE)

    set (RETURN_LIST)
    list (APPEND RETURN_LIST INTERFACE)
    foreach (VALUE ${_MAPPING_ARGS_INTERFACE})
        list (APPEND RETURN_LIST ${VALUE})
    endforeach()

    list (APPEND RETURN_LIST PUBLIC)
    foreach (VALUE ${_MAPPING_ARGS_PUBLIC})
        list (APPEND RETURN_LIST ${VALUE})
    endforeach()

    list (APPEND RETURN_LIST PRIVATE)
    foreach (VALUE ${_MAPPING_ARGS_PRIVATE})
        list (APPEND RETURN_LIST ${VALUE})
    endforeach()

    set (${MAP_NAME} ${RETURN_LIST} PARENT_SCOPE)
endmacro()

function(__cmt_cxx_count_argument INTERFACE_COUNT PUBLIC_COUNT PRIVATE_COUNT)
    cmt_parse_arguments(ARGS "" "" "INTERFACE;PUBLIC;PRIVATE" ${ARGN})
    if (ARGS_UNPARSED_ARGUMENTS)
        list(LENGTH ARGS_UNPARSED_ARGUMENTS PUBLIC_COUNTED)
        set(${INTERFACE_COUNT} 0 PARENT_SCOPE)
        set(${PUBLIC_COUNT} ${PUBLIC_COUNTED} PARENT_SCOPE)
        set(${PRIVATE_COUNT} 0 PARENT_SCOPE)
        return()
    endif()

    list(LENGTH ARGS_PRIVATE PRIVATE_COUNTED)
    list(LENGTH ARGS_PUBLIC PUBLIC_COUNTED)
    list(LENGTH ARGS_INTERFACE INTERFACE_COUNTED)
    set(${INTERFACE_COUNT} ${INTERFACE_COUNTED} PARENT_SCOPE)
    set(${PUBLIC_COUNT} ${PUBLIC_COUNTED} PARENT_SCOPE)
    set(${PRIVATE_COUNT} ${PRIVATE_COUNTED} PARENT_SCOPE)
endfunction()

function(__cmt_cxx_count_argument_for_target TARGET INTERFACE_COUNT PUBLIC_COUNT PRIVATE_COUNT)
    cmt_parse_arguments(ARGS "" "" "INTERFACE;PUBLIC;PRIVATE" ${ARGN})
    if (ARGS_UNPARSED_ARGUMENTS)
        list(LENGTH ARGS_UNPARSED_ARGUMENTS PUBLIC_COUNTED)
        cmt_target_get_property(${TARGET} TYPE TARGET_TYPE REQUIRED)
        if (TARGET_TYPE STREQUAL "INTERFACE_LIBRARY")
            set(${INTERFACE_COUNT} ${PUBLIC_COUNTED} PARENT_SCOPE)
            set(${PUBLIC_COUNT} 0 PARENT_SCOPE)
            set(${PRIVATE_COUNT} 0 PARENT_SCOPE)
        else()
            set(${INTERFACE_COUNT} 0 PARENT_SCOPE)
            set(${PUBLIC_COUNT} ${PUBLIC_COUNTED} PARENT_SCOPE)
            set(${PRIVATE_COUNT} 0 PARENT_SCOPE)
        endif()
        return()
    endif()

    list(LENGTH ARGS_PRIVATE PRIVATE_COUNTED)
    list(LENGTH ARGS_PUBLIC PUBLIC_COUNTED)
    list(LENGTH ARGS_INTERFACE INTERFACE_COUNTED)
    set(${INTERFACE_COUNT} ${INTERFACE_COUNTED} PARENT_SCOPE)
    set(${PUBLIC_COUNT} ${PUBLIC_COUNTED} PARENT_SCOPE)
    set(${PRIVATE_COUNT} ${PRIVATE_COUNTED} PARENT_SCOPE)
endfunction()

function(cmt_cxx_target_create TARGET TYPE)
    cmt_ensure_not_target(${TARGET})
    cmt_ensure_choice(${TYPE} "INTERFACE;STATIC;SHARED;EXECUTABLE;BRIDGE")
    if (TYPE STREQUAL "EXECUTABLE")
        add_executable(${TARGET})
    elseif (TYPE STREQUAL "BRIDGE")
        add_library(${TARGET} INTERFACE)
    else ()
        add_library(${TARGET} ${TYPE})
    endif()
endfunction()

function(cmt_cxx_target_ensure_compatibility TARGET TYPE)
    cmt_parse_arguments(ENSURE_ARGS "" "" "HEADERS;SOURCES;DEPENDENCIES" ${ARGN})
    __cmt_cxx_count_argument_for_target(${TARGET} HEADER_INTERFACE_COUNT HEADER_PUBLIC_COUNT HEADER_PRIVATE_COUNT ${ENSURE_ARGS_HEADERS})
    __cmt_cxx_count_argument_for_target(${TARGET} SOURCE_INTERFACE_COUNT SOURCE_PUBLIC_COUNT SOURCE_PRIVATE_COUNT ${ENSURE_ARGS_SOURCES})
    __cmt_cxx_count_argument_for_target(${TARGET} DEPENDS_INTERFACE_COUNT DEPENDS_PUBLIC_COUNT DEPENDS_PRIVATE_COUNT ${ENSURE_ARGS_DEPENDENCIES})

    math(EXPR TOTAL_SOURCE_COUNT "${SOURCE_INTERFACE_COUNT} + ${SOURCE_PUBLIC_COUNT} + ${SOURCE_PRIVATE_COUNT}")
    math(EXPR TOTAL_HEADER_COUNT "${HEADER_INTERFACE_COUNT} + ${HEADER_PUBLIC_COUNT} + ${HEADER_PRIVATE_COUNT}")
    math(EXPR TOTAL_DEPENDS_COUNT "${DEPENDS_INTERFACE_COUNT} + ${DEPENDS_PUBLIC_COUNT} + ${DEPENDS_PRIVATE_COUNT}")

    if (TYPE STREQUAL "BRIDGE")
        if (TOTAL_SOURCE_COUNT GREATER 0 OR TOTAL_HEADER_COUNT GREATER 0)
            cmt_error("The target ${TARGET} of type ${TYPE} cannot have headers/sources")
            return()
        endif()

        if (NOT TOTAL_DEPENDS_COUNT GREATER 0)
            cmt_error("The target ${TARGET} of type ${TYPE} should have at least one dependency")
            return()
        endif()
    endif()

    if (TYPE STREQUAL "MODULE")
        if (NOT HEADER_PUBLIC_COUNT GREATER 0)
            cmt_error("The target ${TARGET} of type ${TYPE} must have at least one public header file")
            return()
        endif ()
    endif ()

    if (TYPE STREQUAL "INTERFACE")
        if (TOTAL_SOURCE_COUNT GREATER 0)
            cmt_error("The target ${TARGET} of type ${TYPE} cannot have sources")
            return()
        endif ()
        if (HEADER_PRIVATE_COUNT GREATER 0 OR HEADER_PUBLIC_COUNT GREATER 0)
            cmt_error("The target ${TARGET} of type ${TYPE} must have only interface headers")
            return()
        endif ()
        if (NOT HEADER_INTERFACE_COUNT GREATER 0)
            cmt_error("The target ${TARGET} of type ${TYPE} must have at least one interface header file")
            return()
        endif()
    endif ()

    if (TYPE STREQUAL "STATIC" OR TYPE STREQUAL "SHARED" OR TYPE STREQUAL "EXECUTABLE")
        if (NOT TOTAL_SOURCE_COUNT GREATER 0)
            cmt_error("The target ${TARGET} of type ${TYPE} must have at least one source file")
        endif ()
    endif ()
endfunction()

function(cmt_cxx_target_ensure_sources TARGET)
    cmt_parse_arguments(ARGS "" "" "INTERFACE;PUBLIC;PRIVATE;C_SOURCE_FILE_EXTENSIONS;CXX_SOURCE_FILE_EXTENSIONS;" ${ARGN})
    cmt_default_argument(ARGS C_SOURCE_FILE_EXTENSIONS "${CMAKE_C_SOURCE_FILE_EXTENSIONS}")
    cmt_default_argument(ARGS CXX_SOURCE_FILE_EXTENSIONS "${CMAKE_CXX_SOURCE_FILE_EXTENSIONS}")
    cmt_forward_arguments(ARGS "" "" "C_SOURCE_FILE_EXTENSIONS;CXX_SOURCE_FILE_EXTENSIONS;" FORWARD_ARGS)

    macro(__cmt_cxx_ensure_sources LIST)
        foreach(SOURCE_FILE ${${LIST}})
            if (NOT EXISTS ${SOURCE_FILE})
                cmt_error("Error while adding file to target ${TARGET}: the file ${SOURCE_FILE} does not exist")
            endif ()

            cmt_source_get_group(${SOURCE_FILE} SOURCE_TYPE SOURCE_LANGUAGE ${FORWARD_ARGS})
            if (NOT SOURCE_TYPE STREQUAL "SOURCE" AND NOT SOURCE_LANGUAGE STREQUAL "CXX")
                cmt_error("Error while adding file to target ${TARGET}: the file ${SOURCE_FILE} is not a source file (${SOURCE_TYPE}).\n
                  Extensions: ${ARGS_CXX_SOURCE_FILE_EXTENSIONS}")
            endif ()
        endforeach()
    endmacro()

    if (ARGS_PRIVATE OR ARGS_PUBLIC OR ARGS_INTERFACE)
        __cmt_cxx_ensure_sources(ARGS_PRIVATE)
        __cmt_cxx_ensure_sources(ARGS_PUBLIC)
        __cmt_cxx_ensure_sources(ARGS_INTERFACE)
    elseif (ARGS_UNPARSED_ARGUMENTS)
        __cmt_cxx_ensure_sources(${TARGET} ${ARGS_UNPARSED_ARGUMENTS})
    endif ()
endfunction()

function(cmt_cxx_target_ensure_headers TARGET)
    cmt_parse_arguments(ARGS "" "" "INTERFACE;PUBLIC;PRIVATE;C_SOURCE_FILE_EXTENSIONS;CXX_SOURCE_FILE_EXTENSIONS;" ${ARGN})
    cmt_default_argument(ARGS C_SOURCE_FILE_EXTENSIONS "${CMAKE_C_SOURCE_FILE_EXTENSIONS}")
    cmt_default_argument(ARGS CXX_SOURCE_FILE_EXTENSIONS "${CMAKE_CXX_SOURCE_FILE_EXTENSIONS}")
    cmt_forward_arguments(ARGS "" "" "C_SOURCE_FILE_EXTENSIONS;CXX_SOURCE_FILE_EXTENSIONS;" FORWARD_ARGS)

    macro(__cmt_cxx_ensure_headers LIST)
        foreach(SOURCE_FILE ${${LIST}})
            if (NOT EXISTS ${SOURCE_FILE})
                cmt_error("Error while adding file to target ${TARGET}: the file ${SOURCE_FILE} does not exist")
            endif ()

            cmt_source_get_group(${SOURCE_FILE} SOURCE_TYPE SOURCE_LANGUAGE ${FORWARD_ARGS})
            if (NOT SOURCE_TYPE STREQUAL "HEADER" AND NOT SOURCE_LANGUAGE STREQUAL "CXX")
                cmt_error("Error while adding file to target ${TARGET}: the file ${SOURCE_FILE} is not a header file. Extensions: ${ARGS_C_SOURCE_FILE_EXTENSIONS}")
            endif ()
        endforeach()
    endmacro()

    if (ARGS_PRIVATE OR ARGS_PUBLIC OR ARGS_INTERFACE)
        __cmt_cxx_ensure_headers(ARGS_PRIVATE)
        __cmt_cxx_ensure_headers(ARGS_PUBLIC)
        __cmt_cxx_ensure_headers(ARGS_INTERFACE)
    elseif (ARGS_UNPARSED_ARGUMENTS)
        __cmt_cxx_ensure_headers(${TARGET} ${ARGS_UNPARSED_ARGUMENTS})
    endif ()
endfunction()

function(cmt_cxx_target_ensure_directories TARGET)
    cmt_parse_arguments(ARGS "" "" "INTERFACE;PUBLIC;PRIVATE" ${ARGN})

    macro(__cmt_cxx_ensure_directories LIST)
        foreach(DIRECTORY ${${LIST}})
            if (NOT EXISTS ${DIRECTORY})
                cmt_error("Error while adding include directory to target ${TARGET}: the directory does not exist")
            endif ()
        endforeach()
    endmacro()

    if (ARGS_PRIVATE OR ARGS_PUBLIC OR ARGS_INTERFACE)
        __cmt_cxx_ensure_directories(ARGS_PRIVATE)
        __cmt_cxx_ensure_directories(ARGS_PUBLIC)
        __cmt_cxx_ensure_directories(ARGS_INTERFACE)
    elseif (ARGS_UNPARSED_ARGUMENTS)
        __cmt_cxx_ensure_directories(${TARGET} ${ARGS_UNPARSED_ARGUMENTS})
    endif ()
endfunction()

function(cmt_cxx_target_ensure_compiler_options TARGET)
    cmt_parse_arguments(ARGS "" "" "INTERFACE;PUBLIC;PRIVATE" ${ARGN})
    macro(__cmt_cxx_ensure_compiler_option FLAGS)
        foreach(FLAG ${${FLAGS}})
            cmt_check_compiler_option(RESULT OPTION ${FLAG} LANG CXX)
            if (NOT RESULT)
                cmt_error("Error while adding compiler option to target ${TARGET}: the option ${FLAG} is not valid")
            endif ()
        endforeach()
    endmacro()

    if (ARGS_PRIVATE OR ARGS_PUBLIC OR ARGS_INTERFACE)
        __cmt_cxx_ensure_compiler_option(ARGS_PRIVATE)
        __cmt_cxx_ensure_compiler_option(ARGS_PUBLIC)
        __cmt_cxx_ensure_compiler_option(ARGS_INTERFACE)
    elseif (ARGS_UNPARSED_ARGUMENTS)
        __cmt_cxx_ensure_compiler_option(${TARGET} ${ARGS_UNPARSED_ARGUMENTS})
    endif ()
endfunction()

macro(cmt_cxx_target_ensure_linker_options TARGET)
    cmt_parse_arguments(ARGS "" "" "INTERFACE;PUBLIC;PRIVATE" ${ARGN})
    macro(__cmt_cxx_ensure_linker_option FLAGS)
        foreach(FLAG ${${FLAGS}})
            cmt_check_linker_option(RESULT OPTION ${FLAG} LANG CXX)
            if (NOT RESULT)
                cmt_error("Error while adding linker option to target ${TARGET}: the option ${FLAG} is not valid")
            endif ()
        endforeach()
    endmacro()

    if (ARGS_PRIVATE OR ARGS_PUBLIC OR ARGS_INTERFACE)
        __cmt_cxx_ensure_linker_option(ARGS_PRIVATE)
        __cmt_cxx_ensure_linker_option(ARGS_PUBLIC)
        __cmt_cxx_ensure_linker_option(ARGS_INTERFACE)
    elseif (ARGS_UNPARSED_ARGUMENTS)
        __cmt_cxx_ensure_linker_option(${TARGET} ${ARGS_UNPARSED_ARGUMENTS})
    endif ()
endmacro()

