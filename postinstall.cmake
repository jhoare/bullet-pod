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
    execute_process(
      COMMAND ${CMAKE_INSTALL_NAME_TOOL} -id ${CMAKE_INSTALL_PREFIX}/lib/${__lib}  ${CMAKE_INSTALL_PREFIX}/lib/${__lib})
    foreach(__deplib ${BULLET_INSTALL_LIBS})
      execute_process(
        COMMAND ${CMAKE_INSTALL_NAME_TOOL} -change ${__deplib} ${CMAKE_INSTALL_PREFIX}/lib/${__deplib} ${CMAKE_INSTALL_PREFIX}/lib/${__lib} )
    endforeach()
  endforeach()
endif()
