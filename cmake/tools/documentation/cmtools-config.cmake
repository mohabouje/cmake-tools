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

# Options to enable the generation of the documentation
option(CMT_ENABLE_DEPENDENCY_GRAPH  "Enable dependency graph generation"    ON)
option(CMT_ENABLE_DOCUMENTATION     "Enable documentation generation"       ON)

# Options to control the integration of the project with other tools
option(CMT_ENABLE_DOXYGEN           "Enable the integration of doxygen"     ON)
option(CMT_ENABLE_GRAPHVIZ          "Enable the integration of graphviz"    ON)
option(CMT_ENABLE_LATEX             "Enable the integration of latex"       ON)

# Options to control the integration with doxygen
cmake_dependent_option(CMT_ENABLE_DOXYGEN_GRAPHVIZ "Graphviz support for doxygen" ON "CMT_ENABLE_GRAPHVIZ" OFF)
cmake_dependent_option(CMT_ENABLE_DOXYGEN_LATEX "Latex support for doxygen" ON "CMT_ENABLE_LATEX" OFF)


# Code coverage report generation
option(CMT_ENABLE_COVERAGE      "Enable the code coverage data generation"  ON)
option(CMT_ENABLE_PROFILING     "Enable the code profiling data generation" ON)

