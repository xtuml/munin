domain IStore is
  object Invariant;
  object InvStore;
  public type persistedInvariantStructure is structure
    invariantName :string;
    invariantValue :string;
    validFrom :timestamp;
    validTo :timestamp;
    sourceJobDefinitionType :string;
    sourceAuditEventType :string;
    sourceAuditEventOccurrenceId :integer;
end structure;
    public service persistInvariant (
        invariantName : in string,        invariantValue : in string,        validFrom : in timestamp,        validTo : in timestamp,        sourceJobDefinitionType : in string,        sourceAuditEventType : in string,        sourceAuditEventOccurrenceId : in integer    );
    public service setLoadRate (
        loadRate : in duration    );
    private service init (
    );
pragma scenario ( 1 ); 
    private service testInvariantStore (
    );
pragma test_only ( true ); pragma scenario ( 2 ); 
  terminator StoreClient is
    public service addInvariants (
        invariantsToReport : in sequence of persistedInvariantStructure    );
  end terminator;
  relationship R1 is InvStore unconditionally hasStored many Invariant,
    Invariant unconditionally isStoredIn one InvStore;
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
  object InvStore is
    invStoreId :  unique integer;
    invStoreName : preferred  Filesystem::filename;
    storeTimer :   timer;
    loadRate :   duration;
    storeModificationTime :   timestamp;
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
end domain;
