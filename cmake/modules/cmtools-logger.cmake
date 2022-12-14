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

set(CMT_DEFAULT_LOG_LEVEL "STATUS" CACHE STRING "Default log level" FORCE)
set(CMT_DEFAULT_LOG_PREFIX "cmt" CACHE STRING "Set the logger level" FORCE)
set(CMT_SUPPORTED_LOG_LEVELS
        DEPRECATION
        STATUS
        VERBOSE
        NOTICE
        DEBUG
        TRACE
        WARNING
        SEND_ERROR
        FATAL_ERROR
        ERROR
        AUTHOR_WARNING
        CHECK_START
        CHECK_PASS
        CHECK_FAIL
        OFF)
mark_as_advanced(CMT_DEFAULT_LOG_LEVEL CMT_DEFAULT_LOG_PREFIX CMT_SUPPORTED_LOG_LEVELS)
set_property(GLOBAL PROPERTY CMT_LOG_LEVEL_GLOBAL ${CMT_DEFAULT_LOG_LEVEL})
set_property(GLOBAL PROPERTY CMT_LOG_PREFIX_GLOBAL ${CMT_DEFAULT_LOG_PREFIX})
set_property(GLOBAL PROPERTY CMT_LOG_LEVEL_SCOPED ${CMT_DEFAULT_LOG_LEVEL})
set_property(GLOBAL PROPERTY CMT_LOG_PREFIX_SCOPED ${CMT_DEFAULT_LOG_PREFIX})

function (cmt_logger_set_prefix PREFIX)
    cmt_set_global_property(CMT_LOG_PREFIX_GLOBAL ${PREFIX})
    cmt_set_global_property(CMT_LOG_PREFIX_SCOPED ${PREFIX})
endfunction()

function(cmt_logger_set_level LEVEL)
    cmt_ensure_choice(${LEVEL} ${CMT_SUPPORTED_LOG_LEVELS})
    cmt_set_global_property(CMT_LOG_LEVEL_GLOBAL ${LEVEL})
    cmt_set_global_property(CMT_LOG_LEVEL_SCOPED ${LEVEL})
endfunction()

function(cmt_logger_set_context LEVEL PREFIX)
    cmt_ensure_choice(${LEVEL} ${CMT_SUPPORTED_LOG_LEVELS})
    cmt_set_global_property(CMT_LOG_LEVEL_GLOBAL ${LEVEL})
    cmt_set_global_property(CMT_LOG_PREFIX_GLOBAL ${PREFIX})
    cmt_set_global_property(CMT_LOG_LEVEL_SCOPED ${LEVEL})
    cmt_set_global_property(CMT_LOG_PREFIX_SCOPED ${PREFIX})
endfunction()

function(cmt_logger_get_context LEVEL PREFIX)
    cmt_get_global_property(CMT_LOG_LEVEL_GLOBAL LOADED_LEVEL)
    cmt_get_global_property(CMT_LOG_PREFIX_GLOBAL LOADED_PREFIX)
    set(${LEVEL} ${LOADED_LEVEL} PARENT_SCOPE)
    set(${PREFIX} ${LOADED_PREFIX} PARENT_SCOPE)
endfunction()

function(cmt_logger_set_scoped_level LEVEL)
    cmt_ensure_choice(${LEVEL} ${CMT_SUPPORTED_LOG_LEVELS})
    cmt_set_global_property(CMT_LOG_LEVEL_SCOPED ${LEVEL})
endfunction()

function(cmt_logger_set_scoped_context LEVEL PREFIX)
    cmt_ensure_choice(${LEVEL} ${CMT_SUPPORTED_LOG_LEVELS})
    cmt_set_global_property(CMT_LOG_LEVEL_SCOPED ${LEVEL})
    cmt_set_global_property(CMT_LOG_PREFIX_SCOPED ${PREFIX})
endfunction()

function(cmt_logger_get_scoped_context LEVEL PREFIX)
    cmt_get_global_property(CMT_LOG_LEVEL_SCOPED LOADED_LEVEL REQUIRED)
    cmt_get_global_property(CMT_LOG_PREFIX_SCOPED LOADED_PREFIX REQUIRED)
    set(${LEVEL} ${LOADED_LEVEL} PARENT_SCOPE)
    set(${PREFIX} ${LOADED_PREFIX} PARENT_SCOPE)
