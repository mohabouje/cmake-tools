set(TEST_TARGET cmtools-test)
cmt_add_target(
    NAME ${TEST_TARGET}
    TYPE EXECUTABLE
    HEADERS
        ${CMAKE_CURRENT_SOURCE_DIR}/example.hpp
    SOURCES 
        ${CMAKE_CURRENT_SOURCE_DIR}/example.cpp
        ${CMAKE_CURRENT_SOURCE_DIR}/main.cpp
    UNITY
)
gtest_discover_tests(${TEST_TARGET})
add_test(NAME ${TEST_TARGET} COMMAND ${TEST_TARGET})

# # Compiler flags 
cmt_target_enable_all_warnings(${TEST_TARGET})
cmt_target_enable_effective_cxx_warnings(${TEST_TARGET})
cmt_target_enable_generation_header_dependencies(${TEST_TARGET})
cmt_target_enable_warnings_as_errors(${TEST_TARGET})
cmt_target_configure_compiler_optimization_options(${TEST_TARGET})

# Integration test for ccache
cmt_target_enable_ccache(${TEST_TARGET})

# Integration test for clang-tidy
cmt_target_enable_clang_tidy(${TEST_TARGET})

# Integration with include-what-you-use
cmt_target_enable_iwyu(${TEST_TARGET})

# Integration with cppcheck
cmt_target_enable_cppcheck(${TEST_TARGET})

# Integration with cpplint
cmt_target_enable_cpplint(${TEST_TARGET})

# Integration test for clang-build-analyzer
cmt_target_enable_clang_build_analyzer(${TEST_TARGET})

# Integration with lto
# cmt_target_enable_lto(${TEST_TARGET})

# Integration with sanitizers
cmt_target_enable_sanitizer(${TEST_TARGET} UBSAN)

# Integration with lizard
cmt_target_generate_lizard(${TEST_TARGET})

# Integration with codechecker
cmt_target_generate_codechecker(${TEST_TARGET})

# Integration with codechecker
cmt_target_generate_coverage(${TEST_TARGET})

# Integration test for clang-format
cmt_target_generate_clang_format(${TEST_TARGET})

# Print information about target
cmt_target_print_compiler_options(${TEST_TARGET} CONFIG Debug Release)
cmt_target_print_linker_options(${TEST_TARGET} CONFIG Debug Release)


cmt_generate_coverage()
