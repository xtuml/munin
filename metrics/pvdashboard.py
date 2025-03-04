import argparse
import datetime
import json
import os
import re
import stomp
import sys
import time
from string import Template

class AMQPStatistics(object):

    def __init__(self):
        self.conn = stomp.Connection([(host, int(port))])
        #self.conn.set_ssl(for_hosts=[(host, int(port))], key_file='/tmp/client.key', cert_file='/tmp/client.pem', ca_certs='/tmp/broker.pem')
        self.conn.connect(username='ProtocolVerifier', passcode='ProtocolVerifier', wait=True)

    def on_message(self, message):
        # process Statistics message
        report.consume_statistics(message.body.rstrip())

    def receive_from_queue(self):
        self.conn.set_listener('AMQPStatistics', AMQPStatistics())
        self.conn.subscribe('Protocol_Verifier_Statistics', 21)

class AMQPInfoWarn(object):

    def __init__(self):
        self.conn = stomp.Connection([(host, int(port))])
        #self.conn.set_ssl(for_hosts=[(host, int(port))], key_file='/tmp/client.key', cert_file='/tmp/client.pem', ca_certs='/tmp/broker.pem')
        self.conn.connect(username='ProtocolVerifier', passcode='ProtocolVerifier', wait=True)

    def on_message(self, message):
        # process InfoWarn message
        report.consume_infowarn(message.body.rstrip())

    def receive_from_queue(self):
        self.conn.set_listener('AMQPInfoWarn', AMQPInfoWarn())
        self.conn.subscribe('Protocol_Verifier_InfoWarn', 22)

class AMQPReception(object):

    def __init__(self):
        self.conn = stomp.Connection([(host, int(port))])
        #self.conn.set_ssl(for_hosts=[(host, int(port))], key_file='/tmp/client.key', cert_file='/tmp/client.pem', ca_certs='/tmp/broker.pem')
        self.conn.connect(username='ProtocolVerifier', passcode='ProtocolVerifier', wait=True)

    def on_message(self, message):
        # process Reception message
        report.preReceivedAuditEventCount += 1

    def receive_from_queue(self):
        self.conn.set_listener('AMQPReception', AMQPReception())
        self.conn.subscribe('Protocol_Verifier_Reception', 23)

class Report:

    def __init__(self, id):
        self.id = id
        self.job_success = 0
        self.job_fail = 0
        self.job_alarm = 0
        self.lastSuccessfulJob = ""
        self.lastFailedJob = ""
        self.lastAlarmedJob = ""
        self.preReceivedAuditEventCount = 0
        self.receivedAuditEventCount = 0
        self.employedWorkers = 0
        self.assignedJobs = 0
        self.unassignedJobs = 0
        self.buildName = ""
        self.buildVersion = ""
        self.upTime = "PT0S"
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
                    self.buildName = payload['buildName']
                    self.buildVersion = payload['buildVersion']
                    self.upTime = payload['upTime']
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
            else:
                print( s, file=sys.stderr )
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
lastSuccessfulJob: \033[0;32;40m$lastSuccessfulJob\033[0;0m
lastFailedJob: \033[0;33;40m$lastFailedJob\033[0;0m
lastAlarmedJob: \033[0;31;40m$lastAlarmedJob\033[0;0m
rcvd_events: \033[0;96;40m$rcvd_events\033[0;0m  msgin_rate: \033[0;96;40m$in_rate\033[0;0m  throughput: \033[0;95;40m$throughput\033[0;0m  up_time: $upTime
build_name: $buildName  version: $buildVersion
employedWorkers: $employedWorkers  assignedJobs: $assignedJobs  unassignedJobs: $unassignedJobs
"""
        tobj1 = Template(lines1)
        uptime = parse_isoduration(report.upTime, True)
        upstring = ''
        upseconds = 1
        if uptime['days'] != 0:
            upstring = str(uptime['days']) + " days "
            upseconds = upseconds + uptime['days'] * 86400
        if uptime['hours'] != 0:
            upstring = upstring + str(uptime['hours']) + " hours "
            upseconds = upseconds + uptime['hours'] * 3600
        if uptime['minutes'] != 0:
            upstring = upstring + str(uptime['minutes']) + " minutes "
            upseconds = upseconds + uptime['minutes'] * 60
        if uptime['seconds'] != 0:
            upstring = upstring + str(int(uptime['seconds'])) + " seconds "
            upseconds = upseconds + uptime['seconds']
        throughput = int(report.receivedAuditEventCount / upseconds)
        h = tobj1.substitute(job_alarm=report.job_alarm,
                            job_fail=report.job_fail,
                            job_success=report.job_success,
                            lastAlarmedJob=report.lastAlarmedJob,
                            lastFailedJob=report.lastFailedJob,
                            lastSuccessfulJob=report.lastSuccessfulJob,
                            rcvd_events=report.receivedAuditEventCount,
                            in_rate=int(report.preReceivedAuditEventCount / upseconds),
                            buildName=report.buildName,
                            buildVersion=report.buildVersion,
                            upTime=upstring,
                            throughput=throughput,
                            employedWorkers=report.employedWorkers,
                            assignedJobs=report.assignedJobs,
                            unassignedJobs=report.unassignedJobs)
        print( h, end='', flush=True )
        for worker in report.workerAssignments:
            print( "w_jobs:", str(worker), ' ', end='', flush=True )
        print()
        for wcount in report.workerEventCounts:
            print( "w_ecount:", str(wcount), ' ', end='', flush=True )

def parse_isoduration(isostring, as_dict=False):
    """
    Parse the ISO8601 duration string as hours, minutes, seconds
    """
    separators = {
        "PT": None,
        "W": "weeks",
        "D": "days",
        "H": "hours",
        "M": "minutes",
        "S": "seconds",
    }
    duration_vals = {}
    for sep, unit in separators.items():
        partitioned = isostring.partition(sep)
        if partitioned[1] == sep:
            # Matched this unit
            isostring = partitioned[2]
            if sep == "PT":
                continue # Successful prefix match
            dur_str = partitioned[0]
            dur_val = float(dur_str) if "." in dur_str else int(dur_str)
            duration_vals.update({unit: dur_val})
        else:
            if sep == "PT":
                raise ValueError("Missing PT prefix")
            else:
                # No match for this unit: it's absent
                duration_vals.update({unit: 0})
    if as_dict:
        return duration_vals
    else:
        return tuple(duration_vals.values())


if __name__ == '__main__':
    parser = argparse.ArgumentParser(prog='pvdashboard.py', description='dashboard for Protocol Verifier')
    parser.add_argument('--amqpbroker', required=True, help='Specify the AMQP message broker <host:port>')
    args = parser.parse_args()

    host, port = args.amqpbroker.split(':')

    # initialise a report
    report = Report(1)

    t0 = time.monotonic()
    os.system('cls' if os.name == 'nt' else 'clear')

    amqp_statistics = AMQPStatistics()
    amqp_infowarn = AMQPInfoWarn()
    #amqp_reception = AMQPReception()
    amqp_statistics.receive_from_queue()
    amqp_infowarn.receive_from_queue()
    #amqp_reception.receive_from_queue()

    while True:
        # log periodically
        t1 = time.monotonic()
        if ( t1 - t0 ) > 1:
            os.system('cls' if os.name == 'nt' else 'clear')
            report.report()
            t0 = t1

