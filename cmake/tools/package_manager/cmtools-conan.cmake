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

# ! cmt_find_conan
# Try to find the clang-tidy executable.
# If the executable is not found, the function will throw an error.
#
# cmt_find_conan(
#   EXECUTABLE
# )
#
# \output EXECUTABLE The path to the clang-tidy executable.
# \output CONAN_FOUND - True if the executable is found, false otherwise.
# \param BIN_SUBDIR - The subdirectory where the executable is located.
# \group NAMES - The name of the executable.
#
function (cmt_find_conan EXECUTABLE)
    cmt_parse_arguments(ARGS "" "BIN_SUBDIR" "NAMES" ${ARGN})
    cmt_default_argument(ARGS NAMES "conan;")
    cmt_default_argument(ARGS BIN_SUBDIR bin)

    cmt_cache_get_tool(CONAN EXECUTABLE_FOUND EXECUTABLE_PATH EXECUTABLE_VERSION)
    if (${EXECUTABLE_FOUND})
        set(${EXECUTABLE} ${EXECUTABLE_PATH} PARENT_SCOPE)
        return()
    endif()

    foreach (CONAN_EXECUTABLE_NAME ${ARGS_NAMES})
        cmt_find_tool_executable (${CONAN_EXECUTABLE_NAME}
                CONAN_EXECUTABLE
                PATHS ${CONAN_SEARCH_PATHS}
                PATH_SUFFIXES "${ARGS_BIN_SUBDIR}")
        if (CONAN_EXECUTABLE)
            break()
        endif()
    endforeach()

    cmt_report_not_found_if_not_quiet (clang-tidy CONAN_EXECUTABLE
            "The 'clang-tidy' executable was not found in any search or system paths.\n"
            "Please adjust CONAN_SEARCH_PATHS to the installation prefix of the 'clang-tidy' executable or install clang-tidy")

    if (CONAN_EXECUTABLE)
        set (CONAN_VERSION_HEADER "Conan version ")
        cmt_find_tool_extract_version("${CONAN_EXECUTABLE}"
                CONAN_VERSION
                VERSION_ARG --version
                VERSION_HEADER
                "${CONAN_VERSION_HEADER}"
                VERSION_END_TOKEN "\n")
    endif()

    cmt_check_and_report_tool_version(clang-tidy
            "${CONAN_VERSION}"
            REQUIRED_VARS
            CONAN_EXECUTABLE
            CONAN_VERSION)

    cmt_cache_set_tool(CONAN ${CONAN_EXECUTABLE} ${CONAN_VERSION})
    set (${EXECUTABLE} ${CONAN_EXECUTABLE} PARENT_SCOPE)
endfunction()

function(__cmt_conan_normalize_compiler INPUT OUTPUT)
    string(TOLOWER "${INPUT}" LOWER_INPUT)
    if (LOWER_INPUT MATCHES "clang")
        if (CMAKE_CXX_COMPILER_ID MATCHES "AppleClang")
            set(${OUTPUT} "apple-clang" PARENT_SCOPE)
        else()
            set(${OUTPUT} "clang" PARENT_SCOPE)
        endif()
    elseif (LOWER_INPUT MATCHES "gcc")
        set(${OUTPUT} "gcc" PARENT_SCOPE)
    elseif (LOWER_INPUT MATCHES "msvc")
        set(${OUTPUT} "msvc" PARENT_SCOPE)
    else ()
        cmt_fatal("The compiler '${INPUT}' is not supported by conan")
    endif ()
endfunction()

function(__cmt_conan_normalize_libcxx INPUT OUTPUT)
    string(TOLOWER "${INPUT}" LOWER_INPUT)
    if (LOWER_INPUT STREQUAL "libstdc++")
        set(${OUTPUT} "libstdc++11" PARENT_SCOPE)
    elseif (LOWER_INPUT STREQUAL "libc++")
        set(${OUTPUT} "libc++" PARENT_SCOPE)
    else ()
        cmt_fatal("The libcxx '${INPUT}' is not supported by conan")
    endif ()
endfunction()

