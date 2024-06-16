# Collection of CMake helper scripts
# Copyright (C) 2021 intrets

function(make_module)
	set(optionalArgs LIBRARY_TYPE DO_NOT_USE_PRECOMPILED_HEADERS)
	set(oneValueArgs MODULE_NAME CXX_STANDARD)
	set(multiValueArgs MODULE_FILES REQUIRED_LIBS OPTIONAL_LIBS ADDITIONAL_FILES)
	cmake_parse_arguments("" "${optionalArgs}" "${oneValueArgs}" "${multiValueArgs}" ${ARGN})

	message(STATUS "------------make_module start------------")
	message(STATUS "begin making module <${MODULE_NAME}>")

	if (NOT ${_LIBRARY_TYPE})
		set(_LIBRARY_TYPE STATIC)
	endif()

	foreach(FILE ${_MODULE_FILES})
		list(APPEND SOURCES_LIST "${FILE}.cpp")
		list(APPEND HEADERS_LIST "include/${MODULE_NAME}/${FILE}.h")
		list(APPEND ${_MODULE_NAME}_FILES ${FILE})
	endforeach()

	set(${_MODULE_NAME}_FILES "${${_MODULE_NAME}_FILES}" PARENT_SCOPE)

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
			message(STATUS "  found optional lib <${LIB}> in <${_MODULE_NAME}>")
			target_link_libraries(${_MODULE_NAME} PUBLIC ${LIB})
		else()
			message(STATUS "  did not find optional lib <${LIB}> in <${_MODULE_NAME}>")
		endif()
	endforeach()

	target_link_libraries(${_MODULE_NAME} PUBLIC "${_REQUIRED_LIBS}")

	string(TOUPPER ${_MODULE_NAME} LIB_NAME)
	target_compile_definitions(${_MODULE_NAME} PUBLIC LIB_${LIB_NAME})

	if (NOT ${GLOBAL_DO_NOT_USE_PRECOMPILED_HEADERS})
		if (NOT ${_DO_NOT_USE_PRECOMPILED_HEADERS})
			message(STATUS "setting precompiled headers <${PRECOMPILED_HEADERS_TARGET}> on <${_MODULE_NAME}>")
			target_precompile_headers(
				${_MODULE_NAME}
				REUSE_FROM
					${PRECOMPILED_HEADERS_TARGET}
			)
		else()
			message(STATUS "not setting precompiled headers on <${_MODULE_NAME}>")
		endif()
	endif()

	message(STATUS "end making module <${_MODULE_NAME}>")
	message(STATUS "-------------make_module end-------------")
endfunction()
