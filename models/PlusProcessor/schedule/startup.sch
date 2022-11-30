$TESTSCHEDULE

RUN SCENARIO StatementParser   1 "populateDomain"
RUN SCENARIO SequenceProcessor 1 "populateDomain"

$ENDTESTSCHEDULE
