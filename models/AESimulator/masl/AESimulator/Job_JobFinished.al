 state AESimulator::Job.JobFinished () is 
logMessage : string;
testSpec : instance of TestSpec;
destinationFilename : string;
events  : sequence of instance of DeployedEvent;
auditEventFile : instance of AuditEventFile;
eventFileForJob : instance of EventFileForJob;
jobSpec : instance of JobSpec;
testDefinition : instance of TestDefinition;
testJobSpec : instance of TestJobSpec;

begin
	
	logMessage := "AESimulator::Job.JobFinished";
	Logger::log(Logger::Information, "AESimulator", logMessage);
	testSpec := find_one TestSpec();
	jobSpec := this -> R3.JobSpec;
	testDefinition := this -> R7.TestDefinition;
	testJobSpec := jobSpec with testDefinition -> R8.TestJobSpec;
	unlink testJobSpec R15;

	auditEventFile := find_one (this -> R17.AuditEventFile)(isActive = true);
	if testSpec.oneFilePerJob = true then
		generate AuditEventFile.generateFile() to auditEventFile;
	end if;
	
	eventFileForJob := this with auditEventFile -> R17.EventFileForJob; 
	unlink this R17 auditEventFile using eventFileForJob;
	delete eventFileForJob;
	events := this -> R10.DeployedEvent;
	unlink events R6;
	unlink events R5;
	unlink events R10;
	delete events;
	
end state;
