domain AESimulator is
  object AuditEventFile;
  object DeployedEvent;
  object EventData;
  object EventDefinition;
  object EventDispatchOrder;
  object EventFileForJob;
  object Job;
  object JobSpec;
  object TestDefinition;
  object TestJobSpec;
  object TestSpec;
    private service registerCommanLineArgs (
    );
pragma startup ( true ); 
    private service initialise (
    );
pragma scenario ( 1 ); 
  relationship R1 is EventDefinition conditionally isFollowedBy many EventDefinition,
    EventDefinition unconditionally follows one EventDefinition;
  relationship R2 is JobSpec unconditionally isFirst many EventDefinition,
    EventDefinition unconditionally isFirstFor one JobSpec;
  relationship R3 is JobSpec unconditionally wasUsedFor many Job,
    Job unconditionally exectuted one JobSpec;
  relationship R5 is EventDefinition conditionally defines many DeployedEvent,
    DeployedEvent unconditionally isDefinedBy one EventDefinition;
  relationship R6 is Job conditionally hasScheduled many DeployedEvent,
    DeployedEvent unconditionally wasScheduledFor one Job;
  relationship R7 is TestDefinition unconditionally hasExecuted many Job,
    Job unconditionally wasEexecutedBy one TestDefinition;
  relationship R8 is TestDefinition unconditionally shallRun many JobSpec,
    JobSpec unconditionally isRunBy many TestDefinition
    using TestJobSpec;
  relationship R9 is JobSpec unconditionally contains many EventDefinition,
    EventDefinition unconditionally isPartOf one JobSpec;
  relationship R10 is Job conditionally hasReported many DeployedEvent,
    DeployedEvent conditionally WasReportedFor one Job;
  relationship R12 is TestJobSpec unconditionally isFirst one EventDispatchOrder,
    EventDispatchOrder unconditionally firstFor one TestJobSpec;
  relationship R13 is EventDispatchOrder conditionally previousEvent one EventDispatchOrder,
    EventDispatchOrder conditionally nextEvent one EventDispatchOrder;
  relationship R14 is TestDefinition unconditionally dispatches many EventDefinition,
    EventDefinition unconditionally areDispatchedFor many TestDefinition
    using EventDispatchOrder;
  relationship R15 is TestJobSpec conditionally isCurrent one EventDispatchOrder,
    EventDispatchOrder conditionally currentFor one TestJobSpec;
  relationship R16 is EventDefinition conditionally canCarry many EventData,
    EventData unconditionally isCarriedIn one EventDefinition;
  relationship R17 is AuditEventFile unconditionally containsEventsFor many Job,
    Job unconditionally reportsEventTo many AuditEventFile
    using EventFileForJob;
  object AuditEventFile is
    auditEventFileId : preferred unique integer;
//!The audit events that need to be written to the audit event file.
    auditEvents :   JSON::JSONArray;
//!The current number of events that have been written to the file. Only used when one file per job is false.
    numberOfEvents :   integer;
//!A timer used to write events to the audit event file when expired. Only used when one file per job is false.
    fileTimer :   timer;
//!If set to true indictes that this is the active audit event file. Only used when one file per job is false and if in use there should only ever be one active audit event file.
    isActive :   boolean;
    fileId :   UUID::formatted_uuid;
     state Created();
     state FileGenerated();
     event generateFile();
     transition is
      Non_Existent (
        generateFile => Cannot_Happen      ); 
      Created (
        generateFile => FileGenerated      ); 
      FileGenerated (
        generateFile => Cannot_Happen      ); 
    end transition;
  end object;
//!This represents an event that has been generated and then delpoyed as part of the Job. The event is derived from the Event Definition.
  object DeployedEvent is
//!A UUID that is used to uniquely identify the event.
    eventId : preferred  UUID::formatted_uuid;
//!The time that the event was generated
    epochEventCreationTime :   integer;
//!The definition that this event was derived from
    eventDefinitionId :   referential ( R5.isDefinedBy.EventDefinition.eventDefinitionId ) string;
//!The UUID that is the previous event identifier to this event.
    prevEventId :   string;
    jobSpecName :   referential ( R5.isDefinedBy.EventDefinition.jobSpecName ) string;
//!A timer used to control when the event is dispathed. Not currently used as all events are written to file.
    dispatchTimer :   timer;
    jobId :   referential ( R6.wasScheduledFor.Job.jobId, R10.WasReportedFor.Job.jobId ) UUID::formatted_uuid;
