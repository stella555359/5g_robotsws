# -*- coding: utf-8 -*-
"""
:created on: 2018-10-10

:copyright: Nokia
:author: Yonna
:contact: yonna.yao@nokia.com
"""


import logging
import time
import six
import csv
import math
import collections
from abc import abstractmethod, ABCMeta
from .connect import SocketConnect
from ta_kiss_core.sshconnection import SshConnection


@six.add_metaclass(ABCMeta)
class BaseMCS(object):
    def __init__(self, server_ip, dev_ip, mcs_port, timeout, server_username, server_password, prompt):
        self._log = logging.getLogger(__name__)
        self._log.setLevel(logging.DEBUG)
        self.server_ip = server_ip
        self.server_username = server_username
        self.server_password = server_password
        self.dev_ip = dev_ip
        self.mcs_port = mcs_port
        self.timeout = timeout
        self.ssh_prompt = prompt
        self.ssh_client = None
        self.mcsServ_name = 'MCSServ.exe' if self.mcs_port == 18888 else 'MCS_Controller.exe'

    @abstractmethod
    def mcs_prepare(self):
        """start serve , set socket connection to server.
        """

    @abstractmethod
    def set_frequency(self, frequency):
        """Set frequency."""

    @abstractmethod
    def mcs_disconnection(self):
        """ssh and socket disconnection."""

    def query_calibrated_frequency(self):
        """Query calibrated frequency."""
        self._log.debug("MCS 3.0 don't support this function.")

    def query_hw_version(self):
        """Query HW version."""
        self._log.debug("MCS 3.0 don't support this function.")

    def read_error_info(self):
        self._log.debug("MCS 3.0 don't support this function.")

    @abstractmethod
    def apply_channel_for_resource(self, channel):
        """apply channel for resource."""

    @abstractmethod
    def get_calibration_file_name(self):
        """get calibration file name"""

    @abstractmethod
    def get_loading_scene_process(self):
        """get loading scene process"""

    @abstractmethod
    def get_playback_scene_process(self):
        """get playback scene process"""

    @abstractmethod
    def get_reference_channel(self, bport):
        """get reference channel"""

    @abstractmethod
    def get_resource_usage_info(self):
        """get resource usage info"""

    @abstractmethod
    def get_scene(self):
        """get scene"""

    @abstractmethod
    def get_ul_calibration_file_name(self):
        """get ul calibration file name"""

    @abstractmethod
    def load_scene(self, csv_name):
        """load scene"""

    @abstractmethod
    def pause_playback_scene(self):
        """pause playback scene"""

    @abstractmethod
    def reboot_mcs(self):
        """reboot mcs"""

    @abstractmethod
    def release_resource(self):
        """release resource"""

    @abstractmethod
    def restart_playback_scene(self):
        """restart playback scene"""

    @abstractmethod
    def set_reference_channel(self, channel):
        """set reference channel"""

    @abstractmethod
    def set_ul_frequency(self, csn_name=None):
        """set ul frequency"""

    @abstractmethod
    def start_playback_scene(self, loop_time=10):
        """start playback scene"""

    @abstractmethod
    def start_single_frame_playback_scene(self, frame_num):
        """start single frame playback scene"""

    @abstractmethod
    def stop_playback_scene(self):
        """stop playback scene"""

    def _enable_mcs_server_is_running(self):
        """enable mcs server process is running
        """
        self._connect_to_mcs_control_pc(ip=self.server_ip, username=self.server_username,
                                        password=self.server_password, prompt=self.ssh_prompt)
        if self._is_mcs_server_process_start():
            self._stop_mcs_server_process()
        self._start_mcs_server_process()
        if not self._is_mcs_server_process_start():
            raise Exception("Start MCS Server fail!")

    def _connect_to_mcs_control_pc(self, ip, username, password, prompt=">"):
        self.ssh_client = SshConnection(ip, username, password, prompt=prompt, timeout=self.timeout)
        self.ssh_client._setup()

    def _is_mcs_server_process_start(self):
        """return True if mcs server is running, elase return False
        """
        task_info, err, rc = self.ssh_client.execute("tasklist | grep {}".format(self.mcsServ_name))
        for line in task_info.split("\r\n"):
            if line.split(" ")[0] == self.mcsServ_name:
                self._log.debug("MCS Server is running.")
                return True
        self._log.debug("MCS Server doesn't start.")
        return False

    def _start_mcs_server_process(self):
        """start mcsserver.exe.lnk process.
        """
        py_cmd = 'c:\\mcsserver.exe.lnk'
        self.ssh_client.write(py_cmd + "\r\n")
        time.sleep(20)

    def _stop_mcs_server_process(self):
        """kill all running mcs server process.
        """
        process_info, err, rc = self.ssh_client.execute("tasklist | grep {}".format(self.mcsServ_name))
        pids = self._get_mcs_server_process_pid(process_info)
        self._log.info(pids)
        kill_command = 'taskkill /F'
        for pid in pids:
            kill_command = '{} /PID {}'.format(kill_command, pid)
        self._log.info(kill_command)
        try:
            self.ssh_client.execute('{}'.format(kill_command))
        except Exception as e:
            self._log.info(e)

    def _get_mcs_server_process_pid(self, process_info):
        """
        :param process_info:
        :return:
        """
        pid = []
        for line in process_info.split('\r\n'):
            if "grep {}".format(self.mcsServ_name) not in line and self.mcsServ_name in line or "bash.exe" in line:
                pid.append(line.split()[1])
        return pid

    def _set_socket_conntion_to_mcs(self, ip, timeout):
        self.sock = SocketConnect(ip, self.mcs_port, timeout)
        self.sock.connect_socket()

    def query_idn(self):
        """query IDN info.
        """
        self.sock.send_command('SYSTem:IDN')
        return self.sock.receive_command()

    def query_current_frequency(self):
        """query current set frequency.
        """
        cmd = "QUERy:FREQuency"
        self.sock.send_command(cmd)
        ret = self.sock.receive_command()
        result = ret.split("QUERy:FREQuency:")[-1]
        if "," in result:
            return result.split(',')
        if 'FAIL' in result:
            raise Exception("Query Frequency return fail.")
        else:
            return result

    def query_channel_phase_and_attenuation(self, channel):
        """query channel phase and att value.
        """
        cmd = self._create_query_channel_phase_and_attenuation_command_with_channel(channel)
        self.sock.send_command(cmd.strip(';'))
        except_str = cmd.split(';')[-1]
        ret = self._receive_all_return_value(except_str)
        result = ret.split("READm:STATus:")[-1] + ';'
        if 'FAIL' in result:
            raise Exception("Query channel's phase and attenuation fail.")
        ph_att_dic = {}
        for info in result.split(";"):
            tmp = info.split(',')
            if len(tmp) == 3:
                ph_att_dic[tmp[0]] = [tmp[1], tmp[2]]
        self._log.info("Total channel number is {}".format(len(ph_att_dic)))
        return ph_att_dic

    def set_phase(self, phase):
        if 'csv' in phase:
            content = self._get_content_from_csv(phase)
            phase = self._read_value_from_csv(content)
        if not isinstance(phase, dict):
            raise Exception("Parameter should be dictionary.")
        ret = self._set_and_receive_return(phase, 'SETM:PHASe:')
        if not self._check_result(ret, 'SETM:PHASe:'):
            reset_phase = self._reset_value(ret, phase, 'SETM:PHASe:')
            reset_ret = self._set_and_receive_return(reset_phase, 'SETM:PHASe:')
            if not self._check_result(reset_ret, 'SETM:PHASe:'):
                raise Exception("Set phase fail!")

    def set_phase_by_port(self, port, angle_h, angle_v):
        phase_dic = self._generate_phase_by_port(port, float(angle_h), float(angle_v))
        ret = self._set_and_receive_return(phase_dic, 'SETM:PHASe:')
        if not self._check_result(ret, 'SETM:PHASe:'):
            raise Exception("Set phase fail!")

    def set_attenuation(self, att):
        """

        :param att:
        :return:
        """
        if "csv" in att:
            content = self._get_content_from_csv(att)
            att = self._read_value_from_csv(content)
        if not isinstance(att, dict):
            raise Exception("parameter should be dictionary.")
        ret = self._set_and_receive_return(att, 'SETM:ATT:')
        if not self._check_result(ret, 'SETM:ATT:'):
            reset_att = self._reset_value(ret, att, 'SETM:ATT:')
            reset_ret = self._set_and_receive_return(reset_att, 'SETM:ATT:')
            if not self._check_result(reset_ret, 'SETM:ATT:'):
                raise Exception("Set attenuation fail!")

    def set_attenuation_by_port(self, port, att_odd, att_even):
        att_dic = self._generate_attenuation_by_port(port, att_odd, att_even)
        ret = self._set_and_receive_return(att_dic, 'SETM:ATT:')
        if not self._check_result(ret, 'SETM:ATT:'):
            raise Exception("Set attenuation fail!")

    def set_channel_phase_and_attenuation(self, att_phase):
        """set channel's phase and att value.
        """
        self._check_parameter_availability(att_phase)
        ret = self._set_and_receive_return(att_phase, 'SETM:')
        if not self._check_result(ret, 'SETM:'):
            reset_att = self._reset_value(ret, att_phase, 'SETM:')
            reset_ret = self._set_and_receive_return(reset_att, 'SETM:')
            if not self._check_result(reset_ret, 'SETM:'):
                raise Exception("Set attenuation fail!")

    def _get_content_from_csv(self, csv_file):
        csv_content = []
        with open(csv_file, 'r') as file_object:
            content = csv.reader(file_object)
            for con in content:
                csv_content.append(con)
        return csv_content

    def _read_value_from_csv(self, csv_content):
        dic = {}
        for columns_index in range(0, len(csv_content[0]) - 1):
            for row_index in range(0, len(csv_content) - 1):
                channel = '{}{}'.format(csv_content[0][columns_index + 1], csv_content[row_index + 1][0])
                value = csv_content[row_index + 1][columns_index + 1]
                dic[channel] = value
        return dic

    def _set_and_receive_return(self, set_value, cmd_format):
        cmd = cmd_format
        for channel, value in set_value.items():
            cmd = cmd + '{},{};'.format(channel, value)
        self.sock.send_command(cmd.strip(';'))
        return self.sock.receive_command()

    def _check_result(self, ret, cmd_format):
        return True if 'OK' in ret.split(cmd_format)[-1] else False

    def _reset_value(self, ret, src_input, cmd_format):
        fail_channel = []
        result = ret.split(cmd_format)[-1]
        for status in result.split(";"):
            split_str = status.split(",")[0]
            if "FAIL" not in split_str:
                fail_channel.append(split_str)
        self._log.info("{} set fail,try again.".format(''.join(fail_channel)))
        reset_phase = {}
        if fail_channel == []:
            fail_channel = src_input.keys()
        for channel in fail_channel:
            reset_phase[channel] = src_input[channel]
        return reset_phase

    def _check_parameter_availability(self, value):
        if not isinstance(value, dict):
            raise Exception("parameter should be dictionary.")
        for channel, value in value.items():
            if len(value.split(',')) != 2:
                raise Exception("The value format should be 'att_value,phase_value'.")

    def _return_all_channel(self):
        channel = ''
        for a in range(1, 65):
            for b in range(1, 17):
                channel = '{};A{}B{}'.format(channel, a, b)
        return channel.strip(';')

    def _create_query_channel_phase_and_attenuation_command_with_channel(self, channel):
        if isinstance(channel, six.string_types):
            if channel.upper() == 'ALL':
                channel = self._return_all_channel()
            cmd = "READm:STATus:{}".format(channel)
        if isinstance(channel, list):
            cmd = "READm:STATus:"
            for cha in channel:
                cmd = cmd + '{};'.format(cha)
        return cmd

    def _receive_all_return_value(self, except_str):
        self._log.info("will keep receive return value until '{}' appear.".format(except_str))
        return_value = ""
        while True:
            ret = self.sock.receive_command()
            return_value = return_value + ret
            if except_str in ret or 'FAIL' in ret:
                break
        self._log.info(return_value)
        return return_value

    def _generate_attenuation_by_port(self, port, odd, even):
        col_num = 64
        att_disc = collections.OrderedDict() if six.PY2 else {}
        for p in str(port).split(","):
            for index in range(1, col_num+1):
                att_disc["A{}".format(index) + 'B{}'.format(p)] = even if index % 2 == 0 else odd
        return att_disc

    def _socket_teardown(self):
        """close socket connect
        """
        self.sock.close_socket()

    def _ssh_teardown(self):
        """close ssh connection.
        """
        self.ssh_client._teardown()


