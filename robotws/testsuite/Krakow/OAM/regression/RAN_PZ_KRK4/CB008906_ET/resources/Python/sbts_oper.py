# -*- coding: utf-8 -*-
"""
Generic keywords for SBTS operation.

:copyright: Nokia Networks
:author: SHI Kun
:contact: I_NJ_SC_SYSTEM_VERF_GMS
:maintainer: I_NJ_SC_SYSTEM_VERF@internal.nsn.com
"""
import datetime
import time
import traceback
from functools import wraps

from moler.device import DeviceFactory
from moler.exceptions import CommandFailure
from moler.util.moler_test import MolerTest
from robot.libraries.BuiltIn import BuiltIn
from taf.rfrl.bts.devices.du.du_operations import GenericDuOperations
from taf.selenium.sbts.pages.bts_status import DetailedSiteViewPageDetailPanel
from taf.ul.sc.enb.airscale import AirScale as AirScale_ENB
from taf.ul.sc.enb.airscale.fct import Fct
from taf.ul.sc.gnb.airscale import AirScale as AirScale_GNB
from taf.ul.sc.hub import Hub
from taf.ul.sc.util.interface import Util

from testsuite.Krakow.OAM.regression.RAN_PZ_KRK4.CB008906_ET.resources.Python.helper import\
    ONAIR, GNB, ALL_ENABLED, NR, ENABLED, \
    LTE, TDD, FDD, CELL_TYPES


def need_bts_info(func):
    @wraps(func)
    def wrapper(self, *args, **kwargs):
        func_name = func.__name__
        MolerTest.info('>> Start {} <<'.format(func_name))
        bts_info = self.oper.get_bts_info()
        if not bts_info:
            raise Exception('BTS info is empty when execute "{}"!'.format(func_name))
        self.bts_info = bts_info
        out = func(self, *args, **kwargs)
        MolerTest.info('>> Exit {} <<'.format(func_name))
        return out
    return wrapper


def coam_web_login_logout(func):
    @wraps(func)
    def wrapper(self, *args, **kwargs):
        if not self.oper.gui_coam:
            self.oper.login_gui()
        try:
            out = func(self, *args, **kwargs)
            return out
        finally:
            if self.oper.gui_coam:
                self.oper.logout_gui()
                self.oper.gui_coam = None
    return wrapper


