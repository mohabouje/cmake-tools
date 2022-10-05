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

# ! cmt_cxx_google_benchmark
# Creates a new target for the Google Benchmark library.
#
# cmt_cxx_google_benchmark(
#   TARGET_NAME
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
# \group HEADERS A map of headers
# \group SOURCES A map of sources
# \group DEFINITIONS A map of definitions
# \group DEPENDENCIES A map of dependencies (other targets)
# \group PACKAGES A map of other dependencies (packages from the system or packages from the package manager)
# \group LINK_OPTIONS A map of link options
# \group COMPILE_OPTIONS A map of compile options
# \group INCLUDE_DIRECTORIES A map include directories
#
function(cmt_cxx_google_benchmark NAME)
    cmt_cxx_benchmark(${NAME} ${ARGN})
    cmt_cxx_target_packages(${NAME} PRIVATE benchmark)
    cmt_target_add_compiler_options(${NAME} -Wno-global-constructors COMPILER CLANG)
endfunction()