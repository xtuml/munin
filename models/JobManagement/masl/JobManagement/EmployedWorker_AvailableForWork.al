state JobManagement::EmployedWorker.AvailableForWork () is
jmSpec : instance of JobManagementSpec;

begin
	// cancel the absence timer
	cancel this.absenceTimer;
	// reset the failed heartbeat count
	this.failedHeartbeatCount := 0;
	// schedule the absence timer
	jmSpec := find_one JobManagementSpec();
	schedule this.absenceTimer generate EmployedWorker.workerPresenceUnknown() to this delay jmSpec.workerHeartbeatRate;
end state;
