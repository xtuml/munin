import argparse
import datetime
import kafka3
import json

KEY_EVENTS = ('jobmanagement_event_received', 'aeordering_event_processed', 'svdc_event_processed', 'svdc_happy_event_processed', 'svdc_unhappy_event_processed')

class Event:

    def __init__(self, id):
        self.id = id
        self.received = None
        self.ordering_received = None
        self.processed = None


if __name__ == '__main__':
    parser = argparse.ArgumentParser(prog='benchmark.py', description='TODO')
    parser.add_argument('--msgbroker', required=True, help='Specify the message broker <host:port>')
    parser.add_argument('--topic', required=True, help='Specify topic')
    args = parser.parse_args()

    consumer = kafka3.KafkaConsumer(bootstrap_servers=args.msgbroker, auto_offset_reset='earliest')
    consumer.subscribe(args.topic)

    # process messages
    events = {}
    raw_msgs = consumer.poll(timeout_ms=4000)
    while len(raw_msgs) > 0:
        for k, partition in raw_msgs.items():
            for msg in partition:
                data = bytearray(msg.value)
                try:
                    j = json.loads(data.decode('utf-8'))
                except json.decoder.JSONDecodeError:
                    print(f'INVALID JSON')
                    sys.exit(1)
                else:
                    payload = j['payload']
                    label = payload['tag']
                    evt_id = payload['eventId']
                    d = datetime.datetime.strptime(j['timestamp'], "%Y-%m-%dT%H:%M:%S.%fZ")
                if label in KEY_EVENTS:

                    # create or find event
                    if evt_id not in events:
                        evt = Event(evt_id)
                        events[evt_id] = evt
                    else:
                        evt = events[evt_id]

                    if label == 'jobmanagement_event_received':
                        evt.received = d
                    elif label == 'aeordering_event_processed':
                        evt.ordering_received = d
                    elif label in ('svdc_event_processed', 'svdc_happy_event_processed', 'svdc_unhappy_event_processed'):
                        evt.processed = d

        raw_msgs = consumer.poll(timeout_ms=4000)

    evts = events.values()
    print(f'Total number of events: {len(evts)}')
#    print(f'Total number of events (Received by JobManagement): {len(list(filter(lambda e: e.received is not None, evts)))}')
    print(f'Total number of events (Loaded by Ordering): {len(list(filter(lambda e: e.ordering_received is not None, evts)))}')
    print(f'Total number of events (Processed by SVDC): {len(list(filter(lambda e: e.processed is not None, evts)))}')

    evts = list(filter(lambda e: e.ordering_received is not None and e.processed is not None, evts))
    print(f'Total number of events (in calc): {len(evts)}')
    if len(evts) > 0:
        td = max(map(lambda e: e.processed or datetime.min, evts)) - min(map(lambda e: e.ordering_received or datetime.max, evts))
        print(f'Total time: {td.total_seconds():.3f}')
        print(f'Events per second: {len(evts) / td.total_seconds():.3f}')
        print(f'Average time in PV per event: {sum(map(lambda e: (e.processed - e.ordering_received).total_seconds(), evts)) / len(evts):.3f}s')
