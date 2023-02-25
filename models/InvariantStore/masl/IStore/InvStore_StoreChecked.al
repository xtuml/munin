state IStore::InvStore.StoreChecked () is
logMessage : string;
fileStatus : Filesystem::file_status;

begin

	logMessage := "IStore::InvStore.StoreChecked";
	Logger::log(Logger::Information, "IStore", logMessage);
	cancel this.storeTimer;
	
	if Filesystem::file_exists(this.invStoreName) then
		fileStatus := Filesystem::get_file_status(this.invStoreName);
		if fileStatus.modification_time /= this.storeModificationTime then
			generate InvStore.loadStore() to this;
		else
			schedule this.storeTimer generate InvStore.checkStore() to this delay this.loadRate;
		end if;
	else
		logMessage := "InvStore.StoreChecked, failed to locate invariant store. Specified file = " & string(this.invStoreName);
		Logger::log(Logger::Error, "IStore", logMessage);
		raise program_error;
	end if;
	
exception
	when others => 	
	
		logMessage := "AEOrdering::InvStore.StoreChecked, failed to load invariant store";
		Logger::log(Logger::Error, "IStore", logMessage);
		
	
end state;
