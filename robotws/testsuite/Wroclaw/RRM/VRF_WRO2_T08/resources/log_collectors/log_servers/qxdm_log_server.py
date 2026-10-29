"""
Script to run server on UE PC that interacts with QUTS api to collect logs from Qualcomm UEs.
Automatically acquires needed licences, provided License Keeper is running and logged in. Licenses are periodically
refreshed on a seperate thread. Server exposes its API on tcp port using Pyro4 library. Host IP and tcp port number
are given as command args. Script provides methods to collect both .hdf and QCAT coverted .txt logs. Logs can be
filtered using log mask in a form of qualcomm .dmc file.
Example invoke:
python qxdm_log_server.py 10.44.111.11 9091

:copyright: Nokia
:author: adam.kropiwnicki@nokia.com
:maintainer: adam.kropiwnicki@nokia.com
"""

import os
import subprocess
import sys
import threading
from datetime import datetime
from telnetlib3 import Telnet
from time import time, sleep

import Pyro4


def import_qxdm_libs():
    # WA for PEP8
    sys.path.append(r'C:\Program Files (x86)\Qualcomm\QUTS\Support\python')

    global QutsClient
    global Common
    global DiagService

    import QutsClient
    import Common.ttypes
    import DiagService.DiagService
    import DiagService.constants
    import DiagService.ttypes


import_qxdm_libs()


@Pyro4.expose
class QxdmLogServer:
    def __init__(self, host, port):
        self._host = host
        self._port = port
        self._qcat_path = "C:/Program Files/Qualcomm/QCAT7/Bin/QCAT.exe"
        self.uri = None
        self.daemon = None
        self._quts_client = None
        self._dev_manager = None
        self._diag_service = None
        self._logs_dir = os.path.join('C:\\', 'auto', 'logs')
        self._recent_hdf_logs = []
        self._recent_txt_logs = []
        self._licence_manager = LicenceManager()
        self._lk_thread = threading.Thread(target=self._licence_manager.run)
        self._lk_thread.start()

    def launch(self):
        with Pyro4.Daemon(host=self._host, port=self._port) as self.daemon:
            self.uri = self.daemon.register(self, objectId='QXDM_LOG_SERVER')
            self.daemon.requestLoop()

    def shutdown(self, release_licences=False):
        if self._diag_service is not None:
            self._diag_service.destroyService()
        self._licence_manager.shutdown()
        self._lk_thread.join()
        if release_licences:
            self._licence_manager.release_all_licences()
        self.daemon.shutdown()

    def connect_to_qxdm(self, diag_com):
        self._quts_client = QutsClient.QutsClient("LogSessionLiveSample")
        self._dev_manager = self._quts_client.getDeviceManager()
        devices = self._dev_manager.getDevicesForService(DiagService.constants.DIAG_SERVICE_NAME)
        if not devices:
            raise SystemError("No ue devices detected by QUTS")
        diag_initiated = False
        for device in devices:
            self._diag_service = DiagService.DiagService.Client(
                self._quts_client.createService(DiagService.constants.DIAG_SERVICE_NAME, device))
            protocols = self._dev_manager.getProtocolList(device)
            if self._initialize_diag_service(protocols, diag_com):
                diag_initiated = True
                break
        if not diag_initiated:
            raise SystemError('Could not initialize diag service!')
        self._create_data_queue_for_monitoring('default_queue')
        return "Hollywood"

    def _initialize_diag_service(self, protocols, diag_com):
        for protocol in protocols:
            if protocol.protocolType == Common.ttypes.ProtocolType.PROT_DIAG and diag_com in protocol.description:
                selected_protocol = protocol.protocolHandle
                if self._diag_service.initializeServiceByProtocol(selected_protocol) == 0:
                    return True
        return False

    def _create_data_queue_for_monitoring(self, queue_name):
        return_obj_diag = Common.ttypes.DiagReturnConfig()
        return_obj_diag.flags = Common.ttypes.DiagReturnFlags.PARSED_TEXT | \
            Common.ttypes.DiagReturnFlags.PACKET_NAME | Common.ttypes.DiagReturnFlags.PACKET_ID | \
            Common.ttypes.DiagReturnFlags.PACKET_TYPE | Common.ttypes.DiagReturnFlags.TIME_STAMP_STRING | \
            Common.ttypes.DiagReturnFlags.RECEIVE_TIME_STRING | Common.ttypes.DiagReturnFlags.SUMMARY_TEXT
        error_code = self._diag_service.createDataQueue(queue_name, None, return_obj_diag)
        if error_code != 0:
            raise SystemError("Error (code={}) creating data queue".format(error_code))

    def set_log_mask(self, path_or_filters):
        if isinstance(path_or_filters, str):
            self._diag_service.setLoggingMask(QutsClient.readFile(path_or_filters),
                                              Common.ttypes.LogMaskFormat.DMC_FORMAT)
        else:
            self._diag_service.addDataQueueFilter('default_queue', self._create_filters(path_or_filters))

    @staticmethod
    def _create_filters(all_filters):
        diag_packet_filter = Common.ttypes.DiagPacketFilter()
        diag_packet_filter.idOrNameMask = {}
        packet_items = []
        qtrace_items = []
        for filter_scheme in all_filters:
            if 'qtrace' in filter_scheme.lower():
                qtrace_items.append(Common.ttypes.DiagIdFilterItem(idOrName=filter_scheme.split(':')[-1]))
            else:
                packet_items.append(Common.ttypes.DiagIdFilterItem(idOrName=filter_scheme))
        diag_packet_filter.idOrNameMask[Common.ttypes.DiagPacketType.LOG_PACKET] = packet_items
        diag_packet_filter.idOrNameMask[Common.ttypes.DiagPacketType.QTRACE] = qtrace_items
        return diag_packet_filter

    def get_next_item(self, timeout=100):
        diag_packets = self._diag_service.getDataQueueItems('default_queue', 1, timeout)
        if len(diag_packets):
            packet = diag_packets[0]
            return {'code': packet.packetId, 'name': packet.packetName, 'data': packet.parsedText,
                    'timestamp': packet.timeStampString}
        else:
            return None

    def start_logging(self):
        self._dev_manager.startLogging()

    def stop_logging(self):
        hdf_logs = self._dev_manager.saveLogFiles(self._logs_dir)
        for log in hdf_logs:
            timestamp = datetime.now().strftime('%d-%m-%Y_%H-%M-%S-%f')
            target_file = os.path.join(self._logs_dir, '{}_qxdm.hdf'.format(timestamp))
            subprocess.call('mv {} {}'.format(log, target_file))
            self._recent_hdf_logs.append(target_file)

    def reset_logging(self):
        self._dev_manager.resetLogFiles()

    def clear_recent_logs(self):
        for log in self._recent_hdf_logs + self._recent_txt_logs:
            subprocess.call('rm {}'.format(log))
        self._recent_hdf_logs = []
        self._recent_txt_logs = []

    def clear_data_queue(self):
        self._diag_service.clearDataQueue('default_queue')

    def convert_hdf_to_txt(self):
        self._recent_txt_logs = []
        for hdf_log in self._recent_hdf_logs:
            subprocess.call('"{}" -txt "{}"'.format(self._qcat_path, hdf_log))
            self._recent_txt_logs.append(hdf_log.replace('.hdf', '.txt'))

    def get_hdf_log_paths(self):
        return self._recent_hdf_logs

    def get_txt_log_paths(self):
        return self._recent_txt_logs

    def get_licence(self, app='QXDM', tech='5G'):
        self._licence_manager.get_licence(app, tech)

    def release_licence(self, app='QXDM', tech='5G'):
        self._licence_manager.release_licence(app, tech)

    def release_all_licences(self):
        self._licence_manager.release_all_licences()

    def hold_licence(self, app='QXDM', tech='5G', hold_minutes=1440):
        self._licence_manager.hold_licence(app, tech, hold_minutes)

    def change_licence_refresh_rate(self, new_rate_in_min):
        self._licence_manager.change_licence_refresh_rate(new_rate_in_min)

    @staticmethod
    def greetings():
        return "From Hollywood with love ~ QXDM"


