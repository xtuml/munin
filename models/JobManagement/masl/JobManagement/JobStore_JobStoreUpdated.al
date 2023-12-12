state JobManagement::JobStore.JobStoreUpdated () is
ageOffJobTime : timestamp;
jobIdsToStore : string;

begin
		
	// remove any StoredJobIdentifiers that are older than the age off limit and add the to the archive
	ageOffJobTime := timestamp'now - this.jobStoreAgeLimit;
	for jobStoreIdentifier in find StoredJobIdentifier(jobTime <= ageOffJobTime) loop
		jobIdsToStore := jobIdsToStore & jobStoreIdentifier.jobTime'image & " " & jobStoreIdentifier.jobId & "\n";
		delete jobStoreIdentifier;
	end loop;
	Logger::log(Logger::Information, "JobIdStore", jobIdsToStore);
	
	
end state;
