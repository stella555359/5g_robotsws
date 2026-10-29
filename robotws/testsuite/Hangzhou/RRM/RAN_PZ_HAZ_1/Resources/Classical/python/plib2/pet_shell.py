# -*- coding: utf-8 -*-
"""
:copyright: Nokia Networks
:author: Ju Fei
:contact: fei.ju@nokia-sbell.com
"""
import os
import time
import sys
import re
import requests
from robot.api import logger
from robot.libraries import BuiltIn

from petbase import gv
logger = gv.logger
kw = gv.kw


class c_PetShell(object):

    def __init__(self):
        self.logger = logger
        self.known_ue_types = ['android']

    def read_config(self):
        filename = os.path.join(gv.robot_path, 'config.py')
        if os.path.exists(filename):
            gv.logger.info('config.py exist, load it')
            dire, realname = os.path.split(filename)
            import importlib
            if dire not in sys.path:
                sys.path.append(dire)
            module = importlib.import_module(os.path.splitext(realname)[0])
            for item in module.VARIABLES:
                kw('Set Suite Variable', '${' + item['name'] + '}', item['value'])

    def common_suite_setup_for_pet(self, **kwargs):
        kw('run keyword and ignore error', 'Set Library Search Order', 'coam')
        kw('run keyword and ignore error', 'Start testing')
        try:
            varnames = list(dict(os.environ).keys())
            varnames.sort()
            from pprint import pprint
            pprint(dict(os.environ))
            # for varname in varnames:
            #     gv.logger.info('{}:   {}'.format(varname, os.environ.get(varname, '')))
            gv.operator = '{}, {}, {}'.format(gv.tlname,
                                              gv.robot_file.split('/')[-1],
                                              os.environ.get('CM_EXECUTION_LINK', ''))
            gv.queue = os.environ.get('CM_QUEUE', '')
            kw('log to console', gv.operator)
            builtin = BuiltIn.BuiltIn()
            for varname in builtin.get_variables():
                print(f'VAR:  {varname}  ' + str(builtin.get_variables()[varname]))
        except Exception as E:
            gv.logger.error(E)

        kw('run keyword and ignore error', 'enable_ssh_key')
        kw('dealwith_queue')
        kw('lock_resource')
        kw('trigger_jenkins_job')

        fct_ip = kwargs.get('fct_ip', '192.168.255.129')
        kw('suite_setup_prepare', fct_ip)
        kw('install_new_build')

    def common_suite_teardown_for_pet(self, **kwargs):
        if gv.resources:
            for resource in gv.resources.split(','):
                kw('log to console', f'Try to unlock resource: {resource}')
                # kw('Run keyword and ignore error', 'Jenkins Unlock Resource', resource)
                kw('Run keyword and ignore error', 'unlock_resource_in_db', resource)
        kw('Run keyword and ignore error', 'Run', 'cp -r /home/ute/test_results/ /home/ute/test_results_bak')
        kw('Run keyword and ignore error', 'clean_big_file')
        kw('Run keyword and ignore error', 'Run', 'sudo rm -rf /home/ute/.netrc')
        pass

    def common_case_setup_for_pet(self, **kwargs):

        from lib_devices.common import init_keyword_group
        gv.keyword_group = init_keyword_group()

        def pm(name):
            return kwargs.get(name, '')

        admin_ip = kwargs.get('admin_ip', '192.168.255.129')
        fct_ip = kwargs.get('fct_ip', '192.168.255.129')
        admin_ip2 = kwargs.get('admin_ip2', '')
        fct_ip2 = kwargs.get('fct_ip2', '')
        ignore_check_cell = kwargs.get('ignore_cell_check', 'False')
        ignore_check_cell = ignore_check_cell.lower() == 'true'
        use_airphone = gv.pv('use_airphone')
        gv.use_airphone = use_airphone.lower() in ['y', 'yes', 'true']

        # gv.kw('Common Test Setup For RRM')
        gv.case.test = BuiltIn.BuiltIn()._context.test
        qcid_tag = [tag for tag in gv.case.test.tags if 'QC_' in tag]
        gv.case.case_id = qcid_tag[0].split('_')[-1] if qcid_tag else '10000'
        gv.case.case_dire = os.path.join(gv.suite.dire, gv.case.case_id)
        gv.kw('Set Test Variable', '${CASE_DIRE}', gv.case.case_dire)

        os.mkdir(gv.case.case_dire)
        os.mkdir(os.path.join(gv.case.case_dire, 'PMCounter'))
        gv.kw('Set Test Variable', '${PM_DIRE}', os.path.join(gv.case.case_dire, 'PMCounter'))
        os.mkdir(os.path.join(gv.case.case_dire, 'btslog'))
        gv.kw('Set Test Variable', '${BTSLOG_DIRE}', os.path.join(gv.case.case_dire, 'btslog'))

        gv.case.use_bts2 = pm('scf_file2') or pm('pm_file2') or pm('swconfig_file2')
        gv.case.bts_need_reboot = pm('swconfig_file') and not pm('scf_file')
        gv.case.bts_need_reboot2 = pm('swconfig_file2') and not pm('scf_file2')

        gv.case.fct_master = kw('pet_fct_connect', 'host=' + fct_ip)
        gv.case.fct_slave = kw('pet_fct_connect', 'host=' + fct_ip2) if fct_ip2 else None
        gv.case.admin_master = kw('setup_admin', 'bts_host=' + admin_ip, 'name=master', 'use_ssl=True', 'timeout=60')
        gv.case.admin_slave = kw('setup_admin', 'bts_host=' + admin_ip2, 'name=slave',
                                 'use_ssl=True', 'timeout=60') if gv.case.use_bts2 else None

        if gv.use_airphone:
            gv.write_console('Airphone Case')
            os.mkdir(os.path.join(gv.case.case_dire, 'airphone'))
            _params = [f'{x}={kwargs[x]}' for x in kwargs]
            gv.kw('setup_for_ap', *_params)
            gv.kw('run keyword and ignore error', 'teardown_admin', 'master')
            gv.case.admin_master = kw('setup_admin', 'bts_host=' + admin_ip,
                                      'name=master', 'use_ssl=True', 'timeout=60')
            gv.case.fct_master = kw('pet_fct_connect', 'host=' + fct_ip)
        else:
            if gv.debug:
                gv.write_console('DebugMode')
            else:
                swconfig = pm('swconfig_file')
                if swconfig:
                    gv.write_console('upload swconfig {}'.format(swconfig))
                    if os.path.exists(swconfig):
                        kw('pet_fct_upload_file', gv.case.fct_master, swconfig, '/ffs/run/swconfig.txt')
                    else:
                        raise Exception('{} file does no exit.'.format(swconfig))

                swconfig2 = pm('swconfig_file2')
                if swconfig2:
                    gv.write_console('upload swconfig {}'.format(swconfig2))
                    if os.path.exists(swconfig2):
                        kw('pet_fct_upload_file', gv.case.fct_slave, swconfig2, '/ffs/run/swconfig.txt')
                    else:
                        raise Exception('{} file does no exit.'.format(swconfig2))

                scf_file = pm('scf_file')
                if scf_file:
                    gv.write_console('use scf file: ' + scf_file)
                    if os.path.exists(scf_file):
                        kw('perform_commissioning', 'scf_file=' + scf_file, 'connection=master', 'timeout=900')
                    else:
                        raise Exception('{} file does no exit.'.format(scf_file))

                scf_file2 = pm('scf_file2')
                if scf_file2:
                    gv.write_console('use scf file2: ' + scf_file2)
                    if os.path.exists(scf_file2):
                        kw('perform_commissioning', 'scf_file=' + scf_file2, 'connection=slave', 'timeout=900')
                    else:
                        raise Exception('{} file does no exit.'.format(scf_file))

                if gv.case.bts_need_reboot:
                    gv.write_console('Reboot MASTER BTS...')
                    kw('reset_site', 300, 'master')
                gv.case.fct_master = kw('Wait Until Keyword Succeeds', '5 min', '10 sec',
                                        'pet_fct_connect', 'host=' + fct_ip)
                # gv.case.fct_master = kw('pet_fct_connect', 'host=' + fct_ip)
                if gv.case.bts_need_reboot2:
                    gv.write_console('Reboot SLAVE BTS...')
                    kw('reset_site', 300, 'slave')
                gv.case.fct_slave = kw('pet_fct_connect', 'host=' + fct_ip2) if fct_ip2 else None

                pm_file = pm('pm_file')
                if pm_file:
                    gv.write_console('use pm file: ' + pm_file)
                    if os.path.exists(pm_file):
                        kw('perform_delta_recommissioning', 'delta_file=' + pm_file, 'connection=master')
                    else:
                        raise Exception('{} file does no exit.'.format(pm_file))

                pm_file = pm('pm_file2')
                if pm_file:
                    gv.write_console('use pm file: ' + pm_file)
                    if os.path.exists(pm_file):
                        kw('perform_delta_recommissioning', 'delta_file=' + pm_file, 'connection=slave')
                    else:
                        raise Exception('{} file does no exit.'.format(pm_file))

        kw('Set Suite Variable', '${fct_master}', gv.case.fct_master)
        kw('Set Suite Variable', '${fct_slave}', gv.case.fct_slave)
        kw('Set Suite Variable', '${admin_master}', gv.case.admin_master)
        kw('Set Suite Variable', '${admin_slave}', gv.case.admin_slave)

        kw('pet_wait_until_bts_all_onair', 'master', '30min', '5sec', ignore_check_cell)
        if gv.case.use_bts2:
            kw('pet_wait_until_bts_all_onair', 'slave', '15min', '5sec', ignore_check_cell)
        try:
            if not gv.debug:
                self.pet_prepare_scf_id()
        except Exception as E:
            pass

    def common_case_teardown_for_pet(self, **kwargs):
        gv.teardown()
        if gv.use_airphone:
            gv.write_console('Teardown Airphone Case')
            kw('teardown_ap')

        kw('interface.Common step trigger')
        # kw('Run keyword and ignore error', 'Pet Stop Capture Btslog', '${collector_5g}')
        if gv.pv('${ignore_Trunk_roll}').upper() not in ['Y', 'YES', 'TRUE']:
            kw('Run keyword and ignore error', 'stop_and_fix')
        if gv.clean_log == 1:
            kw('log', 'does not need to clean log')
        elif gv.clean_log == 2:
            kw('Run Keyword If Test Passed', 'Run keyword and ignore error', 'pet_remove_big_log_files', '${CASE_DIRE}')
        else:
            kw('Run keyword and ignore error', 'pet_remove_big_log_files', '${CASE_DIRE}')
        if gv.case.admin_master:
            kw('Run keyword and ignore error', 'teardown_admin', 'master')
        if gv.case.admin_slave:
            kw('Run keyword and ignore error', 'teardown_admin', 'slave')
        if gv.case.fct_master:
            kw('Run keyword and ignore error', 'pet_fct_disconnect', '${fct_master}')
        if gv.case.fct_slave:
            kw('Run keyword and ignore error', 'pet_fct_disconnect', '${fct_slave}')

    def setup_iperf_server(self, **kwargs):
        from lib_devices.pet_datadevice import TputDevice
        start_server = kwargs.get('start_server', 'NO').upper() == 'YES'
        bind_ip = kwargs.get('bind_ip', '')
        server = TputDevice(host=kwargs.get('host', ''),
                            username=kwargs.get('username', 'ute'),
                            password=kwargs.get('passowrd', 'qqwweeRR0-'),
                            port=int(kwargs.get('port', 22)))
        server.connect()
        if start_server:
            server.restart_iperf_server(bind_ip)
        server.disconnect()

    def start_dl_iperf(self, **kwargs):
        from lib_devices.pet_datadevice import TputDevice
        server = TputDevice(host=kwargs.get('host', ''),
                            username=kwargs.get('username', 'ute'),
                            password=kwargs.get('password', 'qqwweeRR0-'),
                            port=int(kwargs.get('port', 22)))
        use_iperf3 = kwargs.get('use_iperf3', False)
        server.connect()
        if use_iperf3:
            server.start_iperf_to_ip_with_option3(kwargs.get('ueip', ''), kwargs.get('dloption', ''))
        else:
            server.start_iperf_to_ip_with_option(kwargs.get('ueip', ''), kwargs.get('dloption', ''))
        server.disconnect()

    def stop_dl_iperf(self, **kwargs):
        from lib_devices.pet_datadevice import TputDevice
        server = TputDevice(host=kwargs.get('host', ''),
                            username=kwargs.get('username', 'ute'),
                            password=kwargs.get('passowrd', 'qqwweeRR0-'),
                            port=int(kwargs.get('port', 22)))
        ueip = kwargs.get('ueip', '')
        if ueip:
            server.connect()
            server.kill_iperf_for_specific_ipaddr(ueip)
            server.disconnect()
        else:
            raise Exception('No ueip is specificed.')

    def pb_operator(self, **kwargs):
        factory = kwargs.get('factory', 'facom').lower()
        host = kwargs.get('host')
        port = kwargs.get('port')
        operation = kwargs.get('operation', 'poweron')

        from lib_devices.pet_pb import pb_factory
        pb = pb_factory(host=host, factory=factory, logger=logger)
        if operation == 'poweron':
            pb.power_on(int(port))
        else:
            pb.power_off(int(port))

    def change_pa_signal(self, **kwargs):
        device_type = kwargs.get('devicetype', 'rfswitch').lower()
        model = kwargs.get('model', 'jx').lower()

        host = kwargs.get('host')
        port = int(kwargs.get('port', 23))
        total_inport = int(kwargs.get('totalinport', 8))
        total_outport = int(kwargs.get('totaloutport', 16))

        points = kwargs.get('points', '')
        signal = int(kwargs.get('signal', 93))

        if device_type == 'pa':
            if model == 'jx':
                from lib_devices.pet_pa import c_jx_pa as PA
            if model == 'jxb':
                from lib_devices.pet_pa import c_jxb_pa as PA
            if model == 'hb':
                from lib_devices.pet_pa import c_hb_pa as PA
        else:
            if model == 'jx':
                from lib_devices.pet_pa import c_jx_matrix as PA
            if model == 'hb':
                from lib_devices.pet_pa import c_hb_matrix as PA
        device = PA(host, port, total_inport, total_outport, logger)
        device.connect()
        # ports: like: A5B8,A6B2
        try:
            for point in points.split(','):
                point = point.strip()
                if point:
                    logger.info('Work for {}  ==> {}'.format(point, signal))
                    inport, outport = re.findall('[A-Za-z]([0-9]*)', point)
                    device.change_signal(int(inport), int(outport), int(signal))
                    time.sleep(0.1)
        finally:
            device.disconnect()

    def add_ue(self, **kwargs):
        ue_type = kwargs.get('ue_type', 'android').lower()
        if ue_type not in self.known_ue_types:
            raise Exception('Unspport UE type {}, Support list: {}'.format(ue_type, self.known_ue_types))
        if ue_type == 'android':
            from lib_devices.pet_android_ue import c_android_ue
            kwargs.update({'logger': self.logger})
            ue = c_android_ue(**kwargs)
            ue.setup()
            return ue

    def ue_attach(self, ue=None, **kwargs):
        if ue.ue_type == 'android':
            ue.attach(**kwargs)

    def ue_deattach(self, ue=None, **kwargs):
        if ue.ue_type == 'android':
            ue.deattach(**kwargs)

    def get_ueip(self, ue=None):
        return ue.get_ueip()

    def start_ue_ul_iperf(self, ue=None, **kwargs):
        if ue.ue_type == 'android':
            if kwargs.get('use_cli', 'N') == 'Y':
                ue.start_naa_iperf_cli(**kwargs)
            else:
                ue.start_iperf_with_miperf(**kwargs)

    def stop_ue_ul_iperf(self, ue=None, **kwargs):
        if ue.ue_type == 'android':
            if kwargs.get('use_cli', 'N') == 'Y':
                ue.stop_naa_iperf_cli(**kwargs)
            else:
                ue.stop_iperf_with_miperf(**kwargs)

    def start_ping_to_ue(self, ue=None, **kwargs):
        if ue.ue_type == 'android':
            background = kwargs.get('in_backgroud', 'true').lower() == 'true'
            ue_ip = kwargs.get('ueip', '')
            ue.start_long_ping_to_ue(background, ue_ip)

    def stop_ping_to_ue(self, ue=None, **kwargs):
        if ue.ue_type == 'android':
            ue_ip = kwargs.get('ueip', '')
            ue.stop_long_ping_to_ue(ue_ip)

    def ue_reboot(self, ue=None, **kwargs):
        if ue.ue_type == 'android':
            ue.reboot()

    def ue_make_voice_call(self, ue=None, **kwargs):
        if ue.ue_type == 'android':
            number = kwargs.get('number', '')
            if number:
                ue.make_vocie_call(number)
            else:
                raise Exception('You need specific the call number')

    def ue_cancel_voice_call(self, ue=None):
        if ue.ue_type == 'android':
            ue.cancel_voice_call()

    def prepare_mcs(self, **kwargs):
        mcs_type = kwargs.get('mcs_type', 'jx2')
        kwargs['logger'] = logger
        if mcs_type.lower() == 'jx2':
            from lib_devices.pet_mcs import McsController_JX_2 as c_mcs
            mcs = c_mcs(**kwargs)
            mcs.setup()
            return mcs

    def config_mcs_with_csv_file(self, mcs=None, csv_file=''):
        mcs.set_phase_and_atts_with_csv_file(csv_file)

    def _get_matched_mcshark_build(self, build):
        url = 'https://artifactory-hz1.int.net.nokia.com/artifactory/wslte5g_plugins-local/MCShark/'
        fname = '/tmp/a.html'
        if os.path.exists(fname):
            os.remove(fname)
        os.system(f'wget {url} -O /tmp/a.html')
        lines = re.findall(build, open(fname).read())
        build = lines[0] if lines else ''
        if build:
            self.logger.info(f'发现了完全匹配的mcshark: {build}')
        else:
            self.logger.info(f'没有发现完全匹配的mcshark: {build}，只能用最新的了。')
        return build

    def prepare_mcshark(self):
        dest_dir = '/usr/lib/x86_64-linux-gnu/wireshark/plugins/4.0/epan'
        base_url = 'https://artifactory-hz1.int.net.nokia.com/artifactory/wslte5g_plugins-local/MCShark/'
        if [x for x in os.listdir(dest_dir) if x.startswith('mcshark')]:
            self.logger.info('MCShark plugin already exists.')
            return 0
        if gv.bts_version == '':
            raise Exception('No bts_version found.')
        build = gv.bts_version
        if '9999' in build:
            build = 'SBTS00_' + '_'.join(build.split('_')[1:])

        fname = '/tmp/a.html'
        t_build = self._get_matched_mcshark_build(build)
        if t_build == '':
            if os.path.exists(fname):
                os.remove(fname)
            os.system(f'wget {base_url} -O /tmp/a.html')
            builds = re.findall(r'SBTS00_ENB_[0-9,_]*', open(fname).read())
            builds.sort()
            t_build = build if build in builds else builds[-1]
        url = '{}{}/'.format(base_url, t_build)
        os.system(f'wget {url} -O /tmp/a.html')
        filename = list(set(re.findall(r'mcshark-4.0-[a-zA-Z-_0-9.+]*.so', open(fname).read())))
        filename = [x for x in filename if 'buster' in x]
        if filename:
            url += filename[0]
            self.logger.info('mcshark file: ' + url)
            auth = f'--user={gv.domain_name} --password={gv.domain_password}'
            gv.exec_local_command('sudo wget {} {} -P {}/'.format(url, auth, dest_dir))
        else:
            raise Exception('Could not find download url for MCShark')

    def prepare_nsetap_plugin_for_wireshark0(self, keyword='nsetap'):
        proxies = {'http': 'http://10.144.1.10:8080', 'https': 'http://10.144.1.10:8080'}

        dest_dir = '/usr/lib/x86_64-linux-gnu/wireshark/plugins/4.0/epan'
        if [x for x in os.listdir(dest_dir) if x.startswith(keyword)]:
            self.logger.info(f'{keyword} plugin already exists.')
            return 0

        lines = os.popen('lsb_release -a|grep Release').read().splitlines()
        lines = [x.split(':')[-1].strip() for x in lines if x.strip()]
        os_release = lines[0].strip() if lines else '10'
        self.logger.info(f'Current Debian Version: {os_release}')

        base_url = f'https://bts.inside.nsn.com/labstorage/Analyzer/Wireshark_LTE_NSN/deb{os_release}/'
        response = requests.get(base_url, proxies=proxies)
        release_nos = re.findall(f'{keyword}-[0-9.]*', response.text)
        release_nos.sort()
        latest_release = release_nos[-1]
        response = requests.get(f'{base_url}/{latest_release}', proxies=proxies)
        if response.status_code == 200:
            from lxml import html
            tree = html.fromstring(response.content)
            files = tree.xpath('//a[contains(text(), ".so")]/text()')
            files.sort()
            plugin_file = files[-1]
            self.logger.info(f'file: {plugin_file}')
            gv.exec_local_command(f'export https_proxy=http://10.144.1.10:8080 && '
                                  f'sudo wget {base_url}/{latest_release}/{plugin_file} -P {dest_dir}/')
        else:
            raise Exception(f'Failed to download plug file: {response.status_code}')

    def prepare_nsetap_plugin_for_wireshark2(self, keyword):
        dest_dir = '/usr/lib/x86_64-linux-gnu/wireshark/plugins/4.0/epan'
        if [x for x in os.listdir(dest_dir) if x.startswith(keyword)]:
            self.logger.info(f'{keyword} plugin already exists.')
            return 0
        cmd = f'sudo sshpass -p qqwweeRR0- scp -r ute@{gv.file_server}:/home/ute/store/nsetap/{keyword}* {dest_dir}/'
        gv.exec_local_command(cmd)

    def _list_http_file(self, url):
        import requests
        resp = requests.get(url)
        from lxml import etree
        return etree.fromstring(resp.content, parser=etree.HTMLParser()).xpath('//a/@href')

    def prepare_nsetap_plugin_for_wireshark(self, keyword):
        dest_dir = '/usr/lib/x86_64-linux-gnu/wireshark/plugins/4.0/epan'
        version_code = '4.0'
        if [x for x in os.listdir(dest_dir) if x.startswith(keyword)]:
            self.logger.info(f'{keyword} plugin already exists.')
            return 0
        else:
            self.logger.info(f'{keyword} plugin does not exists.')

        lines = os.popen('lsb_release -a|grep Codename').read().splitlines()
        lines = [x.split(':')[-1].strip() for x in lines if x.strip()]
        os_code = lines[0]
        self.logger.info(f'Current Debian Version: {os_code}')

        base_url = 'https://artifactory-hz1.int.net.nokia.com/artifactory/wslte5g_plugins-local/'
        url = f'{base_url}{keyword.upper()}'
        dires = [x for x in self._list_http_file(url) if keyword.lower() in x.lower()]
        dires.sort()
        files = [x for x in self._list_http_file(f'{url}/{dires[-1]}') if x.endswith('.so')]
        files = [x for x in files if os_code in x and f'-{version_code}-' in x]
        if files:
            dl_url = f'{url}/{dires[-1]}{files[-1]}'
            self.logger.info(f'file: {dl_url}')
            gv.exec_local_command(f'sudo wget {dl_url} -P {dest_dir}/')

    def prepare_nsetap_plugin(self):
        self.prepare_nsetap_plugin_for_wireshark('nsetap')
        # self.prepare_nsetap_plugin_for_wireshark('nsetap_x')

    def check_with_tshark(self, pcapfile='', filter='', perference='', keyword='', eoption=' -e _ws.col.Info',
                          decode_option='', additional_option=''):
        filter_str = '-Y "{}"'.format(filter) if filter else ''
        perference_str = '-o {}'.format(perference) if perference else ''
        decode_str = f'-d "{decode_option}"' if decode_option else ''
        cmd = 'sudo tshark -r {} {} {} {} {} -Tfields {} 2>/dev/null'.format(
            pcapfile, filter_str, perference_str, decode_str, additional_option, eoption)
        self.logger.info(cmd)
        lines = os.popen(cmd).readlines()
        for line in lines:
            self.logger.debug(line)
        if keyword:
            lines = [x for x in lines if keyword.lower() in x.lower()]
        self.logger.info('return length: {}'.format(len(lines)))
        return len(lines)

    def exec_local_command(self, command):
        self.logger.info('Exec Local CMD: [{}]'.format(command))
        lines = os.popen(command).readlines()
        for line in lines:
            self.logger.debug(line)
        return lines

    def setup_agent(self, **kwargs):
        from lib_devices.pet_proxy_client import c_Proxy_Client as Agent
        agent = Agent(**kwargs)
        agent.setup()
        return agent

    def pet_prepare_scf_id(self):
        tlname = gv.pv('${CONFIGURATION}').split('.')[-1]
        tlname = gv.pv('${SCOUTTLNAME}') or tlname
        kw('log to console', '\ntestline name: {}'.format(tlname))
        kw('scout.setup_scout', 'scout_testline_name={}'.format(tlname))
        scfid = 0
        try:
            scfid = kw('scout.request_scf')
        except Exception as E:
            kw('log to console', f'Error happened when get scfid: {E}')
            kw('log to console', 'Try again after 2 minustes')
            kw('sleep', '120s')
            scfid = kw('scout.request_scf')
        kw('log to console', '\nSCF id: {}'.format(scfid))
        return scfid


PetShell = c_PetShell()

if __name__ == '__main__':
    import logging
    log_level = logging.INFO
    FORMAT = '%(name)s-%(asctime)s [%(levelname)s] %(message)s'
    logging.basicConfig(format=FORMAT, datefmt="%Y-%m-%d %H:%M:%S", level=log_level)
    gv.bts_version = 'SBTS23R4_ENB_0000_000944_000000'
    # print(PetShell.prepare_nsetap_plugin())
    # PetShell.prepare_nsetap_plugin_for_wireshark2('nsetap')
    # PetShell._get_matched_mcshark_build('SBTS23R4_ENB_0000_000944_000000')
    PetShell.prepare_mcshark()
