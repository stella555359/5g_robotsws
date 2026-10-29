# -*- coding: utf-8 -*-
"""
:copyright: Nokia Networks
:author: larry.ling@nokia-sbell.com
:contact: larry.ling@nokia-sbell.com
"""
import os
import re
from glob import iglob
from os import path, listdir, walk
import logging
from robot.api import logger as robot_logger

import datetime
from ftplib import FTP, error_perm

import paramiko
# from hran_ssh import hran_ssh
from SSHExecutor import SSHExecutor

import zipfile
from lxml import etree


class oam_file_operations(object):
    """
    File operations relate which is substitute of hran_file_operations

    """

    @staticmethod
    def get_all_files_from_dir(dir, subdir=False):
        """
        Keyword for getting list of all files in given directory

        | **Author:** michal.kwasniewicz@nokia.com
        | **Maintainer:** michal.kwasniewicz@nokia.com
        | **Released with version:** ---

        **Input Parameters:**

        +--------------------+--------+---------------------------------------+
        | Input Parameters   | Man.   | Description                           |
        +====================+========+=======================================+
        | dir                | Yes    | Path to directory                     |
        +--------------------+--------+---------------------------------------+
        | subdir             | No     | Flag determines if entries from       |
        |                    |        | subdirectories should be              |
        |                    |        | listed as well                        |
        +--------------------+--------+---------------------------------------+

        **Minimal example:**

        .. code-block:: robotframework

           Get all files from dir  /home/ute/

        **Extended example (including files in all subdirectories):**

        .. code-block:: robotframework

           Get all files from dir  dir=/home/ute/  subdir=True
        """
        if subdir:
            return [path.join(d, filename) for d, subdirs, files in
                    walk(dir) for filename in files]
        return listdir(dir)

    @staticmethod
    def get_newest_file_from_directory(path_to_search, pattern):
        """
        Keyword for getting path to the last
        modified file from specified directory

        | **Author:** tomasz.1.filipek@nokia.com
        | **Maintainer:** tomasz.1.filipek@nokia.com
        | **Released with version:** ---

        **Input Parameters:**

        +--------------------+--------+----------------------------+
        | Input Parameters   | Man.   | Description                |
        +====================+========+============================+
        | path_to_search     | Yes    | path to directory to check |
        +--------------------+--------+----------------------------+
        | pattern            | Yes    | pattern for filename       |
        +--------------------+--------+----------------------------+

        **Example:**

        .. code-block:: robotframework

           Get newest file from directory  path_to_search=/home/ute/  pattern=*
        """
        return max(iglob(path.join(path_to_search, pattern)),
                   key=path.getmtime)

    @staticmethod
    def parse_files_list(all_files, search_pattern):
        """
        Keyword for filtering list of files
        by matching it against given search_pattern

        | **Author:** michal.kwasniewicz@nokia.com
        | **Maintainer:** michal.kwasniewicz@nokia.com
        | **Released with version:** ---

        | **Full description:**
        | Function gets list of files and returns
        | list of tuples with found matches

        **Input Parameters:**

        +--------------------+--------+---------------------------------------+
        | Input Parameters   | Man.   | Description                           |
        +====================+========+=======================================+
        | all_files          | Yes    | List of files to parse                |
        +--------------------+--------+---------------------------------------+
        | search_pattern     | Yes    | Regexp pattern to be used for parsing |
        +--------------------+--------+---------------------------------------+

        **Example:**

        .. code-block:: robotframework

           ${files_list}=  create list  filename1.txt
           ...  filename2.txt  filename3.txt
           Parse files list  all_files=${files_list}   pattern=filename\\d.txt

        **Return value:**
        List containing tuples with files names
        and tuples containing matched regexp groups
        """
        found_files = []
        compiled_pattern = re.compile(search_pattern)
        logging.info(search_pattern)
        for f in all_files:
            m = compiled_pattern.search(f)
            if m:
                found_file = (m.group(0), m.groups())
                found_files.append(found_file)
        return found_files

    @staticmethod
    def filter_files_list(files_list, filter_pattern):
        """
        Keyword for filtering list of files
        by matching it against given search_pattern


        | **Author:** michal.kwasniewicz@nokia.com
        | **Maintainer:** michal.kwasniewicz@nokia.com
        | **Released with version:** ---

        | **Full description:**
        | Function filters given list of files and
        | list of files which match given pattern

        **Input Parameters:**

        +--------------------+--------+---------------------------------------+
        | Input Parameters   | Man.   | Description                           |
        +====================+========+=======================================+
        | files_list         | Yes    | List of files to be filtered          |
        +--------------------+--------+---------------------------------------+
        | filter_pattern     | Yes    | regexp pattern against which          |
        |                    |        | files should be filtered              |
        +--------------------+--------+---------------------------------------+

        **Example:**

        .. code-block:: robotframework

           ${files_list}=  create list  filename1.txt
           ...  filename2.txt  filename3.txt
           Filter files list  files_list=${files_list}
           ...  filter pattern=filename\\d.txt


        **Return value:**
        Filtered files list
        """
        return [x[0] for x in
                oam_file_operations.parse_files_list(files_list, filter_pattern)]

    def Rah_Set_Connection_Parameters(self, target_path='', target_ip='',
                                      target_username='', target_password='', destination_directory=''):
        logging.info('Nothing done by rah_set_connection_parameters :)')
        pass

    def setup_scfc_parser(self, scfc, parser_technology, from_string=False,
                          alias="default", logger=None):
        """
        Keyword for setting scfc parser.

        | **Author:** damian.skrzypczak@nokia.com
        | **Maintainer:** marcin.wieliczko@nokia.com
        | **Released with version:** ---

        | **Full description:**
        | Setup scfc parser for given scfc file path and technology
        | for more than one scfc parser working at the time,
        | use "alias" system.

        **Input Parameters:**

        +--------------------+--------+---------------------------------------+
        | Input Parameters   | Man.   | Description                           |
        +====================+========+=======================================+
        | scfc               | Yes    | SCFC name/path or file object or      |
        |                    |        | a URL using the HTTP or FTP protocol  |
        +--------------------+--------+---------------------------------------+
        | parser_technology  | Yes    | Parser supported technology -         |
        |                    |        | available: WCDMA/SBTS/LTE/UNIVERSAL   |
        +--------------------+--------+---------------------------------------+
        | from_string        | No     | If given, "scfc" parameter will be    |
        |                    |        | threaten as string                    |
        +--------------------+--------+---------------------------------------+
        | alias              | No     | Optional alias for chosen parser,     |
        |                    |        | useful when more than one             |
        |                    |        | parser is used                        |
        +--------------------+--------+---------------------------------------+
        | logger             | No     | Optional logger, default is           |
        |                    |        | robot.api.logger                      |
        +--------------------+--------+---------------------------------------+

        **Example:**

        .. code-block:: robotframework

           Setup scfc parser  /home/some/path/lte_scfc.xml  LTE

        | **Return values:**
        | True when PASS
        | False when FAIL
        """
        self.logger = robot_logger
        self.logger = logger or self.logger
        try:
            self.technology = parser_technology
            self.scf_file = scfc
            f = open(scfc, 'r')
            self.scf = f.read()
            return True
        except IOError:
            self.logger.error(
                ("SCF Parser did not start because "
                 "there is no appropriate SCF under {}").format(scfc)
            )
            return False
        except Exception as e:
            self.logger.error(
                "{} Parser failed with error {}".format(parser_technology, e))
            return False

    def get_system_modules(self, alias="default"):
        return self.get_managed_object_from_scf(self.scf_file, 'com.nokia.srbts.eqm:SMOD')
        pass

    def get_managed_object_from_scf(self, scf_file, managed_object_class):
        """
        Keyword for get get_managed_object_from_scf.

        | **Author:**
        | **Maintainer:**
        | **Released with version:** ---

        | **Full description:**
        | Get all object of target managed object class
        | return the list of object contains it's parameters and dist name in an dic
        |

        **Input Parameters:**

        +--------------------+--------+---------------------------------------+
        | Input Parameters   | Man.   | Description                           |
        +====================+========+=======================================+
        | scf_file           | Yes    | SCF file path                         |
        |                    |        |                                       |
        +--------------------+--------+---------------------------------------+
        |managed_object_class| Yes    | Managed objectclass in scf.           |
        |                    |        | eg: for SMOD com.nokia.srbts.eqm:SMOD |
        +--------------------+--------+---------------------------------------+

        **Example:**

        .. code-block:: robotframework

           Get Managed Object From Scf  /home/some/path/lte_scfc.xml  com.nokia.srbts.eqm:SMOD

        | **Return values:**
        | list of dic which contains keys of distName and it's paras
        """
        tree = etree.parse(self.scf_file)
        root = tree.getroot()
        mods = []
        for r in root:
            # print(r.tag)
            # for i in r.getchildren():
            for mo in r:
                # print(mo.tag)
                if 'managedObject' not in mo.tag:
                    continue
                # print(mo.get('class'))
                if managed_object_class == mo.get('class'):
                    print(mo.get('class'))
                    mod = {'distName': mo.get('distName')}
                    for p in mo:
                        mod.update({p.get('name'): p.text})
                        # print(p.get('name'))
                        # print(p.text)
                    mods.append(mod)
                    pass
        return mods

    def get_radios(self, alias="default"):
        return self.get_managed_object_from_scf(self.scf_file, 'com.nokia.srbts.eqm:RMOD')

    def get_cells_count(self, technology="", alias="default"):

        """
        Keyword for get get_cells_count.

        | **Author:**
        | **Maintainer:**
        | **Released with version:** ---

        | **Full description:**
        | Get count of cell

        **Input Parameters:**

        +--------------------+--------+---------------------------------------+
        | Input Parameters   | Man.   | Description                           |
        +====================+========+=======================================+
        | technology         | No     | one of GSM/WCDMA/LTE/5G/NR/NB-IOT in  |
        |                    |        | string. If technology=LTE, it will    |
        |                    |        | return all LTE cell include nb-iot    |
        |                    |        | cells.                                |
        +--------------------+--------+---------------------------------------+

        **Example:**

        .. code-block:: robotframework

           Get Cells Count  technology=LTE

        | **Return values:**
        | Count of target cell
        """

        technology = str(technology)

        if technology == 'GSM':
            return len(self.get_managed_object_from_scf(self.scf_file, 'com.nokia.srbts.gsm:GNCEL'))

        elif technology == 'WCDMA':
            return len(self.get_managed_object_from_scf(self.scf_file, 'com.nokia.srbts.wcdma:WNCEL'))

        elif technology == 'LTE':
            return len(self.get_managed_object_from_scf(self.scf_file, 'NOKLTE:LNCEL'))

        elif technology == '5G' or technology == 'NR':
            # pattern = 'distName="[^"]+NRCELL-\\d+"'
            return len(self.get_managed_object_from_scf(self.scf_file, 'com.nokia.srbts.nrbts:NRCELL'))

        elif technology == 'NB-IOT':
            lte_cells = self.get_managed_object_from_scf(self.scf_file, 'NOKLTE:LNCEL')
            nb_cells = []
            for cell in lte_cells:
                if cell['cellTechnology'] == 'NB-IoT-FDD':
                    nb_cells.append(cell)
            return len(nb_cells)

        elif technology == '':
            count = self.get_cells_count('GSM') + self.get_cells_count('WCDMA') \
                    + self.get_cells_count('LTE') + self.get_cells_count('NR')
            return count

        else:
            raise Exception('Unkown technology ' + technology
                            + '. Technology should be string of GSM/WCDMA/LTE/5G/NR/NB-IOT.')

    def teardown_scfc_parser(self, alias="default"):
        """
        Keyword for removing scfc parser.

        | **Author:** damian.skrzypczak@nokia.com
        | **Maintainer:** marcin.wieliczko@nokia.com
        | **Released with version:** ---

        | **Full description:**
        | Shutdown scfc parser

        **Input Parameters:**

        +--------------------+--------+---------------------------------------+
        | Input Parameters   | Man.   | Description                           |
        +====================+========+=======================================+
        | alias              | No     | If given, parser under                |
        |                    |        | alias will be used                    |
        +--------------------+--------+---------------------------------------+

        **Example:**

        .. code-block:: robotframework

           Teardown scfc parser
        """
        logging.info('Nothing done by teardown_scfc_parser :)')

    def get_file_from_system_module(self,
                                    target_ip='192.168.255.129',
                                    target_username='toor4nsn',
                                    target_password='oZPS0POrRieRtu',
                                    source_path='',
                                    destination_path='./',
                                    via_ip='',
                                    via_username='ute',
                                    via_password='ute'):
        """
        Keyword from getting file from master
        system module with optional mediator.

        | **Author:** damian.skrzypczak@nokia.com
        | **Maintainer:** damian.skrzypczak@nokia.com
        | **Released with version:** ---

        | **Full description:**
        | Function downloading file via FTP
        | from System Module(connected directly to VM or through another VM)
        | to desirable directory

        **Input Parameters:**

        +-----------------------+--------+------------------------------------+
        | Input Parameters      | Man.   | Description                        |
        +=======================+========+====================================+
        | source_path           | No     | full path to file on system module |
        +-----------------------+--------+------------------------------------+
        | target_ip             | No     | ip of target system module,        |
        |                       |        | that contains desirable file       |
        +-----------------------+--------+------------------------------------+
        | target_username       | No     | username/login for target          |
        |                       |        | system module,                     |
        +-----------------------+--------+------------------------------------+
        | target_password       | No     | password for target                |
        |                       |        | system module,                     |
        +-----------------------+--------+------------------------------------+
        | via_ip                | No     | ip for middle-handler              |
        |                       |        | VM for connection and downloading  |
        +-----------------------+--------+------------------------------------+
        | via_username          | No     | username/login for middle-handler  |
        |                       |        | VM for connection and downloading  |
        +-----------------------+--------+------------------------------------+
        | via_password          | No     | password for middle-handler VM     |
        |                       |        | for connection and downloading     |
        +-----------------------+--------+------------------------------------+
        | destination_directory | No     | destination directory for where    |
        |                       |        | file will be delivered, default=./ |
        +-----------------------+--------+------------------------------------+

        **Example:**

        .. code-block:: robotframework

           ${some_logs_local_path}=  Get file from system module
           ...  source_path=/home/ute/logs/some_log.txt
           ...  destination_path./some_log.txt
           ...  target_username=XX  target_password=XX  target_ip=X.X.X.X
           ...  via_username=YY  via_password=YY  via_ip=Y.Y.Y.Y

        | **Return value:**
        | path of local file copy
        """
        return FileGetter().get_file_from_smod(
            target_ip=target_ip,
            target_username=target_username,
            target_password=target_password,

            source_path=source_path,
            destination_path=destination_path,

            via_ip=via_ip,
            via_username=via_username,
            via_password=via_password
        )

        pass

    def get_targetbd_node_attribute_value(self, node_name, path):
        return SWPackage().get_targetbd_node_attribute_value(node_name, path)
        pass


