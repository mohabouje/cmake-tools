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

set(CMT_PACKAGE_MANAGER_BACKEND_CONAN "conan")
set(CMT_PACKAGE_MANAGER_BACKEND_VCPKG "vcpkg")
mark_as_advanced(CMT_PACKAGE_MANAGER_BACKEND_CONAN CMT_PACKAGE_MANAGER_BACKEND_VCPKG)

# ! cmt_pkg_set_backend
# Change the backend used by the package manager
#
macro(cmt_pkg_set_backend PACKAGE_MANAGER)
    cmt_ensure_choice(${PACKAGE_MANAGER} ${CMT_PACKAGE_MANAGER_BACKEND_CONAN} ${CMT_PACKAGE_MANAGER_BACKEND_VCPKG})
    set(CMT_PACKAGE_MANAGER_BACKEND ${PACKAGE_MANAGER})
    cmt_set_global_property(CMT_PACKAGE_MANAGER_BACKEND ${PACKAGE_MANAGER})
    cmt_log("Package manager backend set to ${PACKAGE_MANAGER}")
endmacro()

#! cmt_pkg_set_default_backend
# Expected to be called at the top of the project.
# It defines a default package manager backend in case the user does not specify one.
#
macro(cmt_pkg_set_default_backend)
    cmt_pkg_set_backend(${CMT_PACKAGE_MANAGER_BACKEND_CONAN})
endmacro()

#! cmt_define_pkg_backend
# Defines a variable with the backend to be used for the package manager.
# It defines the variable CMT_PACKAGE_MANAGER_BACKEND to one of the following values:
# - conan
# - vcpkg
#
# cmt_define_architecture()
#
macro(cmt_define_pkg_backend)
    cmt_get_global_property(CMT_PACKAGE_MANAGER_BACKEND VALUE)
    if (NOT VALUE)
        cmt_pkg_set_default()
    endif ()
    set(CMT_PACKAGE_MANAGER_BACKEND ${CMT_PACKAGE_MANAGER_BACKEND})
endmacro()

# ! cmt_pkg_install : runs the pkg install command to install the dependencies and provides the path to the toolchain file.
#
# cmt_pkg_install(
#   TOOLCHAIN_FILE
#   [OS <os>]
#   [COMPILER <compiler>]
#   [COMPILE_VERSION <compiler_version>]
#   [COMPILER_LIBCXX <compiler_libcxx>]
#   [CONFIG <build_type>]
# )
#
# \output   TOOLCHAIN_FILE - The path to the toolchain file.
# \param    OS OS to use for the pkg install command (default: ${CMAKE_HOST_SYSTEM_NAME}).
# \param    ARCHITECTURE Architecture to use for the pkg install command
# \param    COMPILER Compiler to use for the pkg install command (default: ${CMAKE_CXX_COMPILER_ID}).
# \param    COMPILE_VERSION Compiler version to use for the pkg install command (default: ${CMAKE_CXX_COMPILER_VERSION}).
# \param    COMPILER_LIBCXX Compiler libcxx to use for the pkg install command (default: ${CMAKE_CXX_COMPILER_LIBCXX}).
# \param    CONFIG Build type to use for the pkg install command (default: CMAKE_BUILD_TYPE)
# \param    INSTALL_DIR Directory where the pkg install command will be executed (default: ${CMAKE_CURRENT_BINARY_DIR}/pkg)
# \param    WORKING_DIR Directory where the pkg install command will be executed (default: ${CMAKE_SOURCE_DIR})
#
function(cmt_pkg_install TOOLCHAIN_FILE)
    cmt_parse_arguments(ARGS "" "ARCHITECTURE;OS;COMPILER;COMPILER_VERSION;COMPILER_LIBCXX;CONFIG;INSTALL_DIR;WORKING_DIR" "" ${ARGN})
    cmt_forward_arguments(ARGS "" "ARCHITECTURE;OS;COMPILER;COMPILER_VERSION;COMPILER_LIBCXX;CONFIG;INSTALL_DIR;WORKING_DIR" "" FORWARD_ARGS)

    cmt_define_pkg_backend()
    if (${CMT_PACKAGE_MANAGER_BACKEND} STREQUAL ${CMT_PACKAGE_MANAGER_BACKEND_CONAN})
        cmt_conan_install(LOADED_TOOLCHAIN ${FORWARD_ARGS})
    elseif (${CMT_PACKAGE_MANAGER_BACKEND} STREQUAL ${CMT_PACKAGE_MANAGER_BACKEND_VCPKG})
        cmt_fatal("vcpkg is not supported yet")
    else()
        cmt_fatal("Unknown package manager: ${CMT_PACKAGE_MANAGER_BACKEND}")
    endif()

    set(${TOOLCHAIN_FILE} ${LOADED_TOOLCHAIN} PARENT_SCOPE)