function(__cmt_conan_normalize_architecture INPUT OUTPUT)
    string(TOLOWER "${INPUT}" LOWER_INPUT)
    if (LOWER_INPUT MATCHES "x86")
        set(${OUTPUT} "x86" PARENT_SCOPE)
    elseif (LOWER_INPUT MATCHES "x86_64")
        set(${OUTPUT} "x86_64" PARENT_SCOPE)
    elseif (LOWER_INPUT STREQUAL "arm")
        set(${OUTPUT} "armv7" PARENT_SCOPE)
    elseif (LOWER_INPUT STREQUAL "arm64")
        set(${OUTPUT} "armv8" PARENT_SCOPE)
    else ()
        cmt_fatal("The architecture '${INPUT}' is not supported by conan")
    endif ()
endfunction()

function(__cmt_conan_normalize_os COMPILER INPUT OUTPUT)
    string(TOLOWER "${INPUT}" LOWER_INPUT)
    if (LOWER_INPUT MATCHES "windows")
        set(${OUTPUT} "Windows" PARENT_SCOPE)
    elseif (LOWER_INPUT MATCHES "linux")
        set(${OUTPUT} "Linux" PARENT_SCOPE)
    elseif (LOWER_INPUT MATCHES "macos")
        set(${OUTPUT} "Macos" PARENT_SCOPE)
    elseif (LOWER_INPUT MATCHES "ios")
        set(${OUTPUT} "iOS" PARENT_SCOPE)
    elseif (LOWER_INPUT MATCHES "android")
        set(${OUTPUT} "Android" PARENT_SCOPE)
    elseif (LOWER_INPUT MATCHES "freebsd")
        set(${OUTPUT} "FreeBSD" PARENT_SCOPE)
    elseif (LOWER_INPUT MATCHES "sunos")
        set(${OUTPUT} "SunOS" PARENT_SCOPE)
    elseif (LOWER_INPUT MATCHES "aix")
        set(${OUTPUT} "AIX" PARENT_SCOPE)
    elseif (LOWER_INPUT MATCHES "qnx")
        set(${OUTPUT} "QNX" PARENT_SCOPE)
    elseif (LOWER_INPUT MATCHES "watchos")
        set(${OUTPUT} "watchOS" PARENT_SCOPE)
    elseif (LOWER_INPUT MATCHES "tvos")
        set(${OUTPUT} "tvOS" PARENT_SCOPE)
    else ()
        cmt_fatal("The os '${INPUT}' is not supported by conan")
    endif ()
endfunction()

function(__cmt_conan_normalizer_compiler_version INPUT OUTPUT)
    string(REPLACE "." ";" TEMPORAL_LIST ${INPUT})
    list(GET TEMPORAL_LIST 0 MAJOR)
    list(GET TEMPORAL_LIST 1 MINOR)
    set(${OUTPUT} "${MAJOR}.${MINOR}" PARENT_SCOPE)
endfunction()

function(__cmt_conan_collect_components PACKAGE_NAME PACKAGE_COMPONENTS)

    set(PACKAGE_COMPONENT_LIST "")
    if (${PACKAGE_NAME}_COMPONENT_NAMES)
        foreach(COMPONENT_NAME ${${PACKAGE_NAME}_COMPONENT_NAMES})
            list(APPEND PACKAGE_COMPONENT_LIST ${COMPONENT_NAME})
        endforeach()
    endif()

    if (${PACKAGE_NAME}_LIBRARIES)
        foreach(COMPONENT_NAME ${${PACKAGE_NAME}_LIBRARIES})
            list(APPEND PACKAGE_COMPONENT_LIST ${COMPONENT_NAME})
        endforeach()
    endif()

    string(TOLOWER ${PACKAGE_NAME} PACKAGE_NAME_LOWER)
    set(LOWER_CANDIDATE "${PACKAGE_NAME_LOWER}::${PACKAGE_NAME_LOWER}")
    if (TARGET ${UPPER_CANDIDATE})
        list(FIND PACKAGE_COMPONENT_LIST ${UPPER_CANDIDATE} INDEX)
        if (${INDEX} EQUAL -1)
            list(APPEND PACKAGE_COMPONENT_LIST ${UPPER_CANDIDATE})
        endif()
    endif()

    string(TOUPPER ${PACKAGE_NAME} PACKAGE_NAME_UPPER)
    set(UPPER_CANDIDATE "${PACKAGE_NAME_UPPER}::${PACKAGE_NAME_UPPER}")
    if (TARGET ${UPPER_CANDIDATE})
        list(FIND PACKAGE_COMPONENT_LIST ${UPPER_CANDIDATE} INDEX)
        if (${INDEX} EQUAL -1)
            list(APPEND PACKAGE_COMPONENT_LIST ${UPPER_CANDIDATE})
        endif()
    endif()

    set(${PACKAGE_COMPONENTS} ${PACKAGE_COMPONENT_LIST} PARENT_SCOPE)
