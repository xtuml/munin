import stomp


class SampleListener(object):

    def __init__(self):
        self.location_queue = "test-activemq-queue"
        self.conn = stomp.Connection([('127.0.0.1', 61613)])
        self.conn.connect(username='admin', passcode='admin', wait=True)

    def on_message(self, message):
        print('message: %s' % message.body)

    def receive_from_queue(self):
        self.conn.set_listener('SampleListener', SampleListener())
        self.conn.subscribe(self.location_queue, 12)
        while True:
            pass


if __name__ == '__main__':
    sampleListener = SampleListener()
    sampleListener.receive_from_queue()
