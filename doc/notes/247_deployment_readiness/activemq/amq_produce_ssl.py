import stomp

location_queue = "test-activemq-queue"
conn = stomp.Connection([('localhost', 61613)])
conn.set_ssl(for_hosts=[('localhost', 61613)], key_file='/tmp/client.key', cert_file='/tmp/client.pem', ca_certs='/tmp/broker.pem')
conn.connect(username='admin', passcode='admin', wait=True)


def send_to_queue(msg):
    conn.send(body=str(msg), destination=location_queue)
    print(msg)


if __name__ == '__main__':
    send_to_queue('len 123')
    conn.disconnect()
