import stomp
from kafka3 import KafkaProducer

class AMQP2KafkaListener(object):

    def __init__(self):
        self.conn = stomp.Connection([('localhost', 61613)])
        #self.conn.set_ssl(for_hosts=[('localhost', 61613)], key_file='/tmp/client.key', cert_file='/tmp/client.pem', ca_certs='/tmp/broker.pem')
        self.conn.connect(username='admin', passcode='admin', wait=True)
        self.producer = KafkaProducer(bootstrap_servers='localhost:9092')

    def on_message(self, message):
        self.producer.send('Protocol_Verifier_Reception', bytes(message.body, encoding='utf8'))

    def receive_from_queue(self):
        self.conn.set_listener('AMQP2KafkaListener', AMQP2KafkaListener())
        self.conn.subscribe('Protocol_Verifier_Reception', 12)
        while True:
            pass


if __name__ == '__main__':
    amqp2kafkalistener = AMQP2KafkaListener()
    amqp2kafkalistener.receive_from_queue()
