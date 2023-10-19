
domain AsyncLogger is

  public service log         ( priority : in Logger::Priority, message : in anonymous string ); pragma kafka_topic();
  public service log         ( priority : in Logger::Priority, logger : in anonymous string,  message : in anonymous string ); pragma kafka_topic();

  public service trace       ( message : in anonymous string ); pragma kafka_topic();
  public service debug       ( message : in anonymous string ); pragma kafka_topic();
  public service information ( message : in anonymous string ); pragma kafka_topic();
  public service notice      ( message : in anonymous string ); pragma kafka_topic();
  public service warning     ( message : in anonymous string ); pragma kafka_topic();
  public service error       ( message : in anonymous string ); pragma kafka_topic();
  public service critical    ( message : in anonymous string ); pragma kafka_topic();
  public service fatal       ( message : in anonymous string ); pragma kafka_topic();

  public service trace       ( logger : in anonymous string, message : in anonymous string ); pragma kafka_topic();
  public service debug       ( logger : in anonymous string, message : in anonymous string ); pragma kafka_topic();
  public service information ( logger : in anonymous string, message : in anonymous string ); pragma kafka_topic();
  public service notice      ( logger : in anonymous string, message : in anonymous string ); pragma kafka_topic();
  public service warning     ( logger : in anonymous string, message : in anonymous string ); pragma kafka_topic();
  public service error       ( logger : in anonymous string, message : in anonymous string ); pragma kafka_topic();
  public service critical    ( logger : in anonymous string, message : in anonymous string ); pragma kafka_topic();
  public service fatal       ( logger : in anonymous string, message : in anonymous string ); pragma kafka_topic();

  public service setLogLevel( priority : in Logger::Priority ); pragma kafka_topic();
  public service setLogLevel( logger : in anonymous string, priority : in Logger::Priority ); pragma kafka_topic();
  public service printLoggers(); pragma kafka_topic();

end domain;
