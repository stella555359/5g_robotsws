#!/bin/python -B
# -*- coding: utf-8 -*-
"""
:copyright: Nokia
:author: Abdrrahmane NEZROUK (Paris Saclay)
:contact: abderrahmane.nezrouk@nokia.com
:maintainer: Abderrahmane Nezrouk (Paris Saclay)
"""

# from taf.config.testline.testline.TestLine import TestLine
import os as os
import random
import time

from ute_common_abstract_core.aliases_registry import aliases_registry
from ute_common_abstract_core.config import Config
from ute_ue.lteue import LteUe
from robot.libraries.BuiltIn import BuiltIn
from robot.api import logger as robot_logger
import logging
from ute_common_abstract_core import logger as core_logger

from .qparser import fileparser, msg_instance
from .android_plugin_patch import android_plugin_patch
from .custom_pm_analyser import custom_pm_analyser
from .known_qualcomm_chipset import QCT_Chipset as QCT_Chipset
import paramiko
import csv


class customDict(object):
    """
    description:
    -----------
        custom dictionary utilities class
        useful functions to verify if dictionary A is implemented in dictionary B
    """

    def __init__(self, seq, parent='', Etree=''):
        self.instanceDict = {}
        self.seq = seq
        self.lines = ''
        self.getDistinctElements(self.seq, parent, Etree)

    def getDistinctElements(self, seq, parent='', Etree=''):
        """helpful recursive function to tranform python dict to string list"""

        if isinstance(seq, dict):
            items = seq.items()
            for v in items:
                if isinstance(v[1], dict):
                    nextparent = "%s%s%s" % (parent, Etree, v[0])
                    self.getDistinctElements(v[1], nextparent, r'[DICT].')
                elif isinstance(v[1], list):
                    nextparent = "%s%s%s" % (parent, Etree, v[0])
                    self.getDistinctElements(v[1], nextparent, r'[LIST].')
                else:
                    line = "%s%s%s= %s" % (parent, Etree, v[0], v[1])
                    self.lines = self.lines + line + '\n'
                    if bool(v[0]):
                        if v[0] in self.instanceDict.keys():
                            if not (line in self.instanceDict[v[0]]):
                                self.instanceDict[v[0]].append(line)
                        else:
                            self.instanceDict.update({v[0]: [line]})
        elif isinstance(seq, list):
            items = seq[:]
            for v in items:
                if isinstance(v, dict):
                    self.getDistinctElements(v, parent, r'[LIST].')
                elif isinstance(v, list):
                    self.getDistinctElements(v, parent, r'[LIST].')
                else:
                    line = "%s%s %s" % (parent, Etree[:-1], v)
                    self.lines = self.lines + line + '\n'
                    nv = parent.split('.')[-1]
                    nv = nv.replace('[LIST]', '')
                    if nv in self.instanceDict.keys():
                        self.instanceDict[nv].append(line)
                    else:
                        self.instanceDict.update({nv: [line]})

    def getDict(self):
        """
        :return:
        python customDict class instance:
        """
        return self.instanceDict

    def mask2dict(self, line):
        """
        helpful function to transform string to python dictionary

        :return
        python dictionary
        """
        pos = [pos for pos, char in enumerate(line) if char == '.']
        if len(pos) > 0:
            nv = line[:pos[0]]
            rline = line[pos[0] + 1:]
            if '[DICT]' in nv:
                return {nv.replace('[DICT]', ''): self.mask2dict(rline)}
            elif '[LIST]' in nv:
                return {nv.replace('[LIST]', ''): [self.mask2dict(rline)]}
        else:
            nv = line.split(' ')
            if len(nv) > 1:
                return {nv[0]: nv[1]}
            else:
                return nv[0]

    def isSubDict(self, input_dic):
        """
        :param input_dic: python dic
        :return:
        Boolean
            return true if the input_dic is implemented to dictionary instance
        """
        for dic in input_dic:
            subDic = customDict(dic).instanceDict
            for key in subDic:
                if key in self.instanceDict.keys():
                    for elm in subDic[key]:
                        for inst in self.instanceDict[key]:
                            if elm in inst:
                                break
                        else:
                            return False
                else:
                    return False
        return True


