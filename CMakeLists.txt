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

install(CODE "message(\"Nothing to do for install.\")")

if (APPLE)
  set(BULLET_INSTALL_LIBS
    libBullet3OpenCL_clew.2.83.dylib
    libBullet2FileLoader.2.83.dylib
    libBullet3Dynamics.2.83.dylib
    libBullet3Collision.2.83.dylib
    libBullet3Geometry.2.83.dylib
    libBullet3Common.2.83.dylib
    libBulletSoftBody.2.83.dylib
    libBulletCollision.2.83.dylib
    libBulletDynamics.2.83.dylib
    libLinearMath.2.83.dylib )

  foreach(__lib ${BULLET_INSTALL_LIBS})
    set(fixup_deplib_command)
    foreach(__deplib ${BULLET_INSTALL_LIBS})
      list(APPEND fixup_deplib_command
        COMMAND ${CMAKE_INSTALL_NAME_TOOL} -change ${__deplib} ${CMAKE_INSTALL_PREFIX}/lib/${__deplib} ${CMAKE_INSTALL_PREFIX}/lib/${__lib} )
    endforeach()
    add_custom_target(fixup_rpath_${__lib} ALL
      COMMAND ${CMAKE_INSTALL_NAME_TOOL} -id ${CMAKE_INSTALL_PREFIX}/lib/${__lib}  ${CMAKE_INSTALL_PREFIX}/lib/${__lib}
      ${fixup_deplib_command})
    add_dependencies(bullet3 fixup_rpath_${__lib})
  endforeach()
endif()
