 state AESimulator::Job.DispatchingEvents () is 
logMessage : string;
undeployedEvents : sequence of instance of DeployedEvent;
deployedEvents : sequence of instance of DeployedEvent;

begin
	
	// evaluate if all events have been dispatched
	undeployedEvents := this -> R6.DeployedEvent();
	deployedEvents := this -> R10.DeployedEvent();
	logMessage := "AESimulator::Job.DispatchingEvents - events to deploy = " & undeployedEvents'length'image & ", events deployed = " & deployedEvents'length'image;
	Logger::log(Logger::Information, "AESimulator", logMessage);
	if undeployedEvents'length /= deployedEvents'length then
		// select the next event to dispatch
		this.selectEventToDispatch();
	else
		// complete the job
		generate Job.jobComplete() to this;
	end if;
	
end state;
