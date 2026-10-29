"""

Set of KW convert files to other formats

:copyright: Nokia Networks
:author: MN_RAN_PZ_KRK_TAG
:contact: I_MN_RAN_PZ_KRK_TAG@internal.nsn.com
:maintainer: I_MN_RAN_PZ_KRK_TAG@internal.nsn.com
"""

import re
import os
import copy
import json
import shutil
import logging
from datetime import datetime
from testsuite.Wroclaw.RRM.VRF_WRO2_T07.resources.log import blog
from testsuite.Wroclaw.RRM.VRF_WRO2_T07.resources.decorators import logged_keyword
from testsuite.Wroclaw.RRM.VRF_WRO2_T07.classical.max_tput.resources.pdcp_counters import PdcpCounters
from testsuite.Wroclaw.RRM.VRF_WRO2_T04.resources.kpi import prepare_counters_ids, calculate_bler, \
    calculate_mcs, prepare_cells_list, download_scf, get_modulation_scheme_settings_from_scf
import testsuite.Wroclaw.RRM.VRF_WRO2_T07.resources.logs.pm_counters as pm
from testsuite.Wroclaw.RRM.VRF_WRO2_T07.resources.robot_globals import robot_globals
from taf.analyzer.pmcounter.interface import pmcounter
from robot.libraries.BuiltIn import BuiltIn
from ute_ue.utils.param_checker import tput_user_value2normalized
from taf.rfrl.ue.parsers.tput_kpi_parsers import L1L2TracesKPIParser
from taf.rfrl.utilities.scout_interface import GenericScout
from taf.rfrl.utilities.robot.general import get_builtin_instance, get_builtin_value
from taf.rfrl.utilities.test_config import DefaultFileLocation, get_log_path

from taf.rfrl.bts.devices.du.cell_operations import GnbCellOperations
from taf.rfrl.bts.devices.generic_bts import GenericBts
from taf.rfrl.bts.devices.generic_bts import login_logout
from taf.rfrl.bts.tools.nrcellid_calculator import NrCellIdentityCalculator
from taf.rfrl.utilities.reports.excel_report import ExcelReport


@logged_keyword
def report_kpis_and_configuration_to_reporting_portal(protocol, tput_dl=None, tput_ul=None,
                                                      deviation='0%', logs_dir=None, ue_alias='UE', cell_number='3'):
    report_tput_kpis_to_reporting_portal(protocol, tput_dl, tput_ul, deviation, logs_dir, cell_number)
    report_environment_params_to_reporting_portal(ue_alias)


@logged_keyword
def get_throughput_from_pdcp_counters(duration=240, protocol='udp'):
    try:
        return RfKPI().get_tput_calculation_from_pdcp_counters(duration=duration, protocol=protocol)
    except Exception as e:
        logging.warning("Something went wrong during generation throughput values from PDCP counters. More info {}"
                        .format(repr(e)))


@logged_keyword
def report_tput_kpis_to_reporting_portal(protocol, tput_dl=None, tput_ul=None,
                                         deviation='0%', logs_dir=None, cell_number='3'):
    """
     Report most important Tput KPIs to Reporting Portal.
     :param protocol: UDP/TCP
     :param tput_dl: One of parameter tput_dl/tput_ul is required
     :param tput_ul: One of parameter tput_dl/tput_ul is required
     :param deviation: in % - Needs to calculate target
     :param logs_dir: path to logs collected during data transfer eg BIP
     :param cell_number: number of cell
     :return: None
     """
    if tput_dl and tput_ul:
        direction = 'BOTH'
    elif tput_dl:
        direction = 'DL'
    else:
        direction = 'UL'

    tput_kpi = TputKPI()
    tput_kpi.report_tput_results_to_reporting_portal(protocol=protocol, tput_dl=tput_dl, tput_ul=tput_ul,
                                                     deviation=deviation)
    tput_kpi.generate_excel_report()

    try:
        RfKPI().report_rf_kpi_to_reporting_portal(protocol=protocol, direction=direction,
                                                  pcap_dir=logs_dir, cell_number=cell_number)
    except Exception as e:
        logging.warning("Something went wrong during generation KPI from BIP logs. More info {}".format(repr(e)))

    if report_scout_kpi_to_rep_enabled():
        try:
            ScoutKPI(bts_type='GNB').report_pm_kpi_to_reporting_portal()
            # ScoutKPI(bts_type='ENB').report_pm_kpi_to_reporting_portal()
        except Exception as e:
            logging.warning("Something went wrong during generation KPI from SCOUT. More info {}".format(repr(e)))


@logged_keyword
def report_environment_params_to_reporting_portal(ue_alias='UE'):
    """
    Report environment params like bts configuration , UE model to Reporting Portal.
    """
    rep = ReportTestDataWrapper()
    env_conf = EnvironmentConfiguration()
    rep.update_test_data_dictionary(env_conf.prepare_test_data_dictionary_with_bts_configuration())
    rep.update_test_data_dictionary(env_conf.prepare_test_data_dictionary_with_ue_configuration(ue_alias))
    rep.report_test_data_results()


@logged_keyword
def report_scout_kpi_to_rep_enabled():
    if get_builtin_value('PM_PERIOD_START_TIME') and get_builtin_value('PM_PERIOD_END_TIME'):
        return True
    else:
        return False


