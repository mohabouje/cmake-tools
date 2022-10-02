# Functionalities that affect all targets moving forward
cmt_configure_compiler_optimization_options()
cmt_enable_warnings_as_errors()
cmt_enable_all_warnings()
cmt_enable_effective_cxx_warnings()
cmt_enable_lto()

cmt_add_compiler_options(
    -Wno-unused-parameter
    -Wno-unused-function
    -Wno-sign-compare
    -Wno-invalid-constexpr
    -Wno-unknown-pragmas
    -Wno-gnu-string-literal-operator-template
    -Wno-ambiguous-reversed-operator
    -Wno-deprecated-copy
    -Wno-deprecated-declarations
    -Wno-format
    -Wno-macro-redefined
    -Wno-mismatched-tags
    -Wno-format-security
    -Wno-c++98-compat-pedantic
    -Wno-newline-eof
    COMPILER CLANG
    LANG CXX
)

cmt_add_compiler_options( 
    -Wno-unused-parameter
    -Wno-unused-function
    -Wno-sign-compare
    -Wno-invalid-constexpr
    -Wno-unknown-pragmas
    -Wno-gnu-string-literal-operator-template
    -Wno-ambiguous-reversed-operator
    -Wno-deprecated-copy
    -Wno-deprecated-declarations
    -Wno-format
    -Wno-macro-redefined
    -Wno-mismatched-tags
    -Wno-format-security
    COMPILER GCC
    LANG CXX
)

cmt_add_compiler_options(-fno-strict-aliasing -pthread)
cmt_add_compiler_options(-std=gnu11 LANG C )
cmt_add_compiler_options(-std=c++2a -ftemplate-backtrace-limit=0 LANG CXX)

# Debug 
cmt_add_debug_compiler_options(-O0 -ggdb)
cmt_add_debug_compiler_option(-fPIC)

# Release
cmt_add_release_compiler_options(-O3 -ggdb)
cmt_add_release_compiler_options(-funroll-loops -Ofast -ffast-math)
cmt_add_release_compiler_option(-mpopcnt)

# Print flags and configuration
# cmt_print_compiler_options(LANG CXX CONFIG Debug Release)
# cmt_print_linker_options(CONFIG Debug Release)

# Integration with doxygen + graphviz
cmt_generate_doxygen_documentation(doxygen)
cmt_generate_dependency_graph(dependency-graph)

add_subdirectory(example)