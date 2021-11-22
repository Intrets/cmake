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

function(find_static_lib LIB_NAME LIB_FILE INCLUDE_FILE)
	set(LIB ${LIB_NAME}_LIB)
	set(INCLUDE_DIR ${LIB_NAME}_INCLUDE_DIR)

	find_path(
		${INCLUDE_DIR} ${INCLUDE_FILE}
	)

	find_library(
		${LIB} ${LIB_FILE}
	)

	include(FindPackageHandleStandardArgs)
	find_package_handle_standard_args(
		${LIB_NAME} DEFAULT_MSG
		${INCLUDE_DIR}
		${LIB}
	)

	add_library(${LIB_NAME} STATIC IMPORTED)
	set_target_properties(${LIB_NAME} PROPERTIES
		IMPORTED_LOCATION ${${LIB}}
		IMPORTED_IMPLIB ${${LIB}}
		INTERFACE_INCLUDE_DIRECTORIES ${${INCLUDE_DIR}}
	)

	if(${${LIB_NAME}_FOUND})
		message("-- ${LIB_NAME} found.")
	endif()
endfunction()