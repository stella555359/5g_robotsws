"""

Set of PROPSIM Keywords used for setting IN/OUT ports and reading current values.

:copyright: Nokia Networks
:author: I_MN_5GSC_KRK_AUTO
:contact: I_MN_5GSC_KRK_AUTO@internal.nsn.com
:maintainer: I_MN_5GSC_KRK_AUTO
:contact: I_MN_5GSC_KRK_AUTO@internal.nsn.com
"""


import six
import os
import csv
import re
import math
import logging
from openpyxl import Workbook
from taf.analyzer.sherpa.interface import sherpa
from taf.rfrl.ue.parsers.qxdm_parser import QxdmLogParser
from local_pc_keywords import get_list_of_files_on_local_pc


class CsvReport(object):
    @staticmethod
    def create_csv_file(csv_file_path, data, headers=None):
        """

        :param csv_file_path: path to csv file
        :param data: Could be passed as:
            list of lists eg [[2.3, 1.2, 5], [2.2, 1.1, 4.9]]
            list of dicts eg [{'first_column': 2.3, 'second_column': 1.2}, {'first_column': 2.2, 'second_column': 1.1}]
        :param headers: list of headers name
        :return:
        """
        dir_path = os.path.dirname(csv_file_path)
        if not os.path.exists(dir_path):
            os.makedirs(dir_path)
        with open(csv_file_path, 'w') as report_file:
            if isinstance(data[0], dict):
                writer = csv.DictWriter(report_file, fieldnames=headers)
                writer.writeheader()
            else:
                writer = csv.writer(report_file)
                if headers:
                    writer.writerow(headers)

            for row in data:
                writer.writerow(row)

    @staticmethod
    def get_headers_and_data(csv_file_path):
        data = []
        headers = []
        if os.path.isfile(csv_file_path):
            with open(csv_file_path) as csv_file:
                reader = csv.reader(csv_file)
                headers = next(reader)
                for row_data in reader:
                    data.append(row_data)
        else:
            logging.warning("{} file doesn't exists".format(csv_file_path))

        return headers, data

    @staticmethod
    def convert_csv_to_excel(csv_file_path, excel_file_dir=None):
        filename = os.path.basename(csv_file_path).replace('.csv', '.xlsx')
        if excel_file_dir is None:
            excel_file_dir = os.path.dirname(csv_file_path)
        excel_file_path = os.path.join(excel_file_dir, filename)
        workbook = Workbook()
        worksheet = workbook.active
        all_headers, data = CsvReport.get_headers_and_data(csv_file_path)
        worksheet.append(all_headers)
        for row_data in data:
            row = []
            for cell_value in row_data:
                try:
                    row.append(float(cell_value))
                except ValueError:
                    row.append(cell_value)
            worksheet.append(row)
        workbook.save(excel_file_path)
        return excel_file_path


class PropsimCsvReport(object):
    FILE_NAME = 'propsim_results.csv'

    __instance = None
    __initialized = None

    def __new__(cls, *args, **kwargs):
        if PropsimCsvReport.__instance is None:
            PropsimCsvReport.__instance = super(PropsimCsvReport, cls).__new__(cls)

        return PropsimCsvReport.__instance

    def __init__(self):
        if self.__initialized:
            return
        self._all_data = []
        self._headers = []
        PropsimCsvReport.__initialized = True

    @property
    def data(self):
        return self._all_data

    @property
    def headers(self):
        return self._headers

    def create_propsim_csv_report_for_single_iteration(self, data, log_dir, file_name=None):
        file_name = file_name if file_name else PropsimCsvReport.FILE_NAME
        full_path = os.path.join(log_dir, file_name)
        propsim_headers, data = self._prepare_data(propsim_values=data)
        CsvReport.create_csv_file(csv_file_path=full_path, data=[data], headers=propsim_headers)
        self._append_data(data=data, headers=propsim_headers)

    @staticmethod
    def get_propsim_results_from_csv(log_dir, file_name=None):
        file_name = file_name if file_name else PropsimCsvReport.FILE_NAME
        csv_file_path = os.path.join(log_dir, file_name)
        headers, data = CsvReport.get_headers_and_data(csv_file_path)

        return headers, data[0]

    def _prepare_data(self, propsim_values):
        headers = []
        data = {}
        for channel_name in propsim_values:
            gain = {'{} gain'.format(channel_name): propsim_values[channel_name]['gain']}
            outputs = propsim_values[channel_name]['outputs']
            inputs = propsim_values[channel_name]['inputs']
            channel_values = propsim_values[channel_name]['channels']

            channels = {
                '{} Pathloss Min'.format(channel_name): min(channel_values),
                '{} Pathloss Max'.format(channel_name): max(channel_values),
            }

            headers.extend(sorted(gain.keys()))
            headers.extend(sorted(outputs.keys()))
            headers.extend(sorted(inputs.keys()))
            headers.extend(sorted(channels.keys()))

            data.update(gain)
            data.update(outputs)
            data.update(inputs)
            data.update(channels)

        return headers, data

    def _append_data(self, data, headers):
        if not self._headers:
            self._headers = headers
        self._all_data.append(data)


