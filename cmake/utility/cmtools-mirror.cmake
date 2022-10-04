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

include(${CMAKE_CURRENT_LIST_DIR}/cmtools-args.cmake)
include(${CMAKE_CURRENT_LIST_DIR}/cmtools-env.cmake)

# Functions summary:
# - cmt_setup_mirrored_build_target
# - cmt_wire_mirrored_build_target_dependencies
# - cmt_create_mirrored_build_target

# cmt_setup_mirrored_build_target:
#
# Sets up "mirrored" build target for TARGET, using its sources. Definitions
# and include directories are currently inherited from the directory and
# target-level include directories and definitions on TARGET.
#
# This does not set up a mirrored target's link libraries or dependencies.
#
# \input TARGET: Target to mirror
# \input SUFFIX: Suffix on this mirrored target
# \group COMPILE_FLAGS: Additional compiler flags for this mirrored target
# \group LINK_FLAGS: Additional linker flags for this mirrored target
#
function (cmt_setup_mirrored_build_target TARGET SUFFIX)
    cmake_parse_arguments (SETUP_MIRRORED_BUILD_TARGET  "" "" "COMPILE_FLAGS;LINK_FLAGS" ${ARGN})
    cmt_ensure_target(${TARGET})

    set (MIRRORED_TARGET ${TARGET}-${SUFFIX})
    if (TARGET ${MIRRORED_TARGET})
        cmt_fatal("Target ${MIRRORED_TARGET} already exists")
    endif ()

    get_target_property (TARGET_TYPE ${TARGET} TYPE)
    get_target_property (TARGET_SOURCES ${TARGET} SOURCES)

    string (STRIP "${TARGET_TYPE}" TARGET_TYPE)
    if (TARGET_TYPE MATCHES "^.*_LIBRARY")
        string (FIND "${TARGET_TYPE}" "_" UNDERSCORE_POS)
        string (SUBSTRING "${TARGET_TYPE}" 0 ${UNDERSCORE_POS} LIBRARY_TYPE)
        add_library (${MIRRORED_TARGET} ${LIBRARY_TYPE} ${TARGET_SOURCES})
    elseif ("${TARGET_TYPE}" STREQUAL "EXECUTABLE")
        add_executable (${MIRRORED_TARGET} ${TARGET_SOURCES})

    else ()
        message (FATAL_ERROR "Mirroring targets of type: ${TARGET_TYPE} to "
                             "generate ${MIRRORED_TARGET} is not possible.\n"
                             "The only supported types are STATIC_LIBRARY, "
                             "SHARED_LIBRARY and EXECUTABLE")
    endif ()

    set_property (TARGET ${MIRRORED_TARGET} PROPERTY COMPILE_FLAGS ${SETUP_MIRRORED_BUILD_TARGET_COMPILE_FLAGS} APPEND)
    set_property (TARGET ${MIRRORED_TARGET} PROPERTY LINK_FLAGS ${SETUP_MIRRORED_BUILD_TARGET_LINK_FLAGS} APPEND)
endfunction ()

# ! cmt_wire_mirrored_build_target_dependencies
#
# For a TARGET, find the corresponding mirrored build target TARGET_SUFFIX and wire up its dependencies as follows:
# 1. For each of the original target's LINK_LIBRARIES, find any libraries that are built in this project as targets, determine if a corresponding
#    mirrored version of that target exists with the SUFFIX specified and then link this mirrored target to that one.
# 2. For all other libraries, link the mirrored target to that library.
# 3. Add dependencies as specified in DEPENDENCIES
#
# \input TARGET: Target to mirror
# \input SUFFIX: Suffix on this mirrored target
# \group DEPENDENCIES: Additional dependencies
#
function (cmt_wire_mirrored_build_target_dependencies TARGET SUFFIX)
    cmake_parse_arguments (WIRE_MIRRORED "" "" "DEPENDENCIES" ${ARGN})
    cmt_ensure_target(${TARGET})

    set (MIRRORED_TARGET ${TARGET}-${SUFFIX})
    if (NOT TARGET ${MIRRORED_TARGET})
        message (FATAL_ERROR "A target named ${MIRRORED_TARGET} must exist to wire the dependencies")
    endif()

    if (WIRE_MIRRORED_DEPENDENCIES)
        add_dependencies (${MIRRORED_TARGET} ${WIRE_MIRRORED_DEPENDENCIES})
    endif()

    get_property (TARGET_LIBRARIES TARGET ${TARGET} PROPERTY LINK_LIBRARIES)
    foreach (LIBRARY ${TARGET_LIBRARIES})
        # If LIBRARY is a target then it might also have a corresponding mirrored target, check for that too
        if (TARGET ${LIBRARY})
            set (LIBRARY_MIRRORED_TARGET ${LIBRARY}-${SUFFIX})
            if (TARGET ${LIBRARY_MIRRORED_TARGET})
                target_link_libraries(${MIRRORED_TARGET} ${LIBRARY_MIRRORED_TARGET})
            else()
                target_link_libraries(${MIRRORED_TARGET} ${LIBRARY})
            endif()
        else()
            target_link_libraries(${MIRRORED_TARGET} ${LIBRARY})
        endif()
    endforeach ()
endfunction ()

# ! cmt_create_mirrored_build_target:
#
# Creates a mirrored build target for TARGET named TARGET_SUFFIX. The mirrored build target will use the specified
# COMPILE_FLAGS and LINK_FLAGS and depend on the original target's library dependencies (or mirrored library dependencies)
# with the same SUFFIX. The dependencies in DEPENDENCIES will be added to the mirrored target
#
# \input TARGET: Target to mirror
# \input SUFFIX: Suffix to add to mirrored target
# \group COMPILE_FLAGS: Additional compile flags for mirrored target
# \group LINK_FLAGS: Additional link flags for mirrored target
# \group DEPENDENCIES: Other targets for mirrored target to depend on
#
function (cmt_create_mirrored_build_target TARGET SUFFIX)
    cmake_parse_arguments (CREATE_MIRRORED "" "" "COMPILE_FLAGS;LINK_FLAGS;DEPENDENCIES" ${ARGN})
    
    cmt_forward_arguments (CREATE_MIRRORED  "" "" "COMPILE_FLAGS;LINK_FLAGS" SETUP_TARGET_FORWARD_OPTIONS)
    cmt_setup_mirrored_build_target (${TARGET} ${SUFFIX} ${SETUP_TARGET_FORWARD_OPTIONS})

    cmt_forward_arguments (CREATE_MIRRORED  "" "" "DEPENDENCIES" WIRE_TARGET_FORWARD_OPTIONS)
    cmt_wire_mirrored_build_target_dependencies (${TARGET} ${SUFFIX} ${WIRE_TARGET_FORWARD_OPTIONS})

endfunction ()