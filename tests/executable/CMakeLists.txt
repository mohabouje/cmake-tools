cmt_cxx_executable(example_application
    DISABLE_STATIC_ANALYSIS
    SOURCES ${CMAKE_CURRENT_LIST_DIR}/main.cpp
    PACKAGES ${TARGET_PACKAGES}
    DEPENDENCIES example_alias
)