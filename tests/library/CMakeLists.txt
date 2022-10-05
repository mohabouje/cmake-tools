cmt_cxx_declare_headers(TARGET_HEADERS
    PUBLIC
        ${CMAKE_CURRENT_SOURCE_DIR}/example.hpp
)

cmt_cxx_declare_sources(TARGET_SOURCES
    PUBLIC
        ${CMAKE_CURRENT_SOURCE_DIR}/example.cpp
)

cmt_cxx_static_library(example_lib
    SOURCES ${TARGET_SOURCES}
    HEADERS ${TARGET_HEADERS}
)

# Compiler flags
cmt_target_enable_all_warnings(example_lib)
cmt_target_enable_effective_cxx_warnings(example_lib)
cmt_target_enable_generation_header_dependencies(example_lib)
cmt_target_enable_warnings_as_errors(example_lib)
cmt_target_configure_compiler_optimization_options(example_lib)