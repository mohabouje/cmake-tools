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


function(__cmt_cxx_ensure TYPE HEADERS SOURCES)
    if (NOT SOURCES AND NOT HEADERS)
        cmt_error("The target ${TARGET} must have at least one source or header file")
    endif ()

    if (TYPE STREQUAL "INTERFACE")
        if (SOURCES)
            cmt_error(FATAL_ERROR "The target ${TARGET} cannot have sources")
        endif ()
    endif ()

    if (TYPE STREQUAL "MODULE")
        if (NOT HEADERS)
            cmt_error(FATAL_ERROR "The target ${TARGET} must have at least one header file")
        endif ()
    endif ()

    if (TYPE STREQUAL "STATIC" OR TYPE STREQUAL "SHARED")
        if (NOT SOURCES)
            cmt_error(FATAL_ERROR "The target ${TARGET} must have at least one source file")
        endif ()
    endif ()
endfunction()

macro(__cmt_cxx_target_feature TARGET FUNCTION)
    cmt_parse_arguments(ARGS "" "" "INTERFACE;PUBLIC;PRIVATE" ${ARGN})
    cmt_ensure_target(${TARGET})

    if (ARGS_PRIVATE OR ARGS_PUBLIC OR ARGS_INTERFACE)
        cmt_forward_arguments(ARGS "" "" "INTERFACE;PUBLIC;PRIVATE" FORWARD_ARGS)
        cmake_language(EVAL CODE "${FUNCTION}(${TARGET} ${FORWARD_ARGS})")
    elseif (ARGS_UNPARSED_ARGUMENTS)
        cmake_language(EVAL CODE "${FUNCTION}(${TARGET} ${ARGS_UNPARSED_ARGUMENTS})")
    endif ()
endmacro()

function(__cmt_cxx_create_target TARGET TYPE)
    cmt_ensure_not_target(${TARGET})
    if (${TYPE} STREQUAL "EXECUTABLE")
        add_executable(${TARGET})
    else ()
        add_library(${TARGET} ${TYPE})
    endif()
endfunction()

macro(__cmt_cxx_headers TARGET)
    __cmt_cxx_target_feature(${TARGET} target_sources ${ARGN})
endmacro()

macro(__cmt_cxx_sources TARGET)
    __cmt_cxx_target_feature(${TARGET} target_sources ${ARGN})
endmacro()

macro(__cmt_cxx_include_directories TARGET)
    __cmt_cxx_target_feature(${TARGET} target_include_directories ${ARGN})
endmacro()

macro(__cmt_cxx_dependencies TARGET)
    cmt_parse_arguments(ARGS "" "" "INTERFACE;PUBLIC;PRIVATE" ${ARGN})
    cmt_ensure_target(${TARGET})

    if (ARGS_PRIVATE OR ARGS_PUBLIC OR ARGS_INTERFACE)
        foreach(DEPENDENCY ${ARGS_UNPARSED_ARGUMENTS})
            cmt_pkg_list_components(${DEPENDENCY} COMPONENTS)
            target_link_libraries(${TARGET} INTERFACE ${COMPONENTS})
        endforeach()
        foreach(DEPENDENCY ${ARGS_INTERFACE})
            cmt_pkg_list_components(${DEPENDENCY} COMPONENTS)
            target_link_libraries(${TARGET} PRIVATE ${COMPONENTS})
        endforeach()
        foreach(DEPENDENCY ${ARGS_PUBLIC})
            cmt_pkg_list_components(${DEPENDENCY} COMPONENTS)
            target_link_libraries(${TARGET} PUBLIC ${COMPONENTS})
        endforeach()
    elseif (ARGS_UNPARSED_ARGUMENTS)
        foreach(DEPENDENCY ${ARGS_PRIVATE})
            cmt_pkg_list_components(${DEPENDENCY} COMPONENTS)
            target_link_libraries(${TARGET} PUBLIC ${COMPONENTS})
        endforeach()
    endif ()
endmacro()

macro(__cmt_cxx_definitions TARGET)
    __cmt_cxx_target_feature(${TARGET} target_compile_definitions ${ARGN})
endmacro()

macro(__cmt_cxx_compile_options TARGET)
    __cmt_cxx_target_feature(${TARGET} target_compile_options ${ARGN})
endmacro()

macro(__cmt_cxx_link_options TARGET)
    __cmt_cxx_target_feature(${TARGET} target_link_options ${ARGN})
endmacro()

function(__cmt_cxx_set_properties TARGET TYPE DOMAIN GROUP)
    cmt_target_set_property(${TARGET} CMT_TARGET_TYPE ${TYPE})
    cmt_target_set_property(${TARGET} CMT_TARGET_DOMAIN ${DOMAIN})
    cmt_target_set_property(${TARGET} CMT_TARGET_GROUP ${GROUP})
    cmt_target_set_property(${TARGET} CMT_TARGET_LANG CXX)