class MCSControl2(BaseMCS):

    def __init__(self, server_ip, dev_ip, mcs_port, timeout, server_uname, server_pwd, prompt):
        super(MCSControl2, self).__init__(server_ip, dev_ip, mcs_port, timeout, server_uname, server_pwd, prompt)

    def mcs_prepare(self, db_path):
        self._enable_mcs_server_is_running()
        self._set_socket_conntion_to_mcs(self.server_ip, self.timeout)
        try:
            self._connect()
        except Exception as e:
            self._disconnect()
            self._connect()
        self._connect_to_db(db_path)

    def _connect(self):
        """
        :return:
        """
        cmd = 'CONNect:DEVIce:{}'.format(self.dev_ip)
        self.sock.send_command(cmd)
        ret = self.sock.receive_command()
        result = ret.split('CONNect:DEVIce:')[-1]
        if "FAIL" in result:
            raise Exception("Connect to MCS fail.")

    def _connect_to_db(self, db_path):
        """

        :param db_path:
        :return:
        """
        cmd = 'CONNect:DB:{}'.format(db_path)
        self.sock.send_command(cmd)
        ret = self.sock.receive_command()
        result = ret.split('CONNect:DB:')[-1]
        if 'FAIL' in result:
            raise Exception("Connect to DB fail!")
        elif 'PARAERR' in result:
            raise Exception("Parameter Error.")
        elif 'OK' not in result:
            raise Exception("Connect to DB have unknown error.")
        else:
            self._log.info("Connect to DB OK.")

    def query_hw_version(self):
        """

        :return:
        """
        cmd = 'SYSTem:VERSion'
        self.sock.send_command(cmd)
        ret = self.sock.receive_command()
        return ret.split("SYSTem:VERSion:")[-1]

    def query_calibrated_frequency(self):
        """

        :return:
        """
        cmd = "LIST:FREQuency"
        self.sock.send_command(cmd)
        ret = self.sock.receive_command()
        if 'FAIL' in ret:
            raise Exception("LIST:FREQuency FAIL!")
        return ret.split(':')[-1].split(',')

    def set_frequency(self, frequency):
        """

        :param frequency:
        :return:
        """
        cmd = "SET:FREQuency:{}".format(frequency)
        self.sock.send_command(cmd)
        ret = self.sock.receive_command()
        result = ret.split("SET:FREQuency:")[-1]
        if 'FAIL' in result:
            raise Exception("Set frequency fail!")
        elif 'PARAERR' in result:
            raise Exception("Parameter Error.")
        elif 'OK' not in result:
            raise Exception("Set frequency have unknown error.")
        else:
            self._log.info("Set frequency OK")

    def _generate_phase_by_port(self, port, angle_h, angle_v):
        interrupt_num = 16
        col_num = 64
        phase_list = []
        phase_disc = collections.OrderedDict() if six.PY2 else {}
        initial_val = [(N / 2) * 180 * math.sin(angle_h / 180.0 * math.pi) for N in range(interrupt_num)]
        loop_num = col_num / interrupt_num if six.PY2 else col_num // interrupt_num
        for col_idx in range(loop_num):
            increase_val = col_idx * 4.2 * 180 * math.sin(angle_v / 180.0 * math.pi)
            increase_list = [round(x + increase_val, 2) for x in initial_val]
            phase_list = phase_list + [str(x) for i, x in enumerate(increase_list)]
        for p in str(port).split(","):
            for index in range(1, len(phase_list) + 1):
                phase_disc["A{}".format(index) + 'B{}'.format(p)] = phase_list[index-1]
        return phase_disc

    def _set_and_receive_return_tmp(self, set_value, cmd_format):
        cmd = cmd_format
        for channel, value in set_value.items():
            cmd = cmd + '{},{};'.format(channel, value)
        self._log.info(cmd)

    def _return_all_channel(self):
        channel = ''
        for a in range(1, 65):
            for b in range(1, 17):
                channel = '{};A{}B{}'.format(channel, a, b)
        return channel.strip(';')

    def read_error_info(self):
        """

        :return:
        """
        cmd = "SYST:ERROr"
        self.sock.send_command(cmd)
        ret = self.sock.receive_command()
        return ret.split('SYST:ERROr:')

    def _disconnect(self):
        """

        :return:
        """
        cmd = "DISCONNect:DEVIce:{}".format(self.dev_ip)
        self.sock.send_command(cmd)
        ret = self.sock.receive_command()
        if 'OK' not in ret:
            raise Exception("Device disconnect fail.")

    def mcs_disconnection(self):
        self._disconnect()
        self._socket_teardown()
        self._ssh_teardown()

    def apply_channel_for_resource(self, channel):
        self._log.info("This MCS do not support this kw.")

    def get_calibration_file_name(self):
        self._log.info("This MCS do not support this kw.")

    def get_loading_scene_process(self):
        self._log.info("This MCS do not support this kw.")

    def get_playback_scene_process(self):
        self._log.info("This MCS do not support this kw.")

    def get_reference_channel(self, bport):
        self._log.info("This MCS do not support this kw.")

    def get_resource_usage_info(self):
        self._log.info("This MCS do not support this kw.")

    def get_scene(self):
        self._log.info("This MCS do not support this kw.")

    def get_ul_calibration_file_name(self):
        self._log.info("This MCS do not support this kw.")

    def load_scene(self, csv_name):
        self._log.info("This MCS do not support this kw.")

    def pause_playback_scene(self):
        self._log.info("This MCS do not support this kw.")

    def reboot_mcs(self):
        self._log.info("This MCS do not support this kw.")

    def release_resource(self):
        self._log.info("This MCS do not support this kw.")

    def restart_playback_scene(self):
        self._log.info("This MCS do not support this kw.")

    def set_reference_channel(self, channel):
        self._log.info("This MCS do not support this kw.")

    def set_ul_frequency(self, csn_name):
        self._log.info("This MCS do not support this kw.")

    def start_playback_scene(self, loop_time):
        self._log.info("This MCS do not support this kw.")

    def start_single_frame_playback_scene(self, frame_num):
        self._log.info("This MCS do not support this kw.")

    def stop_playback_scene(self):
        self._log.info("This MCS do not support this kw.")


