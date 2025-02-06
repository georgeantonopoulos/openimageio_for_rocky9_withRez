#----------------------------------------------------------------
# Generated CMake target import file for configuration "Release".
#----------------------------------------------------------------

# Commands may need to know the format version.
set(CMAKE_IMPORT_FILE_VERSION 1)

# Import target "OpenColorIO::OpenColorIO" for configuration "Release"
set_property(TARGET OpenColorIO::OpenColorIO APPEND PROPERTY IMPORTED_CONFIGURATIONS RELEASE)
set_target_properties(OpenColorIO::OpenColorIO PROPERTIES
  IMPORTED_LINK_DEPENDENT_LIBRARIES_RELEASE "expat::expat;Imath::Imath;yaml-cpp"
  IMPORTED_LOCATION_RELEASE "${_IMPORT_PREFIX}/lib64/libOpenColorIO.so.2.3.1"
  IMPORTED_SONAME_RELEASE "libOpenColorIO.so.2.3"
  )

list(APPEND _cmake_import_check_targets OpenColorIO::OpenColorIO )
list(APPEND _cmake_import_check_files_for_OpenColorIO::OpenColorIO "${_IMPORT_PREFIX}/lib64/libOpenColorIO.so.2.3.1" )

# Commands beyond this point should not need to know the version.
set(CMAKE_IMPORT_FILE_VERSION)
