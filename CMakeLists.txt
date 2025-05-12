cmake_minimum_required(VERSION 3.25)
project(CoWTrie)

set(CMAKE_CXX_STANDARD 20)

include_directories(include)

include(FetchContent)

FetchContent_Declare(
  googletest
  URL https://github.com/google/googletest/archive/03597a01ee50ed33e9dfd640b249b4be3799d395.zip
)
FetchContent_MakeAvailable(googletest)
add_library(CoWTrie STATIC
    src/trie.cpp
    src/store.cpp
)

target_link_libraries(CoWTrie PRIVATE googletest)

enable_testing()

add_executable(trie_test test/trie_test.cpp)
add_executable(store_test test/store_test.cpp)
