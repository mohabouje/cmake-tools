add_executable(integration ${CMAKE_CURRENT_SOURCE_DIR}/clang_format_integration.cpp)
gtest_discover_tests(integration)
add_test(NAME integration COMMAND integration)


cmtools_target_use_ccache(TARGET integration)
cmtools_generate_clang_format(NAME clang-format RECURSIVE DIRECTORIES ${CMAKE_CURRENT_SOURCE_DIR})
cmtools_target_generate_clang_format(TARGET integration)