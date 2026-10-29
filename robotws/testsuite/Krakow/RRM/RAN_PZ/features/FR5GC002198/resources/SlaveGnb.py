from taf.rfrl.utilities.tl_config import load_moler_configuration_from_tl
from testsuite.Krakow.resources.agent.agent import Agent5G
from taf.sbts.oam.coam.admin.interface import admin
from taf.rfrl.utilities.robot.general import get_builtin_value
from moler.util.moler_test import MolerTest
from robot.libraries.BuiltIn import BuiltIn
from moler.device import DeviceFactory
import xml.etree.ElementTree as Et
import moler.config
import requests
import os
import re
import sys


class SlaveGnb(object):
    def __init__(self, gnb_name='7_7_UTE5GCLOUDT4SK044', gnb_topology='CLOUD_5G_ASODA_AEUD', gnb_mplane="10.84.190.44",
                 path_gnb_moler_config='resources/moler_device/slave_gnb_cfg.yml'):
        self.admin = admin()
        self.agent = Agent5G()
        self.latest_sw = None
        self.gnb_mplane = gnb_mplane
        self.latest_sw_cu = None
        self.device_sw_cu = None
        self.device_py_env = None
        self.device_repository = None
        self.gnb_moler_config_loaded = False
        self.work_dir = '/home/ute/test_env'
        self.gnb_name = gnb_name
        self.gnb_topology = gnb_topology
        self.cur_dir = get_builtin_value('SUITE_SOURCE')
        self.path_gnb_config = path_gnb_moler_config
        self.robotws_path = os.path.join(self.work_dir, 'robotws')
        self.py_env_dir = os.path.join(self.work_dir, 'python_env')
        self.tl_config_path = os.path.join(self.work_dir, 'testline_configuration', self.gnb_name)
        self.script_path = 'testsuite/Krakow/RRM/RAN_PZ/features/FR5GC002198/resources/commissioning.robot'

    def _load_gnb_moler_config(self):
        if not self.gnb_moler_config_loaded:
            split_dir = self.cur_dir.split('/')
            gnb_config_abs_path = os.path.join('/'.join(split_dir[:-1]), self.path_gnb_config)
            MolerTest.info('Slave gNB moler config loaded from yaml: {}'.format(gnb_config_abs_path))
            moler.config.load_config(config=gnb_config_abs_path)
            self.gnb_moler_config_loaded = True

    def _initialize_device(self):
        self._load_gnb_moler_config()
        self.device_repository = DeviceFactory.get_cloned_device("GNB2_DU0", "GNB2_DU0_REPOSITORY_OPERATIONS",
                                                                 initial_state="PROXY_PC")
        self.device_sw_cu = DeviceFactory.get_cloned_device("GNB2_DU0", "GNB2_DU0_SOFTWARE_CU",
                                                            initial_state="PROXY_PC")
        self.device_py_env = DeviceFactory.get_cloned_device("GNB2_DU0", "GNB2_DU0_PYTHON_ENV",
                                                             initial_state="PROXY_PC")

    def _connect_gnb(self):
        if not self.gnb_mplane:
            self._get_mplane_addr()
        self.admin.connect_to(bts_host=self.gnb_mplane)

    @staticmethod
    def get_latest_released_build_name(branch):
        builds_wft_api = "https://wft.int.net.nokia.com/ext/builds?custom_filter[baseline]={}" \
                         "&custom_filter[branch_names][]={}&custom_filter[sorting_field]=delivery_date" \
                         "&custom_filter[sorting_direction]=DESC&custom_filter[items]=1" \
                         "&custom_filter[state][]=released"

        builds_wft_api_response = requests.get(url=builds_wft_api.format(branch, branch))
        xml_root = Et.fromstring(builds_wft_api_response.text)
        return xml_root[0][1].text

    def _install_requirements(self):
        cmd_req = "pip install --upgrade pip; pip install -r {}/requirements.cfg;" \
                  "pip install taf.internal.node".format(self.robotws_path)
        install_req = self.device_py_env.get_cmd(cmd_name="run_script",
                                                 cmd_params={'script_command': cmd_req})
        self._activate_python_env()
        install_req(timeout=1200)
        self._deactivate_python_env()

    def _get_mplane_addr(self):
        self._initialize_device()
        init_path = os.path.join(self.tl_config_path, '__init__.py')
        re_mplane = re.compile(r'_gnb_oam_ip\s+=\s+NetworkAddress\(\D+v4=\"(\d+\.\d+\.\d+\.\d+)')
        cmd_cat = self.device_repository.get_cmd(cmd_name="cat",
                                                 cmd_params={'path': init_path})
        cat_output = str(cmd_cat(timeout=120)['LINES'])
        found = re.search(re_mplane, cat_output)
        if found:
            self.gnb_mplane = found.group(1)
            MolerTest.info('gNB {} mplane address: {}'.format(self.gnb_name, self.gnb_mplane))
        else:
            MolerTest.error('gNB {} mplane address not found in {}:\n{}'.format(self.gnb_name,
                                                                                init_path, cat_output),
                            raise_exception=True)

    def _ping_mplane_addr(self):
        if not self.gnb_mplane:
            self._get_mplane_addr()
        cmd_ping = self.device_py_env.get_cmd(cmd_name="ping",
                                              cmd_params={'destination': self.gnb_mplane,
                                                          'options': '-c 10'})
        ping_result = cmd_ping(timeout=60)
        transmitted_packets = ping_result['packets_transmitted']
        received_packets = ping_result['packets_received']
        if transmitted_packets == received_packets:
            MolerTest.info('{} gNB DU MPlane IP is pingable.\n{}'.format(self.gnb_name, ping_result))
        else:
            MolerTest.error('{} gNB DU MPlane IP is not pingable.\n{}'.format(self.gnb_name, ping_result),
                            raise_exception=True)

    @staticmethod
    def _change_dir(device, path):
        cmd_cd = device.get_cmd(cmd_name="cd",
                                cmd_params={"path": path})
        cmd_cd(timeout=120)

    @staticmethod
    def _make_dir(device, dir_path):
        cmd_mkdir = device.get_cmd(cmd_name="mkdir",
                                   cmd_params={'path': dir_path})
        cmd_mkdir(timeout=180)

    def _get_active_gnb_sw(self):
        self._connect_gnb()
        gnb_sw = self.admin.get_sw_version()
        self.admin.teardown_admin()
        return gnb_sw

    def _download_build_artifacts(self, build):
        files_base = 'http://files.ute.nsn-rdnet.net/builds/enb/base/{}/Manifest.ini.txt'
        cmd_wget = self.device_sw_cu.get_cmd(cmd_name="wget",
                                             cmd_params={'options': files_base.format(build)})
        self._change_dir(device=self.device_sw_cu, path=self.work_dir)
        cmd_wget(timeout=120)

    def _get_related_cu_build(self, du_build):
        re_cu_build = re.compile(r"related_artifacts.+'(CUVNF\w+\.\w+\.\w+)'")
        path_artifacts = os.path.join(self.work_dir, 'Manifest.ini.txt')
        cmd_cat = self.device_sw_cu.get_cmd(cmd_name="cat",
                                            cmd_params={'path': path_artifacts})

        self._download_build_artifacts(du_build)
        cat_output = str(cmd_cat(timeout=120)['LINES'])
        MolerTest.info('cat cmd output:\n{}'.format(cat_output))
        match = re_cu_build.search(cat_output)
        if not match:
            MolerTest.error('CU build related to {} not found in artifacts:\n{}'.format(du_build, path_artifacts),
                            raise_exception=True)
        else:
            return match.group(1)

    def _create_python_env(self):
        cmd_create_env = "python3 -m venv {}"
        create_env = self.device_py_env.get_cmd(cmd_name="run_script",
                                                cmd_params={'script_command': cmd_create_env.format(self.py_env_dir)}
                                                )
        self._make_dir(device=self.device_py_env, dir_path=self.py_env_dir)
        create_env(timeout=180)

    def _activate_python_env(self):
        cmd_activate = "source {}"
        activate_env = self.device_py_env.get_cmd(
            cmd_name="run_script",
            cmd_params={'script_command': cmd_activate.format(os.path.join(self.py_env_dir, "bin", "activate"))})
        activate_env(timeout=180)

    def _deactivate_python_env(self):
        cmd_deactivate = "deactivate"
        deactivate_env = self.device_py_env.get_cmd(cmd_name="run_script",
                                                    cmd_params={'script_command': cmd_deactivate})
        deactivate_env(timeout=180)

    def _remove_python_env(self):
        remove_env = self.device_py_env.get_cmd(cmd_name="rm",
                                                cmd_params={'file': self.py_env_dir,
                                                            'options': '-rf'})
        remove_env(timeout=180)

    @load_moler_configuration_from_tl()
    @MolerTest.raise_background_exceptions()
    def clear_work_dir(self):
        cmd_find = self.device_repository.get_cmd(cmd_name="find",
                                                  cmd_params={'options': "$HOME -type d -wholename {}".format(
                                                      self.work_dir)})
        cmd_rm = self.device_repository.get_cmd(cmd_name="rm",
                                                cmd_params={'file': self.work_dir,
                                                            'options': '-rf'})

        find_output = cmd_find(timeout=60)['RESULT']
        MolerTest.info('cmd find output: {}'.format(find_output))
        if not find_output:
            MolerTest.info('Clearing skipped. Directory {} not exist'.format(self.work_dir))
        elif find_output[0] == self.work_dir:
            cmd_rm(timeout=30)
            MolerTest.info('Directory {} exists. Clearing performed.'.format(os.path.abspath(self.work_dir)))

    @load_moler_configuration_from_tl()
    @MolerTest.raise_background_exceptions()
    def clone_repositories(self, error_regex=re.compile("error", re.IGNORECASE)):
        self._initialize_device()
        cmd_git = "git clone 'https://gerrit.ext.net.nokia.com/gerrit/MN/UTE/testline_configuration'"
        cmd_robotws = "git clone 'https://gerrit.ext.net.nokia.com/gerrit/MN/UTE/robotws'"
        cmd_clone_config = self.device_repository.get_cmd(cmd_name="run_script",
                                                          cmd_params={'script_command': cmd_git,
                                                                      'error_regex': error_regex})
        cmd_clone_robotws = self.device_repository.get_cmd(cmd_name="run_script",
                                                           cmd_params={'script_command': cmd_robotws,
                                                                       'error_regex': error_regex})
        self.clear_work_dir()
        self._make_dir(device=self.device_repository, dir_path=self.work_dir)
        self._change_dir(device=self.device_repository, path=self.work_dir)
        cmd_clone_config(timeout=1200)
        cmd_clone_robotws(timeout=1200)
        self._create_python_env()
        self._install_requirements()

    @load_moler_configuration_from_tl()
    @MolerTest.raise_background_exceptions()
    def get_gnb_sw_info(self, branch_name, cloud_tl=False):
        active_sw = self._get_active_gnb_sw()
        self.latest_sw = self.get_latest_released_build_name(branch=branch_name)
        MolerTest.info('Active gNB SW version: {}'.format(active_sw))
        MolerTest.info('Latest released SW version in branch {}: {}'.format(branch_name, self.latest_sw))
        if cloud_tl:
            self._initialize_device()
            self.latest_sw_cu = self._get_related_cu_build(self.latest_sw)
            MolerTest.info('Found CU build related to {}: {}'.format(self.latest_sw, self.latest_sw_cu))

    def _get_active_sw_tag(self, trunk_sw=False):
        sw_tag = None
        software = self._get_active_gnb_sw()
        if "5G" in software:
            sw_tag = re.sub("_0+", ".", re.sub("5G", "pDU", software))
        elif "SBTS" in software:
            if trunk_sw:
                sw_tag = re.sub(r"SBTS\d+\w\d", "SBTS00", software)
            else:
                sw_tag = software
        else:
            MolerTest.error("Error. Not supported gNB active software Release: '{}'\n"
                            "Supported releases: 5G, SBTS".format(software))
        MolerTest.info("gNB active software: '{}', software tag: '{}'".format(software, sw_tag))
        return sw_tag

    @load_moler_configuration_from_tl()
    @MolerTest.raise_background_exceptions()
    def upgrade_gnb_sw(self, skip_upgrade):
        if not skip_upgrade:
            MolerTest.info('gNB SW upgrade ongoing')
            self.agent.run_agent_5g(
                config_path='{}/testline_configuration/{}/'.format(self.work_dir, self.gnb_name),
                label=self.gnb_topology, du_sw_version=self.latest_sw, cu_sw_version=self.latest_sw_cu,
                bts_id=2, agent_timeout=3600)
        else:
            MolerTest.info('gNB SW upgrade skipped')

    @load_moler_configuration_from_tl()
    @MolerTest.raise_background_exceptions()
    def perform_gnb_commissioning(self, script_path=None, gnb_upgraded=True, trunk_softwre=False,
                                  error_regex=re.compile(r'\| FAIL \|')):
        tl = BuiltIn().get_variable_value('${{{}}}'.format("tl"), None)
        local_vm_username = tl.test_pcs[0].default_ssh_connection_details.username
        local_vm_ipaddr = tl.test_pcs[0].default_ssh_connection_details.addr
        local_vm_password = tl.test_pcs[0].default_ssh_connection_details.password
        if gnb_upgraded:
            sw_version = self.latest_sw
        else:
            sw_version = self._get_active_sw_tag(trunk_softwre)
        if not script_path:
            script_path = self.script_path
        local_robotws_path = self.cur_dir.split('testsuite')[0]
        script_absolute_path = os.path.join(local_robotws_path, script_path)
        script_name = script_path.split('/')[-1]

        self._initialize_device()
        cmd_copy_script = self.device_py_env.get_cmd(cmd_name="scp", cmd_params={
            "source": "{}@{}:{}".format(local_vm_username, local_vm_ipaddr, script_absolute_path),
            "dest": self.robotws_path,
            "password": local_vm_password})
        cmd_chmod = self.device_py_env.get_cmd(cmd_name="chmod",
                                               cmd_params={"permission": "777",
                                                           "filename": '{}/{}'.format(self.robotws_path,
                                                                                      script_name)})
        cmd_gnb_commissioning = self.device_py_env.get_cmd(
            cmd_name="run_script",
            cmd_params={"script_command": "robot -v CONFIGURATION:Krakow.{} -v ENB_BUILD:{} -v ENB_BRANCH:{} -L TRACE"
                                          " -b debug.log --outputdir {}/logs_commissioning -V {} {}"
                                          "".format(self.gnb_name, sw_version, sw_version,
                                                    self.work_dir, self.tl_config_path,
                                                    '{}/{}'.format(self.robotws_path, script_name)),
                        "error_regex": error_regex})

        if sys.version_info >= (3, 7):
            cmd_gnb_commissioning.re_fail = None  # Changed to Moler 3.0.0 API
        else:
            cmd_gnb_commissioning._re_fail = None
        cmd_copy_script(timeout=300)
        cmd_chmod(timeout=60)
        self._change_dir(device=self.device_py_env, path=self.robotws_path)
        MolerTest.info(cmd_gnb_commissioning)
        self._activate_python_env()
        cmd_gnb_commissioning(timeout=1800)
        self._deactivate_python_env()
        self._change_dir(device=self.device_py_env, path="~")
        self._ping_mplane_addr()

    @MolerTest.raise_background_exceptions()
    def verify_slave_gnb_is_on_air(self):
        status = None
        try:
            self._connect_gnb()
            status = self.admin.get_bts_statuses()
            MolerTest.info('BTS status: {}'.format(status))
        except Exception as e:
            MolerTest.error('Exception occurred: '.format(e), raise_exception=True)
        finally:
            self.admin.teardown()

        if status["proceduralState"] == 'OnAir':
            MolerTest.info('Slave gNB {} is {}'.format(self.gnb_name, status["proceduralState"]))
        else:
            MolerTest.error('Slave gNB {} is not OnAir. Current gNB status: {}'.format(self.gnb_name, status),
                            raise_exception=True)
