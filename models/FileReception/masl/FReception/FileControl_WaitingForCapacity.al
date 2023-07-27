 state FReception::FileControl.WaitingForCapacity () is 
logMessage : string;
fileReceptionSpec : instance of FileReceptionSpec;
currentFiles : sequence of instance of EventFile;

begin
	
	cancel this.fileControlTimer;
	fileReceptionSpec := find_one FileReceptionSpec();
	currentFiles := this -> R1.EventFile;
	if currentFiles'length < fileReceptionSpec.concurrentReceptionLimit then
		generate FileControl.checkForFile() to this;
	else
		// schedule to check for capacity. Should not be needed as conclusion of reception processing should force the check.
		schedule this.fileControlTimer generate FileControl.checkCapacity() to this delay fileReceptionSpec.fileControlWaitTime;

		// age off any old files
		for eventFile in currentFiles loop
			unlink this R1 eventFile;
			delete eventFile;
		end loop;
		
	end if;
	
  
end state;
