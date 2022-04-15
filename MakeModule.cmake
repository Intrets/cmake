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

function(make_module)
	set(optionalArgs LIBRARY_TYPE)
	set(oneValueArgs MODULE_NAME CXX_STANDARD)
	set(multiValueArgs MODULE_FILES REQUIRED_LIBS OPTIONAL_LIBS)
	cmake_parse_arguments("" "${optionalArgs}" "${oneValueArgs}" "${multiValueArgs}" ${ARGN})

	message(STATUS "begin making module ${MODULE_NAME}")

	if (NOT ${_LIBRARY_TYPE})
		set(_LIBRARY_TYPE STATIC)
	endif()

	foreach(FILE ${_MODULE_FILES})
		list(APPEND SOURCES_LIST "${FILE}.cpp")
		list(APPEND HEADERS_LIST "include/${MODULE_NAME}/${FILE}.h")
	endforeach()

	add_library(${_MODULE_NAME} ${_LIBRARY_TYPE} ${SOURCES_LIST} ${HEADERS_LIST})
	target_compile_features(${_MODULE_NAME} PUBLIC cxx_std_${_CXX_STANDARD})

	target_include_directories(${_MODULE_NAME} PUBLIC include)
	target_include_directories(${_MODULE_NAME} PRIVATE include/${_MODULE_NAME})

	source_group(
		TREE "${CMAKE_CURRENT_SOURCE_DIR}/include/${_MODULE_NAME}"
		PREFIX "Header Files"
		FILES ${HEADERS_LIST}
	)

	foreach(LIB ${_OPTIONAL_LIBS})
		string(TOUPPER ${LIB} LIB_NAME)
		if (${LIB_NAME}_FOUND)
			message(STATUS "  found optional lib ${LIB} in ${_MODULE_NAME}")
			target_link_libraries(${_MODULE_NAME} PUBLIC ${LIB})
		else()
			message(STATUS "  did not find optional lib ${LIB} in ${_MODULE_NAME}")
		endif()
	endforeach()

	target_link_libraries(${_MODULE_NAME} PUBLIC "${_REQUIRED_LIBS}")

	string(TOUPPER ${_MODULE_NAME} LIB_NAME)
	target_compile_definitions(${_MODULE_NAME} PUBLIC LIB_${LIB_NAME})

	option(USE_PRECOMPILED_HEADERS "enable/disable precompiled headers" ON)

	if (USE_PRECOMPILED_HEADERS)
		target_precompile_headers(${_MODULE_NAME} PRIVATE ${HEADERS_LIST})
	endif()

	message(STATUS "end making module ${_MODULE_NAME}")
endfunction()
