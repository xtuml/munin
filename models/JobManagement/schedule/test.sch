# initialise domain
RUN SCENARIO JobManagement 1 "init"

# run tests
RUN SCENARIO Test 1 "run_test" [JobManagement testConfigData 100]
RUN SCENARIO Test 1 "run_test" [JobManagement testRegisterWorker 101]

# done
TERMINATE
