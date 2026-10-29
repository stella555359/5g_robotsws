import socket
import threading
import queue
import struct


class TCPServer:

    def __init__(self, tcpPort):
        """
        Initialise a TCP server listening on a specific tcpPort. Note: The server is not yet launched
        after the initilisation
        :param tcpPort: tcp port number
        """
        # create TCP socket
        self._socket = socket.socket(socket.AF_INET, socket.SOCK_STREAM)
        # Bind socket
        self._socket.bind(("", tcpPort))
        self._socket.settimeout(1.0)
        # Create received message queue
        self._queue = queue.Queue(0)
        # The server is not yet started
        self._started = False

    def launchServer(self):
        """
        Launch TCP server and wait for a new connection from a client. Note: launch it in a separate thread
        :return: None
        """
        # Start listening
        self._started = True
        self._socket.listen(5)
        while self._started:
            try:
                # Wait for new connections
                client_sock, address = self._socket.accept()

                # Create a thread to manage each connection
                client_handler = threading.Thread(
                    target=self._handle_client_connection,
                    args=(client_sock,)
                )
                client_handler.start()
            except socket.timeout:
                pass
            except OSError:
                pass

    def _handle_client_connection(self, client_socket):
        """
        Manage a new connection from a client and start downloading messages. Once a message is downloaded,
        add the message to a queue
        :param client_socket: tcp socket to the client connection
        :return: None
        """
        listChunk = []
        currentlyReceiving = False
        # While the server is started
        while self._started:
            # If a message has begun to be received
            if currentlyReceiving:
                # Receive the data
                chunk = client_socket.recv(len_msg - len_received)
                # If data are not empty
                if chunk != b'' and self._started:
                    # Add received data to the message received
                    listChunk.append(chunk)
                    # Increments the number of data received
                    len_received += len(chunk)
                    # If message is totally received
                    if len_received == len_msg:
                        packet = b"".join(listChunk)
                        listChunk = []
                        # Put in the queue of messages
                        self._parsePacket(packet)
                        # Put the currentlyReceiving flag to off
                        currentlyReceiving = False
            else:
                # Receive the 4 first byte = message length
                chunk = client_socket.recv(4)
                if chunk != b'' and self._started:
                    # Read the message length
                    len_msg = struct.unpack('>I', chunk)[0]
                    # Init the message receiving
                    currentlyReceiving = True
                    msg = b''
                    len_received = 0
        # At the end, close the socket
        client_socket.close()

    def _parsePacket(self, packet):
        """
        parse a packet of messages and add each message to the queue
        :param packet: binary packet containing many messages
        :return: None
        """
        _currentPacket = packet
        # debugWrite(packet)
        while _currentPacket:
            sizeMsg = struct.unpack('>I', _currentPacket[0:4])[0]
            msg, _currentPacket = _currentPacket[4:sizeMsg +
                                                 4], _currentPacket[sizeMsg + 4:]
            self._queue.put(msg)

    def recv(self):
        """
        Return the first message of the queue if there is at least one message. Return None Otherwise
        :return: message or None
        """
        # If there is at least one message return it
        try:
            msg = self._queue.get_nowait()
        except queue.Empty:
            # Otherwise return None
            msg = None
        return msg

    def hasNewMessages(self):
        """
        Check if there is at least one new message to read
        :return: Boolean
        """
        return not self._queue.empty()

    def stopServer(self):
        """
        Stop the tcp server
        :return: None
        """
        self._socket.close()
        self._started = False
