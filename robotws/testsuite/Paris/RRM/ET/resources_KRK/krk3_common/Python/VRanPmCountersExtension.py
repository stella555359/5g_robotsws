"""
:copyright: Nokia Networks
:author: Mateusz Michalik
:maintainer:  Mateusz Michalik
:contact: mateusz.michalik@nokia.com
"""

import os
from ta5g_pm_counters.resources import CountersResources
from robot.api import logger
from time import sleep, strftime, localtime
import taf.transport.ssh as ssh
from robot.libraries.BuiltIn import BuiltIn
from ta5g_interface_tools import ta5g_interface_tools
from robot.libraries.OperatingSystem import OperatingSystem


class VRanPmCountersExtension(CountersResources):
    ROBOT_LIBRARY_SCOPE = 'TEST SUITE'

    tl = BuiltIn().get_variable_value('${{{}}}'.format("tl"), None)
    units_connection_details = {
        "vcu": tl.cloud_hostings[0].master_node.ssh_connection_details,
        "vdu": tl.cloud_hostings[1].master_node.ssh_connection_details
    }

    units_namespaces = {
        "vcu": tl.cloud_hostings[0].namespace,
        "vdu": tl.cloud_hostings[1].namespace
    }

    def ssh_executor(self, cmd, unit):
        sshconn = ssh.ssh()
        try:
            sshconn.connect_to(
                hostname=self.units_connection_details[unit.lower()].addr,
                username=self.units_connection_details[unit.lower()].username,
                password=self.units_connection_details[unit.lower()].password
            )
            logger.debug('{}\n'.format(cmd))
            result = sshconn.execute("{}".format(cmd))
            logger.debug("{}:\n{}".format(unit, result))
        finally:
            sshconn.disconnect()

        return result

    def kubectl_executor(self, cmd, unit):
        """
        method to execute command on ute-*-pm-0 pod
        return cmd result
        """
        result = self.ssh_executor(
            "kubectl exec -n {namespace} {pod} -c {container} -- {pod_cmd}".format(
                namespace=self.units_namespaces[unit.lower()],
                pod="ute-{}-oampm-0".format(self.units_namespaces[unit.lower()]),
                container="ctr-{}-oampm".format(self.units_namespaces[unit.lower()]),
                pod_cmd=cmd
            ),
            unit
        )

        return result

    def kubectl_cp(self, filepath_pod, unit):
        """
        method to execute command on ute-*-pm-0 pod
        return cmd result
        """
        new_filename = filepath_pod.split("/")[-1].replace(":", "")
        new_filepath = "/var/home/core/{}".format(new_filename)
        self.ssh_executor(
            "kubectl cp {pod}:{filepath} {new_filname} -n {namespace} -c {container}".format(
                pod="ute-{}-oampm-0".format(self.units_namespaces[unit.lower()]),
                filepath=filepath_pod,
                new_filname=new_filepath,
                namespace=self.units_namespaces[unit.lower()],
                container="ctr-{}-oampm".format(self.units_namespaces[unit.lower()]),
            ),
            unit
        )

        return new_filepath

    def wait_for_new_vran_pm_filenames(self, **kwargs):
        """
        all params are optional, for example only vCU without other params is enough
        :param timeout:  How many seconds function waits for new PM file,
         when its exceded raises timeout error, default 4000s

        Example:
        | *** Test Cases *** |
        | Example Test |
        |    | Wait For New Vran PM Filename |
        |    | ...    timeout=3600 |

        :return: Newly created RAWs list of full PM counter filenames
        """
        file_ready = False
        differences = {}
        timeout = int(kwargs.pop('timeout', 4000))

        logger.console('\nWaiting for next raw pm file...')

        unzip_timeout = 60
        wrn_print = ('PM file is unzippable after timeout: {}s'.format(unzip_timeout))

        for unit in ["vcu", "vdu"]:
            old_ram_content = self.kubectl_executor(
                "ls -tr /mnt/services/SS_OAM/PMSTAT/pm_report_files 2>/dev/null | xargs -n1 basename 2>/dev/null;:",
                unit
            ).split()
            while not file_ready:
                self._unzip_timeout(timeout, "Timeout, too long time without new PM file on vCU."
                                             " Validated counters may have different interval."
                                             " Please set the same interval for all validated PM counters")
                sleep(10)
                timeout -= 10
                new_ram_content = self.kubectl_executor(
                    "ls -tr /mnt/services/SS_OAM/PMSTAT/pm_report_files 2>/dev/null | xargs -n1 basename 2>/dev/null;:",
                    unit
                ).split()
                file_ready, difference = self._is_new_file_ready(old_ram_content, new_ram_content, raw_file=False)
            differences[unit] = difference

        return differences

    def get_next_vran_unpacked_full_pm_counters_files(self, **kwargs):
        """
        Gets next unpacked full pm counter file from enb ram folder

        :param output_dirpath:  path for save result files
        :param timeout:  How many seconds function waits for new PM file,

        :return: path to file
        """
        output_dirpath = kwargs.pop('output_dirpath', ta5g_interface_tools().get_robot_output_dir())

        _time = strftime("%Y-%m-%d %H:%M:%S", localtime())
        output_dirpath = "{}/PM_LISTENER_CLOUD/{}".format(output_dirpath, _time)
        OperatingSystem().create_directory(output_dirpath)
        OperatingSystem().create_directory("{}/{}".format(output_dirpath, "vcu"))
        OperatingSystem().create_directory("{}/{}".format(output_dirpath, "vdu"))

        logger.console('\nWaiting for next full pm file...')
        pm_counter_filenames = self.wait_for_new_vran_pm_filenames(**kwargs)
        unpacked_pm_counters_filepaths_dict = self.get_and_unpack_vran_pm_counters_file(
            pm_filenames=pm_counter_filenames, output_dirpath=output_dirpath,
        )
        return unpacked_pm_counters_filepaths_dict

    def get_and_unpack_vran_pm_counters_file(self, pm_filenames, output_dirpath):
        unpacked_pm_counters_unit_dict = {}

        for unit in pm_filenames:
            dirpath = "{}/{}".format(output_dirpath, unit)
            try:
                new_filepath = self.kubectl_cp(
                    "/mnt/services/SS_OAM/PMSTAT/pm_report_files/{file_name}".format(file_name=pm_filenames[unit]),
                    unit
                )

                file_content = self.ssh_executor(
                    "zcat {filepath}".format(filepath=new_filepath),
                    unit
                )
                unpacked_pm_counters_filepath = \
                    self.download_file_content_to_target_directory(dirpath, pm_filenames[unit], file_content)

            finally:
                self.ssh_executor("rm {}".format(new_filepath), unit)

            unpacked_pm_counters_unit_dict[unit] = unpacked_pm_counters_filepath

        return unpacked_pm_counters_unit_dict

    @staticmethod
    def download_file_content_to_target_directory(target_dir, file_name, file_content):
        filepath = os.path.join(target_dir, file_name.replace(".gz", ""))
        with open(filepath, 'w') as counter_file:
            counter_file.write(file_content)
        return filepath
