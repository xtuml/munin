 state AESimulator::DeployedEvent.DispatchScheduled () is 
logMessage : string;
job : instance of Job;
eventDefinition : instance of EventDefinition;
deployedEvent : instance of DeployedEvent;
jobSpec : instance of JobSpec;
epochDate : timestamp;
epochEventTime : integer;
eventTime : timestamp;

begin
	
	logMessage := "AESimulator::DeployedEvent.DispatchScheduled";
	Logger::log(Logger::Information, "AESimulator", logMessage);
	
	job := this -> R6.Job;
	eventDefinition := this -> R5.EventDefinition;
	for nextEventDefinition in eventDefinition -> R1.isFollowedBy.EventDefinition loop
		eventTime := timestamp'now;
		epochEventTime := (eventTime - epochDate)'seconds;
		epochEventDispatchTime := epochEventTime + nextEventDefinition.delayDuration'seconds;
		deployedEvent := create DeployedEvent(eventId => UUID::generate_formatted(), epochEventCreationTime => epochEventTime, epochEventDispatchTime => epochEventDispatchTime, prevEventId => string(this.eventId), deployed => false, eventTime => eventTime, Current_State => Created);
		link deployedEvent R5 nextEventDefinition;
		link job R6 deployedEvent;
		generate DeployedEvent.evaluateDispatch() to deployedEvent;
	end loop;
	generate Job.eventCreated() to job;
	
end state;
