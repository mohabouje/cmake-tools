
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

if(CMTOOLS_DEVELOPER_INCLUDED)
	return()
endif()
set(CMTOOLS_DEVELOPER_INCLUDED ON)

include(${CMAKE_CURRENT_LIST_DIR}/cmtools-args.cmake)

# Functions summary:
# - cmtools_append_to_target_property



# cmtools_choice_arguments(
#   [TARGET <target>]
#   [PROPERTY <property>]
#   [PROPERTIES <appen1> <append2> ...]
# )
#
# \param:TARGET TARGET Specifies the target to which the property will be appended.
# \param:PROPERTY PROPERTY Specifies the property to be appended.
# \param:PROPERTIES PROPERTIES Specifies the values to be appended to the property.
#
function(cmtools_append_to_target_property)
    cmake_parse_arguments(ARGS "" "TARGET;PROPERTY" "PROPERTIES" ${ARGN})
    cmake_required_arguments(FUNCTION cxx_import_libraries PREFIX ARGS FIELDS TARGET PROPERTY PROPERTIES)

	get_target_property(EXISTING_PROPERTIES ${ARGS_TARGET} ${ARGS_PROPERTY})
	if (EXISTING_PROPERTIES)
		set(EXISTING_PROPERTIES "${EXISTING_PROPERTIES} ${ARGS_PROPERTIES}")
	endif()
	set_target_properties(${ARGS_TARGET} PROPERTIES ${ARGS_PROPERTY} ${EXISTING_PROPERTIES})
endfunction()





