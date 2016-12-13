project (d16-lib)

set (d16asm_VERSION_MAJOR 1)
set (d16asm_VERSION_MINOR 0)

set(CMAKE_C_FLAGS_DEBUG "-DDEBUG -g")
set(CMAKE_C_FLAGS "-g -std=gnu99")
find_package(BISON REQUIRED)
find_package(FLEX REQUIRED)
find_package(Glib REQUIRED)
 
# configure a header file to pass some of the CMake settings
# to the source code
configure_file (
  "${PROJECT_SOURCE_DIR}/d16asm_config.h.in"
  "${PROJECT_BINARY_DIR}/d16asm_config.h"
)

# add the binary tree to the search path for include files
# so that we will find d16asm_config.h and bison/flex outputs
include_directories(${PROJECT_BINARY_DIR} ${PROJECT_SOURCE_DIR})
include_directories(${Glib_INCLUDE_DIR} ${GlibConfig_INCLUDE_DIR})

BISON_TARGET(parser parser.y ${CMAKE_CURRENT_BINARY_DIR}/parser.c)
FLEX_TARGET(scanner lex.l  ${CMAKE_CURRENT_BINARY_DIR}/lexer.c)
ADD_FLEX_BISON_DEPENDENCY(scanner parser)
set(SOURCE_FILES assembler.c instruction.c label.c aout.c)
if(CLANG_TIDY)
    add_custom_target(
        clang-tidy-3.7
        COMMAND /usr/local/bin/clang-tidy-3.7
        ${SOURCE_FILES}
        --config=''
        --
        --std=c99
        ${Glib_INCLUDE_DIR} ${GlibConfig_INCLUDE_DIR}
        )

endif()
add_library(d16-lib STATIC
  ${SOURCE_FILES} 
  ${BISON_parser_OUTPUTS}
  ${FLEX_scanner_OUTPUTS} )
 
target_include_directories(d16-lib PUBLIC
  ${PROJECT_BINARY_DIR} ${PROJECT_SOURCE_DIR}
  ${Glib_INCLUDE_DIR} ${GlibConfig_INCLUDE_DIR}
)

target_link_libraries(d16-lib
  ${Glib_LIBRARY}
)