//!A flag that indicates the event has been deployed.
    deployed :   boolean;
    epochEventDispatchTime :   integer;
    eventTime :   timestamp;
     state Created();
     state Dispatched();
     state DispatchScheduled();
     event dispatchEvent();
     event evaluateDispatch();
     transition is
      Non_Existent (
        dispatchEvent => Cannot_Happen,
        evaluateDispatch => Cannot_Happen      ); 
      Created (
        dispatchEvent => Cannot_Happen,
        evaluateDispatch => DispatchScheduled      ); 
      Dispatched (
        dispatchEvent => Cannot_Happen,
        evaluateDispatch => Cannot_Happen      ); 
      DispatchScheduled (
        dispatchEvent => Dispatched,
        evaluateDispatch => Cannot_Happen      ); 
    end transition;
  end object;
  object EventData is
    eventDataId : preferred unique integer;
    eventDataName :   string;
    eventDataValue :   string;
    eventDefinitionId :   referential ( R16.isCarriedIn.EventDefinition.eventDefinitionId ) string;
    jobSpecName :   referential ( R16.isCarriedIn.EventDefinition.jobSpecName ) string;
    eventDataType :   string;
  end object;
//!This captures the details of an event that should be generated as part of a Job Spec. This is read in from the configuration file.
  object EventDefinition is
//!The id of the event definition as specified in the configuration file. This id together with the job spec name form the unique identifier for teh instance of Event definition.
    eventDefinitionId : preferred  string;
//!This is the name of the event that is to be generated as part of the test. Event type names are should typically conform to the events that the client expects the system to process. The exception to this is when the test is to pass in invalid events.
    eventTypeName :   string;
//!This is the name of the application that generated the event.
    applicationName :   string;
//!This is the name of the node in the system where the application which generated the event is deployed.
    nodeName :   string;
//!The is the name given to the job spec as part of the test definition.
    jobSpecName : preferred  referential ( R2.isFirstFor.JobSpec.jobSpecName, R9.isPartOf.JobSpec.jobSpecName ) string;
//!This is a duration that specifies a delay time in generating the event with respect to the previous event.
    delayDuration :   duration;
//!This is the previous event definition id. This is used to determine which previous event id to report in the event data that is sent to the Dual Twin System for processing.
    prevId :   string;
    preveventDefinitionId :   referential ( R1.follows.EventDefinition.eventDefinitionId ) string;
    prevjobSpecName :   referential ( R1.follows.EventDefinition.jobSpecName ) string;
//!This indicates that the if this event is the start of a sequence and therefore has no previous event.
    sequenceStart :   boolean;
  end object;
  object EventDispatchOrder is
    nexteventDefinitionId :   referential ( R13.nextEvent.EventDispatchOrder.eventDefinitionId ) string;
    nextjobSpecName :   referential ( R13.nextEvent.EventDispatchOrder.jobSpecName ) string;
    nexttestId :   referential ( R13.nextEvent.EventDispatchOrder.testId ) integer;
    eventDefinitionId : preferred  referential ( R14.dispatches.EventDefinition.eventDefinitionId ) string;
    testId : preferred  referential ( R12.firstFor.TestJobSpec.testId, R15.currentFor.TestJobSpec.testId, R14.areDispatchedFor.TestDefinition.testId ) integer;
    jobSpecName : preferred  referential ( R12.firstFor.TestJobSpec.jobSpecName, R15.currentFor.TestJobSpec.jobSpecName, R14.dispatches.EventDefinition.jobSpecName ) string;
  end object;
  object EventFileForJob is
    auditEventFileId : preferred  referential ( R17.reportsEventTo.AuditEventFile.auditEventFileId ) integer;
    jobId : preferred  referential ( R17.containsEventsFor.Job.jobId ) UUID::formatted_uuid;
  end object;
//!This represents a Job that as been created from a Job Spec as definined by the Test Definition.
//!
//!A Job has shall identify the events that have to be generated from the event definition and create the events in the order specified.
//!
//!Once all the events have been generated the Job is complete.
  object Job is
//!A UUID that is used to uniquely identify the job.
    jobId : preferred  UUID::formatted_uuid;
//!The name of the job spec that this job is using.
    jobSpecName :   referential ( R3.exectuted.JobSpec.jobSpecName ) string;
    testId :   referential ( R7.wasEexecutedBy.TestDefinition.testId ) integer;
