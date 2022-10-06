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


macro(__cmt_cxx_target_feature TARGET FUNCTION)
    cmt_parse_arguments(ARGS "" "" "INTERFACE;PUBLIC;PRIVATE" ${ARGN})
    cmt_ensure_target(${TARGET})

    cmt_target_get_property(${TARGET} TYPE TARGET_TYPE REQUIRED)
    if (TARGET_TYPE STREQUAL "INTERFACE_LIBRARY")
        set(INTERACTION_TYPE INTERFACE)
    else()
        set(INTERACTION_TYPE PUBLIC)
    endif()

    if (ARGS_PRIVATE OR ARGS_PUBLIC OR ARGS_INTERFACE)
        cmt_forward_arguments(ARGS "" "" "INTERFACE;PUBLIC;PRIVATE" FORWARD_ARGS)
        cmake_language(EVAL CODE "${FUNCTION}(${TARGET} ${FORWARD_ARGS})")
    elseif (ARGS_UNPARSED_ARGUMENTS)
        cmake_language(EVAL CODE "${FUNCTION}(${TARGET} ${INTERACTION_TYPE} ${ARGS_UNPARSED_ARGUMENTS})")
    endif ()
endmacro()

macro(cmt_cxx_target_set_packages TARGET)
    cmt_parse_arguments(ARGS "" "" "INTERFACE;PUBLIC;PRIVATE" ${ARGN})
    cmt_ensure_target(${TARGET})
    if (ARGS_PRIVATE OR ARGS_PUBLIC OR ARGS_INTERFACE)
        foreach(DEPENDENCY ${ARGS_PRIVATE})
            cmt_pkg_list_components(${DEPENDENCY} COMPONENTS)
            target_link_libraries(${TARGET} PRIVATE ${COMPONENTS})
        endforeach()
        foreach(DEPENDENCY ${ARGS_INTERFACE})
            cmt_pkg_list_components(${DEPENDENCY} COMPONENTS)
            target_link_libraries(${TARGET} INTERFACE ${COMPONENTS})
        endforeach()
        foreach(DEPENDENCY ${ARGS_PUBLIC})
            cmt_pkg_list_components(${DEPENDENCY} COMPONENTS)
            target_link_libraries(${TARGET} PUBLIC ${COMPONENTS})
        endforeach()
    elseif (ARGS_UNPARSED_ARGUMENTS)
        foreach(DEPENDENCY ${ARGS_UNPARSED_ARGUMENTS})
            cmt_pkg_list_components(${DEPENDENCY} COMPONENTS)
            target_link_libraries(${TARGET} PUBLIC ${COMPONENTS})
        endforeach()
    endif ()
endmacro()

macro(cmt_cxx_target_set_headers TARGET)
    cmt_cxx_target_ensure_headers(${TARGET} ${ARGN})
    __cmt_cxx_target_feature(${TARGET} target_sources ${ARGN})
endmacro()

macro(cmt_cxx_target_set_sources TARGET)
    cmt_cxx_target_ensure_sources(${TARGET} ${ARGN})
    __cmt_cxx_target_feature(${TARGET} target_sources ${ARGN})
endmacro()

macro(cmt_cxx_target_set_include_directories TARGET)
    cmt_cxx_target_ensure_directories(${TARGET} ${ARGN})
    __cmt_cxx_target_feature(${TARGET} target_include_directories ${ARGN})
endmacro()

macro(cmt_cxx_target_set_compile_options TARGET)
    cmt_cxx_target_ensure_compiler_options(${TARGET} ${ARGN})
    __cmt_cxx_target_feature(${TARGET} target_compile_options ${ARGN})
endmacro()

macro(cmt_cxx_target_set_link_options TARGET)
    cmt_cxx_target_ensure_linker_options(${TARGET} ${ARGN})
    __cmt_cxx_target_feature(${TARGET} target_link_options ${ARGN})
endmacro()

macro(cmt_cxx_target_set_dependencies TARGET)
    __cmt_cxx_target_feature(${TARGET} target_link_libraries ${ARGN})
endmacro()

macro(cmt_cxx_target_set_definitions TARGET)
    __cmt_cxx_target_feature(${TARGET} target_compile_definitions ${ARGN})
endmacro()

function(cmt_cxx_target_set_properties TARGET TYPE DOMAIN GROUP)
    cmt_target_set_property(${TARGET} CMT_TARGET_TYPE ${TYPE})
    cmt_target_set_property(${TARGET} CMT_TARGET_DOMAIN ${DOMAIN})
    cmt_target_set_property(${TARGET} CMT_TARGET_GROUP ${GROUP})
    cmt_target_set_property(${TARGET} CMT_TARGET_LANGUAGE CXX)
endfunction()

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

