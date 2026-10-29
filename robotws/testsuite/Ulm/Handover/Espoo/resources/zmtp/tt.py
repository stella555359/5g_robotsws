import binascii
import zmq

# For ABIL:
ctx = zmq.Context()
sock = ctx.socket(zmq.PULL)
sock.setsockopt(zmq.IPV6, 1)
sock.connect('tcp://[fd5f:4268:2387:a881:40:43ff:fe80:1182]:30512')

sock2 = ctx.socket(zmq.PULL)
sock2.setsockopt(zmq.IPV6, 1)
sock2.connect('tcp://[fd5f:4268:2387:a881:40:43ff:fe80:1181]:30512')

# For ABIO:
sock3 = ctx.socket(zmq.PULL)
sock3.setsockopt(zmq.IPV6, 1)
sock3.connect('tcp://[fd5f:4268:2387:a881:40:43ff:fe80:1185]:30512')

sock4 = ctx.socket(zmq.PULL)
sock4.setsockopt(zmq.IPV6, 1)
sock4.connect('tcp://[fd5f:4268:2387:a881:40:43ff:fe80:1186]:30512')

# Initialize poll set
poller = zmq.Poller()
poller.register(sock, zmq.POLLIN)
poller.register(sock2, zmq.POLLIN)
poller.register(sock3, zmq.POLLIN)
poller.register(sock4, zmq.POLLIN)

while True:
    try:
        socks = dict(poller.poll())
        if sock in socks and socks[sock] == zmq.POLLIN:
            o = sock.recv()
            h = str(binascii.hexlify(o), "ascii")
            s = " ".join(h[i:i+2] for i in range(0, len(h), 2))
            print(f'received pmi report from socket 1: {s}')
        if sock2 in socks and socks[sock2] == zmq.POLLIN:
            o = sock2.recv()
            h = str(binascii.hexlify(o), "ascii")
            s = " ".join(h[i:i+2] for i in range(0, len(h), 2))
            print(f'received pmi report from socket 2: {s}')
        if sock3 in socks and socks[sock3] == zmq.POLLIN:
            o = sock3.recv()
            h = str(binascii.hexlify(o), "ascii")
            s = " ".join(h[i:i+2] for i in range(0, len(h), 2))
            print(f'received pmi report from socket 3: {s}')
        if sock4 in socks and socks[sock4] == zmq.POLLIN:
            o = sock4.recv()
            h = str(binascii.hexlify(o), "ascii")
            s = " ".join(h[i:i+2] for i in range(0, len(h), 2))
            print(f'received pmi report from socket: 4: {s}')
    except Exception as e:
        continue
