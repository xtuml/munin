import json
import os
import datetime

from string import Template


OUTPUT_DIR = 'target/site'


def gen_history():

    now = datetime.datetime.utcnow()
    rows = []
    branch = ''

    for root, _, files in os.walk('./summaries'):
        for summary_file in filter(lambda f: f.endswith('.json'), files):
            with open(os.path.join(root, summary_file)) as f:
                summary = json.load(f)
                branch = summary['branch'] if 'branch' in summary else ''
                errors = summary['errors'] if 'errors' in summary else 0
                failures = summary['failures'] if 'failures' in summary else 0
                skipped = summary['skipped'] if 'skipped' in summary else 0
                total_tests = summary['tests'] if 'tests' in summary else 0
                success = round(
                    (total_tests - sum([errors, failures, skipped])) * 100 / total_tests, 2) if total_tests > 0 else 0
                rows.append({'date': summary['timestamp'], 'sha': summary['sha'],
                             'total_tests': total_tests, 'errors': errors,
                             'failures': failures, 'skipped': skipped, 'success': success})

    history_template = None
    with open('templates/history.html') as f:
        history_template = Template(f.read())
    row_template = None
    with open('templates/summary-row.html') as f:
        row_template = Template(f.read())

    rows = sorted(rows, key=lambda r: r['date'], reverse=True)

    with open(os.path.join(OUTPUT_DIR, 'history.html'), 'w') as f:
        f.write(history_template.substitute(
            {'date': now.isoformat(), 'branch': branch, 'summary_rows': '\n'.join(map(row_template.substitute, rows))}))


if __name__ == '__main__':
    os.makedirs(OUTPUT_DIR, exist_ok=True)
    gen_history()
