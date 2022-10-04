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
# - cmt_append_typed_cache_definition
# - cmt_append_cache_definition_variable
# - cmt_forward_cache_namespaces_to_file

# !cmt_append_typed_cache_definition
# Appends some typed values to a CMakeCache definition (eg, -DVALUE=OPTION)
#
# \input COPT Name of the option
# \input VALUE Value
# \input TYPE (string, bool, path, file path)
# \input CLINES Variable constituting the cache arguments
#
macro (cmt_append_typed_cache_definition COPT VALUE TYPE CLINES)
    string (TOUPPER "${TYPE}" UTYPE)
    set (${CLINES} "${${CLINES}}\nset (${COPT} \"${VALUE}\" CACHE ${UTYPE} \"\" FORCE)")
endmacro()

# !cmt_append_cache_definition
# Appends some values to a CMakeCache definition (eg, -DVALUE=OPTION)
#
# \input CACHE_OPTION Name of the option
# \input VALUE Value
# \input CACHE_LINES Variable constituting the cache arguments
macro (cmt_append_cache_definition CACHE_OPTION VALUE CACHE_LINES)
    cmt_append_typed_cache_definition (${CACHE_OPTION}
                                       ${VALUE}
                                       string
                                       ${CACHE_LINES})
endmacro()

# !cmt_append_cache_definition_variable
# Appends some values to a CMakeCache definition (eg, -DVALUE=OPTION)
#
# \input CACHE_OPTION Name of the option
# \input VALUE Variable containing the value to append
# \input CACHE_LINES Variable constituting the cache arguments
#
macro (cmt_append_cache_definition_variable CACHE_OPTION
                                            VALUE
                                            CACHE_LINES)

    if (DEFINED ${VALUE})
        cmt_append_cache_definition (${CACHE_OPTION}
                                     ${VALUE}
                                     ${CACHE_LINES})
    endif()
endmacro()

# !cmt_forward_cache_namespaces_to_file
#
# Appends all variables in this project's cache matching any of
# of the namespaces provided in NAMESPACES to the file specified
# in CACHE_FILE
# 
# \input CACHE_FILE File to append the cache variables to
# \input NAMESPACES Namespaces to match
#
function (cmt_forward_cache_namespaces_to_file CACHE_FILE)

    cmt_parse_arguments (FORWARD_CACHE "" "" "NAMESPACES" ${ARGN})
    cmt_required_arguments(FORWARD_CACHE "" "" "NAMESPACES")

    get_property (AVAILABLE_CACHE_VARIABLES GLOBAL PROPERTY CACHE_VARIABLES)

    # First pass - getting all the variables in the specified namespaces
    foreach (VAR ${AVAILABLE_CACHE_VARIABLES})
        # Search for the namespace at the beginning of the var name. If the
        # found position is 0, then this is a usable cache entry and we should
        # search for the next ":"
        foreach (NAMESPACE ${FORWARD_CACHE_NAMESPACES})
            string (FIND "${VAR}" "${NAMESPACE}" NS_POS)
            if (NS_POS EQUAL 0)
                list (APPEND NAMESPACED_VARIABLES ${VAR})
            endif()
        endforeach()
    endforeach()

    # Second pass - adding those variables to the CACHE_DEFS
    foreach (VAR ${NAMESPACED_VARIABLES})
        get_property (CACHE_VARIABLE_TYPE CACHE ${VAR} PROPERTY TYPE)

        # Ignore STATIC, INTERNAL or UNINITIALIZED type cache entries
        # as they aren't user-modifiable or set.
        if (NOT CACHE_VARIABLE_TYPE STREQUAL "STATIC" AND
            NOT CACHE_VARIABLE_TYPE STREQUAL "INTERNAL" AND
            NOT CACHE_VARIABLE_TYPE STREQUAL "UNINITIALIZED")
            set (TYPE ${CACHE_VARIABLE_TYPE})
            cmt_append_typed_cache_definition (${VAR}
                                               "${${VAR}}"
                                               ${TYPE}
                                               CACHE_DEFS)
        endif()
    endforeach()
    file (WRITE "${CACHE_FILE}" "${CACHE_DEFS}")
endfunction()