cmt_cxx_executable(example_application
    SOURCES ${CMAKE_CURRENT_LIST_DIR}/main.cpp
    PACKAGES ${TARGET_PACKAGES}
    DEPENDENCIES example_lib
)

# Hardcore integration of all tools
cmt_target_enable_all_tools(example_application)
cmt_target_generate_all_tools(example_application ALL DEFAULT)