endfunction()

# ! cmt_conan_install : runs the conan install command to install the dependencies and provides the path to the toolchain file.
#
# cmt_conan_install(
#   TOOLCHAIN_FILE
#   [OS <os>]
#   [ARCHITECTURE <architecture>]
#   [COMPILER <compiler>]
#   [COMPILE_VERSION <compiler_version>]
#   [COMPILER_LIBCXX <compiler_libcxx>]
#   [CONFIG <build_type>]
# )
#
# \output   TOOLCHAIN_FILE - The path to the toolchain file.
# \param    OS OS to use for the conan install command (default: conan-default-profile)
# \param    ARCHITECTURE Architecture to use for the pkg install command (default: conan-default-profile)
# \param    COMPILER Compiler to use for the conan install command (default: conan-default-profile)
# \param    COMPILE_VERSION Compiler version to use for the conan install command (default: conan-default-profile)
# \param    COMPILER_LIBCXX Compiler libcxx to use for the conan install command (default: conan-default-profile)
# \param    CONFIG Build type to use for the conan install command (default: CMAKE_BUILD_TYPE)
# \param    INSTALL_DIR Directory where the conan install command will be executed (default: ${CMAKE_CURRENT_BINARY_DIR}/conan)
# \param    WORKING_DIR Directory where the conan install command will be executed (default: ${CMAKE_SOURCE_DIR})
# \param    INSTALL_DIR Directory where the pkg install command will be executed (default: ${CMAKE_CURRENT_BINARY_DIR}/pkg)
# \param    WORKING_DIR Directory where the pkg install command will be executed (default: ${CMAKE_SOURCE_DIR})

