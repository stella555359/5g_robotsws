import time
from ta5g_ue_mobility import ta5g_ue_mobility
from ta5g_admin_operations import ta5g_admin_operations
try:
    import threading
except ImportError:
    import dummy_threading as threading
import socket
from robot.api import logger

IP = '10.0.1.1'
PORT = 49151
PACKET_SIZE = 1500
TIMEOUT = 60


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
    search_text = "NUMBER_OF_UES_SA=10"
    replace_text = "NUMBER_OF_UES_SA=11"
    with open(lua_cfg, 'r') as file:
        data = file.read()
        data = data.replace(search_text, replace_text)
    with open(lua_cfg, 'w') as file:
        file.write(data)


def clear_changes_in_number_of_sa_ue_in_lua(lua_cfg):
    search_text = "NUMBER_OF_UES_SA=11"
    replace_text = "NUMBER_OF_UES_SA=10"
    with open(lua_cfg, 'r') as file:
        data = file.read()
        data = data.replace(search_text, replace_text)
    with open(lua_cfg, 'w') as file:
        file.write(data)
