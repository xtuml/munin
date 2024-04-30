import argparse
import datetime
import kafka3
import json
import os
import time
import re
from string import Template

class Report:

    def __init__(self, id):
        self.id = id
        self.job_success = 0
        self.job_fail = 0
        self.receivedAuditEventCount = 0
        self.employed_workers = 0
        self.assignedJobs = 0
        self.worker_assignments = []
        self.worker_event_counts = []

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
                    self.employed_workers = payload['employedWorkers']
                    self.assignedJobs = payload['assignedJobs']
                    self.receivedAuditEventCount = payload['receivedAuditEventCount']
                    worker_stats = payload['workerStats']
                    i = 0
                    for worker in worker_stats:
                        if len(self.worker_assignments) < self.employed_workers:
                            self.worker_assignments.append(worker['assignedJobCount'])
                            self.worker_event_counts.append(worker['reportedAuditEventCount'])
                        else:
                            self.worker_assignments[i] = worker['assignedJobCount']
                            self.worker_event_counts[i] = worker['reportedAuditEventCount']
                            i += 1
                    i = 0
        except ValueError:
            return

    def consume_infowarn(self, s):
        ''' Consume a message and gather job results. '''
        if 'job_fail' in s:
            self.job_fail += 1
            print( s )
        elif 'job_success' not in s:
            print( s )
        elif 'job_success' in s:
            self.job_success += 1

    def report(self):
        ''' Report the status of the Protocol Verifier to a templated string. '''
        tstr = """
job_fail: \033[0;31;40m$job_fail\033[0;0m  job_success: \033[0;32;40m$job_success\033[0;0m
rcvd_events: $rcvd_events  employed_workers: $employed_workers  assignedJobs: $assignedJobs
"""
        tobj = Template(tstr)
        h = tobj.substitute(job_fail=report.job_fail,
                           job_success=report.job_success,
                           rcvd_events=report.receivedAuditEventCount,
                           employed_workers=report.employed_workers,
                           assignedJobs=report.assignedJobs)
        print( h, end='', flush=True )
        for worker in report.worker_assignments:
            print( "w_jobs:", str(worker), ' ', end='', flush=True )
        print()
        for wcount in report.worker_event_counts:
            print( "w_ecount:", str(wcount), ' ', end='', flush=True )
        print()


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
