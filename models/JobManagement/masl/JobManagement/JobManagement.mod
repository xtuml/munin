domain JobManagement is
  
  object UnassignedJob;
  object AuditEvent;
  object JobManager;
  object JobWorker;
  object EmployedWorker;
  object AssignedJob;
  object JobStore;
  object RetiredWorker;
  object Job;
  object StoredJobIdentifier;
  object JobManagementSpec;
  
  private type AssignedJobState is enum ( InProgress, Failed, Complete );   
  
  private service registerWorker ( workerId: in UUID::formatted_uuid ); pragma kafka_topic( true );   
  private service workerHeartbeat ( workerId: in UUID::formatted_uuid ); pragma kafka_topic( true );   
  public service acceptEvent ( auditEvent: in string ); pragma kafka_topic( true );   
  private service jobCompleted ( workerId: in UUID::formatted_uuid,
                                 jobId: in string ); pragma kafka_topic( true );   
  private service deregisterWorker ( workerId: in UUID::formatted_uuid ); pragma kafka_topic( true );   
  private service init (); pragma scenario( 1 ); pragma process_listener( "postschedules" );   
  private service registerCommandLineArgs (); pragma process_listener( "initialised" );   
  private service testConfigFile (); pragma scenario( 101 ); pragma test_only( true );   
  private service testRegisterWorker (); pragma test_only( true ); pragma scenario( 102 );   
  private service testWorkerHeartbeat (); pragma scenario( 103 ); pragma test_only( true );   
  private service testAssignWork (); pragma scenario( 104 ); pragma test_only( true );   
  private service clearDomain (); pragma test_only( true );   
  private service sendAuditEvent ( jobId: out string,
                                   reportedAuditEventString: out string ); pragma test_only( true );   
  private service checkJobEventAssignment ( jobName: in string,
                                            jobId: in string,
                                            reportedAuditEventString: in string,
                                            workerId: in UUID::formatted_uuid ); pragma test_only( true );   
  private service testJobCompleted (); pragma test_only( true ); pragma scenario( 105 );   
  private service testDeregisterWorker (); pragma scenario( 106 ); pragma test_only( true );   
  private service testAssignJobQueue (); pragma scenario( 107 ); pragma test_only( true );   
  
  
  terminator Reporting is
    public service reportEvent ( eventPriority: in Logger::Priority,
                                 eventLabel: in string,
                                 eventContent: in string );     
  end terminator;
  
  terminator Worker is
    public service workerRegistered ( workerId: in UUID::formatted_uuid );     
    public service workerUnregistered ( workerId: in UUID::formatted_uuid );     
    public service reportEvent ( workerId: in UUID::formatted_uuid,
                                 auditEvent: in string );     
    public service jobCompletionConfirmed ( workerId: in UUID::formatted_uuid,
                                            jobId: in string );     
  end terminator;
  
  
  
  relationship R1 is JobManager conditionally assignsJobsTo many JobWorker,
                     JobWorker unconditionally isAssignedJobsBy one JobManager;   
  
  relationship R2 is JobWorker is_a ( EmployedWorker, RetiredWorker );   
  
  relationship R3 is JobWorker conditionally employedBefore one JobWorker,
                     JobWorker conditionally employedAfter one JobWorker;   
  
  relationship R4 is JobManager conditionally nextAvailable one JobWorker,
                     JobWorker conditionally availableNext one JobManager;   
  
  relationship R5 is Job is_a ( UnassignedJob, AssignedJob );   
  
  relationship R6 is EmployedWorker unconditionally isProcessing many AssignedJob,
                     AssignedJob unconditionally isBeingProcessedBy one EmployedWorker;   
  
  relationship R7 is Job unconditionally hasReported many AuditEvent,
                     AuditEvent unconditionally wasReportedBy one Job;   
  
  relationship R20 is JobStore unconditionally hasRecorded many StoredJobIdentifier,
                      StoredJobIdentifier unconditionally isRecordedIn one JobStore;   
  
  relationship R21 is JobManager unconditionally wasLastEmployed one JobWorker,
                      JobWorker conditionally employedLast one JobManager;   
  
  relationship R22 is JobManager conditionally wasFirstEmployed one JobWorker,
                      JobWorker unconditionally employedFirst one JobManager;   
  
  
  
  object AuditEvent is
    
    auditEventId: preferred unique integer;     
    jobId: referential ( R7.wasReportedBy.Job.jobId ) string;     
    auditEvent: string;     
    
    public instance service reportAuditEvent ( assignedWorker: in instance of EmployedWorker );     
    
  end object;
  
  object JobManager is
    
    jobManager: preferred unique integer;     
    unassignedJobIds: sequence of string;     
    
    public instance service assignJob ( employedWorker: in instance of EmployedWorker );     
    public instance service selectWorkerForJob () return instance of EmployedWorker;     
    
  end object;
  
  object JobWorker is
    
    workerId: preferred UUID::formatted_uuid;     
    employmentDate: timestamp;     
    jobManager: referential ( R21.employedLast.JobManager.jobManager, R22.employedFirst.JobManager.jobManager, R4.availableNext.JobManager.jobManager, R1.isAssignedJobsBy.JobManager.jobManager ) integer;     
    previousworkerId: referential ( R3.employedAfter.JobWorker.workerId ) UUID::formatted_uuid;     
    
    public service createWorker ( workerId: in UUID::formatted_uuid );     
    public instance service employWorker ();     
    public instance service retireWorker ();     
    
  end object;
  
  object JobStore is
    
    jobStoreId: preferred unique integer;     
    jobStoreAgeLimit: duration;     
    
    public service addJobToStore ( jobId: in string );     
    
    state Created ();     
    state JobStoreUpdated ();     
    
    event purgeJobStore ();     
    
    transition is
      Non_Existent ( purgeJobStore => Cannot_Happen );       
      Created ( purgeJobStore => JobStoreUpdated );       
      JobStoreUpdated ( purgeJobStore => JobStoreUpdated );       
    end transition;
    
  end object;
  
  object Job is
    
    //!This is the jobId as reported by a received audit event. This shal be unique across the monitored system.
    jobId: preferred string;     
    
  end object;
  
  object StoredJobIdentifier is
    
    jobId: preferred string;     
    jobStoreId: referential ( R20.isRecordedIn.JobStore.jobStoreId ) integer;     
    jobTime: timestamp;     
    
  end object;
  
  object JobManagementSpec is
    
    jmSpecId: preferred unique integer;     
    //!This is the maximum number of in progress jobs any one worker can be assigned.
    maxJobsPerWorker: integer;     
    //!This is the maximum nimber of unassigned jobs. If reached an error shall be reported.
    maxUnassignedJobs: integer;     
    //!This is the time that a retired worker shall be retained. Once reached the worker shall be deleted.
    retiredWorkerDeletionTime: duration;     
    //!This is the frequency that the config spec shall be checked for updates.
    specUpdateRate: duration;     
    configTimer: timer;     
    configFile: string;     
    configFilePath: string;     
    configFileModificationTime: timestamp;     
    workerHeartbeatRate: duration;     
    workerHeartbeatFailureThreshold: integer;     
    
    public instance service loadConfigFile ();     
    public instance service checkUpdatedConfig () return boolean;     
    public instance service lastModificationTime () return timestamp;     
    
    state Created ();     
    state ConfigChecked ();     
    
    event checkConfigUpdate ();     
    
    transition is
      Non_Existent ( checkConfigUpdate => Cannot_Happen );       
      Created ( checkConfigUpdate => ConfigChecked );       
      ConfigChecked ( checkConfigUpdate => ConfigChecked );       
    end transition;
    
  end object;
  
  object UnassignedJob is
    
    jobId: preferred referential ( R5.jobId ) string;     
    
  end object;
  
  object EmployedWorker is
    
    workerId: preferred referential ( R2.workerId ) UUID::formatted_uuid;     
    absenceTimer: timer;     
    failedHeartbeatCount: integer;     
    
    state Created ();     
    state Registered ();     
    state Deregistered ();     
    state Absent ();     
    state AvailableForWork ();     
    
    event workerRegistered ();     
    event workerPresenceUnknown ();     
    event workerDeregistered ();     
    event workerPresent ();     
    
    transition is
      Non_Existent ( workerRegistered => Cannot_Happen,
                     workerPresenceUnknown => Cannot_Happen,
                     workerDeregistered => Cannot_Happen,
                     workerPresent => Cannot_Happen );       
      Created ( workerRegistered => Registered,
                workerPresenceUnknown => Cannot_Happen,
                workerDeregistered => Cannot_Happen,
                workerPresent => Cannot_Happen );       
      Registered ( workerRegistered => Cannot_Happen,
                   workerPresenceUnknown => Absent,
                   workerDeregistered => Deregistered,
                   workerPresent => AvailableForWork );       
      Deregistered ( workerRegistered => Cannot_Happen,
                     workerPresenceUnknown => Cannot_Happen,
                     workerDeregistered => Cannot_Happen,
                     workerPresent => Cannot_Happen );       
      Absent ( workerRegistered => Cannot_Happen,
               workerPresenceUnknown => Absent,
               workerDeregistered => Deregistered,
               workerPresent => AvailableForWork );       
      AvailableForWork ( workerRegistered => Cannot_Happen,
                         workerPresenceUnknown => Absent,
                         workerDeregistered => Deregistered,
                         workerPresent => AvailableForWork );       
    end transition;
    
  end object;
  
  object AssignedJob is
    
    jobId: preferred referential ( R5.jobId ) string;     
    workerId: referential ( R6.isBeingProcessedBy.EmployedWorker.workerId ) UUID::formatted_uuid;     
    
  end object;
  
  object RetiredWorker is
    
    workerId: preferred referential ( R2.workerId ) UUID::formatted_uuid;     
    retirementDate: timestamp;     
    
    public instance service deleteRetiredWorker ();     
    
  end object;
  
  
end domain;
