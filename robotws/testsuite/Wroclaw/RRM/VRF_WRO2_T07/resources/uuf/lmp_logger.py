import os
from datetime import datetime, timedelta

from testsuite.Wroclaw.RRM.VRF_WRO2_T07.resources.admin_api.admin_api import AdminApi
from testsuite.Wroclaw.RRM.VRF_WRO2_T07.resources.decorators import logged_keyword
from testsuite.Wroclaw.RRM.VRF_WRO2_T07.resources.log import blog

LMP_LOGGER_ROOT_DIR = '/home/ute/lmp_logs/syslogs/{}'


class LmpLogger:
    INSTANCE_COUNTER = 0
    DATE_FORMAT = '%Y%m%d'
    TIME_FORMAT = '%H%M'

    def __init__(self, alias=None):
        self.lmp_logger_root_dir = None
        self.lmp_logger_start = None
        self.lmp_logger_end = None

        self.idx = LmpLogger.INSTANCE_COUNTER
        LmpLogger.INSTANCE_COUNTER += 1
        self.alias = 'lmp_default_{}'.format(self.idx) if alias is None else alias

    @logged_keyword
    def initialise_lmp_logger(self, lmp_logger_root_dir=None):
        with AdminApi() as web_api:
            global_bts_id = web_api.get_bts_info()['mrbtsID']
        self.lmp_logger_root_dir = lmp_logger_root_dir if lmp_logger_root_dir else \
            LMP_LOGGER_ROOT_DIR.format(global_bts_id)
        blog(self.build_log_print('LMP logger root directory is: {}'.format(self.lmp_logger_root_dir)))

    @logged_keyword
    def start_lmp_logger(self):
        start_time = datetime.now()
        blog(self.build_log_print('LMP logger started... - TIMESTAMP: {}'.format(start_time)))
        self.lmp_logger_start = start_time - timedelta(hours=1)

    @logged_keyword
    def stop_lmp_logger(self):
        if not self.lmp_logger_root_dir:
            raise Exception(self.build_log_print(
                'LMP logger root directory was never set. Make sure "initialise_lmp_logger" is being called.'))

        stop_time = datetime.now()
        blog(self.build_log_print('LMP logger stopped... - TIMESTAMP: {}'.format(self.alias, stop_time)))
        self.lmp_logger_end = stop_time - timedelta(hours=1)

        date_folders = next(os.walk(self.lmp_logger_root_dir))[1]
        date_folders = [os.path.join(self.lmp_logger_root_dir, folder)
                        for folder
                        in date_folders if self._is_folder_date_within_range(folder)]

        btslog_dirs = []
        for date_folder in date_folders:
            time_folders = next(os.walk(date_folder))[1]
            for time_folder in time_folders:
                if self._is_folder_within_time_range(time_folder):
                    btslog_dirs.append(os.path.join(date_folder, time_folder))

        blog(self.build_log_print('LMP logger syslog directories: {}'.format(btslog_dirs)))
        return btslog_dirs

    def _is_folder_date_within_range(self, folder_name):
        date_from_folder = datetime.strptime(folder_name, LmpLogger.DATE_FORMAT)

        if self.lmp_logger_start:
            return self.lmp_logger_start.date() <= date_from_folder.date() <= self.lmp_logger_end.date()
        else:
            raise Exception(self.build_log_print(
                'LMP logger start time was never set. Make sure "start_lmp_logger" is being called.'))

    def _is_folder_within_time_range(self, folder_name):
        start, end = folder_name.split('-')
        start, end = datetime.strptime(start, LmpLogger.TIME_FORMAT), datetime.strptime(end, LmpLogger.TIME_FORMAT)

        if self.lmp_logger_start:
            return self.lmp_logger_start.time() <= end.time() and self.lmp_logger_end.time() >= start.time()
        else:
            raise Exception(self.build_log_print(
                'LMP logger start time was never set. Make sure "start_lmp_logger" is being called.'))

    def build_log_print(self, log):
        return '{} --> '.format(self.alias) + log
