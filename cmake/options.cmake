option(CMT_ENABLE_CCACHE                "Enable the integration of ccache into the build system"                ON)
option(CMT_ENABLE_CLANG_BUILD_ANALYZER  "Enable the integration of clang-tidy into the build system"            OFF)
option(CMT_ENABLE_CLANG_FORMAT          "Enable the integration of clang-format into the build system"          ON)
option(CMT_ENABLE_CLANG_TIDY            "Enable the integration of clang-tidy into the build system"            ON)
option(CMT_ENABLE_CODECHECKER           "Enable the integration of codechecker into the build system"           ON)
option(CMT_ENABLE_CPPCHECK              "Enable the integration of cppcheck into the build system"              ON)
option(CMT_ENABLE_CPPLINT               "Enable the integration of cppcheck into the build system"              ON)
option(CMT_ENABLE_DEPENDENCY_GRAPH      "Enable the integration of dependency-graphs into the build system"     ON)
option(CMT_ENABLE_IWYU                  "Enable the integration of include-what-you-use into the build system"  ON)
option(CMT_ENABLE_LIZARD                "Enable the integration of lizard into the build system"                ON)
option(CMT_ENABLE_LTO                   "Enable the integration of lto into the build system"                   ON)
option(CMT_ENABLE_SANITIZERS            "Enable the integration of sanitizers into the build system"            ON)

# Options to control the integration with lcov
option(CMT_ENABLE_COVERAGE      "Enable the code coverage data generation"  ON)
option(CMT_ENABLE_PROFILING     "Enable the code profiling data generation" ON)

# Options to control the integration with cotire
option(CMT_ENABLE_COTIRE                "Enable the integration of cotire into the build system"    ON)
option(CMT_ENABLE_PRECOMPILED_HEADERS   "Enable the usage of pre-compiled headers"                  ON)
option(CMT_ENABLE_UNITY_BUILDS          "Enable unity builds optimization"                          ON)

# Global options to control the build system
option(CMT_ENABLE_COMPILER_OPTION_CHECKS    "Enable checks in compiler options"         ON)
option(CMT_ENABLE_LINKER_OPTION_CHECKS      "Enable checks in linker options"           ON)

# Options to control the integration with doxygen
option(CMT_ENABLE_DOXYGEN           "Enable the integration of doxygen"  ON)
option(CMT_ENABLE_DOXYGEN_GRAPHVIZ  "Enable graphs support in the doxygen documentation"  ON)
option(CMT_ENABLE_DOXYGEN_LATEX     "Enable latex support in the ddoxygen documentation"  OFF)

# Options to control the integration with graphviz
option(CMT_ENABLE_GRAPHVIZ  "Enable the integration of graphviz"  ON)