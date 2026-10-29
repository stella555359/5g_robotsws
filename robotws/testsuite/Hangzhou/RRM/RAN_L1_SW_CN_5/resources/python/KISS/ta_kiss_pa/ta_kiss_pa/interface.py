# -*- coding: utf-8 -*-
"""
:copyright: Nokia Networks
:author: Chen Jin Emily
:contact: jin_emily.chen@nokia.com
:maintainer: I_EXT_MBB_GLOBAL_LTE_TDD_CITA_KISS_GMS
:contact: I_EXT_MBB_GLOBAL_LTE_TDD_CITA_KISS@internal.nsn.com
"""
import time
import re
import csv
import logging as log
from robot.utils import timestr_to_secs
from .socket_common import SocketClientCommon


class ta_kiss_pa(object):
    """ attenuator
        vendor : HJ -> HaoJin
                JX -> JieXi
                FC -> FACOM
                JFW -> Jfw
                JFW_SFE -> JfwSfe

    """
    def _get_pa_object(self, vendor, ip, port):
        pa_class_map = {"HJ": HaoJinAttenuator,
                        "JX": JieXiAttenuator,
                        "FC": FacomAttenuator,
                        "JFW": JfwAttenuator,
                        "JFW_SFE": JfwSfeAttenuator}
        try:
            return pa_class_map[vendor](ip, port)
        except Exception as err:
            raise Exception("the type '%s' is not supported now!\nSupport type is\
'HJ'->Haojin, 'JX'->JieXi,'FC'->facom, 'JFW','JFW_SFE'" % vendor)

    def _handle_vendors(self, vendor_ip_port_ch_att_list):
        att_ins_dict = {}
        ch_att_val_dict = {}  # {'ip_port':{ch_num:[att_values]}}
        len_att_val_list = 0  # longest len of [att_values]
        for vendor_ip_port_ch_att in vendor_ip_port_ch_att_list:
            vendor, ip, port, ch_num, att_values = \
                [item.strip() for item in vendor_ip_port_ch_att.split(':')]
            port = int(port)
            ch_num = int(ch_num)
            if not att_values:
                continue
            att_value_list = [int(item.strip())
                              for item in att_values.split(',')]
            if len(att_value_list) > len_att_val_list:
                len_att_val_list = len(att_value_list)
            att_ins_name = '%s_%d' % (ip, port)
            # instantiate attenuator instance
            if att_ins_name not in att_ins_dict:
                att_ins_dict[att_ins_name] = self._get_pa_object(vendor, ip, port)

            # built/update {'ip_port':{ch_num:[att_values]}}
            if att_ins_name not in ch_att_val_dict:
                ch_att_val_dict[att_ins_name] = {ch_num: att_value_list}
            else:
                ch_att_val_dict[att_ins_name].update({ch_num: att_value_list})
        return len_att_val_list, ch_att_val_dict, att_ins_dict, vendor

    def _get_send_dict(self, ch_att_val_dict, idx):
        att_to_send_dict = {}
        for att_ins_name in ch_att_val_dict:
            for ch_num in ch_att_val_dict[att_ins_name]:
                if len(ch_att_val_dict[att_ins_name][ch_num]) >= idx + 1:
                    if att_ins_name not in att_to_send_dict:
                        att_to_send_dict[att_ins_name] = [
                            ch_num, ch_att_val_dict[att_ins_name][ch_num][idx]]
                    else:
                        att_to_send_dict[att_ins_name].extend(
                            [ch_num, ch_att_val_dict[att_ins_name][ch_num][idx]])
        return att_to_send_dict

    def set_attenuation_arbitrary_values(self, vendor_ip_port_ch_att_list,
                                         time_interval="1"):
        """This keyword changes programmable attenuator's(PA) attenuation value.
           To now, supports HaoJin(HJ), JieXi(JX), Facom(FC) PA.

        :param vendor_ip_port_ch_att_list: list, [vendor:ip:port:channel:att_value1,att_value2,...,att_value(n), ...]
        :param time_interval: time interval between setting att_value(n) and att_value(n+1).
        Please do NOT set < 0.1, too small interval may cause performance penalty

        | HaoJin, TCP port number is normally 50000, and can be set on PA's web page(but not recommend to change it).

        | For JieXi PA's TCP port number, please use web browser to access JieXi PA, and:
        |    port is 80, if there's NO firmware version displayed on web page.
        |    port is 1000, if there's firmware version displayed on web page.

        | For Facom, socket port is 5000.
        """

        if isinstance(vendor_ip_port_ch_att_list, str):
            vendor_ip_port_ch_att_list = [vendor_ip_port_ch_att_list]

        time_interval = timestr_to_secs(time_interval)

        len_att_val_list, ch_att_val_dict, att_ins_dict, vendor = self._handle_vendors(
            vendor_ip_port_ch_att_list)

        for idx in range(len_att_val_list):
            # {'ip_port':[ch_num, att_value, ch_num, att_value, ...]}
            att_to_send_dict = self._get_send_dict(ch_att_val_dict, idx)
            # set attenuation one attenuator by one
            for att_ins_name in att_to_send_dict:
                send_result = att_ins_dict[att_ins_name].set_multi_ch_att(
                    *att_to_send_dict[att_ins_name])
                if not send_result and vendor != "JFW_SFE":
                    raise Exception(
                        "Error: Set attenuator %s [channel,value] to %s failed." %
                        (att_ins_name, att_to_send_dict[att_ins_name]))

            if idx != len_att_val_list - 1:  # sleep if not last term
                time.sleep(time_interval)

    def set_attenuation_periodical_values(self, vendor_ip_port_ch_att_list,
                                          time_interval="1"):
        """This keyword changes programmable attenuator's(PA) attenuation value.
           To now, supports HaoJin(HJ), JieXi(JX), Facom(FC) PA.
        :param vendor_ip_port_ch_att_list list: [vendor:ip:port:channel:value_start,value_stop,att_value_step(+-),...]
        :param time_interval: time interval between setting att_value(n) and att_value(n+1).
        Please do NOT set < 0.1, too small interval may cause performance penalty

        | HaoJin PA, TCP port is normally 50000, and can be set on PA's web page(but not recommend to change it).

        | For JieXi PA's TCP port number, please use web browser to access JieXi PA, and:
        |    port is 80, if there's NO firmware version displayed on web page.
        |    port is 1000, if there's firmware version displayed on web page.

        | For Focom PA, Socket port is 5000
        """

        if isinstance(vendor_ip_port_ch_att_list, str):
            vendor_ip_port_ch_att_list = [vendor_ip_port_ch_att_list]
        if not isinstance(vendor_ip_port_ch_att_list, list):
            raise Exception('Please input correct format of parameter ' +
                            '"vendor_ip_port_ch_att_list", see doc')

        vendor_ip_port_ch_att_list_new = []
        for vendor_ip_port_ch_att in vendor_ip_port_ch_att_list:
            vendor, ip, port, ch_num, att_val_raw = \
                [item.strip() for item in vendor_ip_port_ch_att.split(':')]
            att_val_raw = [int(item.strip())
                           for item in att_val_raw.split(',')]
            att_val_list = list(range(
                att_val_raw[0],
                att_val_raw[1],
                att_val_raw[2]))
            if att_val_list[-1] != att_val_raw[1]:
                att_val_list.append(att_val_raw[1])
            att_val_str = ','.join([str(item) for item in att_val_list])
            vendor_ip_port_ch_att_new = ':'.join(
                [vendor, ip, port, ch_num, att_val_str])
            vendor_ip_port_ch_att_list_new.append(vendor_ip_port_ch_att_new)
        return self.set_attenuation_arbitrary_values(vendor_ip_port_ch_att_list_new,
                                                     time_interval)

    def set_attenuation_by_csv(self, vendor_ip_port, csv_path):
        """This keyword changes programmable attenuator's(PA) attenuation value by csv file.
           To now, only support Facom(FC) PA.
        :param vendor_ip_port: vendor:ip:port
        :param csv_path: /home/ute/64x16.csv.

        | For Focom PA, Socket port is 5000
        """
        vendor, ip, port = vendor_ip_port.split(':')
        obj = self._get_pa_object(vendor, ip, port)
        obj.set_value_by_csv(vendor_ip_port, csv_path)


