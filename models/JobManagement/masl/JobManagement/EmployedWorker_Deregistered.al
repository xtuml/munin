state JobManagement::EmployedWorker.Deregistered () is
begin
	
	// retire the worker
	(this -> R2.JobWorker).retireWorker();
	
end state;
