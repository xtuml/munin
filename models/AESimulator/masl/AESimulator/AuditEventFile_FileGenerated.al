 state AESimulator::AuditEventFile.FileGenerated () is 
logMessage : string;
testSpec : instance of TestSpec;
destinationFilename : string;
eventFileForJob : instance of EventFileForJob;
auditEventFile : instance of AuditEventFile;

begin

	logMessage := "AESimulator::AuditEventFile.FileGenerated";
	Logger::log(Logger::Information, "AESimulator", logMessage);
	testSpec := find_one TestSpec();
	cancel this.fileTimer;
	// write the file
	if this.numberOfEvents > 0 then
		destinationFilename := testSpec.testFileDestination & "/" & string(this.fileId);
		Filesystem::write_file(Filesystem::filename(destinationFilename), JSON::dump(this.auditEvents));
	end if;
	
	// create the new audit event file and delete the old one
	if testSpec.oneFilePerJob = false and this.isActive = true then
		this.isActive := false;
		auditEventFile := create unique AuditEventFile(numberOfEvents => 0, isActive => true, fileId => UUID::generate_formatted(), Current_State => Created);
		schedule auditEventFile.fileTimer generate AuditEventFile.generateFile() to auditEventFile delay testSpec.fileTimeOutPeriod;
	end if;
	for job in this -> R17.Job loop
		eventFileForJob := job with this -> R17.EventFileForJob;
		unlink this R17 job using eventFileForJob;
		delete eventFileForJob;
		if testSpec.oneFilePerJob = false then
			eventFileForJob := create EventFileForJob(auditEventFileId => auditEventFile.auditEventFileId, jobId => job.jobId);
			link job R17 auditEventFile using eventFileForJob;
		end if;
	end loop;

end state;
