cmake_minimum_required(VERSION 3.5)
project(tensorrt_common)

list(APPEND CMAKE_MODULE_PATH ${CMAKE_CURRENT_SOURCE_DIR}/cmake)

if(NOT CMAKE_CXX_STANDARD)
  set(CMAKE_CXX_STANDARD 17)
  set(CMAKE_CXX_STANDARD_REQUIRED ON)
  set(CMAKE_CXX_EXTENSIONS OFF)
endif()

if(CMAKE_COMPILER_IS_GNUCXX OR CMAKE_CXX_COMPILER_ID MATCHES "Clang")
  add_compile_options(-Wall -Wextra -Wpedantic -Werror)
endif()

find_package(CUDA REQUIRED)
find_package(CUDNN REQUIRED)
find_package(TENSORRT REQUIRED)

if(NOT DEFINED TENSORRT_VERSION_MAJOR)
    if(DEFINED NV_TENSORRT_MAJOR)
        set(TENSORRT_VERSION_MAJOR ${NV_TENSORRT_MAJOR})
    else()
        message(FATAL_ERROR "Could not determine TensorRT version")
    endif()
endif()

cuda_add_library(${PROJECT_NAME} SHARED
  src/tensorrt_common.cpp
)

target_include_directories(${PROJECT_NAME}
  PUBLIC
    $<BUILD_INTERFACE:${CMAKE_CURRENT_SOURCE_DIR}/include>
    ${TENSORRT_INCLUDE_DIRS}
)

target_link_libraries(${PROJECT_NAME}
  ${TENSORRT_LIBRARIES}
  stdc++fs
)

target_compile_definitions(${PROJECT_NAME} PUBLIC
  TENSORRT_VERSION_MAJOR=${TENSORRT_VERSION_MAJOR}
)