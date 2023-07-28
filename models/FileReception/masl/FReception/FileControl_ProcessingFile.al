 state FReception::FileControl.ProcessingFile (        eventFile : in instance of EventFile) is 
logMessage : string;
fileToBeProcessed : string;
auditEvents : string;
fileReceptionSpec : instance of FileReceptionSpec;
jsonElement : JSON::JSONElement;

begin
	
	// create the reception job and link to the event file it has to process
	fileReceptionSpec := find_one FileReceptionSpec();
	fileToBeProcessed := fileReceptionSpec.processedDirectory & "/" & eventFile.fileName;
    auditEvents := Filesystem::read_file(Filesystem::filename(fileToBeProcessed));
	jsonElement := JSON::parse(auditEvents);
	if jsonElement.kind = JSON::Array then
		for elementReceived in JSON::get_array(jsonElement) loop
			if elementReceived.kind = JSON::Object then
				Reception~>AcceptEvents(JSON::dump(elementReceived));
			end if;
		end loop;
	end if;
	// check for more capacity
	generate FileControl.checkCapacity() to this;
	
end state;
