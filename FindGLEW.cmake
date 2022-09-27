# Collection of CMake helper scripts
# Copyright (C) 2021 intrets

include("${CMAKE_SOURCE_DIR}/cmake/FindStaticLib.cmake")

find_static_lib(
	GLEW
	glew32
	GL/glew.h
)
