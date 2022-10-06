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
# - cmt_append_global_property_unique
# - cmt_append_global_property
# - cmt_set_global_property
# - cmt_try_set_global_property
# - cmt_get_global_property
# - cmt_try_get_global_property


# ! cmt_set_global_property
#
# Set PROPERTY_VALUE to the global property PROPERTY, only if it is not already defined
#
# \input  PROPERTY Global property to append to.
# \input  PROPERTY_VALUE Item to append, only if not present.
# \option UNIQUE If set, the property will be not overwritten and an error will be raised
#
function (cmt_set_global_property PROPERTY PROPERTY_VALUE)
    cmt_parse_arguments (ARGS "UNIQUE" "" "" ${ARGN})
    get_property (GLOBAL_PROPERTY GLOBAL PROPERTY ${PROPERTY})
    if (DEFINED GLOBAL_PROPERTY AND ${ARGS_UNIQUE})
        cmt_fatal("The global property ${PROPERTY} is already defined (value ${GLOBAL_PROPERTY})")
    endif()

    set_property (GLOBAL PROPERTY ${PROPERTY}  ${PROPERTY_VALUE})
endfunction()

# ! cmt_get_global_property
#
# Load in PROPERTY_VALUE the value of the global property PROPERTY, only if it is not already defined.
#
# \input  PROPERTY Global property to append to.
# \output PROPERTY_VALUE The value of the property
# \option REQUIRED If set, an error will be raised if the property is not defined
#
function (cmt_get_global_property PROPERTY PROPERTY_VALUE)
    cmt_parse_arguments(ARGS "REQUIRED" "" "" ${ARGN})
    get_property (GLOBAL_PROPERTY GLOBAL PROPERTY ${PROPERTY})
    if (NOT DEFINED GLOBAL_PROPERTY AND ${ARGS_REQUIRED})
        cmt_fatal("The global property ${PROPERTY} is not defined.")
    endif()
    set(${PROPERTY_VALUE} ${GLOBAL_PROPERTY} PARENT_SCOPE)
endfunction()

# ! cmt_append_global_property_unique
#
# Append ITEM to the global property PROPERTY, only if it is not
# already part of the list.
#
# \input  PROPERTY Global property to append to.
# \option UNIQUE If set, the property will be not overwritten and an error will be raised
# \variadic List of items to append
#
function (cmt_append_global_property PROPERTY)
    cmt_parse_arguments(ARGS "UNIQUE" "" "" ${ARGN})
    cmt_get_global_property (${PROPERTY} GLOBAL_PROPERTY)
    foreach(ITEM ${ARGS_UNPARSED_ARGUMENTS})
        if (NOT ${ITEM} IN_LIST GLOBAL_PROPERTY OR NOT ${ARGS_UNIQUE})
            set_property (GLOBAL APPEND PROPERTY ${PROPERTY}  ${ITEM})
        else()
            cmt_fatal("The global property ${PROPERTY} (${GLOBAL_PROPERTY}) already contains the item ${ITEM}")
        endif()
    endforeach()
endfunction()

# ! cmt_target_set_property
#
# Set PROPERTY_VALUE to the global property PROPERTY, only if it is not already defined
# If the property is already defined, it will not be overwritten and an error will be raised
#
# \input  TARGET Target to interact with
# \input  PROPERTY Global property to append to.
# \input  PROPERTY_VALUE Item to append, only if not present.
# \option UNIQUE If set, the property will be not overwritten and an error will be raised
#
function (cmt_target_set_property TARGET PROPERTY PROPERTY_VALUE)
    cmt_parse_arguments(ARGS "UNIQUE" "" "" ${ARGN})
    cmt_target_get_property (${TARGET} ${PROPERTY} STORED_PROPERTY)
    if (DEFINED STORED_PROPERTY AND ${ARGS_UNIQUE})
        cmt_fatal("The property ${PROPERTY} is already defined for target ${TARGET} (value ${STORED_PROPERTY})")
    endif()
    set_property (TARGET ${TARGET} PROPERTY ${PROPERTY}  ${PROPERTY_VALUE})
