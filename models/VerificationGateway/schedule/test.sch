# Run normal path tests
RUN SCENARIO Test 1 "run_test" [VerificationGateway Test001BasicPVInstrumentationSequence 1 CleanUpAllJobs 100]
RUN SCENARIO Test 1 "run_test" [VerificationGateway Test002MultipleHappyJobs_OneJobAfterAnother 2 CleanUpAllJobs 100]
RUN SCENARIO Test 1 "run_test" [VerificationGateway Test003MultipleHappyJobs_EventsInterleaved 3 CleanUpAllJobs 100]
RUN SCENARIO Test 1 "run_test" [VerificationGateway Test004MultipleHappyJobs_EventsInterleaved_WithJobDeletion 4 CleanUpAllJobs 100]
RUN SCENARIO Test 1 "run_test" [VerificationGateway Test051UnhappyJob_SequenceVerificationFailsAndTerminates 51 CleanUpAllJobs 100]
RUN SCENARIO Test 1 "run_test" [VerificationGateway Test052UnhappyJob_AEOReportsJobFailDuringSequenceVerificationThenTerminates 52 CleanUpAllJobs 100]
RUN SCENARIO Test 1 "run_test" [VerificationGateway Test053UnhappyJob_AEOReportsJobFailDuringSequenceVerificationButContinues 53 CleanUpAllJobs 100]

# All done
TERMINATE
