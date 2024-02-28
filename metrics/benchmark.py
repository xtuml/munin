import argparse
import datetime
import kafka3
import re


KEY_EVENTS = ('jobmanagement_event_received', 'jobmanagement_event_written', 'aeordering_events_processed', 'svdc_event_received', 'svdc_event_processed', 'svdc_happy_event_processed', 'svdc_unhappy_event_processed')
PATTERN = r'EventId = ([\da-fA-F]{8}-[\da-fA-F]{4}-[\da-fA-F]{4}-[\da-fA-F]{4}-[\da-fA-F]{12})'


def decode_data(data, datatypes):
    values = []
    for datatype in datatypes:

        if datatype == 'string':

            # check to make sure there is a length at the beginning of the field
            if len(data) < 4:
                raise ValueError

            # get the length
            length = int.from_bytes(data[:4], byteorder='big')
            data = data[4:]

            # check to make sure the data contains 'length' more bytes
            if len(data) < length:
                raise ValueError

            # extract the value
            values.append(data[:length].decode('utf-8'))
            data = data[length:]

        elif datatype == 'timestamp':

            # check to make sure there is enough remaining data
            if len(data) < 8:
                raise ValueError

            nanos = int.from_bytes(data[:8], byteorder='big')
            data = data[8:]

            seconds = nanos / 1e9
            values.append(datetime.datetime.fromtimestamp(seconds))

        else:
            raise ValueError

    return tuple(values)


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
                label, event_content, d = decode_data(data, ('string', 'string', 'timestamp'))
                if label in KEY_EVENTS:

                    # extract the UUID from the event content
                    match = re.search(PATTERN, event_content)
                    if match:
                        evt_id = match.group(1)
                    else:
                        continue

                    # create or find event
                    if evt_id not in events:
                        evt = Event(evt_id)
                        events[evt_id] = evt
                    else:
                        evt = events[evt_id]

                    if label == 'jobmanagement_event_received':
                        evt.received = d
                    elif label == 'jobmanagement_event_written':
                        evt.written = d
                    elif label == 'aeordering_events_processed':
                        evt.ordering_received = d
                    elif label == 'svdc_event_received':
                        evt.svdc_received = d
                    elif label in ('svdc_event_processed', 'svdc_happy_event_processed', 'svdc_unhappy_event_processed'):
                        evt.processed = d

        raw_msgs = consumer.poll(timeout_ms=4000)

    evts = events.values()
    print(f'Total number of events: {len(evts)}')
#    print(f'Total number of events (Received by JobManagement): {len(list(filter(lambda e: e.received is not None, evts)))}')
#    print(f'Total number of events (Written by JobManagement): {len(list(filter(lambda e: e.written is not None, evts)))}')
    print(f'Total number of events (Loaded by Ordering): {len(list(filter(lambda e: e.ordering_received is not None, evts)))}')
    print(f'Total number of events (Received by SVDC): {len(list(filter(lambda e: e.svdc_received is not None, evts)))}')
    print(f'Total number of events (Processed by SVDC): {len(list(filter(lambda e: e.processed is not None, evts)))}')

    evts = list(filter(lambda e: e.ordering_received is not None and e.processed is not None, evts))
    print(f'Total number of events (in calc): {len(evts)}')
    if len(evts) > 0:
        td = max(map(lambda e: e.processed or datetime.min, evts)) - min(map(lambda e: e.ordering_received or datetime.max, evts))
        print(f'Total time: {td.total_seconds():.3f}')
        print(f'Events per second: {len(evts) / td.total_seconds():.3f}')
#        print(f'Average time in reception per event: {sum(map(lambda e: (e.written - e.received).total_seconds(), evts)) / len(evts):.3f}s')
#        print(f'Average time between reception and PV per event: {sum(map(lambda e: (e.ordering_received - e.written).total_seconds(), evts)) / len(evts):.3f}s')
        print(f'Average time in PV per event: {sum(map(lambda e: (e.processed - e.ordering_received).total_seconds(), evts)) / len(evts):.3f}s')