endfunction()


# ! cmt_target_get_property
#
# Load in PROPERTY_VALUE the value of the global property PROPERTY, only if it is not already defined.
# Throw an error if the property is not defined
#
# \input  TARGET Target to interact with
# \input  PROPERTY Global property to append to.
# \output PROPERTY_VALUE The value of the property
# \option REQUIRED If set, an error will be raised if the property is not defined
#
function (cmt_target_get_property TARGET PROPERTY PROPERTY_VALUE)
    cmt_parse_arguments(ARGS "REQUIRED" "" "" ${ARGN})
    get_property (STORED_PROPERTY TARGET ${TARGET} PROPERTY ${PROPERTY})
    if (NOT DEFINED STORED_PROPERTY AND ${ARGS_REQUIRED})
        cmt_fatal("The property ${PROPERTY} is not defined for target ${TARGET}.")
    endif()

    set(${PROPERTY_VALUE} ${STORED_PROPERTY} PARENT_SCOPE)
endfunction()


# ! cmt_target_set_properties
#
# Add a set of properties to a target
#
# \input  TARGET Target to interact with
# \unparsed  List of properties to set [PROPERTY_NAME, PROPERTY_VALUE]
#
function (cmt_target_set_properties TARGET)
    cmt_parse_arguments(ARGS "" "" "" ${ARGN})
    set_target_properties (${TARGET} PROPERTIES ${ARGS_UNPARSED_ARGUMENTS})
endfunction()

# ! cmt_append_global_property_unique
#
# Append ITEM to the global property PROPERTY, only if it is not
# already part of the list.
#
# \input  TARGET Target to interact with
# \input  PROPERTY Global property to append to.
# \option UNIQUE If set, the property will be not overwritten and an error will be raised
# \variadic List of items to append
#
function (cmt_target_append_property TARGET PROPERTY)
    cmt_parse_arguments(ARGS "UNIQUE" "" "" ${ARGN})
    cmt_target_get_property (${TARGET} ${PROPERTY} TARGET_PROPERTY)

    foreach(ITEM ${ARGS_UNPARSED_ARGUMENTS})
        if (NOT ${ITEM} IN_LIST TARGET_PROPERTY OR NOT ${ARGS_UNIQUE})
            set_property (TARGET ${TARGET} APPEND PROPERTY ${PROPERTY} ${ITEM})
        endif()
    endforeach()
endfunction()

# Get all propreties that cmake supports
if(NOT CMAKE_PROPERTY_LIST)
    execute_process(COMMAND cmake --help-property-list OUTPUT_VARIABLE CMAKE_PROPERTY_LIST)
    string(REGEX REPLACE ";" "\\\\;" CMAKE_PROPERTY_LIST "${CMAKE_PROPERTY_LIST}")
    string(REGEX REPLACE "\n" ";" CMAKE_PROPERTY_LIST "${CMAKE_PROPERTY_LIST}")
endif()

function(cmt_print_properties)
    cmt_log("CMAKE_PROPERTY_LIST = ${CMAKE_PROPERTY_LIST}")
endfunction()

function(cmt_print_target_properties target)
    if(NOT TARGET ${target})
        cmt_log("There is no target named '${target}'")
        return()
    endif()

    foreach(property ${CMAKE_PROPERTY_LIST})
        string(REPLACE "<CONFIG>" "${CMAKE_BUILD_TYPE}" property ${property})

        # Fix https://stackoverflow.com/questions/32197663/how-can-i-remove-the-the-location-property-may-not-be-read-from-target-error-i
        if(property STREQUAL "LOCATION" OR property MATCHES "^LOCATION_" OR property MATCHES "_LOCATION$")
            continue()
        endif()

        get_property(was_set TARGET ${target} PROPERTY ${property} SET)
        if(was_set)
            get_target_property(value ${target} ${property})
            cmt_log("${target} ${property} = ${value}")
        endif()
    endforeach()
endfunction()
