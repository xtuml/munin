domain JobManagement is
  
  object AuditEvent;
  object Job;
  object EmployedWorker;
  object JobWorker;
  object JobManager;
  object JobManagementSpec;
  object JobStore;
  object RetiredWorker;
  object StoredJobIdentifier;
  object UanssignedJob;
  object AssignedJob;
  
  private type AssignedJobState is enum ( InProgress, Failed, Complete );   
  
  private service testConfigFile (); pragma scenario( 100 ); pragma test_only( true );   
  private service testRegisterWorker (); pragma test_only( true ); pragma scenario( 101 );   
  private service init (); pragma scenario( 1 ); pragma process_listener( "postschedules" );   
  private service registerCommandLineArgs (); pragma process_listener( "initialised" );   
  private service registerWorker ( workerId: in UUID::formatted_uuid );   
  private service workerHeartbeat ( workerId: in UUID::formatted_uuid,
                                    jobList: in sequence of string );   
  public service acceptEvent ( auditEvent: in string );   
  private service jobCompleted ();   
  private service deregisterWorker ( workerId: in UUID::formatted_uuid );   
  
  
  terminator Reporting is
    public service reportEvent ( eventPriority: in Logger::Priority,
                                 eventLabel: in string,
                                 eventContent: in string );     
  end terminator;
  
  terminator Worker is
    public service workerRegistered ( workerId: in UUID::formatted_uuid );     
  end terminator;
  
  
  
  relationship R1 is JobManager conditionally assignsJobsTo many JobWorker,
                     JobWorker unconditionally isAssignedJobsBy one JobManager;   
  
  relationship R2 is JobWorker is_a ( EmployedWorker, RetiredWorker );   
  
  relationship R3 is JobWorker conditionally employedAfter one JobWorker,
                     JobWorker conditionally employedBefore one JobWorker;   
  
  relationship R4 is JobManager conditionally lastJobAssignedTo one JobWorker,
                     JobWorker conditionally wasLastAssignedBy one JobManager;   
  
  relationship R5 is Job is_a ( UanssignedJob, AssignedJob );   
  
  relationship R6 is EmployedWorker unconditionally isProcessing many AssignedJob,
                     AssignedJob unconditionally isBeingProcessedBy one EmployedWorker;   
  
  relationship R7 is Job unconditionally hasReported many AuditEvent,
                     AuditEvent unconditionally wasReportedBy one Job;   
  
  relationship R8 is Job conditionally previous one Job,
                     Job conditionally next one Job;   
  
  relationship R20 is JobStore unconditionally hasRecorded many StoredJobIdentifier,
                      StoredJobIdentifier unconditionally isRecordedIn one JobStore;   
  
  
  
  object AuditEvent is
    
    auditEventId: preferred unique integer;     
    jobId: referential ( R7.wasReportedBy.Job.jobId ) string;     
    auditEvent: string;     
    
  end object;
  
  object Job is
    
    //!This is the jobId as reported by a received audit event. This shal be unique across the monitored system.
    jobId: preferred string;     
    previousjobId: referential ( R8.next.Job.jobId ) string;     
    jobName: string;     
    
  end object;
  
  object JobWorker is
    
    workerId: preferred UUID::formatted_uuid;     
    previousworkerId: referential ( R3.employedBefore.JobWorker.workerId ) UUID::formatted_uuid;     
    jobManager: referential ( R4.wasLastAssignedBy.JobManager.jobManager, R1.isAssignedJobsBy.JobManager.jobManager ) integer;     
    employmentDate: timestamp;     
    
    public service createWorker ( workerId: in UUID::formatted_uuid );     
    public instance service employWorker ();     
    public instance service retireWorker ();     
    
  end object;
  
  object JobManager is
    
    jobManager: preferred unique integer;     
    
    public instance service assignJob ();     
    
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
  
  object StoredJobIdentifier is
    
    jobId: preferred string;     
    jobStoreId: referential ( R20.isRecordedIn.JobStore.jobStoreId ) integer;     
    jobTime: timestamp;     
    
  end object;
  
  object EmployedWorker is
    
    workerId: preferred referential ( R2.workerId ) UUID::formatted_uuid;     
    absenceTimer: timer;     
    
    state Created ();     
    state Registered ();     
    state Deregistered ();     
    state Absent ();     
    state AvailableForWork ();     
    
    event workerRegistered ();     
    event workerPresenceUnknown ();     
    event workerDregistered ();     
    event workerPresent ();     
    
    transition is
      Non_Existent ( workerRegistered => Cannot_Happen,
                     workerPresenceUnknown => Cannot_Happen,
                     workerDregistered => Cannot_Happen,
                     workerPresent => Cannot_Happen );       
      Created ( workerRegistered => Registered,
                workerPresenceUnknown => Cannot_Happen,
                workerDregistered => Cannot_Happen,
                workerPresent => Cannot_Happen );       
      Registered ( workerRegistered => Cannot_Happen,
                   workerPresenceUnknown => Cannot_Happen,
                   workerDregistered => Cannot_Happen,
                   workerPresent => AvailableForWork );       
      Deregistered ( workerRegistered => Cannot_Happen,
                     workerPresenceUnknown => Cannot_Happen,
                     workerDregistered => Cannot_Happen,
                     workerPresent => Cannot_Happen );       
      Absent ( workerRegistered => Cannot_Happen,
               workerPresenceUnknown => Absent,
               workerDregistered => Deregistered,
               workerPresent => AvailableForWork );       
      AvailableForWork ( workerRegistered => Cannot_Happen,
                         workerPresenceUnknown => Absent,
                         workerDregistered => Deregistered,
                         workerPresent => Cannot_Happen );       
    end transition;
    
  end object;
  
  object RetiredWorker is
    
    workerId: preferred referential ( R2.workerId ) UUID::formatted_uuid;     
    retirementDate: timestamp;     
    
    public instance service deleteRetiredWorker ();     
    
  end object;
  
  object UanssignedJob is
    
    jobId: preferred referential ( R5.jobId ) string;     
    
  end object;
  
  object AssignedJob is
    
    jobId: preferred referential ( R5.jobId ) string;     
    workerId: referential ( R6.isBeingProcessedBy.EmployedWorker.workerId ) UUID::formatted_uuid;     
    
  end object;
  
  
end domain;
