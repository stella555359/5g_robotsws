# -*- coding: utf-8 -*-
"""
:copyright: Nokia Networks
:author: Gall Anonim
:maintainer: Mateusz Bilewicz
:contact: mateusz.bilewicz@nokia.com
:team: MN_RAN_L2_SW_WRO_7_SG
"""
import os
import re
import time
import tarfile
import xml.etree.ElementTree as ET
from robot.libraries.BuiltIn import BuiltIn
from taf.selenium.gnb.oam.coam.cu import cu as cu_selenium
from robot.api import logger
from testsuite.Wroclaw.RRM.VRF_WRO1_T04.L2PS_WRO.resources.Python.common_vcu import vCU
from testsuite.Wroclaw.RRM.VRF_WRO1_T04.L2PS_WRO.resources.Python.common_vdu import vDU
from testsuite.Wroclaw.RRM.VRF_WRO1_T04.L2PS_WRO.resources.Python.file_management import download_files_from
from testsuite.Wroclaw.RRM.VRF_WRO1_T04.L2PS_WRO.resources.Python.shell_management import (
    shell_session_vdu, shell_session_vcu, go_to_the_container, get_vdu_namespace,
    download_file_from_container_to_vdu, get_vcu_master_ip, get_vdu_master_ip)
from testsuite.Wroclaw.RRM.VRF_WRO1_T04.L2PS_WRO.resources.Python.file_management import copy_files_from_local_to_local
from testsuite.Wroclaw.RRM.VRF_WRO1_T04.L2PS_WRO.resources.Python.pm_counters import (
    get_library_instance, modify_value_in_counter_list, wait_for_next_pm_period_aic)


