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

set(CMT_COMPILER_CACHE_ALTERNATIVES ccache sccache CACHE STRING "List of compiler cache alternatives" FORCE)
set(CMT_DEFAULT_COMPILER_CACHE_BACKEND sccache CACHE STRING "Default compiler cache backend" FORCE)
mark_as_advanced(CMT_COMPILER_CACHE_BACKEND CMT_COMPILER_CACHE_ALTERNATIVES)
set_property(GLOBAL PROPERTY CMT_COMPILER_CACHE_BACKEND ${CMT_DEFAULT_COMPILER_CACHE_BACKEND})

# ! cmt_compiler_cache_set_backend
# Changes the default compiler cache to use.
#
# \input cache The compiler cache to use.
function(cmt_compiler_cache_set_backend CACHE)
    cmt_ensure_choice(${CACHE} ${CMT_COMPILER_CACHE_ALTERNATIVES})
    cmt_set_global_property(CMT_COMPILER_CACHE_BACKEND ${CACHE})
endfunction()

# ! cmt_compiler_cache_get_backend
# Returns the compiler cache to use.
#
# \output cache The compiler cache to use.
function(cmt_compiler_cache_get_backend CACHE)
    cmt_get_global_property(CMT_COMPILER_CACHE_BACKEND CACHE_LOADED REQUIRED)
    set(${CACHE} ${CACHE_LOADED} PARENT_SCOPE)
endfunction()

# ! cmt_target_generate_sccache\
# Enable include-what-you-use in all targets.
#
# cmt_enable_compiler_cache()
#
macro(cmt_enable_compiler_cache)
    cmt_compiler_cache_get_backend(CACHE)
    string(TOLOWER ${CACHE} CACHE)
    cmake_language(EVAL CODE "cmt_enable_${CACHE}()")
endmacro()

# ! cmt_target_use_sccache
# Enable the configured or default compiler cache use on the given target
#
# cmt_target_enable_compiler_cache(
#   TARGET
# )
#
# \input TARGET The target to configure
#
function(cmt_target_enable_compiler_cache TARGET)
    cmt_compiler_cache_get_backend(CACHE)
    string(TOLOWER ${CACHE} CACHE)
    cmake_language(EVAL CODE "cmt_enable_${CACHE}()")
endfunction()


# ! cmt_target_generate_compiler_cache
# Generates a new target that compiles with the configured compiler cache.
#
# cmt_target_generate_compiler_cache(
#   TARGET
# )
#
# \input TARGET The target to configure
#
function(cmt_target_generate_compiler_cache TARGET)
    cmt_compiler_cache_get_backend(CACHE)
    string(TOLOWER ${CACHE} CACHE)
    cmake_language(EVAL CODE "cmt_generate_${CACHE}(${TARGET} ${ARGN})")
endfunction()