"""
:copyright: Nokia
:author: adam.kropiwnicki@nokia.com
:maintainer: adam.kropiwnicki@nokia.com
"""

import logging
import os
import re
import sys
import threading
from collections import defaultdict
from pprint import pformat
from telnetlib3 import Telnet
from time import monotonic, sleep

import Pyro4

MIN_RSRP = float('-inf')
MIN_RSRQ = float('-inf')
LOG_DIR = os.path.join("C:\\", "lab_scanner")

logger = logging.getLogger("lab_scan")
stdout = logging.StreamHandler()
log_file = logging.FileHandler(os.path.join(LOG_DIR, "lab_scanner.log"))
formatter = logging.Formatter("%(asctime)s - %(message)s")
stdout.setFormatter(formatter)
log_file.setFormatter(formatter)
logger.addHandler(stdout)
logger.addHandler(log_file)
logger.setLevel("DEBUG")


def import_qxdm_libs():
    # WA for PEP8
    sys.path.append(r"C:\Program Files (x86)\Qualcomm\QUTS\Support\python")

    global QutsClient
    global Common
    global DiagService

    import Common.ttypes
    import DiagService.constants
    import DiagService.DiagService
    import DiagService.ttypes
    import QutsClient


import_qxdm_libs()


@Pyro4.expose
class QxdmLogServer:
    def __init__(self):
        self._qcat_path = "C:/Program Files/Qualcomm/QCAT7/Bin/QCAT.exe"
        self.uri = None
        self.daemon = None
        self._quts_client = None
        self._dev_manager = None
        self._diag_service = None
        self._min_rsrp = MIN_RSRP
        self._min_rsrq = MIN_RSRQ
        self._measurements = self._get_measurements_template()
        self._measure_mutex = threading.Lock()
        self._licence_manager = LicenceManager()
        self._lk_thread = threading.Thread(target=self._licence_manager.run)
        self._logging_thread = threading.Thread(target=self._data_collection_loop)
        self._lk_thread.start()

    def launch(self, host, port=9092):
        with Pyro4.Daemon(host=host, port=int(port)) as self.daemon:
            self.uri = self.daemon.register(self, objectId="LAB_SCANNER")
            logger.info("Server registered. Entering request loop...")
            self.daemon.requestLoop()

    def shutdown(self, release_licences=False):
        self.teardown(release_licences)
        self.daemon.shutdown()

    def teardown(self, release_licences=False):
        if self._diag_service is not None:
            self.stop_logging()
            self._diag_service.destroyService()
            self._diag_service = None
        if self._lk_thread.is_alive():
            self._licence_manager.shutdown()
            self._lk_thread.join()
        if release_licences:
            self._licence_manager.release_all_licences()

    def connect_to_qxdm(self, diag_com):
        self._quts_client = QutsClient.QutsClient("LogSessionLiveSample")
        self._dev_manager = self._quts_client.getDeviceManager()
        devices = self._dev_manager.getDevicesForService(DiagService.constants.DIAG_SERVICE_NAME)
        if not devices:
            raise SystemError("No ue devices detected by QUTS")
        diag_initiated = False
        for device in devices:
            self._diag_service = DiagService.DiagService.Client(
                self._quts_client.createService(DiagService.constants.DIAG_SERVICE_NAME, device)
            )
            protocols = self._dev_manager.getProtocolList(device)
            if self._initialize_diag_service(protocols, diag_com):
                diag_initiated = True
                break
        if not diag_initiated:
            raise SystemError("Could not initialize diag service!")
        self._create_data_queue_for_monitoring("default_queue")
        server.set_log_mask(["0xB97F", "0xB821"])
        logger.info(f"QXDM connected on {diag_com}")

    def _initialize_diag_service(self, protocols, diag_com):
        for protocol in protocols:
            if protocol.protocolType == Common.ttypes.ProtocolType.PROT_DIAG and diag_com in protocol.description:
                selected_protocol = protocol.protocolHandle
                if self._diag_service.initializeServiceByProtocol(selected_protocol) == 0:
                    return True
        return False

    def _create_data_queue_for_monitoring(self, queue_name):
        return_obj_diag = Common.ttypes.DiagReturnConfig()
        return_obj_diag.flags = (
            Common.ttypes.DiagReturnFlags.PARSED_TEXT
            | Common.ttypes.DiagReturnFlags.PACKET_NAME
            | Common.ttypes.DiagReturnFlags.PACKET_ID
            | Common.ttypes.DiagReturnFlags.PACKET_TYPE
            | Common.ttypes.DiagReturnFlags.TIME_STAMP_STRING
            | Common.ttypes.DiagReturnFlags.RECEIVE_TIME_STRING
            | Common.ttypes.DiagReturnFlags.SUMMARY_TEXT
        )
        error_code = self._diag_service.createDataQueue(queue_name, None, return_obj_diag)
        if error_code != 0:
            raise SystemError("Error (code={}) creating data queue".format(error_code))

    def set_log_mask(self, path_or_filters):
        if isinstance(path_or_filters, str):
            self._diag_service.setLoggingMask(
                QutsClient.readFile(path_or_filters), Common.ttypes.LogMaskFormat.DMC_FORMAT
            )
        else:
            self._diag_service.addDataQueueFilter("default_queue", self._create_filters(path_or_filters))

    @staticmethod
    def _create_filters(all_filters):
        diag_packet_filter = Common.ttypes.DiagPacketFilter()
        diag_packet_filter.idOrNameMask = {}
        packet_items = []
        qtrace_items = []
        for filter_scheme in all_filters:
            if "qtrace" in filter_scheme.lower():
                qtrace_items.append(Common.ttypes.DiagIdFilterItem(idOrName=filter_scheme.split(":")[-1]))
            else:
                packet_items.append(Common.ttypes.DiagIdFilterItem(idOrName=filter_scheme))
        diag_packet_filter.idOrNameMask[Common.ttypes.DiagPacketType.LOG_PACKET] = packet_items
        diag_packet_filter.idOrNameMask[Common.ttypes.DiagPacketType.QTRACE] = qtrace_items
        return diag_packet_filter

    def _get_next_item(self, timeout=100):
        diag_packets = self._diag_service.getDataQueueItems("default_queue", 1, timeout)
        if len(diag_packets):
            packet = diag_packets[0]
            return {
                "code": packet.packetId,
                "name": packet.packetName,
                "data": packet.parsedText,
                "timestamp": packet.timeStampString,
            }
        else:
            return None

    def start_logging(self):
        self._dev_manager.startLogging()
        self._logging_stopped = False
        self._logging_thread.start()
        logger.info("Logging started!")

    def _data_collection_loop(self):
        while not self._logging_stopped:
            log = self._get_next_item()
            if log:
                if log['name'] == 'Reserved':
                    logger.warning(f"Got msg with 'Reserved' name and no data. Consider refreshing QUTS / rebooting UE")
                with self._measure_mutex:
                    self._parse_msg_and_update_measurements(log, self._measurements)
            sleep(0.03)

    @staticmethod
    def _get_measurements_template():
        measurements = {
            "NR5G ML1 Searcher Measurement Database Update Ext": {},
            "BCCH_DL_SCH / SystemInformationBlockType1": {},
        }
        return measurements

    @staticmethod
    def _serialize_measurements_dict(measurements):
        for k, v in measurements.items():
            if isinstance(v, Averager):
                measurements[k] = {param: dict(**stats) for param, stats in v.items()}
            elif isinstance(v, dict):
                QxdmLogServer._serialize_measurements_dict(v)

    @staticmethod
    def _consolidate_report(measurements):
        report = {}
        for msg_name, cells in measurements.items():
            for cell, params in cells.items():
                if cell not in report:
                    report[cell] = params
                else:
                    report[cell] = report[cell] | params
        report = list(report.values())
        return report

    def stop_logging(self):
        self._logging_stopped = True
        self._logging_thread.join()
        self._logging_thread = threading.Thread(target=self._data_collection_loop)
        logger.info("logging stopped!")

    def await_ctrc_c(self):
        logger.info("Press ctrc+c / ctrl+z to stop")
        while True:
            sleep(10)

    def get_report(self, timeout=15):
        with self._measure_mutex:
            QxdmLogServer._serialize_measurements_dict(self._measurements)
            report = QxdmLogServer._consolidate_report(self._measurements)
            self._measurements = self._get_measurements_template()
        logger.info("Requested cell report:")
        logger.info(pformat(report, indent=4))
        return report

    def clear_data_queue(self):
        self._diag_service.clearDataQueue("default_queue")
        self._measurements = self._get_measurements_template()

    def _parse_msg_and_update_measurements(self, msg, measurements):
        match msg["name"]:
            case "NR5G ML1 Searcher Measurement Database Update Ext":
                relevant_measurements = measurements["NR5G ML1 Searcher Measurement Database Update Ext"]
                self._parse_ml1_measurement_msg(msg["data"], relevant_measurements)
            case "BCCH_DL_SCH / SystemInformationBlockType1":
                relevant_measurements = measurements["BCCH_DL_SCH / SystemInformationBlockType1"]
                QxdmLogServer._parse_sib1_msg(msg["data"], relevant_measurements)
            case _:
                pass

    def _parse_ml1_measurement_msg(self, data, measurements):
        dash_line_count = 0
        lines = (line for line in data.splitlines())
        for line in lines:
            if "-------------------------------------------------------" in line:
                dash_line_count += 1
                if dash_line_count == 2:
                    self._parse_ml1_measurement_cells_table(lines, measurements)

    def _parse_ml1_measurement_cells_table(self, table_lines, measurements):
        for line in table_lines:
            values = line.split("|")
            if len(values) < 7:
                break
            pci = values[2].strip()
            if pci:
                rsrp = float(values[5].strip())
                rsrq = float(values[6].strip())
                if rsrp < self._min_rsrp or rsrq < self._min_rsrq:
                    logger.info(f'Measurement for pci = {pci} filtered out (rsrp = {rsrp}; rsrq = {rsrq})')
                    continue
                if pci not in measurements:
                    measurements[pci] = {"pci": pci, "stats": Averager()}
                measurements[pci]["stats"].update(rsrp=rsrp, rsrq=rsrq)

    @staticmethod
    def _parse_sib1_msg(data, measurements):
        matched = re.search(r"Physical Cell ID = (\d+)[\s\S]*?cellIdentity '([\d ]+)'B", data)
        if matched:
            pci, cell_identity = matched.groups()
            cell_identity = int(cell_identity.replace(" ", ""), 2)
            measurements[pci] = {"pci": pci, "identity": cell_identity}
        else:
            raise ValueError(f"Could not parse SystemInformationBlockType1 msg! data: {data}")

    def set_min_rsrp(self, value):
        self._min_rsrp = value

    def set_min_rsrq(self, value):
        self._min_rsrq = value

    def get_licence(self, app="QXDM", tech="5G"):
        self._licence_manager.get_licence(app, tech)

    def release_licence(self, app="QXDM", tech="5G"):
        self._licence_manager.release_licence(app, tech)

    def release_all_licences(self):
        self._licence_manager.release_all_licences()

    def hold_licence(self, app="QXDM", tech="5G", hold_minutes=1440):
        self._licence_manager.hold_licence(app, tech, hold_minutes)

    def change_licence_refresh_rate(self, new_rate_in_min):
        self._licence_manager.change_licence_refresh_rate(new_rate_in_min)

    @staticmethod
    def greetings():
        return "LabScanner v.0.0.1"


