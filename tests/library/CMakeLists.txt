cmt_cxx_declare_headers(TARGET_HEADERS
    PUBLIC
        ${CMAKE_CURRENT_SOURCE_DIR}/example.hpp
)

cmt_cxx_declare_sources(TARGET_SOURCES
    PUBLIC
        ${CMAKE_CURRENT_SOURCE_DIR}/example.cpp
)

cmt_cxx_library(example_interface
    DISABLE_STATIC_ANALYSIS
    HEADERS ${CMAKE_CURRENT_SOURCE_DIR}/header_only.hpp
    INCLUDE_DIRECTORIES ${CMAKE_CURRENT_LIST_DIR}
)

cmt_cxx_library(example_static
    DISABLE_STATIC_ANALYSIS
    SOURCES ${CMAKE_CURRENT_SOURCE_DIR}/example.cpp
    HEADERS ${CMAKE_CURRENT_SOURCE_DIR}/example.hpp
    INCLUDE_DIRECTORIES ${CMAKE_CURRENT_LIST_DIR}
)
cmt_target_enable_lizard(example_static)
cmt_target_enable_clang_format(example_static)

cmt_target_generate_lizard(example_static)
cmt_target_generate_clang_format(example_static)

cmt_cxx_bridge_library(example_alias
    DISABLE_STATIC_ANALYSIS
    DEPENDENCIES example_static example_interface
)