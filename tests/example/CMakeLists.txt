set(TARGET_NAME example-test)
set(TARGET_HEADERS ${CMAKE_CURRENT_SOURCE_DIR}/example.hpp)
set(TARGET_SOURCES ${CMAKE_CURRENT_SOURCE_DIR}/example.cpp
                   ${CMAKE_CURRENT_SOURCE_DIR}/main.cpp)

add_executable(${TARGET_NAME} ${TARGET_HEADERS} ${TARGET_SOURCES})
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
cmt_target_enable_all_tool(${TARGET_NAME} REQUIRED)
cmt_target_generate_all_tool(${TARGET_NAME})
