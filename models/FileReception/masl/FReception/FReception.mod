//!This domain receives audit events from the monitored system. The domain is responsible for decoding 
//!the event messages from the form in which they are received to a form that can be used within this 
//!verification model.
//!
//!Any errors in the formatting of the received audit events will be notified through the Logging 
//!required interface.
//!
//!There may be multiple versions of this domain:
//!1. To receive and decode audit events in batch file format
//!2. To receive and decode events live from the monitored system
domain FReception is
  object EventFile;
  object FileControl;
  object FileReceptionSpec;
    private service basicTest01 (
    );
pragma scenario ( 10 ); pragma test_only ( true ); 
    private service testConfigLoad (
    );
pragma scenario ( 11 ); pragma test_only ( true ); 
    private service clearDomain (
    );
pragma scenario ( 12 ); pragma test_only ( true ); 
    private service testFileCapacityManagement (
    );
pragma scenario ( 13 ); pragma test_only ( true ); 
    private service init (
    );
pragma scenario ( 1 ); 
    private service registerCommandLineArgs (
    );
pragma startup ( true ); 
  terminator Reporting is
    public service reportEvent (
        eventPriority : in Logger::Priority,        eventLabel : in string,        eventContent : in string    );
  end terminator;
  terminator Reception is
    public service AcceptEvents (
        auditEvents : in string    );
  end terminator;
  relationship R1 is FileControl conditionally hasIdentified many EventFile,
    EventFile unconditionally wasIdentifiedBy one FileControl;
  object EventFile is
    fileName : preferred  string;
//!Used to indicate if a file idenytifed in the incoming directory has been assigned
    timeProcessed :   timestamp;
    fileControlId :   referential ( R1.wasIdentifiedBy.FileControl.fileControlId ) integer;
    identifier is ( fileName );
  end object;
  object FileControl is
    fileControlId : preferred unique integer;
//!A timer that is used to trigger a check processing capacity or a check for a file to process.
    fileControlTimer :   timer;
    schemaValidationCount :   integer;
     state Created();
     state WaitingForFile();
     state ProcessingFile(        eventFile : in instance of EventFile);
     state WaitingForCapacity();
     event checkForFile();
     event allocateFile(        eventFile : in instance of EventFile);
     event checkCapacity();
     transition is
      Non_Existent (
        checkForFile => Cannot_Happen,
        allocateFile => Cannot_Happen,
        checkCapacity => Cannot_Happen      ); 
      Created (
        checkForFile => WaitingForFile,
        allocateFile => Cannot_Happen,
        checkCapacity => Cannot_Happen      ); 
      WaitingForFile (
        checkForFile => WaitingForFile,
        allocateFile => ProcessingFile,
        checkCapacity => Cannot_Happen      ); 
      ProcessingFile (
        checkForFile => WaitingForFile,
        allocateFile => Cannot_Happen,
        checkCapacity => WaitingForCapacity      ); 
      WaitingForCapacity (
        checkForFile => WaitingForFile,
        allocateFile => Cannot_Happen,
        checkCapacity => WaitingForCapacity      ); 
    end transition;
  end object;
  object FileReceptionSpec is
//!An arbitary unique identifier.
    specId : preferred unique integer;
//!The directory where incoming files that need to be processed are placed.
    incomingDirectory :   string;
//!The directory that processed files should be placed.
    processedDirectory :   string;
//!A number that indicates the limit of concurrent reception jobs that can be executing, e.g. 1 = one active reception job
    concurrentReceptionLimit :   integer;
//!The  path and filename of the config file for this domain.
    configFilePath :   string;
//!This defines the frequency that the configuration file shall be checked to determine if it has been updated.
    specUpdateRate :   duration;
//!The timestamp of the config file. Used to detect if the config file has changed.
    configFileModificationTime :   timestamp;
//!This timer is used to schedule an event to check if the configuration file has been updated.
    configTimer :   timer;
    configFile :   string;
//!The amount of time that the file control shall wait before checking for a file to process or checking the capacity to process a file.
    fileControlWaitTime :   duration;
     state Created();
     state ConfigurationLoaded();
     state ConfigChecked();
     event loadConfig();
     event checkConfigUpdate();
     transition is
      Non_Existent (
        loadConfig => Cannot_Happen,
        checkConfigUpdate => Cannot_Happen      ); 
      Created (
        loadConfig => ConfigurationLoaded,
        checkConfigUpdate => Cannot_Happen      ); 
      ConfigurationLoaded (
        loadConfig => Cannot_Happen,
        checkConfigUpdate => ConfigChecked      ); 
      ConfigChecked (
        loadConfig => ConfigurationLoaded,
        checkConfigUpdate => ConfigChecked      ); 
    end transition;
  end object;
end domain;
