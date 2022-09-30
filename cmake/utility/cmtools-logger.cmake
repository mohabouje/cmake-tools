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

if(CMT_LOGGER_INCLUDED)
	return()
endif()
set(CMT_LOGGER_INCLUDED ON)

macro(cmt_disable_logger)
    set(CMT_DISABLE_LOGGING ON)
endmacro()

macro(cmt_enable_logger)
    set(CMT_DISABLE_LOGGING OFF)
endmacro()

function(message)
    if (NOT CMT_DISABLE_LOGGING)
        _message(${ARGN})
    endif()
endfunction()

function(cmt_log)
    if (NOT CMT_DISABLE_LOGGING)
        _message(STATUS "[cmt] ${ARGN}")
    endif()
endfunction()

function(cmt_warning)
    if (NOT CMT_DISABLE_LOGGING)
        _message(WARNING "[cmt] ${ARGN}")
    endif()
endfunction()

function(cmt_error)
    if (NOT CMT_DISABLE_LOGGING)
        _message(FATAL_ERROR "[cmt] ${ARGN}")
    endif()
endfunction()

function(cmt_debug)
    if (NOT CMT_DISABLE_LOGGING)
        _message(DEBUG "[cmt] ${ARGN}")
    endif()
endfunction()

function(cmt_trace)
    if (NOT CMT_DISABLE_LOGGING)
        _message(TRACE "[cmt] ${ARGN}")
    endif()
endfunction()

function(cmt_info)
    if (NOT CMT_DISABLE_LOGGING)
        _message(INFO "[cmt] ${ARGN}")
    endif()
endfunction()

function(cmt_success)
    if (NOT CMT_DISABLE_LOGGING)
        _message(SUCCESS "[cmt] ${ARGN}")
    endif()
endfunction()

function(cmt_status)
    if (NOT CMT_DISABLE_LOGGING)
        _message(STATUS "[cmt] ${ARGN}")
    endif()
endfunction()

function(cmt_fatal)
    if (NOT CMT_DISABLE_LOGGING)
        _message(FATAL_ERROR "[cmt] ${ARGN}")
    endif()
endfunction()


