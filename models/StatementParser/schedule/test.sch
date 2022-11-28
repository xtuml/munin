$TESTSCHEDULE

# initialize domain
RUN SCENARIO StatementParser 1 "populateDomain"

# run tests
RUN SCENARIO Test 1 "run_test" [StatementParser testParser 11]

# done
TERMINATE

$ENDTESTSCHEDULE
