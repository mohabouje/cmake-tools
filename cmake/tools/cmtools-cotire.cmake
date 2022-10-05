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

# Functions summary:
# - cmt_target_generate_cotire


# !cmt_target_generate_cotire
# Generates a target eligible for cotiring - unity build and/or precompiled header
#
# cmt_target_generate_cotire(
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
    cmt_parse_arguments(ARGS "ALL;DEFAULT;" "SUFFIX;GLOBAL;PCH_FILE;CPP_PER_UNITY" "UNITY_EXCLUDED;LANGUAGES" ${ARGN})
    cmt_required_arguments(ARGS "" "NAME;TYPE" "")
    cmt_default_argument(ARGS LANGUAGES "CXX;")
    cmt_default_argument(ARGS SUFFIX "cotire")
    cmt_default_argument(ARGS GLOBAL "cotire")
	cmt_default_argument(ARGS CPP_PER_UNITY 100)
    cmt_ensure_target(${TARGET})

    if (NOT CMT_ENABLE_COTIRE)
        return()
    endif()

    if (NOT CMT_ENABLE_UNITY_BUILDS AND NOT CMT_ENABLE_PRECOMPILED_HEADERS)
        cmt_log("Skipping cotire for target ${TARGET}. Precompiled headers and unity build are disabled.")
        return()
    endif()

    get_target_property(PREVIOUSLY_ENABLED ${TARGET} CMT_COTIRE_ENABLED)
    if (PREVIOUSLY_ENABLED)
        cmt_warning("Target ${TARGET} has already been enabled for cotire")
        return()
    endif()

    set(TEMPORAL_TARGET "${TARGET}-original")
    if (TARGET ${TEMPORAL_TARGET})
        cmt_warning("Target ${TEMPORAL_TARGET} already exists")
        return()
    endif()

    set_target_properties(${TARGET} PROPERTIES CMT_COTIRE_ENABLED ON)
    cmt_target_create_mirror(${TARGET} "original")
    cmt_ensure_target(${TEMPORAL_TARGET})

    cmt_strip_extraneous_sources(${TEMPORAL_TARGET} TARGET_SOURCES)
    cmt_count_sources(NUM_SOURCES ${TARGET_SOURCES})
    if (${NUM_SOURCES} LESS 2)
        cmt_info("Skipping cotire for ${TARGET} because it has less than 2 sources")
        return()
    endif()

    foreach(EXCLUDE_FILE ${ARGS_UNITY_EXCLUDED})
        set_source_files_properties(${EXCLUDE_FILE} PROPERTIES COTIRE_EXCLUDED TRUE)
    endforeach()
    
    set(UNITY_TARGET ${TARGET}-${ARGS_SUFFIX})
    if (TARGET ${UNITY_TARGET})
        cmt_warning("Target ${UNITY_TARGET} already exists")
        return()
    endif()
    
    set(COTIRE_PROPERTIES)
    cmt_boolean(ENABLE_UNITY_BUILDS ${CMT_ENABLE_UNITY_BUILDS})
    cmt_boolean(ENABLE_PRECOMPILED_HEADERS ${CMT_ENABLE_PRECOMPILED_HEADERS} AND DEFINED ARGS_PCH_FILE)
    cmt_boolean(VALID_PCH_FILE ${ENABLE_PRECOMPILED_HEADERS} AND EXISTS ${ARGS_PCH_FILE})
    cmt_add_switch(COTIRE_PROPERTIES ENABLE_UNITY_BUILDS ON "COTIRE_ADD_UNITY_BUILD ON" OFF "COTIRE_ADD_UNITY_BUILD OFF")
    cmt_add_switch(COTIRE_PROPERTIES VALID_PCH_FILE ON "COTIRE_ENABLE_PRECOMPILED_HEADER ON" OFF "COTIRE_ENABLE_PRECOMPILED_HEADER OFF")
    cmt_add_switch(COTIRE_PROPERTIES VALID_PCH_FILE ON "COTIRE_CXX_PREFIX_HEADER_INIT ${ARGS_PCH_FILE}" OFF "")
    string (REPLACE " " ";" COTIRE_PROPERTIES "${COTIRE_PROPERTIES}")

    set_target_properties(${TEMPORAL_TARGET} PROPERTIES CMT_COTIRE_ENABLED ON ${COTIRE_PROPERTIES})
    set_target_properties(${TEMPORAL_TARGET} PROPERTIES COTIRE_PREFIX_HEADER_IGNORE_PATH "")
    set_target_properties(${TEMPORAL_TARGET} PROPERTIES COTIRE_UNITY_TARGET_NAME ${UNITY_TARGET})

    cmt_forward_arguments(ARGS "" "" "LANGUAGES" COTIRE_ARGS)
    cmt_logger_set_scoped_context(STATUS COTIRE)
    cotire (${TEMPORAL_TARGET} ${COTIRE_ARGS} CONFIGURATIONS ${CMAKE_BUILD_TYPE})
    cmt_logger_discard_scoped_context()
    cmt_ensure_target(${UNITY_TARGET})


    # Disable the original target and enable the unity one
    get_target_property(COTIRE_TARGET ${TEMPORAL_TARGET} COTIRE_UNITY_TARGET_NAME)
    set_target_properties(${COTIRE_TARGET} PROPERTIES OUTPUT_NAME ${UNITY_TARGET})
    set_target_properties(${TEMPORAL_TARGET} PROPERTIES EXCLUDE_FROM_ALL 1 EXCLUDE_FROM_DEFAULT_BUILD 1)
    set_target_properties(${COTIRE_TARGET} PROPERTIES EXCLUDE_FROM_ALL 1 EXCLUDE_FROM_DEFAULT_BUILD 1)

    cmt_target_set_ide_directory(${TEMPORAL_TARGET} "Temporal")
    cmt_target_set_ide_directory(${COTIRE_TARGET} "Cotire")

    # Also set the name of the target output as the original one
    set_target_properties(clean_cotire PROPERTIES FOLDER "CMakePredefinedTargets")
    set_target_properties(all_unity PROPERTIES FOLDER "CMakePredefinedTargets")

    cmt_target_wire_dependencies(${TARGET} ${ARGS_SUFFIX})
    cmt_forward_arguments(ARGS "ALL;DEFAULT" "" "" REGISTER_ARGS)
    cmt_target_register_in_group(${COTIRE_TARGET} ${ARGS_GLOBAL} ${REGISTER_ARGS})

endfunction()