function(cmt_conan_install TOOLCHAIN_FILE)
    cmt_parse_arguments(ARGS "" "ARCHITECTURE;OS;COMPILER;COMPILER_VERSION;COMPILER_LIBCXX;BUILD_TYPE;INSTALL_DIR;WORKING_DIR" "" ${ARGN})

    cmt_define_standard_cxx_library()
    cmt_define_os()
    cmt_define_architecture()
    cmt_define_compiler()
    cmt_define_cxx_compiler_version()

    cmt_default_argument(ARGS ARCHITECTURE ${CMT_ARCHITECTURE})
    cmt_default_argument(ARGS OS ${CMT_OS})
    cmt_default_argument(ARGS COMPILER ${CMT_COMPILER})
    cmt_default_argument(ARGS COMPILER_LIBCXX ${CMT_CXX_STANDARD_LIB})
    cmt_default_argument(ARGS COMPILER_VERSION ${CMT_CXX_COMPILER_VERSION})
    cmt_default_argument(ARGS INSTALL_DIR ${CMAKE_CURRENT_BINARY_DIR}/conan)
    cmt_default_argument(ARGS WORKING_DIR ${CMAKE_SOURCE_DIR})
    cmt_default_argument(ARGS BUILD_TYPE ${CMAKE_BUILD_TYPE})

    cmt_find_conan(CONAN_EXECUTABLE REQUIRED)
    set(ARGS_CONAN_INSTALL_ARGS "")

    __cmt_conan_normalize_architecture(${ARGS_ARCHITECTURE} ARCHITECTURE)
    list(APPEND ARGS_CONAN_INSTALL_ARGS "-s" "arch=${ARCHITECTURE}")

    __cmt_conan_normalize_os(${ARGS_COMPILER} ${ARGS_OS} OS)
    list(APPEND ARGS_CONAN_INSTALL_ARGS "-s" "os=${OS}")

    __cmt_conan_normalize_compiler(${ARGS_COMPILER} COMPILER)
    list(APPEND ARGS_CONAN_INSTALL_ARGS "-s" "compiler=${COMPILER}")

    __cmt_conan_normalize_libcxx(${ARGS_COMPILER_LIBCXX} COMPILER_LIBCXX)
    list(APPEND ARGS_CONAN_INSTALL_ARGS "-s" "compiler.libcxx=${COMPILER_LIBCXX}")

    __cmt_conan_normalizer_compiler_version(${ARGS_COMPILER_VERSION} COMPILER_VERSION)
    list(APPEND ARGS_CONAN_INSTALL_ARGS "-s" "compiler.version=${COMPILER_VERSION}")

    list(APPEND ARGS_CONAN_INSTALL_ARGS "-s" "build_type=${ARGS_BUILD_TYPE}")
    list(APPEND ARGS_CONAN_INSTALL_ARGS "--build=missing")
    list(APPEND ARGS_CONAN_INSTALL_ARGS "--output-folder=${ARGS_INSTALL_DIR}")

    cmt_log("Installing conan dependencies...")
    cmt_logger_set_scoped_context(WARNING conan)
    execute_process(COMMAND ${CONAN_EXECUTABLE} install ${ARGS_CONAN_INSTALL_ARGS} ${ARGS_WORKING_DIR}
            RESULT_VARIABLE EXECUTION_RETURN_CODE
            OUTPUT_VARIABLE EXECUTION_OUTPUT)

    if(NOT ${EXECUTION_RETURN_CODE} EQUAL 0)
        cmt_fatal("Conan install failed with code ${EXECUTION_RETURN_CODE}: ${EXECUTION_OUTPUT}")
    endif()
    set(${TOOLCHAIN_FILE} ${ARGS_INSTALL_DIR}/conan_toolchain.cmake PARENT_SCOPE)
    cmt_logger_reset_scoped_context()
endfunction()

macro(cmt_conan_load TOOLCHAIN_FILE)
    cmt_logger_set_scoped_context(WARNING conan)
    include(${TOOLCHAIN_FILE})
    cmt_logger_reset_scoped_context()
    cmt_log("Loading conan toolchain file: ${TOOLCHAIN_FILE}")
endmacro()

