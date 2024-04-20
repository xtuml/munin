import argparse
import datetime
import kafka3
import json
import time
import re

class Report:

    def __init__(self, id):
        self.id = id
        self.job_success = 0
        self.job_fail = 0
        self.total_assigned_jobs = 0

    def poll_for_messages(self, s):
        ''' Poll the message broker and process messages. '''

    def consume_statistics(self, s):
        ''' Consume a message and gather job manager statistics. '''
        try:
            taji = s.index('Assigned Job Count = ')
            if taji > 0:
                s = s[taji+21:-1]
                comma = s.index(',')
                self.total_assigned_jobs = int(s[:comma])
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
        ''' Report the status of the Protocol Verifier. '''
        print( '\b\b\b\b\b\b\b\b\b\b\b\b\b\b\b\b\b\b\b\b\b\b\b\b\b\b\b\b\b\b\b\b\b\b\b\b\b\b\b\b\b\b\b\b\b\b\b\b\b', end='', flush=True )
        print( '\b\b\b\b\b\b\b\b\b\b\b\b\b\b\b\b\b\b\b\b\b\b\b\b\b\b\b\b\b\b\b\b\b\b\b\b\b\b\b\b\b\b\b\b\b\b\b\b\b', end='', flush=True )
        print( "job_fail:", str(report.job_fail), end='', flush=True )
        print( " job_success:", str(report.job_success), end='', flush=True )
        print( " total_assigned_jobs:", str(report.total_assigned_jobs), ' ', end='', flush=True )

if __name__ == '__main__':
    parser = argparse.ArgumentParser(prog='infowarn.py', description='dashboard for protocol verifier')
    parser.add_argument('--msgbroker', required=False, help='Specify the message broker <host:port>')
    parser.add_argument('--topic', required=False, help='Specify topic')
    args = parser.parse_args()

    consumer = kafka3.KafkaConsumer(bootstrap_servers=args.msgbroker, auto_offset_reset='earliest')
    consumer.subscribe( ['Protocol_Verifier_Statistics','Protocol_Verifier_InfoWarn'] )

    # initialise a report
    report = Report(1)

    t0 = time.monotonic()
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
        if ( t1 - t0 ) > 2:
            report.report()
            t0 = t1

        raw_msgs = consumer.poll(timeout_ms=2000)

