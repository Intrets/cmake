function(make_module)
	set(optionalArgs)
	set(oneValueArgs MODULE_NAME CXX_STANDARD)
	set(multiValueArgs MODULE_FILES REQUIRED_LIBS OPTIONAL_LIBS)
	cmake_parse_arguments("" "${optionalArgs}" "${oneValueArgs}" "${multiValueArgs}" ${ARGN})

	foreach(FILE ${_MODULE_FILES})
		list(APPEND SOURCES_LIST "${FILE}.cpp")
		list(APPEND HEADERS_LIST "include/${MODULE_NAME}/${FILE}.h")
	endforeach()

	add_library(${_MODULE_NAME} ${SOURCES_LIST} ${HEADERS_LIST})
	target_compile_features(${_MODULE_NAME} PUBLIC cxx_std_${_CXX_STANDARD})

	target_include_directories(${_MODULE_NAME} PUBLIC include)
	target_include_directories(${_MODULE_NAME} PRIVATE include/${_MODULE_NAME})

	source_group(
		TREE "${CMAKE_CURRENT_SOURCE_DIR}/include/${_MODULE_NAME}"
		PREFIX "Header Files"
		FILES ${HEADERS_LIST}
	)

	foreach(LIB ${_REQUIRED_LIBS})
		if(NOT TARGET ${LIB})
			message(SEND_ERROR "missing library ${LIB} in ${_MODULE_NAME}")
		endif()
	endforeach()

	target_link_libraries(${_MODULE_NAME} PUBLIC "${_REQUIRED_LIBS}")
	target_link_libraries(${_MODULE_NAME} PUBLIC "${_OPTIONAL_LIBS}")

endfunction()
