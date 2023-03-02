$TESTSCHEDULE

# initialize domain
RUN SCENARIO AEOrdering 1 "init"
# run tests
RUN SCENARIO Test 1 "run_test" [AEOrdering testConfigTestData 2]
RUN SCENARIO Test 1 "run_test" [AEOrdering testInvalidJobDefinition 4]
RUN SCENARIO Test 1 "run_test" [AEOrdering testJobComplete 5]
RUN SCENARIO Test 1 "run_test" [AEOrdering testJobFailure 6]
RUN SCENARIO Test 1 "run_test" [AEOrdering testOrderedJob 7]
RUN SCENARIO Test 1 "run_test" [AEOrdering testOutOfOrderJob 8]
RUN SCENARIO Test 1 "run_test" [AEOrdering testReverseOrderedJob 9]
RUN SCENARIO Test 1 "run_test" [AEOrdering testForkAndMerge 11]
RUN SCENARIO Test 1 "run_test" [AEOrdering testOrderedJobWithData 12]
RUN SCENARIO Test 1 "run_test" [AEOrdering testDeprecatedJob 3]
RUN SCENARIO Test 1 "run_test" [AEOrdering testConfigFile 10]
RUN SCENARIO Test 1 "run_test" [AEOrdering testInjestFile 13]


# done
TERMINATE

$ENDTESTSCHEDULE
