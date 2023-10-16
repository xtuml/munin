#include "AsyncLogger_OOA/__AsyncLogger_services.hh"
#include "AsyncLogger_OOA/__AsyncLogger_types.hh"
#include "Logger_OOA/__Logger_types.hh"
#include "logging/Logging.hh"
#include "swa/String.hh"

namespace masld_AsyncLogger
{
  const bool localServiceRegistration_masls_log = interceptor_masls_log::instance().registerLocal( &masls_log );
  const bool localServiceRegistration_masls_overload1_log = interceptor_masls_overload1_log::instance().registerLocal( &masls_overload1_log );
  const bool localServiceRegistration_masls_trace = interceptor_masls_trace::instance().registerLocal( &masls_trace );
  const bool localServiceRegistration_masls_overload1_trace = interceptor_masls_overload1_trace::instance().registerLocal( &masls_overload1_trace );
  const bool localServiceRegistration_masls_debug = interceptor_masls_debug::instance().registerLocal( &masls_debug );
  const bool localServiceRegistration_masls_overload1_debug = interceptor_masls_overload1_debug::instance().registerLocal( &masls_overload1_debug );
  const bool localServiceRegistration_masls_information = interceptor_masls_information::instance().registerLocal( &masls_information );
  const bool localServiceRegistration_masls_overload1_information = interceptor_masls_overload1_information::instance().registerLocal( &masls_overload1_information );
  const bool localServiceRegistration_masls_notice = interceptor_masls_notice::instance().registerLocal( &masls_notice );
  const bool localServiceRegistration_masls_overload1_notice = interceptor_masls_overload1_notice::instance().registerLocal( &masls_overload1_notice );
  const bool localServiceRegistration_masls_warning = interceptor_masls_warning::instance().registerLocal( &masls_warning );
  const bool localServiceRegistration_masls_overload1_warning = interceptor_masls_overload1_warning::instance().registerLocal( &masls_overload1_warning );
  const bool localServiceRegistration_masls_error = interceptor_masls_error::instance().registerLocal( &masls_error );
  const bool localServiceRegistration_masls_overload1_error = interceptor_masls_overload1_error::instance().registerLocal( &masls_overload1_error );
  const bool localServiceRegistration_masls_critical = interceptor_masls_critical::instance().registerLocal( &masls_critical );
  const bool localServiceRegistration_masls_overload1_critical = interceptor_masls_overload1_critical::instance().registerLocal( &masls_overload1_critical );
  const bool localServiceRegistration_masls_fatal = interceptor_masls_fatal::instance().registerLocal( &masls_fatal );
  const bool localServiceRegistration_masls_overload1_fatal = interceptor_masls_overload1_fatal::instance().registerLocal( &masls_overload1_fatal );
  const bool localServiceRegistration_masls_setLogLevel = interceptor_masls_setLogLevel::instance().registerLocal( &masls_setLogLevel );
  const bool localServiceRegistration_masls_overload1_setLogLevel = interceptor_masls_overload1_setLogLevel::instance().registerLocal( &masls_overload1_setLogLevel );
  const bool localServiceRegistration_masls_printLoggers = interceptor_masls_printLoggers::instance().registerLocal( &masls_printLoggers );

  void masls_log ( const ::masld_Logger::maslt_Priority& maslp_priority,
                   const ::SWA::String&  maslp_message )
  {
    switch ( maslp_priority.getIndex() )
    {
      case ::masld_Logger::maslt_Priority::index_masle_Trace      : masls_trace      (maslp_message); break;
      case ::masld_Logger::maslt_Priority::index_masle_Debug      : masls_debug      (maslp_message); break;
      case ::masld_Logger::maslt_Priority::index_masle_Information: masls_information(maslp_message); break;
      case ::masld_Logger::maslt_Priority::index_masle_Notice     : masls_notice     (maslp_message); break;
      case ::masld_Logger::maslt_Priority::index_masle_Warning    : masls_warning    (maslp_message); break;
      case ::masld_Logger::maslt_Priority::index_masle_Error      : masls_error      (maslp_message); break;
      case ::masld_Logger::maslt_Priority::index_masle_Critical   : masls_critical   (maslp_message); break;
      case ::masld_Logger::maslt_Priority::index_masle_Fatal      : masls_fatal      (maslp_message); break;
    }
  }

