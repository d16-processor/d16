add_library(Unity STATIC
    Unity/unity.c
)
 
target_include_directories(Unity PUBLIC
    Unity
)

add_executable(testing_main
  testing_main.c
  test_instruction.c
  test_label.c
  test_main.c
)
 
target_link_libraries(testing_main
    d16-lib
    Unity
)
