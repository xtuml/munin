state JobManagement::EmployedWorker.Absent () is
jmSpec : instance of JobManagementSpec;

begin
	// cancel the absence timer
	cancel this.absenceTimer;
	// reset the failed heartbeat count
	this.failedHeartbeatCount := this.failedHeartbeatCount + 1;
	jmSpec := find_one JobManagementSpec();
	if this.failedHeartbeatCount > jmSpec.workerHeartbeatFailureThreshold then
		generate EmployedWorker.workerDeregistered() to this;
	else
		// schedule the absence timer
		schedule this.absenceTimer generate EmployedWorker.workerPresenceUnknown() to this delay jmSpec.workerHeartbeatRate;
	end if;
end state;
