import subprocess
import re
import time
from robot.libraries.BuiltIn import BuiltIn
from ta5g_ue_mobility import ta5g_ue_mobility
from ta5g_admin_operations import ta5g_admin_operations
try:
    import threading
except ImportError:
    import dummy_threading as threading
import socket
from robot.api import logger
import json
import os
import glob

ute_wtssim_instance = BuiltIn().get_library_instance('ute_wtssim')

IP = '10.0.1.1'
PORT = 49151
PACKET_SIZE = 1500
TIMEOUT = 60


def assert_dl_traffic_on_every_scell(ue_id, scells_amount, traffic=True, traffic_stabilization=True, trf_margin=50):
    for scell in range(1, int(scells_amount)+1):
        scell_tput = get_scell_avg_dl_data_traffic(ue_id=ue_id,
                                                   scell=scell,
                                                   traffic_stabilization=traffic_stabilization,
                                                   traffic=traffic)
        if int(scell_tput) == 0 and traffic is True:
            raise Exception("Scell_{} t-put is 0".format(scell))
        elif int(scell_tput) > trf_margin and traffic is False:
            raise Exception("Scell_{} t-put: {} is higher than 0".format(scell, float(scell_tput)))
        else:
            print("Scell_{} t-put different than expected one".format(scell))


def assert_ul_traffic_on_every_scell(ue_id, scells_amount, traffic=True, traffic_stabilization=True, trf_margin=50):
    for scell in range(1, int(scells_amount)+1):
        scell_tput = get_scell_avg_ul_data_traffic(ue_id=ue_id,
                                                   scell=scell,
                                                   traffic_stabilization=traffic_stabilization,
                                                   traffic=traffic)
        if int(scell_tput) == 0 and traffic is True:
            raise Exception("Scell_{} t-put is 0".format(scell))
        elif int(scell_tput) > trf_margin and traffic is False:
            raise Exception("Scell_{} t-put: {} is higher than 0".format(scell, float(scell_tput)))
        else:
            print("Scell_{} t-put different than expected one".format(scell))


def assert_traffic_on_single_scell(ue_id, scell_id, direction, traffic=True, traffic_stabilization=True):
    match direction:
        case "ul":
            scell_tput = get_scell_avg_ul_data_traffic(ue_id=ue_id,
                                                       scell=scell_id,
                                                       traffic_stabilization=traffic_stabilization,
                                                       traffic=traffic)
        case "dl":
            scell_tput = get_scell_avg_dl_data_traffic(ue_id=ue_id,
                                                       scell=scell_id,
                                                       traffic_stabilization=traffic_stabilization,
                                                       traffic=traffic)
        case _:
            raise Exception("Incorrect direction provided!")

    if int(scell_tput) == 0 and traffic is True:
        raise Exception("Scell_{} t-put is 0".format(scell_id))
    elif int(scell_tput) != 0 and traffic is False:
        raise Exception("Scell_{} t-put: {} is higher than 0".format(scell_id, float(scell_tput)))
    else:
        print("Scell_{} t-put different than expected one".format(scell_id))


def assert_bearer_stats(qfi, dir, ue_id):
    cmd = f"bearer_stats pdu=1 qfi={qfi} dir={dir} ue={ue_id}"
    result = ute_wtssim_instance.execute_egate_command_and_wait_for_data(cmd=cmd,
                                                                         pass_regexp='Average data rate')
    match = re.search(r"Average data rate\s+(\d+)", result)
    if match:
        average_data_rate = int(match.group(1))
        if average_data_rate <= 0:
            raise Exception("Average Data Rate for qfi={}, dir={} and ue_id={} is lower or equal to 0."
                            .format(qfi, dir, ue_id))
    else:
        raise Exception("Average Data Rate for qfi={}, dir={} and ue_id={} not found in Bearer Stats."
                        .format(qfi, dir, ue_id))