class LicenceManager:
    def __init__(self, host="127.0.0.1", port=6006):
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
            last_hold_time = monotonic()
            while monotonic() < last_hold_time + self._refresh_rate:
                sleep(5)
                if not self._is_alive:
                    return

    def shutdown(self):
        self._is_alive = False

    def _hold_licences(self):
        for app, technologies in self._licences_to_hold.items():
            for tech, hold_timestamp in technologies.items():
                if monotonic() < hold_timestamp:
                    self._execute_lk_keep_command(app, tech, timeout=30)

    def hold_licence(self, app="QXDM", tech="5G", hold_minutes=3000):
        self._licences_to_hold[app][tech] = monotonic() + hold_minutes * 60
        self._execute_lk_keep_command(app, tech, timeout=30)

    def get_licence(self, app="QXDM", tech="5G"):
        self._licences_to_hold[app][tech] = -1.0
        self._execute_lk_keep_command(app, tech, timeout=30)

    def release_licence(self, app="QXDM", tech="5G"):
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
            self._lk_connection.write(bytes("keep {} {}\n".format(app, tech), encoding="utf8"))
            self._await_lk_response("Got licence", timeout)
            self._lk_connection.close()

    def _execute_lk_release_command(self, app, tech, timeout=15):
        with self._connection_mutex:
            self._lk_connection.open(self._host, self._port)
            self._lk_connection.write(bytes("drop {} {}\n".format(app, tech), encoding="utf8"))
            self._await_lk_response("Released Licence successfully|No licence to release", timeout)
            self._lk_connection.close()

    def _await_lk_response(self, response_pattern, timeout=15):
        timer = monotonic() + timeout
        responses = response_pattern.split("|")
        while monotonic() < timer:
            sleep(1)
            output = str(self._lk_connection.read_very_eager())
            if output:
                for response in responses:
                    if response in output:
                        return True
        return False

    def _reset_licences_to_hold(self):
        self._licences_to_hold = {"QXDM": {"4G": 0.0, "5G": 0.0}, "QCAT": {"4G": 0.0, "5G": 0.0}}

    def change_licence_refresh_rate(self, new_rate_in_min):
        self._refresh_rate = new_rate_in_min * 60


