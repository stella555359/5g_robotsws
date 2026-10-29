# -*- coding: utf-8 -*-
"""
:created on: 15-04-2017

:copyright: Nokia
:author: Leo Wang, Lily Xu
:contact: leo.y.wang@nokia.com
:maintainer: Yonna Yao
:contact: yonna.yao@nokia-sbell.com
"""

from ute_common_store import Store
import logging
from .iphy import Iphy
from ute_common_bts.fsm import FsmServices
import subprocess
import sys


class tak_iphy(object):

    ROBOT_LISTENER_API_VERSION = 2
    ROBOT_LIBRARY_SCOPE = 'TEST SUITE'

    def __init__(self):
        self.store = Store()
        self.ROBOT_LIBRARY_LISTENER = self
        self.talib_version_dict = {}
        self.talib_verson_recorded = False

    def _inquiry_all_talib_version(self):
        cmd = "pip freeze"
        talib_version_list = (subprocess.check_output(cmd, shell=True)).decode().strip().split()
        for each_talib in talib_version_list:
            if "==" in each_talib:
                key, value = each_talib.split("==")
                self.talib_version_dict[key] = value

    def _start_keyword(self, name, attrs):
        if '--dryrun' in sys.argv:
            return True
        if not self.talib_verson_recorded:
            self._inquiry_all_talib_version()
            self.talib_verson_recorded = True
        if attrs['libname'].startswith(('ute_', 'ta_')):
            lib_name = attrs['libname'].replace('_', '-')
            talib_version = self.talib_version_dict[lib_name]
            logging.info('kw:{} talib name:{} talib_version:{}'.format(name, attrs['libname'], talib_version))

    def iphy_setup(self, edamon_port=10000, egate_port=20000, lmp_ip="192.168.200.1",
                   host_ip='127.0.0.1', alias='default'):
        """Setup iphy, this keyword must be called before others keyword in this library

        :param edamon_port: Edamon port. default.  10000
        :param egate_port: Egate port. default.   20000
        :param lmp_ip: Iphy lmp ip, default is 192.168.200.1.
        :param host_ip: Host ip address, default is '127.0.0.1'
        :param alias: Name of execution context
        """
        iphy_control = Iphy(edamon_port, egate_port, lmp_ip, host_ip)
        self.store.add(iphy_control, alias)
        self.store.get(alias).setup(alias=alias)

    def iphy_start_wtssim_with_cfg_file(
            self, lua_cfg_file, timeout=120, alias='default'):
        """Start wtssim and load cfg files

        :param lua_cfg_file: Path to the lua file where egate configuration is stored.
                              e.g.  '/opt/iphy/latest/tddLuaScripts/lte_wraparound_cfg.lua'
        :param timeout: Timeout, default is 120 seconds
        :param alias: Name of execution context
        """
        self.store.get(alias).start_wtssim_and_load_cfg_file(
            lua_cfg_file, timeout)

    def iphy_establish_s1_link(self, alias='default'):
        """Start establish s1 link by execute start command on egate.

        :param alias: Name of execution context
        :note: only execute start command and will not wait the status
        """
        self.store.get(alias).start_establish_s1_link()

    def iphy_wait_until_sib1_and_sib2_received(
            self, enb_id=1, cell_id=1, timeout=600, alias='default'):
        """*DEPRECATED!!*, please use 'iphy_sib1_and_sib2_should_be_received'.
        Wait unitl sib1 and sib2 received.

        :param enb_id: eNB ID, default is 1
        :param cell_id: Cell ID, default is 1
        :param timeout: Timeout, default is 600 seconds
        :param alias: Name of execution context
        """
        enb_id = int(str(enb_id))
        cell_id = int(str(cell_id))
        timeout = int(str(timeout))
        return self.store.get(alias).sib1_and_sib2_should_be_received(
            enb_id, cell_id, timeout)

    def iphy_sib1_and_sib2_should_be_received(
            self, enb_id=1, cell_id=1, timeout=600, nb=False, alias='default'):
        """Wait unitl sib1 and sib2 received.

        :param enb_id: eNB ID, default is 1
        :param cell_id: Cell ID, default is 1
        :param timeout: Timeout, default is 600 seconds
        :param nb: Is NB cell, True or False, default is not NB cell
        :param alias: Name of execution context
        :return: Indicate whether sib1 and sib2 is received. If yes, return True, else return False
        :rtype: bool
        """
        enb_id = int(str(enb_id))
        cell_id = int(str(cell_id))
        timeout = int(str(timeout))
        return self.store.get(alias).sib1_and_sib2_should_be_received(
            enb_id, cell_id, timeout, nb)

    def iphy_single_attach(
            self, ue_id, pass_regexp="UE IS ACTIVE", timeout=30, alias='default'):
        """*DEPRECATED!!*, please use iphy_attach
        Attach single iphy

        :param ue_id: UE ID
        :param pass_regexp: Pass regexp, default is "UE IS ACTIVE"
        :param timeout: timeout for waiting pass_regexp context, default is 30 seconds
        :param alias: Name of execution context
        """
        self.store.get(alias).sue_attach(ue_id, pass_regexp, timeout)

    def iphy_multi_attach(self, ue_start, ue_end, interval=0.5,
                          timeout=5, retry=0, selected_plmn=0, emergency=0, alias='default'):
        """*DEPRECATED!!*, please ues iphy_attach
        Attach multi iphys

        :param ue_start: Start UE id
        :param ue_end: End UE id
        :param interval: UE attach interval, default is 0.5 second
        :param timeout: UE attach timeout, default is 5 seconds
        :param retry: UE attach retry, default is 0
        :param selected_plmn: Selected plmn, default is None
        :param emergency: Emergency, default is None
        :param alias: Name of execution context
        """
        self.store.get(alias).mue_attach(
            ue_start,
            ue_end,
            interval,
            timeout,
            retry,
            selected_plmn,
            emergency)

    def iphy_attach(self, ue_id_list, cell_index_list=1, enb_index_list=1, interval=0.5,
                    timeout=5, retry=0, selected_plmn=0, emergency=0, ue_capability=None, alias='default'):
        """Attach specified ue id list
        :param ue_id_list: ue_group id for example:"1,3...5,7,9...11"
        :param cell_index_list: Number of comma contains on Cell_Index should be equal to contains on ue_id_list,
        default is 1.
        :param enb_index_list: Number of comma contains on enb_index should be equal to contains on ue_id_list,
        default is 1
        :param interval: UE attach interval, default is 0.5 second
        :param timeout: UE attach timeout, default is 5 seconds
        :param retry: UE attach retry, default is 0, if retry, set 1
        :param selected_plmn: Selected plmn, default is None
        :param emergency: Emergency, default is 0
        :param String ue_capability: UE capability. The default value is none, common attach can use this value.
        :param alias: Name of execution context
        :note: For ue_capability, if CA ue capability, please add all band into this code stream to run any different
        Testline.
        For example: ue_id_list=1,3...5,7,9...11  cell_index=1,2,1,3 The meaning of parameter is that ue id 1,7 attach
        to cell id 1,
        ue id 3,4,5 attach to cell id 2 and ue id 9,10,11 attach to cell id 3.
        """
        self.store.get(alias).mue_group_attach(
            ue_id_list,
            cell_index_list,
            enb_index_list,
            interval,
            timeout,
            retry,
            selected_plmn,
            emergency,
            ue_capability)

    def iphy_single_detach(self, ue_id, timeout=15, alias='default'):
        """*DEPRECATED!!*, please ues iphy_detach
        Detach single iphy which state is ue.ON or ue.IDLE

        :param ue_id: UE ID
        :param timeout: Timeout, default is 15 seconds
        :param alias: Name of execution context
        """
        self.store.get(alias).sue_detach(ue_id, timeout)

    def iphy_multi_detach(self, ue_start, ue_end, interval=0.5,
                          timeout=5, alias='default'):
        """*DEPRECATED!!*, please ues iphy_detach
        Detach multi iphys which state is ue.ON or ue.IDLE

        :param ue_start: Start UE id
        :param ue_end: End UE id
        :param interval: UE detach interval, default is 0.5 second
        :param timeout: UE detach timeout, default is 5 seconds
        :param alias: Name of execution context
        """
        self.store.get(alias).mue_detach(
            ue_start, ue_end, interval, timeout)

    def iphy_detach(self, ue_id_list, interval=0.5,
                    timeout=5, alias='default'):
        """
        Detach the ue id list which state is ue.ON or ue.IDLE

        :param ue_id_list: ue_group id for example:"1,3...5,7,9...11"
        :param interval: UE detach interval, default is 0.5 second
        :param timeout: UE detach timeout, default is 5 seconds
        :param alias: Name of execution context
        """
        self.store.get(alias).mue_group_detach(
            ue_id_list, interval, timeout)

    def iphy_all_detach(self, interval=0.5, timeout=15, alias='default'):
        """
        Detach all iphys which state is ue.ON or ue.IDLE

        :param interval: UE detach interval, default is 0.5 second
        :param timeout: Timeout, default is 15 seconds
        :param alias: Name of execution context
        """
        self.store.get(alias).detach_all(interval, timeout)

    def iphy_execute_egate_command(
            self, command, pass_regexp=None, fail_regexp=None, timeout=10, alias='default', **kwargs):
        """To execute a single command passed to iphy for the specific objective.

        :param command: Command to execute.
        :param pass_regexp: Regexp indIcating that the command passed.
        :param fail_regexp: Regexp indicating that the command failed.
        :param timeout: Timeout for waiting this operation print pass_regexp. Default is 10 seconds.
        :param alias: Name of execution context
        :return: Data received during the execution. Valid only if pass_regexp is set.
        :rtype: string
        :note: Command could be anything supported by the Telnet interface of egate.
               pass_regexp need assign value by yourself, otherwise the keyword will pass any condition
               you must have already call keyword 'iphy_start_wtssim_with_cfg_file' before call this keyword
        :Supported parameter is available via kwargs:
            return_output (boolean) - Flag indicating whether egate log should be printed out. Default is True.
            padding_buffer (int) - Parameter setting the size of the padding buffer to be used in the output
            If RRC protocol is enabled, set value >40000
        """
        return self.store.get(alias).execute_command(
            command, pass_regexp, fail_regexp, timeout, **kwargs)

    def iphy_get_ul_throughput_ave(self, ue_id, bearer_id=1, alias='default'):
        """Get ul average throughput
        :param String ue_id: UE ID
        :param Integer bearer_id: bearer id value, default value is 1
        :param alias: Name of execution context

        :return: uplink average throughput value, unit is Kbps.
        :rtype: float
        """
        return self.store.get(alias).get_ul_throughput_ave(
            ue_id=ue_id, bearer_id=bearer_id, alias=alias)

    def iphy_get_dl_throughput_ave(self, ue_id, bearer_id=1, alias='default'):
        """Get dl average throughput
        :param String ue_id: UE ID
        :param Integer bearer_id: bearer id value, default value is 1
        :param alias: Name of execution context

        :return: downlink average throughput value, unit is Kbps.
        :rtype: float
        """
        return self.store.get(alias).get_dl_throughput_ave(
            ue_id=ue_id, bearer_id=bearer_id)

    def iphy_get_ul_throughput_max(self, ue_id, bearer_id=1, alias='default'):
        """Get ul maximum throughput
        :param String ue_id: UE ID
        :param Integer bearer_id: bearer id value, default value is 1
        :param alias: Name of execution context

        :return: uplink max throughput value, unit is Kbps.
        :rtype: float
        """
        return self.store.get(alias).get_ul_throughput_max(
            ue_id=ue_id, bearer_id=bearer_id)

    def iphy_get_dl_throughput_max(self, ue_id, bearer_id=1, alias='default'):
        """Get dl maximum throughput
        :param String ue_id: UE ID
        :param Integer bearer_id: bearer id value, default value is 1
        :param alias: Name of execution context

        :return: downlink max throughput value, unit is Kbps.
        :rtype: float
        """
        return self.store.get(alias).get_dl_throughput_max(
            ue_id=ue_id, bearer_id=bearer_id)

    def iphy_set_simulator_state(self, state, alias='default'):
        """Set sim state base on the parameter of state. only support below status:INIT, CONFIGURED, ACTIVE.

        :param String state: Satus, such as: INIT, CONFIGURED, ACTIVE
        :param alias: Name of execution context
        :note: you must have already call keyword 'iphy_start_wtssim_with_cfg_file' before call this keyword
        """
        return self.store.get(alias).set_sim_state(state=state)

    def iphy_get_simulator_state(self, alias='default'):
        """Retrun the state of simulator, include INIT, CONFIGURING, CONFIGURED, ACTIVATING, ACTIVE
        :param alias: Name of execution context

        :return: the state of simulator.
        :rtype: string
        """
        return self.store.get(alias).get_sim_state()

    def iphy_get_active_bearer_qci(self, ue_id, alias='default'):
        """Get qci value of iphy. notice: it only get the active bearer's qci value.
        :param Integer ue_id: ue id
        :param alias: Name of execution context

        :return: active bearer id and qci
        :rtype: dictionary, key is active bearer id, value is qci value
        """
        return self.store.get(alias).get_active_bearer_qci(ue_id=ue_id)

    def iphy_modify_pathloss(self, ue_id, pathloss, alias='default'):
        """Modify pathloss

        :param String  ue_id: the identification of ue
        :param String  pathloss: pathloss value
        :param alias: Name of execution context
        """
        self.store.get(alias).modify_pathloss(ue_id=ue_id, pathloss=pathloss)

    def iphy_validate_uec_is_active(self, alias='default'):
        """Try to validate whether the Iphy uec status is active

        :param alias: Name of execution context
        :return: True if uec is active, else False.
        :rtype: bool
        :note: the keyword also can be used to check onair from UEC side,
        and if the return value is True, please also sleep about 0.2s to wait sib1 and sib2 message.
        """
        return self.store.get(alias).validate_uec_is_active()

    def iphy_modify_bearer(self, ue_id, bearer_id, alias='default', **kwargs):
        """Modifies iphy bearers.

        :param integer ue_id: local identifier of UE, start from 1.
        :param integer bearer_id: local identifier of bearer, range in (1..16)
        :param alias: Name of execution context
        |

        :Supported GBR and MBR parameters are available via kwargs:
            * **mbr_ul**      (integer)  -  Maximal Bit Rate of UL, kbps(only for GBR bearers), range in (1..25600)
            * **gbr_ul**      (integer)  -  Guaranteed Bit Rate of UL, kbps(only for GBR bearers, it should be the same
            as MBR), range in (1..25600)
            * **mbr_dl**      (integer)  -  Maximal Bit Rate of DL, kbps(only for GBR bearers), range in (1..25600)
            * **gbr_dl**      (integer)  -  Guaranteed Bit Rate of DL, kbps(only for GBR bearers, it should be the same
            as MBR), range in (1..25600)
            * **precedence**  (integer)  -  filter precedence (unique among all filters of all UE's bearers in the PDN)
            Note : You just can modify these parameters for GBR bearers, their UE bearer id is in (2, 3, 4, 5) by
            default setting.
        """
        ue_id = int(str(ue_id))
        bearer_id = int(str(bearer_id))
        self.store.get(alias).modify_bearer(
            ue_id=ue_id, bearer_id=bearer_id, **kwargs)

    def iphy_get_dl_bler_ave(self, ue_id, alias='default', **kwargs):
        """Get average downlink bler

        :param Integer ue_id: UE ID
        :param alias: Name of execution context
        :return: downlink bler average value, unit is Kbps
        :rtype: float
        """
        return self.store.get(alias).get_dl_bler_ave(ue_id=ue_id, **kwargs)

    def iphy_get_ul_bler_ave(self, ue_id, alias='default', **kwargs):
        """Get average uplink bler

        :param Integer ue_id: UE ID
        :param alias: Name of execution context
        :return: uplink bler average value, unit is Kbps
        :rtype: float
        """
        return self.store.get(alias).get_ul_bler_ave(ue_id=ue_id, **kwargs)

    def iphy_set_rrc_log(self, switch='on', uec_index=1, alias='default'):
        """Set RRC log switch

        :param switch: choose from 'on' and 'off', default is on
        :param uec_index: default is 1
        :param alias: Name of execution context
        """
        uec_index = int(str(uec_index))
        self.store.get(alias).set_rrc_log(switch=switch, uec_index=uec_index)

    def iphy_cleanup_egate_console_log(self, log_path='/opt/iphy/latest', alias='default'):
        """
        clean up the eagate log.

        :param logpath: set the egate console log path to cleanup
        :return:
        :rtype:
        """
        self.store.get(alias).cleanup_egate_log(log_path=log_path)

    def iphy_get_egate_console_log(
            self, log_save_path, tag=None, alias='default'):
        """Get iphy egate console log to local path

        :param string  log_save_path: the ue log save path
        :param string  tag: Indicate the UE log name
        :param alias: Name of execution context
        """
        self.store.get(alias).get_iphy_log(
            log_save_path=log_save_path, tag=tag)

    def iphy_get_last_allocation_info(self, ue_id, direction, alias='default'):
        """Get iphy last allocaltion info

        :param String  ue_id: the identification of ue
        :param String  direction: the direction , dl or ul
        :param alias: Name of execution context

        :return: Dictionary that contain ue last allocation info
        :rtype: dictionary
        """
        return self.store.get(alias).get_iphy_last_allocation_info(
            ue_id=ue_id, direction=direction)

    def iphy_query_status(self, ue_id, alias='default'):
        """Get state of iphy

        :param String  ue_id: the identification of ue
        :param alias: Name of execution context

        :return: ue states.
        :rtype: string
        """
        state = self.store.get(alias).get_ue_status(ue_id=ue_id)
        state = 'ACTIVE' if state == 'ON' else state
        return state

    def iphy_get_throughput_on_specific_scell(
            self, ue_id, direction, scell_id=0, tput_type='ave', alias='default'):
        """Get iphy throughput on specific scell(ue level).

        :param String  ue_id: the identification of ue
        :param String  direction: the direction , dl or ul
        :param Integer  scell_id:  the identification of cell. Default is 0. 0:PCell 1:Scell-1 2:Scell-2
        :param String  tput_type: the type of throughput. Default is 'ave'. Support below string: ave, max, min,
        current.
        :param alias: Name of execution context

        :return: the value of throughput, unit is Kbps.
        :rtype: float
        """
        return self.store.get(alias).get_iphy_throughput_on_specific_scell(
            ue_id=ue_id, direction=direction, scell_id=scell_id, tput_type=tput_type)

    def iphy_get_ue_throughput(self, ue_id, direction, tput_type, layer='physical', scell='all', alias='default'):
        """ Get ue throughput, egate command is 'ue_stats' . Return value do not contain throughput unit, only the
        throughput value.
        :param ue_id: ud id
        :param direction: it can be 'dl' or 'ul'
        :param tput_type:  it can be 'current', 'minimum', 'maximum', 'average'
        :param layer: it can be 'mac', 'physical', 'harq', 'rlc'
        :param scell: it can be 0,1,2,3,4,5,6 or pcell , scell, all. If set scell, will sum all scell; if set all, will
        sum pcell and scell
        :return: throughput value, unit will not be contained, but it is the same as the one in egate log
        """
        return self.store.get(alias).get_iphy_ue_throughput(ue_id=ue_id, direction=direction, tput_type=tput_type,
                                                            layer=layer, scell=scell)

    def iphy_create_bearer(self, ue_id_list, bearer_id_list, precedence_list=[0, 1, 2, 3, 4, 5, 6], filter_id=None,
                           interval=0.5, timeout=30, alias='default'):
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
        :param Integer filter_id: bearer filter ID. The default is drb_id.
        :param Integer timeout: create bearer timeout. The default value is 30 seconds.
        :param Integer interval: create bearer interval. The default value is 0.5 seconds.
        :param alias: Name of execution context
        """
        self.store.get(alias).create_bearer(ue_id_list=ue_id_list, bearer_id_list=bearer_id_list,
                                            precedence_list=precedence_list,
                                            filter_id=filter_id, interval=interval, timeout=timeout)

    def iphy_delete_bearer(self, ue_id_list, bearer_id_list,
                           interval=0.5, timeout=30, alias='default'):
        """Delete bearers from a list of Bearer IDs

        :param List ue_id_list: UE IDs list
        :param List bearer_id_list: Bearer IDs list
        :param Integer interval: delete bearer interval. The default value is 0.5 seconds.
        :param Integer timeout: delete bearer timeout. The default value is 30 seconds.
        :param alias: Name of execution context
        """
        self.store.get(alias).delete_bearer(
            ue_id_list=ue_id_list,
            bearer_id_list=bearer_id_list,
            interval=interval,
            timeout=timeout)

    def iphy_get_cell_throughput_ave(
            self, cell_id, direction, alias='default'):
        """Get statistics average throughput for cell, only can get Pcell

        :param Integer cell_id: cell id
        :param String  direction: ul or dl
        :param alias: Name of execution context

        :return: cell throughput, unit is bps
        :rtype: float
        """
        return self.store.get(alias).get_cell_throughput_ave(
            cell_id, direction)

    def iphy_get_transmission_mode(self, ue_id, alias='default'):
        """Get the iphy's transmission mode

        :param String  ue_id: UE ID
        :param alias: Name of execution context

        :return: Dictionary that contain ue identification and its TM mode
        :rtype: dictionary
        """
        return self.store.get(alias).get_transmission_mode(ue_id=ue_id)

    def iphy_rrc_reestablish(self, ue_id, cell_id=None,
                             enb_id=None, alias='default'):
        """Reestablish iphy rrc.

        :param String ue_id: Index of ue.
        :param String cell_id: Index of LNCEL.
        :param String enb_id: Index of enb.
        :param alias: Name of execution context
        """
        return self.store.get(alias).rrc_reestablish(
            ue_id=ue_id, cell_id=cell_id, enb_id=enb_id)

    def iphy_handover(self, ue_id, enb_id, cell_id, timeout, alias='default'):
        """Do iphy hand over

           :param String  ue_id: the identification of ue
           :param String  enb_id: the identification of enb
           :param String  cell_id: the identification of cell
           :param String  timeout: the timeout of handover action
           :param alias: Name of execution context
        """
        self.store.get(alias).iphy_handover(
            ue_id=ue_id, enb_id=enb_id, cell_id=cell_id, timeout=timeout)

    def iphy_teardown(self, alias='default'):
        """Teardown iphy
        :param alias: Name of execution context
        """
        self.store.get(alias).teardown()
        self.store.remove(alias)

    def iphy_start_ul_udp_data_traffic(self, ue_id_list, through_put, duration, bearer_id=1, alias='default', **kwargs):
        """start uplink udp data traffic.

        :param String ue_id_list: UE IDs list should >=1, e.g. ue_id_list=1,3,4,5 ue_id_list=1,3...5,8...9,11
        :param through_put: throughput value, (string)  -  Desired data transfer throughput, '10 Mbits/sec'
                            or '500Bytes/sec' or '500'(=500Kbits/sec) or '30M'(=30Mbits/sec) or '30K(=30Kbits/sec)
        :param Integer duration: duration time
        :param Integer bearer_id: bearer id value, default value is 1
        :param alias: Name of execution context
        |
        - units of through_put:
                    - bits/sec        range:56-175000000
                    - Kbits/sec       range:1-175000
                    - Mbits/sec       range:1-175
                    - Bytes/sec
                    - KBytes/sec
                    - MBytes/sec
            Note: conversion rate is equal to 1000.
        """

        if ',' in str(through_put) or ',' in str(duration) or ',' in str(bearer_id):
            self.store.get(alias).start_ul_udp_data_multi_ue_with_diff_para(ue_id_list=ue_id_list,
                                                                            through_put=through_put,
                                                                            duration=duration, bearer_id=bearer_id,
                                                                            **kwargs)
        else:
            self.store.get(alias).start_ul_udp_data_multi_ue(ue_id_list=ue_id_list, through_put=through_put,
                                                             duration=duration, bearer_id=bearer_id, **kwargs)

    def iphy_start_dl_udp_data_traffic(self, ue_id_list, through_put, duration, bearer_id=1, alias='default', **kwargs):
        """start downlink udp data traffic.

        :param String ue_id_list: UE IDs list should >=1, e.g. ue_id_list=1,3,4,5 ue_id_list=1,3...5,8...9,11
        :param through_put: throughput value, (string)  -  Desired data transfer throughput, '10 Mbits/sec'
                            or '500Bytes/sec' or '500'(=500Kbits/sec) or '30M'(=30Mbits/sec) or '30K(=30Kbits/sec)
        :param Integer duration: duration time
        :param Integer bearer_id: bearer id value, default value is 1
        :param alias: Name of execution context

        |
        - units of through_put:
                    - bits/sec        range:56-175000000
                    - Kbits/sec       range:1-175000
                    - Mbits/sec       range:1-175
                    - Bytes/sec
                    - KBytes/sec
                    - MBytes/sec
            Note: conversion rate is equal to 1000.
        """

        if ',' in str(through_put) or ',' in str(duration) or ',' in str(bearer_id):
            self.store.get(alias).start_dl_udp_data_multi_ue_with_diff_para(ue_id_list=ue_id_list,
                                                                            through_put=through_put,
                                                                            duration=duration, bearer_id=bearer_id,
                                                                            **kwargs)
        else:
            self.store.get(alias).start_dl_udp_data_multi_ue(ue_id_list=ue_id_list, through_put=through_put,
                                                             duration=duration, bearer_id=bearer_id, **kwargs)

    def iphy_start_ul_tcp_data_traffic(self, ue_id_list, through_put, duration, bearer_id=1, alias='default', **kwargs):
        """start uplink tcp data traffic.

        :param String ue_id_list: UE IDs list should >=1, e.g. ue_id_list=1,3,4,5 ue_id_list=1,3...5,8...9,11
        :param through_put: throughput value, (string)  -  Desired data transfer throughput, '10 Mbits/sec'
                            or '500Bytes/sec' or '500'(=500Kbits/sec) or '30M'(=30Mbits/sec) or '30K(=30Kbits/sec)
        :param Integer duration: duration time
        :param Integer bearer_id: bearer id value, default value is 1. All UE defined in ue_id_list parameter
                                  should have the same bearer id, and only one value needed for this parameter,
                                  such as bearer_id=1.
        :param alias: Name of execution context
        |
        - units of through_put:
                    - bits/sec        range:56-175000000
                    - Kbits/sec       range:1-175000
                    - Mbits/sec       range:1-175
                    - Bytes/sec
                    - KBytes/sec
                    - MBytes/sec
            Note: conversion rate is equal to 1000.
        """

        if ',' in str(through_put) or ',' in str(duration) or ',' in str(bearer_id):
            self.store.get(alias).start_ul_tcp_data_multi_ue_with_diff_para(ue_id_list=ue_id_list,
                                                                            through_put=through_put,
                                                                            duration=duration, bearer_id=bearer_id,
                                                                            **kwargs)
        else:
            self.store.get(alias).start_ul_tcp_data_multi_ue(ue_id_list=ue_id_list, through_put=through_put,
                                                             duration=duration, bearer_id=bearer_id, **kwargs)

    def iphy_start_dl_tcp_data_traffic(self, ue_id_list, through_put, duration, bearer_id=1, alias='default', **kwargs):
        """start downlink tcp data traffic.

        :param String ue_id_list: UE IDs list should >=1, e.g. ue_id_list=1,3,4,5 ue_id_list=1,3...5,8...9,11
        :param through_put: throughput value, (string)  -  Desired data transfer throughput, '10 Mbits/sec'
                            or '500Bytes/sec' or '500'(=500Kbits/sec) or '30M'(=30Mbits/sec) or '30K(=30Kbits/sec)
        :param Integer duration: duration time
        :param Integer bearer_id: bearer id value, default value is 1.All UE defined in ue_id_list parameter
                                  should have the same bearer id, and only one value needed for this parameter,
                                  such as bearer_id=1.
        :param alias: Name of execution context
        |
        - units of through_put:
                    - bits/sec        range:56-175000000
                    - Kbits/sec       range:1-175000
                    - Mbits/sec       range:1-175
                    - Bytes/sec
                    - KBytes/sec
                    - MBytes/sec
            Note: conversion rate is equal to 1000.
        """

        if ',' in str(through_put) or ',' in str(duration) or ',' in str(bearer_id):
            self.store.get(alias).start_dl_tcp_data_multi_ue_with_diff_para(ue_id_list=ue_id_list,
                                                                            through_put=through_put,
                                                                            duration=duration, bearer_id=bearer_id,
                                                                            **kwargs)
        else:
            self.store.get(alias).start_dl_tcp_data_multi_ue(ue_id_list=ue_id_list, through_put=through_put,
                                                             duration=duration, bearer_id=bearer_id, **kwargs)

    def iphy_stop_dl_udp_data_traffic(self, ue_id_list, bearer_id=1, alias='default', **kwargs):
        """stop udp data traffic. data traffice type is DL.

        :param String ue_id_list: UE IDs list should >=1, e.g. ue_id_list=1,3,4,5 ue_id_list=1,3...5,8...9,11
        :param Integer bearer_id: bearer id value, default value is 1
        :param alias: Name of execution context
        """

        self.store.get(alias).stop_dl_udp_data_multi_ue(
            ue_id_list=ue_id_list, bearer_id=bearer_id, **kwargs)

    def iphy_stop_ul_udp_data_traffic(self, ue_id_list, bearer_id=1, alias='default', **kwargs):
        """stop udp data traffic. data traffice type is UL.

        :param String ue_id_list: UE IDs list should >=1, e.g. ue_id_list=1,3,4,5 ue_id_list=1,3...5,8...9,11
        :param Integer bearer_id: bearer id value, default value is 1
        :param alias: Name of execution context
        """

        self.store.get(alias).stop_ul_udp_data_multi_ue(
            ue_id_list=ue_id_list, bearer_id=bearer_id, **kwargs)

    def iphy_stop_dl_tcp_data_traffic(self, ue_id_list, bearer_id=1, alias='default', **kwargs):
        """stop tcp data traffic. data traffice type is DL.

        :param String ue_id_list: UE IDs list should >=1, e.g. ue_id_list=1,3,4,5 ue_id_list=1,3...5,8...9,11
        :param Integer bearer_id: bearer id value, default value is 1
        :param alias: Name of execution context
        """

        self.store.get(alias).stop_dl_tcp_data_multi_ue(
            ue_id_list=ue_id_list, bearer_id=bearer_id, **kwargs)

    def iphy_stop_ul_tcp_data_traffic(self, ue_id_list, bearer_id=1, alias='default', **kwargs):
        """stop tcp data traffic. data traffice type is UL.

        :param String ue_id_list: UE IDs list should >=1, e.g. ue_id_list=1,3,4,5 ue_id_list=1,3...5,8...9,11
        :param Integer bearer_id: bearer id value, default value is 1
        :param alias: Name of execution context
        """

        self.store.get(alias).stop_ul_tcp_data_multi_ue(
            ue_id_list=ue_id_list, bearer_id=bearer_id, **kwargs)

    def iphy_get_dl_core_id(self, cell_id, alias='default'):
        """get the IPHY DL core id of the cell via below command:

        "EGATE> sim_tti_trace cell=1 format=trace_core_id"

        0X1274,0X1282

        The second ID is the DL IPHY ID. Note the last digit will be changed to 0, that is to say, 0x1280 will be
        returned.

        :param Integer cell_id: the cell ID of the cell
        :param String alias: Name of execution context
        :return: the dl core id of this cell in hex format.
        :rtype: String

        """
        return self.store.get(alias).get_dl_core_id(cell_id)

    def iphy_trigger_dl_antenna_snapshot_dump(self, iphy_core_id, alias='default', **kwargs):
        """trigger DL antenna snapshot dump on I-PHY by execute iphy_dump command

        :param String iphy_core_id: the DSP mapping ID of the cell.
        :param String alias: Name of execution context
        |

        :More supported IP and trigger parameters are available via kwargs:
            * **aashell_ip** - the IP address for telnet IPHY, the default IP is '192.168.200.1'.
            * **aashell_port** - the IP port for tetnet IPHY, the default port is 8023.
            * **iphy_lmp_ip** - the IP address for ssh connection to IPHY, the default IP is '192.168.200.1'
            * **trigger** - the trigger for 'iphy_dump', they can be:
                - *no_trigger* - immediate dump (the same as no "trigger" argument = default trigger)
                - *pcfich_error* - dump on PCFICH decoding error for active cell
                - *pdsch_phy_error* - dump by real PDSCH CRC error triggered by UE PHY(when rvi=0, subframe <= 8)
                - *pdsch_sch_error* - dump by real PDSCH CRC error triggered by UE scheduler(initial TX, not high code
                rate, PCell)
                - *nbpss_ok* - dump of frame with successful NB-PSS decoding
                - *nbsss_ok* - dump of frame with successful NB-SSS decoding
                - *frame* - dump of frame with frame number (0-1023) provided as "param" argument.
            * **param** - if the trigger is not default, more parameters are given for different triggers.
            * **domain** - optional, default = td:
                - *td* - time domain (cpri input), the antenna dump is run at Rx AIF2 side before FFT (default domain)
                - *fd* - frequency domain, the antenna dump is run after FFT (LTE Baseband analyzer with capture type =
                LMTS action replay)

                Note about massive MIMO:
                - *td* - td size but the content = header (4 samples) + guards (24 samples)  + fd antenna dump (samples
                in 5/10/15/20Mhz)
                + guards (24 samples)  + no significant area
                - *fd* - fd antenna dump
        """
        self.store.get(alias).trigger_dl_antenna_snapshot_dump(iphy_core_id, **kwargs)

    def iphy_download_dl_antenna_dump_data(self, iphy_core_id, log_save_path='/tmp/iphy_dump_data',
                                           iphy_lmp_ip='192.168.200.1', alias='default'):
        """After apply the DL IPHY dump command, if has caught the antenna data under /tmp/bts/(IPHY), download them to
        directory log_save_path(VM).
        The file name looks like antennaDump_0x1281_20MHz_cp_norm_antenna0_+timestamp.dat, for example:
        antennaDump_0x1281_20MHz_cp_norm_antenna0_20170815062509.dat

        :param String iphy_core_id: the DSP mapping ID of the cell.
        :param String log_save_path: the directory to save the dump data on the VM, the default directory is
        '/tmp/iphy_dump_data/'.
        :param String iphy_lmp_ip: the IP address for ssh connection to IPHY, the default IP is '192.168.200.1'
        :param alias: Name of execution context

        """
        self.store.get(alias).download_dl_antenna_dump_data(iphy_core_id, log_save_path, iphy_lmp_ip)

    def iphy_get_cell_number(self, alias='default'):
        """Get iphy cell number.

        :param alias: Name of execution context

        :return: cell number
        :rtype: int
        """
        return self.store.get(alias).get_iphy_cell_number()

    def iphy_get_phycell_id(self, cell_index, alias='default'):
        """Get iphy phycell id.

        :param cell_index: Cell index, start from 1.
        :param alias: Name of execution context

        :return: phycell id
        :rtype: int
        """
        return self.store.get(alias).get_iphy_phycell_id(cell_index=cell_index)

    def iphy_get_scell_id(self, ue_id, scell_index, alias='default'):
        """
        Get scell id.
        :param ue_id: ue id
        :param scell_index: scell index
        :param alias: default value is "default"
        :return: scell number
        """
        return self.store.get(alias).get_scell_id(ue_id=ue_id, scell_index=scell_index)

    def iphy_get_scell_throughput_ave(self, enb_id, cell_id, scell_type, direction='dl', alias='default'):
        """Get average throughput for Pcell and Scells(cell level)

        :param enb_id: Enb id
        :param cell_id: Cell id
        :param direction: The direction , dl or ul, dl->type:pdsch ul->type:pusch, default is dl that mean type:pdsch
        :param scell_type: Scell type, pcell or scells
        :param alias: Name of execution context
        :return: the value of throughput, unit is Kbps.
        :rtype: float
        """
        return self.store.get(alias).get_scell_throughput_ave(enb_id=enb_id, cell_id=cell_id,
                                                              scell_type=scell_type, direction=direction)

    def iphy_local_enable_rnd_ports(self, lmp_ip, trs_user, trs_pass):
        """*DEPRECATED!!*, this keyword is not support remote, please ues iphy_enable_rnd_ports

        :param string lmp_ip: iphy lmp ip , default is 192.168.200.1
        """
        try:
            fsmServ = FsmServices(trs_ip=lmp_ip, trs_user=trs_user, trs_pass=trs_pass)
            fsmServ.enable_rnd_ports()
        except Exception:
            pass

    def iphy_local_disable_rnd_ports(self, lmp_ip, trs_user, trs_pass):
        """*DEPRECATED!!*, this keyword is not support remote, please ues iphy_disable_rnd_ports

        :param string lmp_ip: iphy lmp ip , default is 192.168.200.1
        """
        try:
            fsmServ = FsmServices(trs_ip=lmp_ip, trs_user=trs_user, trs_pass=trs_pass)
            fsmServ.disable_rnd_ports()
        except Exception:
            pass
