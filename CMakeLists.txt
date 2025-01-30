cmake_minimum_required(VERSION 3.5)
project(tensorrt_common)

# Keep existing compiler settings
if(NOT CMAKE_CXX_STANDARD)
  set(CMAKE_CXX_STANDARD 17)
  set(CMAKE_CXX_STANDARD_REQUIRED ON)
  set(CMAKE_CXX_EXTENSIONS OFF)
endif()
if(CMAKE_COMPILER_IS_GNUCXX OR CMAKE_CXX_COMPILER_ID MATCHES "Clang")
  add_compile_options(-Wall -Wextra -Wpedantic -Werror)
endif()

# Keep existing dependencies
find_package(CUDA REQUIRED)
find_package(CUDNN REQUIRED)
find_package(TENSORRT REQUIRED)

# Define TensorRT version from NV_TENSORRT defines
if(NOT DEFINED TENSORRT_VERSION_MAJOR)
    if(DEFINED NV_TENSORRT_MAJOR)
        set(TENSORRT_VERSION_MAJOR ${NV_TENSORRT_MAJOR})
    else()
        message(FATAL_ERROR "Could not determine TensorRT version")
    endif()
endif()

# Add to compile definitions
target_compile_definitions(${PROJECT_NAME} PUBLIC
    TENSORRT_VERSION_MAJOR=${TENSORRT_VERSION_MAJOR}
)

if(NOT (${CUDA_FOUND} AND ${CUDNN_FOUND} AND ${TENSORRT_FOUND}))
  message(WARNING "cuda, cudnn, tensorrt libraries are not found")
  return()
endif()

# Keep existing library definition
cuda_add_library(${PROJECT_NAME} SHARED
  src/tensorrt_common.cpp
)

target_include_directories(${PROJECT_NAME}
  PUBLIC
    $<BUILD_INTERFACE:${CMAKE_CURRENT_SOURCE_DIR}/include>
    $<INSTALL_INTERFACE:include>
    ${TENSORRT_INCLUDE_DIRS}
)

target_link_libraries(${PROJECT_NAME}
  ${TENSORRT_LIBRARIES}
  stdc++fs
)

target_compile_definitions(${PROJECT_NAME} PRIVATE
  TENSORRT_VERSION_MAJOR=${TENSORRT_VERSION_MAJOR}
)

# Replace ament exports with standard CMake install
install(
  TARGETS ${PROJECT_NAME}
  EXPORT ${PROJECT_NAME}Targets
  LIBRARY DESTINATION lib
  ARCHIVE DESTINATION lib
  RUNTIME DESTINATION bin
  INCLUDES DESTINATION include
)

install(
  DIRECTORY include/${PROJECT_NAME}/
  DESTINATION include/${PROJECT_NAME}
  FILES_MATCHING PATTERN "*.hpp"
)

install(
  EXPORT ${PROJECT_NAME}Targets
  FILE ${PROJECT_NAME}Targets.cmake
  NAMESPACE ${PROJECT_NAME}::
  DESTINATION lib/cmake/${PROJECT_NAME}
)

include(CMakePackageConfigHelpers)

configure_package_config_file(
  cmake/${PROJECT_NAME}Config.cmake.in
  ${CMAKE_CURRENT_BINARY_DIR}/${PROJECT_NAME}Config.cmake
  INSTALL_DESTINATION lib/cmake/${PROJECT_NAME}
)

write_basic_package_version_file(
  ${CMAKE_CURRENT_BINARY_DIR}/${PROJECT_NAME}ConfigVersion.cmake
  VERSION 1.0.0
  COMPATIBILITY SameMajorVersion
)

install(
  FILES
    ${CMAKE_CURRENT_BINARY_DIR}/${PROJECT_NAME}Config.cmake
    ${CMAKE_CURRENT_BINARY_DIR}/${PROJECT_NAME}ConfigVersion.cmake
  DESTINATION lib/cmake/${PROJECT_NAME}
)