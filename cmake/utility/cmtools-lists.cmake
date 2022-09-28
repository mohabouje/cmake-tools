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

if(CMTOOLS_LISTS_INCLUDED)
	return()
endif()
set(CMTOOLS_LISTS_INCLUDED ON)

include(${CMAKE_CURRENT_LIST_DIR}/cmtools-args.cmake)


# Functions summary:
# - cmtools_filter_list
# - cmtools_filter_out
# - cmtools_filter_in
# - cmtools_join_list


# ! cmtools_filter_list Filters a list based on a regex pattern.
# It will include or exclude the elements that match the pattern.
#
# cmtools_append_to_target_property(
#   [INCLUDE OR EXCLUDE]
#   [REFEX <regex>]
#   [LIST <list> ]
# )
#
# \param:INCLUDE/EXCLUDE INCLUDE/EXCLUDE Include or exclude the list
# \param:REFEX REGEX Regular expression to filter the list
# \param:LIST LIST List to filter
#
function(cmtools_filter_list)
    cmake_parse_arguments(ARGS "INCLUDE;EXCLUDE" "REGEX;LIST" "" ${ARGN})
    cmtools_required_arguments(FUNCTION cmtools_filter_list PREFIX ARGS FIELDS REGEX LIST)
    cmtools_one_of_arguments(FUNCTION cmtools_filter_list PREFIX ARGS FIELDS INCLUDE EXCLUDE)


	set(TEMPORAL_LIST)
	foreach(ITERATOR ${${ARGS_LIST}})
		set(TOUCH)
        if(${ITERATOR} MATCHES ${ARGS_REGEX})
            set(TOUCH true)
            break()
        endif()
		if ((DEFINED ARGS_INCLUDE AND DEFINED TOUCH) OR (DEFINED ARGS_EXCLUDE AND NOT DEFINED TOUCH))
			list(APPEND TEMPORAL_LIST ${ITERATOR})
		endif()
	endforeach()
	set(${ARGS_LIST} ${TEMPORAL_LIST} PARENT_SCOPE)
endfunction()

# ! cmtools_filter_out Filters out a list based on a regex pattern.
#
# cmtools_filter_out(
#   [REFEX <regex>]
#   [LIST <list> ]
# )
#
# \param:REFEX REGEX Regular expression to filter the list
# \param:LIST LIST List to filter
#
macro(cmtools_filter_out)
	cmtools_filter_list(EXCLUDE ${ARGN})
endmacro()

# ! cmtools_filter_in Filters in a list based on a regex pattern.
#
# cmtools_filter_in(
#   [REFEX <regex>]
#   [LIST <list> ]
# )
#
# \param:REFEX REGEX Regular expression to filter the list
# \param:LIST LIST List to filter
#
macro(cmtools_filter_in)
	cmtools_filter_list(INCLUDE ${ARGN})
endmacro()

# ! cmtools_join_list Join items with a separator into a variable.
#
# cmtools_join_list(
#   [NAME <name>]
#   [SEPARATOR <separator>]
#   [LIST <list> ]
# )
#
# \param:REFEX REGEX Regular expression to filter the list
# \param:LIST LIST List to filter
#
function(cmtools_join_list)
    cmake_parse_arguments(ARGS "" "NAME;SEPARATOR" "LIST" ${ARGN})
    cmtools_required_arguments(FUNCTION cmtools_filter_list PREFIX ARGS FIELDS NAME SEPARATOR LIST)


	set(TEMPORAL_OUTPUT)
	set(FIRST)
	foreach(ITERATOR ${ARGS_LIST})
		if(NOT DEFINED FIRST)
			set(TEMPORAL_OUTPUT ${ITERATOR})
			set(FIRST true)
		else()
			set(TEMPORAL_OUTPUT "${TEMPORAL_OUTPUT}${ARGS_SEPARATOR}${ITERATOR}")
		endif()
	endforeach()
	set(${ARGS_NAME} ${TEMPORAL_OUTPUT} PARENT_SCOPE)
endfunction()