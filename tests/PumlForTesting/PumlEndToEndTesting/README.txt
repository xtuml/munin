This folder contains puml files that form the basis of a test suite for the Protocol Verifier. They are being built up with individual features and then combinations of features. They are named in the style <<Job Definition Name>>.puml. When used with plus2json the output files for the different options should be:

--job	<<Job Definition Name>>.json 		- the event defintions for the job
-d	<<Job Definition Name_event_data>>.json - the event data definitions for the job
--play 	<<Job Definition Name_instances>>.json	- example event instances

The first 2 files are dropped into munin/deploy/plus2json-deployed/generated-config. This configures the PV. The config.json file has to contain the same set of job definition names as are in the files in that folder.

The last file is dropped into munin/deploy/aer-incoming which acts as the example instance data to be consumed by the running PV.

The files should be used in the following order:

Simple Sequence Job.puml
Complex No Event Data Job.puml
Intra Job Invariant Job.puml
Extra Job Invariant Source Job.puml
Extra Job Invariant User Job.puml
Loop Count Job.puml
Branch Count Job 1.puml
Branch Count Job 2.puml
Complex Intra Invariant Job.puml

This list will grow over time and hopefully can become the basis of end-to-end regression tests.