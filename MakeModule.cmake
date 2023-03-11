# Collection of CMake helper scripts
# Copyright (C) 2021 intrets

function(make_module)
	set(optionalArgs LIBRARY_TYPE USE_PRECOMPILED_HEADERS)
	set(oneValueArgs MODULE_NAME CXX_STANDARD)
	set(multiValueArgs MODULE_FILES REQUIRED_LIBS OPTIONAL_LIBS ADDITIONAL_FILES)
	cmake_parse_arguments("" "${optionalArgs}" "${oneValueArgs}" "${multiValueArgs}" ${ARGN})

	message(STATUS "begin making module ${MODULE_NAME}")

	if (NOT ${_LIBRARY_TYPE})
		set(_LIBRARY_TYPE STATIC)
	endif()

	foreach(FILE ${_MODULE_FILES})
		list(APPEND SOURCES_LIST "${FILE}.cpp")
		list(APPEND HEADERS_LIST "include/${MODULE_NAME}/${FILE}.h")
	endforeach()

	add_library(${_MODULE_NAME} ${_LIBRARY_TYPE} ${SOURCES_LIST} ${HEADERS_LIST} "${_ADDITIONAL_FILES}")
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

	if (NOT ${_USE_PRECOMPILED_HEADERS})
		if (NOT ${PRECOMPILED_HEADERS_TARGET})
			message(STATUS "set PRECOMPILED_HEADERS_TARGET to the target containing the precompiled headers before creating a module with make_module")
		endif()

		target_precompile_headers(
			${_MODULE_NAME}
			REUSE_FROM
				${PRECOMPILED_HEADERS_TARGET}
		)
	endif()

	message(STATUS "end making module ${_MODULE_NAME}")
endfunction()
