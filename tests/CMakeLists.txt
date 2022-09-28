

if(CMAKE_BUILD_TYPE MATCHES "Release")
    add_definitions(-DNDEBUG)
endif()

if (CMAKE_CXX_COMPILER_ID MATCHES "Clang")
    cmt_add_compile_options(CXX 
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
else()
    cmt_add_compile_options(CXX
        -Wno-unused-parameter
        -Wno-unused-function
        -Wno-sign-compare
        -Wno-attributes
        -Wno-missing-field-initializers
        -Wno-unknown-pragmas
        -Wno-unused-but-set-variable
        -Wno-unused-but-set-parameter
        -Wno-deprecated
        -Wno-deprecated-copy
        -Wno-uninitialized
        -Wno-nonnull
        -Wno-deprecated-declarations
        -Wno-stringop-overflow
        -Wno-array-bounds
        -Wno-format-security
        -Wno-macro-redefined
    )
endif()

# OpenSSL deprecated API
cmt_add_compile_options(CXX
    -Wno-deprecated-declarations
    -Wno-missing-field-initializers
)

cmt_add_compile_options(-Wall -Wextra -Werror)
cmt_add_compile_options(-fno-strict-aliasing -pthread)
cmt_add_compile_options(C -std=gnu11)
cmt_add_compile_options(CXX -std=c++2a -ftemplate-backtrace-limit=0)

# Debug 
cmt_add_compile_options(-O0 -ggdb CONFIG Debug)
cmt_add_compile_options(-fPIC CONFIG Debug)

# Release
cmt_add_compile_options(-O3 -ggdb CONFIG Release)
cmt_add_compile_options(-march=native -funroll-loops -Ofast -ffast-math CONFIG Release)
cmt_add_compile_options(-mpopcnt CONFIG Release)

cmt_print_flags()


add_subdirectory(integration)