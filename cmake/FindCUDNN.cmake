# Based on https://github.com/tier4/cudnn_cmake_module
if(DEFINED ENV{CUDNN_ROOT})
  set(CUDNN_ROOT $ENV{CUDNN_ROOT})
endif()

if(NOT CUDNN_ROOT AND CUDA_TOOLKIT_ROOT_DIR)
  set(CUDNN_ROOT "${CUDA_TOOLKIT_ROOT_DIR}")
endif()

find_path(CUDNN_INCLUDE_DIR cudnn.h
  HINTS ${CUDNN_ROOT} /usr/include /usr/local/include
  PATH_SUFFIXES include cuda/include)

find_library(CUDNN_LIBRARY cudnn
  HINTS ${CUDNN_ROOT} /usr/lib/x86_64-linux-gnu /usr/local/lib
  PATH_SUFFIXES lib lib64 cuda/lib cuda/lib64)

set(CUDNN_INCLUDE_DIRS ${CUDNN_INCLUDE_DIR})
set(CUDNN_LIBRARIES ${CUDNN_LIBRARY})

include(FindPackageHandleStandardArgs)
find_package_handle_standard_args(CUDNN DEFAULT_MSG
  CUDNN_INCLUDE_DIR
  CUDNN_LIBRARY
)