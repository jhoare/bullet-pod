cmake_minimum_required(VERSION 2.8.0)
project(bullet)

include(ExternalProject)

set(BULLET_OPTIONS -DINSTALL_LIBS=on 
		 -DPKGCONFIG_INSTALL_PREFIX=${CMAKE_INSTALL_PREFIX}/lib/pkgconfig
		 -DBUILD_BULLET2_DEMOS=off 
		 -DBUILD_CPU_DEMOS=off 
		 -DBUILD_EXTRAS=off 
		 -DBUILD_OPENGL3_DEMOS=off
		 -DBUILD_UNIT_TESTS=off
		 -DUSE_DOUBLE_PRECISION=on) 

if (WIN32)
	list(APPEND BULLET_OPTIONS -DUSE_MSVC_RUNTIME_LIBRARY_DLL=on)
else()
	list(APPEND BULLET_OPTIONS -DBUILD_SHARED_LIBS=on)   # shared libs doesn't work with msvc (there aren't any dllexports defined) 
endif()

ExternalProject_Add(bullet3
  GIT_REPOSITORY https://github.com/RobotLocomotion/bullet3.git
  GIT_TAG 333807e7e53000ebb7392aa7e12c6059eb4f581b
  CMAKE_ARGS -G${CMAKE_GENERATOR} 
  			 -DCMAKE_INSTALL_PREFIX=${CMAKE_INSTALL_PREFIX} 
  			 -DCMAKE_BUILD_TYPE=${CMAKE_BUILD_TYPE} 
  			 ${BULLET_OPTIONS}
  )

ExternalProject_Add_Step(bullet3 forceconfigure
	COMMAND ${CMAKE_COMMAND} -E echo "Force configure of ${proj}"
	DEPENDEES update
	DEPENDERS configure
	ALWAYS 1)

install(SCRIPT "${CMAKE_SOURCE_DIR}/postinstall.cmake")
