cmake_minimum_required(VERSION 3.23)
project(cmake-tools VERSION 0.0.1 LANGUAGES CXX DESCRIPTION "CMake Tools")
set(CMAKE_EXPORT_COMPILE_COMMANDS ON)
set(CMAKE_CXX_STANDARD 20)
set(CMAKE_CXX_STANDARD_REQUIRED ON)
set(CMAKE_CXX_EXTENSIONS OFF)

set(CMAKE_MODULE_PATH ${CMAKE_MODULE_PATH} "${CMAKE_SOURCE_DIR}/cmake")
include(cmake/cmtools.cmake)


enable_testing()
include(GoogleTest)
add_subdirectory(tests)