endfunction()

# ! cmt_pkg_load
# Load a toolchain file generated by the package manager backend.
#
macro(cmt_pkg_load TOOLCHAIN_FILE)
    cmt_define_pkg_backend()
    if (${CMT_PACKAGE_MANAGER_BACKEND} STREQUAL ${CMT_PACKAGE_MANAGER_BACKEND_CONAN})
        cmt_conan_load(${TOOLCHAIN_FILE})
    elseif (${CMT_PACKAGE_MANAGER_BACKEND} STREQUAL ${CMT_PACKAGE_MANAGER_BACKEND_VCPKG})
        cmt_fatal("vcpkg is not supported yet")
    else()
        cmt_fatal("Unknown package manager: ${CMT_PACKAGE_MANAGER_BACKEND}")
    endif()
endmacro()

# ! cmt_pkg_import_package
# Import a list of packages from the default package manager to the current project.
#
# cmt_pkg_import_package(
#   PACKAGE_NAME
#   <REQUIRED>
#   [OS <os>]
#   [ARCHITECTURE <architecture>]
#   [COMPILER <compiler>]
#   [BUILD_TYPE <build_type>]
#   [COMPONENTS <components> <components> ...]
# )
#
# \input    PACKAGE_NAME - The name of the package to import
# \option   REQUIRED - If set, the function will fail if the package is not found.
# \param    OS OS to use for the pkg install command
# \param    COMPILER Compiler to use for the pkg install command
# \param    ARCHITECTURE Architecture to use for the pkg install command
# \param    CONFIG Build type to use for the pkg install command
# \group    COMPONENTS The components to import from the package
#
function (cmt_pkg_import_package PACKAGE_NAME)
    cmt_parse_arguments(ARGS "REQUIRED" "OS;COMPILER;ARCHITECTURE;CONFIG" "COMPONENTS" ${ARGN})
    cmt_forward_arguments(ARGS "REQUIRED" "OS;COMPILER;ARCHITECTURE;CONFIG" "COMPONENTS" FORWARD_ARGS)
    if (${CMT_PACKAGE_MANAGER_BACKEND} STREQUAL ${CMT_PACKAGE_MANAGER_BACKEND_CONAN})
        cmt_conan_import_package(${PACKAGE_NAME} ${FORWARD_ARGS})
    elseif (${CMT_PACKAGE_MANAGER_BACKEND} STREQUAL ${CMT_PACKAGE_MANAGER_BACKEND_VCPKG})
        cmt_fatal("vcpkg is not supported yet")
    else()
        cmt_fatal("Unknown package manager: ${ARGS_PACKAGE_MANAGER}")
    endif()
endfunction()

# ! cmt_pkg_import_packages
# Import a list of packages from the default package manager to the current project.
#
# cmt_pkg_import_packages(
#   PACKAGES...
#   <REQUIRED>
#   [OS <os>]
#   [ARCHITECTURE <architecture>]
#   [COMPILER <compiler>]
#   [BUILD_TYPE <build_type>]
#   [COMPONENTS <components> <components> ...]
# )
#
# \variadic PACKAGES List of packages to import
# \option   REQUIRED - If set, the function will fail if the package is not found.
# \param    OS OS to use for the conan install command
# \param    COMPILER Compiler to use for the conan install command
# \param    ARCHITECTURE Compiler version to use for the conan install command
# \param    CONFIG Build type to use for the conan install command (default: CMAKE_BUILD_TYPE)
#
function (cmt_pkg_import_packages)
    cmt_parse_arguments(ARGS "REQUIRED" "OS;COMPILER;ARCHITECTURE;CONFIG" "" ${ARGN})
    cmt_forward_arguments(ARGS "REQUIRED" "OS;COMPILER;ARCHITECTURE;CONFIG" "" FORWARD_ARGS)
    if (${CMT_PACKAGE_MANAGER_BACKEND} STREQUAL ${CMT_PACKAGE_MANAGER_BACKEND_CONAN})
        cmt_conan_import_packages(${ARGS_UNPARSED_ARGUMENTS} ${FORWARD_ARGS})
    elseif (${CMT_PACKAGE_MANAGER_BACKEND} STREQUAL ${CMT_PACKAGE_MANAGER_BACKEND_VCPKG})
        cmt_fatal("vcpkg is not supported yet")
    else()
        cmt_fatal("Unknown package manager: ${ARGS_PACKAGE_MANAGER}")
    endif()
