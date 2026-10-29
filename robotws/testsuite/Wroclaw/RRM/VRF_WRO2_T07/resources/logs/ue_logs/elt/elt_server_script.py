"""
Script to run server on UE PC that interacts with ELT (mace) api to collect logs from MediaTek UEs. Expects
mace library to be importable. Currently runs only with Python27 (32bit) and ELT 32bit.
Server exposes its API on tcp port using Pyro4 library. Host IP and tcp port number are given as command args.
Server provides methods to 'stream' logs to client as a dict with a following structure:
    {name: <Name of message>, code: <Code of message>, timestamp: <Timestamp of message>, data: <Data as json dict>}
Logs can also be saved into a .muxraw file for later examination in ELT application. Logs can be filtered using
codes of messages.
Example invoke:
python elt_log_server.py 10.44.111.11 9091

:copyright: Nokia
:author: adam.kropiwnicki@nokia.com
:maintainer: adam.kropiwnicki@nokia.com
"""

import Pyro4
import sys
import json
import subprocess
import os
from datetime import datetime


def import_elt_libs():
    global mace
    import mace


import_elt_libs()


@Pyro4.expose
class EltLogServer:
    _error_item = {'name': 'ErrorItem', 'code': -1, 'data': {}, 'timestamp': datetime.now()}
    _dev_not_connected_err = "No device connected on port {}. Make sure to call 'connect_to_mediatek()' first"

    def __init__(self, host, port):
        self._host = host
        self._port = port
        self._devices = {}
        self.uri = None
        self.daemon = None
        self._log_dir = '/cygdrive/c/Users/wro5grrm/auto/logs'

    def launch(self):
        with Pyro4.Daemon(host=self._host, port=self._port) as self.daemon:
            self.uri = self.daemon.register(self, objectId='ELT_LOG_SERVER')
            self.daemon.requestLoop()

    def shutdown(self):
        self.daemon.shutdown()

    def connect_to_mediatek(self, com_port):
        connection_param = 'portname:{}'.format(com_port)
        self._devices[com_port] = {'device': mace.connect_device(connection_param, database=connection_param)}
        self._devices[com_port]['itemset'] = mace.create_itemset(self._devices[com_port]['device'])
        self._devices[com_port]['logs'] = []

    def subscribe_to_icd(self, com_port, codes=None):
        self._assert_device_connected(com_port)
        if codes is None:
            codes = []
        self._devices[com_port]['itemset'].subscribe_icd(*codes)

    def subscribe_to_ota(self, com_port, codes):
        self._assert_device_connected(com_port)
        if codes is None:
            codes = []
        self._devices[com_port]['itemset'].subscribe_ota(*codes)

    def get_next_message(self, com_port, timeout=100):
        self._assert_device_connected(com_port)
        try:
            item = self._devices[com_port]['itemset'].get_next_item(timeout)
            return EltLogServer._get_message_contents(item)
        except mace.DecodingFailedError:
            return EltLogServer._error_item

    def get_previous_message(self, com_port, timeout=100):
        self._assert_device_connected(com_port)
        try:
            item = self._devices[com_port]['itemset'].get_previous_item(timeout)
            return EltLogServer._get_message_contents(item)
        except mace.DecodingFailedError:
            return EltLogServer._error_item

    @staticmethod
    def _get_message_contents(item):
        if item is None:
            return {}
        if item.type == mace.ItemType.ITEM_OTA_TRACE:
            name = item.ota_message_type
            code = item.global_id.value
            data = json.loads(item.ota_json)
        elif item.type == mace.ItemType.ITEM_ICD_TRACE:
            name = item.icd_name
            code = item.icd_code
            data = json.loads(item.icd_data)
        else:
            name = 'Unknown trace name'
            code = 'Unknown trace code'
            data = 'Unknown trace data'
        timestamp = item.timestamp
        return {'name': str(name), 'code': code, 'data': data, 'timestamp': timestamp}

    def set_time_range(self, com_port, begin_time=None, end_time=None):
        self._assert_device_connected(com_port)
        if begin_time is None:
            if end_time is None:
                return
            self._devices[com_port]['itemset'].set_time_range(end=end_time)
            return
        if end_time is None:
            self._devices[com_port]['itemset'].set_time_range(datetime.strptime(begin_time.split('.')[0],
                                                                                '%Y-%m-%dT%H:%M:%S'))
            return
        self._devices[com_port]['itemset'].set_time_range(datetime.strptime(begin_time.split('.')[0],
                                                                            '%Y-%m-%dT%H:%M:%S'),
                                                          datetime.strptime(end_time.split('.')[0],
                                                                            '%Y-%m-%dT%H:%M:%S'))

    def reset_log_collector(self, com_port):
        self._assert_device_connected(com_port)
        self._devices[com_port]['itemset'] = mace.create_itemset(self._devices[com_port]['device'])

    def save_log_files(self, com_port):
        self._assert_device_connected(com_port)
        self._safe_itemset_iteration(com_port)
        files_before_save = set([log for log in os.listdir(self._log_dir) if log.endswith('.muxraw')])
        self._devices[com_port]['itemset'].save(self._log_dir)
        new_files = set([log for log in os.listdir(self._log_dir) if log.endswith('.muxraw')]) - files_before_save
        assert len(new_files) == 1, 'More than one file has appeared after save: {}'.format(new_files)
        self._devices[com_port]['logs'].append(os.path.join(self._log_dir, new_files.pop()))

    def get_log_paths(self, com_port):
        self._assert_device_connected(com_port)
        return self._devices[com_port]['logs']

    def remove_recent_logs(self, com_port):
        self._assert_device_connected(com_port)
        for log in self._devices[com_port]['logs']:
            subprocess.call('rm {}'.format(log))
        self._devices[com_port]['logs'] = []

    def _safe_itemset_iteration(self, com_port):
        while self.get_next_message(com_port, 10):
            pass

    def _assert_device_connected(self, com_port):
        if com_port not in self._devices:
            raise ValueError(EltLogServer._dev_not_connected_err.format(com_port))

    @staticmethod
    def get_current_timestamp():
        return datetime.now()

    @staticmethod
    def greetings():
        return 'hello pyro! ~ ELT'


if __name__ == '__main__':
    server = EltLogServer(sys.argv[1], int(sys.argv[2]))
    server.launch()