function(cmt_cxx_declare_packages MAP_NAME)
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
#   <DISABLE_STATIC_ANALYSIS>
#   <DISABLE_CPPLINT>
#   <DISABLE_CPPCHECK>
#   <DISABLE_CLANG_TIDY>
#   <DISABLE_IWYU>
#   <DISABLE_CCACHE>
#   <DISABLE_COTIRE>
#   <DISABLE_WARNINGS_AS_ERRORS>
#   <DISABLE_LTO>
#   TARGET_NAME
#   [TYPE type]
#   [PREFIX <prefix>]
#   [DOMAIN <domain>]
#   [GROUP <group>]
#   [DEFINITIONS ...]
#   [LINK_OPTIONS ...]
#   [COMPILE_OPTIONS ...]
#   [DEPENDENCIES ...]
#   [PACKAGES ...]
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
# \group DEPENDENCIES A map of dependencies (other targets)
# \group PACKAGES A map of other dependencies (packages from the system or packages from the package manager)
# \group LINK_OPTIONS A map of link options
# \group COMPILE_OPTIONS A map of compile options
# \group INCLUDE_DIRECTORIES A map include directories
#
function(__cmt_cxx_add_target NAME TYPE DOMAIN GROUP)
    cmt_parse_arguments(ARGS
            "DISABLE_STATIC_ANALYSIS;DISABLE_CPPLINT;DISABLE_CLANG_TIDY;DISABLE_CPPCHECK;DISABLE_IWYU;DISABLE_CCACHE;DISABLE_COTIRE;DISABLE_WARNINGS_AS_ERRORS;DISABLE_LTO"
            ""
            "HEADERS;SOURCES;DEFINITIONS;LINK_OPTIONS;COMPILE_OPTIONS;INCLUDE_DIRECTORIES;DEPENDENCIES;PACKAGES"
            ${ARGN})
    cmt_ensure_choice(TYPE "STATIC;SHARED;INTERFACE;MODULE;EXECUTABLE;BRIDGE")
    cmt_ensure_choice(DOMAIN "PUBLIC;PRIVATE;INTERFACE")
    cmt_ensure_choice(GROUP "LIBRARY;EXECUTABLE;BENCHMARK;TEST")

    set(TARGET_NAME ${NAME})
    cmt_cxx_target_create(${TARGET_NAME} ${TYPE})
    cmt_cxx_target_ensure_compatibility(${TARGET_NAME} ${TYPE} HEADERS ${ARGS_HEADERS} SOURCES ${ARGS_SOURCES} DEPENDENCIES ${ARGS_DEPENDENCIES})
    cmt_cxx_target_set_headers(${TARGET_NAME} ${ARGS_HEADERS})
    cmt_cxx_target_set_sources(${TARGET_NAME} ${ARGS_SOURCES})
    cmt_cxx_target_set_include_directories(${TARGET_NAME} ${ARGS_INCLUDE_DIRECTORIES})
    cmt_cxx_target_set_dependencies(${TARGET_NAME} ${ARGS_DEPENDENCIES})
    cmt_cxx_target_set_packages(${TARGET_NAME} ${ARGS_PACKAGES})
    cmt_cxx_target_set_definitions(${TARGET_NAME} ${ARGS_DEFINITIONS})
    cmt_cxx_target_set_compile_options(${TARGET_NAME} ${ARGS_COMPILE_OPTIONS})
    cmt_cxx_target_set_link_options(${TARGET_NAME} ${ARGS_LINK_OPTIONS})
    cmt_cxx_target_set_properties(${TARGET_NAME} ${TYPE} ${DOMAIN} ${GROUP})

    cmt_target_enable_all_warnings(${TARGET_NAME})
    cmt_target_enable_effective_cxx_warnings(${TARGET_NAME})
    cmt_target_configure_compiler_optimization_options(${TARGET_NAME})


    if (NOT ${ARGS_DISABLE_CPPLINT} AND NOT ${ARGS_DISABLE_STATIC_ANALYSIS})
        cmt_target_enable_cpplint(${TARGET_NAME})
    endif ()

    if (NOT ${ARGS_DISABLE_CLANG_TIDY} AND NOT ${ARGS_DISABLE_STATIC_ANALYSIS})
        cmt_target_enable_clang_tidy(${TARGET_NAME})
    endif ()

    if (NOT ${ARGS_DISABLE_CPPCHECK} AND NOT ${ARGS_DISABLE_STATIC_ANALYSIS})
        cmt_target_enable_cppcheck(${TARGET_NAME})
    endif ()

    if (NOT ${ARGS_DISABLE_IWYU} AND NOT ${ARGS_DISABLE_STATIC_ANALYSIS})
        cmt_target_enable_iwyu(${TARGET_NAME})
    endif ()

    if (NOT ${ARGS_DISABLE_CCACHE})
        cmt_target_enable_ccache(${TARGET_NAME})
    endif ()

    if (NOT ${ARGS_DISABLE_LTO})
        cmt_target_enable_lto(${TARGET_NAME})
    endif ()

    if (NOT ${ARGS_DISABLE_COTIRE})
        # TODO: add an option to create cotire without mirroring but disabling the original target
        # cmt_target_enable_cotire(${TARGET_NAME})
    endif ()

    if (NOT ${ARGS_DISABLE_WARNINGS_AS_ERRORS})
        cmt_target_enable_warnings_as_errors(${TARGET_NAME})
    else()
        cmt_target_disable_warnings_as_errors(${TARGET_NAME})
    endif ()

    string(TOLOWER ${GROUP} GROUP_LOWER)
    string(TOLOWER ${DOMAIN} DOMAIN_LOWER)
    string(TOLOWER ${TYPE} TYPE_LOWER)
    cmt_log("Found ${GROUP_LOWER}: ${TARGET_NAME} (${DOMAIN_LOWER} ${TYPE_LOWER})")