class Averager(defaultdict):
    def __init__(self):
        super(Averager, self).__init__(ParamStats)

    def update(self, params=None, **kwargs):
        if params is None:
            params = {}
        params.update(kwargs)
        for param, value in params.items():
            super(Averager, self).__getitem__(param).add_value(value)

    def __getitem__(self, item):
        value = super(Averager, self).__getitem__(item)
        return value["avg"]

    def min(self, param):
        value = super(Averager, self).__getitem__(param)
        return value["min"]

    def max(self, param):
        value = super(Averager, self).__getitem__(param)
        return value["max"]

    def sum(self, param):
        value = super(Averager, self).__getitem__(param)
        return value["sum"]

    def count(self, param):
        value = super(Averager, self).__getitem__(param)
        return value["count"]

    def avg(self, param):
        return self[param]


class ParamStats(dict):
    _keys_supported = ["count", "sum", "min", "max", "avg"]

    def __init__(self, *args, **kwargs):
        super(ParamStats, self).__init__(*args, **kwargs)
        self["count"] = 0
        self["sum"] = 0
        self["min"] = float("inf")
        self["max"] = float("-inf")
        self["avg"] = float("nan")

    def __setitem__(self, key, value):
        if key not in ParamStats._keys_supported:
            raise KeyError("key '{}' not supported".format(key))
        super(ParamStats, self).__setitem__(key, value)

    def add_value(self, value):
        if value is None:
            return
        self["count"] += 1
        self["sum"] += value
        self["avg"] = round(self["sum"] / float(self["count"]), 2)
        self["min"] = value if value < self["min"] else self["min"]
        self["max"] = value if value > self["max"] else self["max"]


if __name__ == "__main__":
    assert len(sys.argv) > 1, "No serial port provided to script!"
    server = QxdmLogServer()
    server.hold_licence()
    if len(sys.argv) > 2:
        try:
            server.launch(sys.argv[1], sys.argv[2])
        finally:
            server.shutdown()
    else:
        try:
            server.connect_to_qxdm(sys.argv[1])
            server.start_logging()
            while True:
                server.get_report()
                sleep(10)
        finally:
            server.teardown()
