# -*- coding: utf-8 -*
'''
:author: Yang Mengli
:contact: mengli.yang@nokia-sbell.com
:Description: Modification to file swconfig.txt on ASIB
'''

import sys
if sys.version_info.major == 3:
    import subprocess as commands
else:
    import commands
import logging
import os
from taf.transport.ssh import ssh


class swconfig(object):

    def __init__(self):
        self.ssh = ssh()

    def download_swConfig_file_from_asib_to_test_pc(self, localFilePath, remoteFilePath="/ffs/run/swconfig.txt",
                                                    asib_alias="ASIB"):
        """
        Download swconfig file from ASIB. QT template should be
        :param localFilePath: Provide the file path in test pc. Example value can be:/XXX/XXX/swconfig.txt
        :param remoteFilePath: File path on ASIB
        :param asib_alias:
        :return:
        """
        logging.info("Start download swconfig.txt from asib to test pc")
        self.ssh.download_file(remote_path=remoteFilePath, local_path=localFilePath,
                               connection=asib_alias)

    def modify_swConfig_file(self, parametersList, filePath):
        """
        Modify swconfig file on test PC. Currently only support for add and modify R&D parameters
        If input R&D parameter does not exist in swconfig file, then will add it. If already exists, then will
        update with new value
        :param parametersList: list the update content, example input can be: ["0x4600BA=6","0x460002=6"]
        :param filePath: file path on test pc, example input can be: /XXX/XXX/swconfig.txt
        :return: No return value. Will raise exception if modification failed
        """
        for item in parametersList:
            key = item.split('=')[0]
            cmd_update_value = r"sed -i -E 's/^%s\s{0,}=.*/%s/g' %s" % (key, item, filePath)
            cmd_add_value = r"sed -i '$a {}' {}".format(item, filePath)
            if self._is_parameter_exist_in_file(key, filePath):
                cmd = cmd_update_value
            else:
                cmd = cmd_add_value
            (ret_code, output) = commands.getstatusoutput(cmd)
            if ret_code != 0:
                raise Exception("Fail to modify. Output message for command {} is {}".format(cmd, output))
            else:
                logging.info("Modify or add parameter {} to {} successfully. Executed command is: {}".
                             format(item, filePath, cmd))

    def delete_parameter_of_swConfig_file(self, parametersList, filePath):
        """
        Delete parameter of swconfig file on test PC.
        :param parametersList: list the update content, example input can be: ["0x4600BA","0x460002"]
        :param filePath: file path on test pc, example input can be: /XXX/XXX/swconfig.txt
        :return: No return value.
        """
        for item in parametersList:
            cmd_delete_value = "sed -i 's/^{}/#{}/g' {}".format(item, item, filePath)
            if self._is_parameter_exist_in_file(item, filePath):
                cmd = cmd_delete_value
                (ret_code, output) = commands.getstatusoutput(cmd)
                if ret_code != 0:
                    raise Exception("Fail to delete. Output message for command {} is {}".
                                    format(cmd, output))
                else:
                    logging.info("Delete parameter {} to {} successfully. Executed command is: {}".
                                 format(item, filePath, cmd))
            else:
                logging.info("{} has been deleted".format(item))

    def crasign_swconfig_file_on_asib(self, asib_alias="ASIB"):
        """
        Crasign swconfig file on asib
        :param asib_alias: asib connection alias
        :return: no return value
        """
        logging.info("Crasign for swconfig.txt file on ASIB...")
        cmd_crasign = "cd /ffs/run;crasign swconfig.txt"
        output_crasign = self.ssh.execute(cmd_crasign, connection=asib_alias)
        if len(output_crasign) != 0:
            raise Exception("Fail to crasign for swconfig.txt, error message is {}".format(output_crasign))

    def upload_swConfig_file_to_asib_and_crasign(self, localFilePath, remoteFilePath="/ffs/run/swconfig.txt",
                                                 asib_alias="ASIB"):
        """
        Upload local file on test pc to ASIB
        :param localFilePath: File path on test pc, example input can be: /XXX/XXX/swconfig.txt
        :param remoteFilePath: Default file path is /ffs/run/swconfig.txt on ASIB
        :param asib_alias:
        :return:
        """
        logging.info("Backup original swconfig.txt file on ASIB")
        cmd_removeOriginalFile = "cp {} {}.bak".format(remoteFilePath, remoteFilePath)
        self.ssh.execute(cmd_removeOriginalFile, connection=asib_alias)
        logging.info("Start to replace swconfig.txt file on ASIB...")
        self.ssh.upload_file(local_path=localFilePath, remote_path=remoteFilePath, connection=asib_alias)
        self.crasign_swconfig_file_on_asib(asib_alias=asib_alias)

    def restore_swConfig_file_on_asib_and_crasign(self, asib_alias="ASIB"):
        """
        Restore the swconfig file on asib after case execution finished
        :param asib_alias:
        :return: No return value
        """
        logging.info("Restore swconfig.txt file on ASIB")
        cmd_restore_swconfig_file = "mv /ffs/run/swconfig.txt.bak /ffs/run/swconfig.txt"
        output_restore = self.ssh.execute(command=cmd_restore_swconfig_file, connection=asib_alias)
        if len(output_restore) != 0:
            raise Exception("Fail to resore swconfig file on ASIB. Error message is: {}".format(output_restore))
        self.crasign_swconfig_file_on_asib(asib_alias=asib_alias)

    def _is_parameter_exist_in_file(self, parameter, filePath):
        if not os.path.exists(filePath):
            raise Exception("File {} not exists.".format(filePath))
        else:
            cmd_grepParameterInFile = r"cat %s |grep -E '%s\s{0,}='" % (filePath, parameter)
            output = commands.getoutput(cmd_grepParameterInFile).strip()
            logging.info("Output of executed command {} is: {}".format(cmd_grepParameterInFile, output))
            output = self._remove_commented_line(parameter, output)
            if output.startswith(parameter):
                logging.info("Parameter {} exists in {}".format(parameter, filePath))
                return True
            else:
                logging.info("Parameter {} not exists in {}".format(parameter, filePath))
                return False

    @staticmethod
    def _remove_commented_line(parameter, output):
        for param in output.split('\n'):
            if '#' not in param.split(parameter)[0]:
                return param
            else:
                logging.info(param)
                logging.info("Parameter {} is commented out".format(parameter))
        return output
