from junit_xml import TestSuite, TestCase
from isodate import parse_duration
import json
import os
import sys
import datetime


OUTPUT_DIR = 'target/surefire-reports'


def gen_report():

    testcases = dict()
    summary = dict()
    now = datetime.datetime.utcnow()

    for root, _, files in os.walk('./results'):
        for results_file in filter(lambda f: f.endswith('.json'), files):
            with open(os.path.join(root, results_file)) as f:
                results = json.load(f)
                if not isinstance(results, list):
                    results = [results]
                for result in results:
                    match result:
                        case {'suiteName': suiteName, 'testName': testName, 'result': status, 'timestamp': timestamp, 'duration': duration}:
                            duration = parse_duration(duration)
                            summary['tests'] = summary['tests'] + \
                                1 if 'tests' in summary else 1
                            log = result['details'] if 'details' in result and status not in [
                                'SUCCEEDED', 'SKIPPED'] else ''
                            if '-check' in sys.argv and status in ['FAILED', 'ERROR']:
                                sys.exit(1)
                            if suiteName not in testcases:
                                testcases[suiteName] = []
                            tc = TestCase(
                                testName, timestamp=timestamp,
                                elapsed_sec=duration.total_seconds())
                            if status == 'FAILED':
                                tc.add_failure_info(message=next(
                                    iter(log.splitlines()), ''), output=log)
                                summary['failures'] = summary['failures'] + \
                                    1 if 'failures' in summary else 1
                            elif status == 'ERROR':
                                tc.add_error_info(message=next(
                                    iter(log.splitlines()), ''), output=log)
                                summary['errors'] = summary['errors'] + \
                                    1 if 'errors' in summary else 1
                            elif status == 'SKIPPED':
                                tc.add_skipped_info()
                                summary['skipped'] = summary['skipped'] + \
                                    1 if 'skipped' in summary else 1
                            testcases[suiteName].append(tc)
                        case _:
                            pass  # ignoring other JSON objects

    if '-check' not in sys.argv:
        results_path = os.path.join(OUTPUT_DIR, f'{sys.argv[1].replace("/", "_")}-{now.strftime("%Y-%m-%d-%H%M%S")}-results.xml')
        os.makedirs(os.path.dirname(results_path), exist_ok=True)
        with open(results_path, 'w') as f:
            f.write(TestSuite.to_xml_string(
                [TestSuite(suiteName, sorted(testcases[suiteName], key=lambda tc: tc.name),
                    timestamp=now)
                 for suiteName in testcases]))
        summary_path = os.path.join(OUTPUT_DIR, f'{sys.argv[1].replace("/", "_")}-{now.strftime("%Y-%m-%d-%H%M%S")}-summary.json')
        os.makedirs(os.path.dirname(summary_path), exist_ok=True)
        with open(summary_path, 'w') as f:
            summary['timestamp'] = now.isoformat()
            summary['branch'] = sys.argv[1]
            summary['sha'] = sys.argv[2]
            json.dump(summary, f)


if __name__ == '__main__':
    os.makedirs(OUTPUT_DIR, exist_ok=True)
    gen_report()
