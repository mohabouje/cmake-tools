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

include(${CMAKE_CURRENT_LIST_DIR}/cmtools-logger.cmake)

# Functions summary:
# - cmt_required_arguments
# - cmt_ensure_on_of_argument
# - cmt_ensure_argument_choice
# - cmt_default_argument
# - cmt_ensure_target
# - cmt_append_each_to_options_with_prefix
# - cmt_forward_options
# - cmt_append_to_global_property
# - cmt_append_to_global_property_unique


# cmt_required_arguments
#
# This function check if the parsed arguments contain the required arguments
#
# \input PREFIX The prefix to give each item in ARGN.
# \input OPTION_ARGS The list of options to forward.
# \input SINGLEVAR_ARGS List of single variables to forward
# \input MULTIVAR_ARGS List of multi variables to forward
#
function(cmt_required_arguments PREFIX OPTION_ARGS SINGLEVAR_ARGS MULTIVAR_ARGS)
    foreach(arg ${OPTION_ARGS})
        if(NOT DEFINED ${PREFIX}_{arg})
            cmt_fatal("${PREFIX}_${arg} argument required.")
        endif()
    endforeach()

    foreach(arg ${FIELDS})
        if(NOT DEFINED ${PREFIX}_{arg})
            cmt_fatal("${PREFIX}_${arg} argument required.")
        endif()
    endforeach()

    foreach(arg ${FIELDS})
        if(NOT DEFINED ${PREFIX}_{arg})
            cmt_fatal("${PREFIX}_${arg} argument required.")
        endif()
    endforeach()
endfunction()

# ! cmt_forward_options
# Creates a list to forward all arguments of the current function to another function.
#
# \input PREFIX The prefix to give each item in ARGN.
# \input OPTION_ARGS The list of options to forward.
# \input SINGLEVAR_ARGS List of single variables to forward
# \input MULTIVAR_ARGS List of multi variables to forward
# \output   RETURN_LIST  The list to append to.
#
function (cmt_forward_options PREFIX OPTION_ARGS SINGLEVAR_ARGS MULTIVAR_ARGS RETURN_LIST_NAME)
    # Temporary accumulation of variables to forward
    set (RETURN_LIST)

    # Option arguments - just forward the value of each set
    # ${PREFIX_OPTION_ARG} as this will be set to the option or to ""
    foreach (OPTION_ARG ${OPTION_ARGS})
        set (PREFIXED_OPTION_ARG ${PREFIX}_${OPTION_ARG})
        if (${PREFIXED_OPTION_ARG})
            list (APPEND RETURN_LIST ${OPTION_ARG})
        endif()
    endforeach()

    # Single-variable arguments - add the name of the argument and its value to
    # the return list
    foreach (SINGLEVAR_ARG ${SINGLEVAR_ARGS})
        set (PREFIXED_SINGLEVAR_ARG ${PREFIX}_${SINGLEVAR_ARG})
        if (${PREFIXED_SINGLEVAR_ARG})
            list (APPEND RETURN_LIST ${SINGLEVAR_ARG})
            list (APPEND RETURN_LIST ${${PREFIXED_SINGLEVAR_ARG}})
        endif()
    endforeach()

    # Multi-variable arguments - add the name of the argument and all its values
    # to the return-list
    foreach (MULTIVAR_ARG ${MULTIVAR_ARGS})
        set (PREFIXED_MULTIVAR_ARG ${PREFIX}_${MULTIVAR_ARG})
        list (APPEND RETURN_LIST ${MULTIVAR_ARG})
        foreach (VALUE ${${PREFIXED_MULTIVAR_ARG}})
            list (APPEND RETURN_LIST ${VALUE})
        endforeach()
    endforeach()

    set (${RETURN_LIST_NAME} ${RETURN_LIST} PARENT_SCOPE)
endfunction()

# cmt_append_each_to_options_with_prefix
#
# Append items in ARGN to MAIN_LIST, giving each PREFIX.
#
# cmt_append_each_to_options_with_prefix(
#   MAIN_LIST
#   PREFIX
#   <WRAP_IN_QUOTES>
# )
#
# \output   MAIN_LIST List to append to.
# \input    PREFIX Prefix to append to each item.
# \option   WRAP_IN_QUOTES If set, each item in ARGN will be wrapped in quotes.
# \group    LIST List of items to append.
#
function (cmt_append_each_to_options_with_prefix MAIN_LIST PREFIX)
    cmake_parse_arguments (APPEND "WRAP_IN_QUOTES" "" "LIST" ${ARGN})
    foreach (ITEM ${APPEND_LIST})
        if (APPEND_WRAP_IN_QUOTES)
            list (APPEND ${MAIN_LIST} "\\\"${PREFIX}${ITEM}\\\"")
        else()
            list (APPEND ${MAIN_LIST} ${PREFIX}${ITEM})
        endif()
    endforeach()
    set (${MAIN_LIST} ${${MAIN_LIST}} PARENT_SCOPE)
