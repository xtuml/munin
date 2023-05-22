This folder contains puml files that form the basis of a test suite for the Protocol Verifier. They are being built up with individual features and then combinations of features. They are named in the style <<JobDefinitionName>>.puml. When used with plus2json use the following options:

-j --outdir config/job_definitions	- this generates <<Job Definition Name>>.json containing the event and event data defintions for the job
--play 	--outdir reception-incoming	- this generates a happy path set of event instances and drops them into the PV input port


The ExtraJobInvariantSource.puml file must be used before any files containing a user extra job invariant. Otherwise the order of the files is not significant.

SimpleSequenceJob.puml
ComplexNoEventDataJob.puml
IntraJobInvariantJob1.puml
IntraJobInvariantJob2.puml
ExtraJobInvariantSourceJob.puml
ExtraJobInvariantUserJob1.puml
ExtraJobInvariantUserJob2.puml
LoopCountJob.puml
BranchCountJob1.puml
BranchCountJob2.puml
ComplexIntraInvariantJob.puml
SimpleIntraInvariantJob.puml
MultiSequenceJob1.puml
MultiSequenceJob2.puml
MultiSeqComplexJob1.puml
MultiAEDataOnEventJob1.puml

This list will grow over time and hopefully can become the basis of end-to-end regression tests.