endfunction()

macro(__cmt_cxx_map_argument MAP_NAME)
    cmt_parse_arguments(ARGS "" "" "INTERFACE;PRIVATE;PUBLIC" ${ARGN})
    set(${MAP_NAME}_INTERFACE ${ARGS_INTERFACE} PARENT_SCOPE)
    set(${MAP_NAME}_PRIVATE ${ARGS_PRIVATE} PARENT_SCOPE)
    set(${MAP_NAME}_PUBLIC ${ARGS_PUBLIC} PARENT_SCOPE)

    set (RETURN_LIST)

    list (APPEND RETURN_LIST INTERFACE)
    foreach (VALUE ${ARGS_INTERFACE})
        list (APPEND RETURN_LIST ${VALUE})
    endforeach()

    list (APPEND RETURN_LIST PUBLIC)
    foreach (VALUE ${ARGS_PUBLIC})
        list (APPEND RETURN_LIST ${VALUE})
    endforeach()

    list (APPEND RETURN_LIST PRIVATE)
    foreach (VALUE ${ARGS_PRIVATE})
        list (APPEND RETURN_LIST ${VALUE})
    endforeach()

    set (${MAP_NAME} ${RETURN_LIST} PARENT_SCOPE)
endmacro()

function(cmt_cxx_declare_headers MAP_NAME)
    __cmt_cxx_map_argument(${MAP_NAME} ${ARGN})
endfunction()

function(cmt_cxx_declare_sources MAP_NAME)
    __cmt_cxx_map_argument(${MAP_NAME} ${ARGN})
endfunction()

function(cmt_cxx_declare_definitions MAP_NAME)
    __cmt_cxx_map_argument(${MAP_NAME} ${ARGN})
endfunction()

function(cmt_cxx_declare_dependencies MAP_NAME)
    __cmt_cxx_map_argument(${MAP_NAME} ${ARGN})
endfunction()

function(cmt_cxx_declare_compiler_options MAP_NAME)
    __cmt_cxx_map_argument(${MAP_NAME} ${ARGN})
endfunction()

function(cmt_cxx_declare_linker_options MAP_NAME)
    __cmt_cxx_map_argument(${MAP_NAME} ${ARGN})
endfunction()


# ! __cmt_cxx_add_target
# This function creates a target with the specified name and properties
#
# __cmt_cxx_add_target(
#   TARGET_NAME
#   [TYPE type]
#   [PREFIX <prefix>]
#   [DOMAIN <domain>]
#   [GROUP <group>]
#   [DEFINITIONS ...]
#   [LINK_OPTIONS ...]
#   [COMPILE_OPTIONS ...]
#   [DEPENDENCIES ...]
#   [INCLUDE_DIRECTORIES ...]
#   [HEADERS ...]
#   [SOURCES <source1> <source2> ...]
# )
#
# \input TARGET The name of the target to be created
# \input TYPE The type of the target. It can be either EXECUTABLE, STATIC, SHARED, INTERFACE, or MODULE
# \input DOMAIN The domain of the target. It can be either PUBLIC, PRIVATE, or INTERFACE
# \input GROUP The group of the target. It can be either LIBRARY, EXECUTABLE, SCRIPT, TOOL, BENCHMARK or TEST
# \group HEADERS A map of headers
# \group SOURCES A map of sources
# \group DEFINITIONS A map of definitions
# \group DEPENDENCIES A map of dependencies from the package manager
# \group LIBRARIES A map of other dependencies (targets)
# \group LINK_OPTIONS A map of link options
# \group COMPILE_OPTIONS A map of compile options
# \group INCLUDE_DIRECTORIES A map include directories
#
function(__cmt_cxx_add_target NAME TYPE DOMAIN GROUP)
    cmt_parse_arguments(ARGS "" "" "HEADERS;SOURCES;DEFINITIONS;LINK_OPTIONS;COMPILE_OPTIONS;INCLUDE_DIRECTORIES;DEPENDENCIES;LIBRARIES" ${ARGN})
    cmt_ensure_choice(TYPE "STATIC;SHARED;INTERFACE;MODULE;EXECUTABLE")
    cmt_ensure_choice(DOMAIN "PUBLIC;PRIVATE;INTERFACE")
    cmt_ensure_choice(GROUP "LIBRARY;EXECUTABLE;SCRIPT;TOOL;BENCHMARK;TEST")

    set(TARGET_NAME ${NAME})
    __cmt_cxx_ensure(${TYPE} "${ARGS_HEADERS}" "${ARGS_SOURCES}")
    __cmt_cxx_create_target(${TARGET_NAME} ${TYPE})
    __cmt_cxx_headers(${TARGET_NAME} ${ARGS_HEADERS})
    __cmt_cxx_sources(${TARGET_NAME} ${ARGS_SOURCES})
    __cmt_cxx_include_directories(${TARGET_NAME} ${ARGS_INCLUDE_DIRECTORIES})
    __cmt_cxx_dependencies(${TARGET_NAME} ${ARGS_DEPENDENCIES})
    __cmt_cxx_definitions(${TARGET_NAME} ${ARGS_DEFINITIONS})
    __cmt_cxx_compile_options(${TARGET_NAME} ${ARGS_COMPILE_OPTIONS})
    __cmt_cxx_link_options(${TARGET_NAME} ${ARGS_LINK_OPTIONS})
    __cmt_cxx_set_properties(${TARGET_NAME} ${TYPE} ${DOMAIN} ${GROUP})

    string(TOLOWER ${GROUP} GROUP_LOWER)
    string(TOLOWER ${DOMAIN} DOMAIN_LOWER)
    cmt_log("Adding a new ${GROUP_LOWER}: ${TARGET_NAME} (${DOMAIN_LOWER})")