# ! cmt_conan_import_package
# Import a conan package into the current project.
#
# cmt_conan_import_package(
#   PACKAGE_NAME
#   <REQUIRED>
#   [OS <os>]
#   [ARCHITECTURE <architecture>]
#   [COMPILER <compiler>]
#   [CONFIG <build_type>]
#   [COMPONENTS components...]
# )
#
# \output   PACKAGE_NAME - The name of the package to import
# \option   REQUIRED - If set, the function will fail if the package is not found.
# \param    OS OS to use for the conan install command  (default: conan-default-profile)
# \param    ARCHITECTURE Architecture to use for the conan install command (default: conan-default-profile)
# \param    COMPILER Compiler to use for the conan install command  (default: conan-default-profile)
# \param    CONFIG Build type to use for the conan install command (default: CMAKE_BUILD_TYPE)
# \group    COMPONENTS The components to import from the package
#
function (cmt_conan_import_package PACKAGE_NAME)
    cmt_parse_arguments(ARGS "REQUIRED" "OS;ARCHITECTURE;COMPILER;CONFIG" "COMPONENTS" ${ARGN})

    cmt_define_os()
    if (DEFINED ARGS_OS)
        cmt_ensure_argument_choice(ARGS OS LINUX MACOS WINDOWS ANDROID IOS)
        if (NOT ${CMT_OS} STREQUAL ${ARGS_OS})
            return()
        endif()
    endif()

    cmt_define_compiler()
    if (DEFINED ARGS_COMPILER)
        cmt_ensure_argument_choice(ARGS COMPILER  GCC ../clang MVSC)
        if (NOT ${CMT_COMPILER} STREQUAL ${ARGS_COMPILER})
            return()
        endif()
    endif()

    cmt_define_architecture()
    if (DEFINED ARGS_ARCHITECTURE)
        cmt_ensure_argument_choice(ARGS ARCHITECTURE X86 ARM32 ARM64)
        if (NOT ${CMT_ARCHITECTURE} STREQUAL ${ARGS_ARCHITECTURE})
            return()
        endif()
    endif()

    if (DEFINED ARGS_CONFIG)
        cmt_ensure_argument_choice(ARGS CONFIG Debug Release RelWithDebInfo MinSizeRel)
        string(TOUPPER ${ARGS_CONFIG} ARGS_CONFIG)
        if (NOT ${CMAKE_BUILD_TYPE} STREQUAL ${ARGS_CONFIG})
            return()
        endif()
    endif()

    cmt_forward_arguments(ARGS "REQUIRED" "" "COMPONENTS" FIND_PACKAGE)
    cmt_logger_set_scoped_context(WARNING conan)
    find_package(${PACKAGE_NAME} ${FIND_PACKAGE})
    cmt_logger_reset_scoped_context()

    cmt_cache_get_package(${PACKAGE_NAME} PACKAGE_FOUND PACKAGE_COMPONENT)
    if (${PACKAGE_FOUND})
        cmt_debug("Skipping importing ${PACKAGE_NAME} because it is already imported")
        return()
    endif()

    __cmt_conan_collect_components(${PACKAGE_NAME} PACKAGE_COMPONENTS)
    cmt_debug("Imported components [${PACKAGE_COMPONENTS}] from conan package ${PACKAGE_NAME}")
    cmt_cache_set_package(${PACKAGE_NAME} ${PACKAGE_COMPONENTS})
endfunction()


# ! cmt_conan_import_packages Import multiple packages installed with conan
# Import multiple conan packages into the current project.
#
# cmt_conan_import_packages(
#   PACKAGES....
#   <REQUIRED>
#   [OS <os>]
#   [ARCHITECTURE <architecture>]
#   [COMPILER <compiler>]
#   [CONFIG <build_type>]
#   [COMPONENTS components...]
# )
#
# \variadic List of packages to import
# \option   REQUIRED - If set, the function will fail if the package is not found.
# \param    OS OS to use for the conan install command  (default: conan-default-profile)
# \param    COMPILER Compiler to use for the conan install command  (default: conan-default-profile)
# \param    CONFIG Build type to use for the conan install command (default: CMAKE_BUILD_TYPE)
# \group    COMPONENTS The components to import from the package
#
function (cmt_conan_import_packages)
    cmt_parse_arguments(ARGS "REQUIRED" "OS;ARCHITECTURE;COMPILER;CONFIG" "" ${ARGN})
    cmt_forward_arguments(ARGS "REQUIRED" "OS;ARCHITECTURE;COMPILER;CONFIG" "" FORWARDED_ARGS)
    foreach (PACKAGE_NAME ${ARGS_UNPARSED_ARGUMENTS})
        cmt_conan_import_package(${PACKAGE_NAME} ${FORWARDED_ARGS})
    endforeach()
endfunction()

