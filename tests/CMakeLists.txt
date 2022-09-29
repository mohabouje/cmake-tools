

if(CMAKE_BUILD_TYPE MATCHES "Release")
    add_definitions(-DNDEBUG)
endif()

cmt_add_compiler_options(
    COMPILER CLANG
    LANG CXX
    OPTIONS 
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
)

cmt_add_compiler_options(
    COMPILER GCC
    LANG CXX
    OPTIONS 
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
)



# OpenSSL deprecated API
cmt_add_compiler_options(
    OPTIONS
        -Wno-deprecated-declarations
        -Wno-missing-field-initializers
)

cmt_add_compiler_options(OPTIONS -fno-strict-aliasing -pthread)
cmt_add_compiler_options(LANG C OPTIONS -std=gnu11)
cmt_add_compiler_options(LANG CXX OPTIONS -std=c++2a -ftemplate-backtrace-limit=0)

# Debug 
cmt_add_debug_compiler_options(OPTIONS -O0 -ggdb)
cmt_add_debug_compiler_options(OPTIONS -fPIC)

# Release
cmt_add_release_compiler_options(OPTIONS -O3 -ggdb)
cmt_add_release_compiler_options(OPTIONS -funroll-loops -Ofast -ffast-math)
cmt_add_release_compiler_options(OPTIONS -mpopcnt)

cmt_print_flags()


# Functionalities that affect all targets moving forward
cmt_configure_compiler_options()
cmt_enable_warnings_as_errors()
cmt_enable_all_warnings()
cmt_enable_effective_cxx_warnings()

add_subdirectory(integration)