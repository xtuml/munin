$TESTSCHEDULE

# initialize domain
RUN SCENARIO AESequenceDC 1 "InitEventDefinition"
RUN SCENARIO AESequenceDC 2 "InitCyclicTopologyEventDefinition"
RUN SCENARIO AESequenceDC 3 "InitSystemSpec"
RUN SCENARIO AESequenceDC 4 "InitForkAndMergeTopologyEventDefinition"
RUN SCENARIO AESequenceDC 5 "InitIntraJobInvariantDefinition"
RUN SCENARIO AESequenceDC 7 "InitPersistentInvariantAuthAndBankTransferDefinition"
RUN SCENARIO AESequenceDC 8 "InitEventDefinitionForInclusiveOR"
RUN SCENARIO AESequenceDC 9 "InitLoopBreakEventDefinition"
RUN SCENARIO AESequenceDC 501 "InitComplexEventSequence1Definition"
RUN SCENARIO AESequenceDC 502 "InitComplexEventSequence2Definition"
RUN SCENARIO AESequenceDC 10 "InitLoopCountDefinition"
RUN SCENARIO AESequenceDC 901 "InitBranchCountDefinition"


# run normal path tests
RUN SCENARIO Test 1 "run_test" [AESequenceDC Test01NormalPath 1001 CleanUpAllJobs 64]
RUN SCENARIO Test 1 "run_test" [AESequenceDC Test02NormalPath 1002 CleanUpAllJobs 64]
RUN SCENARIO Test 1 "run_test" [AESequenceDC Test03NormalPath 1003 CleanUpAllJobs 64]

# normal cyclic path tests
RUN SCENARIO Test 1 "run_test" [AESequenceDC Test04NormalCyclicPath 1004 CleanUpAllJobs 64]
RUN SCENARIO Test 1 "run_test" [AESequenceDC Test05NormalCyclicPath 1005 CleanUpAllJobs 64]
RUN SCENARIO Test 1 "run_test" [AESequenceDC Test06NormalCyclicPath 1006 CleanUpAllJobs 64]
RUN SCENARIO Test 1 "run_test" [AESequenceDC Test07NormalCyclicPath 1007 CleanUpAllJobs 64]

# Further normal test cases
RUN SCENARIO Test 1 "run_test" [AESequenceDC Test08NormalPath 1008 CleanUpAllJobs 64]
RUN SCENARIO Test 1 "run_test" [AESequenceDC Test10NormalPath 1010 CleanUpAllJobs 64]
RUN SCENARIO Test 1 "run_test" [AESequenceDC Test11NormalPath 1011 CleanUpAllJobs 64]

# Fork and Merge normal test cases
RUN SCENARIO Test 1 "run_test" [AESequenceDC Test12NormalForkAndMergePath 1012 CleanUpAllJobs 64]
RUN SCENARIO Test 1 "run_test" [AESequenceDC Test13NormalInstanceForkAndMergePath 1013 CleanUpAllJobs 64]
# The following test is now invalid because invariants have been added to the defintions
#RUN SCENARIO Test 1 "run_test" [AESequenceDC Test14NormalSplitForkAndMergePath 1014 CleanUpAllJobs 64]
RUN SCENARIO Test 1 "run_test" [AESequenceDC Test15NormalSplitInstanceForkAndMergePath 1015 CleanUpAllJobs 64]
RUN SCENARIO Test 1 "run_test" [AESequenceDC Test16NormalInstanceAndTypeForkAndMergePath 1016 CleanUpAllJobs 64]
RUN SCENARIO Test 1 "run_test" [AESequenceDC Test17NormalXORConstraint 1017 CleanUpAllJobs 64]
RUN SCENARIO Test 1 "run_test" [AESequenceDC Test21NormalIntraJobInvariant 1021 CleanUpAllJobs 64]
RUN SCENARIO Test 1 "run_test" [AESequenceDC Test22NormalSourceExtraJobInvariant 1022 CleanUpAllJobs 64]
RUN SCENARIO Test 1 "run_test" [AESequenceDC Test23NormalUserExtraJobInvariant 1023 CleanUpAllJobs 64]
RUN SCENARIO Test 1 "run_test" [AESequenceDC Test24MultipleInForcePersistentInvariant 1024 CleanUpAllJobs 64]
RUN SCENARIO Test 1 "run_test" [AESequenceDC Test25NormalLoopWithBreakPath 1025 CleanUpAllJobs 64]
RUN SCENARIO Test 1 "run_test" [AESequenceDC Test26NormalLoopWithLoopCount 1026 CleanUpAllJobs 64]
RUN SCENARIO Test 1 "run_test" [AESequenceDC Test27NormalInstanceForkWithBranchCount 1027 CleanUpAllJobs 64]
RUN SCENARIO Test 1 "run_test" [AESequenceDC Test28NormalLoopWithBreakNotTaken 1028 CleanUpAllJobs 64]
RUN SCENARIO Test 1 "run_test" [AESequenceDC Test29NormalBranchCountWithSameSourceAndUserEvent 1029 CleanUpAllJobs 64]
# Complex sequence tests
RUN SCENARIO Test 1 "run_test" [AESequenceDC Test70ComplexSequence_SunnyDay1 1070 CleanUpAllJobs 64]
RUN SCENARIO Test 1 "run_test" [AESequenceDC Test71ComplexSequence_SunnyDay2 1071 CleanUpAllJobs 64]
RUN SCENARIO Test 1 "run_test" [AESequenceDC Test72ComplexSequence_SunnyDay3 1072 CleanUpAllJobs 64]

