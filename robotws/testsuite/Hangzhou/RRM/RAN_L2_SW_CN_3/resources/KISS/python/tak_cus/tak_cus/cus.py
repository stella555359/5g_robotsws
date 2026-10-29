from robot.libraries.Telnet import Telnet
import logging
import time
import re
from robot.libraries.BuiltIn import BuiltIn
from .exception import SectorIsNotReady


class Cus(object):

    def __init__(self):
        self._cus_connected = False
        try:
            self.uex_obj = BuiltIn().get_library_instance("ta_uexgate")
        except Exception as err:
            pass

    def _connect(self, port=1234, host='127.0.0.1', set_true=True):
        self.cus_conn = Telnet()
        self.cus_conn.open_connection(host, port=port)
        if set_true:
            self._cus_connected = True
        logging.info("connect to ue '%s:%s' succeed !" % (host, port))

    def execute_cus_command(self, cmd, prompt='CUS>', prompt_is_regexp=False):
        if not self._cus_connected:
            logging.info("setup a new cus connection")
            self._connect()
        self.cus_conn.set_timeout(20)
        self.cus_conn.set_prompt(prompt, prompt_is_regexp)
        output = self.cus_conn.execute_command(cmd)
        time.sleep(2)
        self._disconnect()
        return output

    def _disconnect(self):
        if self._cus_connected:
            self.cus_conn.close_connection()
            self._cus_connected = False

    def execute_uex_command(self, cmd):
        logging.debug("now executing '{}'...".format(cmd))
        args = []
        kwargs = {}
        if len(cmd.split()) > 1:
            for item in cmd.split()[1:]:
                if "=" in item:
                    kwargs[item.split("=")[0]] = item.split("=")[1]
                else:
                    args.append(item)
        return self.uex_obj.run_uex_command(cmd.split()[0], *args, **kwargs)

    def attach(self, ue_id_str, cell_id_str, interval, timeout, retry, ue_eutra_capabilities=None, enb_id_str=None,
               selected_plmn=None):
        ue_id_list, cell_id_list = self._convert_ue_id_from_str_to_list(ue_id_str, cell_id_str)
        if enb_id_str:
            _, enb_id_list = self._convert_ue_id_from_str_to_list(ue_id_str, enb_id_str)
        for index in range(0, len(ue_id_list)):
            cmd = "ue_attach id={} cell={}".format(ue_id_list[index], cell_id_list[index])
            if enb_id_str:
                cmd = "{} enb={}".format(cmd, enb_id_list[index])
            if ue_eutra_capabilities:
                cmd = "{} ue_eutra_capabilities={}".format(cmd, ue_eutra_capabilities)
            if selected_plmn:
                cmd = '{} selected_plmn="{}"'.format(cmd, selected_plmn)
            self.execute_uex_command(cmd)
            time.sleep(interval)

    def detach(self, ue_id_str, interval):
        ue_id_list, cell_id_list = self._convert_ue_id_from_str_to_list(ue_id_str)
        for index in range(0, len(ue_id_list)):
            self.execute_uex_command("ue_detach id={}".format(ue_id_list[index]))
            time.sleep(interval)

    def detach_all(self, interval):
        ue_summary = self.execute_uex_command("get_ue_summary")
        ue_to_detach = ue_summary["active"] + ue_summary["idle"]
        if len(ue_to_detach) == 0:
            return
        for ue in ue_to_detach:
            self.execute_uex_command("ue_detach id={}".format(ue))
            time.sleep(interval)

    def sector_id_ready(self, cell_id, timeout):
        stime1 = time.time()
        while True:
            stime2 = time.time()
            if (stime2 - stime1) > timeout:
                raise SectorIsNotReady("SECTOR-{} is not ready.".format(cell_id))
            else:
                try:
                    self.execute_cus_command("cm connect", "SECTOR-{}.*ready".format(cell_id), True)
                    return True
                except Exception as e:
                    logging.info(e)

    def start_data_traffic(self, ue_id_str, through_put, direction, protocol, **kwargs):
        unit, through_put = self._validate_and_return_throughput(through_put)
        ue_id_list, cell_id_list = self._convert_ue_id_from_str_to_list(ue_id_str)
        for ue_id in ue_id_list:
            execute_cmd = "trf_data_start ue=%s dir=%s protocol=%s %s=%s" % (ue_id, direction, protocol,
                                                                             unit, through_put)
            for key in kwargs:
                execute_cmd = execute_cmd + " %s=%s" % (key, kwargs[key])
            logging.info(self.execute_uex_command(execute_cmd))

    def get_throughput_ave(self, ue_id, type, unit):
        return self.get_throughput(ue_id, type, "avg", unit)

    def get_throughput(self, ue_id, stat_type, tput_type, unit):
        cmd = "get_ue_stats id=%s type=%s unit=%s" % (ue_id, stat_type, unit)
        ue_stats = self.execute_uex_command(cmd)
        return float('%.2f' % ue_stats['UE']['Overall'][tput_type])

    def stop_data_traffic(self, ue_id_str, direction, **kwargs):
        ue_id_list, cell_index_list = self._convert_ue_id_from_str_to_list(ue_id_str)
        for ue_id in ue_id_list:
            execute_cmd = "trf_data_stop dir=%s ue=%s" % (direction, ue_id)
            for key in kwargs:
                execute_cmd = execute_cmd + " %s=%s" % (key, kwargs[key])
            logging.info(self.execute_uex_command(execute_cmd))

    def get_throughput_on_specific_scell(self, ue_id, type, scell_id, tput_type):
        pass_regexp = self._check_params_for_get_throughput_on_specific_scell(ue_id, scell_id, tput_type)

        execute_ue_stats_command = "get_ue_stats id=%s type=%s scell=%s" % (ue_id, type, scell_id)
        logging.info('execute_ue_stats_command %s' % execute_ue_stats_command)
        ret = self.execute_uex_command(execute_ue_stats_command)["UE"]
        logging.info('execute_ue_stats_command result %s' % ret)
        if pass_regexp not in ret:
            raise Exception("return vlaue is incorrect, maybe scell is not configured. please check it!!!")

        throughput = ret[pass_regexp][tput_type]
        throughput = float(throughput) / 1000
        return float('%.2f' % throughput)

    def create_bearer(self, ue_id_str, qci_id_str, **kwargs):
        ue_id_list, qc_id_list = self._convert_ue_id_from_str_to_list(ue_id_str, qci_id_str)
        for index in range(0, len(ue_id_list)):
            cmd = "bearer_add ue=%s qci=%s" % (ue_id_list[index], qc_id_list[index])
            for key in kwargs:
                execute_cmd = execute_cmd + " %s=%s" % (key, kwargs[key])
            self.execute_uex_command(cmd)

    def get_througput_for_each_bearer(self, ue_id, direction, bearer_id, tput_type):
        throughput_table = self._get_throughput_table_from_ue_stats(ue_id, direction)
        tput_value_dic = {}
        for id in range(0, 30):
            id = 'EPS' if id == 0 else 'EPS' + str(id)
            if id in throughput_table:
                throughput_value = throughput_table[id]['Overall'][tput_type]
                tput_value_dic[id] = throughput_value
        if bearer_id:
            eps = "EPS{}".format(bearer_id)
            return tput_value_dic[eps]
        return tput_value_dic

    def verify_that_average_throughput_for_each_bearer_is_on_target(self, ue_id, direction, throughput_target):
        throughput_table = self._get_throughput_table_from_ue_stats(ue_id, direction)
        for bearer_id in range(0, 30):
            bearer_id = 'EPS' if bearer_id == 0 else 'EPS' + str(bearer_id)
            if bearer_id in throughput_table:
                throughput_value = throughput_table[bearer_id]['Overall']['avg']
                print('Bearer {} throughput value: {}'.format(bearer_id, throughput_value))
                self._compate_current_throughput_with_target(throughput_value, throughput_target)

    def get_cell_throughput(self, cell_id, stat_type, tput_type, unit):
        cmd = "get_cell_stats id=%s type=%s unit=%s" % (cell_id, stat_type, unit)
        cell_stats = self.execute_uex_command(cmd)
        return float('%.2f' % cell_stats[tput_type])

    def _compate_current_throughput_with_target(self, current_throughput, target_throughput):
        current_throughput = float(current_throughput)
        target_throughput = float(target_throughput)
        c = abs(current_throughput - target_throughput) <= 0.1 * target_throughput
        assert c, "current_throughput: {} did not meet target_throughput: {}!".format(current_throughput,
                                                                                      target_throughput)

    def _get_throughput_table_from_ue_stats(self, ue_id, direction):
        """
        Gets the throughput stats from ue_stats in form of a python dictionary.

        :param ue_id:
        :param direction:
        :return:
        """
        number_of_tries = 5

        for i in range(number_of_tries):
            output = self.execute_uex_command('get_ue_stats id={} type={}_rlc unit=Mbps output=extended'.format(
                ue_id, direction))
            error_found = "Error:" in output
            if not error_found:
                break
        return output

    def _convert_ue_id_from_str_to_list(self, ue_id_str, other_id_str=""):
        ue_id_list = []
        other_id_list = []
        ue_id_str_list = str(ue_id_str).split(',')
        other_id_str_list = str(other_id_str).split(',')
        for ue_id in ue_id_str_list:
            if '...' in ue_id:
                for ue in range(int(ue_id.split('...')[0]), int(ue_id.split('...')[1]) + 1):
                    ue_id_list.append(str(ue))
                    if len(other_id_str_list) > 1:
                        other_id_list.append(other_id_str_list[ue_id_str_list.index(ue_id)])
                    elif len(other_id_str_list) == 1:
                        other_id_list.append(other_id_str_list[0])
            else:
                ue_id_list.append(ue_id)
                if len(other_id_str_list) > 1:
                    other_id_list.append(other_id_str_list[ue_id_str_list.index(ue_id)])
                elif len(other_id_str_list) == 1:
                    other_id_list.append(other_id_str_list[0])
        return ue_id_list, other_id_list

    def _validate_and_return_throughput(self, throughput):
        """
            Perform conversion from following units:
            - 'bits/sec'
            - 'Kbits/sec'
            - 'Mbits/sec'
            - 'Bytes/sec'
            - 'KBytes/sec'
            - 'MBytes/sec'
            eg. '10 MBytes/sec'

            Note: conversion rate is equal to 1000:
                1KByte = 1000 Byte; 1MByte = 1000 KByte; etc

            :param throughput: throughput as string in user readable format
            :return: unit(bps/kbps), throughput
        """
        throughput = throughput.lower()
        if 'sec' not in throughput:
            if 'm' in throughput or 'k' in throughput:
                throughput = throughput + 'bits/sec'
            else:
                throughput = throughput + 'kbits/sec'

        tput_pattern = re.compile(
            r'^([\d.]+) {0,1}([km]{0,1}(bits|bytes)/sec)')
        found_object = tput_pattern.search(throughput)
        if found_object is None:
            raise ValueError("Invalid throughput string: '%s'" % throughput)

        tput_smaller_unit_pattern = re.compile(
            r'^([\d.]+) {0,1}((bits|bytes)/sec)')
        found_smaller_unit_object = tput_smaller_unit_pattern.search(
            throughput)
        if found_smaller_unit_object:
            convertion_rate = {
                'bits/sec': 1,
                'bytes/sec': 8 * 1,
            }
            value, unit = found_smaller_unit_object.group(
                1), found_smaller_unit_object.group(2)
            convert_value = convertion_rate[unit] * int(value)
            unit = 'bps'
        else:
            convertion_rate = {
                'kbits/sec': 1,
                'mbits/sec': 1000,
                'kbytes/sec': 8 * 1,
                'mbytes/sec': 8 * 1000,
            }
            value, unit = found_object.group(1), found_object.group(2)
            convert_value = convertion_rate[unit] * int(value)
            unit = 'kbps'

        return unit, convert_value

    def _check_params_for_get_throughput_on_specific_scell(self, ue_id, scell_id, tput_type):
        """check if give parameters for get_throughput_on_specific_scell is validate
                and return pass_regex to get_iphy_throughput_on_specific_scell"""
        if str(tput_type).upper() not in ['AVG', 'MAX', 'MIN', 'CUR']:
            raise Exception(
                "direction or tput_type is invalid, please check it!!!")
        if not str(ue_id).isdigit() or not str(scell_id).isdigit():
            raise Exception("ue_id or scell id is invalid!!!")
        if int(str(scell_id)) == 0:
            pass_regexp = "PCell"
        else:
            pass_regexp = "Scell-{}".format(scell_id)
        return pass_regexp