endfunction()

function(cmt_logger_reset_scoped_context)
    cmt_get_global_property(CMT_LOG_LEVEL_GLOBAL LOADED_LEVEL REQUIRED)
    cmt_get_global_property(CMT_LOG_PREFIX_GLOBAL LOADED_PREFIX REQUIRED)
    cmt_set_global_property(CMT_LOG_LEVEL_SCOPED ${LOADED_LEVEL})
    cmt_set_global_property(CMT_LOG_PREFIX_SCOPED ${LOADED_PREFIX})
endfunction()

macro (cmt_logger_level_penalty LEVEL PENALTY)
    if (${LEVEL} STREQUAL "VERBOSE")
        set(${PENALTY} 0)
    elseif (${LEVEL} STREQUAL "DEBUG")
        set(${PENALTY} 1)
    elseif (${LEVEL} STREQUAL "TRACE")
        set(${PENALTY} 2)
    elseif (${LEVEL} STREQUAL "NOTICE")
        set(${PENALTY} 3)
    elseif (${LEVEL} STREQUAL "STATUS")
        set(${PENALTY} 4)
    elseif (${LEVEL} STREQUAL "CHECK_START" OR ${LEVEL} STREQUAL "CHECK_PASS" OR ${LEVEL} STREQUAL "CHECK_FAIL")
        set(${PENALTY} 5)
    elseif (${LEVEL} STREQUAL "WARNING" OR ${LEVEL} STREQUAL "AUTHOR_WARNING")
        set(${PENALTY} 6)
    elseif (${LEVEL} STREQUAL "DEPRECATION")
        set(${PENALTY} 7)
    elseif (${LEVEL} STREQUAL "FATAL_ERROR")
        set(${PENALTY} 8)
    elseif (${LEVEL} STREQUAL "SEND_ERROR")
        set(${PENALTY} 9)
    elseif (${LEVEL} STREQUAL "OFF")
        set(${PENALTY} 10)
    else ()
        _message(FATAL_ERROR "Invalid log level: ${${LEVEL}}")
    endif ()
endmacro()

function(message)
    cmake_parse_arguments(ARGS "" "PREFIX" "" ${ARGN})
    list(FIND CMT_SUPPORTED_LOG_LEVELS ${ARGV0} LEVEL_INDEX)
    if (LEVEL_INDEX EQUAL -1)
        _message(WARNING "Invalid log level: ${ARGN}")
        return()
    endif()

    cmt_logger_get_scoped_context(SCOPED_LEVEL SCOPED_PREFIX)
    cmt_logger_level_penalty(${ARGV0} ARGUMENT_LEVEL_PENALTY)
    cmt_logger_level_penalty(${SCOPED_LEVEL} SCOPED_LEVEL_PENALTY)
    if (SCOPED_LEVEL_PENALTY GREATER ARGUMENT_LEVEL_PENALTY)
        return()
    endif ()

    string(TIMESTAMP NOW "%H:%M:%S")
    if (ARGS_PREFIX)
        set(PREFIX "${NOW} ${ARGS_PREFIX}")
    else ()
        set(PREFIX "${NOW} ${SCOPED_PREFIX}")
    endif ()

    _message(${ARGV0} "${PREFIX} ${ARGV1}")
endfunction()

macro(cmt_log)
    message(STATUS "${ARGN}")
endmacro()

macro(cmt_warning)
    message(WARNING "${ARGN}")
endmacro()

macro(cmt_error)
    message(SEND_ERROR "${ARGN}")
endmacro()

macro(cmt_fatal)
    message(FATAL_ERROR "${ARGN}")
endmacro()

macro(cmt_deprecated)
    message(DEPRECATION "${ARGN}")
endmacro()

macro(cmt_debug)
    message(DEBUG "${ARGN}")
endmacro()

macro(cmt_trace)
    message(TRACE "${ARGN}")
endmacro()

macro(cmt_notice)
    message(NOTICE "${ARGN}")
endmacro()

macro(cmt_success)
    message(SUCCESS "${ARGN}")
endmacro()
