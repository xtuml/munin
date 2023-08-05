$TESTSCHEDULE
# Initialise domain - nothing to initialise at this stage
#
# Run normal path tests
RUN SCENARIO Test 1 "run_test" [VerificationGateway Test001BasicPVInstrumentationSequence 1 CleanUpAllJobs 100]
RUN SCENARIO Test 1 "run_test" [VerificationGateway Test002MultipleJobPVInstrumentationSequence 2 CleanUpAllJobs 100]
RUN SCENARIO Test 1 "run_test" [VerificationGateway Test003MultipleInterleavedJobsPVInstrumentationSequence 3 CleanUpAllJobs 100]

# All done
TERMINATE

$ENDTESTSCHEDULE