endfunction()


# ! cmt_ensure_on_of_argument
# This function check if the parsed arguments contain at least one of the optional ones
#
# cmt_ensure_argument_choice(
#   PREFIX
#   argument1, argument2, ...
# )
#
# \input PREFIX PREFIX specifies the prefix used to parse the arguments
function(cmt_ensure_on_of_argument PREFIX)
    cmake_parse_arguments (CHOICE "" "" "" ${ARGN})
    foreach(arg ${CHOICE_UNPARSED_ARGUMENTS})
        if(DEFINED ${PREFIX}_${arg})
            return()
        endif()
    endforeach()

    cmt_fatal("At least one of the following arguments is required: ${CHOICE_UNPARSED_ARGUMENTS}.")
endfunction()

# ! cmt_ensure_choice
# This function check if the variable contain one of the choices
#
# cmt_ensure_choice(
#   VARIABLE
#   [OPTIONS option, ...]
# )
#
# \input VARIABLE The variable to check
# \group OPTIONS List of choices
#
function(cmt_ensure_choice VARIABLE)
    cmake_parse_arguments (ARGS "" "" "" ${ARGN})
    foreach(arg ${ARGS_UNPARSED_ARGUMENTS})
        if (${VARIABLE} STREQUAL ${arg})
            return()
        endif()
    endforeach()
    cmt_fatal("Argument ${ARGUMENT} is not one of the following choices: ${CHOICES}")
endfunction()


# ! cmt_ensure_argument_choice
# This function check if the parsed argument contain one of the choices
#
# cmt_ensure_argument_choice(
#   PREFIX
#   ARGUMENT
#   [OPTIONS option, ...]
# )
#
# \input PREFIX specifies the prefix used to parse the arguments
# \input ARGUMENT The argument to check
# \group OPTIONS List of choices
#
function(cmt_ensure_argument_choice PREFIX ARGUMENT)
    cmake_parse_arguments (ARGS "" "" "" ${ARGN})
    foreach(arg ${ARGS_UNPARSED_ARGUMENTS})
        if (${PREFIX}_${ARGUMENT} STREQUAL ${arg})
            return()
        endif()
    endforeach()
    cmt_fatal("Argument ${ARGUMENT} is not one of the following choices: ${ARGS_UNPARSED_ARGUMENTS}")
endfunction()

# ! cmake_default_argument
# This functions checks if an argument was set, if not, it sets it to the default value
#
# cmake_default_argument(
#   PREFIX
#   ARGUMENT
#   [DEFAULT <default>]
# )
#
# \input PREFIX specifies the prefix used to parse the arguments
# \input ARGUMENT Contain the argument to check
# \input DEFAULT Contain the default value to set if the argument is not set
function(cmt_default_argument PREFIX ARGUMENT DEFAULT)
    if(NOT DEFINED ${PREFIX}_${ARGUMENT})
        set(${PREFIX}_${ARGUMENT} ${DEFAULT} PARENT_SCOPE)
    endif()
endfunction()


# ! cmt_ensure_target : Checks if the list of targets exist and are valid
#
# cmt_ensure_target(
#   TARGET
# )
#
# \input TARGET Target to check
#
function(cmt_ensure_target TARGET)
    if(NOT TARGET ${TARGET})
        cmt_fatal("${TARGET} is not a valid target.")
    endif()
endfunction()

# ! cmt_ensure_target : Checks if the list of targets exist and are valid
#
# cmt_ensure_targets(
#   <target1> <target2> ...
# )
#
# \input List of targets to be checked
function(cmt_ensure_targets)
    cmake_parse_arguments(ENSURE_TARGET "" "" "" ${ARGN})
    foreach(arg ${ENSURE_TARGET_UNPARSED_ARGUMENTS})
        cmt_ensure_target(${arg})
    endforeach()
endfunction()

