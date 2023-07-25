domain VerificationGateway is
  object InstrumentationEvent;
  object VerifiableJob;
  private type timer is inst_ref<Timer>
  ;
  private type duration is integer
  ;
    public service acceptInstrumentationEventForJob (
        clientJobId : in string,        clientEventId : in string,        clientEventType : in string    );
  relationship R1 is VerifiableJob unconditionally has_behaviour_verified_using many InstrumentationEvent,
    InstrumentationEvent unconditionally is_used_to_verify_the_behaviour_of one VerifiableJob;
//!For a given VerifiableJob this association indicates which of its InstrumentationEvent's (see R1) was the last one received. 
  relationship R2 is InstrumentationEvent unconditionally was_last_event_received_for one VerifiableJob,
    VerifiableJob unconditionally last_received one InstrumentationEvent;
  relationship R3 is InstrumentationEvent conditionally is_followed_by one InstrumentationEvent,
    InstrumentationEvent conditionally is_preceeded_by one InstrumentationEvent;
  object InstrumentationEvent is
    clientEventId :   string;
    clientEventType :   string;
    jobKey :   referential ( R1.is_used_to_verify_the_behaviour_of.VerifiableJob.jobKey ) integer;
    eventKey : preferred unique integer;
    assignedPreviousEventKey :   referential ( R3.is_preceeded_by.InstrumentationEvent.eventKey ) integer;
  end object;
  object VerifiableJob is
//!The ID of the client Job who behaviour is being verified.
    clientJobId :   string;
//!The unique identifier assigned to the VerifiableJob for use within this domain. The ID of the 'client' Job is not to be used for this purpose, in order that the client's identifier is not leaked beyond where necessary.
    jobKey : preferred unique integer;
    lastReceivedEventKey :   referential ( R2.last_received.InstrumentationEvent.eventKey ) integer;
    public instance service createVerifiableJob (
        clientJobId : in string,        clientEventId : in string,        clientEventType : in string    );
     state ProcessingEventsForJob(        nextEventId : in string,        nextEventType : in string);
     state Deleting();
     event nextEventForExistingJob(        nextEventId : in string,        nextEventType : in string);
     event deleteVerifiableJob();
     transition is
      Non_Existent (
        nextEventForExistingJob => Cannot_Happen,
        deleteVerifiableJob => Cannot_Happen      ); 
      ProcessingEventsForJob (
        nextEventForExistingJob => ProcessingEventsForJob,
        deleteVerifiableJob => Deleting      ); 
      Deleting (
        nextEventForExistingJob => Cannot_Happen,
        deleteVerifiableJob => Cannot_Happen      ); 
    end transition;
  end object;
end domain;
