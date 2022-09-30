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

cmt_disable_logger()
include(${CMAKE_CURRENT_LIST_DIR}/./../third_party/header-language.cmake)
cmt_enable_logger()

# ! cmt_source_type_from_source_file_extension:
#
# Returns the initial type of a source file from its extension. It doesn't
# properly analyze headers and source inclusions to determine the language
# of any headers.
#
# The type of the source will be set in the variable specified in
# RETURN_TYPE. Valid values are C, CXX, HEADER and UNKNOWN
#
# cmt_source_type_from_source_file_extension(
#  SOURCE
#  RETURN_TYPE
# )
#
# \input    SOURCE Source file to scan
# \output   RETURN_TYPE Variable to set the source type in
function (cmt_source_type_from_source_file_extension SOURCE RETURN_TYPE)
    psq_source_type_from_source_file_extension(${SOURCE} ${RETURN_TYPE})
    set(${RETURN_TYPE} ${RETURN_TYPE} PARENT_SCOPE)
endfunction()

# ! cmt_scan_source_for_headers
#
# Opens the source file SOURCE at its absolute path and scans it for
# #include statements if we have not done so already. The content of the
# include statement is pasted together with each provided INCLUDE
# and checked to see if it forms the path to an existing or generated
# source. If it does, then the following rules apply to determine
# the language of the header file:
#
# - If the source including the header is a CXX source (including a CXX
#   header, and no other language has been set for this header, then
#   the language of the header is set to CXX
# - If any source including the header is a C source (including a C header)
#   then the language of the header is forced to "C", with one caveat:
#   - The header file will be opened and scanned for any tokens which match
#     any provided tokens in CPP_IDENTIFIERS or __cplusplus. If it does, then
#     the header language will be set to C;CXX
#
# cmt_scan_source_for_headers(
#  [SOURCE source ]
#  [INCLUDES include ...]
#  [CPP_IDENTIFIERS cpp_identifiers ...]
# )
#
# \param    SOURCE The source file to be scanned
# \group    INCLUDES Any include directories to search for header files
# \group    CPP_IDENTIFIERS CPP_IDENTIFIERS Any identifiers which might indicate that this source can be compiled with both C and CXX.
#
function(cmt_scan_source_for_headers)
    cmake_parse_arguments(ARGS "" "SOURCE" "INCLUDES;CPP_IDENTIFIERS" ${ARGN})
	cmt_required_arguments(FUNCTION cmt_scan_source_for_headers PREFIX ARGS FIELDS SOURCE)
    psq_scan_source_for_headers(${ARGN})
endfunction()

# cmt_determine_language_for_source
#
# Takes any source, including a header file and writes the determined
# language into LANGUAGE_RETURN. If the source is a header file
# SOURCE_WAS_HEADER_RETURN will be set to true as well.
#
# This function only works for header files if those header files
# were included by sources previously scanned by
# psq_scan_source_for_headers. They must be scanned before
# this function is called, otherwise this function will be unable
# to determine the language of the source file and report an error.
#
# cmt_determine_language_for_source(
#  SOURCES
#  LANGUAGE_RETURN
#  SOURCE_WAS_HEADER_RETURN
# )
#
# \input    SOURCE The source whose language is to be determined
# \output   LANGUAGE_RETURN A variable where the language can be written into
# \output   SOURCE_WAS_HEADER_RETURN Indicates whether this was a header or a source that was checked.
# \option   FORCE_LANGUAGE: Performs scanning, but forces language to be one of C or CXX.
function (cmt_determine_language_for_source SOURCE
                                            LANGUAGE_RETURN
                                            SOURCE_WAS_HEADER_RETURN)
    psq_determine_language_for_source(${SOURCE} ${LANGUAGE_RETURN} ${SOURCE_WAS_HEADER_RETURN})
    set(${RETURN_TYPE} ${RETURN_TYPE} PARENT_SCOPE)
    set(${SOURCE_WAS_HEADER_RETURN} ${SOURCE_WAS_HEADER_RETURN} PARENT_SCOPE)
endfunction()