# ! cmt_append_to_global_property_unique
#
# Append ITEM to the global property PROPERTY, only if it is not
# already part of the list.
#
# \input    PROPERTY Global property to append to.
# \input    ITEM Item to append, only if not present.
function (cmt_append_to_global_property_unique PROPERTY ITEM)
    get_property (GLOBAL_PROPERTY GLOBAL PROPERTY ${PROPERTY})
    set (LIST_CONTAINS_ITEM FALSE)

    foreach (LIST_ITEM ${GLOBAL_PROPERTY})
        if (LIST_ITEM STREQUAL ${ITEM})
            set(LIST_CONTAINS_ITEM TRUE)
            break()
        endif()
    endforeach()

    if(NOT LIST_CONTAINS_ITEM)
        set_property (GLOBAL APPEND PROPERTY ${PROPERTY}  ${ITEM})
    endif()
endfunction()

# ! cmt_set_global_property
#
# Set PROPERTY_VALUE to the global property PROPERTY, only if it is not already defined
# If the property is already defined, it will not be overwritten and an error will be raised
#
# \input  PROPERTY Global property to append to.
# \input  PROPERTY_VALUE Item to append, only if not present.
#
function (cmt_set_global_property PROPERTY PROPERTY_VALUE)
    get_property (GLOBAL_PROPERTY GLOBAL PROPERTY ${PROPERTY})
    if (DEFINED GLOBAL_PROPERTY)
        cmt_fatal("The global property ${PROPERTY} is already defined.")
    endif()

    set_property (GLOBAL PROPERTY ${PROPERTY}  ${PROPERTY_VALUE})
endfunction()

# ! cmt_try_set_global_property
#
# Set PROPERTY_VALUE to the global property PROPERTY, only if it is not already defined
# If the property is already defined, it will not be overwritten and be ignored
#
# \input  PROPERTY Global property to append to.
# \input  PROPERTY_VALUE Item to append, only if not present.
# \output PROPERTY_FOUND True if the property is defined, false otherwise
#
macro (cmt_try_set_global_property PROPERTY PROPERTY_VALUE PROPERTY_FOUND)
    get_property (GLOBAL_PROPERTY GLOBAL PROPERTY ${PROPERTY})
    if (DEFINED GLOBAL_PROPERTY)
        set(${PROPERTY_FOUND} TRUE PARENT_SCOPE)
    else()
        set(${PROPERTY_FOUND} FALSE PARENT_SCOPE)
        set_property (GLOBAL PROPERTY ${PROPERTY}  ${PROPERTY_VALUE})
    endif()
endmacro()


# ! cmt_get_global_property
#
# Load in PROPERTY_VALUE the valie of the global property PROPERTY, only if it is not already defined.
# Throw an error if the property is not defined
#
# \input  PROPERTY Global property to append to.
# \output PROPERTY_VALUE The value of the property
#
function (cmt_get_global_property PROPERTY PROPERTY_VALUE)
    get_property (GLOBAL_PROPERTY GLOBAL PROPERTY ${PROPERTY})
    if (DEFINED GLOBAL_PROPERTY)
        set(${PROPERTY_VALUE} ${GLOBAL_PROPERTY} PARENT_SCOPE)
    else()
        cmt_fatal("The global property ${PROPERTY} is not defined.")
    endif()
endfunction()

# ! cmt_try_get_global_property
#
# Load in PROPERTY_VALUE the valie of the global property PROPERTY, only if it is not already defined.
#
# \input  PROPERTY Global property to append to.
# \output PROPERTY_FOUND True if the property is defined, false otherwise
# \output PROPERTY_VALUE The value of the property
#
function (cmt_try_get_global_property PROPERTY PROPERTY_FOUND PROPERTY_VALUE)
    get_property (GLOBAL_PROPERTY GLOBAL PROPERTY ${PROPERTY})
    if (DEFINED GLOBAL_PROPERTY)
        set(${PROPERTY_FOUND} TRUE PARENT_SCOPE)
        set(${PROPERTY_VALUE} ${GLOBAL_PROPERTY} PARENT_SCOPE)
    else()
        set(${PROPERTY_FOUND} FALSE PARENT_SCOPE)
        set(${PROPERTY_VALUE} ${GLOBAL_PROPERTY} PARENT_SCOPE)
    endif()
endfunction()

# ! cmt_append_to_global_property
#
# Append ITEM to the global property PROPERTY.
#
# \input    PROPERTY Global property to append to.
# \input    ITEM Item to append
# \group    LIST List of items to append.
function (cmt_append_to_global_property PROPERTY)
    cmake_parse_arguments (APPEND "" "" "LIST" ${ARGN})
    foreach (ITEM ${APPEND_LIST})
        set_property (GLOBAL APPEND PROPERTY ${PROPERTY} ${ITEM})
    endforeach()
