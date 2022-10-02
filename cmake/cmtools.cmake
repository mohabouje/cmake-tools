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

if(CMT_SETUP_INCLUDED)
	return()
endif()
set(CMT_SETUP_INCLUDED ON)

set(CMT_DEFAULT_BUILD_TYPE "Debug" CACHE STRING "Choose the type of build, options are: Debug Release RelWithDebInfo MinSizeRel.")


include(${CMAKE_CURRENT_LIST_DIR}/options.cmake)

include(${CMAKE_CURRENT_LIST_DIR}/utility/cmtools-logger.cmake)
include(${CMAKE_CURRENT_LIST_DIR}/utility/cmtools-args.cmake)
include(${CMAKE_CURRENT_LIST_DIR}/utility/cmtools-config.cmake)
include(${CMAKE_CURRENT_LIST_DIR}/utility/cmtools-env.cmake)
include(${CMAKE_CURRENT_LIST_DIR}/utility/cmtools-fsystem.cmake)
include(${CMAKE_CURRENT_LIST_DIR}/utility/cmtools-lists.cmake)
include(${CMAKE_CURRENT_LIST_DIR}/utility/cmtools-targets.cmake)
include(${CMAKE_CURRENT_LIST_DIR}/utility/cmtools-compiler.cmake)
include(${CMAKE_CURRENT_LIST_DIR}/utility/cmtools-finder.cmake)
include(${CMAKE_CURRENT_LIST_DIR}/utility/cmtools-cache.cmake)



include(${CMAKE_CURRENT_LIST_DIR}/tools/cmtools-integration.cmake)
include(${CMAKE_CURRENT_LIST_DIR}/tools/cmtools-pch.cmake)
include(${CMAKE_CURRENT_LIST_DIR}/tools/cmtools-ccache.cmake)
include(${CMAKE_CURRENT_LIST_DIR}/tools/cmtools-clang-format.cmake)
include(${CMAKE_CURRENT_LIST_DIR}/tools/cmtools-clang-tidy.cmake)
include(${CMAKE_CURRENT_LIST_DIR}/tools/cmtools-clang-build-analyzer.cmake)
include(${CMAKE_CURRENT_LIST_DIR}/tools/cmtools-iwyu.cmake)
include(${CMAKE_CURRENT_LIST_DIR}/tools/cmtools-lizard.cmake)
include(${CMAKE_CURRENT_LIST_DIR}/tools/cmtools-codechecker.cmake)
include(${CMAKE_CURRENT_LIST_DIR}/tools/cmtools-cppcheck.cmake)
include(${CMAKE_CURRENT_LIST_DIR}/tools/cmtools-cpplint.cmake)
include(${CMAKE_CURRENT_LIST_DIR}/tools/cmtools-coverage.cmake)
include(${CMAKE_CURRENT_LIST_DIR}/tools/cmtools-sanitizers.cmake)
include(${CMAKE_CURRENT_LIST_DIR}/tools/cmtools-cotire.cmake)
include(${CMAKE_CURRENT_LIST_DIR}/tools/cmtools-link-time-optimization.cmake)
include(${CMAKE_CURRENT_LIST_DIR}/tools/cmtools-doc.cmake)