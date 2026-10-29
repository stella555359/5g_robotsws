# -*- coding: utf-8 -*
'''
Author: Ding Binmei
Description: This is for operations to attenuation
'''
from telnetlib import Telnet
import time
import re


class AttenuationHJ(object):

    _MIN_CHANNEL_NUM = 1
    _MAX_CHANNEL_NUM = 16
    _MIN_ATTENUATION_NUM = 0
    _MAX_ATTENUATION_NUM = 110

    def connect_to(self, ip, port=3000, timeout=10):
        self._tn = Telnet(host=ip, port=int(port), timeout=int(timeout))

    def set_value(self, channel, value):
        '''
        Set attenuation value
        :param channel: Valid value should be int value from 1 to 16
        :param value: Valid value should be int value from 1 to 120
        '''
        channel = int(channel)
        value = int(value)
        if self._is_channel_num_valid(channel) and self._is_attenuation_value_valid(value):
            cmd_set = 'ATT {} {}'.format(channel, value*4)
            output_set = self._execute_command(cmd_set)
            current_value = self.get_value(channel)
            if current_value == value*4:
                pass
            else:
                raise IOError("Fail to set new attenuation value. Output value of command {} is: {}."
                              "And current attenuation value is {}".format(cmd_set, output_set, current_value))
        else:
            raise Exception(
                 "Your input values are invalid, expected channel value should be in range of 1 to 16, "
                 "attenuation value should be in range of 0 to 120")

    def get_value(self, channel):
        '''
        Get attenuation value
        :param channel: Valid value should be int value from 1 to 16
        :return: Will return the attenuation value
        '''
        channel = int(channel)
        if self._is_channel_num_valid(channel):
            cmd_read = "ATT"
            output_read = self._execute_command(cmd_read)
            re_att = '\\s*ATT\\s+{}\\s+(\\d+)'.format(channel)
            if re.findall(re_att, output_read):
                attenuation_value = int(re.findall(re_att, output_read)[0])
                return attenuation_value
            else:
                raise IOError(
                    "Fail to get attenuation value for channel {}, output value from command: {} is: {}".format(
                        channel, cmd_read, output_read))
        else:
            raise Exception(
                "Your input channel number {} is invalid. Available values should be in range of 1 to 16".format(
                    channel))

    def disconnect(self):
        self._tn.close()

    def _execute_command(self, cmd, wait_time=2):
        try:
            self._tn.write(cmd.encode('ascii')+b"\r\n")
            output = self._tn.read_until(b'\r\n', wait_time).decode('ascii').strip()
        except Exception as e:
            self._tn.write(cmd+"\r\n")
            output = self._tn.read_until('\r\n', wait_time).strip()
        print("Execute command {}, output value is {}".format(cmd, output))
        return output

    def _is_channel_num_valid(self, channel_num):
        if self._MIN_CHANNEL_NUM <= channel_num <= self._MAX_CHANNEL_NUM:
            return True
        else:
            return False

    def _is_attenuation_value_valid(self, attenuation_value):
        if self._MIN_ATTENUATION_NUM <= attenuation_value <= self._MAX_ATTENUATION_NUM:
            return True
        else:
            return False
