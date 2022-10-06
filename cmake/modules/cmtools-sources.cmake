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

# ! cmt_source_get_group:
#
# Returns the initial type of a source file from its extension. It doesn't
# properly analyze headers and source inclusions to determine the language
# of any headers.
#
# The type of the source will be set in the variable specified in
# RETURN_TYPE. Valid values are C, CXX, HEADER and UNKNOWN
#
# cmt_source_get_group(
#   SOURCE_FILE
#   SOURCE_TYPE
#   SOURCE_LANGUAGE
#   [PREFERRED_LANGUAGE]
#   [C_SOURCE_FILE_EXTENSIONS] (Default is ${CMAKE_C_SOURCE_FILE_EXTENSIONS})
#   [CXX_SOURCE_FILE_EXTENSIONS] (Default is ${CMAKE_CXX_SOURCE_FILE_EXTENSIONS})
#   [HEADER_FILE_EXTENSIONS] (Default is h;hh;hpp;hxx;H;HPP;h++)
# )
#
# Note:
# CMake doesn't provide a list of header file extensions. Here are some common ones.
#
# Notably absent are files without an extension. It appears that these are not used
# outside the standard library and Qt. There's very little chance that we will be scanning them.
#
# If they do need to be scanned, consider having the extensionless header include a header with
# an extension and scanning that instead.
#
# \input    SOURCE_FILE Source file to scan
# \output   SOURCE_TYPE Type of the source file. Valid values are HEADER, SOURCE and UNKNOWN
# \output   SOURCE_LANGUAGE Language of the source file. Valid values are C, CXX and UNKNOWN
# \group    HEADER_FILE_EXTENSIONS List of header file extensions
# \group    C_SOURCE_FILE_EXTENSIONS List of extensions for C source files
# \group    CXX_SOURCE_FILE_EXTENSIONS List of extensions for CXX source files
# \param    PREFERRED_LANGUAGE Preferred language for the source file. Valid values are C, CXX and UNKNOWN
#
function (cmt_source_get_group SOURCE_FILE SOURCE_TYPE SOURCE_LANGUAGE)
    cmt_parse_arguments(ARGS "" "PREFERRED_LANGUAGE" "HEADER_FILE_EXTENSIONS;C_SOURCE_FILE_EXTENSIONS;CXX_SOURCE_FILE_EXTENSIONS;" ${ARGN})
    cmt_default_argument(ARGS C_SOURCE_FILE_EXTENSIONS "${CMAKE_C_SOURCE_FILE_EXTENSIONS}")
    cmt_default_argument(ARGS CXX_SOURCE_FILE_EXTENSIONS "${CMAKE_CXX_SOURCE_FILE_EXTENSIONS}")
    cmt_default_argument(ARGS HEADER_FILE_EXTENSIONS "h;hh;hpp;hxx;H;HPP;h++")
    cmt_default_argument(ARGS PREFERRED_LANGUAGE "CXX")
    cmt_ensure_lang(${ARGS_PREFERRED_LANGUAGE})

    cmt_source_get_property(${SOURCE_FILE} CMT_SOURCE_TYPE STORED_SOURCE_TYPE)
    cmt_source_get_property(${SOURCE_FILE} CMT_SOURCE_LANGUAGE STORED_SOURCE_LANGUAGE)
    if (STORED_SOURCE_TYPE AND STORED_SOURCE_LANGUAGE)
        set (${SOURCE_TYPE} ${STORED_SOURCE_TYPE} PARENT_SCOPE)
        set (${SOURCE_LANGUAGE} ${STORED_SOURCE_LANGUAGE} PARENT_SCOPE)
        return()
    endif()

    macro(report_and_store TYPE LANGUAGE)
        if (LANGUAGE STREQUAL "UNKNOWN")
            set (LANGUAGE ${ARGS_PREFERRED_LANGUAGE})
        endif()

        cmt_source_set_property(${SOURCE_FILE} CMT_SOURCE_TYPE ${TYPE})
        cmt_source_set_property(${SOURCE_FILE} CMT_SOURCE_LANGUAGE ${LANGUAGE})
        set (${SOURCE_TYPE} ${TYPE} PARENT_SCOPE)
        set (${SOURCE_LANGUAGE} ${LANGUAGE} PARENT_SCOPE)
    endmacro()

    get_filename_component (EXTENSION "${SOURCE_FILE}" EXT)
    if (NOT EXTENSION)
        report_and_store(UNKNOWN UNKNOWN)
        return()
    endif()

    string (SUBSTRING ${EXTENSION} 1 -1 EXTENSION)
    list (FIND ARGS_C_SOURCE_FILE_EXTENSIONS ${EXTENSION} C_INDEX)
    if (NOT C_INDEX EQUAL -1)
        report_and_store(SOURCE C)
        return()
    endif()

    list (FIND ARGS_CXX_SOURCE_FILE_EXTENSIONS ${EXTENSION} CXX_INDEX)
    if (NOT CXX_INDEX EQUAL -1)
        report_and_store(SOURCE CXX)
        return()
    endif()


    set (HEADER_EXTENSIONS )
    list (FIND ARGS_HEADER_FILE_EXTENSIONS ${EXTENSION} HEADER_INDEX)
    if (NOT HEADER_INDEX EQUAL -1)
        report_and_store(HEADER UNKNOWN)
        return()
    endif()

    report_and_store(UNKNOWN UNKNOWN)