class SimpleFileGetter(object):
    """

    """

    @staticmethod
    def get_file_from_another_virtual_machine(source_path,
                                              destination_path="./",
                                              username="", password="", ip=""):
        """
        Keyword for downloading file from another virtual machine

        | **Author:** damian.skrzypczak@nokia.com
        | **Maintainer:** damian.skrzypczak@nokia.com
        | **Released with version:** ---

        | **Full description:**
        | Function downloading file from another virtual machine
        | (connected to extension) via sftp to desirable directory

        **Input Parameters:**

        +--------------------+--------+--------------------------------------+
        | Input Parameters   | Man.   | Description                          |
        +====================+========+======================================+
        | source_path:       | Yes    | path of file on virtual machine      |
        +--------------------+--------+--------------------------------------+
        | ip:                | No     | ip of virtual machine                |
        +--------------------+--------+--------------------------------------+
        | username:          | No     | username to login on virtual machine |
        +--------------------+--------+--------------------------------------+
        | password:          | No     | password to login on virtual machine |
        +--------------------+--------+--------------------------------------+

        **Example:**

        .. code-block:: robotframework

           ${some_logs_local_path}=  Get file from another virtual machine
           ...  /home/ute/logs/some_log.txt  ./some_log.txt
           ...  username=XX  password=XX  ip= X.X.X.X

        | **Return value:**
        | path to local copy of downloaded file
        """
        destination_path = SimpleFileGetter._prepare_paths(destination_path,
                                                           source_path)
        SimpleFileGetter._sftp_strategy(ip, username, password, source_path,
                                        destination_path)
        return destination_path

    @staticmethod
    def get_file_from_master_sysmod(source_path, destination_path="./",
                                    username="toor4nsn",
                                    password="oZPS0POrRieRtu",
                                    ip='192.168.255.129'):
        """
        Keyword from getting file from master system module

        | **Author:** damian.skrzypczak@nokia.com
        | **Maintainer:** damian.skrzypczak@nokia.com
        | **Released with version:** ---

        | **Full description:**
        | Function downloading file from MSM(master system module)
        | via remote to desirable directory

        **Input Parameters:**

        +--------------------+--------+----------------------------------+
        | Input Parameters   | Man.   | Description                      |
        +====================+========+==================================+
        | source_path:       | Yes    | path of file on MSM              |
        +--------------------+--------+----------------------------------+
        | destination_path:  | No     | destination of downloaded file,  |
        |                    |        |   default= ./                    |
        +--------------------+--------+----------------------------------+
        | ip:                | No     | ip of MSM                        |
        +--------------------+--------+----------------------------------+
        | username:          | No     | username to login on MSM         |
        +--------------------+--------+----------------------------------+
        | password:          | No     | password to login on MSM         |
        +--------------------+--------+----------------------------------+

        **Example:**

        .. code-block:: robotframework

        ${some_logs_local_path}=  Get file from master sysmod
           ...  /home/ute/logs/some_log.txt  ./some_log.txt
           ...  username=XX  password=XX  ip= X.X.X.X

        | **Return value:**
        | path of local file copy
        """
        destination_path = SimpleFileGetter._prepare_paths(destination_path,
                                                           source_path)
        SimpleFileGetter._sftp_strategy(ip, username, password, source_path,
                                        destination_path)
        return destination_path

    @staticmethod
    def _sftp_strategy(ip, username, password, source_path, destination_path):
        transport = paramiko.Transport(ip)
        transport.start_client()

        try:
            transport.auth_password(username=username, password=password)
        except paramiko.ssh_exception.SSHException:
            full_path = os.path.expanduser("~/.ssh/id_rsa")
            rsa_key = paramiko.RSAKey.from_private_key_file(full_path)
            transport.auth_publickey(username=username, key=rsa_key)

        sftp = paramiko.SFTPClient.from_transport(transport)
        try:
            sftp.get(source_path, destination_path)
        except (IOError, AttributeError):
            logging.error('RemoteIOError ' + str(ip) + ':' + str(source_path))
            raise Exception('RemoteIOError')
        finally:
            sftp.close()
            transport.close()

    @staticmethod
    def _ftp_strategy(ip, username, password, source_path, destination_path):
        ftp = FTP(ip)
        ftp.login(username, password)
        try:
            ftp.retrbinary("RETR {}".format(source_path),
                           open(destination_path, 'wb').write)
        except error_perm:
            logging.error('RemoteIOError ' + str(ip) + ':' + str(source_path))
            raise Exception('RemoteIOError')
        finally:
            ftp.close()

    @staticmethod
    def _prepare_paths(destination_path, source_path):
        destination_dir, destination_filename, source_dir, source_filename = \
            SimpleFileGetter._split_paths(
                destination_path,
                source_path)
        SimpleFileGetter._check_existence_of_directory(destination_dir)
        destination_filename = SimpleFileGetter._add_timestamp(
            destination_filename, source_filename)
        destination_path = os.path.join(destination_dir,
                                        destination_filename)
        return destination_path

    @staticmethod
    def _add_timestamp(destination_filename, source_filename):
        if not destination_filename:
            logging.info("No given destination filename, cloning from source")
            destination_filename = "_".join(
                [str(datetime.datetime.utcnow().strftime("%Y-%m-%d_%H:%M")),
                 source_filename])
        return destination_filename

    @staticmethod
    def _split_paths(destination_path, source_path):
        src_dir, src_filename = os.path.split(source_path)
        dest_dir, dest_filename = os.path.split(destination_path)
        return dest_dir, dest_filename, src_dir, src_filename

    @staticmethod
    def _check_existence_of_directory(destination_directory):
        if not os.path.exists(destination_directory):
            raise IOError('Destination directory "{}" not exists'.format(
                destination_directory))


