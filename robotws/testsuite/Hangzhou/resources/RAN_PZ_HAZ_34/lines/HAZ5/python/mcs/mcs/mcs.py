import logging
import time
import six
import csv
import math
import collections
from abc import abstractmethod, ABCMeta
from .connect import SocketConnect


@six.add_metaclass(ABCMeta)
class MCS_64B16_B1(object):
    def __init__(self, ip, port, timeout=60):
        self._log = logging.getLogger(__name__)
        self._log.setLevel(logging.DEBUG)
        self.ip = ip
        self.port = port
        self.timeout = timeout
        self.sock = None
        self._log.info("receive prepare")
        self._setup_socket()

    def get_version(self):
        self._log.info("receive get_version")
        ret = self.send_command("SYSTem:VERSion?")
        return ret

    def destroy(self):
        self._teardown_socket()

    def send_command(self, request):
        self.sock.send_command(request)
        ret = self.sock.receive_command()
        if "FAIL" in ret:
            raise Exception("send {} Failed.".format(request))
        return ret

    def send_command_with_wait(self, request, response, timeout=60):
        self._log.debug("request:{}\r\nresponse:{}".format(request, response))
        self.sock.send_command(request)
        return self._wait_for_expected_message_received(response, timeout=timeout)

    def _wait_for_expected_message_received(self, response, timeout=60):
        end_time = time.time() + timeout
        message = ""
        while time.time() < end_time:
            message += self.sock.receive_command()
            self._log.info("receive {}".format(message))
            if response in message:
                return message
        raise Exception("wait for {} {}s timeout".format(response, timeout))

    def _setup_socket(self):
        self._log.info("_setup_socket")
        print("Setup Socket Started")
        self.sock = SocketConnect(self.ip, self.port, self.timeout)
        self.sock.connect_socket()
        print("Setup Socket End")

    def generate_layers_setting(self, ports,  phase, att):
        phaseM = int(int(phase) / 1.41)
        attM = int(att) * 4
        result = "SETM"
        i = 0
        while i < 64:
            for index in range(len(ports)):
                B = i * 16 + int(ports[index])
                result += f":{B},{phaseM},{attM}"
            i += 1
        return result

    def _teardown_socket(self):
        """close socket connect
        """
        self.sock.close_socket()