# Suspend & Reactivate JobDefinition test cases
RUN SCENARIO Test 1 "run_test" [AESequenceDC Test20StartOfNewJobForSuspendedJobDefinition 1020 CleanUpAllJobs 64]

# test that detect errors in the CDS

RUN SCENARIO Test 1 "run_test" [AESequenceDC Test31ErrorDetection 1031 CleanUpAllJobs 64]
RUN SCENARIO Test 1 "run_test" [AESequenceDC Test32ErrorDetection 1032 CleanUpAllJobs 64]
RUN SCENARIO Test 1 "run_test" [AESequenceDC Test33ErrorDetection 1033 CleanUpAllJobs 64]
RUN SCENARIO Test 1 "run_test" [AESequenceDC Test34ErrorDetection 1034 CleanUpAllJobs 64]
RUN SCENARIO Test 1 "run_test" [AESequenceDC Test35ErrorDetection 1035 CleanUpAllJobs 64]
RUN SCENARIO Test 1 "run_test" [AESequenceDC Test36ErrorDetection 1036 CleanUpAllJobs 64]
RUN SCENARIO Test 1 "run_test" [AESequenceDC Test37ErrorDetection 1037 CleanUpAllJobs 64]
RUN SCENARIO Test 1 "run_test" [AESequenceDC Test38AnomalousCondition 1038 CleanUpAllJobs 64]
RUN SCENARIO Test 1 "run_test" [AESequenceDC Test39ErrorDetection 1039 CleanUpAllJobs 64]
RUN SCENARIO Test 1 "run_test" [AESequenceDC Test40FailedJob 1040 CleanUpAllJobs 64]
RUN SCENARIO Test 1 "run_test" [AESequenceDC Test41FailedJob 1041 CleanUpAllJobs 64]
RUN SCENARIO Test 1 "run_test" [AESequenceDC Test42FailedJob 1042 CleanUpAllJobs 64]
RUN SCENARIO Test 1 "run_test" [AESequenceDC Test43FailedJobDebatableCondition 1043 CleanUpAllJobs 64]
RUN SCENARIO Test 1 "run_test" [AESequenceDC Test44FailedJobDebatableCondition 1044 CleanUpAllJobs 64]
RUN SCENARIO Test 1 "run_test" [AESequenceDC Test45ErrorDetection 1045 CleanUpAllJobs 64]
RUN SCENARIO Test 1 "run_test" [AESequenceDC Test46ErrorDetectionForkAndMerge 1046 CleanUpAllJobs 64]
RUN SCENARIO Test 1 "run_test" [AESequenceDC Test47ErrorDetectionForkAndMerge 1047 CleanUpAllJobs 64]
RUN SCENARIO Test 1 "run_test" [AESequenceDC Test48ErrorDetectionIllegalSequenceEnd 1048 CleanUpAllJobs 64]
RUN SCENARIO Test 1 "run_test" [AESequenceDC Test49ErrorDetectionIllegalSequenceEnd 1049 CleanUpAllJobs 64]
RUN SCENARIO Test 1 "run_test" [AESequenceDC Test50ErrorDetectionInstanceForkAndMergePath 1050 CleanUpAllJobs 64]
RUN SCENARIO Test 1 "run_test" [AESequenceDC Test51ErrorDetectionInstanceForkAndMergePath 1051 CleanUpAllJobs 64]
RUN SCENARIO Test 1 "run_test" [AESequenceDC Test52ErrorDetectionInstanceAndTypeForkAndMergePath 1052 CleanUpAllJobs 64]
RUN SCENARIO Test 1 "run_test" [AESequenceDC Test53ErrorDetectionConstraintViolation 1053 CleanUpAllJobs 64]
RUN SCENARIO Test 1 "run_test" [AESequenceDC Test53aErrorDetectionANDConstraintViolation 1153 CleanUpAllJobs 64]
RUN SCENARIO Test 1 "run_test" [AESequenceDC Test54ErrorDetectionXORConstraintViolation 1054 CleanUpAllJobs 64]
RUN SCENARIO Test 1 "run_test" [AESequenceDC Test55InvalidIntraJobInvariant 1055 CleanUpAllJobs 64]
RUN SCENARIO Test 1 "run_test" [AESequenceDC Test56InvalidIntraJobInvariant 1056 CleanUpAllJobs 64]
RUN SCENARIO Test 1 "run_test" [AESequenceDC Test57MissingInvariants 1057 CleanUpAllJobs 64]
RUN SCENARIO Test 1 "run_test" [AESequenceDC Test58InvalidUserExtraJobInvariant 1058 CleanUpAllJobs 64]
RUN SCENARIO Test 1 "run_test" [AESequenceDC Test59InvalidUserExtraJobInvariant 1059 CleanUpAllJobs 64]
RUN SCENARIO Test 1 "run_test" [AESequenceDC Test60StalePersistedInvariant 1060 CleanUpAllJobs 64]
RUN SCENARIO Test 1 "run_test" [AESequenceDC Test61InvalidInstanceForkWithBranchCount 1061 CleanUpAllJobs 64]
RUN SCENARIO Test 1 "run_test" [AESequenceDC Test62InvalidLoopWithLoopCount 1062 CleanUpAllJobs 64]
RUN SCENARIO Test 1 "run_test" [AESequenceDC Test63InvalidLoopWithNonIntegerLoopCount 1063 CleanUpAllJobs 64]
# Errors in complex sequences
RUN SCENARIO Test 1 "run_test" [AESequenceDC Test100ComplexSequence_RainyDay1_XORconstraintViolation 1100 CleanUpAllJobs 64]
RUN SCENARIO Test 1 "run_test" [AESequenceDC Test101ComplexSequence_RainyDay2_InstanceForkViolation 1101 CleanUpAllJobs 64]
RUN SCENARIO Test 1 "run_test" [AESequenceDC Test102ComplexSequence_RainyDay3_LOOPCOUNTviolation 1102 CleanUpAllJobs 64]
RUN SCENARIO Test 1 "run_test" [AESequenceDC Test103ComplexSequence_RainyDay4_LOOPCOUNTandBRANCHCOUNTviolation 1103 CleanUpAllJobs 64]
RUN SCENARIO Test 1 "run_test" [AESequenceDC Test104ComplexSequence_RainyDay5_LOOPCOUNTandBRANCHCOUNTandXORviolation 1104 CleanUpAllJobs 64]
RUN SCENARIO Test 1 "run_test" [AESequenceDC Test105ComplexSequence_RainyDay6_InvalidExtraJobInvariantValueUsedInLoop 1105 CleanUpAllJobs 64]
RUN SCENARIO Test 1 "run_test" [AESequenceDC Test106ComplexSequence_RainyDay7_InvalidExtraJobInvariantValueUsedInInstanceFork 1106 CleanUpAllJobs 64]
RUN SCENARIO Test 1 "run_test" [AESequenceDC Test107ComplexSequence_RainyDay8_InvalidExtraJobInvariantNameUsedInLoop 1107 CleanUpAllJobs 64]
RUN SCENARIO Test 1 "run_test" [AESequenceDC Test108ComplexSequence_RainyDay9_InvalidExtraJobInvariantNameUsedInInstanceFork 1108 CleanUpAllJobs 64]


# The following Tests will delete some or all of the JobDefinitions so beware!!!!
RUN SCENARIO Test 1 "run_test" [AESequenceDC Test18DeprecationAndDeletionOfActiveJobDefinition 1018 CleanUpAllJobs 64]
RUN SCENARIO Test 1 "run_test" [AESequenceDC Test19StartOfNewJobForDeprecatedJobDefinition 1019 CleanUpAllJobs 64]

# DO NOT ADD TESTS BEYOND THIS POINT AS SPECIFICATION INSTANCES HAVE BEEN DAMAGED


# This final test cleans out all the event definitions and so occurs at the end
RUN SCENARIO Test 1 "run_test" [AESequenceDC Test09CorrectDeletionOfDefinitions 1009 CleanUpAllJobs 64]
# DO NOT ADD TESTS BEYOND THIS POINT AS SPECIFICATION INSTANCES HAVE BEEN DELETED

# done
TERMINATE

$ENDTESTSCHEDULE