def get_scell_avg_dl_data_traffic(ue_id, scell, unit='Mbps', traffic_stabilization=True, traffic=True):
    if traffic_stabilization:
        time.sleep(10)
    if not traffic:
        unit = 'Kbps'
    pattern = re.compile(r'(\d+(?:\.\d+)?)\s*({})'.format(unit))
    attempts = 5
    for attempt in range(attempts):
        stats = _get_pdsch_ue_stats_for_given_cc(ue_id, scell)
        matches = pattern.findall(stats)
        if matches:
            avg_tput = float(matches[-1][0])
            if traffic and avg_tput > 0:
                return avg_tput
            if not traffic and avg_tput < 500.0:
                return avg_tput
        time.sleep(3)
    raise ValueError(f"Failed to obtain expected avg_tput (traffic={traffic}) after {attempts} attempts")


def get_scell_avg_ul_data_traffic(ue_id, scell, unit='Mbps', traffic_stabilization=True, traffic=True):
    if traffic_stabilization:
        time.sleep(10)
    if not traffic:
        unit = 'Kbps'
    pattern = re.compile(r'(\d+(?:\.\d+)?)\s*({})'.format(unit))
    attempts = 5
    for attempt in range(attempts):
        stats = _get_pusch_ue_stats_for_given_cc(ue_id, scell)
        matches = pattern.findall(stats)
        if matches:
            avg_tput = float(matches[-1][0])
            if traffic and avg_tput > 0:
                return avg_tput
            if not traffic and avg_tput < 500.0:
                return avg_tput
        time.sleep(3)
    raise ValueError(f"Failed to obtain expected avg_tput (traffic={traffic}) after {attempts} attempts")


def _get_pdsch_ue_stats_for_given_cc(ue_id, scell):
    stats = ute_wtssim_instance.execute_egate_command_and_wait_for_data(cmd='ue_stats_nr id={} type=pdsch scell={}'
                                                                        .format(ue_id, scell))
    return stats


def _get_pusch_ue_stats_for_given_cc(ue_id, scell):
    stats = ute_wtssim_instance.execute_egate_command_and_wait_for_data(cmd='ue_stats_nr id={} type=pusch scell={}'
                                                                        .format(ue_id, scell))
    return stats


def create_tce_and_establish_pdu_session_with_traffic(ue_id=1, pdu_id=1, nwslice=1, gw_id=1):
    srv = PcmdServerCreation()
    srv.start_pcmd_and_establish_pdu_session_with_traffic(ue_id, pdu_id, nwslice, gw_id)


def stop_tce():
    srv = PcmdServerCreation()
    srv.stop_pcmd()


class PcmdServerCreation(object):
    def __init__(self, ip=IP, port=PORT):
        self.server_address = (ip, port)
        self.is_running = threading.Event()
        self.pcmd_socket = socket.socket(socket.AF_INET, socket.SOCK_STREAM)
        self._started = threading.Semaphore(0)

    def _wait_for_enb_client_to_connect(self):
        try:
            self.pcmd_socket.settimeout(TIMEOUT)
            self.pcmd_socket.bind(self.server_address)
            self.pcmd_socket.listen(5)
            self.connection, self.client_address = self.pcmd_socket.accept()
        except socket.timeout:
            logger.error("eNB not connected within {} seconds".format(TIMEOUT))
            raise Exception("eNB not connected to PCMD server. Check if MTRACE object is configured.")
        else:
            logger.debug("eNB connected with address: {}".format(self.client_address))

    def _start_pcmd_server_thread(self):
        self.pcmd_server_thread = threading.Thread(target=self.start_pcmd)
        self.pcmd_server_thread.start()

    def start_pcmd(self):
        self.is_running.set()
        self._started.release()
        logger.debug("Entering receive loop.")
        try:
            self.connection.settimeout(10.0)
            while self.is_running.is_set():
                data = self._receive_data()
        finally:
            self._close_connection()

    def _close_connection(self):
        self.pcmd_socket.shutdown(socket.SHUT_RDWR)
        self.pcmd_socket.close()
        self.connection.shutdown(socket.SHUT_RDWR)
        self.connection.close()
        logger.debug("Disconected from eNB.")

    def _receive_data(self):
        data = self.connection.recv(PACKET_SIZE)
        logger.debug("Received from eNB: '{}'".format(repr(data)))
        return data

    def start_second_thread(self, ue_id, pdu_id, nwslice, gw_id):
        ta5g_ue_mobility().establish_pdu_session_with_traffic(ue_id, pdu_id, nwslice, gw_id,
                                                              pass_regexp=None, direction='both', timeout=15,
                                                              throughput='10kbps')

    def stop_pcmd(self):
        self.is_running.clear()

    def start_pcmd_and_establish_pdu_session_with_traffic(self, ue_id, pdu_id, nwslice, gw_id):
        t1 = threading.Thread(target=self._wait_for_enb_client_to_connect)
        t1.start()
        time.sleep(2)
        self.start_second_thread(ue_id, pdu_id, nwslice, gw_id)
        self._start_pcmd_server_thread()
        self._started.acquire()