class ReportKPIWrapper(object):
    """
    Generic class for reporting KPIs to Reporting Portal.
    """

    def __init__(self):
        self.kpi_list = []
        self._kpi_params_template = {
            'name': '',
            'value': '',
            'target': '',
            'description': '',
            'visible_to_db': 'true',
            'kpi_type': 'Throughput',
            'category': 'Performance',
            'unit': '',
        }

    @property
    def current_kpi_template(self):
        return copy.deepcopy(self._kpi_params_template)

    @logged_keyword
    def set_current_kpi_template(self, **kwargs):
        for arg_name in kwargs:
            if arg_name in self._kpi_params_template:
                self._kpi_params_template[arg_name] = str(kwargs[arg_name]) if kwargs[arg_name] is not None else ''
            else:
                logging.warning("Key {} is not supported ".format(arg_name))

    @logged_keyword
    def get_kpi_params(self, **kwargs):
        current_template = self.current_kpi_template
        for arg_name in kwargs:
            if arg_name in self._kpi_params_template:
                current_template[arg_name] = str(kwargs[arg_name])
            else:
                logging.warning("Key {} is not supported ".format(arg_name))

        return current_template

    @logged_keyword
    def add_kpi(self, params):
        """
        Add set of KPI params to kpi_list
        :param params: dictionary or list of dictionary
                       mandatory keys: target, name, visible_to_db, value, kpi_type, description, category, unit
                        common_tput_kpi_params = {
                            'name': 'dl_udp_tput',
                            'value': '200',
                            'target': '160',
                            'description': 'Downlink UDP Throughput',
                            'visible_to_db': 'true',
                            'kpi_type': 'Throughput',
                            'category': 'Performance',
                            'unit': 'bits/sec',
                        }
        :return: Nonel
        """
        if isinstance(params, list):
            self.kpi_list.extend(params)
        else:
            self.kpi_list.append(params)

    @logged_keyword
    def report_all_kpi_results(self):
        """
        Report all kpi results stored in kpi_list
        :return: None
        """
        for params in self.kpi_list:
            BuiltIn().run_keyword('taf.sw.reporting_portal.report_kpi_results',
                                  params['target'],
                                  params['name'],
                                  params['visible_to_db'],
                                  params['value'],
                                  params['kpi_type'],
                                  params['description'],
                                  params['category'],
                                  params['unit'],
                                  )

        self.kpi_list = []


class ReportTestDataWrapper(object):
    """
    Generic class for reporting KPIs to Reporting Portal.
    """
    def __init__(self):
        self.test_data = {}

    @logged_keyword
    def update_test_data_dictionary(self, params):
        """
        Add set of KPI params to test_data dictionary
        :param params: dictionary of test data params - more details:

        https://taf-sw-reporting-portal.docs.taf.ute.nsn-rdnet.net/en/latest/interfaces/interface.html
        :return: None
        """
        self.test_data.update(params)

    @logged_keyword
    def report_test_data_results(self):
        """
        Report all test data params to Reporting Portal
        IMPORTANT - this KW could be call only once during test case!
        :return: None
        """
        json_data = json.dumps(self.test_data)
        BuiltIn().run_keyword('taf.sw.reporting_portal.add_to_test_data', json_data)
        self.test_data = {}