class SherpaCsvReport(object):

    sherpa_params = {
        'macro__dlStat.csv': (['MEAN MCS', 'MIN PRB', 'MAX PRB', 'AVG PRB', 'TOTAL BLER', 'INITIAL BLER',
                              'RESIDUAL BLER'], 'gNB DL'),
        'macro__ulStat.csv': (['MEAN MCS', 'MIN PRB', 'MAX PRB', 'AVG PRB', 'TOTAL BLER', 'INITIAL BLER',
                              'RESIDUAL BLER', 'TP(kb/s)'], 'gNB UL'),
        'micro__l1l2Trace.csv': ([{'TEXT': ['rssi', 'rxPower', 'noisePower', 'sinLayer0']}], 'gNB'),
    }

    #  only [dB] stripped from data values - need to strip others when known
    @staticmethod
    def get_sherpa_results_from_csv(csv_files_dir):
        """
        Get average values for given headers from csv files.
        :param csv_files_dir: directory where csv files are stored
        :return: list of headers, e.g.
        ['MEAN MCS gNB DL', 'PRB MIN gNB DL', 'PRB MAX gNB DL', 'AVG PRB gNB DL', 'TOTAL BLER gNB DL',
        'INITIAL BLER gNB DL', 'RESIDUAL BLER gNB DL', 'MEAN MCS gNB UL', 'PRB MIN gNB UL', 'PRB MAX gNB UL',
        'AVG PRB gNB UL', 'TOTAL BLER gNB UL', 'INITIAL BLER gNB UL', 'RESIDUAL BLER gNB UL', 'TP(kb/s) gNB UL',
        'rssi gNB', 'rxPower gNB', 'noisePower gNB', 'sinLayer0 gNB']
        and list of corresponding values, e.g.
        [None, None, None, None, None, None, None, None, None, None, None, None, None, None, None,
        -66.6599525363412, -66.948220112734, -68.84699966021785, -39.204241040225035]
        """
        sherpa_params = SherpaCsvReport.sherpa_params
        data_dict = {}
        for file_name in sherpa_params.keys():
            file_path = os.path.join(csv_files_dir, file_name)
            if not os.path.isfile(file_path):
                logging.warning("{} file doesn't exists".format(file_path))
                continue

            sherpa_params_per_file = sherpa_params[file_name][0]
            header_suffix = sherpa_params[file_name][1]
            sherpa_analyzer = sherpa()
            sherpa_analyzer.setup_reader(file_path)
            if isinstance(sherpa_params_per_file[0], dict):
                data_dict.update(SherpaCsvReport._get_params_from_text_field(sherpa_params_per_file[0],
                                                                             sherpa_analyzer, header_suffix))
                data_dict.update(SherpaCsvReport._get_params_from_file(sherpa_params_per_file[1:], sherpa_analyzer,
                                                                       header_suffix))
            else:
                data_dict.update(SherpaCsvReport._get_params_from_file(sherpa_params_per_file, sherpa_analyzer,
                                                                       header_suffix))

        headers = sorted(data_dict.keys())
        data = [data_dict[header] for header in headers]

        return headers, data

    @staticmethod
    def _get_params_from_file(sherpa_params_per_file, sherpa_analyzer, header_suffix):
        data_dict = {}
        for header in sherpa_params_per_file:
            list_of_values = sherpa_analyzer.get_values_for_column(header)
            average_value = SherpaCsvReport._calculate_average(list_of_values)  # None if list_of_values is empty
            data_dict.update({"{} {}".format(header, header_suffix): average_value})
        return data_dict

    @staticmethod
    def _get_params_from_text_field(data, sherpa_analyzer, header_suffix):
        data_dict = {}
        for csv_header in data.keys():
            csv_header_values = sherpa_analyzer.get_values_for_column(csv_header)
            for header in data[csv_header]:  # real header in header=value format
                values = [re.findall(r"{}=[^,]+,".format(header), value) for value in csv_header_values]
                values = [value for value in values if value]
                list_of_values, db_unit = SherpaCsvReport._parse_text_field(values)
                if db_unit:
                    average_value = SherpaCsvReport._calculate_average_in_dbm(list_of_values)
                else:
                    average_value = SherpaCsvReport._calculate_average(list_of_values)
                data_dict.update({"{} {}".format(header, header_suffix): average_value})
        return data_dict

    @staticmethod
    def _parse_text_field(data):
        db_unit = False
        data_values = []
        for item in data:
            param = item[0]
            if param[-1] == ",":
                param = param[:-1]
            param = param.split("=")
            value = param[1]
            if 'dB' in value:
                db_unit = True
                value = value.split('d')[0]  # remove dB
            data_values.append(float(value))
        return data_values, db_unit

    @staticmethod
    def _calculate_average(list_of_values):
        if not list_of_values:
            return None
        logging.debug("Input values for _calculate_average: {}".format(list_of_values))
        values = [value.strip('%') if isinstance(value, six.string_types) else value for value in list_of_values]
        values = [float(value) for value in values if value != '']
        logging.debug("Calculate average from values: {}".format(values))
        if not values:
            logging.warning("Input values for _calculate_average are not empty: {}, "
                            "but number values are empty: {}".format(list_of_values, values))
            return None
        return round(sum(values) / len(values), 2)

    @staticmethod
    def _calculate_average_in_dbm(list_of_values):
        if not list_of_values:
            return None
        values_in_mw = [dBmConverter.convert_to_mw(value) for value in list_of_values]
        average = sum(values_in_mw) / len(values_in_mw)
        return dBmConverter.convert_to_db(average)