endfunction()


function(cmt_cxx_static_library NAME)
    cmt_parse_arguments(ARGS "" "DOMAIN" "HEADERS;SOURCES;DEFINITIONS;LINK_OPTIONS;COMPILE_OPTIONS;INCLUDE_DIRECTORIES;DEPENDENCIES;LIBRARIES" ${ARGN})
    cmt_default_argument(ARGS DOMAIN "PUBLIC")
    cmt_forward_arguments(ARGS "" "PREFIX" "HEADERS;SOURCES;DEFINITIONS;LINK_OPTIONS;COMPILE_OPTIONS;INCLUDE_DIRECTORIES;DEPENDENCIES;LIBRARIES" FORWARD_ARGS)
    __cmt_cxx_add_target(${NAME} STATIC ${ARGS_DOMAIN} LIBRARY ${FORWARD_ARGS})
endfunction()

function(cmt_cxx_shared_library NAME)
    cmt_parse_arguments(ARGS "" "DOMAIN" "HEADERS;SOURCES;DEFINITIONS;LINK_OPTIONS;COMPILE_OPTIONS;INCLUDE_DIRECTORIES;DEPENDENCIES;LIBRARIES" ${ARGN})
    cmt_default_argument(ARGS DOMAIN "PUBLIC")
    cmt_forward_arguments(ARGS "" "PREFIX" "HEADERS;SOURCES;DEFINITIONS;LINK_OPTIONS;COMPILE_OPTIONS;INCLUDE_DIRECTORIES;DEPENDENCIES;LIBRARIES" FORWARD_ARGS)
    __cmt_cxx_add_target(${NAME} SHARED ${ARGS_DOMAIN} LIBRARY ${FORWARD_ARGS})
endfunction()

function(cmt_cxx_interface_library NAME)
    cmt_parse_arguments(ARGS "" "DOMAIN" "HEADERS;SOURCES;DEFINITIONS;LINK_OPTIONS;COMPILE_OPTIONS;INCLUDE_DIRECTORIES;DEPENDENCIES;LIBRARIES" ${ARGN})
    cmt_default_argument(ARGS DOMAIN "PUBLIC")
    cmt_forward_arguments(ARGS "" "PREFIX" "HEADERS;SOURCES;DEFINITIONS;LINK_OPTIONS;COMPILE_OPTIONS;INCLUDE_DIRECTORIES;DEPENDENCIES;LIBRARIES" FORWARD_ARGS)
    __cmt_cxx_add_target(${NAME} INTERFACE ${ARGS_DOMAIN} LIBRARY ${FORWARD_ARGS})
endfunction()

function(cmt_cxx_executable NAME)
    cmt_parse_arguments(ARGS "" "DOMAIN" "HEADERS;SOURCES;DEFINITIONS;LINK_OPTIONS;COMPILE_OPTIONS;INCLUDE_DIRECTORIES;DEPENDENCIES;LIBRARIES" ${ARGN})
    cmt_default_argument(ARGS DOMAIN "PUBLIC")
    cmt_forward_arguments(ARGS "" "PREFIX" "HEADERS;SOURCES;DEFINITIONS;LINK_OPTIONS;COMPILE_OPTIONS;INCLUDE_DIRECTORIES;DEPENDENCIES;LIBRARIES" FORWARD_ARGS)
    __cmt_cxx_add_target(${NAME} EXECUTABLE ${ARGS_DOMAIN} EXECUTABLE ${FORWARD_ARGS})
endfunction()