class TputKPI(object):
    """
    Class for reporting throughput KPIs.
    """
    def __init__(self):
        self.rep = ReportKPIWrapper()
        self.rep.set_current_kpi_template(unit='bits/sec')
        self._tput_samples = dict()

    @property
    def tput_samples(self):
        if not self._tput_samples:
            raise ValueError("No tput samples available")
        return self._tput_samples

    @logged_keyword
    def report_tput_results_to_reporting_portal(self, protocol, tput_dl=None, tput_ul=None, deviation='0%'):
        """
        Report set of Tput KPIs to Reporting Portal
        :param protocol: UDP/TCP
        :param tput_dl: One of parameter tput_dl/tput_ul is required
        :param tput_ul: One of parameter tput_dl/tput_ul is required
        :param deviation: in % - Needs to calculate target
        """
        rep_tput_kpi_data = self._prepare_tput_kpi_data(protocol, tput_dl, tput_ul, deviation)
        self.rep.add_kpi(rep_tput_kpi_data)
        self.rep.report_all_kpi_results()

    @logged_keyword
    def generate_excel_report(self, excel_file_path=None):
        """
        Generate excel with tput samples values and graph.
        :param excel_file_path: path of created file. If None file is created in robot logs path.
        :return: None
        """
        if excel_file_path is None:
            excel_file_path = os.path.join(get_log_path(), "tput_kpi_report.xlsx")

        excel_report = ExcelReport(excel_file_path=excel_file_path)
        headers_template = ["SAMPLE", "TPUT bps"]
        headers = []
        data = []
        for sample_name in self.tput_samples.keys():
            sample_values = self.tput_samples[sample_name]
            sample_values = self._convert_bits_to_megabits(sample_values)
            sample_nrs = [i for i in range(len(sample_values))]
            headers.extend(["{} {}".format(sample_name, header) for header in headers_template])
            data.append(sample_nrs)
            data.append(sample_values)

        full_data = list(zip(*data))
        excel_report.create_new_excel_file(headers=headers, data=full_data)
        anchor_row = excel_report.get_max_row() + 3
        while len(headers):
            excel_report.add_graph_to_excel(x_header=headers.pop(0), y_header=headers.pop(0),
                                            title="KPI TPUT Results Mb/s", label="TPUT Mb/s",
                                            anchor="A{}".format(anchor_row))
            anchor_row = anchor_row + 17

    @logged_keyword
    def _convert_bits_to_megabits(self, values):
        """
        Convert list of bit values to Mb rounded to 2 digits.

        :param values: list of values
        :return: list of converted float values
        """
        mega = 1000000.0
        if not isinstance(values, list):
            raise TypeError("Values to convert to Mb should be list of bits")
        converted = [round(float(value)/mega, 2) for value in values]
        return converted

    @logged_keyword
    def _prepare_tput_kpi_data(self, protocol, tput_dl=None, tput_ul=None, deviation='0%'):
        if not tput_dl and not tput_ul:
            raise ValueError("One of parameter 'tput_dl' or 'tput_ul' must be defined")

        kpi_data = []

        if tput_dl:
            kpi_data.extend(self._prepare_tput_kpi_data_for_one_direction(
                protocol=protocol, direction='DL', tput=tput_dl, deviation=deviation))
        if tput_ul:
            kpi_data.extend(self._prepare_tput_kpi_data_for_one_direction(
                protocol=protocol, direction='UL', tput=tput_ul, deviation=deviation))

        return kpi_data

    @logged_keyword
    def _prepare_tput_kpi_data_for_one_direction(self, protocol, direction, tput=None, deviation=None,
                                                 tput_values=None):

        if not tput_values:
            tput_values = self._get_default_data_from_current_test_case(direction, tput, deviation)

        min_kpi_data = self._prepare_min_tput_kpi_data(protocol, direction, value=tput_values['min']['value'])
        avg_kpi_data = self._prepare_avg_tput_kpi_data(protocol, direction,
                                                       value=tput_values['avg']['value'],
                                                       target=tput_values['avg']['target'],)
        max_kpi_data = self._prepare_max_tput_kpi_data(protocol, direction, value=tput_values['max']['value'])

        return [min_kpi_data, avg_kpi_data, max_kpi_data]

    @logged_keyword
    def _get_default_data_from_current_test_case(self, direction, tput, deviation):
        ue = get_builtin_instance('taf.ue')
        tput_data = ue.get_data_transfer_statistics('DT_{}_1'.format(direction.upper())).split(';')
        logging.debug("TPUT DATA: {}".format(tput_data))

        tput_stats = tput_data[0].split(',')
        self._tput_samples[direction] = tput_data[1].split(',')
        tput_values = {
            'min': {
                'value': tput_stats[1],
                'target': ''
            },
            'avg': {
                'value': tput_stats[0],
                'target': self._calculate_target(tput, deviation)
            },
            'max': {
                'value': tput_stats[2],
                'target': ''
            },
        }

        return tput_values

    @logged_keyword
    def _prepare_avg_tput_kpi_data(self, protocol, direction, value, target=''):

        kpi_params = self.rep.get_kpi_params(
            name='avg_{}_{}_tput'.format(direction.lower(), protocol.lower()),
            value=value,
            target=target,
            description='Average {} {} throughput'.format(direction.upper(), protocol.upper()))
        return kpi_params

    @logged_keyword
    def _prepare_min_tput_kpi_data(self, protocol, direction, value, target=''):

        kpi_params = self.rep.get_kpi_params(
            name='min_{}_{}_tput'.format(direction.lower(), protocol.lower()),
            value=value,
            target=target,
            description='Minimum {} {} throughput'.format(direction.upper(), protocol.upper()))
        return kpi_params

    @logged_keyword
    def _prepare_max_tput_kpi_data(self, protocol, direction, value, target=''):

        kpi_params = self.rep.get_kpi_params(
            name='max_{}_{}_tput'.format(direction.lower(), protocol.lower()),
            value=value,
            target=target,
            description='Maximum {} {} throughput'.format(direction.upper(), protocol.upper()))
        return kpi_params

    @staticmethod
    def _calculate_target(tput, deviation):
        def _parse_deviation(dev):
            number = dev.rstrip('%')
            return float(number) / 100.0

        deviation_as_float = _parse_deviation(deviation)
        normalized_tput = tput_user_value2normalized(tput)
        target = normalized_tput - (normalized_tput * deviation_as_float)

        return target


