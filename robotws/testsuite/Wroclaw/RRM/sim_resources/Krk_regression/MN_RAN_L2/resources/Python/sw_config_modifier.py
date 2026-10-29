"""
:copyright: Nokia Networks
:author: Marek Piotrowski
:contact: marek.piotrowski@nokia.com
:team: I_5G_SW_MMW_PLKRK_04
:email: I_5G_SW_MMW_PLKRK_04 <I_5G_SW_MMW_PLKRK_04@nokia.com>
:description:
"""

import re
import paramiko

from robot.api import logger
from robot.libraries.BuiltIn import BuiltIn
from ta5g_enb.html_method_logger import log_method_name
from common_gnb import reset_units_and_wait_for_radio_head_online


class SwConfigModifier(object):
    """
    Class for sharing kw to copy(or download), modify and install swconfig on AP/GNB
    """

    @log_method_name
    def add_flags_to_swconfig(self, flags, filepath='GNB', host='', nokia_login='', nokia_pass='',
                              local_swconfig_path='/tmp/swconfig.txt', reboot=True, **kwargs):
        """
            Function responsible to add given flags to swconfig file. If particular flags exists, but has different
            value, it should ve added with new value once again. It cause loading the last value by gNB.

        :param flags: dict, e.g. {'0x1234': 1, '0x234': '2', ...}, both str and int are supported as value
        :param filepath: str, path to swconfig file. Put 'GNB' or 'AP' to modify file on unit
        :param host: gNB or AP IP
        :param nokia_login: host login
        :param nokia_pass: host password
        :param local_swconfig_path: Local path to downloaded swconfig.txt file
        :param reboot: bool, True if unit should reboot after swconfig file changing to activate, otherwise False
        :return:
        """
        if not host or not nokia_login or not nokia_pass:
            host, nokia_login, nokia_pass = self._get_connection_credentials(filepath)
        if filepath.upper() in ['GNB', 'AP']:
            ssh = paramiko.SSHClient()
            ssh.set_missing_host_key_policy(paramiko.AutoAddPolicy())
            try:
                ssh.connect(hostname=host, username=nokia_login, password=nokia_pass)
                sftp = ssh.open_sftp()
                sftp.get(remotepath='/rom/swconfig.txt', localpath=local_swconfig_path)
                with open(local_swconfig_path, 'r+') as local_file:
                    file_modified = self._modify_swconfig_file_obj(local_file, flags)
                    if file_modified:
                        local_file.flush()
                        sftp.put(localpath=local_swconfig_path, remotepath='/rom/swconfig.txt')
                        ssh.exec_command('crasign /rom/swconfig.txt')
                sftp.close()
            finally:
                ssh.close()
            if reboot:
                reset_units_and_wait_for_radio_head_online(**kwargs)
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

    @staticmethod
    def _get_connection_credentials(remote):
        """
        :param remote: (str) 'GNB' or 'AP'
        """

        host = BuiltIn().get_variable_value('${' + remote.upper() + '_IP}')
        login = BuiltIn().get_variable_value('${NOKIA_USERNAME}')
        password = BuiltIn().get_variable_value('${NOKIA_PASS}')
        return host, login, password

    def activate_l2_ps_debug_logging(self, host='192.168.255.1', nokia_login=None, nokia_pass=None, **kwargs):
        """
        Configure feature flags to enable L2PS and Cplane debug logging.
        """

        if not host or not nokia_login or not nokia_pass:
            host, nokia_login, nokia_pass = self._get_connection_credentials('GNB')
        swconfig_flags = {
            '0x58057a': '0x4', '0x58057b': '0x404001', '0x58057c': '0x800000', '0x58057d': '0x80600001',
            '0x600006': '1', '0x450027': '1', '0x580117': '3', '0x580627': '1', '0x1003F': '1', '0x10040': '1',
            '0x10041': '1', '0x590072': '1', '0x66001b': '1', '0x890001': '1', '0x890002': '1', '0x890003': '1',
            '0x890004': '1', '0x890005': '1', '0x890006': '1'
        }
        self.add_flags_to_swconfig(
            flags=swconfig_flags,
            host=host,
            nokia_login=nokia_login,
            nokia_pass=nokia_pass,
            **kwargs
        )