endfunction()

# ! cmt_pkg_link_package
# Import a conan package and links it components to the current target.
#
# cmt_pkg_link_package(
#   TARGET
#   PACKAGE_NAME
#   <REQUIRED>
#   [OS <os>]
#   [ARCHITECTURE <architecture>]
#   [COMPILER <compiler>]
#   [BUILD_TYPE <build_type>]
#   [COMPONENTS <components> <components> ...]
# )
#
# \input    TARGET - The target to link the package to
# \input    PACKAGE_NAME - The name of the package to import
# \option   REQUIRED - If set, the function will fail if the package is not found.
# \param    OS OS to use for the conan install command
# \param    COMPILER Compiler to use for the conan install command
# \param    ARCHITECTURE Compiler version to use for the conan install command
# \param    CONFIG Build type to use for the conan install command (default: CMAKE_BUILD_TYPE)
# \param    COMPONENTS The components to import from the package
#
function(cmt_pkg_link_package TARGET PACKAGE_NAME)
    cmt_parse_arguments(ARGS "REQUIRED" "OS;COMPILER;ARCHITECTURE;CONFIG" "COMPONENTS" ${ARGN})
    cmt_forward_arguments(ARGS "REQUIRED" "OS;COMPILER;ARCHITECTURE;CONFIG" "COMPONENTS" FORWARD_ARGS)
    if (${CMT_PACKAGE_MANAGER_BACKEND} STREQUAL ${CMT_PACKAGE_MANAGER_BACKEND_CONAN})
        cmt_conan_link_package(${TARGET} ${PACKAGE_NAME} ${FORWARD_ARGS})
    elseif (${CMT_PACKAGE_MANAGER_BACKEND} STREQUAL ${CMT_PACKAGE_MANAGER_BACKEND_VCPKG})
        cmt_fatal("vcpkg is not supported yet")
    else()
        cmt_fatal("Unknown package manager: ${ARGS_PACKAGE_MANAGER}")
    endif()
endfunction()

# ! cmt_pkg_link_packages
# Import a conan package and links it components to the current target.
#
# cmt_pkg_link_packages(
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
# \param    ARCHITECTURE Compiler version to use for the conan install command
# \param    CONFIG Build type to use for the conan install command (default: CMAKE_BUILD_TYPE)
#
function(cmt_pkg_link_packages TARGET PACKAGE_NAME)
    cmt_parse_arguments(ARGS "REQUIRED" "OS;COMPILER;ARCHITECTURE;CONFIG" "" ${ARGN})
    cmt_forward_arguments(ARGS "REQUIRED" "OS;COMPILER;ARCHITECTURE;CONFIG" "" FORWARD_ARGS)
    if (${CMT_PACKAGE_MANAGER_BACKEND} STREQUAL ${CMT_PACKAGE_MANAGER_BACKEND_CONAN})
        cmt_conan_link_packages(${TARGET} ${PACKAGE_NAME} ${FORWARD_ARGS})
    elseif (${CMT_PACKAGE_MANAGER_BACKEND} STREQUAL ${CMT_PACKAGE_MANAGER_BACKEND_VCPKG})
        cmt_fatal("vcpkg is not supported yet")
    else()
        cmt_fatal("Unknown package manager: ${ARGS_PACKAGE_MANAGER}")
    endif()
endfunction()

# ! cmt_pkg_list_components
# List the available packages for an imported component
#
# cmt_pkg_list_components(
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
function(cmt_pkg_list_components PACKAGE_NAME COMPONENTS)
    cmt_parse_arguments(ARGS "REQUIRED" "OS;COMPILER;ARCHITECTURE;CONFIG" "" ${ARGN})
    cmt_forward_arguments(ARGS "REQUIRED" "OS;COMPILER;ARCHITECTURE;CONFIG" "" FORWARD_ARGS)
    if (${CMT_PACKAGE_MANAGER_BACKEND} STREQUAL ${CMT_PACKAGE_MANAGER_BACKEND_CONAN})
        cmt_conan_list_components(${TARGET} ${PACKAGE_NAME} LOADED_COMPONENTS ${FORWARD_ARGS})
    elseif (${CMT_PACKAGE_MANAGER_BACKEND} STREQUAL ${CMT_PACKAGE_MANAGER_BACKEND_VCPKG})
        cmt_fatal("vcpkg is not supported yet")
    else()
        cmt_fatal("Unknown package manager: ${ARGS_PACKAGE_MANAGER}")
    endif()
    set(${COMPONENTS} ${LOADED_COMPONENTS} PARENT_SCOPE)
endfunction()