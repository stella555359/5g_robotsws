#!/bin/python -B
# -*- coding: utf-8 -*-
"""
:copyright: Nokia
:author: Abdrrahmane NEZROUK (Paris Saclay)
:contact: abderrahmane.nezrouk@nokia.com
:maintainer: Abderrahmane Nezrouk (Paris Saclay)
"""

import fnmatch
import os
import json
import re
from datetime import datetime, timedelta

from taf.analyzer.pmcounter.pm_log_reader import PMCounterLogReader


class custom_pm_analyser:
    """
    my custom pm analyser library
    """

    __version__ = '1.0.0'

    def __init__(self):
        """Initialisation of some utils counters list"""
        self.Cellx_PDSCH = ['M55304C01001', 'M55304C01002', 'M55304C01003', 'M55304C01004', 'M55304C01005',
                            'M55304C01006', 'M55304C01007', 'M55304C01008', 'M55304C01009', 'M55304C01010',
                            'M55304C01011', 'M55304C01012', 'M55304C01013', 'M55304C01014', 'M55304C01015',
                            'M55304C01016', 'M55304C01017', 'M55304C01018', 'M55304C01019', 'M55304C01020',
                            'M55304C01021', 'M55304C01022', 'M55304C01023', 'M55304C01024', 'M55304C01025',
                            'M55304C01026', 'M55304C01027', 'M55304C01028']

        self.Cellx_PUSCH = ['M55304C03001', 'M55304C03002', 'M55304C03003', 'M55304C03004', 'M55304C03005',
                            'M55304C03006', 'M55304C03007', 'M55304C03008', 'M55304C03009', 'M55304C03010',
                            'M55304C03011', 'M55304C03012', 'M55304C03013', 'M55304C03014', 'M55304C03015',
                            'M55304C03016', 'M55304C03017', 'M55304C03018', 'M55304C03019', 'M55304C03020',
                            'M55304C03021', 'M55304C03022', 'M55304C03023', 'M55304C03024', 'M55304C03025',
                            'M55304C03026', 'M55304C03027', 'M55304C03028']

        self.PEAK_NUMBER_OF_NSA_USERS_CU_id = 'M55131C00001'
        # Peak number of NSA users in the CU during the measurement period.

        self.MEAS_PERIOD_NR_MAC_PDU_TPUT_id = 'M55304C00001'
        # Duration of the measurement period for the NR MAC PDU throughput

        self.MEAS_PERIOD_NR_PDCP_REPORT1_id = 'M55319C00001'
        # Duration of the measurement period for the PDCP Report 1

        self.MAX_PSCELL_UE_0_ACT_SCELL_DL_id = 'M55316C05000'
        # Maximum amount of PSCell UEs with 0 activated SCells in DL

        self.DL_VOL_TX_NSA_QOS_GRP_09_id = 'M55319C02009'
        # DL PDCP SDU volume transmitted for NSA Bearer - QoS Group 09

        self.UL_VOL_RX_NSA_QOS_GRP_09_id = 'M55319C06009'
        # UL PDCP SDU volume received for NSA Bearer - QoS Group 09

        self.usful_counters = [self.MEAS_PERIOD_NR_PDCP_REPORT1_id, self.MEAS_PERIOD_NR_MAC_PDU_TPUT_id,
                               self.PEAK_NUMBER_OF_NSA_USERS_CU_id, self.MAX_PSCELL_UE_0_ACT_SCELL_DL_id,
                               self.UL_VOL_RX_NSA_QOS_GRP_09_id, self.DL_VOL_TX_NSA_QOS_GRP_09_id]

    # ==================================================================================================
    #                                      construction of json & csv file                             #
    # ==================================================================================================

    def create_json_file_with_pattern(self, pi_list, pi_dir, pi_file_pattern='*PM*'):
        """
            function to create jason and csv file using personal version (performed TAF version)

        :parameter
        pi_list : str list
            list of the pm counter to collect
        pi_dir: str
            path dir to xml pm counters
        pi_file_pattern: str
            pattern of the file to parse
        :return
        str
            return the json file path

        :raise
        IOError:
            Raise an error message if any IO error occurred during the execution.
        """

        # lookup in current dir
        pi_files = fnmatch.filter(os.listdir(pi_dir), pi_file_pattern)
        # removing redundancy pm counters from and constructing one pi_list from Cellx_PUSCH, Cellx_PDSCH
        for pi in self.usful_counters:
            if pi not in pi_list:
                pi_list.append(pi)

        for pi in self.Cellx_PUSCH:
            if pi not in pi_list:
                pi_list.append(pi)

        for pi in self.Cellx_PDSCH:
            if pi not in pi_list:
                pi_list.append(pi)

        pm_dic_list = []
        for pi_file in pi_files:
            # pm_dic = pmcounter.get_pi_value(pi_list=pi_list, pi_dir=pi_dir, pi_file_pattern=pi_file)
            with open(os.path.join(pi_dir, pi_file), 'r') as file_obj:
                file_object_iterator = [file_obj]
                for pm_log_entry in PMCounterLogReader(file_object_iterator):
                    '''
                    pm_json = json.dumps([{
                        str(pm_log_entry.timestamp):
                            pm_log_entry.pm_setup.pi_dict(pi)}
                            for pi in pi_list], indent=2)
                    # not used beacuse can't handle a big amount of files !
                  '''
                    for pi in pi_list:
                        pm_dic_list.append({str(pm_log_entry.timestamp): pm_log_entry.pm_setup.pi_dict(pi)})

        output_json_file = os.path.join(pi_dir, 'pmcounter.json')

        json.dump(pm_dic_list, open(output_json_file, 'w'))

        return (output_json_file)

    def create_json_file_with_start_end_time(self, pi_list, pi_dir, pm_duration='5min', start_time='', end_time='',
                                             opt_counters=u'True'):
        """
            function to create jason and csv file using personal version (performed TAF version)

        :parameter
        pi_list : str list
            list of the pm counter to collect
        pi_dir: str
            path dir to xml pm counters
        start_time, end_time: str
            formatted datetime string exp: "Y-M-D H:M:S+TZ"
        pm_duration: str
            formatted minute string exp: "15min"
            which correspond to reportingIntervalPM scf parameter

        :return
        str
            return the json file path

        :raise
        IOError:
            Raise an error message if any IO error occurred during the execution.
        """
        # call from robot keywords return a string instead of list
        if bool(pi_list):
            if not isinstance(pi_list, list):
                pi_list = pi_list.split(' ')
        else:
            pi_list = []

        pi_files = fnmatch.filter(os.listdir(pi_dir), '*PM*')

        # format start and end time
        start_time, end_time = self._format_start_end_time(
            pm_duration=pm_duration,
            start_time=start_time,
            end_time=end_time
        )

        filtred_files = []

        for pi_file in pi_files:
            if os.path.splitext(pi_file)[1] != '.raw':
                filtred_files.append(pi_file)

        # removing redundancy pm counters from and constructing one pi_list from Cellx_PUSCH, Cellx_PDSCH
        pi_list = list(set(pi_list))
        if opt_counters.lower() in ['true', 'yes', '1', 'in']:
            for pi in self.usful_counters:
                if pi not in pi_list:
                    pi_list.append(pi)

            for pi in self.Cellx_PUSCH:
                if pi not in pi_list:
                    pi_list.append(pi)

            for pi in self.Cellx_PDSCH:
                if pi not in pi_list:
                    pi_list.append(pi)

        timestamps = []
        pm_dic_list = []
        # pi_list = ['M55304C01016']
        dicOfcsv = {pi: {} for pi in pi_list}
        net_elms = []
        for pi_file in filtred_files:
            with open(os.path.join(pi_dir, pi_file), 'r') as file_obj:
                file_object_iterator = [file_obj]
                for pm_log_entry in PMCounterLogReader(file_object_iterator):
                    date_time = self._date_vs_tz_parser(str(pm_log_entry.timestamp))
                    if start_time <= date_time <= end_time:
                        for pi in pi_list:
                            pi_dic = pm_log_entry.pm_setup.pi_dict(pi)
                            if bool(pi_dic.values()[0]):
                                timestamp = str(date_time)
                                pm_dic_list.append({timestamp: pi_dic})
                                dicOfcsv[pi].update({timestamp: item for item in pi_dic.values()})  # pi_dic.values()
                                if date_time not in timestamps:
                                    timestamps.append(date_time)
                                for item in pi_dic.values():
                                    for k in item.keys():
                                        if k not in net_elms:
                                            net_elms.append(k)

        timestamps.sort()
        output_json_file = os.path.join(pi_dir, 'pmcounter.json')
        json.dump(pm_dic_list, open(output_json_file, 'w'))  #

        # for debug purpose
        output_csv_file = os.path.join(pi_dir, 'pmcounter.csv')

        with open(output_csv_file, "w") as outputCsvFile:
            header = 'counter_id;Network Element'
            for tm in timestamps:
                header += ";"
                header += str(tm)

            outputCsvFile.write(header + '\n')

            for key, data in dicOfcsv.items():
                for net_elm in net_elms:
                    dicOfpi = {timestamp: 0 for timestamp in timestamps}
                    found = False
                    for slot, dic in data.items():
                        if bool(dic.get(net_elm)):
                            found = True
                            for timestamp in timestamps:
                                if timestamp == self._date_vs_tz_parser(slot):
                                    dicOfpi[timestamp] = dic[net_elm]
                    if found:
                        line = key + ";" + net_elm
                        for timestamp in timestamps:
                            line += ";" + str(dicOfpi[timestamp])
                        outputCsvFile.write(line + '\n')

        return (output_json_file)

    # ==================================================================================================
    #                                      Private functions                                           #
    # ==================================================================================================

    def _format_start_end_time(self, pm_duration='5min', start_time='', end_time=''):
        """
            helpful function to reformat datetime from string format to datetime python

        :parameter
        start_time, end_time: str
            formatted datetime string exp: "Y-M-D H:M:S+TZ"
        pm_duration: str
            formatted minute string exp: "15min"
            which correspond to reportingIntervalPM scf parameter

        :return
        datetime
            return start_time, end_time

        :raise
        IOError:
            Raise an error message if any IO error occurred during the execution.
        """
        if not isinstance(pm_duration, unicode):
            pm_duration = unicode(pm_duration, 'utf-8')

        pm_duration = pm_duration.replace('min', '').replace('\r\n', '')

        if pm_duration.isnumeric():
            pm_duration = int(pm_duration)
        else:
            raise AssertionError('Error occurred ! pm_duration should be inteeger')

        # pm_delta = timedelta(minutes=pm_duration)
        if bool(start_time):
            start_time = self._date_vs_tz_parser(start_time)
            minutes = start_time.minute
            minutes = minutes - (minutes % pm_duration)
            start_time = datetime(start_time.year,
                                  start_time.month,
                                  start_time.day,
                                  start_time.hour,
                                  minutes,
                                  0)
        else:
            start_time = datetime(1980, 1, 1, 0, 0)

        if bool(end_time):
            end_time = self._date_vs_tz_parser(end_time)
            minutes = end_time.minute
            minutes = minutes - (minutes % pm_duration)
            end_time = datetime(end_time.year,
                                end_time.month,
                                end_time.day,
                                end_time.hour,
                                minutes,
                                0)
        else:
            end_time = datetime(2040, 1, 1, 0, 0)

        if start_time > end_time:
            raise AssertionError(
                'Error occurred ! start_time {} should be > to end_time: {}'.format(start_time, end_time))
        # start_time -= pm_delta

        return start_time, end_time

    def _get_dic_from_json_file(self, filename):
        """

        :param filename: str
            json file path string
        :return:
        python dictionary
            load json file
        """
        if not os.path.isfile(filename):
            raise AssertionError('Error occurred ! {} file is missing'.format(filename))

        try:
            pm_dic = json.load(open(filename))
            return (pm_dic)
        except Exception:
            raise AssertionError('Error occurred ! {} when trying to open file'.format(filename))

    def _date_vs_tz_parser(self, s):
        """
            parse oly format '2020-03-12 10:40:00+0100' or '2020-03-12 10:40:00+01:00'
        :param
        s: str
            datetime with time zone string format exp '2020-03-12 10:40:00+0100' or '2020-03-12 10:40:00+01:00'
        :return
        datetime
            return python datetime including time zone conversion
        """
        s = s.replace('\r\n', '')  # in case value get it from robot consol
        ret = datetime.strptime(s[:19], '%Y-%m-%d %H:%M:%S')

        if len(s) > 19:
            if s[19] == '+':
                ret -= timedelta(hours=int(s[20:22]), minutes=int(s[-2:]))
            elif s[19] == '-':
                ret += timedelta(hours=int(s[20:22]), minutes=int(s[-2:]))
        return ret

    def _get_measurement_periods(self, pm_dic_list, start_time, end_time, counter_id=''):
        """
        :parameter
        pm_dic_list: python dictionary
        start_time, end_time: datetime
        :return
        datetime list
            return the list of pm period starting from the first occurrence counter_id with value > 0
        """

        all_periods = []
        periods = []
        measurement_periods = []

        for elem_dic in pm_dic_list:
            for timestamp, dict_val in elem_dic.items():
                slot = self._date_vs_tz_parser(timestamp)
                if start_time <= slot <= end_time:
                    all_periods.append(slot)
                    if counter_id in dict_val.keys():
                        for k, v in dict_val[counter_id].items():
                            if v.isnumeric() and int(v) > 0:
                                periods.append(slot)

        all_periods = list(set(all_periods))
        all_periods = sorted(all_periods)
        if bool(counter_id):
            if bool(periods):
                min_period = min(periods)
                for index, item in enumerate(all_periods, start=0):
                    if index < len(all_periods) - 1 and item > min_period:
                        measurement_periods.append(item)
        else:
            measurement_periods = all_periods[1:]

        return (measurement_periods)

    def _couter_sum(self, counter_id, pm_dic_list, measurement_periods, nrcell):
        """

        :param
        counter_id: str
        pm_dic_list: list of dictionary
        measurement_periods: list of datetime
            which correspond to measurement pm period
        nrcell: str
            Network element
        :return:
            sum of the counter id value during the measured pm period
        """
        somme = 0.0

        if bool(measurement_periods):
            pattern = r'(^|\/)nrcell(\/|$)'.replace(u'nrcell', nrcell)
            for elem_dic in pm_dic_list:
                for timestamp, dict_val in elem_dic.items():
                    slot = self._date_vs_tz_parser(timestamp)
                    # "2020-02-28 11:30:00+00:00"
                    if slot in measurement_periods:
                        if counter_id in dict_val.keys():
                            for k, v in dict_val[counter_id].items():
                                if not bool(nrcell) or re.search(pattern, k):
                                    if v.isnumeric():
                                        somme += int(v)
        return (somme)

    def _counters_list_sum(self, pi_list, pm_dic_list, measurement_periods, nrcell):
        """

        :param
        pi_list: str list
            list of counter id
        pm_dic_list: list of dictionary
        measurement_periods: list of datetime
            which correspond to measurement pm period
        nrcell: str
            Network element
        :return:
        python dictionary
            list of sum of the counter id value during the measured pm period
        """
        pm_dic_values = dict((key, 0) for key in pi_list)

        if bool(measurement_periods):
            pattern = r'(^|\/)nrcell(\/|$)'.replace(u'nrcell', nrcell)
            for elem_dic in pm_dic_list:
                for timestamp, dict_val in elem_dic.items():
                    slot = self._date_vs_tz_parser(timestamp)
                    # "2020-02-28 11:30:00+00:00"
                    if slot in measurement_periods:
                        for pi_name in pi_list:
                            if pi_name in dict_val.keys():
                                for k, v in dict_val[pi_name].items():
                                    if not bool(nrcell) or re.search(pattern, k):
                                        if v.isnumeric():
                                            pm_dic_values[pi_name] += int(v)

        return (pm_dic_values)

    # ==================================================================================================
    #                                      Public functions                                            #
    # ==================================================================================================

    def get_nrcell_counter_per_pm_period(self, filename, counter_id, nrcell, slot_time, pm_duration):
        """

        :param
        filename: str
            json file path
        counter_id: str
            counter id value
        nrcell: str
            network element
        slot_time: str
            datetime of the measurement period
        pm_duration:
            pm period duration

        :return
        integer
            value of the counter id
        """
        pm_dic_list = self._get_dic_from_json_file(filename)
        slot_time = self._date_vs_tz_parser(slot_time)

        pi_value = 0.0
        pattern = r'(^|\/)nrcell(\/|$)'.replace(u'nrcell', nrcell)

        for elem_dic in pm_dic_list:
            for timestamp, dict_val in elem_dic.items():
                date_time = self._date_vs_tz_parser(timestamp)  # "2020-02-28 11:30:00+00:00"
                if 0 < (date_time - slot_time).total_seconds() < pm_duration:
                    if counter_id in dict_val.keys():
                        for k, v in dict_val[counter_id].items():
                            if re.search(pattern, k):
                                if v.isnumeric():
                                    return (int(v))
        return (pi_value)

    def get_nrcell_counter_1_period(self, filename, counter_id, nrcell, slot_time, pm_duration):
        """

        :param
        filename: str
            json file path
        counter_id: str
            counter id value. ex: M55308C11001
        nrcell: str
            network element. ex: MRBTS-23262/NRBTS-23262/NRCELL-1
        slot_time: str
            datetime of the event. ex: 2021-01-19 14:59:00
        pm_duration:
            pm period duration in seconds, type int

        :return
        integer
            value of the counter id in the period of slot_time. ex: if slot time=2021-01-19 14:59:00
            and pm_duration=900, and json files contains:
            {"2021-01-19 14:45:00": {"M55308C11001": {"MRBTS-23262/NRBTS-23262/NRCELL-1": "65269"}}}
            {"2021-01-19 15:00:00": {"M55308C11001": {"MRBTS-23262/NRBTS-23262/NRCELL-1": "0"}}}
            returns:    65269
        """
        pm_dic_list = self._get_dic_from_json_file(filename)
        slot_time = self._date_vs_tz_parser(slot_time)

        pi_value = 0.0
        pattern = r'(^|\/)nrcell(\/|$)'.replace(u'nrcell', nrcell)

        for elem_dic in pm_dic_list:
            for timestamp, dict_val in elem_dic.items():
                date_time = self._date_vs_tz_parser(timestamp)  # "2020-02-28 11:30:00+00:00"
                pm_duration_float = float(pm_duration)
                if 0 < (slot_time - date_time).total_seconds() < pm_duration_float:
                    if counter_id in dict_val.keys():
                        for k, v in dict_val[counter_id].items():
                            if re.search(pattern, k):
                                if v.isnumeric():
                                    return (int(v))
        return (int(pi_value))

    def sum_counter_data_nrcell_CA(self, filename, counter_id, nrcell, pm_duration='5min', start_time='', end_time=''):
        """

        :param
        filename: str
            json file path
        counter_id: str
            counter id value
        nrcell: str
            network element
        start_time, end_time: str
            datetime of the measurement period
        pm_duration:
            pm period duration

        :return
        integer
            total sum of counter id value during the measurement period (between start_time, end_time)
            with CA activation in account
        """

        pm_dic_list = self._get_dic_from_json_file(filename)

        # format start and end time
        start_time, end_time = self._format_start_end_time(
            pm_duration=pm_duration,
            start_time=start_time,
            end_time=end_time
        )

        measurement_periods = self._get_measurement_periods(
            pm_dic_list=pm_dic_list,
            counter_id=self.PEAK_NUMBER_OF_NSA_USERS_CU_id,
            start_time=start_time,
            end_time=end_time)

        return (self._couter_sum(
            counter_id=counter_id,
            pm_dic_list=pm_dic_list,
            measurement_periods=measurement_periods,
            nrcell=nrcell))

    def sum_counter_data_CA(self, filename, counter_id, pm_duration='5min', start_time='', end_time=''):
        """

        :param
        filename: str
            json file path
        counter_id: str
            counter id value
        start_time, end_time: str
            datetime of the measurement period
        pm_duration:
            pm period duration

        :return
        integer
            total sum of counter id value during the measurement period (between start_time, end_time)
            with CA activation in account
        """
        pm_dic_list = self._get_dic_from_json_file(filename)

        # format start and end time
        start_time, end_time = self._format_start_end_time(
            pm_duration=pm_duration,
            start_time=start_time,
            end_time=end_time
        )

        measurement_periods = self._get_measurement_periods(
            pm_dic_list=pm_dic_list,
            counter_id=self.PEAK_NUMBER_OF_NSA_USERS_CU_id,
            start_time=start_time,
            end_time=end_time)

        return (self._couter_sum(
            counter_id=counter_id,
            pm_dic_list=pm_dic_list,
            measurement_periods=measurement_periods,
            nrcell=''))

    def Cellx_PDSCH_wo_Retransm_Tput(self, filename, nrcell, pm_duration='5min', start_time='', end_time=''):
        """

        :param
        filename: str
            json file path
        nrcell: str
            network element
        start_time, end_time, end_time: str
            datetime of the measurement period
        pm_duration:
            pm period duration

        :return
        integer
            retun MAC DL throughput per NRCELL during the measurement period
        """

        pm_dic_list = self._get_dic_from_json_file(filename)
        # format start and end time
        start_time, end_time = self._format_start_end_time(
            pm_duration=pm_duration,
            start_time=start_time,
            end_time=end_time
        )

        measurement_periods = self._get_measurement_periods(
            pm_dic_list=pm_dic_list,
            counter_id=self.PEAK_NUMBER_OF_NSA_USERS_CU_id,
            start_time=start_time,
            end_time=end_time)

        TputDL_Cell_raw = self._counters_list_sum(
            pi_list=self.Cellx_PDSCH,
            pm_dic_list=pm_dic_list,
            measurement_periods=measurement_periods,
            nrcell=nrcell)

        Tput_PDSCH_woRETRANS_Cellx = 0.0
        for k, v in TputDL_Cell_raw.items():
            Tput_PDSCH_woRETRANS_Cellx += v

        DurationDL = self._couter_sum(
            counter_id=self.MEAS_PERIOD_NR_MAC_PDU_TPUT_id,
            pm_dic_list=pm_dic_list,
            measurement_periods=measurement_periods,
            nrcell='')

        if Tput_PDSCH_woRETRANS_Cellx > 0 and DurationDL > 0:
            Tput_PDSCH_woRETRANS_Cellx = 8 * Tput_PDSCH_woRETRANS_Cellx / DurationDL

        return Tput_PDSCH_woRETRANS_Cellx

    def Cellx_PUSCH_wo_Retransm_Tput(self, filename, nrcell, pm_duration='5min', start_time='', end_time=''):
        """

        :param
        filename: str
            json file path
        counter_id: str
            counter id value
        nrcell: str
            network element
        start_time, end_time: str
            datetime of the measurement period
        pm_period:
            pm period duration

        :return
        integer
            total sum of counter id value during the measurement period (between start_time, end_time)
        """

        pm_dic_list = self._get_dic_from_json_file(filename)
        # format start and end time
        start_time, end_time = self._format_start_end_time(
            pm_duration=pm_duration,
            start_time=start_time,
            end_time=end_time
        )

        measurement_periods = self._get_measurement_periods(
            pm_dic_list=pm_dic_list,
            counter_id=self.PEAK_NUMBER_OF_NSA_USERS_CU_id,
            start_time=start_time,
            end_time=end_time)

        TputUL_Cell_raw = self._counters_list_sum(
            pi_list=self.Cellx_PUSCH,
            pm_dic_list=pm_dic_list,
            measurement_periods=measurement_periods,
            nrcell=nrcell)

        Tput_PUSCH_woRETRANS_Cellx = 0.0
        for k, v in TputUL_Cell_raw.items():
            Tput_PUSCH_woRETRANS_Cellx += v

        DurationDL = self._couter_sum(
            counter_id=self.MEAS_PERIOD_NR_MAC_PDU_TPUT_id,
            pm_dic_list=pm_dic_list,
            measurement_periods=measurement_periods,
            nrcell='')

        if Tput_PUSCH_woRETRANS_Cellx > 0 and DurationDL > 0:
            Tput_PUSCH_woRETRANS_Cellx = 8 * Tput_PUSCH_woRETRANS_Cellx / DurationDL

        return Tput_PUSCH_woRETRANS_Cellx

    def sum_counter_data_nrcell(self, filename, counter_id, nrcell, pm_duration='5min', start_time='', end_time=''):
        """

        :param
        filename: str
            json file path
        counter_id: str
            counter id value
        nrcell: str
            network element
        start_time, end_time: str
            datetime of the measurement period
        pm_period:
            pm period duration

        :return
        integer
            total sum of counter id value during the measurement period (between start_time, end_time)
            without CA activation in account
        """

        pm_dic_list = self._get_dic_from_json_file(filename)

        # format start and end time
        start_time, end_time = self._format_start_end_time(
            pm_duration=pm_duration,
            start_time=start_time,
            end_time=end_time
        )

        measurement_periods = self._get_measurement_periods(
            pm_dic_list=pm_dic_list,
            start_time=start_time,
            end_time=end_time)

        return (self._couter_sum(
            counter_id=counter_id,
            pm_dic_list=pm_dic_list,
            measurement_periods=measurement_periods,
            nrcell=nrcell))

    def sum_counter_data(self, filename, counter_id, pm_duration='5min', start_time='', end_time=''):
        """

        :param
        filename: str
            json file path
        counter_id: str
            counter id value
        nrcell: str
            network element
        start_time, end_time: str
            datetime of the measurement period
        pm_period:
            pm period duration

        :return
        integer
            total sum of counter id value during the measurement period (between start_time, end_time)
            without CA activation in account
        """

        pm_dic_list = self._get_dic_from_json_file(filename)

        # format start and end time
        start_time, end_time = self._format_start_end_time(
            pm_duration=pm_duration,
            start_time=start_time,
            end_time=end_time
        )

        measurement_periods = self._get_measurement_periods(
            pm_dic_list=pm_dic_list,
            start_time=start_time,
            end_time=end_time)

        return (self._couter_sum(
            counter_id=counter_id,
            pm_dic_list=pm_dic_list,
            measurement_periods=measurement_periods,
            nrcell=''))
