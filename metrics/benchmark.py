import http.client

from datetime import datetime, timedelta
from prometheus_client.parser import text_string_to_metric_families
from prometheus_client.samples import Sample

class Event:

    def __init__(self, id):
        self.id = id
        self.valid = True
        self.received = None
        self.validated = None
        self.written = None
        self.ordering_received = None
        self.svdc_received = None
        self.processed = None

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
                    case Sample(labels={'event_id': evt_id, 'timestamp': ts}):
                        # create or find event
                        if evt_id not in events:
                            evt = Event(evt_id)
                            events[evt_id] = evt
                        else:
                            evt = events[evt_id]

                        d = datetime.fromisoformat(ts[:-1])

                        if sample.name == 'reception_event_received_total':
                            evt.received = d
                        elif sample.name == 'reception_event_valid_total':
                            evt.validated = d
                        elif sample.name == 'reception_event_invalid_total':
                            evt.validated = d
                            evt.valid = False
                        elif sample.name == 'reception_event_written_total':
                            evt.written = d
                        elif sample.name == 'aeordering_events_processed_total':
                            evt.ordering_received = d
                        elif sample.name == 'svdc_event_received_total':
                            evt.svdc_received = d
                        elif sample.name == 'svdc_event_processed_total':
                            evt.processed = d

        evts = events.values()
        print(f'Total number of events: {len(evts)}')
        print(f'Total number of events (Received by Reception): {len(list(filter(lambda e: e.received is not None, evts)))}')
        print(f'Total number of events (Written by Reception): {len(list(filter(lambda e: e.written is not None, evts)))}')
        print(f'Total number of events (Loaded by Ordering): {len(list(filter(lambda e: e.ordering_received is not None, evts)))}')
        print(f'Total number of events (Received by SVDC): {len(list(filter(lambda e: e.svdc_received is not None, evts)))}')
        print(f'Total number of events (Processed by SVDC): {len(list(filter(lambda e: e.processed is not None, evts)))}')

        evts = list(filter(lambda e: e.received is not None and e.processed is not None, evts))
        print(f'Total number of events (in calc): {len(evts)}')
        if len(evts) > 0:
            td = max(map(lambda e: e.processed or datetime.min, evts)) - min(map(lambda e: e.received or datetime.max, evts))
            print(f'Total time: {td.total_seconds():.3f}')
            print(f'Events per second: {len(evts) / td.total_seconds():.3f}')
            print(f'Average time per event: {sum(map(lambda e: (e.written - e.received).total_seconds(), evts)) / len(evts):.3f}')
            print(f'Average validation time per event: {sum(map(lambda e: (e.validated - e.received).total_seconds() if e.validated else 0, evts)) / len(evts):.3f}')
            print(f'Average filesystem time per event: {sum(map(lambda e: (e.ordering_received - e.written).total_seconds(), evts)) / len(evts):.3f}')
            print(f'Average ordering time per event: {sum(map(lambda e: (e.svdc_received - e.svdc_received).total_seconds(), evts)) / len(evts):.3f}')
            print(f'Average verification time per event: {sum(map(lambda e: (e.processed - e.svdc_received).total_seconds(), evts)) / len(evts):.3f}')

    else:
        print('Request failed')