class AttenuatorCommon(SocketClientCommon):
    """This a base for socket based attenuator class.
       Child classes include: HaoJinAttenuator(), JieXiAttenuator()
    """
    TRIAL_COUNT = 3
    SOCK_TIMEOUT = 3
    TIME_INTERVAL = SOCK_TIMEOUT / 10.0

    def __init__(self, host, socket_port, timeout=SOCK_TIMEOUT):
        """@param host: string of attenuator's IP(or network name).
           @param socket_port: attenuator's socket port, integer.
           @param timeout: timeout for low level socket operations.
        """
        self.host = host
        self.socket_port = socket_port
        super(AttenuatorCommon, self).__init__(host, socket_port, timeout)

    def send_and_recv_cmd(self, cmd_to_send, len_cmd_to_recv,
                          time_between_trial=TIME_INTERVAL):
        """@param len_cmd_to_recv:
            if >= 0, will recv data from socket after cmd_to_send sent
            if < 0, will only send cmd_to_send, no recv
        """
        # try max self.TRIAL_COUNT times to send cmd and recv its return
        trial_count = 0
        cmd_ret = ''
        while trial_count < self.TRIAL_COUNT:
            try:
                self.open_connection()
                self.recv_data(100)
                self.send_data(cmd_to_send.encode('utf-8'))
                if len_cmd_to_recv >= 0:
                    cmd_ret = self.recv_data(len_cmd_to_recv)
                self.close_connection()
            except Exception as err_info:
                log.debug(
                    'Exception occurred during socket operation on PA ' + '%s:%d\n%s' %
                    (self.host, self.socket_port, err_info))
            if len(cmd_ret) >= len_cmd_to_recv:
                return cmd_ret
            else:
                trial_count += 1
                if trial_count < self.TRIAL_COUNT:
                    time.sleep(time_between_trial)
        return cmd_ret


