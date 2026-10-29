# -*- coding: utf-8 -*-
"""
Author: Slawomir Szopinski, slawomir.szopinski@nokia.com
"""
import logging
import os
from datetime import datetime
from taf.rfrl.bts.devices.du.cell_operations import GnbCellOperations
from taf.sbts.oam.coam.admin import admin


class GnbCellCustom(GnbCellOperations):

    def __init__(self):
        super(GnbCellCustom, self).__init__()
        self.cells_info = []
        self.nbiot_cells_info = []

    def check_KPI(self, test_start_time, cell_ids=None, kpi_value=330, bts_id=0, du_id=0, cell_type='all'):

        syslog_path = self._syslog_merging(test_start_time)
        kpi = []
        if cell_ids is None:
            cell_ids = self._get_all_global_cell_ids(bts_id=bts_id, du_id=du_id, cell_type=cell_type)
        logging.debug('cell ids: {}'.format(cell_ids))

        for cell_id in cell_ids:
            cell_kpi = self._last_cell_up_first_cell_down_delta(syslog_path, cell_id, test_start_time)
            if type(cell_kpi) is int:
                kpi.append(cell_kpi)
        self._syslog_removal(syslog_path)

        if len(kpi) == 0:
            logging.error('There is no calculated KPI')
            raise KpiNotCalculated
        elif max(kpi) <= kpi_value:
            logging.debug('KPI time {} is as expected'.format(max(kpi)))
        else:
            logging.error('KPI time was exceeded. Actual KPI time is: {}'.format(max(kpi)))
            raise KpiTimeExceeded

    def compare_delta_cell_downtime(self, test_start_time, start_time, cell_ids, min_time, max_time):
        if len(cell_ids) == 2:
            syslog_path = self._syslog_merging(test_start_time)
            timestamps = []

            for cell in cell_ids:
                timestamps.append(self._get_cell_down_timestamp(syslog_path, start_time, cell))

            self._syslog_removal(syslog_path)

            if timestamps[0] < timestamps[1]:
                test_start = datetime.fromtimestamp(start_time).strftime('%H:%M:%S.%f')
                test_start_datetime = datetime.strptime(test_start, '%H:%M:%S.%f')
                delta_first = timestamps[0] - test_start_datetime
                delta_second = timestamps[1] - timestamps[0]
                logging.debug('Cell-{} downtime in seconds: {}\nCell-{} downtime in seconds: {}'.format(
                    cell_ids[0], delta_first.seconds, cell_ids[1], delta_second.seconds))

                if min_time <= delta_first.seconds <= max_time and min_time <= delta_second.seconds <= max_time:
                    logging.debug('Cells downtime is as expected')
                else:
                    logging.error('Cells did not failed during expected time')
                    raise CellDowntimeOutOfKPI

            elif timestamps[0] > timestamps[1]:
                test_start = datetime.fromtimestamp(start_time).strftime('%H:%M:%S.%f')
                test_start_datetime = datetime.strptime(test_start, '%H:%M:%S.%f')
                delta_first = timestamps[1] - test_start_datetime
                delta_second = timestamps[0] - timestamps[1]
                logging.debug('Cell-{} downtime in seconds: {}\nCell-{} downtime in seconds: {}'.format(
                    cell_ids[1], delta_first.seconds, cell_ids[0], delta_second.seconds))

                if min_time <= delta_first.seconds <= max_time and min_time <= delta_second.seconds <= max_time:
                    logging.debug('Cells downtime is as expected')
                else:
                    logging.error('Cells did not failed during expected time')
                    raise CellDowntimeOutOfKPI

            else:
                logging.error('Cells shut down simultaniously')
                raise CellDisabledSimultaniously

        else:
            logging.error('There are too low or too much cell_ids')

    def verify_multiRAT_configuration(self):
        api = admin()
        connection = api.connect_to()
        dist_name = connection.get_bts_info()
        api.teardown_admin()

        if dist_name['ratState']['lte'] == 'ALL_ENABLED' and dist_name['ratState']['nr'] == 'ALL_ENABLED':
            logging.debug('MultiRAT is configured')
        else:
            logging.error('MultiRAT is not configured')
            raise MultiRATConfigurationError

    def _get_cell_down_timestamp(self, syslog_file, test_start_timestamp, cell_id=None):
        timestamp_datetime = None

        syslog = open(syslog_file, "r")
        syslog_lines = syslog.readlines()

        if cell_id is None:
            cell_log = 'status change to operational state: Disabled, availability status: Offline'
        else:
            cell_log = 'CELL_M-{} status change to operational state: Disabled, availability status: Offline'.format(
                cell_id)

        for line in syslog_lines:

            if cell_log in line:
                logging.debug('Cell status changed to disabled log line: {}'.format(line))
                timestamp = line.split(" ")[2]
                timestamp_datetime = datetime.strptime(timestamp, "%H:%M:%S.%f")
                test_start = datetime.fromtimestamp(test_start_timestamp).strftime('%H:%M:%S.%f')
                test_start_datetime = datetime.strptime(test_start, "%H:%M:%S.%f")

                if timestamp_datetime > test_start_datetime:
                    break
                else:
                    timestamp_datetime = None

        syslog.close()

        if timestamp_datetime is None:

            if cell_id is not None:
                logging.error('Cell {} did not switch off during testing'.format(cell_id))
            else:
                logging.error('No cell switch off during testing'.format(cell_id))
            raise CellNotDisabled

        else:
            return timestamp_datetime

    def _get_cell_up_timestamp(self, syslog_file, cell_id, test_start_timestamp):
        timestamp_datetime = None

        syslog = open(syslog_file, "r")
        syslog_lines = syslog.readlines()
        state_info_nr = 'StateInfo::proceduralState of NR-{} has been changed from Validated to OnAirDone'
        state_info_lte = 'StateInfo::proceduralState of LTE-{} has been changed from Validated to OnAirDone'

        for line in syslog_lines:

            if (state_info_nr.format(cell_id) in line or state_info_lte.format(cell_id) in line):
                timestamp = line.split(" ")[2]
                timestamp_datetime = datetime.strptime(timestamp, "%H:%M:%S.%f")
                test_start = datetime.fromtimestamp(test_start_timestamp).strftime('%H:%M:%S.%f')
                test_start_datetime = datetime.strptime(test_start, "%H:%M:%S.%f")

                if timestamp_datetime > test_start_datetime:
                    break

        syslog.close()
        return timestamp_datetime

    def _syslog_merging(self, test_start_time):
        os.chdir('/tmp/btslog2')
        logging.debug('time start: {}'.format(test_start_time))
        files_list = []

        for file in os.listdir(os.getcwd()):
            modification_time = os.path.getmtime('/'.join((os.getcwd(), file)))

            if modification_time >= test_start_time and 'SYSLOG' in file:
                files_list.append('/'.join((os.getcwd(), file)))

        with open('syslog_file.txt', 'w') as outfile:

            for file in files_list:

                with open(file) as infile:
                    outfile.write(infile.read())

                outfile.write('\n')

        syslog_path = '/'.join((os.getcwd(), 'syslog_file.txt'))

        return syslog_path

    def _syslog_removal(self, syslog_path):
        os.remove(syslog_path)

    def _last_cell_up_first_cell_down_delta(self, syslog_file, cell_id, test_start_time):

        if self._get_cell_up_timestamp(syslog_file, cell_id, test_start_time) is None:
            return "Cell {} up timestamp not found".format(cell_id)

        if self._get_cell_down_timestamp(syslog_file, test_start_time) is None:
            return "First cell down timestamp not found"

        cell_up_timestamp = self._get_cell_up_timestamp(syslog_file, cell_id, test_start_time)
        cell_down_timestamp = self._get_cell_down_timestamp(syslog_file, test_start_time)
        delta = cell_up_timestamp - cell_down_timestamp
        return int(delta.seconds)


class KpiTimeExceeded(Exception):
    pass


class KpiNotCalculated(Exception):
    pass


class CellNotDisabled(Exception):
    pass


class CellDowntimeOutOfKPI(Exception):
    pass


class CellDisabledSimultaniously(Exception):
    pass


class MultiRATConfigurationError(Exception):
    pass
