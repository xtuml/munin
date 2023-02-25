state IStore::InvStore.StoreLoaded () is
lock : Filesystem::file_lock;
storeContents : string;
tokens : sequence of string;
invariantName : string;
invariantValue : string;
validFrom : timestamp;
validTo : timestamp;
sourceJobDefinitionType : string;
sourceAuditEventType : string;
sourceAuditEventOccurrenceId : string;
invariant : instance of Invariant;
invariantToReport : persistedInvariantStructure;
invariantsToReport : sequence of persistedInvariantStructure;
logMessage : string;
fileStatus : Filesystem::file_status;

begin
	logMessage := "IStore::InvStore.StoreLoaded";
	Logger::log(Logger::Information, "IStore", logMessage);

 	cancel this.storeTimer;
	if Filesystem::lock_file(Filesystem::filename(this.invStoreName), Filesystem::ExclusiveLock, lock, false) then
        fileStatus := Filesystem::get_file_status(Filesystem::filename(this.invStoreName));
        this.storeModificationTime := fileStatus.modification_time;
		storeContents := Filesystem::read_file(this.invStoreName);
        for line in Strings::tokenize(storeContents, "\n") loop
        	tokens :=  Strings::tokenize(line, ",");
        	invariantName := tokens[tokens'first];
        	invariantValue := tokens[tokens'first + 1];
        	validFrom := timestamp'parse(tokens[tokens'first + 2]);
        	validTo := timestamp'parse(tokens[tokens'first + 3]);
        	sourceJobDefinitionType := tokens[tokens'first + 4];
        	sourceAuditEventType := tokens[tokens'first + 5];
        	sourceAuditEventOccurrenceId := tokens[tokens'first + 6];
        	invariant := find_one Invariant(invariantName = invariantName and invariantValue = invariantValue);
        	if invariant = null then
        		invariant := create Invariant(invariantName => invariantName, invariantValue => invariantValue, validFrom => validFrom, validTo => validTo, 
        			                          sourceJobDefinitionType => sourceJobDefinitionType, sourceAuditEventType => sourceAuditEventType, 
        			                          sourceAuditEventOccurrenceId => sourceAuditEventOccurrenceId, reportedToLocalClient => false, stored => true);
        	end if;
        end loop;
	
		// remove any stale invariants
		for invariantToRemove in find Invariant(validTo < timestamp'now) loop
			delete invariantToRemove;
		end loop;
		
		// write the invariant data back to the store
		storeContents := "";
		for validInvariant in find Invariant() loop
			storeContents := storeContents & validInvariant.invariantName & "," & validInvariant.invariantValue & "," & validInvariant.validFrom'image & "," & validInvariant.validTo'image
			                 & "," & validInvariant.sourceJobDefinitionType & "," & validInvariant.sourceAuditEventType & "," &  validInvariant.sourceAuditEventOccurrenceId & "\n";  
			if validInvariant.reportedToLocalClient = false then
				invariantToReport.invariantName := validInvariant.invariantName;
				invariantToReport.invariantValue := validInvariant.invariantValue;
				invariantToReport.validFrom := validInvariant.validFrom;
				invariantToReport.validTo := validInvariant.validTo;
				invariantToReport.sourceJobDefinitionType := validInvariant.sourceJobDefinitionType;
				invariantToReport.sourceAuditEventType := validInvariant.sourceAuditEventType;
				invariantToReport.sourceAuditEventOccurrenceId := integer'parse(validInvariant.sourceAuditEventOccurrenceId);
				invariantsToReport := invariantsToReport & invariantToReport;
				validInvariant.reportedToLocalClient := true;
			end if;
			validInvariant.stored := true;
		end loop;
		if invariantsToReport'length > 0 then
			StoreClient~>addInvariants(invariantsToReport);
		end if;
		
		// write the file
		Filesystem::write_file(this.invStoreName, storeContents);
		
		// unlock the file
		Filesystem::unlock_file(lock);
		schedule this.storeTimer generate InvStore.checkStore() to this delay this.loadRate;
	else
		// back off for one second for the file to become unlocked
		schedule this.storeTimer generate InvStore.loadStore() to this delay @PT1S@;
	end if;
exception
	when others => 
		logMessage := "IStore::InvStore.StoreLoaded - failed to load invariant store";
		Logger::log(Logger::Information, "IStore", logMessage);

end state;