  void masls_overload1_log ( const ::masld_Logger::maslt_Priority& maslp_priority,
                             const ::SWA::String&  maslp_logger,
                             const ::SWA::String&  maslp_message )
  {
    switch ( maslp_priority.getIndex() )
    {
      case ::masld_Logger::maslt_Priority::index_masle_Trace      : masls_overload1_trace      (maslp_logger,maslp_message); break;
      case ::masld_Logger::maslt_Priority::index_masle_Debug      : masls_overload1_debug      (maslp_logger,maslp_message); break;
      case ::masld_Logger::maslt_Priority::index_masle_Information: masls_overload1_information(maslp_logger,maslp_message); break;
      case ::masld_Logger::maslt_Priority::index_masle_Notice     : masls_overload1_notice     (maslp_logger,maslp_message); break;
      case ::masld_Logger::maslt_Priority::index_masle_Warning    : masls_overload1_warning    (maslp_logger,maslp_message); break;
      case ::masld_Logger::maslt_Priority::index_masle_Error      : masls_overload1_error      (maslp_logger,maslp_message); break;
      case ::masld_Logger::maslt_Priority::index_masle_Critical   : masls_overload1_critical   (maslp_logger,maslp_message); break;
      case ::masld_Logger::maslt_Priority::index_masle_Fatal      : masls_overload1_fatal      (maslp_logger,maslp_message); break;
    }
  }


  void masls_trace ( const ::SWA::String& maslp_message )
  {
    Logging::trace ( maslp_message.s_str() );
  }


  void masls_overload1_trace ( const ::SWA::String& maslp_logger,
                               const ::SWA::String& maslp_message )
  {
    Logging::trace ( maslp_logger.s_str(), maslp_message.s_str() );
  }

  void masls_debug ( const ::SWA::String& maslp_message )
  {
    Logging::debug ( maslp_message.s_str() );
  }


  void masls_overload1_debug ( const ::SWA::String& maslp_logger,
                               const ::SWA::String& maslp_message )
  {
    Logging::debug ( maslp_logger.s_str(), maslp_message.s_str() );
  }


  void masls_information ( const ::SWA::String& maslp_message )
  {
    Logging::information ( maslp_message.s_str() );
  }

  void masls_overload1_information ( const ::SWA::String& maslp_logger,
                                     const ::SWA::String& maslp_message )
  {
    Logging::information ( maslp_logger.s_str(), maslp_message.s_str() );
  }

  void masls_notice ( const ::SWA::String& maslp_message )
  {
    Logging::notice ( maslp_message.s_str() );
  }

  void masls_overload1_notice ( const ::SWA::String& maslp_logger,
                                const ::SWA::String& maslp_message )
  {
    Logging::notice ( maslp_logger.s_str(), maslp_message.s_str() );
  }

  void masls_warning ( const ::SWA::String& maslp_message )
  {
    Logging::warning ( maslp_message.s_str() );
  }

  void masls_overload1_warning ( const ::SWA::String& maslp_logger,
                                 const ::SWA::String& maslp_message )
  {
    Logging::warning ( maslp_logger.s_str(), maslp_message.s_str() );
  }

  void masls_error ( const ::SWA::String& maslp_message )
  {
    Logging::error ( maslp_message.s_str() );
  }

  void masls_overload1_error ( const ::SWA::String& maslp_logger,
                               const ::SWA::String& maslp_message )
  {
    Logging::error ( maslp_logger.s_str(), maslp_message.s_str() );
  }


  void masls_critical ( const ::SWA::String& maslp_message )
  {
    Logging::critical ( maslp_message.s_str() );
  }


