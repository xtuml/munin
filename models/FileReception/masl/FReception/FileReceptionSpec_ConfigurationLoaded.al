 state FReception::FileReceptionSpec.ConfigurationLoaded () is 
logMessage : string;
fileStatus : Filesystem::file_status;
fileControl : instance of FileControl;
fileName : Filesystem::filename;
configJSONString : string;
configJSONElement : JSON::JSONElement;
configJSONObject : JSON::JSONObject;
configValidationResult : JSON::JSONObject;
filePermissions : Filesystem::permissions;

begin
	
	filePermissions.group.read := true;
	filePermissions.other.read := true;
	filePermissions.group.write := true;
	filePermissions.other.write := true;
	// check the config file has not been removed
	fileName := Filesystem::filename(this.configFilePath & this.configFile);
	if Filesystem::file_exists(fileName) then

		configJSONString := Filesystem::read_file(fileName);
		configJSONElement := JSON::parse(configJSONString);
		configValidationResult := JSONValidation::validate(configJSONElement, #PROP["fileReceptionConfigSchema"]#);
		
		if JSON::get_boolean(configValidationResult["valid"]) then
		    // extract the spec data items
			configJSONObject := JSON::get_object(configJSONElement);
			if configJSONObject'contains("SpecUpdateRate") then
				this.specUpdateRate := duration'parse(JSON::get_string(configJSONObject["SpecUpdateRate"]));
			end if;
			if configJSONObject'contains("IncomingDirectory") then
				this.incomingDirectory := JSON::get_string(configJSONObject["IncomingDirectory"]);
			end if;
			if configJSONObject'contains("ProcessedDirectory") then
				this.processedDirectory := JSON::get_string(configJSONObject["ProcessedDirectory"]);
			end if;
			if configJSONObject'contains("ConcurrentReceptionLimit") then
				this.concurrentReceptionLimit := integer'parse(JSON::get_string(configJSONObject["ConcurrentReceptionLimit"]));
			end if;
			if configJSONObject'contains("FileControlWaitTime") then
				this.fileControlWaitTime := duration'parse(JSON::get_string(configJSONObject["FileControlWaitTime"]));
			end if;
    	else
			logMessage := "AEReception::ReceptionSpec.ConfigurationLoaded : Config file invalid:\n" & JSON::dump(configValidationResult, true);
			Logger::log(Logger::Debug, "AEReception", logMessage);
			raise JSON::JSONException("Config file invalid");
		end if;

		// set the config file mod time
		fileName := Filesystem::filename(this.configFilePath & this.configFile);
		fileStatus := Filesystem::get_file_status(Filesystem::filename(fileName));
		this.configFileModificationTime := fileStatus.modification_time;
				
		// schedule to check the config file
		schedule this.configTimer generate FileReceptionSpec.checkConfigUpdate() to this delay this.specUpdateRate;
	else
		logMessage := "FileReception::FileReceptionSpec.ConfigurationLoaded : failed to locate config file. Specified file = " & this.configFilePath & this.configFile;
		Logger::log(Logger::Error, "FileReception", logMessage);
		raise program_error;
	end if;
	
	// check if file control exists and if not create it
	fileControl := find_one FileControl();
	if fileControl = null then
		fileControl := create unique FileControl(schemaValidationCount => 0, Current_State => Created);
		filePermissions.group.read := true;
		filePermissions.other.read := true;
		filePermissions.group.write := true;
		filePermissions.other.write := true;
		// check the incoming directory exists and if not create it
		if not Filesystem::file_exists(Filesystem::filename(this.incomingDirectory)) then
			Filesystem::create_directory(Filesystem::filename(this.incomingDirectory));
		end if;
		Filesystem::add_permissions(Filesystem::filename(this.incomingDirectory),filePermissions);
		// check the processed directory exists and if not create it
		if not Filesystem::file_exists(Filesystem::filename(this.processedDirectory)) then
			Filesystem::create_directory(Filesystem::filename(this.processedDirectory));
		end if;
		Filesystem::add_permissions(Filesystem::filename(this.processedDirectory),filePermissions);
		schedule fileControl.fileControlTimer generate FileControl.checkForFile() to fileControl delay duration'seconds(0);
	end if;
	
exception
	when program_error =>
		raise program_error;
	when others => 	
	
		logMessage := "FileReception::FileReceptionSpec.ConfigurationLoaded : failed to load configuration file";
		Logger::log(Logger::Error, "FileReception", logMessage);
		raise program_error;
		
end state;
