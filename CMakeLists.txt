cmake_minimum_required(VERSION 3.10)

# Store in CMAKE_DEB_HOST_ARCH var the current build architecture
execute_process(COMMAND
  dpkg-architecture
    -qDEB_HOST_ARCH
  OUTPUT_VARIABLE
    CMAKE_DEB_HOST_ARCH
  OUTPUT_STRIP_TRAILING_WHITESPACE
)
if(${CMAKE_DEB_HOST_ARCH} MATCHES "arm64")
	set(CPU_TYPE "arm")
	message(STATUS "CMAKE_DEB_HOST_ARCH:${CMAKE_DEB_HOST_ARCH} CPU_TYPE=${CPU_TYPE}")  

elseif(${CMAKE_DEB_HOST_ARCH} MATCHES "i386")
	set(CPU_TYPE "x86")
	message(STATUS "CMAKE_DEB_HOST_ARCH:${CMAKE_DEB_HOST_ARCH} CPU_TYPE=${CPU_TYPE}") 
	set(CPU_TYPE "x86")
elseif(${CMAKE_DEB_HOST_ARCH} MATCHES "amd64")
	set(CPU_TYPE "x64")
	message(STATUS "CMAKE_DEB_HOST_ARCH:${CMAKE_DEB_HOST_ARCH} CPU_TYPE=${CPU_TYPE}") 	
	
else()
	set(CPU_TYPE "x64")
	message(STATUS "CMAKE_DEB_HOST_ARCH:${CMAKE_DEB_HOST_ARCH} CPU_TYPE=${CPU_TYPE}") 
endif()

IF (WIN32)
	#SET(CMAKE_C_COMPILER "c:/Program Files/LLVM/bin/clang")
	#SET(CMAKE_CXX_COMPILER "c:/Program Files/LLVM/bin/clang++")
ELSEIF (APPLE)

ELSEIF (UNIX)
  #find_package(LLVM REQUIRED CONFIG)
  message(STATUS "This is BINARY dir " ${PROJECT_BINARY_DIR})
  message(STATUS "This is SOURCE dir " ${PROJECT_SOURCE_DIR})
  #message(STATUS "Found LLVM ${LLVM_PACKAGE_VERSION}")
  #message(STATUS "Using LLVMConfig.cmake in: ${LLVM_DIR}")
  #include(${CMAKE_CURRENT_SOURCE_DIR}/cmake/llvm.toolchain.cmake)

ENDIF ()
message(STATUS "CMAKE_C_COMPILER:${CMAKE_C_COMPILER}") 
message(STATUS "CMAKE_CXX_COMPILER:${CMAKE_CXX_COMPILER}") 
set(PROJECT_NAME "mediasoup-server")
project(${PROJECT_NAME})

set(CMAKE_ARCHIVE_OUTPUT_DIRECTORY "${PROJECT_BINARY_DIR}/${CMAKE_BUILD_TYPE}")
set(CMAKE_LIBRARY_OUTPUT_DIRECTORY "${PROJECT_BINARY_DIR}/${CMAKE_BUILD_TYPE}")
set(CMAKE_RUNTIME_OUTPUT_DIRECTORY "${PROJECT_BINARY_DIR}/${CMAKE_BUILD_TYPE}")

set(PROJECT_INCLUDE_DIR ${CMAKE_CURRENT_SOURCE_DIR}/release/include 
${CMAKE_CURRENT_SOURCE_DIR}/release/include/oatpp-1.4.0/oatpp
${CMAKE_CURRENT_SOURCE_DIR}/release/include/oatpp-1.4.0/oatpp-openssl
${CMAKE_CURRENT_SOURCE_DIR}/release/include/oatpp-1.4.0/oatpp-websocket
${CMAKE_CURRENT_SOURCE_DIR}/worker/include 
${CMAKE_CURRENT_SOURCE_DIR}/release/include/concurrentqueue
${CMAKE_CURRENT_SOURCE_DIR}/deps/json/single_include
)
set(PROJECT_LIB_DIR ${CMAKE_CURRENT_SOURCE_DIR}/release/lib)
set(WORKER_INCLUDE_DIR ${CMAKE_CURRENT_SOURCE_DIR}/worker/include)
set(LIB_WEBRTC_INCLUDE_DIR ${CMAKE_CURRENT_SOURCE_DIR}/deps/libwebrtc ${CMAKE_CURRENT_SOURCE_DIR}/deps/libwebrtc/libwebrtc ${CMAKE_CURRENT_SOURCE_DIR}/deps/libwebrtc/deps/abseil-cpp)
set(PROJECT_RELEASE_DIR ${CMAKE_CURRENT_SOURCE_DIR}/release)
set(CONTROLLER_INCLUDE_DIR ${CMAKE_CURRENT_SOURCE_DIR}/controller)