  void masls_overload1_critical ( const ::SWA::String& maslp_logger,
                                  const ::SWA::String& maslp_message )
  {
    Logging::critical ( maslp_logger.s_str(), maslp_message.s_str() );
  }


  void masls_fatal ( const ::SWA::String& maslp_message )
  {
    Logging::fatal ( maslp_message.s_str() );
  }


  void masls_overload1_fatal ( const ::SWA::String& maslp_logger,
                               const ::SWA::String& maslp_message )
  {
    Logging::fatal ( maslp_logger.s_str(), maslp_message.s_str() );
  }

  void masls_setLogLevel ( const ::masld_Logger::maslt_Priority& maslp_priority )
  {
    switch ( maslp_priority.getIndex() )
    {
      case ::masld_Logger::maslt_Priority::index_masle_Trace      : Logging::Logger::getInstance().setLogLevel(Logging::Logger::Trace      ); break;
      case ::masld_Logger::maslt_Priority::index_masle_Debug      : Logging::Logger::getInstance().setLogLevel(Logging::Logger::Debug      ); break;
      case ::masld_Logger::maslt_Priority::index_masle_Information: Logging::Logger::getInstance().setLogLevel(Logging::Logger::Information); break;
      case ::masld_Logger::maslt_Priority::index_masle_Notice     : Logging::Logger::getInstance().setLogLevel(Logging::Logger::Notice     ); break;
      case ::masld_Logger::maslt_Priority::index_masle_Warning    : Logging::Logger::getInstance().setLogLevel(Logging::Logger::Warning    ); break;
      case ::masld_Logger::maslt_Priority::index_masle_Error      : Logging::Logger::getInstance().setLogLevel(Logging::Logger::Error      ); break;
      case ::masld_Logger::maslt_Priority::index_masle_Critical   : Logging::Logger::getInstance().setLogLevel(Logging::Logger::Critical   ); break;
      case ::masld_Logger::maslt_Priority::index_masle_Fatal      : Logging::Logger::getInstance().setLogLevel(Logging::Logger::Fatal      ); break;
    }
  }


  void masls_overload1_setLogLevel ( const ::SWA::String&  maslp_logger,
                                     const ::masld_Logger::maslt_Priority& maslp_priority )
  {
    switch ( maslp_priority.getIndex() )
    {
      case ::masld_Logger::maslt_Priority::index_masle_Trace      : Logging::Logger::getInstance().setLogLevel(maslp_logger.s_str(),Logging::Logger::Trace      ); break;
      case ::masld_Logger::maslt_Priority::index_masle_Debug      : Logging::Logger::getInstance().setLogLevel(maslp_logger.s_str(),Logging::Logger::Debug      ); break;
      case ::masld_Logger::maslt_Priority::index_masle_Information: Logging::Logger::getInstance().setLogLevel(maslp_logger.s_str(),Logging::Logger::Information); break;
      case ::masld_Logger::maslt_Priority::index_masle_Notice     : Logging::Logger::getInstance().setLogLevel(maslp_logger.s_str(),Logging::Logger::Notice     ); break;
      case ::masld_Logger::maslt_Priority::index_masle_Warning    : Logging::Logger::getInstance().setLogLevel(maslp_logger.s_str(),Logging::Logger::Warning    ); break;
      case ::masld_Logger::maslt_Priority::index_masle_Error      : Logging::Logger::getInstance().setLogLevel(maslp_logger.s_str(),Logging::Logger::Error      ); break;
      case ::masld_Logger::maslt_Priority::index_masle_Critical   : Logging::Logger::getInstance().setLogLevel(maslp_logger.s_str(),Logging::Logger::Critical   ); break;
      case ::masld_Logger::maslt_Priority::index_masle_Fatal      : Logging::Logger::getInstance().setLogLevel(maslp_logger.s_str(),Logging::Logger::Fatal      ); break;
    }
  }


  void masls_printLoggers ( )
  {
    Logging::Logger::getInstance().printLoggers();
  }

}
