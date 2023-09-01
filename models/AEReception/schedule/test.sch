$TESTSCHEDULE

# initialize domain
RUN SCENARIO AEReception 1 "init"

# run tests

RUN SCENARIO Test 1 "run_test" [AEReception basicTest01 11]
RUN SCENARIO Test 1 "run_test" [AEReception testConfigLoad 12]

# done
TERMINATE

$ENDTESTSCHEDULE
