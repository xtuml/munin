$TESTSCHEDULE
PAUSE

# initialize domain
RUN SCENARIO FReception 1 "init"

# run tests

RUN SCENARIO Test 1 "run_test" [FReception basicTest01 10]
RUN SCENARIO Test 1 "run_test" [FReception testFileCapacityManagement 13]
RUN SCENARIO Test 1 "run_test" [FReception testConfigLoad 11]

# done
TERMINATE

$ENDTESTSCHEDULE
