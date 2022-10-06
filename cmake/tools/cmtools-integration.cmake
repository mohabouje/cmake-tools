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

set(CMT_STATIC_ANALYSIS_TOOLS 
        "cppcheck" 
        "clang-tidy"
        "iwyu"
        "cpplint"
        "lizard"
        "codechecker"
        "clang-build-analyzer"
        "clang-format"
        "coverage"
        "cotire")

function (cmt_target_enable_tool TARGET TOOL)
    cmt_parse_arguments(ARGS "REQUIRED" "" "" ${ARGN})
    cmt_ensure_target(${TARGET})

    macro(report_warning)
        if (${ARGS_REQUIRED})
            cmt_warning(${ARGN})
        endif()
    endmacro()

    string(TOUPPER ${TOOL} TOOL_TAG)
    string(REGEX REPLACE "-" "_" TOOL_TAG ${TOOL_TAG})
    if (TOOL_TAG STREQUAL "CPPCHECK")
        cmt_target_enable_cppcheck(${TARGET})
    elseif (TOOL_TAG STREQUAL "CPPLINT")
        cmt_target_enable_cpplint(${TARGET})
    elseif (TOOL_TAG STREQUAL "CLANG_TIDY")
        cmt_target_enable_clang_tidy(${TARGET})
    elseif (TOOL_TAG STREQUAL "IWYU")
        cmt_target_enable_iwyu(${TARGET})
    elseif (TOOL_TAG STREQUAL "CCACHE")
        cmt_target_enable_ccache(${TARGET})
    elseif (TOOL_TAG STREQUAL "COTIRE")
        report_warning("Built-In analysis of ${TOOL} is not supported")
    elseif (TOOL_TAG STREQUAL "CODECHECKER")
        report_warning("Built-In analysis of ${TOOL} is not supported")
    elseif (TOOL_TAG STREQUAL "LIZARD")
        cmt_target_enable_lizard(${TARGET})
    elseif (TOOL_TAG STREQUAL "CLANG_BUILD_ANALYZER")
        report_warning("Built-In analysis of ${TOOL} is not supported")
    elseif (TOOL_TAG STREQUAL "CLANG_FORMAT")
        cmt_target_enable_clang_format(${TARGET})
    elseif (TOOL_TAG STREQUAL "COVERAGE")
        report_warning("Built-In analysis of ${TOOL} is not supported")
    else()
        cmt_fatal("Unknown tool ${TOOL}. Available ${CMT_STATIC_ANALYSIS_TOOLS}")
    endif()
endfunction ()

function (cmt_target_enable_all_tools TARGET)
    cmt_parse_arguments(ARGS "REQUIRED" "" "" ${ARGN})
    cmt_forward_arguments(ARGS "REQUIRED" "" "" FORWARD_ARGS)
    foreach(TOOL ${CMT_STATIC_ANALYSIS_TOOLS})
        cmt_target_enable_tool(${TARGET} ${TOOL} ${FORWARD_ARGS})
    endforeach()
endfunction()

function (cmt_target_generate_tool TARGET TOOL)
    cmt_parse_arguments(ARGS "" "ALL;DEFAULT" "" ${ARGN})
    cmt_ensure_target(${TARGET})

    string(TOLOWER ${TOOL} TOOL_SUFFIX)
    string(REGEX REPLACE "_" "-" TOOL_SUFFIX ${TOOL_SUFFIX})

    string(TOUPPER ${TOOL} TOOL_TAG)
    string(REGEX REPLACE "-" "_" TOOL_TAG ${TOOL_TAG})

    cmt_forward_arguments(ARGS "ALL;DEFAULT" "" "" FORWARD_ARGS)
    if (TOOL_TAG STREQUAL "CPPCHECK")
        cmt_target_generate_cppcheck(${TARGET} SUFFIX ${TOOL_SUFFIX} ${FORWARD_ARGS})
    elseif (TOOL_TAG STREQUAL "CPPLINT")
        cmt_target_generate_cpplint(${TARGET} SUFFIX ${TOOL_SUFFIX} ${FORWARD_ARGS})
    elseif (TOOL_TAG STREQUAL "CLANG_TIDY")
        cmt_target_generate_clang_tidy(${TARGET} SUFFIX ${TOOL_SUFFIX} ${FORWARD_ARGS})
    elseif (TOOL_TAG STREQUAL "IWYU")
        cmt_target_generate_iwyu(${TARGET} SUFFIX ${TOOL_SUFFIX} ${FORWARD_ARGS})
    elseif (TOOL_TAG STREQUAL "CCACHE")
        cmt_target_generate_ccache(${TARGET} SUFFIX ${TOOL_SUFFIX} ${FORWARD_ARGS})
    elseif (TOOL_TAG STREQUAL "COTIRE")
        cmt_target_generate_cotire(${TARGET} SUFFIX ${TOOL_SUFFIX} ${FORWARD_ARGS})
    elseif (TOOL_TAG STREQUAL "CODECHECKER")
        cmt_target_generate_codechecker(${TARGET} SUFFIX ${TOOL_SUFFIX} ${FORWARD_ARGS})
    elseif (TOOL_TAG STREQUAL "LIZARD")
        cmt_target_generate_lizard(${TARGET} SUFFIX ${TOOL_SUFFIX} ${FORWARD_ARGS})
    elseif (TOOL_TAG STREQUAL "CLANG_BUILD_ANALYZER")
        cmt_target_generate_clang_build_analyzer(${TARGET}  SUFFIX ${TOOL_SUFFIX} ${FORWARD_ARGS})
    elseif (TOOL_TAG STREQUAL "CLANG_FORMAT")
        cmt_target_generate_clang_format(${TARGET} SUFFIX ${TOOL_SUFFIX} ${FORWARD_ARGS})
    elseif (TOOL_TAG STREQUAL "COVERAGE")
        cmt_target_generate_coverage(${TARGET} SUFFIX ${TOOL_SUFFIX} ${FORWARD_ARGS})
    else()
        cmt_fatal("Unknown tool ${TOOL}. Available ${CMT_STATIC_ANALYSIS_TOOLS}")
    endif()
endfunction ()

function (cmt_target_generate_all_tools TARGET)
    cmt_parse_arguments(ARGS "" "ALL;DEFAULT" "" ${ARGN})
    cmt_ensure_target(${TARGET})
    cmt_forward_arguments(ARGS "ALL;DEFAULT" "" "" FORWARD_ARGS)
    foreach(TOOL ${CMT_STATIC_ANALYSIS_TOOLS})
        cmt_target_generate_tool(${TARGET} ${TOOL} ${FORWARD_ARGS})
    endforeach()
endfunction()
