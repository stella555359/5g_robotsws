"""
Script to run server on UE PC that interacts with ELT (mace) api to collect logs from MediaTek UEs. Expects
mace library to be importable. Server exposes its API on tcp port using Pyro4 library. Host IP and tcp port number
are given as command args. Server collects logs to as a json file containing list of dicts with a following structure:
    {name: <Name of message>, code: <Code of message>, timestamp: <Timestamp of message>, data: <Data as json dict>}
Logs can be filtered using codes of messages.
Please keep in mind that for various reasons ELT Temp directory will be cleaned with 'reset_log_collector' method
Example invoke:
python elt_log_server.py 10.44.111.11 9091

:copyright: Nokia
:author: adam.kropiwnicki@nokia.com
:maintainer: adam.kropiwnicki@nokia.com
"""

import json
import os
import subprocess
import sys
import threading
import time
from datetime import datetime

import Pyro4


def import_elt_libs():
    global mace
    import mace


import_elt_libs()


@Pyro4.expose
class EltLogServer(object):
    def __init__(self, host, port):
        self._host = host
        self._port = port
        self._devices = {}
        self.uri = None
        self.daemon = None
        self._log_dir = 'C:/auto/logs'
        self._temp_dir = mace.__file__.replace('\\', '/').replace('mace.py', 'Temp') + '/*'

    def launch(self):
        with Pyro4.Daemon(host=self._host, port=self._port) as self.daemon:
            self.uri = self.daemon.register(self, objectId='ELT_LOG_SERVER')
            self.daemon.requestLoop()

    def shutdown(self):
        self.daemon.shutdown()

    def connect_to_mediatek(self, com_port, database_file=None):
        connection_param = 'portname:{}'.format(com_port)
        database_param = connection_param if database_file is None else database_file
        self._devices[com_port] = {'device': mace.connect_device(connection_param, database=database_param)}
        self._devices[com_port]['itemset'] = mace.create_itemset(self._devices[com_port]['device'])
        self._devices[com_port]['log_files'] = []
        queue = MessageQueue(self._devices[com_port]['itemset'])
        self._devices[com_port]['queue'] = queue
        self.reset_log_collector(com_port)
        self._devices[com_port]['loop_thread'] = threading.Thread(target=queue.run)

    def send_at_command(self, com_port, command):
        self._devices[com_port]['device'].send_at_command(command)
        time.sleep(1)

    def send_pcommand(self, com_port):
        self._devices[com_port]['device'].send_pcommand("MOD_VGMM", 1, "SET_FOR_BIT")
        time.sleep(1)

    def set_ip(self, com_port, ip_addr, serial_number=None):
        adb_flag = f"-s {serial_number}" if serial_number is not None else ""
        wwan = subprocess.getoutput("adb shell ifconfig | grep -o \"wwan.\"")
        subprocess.check_call(f"adb {adb_flag} root", shell=True)
        time.sleep(1)
        subprocess.check_call(f"adb {adb_flag} shell ip addr add " + ip_addr + "/24 dev " + wwan, shell=True)
        time.sleep(1)
        subprocess.check_call(f"adb {adb_flag} shell ifconfig" + wwan + " up", shell=True)
        time.sleep(1)
        subprocess.check_call(f"adb {adb_flag} shell ip route add default via " + ip_addr + " dev " + wwan, shell=True)
        time.sleep(1)
        return ip_addr

    def subscribe_to_icd(self, com_port, codes=None):
        if codes is None:
            codes = []
        self._devices[com_port]['itemset'].subscribe_icd(*codes)

    def subscribe_to_ota(self, com_port, codes):
        if codes is None:
            codes = []
        self._devices[com_port]['itemset'].subscribe_ota(*codes)

    def subscribe_to_sys(self, com_port, codes):
        if codes is None:
            codes = []
        self._devices[com_port]['itemset'].subscribe_sys(*codes)

    def start_log_collecting(self, com_port):
        self.stop_log_collecting(com_port)
        self._devices[com_port]['loop_thread'].start()

    def stop_log_collecting(self, com_port):
        if self._devices[com_port]['loop_thread'].is_alive():
            self._devices[com_port]['queue'].collect = False
            self._devices[com_port]['loop_thread'].join()
        self._devices[com_port]['loop_thread'] = threading.Thread(target=self._devices[com_port]['queue'].run)

    def reset_log_collector(self, com_port):
        subprocess.call(['rm', '-rf', self._temp_dir])
        self._devices[com_port]['queue'].clear_queue()

    def save_log_files(self, com_port):
        timestamp = datetime.now().strftime('%Y-%m-%d__%H-%M-%S')
        log_path = os.path.join(self._log_dir, "{}_elt.json".format(timestamp))
        self._devices[com_port]['queue'].save_queue(log_path)
        self._devices[com_port]['log_files'].append(log_path)

    def get_log_paths(self, com_port):
        return self._devices[com_port]['log_files']

    def remove_recent_logs(self, com_port):
        for log in self._devices[com_port]['log_files']:
            subprocess.call('rm {}'.format(log))
        self._devices[com_port]['log_files'] = []

    def inspect_queue(self, com_port, timeout=10):
        return self._devices[com_port]['queue'].inspect(timeout)

    @staticmethod
    def greetings():
        return "From Hollywood with love ~ ELT"