endfunction()


function(cmt_cxx_static_library NAME)
    cmt_parse_arguments(ARGS "" "DOMAIN" "HEADERS;SOURCES;DEFINITIONS;LINK_OPTIONS;COMPILE_OPTIONS;INCLUDE_DIRECTORIES;DEPENDENCIES;PACKAGES" ${ARGN})
    cmt_default_argument(ARGS DOMAIN "PUBLIC")
    cmt_forward_arguments(ARGS "" "" "HEADERS;SOURCES;DEFINITIONS;LINK_OPTIONS;COMPILE_OPTIONS;INCLUDE_DIRECTORIES;DEPENDENCIES;PACKAGES" FORWARD_ARGS)
    __cmt_cxx_add_target(${NAME} STATIC ${ARGS_DOMAIN} LIBRARY ${FORWARD_ARGS})
endfunction()

function(cmt_cxx_shared_library NAME)
    cmt_parse_arguments(ARGS "" "DOMAIN" "HEADERS;SOURCES;DEFINITIONS;LINK_OPTIONS;COMPILE_OPTIONS;INCLUDE_DIRECTORIES;DEPENDENCIES;PACKAGES" ${ARGN})
    cmt_default_argument(ARGS DOMAIN "PUBLIC")
    cmt_forward_arguments(ARGS "" "" "HEADERS;SOURCES;DEFINITIONS;LINK_OPTIONS;COMPILE_OPTIONS;INCLUDE_DIRECTORIES;DEPENDENCIES;PACKAGES" FORWARD_ARGS)
    __cmt_cxx_add_target(${NAME} SHARED ${ARGS_DOMAIN} LIBRARY ${FORWARD_ARGS})
endfunction()

function(cmt_cxx_interface_library NAME)
    cmt_parse_arguments(ARGS "" "DOMAIN" "HEADERS;DEFINITIONS;LINK_OPTIONS;COMPILE_OPTIONS;INCLUDE_DIRECTORIES;DEPENDENCIES;PACKAGES" ${ARGN})
    cmt_default_argument(ARGS DOMAIN "PUBLIC")
    cmt_forward_arguments(ARGS "" "" "HEADERS;DEFINITIONS;LINK_OPTIONS;COMPILE_OPTIONS;INCLUDE_DIRECTORIES;DEPENDENCIES;PACKAGES" FORWARD_ARGS)
    __cmt_cxx_add_target(${NAME} INTERFACE ${ARGS_DOMAIN} LIBRARY ${FORWARD_ARGS})
endfunction()

function(cmt_cxx_bridge_library NAME)
    cmt_parse_arguments(ARGS "" "DOMAIN" "DEFINITIONS;LINK_OPTIONS;COMPILE_OPTIONS;INCLUDE_DIRECTORIES;DEPENDENCIES;PACKAGES" ${ARGN})
    cmt_default_argument(ARGS DOMAIN "PUBLIC")
    cmt_forward_arguments(ARGS "" "" "DEFINITIONS;LINK_OPTIONS;COMPILE_OPTIONS;INCLUDE_DIRECTORIES;DEPENDENCIES;PACKAGES" FORWARD_ARGS)
    __cmt_cxx_add_target(${NAME} BRIDGE ${ARGS_DOMAIN} LIBRARY ${FORWARD_ARGS})
endfunction()

