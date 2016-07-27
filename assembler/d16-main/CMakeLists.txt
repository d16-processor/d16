add_executable(d16 main.c)
target_link_libraries(d16 d16-lib)
install(TARGETS d16 DESTINATION bin)