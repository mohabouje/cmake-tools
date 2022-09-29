add_executable(integration ${CMAKE_CURRENT_SOURCE_DIR}/clang_format_integration.cpp)
gtest_discover_tests(integration)
add_test(NAME integration COMMAND integration)

# Compiler flags 
cmt_target_enable_all_warnings(TARGET integration)
cmt_target_enable_effective_cxx_warnings(TARGET integration)
cmt_target_enable_generation_header_dependencies(TARGET integration)
cmt_target_enable_warnings_as_errors(TARGET integration)
cmt_target_configure_compiler_options(TARGET integration)

# Integration test for ccache
cmt_target_enable_ccache(TARGET integration)

# Integration test for clang-format
cmt_target_generate_clang_format(TARGET integration)

# Integration test for clang-tidy
cmt_target_enable_clang_tidy(TARGET integration)
cmt_target_generate_clang_tidy(TARGET integration)

# Integration test for clang-build-analyzer
cmt_target_enable_clang_build_analyzer(TARGET integration)

# Integration with include-what-you-use
cmt_target_enable_iwyu(TARGET integration)
cmt_target_generate_iwyu(TARGET integration)

# Integration with lizard
cmt_target_generate_lizard(TARGET integration)

# Integration with cppcheck
cmt_target_enable_cppcheck(TARGET integration)
cmt_target_generate_cppcheck(TARGET integration)

# Integration with cpplint
cmt_target_enable_cpplint(TARGET integration)

# Integration with codechecker
cmt_target_generate_codechecker(TARGET integration)

# Integration with code coverage tools
cmt_project_coverage()
cmt_target_generate_coverage(TARGET integration DEPENDENCIES integration)

# Integration with sanitizers
cmt_target_enable_sanitizer(TARGET integration SANITIZER TSAN)
cmt_target_enable_sanitizers(TARGET integration SANITIZERS ASAN UBSAN)

# Integration with cotire
# cmt_target_enable_cotire(TARGET integration)

# Integration with dependency graph
cmt_project_dependency_graph()

# Integration with lto
cmt_target_enable_lto(TARGET integration)