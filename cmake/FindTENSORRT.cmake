# Based on https://github.com/tier4/tensorrt_cmake_module
if(DEFINED ENV{TENSORRT_ROOT})
  set(TENSORRT_ROOT $ENV{TENSORRT_ROOT})
endif()

if(NOT TENSORRT_ROOT AND CUDA_TOOLKIT_ROOT_DIR)
  set(TENSORRT_ROOT "${CUDA_TOOLKIT_ROOT_DIR}")
endif()

find_path(TENSORRT_INCLUDE_DIR NvInfer.h
  HINTS ${TENSORRT_ROOT} /usr/include /usr/local/include
  PATH_SUFFIXES include)

find_library(TENSORRT_LIBRARY_INFER nvinfer
  HINTS ${TENSORRT_ROOT} /usr/lib/x86_64-linux-gnu /usr/local/lib
  PATH_SUFFIXES lib lib64)

find_library(TENSORRT_LIBRARY_ONNX nvonnxparser
  HINTS ${TENSORRT_ROOT} /usr/lib/x86_64-linux-gnu /usr/local/lib
  PATH_SUFFIXES lib lib64)

set(TENSORRT_INCLUDE_DIRS ${TENSORRT_INCLUDE_DIR})
set(TENSORRT_LIBRARIES ${TENSORRT_LIBRARY_INFER} ${TENSORRT_LIBRARY_ONNX})

# Version detection from NvInfer.h
if(EXISTS "${TENSORRT_INCLUDE_DIR}/NvInfer.h")
  file(READ "${TENSORRT_INCLUDE_DIR}/NvInfer.h" NVINFER_H_CONTENTS)
  string(REGEX MATCH "define NV_TENSORRT_MAJOR ([0-9]+)" _ "${NVINFER_H_CONTENTS}")
  set(TENSORRT_VERSION_MAJOR ${CMAKE_MATCH_1})
  message(STATUS "Found TensorRT version: ${TENSORRT_VERSION_MAJOR}")
endif()

include(FindPackageHandleStandardArgs)
find_package_handle_standard_args(TENSORRT DEFAULT_MSG
  TENSORRT_INCLUDE_DIR
  TENSORRT_LIBRARY_INFER
  TENSORRT_LIBRARY_ONNX
  TENSORRT_VERSION_MAJOR
)