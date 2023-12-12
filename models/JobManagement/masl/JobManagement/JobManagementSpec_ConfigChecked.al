state JobManagement::JobManagementSpec.ConfigChecked () is
logMessage : string;
fileStatus : Filesystem::file_status;
fileName : Filesystem::filename;
configUpdates : boolean;

begin

    if this.checkUpdatedConfig() = true then
    	this.loadConfigFile();
    end if;

    // check the job store and purge if required
    generate JobStore.purgeJobStore() to (find_one JobStore());
    schedule this.configTimer generate JobManagementSpec.checkConfigUpdate() to this delay this.specUpdateRate;
	
exception
	when others => 	
	
		logMessage := "JobManagement::JobManagementSpec.ConfigChecked : failed to load configuration file";
		Logger::log(Logger::Error, "JobManagement", logMessage);
		raise program_error;
		
end state;
