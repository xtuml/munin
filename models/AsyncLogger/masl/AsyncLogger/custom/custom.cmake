target_sources( AsyncLogger PRIVATE ${CMAKE_CURRENT_LIST_DIR}/AsyncLogger_services.cc )
if ( NOT Logger_FOUND )
find_package ( Logger CONFIG QUIET )
endif()
target_link_libraries( AsyncLogger PRIVATE Logger::Logger )
