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
# - cmt_filter_list
# - cmt_filter_out
# - cmt_filter_in
# - cmt_join_list


# ! cmt_filter_list 
# Filters a list based on a regex pattern.
# It will include or exclude the elements that match the pattern.
#
# cmt_filter_list(
#   <INCLUDE>
#   <EXCLUDE>
#   REGEX
#   LIST
# )
#
# \input  REGEX Regular expression to filter the list
# \output LIST List to filter
# \option INCLUDE If set, the elements that match the regex will be included in the list
# \option EXCLUDE If set, the elements that match the regex will be excluded from the list
#
function(cmt_filter_list REGEX LIST)
    cmt_parse_arguments(ARGS "INCLUDE;EXCLUDE" "" "" ${ARGN})
    cmt_ensure_on_of_argument(ARGS INCLUDE EXCLUDE)

	set(TEMPORAL_LIST)
	foreach(ITERATOR ${LIST})
		set(TOUCH)
        if(${ITERATOR} MATCHES ${REGEX})
            set(TOUCH true)
            break()
        endif()
		if ((DEFINED ARGS_INCLUDE AND DEFINED TOUCH) OR (DEFINED ARGS_EXCLUDE AND NOT DEFINED TOUCH))
			list(APPEND TEMPORAL_LIST ${ITERATOR})
		endif()
	endforeach()
	set(${LIST} ${TEMPORAL_LIST} PARENT_SCOPE)
endfunction()

# ! cmt_filter_out
# Filters out a list based on a regex pattern.
#
# cmt_filter_out(
#   REGEX
#   LIST
# )
#
# \input  REGEX Regular expression to filter the list
# \output LIST List to filter
#
macro(cmt_filter_out REGEX LIST)
	cmt_filter_list(REGEX LIST EXCLUDE ${ARGN})
endmacro()

# ! cmt_filter_in
# Filters in a list based on a regex pattern.
#
# cmt_filter_in(
#   REGEX
#   LIST
# )
#
# \input  REGEX Regular expression to filter the list
# \output LIST List to filter
#
macro(cmt_filter_in REGEX LIST)
	cmt_filter_list(REGEX LIST INCLUDE ${ARGN})
endmacro()

# ! cmt_join_list
# Join items with a separator into a variable.
#
# cmt_join_list(
#   LIST
#   SEPARATOR
#   OUTPUT
# )
#
# \input  LIST List to join
# \input  SEPARATOR Separator to use
# \output OUTPUT Resulting string
#
function(cmt_join_list LIST SEPARATOR OUTPUT)
	set(TEMPORAL_OUTPUT)
	set(FIRST)
	foreach(ITERATOR ${LIST})
		if(NOT DEFINED FIRST)
			set(TEMPORAL_OUTPUT ${ITERATOR})
			set(FIRST true)
		else()
			set(TEMPORAL_OUTPUT "${TEMPORAL_OUTPUT}${SEPARATOR}${ITERATOR}")
		endif()
	endforeach()
	set(${OUTPUT} ${TEMPORAL_OUTPUT} PARENT_SCOPE)
endfunction()