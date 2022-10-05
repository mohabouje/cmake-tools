set(TARGET_NAME example-test)
cmt_cxx_declare_headers(TARGET_HEADERS
    PUBLIC
        ${CMAKE_CURRENT_SOURCE_DIR}/example.hpp
)

cmt_cxx_declare_sources(TARGET_SOURCES
    PUBLIC
        ${CMAKE_CURRENT_SOURCE_DIR}/example.cpp
        ${CMAKE_CURRENT_SOURCE_DIR}/main.cpp
)

cmt_cxx_executable(${TARGET_NAME}
    SOURCES ${TARGET_SOURCES}
    HEADERS ${TARGET_HEADERS}
)

gtest_discover_tests(${TARGET_NAME})
add_test(NAME ${TARGET_NAME} COMMAND ${TARGET_NAME})

# # Compiler flags
cmt_target_enable_all_warnings(${TARGET_NAME})
cmt_target_enable_effective_cxx_warnings(${TARGET_NAME})
cmt_target_enable_generation_header_dependencies(${TARGET_NAME})
cmt_target_enable_warnings_as_errors(${TARGET_NAME})
cmt_target_configure_compiler_optimization_options(${TARGET_NAME})


# Print information about target
# cmt_target_print_compiler_options(${TARGET_NAME} CONFIG Debug Release)
# cmt_target_print_linker_options(${TARGET_NAME} CONFIG Debug Release)

# Hardcore integration of all tools
cmt_target_enable_all_tool(${TARGET_NAME})
cmt_target_generate_all_tool(${TARGET_NAME} ALL DEFAULT)

cmt_pkg_link_package(${TARGET_NAME} spdlog cli11)