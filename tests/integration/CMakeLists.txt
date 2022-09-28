add_executable(integration ${CMAKE_CURRENT_SOURCE_DIR}/clang_format_integration.cpp)
gtest_discover_tests(integration)
add_test(NAME integration COMMAND integration)


# Integration test for ccache
cmtools_target_enable_ccache(TARGET integration)

# Integration test for clang-format
cmtools_target_generate_clang_format(TARGET integration)

# Integration test for clang-tidy
cmtools_target_enable_clang_tidy(TARGET integration)
cmtools_target_generate_clang_tidy(TARGET integration)

# Integration test for clang-build-analyzer
cmtools_target_enable_clang_build_analyzer(TARGET integration)

# Integration with include-what-you-use
cmtools_target_enable_iwyu(TARGET integration)
cmtools_target_generate_iwyu(TARGET integration)

# Integration with lizard
cmtools_target_generate_lizard(TARGET integration)

# Integration with cppcheck
cmtools_target_enable_cppcheck(TARGET integration)
cmtools_target_generate_cppcheck(TARGET integration)

# Integration with cpplint
cmtools_target_enable_cpplint(TARGET integration)

# Integration with codechecker
cmtools_target_generate_codechecker(TARGET integration)

# Integration with code coverage tools
cmtools_project_coverage()
cmtools_target_generate_coverage(TARGET integration DEPENDENCIES integration)

# Integration with sanitizers
cmtools_target_enable_sanitizer(TARGET integration SANITIZER TSAN)

# Integration with cotire
cmtools_target_enable_cotire(TARGET integration)

# Integration with dependency graph
cmtools_project_dependency_graph()