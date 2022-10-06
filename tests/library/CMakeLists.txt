cmt_cxx_declare_headers(TARGET_HEADERS
    PUBLIC
        ${CMAKE_CURRENT_SOURCE_DIR}/example.hpp
)

cmt_cxx_declare_sources(TARGET_SOURCES
    PUBLIC
        ${CMAKE_CURRENT_SOURCE_DIR}/example.cpp
)

cmt_cxx_static_library(example_lib
    DISABLE_STATIC_ANALYSIS
    SOURCES ${TARGET_SOURCES}
    HEADERS ${TARGET_HEADERS}
    INCLUDE_DIRECTORIES ${CMAKE_CURRENT_LIST_DIR}
)