# Collection of CMake helper scripts
# Copyright (C) 2021  Intrets
#
# This program is free software: you can redistribute it and/or modify
# it under the terms of the GNU General Public License as published by
# the Free Software Foundation, either version 3 of the License, or
# (at your option) any later version.
#
# This program is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU General Public License for more details.
#
# You should have received a copy of the GNU General Public License
# along with this program.  If not, see <https://www.gnu.org/licenses/>.

set(LIB_NAME PhysX)

if (NOT WIN32)
	message(FATAL_ERROR "ABORTED: probably did some windows specific things here, need to test/make for non-windows")
endif()

function(find_physx_part)
	set(optionalArgs)
	set(oneValueArgs PART_NAME LIB_NAME DLL_NAME)
	set(multiValueArgs)
	cmake_parse_arguments("" "${optionalArgs}" "${oneValueArgs}" "${multiValueArgs}" ${ARGN})

	if (CMAKE_BUILD_TYPE STREQUAL "Debug")
		set(PATH_SUFFIX debug)
	else()
		set(PATH_SUFFIX release)
	endif()

	find_library(
		${_LIB_NAME}
		NAMES ${_PART_NAME}
		PATH_SUFFIXES ${PATH_SUFFIX}
	)

	if (${_LIB_NAME})
		string(LENGTH ${${_LIB_NAME}} LIB_NAME_LENGTH)
		math(EXPR LIB_NAME_LENGTH "${LIB_NAME_LENGTH} - 4")
		string(SUBSTRING ${${_LIB_NAME}} 0 ${LIB_NAME_LENGTH} ${_DLL_NAME})
		string(APPEND ${_DLL_NAME} .dll)

		set(${_DLL_NAME} "${${_DLL_NAME}}" CACHE FILEPATH "")
	endif()
endfunction()

find_path(
	PHYSX_INCLUDE_DIR PxPhysicsAPI.h
)

find_path(
	PHYSX_SHARED_INCLUDE_DIR foundation/Px.h
)

find_physx_part(
	LIB_NAME PHYSX_LIB
	DLL_NAME PHYSX_DLL
	PART_NAME PhysX_64
)

find_physx_part(
	LIB_NAME PHYSX_LIB_COMMON
	DLL_NAME PHYSX_DLL_COMMON
	PART_NAME PhysXCommon_64
)

find_physx_part(
	LIB_NAME PHYSX_LIB_FOUNDATION
	DLL_NAME PHYSX_DLL_FOUNDATION
	PART_NAME PhysXFoundation_64
)

find_physx_part(
	LIB_NAME PHYSX_LIB_EXTENSIONS
	DLL_NAME PHYSX_DLL_EXTENSIONS
	PART_NAME PhysXExtensions_static_64
)

include(FindPackageHandleStandardArgs)
find_package_handle_standard_args(
	PhysX
	REQUIRED_VARS
		PHYSX_INCLUDE_DIR
		PHYSX_SHARED_INCLUDE_DIR
		PHYSX_LIB
		PHYSX_LIB_COMMON
		PHYSX_LIB_FOUNDATION
		PHYSX_LIB_EXTENSIONS
)

add_library(PhysX SHARED IMPORTED)
set_target_properties(PhysX PROPERTIES
	IMPORTED_LOCATION ${PHYSX_DLL}
	IMPORTED_IMPLIB ${PHYSX_LIB}
	INTERFACE_INCLUDE_DIRECTORIES "${PHYSX_INCLUDE_DIR};${PHYSX_SHARED_INCLUDE_DIR}"
)

add_library(PhysXCommon SHARED IMPORTED)
set_target_properties(PhysXCommon PROPERTIES
	IMPORTED_LOCATION ${PHYSX_DLL_COMMON}
	IMPORTED_IMPLIB ${PHYSX_LIB_COMMON}
	INTERFACE_INCLUDE_DIRECTORIES "${PHYSX_INCLUDE_DIR};${PHYSX_SHARED_INCLUDE_DIR}"
)

add_library(PhysXFoundation SHARED IMPORTED)
set_target_properties(PhysXFoundation PROPERTIES
	IMPORTED_LOCATION ${PHYSX_DLL_FOUNDATION}
	IMPORTED_IMPLIB ${PHYSX_LIB_FOUNDATION}
	INTERFACE_INCLUDE_DIRECTORIES "${PHYSX_INCLUDE_DIR};${PHYSX_SHARED_INCLUDE_DIR}"
)

add_library(PhysXExtensions STATIC IMPORTED)
set_target_properties(PhysXExtensions PROPERTIES
	IMPORTED_LOCATION ${PHYSX_LIB_EXTENSIONS}
	IMPORTED_IMPLIB ${PHYSX_LIB_EXTENSIONS}
	INTERFACE_INCLUDE_DIRECTORIES "${PHYSX_INCLUDE_DIR};${PHYSX_SHARED_INCLUDE_DIR}"
)

target_link_libraries(PhysX INTERFACE
	PhysXCommon
	PhysXFoundation
	PhysXExtensions
)