def update_number_of_sa_ue_in_lua(lua_cfg):
    search_text = "NUMBER_OF_UES_SA_TDD_CELL_1=10"
    replace_text = "NUMBER_OF_UES_SA_TDD_CELL_1=11"
    with open(lua_cfg, 'r') as file:
        data = file.read()
        data = data.replace(search_text, replace_text)
    with open(lua_cfg, 'w') as file:
        file.write(data)


def clear_changes_in_number_of_sa_ue_in_lua(lua_cfg):
    search_text = "NUMBER_OF_UES_SA_TDD_CELL_1=11"
    replace_text = "NUMBER_OF_UES_SA_TDD_CELL_1=10"
    with open(lua_cfg, 'r') as file:
        data = file.read()
        data = data.replace(search_text, replace_text)
    with open(lua_cfg, 'w') as file:
        file.write(data)


def _load_json_file(file_path: str) -> list:
    with open(file_path, 'r') as file:
        data = json.load(file)
    return data


def _validate_json_entries(json_data: list, cell_id: int) -> bool:
    combinations = {}
    found_different_rnti = False

    for event in json_data.get("events", []):
        ulMuUeData = event.get("ulMuUeData")
        if not ulMuUeData or "body" not in ulMuUeData or "eventHeader" not in ulMuUeData["body"]:
            print(f"Skipping event due to missing 'ulMuUeData' or 'eventHeader': {event}")
            continue

        event_header = ulMuUeData["body"]["eventHeader"]
        event_status = ulMuUeData["body"].get("ulMuStatus")

        if event_header.get("physCellId") == int(cell_id) and event_status == "MUPAIRED_NO_TAPERING":
            key = (event_header.get("sfn"),
                   event_header.get("slot"),
                   event_header.get("lcrId"),
                   event_header.get("physCellId"),
                   event_status)

            rnti = event_header.get("rnti")

            if key in combinations:
                if rnti != combinations[key]:
                    print(f"Found matching combination with different rnti: {key}, rnti: {rnti} vs {combinations[key]}")
                    found_different_rnti = True
            else:
                combinations[key] = rnti

    return found_different_rnti


def validate_tti_traces_for_rnti(directory_path, cell_id):
    # Check if the directory exists
    if not os.path.isdir(directory_path):
        raise FileNotFoundError(f"The directory '{directory_path}' does not exist.")

    # Use glob to find all JSON files in the directory
    json_files = glob.glob(os.path.join(directory_path, '*.json'))

    # Check if there are any JSON files in the directory
    if not json_files:
        raise FileNotFoundError(f"No JSON files found in the directory '{directory_path}'.")

    overall_pass = False

    for json_file in json_files:
        json_data = _load_json_file(json_file)
        if _validate_json_entries(json_data, cell_id):
            overall_pass = True

    # Check if any file passed the validation
    if not overall_pass:
        raise Exception(f"No combination found with different rnti values for cell_id: {cell_id} in any JSON file.")


def download_missing_packages():
    try:
        subprocess.run(["pip", "install", "polars"], check=True)
    except subprocess.CalledProcessError as e:
        logger.warn("An error occurred while downloading packages.")
