cmake_minimum_required(VERSION 3.5)

project(AEO_SVDC VERSION 1.0)

set(CMAKE_PREFIX_PATH ${CMAKE_PREFIX_PATH} /opt/masl)
set(CMAKE_PREFIX_PATH ${CMAKE_PREFIX_PATH} /opt/poco)

set(CMAKE_MODULE_PATH ${CMAKE_MODULE_PATH} /opt/masl/lib/cmake/MaslCore)
set(CMAKE_MODULE_PATH ${CMAKE_MODULE_PATH} /opt/masl/lib/cmake/UtilityDomains)
set(CMAKE_MODULE_PATH ${CMAKE_MODULE_PATH} /opt/poco/lib/cmake/Poco)

set(INSTALL_LIB_DIR lib CACHE PATH "Installation directory for libraries")
set(INSTALL_BIN_DIR bin CACHE PATH "Installation directory for executables")
set(INSTALL_INCLUDE_DIR include CACHE PATH "Installation directory for header files")

include(MaslCoreConfig)
include(UtilityDomainsConfig)
include(SimpleAdd)
include(Masl)

find_package(Poco REQUIRED COMPONENTS XML Foundation)
find_package(Sqlite3 REQUIRED)
find_package(Boost REQUIRED QUIET COMPONENTS system regex)
link_libraries(Boost::boost Boost::regex)

include_directories("/install/include")
link_directories("/install/lib")

add_custom_target (masl-core)
set_property (TARGET masl-core PROPERTY MAIN_JAR /opt/masl/lib/masl-core.jar)

add_masl_project(masl/${PROJECT_NAME}/${PROJECT_NAME}.prj EXTRA_ARGS ${EXTRA_MASL_ARGS} EXTRA_DOMAIN_PATHS /install/lib/masl /opt/masl/lib/masl)
generate_masl()
