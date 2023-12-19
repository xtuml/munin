state JobManagement::EmployedWorker.Registered () is
jobManager : instance of JobManager;
jmSpec : instance of JobManagementSpec;
unassignedJobIds : sequence of string;

begin
  
	// report the worker as registered
	Worker~>workerRegistered(this.workerId);
	
	// ask the job manager to assign a job
	jobManager := find_one JobManager();
	unassignedJobIds := jobManager.unassignedJobIds;
	if unassignedJobIds'length > 0 then
		jobManager.assignJob(this);
	end if;
	
	// set the absence timer
	this.failedHeartbeatCount := 0;
	jmSpec := find_one JobManagementSpec();
	schedule this.absenceTimer generate EmployedWorker.workerPresenceUnknown() to this delay jmSpec.workerHeartbeatRate;

end state;
