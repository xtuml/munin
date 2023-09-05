 state AESimulator::DeployedEvent.Dispatched () is 
logMessage : string;
job : instance of Job;
eventDefinition : instance of EventDefinition;
testSpec : instance of TestSpec;
audit_event: JSON::JSONObject;
auditEventData: JSON::JSONObject;
auditEventFile : instance of AuditEventFile;
newAuditEventFile : instance of AuditEventFile;
eventFileForJob : instance of EventFileForJob;
epochDate : timestamp;

begin
	
	logMessage := "AESimulator::DeployedEvent.Dispatched";
	Logger::log(Logger::Information, "AESimulator", logMessage);
	
	job := this -> R6.Job;
	eventDefinition := this -> R5.EventDefinition;
	testSpec := find_one TestSpec();
	this.deployed := true;
	auditEventFile := find_one (job -> R17.AuditEventFile)(isActive = true);
	if auditEventFile /= null then			
		auditEventFile.auditEvents := auditEventFile.auditEvents & JSON::to_json(eventDefinition.nodeName);
		audit_event["timestamp"] := JSON::to_json(this.eventTime'image);
		audit_event["applicationName"] := JSON::to_json(eventDefinition.applicationName);
		audit_event["jobId"] := JSON::to_json(string(job.jobId));
		audit_event["jobName"] := JSON::to_json(string(job.jobSpecName));
		audit_event["eventType"] := JSON::to_json(eventDefinition.eventTypeName);
		audit_event["eventId"] := JSON::to_json(string(this.eventId));
		for eventData in eventDefinition -> R16.EventData loop
			auditEventData["dataItemType"] := JSON::to_json(eventData.eventDataName);
			if eventData.eventDataName = "LOOPCOUNT" or eventData.eventDataName = "BRANCHCOUNT" then
				auditEventData["value"] := JSON::to_json(integer'parse(eventData.eventDataValue));
			else
				auditEventData["value"] := JSON::to_json(eventData.eventDataValue);
			end if;
			audit_event[eventData.eventDataType] := JSON::to_json(auditEventData);
		end loop;
		if this.prevEventId /= "" and eventDefinition.sequenceStart = false then
		  audit_event["previousEventIds"] := JSON::to_json(this.prevEventId);
		end if;
		auditEventFile.auditEvents := auditEventFile.auditEvents & JSON::to_json(audit_event);
		auditEventFile.numberOfEvents := auditEventFile.numberOfEvents + 1;
		if testSpec.oneFilePerJob = false and auditEventFile.numberOfEvents >= testSpec.maxEventsPerFile then
			generate AuditEventFile.generateFile() to auditEventFile;
			// make this audit file inactive and create a new audit file
			auditEventFile.isActive := false;
			newAuditEventFile := create unique AuditEventFile(numberOfEvents => 0, isActive => true, fileId => UUID::generate_formatted(), Current_State => Created);
			schedule newAuditEventFile.fileTimer generate AuditEventFile.generateFile() to newAuditEventFile delay testSpec.fileTimeOutPeriod;
			for job in auditEventFile -> R17.Job loop
				eventFileForJob := job with auditEventFile -> R17.EventFileForJob;
				unlink auditEventFile R17 job using eventFileForJob;
				delete eventFileForJob;
				if testSpec.oneFilePerJob = false then
					eventFileForJob := create EventFileForJob(auditEventFileId => newAuditEventFile.auditEventFileId, jobId => job.jobId);
					link job R17 newAuditEventFile using eventFileForJob;
				end if;
			end loop;
		end if;
	else
		logMessage := "AESimulator::DeployedEvent.Dispatched - Failed to find active Audit Event File";
		Logger::log(Logger::Information, "AESimulator", logMessage);
	end if;
	link this R10 job;
	generate Job.eventDispatched() to job;
	
end state;
