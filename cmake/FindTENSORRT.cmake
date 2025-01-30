# cmake/FindTENSORRT.cmake
if(NOT DEFINED ENV{TENSORRT_ROOT} AND NOT DEFINED TENSORRT_ROOT)
  if(EXISTS "/usr/include/x86_64-linux-gnu/NvInfer.h")
    set(TENSORRT_ROOT "/usr/include/x86_64-linux-gnu")
  elseif(EXISTS "/usr/local/cuda/include/NvInfer.h")
    set(TENSORRT_ROOT "/usr/local/cuda")
  endif()
endif()

find_path(TENSORRT_INCLUDE_DIR NvInfer.h
  HINTS 
    ${TENSORRT_ROOT}
    /usr/include/x86_64-linux-gnu
    /usr/local/cuda/include
    /usr/include
  NO_DEFAULT_PATH
)

find_library(TENSORRT_LIBRARY_INFER nvinfer
  HINTS
    /usr/lib/x86_64-linux-gnu
    /usr/local/cuda/lib64
    ${TENSORRT_ROOT}/lib
    ${TENSORRT_ROOT}/lib64
  NO_DEFAULT_PATH
)

find_library(TENSORRT_LIBRARY_ONNXPARSER nvonnxparser
  HINTS
    /usr/lib/x86_64-linux-gnu
    /usr/local/cuda/lib64
    ${TENSORRT_ROOT}/lib
    ${TENSORRT_ROOT}/lib64
  NO_DEFAULT_PATH
)

if(TENSORRT_INCLUDE_DIR AND EXISTS "${TENSORRT_INCLUDE_DIR}/NvInfer.h")
  file(READ "${TENSORRT_INCLUDE_DIR}/NvInfer.h" TENSORRT_HEADER_CONTENT)
  string(REGEX MATCH "define NV_TENSORRT_MAJOR ([0-9]+)" _ "${TENSORRT_HEADER_CONTENT}")
  
  if(CMAKE_MATCH_1)
    set(TENSORRT_VERSION_MAJOR ${CMAKE_MATCH_1})
  else()
    # Fallback for older TensorRT versions
    set(TENSORRT_VERSION_MAJOR 7)
    message(STATUS "Could not determine TensorRT version from header, assuming ${TENSORRT_VERSION_MAJOR}")
  endif()
endif()

set(TENSORRT_INCLUDE_DIRS ${TENSORRT_INCLUDE_DIR})
set(TENSORRT_LIBRARIES ${TENSORRT_LIBRARY_INFER} ${TENSORRT_LIBRARY_ONNXPARSER})

include(FindPackageHandleStandardArgs)
find_package_handle_standard_args(TENSORRT
  REQUIRED_VARS
    TENSORRT_INCLUDE_DIR
    TENSORRT_LIBRARY_INFER
    TENSORRT_LIBRARY_ONNXPARSER
    TENSORRT_VERSION_MAJOR
)

if(NOT TARGET TensorRT::TensorRT)
  add_library(TensorRT::TensorRT INTERFACE IMPORTED)
  set_target_properties(TensorRT::TensorRT PROPERTIES
    INTERFACE_INCLUDE_DIRECTORIES "${TENSORRT_INCLUDE_DIRS}"
    INTERFACE_LINK_LIBRARIES "${TENSORRT_LIBRARIES}"
  )
endif()