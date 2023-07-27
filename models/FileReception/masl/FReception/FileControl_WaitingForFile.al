 state FReception::FileControl.WaitingForFile () is 
logMessage : string;
fileReceptionSpec : instance of FileReceptionSpec;
fileNames : sequence of Filesystem::filename;
eventFile : instance of EventFile;
fileToBeProcessed : Filesystem::filename;
lock: Filesystem::file_lock;
fileAssigned : boolean := false;
filePermissions : Filesystem::permissions;

begin

	// find a file to process
	fileReceptionSpec := find_one FileReceptionSpec();
	fileNames := Filesystem::list_directory(Filesystem::filename(fileReceptionSpec.incomingDirectory));
	for currentFile in fileNames loop
		begin
			if Filesystem::lock_file(Filesystem::filename(fileReceptionSpec.incomingDirectory & "/") & currentFile, Filesystem::ExclusiveLock, lock, false) then
				fileToBeProcessed := Filesystem::filename(fileReceptionSpec.processedDirectory & "/") & currentFile;
				Filesystem::move_file( Filesystem::filename(fileReceptionSpec.incomingDirectory & "/") & currentFile, Filesystem::filename(fileToBeProcessed));
				// verify that the move worked
				if Filesystem::file_exists(Filesystem::filename(fileToBeProcessed)) then
					eventFile := create EventFile(fileName => string(currentFile), timeProcessed => timestamp'now);
					link this R1 eventFile;
					generate FileControl.allocateFile(eventFile) to this;
					fileAssigned := true;
					logMessage := "FileReception::FileControl.WaitingForFile : assigning file " & eventFile.fileName;
					Logger::log(Logger::Debug, "FileReception", logMessage);
					exit; // for loop
				end if;
			end if;
		exception
			when others => null;
		end;
	end loop;
	if fileAssigned = false then
		schedule this.fileControlTimer generate FileControl.checkForFile() to this delay fileReceptionSpec.fileControlWaitTime;
	end if;
	
end state;