class CountersCU(vCU):
    """
    Counters vCU Class

    Collect and verifies pm counters from vCU
    """

    def get_pm_counter(self, object_class_name=' ', counter_id='M55323C00001', object_name='NRBTS'):
        """Gets pm counter values from vCU

        :param object_class_name: str, object class name to filtered (should be empty for all objects to filter)
        :param counter_id: str, counter ID for filtering the object tree of pm counters eg: M55323C00001
        :param object_name: str, object name to be filtered
        """
        connection = cu_selenium()
        try:
            connection.login(url='https://192.168.100.129/login')
            pm_counter = connection.get_pm_counters(object_class_name, counter_id, object_name)
            file = pm_counter['file']
            return file, pm_counter['counters']
        finally:
            connection.logout()

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

        data = ET.Element('PMSetup')
        element1 = ET.SubElement(data, 'PMMOResult')
        s_elem = ET.SubElement(element1, 'MO')
        s_elem.text = mo_id
        for counter in counter_list:
            if counter.startswith('M'):
                file, values = self.get_pm_counter(object_class_name, counter, object_name)
                copy_files_from_local_to_local(file, out_dir)
                values = values[0]
                counter_values = {}
                for key, value in values.items():
                    if re.match(
                            '[0-9]{4}-(0[1-9]|1[0-2])-(0[1-9]|[1-2][0-9]|3[0-1]) (2[0-3]|[01][0-9]):[0-5][0-9]:[0-5]['
                            '0-9]',
                            key):
                        counter_values[key] = value
                maxdate = max(counter_values)
                s_elem1 = ET.SubElement(element1, counter)
                s_elem1.text = counter_values[maxdate]

            b_xml = ET.tostring(data)
            with open("{}/vCU_pm_counters.xml".format(out_dir), "wb") as f:
                f.write(b_xml)
        logger.info("Pm Counters for vCU: ", also_console=True)
        pm.verify_last_counters_in_file(*counter_list, local_moid=mo_id,
                                        file_path="{}/vCU_pm_counters.xml".format(out_dir))

    @staticmethod
    def wait_for_next_pm_counter_files_to_generate():
        """
        Waits until next Measurement Period starts and compares generated files from before it with current ones until
        there is a difference and required files are present.

        """
        path_in_container = '/var/opt/nokia/performancemanagement/storage/results'
        cmd = 'ls -t | grep MRBTS | head -n 50'
        with shell_session_vcu(host=get_vcu_master_ip()) as handler:
            container = get_vdu_namespace()
            go_to_the_container(handler, container, 'pmcore', 'pm-0')
            handler.execute(cmd='cd {}'.format(path_in_container))
            shin, files, sherr = handler.execute(cmd=cmd)
        logger.console('Waiting for next Measurement Period...')
        wait_for_next_pm_period_aic()
        logger.console('Waiting for new PM Counters files to generate...')
        with shell_session_vcu(host=get_vcu_master_ip()) as handler:
            go_to_the_container(handler, container, 'pmcore', 'pm-0')
            handler.execute(cmd='cd {}'.format(path_in_container))
            while True:
                shin, new_files, sherr = handler.execute(cmd=cmd)
                new_files = filter(lambda a: 'xml.gz\n' in a, new_files)
                if files != new_files:
                    break
                time.sleep(30)

    @staticmethod
    def get_latest_pm_counters_file_from_vcu(counter_file='pm_counters.xml', rad_counters=False):
        """
        Downloads latest PM Counters files from vCU and merges them into one xml file for ta5g_pm_counters

        :param counter_file:    (str) Name of merged PM Counters file.
        :param rad_counters:    (bool) Get RAD counters when true.

        :return:                (str) Path to merged PM Counters file.
        """
        out_dir = BuiltIn().get_variable_value("${OUTPUT_DIR}")
        suite_name = BuiltIn().get_variable_value("${SUITE_NAME}")
        out_dir = os.path.join(out_dir, suite_name, counter_file.split('.')[0])
        if not os.path.exists(out_dir):
            os.mkdir(out_dir)
        for file in os.listdir(out_dir):
            os.remove(os.path.join(out_dir, file))
        if rad_counters:
            path_in_container = '/var/opt/nokia/performancemanagement/storage/RD_results'
        else:
            path_in_container = '/var/opt/nokia/performancemanagement/storage/results'
        with shell_session_vcu(host=get_vcu_master_ip()) as handler:
            container = get_vdu_namespace()
            go_to_the_container(handler, container, 'pmcore', 'pm-0')
            handler.execute(cmd='cd {}'.format(path_in_container))
            shin, files, sherr = handler.execute(cmd='ls -t | grep MRBTS | head -n 50')
            files = filter(lambda a: 'xml.gz\n' in a, files)
            period_ends = [int(file.split('-')[1].split('+')[0].split('.')[1]) for file in files]
            cmd = 'tar czf pm_counters.txz $(ls -t | head -n 50 | grep {})'.format(str(max(period_ends)))
            handler.execute(cmd=cmd)
        with shell_session_vcu(host=get_vcu_master_ip()) as handler:
            download_file_from_container_to_vdu(handler, container, 'pmcore', 'pm-0',
                                                '{}/pm_counters.txz'.format(path_in_container))
        file_path_vcu = '/var/home/core/pm_counters.txz'
        file_path_local = os.path.join(out_dir, 'pm_counters.txz')
        download_files_from(get_vcu_master_ip(), 'core', 'system123', file_path_vcu,
                            file_path_local)
        pm_archive_file = tarfile.open(file_path_local)
        try:
            pm_archive_file.extractall(out_dir)
        except EOFError:
            pass
        pm_archive_file.close()
        os.remove(file_path_local)

        files = [file for file in os.listdir(out_dir) if 'MRBTS' in str(file)]
        paths = [str(os.path.join(out_dir, basename)) for basename in files]

        os.system('gzip -d {}'.format(" ".join(paths)))
        paths = [path.strip('.gz') for path in paths]
        out_file = ET.parse(paths[0])
        out_file_root = out_file.getroot()
        pmsetup = out_file_root.find('PMSetup')

        for file in paths[1:]:
            tree = ET.parse(file)
            root = tree.getroot()
            pmmoresult = root.find('./PMSetup')
            pmsetup.append(pmmoresult)
        out_file.write('{}/{}'.format(out_dir, counter_file))

        return '{}/{}'.format(out_dir, counter_file)


