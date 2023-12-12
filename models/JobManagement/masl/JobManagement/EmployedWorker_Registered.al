state JobManagement::EmployedWorker.Registered () is
jobManager : instance of JobManager;

begin
  
	// report the worker as registered
	Worker~>workerRegistered(this.workerId);
	
	// ask the job manager to assign a job
	jobManager := find_one JobManager();
	jobManager.assignJob();

end state;
