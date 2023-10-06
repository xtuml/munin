# initialise domain
RUN SCENARIO IStore 1 "init"

# run tests
RUN SCENARIO Test 1 "run_test" [IStore testInvariantStore 2]

# done
TERMINATE