class SBTSOper(object):

    def __init__(self):
        self.bts_info = {}
        self.oper = GenericDuOperations(bts_type=GNB)

        tl = BuiltIn().get_variable_value('${tl}')
        self.tl = tl

        gnb_exist = False
        enb_exist = False
        self.enb = None
        self.gnb = None
        self.gnb_ws = None
        self.shub = None
        self.shub_ws = None
        self.asi_container_id = None
        gnb_oamip = '192.168.255.129'

        if hasattr(tl, 'gnbs') and tl.gnbs:
            gnb_exist = True
            gnb_oamip = tl.gnbs[0].cu.oam_http_connection_details.addr
        if hasattr(tl, 'enbs') and tl.enbs:
            enb_exist = True
        # instance to connect GNB board
        if gnb_exist:
            self.gnb = AirScale_GNB(autoconnect=False, oam_ip=gnb_oamip)
        # instance to connect ENB board
        if enb_exist:
            fct = Fct(device_name='ENB0', autoconnect=False)
            self.enb = AirScale_ENB(fct=fct)
            self.enb_hops = ['ENB0_WS']

        self.enb_exist = enb_exist
        self.gnb_exist = gnb_exist
        self.sbts_alias = 'GUI_GNB0_DU0'

    def connect_devices(self):
        if self.gnb_exist:
            self.gnb.connect_to_gnb()
            self.asi_container_id = self.gnb.get_asi_container_id()

        if self.enb_exist:
            self.enb.connect_to_enb()

        # instance to connect sHUB of master or slave
        self.shub = Hub(device_name='GNB0_HUB0', autoconnect=True)

    def connect_shub(self):
        self.shub.connect_to_hub()

    def disconnect_shub(self):
        self.shub.device.goto_state(state='PROXY_PC')

    def get_target_bts_id(self, rat):
        if rat == NR:
            return self.tl.gnbs[0].global_bts_id
        return self.tl.enbs[0].global_bts_id

    def get_bts_info(self):
        """
        Get BTS information then other method can query specific information.

        :return: None
        """
        bts_info = self.oper.get_bts_info()
        self.bts_info = bts_info
        return bts_info

    def clear_bts_info(self):
        self.bts_info = {}

    @need_bts_info
    def check_bbu_status(self, status=ONAIR, raise_exception=True):
        """
        Check if current status of BBU is same as the expected value defined by 'status'.

        :param status: str, which status BBU should be in: OnAir,
        :param raise_exception: bool, True - if the status is not expected, exception will be raised.
        :return: bool, True - expected, False - Not Expected
        """
        bts_info = self.bts_info
        current_bbu_status = bts_info.get('status', []).get('proceduralState', '')
        if current_bbu_status:
            MolerTest.info('Current BTS status: \n {}'.format(current_bbu_status))
            if current_bbu_status == status:
                return True
            else:
                error_msg = '{} is not expected ({}).'.format(current_bbu_status, status)
                MolerTest.error(error_msg, raise_exception=raise_exception)
            return False
        else:
            MolerTest.error('Can not get bbu status! \nCurrent BTS Info: {}'.format(bts_info),
                            raise_exception=raise_exception)

    @need_bts_info
    def check_rat_state(self, rat=NR, state=ALL_ENABLED, raise_exception=True):
        """
        Check RAT state

        :param rat: str, NR, LTE, WCDMA, GSM
        :param state: str, which state should be in: ALL_ENABLED, ALL_FAILED, NO_CELLS
        :param raise_exception: bool, True - if the status is not expected, exception will be raised.
        :return: bool, True - expected, False - Not Expected
        """
        bts_info = self.bts_info
        current_nr_state = bts_info.get('ratState', []).get(rat, '')
        if current_nr_state == state:
            return True
        else:
            error_msg = '{} is not expected ({}) for {}.\nCurrent BTS Info: {}'.format(
                current_nr_state, state, rat, bts_info)
            MolerTest.error(error_msg, raise_exception=raise_exception)
        return False

    @need_bts_info
    def check_shubs_state(self, state=ENABLED, raise_exception=True):
        """
        Check sHUB state

        :param state: str, which state should be in: ENABLED, Offline
        :param raise_exception: bool, True - if the status is not expected, exception will be raised.
        :return: bool, True - expected, False - Not Expected
        """
        bts_info = self.bts_info
        shubs = bts_info.get('radioModules', []).get('asirmod', [])
        MolerTest.info('RMOD information:\n {}'.format(shubs))
        if shubs:
            for shub in shubs:
                dn = shub['id']['configuration']
                current_status = shub['status']['operationalState']
                MolerTest.info('To check shub: {}, {}'.format(dn, state))
                if current_status != ENABLED:
                    error_msg = '{} is not expected ({}) for {}.\nCurrent all shubs info: {}'.format(
                        current_status, state, dn, shubs)
                    MolerTest.error(error_msg, raise_exception=raise_exception)
                    return False
        else:
            MolerTest.error('Can not get information to check shub state! \nCurrent BTS Info: {}'.format(bts_info),
                            raise_exception=raise_exception)

    @need_bts_info
    def get_shub_quantity(self, raise_exception=True):
        """
        Get total number of all sHUBs.

        :param raise_exception: bool, True - if the number is 0, exception will be raised.
        :return: int
        """
        bts_info = self.bts_info
        shubs = bts_info.get('radioModules', []).get('asirmod', [])
        MolerTest.info('RMOD information:\n {}'.format(shubs))

        quantity = len(shubs)
        if not quantity:
            MolerTest.error('Can not get sHUB quantity!', raise_exception=raise_exception)
        else:
            MolerTest.info('Found {} sHUBs.'.format(quantity))
        return quantity

    def collect_snapshot_in_asir_shub(self, output_dir, file_name='rfsw_snapshot.zip'):
        shub = self.shub
        shub.collect_snapshot(file_name)
        shub.download_snapshot_from_hub(output_dir=output_dir, filename=file_name)

    def check_cell_info_via_webui(self):
        """
        Check running cell information

        :return: dict
         {
            215: [
            {
                'rat': 'nr',
                'Global cell ID': '0',
                'targetLcrId': 3,
                'Operational state': 'enabled',
                'pmax': '23 dBm',
                'tech': 'tdd'
            }],
            100215: [
            {
                'rat': 'lte',
                'Global cell ID': '1',
                'targetLcrId': 3,
                'Operational state': 'enabled',
                'pmax': '18 dBm',
                'tech': 'fdd'
            }]
        }
        """
        cell_info = {}
        webem = self.oper.gui_coam

        # get bts id firstly
        bts_id = webem.get_bts_id(sbts=self.sbts_alias)
        MolerTest.info('Get BTS ID from COAM WebUI: {}'.format(bts_id))

        nr_cells = [item for item in webem.get_object_name_list(CELL_TYPES[NR], sbts=self.sbts_alias)
                    if item.startswith(CELL_TYPES[NR] + '-')]
        MolerTest.info('Get NR Cells: {}'.format(nr_cells))

        lte_cells = [item for item in webem.get_object_name_list(CELL_TYPES[LTE], sbts=self.sbts_alias)
                     if item.startswith(CELL_TYPES[LTE] + '-')]
        MolerTest.info('Get LTE Cells: {}'.format(lte_cells))

        for cell in nr_cells + lte_cells:
            cell_id = cell.split('-')[-1]
            if CELL_TYPES[NR] in cell:
                tech = NR
            elif CELL_TYPES[LTE] in cell:
                tech = LTE
            else:
                MolerTest.error('Wrong cell type: {}'.format(cell), raise_exception=True)
            result = webem.get_cell_info(cell_idx=cell_id, technology=tech, sbts=self.sbts_alias)
            MolerTest.info('results of cell info (cell idx: {}): {}'.format(cell_id, result))
            if tech == NR:
                # nr cell id: |  gnb Identity (22 bits - 32 bite) | Cell Identity (14 bits - 4bits)
                cell_id = int(result['NR cell ID'])
                target_bts_id = cell_id >> 14
                target_lcr_id = cell_id - (target_bts_id << 14)
                rat = NR
            else:
                # lte cell id: eNB_ID * 256 + sector_id
                cell_id = int(result['E-UTRAN cell ID'])
                target_bts_id = cell_id >> 8
                target_lcr_id = cell_id - (target_bts_id << 8)
                rat = LTE

            if target_bts_id not in cell_info:
                cell_info[target_bts_id] = []
            cell_info[target_bts_id].append(
                {
                    'rat': rat,
                    'Global cell ID': result['Global cell ID'],
                    'targetLcrId': target_lcr_id,
                    'Operational state': result['Status']['Operational state'],
                    'pmax': result['Maximum output power'],
                    'tech': TDD if TDD in result['Cell technology'].lower() else FDD
                }
            )
        MolerTest.info('Got running cell information: {}'.format(cell_info))
        return cell_info

    def get_all_parameters_via_webui(self, filter_param):
        self.oper.gui_coam.get_parameter_value_by_global_search(filter_param, sbts=self.sbts_alias)

    def get_active_alarms_via_webui(self):
        return self.oper.gui_coam.get_active_alarm_info(sbts=self.sbts_alias)

    def get_mrbts_id(self):
        if hasattr(self.tl.gnbs[0], 'instance_id'):
            return self.tl.gnbs[0].instance_id
        return self.get_mrbts_id_by_admin()

    def reboot_bbu(self):
        self.gnb.reboot(timeout=60)

    @need_bts_info
    def get_mrbts_id_by_admin(self):
        return self.bts_info['mrbtsID']

    def set_parameter_value(self, dist_name, filter_param, new_value):
        self.oper.gui_coam.set_parameter_value(dist_name, filter_param, new_value, sbts=self.sbts_alias)

    def activate_plan(self):
        # call the method in taf.selenium.sbts.interface.py
        self.oper.gui_coam.activate_plan(sbts=self.sbts_alias)

    def validate_plan(self):
        # call the method in taf.selenium.sbts.interface.py
        self.oper.gui_coam.validate_plan(sbts=self.sbts_alias)

    def get_parameter_value(self, dist_name, filter_param, node_index=None, abbr=None):
        # call the method in taf.selenium.sbts.interface.py
        return self.oper.gui_coam.get_parameter_value(dist_name, filter_param, node_index=node_index, abbr=abbr,
                                                      sbts=self.sbts_alias)

    def get_snapshot(self):
        try:
            webem = self.oper.gui_coam
            webem.collect_snapshot(sbts=self.sbts_alias)
        except Exception as e:
            MolerTest.error('Can NOT get snapshot successfully!\n{}'.format(e), raise_exception=True)
        return webem.download_dir

    def download_files(self, file_name, local_dir, remote_dir):
        Util().download_files(local_dir=local_dir, remote_file=file_name, remote_dir=remote_dir,
                              remote_device_name='GNB0', hops=[], timeout=120)

    def add_ems_moler_configuration(self, device_name, ems_config):
        proxy_pc_params = self.get_proxy_pc_params(config=ems_config)
        self.mlc.moler_devices.add_enb_emssim_configuration(
            device_name=device_name,
            host=ems_config['host'],
            port=ems_config['port'],
            **proxy_pc_params
        )

    def reboot_shub(self):
        shub = self.shub
        shub_ws = DeviceFactory.get_device('GNB0_HUB0_WS')

        shub.device.goto_state('LINUX')
        shub.reboot()
        self.wait_for_device_unreachable(shub_ws)

    def get_current_time_in_shub(self):
        shub = self.shub
        shub.device.goto_state('LINUX')
        cmd_time = shub.device.get_cmd(cmd_name='date')
        result = cmd_time()
        """
        DATE:     08-12-2022
        TIME:     01:35:36
        ZONE:     +0000 UTC
        EPOCH:        1670463336
        WEEK_NUMBER:  49
        DAY_OF_YEAR:  342
        DAY_OF_WEEK:  4 (Thursday)
        MONTH:        12 (December)
        """
        date_str = result['DATE']['FULL']
        time_str = result['TIME']['FULL']
        time_in_shub = datetime.datetime.strptime(date_str + ' ' + time_str, '%d-%m-%Y %H:%M:%S')
        MolerTest.info('Got time in shub: {}'.format(time_in_shub))
        return time_in_shub

    def get_client_ip(self, host_type):
        if host_type == 'FHNET':
            shub_ip = self.get_shub_ip_in_bbu()

            device = self.gnb.device

            # login shub
            device.goto_state('FHNET')
            # tcpdump "ip and udp and not arp and host 172.22.0.2 and outbound" -t -i any -c 5 -q
            tcpdump_cmd = device.get_cmd(
                cmd_name='tcpdump',
                cmd_params={
                    'options': '"ip and udp and not arp and host {} and outbound" -t -i any -c 1 -q'.format(
                        shub_ip)
                }
            )
            result = tcpdump_cmd(timeout=60)
            MolerTest.info('Got output of tcpdump: {}'.format(result))
            # Output like:
            # {'listening': 'any',
            # 'link-type': 'LINUX_SLL (Linux cooked v1)',
            # 'capture size': '262144 bytes',
            # '0': {'source': '172.21.0.2.13001',
            # 'destination': '172.22.0.2.13100',
            # 'details': 'UDP, length 12'},
            # 'packets received by filter': '4', 'packets dropped by kernel': '0'}
            return '.'.join(result['0']['source'].split('.')[:-1])

        elif host_type == 'WS':
            # maybe need change later
            lmp_of_shub = self.tl.gnbs[0].dus[0].rus[0].lmp_connection.addr
            ip_network = '.'.join(lmp_of_shub.split('.')[:-1])
            shub_ws = self.shub_ws
            if not shub_ws:
                shub_ws = DeviceFactory.get_device('GNB0_HUB0_WS')

            shub_ws.goto_state('UNIX_REMOTE')
            ip_cmd = shub_ws.get_cmd(cmd_name='ip_addr')

            if ip_cmd and ip_network:
                result = ip_cmd()
                for itf, ip_info in result.items():
                    for ip_protocol, ip in ip_info.items():
                        ip_addr = ip[0].get('IP', '')
                        if ip_addr and ip_addr.startswith(ip_network):
                            return ip_addr
        return None

    def ssh_login_shub_from_ws(self, host='192.168.255.129', login='toor4nsn', password='oZPS0POrRieRtu',
                               expected_prompt='toor4nsn@fzhub.*#', raise_exception=False):
        shub_ws = self.shub_ws
        if not shub_ws:
            shub_ws = DeviceFactory.get_device('GNB0_HUB0_WS')

        shub_ws.goto_state('UNIX_REMOTE')
        ssh_cmd = shub_ws.get_cmd(
            cmd_name='ssh',
            cmd_params={'host': host, 'login': login, 'password': password,
                        'expected_prompt': expected_prompt,
                        'allowed_newline_after_prompt': True
                        },
            check_state=True)

        try:
            ssh_cmd()
            time.sleep(2)
        except CommandFailure:
            if raise_exception:
                MolerTest.error('Can not login sHUB successfully!', raise_exception=raise_exception)
            else:
                MolerTest.info('During exception test, can not login sHUB successfully!')
        finally:
            shub_ws.goto_state('UNIX_REMOTE')

        self.shub_ws = shub_ws

    def get_shub_ip_in_bbu(self):
        device = self.gnb.device

        # get ip of shub
        # /MRBTS-1/RAT-1/BTS_L-1/EQM_L-1/CABINET_L-1/SMOD_L-1;0;172.22.0.2;NH211600050;APHG
        # /MRBTS-1/RAT-1/BTS_L-1/EQM_L-1/CABINET_L-1/BBMOD_L-1;0;172.22.0.2;NH210300340;APHG
        device.goto_state('FCT')
        grep_cmd = device.get_cmd(
            cmd_name='grep',
            cmd_params={'options': 'APH /ffs/run/config/FRIps.txt'}
        )
        shub_ip = grep_cmd()['LINES'][0].split(';')[-3]
        MolerTest.info('Got IP of sHUB: {}'.format(shub_ip))
        return shub_ip

    def ssh_login_shub_from_fhnet(self, shub_ip, login='toor4nsn', password='oZPS0POrRieRtu',
                                  expected_prompt='toor4nsn@fzhub.*#', raise_exception=False):
        device = self.gnb.device

        # login shub
        device.goto_state('FHNET')
        ssh_cmd = device.get_cmd(
            cmd_name='ssh',
            cmd_params={'host': shub_ip, 'login': login, 'password': password,
                        'expected_prompt': expected_prompt,
                        'allowed_newline_after_prompt': True},
            check_state=True)
        try:
            ssh_cmd()
            time.sleep(2)
        except CommandFailure:
            if raise_exception:
                MolerTest.error('Can not login sHUB successfully!', raise_exception=raise_exception)
            else:
                MolerTest.info('During exception test, can not login sHUB successfully!')

        exit_cmd = device.get_cmd(cmd_name='exit')
        try:
            exit_cmd()
        except CommandFailure:
            if raise_exception:
                MolerTest.error('Can not exit sHUB successfully!', raise_exception=raise_exception)
            else:
                MolerTest.info('During exception test, can not exit sHUB successfully!')
        finally:
            device.goto_state('FCT')

    @staticmethod
    def _ping_device(ws, expected_event='ping_response', destination='192.168.255.129', timeout=60.0):
        timeout = float(timeout)
        cmd_ping = ws.get_cmd(cmd_name='ping', cmd_params={'destination': destination, 'options': '-O'})
        event_ping = ws.get_event(event_name=expected_event, event_params={'till_occurs_times': 3})
        event_ping.start()
        cmd_ping.start(timeout=timeout)
        if event_ping.await_done(timeout=timeout):
            cmd_ping.cancel()

    def wait_for_device_unreachable(self, ws, timeout=30):
        dt_start = time.time()
        while time.time() < dt_start + timeout:
            try:
                self._ping_device(ws, expected_event='ping_no_response')
                break
            except Exception as e:
                MolerTest.error(traceback.format_exc())
        else:
            MolerTest.error("Device's status is not expected in {}s.".format(timeout), raise_exception=True)

    def wait_for_device_reachable(self, ws, timeout=30):
        dt_start = time.time()
        while time.time() < dt_start + timeout:
            try:
                self._ping_device(ws, expected_event='ping_response')
                break
            except Exception as e:
                MolerTest.error(traceback.format_exc())
        else:
            MolerTest.error("Device's status is not expected in {}s.".format(timeout), raise_exception=True)

    @staticmethod
    def get_proxy_pc_params(config):
        proxy_pc_params = {}
        if config.get('proxy_pc', None):
            proxy_pc_params = {
                'proxy_pc_host': config['proxy_pc'].default_ssh_connection_details.addr,
                'proxy_pc_login': config['proxy_pc'].default_ssh_connection_details.username,
                'proxy_pc_password': config['proxy_pc'].default_ssh_connection_details.password,
            }
        return proxy_pc_params

    @staticmethod
    def _run_script(device, script_cmd, additional_params=None):
        """
        Run script

        :param device: device instance
        :param script_cmd: command to ran
        :param additional_params: params to run script
        :return: None
        """
        cmd = script_cmd
        if additional_params is not None:
            cmd = ' '.join([script_cmd, additional_params])

        run_script = device.get_cmd(cmd_name='run_script',
                                    cmd_params={'script_command': cmd})
        run_script()

    @staticmethod
    def _lxc_attach(device, node_name, options):
        """
        Run command in LXC

        :param device: device instance
        :param node_name: str
        :param options: str, options added into lxc-attach
        :return: None
        """
        lxc_attach = device.get_cmd(cmd_name='lxc_attach',
                                    cmd_params={'name': node_name, 'options': options}
                                    )
        lxc_attach()


class ASiRWebEMBtn(DetailedSiteViewPageDetailPanel):
    _ASIR_WEBEM_BUTTON_XPATH = "//ui-button[@a-text='Launch ASiR WebEM']/button"

    def __init__(self, driver):
        super(ASiRWebEMBtn, self).__init__(driver)

    def enabled(self):
        return self.driver.find_element_by_xpath(self._ASIR_WEBEM_BUTTON_XPATH).is_enabled()
