 state AESimulator::Job.JobStarted () is 
logMessage : string;
eventDefinition : instance of EventDefinition;
deployedEvent : instance of DeployedEvent;
testSpec : instance of TestSpec;
auditEventFile : instance of AuditEventFile;
eventFileForJob : instance of EventFileForJob;
jobSpec : instance of JobSpec;
epochDate : timestamp;
epochEventTime : integer;
epochEventDispatchTime : integer;
eventTime : timestamp;

begin
	
	logMessage := "AESimulator::Job.JobStarted";
	Logger::log(Logger::Information, "AESimulator", logMessage);
	
	testSpec := find_one TestSpec();
	if testSpec.oneFilePerJob = true then
		auditEventFile := create AuditEventFile(isActive => true, fileId => this.jobId, Current_State => Created);
	else
		auditEventFile := find_one AuditEventFile(isActive = true);
	end if;
	eventFileForJob := create EventFileForJob(auditEventFileId => auditEventFile.auditEventFileId, jobId => this.jobId);
	link this R17 auditEventFile using eventFileForJob;
	jobSpec := this -> R3.JobSpec;
	for eventDefinition in jobSpec -> R2.EventDefinition loop
		eventTime := timestamp'now;
		epochEventTime := (eventTime - epochDate)'seconds;
		epochEventDispatchTime := epochEventTime + eventDefinition.delayDuration'seconds;
		deployedEvent := create DeployedEvent(eventId => UUID::generate_formatted(), epochEventCreationTime => epochEventTime, epochEventDispatchTime => epochEventDispatchTime, deployed => false, eventTime => eventTime, Current_State => Created);
		link deployedEvent R5 eventDefinition;
		link this R6 deployedEvent;
		generate DeployedEvent.evaluateDispatch() to deployedEvent;
	end loop;
		
end state;
