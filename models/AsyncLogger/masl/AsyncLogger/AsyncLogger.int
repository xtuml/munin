domain AsyncLogger is

  public service log         ( priority : in Logger::Priority, logger : in anonymous string,  message : in anonymous string ); pragma kafka_topic();

  public service trace       ( logger : in anonymous string, message : in anonymous string ); pragma kafka_topic();
  public service debug       ( logger : in anonymous string, message : in anonymous string ); pragma kafka_topic();
  public service information ( logger : in anonymous string, message : in anonymous string ); pragma kafka_topic();
  public service warning     ( logger : in anonymous string, message : in anonymous string ); pragma kafka_topic();
  public service error       ( logger : in anonymous string, message : in anonymous string ); pragma kafka_topic();
  public service fatal       ( logger : in anonymous string, message : in anonymous string ); pragma kafka_topic();

  public service setLogLevel( logger : in anonymous string, priority : in Logger::Priority ); pragma kafka_topic();

  public service enabled            ( priority : in Logger::Priority, logger : in anonymous string ) return boolean; pragma kafka_topic();
  public service traceEnabled       ( logger : in anonymous string ) return boolean; pragma kafka_topic();
  public service debugEnabled       ( logger : in anonymous string ) return boolean; pragma kafka_topic();
  public service informationEnabled ( logger : in anonymous string ) return boolean; pragma kafka_topic();
  public service warningEnabled     ( logger : in anonymous string ) return boolean; pragma kafka_topic();
  public service errorEnabled       ( logger : in anonymous string ) return boolean; pragma kafka_topic();
  public service fatalEnabled       ( logger : in anonymous string ) return boolean; pragma kafka_topic();

end domain;
