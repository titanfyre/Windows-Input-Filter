cmake_minimum_required(VERSION 3.24)
project(WindowsInputFilterSDK VERSION 0.1.0.0 LANGUAGES C CXX)
if(NOT WIN32 OR NOT CMAKE_SIZEOF_VOID_P EQUAL 8)
  message(FATAL_ERROR "This SDK requires Windows x64. No driver is installed by this build.")
endif()
include(GNUInstallDirs)
include(CMakePackageConfigHelpers)
add_library(TitanWindowsInputFilter STATIC
  "sdk/InputFilter/InputFilter.cpp"
)
add_library(WindowsInputFilterSDK::sdk ALIAS TitanWindowsInputFilter)
set_target_properties(TitanWindowsInputFilter PROPERTIES EXPORT_NAME sdk)
target_compile_features(TitanWindowsInputFilter PUBLIC cxx_std_17)
target_compile_definitions(TitanWindowsInputFilter PUBLIC )
target_compile_definitions(TitanWindowsInputFilter PRIVATE UNICODE _UNICODE NOMINMAX WIN32_LEAN_AND_MEAN _WIN32_WINNT=0x0A00)
if(MSVC)
  target_compile_options(TitanWindowsInputFilter PRIVATE /utf-8 /EHsc /W4)
endif()
target_include_directories(TitanWindowsInputFilter PUBLIC
  "$<BUILD_INTERFACE:${CMAKE_CURRENT_SOURCE_DIR}/sdk>"
  "$<INSTALL_INTERFACE:include/>"
  "$<BUILD_INTERFACE:${CMAKE_CURRENT_SOURCE_DIR}/sdk/InputFilter>"
  "$<INSTALL_INTERFACE:include/InputFilter>"
)
target_link_libraries(TitanWindowsInputFilter PUBLIC advapi32 bcrypt cfgmgr32 comctl32 hid newdev ole32 setupapi user32)
install(TARGETS TitanWindowsInputFilter EXPORT WindowsInputFilterSDKTargets ARCHIVE DESTINATION ${CMAKE_INSTALL_LIBDIR})
install(DIRECTORY sdk/ DESTINATION include FILES_MATCHING PATTERN "*.h" PATTERN "*.hpp" PATTERN "*.inl")
install(FILES LICENSE DESTINATION share/windows-input-filter)
install(EXPORT WindowsInputFilterSDKTargets NAMESPACE WindowsInputFilterSDK:: DESTINATION ${CMAKE_INSTALL_LIBDIR}/cmake/WindowsInputFilterSDK)
configure_file("WindowsInputFilterSDKConfig.cmake.in" "${CMAKE_CURRENT_BINARY_DIR}/WindowsInputFilterSDKConfig.cmake" @ONLY)
write_basic_package_version_file("${CMAKE_CURRENT_BINARY_DIR}/WindowsInputFilterSDKConfigVersion.cmake" VERSION 0.1.0.0 COMPATIBILITY SameMajorVersion)
install(FILES "${CMAKE_CURRENT_BINARY_DIR}/WindowsInputFilterSDKConfig.cmake" "${CMAKE_CURRENT_BINARY_DIR}/WindowsInputFilterSDKConfigVersion.cmake" DESTINATION ${CMAKE_INSTALL_LIBDIR}/cmake/WindowsInputFilterSDK)