endfunction()

# ! cmt_add_switch:
# Specify certain command line switches depending on value of
# boolean variable.
#
# \input  ALL_OPTIONS Existing list of command line switches.
# \input  OPTION_NAME Boolean variable to check.
# \option ON Switch to add if boolean variable is true.
# \option OFF Switch to add if boolean variable is false.
#
function (cmt_add_switch ALL_OPTIONS OPTION_NAME)
    set (ADD_SWITCH_SINGLEVAR_ARGS ON OFF)
    cmake_parse_arguments (ADD_SWITCH
                           ""
                           "${ADD_SWITCH_SINGLEVAR_ARGS}"
                           ""
                           ${ARGN})

    if (${OPTION_NAME})
        list (APPEND ${ALL_OPTIONS} ${ADD_SWITCH_ON})
    else()
        list (APPEND ${ALL_OPTIONS} ${ADD_SWITCH_OFF})
    endif()
    set (${ALL_OPTIONS} ${${ALL_OPTIONS}} PARENT_SCOPE)
endfunction()

# ! cmake_unit_parse_args_key
#
# This is an optimization on cmake_parse_arguments which should
# help to reduce the number of times which it is called. Effectively,
# it hashes its arguments and then checks to see if we've called
# cmake_parse_arguments with this kind of hash. If we have, it uses
# the cached values.
#
# \input  PREFIX: cmake_parse_arguments PREFIX
# \input  OPTION_ARGS_STRING: "Option" like arguments, which are either present or not present.
# \input  SINGLEVAR_ARGS_STRING: "Single variable" like arguments, which only have one value.
# \input  MULTIVAR_ARGS_STRING: "Multiple variable" like arguments, which can have multiple variables.
# \output RETURN_KEY: A variable to store the computed key for later use with cmake_fetch_parsed_arg.
#
function (cmake_parse_args_key PREFIX
                               OPTION_ARGS_STRING
                               SINGLEVAR_ARGS_STRING
                               MULTIVAR_ARGS_STRING
                               RETURN_KEY)

    # First get the key for this variable length arguments set
    string (MD5 CACHE_KEY "${ARGV}")

    # Lookup to see if we've parsed arguments like these before
    get_property (CACHE_KEY_IS_SET GLOBAL PROPERTY _CMAKE_OPT_PARSE_ARGS_CACHED_${CACHE_KEY})
    if (NOT CACHE_KEY_IS_SET)
        # Cache key was not set. Parse arguments and then store the
        # results in global properties.
        cmake_parse_arguments (${PREFIX} "${OPTION_ARGS_STRING}" "${SINGLEVAR_ARGS_STRING}" "${MULTIVAR_ARGS_STRING}" ${ARGN})
        set (VARIABLES ${OPTION_ARGS_STRING} ${SINGLEVAR_ARGS_STRING} ${MULTIVAR_ARGS_STRING})
        foreach (VAR ${VARIABLES})
            set_property (GLOBAL
                          PROPERTY
                          _CMAKE_OPT_PARSE_ARGS_CACHED_${CACHE_KEY}_${VAR}
                          "${${PREFIX}_${VAR}}")
        endforeach()
        set_property (GLOBAL PROPERTY _CMAKE_OPT_PARSE_ARGS_CACHED_${CACHE_KEY} TRUE)
    endif()

    set (${RETURN_KEY} ${CACHE_KEY} PARENT_SCOPE)
endfunction()

# ! cmake_fetch_parsed_arg
#
# Fetch the value of a parsed argument from cmake_parse_args_key.
#
# A value named ${PREFIX}_${ARGUMENT} will be set in the PARENT_SCOPE
# after calling this function, much like cmake_parse_arguments.
#
# \input CACHE_KEY: The key returned by cmake_parse_args_key
# \input PREFIX: The argument prefix as passed to cmake_parse_args_key
# \input ARGUMENT: The name of the argument (not the return value).
function (cmake_fetch_parsed_arg CACHE_KEY PREFIX ARGUMENT)

    get_property (VALUE GLOBAL
                  PROPERTY
                  _CMAKE_OPT_PARSE_ARGS_CACHED_${CACHE_KEY}_${ARGUMENT})
    set (${PREFIX}_${ARGUMENT} "${VALUE}" PARENT_SCOPE)

endfunction()