class LicenceManager:
    def __init__(self, host='127.0.0.1', port=6006):
        self._host = host
        self._port = port
        self._lk_connection = Telnet()
        self._connection_mutex = threading.Lock()
        self._reset_licences_to_hold()
        self._is_alive = False
        self._refresh_rate = 30 * 60

    def run(self):
        self._is_alive = True
        while self._is_alive:
            self._hold_licences()
            last_hold_time = time()
            while time() < last_hold_time + self._refresh_rate:
                sleep(5)
                if not self._is_alive:
                    return

    def shutdown(self):
        self._is_alive = False

    def _hold_licences(self):
        for app, technologies in self._licences_to_hold.items():
            for tech, hold_timestamp in technologies.items():
                if time() < hold_timestamp:
                    self._execute_lk_keep_command(app, tech, timeout=30)

    def hold_licence(self, app='QXDM', tech='5G', hold_minutes=3000):
        self._licences_to_hold[app][tech] = time() + hold_minutes * 60
        self._execute_lk_keep_command(app, tech, timeout=30)

    def get_licence(self, app='QXDM', tech='5G'):
        self._licences_to_hold[app][tech] = -1.0
        self._execute_lk_keep_command(app, tech, timeout=30)

    def release_licence(self, app='QXDM', tech='5G'):
        self._licences_to_hold[app][tech] = 0.0
        self._execute_lk_release_command(app, tech, timeout=15)

    def release_all_licences(self):
        for app, technologies in self._licences_to_hold.items():
            for tech, hold_timestamp in technologies.items():
                if hold_timestamp:
                    self._execute_lk_release_command(app, tech, timeout=15)
        self._reset_licences_to_hold()

    def _execute_lk_keep_command(self, app, tech, timeout=15):
        with self._connection_mutex:
            self._lk_connection.open(self._host, self._port)
            self._lk_connection.write(bytes('keep {} {}\n'.format(app, tech), encoding='utf8'))
            self._await_lk_response('Got licence', timeout)
            self._lk_connection.close()

    def _execute_lk_release_command(self, app, tech, timeout=15):
        with self._connection_mutex:
            self._lk_connection.open(self._host, self._port)
            self._lk_connection.write(bytes('drop {} {}\n'.format(app, tech), encoding='utf8'))
            self._await_lk_response('Released Licence successfully|No licence to release', timeout)
            self._lk_connection.close()

    def _await_lk_response(self, response_pattern, timeout=15):
        timer = time() + timeout
        responses = response_pattern.split('|')
        while time() < timer:
            sleep(1)
            output = str(self._lk_connection.read_very_eager())
            if output:
                for response in responses:
                    if response in output:
                        return True
        return False

    def _reset_licences_to_hold(self):
        self._licences_to_hold = {'QXDM': {'4G': 0.0, '5G': 0.0}, 'QCAT': {'4G': 0.0, '5G': 0.0}}

    def change_licence_refresh_rate(self, new_rate_in_min):
        self._refresh_rate = new_rate_in_min * 60


if __name__ == '__main__':
    server = QxdmLogServer(sys.argv[1], int(sys.argv[2]))
    server.launch()
