# -*- coding: utf-8 -*-
"""
:created on: 15-04-2017

:copyright: Nokia
:author: Leo Wang, Lily Xu
:contact: leo.y.wang@nokia.com
:maintainer: Yonna Yao
:contact: yonna.yao@nokia-sbell.com
"""

import os
import time
import re
import pkg_resources
from lxml import etree
from itertools import groupby
from collections import Counter
import six
from ute_wtssim import ute_wtssim
from ta_kiss_core.logger import Logger
from ute_common_converter.to_number import to_int
from ta_kiss_core.sshconnection.local_sshconnection import LocalSshConnection
from ute_fsmaccess import ute_fsmaccess
from ta_kiss_core.sshconnection.sshconnection import SshConnection
from .AaShell import AaShell
from .exception import *
from .exception import KissIphySibMessageNotReceived
from .throughput import IphyThroughput

DIC_FORMAT = {0: 'DCI_FORMAT_0',
              1: 'DCI_FORMAT_1',
              2: 'DCI_FORMAT_1A',
              3: 'DCI_FORMAT_1B',
              4: 'DCI_FORMAT_1C',
              5: 'DCI_FORMAT_1D',
              6: 'DCI_FORMAT_2',
              7: 'DCI_FORMAT_2A',
              8: 'DCI_FORMAT_2B',
              9: 'DCI_FORMAT_2C',
              10: 'DCI_FORMAT_2D',
              11: 'DCI_FORMAT_3_3A',
              12: 'DCI_FORMAT_1A_RACH',
              13: 'DCI_FORMAT_1A_FDD_TDD',
              14: 'DCI_FORMAT_2_FDD_TDD',
              15: 'DCI_FORMAT_2A_FDD_TDD',
              16: 'DCI_FORMAT_4',
              17: 'DCI_NUM_FORMATS'
              }

THROUGHPUT_TYPE = {
                    ('dl', 'physical'): 'pdsch',
                    ('ul', 'physical'): 'pusch',
                    ('dl', 'mac'): 'dl_mac',
                    ('ul', 'mac'): 'ul_mac',
                    ('dl', 'harq'): 'dl_harq',
                    ('ul', 'harq'): 'ul_harq',
                    ('dl', 'rlc'): 'dl_rlc',
                    ('ul', 'rlc'): 'ul_rlc'
                    }


class Wts(object):

    def __init__(self, port, user, tool_path="/opt/iphy/latest"):
        self.port = port
        self.user = user
        self.tool_path = tool_path

    def start(self):
        """none"""
        pass

    def stop(self):
        """none"""
        pass


class Egate(Wts):

    def __init__(self, port=20000, user="ute"):
        super(Egate, self).__init__(port, user)


class Edamon(Wts):

    def __init__(self, port=10000, user="root"):
        super(Edamon, self).__init__(port, user)