class HaoJinAttenuator(AttenuatorCommon):
    """This a class realizes:
       Attenuation value set/read for HaoJin attenuators.
    """
    TRIAL_COUNT = 3
    SOCK_TIMEOUT = 2

    def __init__(self, host, socket_port):
        """@param host: string of attenuator's IP(or network name).
           @param socket_port: attenuator's socket port, integer.
        """
        super(HaoJinAttenuator, self).__init__(host, socket_port,
                                               self.SOCK_TIMEOUT)

    def set_multi_ch_att(self, *channels_att_values):
        """@param *channels_att_values:
            channel number, attenuation value, ... (all are integers).
           @return: True/False.
        """
        cmd_to_send = ''
        cmd_to_recv = ''
        num_of_ch = len(channels_att_values) // 2
        for idx in range(num_of_ch):
            ch_num = channels_att_values[2 * idx]
            att_value = channels_att_values[2 * idx + 1]
            if att_value < 0:
                att_value = 0
            if att_value > 110:
                att_value = 110
            if idx == 0:
                cmd_to_send += 'ATT %d %d;' % (ch_num, att_value)
            else:
                cmd_to_send += '%d %d;' % (ch_num, att_value)
            cmd_to_recv += 'ATT %d %d' % (ch_num, att_value)
        cmd_to_send = cmd_to_send[:-1] + '\r\n'

        len_cmd_to_recv = len(cmd_to_recv) + len('\r\n')

        cmd_ret = self.send_and_recv_cmd(cmd_to_send, len_cmd_to_recv).strip()
        if not cmd_ret:  # empty string
            cmd_ret = 'EMPTY'
        if cmd_ret == cmd_to_recv:
            log.info('HaoJin attenuator %s set ATT value succeeded, '
                     % self.host + 'command return = "%s"' % cmd_ret)
            return True
        else:
            log.info('WARN: HaoJin attenuator %s set ATT value ' % self.host +
                     'failed, command return "%s" != expected "%s"'
                     % (cmd_ret, cmd_to_recv))
            return True

    def get_multi_ch_att(self, *channels):
        """@param *channels: channel numbers, integer.
           @return: dict of channel:att_value pairs, or {}.
        """
        dict_ret = {}
        cmd_to_send = 'ATT\r\n'
        cmd_ret = self.send_and_recv_cmd(cmd_to_send, 10).strip()
        if cmd_ret:
            att_values = cmd_ret.split(';')
            for ch_num in channels:
                if len(att_values) < ch_num:
                    raise Exception(
                        'HaoJin attenuator %s read ATT value failed' %
                        self.host +
                        ', channel %d is ' %
                        ch_num +
                        'out of attenuator\'s physical range 1~%d' %
                        len(att_values))
                att_value = att_values[ch_num - 1]
                att_value = int(att_value.split(' ')[-1])
                dict_ret[ch_num] = att_value
            return dict_ret
        else:  # recv empty string
            log.info('WARN: HaoJin attenuator %s read ATT value ' % self.host +
                     'failed, no data received')
            return dict_ret


