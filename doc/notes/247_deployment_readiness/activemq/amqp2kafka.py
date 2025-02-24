import stomp
from kafka3 import KafkaProducer

class SampleListener(object):

    def __init__(self):
        self.location_queue = "Protocol_Verifier_Reception"
        self.conn = stomp.Connection([('localhost', 61613)])
        self.conn.set_ssl(for_hosts=[('localhost', 61613)], key_file='/tmp/client.key', cert_file='/tmp/client.pem')
        self.conn.connect(username='ProtocolVerifier', passcode='ProtocolVerifier', wait=True)
        self.producer = KafkaProducer(bootstrap_servers='localhost:9092')

    def on_message(self, message):
        self.producer.send('Protocol_Verifier_Reception', bytes(message.body, encoding='utf8'))

    def receive_from_queue(self):
        self.conn.set_listener('SampleListener', SampleListener())
        self.conn.subscribe(self.location_queue, 12)
        while True:
            pass


if __name__ == '__main__':
    sampleListener = SampleListener()
    sampleListener.receive_from_queue()