class FileGetter(SimpleFileGetter):
    common_credentials = {"VM": ("ute", "ute"),
                          "MSM": ("toor4nsn", "oZPS0POrRieRtu")}

    download_commands_patterns = {
        "VM": ("wget --user={usr} --password={password} "
               "-O {dest} ftp://{ip}//{src_path} --proxy=off"),
        "MSM": "ftpget -u {usr} -p {password} {ip} {dest} {src_path}"}

    download_methods = {
        "VM": SimpleFileGetter.get_file_from_another_virtual_machine,
        "MSM": SimpleFileGetter.get_file_from_master_sysmod}

    @staticmethod
    def get_file_from_smod(target_ip='192.168.255.129',
                           target_username='toor4nsn',
                           target_password='oZPS0POrRieRtu',
                           source_path='', destination_path='./',
                           via_ip='', via_username='ute',
                           via_password='ute'):
        """
        Keyword from getting file from master
        system module with optional mediator.

        | **Author:** damian.skrzypczak@nokia.com
        | **Maintainer:** damian.skrzypczak@nokia.com
        | **Released with version:** ---

        | **Full description:**
        | Function downloading file via FTP
        | from System Module(connected directly to VM or through another VM)
        | to desirable directory

        **Input Parameters:**

        +-----------------------+--------+------------------------------------+
        | Input Parameters      | Man.   | Description                        |
        +=======================+========+====================================+
        | source_path           | No     | full path to file on system module |
        +-----------------------+--------+------------------------------------+
        | target_ip             | No     | ip of target system module,        |
        |                       |        | that contains desirable file       |
        +-----------------------+--------+------------------------------------+
        | target_username       | No     | username/login for target          |
        |                       |        | system module,                     |
        +-----------------------+--------+------------------------------------+
        | target_password       | No     | password for target                |
        |                       |        | system module,                     |
        +-----------------------+--------+------------------------------------+
        | via_ip                | No     | ip for middle-handler              |
        |                       |        | VM for connection and downloading  |
        +-----------------------+--------+------------------------------------+
        | via_username          | No     | username/login for middle-handler  |
        |                       |        | VM for connection and downloading  |
        +-----------------------+--------+------------------------------------+
        | via_password          | No     | password for middle-handler VM     |
        |                       |        | for connection and downloading     |
        +-----------------------+--------+------------------------------------+
        | destination_directory | No     | destination directory for where    |
        |                       |        | file will be delivered, default=./ |
        +-----------------------+--------+------------------------------------+

        **Example:**

        .. code-block:: robotframework

           ${some_logs_local_path}=  Get file from system module
           ...  source_path=/home/ute/logs/some_log.txt
           ...  destination_path./some_log.txt
           ...  target_username=XX  target_password=XX  target_ip=X.X.X.X
           ...  via_username=YY  via_password=YY  via_ip=Y.Y.Y.Y

        | **Return value:**
        | path of local file copy
        """

        if via_ip:
            return FileGetter.get_file_from_extension(
                target_ip=target_ip,
                via_ip=via_ip,
                source_path=source_path,
                target_username=target_username,
                target_password=target_password,
                via_username=via_username,
                via_password=via_password,
                destination_path=destination_path,
                via_vm=True)
        else:
            return SimpleFileGetter.get_file_from_master_sysmod(
                source_path=source_path,
                destination_path=destination_path,
                username=target_username,
                password=target_password, ip=target_ip)

    @staticmethod
    def get_file_from_extension(target_ip="", via_ip='', source_path="",
                                target_username="toor4nsn",
                                target_password="oZPS0POrRieRtu",
                                via_username="", via_password="",
                                destination_path="./", via_vm=False):
        """
        Keyword for getting file from extension system module

        | **Author:** damian.skrzypczak@nokia.com
        | **Maintainer:** damian.skrzypczak@nokia.com
        | **Released with version:** ---

        | **Full description:**
        | Function downloading file
        | from EXSM(extension system module)
        | to desirable directory

        **Input Parameters:**

        +-----------------------+--------+------------------------------------+
        | Input Parameters      | Man.   | Description                        |
        +=======================+========+====================================+
        | source_path           | No     | path to file on EXSM               |
        +-----------------------+--------+------------------------------------+
        | target_ip             | No     | ip of target EXSM,                 |
        |                       |        | that contains desirable file       |
        +-----------------------+--------+------------------------------------+
        | target_username       | No     | username/login for target EXSM,    |
        +-----------------------+--------+------------------------------------+
        | target_password       | No     | password for target EXSM,          |
        +-----------------------+--------+------------------------------------+
        | via_ip                | No     | ip for middle-handler for          |
        |                       |        | connection and downloading         |
        +-----------------------+--------+------------------------------------+
        | via_username          | No     | username/login for middle-handler  |
        |                       |        | for connection and downloading     |
        +-----------------------+--------+------------------------------------+
        | via_password          | No     | password for middle-handler for    |
        |                       |        | connection and downloading         |
        +-----------------------+--------+------------------------------------+
        | destination_directory | No     | destination directory for where    |
        |                       |        | file will be delivered, default=./ |
        +-----------------------+--------+------------------------------------+
        | via_vm                | No     | flag for connection via another    |
        |                       |        | virtual machine, connected to EXMS |
        +-----------------------+--------+------------------------------------+

        **Example:**

        .. code-block:: robotframework

           ${some_logs_local_path}=  Get file from extension
           ...  source_path=/home/ute/logs/some_log.txt
           ...  destination_path./some_log.txt
           ...  target_username=XX  target_password=XX  target_ip=X.X.X.X
           ...  via_username=YY  via_password=YY  via_ip=Y.Y.Y.Y
           ...  via_vm = True

        | **Return value:**
        | path of local file copy
        """

        filename = os.path.split(source_path)[-1]
        via_destination_path = os.path.join("/tmp/", "ESM_" + filename)

        given_credentials = (via_password, via_username)

        if via_vm:
            chosen_mode = "VM"
        else:
            chosen_mode = "MSM"

        via_password, via_username = given_credentials if all(
            given_credentials) else FileGetter.common_credentials[
            chosen_mode]
        chosen_command_pattern = FileGetter.download_commands_patterns[
            chosen_mode]

        chosen_method = FileGetter.download_methods[chosen_mode]
        command = chosen_command_pattern.format(usr=target_username,
                                                password=target_password,
                                                dest=via_destination_path,
                                                ip=target_ip,
                                                src_path=source_path
                                                )

        FileGetter._execute(command, via_ip, via_password, via_username)
        return chosen_method(source_path=via_destination_path,
                             destination_path=destination_path,
                             username=via_username, password=via_password,
                             ip=via_ip)

    @staticmethod
    def _execute(command, via_ip, via_password, via_username):
        command_executor = SSHExecutor()
        command_executor.set_connection_parameters(ip=via_ip,
                                                   user=via_username,
                                                   password=via_password)
        command_executor.run_command(command)


