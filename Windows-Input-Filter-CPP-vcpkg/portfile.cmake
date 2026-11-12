vcpkg_download_distfile(ARCHIVE
    URLS "https://github.com/titanfyre/Windows-Input-Filter/releases/download/sdk-v0.1.0/windows-input-filter-sdk-0.1.0.tar.gz"
    FILENAME "windows-input-filter-sdk-0.1.0.tar.gz"
    SHA512 66c08276616863e8c1d4a4fbb7436beb7fe5033991dbde84b9e382cdd115f805ae381cca91f70360060034598c834b010ca1730fa3778ad2337ba7845c1566d4
)
vcpkg_extract_source_archive(SOURCE_PATH ARCHIVE "${ARCHIVE}" NO_REMOVE_ONE_LEVEL)
vcpkg_cmake_configure(SOURCE_PATH "${SOURCE_PATH}")
vcpkg_cmake_install()
vcpkg_cmake_config_fixup(PACKAGE_NAME WindowsInputFilterSDK CONFIG_PATH lib/cmake/WindowsInputFilterSDK)
file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/include" "${CURRENT_PACKAGES_DIR}/debug/share")
vcpkg_install_copyright(FILE_LIST "${SOURCE_PATH}/LICENSE")
