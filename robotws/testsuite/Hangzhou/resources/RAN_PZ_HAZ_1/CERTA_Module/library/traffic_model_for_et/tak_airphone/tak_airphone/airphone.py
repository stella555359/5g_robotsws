# -*- coding: utf-8 -*-
"""
:created on: 18-02-2024

:copyright: Nokia
:author: winnie he
:contact: winnie.he@nokia-sbell.com
"""

import logging
import os
import re
import time
import pkg_resources
from ute_wtssim import ute_wtssim
import copy


class Airphone(object):
    def __init__(self, edamon_port, egate_port, tool_dir, host_ip, save_egate=False):
        """Init

        :param edamon_port: Edamon port
        :param egate_port: Egate port
        :param tool_dir: Path to the directory where the edaemon binary is available
        :param host_ip: IP address of the remote/local machine
        """
        self.wtssim = ute_wtssim()
        self._log = logging.getLogger(__name__)
        self.edamon_port = edamon_port
        self.egate_port = egate_port
        self.tool_dir = tool_dir
        self.host_ip = host_ip
        self.wts_alias = None
        self.reconnect = False
        self.enb_id = None
        self.gnb_id = None
        self.wts_cfg_file = None
        self.save_egate = save_egate
        self._ue_lua_path = os.path.join(pkg_resources.resource_filename("tak_airphone", "tak_airphone"),
                                         "luafiles", "ue_script.lua")

    def get_wtssim_obj(self):
        return self.wtssim

    def setup(self, **kwargs):
        """Setup

        :param kwargs:
        :return:
        """
        self.wts_alias = kwargs.get('alias')
        print("wts alias "+self.wts_alias)
        self.wtssim.setup_egate(self.egate_port, host_ip=self.host_ip, tool_dir=self.tool_dir,
                                save_egate=self.save_egate,
                                alias=self.wts_alias)
        self.wtssim.setup_edaemon(
            self.edamon_port,
            host_ip=self.host_ip,
            tool_dir=self.tool_dir,
            alias=self.wts_alias)
        self.wtssim.link_edaemons_to_egate(alias=self.wts_alias)

    def start_wtssim_with_cfg_file(self, cfg_file, reload, timeout):
        """Start wtssim and load cfg files

        :param cfg_file: Path to the lua file where egate configuration is stored
        :param reload: load cfg file or not
        :param timeout: Timeout
        :return:
        """
        self.wts_cfg_file = cfg_file
        if reload:
            if self.reconnect:
                self.execute_command('reset')
            if not os.path.exists(cfg_file):
                raise Exception("{} file is not exist!".format(cfg_file))
            self.wtssim.start_egate_process(cfg_file, timeout=timeout, reconnect=self.reconnect)
            self.reconnect = True

    def execute_command(self, cmd, pass_regexp=None, fail_regexp=None, timeout=10, **kwargs):
        """To execute a single command passed to airphone for the specific objective

        :param cmd: Command to execute.
        :param pass_regexp: Regexp indIcating that the command passed.
        :param fail_regexp: Regexp indicating that the command failed.
        :param timeout: Timeout for waiting this operation print pass_regexp
        :param kwargs:
        :return:
        """
        ret = self.wtssim.execute_egate_command(cmd, pass_regexp, fail_regexp, timeout, **kwargs)
        return ret

    def execute_command_and_wait_for_data(self, cmd, pass_regexp=None, timeout=10, **kwargs):
        """To execute a single command passed to airphone for the specific objective

        :param cmd: Command to execute.
        :param pass_regexp: Regexp indIcating that the command passed.
        :param timeout: Timeout for waiting this operation print pass_regexp
        :param kwargs:
        :return:
        """
        ret = self.wtssim.execute_egate_command_and_wait_for_data(cmd, timeout, pass_regexp=pass_regexp, **kwargs)
        return ret

    def _get_id_from_enb_disp(self, type):
        """

        :param type: enb/ENB or gnb/GNB
        :return:
        """
        self.set_log_flush()
        id = ''
        disp_info = self.execute_command_and_wait_for_data('enb_disp', 'EGATE>')
        self._log.info(disp_info)
        for line in disp_info.split("\n"):
            if type.upper() in line:
                if type.upper() == 'GNB' and 'external' in line:
                    id = line.split()[0]
                    break
                elif type.upper() != 'GNB':
                    id = line.split()[0]
                    break
        self._log.info(id)
        return id

    def get_cell_id_list(self, type):
        """Get all cell ids from egate

        :param type: enb or gnb
        :return: Cell id list
        """
        cell_id_list = []
        type_id = self._get_id_from_enb_disp(type)
        self.set_log_flush()
        disp_info = self.execute_command_and_wait_for_data('enb_disp id={}'.format(type_id), 'EGATE>')
        self._log.info(disp_info)
        for line in disp_info.split("\n"):
            ret = re.search('Cell (\\d+)', line)
            if ret:
                cell_id = ret.groups()[0]
                self._log.info(cell_id)
                cell_id_list.append(cell_id)
        return cell_id_list

    def get_enb_id(self):
        """Get enb id from egate

        :return:
        """
        self.set_log_flush()
        disp_info = self.execute_command_and_wait_for_data('enb_disp', 'EGATE>')
        self._log.info(disp_info)
        for line in disp_info.split("\n"):
            if 'ENB' in line and 'simulated' in line:
                self.enb_id = re.search('\\d+', line.split()[0]).group()
                break
        self._log.info(self.enb_id)
        return self.enb_id

    def get_gnb_id(self):
        """Get gnb id from egate

        :return:
        """
        self.set_log_flush()
        disp_info = self.execute_command_and_wait_for_data('enb_disp', 'EGATE>')
        self._log.info(disp_info)
        for line in disp_info.split("\n"):
            if 'GNB' in line and 'external' in line:
                self.gnb_id = re.search('\\d+', line.split()[0]).group()
                break
        self._log.info(self.gnb_id)
        return self.gnb_id

    def _get_id_from_cfg_file(self, type):
        """

        :param type:
        :return:
        """
        with open(self.wts_cfg_file, 'r') as f:
            content = f.read()
            id_ret = re.search('set_{} id=(\\d+)'.format(type), content)
            if not id_ret:
                var = re.search("set_{} id='..(\\w+)..'".format(type), content).groups()[0]
                id_ret = re.search('{}="(\\d+)"'.format(var), content)
            return id_ret.groups()[0]

    def wait_until_sib1_received(self, cell_id=1, timeout=600):
        """Wait unitl sib1 received.

        :param cell_id: Cell ID, default is 1
        :param timeout: Timeout, default is 600 seconds
        """
        disp_info = self.execute_command_and_wait_for_data(cmd='enb_cell_ib_disp enb={} cell={} type=sib1'.format(
            self.gnb_id, cell_id), pass_regexp="systemInformationBlockType1", timeout=timeout)
        self._log.info(disp_info)

    def get_sim_state(self):
        """Get sim state

        :return: The state of simulator
        """
        self.set_log_flush()
        sim_state_cmd = 'sim_state_disp'
        self._log.info('command of get simulator state: {}'.format(sim_state_cmd))
        ret = self.execute_command(cmd=sim_state_cmd, pass_regexp="The state is")
        for line in ret.split('\n'):
            if 'The state is' in line:
                state = line.strip().split(' ')[-1]
                return state
            else:
                continue
        raise Exception("can't get simulator state!!!")

    def nsa_lte_attach(self, ue_id, profile_id, timeout, ue_nr_capabilities, ue_eutra_nr_capabilities):
        """Lte attach specified ue id for NSA

        :param ue_id: UE ID
        :param profile_id: Profile id
        :param timeout: UE attach timeout
        :param ue_nr_capabilities: UE capability
        :param ue_eutra_nr_capabilities: UE capability
        :return:
        """
        timeout = int(timeout)
        cmd = "ue_attach id={} profile={}".format(ue_id, profile_id) if profile_id else "ue_attach id={}".format(ue_id)
        if ue_nr_capabilities:
            cmd = "{} ue_nr_capabilities={}".format(cmd, ue_nr_capabilities)
        if ue_eutra_nr_capabilities:
            cmd = "{} ue_eutra_nr_capabilities={}".format(cmd, ue_eutra_nr_capabilities)
        ret = self.execute_command(cmd, pass_regexp="UE IS ACTIVE", timeout=timeout)
        self._log.info(ret)

    def nsa_5g_attach(self, ue_id, cell_id, bearer_id, timeout):
        """5g attach specified ue id for NSA

        :param ue_id: UE ID
        :param cell_id: Cell id
        :param bearer_id: Bearer id
        :param timeout: UE attach timeout
        :return:
        """
        if not self.gnb_id:
            self.get_gnb_id()
        cmd = "ue_dc_enb_start ue=%s target_gnb=%s target_cells=%s bearer=%s type=split_scg" \
              % (ue_id, self.gnb_id, cell_id, bearer_id)
        ret = self.execute_command(cmd, pass_regexp="reported successful RA", timeout=timeout)
        self._log.info(ret)

    def nsa_attach(self, ue_id, profile_id, cell_id, bearer_id, interval, timeout,
                   ue_nr_capabilities, ue_eutra_nr_capabilities):
        """Attach specified ue id for NSA

        :param ue_id: UE ID
        :param profile_id: Profile id
        :param cell_id: Cell id
        :param bearer_id: Bearer id
        :param interval: Interval
        :param timeout: UE attach timeout
        :param ue_nr_capabilities: UE capability
        :param ue_eutra_nr_capabilities: UE capability
        :return:
        """
        ue_id_list = self._convert_id_from_str_to_list(ue_id) if not isinstance(ue_id, int) else [ue_id]
        timeout = int(timeout)
        start_time = time.time()
        for ue in ue_id_list:
            new_timeout = timeout - (time.time() - start_time)
            self.nsa_lte_attach(ue, profile_id, new_timeout, ue_nr_capabilities, ue_eutra_nr_capabilities)
            self.nsa_5g_attach(ue, cell_id, bearer_id, new_timeout)
            time.sleep(interval)

    def nsa_detach(self, ue_id, timeout, interval):
        """Detach specified ue id for NSA

        :param ue_id: UE ID
        :param timeout: UE detach timeout
        :param interval: interval, default is 0.5
        :return:
        """
        ue_id_list = self._convert_id_from_str_to_list(ue_id) if not isinstance(ue_id, int) else [ue_id]
        timeout = int(timeout)
        start_time = time.time()
        for ue in ue_id_list:
            new_timeout = timeout - (time.time() - start_time)
            cmd = "ue_detach id={}".format(ue)
            ret = self.execute_command(cmd, pass_regexp="detached", timeout=new_timeout)
            self._log.info(ret)
            time.sleep(interval)

    def nsa_detach_all(self, interval, timeout):
        """Detach all ue for NSA

        :param interval: interval, default is 0.5
        :param timeout: UE detach timeout, default is 30 seconds
        :return:
        """
        entry = "nsa_detach_all_ue(%s,%s)" % (interval, timeout)
        cmd_str = "script file=%s entry=%s" % (self._ue_lua_path, entry)
        self._log.info(self.execute_command(cmd_str, timeout=timeout, pass_regexp="PASSED"))

    def setup_x2_connection(self, timeout, enb_id, gnb_id):
        """Setup X2 connection for NSA bts onair

        :param timeout: setup x2 connection timeout
        :param enb_id: enb id
        :param gnb_id: gnb id
        :return:
        """
        if not enb_id:
            if not self.enb_id:
                self.get_enb_id()
            enb_id = self.enb_id
        if not gnb_id:
            if not self.gnb_id:
                self.get_gnb_id()
            gnb_id = self.gnb_id
        cmd = "enb_x2_link_up enb=%s target=%s" % (enb_id, gnb_id)
        ret = self.execute_command(cmd, pass_regexp="ENB-{}: X2AP Link with GNB-{} .* is up".format(enb_id, gnb_id),
                                   timeout=timeout)
        self._log.info(ret)

    def set_traffic_type(self, ue_id, pdu_id, type, timeout, interval):
        """Airphone set traffic type

        :param ue_id: UE ID
        :param pdu_id: pdu id
        :param type: trf type
        :return:
        """
        ue_id_list = self._convert_id_from_str_to_list(ue_id) if not isinstance(ue_id, int) else [ue_id]
        timeout = int(timeout)
        start_time = time.time()
        for ue in ue_id_list:
            new_timeout = timeout - (time.time() - start_time)
            cmd = "set_pdu_param ue=%s pdu=%s trf_type=%s" % (ue, pdu_id, type)
            self._log.info(cmd)
            ret = self.execute_command(cmd, timeout=new_timeout)
            self._log.info(ret)
            time.sleep(interval)

    def sa_attach(self, ue_id, timeout, ue_capability, interval):
        """Attach specified ue id for SA

        :param ue_id: UE ID
        :param timeout: UE attach timeout
        :param ue_capability: UE capability
        :param interval:
        :return:
        """
        ue_id_list = self._convert_id_from_str_to_list(ue_id) if not isinstance(ue_id, int) else [ue_id]
        timeout = int(timeout)
        start_time = time.time()
        for ue in ue_id_list:
            new_timeout = timeout - (time.time() - start_time)
            cmd = "ue_register id={} ue_nr_capabilities={}".format(ue, ue_capability) if ue_capability \
                else "ue_register id={}".format(ue)
            ret = self.execute_command(cmd, pass_regexp="REGISTRATION COMPLETE", timeout=new_timeout)
            self._log.info(ret)
            time.sleep(interval)

    def sa_detach(self, ue_id, timeout, interval):
        """Detach specified ue id for SA

        :param ue_id: UE ID
        :param timeout: UE detach timeout
        :param interval:
        :return:
        """
        ue_id_list = self._convert_id_from_str_to_list(ue_id) if not isinstance(ue_id, int) else [ue_id]
        timeout = int(timeout)
        start_time = time.time()
        for ue in ue_id_list:
            new_timeout = timeout - (time.time() - start_time)
            cmd = "ue_deregister id={} ue_deregister_type=switch_off".format(ue)
            ret = self.execute_command(cmd, pass_regexp="UE Context Release Complete", timeout=new_timeout)
            self._log.info(ret)
            time.sleep(interval)

    def pdu_session_setup(self, ue_id, pdu_id, nwslice_id, gw_id, timeout, pass_regexp, interval):
        """Simulate PDU session setup on 5GNR side

        :param ue_id: ue id
        :param pdu_id: default is 1
        :param nwslice_id: default is 1
        :param gw_id: default is 1
        :param timeout: simulate PDU session, default is 180
        :param pass_regexp: pass regex
        :param interval: interval, default is 0.5
        :return:
        """
        ue_id_list = self._convert_id_from_str_to_list(ue_id) if not isinstance(ue_id, int) else [ue_id]
        timeout = int(timeout)
        start_time = time.time()
        for ue in ue_id_list:
            new_timeout = timeout - (time.time() - start_time)
            cmd = "ue_pdu_session_setup pdu=%s ue=%s nwslice=%s gw=%s" % (pdu_id, ue, nwslice_id, gw_id)
            ret = self.execute_command(cmd, pass_regexp=pass_regexp, timeout=new_timeout)
            self._log.info(ret)
            time.sleep(interval)

    def nsa_start_data_traffic(self, ue_id, direction, throughput, trf_id, bearer_id, duration, interval, protocol,
                               **kwargs):
        """NSA start data traffic

        :param ue_id: UE ID
        :param direction: downlink or uplink
        :param throughput: throughput value, desired data transfer throughput
        :param trf_id: trf id
        :param bearer_id:
        :param duration: duration value
        :param interval:
        :param protocol:
        :param kwargs:
        :return:
        """
        value = re.search('\\d+', throughput).group()
        unit = re.search('[a-zA-Z]+', throughput).group().lower()
        ue_id_list = self._convert_id_from_str_to_list(ue_id) if not isinstance(ue_id, int) else [ue_id]
        for ue in ue_id_list:
            cmd = "trf_data_start ue=%s id=%s dir=%s trf_id=%s %s=%s seconds=%s" % (ue, bearer_id,
                                                                                    direction, trf_id, unit, value,
                                                                                    duration)
            if protocol != "udp":
                cmd = cmd + " protocol=%s" % protocol
            for key in kwargs:
                cmd = cmd + " %s=%s" % (key.lower(), kwargs[key])
            self._log.info("cmd = %s" % cmd)
            ret = self.execute_command(cmd, pass_regexp="TRF", fail_regexp="Can't start traffic")
            self._log.info(ret)
            time.sleep(interval)

    def nsa_stop_data_traffic(self, ue_id, direction, bearer_id, interval, **kwargs):
        """NSA stop data traffic

        :param ue_id: UE ID
        :param direction: downlink or uplink
        :param bearer_id:
        :param interval:
        :param kwargs:
        :return:
        """
        ue_id_list = self._convert_id_from_str_to_list(ue_id) if not isinstance(ue_id, int) else [ue_id]
        for ue in ue_id_list:
            cmd = "trf_data_stop ue=%s id=%s dir=%s" % (ue, bearer_id, direction)
            for key in kwargs:
                cmd = cmd + " %s=%s" % (key.lower(), kwargs[key])
            self._log.info("cmd = %s" % cmd)
            ret = self.execute_command(cmd, pass_regexp="stopped")
            self._log.info(ret)
            time.sleep(interval)

    def nsa_get_throughput(self, ue_id, direction, rate_type, bearer_id, **kwargs):
        """NSA get throughput

        :param ue_id: UE ID
        :param direction: downlink or uplink
        :param rate_type: max or average or min throghput
        :param bearer_id:
        :param kwargs:
        :return: throughput value, unit is kbps
        """
        cmd = "bearer_stats ue=%s id=%s dir=%s" % (ue_id, bearer_id, direction)
        for key in kwargs:
            cmd = cmd + " %s=%s" % (key.lower(), kwargs[key])
        self._log.info("egate cmd=%s" % cmd)
        stats_info = self.execute_command(cmd, pass_regexp="Average packet interval")
        self._log.info(stats_info)
        tput = self._convert_bps_to_kbps(self._analyse_internal_traffic(stats_info, rate_type))
        self.set_log_flush()
        return tput

    def sa_start_data_traffic(self, ue_id, direction, throughput, trf_id, pdu_id, duration, interval, protocol,
                              **kwargs):
        """SA start data traffic

        :param ue_id: UE ID
        :param direction: downlink or uplink
        :param throughput: throughput value, desired data transfer throughput
        :param trf_id: trf id
        :param pdu_id: pdu id
        :param duration: duration value
        :param interval:
        :param protocol:
        :param kwargs:
        :return:
        """
        value = re.search('\\d+', throughput).group()
        unit = re.search('[a-zA-Z]+', throughput).group().lower()
        ue_id_list = self._convert_id_from_str_to_list(ue_id) if not isinstance(ue_id, int) else [ue_id]
        for ue in ue_id_list:
            cmd = "trf_data_start ue=%s pdu=%s dir=%s trf_id=%s %s=%s seconds=%s" % (ue, pdu_id, direction, trf_id,
                                                                                     unit, value, duration)
            if protocol != "udp":
                cmd = cmd + " protocol=%s" % protocol
            for key in kwargs:
                cmd = cmd + " %s=%s" % (key.lower(), kwargs[key])
            self._log.info("cmd = %s" % cmd)
            ret = self.execute_command(cmd, pass_regexp="TRF", fail_regexp="Can't start traffic")
            self._log.info(ret)
            time.sleep(interval)

    def sa_stop_data_traffic(self, ue_id, direction, pdu_id, qfi_id, interval, **kwargs):
        """SA stop data traffic

        :param ue_id: UE ID
        :param direction: downlink or uplink
        :param pdu_id: pdu id
        :param qfi_id: qfi id
        :param interval:
        :param kwargs:
        :return:
        """
        ue_id_list = self._convert_id_from_str_to_list(ue_id) if not isinstance(ue_id, int) else [ue_id]
        for ue in ue_id_list:
            cmd = "trf_data_stop ue=%s pdu=%s qfi=%s dir=%s" % (ue, pdu_id, qfi_id, direction)
            for key in kwargs:
                cmd = cmd + " %s=%s" % (key.lower(), kwargs[key])
            self._log.info("cmd = %s" % cmd)
            pass_regex = "stopped" if 'dl' == direction else "Stopping"
            ret = self.execute_command(cmd, pass_regexp=pass_regex)
            self._log.info(ret)
            time.sleep(interval)

    def sa_get_throughput(self, ue_id, direction, pdu_id, qfi_id, rate_type, **kwargs):
        """SA get throughput

        :param ue_id: UE ID
        :param direction: downlink or uplink
        :param pdu_id: pdu id
        :param qfi_id: qfi id
        :param rate_type: max or average or min throghput
        :param kwargs:
        :return: throughput value, unit is kbps
        """
        cmd = "bearer_stats ue=%s pdu=%s qfi=%s dir=%s" % (ue_id, pdu_id, qfi_id, direction)
        for key in kwargs:
            cmd = cmd + " %s=%s" % (key.lower(), kwargs[key])
        self._log.info("egate cmd=%s" % cmd)
        stats_info = self.execute_command(cmd, pass_regexp="Average packet interval")
        self._log.info(stats_info)
        tput = self._convert_bps_to_kbps(self._analyse_internal_traffic(stats_info, rate_type))
        self.set_log_flush()
        return tput

    def get_throughput_on_specific_scell(self, ue_id, scell_id, type, tput_type):
        """Get airphne throughput on specific scell(ue level).

        :param String ue_id: the identification of ue
        :param Integer scell_id:  the identification of cell. Default is 0
        :param String type: the direction , pdsch or pusch
        :param String tput_type: the type of throughput. Default is 'ave'.
               Support below string: ave, max, min, current.
        :param alias: Name of execution context

        :return: the value of throughput, unit is Kbps.
        :rtype: float
        """
        self._check_params(ue_id, type, scell_id, tput_type)
        ue_stats_command = "ue_stats_nr id=%s type=%s scell=%s" % (ue_id, str(type).lower(), scell_id)
        pass_regex = "CellIndex-{}".format(scell_id)
        ret = self.execute_command(ue_stats_command, pass_regexp=pass_regex)
        self._log.info('ue_stats_command result %s' % ret)
        line_ret = ret.split('\n')
        output_line = ''
        for output in line_ret:
            if pass_regex in output:
                output_line = output
                break
        throughput = float(self._analyse_throughput(output_line, tput_type))
        return throughput

    def _check_params(self, ue_id, direction, scell_id, tput_type):
        """check if give parameters for get_throughput_on_specific_scell is validate"""
        if str(direction).upper() not in ['PDSCH', 'PUSCH'] or str(
                tput_type).upper() not in ['AVE', 'MAX', 'MIN', 'CURRENT']:
            raise Exception(
                "direction or tput_type is invalid, please check it!!!")
        if not str(ue_id).isdigit() or not str(scell_id).isdigit():
            raise Exception("ue_id or scell id is invalid!!!")

    def _analyse_throughput(self, output_line, tput_type):
        """analyse value for get_throughput_on_specific_scell"""
        output_list = output_line.split()[1:]
        if len(output_list) < 8:
            # Add unit bps to keep uniform
            tmp_list = copy.deepcopy(output_list)
            count = 0
            for index in range(0, len(output_list)):
                if not output_list[index].isalpha():
                    if index < len(output_list) - 1 and 'bps' not in output_list[index + 1]:
                        tmp_list.insert(index + count + 1, 'bps')
                        count += 1
                    elif index == len(output_list) - 1:
                        tmp_list.insert(index + count + 1, 'bps')
            output_list = tmp_list
        ret = re.findall("\\d+.*bps", "".join(output_list))
        tput_list = ret[0].split('bps')
        tput_dict = {'current': 0, 'min': 1, 'max': 2, 'ave': 3}
        value_unit = tput_list[tput_dict[tput_type]]
        unit_ret = re.search("[A-Za-z]", value_unit)
        unit = unit_ret.group()[0] if unit_ret else ""
        throughput = value_unit.split(unit)[0] if unit else value_unit
        if 'M' == unit:
            throughput = float(throughput) * 1000
        return throughput

    def collect_edaemon_log_files(self, unzip, subdirectory, **kwargs):
        """Download created log files to the test result directory.

        :param unzip: (boolean) – Flag indicating whether collected logs should be extracted.
        :param subdirectory: (string) – Name of folder to create in addition to the normal test result structure.
        :param kwargs:
        :return:
        """
        self.wtssim.collect_edaemon_log_files(unzip, subdirectory, **kwargs)

    def collect_egate_log_files(self, unzip, subdirectory, **kwargs):
        """Download created files to the test result directory.

        :param unzip: (boolean) – Flag indicating whether collected logs should be extracted.
        :param subdirectory: (string) – Name of folder to create in addition to the normal test result structure.
        :param kwargs:
        :return:
        """
        self.set_log_flush()
        self.wtssim.collect_egate_log_files(unzip, subdirectory, **kwargs)
        if unzip:
            time.sleep(1)
            with open("{}/egate_console.log".format(subdirectory), "r") as fr:
                con = fr.readlines()
            time.sleep(1)
            with open("{}/egate_console.log".format(subdirectory), "w") as fw:
                fw.write("".join(con[2:]))

    def cleanup_egate_console_log(self, log_path):
        """Cleanup egate console log.

        :param string log_path: the egate log path
        """
        self.set_log_flush()
        time.sleep(2)
        self._remove_old_egate_cosole_log(log_path)

    def bler_testmode_nr(self, profile_id, **kwargs):
        """Config bler testmode

        :param profile_id:
        :param kwargs:
        :return:
        """
        cmd = "bler_testmode_nr profile_id={}".format(profile_id)
        for key in kwargs:
            cmd = cmd + " %s=%s" % (key.lower(), kwargs[key])
        self.execute_command(cmd)

    def pdu_session_modify(self, ue_id, pdu_id, pass_regexp, **kwargs):
        """Modify pdu session

        :param ue_id: UE id
        :param pdu_id: PDU id, default is 1
        :param pass_regexp:
        :param kwargs:
        :return:
        """
        cmd = "ue_pdu_session_modify ue={} pdu={}".format(ue_id, pdu_id)
        for key in kwargs:
            cmd = cmd + " %s=%s" % (key.lower(), kwargs[key])
        self.execute_command(cmd, pass_regexp=pass_regexp)

    def measurement_send_nr(self, id, meas_id, event, pass_regexp, **kwargs):
        """Send measurement

        :param id:
        :param meas_id:
        :param event:
        :param pass_regexp:
        :param alias: Name of execution context
        :param kwargs:
        :return:
        """
        cmd = "ue_measurement_send_nr id={} meas_id={} event={}".format(id, meas_id, event)
        for key in kwargs:
            cmd = cmd + " %s=%s" % (key.lower(), kwargs[key])
        self.execute_command(cmd, pass_regexp=pass_regexp)

    def cqi_param(self, id, on, nr_cqi_mode, scell_id, nr_ri, nr_cqi, **kwargs):
        """Config cqi param

        :param id:
        :param on:
        :param nr_cqi_mode:
        :param scell_id:
        :param nr_ri:
        :param nr_cqi:
        :param kwargs:
        :return:
        """
        cmd = "ue_cqi_param id={} on={} nr_cqi_mode={} scell={} nr_ri={} nr_cqi={} ".format(id, on, nr_cqi_mode,
                                                                                            scell_id, nr_ri, nr_cqi)
        for key in kwargs:
            cmd = cmd + " %s=%s" % (key.lower(), kwargs[key])
        self.execute_command(cmd)

    def location_change(self, id, cell_id, **kwargs):
        """Change location

        :param id:
        :param cell_id:
        :param kwargs:
        :return:
        """
        cmd = "ue_location_change id={} cell={}".format(id, cell_id)
        for key in kwargs:
            cmd = cmd + " %s=%s" % (key.lower(), kwargs[key])
        self.execute_command(cmd)

    def csi_override_testmode_nr(self, profile_id, cqi, ri, cri, li, pmi, cqi_mode, ri_mode, pmi_mode, cri_mode,
                                 li_mode, **kwargs):
        """Config csi override testmode

        :param profile_id:
        :param cqi:
        :param ri:
        :param cri:
        :param li:
        :param pmi:
        :param cqi_mode:
        :param ri_mode:
        :param pmi_mode:
        :param cri_mode:
        :param li_mode:
        :param kwargs:
        :return:
        """
        cmd = "csi_override_testmode_nr profile_id={} cqi_mode={} cqi={} ri_mode={} ri={} pmi_mode={} cri_mode={} " \
              "cri={} li_mode={} li={} pmi={}".format(profile_id, cqi_mode, cqi, ri_mode, ri, pmi_mode, cri_mode, cri,
                                                      li_mode, li, pmi)
        for key in kwargs:
            cmd = cmd + " %s=%s" % (key.lower(), kwargs[key])
        self.execute_command(cmd)

    def teardown(self):
        """Teardown"""
        # TODO: confirm whether need alias
        self.wtssim.teardown_egate(alias=self.wts_alias)
        self.wtssim.teardown_edaemon(alias=self.wts_alias)

    def _analyse_internal_traffic(self, stats_info, rate_type):
        """Get throughput by analyze info from egate command.

        :param string  stats_info: info from egate.
        :param string  rate_type: include ave, max min

        :return: according to rate_type, get throughput value, unit is kbps
        :rtype: string
        """
        rate_type = rate_type.lower()
        rate_dict = {'ave': "Average data rate",
                     'max': "Maximum data rate",
                     'min': "Minimum data rate"}

        for line in stats_info.split("\n"):
            if rate_dict[rate_type] in line:
                tput = line.split()[3]
        return tput

    def _convert_bps_to_kbps(self, tput):
        """Convert bps to kbps

        :param tput: throughput value, unit is bps
        :return: throughput value, unit is kbps
        """
        ret = float(tput) / 1000
        return float('%.2f' % ret)

    def set_log_flush(self):
        """Set log flush

        :return:
        """
        try:
            cmd = "sim_log_set flush"
            echo_info = self.execute_command(cmd)
            self._log.info(echo_info)
        except Exception as e:
            self._log.info("WTS log flush fail as {}!".format(e))

    def _remove_old_egate_cosole_log(self, log_path):
        """Remove old egate and edaemon log once the uec is activate before case start"""
        log_name = 'egate_console.log'
        self._log.info("remove log name %s" % log_name)
        os.system("cd %s;echo ''>%s" % (log_path, log_name))

    def _convert_id_from_str_to_list(self, id_str):
        """Convert id from str to list

        :param id_str: id string
        :return:
        """
        id_list = []
        for index, id_tmp in enumerate(id_str.split(",")):
            if "..." in id_tmp:
                continue_id = id_tmp.strip().split("...")
                self._log.info("continue id list %s ... %s" % (continue_id[0], continue_id[1]))
                for id_tmp in range(int(continue_id[0]), int(continue_id[1]) + 1):
                    id_list.append(int(id_tmp))
            else:
                try:
                    id_list.append(int(id_tmp))
                except Exception as e:
                    raise Exception("parameter id is invalid,should be integer, please check it!!!")
        return id_list
