 state AESimulator::TestDefinition.TestStarted () is 
logMessage : string;
job : instance of Job;

begin
	
	logMessage := "AESimulator::TestDefinition.TestStarted";
	Logger::log(Logger::Information, "AESimulator", logMessage);
	for jobSpec in this -> R8.JobSpec loop
		job := create Job(jobId => UUID::generate_formatted(), jobStartTime => timestamp'now, Current_State => Created);
		link this R7 job;
		link job R3 jobSpec;
		generate Job.startJob() to job;
	end loop;
	this.testCount := this.testCount + 1;
	
	if this.testCount < this.totalTests then
		schedule this.testTimer generate TestDefinition.startTest() to this delay this.testFrequency;
	else
		generate TestDefinition.testComplete() to this;
	end if;

end state;