class MCSControl3(BaseMCS):
    def __init__(self, server_ip, dev_ip, mcs_port, timeout, server_uname, server_pwd, prompt):
        super(MCSControl3, self).__init__(server_ip, dev_ip, mcs_port, timeout, server_uname, server_pwd, prompt)

    def mcs_prepare(self, db_path):
        self._enable_mcs_server_is_running()
        self._set_socket_conntion_to_mcs(self.dev_ip, self.timeout)

    def reboot_mcs(self):
        self.sock.send_command('REstart')
        if "REstart OK" not in self.sock.receive_command():
            raise Exception("Reboot mcs server fail!")

    def get_resource_usage_info(self):
        self.sock.send_command('GETM:INFO')
        ret = self.sock.receive_command()
        result = ret.split('GETM:INFO:')[1].strip().strip()
        value = [{i.split(',')[0]:i.split(',')[1]} for i in result.split(';')] if ',' in result else result
        return value

    def get_calibration_file_name(self):
        self.sock.send_command('GET:CSN')
        ret = self.sock.receive_command()
        return ret.split('GET:CSN:')[1].split(';')

    def get_ul_calibration_file_name(self):
        self.sock.send_command('GET:UL:CSN')
        ret = self.sock.receive_command()
        return ret.split('GET:UL:CSN:')[1].split(';')

    def set_frequency(self, frequency=None):
        if frequency is None:
            return
        self.sock.send_command('CSN:LOAD:{}'.format(frequency))
        self._wait_100s_for_resulte("Set Frequency Fail!")

    def set_ul_frequency(self, csn_name=None):
        raise Exception("This function do not support.")
        if csn_name is None:
            return
        self.sock.send_command('CSN:UL:LOAD:{}'.format(csn_name))
        if 'OK' not in self.sock.receive_command():
            raise Exception("Set UL Frequency Fail!")

    def apply_channel_for_resource(self, channel):
        channel = channel.split(',') if ',' in channel else channel.split()
        cmd = 'SET:ALLOC:CHANnel:'
        self._log.debug("channel:{}".format(channel))
        for c in channel:
            cmd += c + ';'
        self.sock.send_command(cmd.strip(';'))
        if "OK" not in self.sock.receive_command():
            raise Exception("Set Alloc channel fail")

    def release_resource(self):
        self.sock.send_command('FREE')
        if "OK" not in self.sock.receive_command():
            raise Exception('Release resource fail!')

    def get_scene(self):
        self.sock.send_command('GET:SCENe')
        ret = self.sock.receive_command()
        if "FAIL" in ret:
            raise Exception('Get Scene fail.')
        return ret.split('GET:SCENe:')[1].split(";")

    def load_scene(self, csv_name):
        csv = csv_name.split(",") if "," in csv_name else csv_name.split()
        cmd = 'SET:SCENe:'
        for c in csv:
            cmd += c + ';'
        self.sock.send_command(cmd.strip(';'))
        if "OK" not in self.sock.receive_command():
            raise Exception("Load scene fail.")

    def get_loading_scene_process(self):
        self.sock.send_command("LOAD:SCENe:RATE")
        ret = self.sock.receive_command()
        if "FAIL" in ret:
            raise Exception("Get loading scene process fail.")
        return ret.split("LOAD:SCENe:RATE:")

    def start_playback_scene(self, loop_time=10):
        self.sock.send_command("PLAY:SCENe:STARt:{}".format(loop_time))
        if "OK" not in self.sock.receive_command():
            raise Exception("Set playback time fail.")

    def pause_playback_scene(self):
        self.sock.send_command("PLAY:SCENe:PAUSe")
        if "OK" not in self.sock.receive_command():
            raise Exception("Set Pause for scene fail.")

    def restart_playback_scene(self):
        self.sock.send_command("PLAY:SCENe:GOON")
        if "OK" not in self.sock.receive_command():
            raise Exception("Restart scene fail.")

    def stop_playback_scene(self):
        self.sock.send_command("PLAY:SCENe:STOP")
        if "OK" not in self.sock.receive_command():
            raise Exception("Stop play scene fail.")

    def get_playback_scene_process(self):
        self.sock.send_command("PLAY:SCENe:RATE")
        ret = self.sock.receive_command()
        if "FAIL" in ret:
            raise Exception("Get playback scene process fail.{}".format(ret.split("PLAY:SCENe:RATE:")[1]))
        return ret.split("PLAY:SCENe:RATE:")

    def start_single_frame_playback_scene(self, frame_num):
        self.sock.send_command("PLAY:SCENe:SINGle:{}".format(frame_num))
        if "OK" not in self.sock.receive_command():
            raise Exception("Start single frame playback scene fail.")

    def set_reference_channel(self, channel):
        chan = channel.split(";") if ";" in channel else channel.split()
        cmd = "SET:BASE:CHANnel:"
        for c in chan:
            cmd += c + ","
        self.sock.send_command(cmd.strip(','))
        if "OK" not in self.sock.receive_command():
            raise Exception("Set reference channel fail.")

    def get_reference_channel(self, bport):
        bp = bport.split(";") if ";" in bport else bport.split()
        cmd = "READ:BASE:CHANnel:"
        for p in bp:
            cmd += p + ","
        self.sock.send_command(cmd.strip(','))
        ret = self.sock.receive_command()
        if "FAIL" in ret:
            raise Exception("Get reference channel fail.")
        return ret.split("READ:BASE:CHANnel:")[1].split(";")

    def mcs_disconnection(self):
        self._socket_teardown()
        self._ssh_teardown()

    def _wait_100s_for_resulte(self, errmsg):
        t = 0
        while True:
            ret = self.sock.receive_command()
            if "OK" in ret:
                break
            if t > 60:
                raise Exception("Command has been executed for 5 minutes without returning 'OK'.")
            if "%" in ret:
                t += 1
                time.sleep(5)
            if "FAIL" in ret:
                raise Exception(errmsg)
