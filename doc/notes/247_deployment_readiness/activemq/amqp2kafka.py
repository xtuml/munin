import stomp
from kafka3 import KafkaProducer

class SampleListener(object):

    def __init__(self):
        self.location_queue = "Protocol_Verifier_Reception"
        self.conn = stomp.Connection([('127.0.0.1', 61613)])
        self.conn.connect(username='ProtocolVerifier', passcode='ProtocolVerifier', wait=True)
        self.producer = KafkaProducer(bootstrap_servers='127.0.0.1:9092')

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