class JieXiAttenuator(AttenuatorCommon):
    """This a class realizes:
       Attenuation value set/read for JieXi attenuators.
    """
    TRIAL_COUNT = 3
    SOCK_TIMEOUT = 2

    def __init__(self, host, socket_port):
        """@param host: string of attenuator's IP(or network name).
           @param socket_port: attenuator's socket port, integer.
        """
        if socket_port == 80:
            cmd_set_remote = '*SETREMOTE\x00'
            len_cmd_set_remote_ret = -1
        elif socket_port == 1000:
            cmd_set_remote = '*SETREMOTE\r\n'
            len_cmd_set_remote_ret = 1
        else:
            raise Exception('JieXi attenuator(%s) can ONLY support '
                            % self.host + 'socket port 1000 or 80, not %d'
                            % socket_port)

        super(JieXiAttenuator, self).__init__(host, socket_port,
                                              self.SOCK_TIMEOUT)
        # set *SETREMOTE to JieXi attenuator
        self.send_and_recv_cmd(cmd_set_remote, len_cmd_set_remote_ret)

    def set_multi_ch_att(self, *channels_att_values):
        """@param *channels_att_values:
            channel number, attenuation value, ... (all are integers)
           @return: True/False
        """
        ret_val = False
        result = []
        num_of_ch = len(channels_att_values) // 2
        for idx in range(num_of_ch):
            ch_num = channels_att_values[2 * idx]
            att_value = channels_att_values[2 * idx + 1]

            att_value = 0 if att_value < 0 else att_value
            att_value = 127 if att_value > 127 else att_value

            if self.socket_port == 80:
                cmd_to_send = 'BO%d %d\x00' % (ch_num, att_value)
            elif self.socket_port == 1000:
                cmd_to_send = 'SET:%d:%d\r\n' % (ch_num, att_value)

            self.send_and_recv_cmd(cmd_to_send, -1)
            cmd_ret = self.get_multi_ch_att(ch_num)[ch_num]
            if cmd_ret == -1:
                log.info(
                    'JieXi attenuator %s set channel %d to value %s failed'
                    'cannot read back ATT value after setting' %
                    (self.host, ch_num, att_value))
                ret_val = False
            elif cmd_ret != att_value:
                log.info(
                    'JieXi attenuator %s set channel %d to value %s failed'
                    'ATT value read back after setting is %d' %
                    (self.host, ch_num, att_value, cmd_ret))
                ret_val = False
            else:
                log.info('JieXi attenuator %s set channel %d '
                         % (self.host, ch_num) +
                         'ATT value %d succeeded' % att_value)
                ret_val = True
            result.append(ret_val)
        return False if False in result else True

    def get_multi_ch_att(self, *channels):
        """@param *channels: channel numbers, integer.
           @return: dict of channel:att_value pairs,
           if att_value == 1, means that channel didn't get ATT value properly.
        """
        dict_ret = {}
        for ch_num in channels:
            if self.socket_port == 80:
                cmd_to_send = 'BI%d?\x00' % ch_num
                len_cmd_to_recv = 1
            elif self.socket_port == 1000:
                cmd_to_send = 'READ:%d\r\n' % ch_num
                len_cmd_to_recv = 10
            cmd_ret = self.send_and_recv_cmd(cmd_to_send,
                                             len_cmd_to_recv).strip()
            if isinstance(cmd_ret, bytes):
                cmd_ret = cmd_ret.decode('utf-8')
            if cmd_ret:
                if 'ERR' in cmd_ret:
                    log.info('WARN: JieXi attenuator %s read channel %d '
                             % (self.host, ch_num) +
                             'ATT value failed, command return = "%s"'
                             % cmd_ret)
                    dict_ret[ch_num] = -1
                else:
                    if self.socket_port == 80:
                        att_value = int(cmd_ret)
                    elif self.socket_port == 1000:
                        att_value = int(cmd_ret.split(':')[-1])
                    dict_ret[ch_num] = att_value
            else:  # recv empty string
                log.info('WARN: JieXi attenuator %s read channel %d ATT value '
                         % (self.host, ch_num) + 'failed, no data received')
                dict_ret[ch_num] = -1
        return dict_ret


