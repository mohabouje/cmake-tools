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

include(${CMAKE_CURRENT_LIST_DIR}/./../tools/cmtools-conan.cmake)


function(cmt_pkg_set_default_backend)
    set(CMT_PACKAGE_MANAGER "conan" PARENT_SCOPE)
    cmt_set_global_property(CMT_PACKAGE_MANAGER "conan")
endfunction()

function(cmt_pkg_set_backend PACKAGE_MANAGER)
    cmt_ensure_choice(${PACKAGE_MANAGER} "conan" "vcpkg")
    set(CMT_PACKAGE_MANAGER ${PACKAGE_MANAGER} PARENT_SCOPE)
    cmt_set_global_property(CMT_PACKAGE_MANAGER ${PACKAGE_MANAGER})
endfunction()

macro(cmt_define_pkg_manager)
    cmt_get_global_property(CMT_PACKAGE_MANAGER VALUE)
    if (NOT VALUE)
        cmt_pkg_set_default()
    endif ()
    set(CMT_PACKAGE_MANAGER ${CMT_PACKAGE_MANAGER} PARENT_SCOPE)
endmacro()

# ! cmt_pkg_install : runs the pkg install command to install the dependencies and provides the path to the toolchain file.
#
# cmt_pkg_install(
#   TOOLCHAIN_FILE
#   [OS <os>]
#   [COMPILER <compiler>]
#   [COMPILE_VERSION <compiler_version>]
#   [COMPILER_LIBCXX <compiler_libcxx>]
#   [BUILD_TYPE <build_type>]
# )
#
# \output   TOOLCHAIN_FILE - The path to the toolchain file.
# \param    OS OS to use for the pkg install command (default: ${CMAKE_HOST_SYSTEM_NAME}).
# \param    COMPILER Compiler to use for the pkg install command (default: ${CMAKE_CXX_COMPILER_ID}).
# \param    COMPILE_VERSION Compiler version to use for the pkg install command (default: ${CMAKE_CXX_COMPILER_VERSION}).
# \param    COMPILER_LIBCXX Compiler libcxx to use for the pkg install command (default: ${CMAKE_CXX_COMPILER_LIBCXX}).
# \param    BUILD_TYPE Build type to use for the pkg install command (default: CMAKE_BUILD_TYPE)
# \param    INSTALL_DIR Directory where the pkg install command will be executed (default: ${CMAKE_CURRENT_BINARY_DIR}/pkg)
# \param    WORKING_DIR Directory where the pkg install command will be executed (default: ${CMAKE_SOURCE_DIR})
#
function(cmt_pkg_install TOOLCHAIN_FILE)
    cmt_define_pkg_manager()
    if (${CMT_PACKAGE_MANAGER} STREQUAL "conan")
        cmt_conan_install(${ARGN})
    elseif (${CMT_PACKAGE_MANAGER} STREQUAL "vcpkg")
        cmt_fatal("vcpkg is not supported yet")
    else()
        cmt_fatal("Unknown package manager: ${CMT_PACKAGE_MANAGER}")
    endif()
endfunction()

# ! cmt_pkg_install : runs the pkg install command to install the dependencies and loads toolchain file.
#
# cmt_pkg_install(
#   [OS <os>]
#   [COMPILER <compiler>]
#   [COMPILE_VERSION <compiler_version>]
#   [COMPILER_LIBCXX <compiler_libcxx>]
#   [BUILD_TYPE <build_type>]
# )
#
# \param    OS OS to use for the pkg install command (default: pkg-default-profile)
# \param    COMPILER Compiler to use for the pkg install command (default: pkg-default-profile)
# \param    COMPILE_VERSION Compiler version to use for the pkg install command (default: pkg-default-profile)
# \param    COMPILER_LIBCXX Compiler libcxx to use for the pkg install command (default: pkg-default-profile)
# \param    BUILD_TYPE Build type to use for the pkg install command (default: CMAKE_BUILD_TYPE)
# \param    INSTALL_DIR Directory where the pkg install command will be executed (default: ${CMAKE_CURRENT_BINARY_DIR}/pkg)
# \param    WORKING_DIR Directory where the pkg install command will be executed (default: ${CMAKE_SOURCE_DIR})
#
function(cmt_pkg_setup)
    cmt_define_pkg_manager()
    if (${CMT_PACKAGE_MANAGER} STREQUAL "conan")
        cmt_conan_setup(${ARGN})
    elseif (${CMT_PACKAGE_MANAGER} STREQUAL "vcpkg")
        cmt_fatal("vcpkg is not supported yet")
    else()
        cmt_fatal("Unknown package manager: ${CMT_PACKAGE_MANAGER}")
    endif()
endfunction()

function(cmt_pkg_load TOOLCHAIN_FILE)
    cmt_define_pkg_manager()
    if (${CMT_PACKAGE_MANAGER} STREQUAL "conan")
        cmt_conan_load(${TOOLCHAIN_FILE})
    elseif (${CMT_PACKAGE_MANAGER} STREQUAL "vcpkg")
        cmt_fatal("vcpkg is not supported yet")
    else()
        cmt_fatal("Unknown package manager: ${CMT_PACKAGE_MANAGER}")
    endif()
endfunction()

# ! cmt_pkg_import_packages
# Import a list of packages from the default package manager to the current project.
#
#
# \variadic PACKAGES List of packages to import
# \option   REQUIRED - If set, the function will fail if the package is not found.
# \param    OS OS to use for the pkg install command
# \param    COMPILER Compiler to use for the pkg install command
# \param    ARCHITECTURE Architecture to use for the pkg install command
# \param    CONFIG Build type to use for the pkg install command
# \group    COMPONENTS The components to import from the package
#
function (cmt_pkg_import_packages)
    cmt_parse_arguments(ARGS "REQUIRED" "OS;COMPILER;ARCHITECTURE;CONFIG" "" ${ARGN})
    cmt_forward_arguments(ARGS "REQUIRED" "OS;COMPILER;ARCHITECTURE;CONFIG" "" FORWARD_ARGS)
    if (${CMT_PACKAGE_MANAGER} STREQUAL "conan")
        cmt_conan_import_packages(${ARGS_UNPARSED_ARGUMENTS} ${FORWARD_ARGS})
    elseif (${CMT_PACKAGE_MANAGER} STREQUAL "vcpkg")
        cmt_fatal("vcpkg is not supported yet")
    else()
        cmt_fatal("Unknown package manager: ${ARGS_PACKAGE_MANAGER}")
    endif()
endfunction()

# ! cmt_pkg_import
# Import a list of packages from the default package manager to the current project.
#
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
    if (${CMT_PACKAGE_MANAGER} STREQUAL "conan")
        cmt_conan_import_package(${PACKAGE_NAME} ${FORWARD_ARGS})
    elseif (${CMT_PACKAGE_MANAGER} STREQUAL "vcpkg")
        cmt_fatal("vcpkg is not supported yet")
    else()
        cmt_fatal("Unknown package manager: ${ARGS_PACKAGE_MANAGER}")
    endif()
endfunction()