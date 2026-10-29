"""
:copyright: Nokia Networks
:author: Gall Anonim
:maintainer: Mateusz Bilewicz
:contact: mateusz.bilewicz@nokia.com
:team: MN_RAN_L2_SW_WRO_7_SG
"""

import paramiko
from robot.api import logger
from ta5g_enb.html_method_logger import log_method_name
from testsuite.Wroclaw.RRM.VRF_WRO1_T04.L2PS_WRO.resources.Python.common_gnb import run_on_gnb, run_on_ap, handle_admin
import re


class SwConfigModifier(object):
    """
    Class for sharing kw to copy(or download), modify and install swconfig on AP/GNB
    """
    @log_method_name
    def get_AP_version(self, ap_ip, nokia_login, nokia_pass):
        """
        :return: e.g. '4.0.14972'
        """
        logger.info('download_sw_config - debug 1.1')
        cmd = 'ls -la /rom/TargetBD*xml'
        output = run_on_ap(hostname=ap_ip, username=nokia_login, password=nokia_pass, cmd=cmd)
        logger.info('download_sw_config - debug 1.2: {}\n{}\n{}\n{}'.format(output[1], ap_ip, nokia_login, nokia_pass))
        ver = output[1].split('_', 1)[1].split('.')[0]
        logger.info('download_sw_config - debug 1.3: {}'.format(ver))
        ver_short = self._convert_to_short_ver(ver)
        logger.info('download_sw_config - debug 1.4: {}'.format(ver_short))
        return ver_short

    @classmethod
    @log_method_name
    def _convert_to_short_ver(cls, ver_long, stream=False):
        """

        :param ver_long: e.g. 5G_GNB_0004_000000_014972.
        :param stream: True or False, if false return e.g. 4.0.14972 , if True - e.g. 5G20B_10.1800
        :return: e.g. 4.0.14972
        """
        ver_split = ver_long.split('_')
        if stream is True:
            c0 = ver_split[0]
            c2 = ver_split[2].lstrip('0')
            if not c2:
                c2 = '0'
            c3 = ver_split[3].lstrip('0')
            if not c3:
                c3 = '0'
            ver_short = c0 + '_' + c2 + '.' + c3
        else:
            c2 = ver_split[2].lstrip('0')
            if not c2:
                c2 = '0'
            c3 = ver_split[3].lstrip('0')
            if not c3:
                c3 = '0'
            c4 = ver_split[4].lstrip('0')
            if not c4:
                c4 = '0'
            ver_short = c2 + '.' + c3 + '.' + c4
        return ver_short

    @log_method_name
    def get_stream(self, gnb_ip, nokia_login, nokia_pass):
        """
        :return: gNb build name in format: e.g. '5G20B_10.1800'
        """
        cmd = 'ls -la /rom/TargetBD*xml'
        output = run_on_gnb(hostname=gnb_ip, username=nokia_login, password=nokia_pass, cmd=cmd)
        ver = output[1].split('_', 1)[1].split('.')[0]
        ver_short = self._convert_to_short_ver(ver, stream=True)
        return ver_short

    @log_method_name
    def get_implementation(self, gnb_ip, nokia_login, nokia_pass):
        """
        :return: str 'l1b' or 'fs' depending on the configuration
        """
        cmd = 'cat /tmp/rat_psconfig.xml | grep L1BypassMap'
        output = run_on_gnb(hostname=gnb_ip, username=nokia_login, password=nokia_pass, cmd=cmd)
        if len(output[1]):
            return 'l1b'
        else:
            return 'fs'

    @staticmethod
    @log_method_name
    def get_setup_information():
        obj = SwConfigModifier()
        setup_info = {
            "unit_name": obj.get_capability_unit_name(),
            "fbb_info": "",
            "technology": obj.get_duplex(),
            "cell_type": obj.get_gnb_type(),
            "band": obj.get_gnb_band()
        }
        logger.info("unit_name: {}".format(setup_info["unit_name"]))
        if "ASOE" not in setup_info["unit_name"]:
            setup_info["fbb_info"] = obj.get_fbb_info()
            logger.info("fbb_info: {}".format(setup_info["fbb_info"]))
        elif "ASOE" in setup_info["unit_name"]:
            setup_info["fbb_info"] = "ASOE"
        else:
            setup_info["fbb_info"] = "Unknown"

        logger.info("cell_type: {}".format(setup_info["cell_type"]))

        logger.info("technology".format(setup_info["technology"]))

        return setup_info

    @staticmethod
    @handle_admin
    @log_method_name
    def get_duplex(*args, **kwargs):
        """
        :return: str 'TDD' or 'FDD' depending on the configuration
        """
        out = kwargs["connection"].get_cells_info()
        duplex = out[0]['technology']
        return duplex

    @staticmethod
    @handle_admin
    @log_method_name
    def get_capability_unit_name(*args, **kwargs):
        """
        :return: str 'ASIK' or 'ASIB' depending on the configuration
        """
        out = kwargs["connection"].get_detected_hw_info(timeout=60)

        out_systemModules = out['systemModules']
        dict_out_systemModules = dict(out_systemModules[0])
        unit_name_tmp = dict_out_systemModules['productName']
        unit_name = unit_name_tmp[:4:]
        return unit_name

    @staticmethod
    @handle_admin
    @log_method_name
    def get_gnb_band(*args, **kwargs):
        """
        :return: str 'n78' or 'n71' depending on the band configurtion on first cell
        """
        result = kwargs["connection"].get_cells_info()
        return result[0]["band"]

    @staticmethod
    @handle_admin
    @log_method_name
    def get_fbb_info(*args, **kwargs):
        """
        :return: str 'ABIL' or 'ABIO' depending on the configuration
        """
        out = kwargs["connection"].get_fbb_info()
        fbb_info_out = out[0]['productName']
        fbb_info = fbb_info_out[:4:]
        return fbb_info

    @staticmethod
    @handle_admin
    @log_method_name
    def get_gnb_type(*args, **kwargs):
        """
        :return: str 'SA' or 'NSA' depending on the configuration
        """
        out = kwargs["connection"].get_cells_info()
        type = out[0]['cellDepType']
        type = type.replace("+", "")
        return type

    @staticmethod
    @log_method_name
    def get_wavelength_type():
        """
        :return:
        """
        # TODO
        return 'cmwv'

    @log_method_name
    def add_flags_to_swconfig(self, flags, filepath='GNB', host='', nokia_login='', nokia_pass='', reboot=True):
        """
            Function responsible to add given flags to swconfig file. If particular flags exists, but has different
            value, it should ve added with new value once again. It cause loading the last value by gNB.

        :param flags: dict, e.g. {'0x1234': 1, '0x234': '2', ...}, both str and int are supported as value
        :param filepath: str, path to swconfig file. Put 'GNB' or 'AP' to modify file on unit
        :param host: gNB or AP IP
        :param nokia_login: host login
        :param nokia_pass: host password
        :param reboot: bool, True if unit should reboot after swconfig file changing to activate, otherwise False
        :return:
        """
        if filepath.upper() in ['GNB', 'AP']:
            ssh = paramiko.SSHClient()
            ssh.set_missing_host_key_policy(paramiko.AutoAddPolicy())
            try:
                logger.info('SSH connecting to {}'.format(host))
                ssh.connect(hostname=host, username=nokia_login, password=nokia_pass)
                ssh.exec_command('cp /rom/swconfig.txt /rom/swconfig.txt_backup')
                sftp_client = ssh.open_sftp()
                remote_file = sftp_client.file('/rom/swconfig.txt', 'r+')

                try:
                    mod = self._modify_swconfig_file_obj(remote_file, flags)
                    if mod:
                        # TODO: below command could be used in the future, don't delete
                        # cmd = r'cd /rom; tr < swconfig.txt -d "\000" > swconfig2.txt;' + \
                        #       'mv swconfig2.txt swconfig.txt;' + \
                        #       ' crasign swconfig.txt'
                        remote_file.flush()
                        ssh.exec_command('crasign /rom/swconfig.txt')
                except Exception:
                    remote_file.close()
                    ssh.exec_command('mv /rom/swconfig.txt_backup /rom/swconfig.txt')
                    raise
                finally:
                    remote_file.close()

                if reboot:
                    ssh.exec_command('sync; reboot')

            finally:
                ssh.close()

        else:
            with open(filepath, 'r+') as file_object:
                self._modify_swconfig_file_obj(file_object, flags)

    @log_method_name
    def _modify_swconfig_file_obj(self, file_obj, flags):
        """

        :param file_obj: object file
        :param flags: dict,
        :return: True if file modified, if not - False
        """
        modified = False
        flags_file = self._parse_to_dict(file_obj)
        content = file_obj.readlines()
        if '\n' not in content[-1]:
            content[-1] += '\n'
        for k, v in flags.items():
            line = '{}={}\n'.format(k, v)
            if k not in flags_file:
                content.append(line)
                modified = True
                logger.info('Append to swconfig.txt: {}'.format(line))
            elif flags_file[k] != str(v):
                for i in range(len(content)):
                    if k in content[i] and '=' + str(v) not in content[i].strip():
                        content[i] = '# ' + content[i]
                        content.append(line)
                        modified = True
                        logger.info('Append to swconfig.txt: {}'.format(line))
        if modified:
            file_obj.truncate(0)
            file_obj.seek(0)
            file_obj.writelines(content)
            return True
        return False

    @staticmethod
    @log_method_name
    def _parse_to_dict(file_obj):
        """

        :param file_obj: object file
        :return: dict,
        """
        dictionary = {}
        content = file_obj.readlines()
        file_obj.seek(0)
        for i in content:
            if len(i.strip()) and i.strip()[0] is not '#':  # remove blank and commented lines
                try:
                    flag = re.search(r'\w+=\d+', i.replace(' ', '')).group()
                    flag_nr = flag.split('=')[0]
                    flag_val = flag.split('=')[1]
                    dictionary.update({flag_nr: flag_val})
                except Exception:
                    pass
        if len(dictionary):
            return dictionary
        else:
            raise Exception('Not found any swconfig flag in file!')