class RfKPI(object):
    """
    Class for reporting RF KPIs calculated from L1L2 BIP traces.
    """
    def __init__(self):
        self.rep = ReportKPIWrapper()
        self.pdcp_counters = PdcpCounters()
        self._release = self._get_sw_release_name()
        self.counter_dir = os.path.join(robot_globals.outputdir(), 'max_tput_counters')
        self.full_counter_dir = os.path.join(self.counter_dir, 'pm_counters')

    @logged_keyword
    def report_rf_kpi_to_reporting_portal(self, protocol, direction, pcap_dir=None, cell_number='3'):
        """
        Report set of Tput KPIs to Reporting Portal
        :param protocol: UDP/TCP
        :param direction: direction of tput - [DL, UL, BOTH]
        :param pcap_dir: directory where BIP pcap are located. If not pass - default location will be used.
        :return:
        """
        rep_rf_kpi_data = self._prepare_rep_kpi_data(protocol, direction, pcap_dir, cell_number)
        self.rep.add_kpi(rep_rf_kpi_data)
        self.rep.report_all_kpi_results()

    @logged_keyword
    def _prepare_rep_kpi_data(self, protocol, direction, pcap_dir=None, cell_number='3'):
        """
        Report set of Tput KPIs to Reporting Portal
        :param protocol: UDP/TCP
        :param direction: direction of tput - [DL, UL, BOTH]
        :param pcap_dir: directory where BIP pcap are located. If not pass - default location will be used.
        :return:
        """
        kpi_data = []
        if not pcap_dir:
            pcap_dir = self._get_default_pcap_logs_location()

        if direction in ['DL', 'BOTH']:
            kpi_data.extend(
                self._prepare_rep_kpi_data_for_one_direction_from_counters(protocol=protocol,
                                                                           direction='DL', cell_number=cell_number))
        if direction in ['UL', 'BOTH']:
            kpi_data.extend(
                self._prepare_rep_kpi_data_for_one_direction_from_counters(protocol=protocol,
                                                                           direction='UL', cell_number=cell_number))

        return kpi_data

    @logged_keyword
    def cleanup_all_downloaded_counter_files(self, counter_dir):
        try:
            shutil.rmtree(counter_dir)
        except OSError as e:
            blog("Can't remove counter directory! Error: {0} : {1}".format(counter_dir, e.strerror))

    @logged_keyword
    def extract_last_values_from_pi_dict(self, pi_dict, counters_count, sum_of_batches=1):
        sum_of_batches = int(sum_of_batches)
        result_dict = {}
        pi_dict = [entry for entry in pi_dict if list(list(entry.values())[0].values())[0] != {}]
        for date_entry in pi_dict[-1 * sum_of_batches * counters_count:]:
            try:
                for cell_id, counter_val in list(list(date_entry.values())[0].values())[0].items():
                    result_dict[list(list(date_entry.values())[0].keys())[0]][cell_id.split('-')[-1]] \
                        += int(counter_val)
            except KeyError:
                result_dict[list(list(date_entry.values())[0].keys())[0]] = \
                    {k.split('-')[-1]: int(v) for (k, v) in list(list(date_entry.values())[0].values())[0].items()}
        return result_dict

    @logged_keyword
    def get_sum_of_n_last_counter_values(self, n_last, counter_ids, pm_counters_path):
        counters_count = len(counter_ids)
        analyzer = pmcounter()
        pi_dict = analyzer.get_pi_value(pi_list=counter_ids, pi_dir=pm_counters_path, pi_file_pattern='PM*')
        value_dict = self.extract_last_values_from_pi_dict(pi_dict, counters_count, n_last)
        return value_dict

    @logged_keyword
    def collect_counters(self):
        pm_counters_path = pm.collect_counters(target_dir=self.counter_dir)
        return pm_counters_path

    @logged_keyword
    def extract_list_of_values_from_counters(self, counter_dict):
        counter_values = []
        for counter in list(counter_dict.values()):
            counter_values.append(list(counter.values())[0])
        return counter_values

    @logged_keyword
    def get_tput_calculation_from_pdcp_counters(self, duration=240, protocol='udp'):
        self.collect_counters()

        num_of_pdcp_sdu_dict = self.get_sum_of_n_last_counter_values(1,
                                                                     self.pdcp_counters.DL_SDU_TX_NSA_QOS_GRP,
                                                                     self.full_counter_dir)
        volume_of_pdcp_sdu_dict = self.get_sum_of_n_last_counter_values(1,
                                                                        self.pdcp_counters.DL_VOL_TX_NSA_QOS_GRP,
                                                                        self.full_counter_dir)

        num_of_pdcp_sdu_values = self.extract_list_of_values_from_counters(num_of_pdcp_sdu_dict)
        volume_of_pdcp_sdu_values = self.extract_list_of_values_from_counters(volume_of_pdcp_sdu_dict)
        packet_size = self.pdcp_counters.get_packet_size(volume_of_pdcp_sdu_values, num_of_pdcp_sdu_values)

        if protocol == 'udp':
            pdcp_sdu_tput = \
                self.pdcp_counters.calculate_nsa_udp_dl_tput_from_pdcp_sdu(counter_values=num_of_pdcp_sdu_values,
                                                                           tput_duration=duration,
                                                                           udp_packet_size=packet_size)
        elif protocol == 'tcp':
            pdcp_sdu_tput = \
                self.pdcp_counters.calculate_nsa_tcp_dl_tput_from_pdcp_sdu(counter_values=num_of_pdcp_sdu_values,
                                                                           tput_duration=duration,
                                                                           tcp_packet_size=packet_size)
        else:
            pdcp_sdu_tput = None
            logging.error("No protocol specified during calculating throughput from PDCP SDUs!")

        pdcp_volume_tput = \
            self.pdcp_counters.calculate_nsa_dl_tput_from_pdcp_volume(counter_values=volume_of_pdcp_sdu_values,
                                                                      tput_duration=duration)
        return pdcp_sdu_tput, pdcp_volume_tput

    @logged_keyword
    def get_bler_and_average_mcs(self, cells_ids='ALL', direction='DL', reporting_interval_pm_number=1):
        try:
            cells_list = prepare_cells_list(cells_ids)
            scf_file = download_scf()
            modulation_schme = get_modulation_scheme_settings_from_scf(scf_file, cells_list)
            counter_ids = prepare_counters_ids(direction)
            self.collect_counters()
            counters_values = self.get_sum_of_n_last_counter_values(
                reporting_interval_pm_number, counter_ids, self.full_counter_dir)
            bler = calculate_bler(counters_values, cells_list, direction, show_on_console=True)
            blog("BLER: {}".format(bler))
            mcs = calculate_mcs(counters_values, cells_list, direction, modulation_schme, show_on_console=True)
            blog("MCS: {}".format(bler))
        finally:
            self.cleanup_all_downloaded_counter_files(self.full_counter_dir)
        return mcs, bler

    @logged_keyword
    def _prepare_rep_kpi_data_for_one_direction_from_counters(self, protocol, direction, cell_number=3):
        mcs, bler = self.get_bler_and_average_mcs(direction=direction)

        if direction in ['DL']:
            beam_kpi_data = self._prepare_beam_kpi_data(protocol, direction, '0')
            blog("beam_kpi_data_dl: {}".format(beam_kpi_data))
            mcs_kpi_data = self._prepare_mcs_kpi_data(protocol, direction, mcs[int(cell_number)]['dl_mcs'])
            blog("mcs_kpi_data_dl: {}".format(mcs_kpi_data))
            bler_kpi_data = self._prepare_bler_kpi_data(protocol, direction, bler[int(cell_number)]['dl_bler'])
            blog("bler_kpi_data_dl: {}".format(bler_kpi_data))
        elif direction in ['UL']:
            beam_kpi_data = self._prepare_beam_kpi_data(protocol, direction, 0)
            blog("beam_kpi_data_ul: {}".format(beam_kpi_data))
            mcs_kpi_data = self._prepare_mcs_kpi_data(protocol, direction, mcs[int(cell_number)]['ul_mcs'])
            blog("mcs_kpi_data_ul: {}".format(mcs_kpi_data))
            bler_kpi_data = self._prepare_bler_kpi_data(protocol, direction, bler[int(cell_number)]['ul_bler'])
            blog("bler_kpi_data_ul: {}".format(bler_kpi_data))
        else:
            blog("Direction parameter is not set to DL or UL!", level='WARN')
            beam_kpi_data = None
            mcs_kpi_data = None
            bler_kpi_data = None

        return [beam_kpi_data, mcs_kpi_data, bler_kpi_data]

    @logged_keyword
    def _prepare_rep_kpi_data_for_one_direction(self, protocol, direction, pcap_dir=None, rfp_values=None):
        """
        Report set of Tput KPIs to Reporting Portal
        :param protocol: UDP/TCP
        :param direction: direction of tput - [DL, UL]
        :param pcap_dir: directory where BIP pcap are located. If not pass - default location will be used.
        :return:
        """

        if not rfp_values:
            rfp_values = self._get_default_data_from_current_test_case(direction, pcap_dir)

        beam_kpi_data = self._prepare_beam_kpi_data(protocol, direction, rfp_values['beam_id']['value'])
        mcs_kpi_data = self._prepare_mcs_kpi_data(protocol, direction, rfp_values['mcs']['value'])
        bler_kpi_data = self._prepare_bler_kpi_data(protocol, direction, rfp_values['bler']['value'])

        return [beam_kpi_data, mcs_kpi_data, bler_kpi_data]

    @staticmethod
    def _get_default_pcap_logs_location():
        log_path = get_builtin_value('LOG_PATH')
        if log_path:
            return os.path.join(log_path, 'data_transfer')
        else:
            logging.error("${LOG_PATH} is required for parsing BIP logs")

    @logged_keyword
    def _get_default_data_from_current_test_case(self, direction, pcap_dir):
        if direction == 'DL':
            beam_id, mcs, bler = self._get_rf_kpi_for_dl(pcap_dir)
        elif direction == 'UL':
            beam_id, mcs, bler = self._get_rf_kpi_for_ul(pcap_dir)

        mcs_avg = mcs.get('avg', None) if mcs else ''

        rfp_values = {
            'beam_id': {
                'value': beam_id,
                'target': ''    # TBD
            },
            'mcs': {
                'value': mcs_avg,
                'target': ''    # TBD
            },
            'bler': {
                'value': bler,
                'target': ''    # TBD
            },
        }

        return rfp_values

    @logged_keyword
    def _prepare_beam_kpi_data(self, protocol, direction, value, target=''):

        kpi_params = self.rep.get_kpi_params(name='{}_{}_beam_id'.format(direction.lower(), protocol.lower()),
                                             value=value,
                                             target=target,
                                             description='{} {} BEAM ID'.format(direction.upper(), protocol.upper()),
                                             unit='#')
        return kpi_params

    @logged_keyword
    def _prepare_mcs_kpi_data(self, protocol, direction, value, target=''):

        kpi_params = self.rep.get_kpi_params(name='{}_{}_mcs'.format(direction.lower(), protocol.lower()),
                                             value=value,
                                             target=target,
                                             description='{} {} MCS'.format(direction.upper(), protocol.upper()),
                                             unit='#')
        return kpi_params

    @logged_keyword
    def _prepare_bler_kpi_data(self, protocol, direction, value, target=''):

        kpi_params = self.rep.get_kpi_params(name='{}_{}_bler'.format(direction.lower(), protocol.lower()),
                                             value=value,
                                             target=target,
                                             description='{} {} BLER'.format(direction.upper(), protocol.upper()),
                                             unit='#')
        return kpi_params

    @logged_keyword
    def _get_rf_kpi_for_dl(self, pcap_dir):
        parser = L1L2TracesKPIParser(release=self._release)
        converted_csv_files = parser.convert_all_pcap_files(pcap_dir=pcap_dir, direction='DL')
        files_for_parsing = " ".join(converted_csv_files)

        beam_id, mcs, bler = ['', '', '']
        if files_for_parsing:
            beam_id = parser.get_beam_id_for_dl(csv_file=files_for_parsing)
            mcs = parser.get_mcs_for_dl(csv_file=files_for_parsing)
            bler = parser.get_bler_for_dl(csv_file=files_for_parsing)

        return beam_id, mcs, bler

    def _get_rf_kpi_for_ul(self, pcap_dir):
        parser = L1L2TracesKPIParser(release=self._release)
        converted_csv_files = parser.convert_all_pcap_files(pcap_dir=pcap_dir, direction='UL')
        files_for_parsing = " ".join(converted_csv_files)

        beam_id, mcs, bler = ['', '', '']
        if files_for_parsing:
            beam_id = parser.get_beam_id_for_ul(csv_file=files_for_parsing)
            mcs = parser.get_mcs_for_ul(csv_file=files_for_parsing)
            bler = parser.get_bler_for_ul(csv_file=files_for_parsing)

        return beam_id, mcs, bler

    @logged_keyword
    def _get_sw_release_name(self, bts_id=0, du_id=0):
        bts = GenericBts()
        bts.connect(bts_id=bts_id, du_id=du_id)
        release = bts.admin.get_sw_release_name(connection=bts.rest_alias.format(bts_id, du_id))
        bts.disconnect(bts_id=bts_id, du_id=du_id)

        return release