endfunction()

# cmt_source_sort_group:
#
# Sort provided sources into their various languages and separate
# header files from non-headers.
#
# cmt_source_sort_group(
#  C_SOURCES
#  CXX_SOURCES
#  HEADERS
#  SKIPPED
#   [PREFERRED_LANGUAGE]
#  [SOURCES source ...]
#  [INCLUDES include ...]
#  [CPP_IDENTIFIERS cpp_identifiers ...]
# )
#
# \output   C_SOURCES Variable to store list of C sources in.
# \output   CXX_SOURCES Variable to store list of C++ sources in.
# \output   HEADERS HEADERS Variable to store list of headers in.
# \output   SKIPPED Variable to store list of skipped sources in.
# \group    HEADER_FILE_EXTENSIONS List of header file extensions
# \group    C_SOURCE_FILE_EXTENSIONS List of extensions for C source files
# \group    CXX_SOURCE_FILE_EXTENSIONS List of extensions for CXX source files
# \param    PREFERRED_LANGUAGE Preferred language for the source file. Valid values are C, CXX and UNKNOWN
# \group    SOURCES SOURCES List of source files to separate out.
#
function (cmt_source_sort_group C_SOURCES CXX_SOURCES HEADERS SKIPPED)
    cmt_parse_arguments(ARGS "" "PREFERRED_LANGUAGE" "SOURCES;HEADER_FILE_EXTENSIONS;C_SOURCE_FILE_EXTENSIONS;CXX_SOURCE_FILE_EXTENSIONS;" ${ARGN})
    cmt_required_arguments(ARGS "" "" "SOURCES")

    set (_C_SOURCES)
    set (_CXX_SOURCES)
    set (_HEADERS)
    set (_SKIPPED)
    cmt_forward_arguments (ARGS "" "PREFERRED_LANGUAGE" "HEADER_FILE_EXTENSIONS;C_SOURCE_FILE_EXTENSIONS;CXX_SOURCE_FILE_EXTENSIONS;" DETERMINE_LANG_OPTIONS)
    foreach (SOURCE ${ARGS_SOURCES})
        cmt_source_get_group(${SOURCE} SOURCE_TYPE SOURCE_LANGUAGE ${DETERMINE_LANG_OPTIONS})
        if (SOURCE_TYPE STREQUAL "SOURCE")
            if (SOURCE_LANGUAGE STREQUAL "C")
                list (APPEND ${_C_SOURCES} ${SOURCE})
            elseif (SOURCE_LANGUAGE STREQUAL "CXX")
                list (APPEND ${_CXX_SOURCES} ${SOURCE})
            else()
                cmt_fatal("Unknown source language ${SOURCE_LANGUAGE} for source ${SOURCE}")
            endif()
        elseif (SOURCE_TYPE STREQUAL "HEADER")
            list (APPEND ${_HEADERS} ${SOURCE})
        else()
            list (APPEND ${_SKIPPED} ${SOURCE})
        endif()
    endforeach()
    set(${C_SOURCES} ${_C_SOURCES} PARENT_SCOPE)
    set(${CXX_SOURCES} ${_CXX_SOURCES} PARENT_SCOPE)
    set(${HEADERS} ${_HEADERS} PARENT_SCOPE)
    set(${SKIPPED} ${_SKIPPED} PARENT_SCOPE)
endfunction()

