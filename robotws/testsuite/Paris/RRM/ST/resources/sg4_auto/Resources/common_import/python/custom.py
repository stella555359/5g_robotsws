"""
        Variable file to set all NPS IV custom variables

        AUTHOR      Pascal Lecuyer       pascal.lecuyer@nokia.com
"""

__version__ = '2.2.6'
__date__ = '11/05/2020'

import os
import shutil
import yaml
from robot.api import logger
from robot.libraries.BuiltIn import BuiltIn

tl_name = None
custom = None
netact = None
nsp_nfmp = None
switchdict = None
eclat = None


class nps_syve_custom():
    PATH_Tools = ""
    PATH_Storage = ""
    PATH_RESOURCES = ""
    PATH_TL_Config = ""
    custom_file = ""
    ue_config_file = ""

    def check_config_file(self, filename):
        if not os.path.isfile(filename):
            # if not self.bfat():
            #     logger.error("%s not found." % filename, html=True)
            return False
        return True

    def launched_by_CloudManager(self):
        Configuration = BuiltIn().get_variable_value("${CONFIGURATION}")
        eNB_build = BuiltIn().get_variable_value("${ENB_BUILD}")
        eNB_branch = BuiltIn().get_variable_value("${ENB_BRANCH}")
        if (Configuration is not None) and (eNB_build is not None) and (eNB_branch is not None):
            return True
        return False

    def launched_by_eCLAT(self):
        if 'WORKSPACE' in os.environ:
            return True
        return False

    def CloudManager_launcher(self):
        """
        Case of testsuite robot launched by CloudManager
        :return: True if launch by CloudManager otherwise False
        """
        global eclat
        Configuration = BuiltIn().get_variable_value("${CONFIGURATION}")
        create_custom_variable = False
        if Configuration[:12] == 'ParisSaclay.':
            self.PATH_Storage = '%s/robot_temporary' % os.environ['HOME']
            self.PATH_RESOURCES = '%s/resources' % os.environ['HOME']
            self.PATH_Tools = '%s/resources/tools' % os.environ['HOME']
            base = ''
            for elt in os.path.dirname(os.path.abspath(__file__)).split('/')[1:-3]:
                base += '/' + elt
            self.PATH_TL_Config = '%s/config/ParisSaclay/%s' % (base, Configuration[12:])
            # Creation of path in local on the VM
            for ipath in [self.PATH_Storage, self.PATH_RESOURCES, self.PATH_Tools]:
                if not os.path.isdir(ipath):
                    if os.path.exists(ipath):
                        shutil.rmtree(ipath)
                    os.makedirs(ipath)
            eclat = {'launcher': 'CloudManager',
                     'storage': self.PATH_Storage,
                     'tools': self.PATH_Tools,
                     'exec_path': '',
                     'robotws5g': '',
                     'robotws5g_branch': '',
                     'logCollector_TLcfg': '',
                     'logCollector_CMDcfg': '',
                     'LOGS_STORAGE': self.PATH_Storage,
                     'PM_STORAGE': self.PATH_Storage,
                     'TL_PATH_CONFIG': self.PATH_TL_Config,
                     'TESTCASE_PATH': ''}
            config_file_found = False
            if 'INIT_CONFIG_FILE_PATH' in os.environ:
                self.custom_file = '%s/custom.yaml' % os.environ['INIT_CONFIG_FILE_PATH']
                self.ue_config_file = '%s/ue_config.yaml' % os.environ['INIT_CONFIG_FILE_PATH']
                config_file_found = self.check_config_file(self.custom_file)
            if not config_file_found:
                self.custom_file = '%s/custom.yaml' % self.PATH_TL_Config
                self.ue_config_file = '%s/ue_config.yaml' % self.PATH_TL_Config
                config_file_found = self.check_config_file(self.custom_file)
            create_custom_variable = config_file_found
        return create_custom_variable

    def eclat_launcher(self):
        """
        Case of testsuite robot launched by eCLAT
        :return: True if launch by eCLAT otherwise False
        """
        global eclat
        eclat = {'launcher': 'eCLAT',
                 'storage': os.environ['ECLAT_STORAGE'],
                 'tools': os.environ['ECLAT_TOOLS'],
                 'exec_path': os.environ['WORKSPACE'],
                 'robotws5g': os.environ['ROBOTWS5G_DIRECTORY'],
                 'robotws5g_branch': os.environ['ROBOTWS5G_BRANCH'],
                 'logCollector_TLcfg': os.environ['TLConfig'],
                 'logCollector_CMDcfg': os.environ['TLCommandsAndFiles'],
                 'LOGS_STORAGE': os.environ['LOGS_STORAGE'],
                 'PM_STORAGE': os.environ['PM_STORAGE'],
                 'TL_PATH_CONFIG': os.environ['TL_PATH_CONFIG'],
                 'eMODE': os.environ['eMODE'],
                 'TESTCASE_PATH': os.path.join(os.environ['WORKSPACE'], 'test-cases', os.environ['testCaseId'])}
        self.PATH_Storage = os.environ['ECLAT_STORAGE']
        self.PATH_Tools = os.environ['ECLAT_TOOLS']
        self.PATH_TL_Config = os.environ['eMODE'][3:]
        config_file_found = False
        if 'INIT_CONFIG_FILE_PATH' in os.environ:
            self.custom_file = '%s/custom.yaml' % os.environ['INIT_CONFIG_FILE_PATH']
            self.ue_config_file = '%s/ue_config.yaml' % os.environ['INIT_CONFIG_FILE_PATH']
            config_file_found = self.check_config_file(self.custom_file)
        if not config_file_found:
            self.custom_file = '%s/custom.yaml' % self.PATH_TL_Config
            self.ue_config_file = '%s/ue_config.yaml' % self.PATH_TL_Config
            config_file_found = self.check_config_file(self.custom_file)
        return config_file_found

    def other_launcher(self):
        """
        Case of testsuite robot launched manually or by another tool
        :return: True if launch by eCLAT otherwise False
        """
        global eclat
        self.PATH_Storage = '%s/robot_temporary' % os.environ['HOME']
        self.PATH_RESOURCES = '%s/resources' % os.environ['HOME']
        self.PATH_Tools = '%s/resources/tools' % os.environ['HOME']
        self.PATH_TL_Config = '%s/TL_Config' % os.environ['HOME']
        # Creation of path in local on the VM
        for ipath in [self.PATH_Storage, self.PATH_RESOURCES, self.PATH_Tools, self.PATH_TL_Config]:
            if not os.path.isdir(ipath):
                if os.path.exists(ipath):
                    shutil.rmtree(ipath)
                os.makedirs(ipath)
        eclat = {'launcher': 'unknown',
                 'storage': self.PATH_Storage,
                 'tools': self.PATH_Tools,
                 'exec_path': '',
                 'robotws5g': '',
                 'robotws5g_branch': '',
                 'logCollector_TLcfg': '',
                 'logCollector_CMDcfg': '',
                 'LOGS_STORAGE': self.PATH_Storage,
                 'PM_STORAGE': self.PATH_Storage,
                 'TL_PATH_CONFIG': self.PATH_TL_Config,
                 'TESTCASE_PATH': ''}
        config_file_found = False
        if 'INIT_CONFIG_FILE_PATH' in os.environ:
            self.custom_file = '%s/custom.yaml' % os.environ['INIT_CONFIG_FILE_PATH']
            self.ue_config_file = '%s/ue_config.yaml' % os.environ['INIT_CONFIG_FILE_PATH']
            config_file_found = self.check_config_file(self.custom_file)
        if not config_file_found:
            if 'TL_PATH_CONFIG' in os.environ:
                self.custom_file = '%s/custom.yaml' % os.environ['TL_PATH_CONFIG']
                self.ue_config_file = '%s/ue_config.yaml' % os.environ['TL_PATH_CONFIG']
                eclat['TL_PATH_CONFIG'] = os.environ['TL_PATH_CONFIG']
                config_file_found = self.check_config_file(self.custom_file)
        if not config_file_found:
            self.custom_file = './custom.yaml'
            self.ue_config_file = './ue_config.yaml'
            config_file_found = self.check_config_file(self.custom_file)
        return config_file_found

    def bfat(self):
        """
        Case of testsuite robot launched manually or by another tool
        :return: True if launch by eCLAT otherwise False
        """

        bfat_custom = BuiltIn().get_variable_value("${system_under_test.custom.1.MRBTS}")
        if bfat_custom is not None:
            return True
        return False

    def string_to_list(self, string_to_analyse):
        if type(string_to_analyse) is list:
            return string_to_analyse
        if type(string_to_analyse) is str:
            in_srting = False
            local_list = []
            for c in string_to_analyse:
                if in_srting:
                    if c == "'":
                        local_list.append(s)
                        in_srting = False
                    else:
                        s += c
                else:
                    if c == "'":
                        s = ''
                        in_srting = True
            return local_list
        return []

    def func_create_custom_variable(self):
        """
        Create custom dictionary by using custom.yaml file.
        Create tl_name, netact, nsp_nfmp and switchdict as well
        """
        global tl_name, custom, netact, nsp_nfmp, switchdict, eclat
        try:
            with open(self.custom_file, 'r') as stream:
                data_loaded = yaml.safe_load(stream)
                if 'tl_name' in data_loaded:
                    tl_name = data_loaded['tl_name']
                else:
                    tl_name = None
                if 'custom' in data_loaded:
                    custom = data_loaded['custom']
                    custom.update({'PATH_Tools': self.PATH_Tools})
                    custom.update({'PATH_Storage': self.PATH_Storage})
                    custom.update({'eclat': eclat})
                    custom.update({'PATH_Tools_titan': '/mnt/titan/tools'})
                    custom.update({'PATH_TL_Config': self.PATH_TL_Config})
                    for k, v in custom.items():
                        if v == 'None':
                            custom[k] = None
                        elif v == 'os.path.abspath(os.path.dirname(__file__))':
                            custom[k] = os.path.abspath(os.path.dirname(__file__))
                    # Management of key 'prisma_ppu_cell_5G'
                    # code to fix a bug about yaml to python translation then translate string into list
                    if ('prisma_ppu_cell_5G' in custom) and (type(custom['prisma_ppu_cell_5G']) is dict):
                        for k, v in custom['prisma_ppu_cell_5G'].items():
                            custom['prisma_ppu_cell_5G'][k] = self.string_to_list(v)
                    # Insert UE configuration file in dictionary custom
                    try:
                        with open(self.ue_config_file, 'r') as str_ue_config:
                            ue_config_loaded = yaml.safe_load(str_ue_config)
                            if 'UE_POOLS' in ue_config_loaded:
                                custom.update({'UE_POOLS': ue_config_loaded['UE_POOLS']})
                    except IOError:
                        pass
                else:
                    custom = None
                if 'netact' in data_loaded:
                    netact = data_loaded['netact']
                else:
                    netact = None
                if 'nsp_nfmp' in data_loaded:
                    nsp_nfmp = data_loaded['nsp_nfmp']
                else:
                    nsp_nfmp = None
                if 'switchdict' in data_loaded:
                    switchdict = data_loaded['switchdict']
                else:
                    switchdict = None
        except IOError:
            logger.error("Cannot open %s." % self.custom_file, html=True)
            pass

    def func_create_custom_variable_from_bfat(self):
        global custom
        custom = {
            'TL_Number': BuiltIn().get_variable_value("${system_under_test.custom.1.TL_number}"),
            'GNB_Friendly_TL_Name': BuiltIn().get_variable_value("${system_under_test.custom.1.GNB_Friendly_TL_Name}"),
            'GNB_Architecture': BuiltIn().get_variable_value("${system_under_test.custom.1.GNB_Architecture}"),
            'UE_Architecture': BuiltIn().get_variable_value("${system_under_test.custom.1.UE_Architecture}"),
            'GNB_nr_bts': BuiltIn().get_variable_value("${system_under_test.custom.1.GNB_nr_bts}"),
            'MRBTS': BuiltIn().get_variable_value("${system_under_test.custom.1.MRBTS}"),
            'GNB_First_CellID': BuiltIn().get_variable_value("${system_under_test.custom.1.GNB_First_CellID}"),
            'GNB_First_Cell_nrArfcn': BuiltIn().get_variable_value(
                "${system_under_test.custom.1.GNB_First_Cell_nrArfcn}"),
            'Cell_list': [
                {
                    'CellID': BuiltIn().get_variable_value("${system_under_test.custom.1.custom_cell.1.CellID}"),
                    'nrArfcn': BuiltIn().get_variable_value("${system_under_test.custom.1.custom_cell.1.nrArfcn}")
                },
                {
                    'CellID': BuiltIn().get_variable_value("${system_under_test.custom.1.custom_cell.2.CellID}"),
                    'nrArfcn': BuiltIn().get_variable_value("${system_under_test.custom.1.custom_cell.2.nrArfcn}")
                },
                {
                    'CellID': BuiltIn().get_variable_value("${system_under_test.custom.1.custom_cell.3.CellID}"),
                    'nrArfcn': BuiltIn().get_variable_value("${system_under_test.custom.1.custom_cell.3.nrArfcn}")
                }
            ],
            'yaml_prisma_filename_path': BuiltIn().get_variable_value(
                "${system_under_test.custom.1.yaml_prisma_filename_path}"),
            'yaml_prisma_filename': BuiltIn().get_variable_value("${system_under_test.custom.1.yaml_prisma_filename}"),
            'prisma_S1_present': BuiltIn().get_variable_value("${system_under_test.custom.1.prisma_S1_present}"),
            'prisma_UU_create_5G_cell': BuiltIn().get_variable_value(
                "${system_under_test.custom.1.prisma_UU_create_5G_cell}"),
            'prisma_ppu_cell_5G': [
                BuiltIn().get_variable_value("${system_under_test.custom.1.custom_prisma_ppu_cell_5g.1.ppu}"),
                BuiltIn().get_variable_value("${system_under_test.custom.1.custom_prisma_ppu_cell_5g.2.ppu}")
            ],
            'prisma_ppu_rach': BuiltIn().get_variable_value("${system_under_test.custom.1.prisma_ppu_rach}"),
            'Ul_gain': int(BuiltIn().get_variable_value("${system_under_test.custom.1.Ul_gain}")),
            'Dl_gain': int(BuiltIn().get_variable_value("${system_under_test.custom.1.Dl_gain}")),
            'prisma_tstm_X2_present': BuiltIn().get_variable_value(
                "${system_under_test.custom.1.prisma_tstm_X2_present}"),
            'prisma_UU_start_script': BuiltIn().get_variable_value(
                "${system_under_test.custom.1.prisma_UU_start_script}"),
            'prisma_cli_path': BuiltIn().get_variable_value("${system_under_test.custom.1.prisma_cli_path}"),
            'airmosaic_cfg_path': BuiltIn().get_variable_value("${system_under_test.custom.1.airmosaic_cfg_path}"),
            'sid_filename': BuiltIn().get_variable_value("${system_under_test.custom.1.sid_filename}"),
            'prisma_enable_amm': BuiltIn().get_variable_value("${system_under_test.custom.1.prisma_enable_amm}"),
            'prisma_clock_timer': BuiltIn().get_variable_value("${system_under_test.custom.1.prisma_clock_timer}"),
            'iPerf_VM_DL_ipaddress': BuiltIn().get_variable_value(
                "${system_under_test.custom.1.iPerf_VM_DL_ipaddress}"),
            'iPerf_VM_DL_login': BuiltIn().get_variable_value("${system_under_test.custom.1.iPerf_VM_DL_login}"),
            'iPerf_VM_DL_passwd': BuiltIn().get_variable_value("${system_under_test.custom.1.iPerf_VM_DL_passwd}"),
            'iPerf_VM_DL_Network_Interface_Address': BuiltIn().get_variable_value(
                "${system_under_test.custom.1.iPerf_VM_DL_Network_Interface_Address}"),
            'iPerf_VM_DL_Port': [
                BuiltIn().get_variable_value("${system_under_test.custom.1.custom_iperf_vm_dl_port.1.port}"),
                BuiltIn().get_variable_value("${system_under_test.custom.1.custom_iperf_vm_dl_port.2.port}"),
                BuiltIn().get_variable_value("${system_under_test.custom.1.custom_iperf_vm_dl_port.3.port}"),
                BuiltIn().get_variable_value("${system_under_test.custom.1.custom_iperf_vm_dl_port.4.port}"),
                BuiltIn().get_variable_value("${system_under_test.custom.1.custom_iperf_vm_dl_port.5.port}"),
                BuiltIn().get_variable_value("${system_under_test.custom.1.custom_iperf_vm_dl_port.6.port}"),
                BuiltIn().get_variable_value("${system_under_test.custom.1.custom_iperf_vm_dl_port.7.port}"),
                BuiltIn().get_variable_value("${system_under_test.custom.1.custom_iperf_vm_dl_port.8.port}"),
                BuiltIn().get_variable_value("${system_under_test.custom.1.custom_iperf_vm_dl_port.9.port}"),
                BuiltIn().get_variable_value("${system_under_test.custom.1.custom_iperf_vm_dl_port.10.port}"),
                BuiltIn().get_variable_value("${system_under_test.custom.1.custom_iperf_vm_dl_port.11.port}"),
                BuiltIn().get_variable_value("${system_under_test.custom.1.custom_iperf_vm_dl_port.12.port}"),
                BuiltIn().get_variable_value("${system_under_test.custom.1.custom_iperf_vm_dl_port.13.port}"),
                BuiltIn().get_variable_value("${system_under_test.custom.1.custom_iperf_vm_dl_port.14.port}")
            ],
            'iPerf_VM_UL_ipaddress': BuiltIn().get_variable_value(
                "${system_under_test.custom.1.iPerf_VM_UL_ipaddress}"),
            'iPerf_VM_UL_login': BuiltIn().get_variable_value("${system_under_test.custom.1.iPerf_VM_UL_login}"),
            'iPerf_VM_UL_passwd': BuiltIn().get_variable_value("${system_under_test.custom.1.iPerf_VM_UL_passwd}"),
            'iPerf_VM_UL_Network_Interface_Address': [
                BuiltIn().get_variable_value(
                    "${system_under_test.custom.1.custom_iperf_vm_ul_network_interface_address.1.ip}"),
                BuiltIn().get_variable_value(
                    "${system_under_test.custom.1.custom_iperf_vm_ul_network_interface_address.2.ip}"),
                BuiltIn().get_variable_value(
                    "${system_under_test.custom.1.custom_iperf_vm_ul_network_interface_address.3.ip}"),
                BuiltIn().get_variable_value(
                    "${system_under_test.custom.1.custom_iperf_vm_ul_network_interface_address.4.ip}"),
                BuiltIn().get_variable_value(
                    "${system_under_test.custom.1.custom_iperf_vm_ul_network_interface_address.5.ip}"),
                BuiltIn().get_variable_value(
                    "${system_under_test.custom.1.custom_iperf_vm_ul_network_interface_address.6.ip}"),
                BuiltIn().get_variable_value(
                    "${system_under_test.custom.1.custom_iperf_vm_ul_network_interface_address.7.ip}"),
                BuiltIn().get_variable_value(
                    "${system_under_test.custom.1.custom_iperf_vm_ul_network_interface_address.8.ip}"),
                BuiltIn().get_variable_value(
                    "${system_under_test.custom.1.custom_iperf_vm_ul_network_interface_address.9.ip}"),
                BuiltIn().get_variable_value(
                    "${system_under_test.custom.1.custom_iperf_vm_ul_network_interface_address.10.ip}"),
                BuiltIn().get_variable_value(
                    "${system_under_test.custom.1.custom_iperf_vm_ul_network_interface_address.11.ip}"),
                BuiltIn().get_variable_value(
                    "${system_under_test.custom.1.custom_iperf_vm_ul_network_interface_address.12.ip}"),
                BuiltIn().get_variable_value(
                    "${system_under_test.custom.1.custom_iperf_vm_ul_network_interface_address.13.ip}"),
                BuiltIn().get_variable_value(
                    "${system_under_test.custom.1.custom_iperf_vm_ul_network_interface_address.14.ip}")
            ],
            'iPerf_VM_UL_Port': BuiltIn().get_variable_value("${system_under_test.custom.1.iPerf_VM_UL_Port}")
        }

    def custom_manage(self):
        if self.launched_by_CloudManager():
            custom_file_found = self.CloudManager_launcher()
        elif self.launched_by_eCLAT():
            custom_file_found = self.eclat_launcher()
        else:
            custom_file_found = self.other_launcher()
        if custom_file_found:
            self.func_create_custom_variable()
        elif self.bfat():
            self.func_create_custom_variable_from_bfat()
        # else:
        #     logger.error("No custom.yaml found.", html=True)


def is_dryrun():
    toto = BuiltIn().get_variable_value("${tl[100]}")
    if toto is not None:
        return True
    return False


if is_dryrun():
    try:
        from mock import MagicMock
    except ImportError:
        from unittest.mock import MagicMock
    tl_name = MagicMock()

    custom = MagicMock()
    netact = MagicMock()
    nsp_nfmp = MagicMock()
    switchdict = MagicMock()
    eclat = MagicMock()
else:
    mgt_custom = nps_syve_custom()
    mgt_custom.custom_manage()