function(cmt_cxx_library NAME)
    cmt_parse_arguments(ARGS "" "DOMAIN" "HEADERS;SOURCES;DEFINITIONS;LINK_OPTIONS;COMPILE_OPTIONS;INCLUDE_DIRECTORIES;DEPENDENCIES;PACKAGES" ${ARGN})
    cmt_default_argument(ARGS DOMAIN "PUBLIC")
    __cmt_cxx_count_argument(HEADER_INTERFACE_COUNT HEADER_PUBLIC_COUNT HEADER_PRIVATE_COUNT ${ARGS_HEADERS})
    __cmt_cxx_count_argument(SOURCE_INTERFACE_COUNT SOURCE_PUBLIC_COUNT SOURCE_PRIVATE_COUNT ${ARGS_SOURCES})
    math(EXPR TOTAL_SOURCE_COUNT "${SOURCE_INTERFACE_COUNT} + ${SOURCE_PUBLIC_COUNT} + ${SOURCE_PRIVATE_COUNT}")
    math(EXPR TOTAL_HEADER_COUNT "${HEADER_INTERFACE_COUNT} + ${HEADER_PUBLIC_COUNT} + ${HEADER_PRIVATE_COUNT}")
    if (TOTAL_SOURCE_COUNT EQUAL 0 AND TOTAL_HEADER_COUNT EQUAL 0)
        cmt_forward_arguments(ARGS "" "" "DEFINITIONS;LINK_OPTIONS;COMPILE_OPTIONS;INCLUDE_DIRECTORIES;DEPENDENCIES;PACKAGES" FORWARD_ARGS)
        cmt_cxx_bridge_library(${NAME} ${FORWARD_ARGS})
    elseif (TOTAL_SOURCE_COUNT EQUAL 0)
        cmt_forward_arguments(ARGS "" "" "HEADERS;DEFINITIONS;LINK_OPTIONS;COMPILE_OPTIONS;INCLUDE_DIRECTORIES;DEPENDENCIES;PACKAGES" FORWARD_ARGS)
        cmt_cxx_interface_library(${NAME} ${FORWARD_ARGS})
    else()
        cmt_forward_arguments(ARGS "" "" "HEADERS;SOURCES;DEFINITIONS;LINK_OPTIONS;COMPILE_OPTIONS;INCLUDE_DIRECTORIES;DEPENDENCIES;PACKAGES" FORWARD_ARGS)
        cmt_cxx_static_library(${NAME} ${FORWARD_ARGS})
    endif ()
endfunction()

function(cmt_cxx_executable NAME)
    cmt_parse_arguments(ARGS "" "DOMAIN" "HEADERS;SOURCES;DEFINITIONS;LINK_OPTIONS;COMPILE_OPTIONS;INCLUDE_DIRECTORIES;DEPENDENCIES;PACKAGES" ${ARGN})
    cmt_default_argument(ARGS DOMAIN "PUBLIC")
    cmt_forward_arguments(ARGS "" "PREFIX" "HEADERS;SOURCES;DEFINITIONS;LINK_OPTIONS;COMPILE_OPTIONS;INCLUDE_DIRECTORIES;DEPENDENCIES;PACKAGES" FORWARD_ARGS)
    __cmt_cxx_add_target(${NAME} EXECUTABLE ${ARGS_DOMAIN} EXECUTABLE ${FORWARD_ARGS})
endfunction()

function(cmt_cxx_benchmark NAME)
    cmt_parse_arguments(ARGS "" "DOMAIN" "HEADERS;SOURCES;DEFINITIONS;LINK_OPTIONS;COMPILE_OPTIONS;INCLUDE_DIRECTORIES;DEPENDENCIES;PACKAGES" ${ARGN})
    cmt_default_argument(ARGS DOMAIN "PRIVATE")
    cmt_forward_arguments(ARGS "" "PREFIX" "HEADERS;SOURCES;DEFINITIONS;LINK_OPTIONS;COMPILE_OPTIONS;INCLUDE_DIRECTORIES;DEPENDENCIES;PACKAGES" FORWARD_ARGS)
    __cmt_cxx_add_target(${NAME} EXECUTABLE ${ARGS_DOMAIN} BENCHMARK ${FORWARD_ARGS})
    if (NOT ${CMAKE_BUILD_TYPE} STREQUAL "Release")
        cmt_log("Benchmark ${NAME} was built as ${CMAKE_BUILD_TYPE}. Timings may be affected.")
    endif()
    cmt_target_register_in_group(${NAME} "benchmark")
endfunction()

function(cmt_cxx_test NAME)
    cmt_parse_arguments(ARGS "" "DOMAIN" "HEADERS;SOURCES;DEFINITIONS;LINK_OPTIONS;COMPILE_OPTIONS;INCLUDE_DIRECTORIES;DEPENDENCIES;PACKAGES" ${ARGN})
    cmt_default_argument(ARGS DOMAIN "PRIVATE")
    cmt_forward_arguments(ARGS "" "PREFIX" "HEADERS;SOURCES;DEFINITIONS;LINK_OPTIONS;COMPILE_OPTIONS;INCLUDE_DIRECTORIES;DEPENDENCIES;PACKAGES" FORWARD_ARGS)
    __cmt_cxx_add_target(${NAME} EXECUTABLE ${ARGS_DOMAIN} TEST ${FORWARD_ARGS})
endfunction()