class SWPackage(object):
    """

    """

    def __init__(self):
        super(SWPackage, self).__init__()

    @staticmethod
    def get_node_attribute_value(node_name, path, path_within_zip):
        """
        Keyword for getting attribute from software package

        | **Author:** agata.maslowska@nokia.com
        | **Maintainer:** agata.maslowska@nokia.com
        | **Released with version:** ---

        | **Full description:**
        | Function returns value of the given node.
        | Parameter 'node_name' can be full node's name or one of following:
        | SOFTWARE_PACKAGE_NAME for "swReleaseVersionPackageName",
        | SOFTWARE_VERSION for 'swReleaseVersionName'.

        **Input Parameters:**

        +--------------------+--------+---------------------------------------+
        | Input Parameters   | Man.   | Description                           |
        +====================+========+=======================================+
        | node_name          | Yes    | That node's value will be returned    |
        +--------------------+--------+---------------------------------------+
        | path               | Yes    | Path to sw package zip file           |
        +--------------------+--------+---------------------------------------+
        | path_within_zip    | Yes    | Path to TargetBD file                 |
        |                    |        | within sw zip file                    |
        +--------------------+--------+---------------------------------------+

        | **Return value:**
        | Node's value if exists, else: None
        """
        zf = zipfile.ZipFile(path, 'r')
        for name in zf.namelist():
            if re.match("{}.*\\.xml".format(path_within_zip), name):
                file_content = zf.read(name)
                tree = etree.fromstring(file_content)
                value = tree.get(node_name)
                return value
        raise IOError

    def get_targetbd_node_attribute_value(self, node_name, path):
        """
        Keyword for parsing TargetBD and getting value for given node name.

        | **Author:** agata.maslowska@nokia.com
        | **Maintainer:** agata.maslowska@nokia.com
        | **Released with version:** ---

        | **Full description:**
        | Function parses TargetBD file within sw package zip file
        | and returns value of given node.
        | Parameter 'node_name' can be full node's name or one of following:
        | SOFTWARE_PACKAGE_NAME for "swReleaseVersionPackageName",
        | SOFTWARE_VERSION for 'swReleaseVersionName'

        **Input Parameters:**

        +--------------------+--------+------------------------------------+
        | Input Parameters   | Man.   | Description                        |
        +====================+========+====================================+
        | node_name          | Yes    | That node's value will be returned |
        +--------------------+--------+------------------------------------+
        | path               | Yes    | Path to sw package zip file        |
        +--------------------+--------+------------------------------------+

        | **Return value:**
        | Node attribute's value if such exists in
        | TargetBD file within sw package,
        | None if there is no such package / TargetBD file / Node
        """
        targetbd_path = "bts_sw/TargetBD"

        try:
            node_value = self.get_node_attribute_value(node_name, path,
                                                       targetbd_path)
            logging.info("{} found.".format(path))

        except IOError:
            logging.error("No such file under given path: {}.".format(path))
            return None

        if not node_value:
            logging.error("No such param in TargetBD: {}.".format(node_name))
            return None
        else:
            logging.info("{} = {}".format(node_name, node_value))
            return node_value
