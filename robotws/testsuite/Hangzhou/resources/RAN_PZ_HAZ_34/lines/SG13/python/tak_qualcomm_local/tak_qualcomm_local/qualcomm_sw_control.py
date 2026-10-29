"""
:created on: 25-04-2021

:copyright: Nokia
:author: Lily Xu
:contact: lily.l.xu@nokia.com
:maintainer: I_EXT_MBB_GLOBAL_LTE_TDD_CITA_KISS_GMS
:contact: I_EXT_MBB_GLOBAL_LTE_TDD_CITA_KISS@internal.nsn.com
"""

import sys
import time
from win32com.client import Dispatch
import datetime
import os
import subprocess
import re
from ute_common_store import Store
from tak_qualcomm_local.util import write_debug_log_to_file


sys.path.append('C:\\Program Files (x86)\\Qualcomm\\QUTS\\Support\\python')
if True:  # noqa: E402
    import QutsClient
    import Common.ttypes
    import DiagService.DiagService
    import DiagService.constants
    import DiagService.ttypes
    import DeviceConfigService.DeviceConfigService
    import DeviceConfigService.constants
    import DeviceConfigService.ttypes
    import QXDMService.QxdmService
    import QXDMService.constants
    import QXDMService.ttypes

LOG_FILE = "QualcommSwControlLogger_" + datetime.datetime.today().strftime("%Y-%m-%d-%H-%M") + ".txt"


class Device(object):

    def __init__(self):
        self.adb_devices = []
        self.diag_devices = []
        self.quts_client = None

    def get_adb_devices(self):
        self.quts_client = QutsClient.QutsClient("TestAutomation")
        time.sleep(5)
        dev_manager = self.quts_client.getDeviceManager()
        if not dev_manager:
            write_debug_log_to_file(LOG_FILE, "dev_manager is null upon instantiation")
            return
        device_list = dev_manager.getDeviceList()  # gets the list of all the devices connected to the system
        self.diag_devices = dev_manager.getDevicesForService(DiagService.constants.DIAG_SERVICE_NAME)
        write_debug_log_to_file(LOG_FILE, 'total ue num is : ' + str(len(device_list)))
        write_debug_log_to_file(LOG_FILE, self.diag_devices)
        if len(device_list) != len(self.diag_devices):
            for i in range(0, len(device_list)):
                if device_list[i].adbSerialNumber:
                    self.adb_devices.append(device_list[i])
        else:
            self.adb_devices = device_list
        write_debug_log_to_file(LOG_FILE, "adb_device_list:{}".format(self.adb_devices))

    def create_dev_config_service(self, adb_serial):
        self.get_adb_devices()

        for i in range(0, len(self.adb_devices)):
            if adb_serial == self.adb_devices[i].adbSerialNumber:
                diag_device = self.diag_devices[i]
                write_debug_log_to_file(LOG_FILE, "The chip name of the first device with DIAG_PROT:")
                break

        dev_config_service = DeviceConfigService.DeviceConfigService.Client(self.quts_client.createService(
            DeviceConfigService.constants.DEVICE_CONFIG_SERVICE_NAME, diag_device))
        if 0 != dev_config_service.initializeService():
            write_debug_log_to_file(LOG_FILE, "dev_config is null upon instantiation")
            return
        return dev_config_service

    def create_diag_service(self, adb_serial):
        diag_device, diag_port_handle = self._get_diag_device_and_port_handle(adb_serial)
        if diag_port_handle != -1:
            diag_service = DiagService.DiagService.Client(
                self.quts_client.createService(DiagService.constants.DIAG_SERVICE_NAME, diag_device))
        else:
            write_debug_log_to_file(LOG_FILE, "No diag protocol handle found")
            diag_service = None
        return diag_service, diag_port_handle, diag_device

    def create_qxdm_service(self, adb_serial):
        diag_device, diag_port_handle = self._get_diag_device_and_port_handle(adb_serial)

        if diag_port_handle != -1:
            qxdm_service = QXDMService.QxdmService.Client(
                self.quts_client.createService(QXDMService.constants.QXDM_SERVICE_NAME, diag_device))
        else:
            write_debug_log_to_file(LOG_FILE, "No diag protocol handle found")
            qxdm_service = None
        return qxdm_service, diag_port_handle

    def _get_diag_device_and_port_handle(self, adb_serial):
        self.get_adb_devices()
        diag_port_handle = -1
        diag_device = None

        for i in range(0, len(self.adb_devices)):
            if adb_serial == self.adb_devices[i].adbSerialNumber:
                list_of_protocol = self.adb_devices[i].protocols
                diag_device = self.diag_devices[i]
                for j in range(len(list_of_protocol)):
                    if list_of_protocol[j].protocolType == Common.ttypes.ProtocolType.PROT_DIAG:
                        write_debug_log_to_file(LOG_FILE, list_of_protocol[j].description)
                        diag_port_handle = list_of_protocol[j].protocolHandle
                        break
                break
        return diag_device, diag_port_handle


