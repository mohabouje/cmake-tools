cmake_minimum_required(VERSION 3.23)
project(cmake-tools VERSION 0.0.1 LANGUAGES CXX DESCRIPTION "CMake Tools")
set(CMAKE_EXPORT_COMPILE_COMMANDS ON)
set(CMAKE_CXX_STANDARD 20)
set(CMAKE_CXX_STANDARD_REQUIRED ON)
set(CMAKE_CXX_EXTENSIONS OFF)

set(CMAKE_MODULE_PATH ${CMAKE_MODULE_PATH} "${CMAKE_SOURCE_DIR}/cmake")
include(cmake/cmtools.cmake)

cmt_setup()
cmt_fetch_dependencies()

# Testing integration with conan
cmt_pkg_set_backend("conan")
cmt_pkg_install(TOOLCHAIN_FILE COMPILER_VERSION 13.1)
cmt_pkg_load(${TOOLCHAIN_FILE})
cmt_pkg_import_package(mimalloc ARCHITECTURE X86)
cmt_pkg_import_package(spdlog REQUIRED)
cmt_pkg_import_packages(spdlog xxhash cli11 REQUIRED)

enable_testing()
include(GoogleTest)
add_subdirectory(tests)
