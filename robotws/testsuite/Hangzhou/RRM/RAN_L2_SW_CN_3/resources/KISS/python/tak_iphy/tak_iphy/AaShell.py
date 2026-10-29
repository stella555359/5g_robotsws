# -*- coding: utf-8 -*-
"""
:created on: 10-08-2017

:copyright: Nokia
:author: Wang Xiaoling
:contact: Xiaoling.Wang@alcatel-sbell.com.cn
"""

import re
import telnetlib
import logging
import time
import six


class AaShell(object):
    """telnet the AaShell

    """
    def __init__(self, host="192.168.200.1", port=8023):
        self.host = host
        self.port = port
        self._prompt = "AaShell>"
        self._client = None

    def connect(self, try_times=10, time_sleep=2):
        """ connect to the host

        :return: connect result and console output
        """
        for ii in range(try_times):
            try:
                self._client = telnetlib.Telnet(self.host, int(self.port))
                result, output = self.read_until_regexp(self._prompt)
                if result:
                    logging.info('Connection established: ' + str(self.host) + ':' + str(self.port))
                    break
                else:
                    logging.info(output)
            except Exception as e:
                logging.info("telnet trying to reconnect: " + str(ii))
                logging.exception(str(e))
                time.sleep(time_sleep)
        else:
            raise Exception("error in AaShell connection")

    def read_until_regexp(self, regexp, timeout=1):
        """Reads data from Telnet until regexp matches.

        :param regexp: String or compiled regexp entry.
        :param integer timeout: Timeout for operation.

        :return: Status and read data.
        :rtype:  list
        """
        if isinstance(regexp, six.string_types):
            regexp = re.compile(regexp, re.DOTALL)
        return self._read_until_regexp(regexp, timeout)

    def execute_command(self, cmd, passexp):
        """execute a command

        :param cmd: the command to be executed.
        :param passexp: the expected return value if passed.
        :return: the result of command execution.
        """
        self._client.write('{}\r\n'.format(cmd).encode('utf-8'))
        logging.info(cmd)
        result, output = self.read_until_regexp(passexp)
        logging.info(output)
        if result:
            logging.info(cmd + ' succesfully')
            return True
        else:
            raise Exception('Failed to execute ' + cmd)

    def close(self):
        """Closes telnet connection.
        """
        if self._client is not None:
            self._client.close()
            self._client = None

    def _read_until_regexp(self, regexp, timeout):
        output = ''
        telnet_read = ''
        start_time = time.time()
        while time.time() - start_time <= timeout:
            telnet_read = str(self._client.read_very_eager())
            if not telnet_read:
                continue
            output += telnet_read
            if regexp.search(output):
                return True, output
        return False, output