class QualcommSwControl(object):

    def __init__(self):
        """ init """
        self.store = Store()
        self._kill_exe_process("QXDM.exe")
        self.qxdm_window = None

    def qxdm_connect_to_device(self, adb_serial, dmc_file=None):
        """ qxdm connect to device
        """
        device = Device()
        diag_service, diag_port_handle, diag_device = device.create_diag_service(adb_serial)

        # for a single modem device
        if 0 != diag_service.initializeService():
            write_debug_log_to_file(LOG_FILE, "Diag service init failed")
            return

        # start QXDM
        self.qxdm_window = self._load_automation_window()
        if self.qxdm_window is None:
            write_debug_log_to_file(LOG_FILE, "failed to get QXDM automation interface")
            return
        else:
            write_debug_log_to_file(LOG_FILE, "QXDM automation interface successfully launched")
        if dmc_file:
            time.sleep(3)
            write_debug_log_to_file(LOG_FILE, "start to load {}".format(dmc_file))
            self.qxdm_window.LoadConfig(dmc_file)
            time.sleep(3)
            write_debug_log_to_file(LOG_FILE, "finish to load {}".format(dmc_file))
        self.store.add(self.qxdm_window, alias=adb_serial)
        write_debug_log_to_file(LOG_FILE, "connecting device")
        device_connect_result = self.qxdm_window.ConnectToDevice(str(diag_device), str(diag_port_handle))
        if not device_connect_result:
            write_debug_log_to_file(LOG_FILE, "qxdm failed to connect to device")
        else:
            write_debug_log_to_file(LOG_FILE, "QXDM successfully connects to device with device_handle={0}, "
                                              "protHandle={1}".format(diag_device, diag_port_handle))

        diag_service.destroyService()

    def qxdm_save_trace(self, adb_serial, save_path, quit_app):
        """ qxdm save trace
        """
        now = time.strftime("%Y-%m-%d_%H-%M-%S", time.localtime(time.time()))
        log_path = save_path + adb_serial + '_qxdmlog_' + now.strip()
        self.dev_connected_win = self.store.get(adb_serial)
        write_debug_log_to_file(LOG_FILE, "self.dev_connected_win:%s" % self.dev_connected_win)
        item = self.dev_connected_win.SaveItemStore(log_path)
        if item == 0:
            write_debug_log_to_file(LOG_FILE, "save %s failed" % log_path)
        else:
            write_debug_log_to_file(LOG_FILE, "save log to : " + str(log_path))
        if quit_app:
            self.dev_connected_win.QuitApplication()
        self.store.remove(alias=adb_serial)
        return log_path

    def get_field_value(self, field_name, trace_file, index, timeout):
        """ get field value
        """
        timeout = int(timeout)
        trace_txt = self._qcat_convert_qxdm_trace(trace_file)
        time.sleep(timeout)
        field_name = str(field_name)
        index = int(index)
        flag = False
        with open(trace_txt, 'r', encoding='utf-8', errors='ignore') as f:
            try:
                i = 1
                for line in f:
                    if field_name in line:
                        if i < index:
                            i = i + 1
                        else:
                            flag = True
                            break
            except Exception as e:
                write_debug_log_to_file(LOG_FILE, e)
        if not flag:
            write_debug_log_to_file(LOG_FILE, "not found the field:{}".format(field_name))
            return ''
        tmp_value = line.split(field_name)[1].strip()
        if '=' in line:
            value = tmp_value.split('=')[1].strip()
        elif ',' in line:
            value = tmp_value.split(',')[0]
        else:
            value = tmp_value
        return value

    def qcat_export_txt(self, input_file, output_path, filter):
        """ qcat export txt
        """
        self._kill_exe_process("QCAT.exe")
        disable = 0
        enable = 1
        qcat = Dispatch("QCAT6.Application")
        qcat.Visible = 0
        time.sleep(10)
        if qcat.LoadWorkspace("") != 1:
            self._kill_exe_process("QCAT.exe")
            raise Exception("qcat load workspace fail...........")
        if qcat.OpenLog(input_file) != 1:
            self._kill_exe_process("QCAT.exe")
            raise Exception("open trace file fail...........")
        if filter:
            filter = str(filter)
            workspace = qcat.Workspace
            workspace.SelectOutput(";", disable)
            workspace.SelectOutput(filter, enable)
            if workspace.ExportToText(output_path, "\t") != 1:
                self._kill_exe_process("QCAT.exe")
                raise Exception("qcat export to txt fail...........")
            file_path = "{}{}.txt".format(output_path, re.sub("[\\W\\d]", "_", filter.strip()))
        else:
            out_txt = str(input_file).replace('.hdf', '.txt')
            file_path = "{}{}".format(output_path, os.path.basename(out_txt))
            if qcat.SaveAsText(file_path) != 1:
                self._kill_exe_process("QCAT.exe")
                raise Exception("convert fail")
        self._kill_exe_process("QCAT.exe")
        return file_path

    def read_nvitem(self, adb_serial, item_name_or_id, subscription_id, index):
        """ read nv item

        :param adb_serial:
        :param item_name_or_id:
        :param subscription_id:
        :param index:
        :return:
        """
        device = Device()
        dev_config_service = device.create_dev_config_service(adb_serial)
        nv_data = dev_config_service.nvReadItem(item_name_or_id, subscription_id, index,
                                                DeviceConfigService.ttypes.NvReturns(2 | 3 | 4))
        if nv_data.errorCode:
            raise Exception("failed to read nv item, error code is {}".format(nv_data['errorCode']))
        else:
            write_debug_log_to_file(LOG_FILE, "Success to read {} and return {}".format(adb_serial, nv_data))
        # 'LTE Band Pref = 0x10000000000\r\n'
        parsed_text = nv_data.parsedText
        dev_config_service.destroyService()
        ret = re.findall("=.*(0x\\d+)\\r", parsed_text)
        if not ret:
            ret = re.findall("(\\d+)\\r", parsed_text)
        return ret[index-1] if ret else None

    def write_nvitem(self, adb_serial, item_name_or_id, value_list, subscription_id):
        device = Device()
        dev_config_service = device.create_dev_config_service(adb_serial)
        err_code = dev_config_service.nvSetItem(item_name_or_id, value_list, subscription_id)
        if err_code != 0:
            raise Exception("Failed to write nv item")
        else:
            write_debug_log_to_file(LOG_FILE, "Success to set {} with {} {} {}".format(
                adb_serial, item_name_or_id, value_list, subscription_id))
        dev_config_service.destroyService()

    def qxdm_send_cmd(self, adb_serial, cmd):
        device = Device()
        qxdm_service, diag_port_handle = device.create_qxdm_service(adb_serial)
        if 0 != qxdm_service.startQXDM(diag_port_handle):
            write_debug_log_to_file(LOG_FILE, "Error in start QXDM")
            return
        else:
            write_debug_log_to_file(LOG_FILE, "Qxdm Service started on handle " + str(diag_port_handle))
        if 0 == qxdm_service.sendCommand(cmd.encode('utf-8')):
            print("Send Command Successful: {}".format(cmd))
        else:
            print("Send Command Failed: {}".format(cmd))
        qxdm_service.destroyService()

    def _qcat_convert_qxdm_trace(self, trace_file):
        """ qcat convert qxdm trace
        """
        self._kill_exe_process("QCAT.exe")
        qcat = Dispatch("QCAT6.Application")
        qcat.Visible = 0
        if qcat.OpenLog(trace_file) != 1:
            self._kill_exe_process("QCAT.exe")
            raise Exception("open trace file fail...........")
        trace_txt = str(trace_file).replace('.hdf', '.txt')
        if qcat.SaveAsText(trace_txt) != 1:
            self._kill_exe_process("QCAT.exe")
            raise Exception("convert fail")
        self._kill_exe_process("QCAT.exe")
        return trace_txt

    def _load_automation_window(self):
        """ Initialize QXDM instance and return its automation window
        """
        qxdm_instance = Dispatch("QXDM.QXDM5AutoApplication")
        auto_window = None
        if not bool(qxdm_instance):
            write_debug_log_to_file(LOG_FILE, "Unable to obtain DMC interface")
        else:
            auto_window = qxdm_instance.GetAutomationWindow2()
            auto_window.setVisible(True)  # change to False to hide QXDM UI
        return auto_window

    def _kill_exe_process(self, process_name):
        """ Kill .exe process
        """
        while self._check_process_exist(process_name):
            cmd = "TASKKILL /F /IM " + process_name
            try:
                subprocess.check_output(cmd, shell=True, stderr=subprocess.STDOUT)
            except subprocess.CalledProcessError as e:
                write_debug_log_to_file(LOG_FILE, str(e))
                write_debug_log_to_file(LOG_FILE, str(e.output))
        if not self._check_process_exist(process_name):
            return True
        else:
            return False

    def _check_process_exist(self, process_name):
        """ check process exist
        """
        p = os.popen('tasklist /FI "IMAGENAME eq %s"' % process_name)
        if p.read().count(process_name) > 0:
            write_debug_log_to_file(LOG_FILE, "%s is existed, need to kill" % process_name)
            return True
        else:
            return False


if __name__ == "__main__":
    qualcomm = QualcommSwControl()
    # qualcomm.qxdm_send_cmd('2cdcf49b', 'QSHRequest cfg nr5gmac 0x00 0x05 0x02 0x00 0x01')
    qualcomm.qxdm_connect_to_device('72d1d395')
    # print(qualcomm.read_nvitem("2cdcf49b", "74087", -1, 2))
    # time.sleep(1)
    # print(qualcomm.read_nvitem("2cdcf49b", "80000", -1, 1))
    # qualcomm.write_nvitem("2cdcf49b", "74087", "0,8192", -1)
    # time.sleep(2)
    # print(qualcomm.read_nvitem("2cdcf49b", "74087", -1, 0))
    # QualcommSwControl().write_nvitem("878674d2", "80000", "64", -1)
    # print(QualcommSwControl().read_nvitem("878674d2", "80000", -1, 0))
    # qualcomm = QualcommSwControl()
    # qualcomm.qxdm_connect_to_device('49896eae', 'E:\\gaolei\\gaolei_test-mR-gbr_n')
    # time.sleep(120)
    # qualcomm.qxdm_save_trace('49896eae', 'E:\\gaolei\\', True)