# cmt_sort_sources_to_languages:
#
# Sort provided sources into their various languages and separate
# header files from non-headers.
#
# cmt_sort_sources_to_languages(
#  C_SOURCES
#  CXX_SOURCES
#  HEADER_SOURCES
#  <FORCE_LANGUAGE>
#  [SOURCES source ...]
#  [INCLUDES include ...]
#  [CPP_IDENTIFIERS cpp_identifiers ...]
# )
#
# \arg      C_SOURCES Variable to store list of C sources in.
# \arg      CXX_SOURCES Variable to store list of C++ sources in.
# \arg      HEADERS HEADERS Variable to store list of headers in.
# \option   FORCE_LANGUAGE Force language of all sources to be either C or CXX.
# \group    SOURCES SOURCES List of source files to separate out.
# \group    CPP_IDENTIFIERS List of identifiers that indicate that a source file is actually a C++ source file.
# \group    INCLUDES Include directories to search.
#
function (cmt_sort_sources_to_languages C_SOURCES CXX_SOURCES HEADERS)


    cmake_parse_arguments(SORT_SOURCES "" "FORCE_LANGUAGE" "SOURCES;CPP_IDENTIFIERS;INCLUDES" ${ARGN})
	cmt_required_arguments(FUNCTION cmt_sort_sources_to_languages PREFIX SORT_SOURCES FIELDS SOURCES)
    cmt_forward_options (DETERMINE_LANG_OPTIONS
                         PREFFIX SORT_SOURCES
                         SINGLEVAR_ARGS FORCE_LANGUAGE
                         MULTIVAR_ARGS CPP_IDENTIFIERS INCLUDES)

    foreach (SOURCE ${SORT_SOURCES_SOURCES})
        set(INCLUDES ${SORT_SOURCES_INCLUDES})
        set(CPP_IDENTIFIERS ${SORT_SOURCES_CPP_IDENTIFIERS})
        cmt_determine_language_for_source ("${SOURCE}"
                                           LANGUAGE
                                           SOURCE_WAS_HEADER
                                           ${DETERMINE_LANG_OPTIONS})

        # Scan this source for headers, we'll need them later
        if (NOT SOURCE_WAS_HEADER)
            cmt_scan_source_for_headers (SOURCE "${SOURCE}"
                                                ${DETERMINE_LANG_OPTIONS})
        endif()

        list (FIND LANGUAGE "C" C_INDEX)
        list (FIND LANGUAGE "CXX" CXX_INDEX)
        if (NOT C_INDEX EQUAL -1)
            list (APPEND _C_SOURCES "${SOURCE}")
        endif ()
        if (NOT CXX_INDEX EQUAL -1)
            list (APPEND _CXX_SOURCES "${SOURCE}")
        endif ()
        if (SOURCE_WAS_HEADER)
            list (APPEND _HEADERS "${SOURCE}")
        endif ()
    endforeach ()
    set(${C_SOURCES} ${_C_SOURCES} PARENT_SCOPE)
    set(${CXX_SOURCES} ${_CXX_SOURCES} PARENT_SCOPE)
    set(${HEADERS} ${_HEADERS} PARENT_SCOPE)
endfunction ()


# !cmt_strip_extraneous_sources
# Fetches the target's SOURCES property, but removes any non-linkable
# and non-header sources from it, storing the result in RETURN_SOURCES.
#
# Most tools choke on being passed these sources, so its better to strip
# them out as early as possible
#
# cmt_strip_extraneous_sources(
#   TARGET
#   RETURN_SOURCES  
# )
#
# \input    TARGET Target to fetch sources from
# \output   RETURN_SOURCE Variable to store returned sources in
#
function (cmt_strip_extraneous_sources TARGET RETURN_SOURCES)
    cmt_ensure_target(${TARGET})
    get_target_property (TARGET_SOURCES ${TARGET} SOURCES)
    foreach (SOURCE ${TARGET_SOURCES})
        cmt_source_type_from_source_file_extension ("${SOURCE}"
                                                    SOURCE_TYPE)
        if (NOT SOURCE_TYPE STREQUAL "UNKNOWN")
            list (APPEND STRIPPED_SOURCES "${SOURCE}")
        endif()
    endforeach()
    set(${RETURN_SOURCES} ${STRIPPED_SOURCES} PARENT_SCOPE)
endfunction ()

# cmt_filter_out_generated_sources
#
# Filter out generated sources from SOURCES and store the resulting
# list of sources in `RESULT_VARIABLE`.
#
# cmt_filter_out_generated_sources
#  RESULT_VARIABLE
#  [SOURCES source1 source2 ...]
# )
#
# \output RESULT_VARIABLE RESULT_VARIABLE: Resultant list of sources, without generated sources.
# \group SOURCES SOURCES: List of source files, including generated sources.
#
function (cmt_filter_out_generated_sources RESULT_VARIABLE)
    cmake_parse_arguments (FILTER_OUT "" "" "SOURCES" ${ARGN})
    set (${RESULT_VARIABLE} PARENT_SCOPE)
    set (FILTERED_SOURCES)
    foreach (SOURCE ${FILTER_OUT_SOURCES})
        get_property (SOURCE_IS_GENERATED SOURCE "${SOURCE}" PROPERTY GENERATED)
        if (NOT SOURCE_IS_GENERATED)
            list (APPEND FILTERED_SOURCES "${SOURCE}")
        endif ()
    endforeach ()
    set (${RESULT_VARIABLE} ${FILTERED_SOURCES} PARENT_SCOPE)
endfunction ()


# ! cmt_count_sources
# Counts the number of source files
# 
# cmt_count_sources(
#   [RESULT <result variable>]
#   source1, source2 ...
# )
#
# \output RESULT The variable to store the result in
function(cmt_count_sources RESULT)
    cmake_parse_arguments(ARGS "" "" "" ${ARGN})
    set(result 0)
    foreach(SOURCE_FILE ${ARGS_UNPARSED_ARGUMENTS})
        if("${SOURCE_FILE}" MATCHES \\.\(c|C|cc|cp|cpp|CPP|c\\+\\+|cxx|i|ii\)$)
            math(EXPR result "${result} + 1")
        endif()
    endforeach()
    set(${RESULT} ${result} PARENT_SCOPE)
endfunction()