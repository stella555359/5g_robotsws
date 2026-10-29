r"""
For detailed description of the QUTS APIs, please refer to
QUTS documentation
    at "C:\Program Files (x86)\Qualcomm\QUTS\QUTS_User_Guide.docm"
This sample includes connecting to device, using Diag, sending
commands and collecting logs.

Help:
-t  the time for catch QXDMlogs
-p  to add port which need catch log, [MDM, MSM] for one UE,
if mutli UE in one PC, can use [COM3, COM4 ,COM5 ....]
-c  the config for log ctach
-s  the saved qxdm logpath and name

Sample usage:
EX in CMD winodws use:
python QXDM5Logcatch.py -t 10 -p MDM -c C:\Users\nokia5G\Desktop\
QXDM99\power5gnr01.dmc
                        -s C:\Users\nokia5G\Desktop\QXDM99\test.hdf

EX in Cygwin use:
python QXDM5Logcatch.py -t 10 -p MDM -c C:\\Users\\nokia5G\\
Desktop\\QXDM99\\power5gnr01.dmc
                        -s C:\\Users\\nokia5G\\Desktop\\QXDM99\\test.hdf

covert to txt can also use command as below:
C:\Program Files (x86)\Qualcomm\QCAT 6.x\Bin\QCAT.exe -txt
C:\Users\nokia5G\Desktop\QXDM99\test.hdf
"""

import os
import sys
import time
import shutil
import argparse


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


def collect_qxdm_logs(config, duration, output, port):
    qxdm_lc = QXDMLogCollector(config=config, duration=duration,
                               log_file_path=output, port=port)
    qxdm_lc.remove_output_file()
    qxdm_lc.print_available_devices()
    qxdm_lc.connect_to_device()

    time.sleep(3)

    qxdm_lc.load_config()
    qxdm_lc.capture_log()
    qxdm_lc.save_hdf_log()
    qxdm_lc.cleanup_session()


class QXDMLogCollector(object):
    def __init__(self, config, duration, log_file_path, port):
        self.config = config
        self.duration = duration
        self.log_file_path = log_file_path
        self.log_dir = os.path.dirname(log_file_path)
        self.port = port

        self.quts_client = self._get_quts_client()
        self.dev_manager = self._get_device_manager()
        self.devices = self._get_device_list()
        self.diag_service = None

    def _get_quts_client(self):
        quts_client = QutsClient.QutsClient("LogSessionLiveSample")
        quts_client.setOnDataQueueUpdatedCallback(_onDataQueueUpdated)
        quts_client.setOnMessageCallback(_onMessage)
        return quts_client

    def _get_device_manager(self):
        return self.quts_client.getDeviceManager()

    def _get_device_list(self, tries=3):
        # Get the list of devices connected to the PC that supports Diag.
        devices = None
        attempt = 1
        while not devices and attempt <= tries:
            devices = self.dev_manager.\
                getDevicesForService(DiagService.constants.DIAG_SERVICE_NAME)
            attempt = attempt + 1
            time.sleep(1)

        if devices is None:
            print("[WARN] Cannot get list of devices "
                  "connected to PC")
        return devices

    def print_available_devices(self):
        print("Devices Connected to PC: {}".format(self.devices))

    def connect_to_device(self):
        for device in self.devices:
            protocols = self.dev_manager.getProtocolList(device)
            self.diag_service = self._get_diag_service(device)
            for protocol in protocols:
                if protocol.protocolType == Common.ttypes.ProtocolType.\
                        PROT_DIAG and self.port in protocol.description:
                    selected_protocol = protocol.protocolHandle
                    self.diag_service.\
                        initializeServiceByProtocol(selected_protocol)
                    print("Device handle: {}".format(device))
                    print("Connect with protocol chip named " +
                          self.dev_manager.getChipName(
                              device, selected_protocol))
                    return device

    def _get_diag_service(self, device):
        return DiagService.DiagService.Client(
            self.quts_client.createService(
                DiagService.constants.DIAG_SERVICE_NAME, device))

    def load_config(self):
        print("Load the config from " + self.config)
        self.diag_service.setLoggingMask(
            QutsClient.readFile(self.config),
            Common.ttypes.LogMaskFormat.DMC_FORMAT)

    def capture_log(self):
        print("Start to catch QXDMlog for " + self.duration + " seconds")
        self.dev_manager.startLogging()
        time.sleep(float(self.duration))

    def save_hdf_log(self):
        outfile = self.dev_manager.saveLogFiles(self.log_dir)
        shutil.move(outfile[0], self.log_file_path)
        print("Saved log to: %s" % self.log_file_path)

    def cleanup_session(self):
        self.diag_service.destroyService()
        print("Exit QUTS...")

    def remove_output_file(self):
        try:
            os.unlink(self.log_file_path)
        except BaseException:
            pass


def _onDataQueueUpdated(queueName, queueSize):
    print(queueName, " update ", queueSize)


def _onMessage(level, location, title, description):
    print("Message Received " + title + " " + description)


if __name__ == "__main__":
    arg_parser = argparse.ArgumentParser(
        description='Parameters: Collect QXDM hdf log')
    arg_parser.add_argument('-t', '--time', dest='time',
                            type=str, required=True,
                            help='time for collecting logs')
    arg_parser.add_argument('-p', '--prot', dest='port',
                            type=str, required=True, help='COM port number')
    arg_parser.add_argument('-c', '--config', dest='config',
                            type=str, required=True, help='DMC config file')
    arg_parser.add_argument('-s', '--saveFile', dest='output_file',
                            type=str, required=True, help='Path to log file')

    param = arg_parser.parse_args()
    collect_qxdm_logs(config=param.config,
                      duration=param.time,
                      output=param.output_file,
                      port=param.port)