# ! cmt_source_count_group
# Counts the number of source files
#
# cmt_source_count_group(
#   C_SOURCES_COUNT
#   CXX_SOURCES_COUNT
#   HEADERS_COUNT
#   SKIPPED_COUNT
#   [SOURCES source ...]
#   [PREFERRED_LANGUAGE]
#   [C_SOURCE_FILE_EXTENSIONS] (Default is ${CMAKE_C_SOURCE_FILE_EXTENSIONS})
#   [CXX_SOURCE_FILE_EXTENSIONS] (Default is ${CMAKE_CXX_SOURCE_FILE_EXTENSIONS})
#   [HEADER_FILE_EXTENSIONS] (Default is h;hh;hpp;hxx;H;HPP;h++)
# )
#
# \output   C_SOURCES_COUNT Variable to store number of C sources in.
# \output   CXX_SOURCES_COUNT Variable to store number of C++ sources in.
# \output   HEADERS_COUNT HEADERS Variable to store number of headers in.
# \option   SKIPPED_COUNT Variable to store number of skipped sources in.
# \group    HEADER_FILE_EXTENSIONS List of header file extensions
# \group    C_SOURCE_FILE_EXTENSIONS List of extensions for C source files
# \group    CXX_SOURCE_FILE_EXTENSIONS List of extensions for CXX source files
# \param    PREFERRED_LANGUAGE Preferred language for the source file. Valid values are C, CXX and UNKNOWN
# \group    SOURCES SOURCES List of source files to separate out.
#

function(cmt_source_count_group C_SOURCES_COUNT CXX_SOURCES_COUNT HEADERS_COUNT SKIPPED_COUNT)
    cmt_source_sort_group(C_SOURCES CXX_SOURCES HEADERS SKIPPED ${ARGN})

    list(LENGTH C_SOURCES C_SOURCES_COUNT_COMPUTED)
    list(LENGTH CXX_SOURCES CXX_SOURCES_COUNT_COMPUTED)
    list(LENGTH HEADERS HEADERS_COUNT_COMPUTED)
    list(LENGTH SKIPPED SKIPPED_COUNT_COMPUTED)
    set(${C_SOURCES_COUNT} ${C_SOURCES_COUNT_COMPUTED} PARENT_SCOPE)
    set(${CXX_SOURCES_COUNT} ${CXX_SOURCES_COUNT_COMPUTED} PARENT_SCOPE)
    set(${HEADERS_COUNT} ${HEADERS_COUNT_COMPUTED} PARENT_SCOPE)
    set(${SKIPPED_COUNT} ${SKIPPED_COUNT_COMPUTED} PARENT_SCOPE)
endfunction()

# !cmt_source_filter_extraneous
# Filters out the files that are not grouped in the source tree.
#
# cmt_source_filter_extraneous(
#   TARGET
#   RETURN_SOURCES
#   <SKIP_GENERATED>
#   <SKIP_HEADERS>
#   [PREFERRED_LANGUAGE]
#   [C_SOURCE_FILE_EXTENSIONS] (Default is ${CMAKE_C_SOURCE_FILE_EXTENSIONS})
#   [CXX_SOURCE_FILE_EXTENSIONS] (Default is ${CMAKE_CXX_SOURCE_FILE_EXTENSIONS})
#   [HEADER_FILE_EXTENSIONS] (Default is h;hh;hpp;hxx;H;HPP;h++)
# )
#
# \input    TARGET Target to fetch sources from
# \option   SKIP_GENERATED Skip generated files
# \option   SKIP_HEADERS Skip header files
# \output   RETURN_SOURCE Variable to store returned sources in
# \group    HEADER_FILE_EXTENSIONS List of header file extensions
# \group    C_SOURCE_FILE_EXTENSIONS List of extensions for C source files
# \group    CXX_SOURCE_FILE_EXTENSIONS List of extensions for CXX source files
# \param    PREFERRED_LANGUAGE Preferred language for the source file. Valid values are C, CXX and UNKNOWN
#
function (cmt_source_filter RETURN_SOURCES)
    cmt_parse_arguments(ARGS "SKIP_GENERATED;SKIP_HEADERS" "PREFERRED_LANGUAGE" "SOURCES;HEADER_FILE_EXTENSIONS;C_SOURCE_FILE_EXTENSIONS;CXX_SOURCE_FILE_EXTENSIONS;" ${ARGN})

    cmt_source_sort_group(C_SOURCES CXX_SOURCES HEADERS SKIPPED ${ARGN})

    set(_FILTERED_SOURCES)
    macro(__cmt_append_sources _sources)
        foreach(_source ${${_sources}})
            if (${ARGS_SKIP_GENERATED})
                cmt_source_get_property(${_source} CMT_SOURCE_GENERATED STORED_SOURCE_GENERATED)
                if (NOT STORED_SOURCE_GENERATED)
                    list(APPEND _FILTERED_SOURCES ${_source})
                endif()
            else()
                list(APPEND _FILTERED_SOURCES ${_source})
            endif()
        endforeach()
    endmacro()

    __cmt_append_sources(C_SOURCES)
    __cmt_append_sources(CXX_SOURCES)

    if (NOT ${ARGS_SKIP_HEADERS})
        __cmt_append_sources(HEADERS)
    endif()

    set(${RETURN_SOURCES} ${_FILTERED_SOURCES} PARENT_SCOPE)
endfunction()
