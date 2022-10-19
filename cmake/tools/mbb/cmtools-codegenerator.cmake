function(cmt_codegenerator_library TARGET)
    cmt_parse_arguments(ARGS "" "INSTALL_DIR;ROOT_DIR" "SOURCES" ${ARGN})
    cmt_required_arguments(ARGS "" "" "SOURCES")
    cmt_default_argument(ARGS INSTALL_DIR "${CMAKE_BINARY_DIR}/generated")
    cmt_default_argument(ARGS ROOT_DIR "${PROJECT_SOURCE_DIR}")
    cmt_ensure_not_target(${TARGET})
    set(GENERATE_COMMAND codegenerator
            --schema-dir ${CMAKE_CURRENT_LIST_DIR}
            --install-dir ${ARGS_INSTALL_DIR}
            --language cpp
            --root-dir ${ARGS_ROOT_DIR}
            --target ${TARGET})

    set(GENERATED_CMAKE_FILE ${ARGS_INSTALL_DIR}/${TARGET}/CMakeLists.txt)
    set(TARGET_GENERATOR_NAME ${TARGET}_generator)
    add_custom_target(${TARGET_GENERATOR_NAME}
            SOURCES ${ARGS_SOURCES}
            COMMAND ${GENERATE_COMMAND}
            COMMAND ${CMAKE_COMMAND} -B${CMAKE_BINARY_DIR} -S${CMAKE_SOURCE_DIR}
            DEPENDS codegenerator
            COMMENT "Generating ${TARGET} C++ API"
            VERBATIM)
    include(${GENERATED_CMAKE_FILE} OPTIONAL)
endfunction()

function(cmt_codegenerator_link TARGET)
    cmt_ensure_target(${TARGET})
    cmt_parse_arguments(ARGS "" "" "PRIVATE;PUBLIC;INTERFACE" ${ARGN})

    foreach(GENERATED_TARGET ${ARGS_PRIVATE})
        set(GENERATOR_TARGET_NAME ${GENERATED_TARGET}_generator)
        add_dependencies(${TARGET} ${GENERATOR_TARGET_NAME})
    endforeach()

    foreach(GENERATED_TARGET ${ARGS_PUBLIC})
        set(GENERATOR_TARGET_NAME ${GENERATED_TARGET}_generator)
        add_dependencies(${TARGET} ${GENERATOR_TARGET_NAME})
    endforeach()

    foreach(GENERATED_TARGET ${ARGS_INTERFACE})
        set(GENERATOR_TARGET_NAME ${GENERATED_TARGET}_generator)
        add_dependencies(${TARGET} ${GENERATOR_TARGET_NAME})
    endforeach()

    cmt_log("Adding dependencies to ${TARGET}: PRIVATE ${ARGS_PRIVATE} PUBLIC ${ARGS_PUBLIC} INTERFACE ${ARGS_INTERFACE}")
endfunction()