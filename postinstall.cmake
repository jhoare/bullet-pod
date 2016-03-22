if (APPLE)
  message("JRH: Bullet postinstall.cmake running")
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
				COMMAND install_name_tool -change ${__deplib} ${CMAKE_INSTALL_PREFIX}/lib/${__deplib} ${CMAKE_INSTALL_PREFIX}/lib/${__lib} )
		endforeach()
    execute_process(
			COMMAND install_name_tool -id ${CMAKE_INSTALL_PREFIX}/lib/${__lib}  ${CMAKE_INSTALL_PREFIX}/lib/${__lib}
			${fixup_deplib_command})
    message("JRH: fixup_deplib_command: ${fixup_deplib_command}")
	endforeach()
endif()