//!The time that the job was started.
    jobStartTime :   timestamp;
    public instance service selectEventToDispatch (
    );
     state Created();
     state JobStarted();
     state JobFinished();
     state CreatingEvents();
     state DispatchingEvents();
     event startJob();
     event jobComplete();
     event eventCreated();
     event eventDispatched();
     event startEventDispatch();
     transition is
      Non_Existent (
        startJob => Cannot_Happen,
        jobComplete => Cannot_Happen,
        eventCreated => Cannot_Happen,
        eventDispatched => Cannot_Happen,
        startEventDispatch => Cannot_Happen      ); 
      Created (
        startJob => JobStarted,
        jobComplete => Ignore,
        eventCreated => Ignore,
        eventDispatched => Ignore,
        startEventDispatch => Ignore      ); 
      JobStarted (
        startJob => Ignore,
        jobComplete => Ignore,
        eventCreated => CreatingEvents,
        eventDispatched => Ignore,
        startEventDispatch => Ignore      ); 
      JobFinished (
        startJob => Ignore,
        jobComplete => Ignore,
        eventCreated => Ignore,
        eventDispatched => Ignore,
        startEventDispatch => Ignore      ); 
      CreatingEvents (
        startJob => Ignore,
        jobComplete => JobFinished,
        eventCreated => CreatingEvents,
        eventDispatched => Ignore,
        startEventDispatch => DispatchingEvents      ); 
      DispatchingEvents (
        startJob => Ignore,
        jobComplete => JobFinished,
        eventCreated => Ignore,
        eventDispatched => DispatchingEvents,
        startEventDispatch => Ignore      ); 
    end transition;
  end object;
//!This represents a job specification that has been loaded in from the simulator configuration file.
//!
//!The simulator shall execute this Job Spec at the rate specified in the test definition class.
//!
//!There can be many Job Specs for a test definition. The Job Spec is associated with the Event Definition which captures all the events for the Job Spec and the order it which they are played.
  object JobSpec is
//!This is the test name that has been given to the job spec e.g. EndToEndOrderedJob
    jobSpecName : preferred  string;
    jobName :   string;
  end object;
//!This captures the details of a test. A Test may have manay Job Specs and each Job Spec captures the types of event an the order that the events shall be played.
//!
//!The Test Definition also details the total number of test that are to be executed for the test and the frequency that the test should be executed.
  object TestDefinition is
//!An arbitary identifier for this test definition.
    testId : preferred  integer;
//!This defines the total number of times this test is to be executed.
    totalTests :   integer;
//!A duration that specifies the frequency that the test should be run e.g. PT1S is every second.
    testFrequency :   duration;
//!A timer used to schedule the execution of the test.
    testTimer :   timer;
//!A count of the completed tests which is used to determine when the total tests has been reached.
    testCount :   integer;
    testName :   string;
     state Created();
     state TestStarted();
     state TestFinished();
     event startTest();
     event testComplete();
     transition is
      Non_Existent (
        startTest => Cannot_Happen,
        testComplete => Cannot_Happen      ); 
      Created (
        startTest => TestStarted,
        testComplete => Cannot_Happen      ); 
      TestStarted (
        startTest => TestStarted,
        testComplete => TestFinished      ); 
      TestFinished (
        startTest => Cannot_Happen,
        testComplete => Cannot_Happen      ); 
    end transition;
  end object;
  object TestJobSpec is
    testId : preferred  referential ( R8.isRunBy.TestDefinition.testId ) integer;
    jobSpecName : preferred  referential ( R8.shallRun.JobSpec.jobSpecName ) string;
  end object;
  object TestSpec is
    testSpecId : preferred unique integer;
    jobSpecificationLocation :   string;
//!A boolean that indicates when true that all the events for that job should be placed in the same file.
//!
//!In false the events shall be placed in a sahred file up to the maximum events per file or the file timeout period.
    oneFilePerJob :   boolean;
//!The path to the directory where the job file containing the generated events should be constructed.
    testFileLocation :   string;
//!The path to the directory where the completed job file containing the generated events should be moved to so that it can be processed by the Dual Twin System
    testFileDestination :   string;
//!Thi si the maximum number of events that can be added to a file when the simulator is not being executed in a one file per job mode.
    maxEventsPerFile :   integer;
//!This is the maximum amount of time that can elapse before a file is generated when not operating in a one file per job mode.
    fileTimeOutPeriod :   duration;
  end object;
end domain;
