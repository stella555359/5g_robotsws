from testsuite.Krakow.OAM.features.CB006483.admin_cli.cli_methods import AdminCli
from taf.sbts.oam.coam.admin import admin
from robot.api import logger
import json
from contextlib import contextmanager
import os


class AdminCommand:
    def __init__(self):
        self.sw_version = self.get_sw_version()
        self.admin_cli = AdminCli(self.sw_version)

    @contextmanager
    def admin_connection(self):
        api = admin()
        api.connect_to()
        try:
            yield api
        finally:
            api.teardown_admin()

    def get_sw_version(self, trunk_build='SBTS00'):
        """
        Get software version based on active one
        :param trunk_build:
        :return software version
        """
        with self.admin_connection() as conn:
            sw_version = conn.get_sw_version()
            if '9999' in sw_version:
                sw_list = sw_version.split('_')
                sw_version = '{}_{}'.format(trunk_build, '_'.join(sw_list[1:]))
            logger.info('Software version {}'.format(sw_version))
            return sw_version

    def get_snapshot_history(self, dir_path='/tmp', snapshot_file_name='Snapshot_history.txt'):
        """
        Get snapshot history file
        :param dir_path: directory where the snapshot will be downloaded
        :param snapshot_file_name: snapshot file name
        :return Snapshot location
        """
        snap_location = os.path.join(dir_path, snapshot_file_name)
        data = {"requestId": 1, "parameters": {"name": "getSnapshotHistory"}}
        return self.admin_cli.get_command_result(data, output_file=snap_location)

    def change_lss_credentials(self, username='ute', password='ute'):
        """
        Change credential for LSS
        :param username:
        :param password:
        """
        data = {"requestId": 1, "parameters": {"name": "configLssAccount",
                                               "parameters": {"lssUserName": str(username), "lssPwd": str(password)}}}
        self.admin_cli.get_command_result(data)

    def get_snapshot_history_file_result(self,
                                         snap_location=None,
                                         dir_path='/tmp',
                                         snapshot_file_name='Snapshot_history.txt'):
        """
        Get last line of snapshot file history
        :param snap_location: path to snapshot file
        :param dir_path: directory where the snapshot will be downloaded
        :param snapshot_file_name: snapshot file name
        :return dict with result (eg. end_time, start_time, trigger_type, trigger_reason)
        """
        snapshot_path = snap_location if snap_location else self.get_snapshot_history(dir_path, snapshot_file_name)
        with open(snapshot_path, 'r') as fp:
            get_last_line = [line.rstrip() for line in fp.readlines()][-1]
            dict_result = json.loads(get_last_line)
            return dict_result