class CountersDU(vDU):
    """
    Counters vDU Class

    Collect and verifies pm counters from vDU
    """

    def get_measurement_data(self):
        """Gets all the current measurements on vDU

        :return: list of dicts containing measurements information
        """
        with self.vdu_session() as connection:
            measurements = connection.get_measurements()
            return measurements

    def get_latest_pm_counter_value(self, mrbts_id, nrbts_id, counter_id, cell=1):
        """Gets latest pm counter value from vDU

        :param mrbts_id: mrbts id
        :param nrbts_id: nrbts id
        :param counter_id: counter id eg: M55117C02003
        :param cell: cell id
        """
        dimension_dn = "MRBTS-{}/NRBTS-{}/NRCELL-{}".format(mrbts_id, nrbts_id, cell)
        with self.vdu_session() as connection:
            pm_counter = connection.get_counter_values(counter_id, dimension_dn, vdu_connection='default')
            return pm_counter[-1]['start_time'], pm_counter[-1]['value']

    def verify_if_counter_is_incremented_correctly(self, mrbts_id, nrbts_id, cells=[1], counter_id='M55306C06001',
                                                   expected_value=0):
        """Checks if selected counter has specified expected value

        :param mrbts_id: mrbts id
        :param nrbts_id: nrbts id
        :param counter_id: counter id eg: M55117C02003
        :param cells: cell id as denoted in SCF by NRCELL object
        :param expected_value: value that is expected of the counter
        """
        for cell in cells:
            period, counter_value = self.get_latest_pm_counter_value(mrbts_id, nrbts_id, counter_id, cell)
            print("Counter value: {} Counter period: {}".format(counter_value, period))
            assert int(counter_value) == expected_value, "Value for period {} is {} but expected is {}". \
                format(period, counter_value, expected_value)

    def save_latest_pm_counters_to_xml(self, mrbts_id, nrbts_id, cell, counter_list=None, file_name='pmcounter.xml'):
        out_dir = BuiltIn().get_variable_value("${OUTPUT_DIR}")
        data = ET.Element('PMSetup')
        element1 = ET.SubElement(data, 'PMMOResult')

        s_elem = ET.SubElement(element1, 'MO')
        mo_id = "MRBTS-{}/NRBTS-{}/NRCELL-{}".format(mrbts_id, nrbts_id, cell)
        s_elem.text = mo_id
        for counter in counter_list:
            if counter.startswith('M'):
                period, counter_value = self.get_latest_pm_counter_value(mrbts_id, nrbts_id, counter, cell)
                s_elem1 = ET.SubElement(element1, counter)
                s_elem1.text = counter_value

            b_xml = ET.tostring(data)
            with open("{}/pmcounter.xml".format(out_dir), "wb") as f:
                f.write(b_xml)
        return "{}/{}".format(out_dir, file_name)

    @staticmethod
    def wait_for_next_pm_counter_files_to_generate():
        """
        Waits until next Measurement Period starts and compares generated files from before it with current ones until
        there is a difference and required files are present.

        """
        path_in_container = '/var/opt/nokia/performancemanagement/storage/results'
        cmd = 'ls -t | grep MRBTS | head -n 30'
        with shell_session_vdu(host=get_vdu_master_ip()) as handler:
            container = get_vdu_namespace()
            go_to_the_container(handler, container, 'pmcore', 'pm-0')
            handler.execute(cmd='cd {}'.format(path_in_container))
            shin, files, sherr = handler.execute(cmd=cmd)
        logger.console('Waiting for next Measurement Period...')
        wait_for_next_pm_period_aic()
        logger.console('Waiting for new PM Counters files to generate...')
        with shell_session_vdu(host=get_vdu_master_ip()) as handler:
            go_to_the_container(handler, container, 'pmcore', 'pm-0')
            handler.execute(cmd='cd {}'.format(path_in_container))
            while True:
                shin, new_files, sherr = handler.execute(cmd=cmd)
                new_files = filter(lambda a: 'xml.gz\n' in a, new_files)
                if files != new_files:
                    break
                time.sleep(30)

    @staticmethod
    def get_latest_pm_counters_file_from_vdu(counter_file='pm_counters.xml', rad_counters=False):
        """
        Downloads latest PM Counters files from vDU and merges them into one xml file for ta5g_pm_counters

        :param counter_file:    (str) Name of merged PM Counters file.
        :param rad_counters:    (bool) Get RAD counters when true.

        :return:                (str) Path to merged PM Counters file.
        """
        out_dir = BuiltIn().get_variable_value("${OUTPUT_DIR}")
        suite_name = BuiltIn().get_variable_value("${SUITE_NAME}")
        out_dir = os.path.join(out_dir, suite_name, counter_file.split('.')[0])
        if not os.path.exists(out_dir):
            os.mkdir(out_dir)
        for file in os.listdir(out_dir):
            os.remove(os.path.join(out_dir, file))
        if rad_counters:
            path_in_container = '/var/opt/nokia/performancemanagement/storage/RD_results'
        else:
            path_in_container = '/var/opt/nokia/performancemanagement/storage/results'
        with shell_session_vdu(host=get_vdu_master_ip()) as handler:
            container = get_vdu_namespace()
            go_to_the_container(handler, container, 'pmcore', 'pm-0')
            handler.execute(cmd='cd {}'.format(path_in_container))
            shin, files, sherr = handler.execute(cmd='ls -t | grep MRBTS | head -n 40')
            files = filter(lambda a: 'xml.gz\n' in a, files)
            period_ends = [int(file.split('-')[1].split('+')[0].split('.')[1]) for file in files]
            cmd = 'tar czf pm_counters.txz $(ls -t | head -n 40 | grep {})'.format(str(max(period_ends)))
            handler.execute(cmd=cmd)
        with shell_session_vdu(host=get_vdu_master_ip()) as handler:
            download_file_from_container_to_vdu(handler, container, 'pmcore', 'pm-0',
                                                '{}/pm_counters.txz'.format(path_in_container))
        file_path_vdu = '/var/home/core/pm_counters.txz'
        file_path_local = os.path.join(out_dir, 'pm_counters.txz')
        download_files_from(get_vdu_master_ip(), 'core', 'system123', file_path_vdu, file_path_local)
        pm_archive_file = tarfile.open(file_path_local)
        try:
            pm_archive_file.extractall(out_dir)
        except EOFError:
            pass
        pm_archive_file.close()
        os.remove(file_path_local)

        files = [file for file in os.listdir(out_dir) if 'MRBTS' in str(file)]
        paths = [str(os.path.join(out_dir, basename)) for basename in files]

        os.system('gzip -d {}'.format(" ".join(paths)))
        paths = [path.strip('.gz') for path in paths]
        out_file = ET.parse(paths[0])
        out_file_root = out_file.getroot()
        pmsetup = out_file_root.find('PMSetup')

        for file in paths[1:]:
            tree = ET.parse(file)
            root = tree.getroot()
            pmmoresult = root.find('./PMSetup/PMMOResult')
            pmsetup.append(pmmoresult)
        out_file.write('{}/{}'.format(out_dir, counter_file))

        return '{}/{}'.format(out_dir, counter_file)

    def store_latest_pm_counters_in_dict(self, mrbts_id, nrbts_id, cell, counter_list=None):
        counters_with_values = dict()
        for counter in counter_list:
            if counter.startswith('M'):
                period, counter_value = self.get_latest_pm_counter_value(mrbts_id, nrbts_id, counter, cell)
                counters_with_values[counter] = int(counter_value)
        return counters_with_values

    def get_pm_counters_vdu(self, mrbts_id, nrbts_id, cells=[1], counter_list=None):
        """Get pm counter

        :param mrbts_id: mrbts id
        :param nrbts_id: nrbts id
        :param cells: number of cells
        :param counter_list:    list of pm counters to check with constraints and names to display:
                                counter_list = ['M55303C14001', '>0', 'PUCCH_FORMAT1_NON_DTX',
                                                'M55303C13001', '0', 'PUCCH_FORMAT1_DTX']
        """

        pm = get_library_instance("ta5g_pm_counters")
        for cell in cells:
            counters_xml = self.save_latest_pm_counters_to_xml(mrbts_id, nrbts_id, cell, counter_list)
            mo_id = "MRBTS-{}/NRBTS-{}/NRCELL-{}".format(mrbts_id, nrbts_id, cell)
            logger.info("Pm Counters for vDU: ", also_console=True)
            pm.verify_last_counters_in_file(*counter_list, local_moid=mo_id,
                                            file_path=counters_xml)

    @staticmethod
    def get_latest_counter_values_for_cells(counter_id, pm_file, cells=[1]):
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
    def check_pm(pm_file, cells=[1], counter_list=None):
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

    def check_pm_counters_vdu_with_transient_phase(self, counter_list, pm_file, forced_cells=[1], num_of_ues=1):
        """
        Validates PM counters consulting transient phase - allowed DTXs are ignored.

        :param counter_list: List of counters to be validated.
        :param pm_file:      Absolute path to file with PM Counters.
        :param forced_cells: List with cell's ids for which counters will be validated.
        :param num_of_ues:      Number of UEs attached in test.
        """
        ues_per_cell = int(num_of_ues) / len(forced_cells)
        dtx_f3_transient_phase = self.get_latest_counter_values_for_cells(counter_id='M55303C28002', pm_file=pm_file,
                                                                          cells=forced_cells)
        for cell in forced_cells:
            counter_list = modify_value_in_counter_list(counter_list,
                                                        int(dtx_f3_transient_phase[cell] + ues_per_cell), '<=')
            self.check_pm(pm_file, [cell], counter_list)

    @staticmethod
    def verify_if_any_counter_from_list_incremented(counter_list, counter_file, cells=[1]):
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
            mo_id = 'PLMN-PLMN/MRBTS-{}/NRBTS-{}/NRCELL-{}'.format(mrbts, nrbts, cell)
            values_list = list()
            for counter in counter_list:
                counter_values_list = pm.get_pm_counter_value(counter=counter, localmoid=mo_id, filepath=counter_file)
                counter_value = counter_values_list[-1]
                values_list.append(counter_value)
            sum_values = sum(values_list)
            assert sum_values > 0, \
                'Sum of counters values {} is not greater than 0. No counter has increased.'.format(sum_values)

    @staticmethod
    def verify_if_counters_from_list_not_incremented(counter_list, first_file, second_file, cells=[1]):
        """
        The function verifies if any counter from a given counter list incremented

        counter_list(list):    List of counters IDs
        first_file(str):       PM counters file that was got in the first phase of the test (e.g before UE attach)
        second_file(str):      PM counters file that was got in the second phase of the test (e.g after e UE attach)
        cells(list):           Cells to check
        """
        pm = get_library_instance("ta5g_pm_counters")
        mrbts = BuiltIn().get_variable_value("${MRBTS_ID}")
        nrbts = BuiltIn().get_variable_value("${NRBTS_ID}")
        for cell in cells:
            mo_id = 'PLMN-PLMN/MRBTS-{}/NRBTS-{}/NRCELL-{}'.format(mrbts, nrbts, cell)
            prev_values_list = list()
            next_values_list = list()
            for counter in counter_list:
                prev_counter_values_list = pm.get_pm_counter_value(counter=counter, localmoid=mo_id,
                                                                   filepath=first_file)
                prev_counter_value = prev_counter_values_list[-1]
                prev_values_list.append(prev_counter_value)
                next_counter_values_list = pm.get_pm_counter_value(counter=counter, localmoid=mo_id,
                                                                   filepath=second_file)
                next_counter_value = next_counter_values_list[-1]
                next_values_list.append(next_counter_value)
            prev_sum_values = sum(prev_values_list)
            next_sum_values = sum(next_values_list)
            assert next_sum_values == prev_sum_values, \
                'Sum of counters values {} is greater than {}. Some counter has increased.'.format(next_sum_values,
                                                                                                   prev_sum_values)
