# -*- coding: utf-8 -*-
"""
:copyright: Nokia Networks
:author: Chen Jin Emily
:contact: jin_emily.chen@nokia.com
:maintainer: I_EXT_MBB_GLOBAL_LTE_TDD_CITA_KISS_GMS
:contact: I_EXT_MBB_GLOBAL_LTE_TDD_CITA_KISS@internal.nsn.com
"""
import select
import socket
import time
import timeit
import logging as log
import six


class SocketClientCommon(object):
    """This a class realizes:
       Data sending and receiving through a socket.socket() connection
       which is SOCK_STREAM type.
       You can consider it as a TCP-like connection.
       This class connects to only one remote host at a time.
    """

    # length of data to recv on each socket.socket.recv() call
    RECV_SIZE = 8192
    TIMEOUT_DIV = 5.0

    def __init__(self, host, port, data_op_timeout=3):
        """@param host: string of host's name or IP.
           @param port: integer number.
           @param data_op_timeout:
            this timeout influence self.recv_data() and self.send_data().
            1. if expected length of data is not received during a whole
               'data_op_timeout', then, recv_data() will return what
               it already received.
            2. if socket is not writable during a whole 'data_op_timeout',
               then, send_data() will fail.
            3. socket.socket()'s timeout will be
               1/TIMEOUT_DIV of 'data_op_timeout'
        """
        super(SocketClientCommon, self).__init__()
        self._socket_instance = None
        self._host = host
        self._port = port
        self._is_open = False
        self._data_op_timeout = data_op_timeout
        self.timeout = data_op_timeout / self.TIMEOUT_DIV

    def set_data_op_timeout(self, data_op_timeout):
        """re-set data_op_timeout.
           See __init__'s doc string for more info about this property.
           This method will NOT close socket connection if it is open.
           @return: previous data_op_timeout value.
        """
        previous_timeout = self._data_op_timeout
        self._data_op_timeout = data_op_timeout
        self.timeout = data_op_timeout / self.TIMEOUT_DIV
        if self._socket_instance:
            self._socket_instance.settimeout(self.timeout)
        return previous_timeout

    def is_open(self):
        """@return: True/False, indicates whether socket is connected to a
            remote host or not.
        """
        return self._is_open

    def open_connection(self, data_op_timeout=-1):
        """Instantiate a new socket.socket() instance, try to connect it to
           host:port, and set its timeout.
           IPv6 host supported.
           If instantiating or connecting failed, raise Exception.
           @param host, port, data_op_timeout: see __init__'s doc string.
        """
        if self._is_open:
            return True

        if data_op_timeout == -1:
            data_op_timeout = self._data_op_timeout
        timeout = data_op_timeout / self.TIMEOUT_DIV

        if data_op_timeout < 0:
            raise Exception('Cannot establish socket connection, ' +
                            '"data_op_timeout" is invalid(< 0): %s'
                            % repr(data_op_timeout))

        # instantiate a socket.socket() with first address family available
        for ret in socket.getaddrinfo(self._host, self._port, socket.AF_UNSPEC,
                                      socket.SOCK_STREAM):
            family, sock_type, proto, canon_name, sock_addr = ret
            try:
                self._socket_instance = socket.socket(family, sock_type, proto)
            except socket.error as err_info:
                log.debug('Failed to instantiate socket(): %s' % err_info)
                self._socket_instance = None
                continue
            # set timeout before connecting
            self._socket_instance.settimeout(timeout)
            self.timeout = timeout
            try:
                self._socket_instance.connect(sock_addr)
                self._is_open = True
            except socket.error as err_info:
                log.debug('Failed to connect socket() to "%s:%d": %s'
                          % (sock_addr[0], sock_addr[1], err_info))
                self._socket_instance.close()
                self._socket_instance = None
                self._is_open = False
                continue
            # instantiate and connect succeeded, break
            break
        if self._socket_instance is None:
            raise Exception('Failed to establish socket connection to ' +
                            '"%s:%d": %s' % (self._host, self._port, err_info))
        else:
            return True

    def close_connection(self):
        """Close internal socket instance's established connection.
        """
        if not self._is_open:
            return True
        try:
            self._socket_instance.shutdown(socket.SHUT_RDWR)
            self._socket_instance.close()
        except Exception as err_info:
            log.info('Close socket "%s:%d" failed with exception: "%s"\n'
                     % (self._host, self._port, err_info) +
                     'This error is ignored.')
        del self._socket_instance
        self._socket_instance = None
        self._is_open = False
        return True

    def is_ready_to_recv(self):
        """to receive string
        """
        ready_to_read, _, _ = select.select([self._socket_instance], [], [],
                                            self.timeout)
        return True if ready_to_read else False

    def recv_all_avail_data(self, timeout=None):
        """recv all available data from socket until socket is unreadble, or timeout
        is reached.
        @note: added by Sam at 2015/01/19 when debug tm500 multi ue socket recv problem.
        """
        ret = ""
        starttime = time.time()
        while self.is_ready_to_recv():
            buf = self._socket_instance.recv(self.RECV_SIZE)
            if buf == "":
                break
            ret += buf
            if timeout is not None:
                if time.time() - starttime >= timeout:
                    break
        return ret

    def _get_data_from_buffer(self):
        if not self.is_ready_to_recv():
            return ''
        else:
            ret = self._socket_instance.recv(self.RECV_SIZE)
            if type(ret) is str:
                return ret
            else:
                return ret.decode()

    def recv_data(self,
                  expect_recv_len=1,
                  temp_timeout=None):
        """Receive data from the connected internal socket instance.
        """
        # re-set self._data_op_timeout if needed
        if temp_timeout is not None:
            previous_op_timeout = self.set_data_op_timeout(temp_timeout)
            start_time = timeit.default_timer()

        ret_str = self._get_data_from_buffer()
        if temp_timeout and expect_recv_len <= 0:
            self.set_data_op_timeout(previous_op_timeout)
            return ret_str
        else:
            return ret_str

        while (len(ret_str) < expect_recv_len) and \
                (timeit.default_timer() - start_time + self.timeout <= self._data_op_timeout):
            time.sleep(self.timeout)
            ret_str += self._get_data_from_buffer()
            if len(ret_str) >= expect_recv_len:
                break
        if temp_timeout is not None:
            self.set_data_op_timeout(previous_op_timeout)
        return ret_str

    def send_data(self, data_to_send, use_timeout=True):
        """Send data to remote host by internal socket instance.
        """
        if not isinstance(data_to_send, (six.text_type, six.string_types, bytes)):
            raise Exception('Socket "%s:%d", "data_to_send" is NOT '
                            % (self._host, self._port) +
                            'string, it is %s' % data_to_send)
        if not len(data_to_send):
            raise Exception('Socket "%s:%d", "data_to_send" is empty!'
                            % (self._host, self._port))

        if use_timeout:
            start_time = timeit.default_timer()

        _, ready_to_write, _ = \
            select.select([], [self._socket_instance], [], self.timeout)
        while use_timeout and (not ready_to_write) and \
            (timeit.default_timer() - start_time + self.timeout <=
             self._data_op_timeout):
            time.sleep(self.timeout)
            _, ready_to_write, _ = \
                select.select([], [self._socket_instance], [], self.timeout)
        if not ready_to_write:
            log.info('Socket "%s:%d" is not ready for data sending! '
                     % (self._host, self._port) + 'No data sent.')
            return False
        else:
            self._socket_instance.sendall(data_to_send)
            return True
