import argparse
import datetime
import kafka3
import json
import os
import re
import sys
import time
from string import Template

class Report:

    def __init__(self, id):
        self.id = id
        self.job_success = 0
        self.job_fail = 0
        self.job_alarm = 0
        self.lastSuccessfulJob = ""
        self.lastFailedJob = ""
        self.lastAlarmedJob = ""
        self.receivedAuditEventCount = 0
        self.employedWorkers = 0
        self.assignedJobs = 0
        self.unassignedJobs = 0
        self.workerAssignments = []
        self.workerEventCounts = []

    def poll_for_messages(self, s):
        ''' Poll the message broker and process messages. '''

    def consume_statistics(self, s):
        ''' Consume a message and gather job manager statistics. '''
        try:
            if 'jobmanagement_stats' in s:
                try:
                    j = json.loads(s)
                except json.decoder.JSONDecodeError:
                    print(f'INVALID JSON')
                    sys.exit(1)
                else:
                    payload = j['payload']
                    self.employedWorkers = payload['employedWorkers']
                    self.assignedJobs = payload['assignedJobs']
                    self.unassignedJobs = payload['unassignedJobs']
                    self.receivedAuditEventCount = payload['receivedAuditEventCount']
                    worker_stats = payload['workerStats']
                    i = 0
                    if worker_stats:
                        for worker in worker_stats:
                            if len(self.workerAssignments) < self.employedWorkers:
                                self.workerAssignments.append(worker['assignedJobCount'])
                                self.workerEventCounts.append(worker['reportedAuditEventCount'])
                            else:
                                self.workerAssignments[i] = worker['assignedJobCount']
                                self.workerEventCounts[i] = worker['reportedAuditEventCount']
                                i += 1
                    i = 0
        except ValueError:
            return

    def consume_infowarn(self, s):
        ''' Consume a message and gather job results. '''
        j = None
        if 'job_fail' in s or 'job_success' in s or 'job_alarm' in s:
            try:
                j = json.loads(s)
            except json.decoder.JSONDecodeError:
                print("INVALID JSON", s)
                sys.exit(1)
            else:
                payload = j['payload']
                if 'job_fail' in s:
                    self.job_fail += 1
                    self.lastFailedJob = payload['jobName']
                    print( s, file=sys.stderr )
                elif 'job_alarm' in s:
                    self.job_alarm += 1
                    self.lastAlarmedJob = payload['jobName']
                    print( s, file=sys.stderr )
                elif 'job_success' in s:
                    self.job_success += 1
                    self.lastSuccessfulJob = payload['jobName']
        else:
            print( s, file=sys.stderr )

    def report(self):
        ''' Report the status of the Protocol Verifier to a templated string. '''
        lines1 = """
job_success: \033[0;32;40m$job_success\033[0;0m job_fail: \033[0;33;40m$job_fail\033[0;0m job_alarm: \033[0;31;40m$job_alarm\033[0;0m
rcvd_events: $rcvd_events  employedWorkers: $employedWorkers  assignedJobs: $assignedJobs  unassignedJobs: $unassignedJobs
"""
        tobj1 = Template(lines1)
        h = tobj1.substitute(job_alarm=report.job_alarm,
                            job_fail=report.job_fail,
                            job_success=report.job_success,
                            rcvd_events=report.receivedAuditEventCount,
                            employedWorkers=report.employedWorkers,
                            assignedJobs=report.assignedJobs,
                            unassignedJobs=report.unassignedJobs)
        print( h, end='', flush=True )
        for worker in report.workerAssignments:
            print( "w_jobs:", str(worker), ' ', end='', flush=True )
        print()
        for wcount in report.workerEventCounts:
            print( "w_ecount:", str(wcount), ' ', end='', flush=True )
        lines2 = """
lastSuccessfulJob: \033[0;32;40m$lastSuccessfulJob\033[0;0m
lastFailedJob: \033[0;33;40m$lastFailedJob\033[0;0m
lastAlarmedJob: \033[0;31;40m$lastAlarmedJob\033[0;0m
"""
        tobj2 = Template(lines2)
        h = tobj2.substitute(lastAlarmedJob=report.lastAlarmedJob,
                            lastFailedJob=report.lastFailedJob,
                            lastSuccessfulJob=report.lastSuccessfulJob)
        print( h, end='', flush=True )


if __name__ == '__main__':
    parser = argparse.ArgumentParser(prog='infowarn.py', description='dashboard for protocol verifier')
    parser.add_argument('--msgbroker', required=True, help='Specify the message broker <host:port>')
    parser.add_argument('--topic', required=False, help='Specify topic')
    args = parser.parse_args()

    consumer = kafka3.KafkaConsumer(bootstrap_servers=args.msgbroker, auto_offset_reset='earliest')
    consumer.subscribe( ['Protocol_Verifier_Statistics','Protocol_Verifier_InfoWarn'] )

    # initialise a report
    report = Report(1)

    t0 = time.monotonic()
    os.system('cls' if os.name == 'nt' else 'clear')
    # process messages
    raw_msgs = consumer.poll(timeout_ms=20000)
    while len(raw_msgs) > 0:
        for tp, partition in raw_msgs.items():
            for msg in partition:
                s = msg.value.decode('utf-8').rstrip()
                if tp.topic == 'Protocol_Verifier_Statistics':
                    report.consume_statistics(s)
                elif tp.topic == 'Protocol_Verifier_InfoWarn':
                    report.consume_infowarn(s)
        # log periodically
        t1 = time.monotonic()
        if ( t1 - t0 ) > 1:
            os.system('cls' if os.name == 'nt' else 'clear')
            report.report()
            t0 = t1

        raw_msgs = consumer.poll(timeout_ms=8000)
