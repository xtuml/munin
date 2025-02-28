import argparse
import kafka3
import stomp

if __name__ == '__main__':
    parser = argparse.ArgumentParser(prog='kafka2amqp.py', description='Kafka to AMQP bridge for protocol verifier')
    parser.add_argument('--msgbroker', required=True, help='Specify the message broker <host:port>')
    parser.add_argument('--topic', required=False, help='Specify topic')
    args = parser.parse_args()

    consumer = kafka3.KafkaConsumer(bootstrap_servers=args.msgbroker, auto_offset_reset='earliest')
    consumer.subscribe( ['Protocol_Verifier_Statistics','Protocol_Verifier_InfoWarn','Protocol_Verifier_Reception'] )

    # AMQP broker
    amqpconn = stomp.Connection([('localhost', 61613)])
    #amqpconn.set_ssl(for_hosts=[('localhost', 61613)], key_file='/tmp/client.key', cert_file='/tmp/client.pem', ca_certs='/tmp/broker.pem')
    amqpconn.connect(username='ProtocolVerifier', passcode='ProtocolVerifier', wait=True)

    # process messages
    raw_msgs = consumer.poll(timeout_ms=20000)
    while len(raw_msgs) > 0:
        for tp, partition in raw_msgs.items():
            for msg in partition:
                s = msg.value.decode('utf-8').rstrip()
                if tp.topic == 'Protocol_Verifier_Statistics':
                    amqpconn.send(body=s, destination='Protocol_Verifier_Statistics')
                elif tp.topic == 'Protocol_Verifier_InfoWarn':
                    amqpconn.send(body=s, destination='Protocol_Verifier_InfoWarn')
                elif tp.topic == 'Protocol_Verifier_Reception':
                    a = 'NOP'
        raw_msgs = consumer.poll(timeout_ms=8000)
