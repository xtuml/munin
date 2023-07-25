 state VerificationGateway::VerifiableJob.ProcessingEventsForJob (        nextEventId : in string,        nextEventType : in string) is 
newInstrumentationEvent : instance of InstrumentationEvent;
previousInstrumentationEvent : instance of InstrumentationEvent;

begin
  // Create a new instance of InstrumentationEvent and link it up to the Job via R1 and R2
  newInstrumentationEvent := create unique InstrumentationEvent (clientEventId => nextEventId, clientEventType => nextEventType);
  link this R1 newInstrumentationEvent;
  previousInstrumentationEvent := find_one InstrumentationEvent (eventKey = this.lastReceivedEventKey);
  if previousInstrumentationEvent /= null then
    // The previous InstrumentationEvent for the job has been found - so stitch the newInstrumentationEvent to the 
    // previousInstrumentationEvent by re-linking R2 and link R3 in readiness for the next event.
    unlink this R2 previousInstrumentationEvent;
    link this R2 newInstrumentationEvent;
    link previousInstrumentationEvent R3.is_followed_by newInstrumentationEvent; 
  else
    // TODO
  end if;
end state;