class EnvironmentConfiguration(object):
    """
    Class for reporting BTS configuration to Reporting Portal.
    Sample json build by EnvironmentConfiguration class:
            sample_json = {
            'bts_configuration': {
                'pMax': 390,
                'ssPbchBlockPower': 18,
                'p0NominalPucch': -85,
                'p0NominalPusch': -85,
                'p0NominalSrs': -85,
                'cc_dl': 4,
                'cc_ul': 2,
            },
            'ue_model': 'Samsung S10',
            'ue_sw_version': 'QKQ1.200920.00',
        }
    """

    def __init__(self):
        self._cell_configuration = None
        self._nrbts_configuration = None
        self._nrgroup_configuration = None

    @property
    def cell_configuration(self):
        return self._cell_configuration

    @property
    def nrbts_configuration(self):
        return self._nrbts_configuration

    @property
    def nrgroup_configuration(self):
        return self._nrgroup_configuration

    @logged_keyword
    def prepare_test_data_dictionary_with_bts_configuration(self):
        """
        Update test data dictionary with BTS configuration params
        """

        self._cell_configuration = ScfParams().collect_cells_configuration()
        self._nrbts_configuration = ScfParams().get_nrbts_configuration()
        # cell_info = EnvironmentConfiguration._get_attached_cell_and_sector_id()
        # bts_configuration['bts_configuration']['sector_id'] = cell_info['cell_group_id']
        scf_params = []
        scf_params.extend(self._prepare_nrcell_scf_kpi_params())
        scf_params.extend(self._prepare_nrbts_scf_kpi_params())
        scf_params.extend(self._prepare_nrgroup_scf_kpi_params())
        bts_configuration = {
            'bts_configuration': {
                'SCF': scf_params
            }}

        return bts_configuration

    @logged_keyword
    def _prepare_nrcell_scf_kpi_params(self):
        """
        Report cell configuration to reporting portal.
        """
        _re_unit = re.compile(r'(?P<VALUE>\d+)(?P<UNIT>(MHz)|(ms))')
        scf_params = []
        for nrcell_id in self.cell_configuration:
            for scf_param in self.cell_configuration[nrcell_id]:
                value = self.cell_configuration[nrcell_id][scf_param]['value']
                unit = None
                match = _re_unit.search(value)
                if match:
                    value = match.group('VALUE')
                    unit = match.group('UNIT')
                single_param = {
                    "value": value,
                    "name": scf_param,
                    "description": self.cell_configuration[nrcell_id][scf_param]['description'],
                    "object": nrcell_id,
                    "unit": '#'
                }
                if unit:
                    single_param['unit'] = unit

                scf_params.append(single_param)

        return scf_params

    @logged_keyword
    def _prepare_nrbts_scf_kpi_params(self):
        """
        Report NRBTS configuration to reporting portal.
        """
        scf_params = []
        for scf_param in self.nrbts_configuration:
            value = self.nrbts_configuration[scf_param]['value']
            single_param = {
                "value": value,
                "name": scf_param,
                "description": self.nrbts_configuration[scf_param]['description'],
                "object": 'NRBTS',
                "unit": '#'
            }
            scf_params.append(single_param)

        return scf_params

    @logged_keyword
    def _prepare_nrgroup_scf_kpi_params(self):
        """
        Report NRCELLGRP configuration to reporting portal.
        """
        self._nrgroup_configuration = ScfParams().get_nrcellgrp_configuration()
        scf_params = []
        for scf_param in self.nrgroup_configuration:
            value = self.nrgroup_configuration[scf_param]['value']
            single_param = {
                "value": value,
                "name": scf_param,
                "description": self.nrgroup_configuration[scf_param]['description'],
                "object": 'NRCELLGRP',
                "unit": '#'
            }

            scf_params.append(single_param)

        return scf_params

    @staticmethod
    def prepare_test_data_dictionary_with_ue_configuration(ue_alias='UE'):
        """
        Report set of UE configuration params to Reporting Portal
        """
        # TODO need to add IMEI
        ue_params = {}
        ue = get_builtin_instance('taf.ue')

        ue_params['ue_model'] = ue.get_ue_info(ue_alias, 'DEVICE_MODEL')
        try:
            ue_params['ue_sw_version'] = ue.get_ue_info(ue_alias, 'UE_FIRMWARE_VERSION')
        except Exception as e:
            logging.warning("Cannot collect UE FIRMWARE VERSION from UE. {}".format(repr(e)))

        return ue_params

    @staticmethod
    def _get_attached_cell_and_sector_id():
        params = {}
        uav = get_builtin_instance('krk_resources.devices.ue.ue_attach_verification.UeAttachVerification')
        if uav.nr_cell_id:
            logging.debug("Get global cell id based on NR_CELL_ID={}".format(uav.nr_cell_id))
            global_cell_id = NrCellIdentityCalculator().calculate_global_cell_id(uav.nr_cell_id)
            logging.debug("Get Sector ID based on GLOBAL_CELL_ID={}".format(global_cell_id))
            cell_group_id_info = GnbCellOperations().get_cell_group_id_linked_to_cell_id(cell_id=global_cell_id,
                                                                                         cell_id_type='global')
            cell_group_id = cell_group_id_info.get('ID', None) if cell_group_id_info else ''
            logging.debug("NR_CELL_ID={}, GLOBAL_CELL_ID={}, SECTOR_ID={}".format(uav.nr_cell_id,
                                                                                  global_cell_id, cell_group_id))
            params = {
                'cell_id': global_cell_id,
                'cell_group_id': cell_group_id
            }
        return params


