cmake_minimum_required(VERSION 3.16)
project(vo_web CXX)

set(CMAKE_CXX_STANDARD 17)
set(CMAKE_CXX_STANDARD_REQUIRED ON)
set(CMAKE_CXX_EXTENSIONS OFF)

set(INTERP_SRC "${CMAKE_CURRENT_SOURCE_DIR}/../interp/src")

add_executable(vo_web
    src/web_main.cpp
    ${INTERP_SRC}/lexer/lexer.cpp
    ${INTERP_SRC}/parser/parser.cpp
    ${INTERP_SRC}/interpreter/value.cpp
    ${INTERP_SRC}/interpreter/environment.cpp
    ${INTERP_SRC}/interpreter/interpreter.cpp
)

target_include_directories(vo_web PRIVATE ${INTERP_SRC})

target_compile_options(vo_web PRIVATE -fexceptions)

set_target_properties(vo_web PROPERTIES
    OUTPUT_NAME "vo"
    SUFFIX ".js"
)

# Assemble a single web_lib directory so the preload is unambiguous:
# start with interp/lib (all stdlib), then overlay emscripted/lib (web-safe
# overrides — e.g. the empty stdio.vo that lets the native builtins win).
set(WEB_LIB_STAGING "${CMAKE_CURRENT_BINARY_DIR}/web_lib")

add_custom_command(TARGET vo_web PRE_LINK
    COMMAND ${CMAKE_COMMAND} -E copy_directory
        "${CMAKE_CURRENT_SOURCE_DIR}/../interp/lib"
        "${WEB_LIB_STAGING}"
    COMMAND ${CMAKE_COMMAND} -E copy_directory
        "${CMAKE_CURRENT_SOURCE_DIR}/lib"
        "${WEB_LIB_STAGING}"
    COMMENT "Assembling web_lib (interp/lib + emscripted/lib overrides)"
)

set_target_properties(vo_web PROPERTIES
    LINK_FLAGS "-sEXPORTED_FUNCTIONS=['_run_vo'] -sEXPORTED_RUNTIME_METHODS=['ccall'] -sALLOW_MEMORY_GROWTH=1 -sSTACK_SIZE=5242880 -fexceptions -sDISABLE_EXCEPTION_CATCHING=0 -O2 --preload-file ${WEB_LIB_STAGING}@/lib"
)
