cmake_minimum_required(VERSION 3.5)

project(AEOrdering VERSION 1.0)

set(CMAKE_CXX_STANDARD 11)

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

add_library(rdkafka SHARED IMPORTED)
set_property(TARGET rdkafka PROPERTY IMPORTED_LOCATION "/opt/rdkafka/lib/librdkafka.so")
include_directories("/opt/rdkafka/include")
add_library(cppkafka SHARED IMPORTED)
set_property(TARGET cppkafka PROPERTY IMPORTED_LOCATION "/opt/cppkafka/lib/libcppkafka.so")
include_directories("/opt/cppkafka/include")

add_custom_target (masl-core)
set_property (TARGET masl-core PROPERTY MAIN_JAR /opt/masl/lib/masl-core.jar)

if (CMAKE_BUILD_TYPE STREQUAL "Debug")
  list(APPEND EXTRA_MASL_ARGS -test)
endif ()

add_masl_domain(masl/${PROJECT_NAME}/${PROJECT_NAME}.mod
  EXTRA_ARGS ${EXTRA_MASL_ARGS} EXTRA_DOMAIN_PATHS /opt/masl/lib/masl
  JVM_ARGS
  -DorderingConfigSchema="${CMAKE_INSTALL_PREFIX}/share/json/ordering_config_schema.json"
  -DjobDefinitionSchema="${CMAKE_INSTALL_PREFIX}/share/json/job_definition_schema.json"
)
generate_masl()

install(
  FILES
  schema/ordering_config_schema.json
  schema/job_definition_schema.json
  DESTINATION share/json
)
