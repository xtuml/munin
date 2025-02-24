import stomp


class SampleListener(object):

    def __init__(self):
        self.location_queue = "test-activemq-queue"
        self.conn = stomp.Connection([('localhost', 61613)])
        #self.conn.set_ssl(for_hosts=[('localhost', 61613)], key_file='/tmp/client.key', cert_file='/tmp/client.pem')
        self.conn.set_ssl(for_hosts=[('localhost', 61613)], key_file='/tmp/client.key', cert_file='/tmp/client.pem', ca_certs='/tmp/broker.pem')
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