IF (WIN32)
  # Windows-specific compiler definitions to avoid conflicts
  add_definitions(-DNOMINMAX)           # Prevent Windows.h from defining min/max macros
  add_definitions(-D_WIN32_WINNT=0x0602) # Target Windows 8 and above (required for libuv)
  add_definitions(-DWIN32_LEAN_AND_MEAN) # Reduce Windows header bloat
  
  # Use system-installed OpenSSL instead of deps/openssl source
  set(OPENSSL_ROOT_DIR "C:/Program Files/OpenSSL-Win64")
  set(PROJECT_INCLUDE_DIR ${PROJECT_INCLUDE_DIR} "C:/Program Files/OpenSSL-Win64/include")
  set(PROJECT_INCLUDE_DIR ${PROJECT_INCLUDE_DIR} ${CMAKE_CURRENT_SOURCE_DIR}/deps/boost/include)
  set(PROJECT_INCLUDE_DIR ${PROJECT_INCLUDE_DIR} ${CMAKE_CURRENT_SOURCE_DIR}/deps/libsrtp)
  set(PROJECT_INCLUDE_DIR ${PROJECT_INCLUDE_DIR} ${CMAKE_CURRENT_SOURCE_DIR}/deps/libsrtp/include)
  set(PROJECT_INCLUDE_DIR ${PROJECT_INCLUDE_DIR} ${CMAKE_CURRENT_SOURCE_DIR}/deps/libuv/include)
  set(PROJECT_INCLUDE_DIR ${PROJECT_INCLUDE_DIR} ${CMAKE_CURRENT_SOURCE_DIR}/deps/oatpp/src)
  set(PROJECT_INCLUDE_DIR ${PROJECT_INCLUDE_DIR} ${CMAKE_CURRENT_SOURCE_DIR}/deps/oatpp-openssl/src)
  set(PROJECT_INCLUDE_DIR ${PROJECT_INCLUDE_DIR} ${CMAKE_CURRENT_SOURCE_DIR}/deps/oatpp-websocket/src)
  set(PROJECT_INCLUDE_DIR ${PROJECT_INCLUDE_DIR} ${CMAKE_CURRENT_SOURCE_DIR}/deps/libsdptransform)
  set(PROJECT_INCLUDE_DIR ${PROJECT_INCLUDE_DIR} ${CMAKE_CURRENT_SOURCE_DIR}/deps/netstring)
  set(PROJECT_INCLUDE_DIR ${PROJECT_INCLUDE_DIR} ${CMAKE_CURRENT_SOURCE_DIR}/deps/usrsctp/usrsctplib)
  set(PROJECT_INCLUDE_DIR ${PROJECT_INCLUDE_DIR} ${CMAKE_CURRENT_SOURCE_DIR}/deps/json/single_include)
  # Windows-specific: Add sigslot, flatbuffers, abseil-cpp, concurrentqueue include paths
  set(PROJECT_INCLUDE_DIR ${PROJECT_INCLUDE_DIR} ${CMAKE_CURRENT_SOURCE_DIR}/deps/sigslot/include)
  set(PROJECT_INCLUDE_DIR ${PROJECT_INCLUDE_DIR} ${CMAKE_CURRENT_SOURCE_DIR}/deps/flatbuffers/include)
  set(PROJECT_INCLUDE_DIR ${PROJECT_INCLUDE_DIR} ${CMAKE_CURRENT_SOURCE_DIR}/deps/abseil-cpp)
  set(PROJECT_INCLUDE_DIR ${PROJECT_INCLUDE_DIR} ${CMAKE_CURRENT_SOURCE_DIR}/deps/concurrentqueue)
  set(PROJECT_INCLUDE_DIR ${PROJECT_INCLUDE_DIR} ${CMAKE_CURRENT_SOURCE_DIR}/deps)  # For moodycamel/concurrentqueue.h
  set(PROJECT_LIB_DIR ${CMAKE_CURRENT_SOURCE_DIR}/lib/win/${CPU_TYPE})
  # Set FBS output directory for Windows
  set(FBS_OUTPUT_DIR ${CMAKE_CURRENT_SOURCE_DIR}/generated/fbs)
