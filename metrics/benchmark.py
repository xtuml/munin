import datetime
import http.client

from prometheus_client.parser import text_string_to_metric_families
from prometheus_client.samples import Sample

class Event:

    def __init__(self, id):
        self.id = id
        self.valid = True
        self.received = None
        self.validated = None
        self.written = None

if __name__ == '__main__':
    conn = http.client.HTTPConnection('localhost', 9144)
    conn.request('GET', '/metrics')
    resp = conn.getresponse()
    if resp.status == 200:
        s = resp.read().decode('utf-8')

        events = {}

        for family in text_string_to_metric_families(s):
            for sample in family.samples:
                match sample:
                    case Sample(name='reception_event_received_total', labels={'event_id': evt_id, 'timestamp': ts}):
                        if evt_id not in events:
                            evt = Event(evt_id)
                            events[evt_id] = evt
                        else:
                            print('here')
                            evt = events[evt_id]
                        evt.received = datetime.datetime.fromisoformat(ts[:-1])
                    case Sample(name='reception_event_valid_total', labels={'event_id': evt_id, 'timestamp': ts}):
                        if evt_id not in events:
                            evt = Event(evt_id)
                            events[evt_id] = evt
                        else:
                            evt = events[evt_id]
                        evt.validated = datetime.datetime.fromisoformat(ts[:-1])
                    case Sample(name='reception_event_invalid_total', labels={'event_id': evt_id, 'timestamp': ts}):
                        if evt_id not in events:
                            evt = Event(evt_id)
                            events[evt_id] = evt
                        else:
                            evt = events[evt_id]
                        evt.validated = datetime.datetime.fromisoformat(ts[:-1])
                        evt.valid = False
                    case Sample(name='reception_event_written_total', labels={'event_id': evt_id, 'timestamp': ts}):
                        if evt_id not in events:
                            evt = Event(evt_id)
                            events[evt_id] = evt
                        else:
                            evt = events[evt_id]
                        evt.written = datetime.datetime.fromisoformat(ts[:-1])

        print(f'Total number of events: {len(events)}')
        td = max(map(lambda e: e.written, events.values())) - min(map(lambda e: e.received, events.values()))
        print(f'Total time: {td.total_seconds():.3f}')
        print(f'Events per second: {len(events) / td.total_seconds():.3f}')
        print(f'Average time per event: {sum(map(lambda e: (e.written - e.received).total_seconds(), events.values())) / len(events):.3f}')
        print(f'Average validation time per event: {sum(map(lambda e: (e.validated - e.received).total_seconds() if e.validated else 0, events.values())) / len(events):.3f}')
    else:
        print('Request failed')
