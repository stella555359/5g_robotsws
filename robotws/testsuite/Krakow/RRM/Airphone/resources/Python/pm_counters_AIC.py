# -*- coding: utf-8 -*-
"""
:copyright: Nokia Networks
:author: Szymon Lange, Adrianna Pienkowska, Beata Kapusta
:maintainer:  Szymon Lange, Adrianna Pienkowska, Beata Kapusta
:contact: szymon.lange@nokia.com, adrianna.pienkowska@nokia.com, beata.kapusta@nokia.com
:team: I_5GSC_SW_ENG_KRK_VRF_GMS
:email: I_5GSC_SW_ENG_KRK_VRF_GMS <I_5GSC_SW_ENG_KRK_VRF@internal.nsn.com>
"""
import os
import re
import time
import xml.etree.ElementTree as ETree
from robot.api import logger
from robot.libraries.BuiltIn import BuiltIn

from testsuite.Krakow.RRM.Airphone.resources.Python.common_vcu import vCU
from testsuite.Krakow.RRM.Airphone.resources.Python.common_vdu import vDU
from testsuite.Krakow.RRM.Airphone.resources.Python.pm_counters import (
    get_library_instance, modify_value_in_counter_list)
from testsuite.Krakow.RRM.Airphone.resources.Python.utilities import logger_console_info
from testsuite.Krakow.RRM.Airphone.resources.Python.file_management import (
    download_files_from, extract_tarfile_to_dir_and_remove)
from testsuite.Krakow.RRM.Airphone.resources.Python.shell_management import (
    shell_session_vdu, go_to_the_container, get_vdu_namespace, download_file_from_container_to_vdu,
    get_vdu_connection_params
)
from testsuite.Krakow.RRM.Airphone.resources.Python.file_management import copy_files_from_local_to_local


class CountersCU(vCU):
    """
    Counters vCU Class

    Collect and verifies pm counters from vCU
    """

    def get_pm_counters_vcu(self, mrbts_id, nrbts_id, cell=1, object_class_name=' ', object_name='NRBTS',
                            counter_list=None):
        """Gets vCU counters

        :param mrbts_id: mrbts id
        :param nrbts_id: nrbts id
        :param cell: number of cells
        :param object_class_name: str, object class name to filtered (should be empty for all objects to filter)
        :param object_name: str, object name to be filtered
        :param counter_list:    list of pm counters to check with constraints and names to display:
                                counter_list = ['M55323C00001', '>0', 'DL_NUM_SNT_F1_QoS_GRP_01',
                                                'M55313C00006', '0', 'NUM_DL_FWD_SDU_RCV_QoS_GRP_06',
                                                'M55113C00001', '0', 'F1_UE_CTXT_MOD_REQ_SENT']
        """

        pm = get_library_instance("ta5g_pm_counters")
        out_dir = BuiltIn().get_variable_value("${OUTPUT_DIR}")
        mo_id = "MRBTS-{}/NRBTS-{}/NRCELL-{}".format(mrbts_id, nrbts_id, cell)

        data = ETree.Element('PMSetup')
        element1 = ETree.SubElement(data, 'PMMOResult')
        s_elem = ETree.SubElement(element1, 'MO')
        s_elem.text = mo_id
        for counter in counter_list:
            if counter.startswith('M'):
                file, values = self.get_pm_counter(object_class_name, counter, object_name)
                copy_files_from_local_to_local(file, out_dir)
                values = values[0]
                counter_values = {}
                for key, value in values.items():
                    if re.match('[0-9]{4}-(0[1-9]|1[0-2])-(0[1-9]|[1-2][0-9]|3[0-1]) '
                                '(2[0-3]|[01][0-9]):[0-5][0-9]:[0-5][0-9]', key):
                        counter_values[key] = value
                maxdate = max(counter_values)
                s_elem1 = ETree.SubElement(element1, counter)
                s_elem1.text = counter_values[maxdate]

            b_xml = ETree.tostring(data)
            with open("{}/vCU_pm_counters.xml".format(out_dir), "wb") as f:
                f.write(b_xml)
        logger_console_info("Pm Counters for vCU: ")
        pm.verify_last_counters_in_file(
            *counter_list, local_moid=mo_id, file_path="{}/vCU_pm_counters.xml".format(out_dir))