ENDIF ()

IF(NOT WIN32)
    set(CMAKE_CXX_FLAGS "${CMAKE_CXX_FLAGS} -std=c++17")
ENDIF()
message("\n=========== mediasoup-server Build Configuration ===========\n")
message(STATUS "PROJECT_INCLUDE_DIR : " ${PROJECT_INCLUDE_DIR})
message(STATUS "PROJECT_LIB_DIR : " ${PROJECT_LIB_DIR})

message("")


# add subdirectory
#add_subdirectory(deps/libuv)

# add openssl no need app 
set(WITH_APPS OFF CACHE INTERNAL "")
#add_subdirectory(deps/openssl)
unset(WITH_APPS)


#add_subdirectory(deps/catch)

set(TEST_APPS OFF CACHE INTERNAL "")
set(ENABLE_OPENSSL ON CACHE INTERNAL "")
#add_subdirectory(deps/libsrtp)
unset(TEST_APPS)
unset(ENABLE_OPENSSL)

#add_subdirectory(deps/netstring)

set(sctp_werror OFF CACHE INTERNAL "")
set(sctp_build_programs OFF CACHE INTERNAL "")
set(sctp_build_fuzzer OFF CACHE INTERNAL "")
set(sctp_link_programs_static OFF CACHE INTERNAL "")
#add_subdirectory(deps/usrsctp)
unset(sctp_werror)
unset(sctp_build_programs)
unset(sctp_build_fuzzer)
unset(sctp_link_programs_static)

set(JSON_BuildTests OFF CACHE INTERNAL "")
set(JSON_Install OFF CACHE INTERNAL "")
#add_subdirectory(deps/json)
unset(JSON_BuildTests)
unset(JSON_Install)

IF(WIN32)
# Build getopt library for command line parsing
set(BUILD_SHARED_LIBS OFF CACHE BOOL "" FORCE)
add_subdirectory(deps/getopt)

# Build dependencies for Windows
set(OATPP_BUILD_TESTS OFF CACHE BOOL "" FORCE)
set(OATPP_INSTALL OFF CACHE BOOL "" FORCE)
add_subdirectory(deps/oatpp)

set(OATPP_MODULES_LOCATION CUSTOM CACHE STRING "" FORCE)
set(OATPP_DIR_SRC ${CMAKE_CURRENT_SOURCE_DIR}/deps/oatpp/src CACHE STRING "" FORCE)
set(OATPP_DIR_LIB ${CMAKE_BINARY_DIR}/deps/oatpp/src CACHE STRING "" FORCE)
add_subdirectory(deps/oatpp-openssl)
add_subdirectory(deps/oatpp-websocket)

set(LIBUV_BUILD_SHARED OFF CACHE BOOL "" FORCE)
set(LIBUV_BUILD_TESTS OFF CACHE BOOL "" FORCE)
add_subdirectory(deps/libuv)

set(TEST_APPS OFF CACHE BOOL "" FORCE)
set(ENABLE_OPENSSL ON CACHE BOOL "" FORCE)
set(ENABLE_WARNINGS_AS_ERRORS OFF CACHE BOOL "" FORCE)
add_subdirectory(deps/libsrtp)

set(sctp_werror OFF CACHE BOOL "" FORCE)
set(sctp_build_programs OFF CACHE BOOL "" FORCE)
add_subdirectory(deps/usrsctp)

# Build Abseil library
set(ABSL_PROPAGATE_CXX_STD ON CACHE BOOL "" FORCE)
set(ABSL_BUILD_TESTING OFF CACHE BOOL "" FORCE)
add_subdirectory(deps/abseil-cpp)

ENDIF()

#add_subdirectory(deps/libressl)
#add_subdirectory(deps/oatpp)
#add_subdirectory(deps/oatpp-libressl)
#add_subdirectory(deps/oatpp-websocket)
#add_subdirectory(deps/webservice)
#add_subdirectory(protoo)
add_subdirectory(deps/libwebrtc)
add_subdirectory(worker)
add_subdirectory(controller)
add_subdirectory(sfu)

add_dependencies(sfu controller worker webrtc)