class custom_robot_keywords(object):
    """
    implemented library for :
        * qmdl patching from ta-ue-android-plugin
        * Ue log collect and parsing
        * pm counter parsing
    """

    __version__ = '1.0.2'

    def __init__(self):
        """Basic initialization."""
        try:
            self.robot_output_dir = BuiltIn().get_variable_value('${OUTPUT DIR}')
        except Exception:
            self.robot_output_dir = '/tmp'
            pass
        self._init_loggers(logger_name='CustomKeysWord', log_filename='Custom_robot_keywords.log')
        self.logger = logging.getLogger('CustomKeysWord')
        self.pm_counter_instance = custom_pm_analyser()
        self._public_pm_counters_methods = self._get_public_method_names(custom_pm_analyser)
        self._keywords = self.get_keyword_names()
        self.qmdl_filter = [1, '0x1FF0', '0x1FFB', '0x1FFC']

    def patch_android_plugin_lib(self):
        """Function to apply android plugin patch intend to specify qcat conversion options."""

        apply_patch_files = android_plugin_patch()
        result = apply_patch_files.patch_android_plugin_lib()
        return (result)

    def patch_qmdl_file(self):
        """Function to apply qmdl patch intend to specify qcat conversion options."""

        apply_patch_files = android_plugin_patch()
        result = apply_patch_files.patch_qmdl_file()
        return (result)

    def patch_Software_file(self):
        """Function to apply selenium coam software patch intend to solve temporary a library bug."""

        apply_patch_files = android_plugin_patch()
        result = apply_patch_files.patch_Software_file()
        return (result)

    def _get_public_method_names(self, obj):
        """
        Abstract function:
        -----------------
        :param
        obj: python object instance class

        :return
        str list
            helpful function to list of public keyword from a defined object
        """
        result = []
        for name in dir(obj):
            if name.startswith('_'):
                continue
            if callable(getattr(obj, name)):
                result.append(name)
        return result

    def get_keyword_names(self):
        """
        Abstract function:
        -----------------

        Returns:
        -------
        str list
            helpful function to list of public keyword name to be used by the library
        """
        keyword_names = [method for method in dir(self) if
                         method[0] != '_' and 'ROBOT' not in method and 'logger' not in method]
        keyword_names.remove('get_keyword_names')
        keyword_names.remove('run_keyword')
        keyword_names.extend(self._public_pm_counters_methods)
        return keyword_names

    def run_keyword(self, name, args, kwargs):
        """
        function to call public robot keywords dynamically.

        :param
        name : str
            The name of the keyword called from robot
        args : str
            arguments passed to the robot keyword
        kwargs : str
            kwargs passed to the robot keyword

        :return
        None
        """
        if name in self._keywords:
            self.logger.info("Running keyword '%s' with arguments %s." % (name, args))
            if name in self._public_pm_counters_methods:
                # fun = setattr(name, *args, **kwargs)
                func = getattr(self.pm_counter_instance, name)
            else:
                func = getattr(self, name)
            return func(*args, **kwargs)

    def _init_loggers(self, logger_name, log_filename):
        """ function to init the library logger"""

        if self.robot_output_dir:
            logfile_full_path = os.path.join(self.robot_output_dir, log_filename)
        else:
            logfile_full_path = os.path.join(core_logger.get_logging_path(), log_filename)
        core_logger.setup_new_file_handler(
            logger_name=logger_name,
            log_level=logging.INFO,
            log_filename=logfile_full_path,
            formatter=logging.Formatter("%(asctime)s %(levelname)-10s %(threadName)-30s: |%(message)s"))

    def _perform_cmd_over_ssh(self, cmd_line, hostname, username, password=None, ssh_key_file_path=None, port=22,
                              timeout=180):
        """
        function to transfer local files to remote host dir using scp

        :param
        hostname : str
            remotes ssh hostname
        username : str
            ssh user name
        password : str
            ssh user password
        cmd_line: str
            cmd line to execute

        :return
        str
            command line response

        :raise
        NotImplementedError
            Raise an error message if any IO error occurred during the transfer process.
        """

        ssh_client = paramiko.SSHClient()
        ssh_client.set_missing_host_key_policy(paramiko.AutoAddPolicy())
        ssh_client.connect(hostname=hostname, port=port, username=username, key_filename=ssh_key_file_path,
                           password=password, look_for_keys=False,
                           banner_timeout=180,
                           timeout=180)
        # BHR begin 06/07/2023 with pyton3, no need to use decode function,it is implicitly done
        # cmd_line = cmd_line.decode("unicode-escape").replace('\\', '/')
        # BHR end
        stdin, stdout, stderr = ssh_client.exec_command(cmd_line, timeout=timeout)
        err = stderr.read()
        result = stdout.read()
        ssh_client.close()
        return err, result

    def _transfer_files_from_local_to_remote_dir(self, local_files, remote_dir, hostname, username, password=None,
                                                 ssh_key_file_path=None, port=22, timeout=30):
        """
        function to transfer local files to remote host dir using scp

        :param
        hostname : str
            remotes ssh hostname
        username : str
            ssh user name
        password : str
            ssh user password
        local_files: str list
            list of the files with path to transfer
        remote_dir: str
            remote directory path

        :return
        str list
            a list of transferred files

        :raise
        NotImplementedError
            Raise an error message if any IO error occurred during the transfer process.
        """
        err = ''
        transferred_files = []
        # convert local_files to list if local_files is a string file path
        if not isinstance(local_files, list):
            local_files = [local_files]
        ssh_client = paramiko.SSHClient()
        ssh_client.set_missing_host_key_policy(paramiko.AutoAddPolicy())
        ssh_client.connect(hostname=hostname, port=port, username=username, key_filename=ssh_key_file_path,
                           password=password, look_for_keys=False,
                           banner_timeout=180,
                           timeout=180)
        sftp = ssh_client.open_sftp()
        for file_path in local_files:
            error = ''
            local_path = file_path.split('/')[-1]
            remote_file_name = os.path.join(remote_dir, local_path)
            try:
                sftp.put(file_path, remote_file_name)
                transferred_files.append(remote_file_name)
            except Exception as exc:  # pylint: disable=broad-except
                error = "{!r}".format(exc)

            if bool(error) and "WARNING" not in error.upper():
                err += ">>> Error while executing:\n" \
                       + "copy " + file_path + " to " + remote_dir \
                       + "\n>>> Returned with error:\n" \
                       + str(error)
        sftp.close()
        ssh_client.close()
        return err, transferred_files

    def _transfer_files_from_remote_to_local_dir(self, remote_files, local_dir, hostname, username, password=None,
                                                 ssh_key_file_path=None, port=22, timeout=30):
        """
        function to transfer local remote host to local dir using scp

        :param
        hostname : str
            remotes ssh hostname
        username : str
            ssh user name
        password : str
            ssh user password
        remote_files: str list
            list of the files with path to transfer
        local_dir: str
            remote directory path

        :return
        str list
            a list of transferred files

        :raise
        NotImplementedError
            Raise an error message if any IO error occurred during the transfer process.
        """
        err = ''
        transferred_files = []
        # convert local_files to list if local_files is a string file path
        if not isinstance(remote_files, list):
            remote_files = [remote_files]
        ssh_client = paramiko.SSHClient()
        ssh_client.set_missing_host_key_policy(paramiko.AutoAddPolicy())
        ssh_client.connect(hostname=hostname, port=port, username=username, key_filename=ssh_key_file_path,
                           password=password, look_for_keys=False,
                           banner_timeout=180,
                           timeout=180)
        sftp = ssh_client.open_sftp()
        for remote_file in remote_files:
            error = ''
            file_name = remote_file.split('/')[-1]
            local_file = os.path.join(local_dir, file_name)
            try:
                sftp.get(remote_file, local_file)
                transferred_files.append(local_file)
            except Exception as exc:  # pylint: disable=broad-except
                error = "{!r}".format(exc)

            if bool(error) and "WARNING" not in error.upper():
                err += ">>> Error while executing:\n" \
                       + "copy " + remote_file + " to " + local_dir \
                       + "\n>>> Returned with error:\n" \
                       + str(error)

        sftp.close()
        ssh_client.close()
        return err, transferred_files

    def _get_ue_config(self, alias):
        """
        Abstract function:
        -----------------
            load ue dictionary definition from yaml file

        :param
        alias: str
            Ue alias
        :return
        None
        """
        alias = alias.upper().replace('_', '')
        abstract_lib_config = os.environ['ABSTRACT_LIB_CONFIG']
        device_configuration = Config().read_yaml_configfile(abstract_lib_config)
        ue_pools = device_configuration['UE_POOLS']['AndroidUePool']['inline_config']
        self.logger.info('ue_pools : '.format(ue_pools))
        for key in ue_pools.keys():
            if key.upper().replace('_', '') in alias:
                return ue_pools[key]
                break

        raise AssertionError('Ue alias : {alias} not defined in Yaml config file'.format(alias))

    # ================================================================================================
    #                                   useful robot keyword functions                               #
    # ================================================================================================

    def run_adb_cmd_on_ue(self, alias, cmd_line, timeout=30):
        """

        :param
        alias: str
            Ue alias
        cmd_line: str
            the adb command to tun on Ue alias
        timeout: integer
            timeout which correspond to execusion ssh command time
        :return:
        str
            err, and the command execusion
        """

        _ue_config = self._get_ue_config(alias)

        ue_sn = _ue_config['CONSTRUCTOR_PARAMETERS']['serial_number']

        cmd = 'adb -s ' + ue_sn + ' shell ' + cmd_line

        self.logger.info("Ue %s cmd line = %s" % (alias, cmd))

        err, result = self._perform_cmd_over_ssh(
            hostname=_ue_config['CONSTRUCTOR_PARAMETERS']['configuration']['ue_pc_ip'],
            username=_ue_config['CONSTRUCTOR_PARAMETERS']['configuration']['login'],
            password=_ue_config['CONSTRUCTOR_PARAMETERS']['configuration']['password'],
            cmd_line=cmd,
            timeout=timeout)
        return err, result

    def run_adb_cmd_noshell_on_ue(self, alias, cmd_line, timeout=30):
        """

        :param
        alias: str
            Ue alias
        cmd_line: str
            the adb command to tun on Ue alias
        timeout: integer
            timeout which correspond to execusion ssh command time
        :return:
        str
            err, and the command execusion
        """

        _ue_config = self._get_ue_config(alias)

        ue_sn = _ue_config['CONSTRUCTOR_PARAMETERS']['serial_number']

        cmd = 'adb -s ' + ue_sn + ' ' + cmd_line

        self.logger.info("Ue %s cmd line = %s" % (alias, cmd))

        err, result = self._perform_cmd_over_ssh(
            hostname=_ue_config['CONSTRUCTOR_PARAMETERS']['configuration']['ue_pc_ip'],
            username=_ue_config['CONSTRUCTOR_PARAMETERS']['configuration']['login'],
            password=_ue_config['CONSTRUCTOR_PARAMETERS']['configuration']['password'],
            cmd_line=cmd,
            timeout=timeout)
        return err, result

    def get_ue_chipset_info(self, alias, timeout=30):
        """

        :param
        alias: str
            Ue alias
        timeout: integer
            timeout which correspond to execusion ssh command time
        :return:
        str
            the type of the qualcomm mobile chipset SDX50, or SDX55 or uknown
            Hardware	: Qualcomm Technologies, Inc SM8150 ==> SDX50 chipset
            Hardware        : Qualcomm Technologies, Inc KONA ==> SDX55 chipset
        """

        _ue_config = self._get_ue_config(alias)

        if 'chipset_NR5G_mode' in _ue_config['CONSTRUCTOR_PARAMETERS']['configuration'].keys():
            return _ue_config['CONSTRUCTOR_PARAMETERS']['configuration']['chipset_NR5G_mode']

        ue_sn = _ue_config['CONSTRUCTOR_PARAMETERS']['serial_number']

        command_line = 'adb -s ' + ue_sn + ' shell cat /proc/cpuinfo | grep -i Hardware'

        err, result = self._perform_cmd_over_ssh(
            hostname=_ue_config['CONSTRUCTOR_PARAMETERS']['configuration']['ue_pc_ip'],
            username=_ue_config['CONSTRUCTOR_PARAMETERS']['configuration']['login'],
            password=_ue_config['CONSTRUCTOR_PARAMETERS']['configuration']['password'],
            cmd_line=command_line,
            timeout=timeout)

        if bool(err) and "WARNING" not in err.upper():
            raise AssertionError(err)

        result = result.split(' ')[-1]
        for key in QCT_Chipset:
            if key in result:
                return QCT_Chipset[key]

        self.logger.info("Ue %s chipset = %s" % (alias, result))
        return "Unknown"

    def get_ue_ipv4_addr(self, alias, network_list=['172'], timeout=30):
        """

        :param
        alias: str
            Ue alias
        timeout: integer
            timeout which correspond to execusion ssh command time
        :return:
        str
            return the ipv4 Ue address
        """

        _ue_config = self._get_ue_config(alias)

        if 'chipset_NR5G_mode' in _ue_config['CONSTRUCTOR_PARAMETERS']['configuration'].keys():
            return _ue_config['CONSTRUCTOR_PARAMETERS']['configuration']['chipset_NR5G_mode']

        ue_sn = _ue_config['CONSTRUCTOR_PARAMETERS']['serial_number']

        # command_line = 'adb -s ' + ue_sn + ' shell ip -4 addr show | grep -oE \"\\b([0-9]{1,3}\.){3}[0-9]{1,3}\\b\"'
        command_line = 'adb -s ' + ue_sn + ' shell ip -4 addr show | grep - oP \"(?<=inet\\s)\\d+(\\.\\d+){3}\"'

        err, result = self._perform_cmd_over_ssh(
            hostname=_ue_config['CONSTRUCTOR_PARAMETERS']['configuration']['ue_pc_ip'],
            username=_ue_config['CONSTRUCTOR_PARAMETERS']['configuration']['login'],
            password=_ue_config['CONSTRUCTOR_PARAMETERS']['configuration']['password'],
            cmd_line=command_line,
            timeout=timeout)

        if bool(err) and "WARNING" not in err.upper():
            raise AssertionError(err)

        ipv4_list = result.split('\n').strip()
        for ipv4 in ipv4_list:
            first_octet = ipv4.split('.')[0]
            if bool(first_octet) and first_octet in network_list:
                self.logger.info("Ue %s ipv4 address = %s" % (alias, ipv4))
                return ipv4
        self.logger.info("Unknown ipv4 adress for Ue %s ipv4 address" % alias)
        return ''

    def get_ue_android_info(self, alias, info_type, timeout=None):
        """
        helpful function to get Ue info
        :parameter
        Ue_alias: str
            alias of the Ue
        info_type: str
            CELL_ID, DEVICE_MODEL, IP, UE_OS_VER, PCI, ANDROID_VER, ENB_ID,
            IMEI, MOBILE_APP_VERSION, MCC, LAC, SIGNAL_STRENGTH, MNC, IMSI
        :return
        str
           return the info type string
        """
        ue = aliases_registry()[alias]
        result = ue.get_info(info_type, timeout)
        self.logger.info("Ue %s has info %s = %s" % (alias, info_type, result))
        return result

    def copy_files_from_uepc_to_local_dir(self, alias, remote_files, local_dir, timeout=20):
        """
        Abstract function:
        ------------------
            transfer files from uepc server to VM local dir

        :parameter
        alias: str
            Ue alias
        remote_files: str list
            list of the files with path to transfer
        local_dir: str
            local directory path

        :return
        str list
            a list of transferred files

        :return
        NotImplementedError
            Raise an error message if any IO error occurred during the transfer process.
        """

        _ue_config = self._get_ue_config(alias)
        self.logger.info(str(_ue_config))

        err, transferred_files = self._transfer_files_from_remote_to_local_dir(
            hostname=_ue_config['CONSTRUCTOR_PARAMETERS']['configuration']['ue_pc_ip'],
            username=_ue_config['CONSTRUCTOR_PARAMETERS']['configuration']['login'],
            password=_ue_config['CONSTRUCTOR_PARAMETERS']['configuration']['password'],
            remote_files=remote_files,
            local_dir=local_dir,
            timeout=timeout)
        return err

    def copy_files_from_local_to_uepc_server_dir(self, alias, local_files, timeout=20):
        """
        Abstract function:
        ------------------
            transfer files from VM to uepc server dir

        :parameter
        alias: str
            Ue alias
        local_files: str list
            list of the files with path to transfer

        :return
        str list
            a list of transferred files

        :raise
        NotImplementedError
            Raise an error message if any IO error occurred during the transfer process.
        """
        _ue_config = self._get_ue_config(alias)
        if isinstance(local_files, str):
            local_files = [].append(local_files)
        # convert local_files to list if local_files is a string file path
        err, transferred_files = self._transfer_files_from_local_to_remote_dir(
            hostname=_ue_config['CONSTRUCTOR_PARAMETERS']['configuration']['ue_pc_ip'],
            username=_ue_config['CONSTRUCTOR_PARAMETERS']['configuration']['login'],
            password=_ue_config['CONSTRUCTOR_PARAMETERS']['configuration']['password'],
            local_files=local_files,
            remote_dir=_ue_config['CONSTRUCTOR_PARAMETERS']['configuration']['server_dir'],
            timeout=timeout)
        return err

    def get_decoded_qmdl_files_path(self, alias, local_dir=None, timeout=480):
        """
        Abstract function:
        ------------------
            function to collect decoded qmdl file

        :parameter
        alias: str list
            Ue alias string

        :return
        str
            local decoded qmdl file path

        :raise
        NotImplementedError
            Raise an error message if any IO error occurred during the collect process.
        """
        _ue_config = self._get_ue_config(alias)
        if alias not in aliases_registry():
            raise AssertionError("Error occurred ! unknown alias")

        ue = aliases_registry()[alias]  # ==> ta_ue_plugin_android.ue.android.android_ue.AndroidUe
        if not isinstance(ue, LteUe):
            raise AssertionError("Error occurred ! alias not a LteUe class")

        remote_decoded_qmdl_file = ue._method_proxy("get_path_to_decoded_qmdl_file")
        remote_decoded_qmdl_file = remote_decoded_qmdl_file.decode("unicode-escape").replace('\\', '/')
        remote_qmdl_file = remote_decoded_qmdl_file.replace('.txt', '.qmdl')
        if not bool(local_dir):
            local_dir = os.path.join(self.robot_output_dir,
                                     time.strftime("%Y-%m-%d--%H-%M-%S") + "_" + str(random.randint(1000, 9000)))
        self.logger.info('local dir: {}'.format(local_dir))
        if not os.path.exists(local_dir):
            os.makedirs(local_dir)
            self.logger.info('Creation of local dir: {}'.format(local_dir))

        err, transferred_files = self._transfer_files_from_remote_to_local_dir(
            hostname=_ue_config['CONSTRUCTOR_PARAMETERS']['configuration']['ue_pc_ip'],
            username=_ue_config['CONSTRUCTOR_PARAMETERS']['configuration']['login'],
            password=_ue_config['CONSTRUCTOR_PARAMETERS']['configuration']['password'],
            remote_files=[remote_decoded_qmdl_file, remote_qmdl_file],
            local_dir=local_dir,
            timeout=timeout)
        if bool(err):
            raise AssertionError(err)

        os.environ['UE_LOG_FILES'] = transferred_files[0]

        return transferred_files[0]

    def is_message_contain_given_key(self, message_instance, key):
        """ function to check if the message contain a given key"""
        if message_instance is not None:
            return bool(key in message_instance)
        return False

    def is_message_contain_given_dic(self, message_instance, dic):
        """ function to check if the message contain a given dict"""
        if message_instance is not None:
            instanceDic = customDict(message_instance.values()[0])
            return instanceDic.isSubDict(dic)
        return False

    def is_message_description_contain(self, message_instance, message_description):
        """  check if message instance contain description """
        if message_instance.description is not None:
            return bool(message_description in message_instance.description)
        return False

    def is_message_subtitle_contain(self, message_instance, message_subtitle):
        """ function to check if the message contain a given subtitle"""
        if message_subtitle == '':
            return True
        if message_instance.subtitle is not None:
            return bool(message_subtitle in message_instance.subtitle)
        return False

    def get_ue_log_file(self):
        ''' function to check and return local decoded qmdl file.'''
        if not bool(os.environ['UE_LOG_FILES']):
            raise AssertionError("Error occurred ! Ue log files are missing")
        elif not os.path.isfile(os.environ['UE_LOG_FILES']):
            raise AssertionError('Error occurred ! {} file is missing'.format(os.environ['UE_LOG_FILES']))

        return os.environ['UE_LOG_FILES']

    def is_ue_log_message_contain(self, mode_description_subtitle, dic, timeout=120):
        """
        Abstract function:
        -----------------
            function to check if the QCT Ue log message contain the following dic value

        Qcat custom filter
                    1 : to exclude.
                    0 : to include.

        :parameter
        mode_description_subtitle : str
            string to define message to check (exp: NR5G:ML1_Searcher_ACQ_Config_And_Response:)
        dic: list of python dictionary
            python dictionary of the message to check (exp: [{'Record': {'Result': 'SUCCESS'}}])

        :return
        boolean
            return boolean true if the message is found or raise en robot error if not found

        :raise
        IOError:
            Raise an error message if any IO error occurred during the execution.
        """

        if not isinstance(dic, list):
            raise AssertionError('Error Occured {} sould be a python list of dictionary'.format(dic))
        else:
            for item in dic:
                if not isinstance(item, dict):
                    raise AssertionError('Error on item {} sould be a python dictionary'.format(item))

        mode, description, subtitle = mode_description_subtitle.split(':')

        self.logger.info('mode: {}, description {}, subtitle {}'.format(mode, description, subtitle))
        self.logger.info('dic: {}'.format(dic))
        if mode is None or description is None:
            raise AssertionError('Error occurred ! Format miss match')

        if mode not in ['LTE', 'NR5G']:
            raise AssertionError('Only LTE ans NR5G call flow are accepted')

        description = description.replace('_', ' ')

        ue_log_file = self.get_ue_log_file()

        try:
            f = open(ue_log_file)
            qcat_list = fileparser(f, self.qmdl_filter)
            for item in qcat_list:
                msgs = msg_instance(item)
                if bool(msgs):
                    for msg_item in msgs:
                        if msg_item.timestamp > timeout:
                            raise AssertionError('No message with dict {} was found'.format(dic))
                        if self.is_message_description_contain(msg_item, description):
                            if self.is_message_subtitle_contain(msg_item, subtitle):
                                if self.is_message_contain_given_dic(msg_item, dic):
                                    f.close()
                                    return None
            f.close()
        except IOError as err:
            raise AssertionError("Error occurred on {} \n\t {}".format(ue_log_file, err.strerror))
        finally:
            pass
        raise AssertionError('No message with dict {} was found'.format(dic))

    def get_all_msg_from_ue_logs(self, mode_id, filename, filter_listDic,
                                 fields_list=None, timeout=5):
        """
        Abstract function:
        -----------------
            function to return all QCT Ue log message contain the following dic value (filter)

        Qcat custom filter
                    1 : to exclude.
                    0 : to include.

        :parameter
        mode_description_subtitle : str
            string to define message to check (exp: NR5G:ML1_Searcher_ACQ_Config_And_Response:)
        dic: list of python dictionary
            python dictionary of the message to check (exp: [{'Record': {'Result': 'SUCCESS'}}])

        :return
        boolean
            return boolean true if the message is found or raise en robot error if not found

        :raise
        IOError:
            Raise an error message if any IO error occurred during the execution.
        """
        if not bool(filename) and not isinstance(filename, str):
            raise AssertionError('Error Occured filename {} param sould be a str python'.format(filename))
        if not bool(fields_list) and not isinstance(fields_list, dict):
            raise AssertionError('Error Occured {} sould be a python dict'.format(fields_list))
        if not isinstance(filter_listDic, list):
            raise AssertionError('Error Occured {} sould be a python list of dictionary'.format(filter_listDic))
        else:
            for item in filter_listDic:
                if not isinstance(item, dict):
                    raise AssertionError('Error on item {} sould be a python dictionary'.format(item))

        mode, id = mode_id.split(':')

        self.logger.info('mode: {}, id {}'.format(mode, id))
        self.logger.info('dic: {}'.format(filter_listDic))
        if mode is None or id is None:
            raise AssertionError('Error occurred ! Format miss match')

        if mode not in ['LTE', 'NR5G']:
            raise AssertionError('Only LTE ans NR5G call flow are accepted')

        ue_log_file = self.get_ue_log_file()
        id = id.strip()
        raise_an_error = True

        try:
            csv_filepath = os.path.join(self.robot_output_dir, filename)
            robot_logger.debug('output %s path : %s' % (filename, csv_filepath))
            with open(csv_filepath, 'w') as csvfile:
                fieldnames = ['msg_id', 'date_time', 'timestamp']
                for key in fields_list.keys():
                    fieldnames.append(key)
                writer = csv.DictWriter(csvfile, fieldnames=fieldnames)
                writer.writeheader()
                f = open(ue_log_file)
                qcat_list = fileparser(f, [0, id])
                for item in qcat_list:
                    msgs = msg_instance(item)
                    if bool(msgs):
                        for msg_item in msgs:
                            if raise_an_error and msg_item.timestamp > timeout:
                                raise AssertionError('No message id: {} with key {} was found'.format(id,
                                                                                                      filter_listDic))
                            if self.is_message_contain_given_dic(msg_item, filter_listDic):
                                raise_an_error = False
                                csv_fields_item = {'msg_id': id,
                                                   'date_time': msg_item.date_time,
                                                   'timestamp': msg_item.timestamp
                                                   }
                                for key in fields_list.keys():
                                    csv_fields_item.update({key: msg_item.get_value_by_unique_key(fields_list[key])})
                                writer.writerow(csv_fields_item)
                f.close()
            return csv_filepath
        except IOError as err:
            raise AssertionError("Error occurred on {} \n\t {}".format(ue_log_file, err.strerror))
        finally:
            pass

    def get_value_from_ue_logs(self, mode_description_subtitle, att, timeout=120):
        """
        Abstract function:
        -----------------
            This function returns the value of key att in message mode_description_subtitle in Ue log file

        Qcat custom filter
                    1 : to exclude.
                    0 : to include.

        :parameter
        mode_description_subtitle : str
            string to define message to check (exp: NR5G:ML1_Searcher_ACQ_Config_And_Response:)
        att: key
            python dictionary of the message to check (ex: SSB ID). Key must be unique in the message.

        :return
            list containing the value matching the key.
            In case the message is present several time in the log, only the value matching the first
            occurence will be reported.
            It is up to the script calling the function to deal with the type of the value, i.e it has to know what
            type it is expecting.

        :raise
        IOError:
            Raise an error message if any IO error occurred during the execution.
        """

        mode, description, subtitle = mode_description_subtitle.split(':')

        self.logger.info('mode: {}, description {}, subtitle {}'.format(mode, description, subtitle))
        self.logger.info('att: {}'.format(att))
        if mode is None or description is None:
            raise AssertionError('Error occurred ! Format miss match')

        if mode not in ['LTE', 'NR5G']:
            raise AssertionError('Only LTE ans NR5G call flow are accepted')

        description = description.replace('_', ' ')

        ue_log_file = self.get_ue_log_file()

        message_list = []
        raise_an_error = True
        try:
            f = open(ue_log_file)
            qcat_list = fileparser(f, self.qmdl_filter)
            for item in qcat_list:
                msgs = msg_instance(item)
                type_msgs = type(msgs)
                if bool(msgs):
                    for msg_item in msgs:
                        if raise_an_error and msg_item.timestamp > timeout:
                            raise AssertionError('No message {} with key {} was found'.format(description, att))
                        if self.is_message_description_contain(msg_item, description):
                            if self.is_message_subtitle_contain(msg_item, subtitle):
                                raise_an_error = False
                                message_list.append(msg_item.get_value_by_unique_key(att))
                                self.logger.info('message_list: {}'.format(message_list))
            f.close()
        except IOError as err:
            raise AssertionError("Error occurred on {} \n\t {}".format(ue_log_file, err.strerror))
        finally:
            pass
        return message_list

    def get_csv_files_from_ue_log(self, csv_filepath, id, mask_list):
        """
        Abstract function:
        -----------------
            function to return all QCT Ue log message contain the following dic value (filter)

        Qcat custom filter
                    1 : to exclude.
                    0 : to include.

        :parameter
        mode_description_subtitle : str
            string to define message to check (exp: NR5G:ML1_Searcher_ACQ_Config_And_Response:)
        dic: list of python dictionary
            python dictionary of the message to check (exp: [{'Record': {'Result': 'SUCCESS'}}])

        :return
        boolean
            return boolean true if the message is found or raise en robot error if not found

        :raise
        IOError:
            Raise an error message if any IO error occurred during the execution.
        """
        idx = [0]
        for x in id.split(':'):
            if bool(x) and x not in idx:
                idx.append((x))
        if not bool(csv_filepath) and not isinstance(csv_filepath, str):
            raise AssertionError('Error Occured csv_filepath {} param sould be a str python'.format(csv_filepath))

        ue_log_file = self.get_ue_log_file()
        fieldnames = ['msg_id', 'date_time', 'timestamp']
        for key, value in mask_list.items():
            x = key.split('.')
            for i in range(0, len(x)):
                if x[i] not in fieldnames:
                    fieldnames.append(x[i])
            for i in range(0, len(value)):
                if value[i] not in fieldnames:
                    fieldnames.append(value[i])
        robot_logger.debug('fieldnames %s' % (fieldnames))
        schemat = self._get_schemat(mask_list.keys())
        try:
            with open(csv_filepath, 'w') as csvfile:
                writer = csv.DictWriter(csvfile, fieldnames=fieldnames)
                writer.writeheader()
                f = open(ue_log_file)
                qcat_list = fileparser(f, idx)
                for item in qcat_list:
                    msgs = msg_instance(item)
                    if bool(msgs):
                        for msg_item in msgs:
                            outputDic = {'msg_id': msg_item.id,
                                         'date_time': msg_item.date_time,
                                         'timestamp': msg_item.timestamp}
                            # robot_logger.debug('msgitem id %s description : %s' % (
                            # msg_item.id, msg_item.description))
                            custDict = customDict(msg_item).getDict()
                            # robot_logger.debug('msg_item : %s' % msg_item)
                            # robot_logger.debug('custDict : %s' % custDict)
                            rows = self._get_dicts_values(mask_list, custDict, schemat)
                            # robot_logger.debug('rows : %s' % rows)
                            for row in rows:
                                newRow = dict(outputDic)
                                newRow.update(row)
                                writer.writerow(newRow)
                f.close()
            return csv_filepath
        except IOError as err:
            raise AssertionError("Error occurred on {} \n\t {}".format(ue_log_file, err.strerror))

    def _get_dicts_values(self, item_list, cDic, schemat):
        '''                             '''
        out_dic = {}  # {k: {} for k in item_list.keys()}
        for k, list in item_list.items():
            # tmp_dic = out_dic[k]
            arr = k.split('.')
            for v in list:
                if v in cDic.keys():
                    lines = cDic[v]
                    for line in lines:
                        dic = {'k_dic': k}
                        dic.update({x: '' for x in arr})
                        dic.update({x: '' for x in list})
                        tab = line.split('.')
                        if len(tab) > len(arr):
                            new_key = ''
                            for i in range(0, len(arr)):
                                if arr[i] in tab[i]:
                                    item = tab[i].replace('[LIST]', '').replace('[DICT]', '')
                                    if bool(new_key):
                                        new_key += '.' + item
                                    else:
                                        new_key = item
                                    dic[arr[i]] = item
                            dic[v] = line.split('=')[1].strip()
                            if new_key not in out_dic:
                                out_dic.update({new_key: dic})
                            else:
                                for nk, nv in out_dic[new_key].items():
                                    if bool(dic[nk]):
                                        out_dic[new_key].update({nk: dic[nk]})
        rows = []
        k_list = []
        for key, value in out_dic.items():
            row = dict(value)
            for k, v_list in schemat.items():
                if k in value['k_dic']:
                    for item_key in v_list:
                        for key_sub, value_sub in out_dic.items():
                            if item_key == value_sub['k_dic'] and key_sub in key:
                                row.update(value_sub)
                    del row['k_dic']
                    rows.append(row)

                else:
                    for item_key in v_list:
                        k_list.append(item_key)
        # for key, row in out_dic.items():
        #     if row['k_dic'] in k_list:
        #         del row['k_dic']
        #         rows.append(row)
        return rows

    def _get_schemat(self, keys_list):
        schemat = {x: [] for x in keys_list}
        keys_to_remove = []
        for x in keys_list:
            list_x = x.split('.')
            for y in keys_list:
                list_y = y.split('.')
                inc = 1
                if len(list_x) < len(list_y):
                    for i in range(0, len(list_x)):
                        if list_x[i] not in list_y[i]:
                            inc = 0
                            break
                    if bool(inc):
                        schemat[y].append(x)
                        if x not in keys_to_remove:
                            keys_to_remove.append(x)
        for k in keys_to_remove:
            del schemat[k]
        for k in schemat.keys():
            schemat[k] = sorted(schemat[k])

        return schemat

    def _get_all_values(self, keys_list, cDic):
        row = {k: '' for k in keys_list}
        rows = []
        for k in keys_list:
            line = ''
            if k in cDic.keys():
                for item in cDic[k]:
                    value_list = item.split('=')
                    if len(value_list) > 1:
                        line += value_list[1].strip() + '|'
                line = line[:-1] if bool(line) else line
                row[k] = line
        rows.append(row)
        return rows

    def get_csv_file_rrc_log_ue(self, filename, id, key_fiealds):
        """
        Abstract function:
        -----------------

        Qcat custom filter
                    1 : to exclude.
                    0 : to include.

        :parameter
        filename : str
            string which represent the name of the csv file to generate
        id : str
            string list to define Qcat message id to check (exp: 0xBC0C0)
        key_fiealds: list of string
            python list of fields name to collect

        :return
        String
            return absolute file path

        :raise
        IOError:
            Raise an error message if any IO error occurred during the execution.
        """
        idx = [0]
        for x in id.split(':'):
            if bool(x) and x not in idx:
                idx.append((x))
        if not bool(filename) and not isinstance(filename, str):
            raise AssertionError('Error Occured filename {} param sould be a str python'.format(filename))

        ue_log_file = self.get_ue_log_file()
        fieldnames = ['msg_id', 'date_time', 'timestamp', 'description', 'subtitle', 'message']
        for key in key_fiealds:
            if key not in fieldnames:
                fieldnames.append(key)
        robot_logger.debug('fieldnames %s' % (fieldnames))
        # schemat = self._get_schemat(mask_list.keys())
        try:
            csv_filepath = os.path.join(self.robot_output_dir, filename)
            robot_logger.debug('output %s path : %s' % (filename, csv_filepath))
            with open(csv_filepath, 'w') as csvfile:
                writer = csv.DictWriter(csvfile, fieldnames=fieldnames)
                writer.writeheader()
                f = open(ue_log_file)
                qcat_list = fileparser(f, idx)
                for item in qcat_list:
                    msgs = msg_instance(item)
                    if bool(msgs):
                        for msg_item in msgs:
                            outputDic = {'msg_id': msg_item.id,
                                         'date_time': msg_item.date_time,
                                         'timestamp': msg_item.timestamp,
                                         'description': msg_item.description,
                                         'subtitle': msg_item.subtitle,
                                         'message': msg_item.keys()[0]}
                            # robot_logger.debug('msgitem id %s description : %s  value %s' % (
                            #     msg_item.id, msg_item.description, msg_item.keys()[0]))

                            custDict = customDict(msg_item).getDict()
                            robot_logger.debug('msg_item : %s' % msg_item)
                            robot_logger.debug('custDict : %s' % custDict)
                            rows = self._get_all_values(key_fiealds, custDict)
                            robot_logger.debug('rows : %s' % rows)
                            for row in rows:
                                newRow = dict(outputDic)
                                newRow.update(row)
                                writer.writerow(newRow)
                f.close()
            return csv_filepath
        except IOError as err:
            raise AssertionError("Error occurred on {} \n\t {}".format(ue_log_file, err.strerror))