class CountersDU(vDU):
    """
    Counters vDU Class

    Collect and verifies pm counters from vDU
    """

    @staticmethod
    def wait_for_next_pm_counter_files_to_generate(files_to_check, timeout=350):
        """
        Waits until next Measurement Period starts and compares generated files from before it with current ones until
        there is a difference and required files are present.

        :param files_to_check:  (list) List of counters files ids that need to be generated e.g:
                                [9, 12, 17] for files
                                A20220523.1335+0000-20220523.1340+0000_MRBTS-1234:9.xml.gz,
                                A20220523.1335+0000-20220523.1340+0000_MRBTS-1234:12.xml.gz,
                                A20220523.1335+0000-20220523.1340+0000_MRBTS-1234:17.xml.gz.
        :param timeout:  (str) In seconds
        """
        path_in_container = '/mnt/services/SS_OAM/PMSTAT/pm_report_files'
        cmd = 'ls -t | grep MRBTS | head -n 35'
        with shell_session_vdu() as handler:
            container = get_vdu_namespace()
            go_to_the_container(handler, container, 'pmdataserver', 'oampm-0')
            handler.execute(cmd='cd {}'.format(path_in_container))
            shin, files, sherr = handler.execute(cmd=cmd)
            period_end = files[0].split('.')[2].split('+')[0]
        logger_console_info('Waiting for new PM Counters files to generate...')
        with shell_session_vdu() as handler:
            go_to_the_container(handler, container, 'pmdataserver', 'oampm-0')
            handler.execute(cmd='cd {}'.format(path_in_container))
            while timeout > 0:
                shin, new_files, err = handler.execute(cmd=cmd)
                new_files_ids = [file.strip('.xml.gz\n').split('-')[2] for file in new_files]
                time.sleep(30)
                timeout -= 30
                conditions_ok = {
                    'files_differ': files != new_files,
                    'all_required_files_present': all(str(file_id) in new_files_ids for file_id in files_to_check),
                    'period_end_changed': period_end != new_files[0].split('.')[2].split('+')[0]
                }
                logger.debug(f'Status of conditions: {conditions_ok}')
                if all(conditions_ok.values()):
                    return
            logger_console_info(conditions_ok, pprint=True)
            raise TimeoutError('PM counter files not generated in {}s!'.format(timeout))

    @staticmethod
    def _download_pm_file_from_vdu(file_path_local):
        vdu_ip, vdu_user, vdu_pass = get_vdu_connection_params()
        path_in_container = 'mnt/services/SS_OAM/PMSTAT/pm_report_files'
        with shell_session_vdu() as handler:
            container = get_vdu_namespace()
            go_to_the_container(handler, container, 'pmdataserver', 'oampm-0')
            handler.execute(cmd='cd {}'.format(path_in_container))
            shin, files, sherr = handler.execute(cmd='ls -t | grep MRBTS | head -n 40')
            period_ends = [int(file.split('-')[1].split('+')[0].split('.')[1]) for file in files]
            cmd = f'tar cf pm_counters.txz $(ls -t | head -n 40 | grep {str(max(period_ends))}+[0-9]*_MRBTS)'
            shin, out, sherr = handler.execute(cmd=cmd)
            if 'refusing to create an empty archive' in out:
                logger.error('Could not create archive with pm-couter files on pod!')
                raise FileNotFoundError

        with shell_session_vdu() as handler:
            download_file_from_container_to_vdu(
                handler, container, 'pmdataserver', 'oampm-0', '{}/pm_counters.txz'.format(path_in_container))

        file_path_vdu = '/var/home/core/pm_counters.txz'
        download_files_from(vdu_ip, vdu_user, vdu_pass, file_path_vdu, file_path_local)

    @staticmethod
    def _merge_pm_files(file_paths_list, output_file_path):
        """
        Merges XML files into one

        :param file_paths_list: list of full paths to files to merge
        :param output_file_path: full path to output file
        """
        os.system('gzip -d {}'.format(" ".join(file_paths_list)))
        paths = [path.strip('.gz') for path in file_paths_list]
        out_file = ETree.parse(paths[0])
        out_file_root = out_file.getroot()
        pmsetup = out_file_root.find('PMSetup')

        for file in paths[1:]:
            tree = ETree.parse(file)
            root = tree.getroot()
            pmmoresult = root.find('./PMSetup/PMMOResult')
            pmsetup.append(pmmoresult)
        out_file.write(output_file_path)

    def get_latest_pm_counters_file_from_vdu(self, counter_file='pm_counters.xml'):
        """
        Downloads latest PM Counters files from vDU and merges them into one xml file for ta5g_pm_counters

        :param counter_file:    (str) Name of merged PM Counters file.

        :return:                (str) Path to merged PM Counters file.
        """
        out_dir = BuiltIn().get_variable_value("${OUTPUT_DIR}")
        suite_name = BuiltIn().get_variable_value("${SUITE_NAME}")
        out_dir = os.path.join(out_dir, suite_name, counter_file.split('.')[0])
        if not os.path.exists(out_dir):
            os.mkdir(out_dir)
        for file in os.listdir(out_dir):
            os.remove(os.path.join(out_dir, file))
        file_path_local = os.path.join(out_dir, 'pm_counters.txz')

        self._download_pm_file_from_vdu(file_path_local=file_path_local)
        extract_tarfile_to_dir_and_remove(out_dir, file_path=file_path_local)

        files = [file for file in os.listdir(out_dir) if 'MRBTS' in str(file)]
        paths = [str(os.path.join(out_dir, basename)) for basename in files]
        out_path = '{}/{}'.format(out_dir, counter_file)
        self._merge_pm_files(file_paths_list=paths, output_file_path=out_path)

        return out_path

    def store_latest_pm_counters_in_dict(self, mrbts_id, nrbts_id, cell, counter_list=None):
        counters_with_values = dict()
        for counter in counter_list:
            if counter.startswith('M'):
                period, counter_value = self.get_latest_pm_counter_value(mrbts_id, nrbts_id, counter, cell)
                counters_with_values[counter] = int(counter_value)
        return counters_with_values

    @staticmethod
    def get_latest_counter_values_for_cells(counter_id, pm_file, cells=(1,)):
        """
        Get latest counter value for specified cells.

        :param counter_id:  (str) Counter name
        :param pm_file:     (str) Absolute path to file with PM Counters
        :param cells:       (list) List with cell's ids for which counter will be check
        """
        pm = BuiltIn().get_library_instance("ta5g_pm_counters")
        mrbts = BuiltIn().get_variable_value("${MRBTS_ID}")
        nrbts = BuiltIn().get_variable_value("${NRBTS_ID}")
        counter_values = dict()
        for cell in cells:
            mo_id = "PLMN-PLMN/MRBTS-{}/NRBTS-{}/NRCELL-{}".format(mrbts, nrbts, cell)
            counter_values[cell] = pm.get_latest_pm_counter_value(counter_id, mo_id, pm_file)
        return counter_values

    @staticmethod
    def check_pm(pm_file, cells=(1,), counter_list=None):
        """
        Checks if counters changed correctly for all cells.

        :param pm_file:         absolute path to file with PM Counters
        :param cells:           list of nrCellIds
        :param counter_list:    list of pm counters to check with constraints and names to display:
                                counter_list = ['M55303C14001', '>0', 'PUCCH_FORMAT1_NON_DTX',
                                                'M55303C13001', '0', 'PUCCH_FORMAT1_DTX']
                                for more information check ta5g_pm_counters documentation
        """
        pm = get_library_instance("ta5g_pm_counters")
        mrbts = BuiltIn().get_variable_value("${MRBTS_ID}")
        nrbts = BuiltIn().get_variable_value("${NRBTS_ID}")
        for cell in cells:
            mo_id = "PLMN-PLMN/MRBTS-{}/NRBTS-{}/NRCELL-{}".format(mrbts, nrbts, cell)
            pm.verify_last_counters_in_file(*counter_list, local_moid=mo_id, file_path=pm_file)

    def check_pm_counters_vdu_with_transient_phase(self, counter_list, pm_file, forced_cells=(1,), num_of_ues=1):
        """
        Validates PM counters consulting transient phase - allowed DTXs are ignored.

        :param counter_list: List of counters to be validated.
        :param pm_file:      Absolute path to file with PM Counters.
        :param forced_cells: List with cell's ids for which counters will be validated.
        :param num_of_ues:      Number of UEs attached in test.
        """
        ues_per_cell = int(num_of_ues) / len(forced_cells)
        dtx_f3_transient_phase = self.get_latest_counter_values_for_cells(
            counter_id='M55303C28002', pm_file=pm_file, cells=forced_cells)
        for cell in forced_cells:
            counter_list = modify_value_in_counter_list(
                counter_list, int(dtx_f3_transient_phase[cell] + ues_per_cell), '<=')
            self.check_pm(pm_file, [cell], counter_list)

    @staticmethod
    def verify_if_any_counter_from_list_incremented(counter_list, counter_file, cells=(1,)):
        """
        The function verifies if any counter from a given counter list incremented


        :param counter_list:    list of pm counters to check with constraints and names to display:
                                counter_list = ['M55303C14001', '>0', 'PUCCH_FORMAT1_NON_DTX',
                                                'M55303C13001', '0', 'PUCCH_FORMAT1_DTX']
                                for more information check ta5g_pm_counters documentation
        :param counter_file:         absolute path to file with PM Counters
        :param cells:           list of nrCellIds
        """
        pm = get_library_instance("ta5g_pm_counters")
        mrbts = BuiltIn().get_variable_value("${MRBTS_ID}")
        nrbts = BuiltIn().get_variable_value("${NRBTS_ID}")
        for cell in cells:
            mo_id = f'PLMN-PLMN/MRBTS-{mrbts}/NRBTS-{nrbts}/NRCELL-{cell}'
            values_list = []
            for counter in counter_list:
                counter_values_list = pm.get_pm_counter_value(counter=counter, localmoid=mo_id, filepath=counter_file)
                counter_value = counter_values_list[-1]
                values_list.append(counter_value)
            sum_values = sum(values_list)

            fail_msg = f'Sum of counters values {sum_values} is not greater than 0. No counter has increased.'
            try:
                assert sum_values > 0, fail_msg
            except AssertionError as e:
                logger.error(fail_msg)
                raise e

    @staticmethod
    def verify_if_counters_from_list_not_incremented(counter_list, first_file, second_file, cells=(1,)):
        """
        The function verifies if any counter from a given counter list incremented

        counter_list(tuple):   Tuple of counters IDs
        first_file(str):       PM counters file that was got in the first phase of the test (e.g before UE attach)
        second_file(str):      PM counters file that was got in the second phase of the test (e.g after e UE attach)
        cells(list):           Cells to check
        """
        pm = get_library_instance("ta5g_pm_counters")
        mrbts = BuiltIn().get_variable_value("${MRBTS_ID}")
        nrbts = BuiltIn().get_variable_value("${NRBTS_ID}")
        for cell in cells:
            mo_id = f'PLMN-PLMN/MRBTS-{mrbts}/NRBTS-{nrbts}/NRCELL-{cell}'
            prev_values_list = []
            next_values_list = []
            for counter in counter_list:
                prev_counter_values_list = pm.get_pm_counter_value(
                    counter=counter, localmoid=mo_id, filepath=first_file)
                prev_counter_value = prev_counter_values_list[-1]
                prev_values_list.append(prev_counter_value)
                next_counter_values_list = pm.get_pm_counter_value(
                    counter=counter, localmoid=mo_id, filepath=second_file)
                next_counter_value = next_counter_values_list[-1]
                next_values_list.append(next_counter_value)
            prev_sum_values = sum(prev_values_list)
            next_sum_values = sum(next_values_list)

            fail_msg = f'Sum of counters values {next_sum_values} is greater than {prev_sum_values}. ' \
                       'Some counter has increased.'
            try:
                assert next_sum_values == prev_sum_values, fail_msg
            except AssertionError as e:
                logger.error(fail_msg)
                raise e