class ScfParams(GnbCellOperations):
    """
    Class for reporting selected SCF configuration params to Reporting Portal.
    """
    _re_integer = re.compile(r'^(\d+)')

    @login_logout
    def collect_cells_configuration(self, bts_id=0, du_id=0):
        """
        Collect basic cell configuration.
        :param bts_id:          BTS id - related to Test Line configuration. Default: 0
        :param du_id:           DU id(Distributed Unit) - id related to Test Line configuration - gnb.dus[]
        :return:
        """
        cells_configuration = {}
        cell_params_rep = {
            'pMax': 'Maximum output power',
            'ssPbchBlockPower': 'SS PBCH Block Power',
            'p0NominalPucch': 'P0 nominal PUCCH',
            'p0NominalPusch': 'P0 nominal PUSCH',
            'p0NominalSrs': 'P0 nominal SRS',
            'dlMimoMode': 'Downlink MIMO Mode',
            'ulMimoMode': 'Uplink MIMO mode',
            'actPRBBlanking': 'Activate PRB blanking',
            'actDl256Qam': 'Activate 256QAM in DL',
            'dlDMRSAdditionalPosition': 'Downlink DMRS additional position',
            'ulDMRSAdditionalPosition': 'Uplink DMRS additional position',
            'actPrachMultiplexing': 'Activate PRACH slot uplink channel multiplexing',
            'actPdschAtSsbSlots': 'Activate PDSCH at SSB slots',
            'csirsTrackingPeriod': 'CSI-RS Tracking Period',
            'actAperCsi': 'Activate aperiodic CSI reporting',
            'prachConfigurationIndex': 'PRACH configuration index',
            'pucchModeSelect': 'PUCCH mode selection',
            'actPcsiOnF2Fdm': 'Activate Periodic CSI FDM',
            'cellDepType': 'Cell deployment type',
            'maxNrDssRatio': 'Maximum LTE-NR downlink sharing ratio',
            'minNrDssRatio': 'Minimum LTE-NR downlink sharing ratio',
            'actDynUlDataSplitMode': 'Activate dynamic UL data split mode',
        }
        cell_id_list = self._get_all_global_cell_ids(bts_id=bts_id, du_id=du_id)
        for cell_id in cell_id_list:
            cell_params = self.get_cell_parameters(bts_id=bts_id, du_id=du_id, cell_id=cell_id)
            if cell_params['cellTechnology'] == 'FDD':
                fdd_params = self._get_fdd_cell_parameters(bts_id=bts_id, du_id=du_id, cell_id=cell_id)
                cell_params.update(fdd_params)
            nrcell_id = "NRCELL-{}".format(cell_id)

            cells_configuration[nrcell_id] = {}
            for param in cell_params_rep:
                value = cell_params.get(param, '')
                if value:
                    cells_configuration[nrcell_id][param] = {}
                    cells_configuration[nrcell_id][param]['value'] = value
                    cells_configuration[nrcell_id][param]['description'] = cell_params_rep[param]
            cells_configuration[nrcell_id].update(self._get_bw_configuration(cell_params))

        logging.debug("All cell configuration: {}".format(cells_configuration))

        return cells_configuration

    @login_logout
    def get_nrbts_configuration(self, bts_id=0, du_id=0):
        """
        Collect number of CC for DL and UL.
        :param bts_id:          BTS id - related to Test Line configuration. Default: 0
        :param du_id:           DU id(Distributed Unit) - id related to Test Line configuration - gnb.dus[]
        :return:
        """
        nrbts_params_rep = {
            'actLteNrDss': 'Activate LTE-NR dynamic spectrum sharing',
            'actEnhancedLinkAdaptation': 'Activate the enhanced link adaptation procedures',
            'ssBurstSetPeriod': 'SS Burst Set Period',
            'actFdmScheduling': 'Activate frequency domain scheduling',
            'actFdmEnhancedScheduling': 'Activate enhanced frequency domain scheduling',
            'gNbCuType': 'gNB CU type',
            'sCellActivationMethod': 'Secondary cells Activation Method',
        }
        dist_name = self.adjust_dist_name("MRBTS-{}/NRBTS-{}", bts_id=bts_id, du_id=du_id)
        nrbts_info = self._get_object_parameters_dict(dist_name=dist_name, bts_id=bts_id, du_id=du_id)

        nrbts_config = {}
        for param in nrbts_params_rep:
            value = nrbts_info.get(param, '')
            if value:
                nrbts_config[param] = {}
                nrbts_config[param]['value'] = value
                nrbts_config[param]['description'] = nrbts_params_rep[param]

        nrbts_config.update(
            {

                'cc_dl': {'value': int(nrbts_info.get('maxNumScellsDl', 0)) + 1,
                          'description': 'Downlink Carrier Cell aggregation'},
                'cc_ul': {'value': int(nrbts_info.get('maxNumScellsUl', 0)) + 1,
                          'description': 'Uplink Carrier Cell aggregation'}
            })

        logging.debug("NRBTS configuration: {}".format(nrbts_config))

        return nrbts_config

    @login_logout
    def get_nrcellgrp_configuration(self, bts_id=0, du_id=0):
        """
        Collect NRCELLGRP info.
        :param bts_id:          BTS id - related to Test Line configuration. Default: 0
        :param du_id:           DU id(Distributed Unit) - id related to Test Line configuration - gnb.dus[]
        :return:
        """
        nrcellgrp_params_rep = {
            'actProactUlScheduling': 'Activate UL proactive scheduling',
        }
        nrcellgrp_config = {}
        core_dist_name = self.adjust_dist_name("MRBTS-{}/NRBTS-{}", bts_id=bts_id, du_id=du_id)
        cell_groups_info = self._get_cell_groups_info(bts_id=bts_id, du_id=du_id)
        for cell_group in cell_groups_info:

            nrcellgroup_dist_name = "{}/{}".format(core_dist_name, cell_group['name'])
            logging.debug("NR CELL GROUP dist name: {}".format(nrcellgroup_dist_name))
            nrcellgroup_info = self._get_object_parameters_dict(dist_name=nrcellgroup_dist_name,
                                                                bts_id=bts_id, du_id=du_id)
            logging.debug("NRCELLGRP Info: {}".format(nrcellgroup_info))

            for param in nrcellgrp_params_rep:
                value = nrcellgroup_info.get(param, '')
                if value:
                    nrcellgrp_config[param] = {}
                    nrcellgrp_config[param]['value'] = value
                    nrcellgrp_config[param]['description'] = nrcellgrp_params_rep[param]

        logging.debug("NRCELLGRP configuration: {}".format(nrcellgrp_config))

        return nrcellgrp_config

    @login_logout
    def _get_fdd_cell_parameters(self, bts_id=0, cell_id=1, du_id=0):
        dist_name = self.adjust_dist_name("MRBTS-{}/NRBTS-{}", bts_id=bts_id, du_id=du_id)
        fdd_params = self._get_object_parameters_dict(dist_name="{}/NRCELL-{}/NRCELL_FDD-1".format(dist_name, cell_id),
                                                      bts_id=bts_id, du_id=du_id)
        return fdd_params

    @staticmethod
    def _get_int_value_from_string(string_value):
        int_value = 0
        if string_value:
            match = ScfParams._re_integer.search(string_value)
            if match:
                int_value = match.group(0)

        return int_value

    @staticmethod
    def _get_bw_configuration(cell_params):
        # For FDD need to use chBwDl/chBwUl param
        params = {}
        if 'chBwDl' in cell_params and 'chBwUl' in cell_params:
            params['chBwDl'] = {
                'value': cell_params['chBwDl'],
                'description': 'Downlink Channel bandwidth',
            }
            params['chBwUl'] = {
                'value': cell_params['chBwUl'],
                'description': 'Uplink Channel bandwidth',
            }
        else:
            params['chBw'] = {
                'value': cell_params['chBw'],
                'description': 'Channel bandwidth',
            }

        return params