class Iphy(object):

    def __init__(self, edamon_port, egate_port, lmp_ip, host_ip):
        self.wtssim = ute_wtssim()
        self._log = Logger()
        self.edamon = Edamon(edamon_port)
        self.egate = Egate(egate_port)
        self.wts_alias = None
        self.host_ip = host_ip
        self.lmp_ip = lmp_ip
        self._cpln_lua_path = "lte_cpln.lua"
        self.lua_cfg_file = ''

    def setup(self, **kwargs):
        """Setup"""
        self.wts_alias = kwargs.get('alias')
        self.wtssim.setup_egate(self.egate.port, host_ip=self.host_ip)
        self.wtssim.setup_edaemon(
            self.edamon.port,
            alias=self.wts_alias,
            host_ip=self.host_ip)
        self.wtssim.link_edaemons_to_egate(self.wts_alias)

    def execute_command(self, cmd, pass_regexp=None,
                        fail_regexp=None, timeout=10, **kwargs):
        """Iphy execute command, using egate command

        :param string  cmd: Command to execute.
        :param string  pass_regexp: Regexp indIcating that the command passed.
        :param string  fail_regexp: Regexp indicating that the command failed.
        :param integer timeout: Timeout for this operation. Default is 10 seconds.
        :return: Data received during the execution. Valid only if pass_regexp is set.
        :rtype: string
        :note: Command could be anything supported by the Telnet interface of egate.
        """
        ret = self.wtssim.execute_egate_command(
            cmd, pass_regexp, fail_regexp, timeout, **kwargs)
        return ret

    def start_wtssim_and_load_cfg_file(
            self, egate_cfg_file, timeout=120):
        """Start wtssim and load cfg files

        :param egate_cfg_file: Path to the lua file where egate configuration is stored.
                                e.g.  '/opt/iphy/latest/tddLuaScripts/lte_wraparound_cfg.lua'
        :param timeout: Timeout, default is 120 seconds
        """
        self.lua_cfg_file = egate_cfg_file
        self.wtssim.start_egate_process(egate_cfg_file, timeout=timeout)

    def start_establish_s1_link(self):
        """start establish s1 link by execute start command on egate.
        """
        self._log.info(self.execute_command('start'))

    def sib1_and_sib2_should_be_received(self, enb_id=1, cell_id=1, timeout=600, nb=False):
        """Wait unitl sib1 and sib2 received.

        :param enb_id: eNB ID, default is 1
        :param cell_id: Cell ID, default is 1
        :param timeout: Timeout, default is 600 seconds
        :param nb: Is NB cell, default is not NB cell
        """
        if nb:
            entry = "wait_until_sib1_and_sib2_received(%d,%d,%r)" % (enb_id, cell_id, nb)
        else:
            entry = "wait_until_sib1_and_sib2_received(%d,%d)" % (enb_id, cell_id)
        cmd_str = "script file=%s entry=%s" % (self._cpln_lua_path, entry)
        stime1 = time.time()
        while True:
            stime2 = time.time()
            if (stime2 - stime1) > timeout:
                raise KissIphySibMessageNotReceived("There is no sib message received.")
            else:
                if self._get_sib_status_by_lua(cmd_str):
                    return True

    def _get_sib_status_by_lua(self, command):
        """Get sib status from iphy by lua script.
        """
        ret = ""
        try:
            ret = self.execute_command(command, pass_regexp="PASSED", fail_regexp="FAILED")
        except Exception as e:
            if "Runtime error: C++ exception" in str(e):
                self._log.info("Cell id maybe incorrect.")
        finally:
            self._log.info(ret)
            if "PASSED" in ret:
                return True
            else:
                time.sleep(1)
                return False

    def sue_attach(self, ue_id, pass_regexp="UE IS ACTIVE",
                   timeout=30):
        """Attach single iphy

        :param ue_id: UE ID
        :param pass_regexp: Pass regexp, default is "UE IS ACTIVE"
        :param timeout: Timeout, default is 30 seconds
        """
        self.execute_command(
            "ue_attach id={}".format(ue_id),
            pass_regexp=pass_regexp,
            timeout=timeout)

    def mue_attach(self, ue_start, ue_end, interval=0.5, timeout=5, retry=0,
                   selected_plmn=0, emergency=0):
        """Attach multi iphys

        :param ue_start: Start UE id
        :param ue_end: End UE id
        :param interval: UE attach interval, default is 0.5 second
        :param timeout: UE attach timeout, default is 5 seconds
        :param retry: UE attach retry, default is 0
        :param selected_plmn: Selected plmn, default is 0
        :param emergency: Emergency, default is 0
        """
        entry = "mue_attach(%s,%s,%s,%s,%s,%s,%s)" % \
                (ue_start, ue_end, interval, timeout, retry, selected_plmn, emergency)
        cmd_str = "script file=%s entry=%s" % (self._cpln_lua_path, entry)
        self._log.info("Executing Egate script command '%s'" % cmd_str)
        self._log.info(
            self.execute_command(
                cmd_str,
                timeout=int(
                    str(timeout)),
                pass_regexp="Result=PASSED"))

    def mue_group_attach(self, ue_id_list, cell_index_list=1, enb_index_list=1, interval=0.5, timeout=5,
                         retry=0, selected_plmn=0, emergency=0, ue_capability=None):
        """Attach multi group iphys

        :param ue_id_list: ue_group id for example:"1,2,3, 50...100"
        :param cell_index_list: Number of comma contains on Cell_Index should be equal to contains on ue_id_list.
        default is 1
        :param enb_index_list: Number of comma contains on enb_index should be equal to contains on ue_id_list.
        default is 1
        :param interval: UE attach interval, default is 0.5 second
        :param timeout: UE attach timeout, default is 5 seconds
        :param retry: UE attach retry, default is 0
        :param selected_plmn: Selected plmn, default is 0
        :param emergency: Emergency, default is 0
        :param String ue_capability: UE capability. The default value is none, common attach can use this value.
        For example: ue_id_list=1,3...5,7,9...11  cell_index=1,2,1,3 The meaning of parameter is that ue id 1,7 attach
        to cell id 1,
        ue id 3,4,5 attach to cell id 2 and ue id 9,10,11 attach to cell id 3.
        """
        ue_index_list, cell_index_list = self.convert_ue_id_from_str_to_list(ue_id_list, cell_index_list)
        ue_id_listtemp, enb_index_list = self.convert_ue_id_from_str_to_list(ue_id_list, enb_index_list)
        self._log.info("ue index: %s" % ue_index_list)
        ue_number = len(ue_index_list)
        # cell_index_list = self.get_attach_parameter_list(cell_index_list, ue_number)
        self._log.info("cell index: %s" % cell_index_list)
        self._log.info("enb index: %s" % enb_index_list)
        if len(cell_index_list) != ue_number:
            raise Exception("ue index dismatch with cell id")
        flag_index = 0
        for idList in self.get_range_ue_id_list(ue_index_list):
            interval = str(interval)
            ue_start = idList[0]
            ue_end = idList[1]
            for id_list in range(ue_start, ue_end + 1):
                change_ue_location = "change_location_ue id=%s cell=%s enb=%s" % \
                                     (id_list, cell_index_list[flag_index], enb_index_list[flag_index])
                flag_index = flag_index + 1
                self._log.info(self.execute_command(cmd=change_ue_location, timeout=2, pass_regexp="location",
                                                    fail_regexp="is neither IDLE nor OFF"))
                self.execute_command("ue_param id=%s reset" % (id_list))
                if ue_capability is not None:
                    self.execute_command("ue_param id=%s ue_eutra_capabilities=%s" % (id_list, ue_capability))
            timeoutLua = float(float(str(timeout)) / len(ue_index_list))

            entry = "mue_attach(%s,%s,%s,%s,%s,%s,%s)" % \
                    (ue_start, ue_end, interval, timeoutLua, retry, selected_plmn, emergency)
            cmdStr = "script file=%s entry=%s" % (self._cpln_lua_path, entry)
            self._log.info("Executing Egate script command '%s'" % cmdStr)
            self._log.info(
                self.execute_command(
                    cmdStr,
                    timeout=int(
                        str(timeout)),
                    pass_regexp="Result=PASSED"))

    def get_range_ue_id_list(self, ue_id_sub_list=None):
        """ Converting a ueIdList of integers into python ranges.

            :param list ue_id_sub_list: list to be converted
        """
        ueIdList = ue_id_sub_list
        return [[t[0][1], t[-1][1]] for t in (tuple(g[1])
                                              for g in groupby(enumerate(ueIdList), lambda i_x: i_x[0] - i_x[1]))]

    def sue_detach(self, ue_id, timeout=15):
        """Detach single iphy which state is ue.ON or ue.IDLE

        :param ue_id: UE ID
        :param timeout: Timeout, default is 15 seconds
        """
        cmd_str = "ue_detach id={}".format(ue_id)
        self._log.info(self.execute_command(cmd_str, timeout=timeout))

    def mue_detach(self, ue_start, ue_end, interval=0.5,
                   timeout=5):
        """Detach multi iphys which state is ue.ON or ue.IDLE

        :param ue_start: Start UE id
        :param ue_end: End UE id
        :param interval: UE detach interval, default is 0.5 second
        :param timeout: UE detach timeout, default is 5 seconds
        """
        entry = "mue_detach(%s,%s,%s,%s,1)" % (
            ue_start, ue_end, interval, timeout)
        cmd_str = "script file=%s entry=%s" % (self._cpln_lua_path, entry)
        self._log.info("Executing Egate script command '%s'" % cmd_str)
        self._log.info(self.execute_command(cmd_str,
                                            timeout=timeout, pass_regexp="PASSED"))

    def mue_group_detach(self, ue_id_list, interval=0.5,
                         timeout=5):
        """Detach multi group iphys which state is ue.ON or ue.IDLE

        :param ue_id_list: ue_group id for example:"1,2,3, 50...100"
        :param interval: UE detach interval, default is 0.5 second
        :param timeout: UE detach timeout, default is 5 seconds
        """
        ue_id_list = self.convert_ue_id_from_str_to_list_group(ue_id_list)
        entry = "mue_group_detach(%s,%s,%s,1)" % (
            ue_id_list, interval, timeout)
        cmd_str = "script file=%s entry=%s" % (self._cpln_lua_path, entry)
        self._log.info("Executing Egate script command '%s'" % cmd_str)
        self._log.info(self.execute_command(cmd_str,
                                            timeout=timeout, pass_regexp="PASSED"))

    def detach_all(self, interval=0.5, timeout=15):
        """Detach all UEs which state is ue.ON or ue.IDLE.

        :param timeout: detach all UE timeout, default is 15 seconds.
        """
        entry = "detach_all_ue(%s,%s)" % (interval, timeout)
        cmd_str = "script file=%s entry=%s" % (self._cpln_lua_path, entry)
        self._log.info(self.execute_command(cmd_str, timeout=timeout, pass_regexp="PASSED"))

    def start_ul_udp_data(self, ue_id, duration, bearer_id=1, **kwargs):
        """start udp data traffic by egate command. data traffice type is UL.

        :param String ue_id: UE ID
        :param Integer duration: duration time
        :param Integer bearer_id: bearer id value, default value is 1

        |

        :Supported through_put parameter is available via kwargs:
            through_put value.  e.g.  '10 Mbits/sec' or '500Bytes/sec'
            :units:
            - 'bits/sec'        range:56-175000000
            - 'Kbits/sec'       range:1-175000
            - 'Mbits/sec'       range:1-175
            - 'Bytes/sec'
            - 'KBytes/sec'
            - 'MBytes/sec'

            Note: conversion rate is equal to 1000.
        """
        self.start_data_traffic(
            ue_id,
            direction="ul",
            protocol="udp",
            duration=duration,
            bearer_id=bearer_id,
            **kwargs)

    def start_dl_udp_data(self, ue_id, duration, bearer_id=1, **kwargs):
        """start udp data traffic by egate command. data traffice type is DL.

        :param String ue_id: UE ID
        :param Integer duration: duration time
        :param Integer bearer_id: bearer id value, default value is 1

        |

        :Supported through_put parameter is available via kwargs:
            through_put value.  e.g.  '10 Mbits/sec' or '500Bytes/sec'
            :units:
            - 'bits/sec'        range:56-175000000
            - 'Kbits/sec'       range:1-175000
            - 'Mbits/sec'       range:1-175
            - 'Bytes/sec'
            - 'KBytes/sec'
            - 'MBytes/sec'

            Note: conversion rate is equal to 1000.
        """
        self.start_data_traffic(
            ue_id,
            direction="dl",
            protocol="udp",
            duration=duration,
            bearer_id=bearer_id,
            **kwargs)

    def start_ul_tcp_data(self, ue_id, duration, bearer_id=1, **kwargs):
        """start tcp data traffic by egate command. data traffice type is UL.

        :param String ue_id: UE ID
        :param Integer duration: duration time
        :param Integer bearer_id: bearer id value, default value is 1.

        |

        :Supported through_put parameter is available via kwargs:
            through_put value.  e.g.  '10 Mbits/sec' or '500Bytes/sec'
            :units:
            - 'bits/sec'        range:56-175000000
            - 'Kbits/sec'       range:1-175000
            - 'Mbits/sec'       range:1-175
            - 'Bytes/sec'
            - 'KBytes/sec'
            - 'MBytes/sec'

            Note: conversion rate is equal to 1000.
        """
        self.start_data_traffic(
            ue_id,
            direction="ul",
            protocol="tcp",
            duration=duration,
            bearer_id=bearer_id,
            **kwargs)

    def start_dl_tcp_data(self, ue_id, duration, bearer_id=1, **kwargs):
        """start tcp data traffic by egate command. data traffice type is DL.

        :param String ue_id: UE ID
        :param Integer duration: duration time
        :param Integer bearer_id: bearer id value, default value is 1.

        |

        :Supported through_put parameter is available via kwargs:
            through_put value.  e.g.  '10 Mbits/sec' or '500Bytes/sec'
            :units:
            - 'bits/sec'        range:56-175000000
            - 'Kbits/sec'       range:1-175000
            - 'Mbits/sec'       range:1-175
            - 'Bytes/sec'
            - 'KBytes/sec'
            - 'MBytes/sec'

            Note: conversion rate is equal to 1000.
        """
        self.start_data_traffic(
            ue_id,
            direction="dl",
            protocol="tcp",
            duration=duration,
            bearer_id=bearer_id,
            **kwargs)

    def get_eicic_ul_throughput(self, direct, rate_type, ue_id, bearer_id):
        """get EICIC ul throughput average from egate log.

        :param String direct: direction, such as 'dl' or 'ul'.
        :param String rate_type: rate type, such as 'ave' or 'max' or 'min'
        :param Integer ue_id: UE ID
        :param Integer bearer_id: bearer id value, default value is 1
        """
        cmd = "bearer_stats ue=%s id=%s dir=%s" % (ue_id, bearer_id, direct)
        self._log.info("egate cmd=%s" % cmd)
        echo_info = self.execute_command(
            cmd, pass_regexp="Total packets dropped")
        self._log.info(echo_info)
        return self._convert_bps_str_to_kbps(self._analyse_throughput_echo(echo_info, rate_type))

    def get_ul_throughput_ave(self, ue_id, bearer_id=1, **kwargs):
        """get ul throughput average from egate log.

        :param Integer ue_id: UE ID
        :param Integer bearer_id: bearer id value, default value is 1
        """
        alias = kwargs.get('alias')
        if "EICIC_UEC" == alias:
            return self.get_eicic_ul_throughput(
                "ul", "eicic_ul_ave", ue_id, bearer_id)
        else:
            return self.get_throughput("ul", "ave", ue_id, bearer_id)

    def get_dl_throughput_ave(self, ue_id, bearer_id=1):
        """get dl throughput average from egate log.

        :param Integer ue_id: UE ID
        :param Integer bearer_id: bearer id value, default value is 1
        """
        return self.get_throughput("dl", "ave", ue_id, bearer_id)

    def get_ul_throughput_max(self, ue_id, bearer_id=1):
        """get ul throughput max from egate log.

        :param Integer ue_id: UE ID
        :param Integer bearer_id: bearer id value, default value is 1
        """
        return self.get_throughput("ul", "max", ue_id, bearer_id)

    def get_dl_throughput_max(self, ue_id, bearer_id=1):
        """get dl throughput max from egate log.

        :param Integer ue_id: UE ID
        :param Integer bearer_id: bearer id value, default value is 1
        """
        return self.get_throughput("dl", "max", ue_id, bearer_id)

    def stop_dl_udp_data(self, ue_id, bearer_id, **kwargs):
        """stop udp data traffic by egate command. data traffice type is DL.

        :param String ue_id: UE ID
        :param Integer bearer_id: bearer id value, default value is 1
        """
        execute_cmd = "trf_data_stop dir=dl id=%s ue=%s" % (bearer_id, ue_id)
        for key in kwargs:
            execute_cmd = execute_cmd + " %s=%s" % (key, kwargs[key])
        self._log.info("execute_cmd = %s" % execute_cmd)
        self._log.info(
            self.execute_command(
                execute_cmd,
                pass_regexp="stopped"))

    def stop_ul_udp_data(self, ue_id, bearer_id, **kwargs):
        """stop udp data traffic by egate command. data traffice type is UL.

        :param String ue_id: UE ID
        :param Integer bearer_id: bearer id value, default value is 1
        """
        execute_cmd = "trf_data_stop dir=ul id=%s ue=%s" % (bearer_id, ue_id)
        for key in kwargs:
            execute_cmd = execute_cmd + " %s=%s" % (key, kwargs[key])
        self._log.info("execute_cmd = %s" % execute_cmd)
        self._log.info(
            self.execute_command(
                execute_cmd,
                pass_regexp="stopped"))

    def stop_dl_tcp_data(self, ue_id, bearer_id, **kwargs):
        """stop tcp data traffic by egate command. data traffice type is DL.

        :param String ue_id: UE ID
        :param Integer bearer_id: bearer id value, default value is 1
        """
        execute_cmd = "trf_data_stop dir=dl id=%s ue=%s" % (bearer_id, ue_id)
        for key in kwargs:
            execute_cmd = execute_cmd + " %s=%s" % (key, kwargs[key])
        self._log.info("execute_cmd = %s" % execute_cmd)
        self._log.info(
            self.execute_command(
                execute_cmd,
                pass_regexp="stopped"))

    def stop_ul_tcp_data(self, ue_id, bearer_id, **kwargs):
        """stop tcp data traffic by egate command. data traffice type is UL.

        :param String ue_id: UE ID
        :param Integer bearer_id: bearer id value, default value is 1
        """
        execute_cmd = "trf_data_stop dir=ul id=%s ue=%s" % (bearer_id, ue_id)
        for key in kwargs:
            execute_cmd = execute_cmd + " %s=%s" % (key, kwargs[key])
        self._log.info("execute_cmd = %s" % execute_cmd)
        self._log.info(
            self.execute_command(
                execute_cmd,
                pass_regexp="stopped"))

    def set_sim_state(self, state):
        """Set sim state base on the parameter of state. only support below status:INIT, CONFIGURED, ACTIVE.

        :param String state: Satus, such as: INIT, CONFIGURED, ACTIVE
        """
        self._check_params_for_set_sim_state(state)

        current_state = self.get_sim_state()
        if state.upper() == current_state:
            self._log.info(
                'current_state: {}, not need change.'.format(current_state))
            return

        if 'INIT' == state.upper():
            self.execute_command(cmd='reset', pass_regexp='EGATE>')
        elif 'CONFIGURED' == state.upper():
            self._set_sim_state_to_configured(current_state, self.lua_cfg_file)
        elif 'ACTIVE' == state.upper():
            self._set_sim_state_to_active(current_state, self.lua_cfg_file)

        self._check_if_sim_state_is_set(state)
        self._log.info('change the state of simulator successfully')

    def get_sim_state(self):
        """Retrun the state of sim, include INIT, CONFIGURING, CONFIGURED, ACTIVATING, ACTIVE
        """
        sim_state_cmd = 'sim_state_disp'
        self._log.info(
            'command of get simulator state: {}'.format(sim_state_cmd))
        ret = self.execute_command(
            cmd=sim_state_cmd,
            pass_regexp="The state is")
        self._log.info('execute command result: {}'.format(ret))
        for line in ret.split('\n'):
            if 'The state is' in line:
                self._log.info('line: {}'.format(line))
                state = line.strip().split(' ')[-1]
                return state
            else:
                continue
        raise Exception("can't get simulator state!!!")

    def get_active_bearer_qci(self, ue_id):
        """Get active bearer qci value
        :param Integer ue_id: ue id
        """
        qci = {}
        entry = "get_bearer_info(%s)" % (int(str(ue_id)))
        cmdStr = "script file=%s entry=%s" % (self._cpln_lua_path, entry)
        states_value = self.execute_command(
            cmd=cmdStr,
            timeout=10,
            pass_regexp="PASSED",
            fail_regexp="FAILED")
        return self._get_qci_dic(states_value)

    def modify_pathloss(self, ue_id, pathloss):
        """Modify path loss

        :param String  ue_id: the identification of ue
        :param String  pathloss: pathloss value
        """
        entry = "modify_pathloss(%s,%s)" % (ue_id, int(pathloss))
        cmdStr = "script file=%s entry=%s" % (self._cpln_lua_path, entry)
        self._log.info(
            self.execute_command(
                cmd=cmdStr,
                timeout=10,
                pass_regexp="PASSED",
                fail_regexp="FAILED"))

    def validate_uec_is_active(self):
        """Try to check iphy uec status"""
        uec_is_active = False
        try:
            data = self.wtssim.execute_egate_command_and_wait_for_data(
                "uec_disp id=1", timeout=5)
            if "ACTIVE" not in data:
                uec_is_active = False
                self._log.debug(
                    "UEC is not active, now restart all egate services.")
            else:
                uec_is_active = True
                self._log.debug("UEC is active, now reuse the egate services.")
        except Exception:
            uec_is_active = False
            self._log.debug(
                "Can not telnet to wtssim, now restart all egate services.")
        finally:
            return uec_is_active

    def modify_bearer(self, ue_id, bearer_id, **kwargs):
        """Modifies UE bearers by Egate command.

        :param integer ue_id: local identifier of UE, start from 1.
        :param integer bearer_id: local identifier of bearer, range in (1..16)

        |

        :Supported GBR , MBR and filter precedence parameters are available via kwargs:
            * **mbr_ul**      (integer)  -  Maximal Bit Rate of UL, kbps(only for GBR bearers), range in (1..25600)
            * **gbr_ul**      (integer)  -  Guaranteed Bit Rate of UL, kbps(only for GBR bearers, it should be the same
            as MBR), range in (1..25600)
            * **mbr_dl**      (integer)  -  Maximal Bit Rate of DL, kbps(only for GBR bearers), range in (1..25600)
            * **gbr_dl**      (integer)  -  Guaranteed Bit Rate of DL, kbps(only for GBR bearers, it should be the same
            as MBR), range in (1..25600)
            * **precedence**  (integer)  -  filter precedence (unique among all filters of all UE's bearers in the PDN)
        :Note : You just can modify these parameters for GBR bearers, their UE bearer id is in (2, 3, 4, 5) by default
        setting.
        """
        execute_cmd = "bearer_mod ue=%d id=%d" % (ue_id, bearer_id)
        for key in kwargs:
            execute_cmd = execute_cmd + " %s=%s" % (key, kwargs[key])
        self._log.info("Executing Egate command = %s" % execute_cmd)
        self._log.info(
            self.execute_command(
                execute_cmd,
                pass_regexp="has been modified",
                fail_regexp="Error:"))

    def get_dl_bler_ave(self, ue_id, **kwargs):
        """get dl bler from egate log.

        :param Integer ue_id: UE ID
        """
        bearer_id = kwargs.get("bearer_id") if kwargs.get("bearer_id") else 1
        return self.get_bler("dl", ue_id, bearer_id)

    def get_ul_bler_ave(self, ue_id, **kwargs):
        """get ul bler from egate log.
        """
        bearer_id = kwargs.get("bearer_id") if kwargs.get("bearer_id") else 1
        return self.get_bler("ul", ue_id, bearer_id)

    def set_rrc_log(self, switch='on', uec_index=1):
        """Set RRC log switch
        """
        switch = switch.lower()
        rrc_log_cmd = 'trace uec=%d protocol=rrc %s' % (uec_index, switch)
        rrc_log_ret_cmd = 'trace'
        ret_state = None
        self.execute_command(rrc_log_cmd)
        pass_regular_expression = r'UEC-%d\s+\|' % (uec_index)
        ret = self.execute_command(
            rrc_log_ret_cmd, pass_regexp=pass_regular_expression)
        ret_state = self._extract_rrc_log_status(
            ret, pass_regular_expression)
        if ret_state == switch:
            self._log.info('RRC log switch %s Success' % (switch))
        else:
            error_message = 'RRC log switch %s Failed' % (switch)
            raise Exception(error_message)

    def cleanup_egate_log(self, log_path):
        """
        cleanup egate log.

        :param string  log_save_path: the egate log path
        """
        self.execute_command("set_log flush")
        time.sleep(2)
        self._remove_old_egate_cosole_log(log_path)

    def get_iphy_log(self, log_save_path, tag):
        """
        Copy egate console log to specific path.

        :param string  log_save_path: the ue log save path
        :param string  tag: Indicate the UE log name
        """
        self.execute_command("set_log flush")
        time.sleep(2)
        self._capture_all_logfile(log_save_path, tag)
        return True

    def get_iphy_last_allocation_info(self, ue_id, direction):
        """get ue last allocation info
        """
        info_dic = {}
        ret = self.get_ue_stats(ue_id, direction, 'LAST_ALLOC')
        stats_info = ret.split('ue_stats is:')[-1]
        for line in stats_info.split("\n"):
            key = re.findall(r"(\w+)=(\w+)", line, re.M)
            if key != []:
                info_dic.setdefault(str(key[0][0]), str(key[0][1]))
        for key in list(info_dic.keys()):
            if key == 'dci_format':
                info_dic[key] = DIC_FORMAT[int(info_dic[key])]
        self._log.info("stats info:\n%s" % info_dic)
        return info_dic

    def get_ue_status(self, ue_id):
        """Iphy get ue state command
        return: string ue state such as off,active,idle
        """
        ue_id = int(str(ue_id))
        entry = "get_ue_states(%d)" % (ue_id)
        cmd_str = "script file=%s entry=%s" % (self._cpln_lua_path, entry)
        ret, status = "", ""
        try:
            ret = self.execute_command(cmd=cmd_str,
                                       pass_regexp="GET_PASSED",
                                       timeout=1)
        finally:
            buf = six.StringIO(ret)
            for line in buf.readlines():
                if " Ue_" in line:
                    self._log.info(line)
                    status = line.split("is ")[-1].strip()
                    break
            return status if ("GET_PASSED" in ret) else "NULL"

    def get_iphy_throughput_on_specific_scell(
            self, ue_id, direction, scell_id=0, tput_type='ave'):
        """get iphy throughput on specific scell.

        :param String  ue_id: the identification of ue
        :param String  direction: the direction , dl or ul
        :param Integer  scell_id:  the identification of cell. Default is 0. 0:PCell 1:Scell-1 2:Scell-2
        :param String  tput_type: the type of throughput. Default is 'ave'. Support below string: ave, max, min,
        current.
        :param alias: Name of execution context

        :return: the value of throughput, unit is Kbps.
        :rtype: float
        """
        pass_regexp = self._check_params_for_get_iphy_throughput_on_specific_scell(
            ue_id, direction, scell_id, tput_type)

        ue_stats_type = {'UL': 'pusch', 'DL': 'pdsch'}
        execute_ue_stats_command = "ue_stats id=%s type=%s scell=%s" % \
                                   (ue_id, ue_stats_type[
                                    str(direction).upper()], scell_id)
        self._log.info(
            'execute_ue_stats_command %s' %
            execute_ue_stats_command)
        ret = self.execute_command(
            execute_ue_stats_command,
            pass_regexp=pass_regexp)
        self._log.info('execute_ue_stats_command result %s' % ret)
        dict_ret = ret.split('\n')
        if len(dict_ret) < 5:
            raise Exception(
                "return vlaue is incorrect, maybe ue is not active. please check it!!!")
        output_line = ''
        for output in dict_ret:
            if pass_regexp in output:
                output_line = output
                self._log.info('redefine dict_ret %s' % output_line)
                break

        self._log.info('dict_ret %s' % output_line)
        if 'PCell' not in output_line and 'SCell' not in output_line:
            raise Exception(
                "return vlaue is incorrect, maybe scell is not configured. please check it!!!")

        throughput = float(self._analyse_throughput_value_on_specific_scell(
            output_line, tput_type))
        return throughput

    def get_iphy_ue_throughput(self, ue_id, direction, tput_type, layer, scell):
        """
         sum the throughput for scell, the egate command is ue_stats.
        :param ue_id: ue id
        :param direction: dl or ul
        :param tput_type: 'current', 'minimum', 'maximum', 'average'
        :param layer: 'mac', 'physical', 'harq', 'rlc'
        :param scell: 0,1,2,3,4,5,6 or pcell , scell, all.
        :return: throughput value
        """
        self._check_parameter_error(direction, layer, tput_type)
        cmd = "ue_stats id={} type={} scell=primary,secondary".format(ue_id, THROUGHPUT_TYPE[direction, layer])
        egate_info = self.execute_command(cmd, pass_regexp='PCell')
        return IphyThroughput().sum_l2_cell_throughput(egate_info, tput_type, scell)

    def _check_parameter_error(self, direction, layer, tput_type):
        """

        :param direction:
        :param layer:
        :param tput_type:
        :return:
        """
        if direction not in ['dl', 'ul']:
            raise Exception("'direction' should be 'dl' or 'ul'")
        if layer not in ['mac', 'physical', 'harq', 'rlc']:
            raise Exception("'layer' should be 'mac', 'physical', 'harq' or 'rlc'")
        if tput_type not in ['current', 'minimum', 'maximum', 'average']:
            raise Exception("'tput_type' should be 'current', 'minimum', 'maximum' or 'average'")

    def create_bearer(self, ue_id_list, bearer_id_list, precedence_list=[
                      0, 1, 2, 3, 4, 5, 6], filter_id=None, interval=0.5, timeout=30):
        """"Create bearers from a list of Bearer IDs
        :QCI mapping: bearer id=1 qci=8
        :QCI mapping: bearer id=2 qci=1 gbr_ul=31   gbr_dl=31   mbr_ul=31   mbr_dl=31
        :QCI mapping: bearer id=3 qci=2 gbr_ul=144  gbr_dl=144  mbr_ul=144  mbr_dl=144
        :QCI mapping: bearer id=4 qci=3 gbr_ul=64   gbr_dl=128  mbr_ul=64   mbr_dl=128
        :QCI mapping: bearer id=5 qci=4 gbr_ul=32   gbr_dl=320  mbr_ul=32   mbr_dl=320
        :QCI mapping: bearer id=6 qci=5
        :QCI mapping: bearer id=7 qci=6
        :QCI mapping: bearer id=8 qci=7
        :QCI mapping: bearer id=9 qci=9

        |
        :param List ue_id_list: UE IDs list
        :param List bearer_id_list: Bearer IDs list
        :param List precedence_list: bearer filter precedence_list. Size must be equal or greater than bearer_id_list
                                     and each entry must be unique (default: [0,1,2,3,4,5,6])
        :param Integer filter_id: bearer filter ID. The default is bear_id.
        :param Integer interval: create bearer interval. The default value is 0.5 seconds.
        :param Integer timeout: create bearer timeout. The default value is 30 seconds.
        """
        lua_filter_id = filter_id
        ue_id_list, bearer_id_list, precedence_list = self._process_parameter_for_create_bearer(
            ue_id_list, bearer_id_list, precedence_list)

        for id_list in self.get_range_ue_id_list(ue_id_list):
            interval = str(interval)
            ue_start = id_list[0]
            ue_end = id_list[1]
            for bearer_index, bearer_id in enumerate(bearer_id_list):
                lua_precedence = precedence_list[bearer_index]
                if filter_id is None:
                    lua_filter_id = bearer_id
                entry = "mue_bearer_add(%s,%s,%s,%s,%s)" % (ue_start, ue_end, bearer_id, lua_filter_id, lua_precedence)
                cmd_str = "script file=%s entry=%s" % (self._cpln_lua_path, entry)
                self._log.info("Executing Egate script command '%s'" % cmd_str)
                self._log.info(self.execute_command(cmd=cmd_str, timeout=timeout, pass_regexp="Result=PASSED",
                                                    fail_regexp="FAILED:"))

    def delete_bearer(self, ue_id_list, bearer_id_list, interval=0.5, timeout=30):
        """Delete bearer

        :param List ue_id_list: UE IDs list
        :param List bearer_id_list: Bearer IDs list
        :param Integer interval: delete bearer interval. The default value is 0.5 seconds.
        :param Integer timeout: delete bearer timeout. The default value is 30 seconds.
        :param Integer timeout: delete bearer timeout. The default value is 30 seconds.
        """
        ue_id_list = self._convert_unicode(ue_id_list)
        bearer_id_list = self._convert_unicode(bearer_id_list)

        for id_list in self.get_range_ue_id_list(ue_id_list):
            interval = str(interval)
            ue_start = id_list[0]
            ue_end = id_list[1]
            for bearer_id in bearer_id_list:
                entry = "mue_bearer_del(%s,%s,%s,%s)" % (ue_start, ue_end, bearer_id, interval)
                cmd_str = "script file=%s entry=%s" % (self._cpln_lua_path, entry)
                self._log.info("Executing Egate script command '%s'" % cmd_str)
                self._log.info(self.execute_command(cmd=cmd_str, timeout=timeout, pass_regexp="Result=PASSED",
                                                    fail_regexp="FAILED:"))

    def get_cell_throughput_ave(self, cell_id, direction):
        """get cell average throughput

        :param Integer cell_id: cell id
        :param String  direction: ul or dl
        """
        cell_status = self.get_cell_states(cell_id, direction)
        cell_status_list = cell_status.split()
        for each_value in cell_status_list:
            if str(direction).lower() == "dl" and "int_avg_rate=" in each_value:
                avg_rate = float(str(each_value.split("=")[1]))
                return avg_rate
            elif str(direction).lower() == "ul" and "average=" in each_value:
                avg_rate = float(each_value.split()
                                 [-1].split("=")[-1].rstrip("}"))
                return avg_rate

    def get_transmission_mode(self, ue_id):
        """get transmission mode
        """
        tm_dict = {}
        execute_cmd = "ue_disp at=ue id=%s" % ue_id
        self._log.info("execute_cmd = %s" % execute_cmd)
        ret = self.execute_command(
            execute_cmd, pass_regexp="Transmission Mode")
        self._log.debug(ret)
        for line in str(ret).split('\n'):
            if 'Transmission Mode' in line:
                tm_dict.setdefault(str(ue_id), line.split()[-1])
                self._log.info(tm_dict)
                return tm_dict

        tm_dict.setdefault(ue_id, '')
        self._log.info(tm_dict)
        return tm_dict

    def rrc_reestablish(self, ue_id, cell_id=None, enb_id=None):
        """reestablish ue rrc connection"""

        if cell_id is None or enb_id is None:
            entry = "ue_rrc_reestablish(%s)" % (ue_id)
        else:
            entry = "ue_rrc_reestablish(%s,%s,%s)" % (ue_id, cell_id, enb_id)
        cmd_str = "script file=%s entry=%s" % (self._cpln_lua_path, entry)
        pass_exp = "RRC Reestablishment sucessfully completed"
        ret = ""
        try:
            ret = self.execute_command(cmd=cmd_str,
                                       pass_regexp=pass_exp,
                                       fail_regexp=None,
                                       timeout=5)
        finally:
            self._log.info(ret)
        return ret

    def iphy_handover(self, ue_id, enb_id, cell_id, timeout):
        """iphy handover
        """
        entry = "ue_handover(%s,%s,%s,%s)" % (ue_id, enb_id, cell_id, timeout)
        cmdStr = "script file=%s entry=%s" % (self._cpln_lua_path, entry)
        self._log.info(
            self.execute_command(
                cmd=cmdStr,
                timeout=10,
                pass_regexp="PASSED",
                fail_regexp="FAILED"))

    def teardown(self):
        """Teardown"""
        # TODO: confirm whether need alias
        self.wtssim.collect_egate_log_files()
        self.wtssim.collect_edaemon_log_files(alias=self.wts_alias)
        # TODO: confirm whether need alias
        self.wtssim.teardown_egate()
        self.wtssim.teardown_edaemon(alias=self.wts_alias)

    def start_data_traffic(self, ue_id, direction, protocol,
                           duration, bearer_id=1, **kwargs):
        """start data traffic by egate command.

        :param String ue_id: UE ID
        :param Integer duration: duration time
        :param String direction: direction, dl or ul
        :param String protocol: protocol, udp or tcp
        :param Integer bearer_id: bearer id value, default value is 1

        /

        :Supported through_put parameter is available via kwargs:
            through_put value.  e.g.  '10 Mbits/sec' or '500Bytes/sec'
            :units:
            - 'bits/sec'        range:56-175000000
            - 'Kbits/sec'       range:1-175000
            - 'Mbits/sec'       range:1-175
            - 'Bytes/sec'
            - 'KBytes/sec'
            - 'MBytes/sec'

            Note: conversion rate is equal to 1000.
        """
        throughput = kwargs.get('through_put', None)
        if throughput is not None:
            unit, throughput = self._validate_and_return_throughput(throughput)
            execute_cmd = "trf_data_start ue=%s dir=%s protocol=%s id=%s %s=%s seconds=%s" % \
                (ue_id, direction, protocol, bearer_id, unit, throughput, duration)
        else:
            execute_cmd = "trf_data_start ue=%s dir=%s protocol=%s id=%s seconds=%s" % \
                          (ue_id, direction, protocol, bearer_id, duration)
        for key in kwargs:
            if key != "through_put":
                execute_cmd = execute_cmd + " %s=%s" % (key, kwargs[key])
        self._log.info("execute_cmd = %s" % execute_cmd)
        self._log.info(
            self.execute_command(
                execute_cmd,
                pass_regexp="TRF",
                fail_regexp="Can't start traffic"))

    def get_throughput(self, direct, rate_type, ue_id, bearer_id):
        """according to rate_type, get throughput value.

        :param String direct: direction, such as 'dl' or 'ul'.
        :param String rate_type: rate type, such as 'ave' or 'max' or 'min'
        :param Integer ue_id: UE ID
        :param Integer bearer_id: bearer id value
        """
        cmd = "bearer_stats ue=%s id=%s dir=%s" % (ue_id, bearer_id, direct)
        self._log.info("egate cmd=%s" % cmd)
        echo_info = self.execute_command(
            cmd, pass_regexp="Average packet interval")
        self._log.info(echo_info)
        ret_tput = self._convert_bps_str_to_kbps(self._analyse_throughput_echo(echo_info, rate_type))
        try:
            cmd1 = "ue_stats id=%s scell=primary,secondary type=pdsch,pusch,dl_harq,ul_harq" % ue_id
            echo_info1 = self.execute_command(
                cmd1, pass_regexp="PUSCH Throughput")
            self._log.info(echo_info1)
        except Exception as e:
            self._log.warn("execute ue_stats id=%s type=pdsch,pusch,dl_harq,ul_harq failed because %s" %
                           (ue_id, str(e)))
        self._get_throughput_set_log_flush()
        return ret_tput

    def _get_throughput_set_log_flush(self):
        try:
            cmd = "set_log flush"
            echo_info = self.execute_command(cmd)
            self._log.info(echo_info)
        except Exception:
            self._log.info("WTS log flush fail!")

    def get_bler(self, direction, ue_id, bearer_id):
        """get bler via harq info
        """
        cmd = "ue_stats id={} type={}_harq".format(
            ue_id, str(direction).lower())
        self._log.info("egate cmd=%s" % cmd)
        echo_info = self.execute_command(cmd, pass_regexp="Total")
        self._log.debug(echo_info)
        key_msg_dl = "Number of DCIs"
        key_msg_ul = "Number of UL grants for new data"
        key_msg = key_msg_dl if str(direction).lower() == "dl" else key_msg_ul
        total = self._get_harq_value_from_echo_info(key_msg, echo_info)
        key_msg_dl = "Number of CRC errors (NACKs for real CRC errors), not due to high code rate"
        key_msg_ul = "Number of dropped UL Grants"
        key_msg = key_msg_dl if str(direction).lower() == "dl" else key_msg_ul
        not_due_to_high_code = self._get_harq_value_from_echo_info(
            key_msg, echo_info)
        key_msg_dl = "Number of CRC errors (NACKs for real CRC errors), due to high code rate"
        key_msg_ul = "Number of non-adaptive Re-TXs"
        key_msg = key_msg_dl if str(direction).lower() == "dl" else key_msg_ul
        due_to_high_code = self._get_harq_value_from_echo_info(
            key_msg, echo_info)
        self._log.info(
            "total:{} not due to high code{}, due to high code {}".format(total, not_due_to_high_code,
                                                                          due_to_high_code))
        ret = 0 if float(total) == 0.0 else (float(not_due_to_high_code) + float(due_to_high_code)) / float(total)
        return ret

    def get_ue_stats(self, ue_id, direction, stats):
        """get statistics data for ue
        """
        entry = "get_ue_stats(%s,%s,%s)" % (
            int(str(ue_id)), str(direction).lower(), stats)
        cmd_str = "script file=%s entry=%s" % (self._cpln_lua_path, entry)
        stats_value = self.execute_command(
            cmd=cmd_str,
            timeout=10,
            pass_regexp="PASSED",
            fail_regexp="FAILED")
        return stats_value

    def get_cell_states(self, cell_id, direction):
        """get statistics data for cell
        """
        entry = "get_cell_states(%s,%s)" % (
            int(str(cell_id)), str(direction).lower())
        cmd_str = "script file=%s entry=%s" % (self._cpln_lua_path, entry)
        states_value = self.execute_command(
            cmd=cmd_str,
            timeout=10,
            pass_regexp="PASSED",
            fail_regexp="FAILED")
        self._log.info(states_value)
        return states_value

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

    def _analyse_throughput_echo(self, echo_info, rate_type, direct=None):
        """get throughput by analyze info from egate command.

        :param string  echo_info: info from egate.
        :param string  rate_type: include ave, max min

        :return: according to rate_type, get throughput value.
        :rtype: string
        """
        rate_type = rate_type.lower()
        rate_dict = {'ave': "Average data rate",
                     'max': "Maximum data rate",
                     'min': "Minimum data rate",
                     'eicic_ul_ave': "Total packets sent"}

        if direct:
            rate_type = "PCell"
        else:
            rate_type = rate_dict[rate_type]

        return self._get_value_on_name_from_echo_info(
            rate_type, echo_info, direct)

    def _get_value_on_name_from_echo_info(self, name, echo_info, direct=None):
        """get the value base on the name from the echo info.
        """
        value = -1
        rate_dict_found = False
        rate_dict = {"dl": "PDSCH Throughput", "ul": "PUSCH Throughput"}
        segment_digit = {None: 3, "ul": -1, 'dl': -1}
        for line in echo_info.split("\n"):
            self._log.debug("name %s, line %s" % (name, line))
            if direct and not rate_dict_found:
                if rate_dict[direct] in line:
                    rate_dict_found = True
                continue
            if name in line or (direct == 'ul' and 'bps' in line):
                value = line.split()[segment_digit[direct]]
                return self._convert_value_for_get_value_on_name_from_echo_info(
                    value, line, direct, segment_digit)

    def _convert_to_bps_unit(self, rate):
        rate = rate.lower()
        rate_pattern = re.compile(r'^([\d.]+) {0,1}([kmg]{0,1}bps)')
        found_object = rate_pattern.search(rate)
        convertion_rate = {
            'kbps': 1000,
            'mbps': 1000 * 1000,
            'gbps': 1000 * 1000 * 1000,
        }
        value, unit = found_object.group(1), found_object.group(2)
        convert_value = convertion_rate[unit] * float(value)
        return convert_value

    def _get_qci_dic(self, info):
        """get the bearer id and qci
        """
        qci_dic = {}
        info_list = info.split('EGATE>')
        for line in info_list:
            id = re.findall(r"\bid=\d+", line, re.M)
            if id != []:
                qci = re.findall(r"\bqci=\d+", line, re.M)
                if qci == []:
                    qci_valu = None
                else:
                    qci_valu = int(qci[0].split("=")[-1])
                qci_dic.setdefault(str(id[0].split("=")[-1]), qci_valu)
        return qci_dic

    def _get_harq_value_from_echo_info(self, name, echo_info):
        """get the harq value base on the name from the echo info.
        """
        for line in echo_info.split("\n"):
            if name in line:
                value = line.split()[-1]
                self._log.debug("value = {}".format(value))
                return value

    def _create_local_folder(self, destination):
        """create local folder
        """
        if not os.path.isdir(destination):
            os.mkdir(destination)
        return destination

    def _extract_rrc_log_status(self, log_info, regexp):
        """Extract the rrc log state.

        :param string log_info: the rrc function state log
        :param string regexp:
        :return: ret state: rrc log function state, on or off.
        :rtype: string
        """
        column_of_rrc = 0
        ret_state = None
        found_rrc_flag = False
        for line in six.StringIO(log_info):
            if 'rrc' in line and not found_rrc_flag:
                found_rrc_flag = True
                column_of_rrc = re.split(r'\s+', line.strip()).index('rrc')
                continue
            if re.findall(regexp, line):
                ret_state = re.split(r'\s+', line.strip())[column_of_rrc + 1]
                break
        return ret_state.lower() if ret_state else ret_state

    def _remove_old_egate_cosole_log(self, log_path):
        """Remove old egate and edaemon log once the uec is activate before case start"""
        self._tool_dir = log_path
        ssh_client = LocalSshConnection()
        log_name = 'egate_console.log'
        self._log.info("remove log name %s" % log_name)
        ret = ssh_client.execute(r"cd %s;sudo rm `ls %s.* |grep -v \`readlink %s\`| awk -F '\n' '{print $1}'`;> %s"
                                 % (self._tool_dir, log_name, log_name, log_name))
        self._log.debug(ret)

    def _capture_all_logfile(self, target_path="/home/ute/tmp/", tag=None):
        """Capture all log file"""
        ssh_client = LocalSshConnection()
        ret = ssh_client.execute("ls /opt/iphy/latest/egate_console.log.*")
        file_list = ret[0].split("\n")
        current_time = time.strftime("%Y%m%d%H%M%S")
        if tag is not None:
            target_log_pathname = "egate_console_" + tag
        else:
            target_log_pathname = "egate_console_" + current_time
        for file_name in file_list:
            name = file_name.split("/")[-1]
            if name == "":
                continue
                self._log.debug("file:{}".format(name))
            full_log_name = os.path.join("/opt/iphy/latest/", name)
            if not os.path.isdir(os.path.join(
                    target_path, target_log_pathname)):
                ssh_client.execute(
                    "mkdir -p {}".format(os.path.join(target_path, target_log_pathname)))
            logname_plus_time = os.path.join(
                target_path, target_log_pathname, name)
            ssh_client.get_file(file_name, logname_plus_time)
            self._log.debug("the egate log file is {}.\n".format(file_name))

    def _analyse_throughput_value_on_specific_scell(
            self, output_line, tput_type):
        """analyse value for get_iphy_throughput_on_specific_scell in order to make sure mccabe<7"""
        output_line_split = output_line.split()
        tput_dict = {}
        start_index = 1
        length_of_str = len(output_line_split)
        self._log.info('length_of_str %s' % length_of_str)
        for key_type in ["CURRENT", "MIN", "MAX", "AVE"]:
            if start_index + 1 > length_of_str - 1:
                secd_index = start_index
            else:
                secd_index = start_index + 1
            self._log.info('secd_index %s' % secd_index)
            try:
                float(output_line_split[secd_index])
                tput_dict[key_type] = [output_line_split[start_index], '']
                start_index += 1
            except Exception:
                tput_dict[key_type] = [
                    output_line_split[start_index],
                    output_line_split[secd_index]]
                start_index += 2
        self._log.info('tput_dict %s' % tput_dict)
        throughput = tput_dict[str(tput_type).upper()][0]
        if tput_dict[str(tput_type).upper()][1] == 'Mbps':
            throughput = float(throughput) * 1000
        return throughput

    def _check_params_for_set_sim_state(self, state):
        """check if given paramerters are validate for set_sim_state"""
        if state.upper() not in ['INIT', 'CONFIGURED', 'ACTIVE']:
            raise Exception("parameter state: {} is invalid!!!".format(state))

    def _check_if_sim_state_is_set(self, state):
        """check if set sim state successful or not"""
        current_state = self.get_sim_state()
        self._log.info('after change the state is : {}'.format(current_state))
        if state.upper() != current_state:
            raise Exception("change state fail!!!")

    def _check_params_for_get_iphy_throughput_on_specific_scell(
            self, ue_id, direction, scell_id, tput_type):
        """check if give parameters for get_iphy_throughput_on_specific_scell is validate
                and return pass_regex to get_iphy_throughput_on_specific_scell"""
        if str(direction).upper() not in ['UL', 'DL'] or str(
                tput_type).upper() not in ['AVE', 'MAX', 'MIN', 'CURRENT']:
            raise Exception(
                "direction or tput_type is invalid, please check it!!!")
        if not str(ue_id).isdigit() or not str(scell_id).isdigit():
            raise Exception("ue_id or scell id is invalid!!!")
        if int(str(scell_id)) == 0:
            pass_regexp = "PCell"
        else:
            pass_regexp = "SCell"
        return pass_regexp

    def _check_params_for_iphy_call_summary(self, plugin, dspshrink):
        if not os.path.exists(dspshrink):
            raise Exception("dspshrink is not found.")

        if plugin is None:
            plugin = os.path.join(
                pkg_resources.resource_filename(
                    "ta_kiss_iphy", "tools"), "trace.plg")
        return plugin

    def convert_ue_id_from_str_to_list(self, ue_id_list, cell_id_list):
        """convert ue id and cell id from str to list
        """
        cell_id_list_tmp = cell_id_list
        ue_id_list = str(ue_id_list)
        if cell_id_list != 1:
            add_to_cell_id_cmd = "int(cell_id_array[index])"
            cell_id_list = str(cell_id_list)
        else:
            add_to_cell_id_cmd = "int(1)"
            cell_id_list = ""
        self._log.info("original parameter ue id list %s" % ue_id_list)
        self._log.info("original parameter cell/enb id list %s" % cell_id_list)
        ue_id_array = ue_id_list.strip().split(',')
        cell_id_array = cell_id_list.strip().split(',')
        self._log.info("ue id convert to array list: %s" % ue_id_array)
        self._log.info("cell/enb id convert to array list: %s" % cell_id_array)
        if cell_id_list_tmp != 1:
            if len(ue_id_array) != len(cell_id_array):
                raise Exception("Number of Cell/enb id is not equal to UE id , please check parameter!!!")
        ue_id_list, cell_id_list = self.convert_ue_id_from_str_to_list_add(add_to_cell_id_cmd, ue_id_array,
                                                                           cell_id_array)
        self._log.info("the converted ue id list is %s" % ue_id_list)
        self._log.info("the converted cell/enb id list is %s" % cell_id_list)
        ue_id_list_tmp = list(set(ue_id_list))
        if len(ue_id_list) != len(ue_id_list_tmp):
            self._log.info("parameter ue id list is reduplicative : %s" % Counter(ue_id_list))
            raise Exception("parameter ue id list is reduplicative, please check your id parameter")
        return ue_id_list, cell_id_list

    def convert_ue_id_from_str_to_list_add(self, add_to_cell_id_cmd, ue_id_array, cell_id_array):
        """convert ue id and cell id from str to list add
        """
        ue_id_list = []
        cell_id_list = []
        for index, id_tmp in enumerate(ue_id_array):
            if "..." in id_tmp:
                continue_id = id_tmp.strip().split("...")
                self._log.info("continue ue id list %s ... %s" % (continue_id[0], continue_id[1]))
                for id_tmp in range(int(continue_id[0]), int(continue_id[1]) + 1):
                    ue_id_list.append(int(id_tmp))
                    cell_id_list.append(eval(add_to_cell_id_cmd))
            else:
                try:
                    ue_id_list.append(int(id_tmp))
                    cell_id_list.append(eval(add_to_cell_id_cmd))
                except Exception:
                    raise Exception("parameter ue/cell/enb id is invalid,should be integer, please check it!!!")
        return ue_id_list, cell_id_list

    def convert_ue_id_from_str_to_list_group(self, ue_id_list):
        """convert ue id and cell id from str to list group
        """
        ue_group_list = ue_id_list.split(',')
        for i in range(len(ue_group_list)):
            if (ue_group_list[i].find("...") != -1):
                valus = ue_group_list[i]
                index = valus.index("...")
                min = valus[0:index]
                max = valus[index + 3:]
                self._log.info("index: %s   min: %s  max: %s" % (index, min, max))
                new_value = min
                for j in range(int(min) + 1, int(max) + 1):
                    new_value += ":"
                    new_value += str(j)
                self._log.info("new_value:%s " % (new_value))
                ue_group_list[i] = new_value
        ue_id_list = ":".join(ue_group_list)
        return ue_id_list

    def start_ul_udp_data_multi_ue(self, ue_id_list, through_put, duration, bearer_id=1, **kwargs):
        """start udp data traffic by egate command. data traffice type is UL.
        """
        unit, through_put = self._validate_and_return_throughput(through_put)
        ue_id_list, cell_index_list = self.convert_ue_id_from_str_to_list(ue_id_list, 1)
        for ue_id in ue_id_list:
            execute_cmd = "trf_data_start ue=%s dir=ul protocol=udp id=%s %s=%s seconds=%s" % \
                          (ue_id, bearer_id, unit, through_put, duration)
            for key in kwargs:
                execute_cmd = execute_cmd + " %s=%s" % (key, kwargs[key])
            self._log.info("execute_cmd = %s" % execute_cmd)
            self._log.info(self.execute_command(execute_cmd, pass_regexp="TRF", fail_regexp="Can't start traffic"))

    def start_ul_udp_data_multi_ue_with_diff_para(self, ue_id_list, through_put, duration, bearer_id=1, **kwargs):
        """start tcp data traffic by egate command. data traffice type is UL.
        """
        ue_id_loc = 0
        ue_id_list, cell_index_list = self.convert_ue_id_from_str_to_list(ue_id_list, 1)
        for ue_id in ue_id_list:
            if self._check_para_value(ue_id_list, through_put):
                through_put_new = through_put.strip().split(',')
                unit, through_put_tmp = self._validate_and_return_throughput(through_put_new[ue_id_loc])
            else:
                unit, through_put_tmp = self._validate_and_return_throughput(through_put)
            if self._check_para_value(ue_id_list, duration):
                duration_new = duration.strip().split(',')
                duration_tmp = duration_new[ue_id_loc]
            else:
                duration_tmp = duration
            if self._check_para_value(ue_id_list, bearer_id):
                bearer_id_new = bearer_id.strip().split(',')
                bearer_id_tmp = bearer_id_new[ue_id_loc]
            else:
                bearer_id_tmp = bearer_id
            execute_cmd = "trf_data_start ue=%s dir=ul protocol=udp id=%s %s=%s seconds=%s" % \
                          (ue_id, bearer_id_tmp, unit, through_put_tmp, duration_tmp)
            for key in kwargs:
                execute_cmd = execute_cmd + " %s=%s" % (key, kwargs[key])
            self._log.info("execute_cmd = %s" % execute_cmd)
            self._log.info(self.execute_command(execute_cmd, pass_regexp="TRF", fail_regexp="Can't start traffic"))
            ue_id_loc = ue_id_loc + 1

    def start_dl_udp_data_multi_ue(self, ue_id_list, through_put, duration, bearer_id=1, **kwargs):
        """start udp data traffic by egate command. data traffice type is DL.
        """
        unit, through_put = self._validate_and_return_throughput(through_put)
        ue_id_list, cell_index_list = self.convert_ue_id_from_str_to_list(ue_id_list, 1)
        for ue_id in ue_id_list:
            execute_cmd = "trf_data_start ue=%s dir=dl protocol=udp id=%s %s=%s seconds=%s" % \
                          (ue_id, bearer_id, unit, through_put, duration)
            for key in kwargs:
                execute_cmd = execute_cmd + " %s=%s" % (key, kwargs[key])
            self._log.info("execute_cmd = %s" % execute_cmd)
            self._log.info(self.execute_command(execute_cmd, pass_regexp="TRF", fail_regexp="Can't start traffic"))

    def start_dl_udp_data_multi_ue_with_diff_para(self, ue_id_list, through_put, duration, bearer_id=1, **kwargs):
        """start tcp data traffic by egate command. data traffice type is UL.
        """
        ue_id_loc = 0
        ue_id_list, cell_index_list = self.convert_ue_id_from_str_to_list(ue_id_list, 1)
        for ue_id in ue_id_list:
            if self._check_para_value(ue_id_list, through_put):
                through_put_new = through_put.strip().split(',')
                unit, through_put_tmp = self._validate_and_return_throughput(through_put_new[ue_id_loc])
            else:
                unit, through_put_tmp = self._validate_and_return_throughput(through_put)
            if self._check_para_value(ue_id_list, duration):
                duration_new = duration.strip().split(',')
                duration_tmp = duration_new[ue_id_loc]
            else:
                duration_tmp = duration
            if self._check_para_value(ue_id_list, bearer_id):
                bearer_id_new = bearer_id.strip().split(',')
                bearer_id_tmp = bearer_id_new[ue_id_loc]
            else:
                bearer_id_tmp = bearer_id
            execute_cmd = "trf_data_start ue=%s dir=dl protocol=udp id=%s %s=%s seconds=%s" % \
                          (ue_id, bearer_id_tmp, unit, through_put_tmp, duration_tmp)
            for key in kwargs:
                execute_cmd = execute_cmd + " %s=%s" % (key, kwargs[key])
            self._log.info("execute_cmd = %s" % execute_cmd)
            self._log.info(self.execute_command(execute_cmd, pass_regexp="TRF", fail_regexp="Can't start traffic"))
            ue_id_loc = ue_id_loc + 1

    def start_ul_tcp_data_multi_ue(self, ue_id_list, through_put, duration, bearer_id=1, **kwargs):
        """start tcp data traffic by egate command. data traffice type is UL.
        """
        unit, through_put = self._validate_and_return_throughput(through_put)
        ue_id_list, cell_index_list = self.convert_ue_id_from_str_to_list(ue_id_list, 1)
        for ue_id in ue_id_list:
            execute_cmd = "trf_data_start ue=%s dir=ul protocol=tcp id=%s %s=%s seconds=%s" % \
                          (ue_id, bearer_id, unit, through_put, duration)
            for key in kwargs:
                execute_cmd = execute_cmd + " %s=%s" % (key, kwargs[key])
            self._log.info("execute_cmd = %s" % execute_cmd)
            self._log.info(self.execute_command(execute_cmd, pass_regexp="TRF", fail_regexp="Can't start traffic"))

    def start_ul_tcp_data_multi_ue_with_diff_para(self, ue_id_list, through_put, duration, bearer_id=1, **kwargs):
        """start tcp data traffic by egate command. data traffice type is UL.
        """
        ue_id_loc = 0
        ue_id_list, cell_index_list = self.convert_ue_id_from_str_to_list(ue_id_list, 1)
        for ue_id in ue_id_list:
            if self._check_para_value(ue_id_list, through_put):
                through_put_new = through_put.strip().split(',')
                unit, through_put_tmp = self._validate_and_return_throughput(through_put_new[ue_id_loc])
            else:
                unit, through_put_tmp = self._validate_and_return_throughput(through_put)
            if self._check_para_value(ue_id_list, duration):
                duration_new = duration.strip().split(',')
                duration_tmp = duration_new[ue_id_loc]
            else:
                duration_tmp = duration
            if self._check_para_value(ue_id_list, bearer_id):
                bearer_id_new = bearer_id.strip().split(',')
                bearer_id_tmp = bearer_id_new[ue_id_loc]
            else:
                bearer_id_tmp = bearer_id
            execute_cmd = "trf_data_start ue=%s dir=ul protocol=tcp id=%s %s=%s seconds=%s" % \
                          (ue_id, bearer_id_tmp, unit, through_put_tmp, duration_tmp)
            for key in kwargs:
                execute_cmd = execute_cmd + " %s=%s" % (key, kwargs[key])
            self._log.info("execute_cmd = %s" % execute_cmd)
            self._log.info(self.execute_command(execute_cmd, pass_regexp="TRF", fail_regexp="Can't start traffic"))
            ue_id_loc = ue_id_loc + 1

    def _check_para_value(self, ue_id_list, para_list):
        if isinstance(para_list, int):
            para_list = str(para_list)
        if ',' in para_list:
            para_list_tmp = para_list.strip().split(',')
            if len(ue_id_list) == len(para_list_tmp):
                return True
            else:
                return False
        else:
            return False

    def start_dl_tcp_data_multi_ue(self, ue_id_list, through_put, duration, bearer_id=1, **kwargs):
        """start tcp data traffic by egate command. data traffice type is DL.
        """
        unit, through_put = self._validate_and_return_throughput(through_put)
        ue_id_list, cell_index_list = self.convert_ue_id_from_str_to_list(ue_id_list, 1)
        for ue_id in ue_id_list:
            execute_cmd = "trf_data_start ue=%s dir=dl protocol=tcp id=%s %s=%s seconds=%s" % \
                          (ue_id, bearer_id, unit, through_put, duration)
            for key in kwargs:
                execute_cmd = execute_cmd + " %s=%s" % (key, kwargs[key])
            self._log.info("execute_cmd = %s" % execute_cmd)
            self._log.info(self.execute_command(execute_cmd, pass_regexp="TRF", fail_regexp="Can't start traffic"))

    def start_dl_tcp_data_multi_ue_with_diff_para(self, ue_id_list, through_put, duration, bearer_id=1, **kwargs):
        """start tcp data traffic by egate command. data traffice type is DL.
        """
        ue_id_loc = 0
        ue_id_list, cell_index_list = self.convert_ue_id_from_str_to_list(ue_id_list, 1)
        for ue_id in ue_id_list:
            if self._check_para_value(ue_id_list, through_put):
                through_put_new = through_put.strip().split(',')
                unit, through_put_tmp = self._validate_and_return_throughput(through_put_new[ue_id_loc])
            else:
                unit, through_put_tmp = self._validate_and_return_throughput(through_put)
            if self._check_para_value(ue_id_list, duration):
                duration_new = duration.strip().split(',')
                duration_tmp = duration_new[ue_id_loc]
            else:
                duration_tmp = duration
            if self._check_para_value(ue_id_list, bearer_id):
                bearer_id_new = bearer_id.strip().split(',')
                bearer_id_tmp = bearer_id_new[ue_id_loc]
            else:
                bearer_id_tmp = bearer_id
            execute_cmd = "trf_data_start ue=%s dir=dl protocol=tcp id=%s %s=%s seconds=%s" % \
                          (ue_id, bearer_id_tmp, unit, through_put_tmp, duration_tmp)
            for key in kwargs:
                execute_cmd = execute_cmd + " %s=%s" % (key, kwargs[key])
            self._log.info("execute_cmd = %s" % execute_cmd)
            self._log.info(self.execute_command(execute_cmd, pass_regexp="TRF", fail_regexp="Can't start traffic"))
            ue_id_loc = ue_id_loc + 1

    def stop_dl_udp_data_multi_ue(self, ue_id_list, bearer_id, **kwargs):
        """stop udp data traffic by egate command. data traffice type is DL.
        """
        ue_id_list, cell_index_list = self.convert_ue_id_from_str_to_list(ue_id_list, 1)
        for ue_id in ue_id_list:
            execute_cmd = "trf_data_stop dir=dl id=%s ue=%s" % (bearer_id, ue_id)
            for key in kwargs:
                execute_cmd = execute_cmd + " %s=%s" % (key, kwargs[key])
            self._log.info("execute_cmd = %s" % execute_cmd)
            self._log.info(self.execute_command(execute_cmd, pass_regexp="stopped"))

    def stop_ul_udp_data_multi_ue(self, ue_id_list, bearer_id, **kwargs):
        """stop udp data traffic by egate command. data traffice type is UL.
        """
        ue_id_list, cell_index_list = self.convert_ue_id_from_str_to_list(ue_id_list, 1)
        for ue_id in ue_id_list:
            execute_cmd = "trf_data_stop dir=ul id=%s ue=%s" % (bearer_id, ue_id)
            for key in kwargs:
                execute_cmd = execute_cmd + " %s=%s" % (key, kwargs[key])
            self._log.info("execute_cmd = %s" % execute_cmd)
            self._log.info(self.execute_command(execute_cmd, pass_regexp="stopped"))

    def stop_dl_tcp_data_multi_ue(self, ue_id_list, bearer_id, **kwargs):
        """stop tcp data traffic by egate command. data traffice type is DL.
        """
        ue_id_list, cell_index_list = self.convert_ue_id_from_str_to_list(ue_id_list, 1)
        for ue_id in ue_id_list:
            execute_cmd = "trf_data_stop dir=dl id=%s ue=%s" % (bearer_id, ue_id)
            for key in kwargs:
                execute_cmd = execute_cmd + " %s=%s" % (key, kwargs[key])
            self._log.info("execute_cmd = %s" % execute_cmd)
            self._log.info(self.execute_command(execute_cmd, pass_regexp="stopped"))

    def stop_ul_tcp_data_multi_ue(self, ue_id_list, bearer_id, **kwargs):
        """stop tcp data traffic by egate command. data traffice type is UL.
        """
        ue_id_list, cell_index_list = self.convert_ue_id_from_str_to_list(ue_id_list, 1)
        for ue_id in ue_id_list:
            execute_cmd = "trf_data_stop dir=ul id=%s ue=%s" % (bearer_id, ue_id)
            for key in kwargs:
                execute_cmd = execute_cmd + " %s=%s" % (key, kwargs[key])
            self._log.info("execute_cmd = %s" % execute_cmd)
            self._log.info(self.execute_command(execute_cmd, pass_regexp="stopped"))

    def _set_sim_state_to_active(self, current_state, lua_cfg_file):
        """set sim state to ACTIVE"""
        if 'CONFIGURED' != current_state:
            self._set_sim_state_to_configured(current_state, lua_cfg_file)
        ret = self.execute_command(
            cmd='start',
            pass_regexp='CHANGE STATE: ACTIVE',
            timeout=900)
        self._log.info('start command result: {}'.format(ret))

    def _set_sim_state_to_configured(self, current_state, lua_cfg_file):
        """set sim state to CONFIGURED"""
        if 'INIT' != current_state:
            self.execute_command(cmd='reset', pass_regexp='EGATE>')
        ret = self.execute_command(
            cmd='cfg file={}'.format(lua_cfg_file),
            pass_regexp='CHANGE STATE: CONFIGURED')
        self._log.info('cfg file command result: {}'.format(ret))

    def get_dl_core_id(self, cell_id):
        """get the IPHY DL core id of the cell via command 'sim_tti_trace cell=1 format=trace_core_id'

        :param Integer cell_id: the cell ID of the cell
        :return: the dl core id of this cell in hex format.
        :rtype: String

        """
        cmd = 'sim_tti_trace cell=%s format=trace_core_id' % str(cell_id)

        dl_core_id = ''
        try:
            output = self.execute_command(cmd, pass_regexp=",0X", fail_regexp="Error")
            self._log.info(output)
            core_id = output.strip().split('\n')[0].strip()
            dl_core_id = core_id.split(',')[1].strip()
            dl_core_id = dl_core_id[:-1] + '0'
            self._log.info("core id for dl: {}".format(dl_core_id))
        except Exception as e:
            self._log.debug(str(e))
            raise KissIphyGetDLCoreIdException("failed to get the dl iphy id of cell:{}, "
                                               "please make sure cell is onair.".format(cell_id))
        return dl_core_id.lower()

    def make_dir(self, log_save_path):
        """create a log saved directory

        :param String log_save_path: the log saved path
        :return:

        """
        if not os.path.exists(log_save_path):
            os.makedirs(log_save_path)

    def clear_dl_antenna_dump_data(self, iphy_core_id, iphy_lmp_ip):
        """clear the history DL antenna dump data on IPHY board.

        :param String iphy_core_id: the iphy id, such as '0x1280'
        :param String iphy_lmp_ip: IP for ssh connection to IPHY, the default IP is '192.168.200.1'

        """
        ssh_client = self._setup_connect_to_iphy(iphy_lmp_ip)

        iphy_id_str_prefix3 = iphy_core_id[2:5]
        rm_cmd = 'rm /ram/antennaDump_*0x%s*\n' % iphy_id_str_prefix3
        self._log.debug(ssh_client.execute(rm_cmd))
        ls_cmd = 'ls /ram/antennaDump_*0x%s*\n' % iphy_id_str_prefix3
        self._log.info(ssh_client.execute(ls_cmd))
        mkdir_cmd = 'mkdir /ram'
        self._log.info(ssh_client.execute(mkdir_cmd))
        ssh_client._teardown()

    def trigger_dl_antenna_snapshot_dump(self, iphy_core_id, **kwargs):
        """dump DL antenna snapshot on I-PHY.

        :param string iphy_core_id: the DSP mapping ID to the cell.
        |

        :More supported IP and trigger parameters are available via kwargs:
            * **aashell_ip** - the IP address for telnet IPHY, the default IP is '192.168.200.1'.
            * **aashell_port** - the IP port for tetnet IPHY, the default port is 8023.
            * **iphy_lmp_ip** - the IP address for ssh connection to IPHY, the default IP is '192.168.200.1'
            * **trigger** - the trigger for 'iphy_dump_dl', they can be:
                - *no_trigger* - immediate dump (the same as no "trigger" argument = default trigger)
                - *pcfich_error* - dump on PCFICH decoding error for active cell
                - *pdsch_phy_error* - dump by real PDSCH CRC error triggered by UE PHY(when rvi=0, subframe <= 8)
                - *pdsch_sch_error* - dump by real PDSCH CRC error triggered by UE scheduler(initial TX, not high code
                rate, PCell)
                - *nbpss_ok* - dump of frame with successful NB-PSS decoding
                - *nbsss_ok* - dump of frame with successful NB-SSS decoding
                - *frame* - dump of frame with frame number (0-1023) provided as "param" argument.
            * **param** - if the trigger is not default, more parameters are given for different triggers.
            * **domain** - optional, default = td
        """
        if not iphy_core_id.strip():
            raise KissIphyTriggerDLAntennaDumpWithNullIphyId("iphy_core_id is NULL! Please provide the correct iphy "
                                                             "id.")

        aashell_ip = kwargs.get('aashell_ip', '192.168.200.1')
        aashell_port = kwargs.get('aashell_port', 8023)
        iphy_lmp_ip = kwargs.get('iphy_lmp_ip', '192.168.200.1')
        trigger = kwargs.get('trigger', '')
        param = kwargs.get('param', '')
        domain = kwargs.get('domain', '')

        aashell = AaShell(aashell_ip, aashell_port)
        aashell.connect()

        iphy_dump_dl_cmd = 'iphy_dump_dl %s %s %s %s' % (iphy_core_id, trigger, param, domain)
        expresult = 'Antenna dumping is started. Please check for antennaDump_xxx.bin files in /ram/ folder in ' \
                    'I-PHY FSM'

        self.clear_dl_antenna_dump_data(iphy_core_id, iphy_lmp_ip)

        try:
            aashell.execute_command(iphy_dump_dl_cmd, expresult)
        except Exception:
            iphy_dump_dl_cmd = 'iphy_dump_dl %s %s %s %s' % (iphy_core_id, trigger, param, domain)
            self.clear_dl_antenna_dump_data(iphy_core_id, iphy_lmp_ip)
            aashell.execute_command(iphy_dump_dl_cmd, expresult)
        aashell.close()

    def download_dl_antenna_dump_data(self, iphy_core_id, log_save_path, iphy_lmp_ip):
        """download the dl antenna dump data from IPHY to VM.

        :param String iphy_core_id: the iphy id, such as '0x1280'
        :param String log_save_path: the log saved path on VM
        :param String iphy_lmp_ip: the IP address for ssh connection to IPHY, the default IP is '192.168.200.1'

        """
        if not iphy_core_id.strip():
            raise KissIphyDownloadAntennaDumpDataWithNullIphyId("iphy_core_id is NULL! Please provide the correct "
                                                                "iphy id.")

        ssh_client = self._setup_connect_to_iphy(iphy_lmp_ip)

        iphy_id_str_prefix3 = iphy_core_id[2:5]
        out, err, ret = ssh_client.execute('ls /ram/antennaDump_*0x%s*\n' % iphy_id_str_prefix3)
        self._log.info("out: {}".format(out))
        if ret == 0:
            dump_file_list = out.split("\n")
            self.make_dir(log_save_path)
            for file_name in dump_file_list:
                if file_name != '':
                    self._log.info("Successfully dump DL antenna snapshot : {}".format(file_name))
                    time_stamp = time.strftime("%Y%m%d%H%M%S", time.localtime())
                    dump_file_name = os.path.basename(file_name)
                    short_file_name, ext = os.path.splitext(dump_file_name)
                    dest_file_name = short_file_name + "_" + time_stamp + ext
                    dest_file = os.path.join(log_save_path, dest_file_name)
                    ssh_client.get_file(file_name, dest_file)
            ssh_client._teardown()
        else:
            ssh_client._teardown()
            self._log.debug("error: {}, ret:{}".format(err, ret))
            raise KissIphyDLAntennaDumpException("Dump event isn't triggered, no dump data is found.")

    def _setup_connect_to_iphy(self, iphy_lmp_ip):
        try:
            ssh_client = SshConnection(iphy_lmp_ip, 'toor4nsn', 'oZPS0POrRieRtu', prompt=">", timeout=5)
            ssh_client._setup()
        except Exception as e:
            if "No match found for '>' " in str(e):
                self._log.info("use '#' to login in")
                ssh_client._teardown()
                ssh_client = SshConnection(iphy_lmp_ip, 'toor4nsn', 'oZPS0POrRieRtu', prompt="#", timeout=5)
                ssh_client._setup()
            else:
                raise Exception(e)
        return ssh_client

    def _get_iphy_wts_config_file(self):
        """get wts config file from iphy.
        """
        fsm = ute_fsmaccess()
        fsm.setup_wts_fsm_access(prompt=' >', fallback_prompt='#', host=self.lmp_ip, remote_host=self.host_ip)
        config_file = fsm.get_wts_config_file('/tmp/')
        fsm.teardown_wts_fsm_access()
        return config_file

    def _get_pci_from_wts_file(self, wts_file):
        """get pci from iphy wts file.
        """
        doc = etree.parse(source=wts_file)
        html = doc.getroot()
        cell_list = html.xpath('//cell')
        pci_list = list(filter(None, list(set([int(cell.text) for cell in cell_list]))))
        pci_list.sort()
        return pci_list

    def get_iphy_cell_number(self):
        """Get iphy cell number.
        """
        config_file = self._get_iphy_wts_config_file()
        all_pci = self._get_pci_from_wts_file(config_file)
        return len(all_pci)

    def get_iphy_phycell_id(self, cell_index):
        """Get iphy phycell id.
        """
        config_file = self._get_iphy_wts_config_file()
        all_pci = self._get_pci_from_wts_file(config_file)
        if to_int(cell_index) > len(all_pci):
            raise IphyGetPhyCellIdError("cell %s is illegal, total cell number is %s."
                                        % (cell_index, len(all_pci)))
        return all_pci[to_int(cell_index) - 1]

    def get_scell_throughput_ave(self, enb_id, cell_id, scell_type, direction):
        """Get average throughput for Pcell and Scells(cell level)

        :param enb_id: Enb id
        :param cell_id: Cell id
        :param direction: The direction , dl or ul, dl->type:pdsch ul->type:pusch
        """
        type_dict = {"dl": "pdsch", "ul": "pusch"}
        name_dict = {"pcell": "PCell", "scells": "SCells"}
        cmd = "cell_stats enb=%s id=%s type=%s scell=%s" % (
            enb_id, cell_id, type_dict[direction], scell_type)
        echo_info = self.execute_command(
            cmd, pass_regexp=type_dict[direction].upper())
        self._log.info(echo_info)
        ave_throughput = self._get_value_on_name_from_echo_info(
            name_dict[scell_type], echo_info, direction)
        if ave_throughput is not None:
            ave_throughput = self._convert_bps_str_to_kbps(ave_throughput)
        else:
            ave_throughput = 0
        return ave_throughput

    def _process_parameter_for_create_bearer(self, ue_id_list, bearer_id_list, precedence_list):
        """process parameters for create bearer"""
        ue_id_list = self._convert_unicode(ue_id_list)
        bearer_id_list = self._convert_unicode(bearer_id_list)
        precedence_list = self._convert_unicode(precedence_list)
        size_of_bearer_list = len(bearer_id_list)
        size_of_precedence_list = len(precedence_list)
        if not size_of_bearer_list <= size_of_precedence_list:
            raise Exception("Size of precedence_list (%d) is lower than size of bearer_id_list (%d)" %
                            (size_of_precedence_list, size_of_bearer_list))
        if not len(set(precedence_list)) == size_of_precedence_list:
            raise Exception("Each element of precedence_list must be unique")
        return ue_id_list, bearer_id_list, precedence_list

    def _convert_unicode(self, id_list):
        """convert unicode"""
        if isinstance(id_list, six.text_type):
            id_list = self._convert_id_str_to_list(str(id_list))
        if isinstance(id_list, six.string_types):
            id_list = self._convert_id_str_to_list(str(id_list))
        return id_list

    def _convert_id_str_to_list(self, id_str):
        """convert id string(format such as 1,2...4,5 ) to id list
        the ID can be ue ID or bearer ID.
        """
        id_str = str(id_str)
        id_array = id_str.split(",")
        id_list = []
        for id_tmp in id_array:
            try:
                if "..." in id_tmp:
                    continue_id = id_tmp.strip().split("...")
                    id_list.extend(
                        range(int(continue_id[0]), int(continue_id[1]) + 1))
                else:
                    id_list.append(int(id_tmp))
            except Exception:
                raise Exception("parameter id is invalid, should be integer, please check it!!!")
        if len(id_list) != len(set(id_list)):
            raise Exception("parameter id in list is duplicate, please check your id parameter")
        id_list.sort()
        return id_list

    def _convert_bps_str_to_kbps(self, str):
        ret = float(str) / 1000
        return float('%.2f' % ret)

    def _convert_value_for_get_value_on_name_from_echo_info(self, value, line, direct, segment_digit):
        if "bps" in value:
            number = line.split()[segment_digit[direct] - 1]
            unit = line.split()[segment_digit[direct]]
            value = self._convert_to_bps_unit(number + unit)
        return value

    def get_scell_id(self, ue_id, scell_index, timeout=5):
        """ get scell id."""
        entry = "get_scell_id(%s,%s)" % (ue_id, scell_index)
        cmd_str = "script file=%s entry=%s" % (self._cpln_lua_path, entry)
        self._log.info("Executing Egate script command '%s'" % cmd_str)
        ret = self.execute_command(cmd_str, timeout=int(str(timeout)), pass_regexp="Result=PASSED",
                                   fail_regexp="Result=FAILED")
        scell_id = re.search('get_scell_id Result=.*scell_id=(.*) end', ret, re.MULTILINE).group(1)
        if scell_id == "nil":
            raise Exception("Get scell id fail!")
        return to_int(scell_id)