def catch_decoding_error(get_value_func):
    def wrapper(item):
        try:
            value = get_value_func(item)
        except mace.DecodingFailedError:
            value = "MaceDecodingError"
        return value
    return wrapper


class MessageQueue(object):
    def __init__(self, itemset):
        self._itemset = itemset
        self.collect = False
        self._messages = []
        self._queue_mutex = threading.Lock()

    def run(self):
        self.collect = True
        self.exhaust_poll()
        while self.collect:
            message = self.poll()
            if message is not None:
                MessageQueue._determine_message_status(message)
                self.queue_message(message)

    def poll(self):
        item = self._itemset.get_next_item(1)
        if item is not None:
            return self._parse_msg(item)
        return None

    def exhaust_poll(self):
        item = self._itemset.get_next_item(0)
        while item:
            item = self._itemset.get_next_item(0)

    def inspect(self, timeout=10):
        end_time = time.time() + timeout
        idx = 0
        while time.time() < end_time:
            try:
                yield self._messages[idx]
                idx += 1
            except IndexError:
                time.sleep(0.1)

    @staticmethod
    def _parse_msg(item):
        timestamp = MessageQueue._get_item_timestamp(item)
        message_type = MessageQueue._get_item_type(item)
        if message_type == mace.ItemType.ITEM_OTA_TRACE:
            name, code, data = MessageQueue._parse_ota_message(item)
        elif message_type == mace.ItemType.ITEM_ICD_TRACE:
            name, code, data = MessageQueue._parse_icd_message(item)
        elif message_type == mace.ItemType.ITEM_SYS_TRACE:
            name, code, data = MessageQueue._parse_sys_message(item)
        else:
            name = "Unknown trace name"
            code = "Unknown trace code"
            data = {"Unknown trace data": {}}
        return {'name': str(name), 'code': code, 'data': data, 'timestamp': timestamp}

    @staticmethod
    def _parse_icd_message(item):
        name = MessageQueue._get_icd_item_name(item)
        code = MessageQueue._get_icd_item_code(item)
        data = MessageQueue._get_icd_item_data(item)
        return name, code, MessageQueue.encode_json(data)

    @staticmethod
    def _parse_ota_message(item):
        name = MessageQueue._get_ota_item_name(item)
        code = MessageQueue._get_ota_item_code(item)
        data = MessageQueue._get_ota_item_data(item)
        return name, code, MessageQueue.encode_json(data)

    @staticmethod
    def _parse_sys_message(item):
        name = MessageQueue._get_sys_item_name(item)
        code = MessageQueue._get_sys_item_code(item)
        data = MessageQueue._get_sys_item_data(item)
        return name, code, data

    @staticmethod
    def encode_json(item_data):
        try:
            encoded = json.loads(item_data)
        except TypeError as e:
            encoded = {"JsonEncodingError": str(e), "Faulty data": item_data}
        except json.JSONDecodeError as e:
            encoded = {"JSONDecodeError": str(e), "Faulty data": item_data}
        return encoded

    @staticmethod
    @catch_decoding_error
    def _get_item_timestamp(item):
        return item.timestamp.strftime('%Y-%m-%d_%H-%M-%S.%f')

    @staticmethod
    @catch_decoding_error
    def _get_item_type(item):
        return item.type

    @staticmethod
    @catch_decoding_error
    def _get_icd_item_name(item):
        return item.icd_name

    @staticmethod
    @catch_decoding_error
    def _get_icd_item_code(item):
        return item.icd_code

    @staticmethod
    @catch_decoding_error
    def _get_icd_item_data(item):
        return item.icd_data

    @staticmethod
    @catch_decoding_error
    def _get_ota_item_name(item):
        return item.ota_message_type

    @staticmethod
    @catch_decoding_error
    def _get_ota_item_code(item):
        return item.global_id.value

    @staticmethod
    @catch_decoding_error
    def _get_ota_item_data(item):
        return item.ota_json

    @staticmethod
    @catch_decoding_error
    def _get_sys_item_name(item):
        return "SYS_TRACE"

    @staticmethod
    @catch_decoding_error
    def _get_sys_item_code(item):
        return item.message_id.value

    @staticmethod
    @catch_decoding_error
    def _get_sys_item_data(item):
        return str(item)

    @staticmethod
    def _is_faulty_message(message):
        for value in message.values():
            if isinstance(value, str) and 'error' in value.lower():
                return True
            if isinstance(value, dict) and any(['error' in key.lower() for key in value]):
                return True
        return False

    @staticmethod
    def _determine_message_status(message):
        if MessageQueue._is_faulty_message(message):
            message['valid'] = False
        else:
            message['valid'] = True

    def queue_message(self, message):
        with self._queue_mutex:
            self._messages.append(message)

    def clear_queue(self):
        with self._queue_mutex:
            self._messages = []

    def save_queue(self, path):
        with self._queue_mutex:
            with open(path, 'w') as f:
                json.dump(self._messages, f, indent=4)


if __name__ == '__main__':
    server = EltLogServer(sys.argv[1], int(sys.argv[2]))
    server.launch()
