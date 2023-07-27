 state FReception::FileReceptionSpec.ConfigChecked () is 
logMessage : string;
fileStatus : Filesystem::file_status;

begin
	
	if Filesystem::file_exists(Filesystem::filename(this.configFilePath & this.configFile)) then
		fileStatus := Filesystem::get_file_status(Filesystem::filename(this.configFilePath & this.configFile));
		if fileStatus.modification_time /= this.configFileModificationTime then
			generate FileReceptionSpec.loadConfig() to this;
		else
			schedule this.configTimer generate FileReceptionSpec.checkConfigUpdate() to this delay this.specUpdateRate;
		end if;
		else
		logMessage := "FileReception::FileReceptionSpec.ConfigChecked : failed to locate config file. Specified file = " & this.configFilePath & this.configFile;
		Logger::log(Logger::Error, "FileReception", logMessage);
		raise program_error;
	end if;
	
exception
	when others => 	
	
		logMessage := "FileReception::FileReceptionSpec.ConfigChecked : failed to load configuration file";
		Logger::log(Logger::Error, "FileReception", logMessage);
		raise program_error;		
	
end state;
