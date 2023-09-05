 state AESimulator::Job.CreatingEvents () is 
logMessage : string;
eventDefinitions : sequence of instance of EventDefinition;
createdEvents : sequence of instance of DeployedEvent;
jobSpec : instance of JobSpec;
testDefinition : instance of TestDefinition;
testJobSpec : instance of TestJobSpec;
eventToDispatch : instance of DeployedEvent;

begin
	
	eventDefinitions := this -> R3.JobSpec -> R9.EventDefinition;
	createdEvents := this -> R6.DeployedEvent;
	logMessage := "AESimulator::Job.DispatchingEvents - events to create = " & eventDefinitions'length'image & ", events created = " & createdEvents'length'image;
	Logger::log(Logger::Information, "AESimulator", logMessage);
	if  eventDefinitions'length = createdEvents'length then
		// locate the first event to dispatch and request that it is dispatched
		jobSpec := this -> R3.JobSpec;
		testDefinition := this -> R7.TestDefinition;
		testJobSpec := jobSpec with testDefinition -> R8.TestJobSpec;
		if testJobSpec /= null then
			generate Job.startEventDispatch() to this;
		else
			logMessage := "AESimulator::Job.DispatchingEvents - job failed test name = " & testDefinition.testName & ", job spec name = " & jobSpec.jobSpecName;
			Logger::log(Logger::Error, "AESimulator", logMessage);
		end if; 
	end if;
	
end state;
