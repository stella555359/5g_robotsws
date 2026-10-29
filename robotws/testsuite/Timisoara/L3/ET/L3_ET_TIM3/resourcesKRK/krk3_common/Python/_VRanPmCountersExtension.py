"""
:copyright: Nokia Networks
:author: Mateusz Michalik
:maintainer:  Mateusz Michalik
:contact: mateusz.michalik@nokia.com
"""

import os
from ta5g_pm_counters.resources import CountersResources
from ta5g_pm_counters import counters_checker, PmCountersValidator
from robot.api import logger
from time import sleep
import taf.transport.ssh as ssh
from robot.libraries.BuiltIn import BuiltIn
from robot.libraries.OperatingSystem import OperatingSystem
import json
from ta5g_interface_tools import ta5g_interface_tools
from robot.libraries.XML import XML
from robot.utils import asserts
import copy
from functools import reduce
import operator


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
            logger.debug('{}\n'.format(result))

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
                pod="ute-{}-pm-0".format(self.units_namespaces[unit.lower()]),
                container="ctr-{}-pmcore".format(self.units_namespaces[unit.lower()]),
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
                pod="ute-{}-pm-0".format(self.units_namespaces[unit.lower()]),
                filepath=filepath_pod,
                new_filname=new_filepath,
                namespace=self.units_namespaces[unit.lower()],
                container="ctr-{}-pmcore".format(self.units_namespaces[unit.lower()]),
            ),
            unit
        )

        return new_filepath

    def get_json_result_mapping(self, unit):
        """
        read resultMapping.json and return dict
        {'55124': {'filenames': ['A20220708.1615+0000-20220708.1620+0000_gNB5G:17.xml.gz'...]},
         '55133': {'filenames': ['A20220708.1615+0000-20220708.1620+0000_gNB5G:25.xml.gz',...
        """
        return json.loads(self.kubectl_executor(
            "cat /var/opt/nokia/performancemanagement/storage/results/resultMapping.json",
            unit
        ))

    def get_object_to_id_dict(self, unit):
        """
        get xml id_object_stats file names list:
        ['51301_ETHLK_stats_v30.xml', '51302_VLAN_stats_v26.xml', '51324_IPNO_stats_v30.xml',....]

        return in format object_name:ID dict {'ETHLK': '51301', 'VLAN': '51302', 'IPNO': '51324', 'TCP': '51325',....}
        """

        pm_objects_plans = self.kubectl_executor(
            "ls /var/opt/nokia/performancemanagement/storage/persistence/plans",
            unit
        ).split()

        return dict(pm_plan_filename.split("_")[:2][::-1] for pm_plan_filename in pm_objects_plans)

    def wait_time_for_counter_enabling(self, unit, pm_objects_list, pm_object_dict, result_mapping, timeout):
        if not pm_objects_list:
            return []

        for pm_object in pm_objects_list:
            while not (pm_object in pm_object_dict):
                self._unzip_timeout(timeout, "Timeout, too long time to all pm objects enabled.")
                sleep(10)
                timeout -= 10
                pm_object_dict = self.get_object_to_id_dict(unit)

            while not (pm_object_dict[pm_object] in result_mapping):
                self._unzip_timeout(timeout, "Timeout, too long time to all pm objects enabled.")
                sleep(10)
                timeout -= 10
                result_mapping = self.get_json_result_mapping(unit)

        return [result_mapping[pm_object_dict[pm_object]]["filenames"][0].split("_")[-1]
                for pm_object in pm_objects_list]

    def wait_time_for_needed_units_pm_enabling(self, vdu_pm_objects, vcu_pm_objects, timeout):
        current_pm_object_dict = {
            "vdu": self.get_object_to_id_dict("vdu"),
            "vcu": self.get_object_to_id_dict("vcu")
        }

        current_result_mapping = {
            "vdu": self.get_json_result_mapping("vdu"),
            "vcu": self.get_json_result_mapping("vcu")

        }

        vdu_pm_files_id_extension_list = self.wait_time_for_counter_enabling(
            "vdu",
            vdu_pm_objects,
            current_pm_object_dict["vdu"],
            current_result_mapping["vdu"],
            timeout
        )

        vcu_pm_files_id_extension_list = self.wait_time_for_counter_enabling(
            "vcu",
            vcu_pm_objects,
            current_pm_object_dict["vcu"],
            current_result_mapping["vcu"],
            timeout
        )

        return {"vdu": vdu_pm_files_id_extension_list, "vcu": vcu_pm_files_id_extension_list}

    def wait_for_new_vran_pm_filenames(self, **kwargs):
        """
        all params are optional, for example only vCU without other params is enough
        :param vDU: @{vDU_PM_OBJECTS_LIST}
        :param vCU: @{vCU_PM_OBJECTS_LIST}
        :param timeout:  How many seconds function waits for new PM file,
         when its exceded raises timeout error, default 4000s

        Example:
        | *** Variables *** |
        | @{vCU_PM_OBJECTS_LIST}    PDCP2    HICPU |
        | @{vDU_PM_OBJECTS_LIST}    RACDU |
        | *** Test Cases *** |
        | Example Test |
        |    | Wait For New Vran PM Filename |
        |    | ...    vDU=@{vDU_PM_OBJECTS_LIST} |
        |    | ...    vCU=@{vCU_PM_OBJECTS_LIST} |
        |    | ...    timeout=3600 |

        :return: Newly created RAWs list of full PM counter filenames
        """
        vdu_pm_objects = kwargs.pop('vDU', [])
        vcu_pm_objects = kwargs.pop('vCU', [])

        timeout = int(kwargs.pop('timeout', 4000))

        logger.console('\nWaiting for next raw pm file...')

        unzip_timeout = 60
        wrn_print = ('PM file is unzippable after timeout: {}s'.format(unzip_timeout))

        differences = {
            "vdu": [],
            "vcu": []
        }

        '''
        wait for pm files after counters enable
        pm_files_id_extension_dict = {"vdu": ['gNB5G:42.xml.gz', 'gNB5G:49.xml.gz', ...],
        "vcu":['gNB5G:42.xml.gz', 'gNB5G:49.xml.gz', ...]}
        '''
        pm_files_id_extension_dict = self.wait_time_for_needed_units_pm_enabling(
            vdu_pm_objects,
            vcu_pm_objects,
            timeout
        )

        old_ram_content_dict = {
            "vcu": {},
            "vdu": {}
        }

        for unit in pm_files_id_extension_dict:
            if not pm_files_id_extension_dict[unit]:
                continue
            for id_extension in pm_files_id_extension_dict[unit]:
                old_ram_content = self.kubectl_executor(
                    "ls /var/opt/nokia/performancemanagement/storage/results/ | grep A*{}"
                    " 2>/dev/null | xargs -n1 basename 2>/dev/null;:".format(id_extension),
                    unit
                ).split()
                old_ram_content_dict[unit][id_extension] = old_ram_content

        while sum(map(len, differences.values())) != sum(map(len, pm_files_id_extension_dict.values())):
            self._unzip_timeout(timeout, "Timeout, too long time without new PM file on vCU."
                                         " Validated counters may have different interval."
                                         " Please set the same interval for all validated PM counters")
            sleep(10)
            timeout -= 10
            for unit in pm_files_id_extension_dict:
                if not pm_files_id_extension_dict[unit]:
                    continue
                for id_extension in old_ram_content_dict[unit]:
                    new_ram_content = self.kubectl_executor(
                        "ls /var/opt/nokia/performancemanagement/storage/results/ | grep A*{}"
                        " 2>/dev/null | xargs -n1 basename 2>/dev/null;:".format(id_extension),
                        unit
                    ).split()
                    if new_ram_content:
                        file_ready, difference = self._is_new_file_ready(old_ram_content_dict[unit][id_extension],
                                                                         new_ram_content, raw_file=False)
                        if file_ready and not any(
                                difference.split("_")[1] in pm_filename.split("_")[1]
                                for pm_filename in differences[unit]):
                            differences[unit].append(difference)
            logger.debug('Num of expected files: {}'.format(sum(map(len, pm_files_id_extension_dict.values()))))
            logger.debug('New PM files: {}'.format(differences))
            logger.debug('Num of new PM files: {}'.format(sum(map(len, differences.values()))))

        return differences

    def check_pm_file_is_unzippable(self, unit, differences, timeout, error_msg):
        while True:
            self._unzip_timeout(timeout, error_msg)
            msg_rc = self.kubectl_executor(
                "gunzip -t /var/opt/nokia/performancemanagement/storage/results/{}".format(differences[unit][0]),
                unit
            )
            if len(msg_rc) == 0:
                break
            logger.info('File is unzippable, try again after 5s : {}'.format(msg_rc))
            sleep(5)
            timeout -= 5

    def get_next_vran_unpacked_full_pm_counters_files(self, **kwargs):
        """
        Gets next unpacked full pm counter file from enb ram folder

        :param pm_objects_list: list of PM objects to validate for example: ['PDCP2', 'ETHLK']
        :param output_dirpath:  path for save result files
        :param timeout:  How many seconds function waits for new PM file,

        :return: path to file
        """
        output_dirpath = kwargs.pop('output_dirpath', ta5g_interface_tools().get_robot_output_dir())

        logger.console('\nWaiting for next full pm file...')
        pm_counter_filenames = self.wait_for_new_vran_pm_filenames(**kwargs)
        unpacked_pm_counters_filepaths_dict = self.get_and_unpack_vran_pm_counters_file(
            pm_filenames_list=pm_counter_filenames, output_dirpath=output_dirpath,
        )
        return unpacked_pm_counters_filepaths_dict

    def get_and_unpack_vran_pm_counters_file(self, pm_filenames_list, output_dirpath):
        unpacked_pm_counters_unit_dict = {}

        for unit in pm_filenames_list:
            unpacked_pm_counters_filepaths = []
            dirpath = "{}/{}".format(output_dirpath, unit)
            for file_name in pm_filenames_list[unit]:
                try:
                    new_filepath = self.kubectl_cp(
                        "/var/opt/nokia/performancemanagement/storage/results/{file_name}".format(file_name=file_name),
                        unit
                    )

                    file_content = self.ssh_executor(
                        "zcat {filepath}".format(filepath=new_filepath),
                        unit
                    )
                    unpacked_pm_counters_filepath = \
                        self.download_file_content_to_target_directory(dirpath, file_name, file_content)

                finally:
                    self.ssh_executor("rm {}".format(new_filepath), unit)

                unpacked_pm_counters_filepaths.append(unpacked_pm_counters_filepath)
            unpacked_pm_counters_unit_dict[unit] = copy.deepcopy(unpacked_pm_counters_filepaths)

        return unpacked_pm_counters_unit_dict

    @staticmethod
    def download_file_content_to_target_directory(target_dir, file_name, file_content):
        filepath = os.path.join(target_dir, file_name.replace(".gz", ""))
        with open(filepath, 'w') as counter_file:
            counter_file.write(file_content)
        return filepath

    def verify_vran_last_counters_in_files(self, *args, **kwargs):
        local_moid = kwargs.get('local_moid', 'DN:NE-LNBTS-1/LNCEL-1/MCC-244/MNC-09')
        files_list = kwargs.pop('files_list', None)
        measurement_type = kwargs.pop('measurement_type', None)
        moid_filtered_files = self.find_pm_file_by_distname(files_list, local_moid, measurement_type)
        asserts.assert_not_equal(len(moid_filtered_files), 0, msg="Missing file with local_moid: {}".format(local_moid))
        for file_path in moid_filtered_files:
            counters_checker.verify_last_counters_in_file(*args, local_moid=local_moid, file_path=file_path)

    def get_unit_pm_counters_values(self, counter, localmoid, filepaths_list):
        values_list = []
        moid_filtered_files = self.find_pm_file_by_distname(filepaths_list, localmoid)
        for file_path in moid_filtered_files:
            OperatingSystem().file_should_exist(file_path)
            pm_counter_values = PmCountersValidator().get_latest_pm_counter_value(counter, localmoid, file_path)
            values_list.append(pm_counter_values)
        if values_list:
            reduce(operator.concat, values_list)
        return values_list

    def get_vran_pm_counters_values(self, counter, localmoid, pm_filepaths_dict):
        values_dict = {}
        for unit in pm_filepaths_dict:
            values_list = self.get_unit_pm_counters_values(counter, localmoid, pm_filepaths_dict[unit])
            values_dict[unit] = values_list
        asserts.assert_not_equal(
            sum(map(len, values_dict.values())),
            0,
            msg="PM Counter {} does not exist in {}".format(counter, localmoid)
        )
        return values_dict

    @staticmethod
    def find_pm_file_by_distname(files_list, local_moid, measurement_type):
        moid_filtered_files = [
            file_path
            for file_path in files_list
            if XML().get_element_count(
                source=file_path, xpath=".//MO[DN='{}']".format(local_moid)
            )
            > 0
            and XML().get_element_count(
                file_path,
                xpath=".//PMTarget[@measurementType='{}']".format(measurement_type),
            )
            > 0
        ]

        return moid_filtered_files