# ! cmt_conan_link_package
# Import a conan package and links all or the selected components to the target.
#
# cmt_conan_link_package(
#   TARGET
#   PACKAGE_NAME
#   <REQUIRED>
#   [OS <os>]
#   [ARCHITECTURE <architecture>]
#   [COMPILER <compiler>]
#   [CONFIG <build_type>]
# )
#
# \input    TARGET - The target to link the package to
# \input    PACKAGE_NAME - The name of the package to import
# \option   REQUIRED - If set, the function will fail if the package is not found.
# \param    ARCHITECTURE Architecture to use for the conan install command (default: conan-default-profile)
# \param    OS OS to use for the conan install command
# \param    COMPILER Compiler to use for the conan install command
# \param    CONFIG Build type to use for the conan install command (default: CMAKE_BUILD_TYPE)
# \group    COMPONENTS The components to import from the package
#
function(cmt_conan_link_package TARGET PACKAGE_NAME)
    cmt_parse_arguments(ARGS "REQUIRED" "OS;COMPILER;ARCHITECTURE;CONFIG" "COMPONENTS" ${ARGN})
    cmt_ensure_target(${TARGET})
    cmt_forward_arguments(ARGS "REQUIRED" "OS;COMPILER;ARCHITECTURE;CONFIG" "COMPONENTS" FORWARDED_ARGS)
    cmt_conan_import_package(${PACKAGE_NAME} ${FORWARDED_ARGS})
    cmt_cache_get_package(${PACKAGE_NAME} _ PACKAGE_COMPONENT)
    target_link_libraries(${TARGET} PUBLIC ${PACKAGE_COMPONENT})
endfunction()

# ! cmt_conan_link_packages
# Import a conan package and links all its components to the target.
#
# cmt_conan_link_packages(
#   TARGET
#   PACKAGE_NAME
#   <REQUIRED>
#   [OS <os>]
#   [ARCHITECTURE <architecture>]
#   [COMPILER <compiler>]
#   [CONFIG <build_type>]
# )
#
# \input    TARGET - The target to link the package to
# \input    PACKAGE_NAME - The name of the package to import
# \option   REQUIRED - If set, the function will fail if the package is not found.
# \param    OS OS to use for the conan install command
# \param    COMPILER Compiler to use for the conan install command
# \param    CONFIG Build type to use for the conan install command (default: CMAKE_BUILD_TYPE)
#
function(cmt_conan_link_packages TARGET)
    cmt_parse_arguments(ARGS "REQUIRED" "OS;COMPILER;ARCHITECTURE;CONFIG" "" ${ARGN})
    cmt_ensure_target(${TARGET})
    cmt_forward_arguments(ARGS "REQUIRED" "OS;COMPILER;ARCHITECTURE;CONFIG" "" FORWARDED_ARGS)
    foreach(PACKAGE_NAME ${ARGS_UNPARSED_ARGUMENTS})
        cmt_conan_import_package(${PACKAGE_NAME} ${FORWARDED_ARGS})
        cmt_cache_get_package(${PACKAGE_NAME} _ PACKAGE_COMPONENT)
        target_link_libraries(${TARGET} ${PACKAGE_COMPONENT})
    endforeach()
endfunction()

# ! cmt_conan_list_components
# List the available packages for an imported component
#
# cmt_conan_list_components(
#   PACKAGE_NAME
#   COMPONENTS
#   <REQUIRED>
#   [OS <os>]
#   [ARCHITECTURE <architecture>]
#   [COMPILER <compiler>]
#   [CONFIG <build_type>]
# )
#
# \input    PACKAGE_NAME - The name of the package to import
# \output   COMPONENTS - The components of the package
# \option   REQUIRED - If set, the function will fail if the package is not found.
# \param    OS OS to use for the conan install command  (default: conan-default-profile)
# \param    ARCHITECTURE Architecture to use for the conan install command (default: conan-default-profile)
# \param    COMPILER Compiler to use for the conan install command  (default: conan-default-profile)
# \param    CONFIG Build type to use for the conan install command (default: CMAKE_BUILD_TYPE)
#
function(cmt_conan_list_components PACKAGE_NAME COMPONENTS)
    cmt_parse_arguments(ARGS "REQUIRED" "OS;COMPILER;ARCHITECTURE;CONFIG" "" ${ARGN})
    cmt_forward_arguments(ARGS "REQUIRED" "OS;COMPILER;ARCHITECTURE;CONFIG" "" FORWARDED_ARGS)
    cmt_conan_import_package(${PACKAGE_NAME} ${FORWARDED_ARGS})
    cmt_cache_get_package(${PACKAGE_NAME} _ PACKAGE_COMPONENTS)
    set(${COMPONENTS} ${PACKAGE_COMPONENTS} PARENT_SCOPE)
endfunction()