class QXDMReport(object):
    params = {
        '0xB8D2': {
            'headers': [
                'CarrierIdType->PUCCH Data->Transmit Power',
                'CarrierIdType->PUCCH Data->Pathloss',
                'CarrierIdType->PUCCH Data->PHR MTPL',
                'CarrierIdType->PUCCH Data->Minimum Power',
                'CarrierIdType->PUSCH Data->Transmit Power',
                'CarrierIdType->PUSCH Data->Pathloss',
                'CarrierIdType->PUSCH Data->PHR MTPL',
                'CarrierIdType->PUSCH Data->Minimum Power'
            ]
        },
        '0xB97F': {
            'headers': [
                'Cell Quality RSRP',
            ]
        }
    }

    @staticmethod
    def get_data_from_qxdm_txt_file(log_dir, pci, file_name='qxdm.txt'):
        headers = []
        data = []
        qxdm_data = {}
        params = QXDMReport.params.copy()
        file_path = os.path.join(log_dir, file_name)
        if not os.path.isfile(file_path):
            logging.warning("{} file doesn't exists".format(file_path))
            return headers, data

        parser = QxdmLogParser(file_path=file_path, message_ids=QXDMReport.params.keys())
        parser.parse()
        results = parser.ret

        pure_value_messages = ['0xB8D2']
        avg_value_messages = ['0xB97F']

        for message_id in sorted(results.keys()):
            params[message_id]['values'] = []
            for message in results[message_id]:
                for key in sorted(message.keys()):
                    if message_id in pure_value_messages:
                        if not QXDMReport._add_results_for_message_B8D2(message_id, key, message, qxdm_data, params):
                            continue
                    elif message_id in avg_value_messages:
                        if not QXDMReport._add_results_for_message_B97F(message_id, key, message, qxdm_data, params,
                                                                        pci=pci):
                            continue
                    break  # break when all values are filled(sometimes data are in 2 separate tables)
                if message_id not in avg_value_messages:
                    break  # get values only from first message

            if message_id in avg_value_messages:
                for header in params[message_id]['headers']:
                    avg = float(sum(qxdm_data[header])) / float(len(qxdm_data[header]))
                    qxdm_data[header] = dBmConverter.convert_to_db(avg)

            headers.extend(params[message_id]['headers'])
            data.extend([qxdm_data[header] for header in QXDMReport.params[message_id]['headers']])

        return headers, data

    @staticmethod
    def _add_results_for_message_B8D2(message_id, key, message, qxdm_data, params):
        if not isinstance(message[key], dict) or 'TX IU Power Sub Packet' not in message[key]:
            return False

        table = message[key]['TX IU Power Sub Packet']['Power Info']
        if len(table['values']) == 0:
            return False

        all_values_filled = True
        for record in table['values']:
            for header in params[message_id]['headers']:
                value = record[table['headers'].index(header)]
                if not qxdm_data.get(header, None):
                    qxdm_data[header] = value
                    if not value:
                        all_values_filled = False

        return all_values_filled

    @staticmethod
    def _add_results_for_message_B97F(message_id, key, message, qxdm_data, params, pci):
        if 'Component Carrier List' not in key:
            return False

        table = message[key]['Cells']

        all_values_filled = True
        pci_value_index = table['headers'].index('PCI')
        for record in table['values']:
            pci_value = record[pci_value_index]
            if pci_value and int(pci_value) == pci:
                for header in params[message_id]['headers']:
                    value = record[table['headers'].index(header)]
                    if value:
                        if header not in qxdm_data:
                            qxdm_data[header] = []
                        qxdm_data[header].append(dBmConverter.convert_to_mw(value))
                    else:
                        all_values_filled = False

        return all_values_filled


