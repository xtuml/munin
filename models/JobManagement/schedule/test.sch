# initialise domain
RUN SCENARIO JobManagement 1 "init"

# run tests
PAUSE
RUN SCENARIO Test 1 "run_test" [JobManagement testConfigData 101]
RUN SCENARIO Test 1 "run_test" [JobManagement testRegisterWorker 102]
RUN SCENARIO Test 1 "run_test" [JobManagement testWorkerHeartbeat 103]
RUN SCENARIO Test 1 "run_test" [JobManagement testAssignWork 104]
RUN SCENARIO Test 1 "run_test" [JobManagement testJobCompleted 105]
RUN SCENARIO Test 1 "run_test" [JobManagement testDeregisterWorker 106]
RUN SCENARIO Test 1 "run_test" [JobManagement testAssignJobQueue 107]

# done
TERMINATE