class ScoutKPI(GenericScout):
    """
    Class for generating KPI results for current test case
    """
    SCOUT_KPI_TEMPLATES = {
        # 20A
        'NSA_GNB_KPI_TPUT_5G20A': 102,
        'NSA_ENB_KPI_TPUT_5G20A': 103,
        'SA_ENB_KPI_TPUT_5G20A': 103,
        # 20B
        'NSA_GNB_KPI_TPUT_5G20B': 114,
    }

    def __init__(self, test_line_name=None, bts_type='GNB'):
        super(ScoutKPI, self).__init__(test_line_name=test_line_name, bts_type=bts_type)
        self.rep = ReportKPIWrapper()

    @logged_keyword
    def report_pm_kpi_to_reporting_portal(self, kpi_data=None):
        if not kpi_data:
            kpi_data = self.generate_kpi_report_from_scout_for_current_test_case()

        rep_kpi_data = self._prepare_rep_kpi_data(kpi_data)
        self.rep.add_kpi(rep_kpi_data)
        self.rep.report_all_kpi_results()

    @logged_keyword
    def _prepare_rep_kpi_data(self, kpi_data):
        """
        Prepare data for Reporting Portal.
        :param kpi_data:
        :return: rep_kpi_data
        """
        rep_kpi_data = []

        if kpi_data:
            for kpi in kpi_data:
                kpi_params = self.rep.get_kpi_params(name=kpi['code'],
                                                     value=self._get_value(kpi['global_result']['value']),
                                                     target=self._get_target(kpi['start_range'], kpi['end_range']),
                                                     description=kpi['name'],
                                                     unit=kpi.get('unit', '#'))
                rep_kpi_data.append(kpi_params)

        return rep_kpi_data

    @staticmethod
    def _get_target(start_range, end_range):
        target = '{};{}'.format(start_range, end_range) if start_range and end_range else ''
        return target

    @staticmethod
    def _get_value(value):
        kpi_value = round(float(value), 3) if value else ''
        return kpi_value

    @logged_keyword
    def generate_kpi_report_from_scout_for_current_test_case(self):
        """
        Collect KPI results from current test case - all needed parameters are generated automatically.
        :return: KPI report as a dict
        """
        template_name = self._get_kpi_template_name()
        kpi_report_name = "{}_{}".format(get_builtin_value('TEST NAME', ''), template_name)
        template_id = self._get_kpi_template_id(template_name)
        start_time, end_time = self._get_start_and_end_time()
        if start_time and end_time:
            self.wait_for_kpi_data_available_in_scoaut(start_time)
            return self.generate_kpi_report_on_the_scout(report_name=kpi_report_name, kpi_template_id=template_id,
                                                         start_time=start_time, end_time=end_time)
        else:
            logging.warning("Cannot gather scout KPI report because of lack of defined ${PM_PERIOD_START_TIME} or "
                            "${PM_PERIOD_END_TIME}")

    @logged_keyword
    def _get_kpi_template_name(self):
        # TODO Another option could be define variable in the robot test case eg SCOUT_KPI_TEMPLATE_NAME and
        #  use it if defined
        branch = DefaultFileLocation().get_commissioning_branch()
        template_name = 'NSA_{}_KPI_TPUT_{}'.format(self.bts_type.upper(), branch)
        return template_name

    @staticmethod
    def _get_kpi_template_id(template_name):
        return ScoutKPI.SCOUT_KPI_TEMPLATES.get(template_name, None)

    @staticmethod
    def _get_start_and_end_time():
        start_time = datetime.utcfromtimestamp(get_builtin_value('PM_PERIOD_START_TIME'))
        end_time = datetime.utcfromtimestamp(get_builtin_value('PM_PERIOD_END_TIME'))
        return start_time.isoformat(), end_time.isoformat()