class FacomAttenuator(AttenuatorCommon):
    """This a class realizes:
       Attenuation value set/read for Facom attenuators.
    """
    TRIAL_COUNT = 3
    SOCK_TIMEOUT = 2

    def __init__(self, host, socket_port):
        """@param host: string of attenuator's IP(or network name).
           @param socket_port: attenuator's socket port, integer.
        """

        super(FacomAttenuator, self).__init__(host, socket_port,
                                              self.SOCK_TIMEOUT)
        recv = self.send_and_recv_cmd("$TA,Z*\r\n", 10)

        if "*" in recv.strip()[:-1]:
            self.type = "array"
            self.row, self.col = re.search('(\\d\\d)\\*(\\d\\d)', recv).groups()

        else:
            self.type = "non_array"

    def set_multi_ch_att(self, *channels_att_values):
        """@param *channels_att_values:
            channel number, attenuation value, ... (all are integers)
           @return: True/False
        """
        if self.type == "non_array":
            ret = self._set_val_non_array(*channels_att_values)
        else:
            ret = self._set_val_array(*channels_att_values)
        return ret

    def _set_val_array(self, *channels_att_values):
        ret_val = False
        num_of_ch = len(channels_att_values) // 2
        for idx in range(num_of_ch):
            ch_num = channels_att_values[2 * idx]
            att_value = channels_att_values[2 * idx + 1]
            row = str((int(ch_num)-1) % int(self.row)+1).zfill(2)
            col = str((int(ch_num)-1) // int(self.row)+1).zfill(2)
            facom_value = hex(int(att_value) * 2)[2:].upper()
            cmd_to_send = "$TA,A,%s%s%s*\r\n" % (row, col, facom_value)
            cmd_ret = self.send_and_recv_cmd(cmd_to_send, 2)
            log.info(
                "send->'%s', Receive<-'%s'" %
                (cmd_to_send.strip(), cmd_ret.strip()))
            ret_val = True
            cmd_to_send = "$TA,B,%s%s*\r\n" % (row, col)
            cmd_ret = self.send_and_recv_cmd(cmd_to_send, 2)
            log.info(
                "send->'%s', Receive<-'%s'" %
                (cmd_to_send.strip(), cmd_ret.strip()))
        return ret_val

    def _set_val_non_array(self, *channels_att_values):
        ret_val = False
        num_of_ch = len(channels_att_values) // 2
        for idx in range(num_of_ch):
            ch_num = channels_att_values[2 * idx]
            att_value = channels_att_values[2 * idx + 1]

            channel = int(ch_num)
            if channel < 10:
                channel = '0%s' % channel
            facom_value = hex(int(att_value) * 2)[2:].upper()
            if len(facom_value) == 1:
                facom_value = '0%s' % facom_value
            cmd_to_send = "$TA,C,%s%s*\r\n" % (channel, facom_value)

            cmd_ret = self.send_and_recv_cmd(cmd_to_send, 2)
            log.info(
                "send->'%s', Receive<-'%s'" %
                (cmd_to_send.strip(), cmd_ret.strip()))
            ret_val = True
            cmd_to_send = "$TA,H,%s*\r\n" % (channel)
            log.info(
                "send->'%s', Receive<-'%s'" %
                (cmd_to_send.strip(), cmd_ret.strip()))

        return ret_val

    def get_multi_ch_att(self, *channels):
        """@param *channels: channel numbers, integer.
           @return: dict of channel:att_value pairs,
           if att_value == 1, means that channel didn't get ATT value properly.
        """
        dict_ret = {}
        for ch_num in channels:
            ch_num = int(ch_num)
            if ch_num < 10:
                ch_num = '0%s' % ch_num
            cmd_to_send = "$TA,H,%s*\r\n" % ch_num

            cmd_ret = self.send_and_recv_cmd(cmd_to_send,
                                             len(cmd_to_send)).strip()

            if cmd_ret:
                if 'FF' in cmd_ret:
                    log.info('WARN: Facom attenuator %s read channel %s '
                             % (self.host, ch_num) +
                             'ATT value failed, command return = "%s"'
                             % cmd_ret)
                    dict_ret[ch_num] = -1
                else:
                    dict_ret[ch_num] = int(cmd_ret[6:8], 16) // 2
            else:  # recv empty string
                log.info('WARN: JieXi attenuator %s read channel %s ATT value '
                         % (self.host, ch_num) + 'failed, no data received')
                dict_ret[ch_num] = -1
        return dict_ret

    def set_value_by_csv(self, vendor_ip_port, csv_path):
        vendor, host, port = vendor_ip_port.split(':')
        import socket
        clientsocket = socket.socket(socket.AF_INET, socket.SOCK_STREAM)
        clientsocket.settimeout(3)
        clientsocket.connect((host, int(port)))
        csvFile = open(csv_path, 'r')
        reader = csv.reader(csvFile)
        row = 0
        col = 0
        for i in reader:
            log.info('source: %s' % i)
            tmp = "".join(i)
            if 'PA' in tmp or 'B' in tmp:
                continue
            row = row + 1
            channel_value = []
            for j in range(len(i)):
                if not i[j]:
                    continue
                col = col + 1
                i_s = i[j]
                i_s_hex = hex(int(float(i_s)+float(i_s))).upper()
                i_s_hex = i_s_hex[2:]
                i_s_hex = str(i_s_hex).zfill(2)
                channlA = str(row).zfill(2)
                channlB = str(col).zfill(2)
                cv = "{channlA}{channlB}{att}".format(
                        channlA=channlA, channlB=channlB, att=i_s_hex)
                channel_value.append(cv)
                sendcmd = "$TA,A,%s*\r\n" % cv
                clientsocket.sendall(sendcmd.encode())
                clientsocket.recv(2000)
                if col == 16:
                    col = 0
            log.info(','.join(channel_value))
        clientsocket.close()


class JfwAttenuator(AttenuatorCommon):
    """This a class realizes:
       Attenuation value set/read for JFW attenuators.
    """
    TRIAL_COUNT = 3
    SOCK_TIMEOUT = 2

    def __init__(self, host, socket_port):
        """@param host: string of attenuator's IP(or network name).
           @param socket_port: attenuator's socket port, integer.
        """
        super(JfwAttenuator, self).__init__(host, socket_port,
                                            self.SOCK_TIMEOUT)

    def set_multi_ch_att(self, *channels_att_values):
        """@param *channels_att_values:
            channel number, attenuation value, ... (all are integers).
           @return: True/False.
        """
        cmd_to_send = ''

        num_of_ch = len(channels_att_values) // 2
        for idx in range(num_of_ch):
            ch_num = channels_att_values[2 * idx]
            att_value = channels_att_values[2 * idx + 1]
            if att_value < 0:
                att_value = 0
            if att_value > 63:
                att_value = 63
            if idx == 0:
                cmd_to_send += 'SA -TR %d %d,' % (ch_num, att_value)
            else:
                cmd_to_send += '%d %d,' % (ch_num, att_value)

        cmd_to_send = cmd_to_send[:-1] + '\r\n'

        cmd_ret = self.send_and_recv_cmd(cmd_to_send, 0).strip()
        if cmd_ret:
            log.info("JFW attenuator '%s' set ATT value succeeded, "
                     % self.host + 'command return = "%s"' % cmd_ret)
            return True
        else:
            log.info('WARN: JFW attenuator %s set ATT value ' %
                     self.host + 'failed, command return NULL')
            return True

    def get_multi_ch_att(self, *channels):
        """@param *channels: channel numbers, integer.
           @return: dict of channel:att_value pairs, or {}.
        """
        dict_ret = {}
        cmd_to_send = 'RAA\r\n'
        cmd_ret = self.send_and_recv_cmd(cmd_to_send, 10).strip()
        if cmd_ret:
            att_values = cmd_ret.split(';')
            for ch_num in channels:
                if len(att_values) < ch_num:
                    raise Exception('JFW attenuator %s read ATT value failed'
                                    % self.host + ', channel %d is ' % ch_num +
                                    'out of attenuator\'s physical range 1~%d'
                                    % len(att_values))
                att_value = att_values[ch_num - 1]
                att_value = int(att_value.split(' ')[-1])
                dict_ret[ch_num] = att_value
            return dict_ret
        else:
            log.info('WARN: JFW attenuator %s read ATT value ' % self.host +
                     'failed, no data received')
            return dict_ret


class JfwSfeAttenuator(AttenuatorCommon):
    """This a class realizes:
       Attenuation value set/read for JFW attenuators.
    """
    TRIAL_COUNT = 3
    SOCK_TIMEOUT = 2

    def __init__(self, host, socket_port):
        """@param host: string of attenuator's IP(or network name).
           @param socket_port: attenuator's socket port, integer.
        """
        super(JfwSfeAttenuator, self).__init__(host, socket_port,
                                               self.SOCK_TIMEOUT)

    def set_multi_ch_att(self, *channels_att_values):
        """@param *channels_att_values:
            channel number, attenuation value, ... (all are integers).
           @return: True/False.
        """
        cmd_to_send = ''
        num_of_ch = len(channels_att_values) // 2
        for idx in range(num_of_ch):
            ch_num = channels_att_values[2 * idx]
            att_value = channels_att_values[2 * idx + 1]
            if att_value < 0:
                att_value = 0
            if att_value > 63:
                att_value = 63

            cmd_to_send += 'ATT %d %d\r\n' % (ch_num, att_value)
            cmd_ret = self.send_and_recv_cmd(cmd_to_send, 0).strip()
            log.info(cmd_ret)

    def get_multi_ch_att(self, *channels):
        """@param *channels: channel numbers, integer.
           @return: dict of channel:att_value pairs, or {}.
        """
        return
        '''
        dict_ret = {}
        cmd_to_send = 'RAA\r\n'
        cmd_ret = self.send_and_recv_cmd(cmd_to_send, 10).strip()
        if cmd_ret:
            att_values = cmd_ret.split(';')
            for ch_num in channels:
                if len(att_values) < ch_num:
                    raise Exception('JFW attenuator %s read ATT value failed'
                                    % self.host + ', channel %d is ' % ch_num +
                                    'out of attenuator\'s physical range 1~%d'
                                    % len(att_values))
                att_value = att_values[ch_num - 1]
                att_value = int(att_value.split(' ')[-1])
                dict_ret[ch_num] = att_value
            return dict_ret
        else:  # recv empty string
            log.info('WARN: JFW attenuator %s read ATT value ' % self.host +
                     'failed, no data received')
            return dict_ret
        '''
