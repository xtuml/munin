domain IStore is
  object InvStore;
  object Invariant;
  public type persistedInvariantStructure is structure
    invariantName :string;
    invariantValue :string;
    validFrom :timestamp;
    validTo :timestamp;
    sourceJobDefinitionType :string;
    sourceAuditEventType :string;
    sourceAuditEventOccurrenceId :integer;
end structure;
    private service testInvariantStore (
    );
pragma test_only ( true ); pragma scenario ( 2 ); 
    private service init (
    );
pragma scenario ( 1 ); pragma process_listener ( "postschedules" ); 
    private service registerCommandLineArgs (
    );
pragma process_listener ( "initialised" ); 
    public service persistInvariant (
        invariantName : in string,        invariantValue : in string,        validFrom : in timestamp,        validTo : in timestamp,        sourceJobDefinitionType : in string,        sourceAuditEventType : in string,        sourceAuditEventOccurrenceId : in integer    );
pragma kafka_topic ( true ); 
    public service setLoadRate (
        loadRate : in duration    );
pragma kafka_topic ( true ); 
    public service restoreNamedInvariant (
        invariantName : in string,        invariantValue : in string    );
pragma kafka_topic ( true ); 
  terminator StoreClient is
    public service addInvariants (
        invariantsToReport : in sequence of persistedInvariantStructure    );
  end terminator;
  relationship R1 is InvStore unconditionally hasStored many Invariant,
    Invariant unconditionally isStoredIn one InvStore;
  object InvStore is
    invStoreId :  unique integer;
    invStoreName : preferred  Filesystem::filename;
    storeTimer :   timer;
    loadRate :   duration;
    storeModificationTime :   timestamp;
    storeToFile :   boolean;
     state Created();
     state StoreLoaded();
     state StoreChecked();
     event loadStore();
     event checkStore();
     transition is
      Non_Existent (
        loadStore => Cannot_Happen,
        checkStore => Cannot_Happen      ); 
      Created (
        loadStore => StoreLoaded,
        checkStore => Cannot_Happen      ); 
      StoreLoaded (
        loadStore => StoreLoaded,
        checkStore => StoreChecked      ); 
      StoreChecked (
        loadStore => StoreLoaded,
        checkStore => StoreChecked      ); 
    end transition;
  end object;
  object Invariant is
    invariantName : preferred  string;
    invariantValue : preferred  string;
    validFrom :   timestamp;
    validTo :   timestamp;
    sourceJobDefinitionType :   string;
    sourceAuditEventType :   string;
    sourceAuditEventOccurrenceId :   string;
    invStoreName :   referential ( R1.isStoredIn.InvStore.invStoreName ) Filesystem::filename;
    reportedToLocalClient :   boolean;
    stored :   boolean;
  end object;
end domain;
