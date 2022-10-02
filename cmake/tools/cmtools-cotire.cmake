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

include(${CMAKE_CURRENT_LIST_DIR}/./../utility/cmtools-args.cmake)
include(${CMAKE_CURRENT_LIST_DIR}/./../utility/cmtools-env.cmake)

cmt_disable_logger()
include(${CMAKE_CURRENT_LIST_DIR}/./../third_party/cotire.cmake)
cmt_enable_logger()

# Functions summary:
# - cmt_target_enable_cotire

# !cmt_target_enable_cotire:
#
# For a target TARGET, adds a prefix header with all found headers used in this TARGET, cause it to be included when
# building TARGET and precompile the prefix header before building TARGET. Also adds a new target TARGET_unity with a
# single-source file which includes every other source file in one compilation unit.
#
# The TARGET_unity target will be set up to depend on any libraries this TARGET links to, and will prefer _unity versions of those libraries if  Davailable.
#
# \input TARGET: Target to accelerate
# \option NO_UNITY_BUILD: Don't generate TARGET_unity
# \option NO_PRECOMPILED_HEADERS: Don't generate a precompiled header
#
function (cmt_target_enable_cotire TARGET)
    cmake_parse_arguments (ACCELERATION "NO_UNITY_BUILD;NO_PRECOMPILED_HEADERS" "" "" ${ARGN})
    cmt_ensure_target(${TARGET})

    if (NOT CMT_ENABLE_COTIRE)
        return()
    endif()

    set (COTIRE_PROPERTIES)
    cmt_add_switch (COTIRE_PROPERTIES ACCELERATION_NO_UNITY_BUILD ON "COTIRE_ADD_UNITY_BUILD OFF" OFF "COTIRE_ADD_UNITY_BUILD ON")
    cmt_add_switch (COTIRE_PROPERTIES ACCELERATION_NO_PRECOMPILED_HEADERS ON "COTIRE_ENABLE_PRECOMPILED_HEADER OFF" OFF "COTIRE_ENABLE_PRECOMPILED_HEADER ON")
    string (REPLACE " " ";" COTIRE_PROPERTIES "${COTIRE_PROPERTIES}")

    set_target_properties (${TARGET} PROPERTIES CMT_ACCELERATED ON ${COTIRE_PROPERTIES})
    set_target_properties (${TARGET} PROPERTIES COTIRE_PREFIX_HEADER_IGNORE_PATH "")

    cmt_disable_logger()
    cotire (${TARGET})
    cmt_enable_logger()
endfunction ()



# !cmt_add_target
# Generates a target eligible for cotiring - unity build and/or precompiled header
#
# cmt_add_target(
#   TARGET
#   [CPP_PER_UNIT <cpp per unit>]
#   [PCH_FILE <pch file>]
#   [UNITY_EXCLUDE <source1> <source2>...]
# )
# \input TARGET Target to add cotiring
# \param CPP_PER_UNIT The number of cpp files per unity unit
# \param PCH_FILE The precompiled header file
# \group UNITY_EXCLUDE The source files to exclude from unity build
#
function(cmt_target_generate_cotire TARGET)
    cmake_parse_arguments(ARGS "" "SUFFIX;GLOBAL;PCH_FILE;CPP_PER_UNITY" "UNITY_EXCLUDED" ${ARGN})
    cmt_required_arguments(ARGS "" "NAME;TYPE" "")
    cmt_default_argument(ARGS SUFFIX "cotire")
    cmt_default_argument(ARGS GLOBAL "cotire")
	cmt_default_argument(ARGS CPP_PER_UNITY 100)
    cmt_ensure_target(${TARGET})


    if(NOT CMT_ENABLE_COTIRE)
        return()
    endif()

    cmt_strip_extraneous_sources(${TARGET} TARGET_SOURCES)

    cmt_count_sources(NUM_SOURCES ${TARGET_SOURCES})
    if (${NUM_SOURCES} LESS 2)
        return()
    endif()

endfunction()