class SummaryCsvReport(object):

    def create_summary_csv_report(self, logs_dir, pci, file_name='summary_results.csv'):
        file_path = os.path.join(logs_dir, file_name)
        headers, all_values = self._get_aggregatted_data_from_partial_csv_reports(logs_dir, int(pci))
        CsvReport.create_csv_file(csv_file_path=file_path, data=all_values, headers=headers)
        return file_path

    def _get_aggregatted_data_from_partial_csv_reports(self, logs_dir, pci):
        all_iterations = self._get_all_iterations(logs_dir)
        headers = []
        all_values = []
        for index, dir_path in enumerate(all_iterations):
            iter_data = {}
            propsim_headers, propsim_data = PropsimCsvReport.get_propsim_results_from_csv(log_dir=dir_path)
            sherpa_headers, sherpa_data = SherpaCsvReport.get_sherpa_results_from_csv(
                csv_files_dir=os.path.join(dir_path, "sherpa"))
            qxdm_headers, qxdm_data = QXDMReport.get_data_from_qxdm_txt_file(log_dir=dir_path, pci=pci)
            iperf_headers, iperf_data = CsvReport.get_headers_and_data(
                csv_file_path=os.path.join(dir_path, 'iperf_results.txt'))

            if index == 0:
                headers.extend(propsim_headers)
                headers.extend(sherpa_headers)
                headers.extend(qxdm_headers)
                headers.extend(iperf_headers)

            if propsim_headers and propsim_headers:
                iter_data.update(dict(zip(propsim_headers, propsim_data)))
            if sherpa_headers and sherpa_data:
                iter_data.update(dict(zip(sherpa_headers, sherpa_data)))
            if qxdm_headers and qxdm_data:
                iter_data.update(dict(zip(qxdm_headers, qxdm_data)))
            if iperf_headers and iperf_data:
                iter_data.update(dict(zip(iperf_headers, iperf_data[0])))

            all_values.append(iter_data)

        return headers, all_values

    def _get_all_iterations(self, logs_dir):
        dir_path = os.path.join(logs_dir, '*/')

        all_directories = get_list_of_files_on_local_pc(dir_path=dir_path, options='-dtr')
        iteration_directories = []
        for dir_path in all_directories:
            if self._get_iteration_from_path(dir_path):
                iteration_directories.append(dir_path)
        iteration_directories.sort(key=lambda _dir_path: self._get_iteration_from_path(_dir_path))
        logging.debug("All iteration directories: {}".format(iteration_directories))
        return iteration_directories

    @staticmethod
    def _get_iteration_from_path(dir_path):
        re_numeber = re.compile(r'^(\d+)$')
        dir_name = dir_path.split(r'/')[-2]
        match = re_numeber.search(dir_name)
        if match:
            return int(match.group(0))


class dBmConverter(object):
    @staticmethod
    def convert_to_mw(db_value):
        return math.pow(10, float(db_value) / float(10))

    @staticmethod
    def convert_to_db(mw_value):
        return round(10 * math.log10(float(mw_value)), 2)
