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

if(CMTOOLS_ARGUMENTS_INCLUDED)
	return()
endif()
set(CMTOOLS_ARGUMENTS_INCLUDED ON)

# Functions summary:
# - cmtools_required_arguments
# - cmtools_one_of_arguments
# - cmtools_choice_arguments
# - cmtools_default_argument
# - cmtools_ensure_target

# ! cmtools_required_arguments : this function check if the parsed arguments contain the required arguments
#
# cmtools_required_arguments(
#   [FUNCTION <file>]
#   [PREFIX <prefix>]
#   [FIELDS <field1> <field2> ...]
# )
#
# \param:FUNCTION FUNCTION specify the name of the function that is being checked
# \param:PREFIX PREFIX specifies the prefix used to parse the arguments
# \group:FIELDS FIELDS contains the list of required arguments
function(cmtools_required_arguments)
    cmake_parse_arguments(CHECK "" "FUNCTION;PREFIX" "FIELDS" ${ARGN})

    if(NOT DEFINED CHECK_FUNCTION)
        message(FATAL_ERROR "cmtools_required_arguments: 'FUNCTION' argument required.")
    endif()

    if(NOT DEFINED CHECK_PREFIX)
        message(FATAL_ERROR "cmtools_required_arguments: 'PREFIX' argument required.")
    endif()

    if(NOT DEFINED CHECK_FIELDS)
        message(FATAL_ERROR "cmtools_required_arguments: 'FIELDS' argument required.")
    endif()

    foreach(arg ${CHECK_FIELDS})
        if(NOT DEFINED ${CHECK_PREFIX}_${arg})
            message(FATAL_ERROR "${CHECK_FUNCTION}: ${CHECK_PREFIX}_${arg} argument required.")
        endif()
    endforeach()
endfunction()

# ! cmtools_one_of_arguments : this function check if the parsed arguments contain at least one of the optional fields
#
# cmtools_one_of_arguments(
#   [FUNCTION <file>]
#   [PREFIX <prefix>]
#   [FIELDS <field1> <field2> ...]
# )
#
# \param:FUNCTION FUNCTION specify the name of the function that is being checked
# \param:PREFIX PREFIX specifies the prefix used to parse the arguments
# \group:FIELDS FIELDS contains the list of optional arguments
function(cmtools_one_of_arguments)
    cmake_parse_arguments(CHECK "" "FUNCTION;PREFIX" "FIELDS" ${ARGN})

    if(NOT CHECK_FUNCTION)
        message(FATAL_ERROR "cmtools_required_arguments: 'FUNCTION' argument required.")
    endif()

    if(NOT CHECK_PREFIX)
        message(FATAL_ERROR "cmtools_required_arguments: 'PREFIX' argument required.")
    endif()

    if(NOT CHECK_FIELDS)
        message(FATAL_ERROR "cmtools_required_arguments: 'FIELDS' argument required.")
    endif()

    set(OPTIONAL_FIELD_FOUND OFF)

    foreach(arg ${CHECK_FIELDS})
        if(${CHECK_PREFIX}_${arg})
            set(OPTIONAL_FIELD_FOUND ON)
        endif()
    endforeach()

    if(NOT OPTIONAL_FIELD_FOUND)
        message(FATAL_ERROR "${CHECK_FUNCTION}: At least one of the following arguments is required: ${CHECK_FIELDS}.")
    endif()
endfunction()

# ! cmtools_choice_arguments : this function check if the parsed argument contain one of the choices
#
# cmtools_choice_arguments(
#   [FUNCTION <file>]
#   [PREFIX <prefix>]
#   [CHOICE <prefix>]
#   [OPTIONS  <option1> <option2> ...]
# )
#
# \param:FUNCTION FUNCTION specify the name of the function that is being checked
# \param:PREFIX PREFIX specifies the prefix used to parse the arguments
# \param:CHOICE CHOICE specifies the choice to check
# \group:OPTIONS OPTIONS contains the list of optional arguments
function(cmtools_choice_arguments)
    cmake_parse_arguments(CHECK "" "FUNCTION;PREFIX;CHOICE" "OPTIONS" ${ARGN})

    if(NOT CHECK_FUNCTION)
        message(FATAL_ERROR "cmtools_required_arguments: 'FUNCTION' argument required.")
    endif()

    if(NOT CHECK_PREFIX)
        message(FATAL_ERROR "cmtools_required_arguments: 'PREFIX' argument required.")
    endif()

    if(NOT CHECK_CHOICE)
        message(FATAL_ERROR "cmtools_required_arguments: 'CHOICE' argument required.")
    endif()

    if(NOT CHECK_OPTIONS)
        message(FATAL_ERROR "cmtools_required_arguments: 'OPTIONS' argument required.")
    endif()

    set(CHOICE_FOUND OFF)

    foreach(arg ${CHECK_OPTIONS})
        if(${${CHECK_PREFIX}_${CHECK_CHOICE}} STREQUAL ${arg})
            set(CHOICE_FOUND ON)
        endif()
    endforeach()

    if(NOT CHOICE_FOUND)
        message(FATAL_ERROR "${CHECK_FUNCTION}: '${${CHECK_CHOICE}}' is not a valid choice. Valid choices are: ${CHECK_OPTIONS}.")
    endif()
endfunction()

# ! cmake_default_argument : This functions checks if an argument was set, if not, it sets it to the default value
#
# cmake_default_argument(
#   [PREFIX <prefix>]
#   [FIELD <field>]
#   [DEFAULT <default>]
# )
#
# \param:PREFIX PREFIX specifies the prefix used to parse the arguments
# \param:FIELD FIELD Contain the name of the field to check
# \param:DEFAULT DEFAULT Contain the default value to set
function(cmtools_default_argument)
    cmake_parse_arguments(ARG_CHECK "" "PREFIX;FIELD;DEFAULT" "" ${ARGN})
    # cmtools_required_arguments(FUNCTION cmake_default_argument PREFIX ARG_CHECK FIELDS PREFIX FIELD DEFAULT)

    if(NOT ${ARG_CHECK_PREFIX}_${ARG_CHECK_FIELD})
        set(${ARG_CHECK_PREFIX}_${ARG_CHECK_FIELD} ${ARG_CHECK_DEFAULT} PARENT_SCOPE)
    endif()
endfunction()


# ! cmtools_ensure_target : Checks if the list of targets exist and are valid
#
# cmtools_ensure_targets(
#   [FUNCTION <file>]
#   [TARGETS <target1> <target2> ...]
# )
#
# \param:FUNCTION FUNCTION specify the name of the function that is being checked
# \group:TARGETS TARGETS contains the list of optional arguments
function(cmtools_ensure_targets)
    cmake_parse_arguments(CHECK "" "FUNCTION" "TARGETS" ${ARGN})
    cmtools_required_arguments(FUNCTION cmtools_ensure_targets PREFIX CHECK FIELDS TARGETS)

    foreach(arg ${CHECK_TARGETS})
        if(NOT TARGET ${arg})
            message(FATAL_ERROR "${CHECK_FUNCTION}: ${arg} is not a valid target.")
        endif()
    endforeach()
endfunction()