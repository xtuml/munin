 state FReception::FileControl.ProcessingFile (        eventFile : in instance of EventFile) is 
logMessage : string;
fileToBeProcessed : string;
auditEvents : string;
fileReceptionSpec : instance of FileReceptionSpec;

begin
	
	// create the reception job and link to the event file it has to process
	fileReceptionSpec := find_one FileReceptionSpec();
	fileToBeProcessed := fileReceptionSpec.processedDirectory & "/" & eventFile.fileName;
    auditEvents := Filesystem::read_file(Filesystem::filename(fileToBeProcessed));
    Reception~>AcceptEvents(auditEvents);
	// check for more capacity
	generate FileControl.checkCapacity() to this;
	
end state;
