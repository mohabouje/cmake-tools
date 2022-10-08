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

include(CMakeDependentOption)

option(CMT_ENABLE_STATIC_ANALYSIS 		"Enable the different static analyzer in all targets" 					OFF)
option(CMT_ENABLE_CLANG_TIDY            "Enable the integration of clang-tidy into the build system"            ON)
option(CMT_ENABLE_CODECHECKER           "Enable the integration of codechecker into the build system"           ON)
option(CMT_ENABLE_CPPCHECK              "Enable the integration of cppcheck into the build system"              ON)
option(CMT_ENABLE_CPPLINT               "Enable the integration of cppcheck into the build system"              ON)
option(CMT_ENABLE_IWYU                  "Enable the integration of include-what-you-use into the build system"  ON)
option(CMT_ENABLE_LIZARD                "Enable the integration of lizard into the build system"                ON)



