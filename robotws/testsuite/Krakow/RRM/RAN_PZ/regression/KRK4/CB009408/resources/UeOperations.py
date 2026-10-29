"""
Custom Data Transfer Keywords
"""
from robot.libraries.BuiltIn import BuiltIn
from testsuite.Krakow.RRM.RAN_PZ.resources.small_cells.sc_keywords import SmallCellsKeywords
from taf.rfrl.utilities.robot.general import get_builtin_instance
from taf.rfrl.ue.helpers import data_transfer
from taf.rfrl.bts.devices.du.logs_collecting.btslog_collector import GnbBtslogCollector
from taf.rfrl.utilities.tl_config import load_moler_configuration_from_tl
from taf.hw.rf_attenuator import rf_attenuator
from moler.util.moler_test import MolerTest
from moler.device import DeviceFactory
import time
import logging


class UeOperations(object):
    def __init__(self):
        self.observer = None
        self.ue_controlled = False
        self.ue_rebooted = False
        self.ue = get_builtin_instance("ue")
        self.sc_keywords = SmallCellsKeywords()
        self.tl = BuiltIn().get_variable_value('${{{}}}'.format("tl"), None)
        self.serial_number = None
        self.attenuator_device = rf_attenuator()

    def reboot_qualcomm_ue(self):
        if not self.ue_controlled:
            self.ue.require_ue("UE", "REAL_UE")
            self.ue_controlled = True
        self.ue.reboot_ue("UE", 120)

    def attach_qualcomm_ue(self):
        if not self.ue_controlled:
            self.ue.require_ue("UE", "REAL_UE")
            self.ue_controlled = True
        self.ue.attach_ue("UE")

    def detach_qualcomm_ue(self):
        self.ue.detach_ue("UE")

    @load_moler_configuration_from_tl()
    def perform_attach_procedure(self, cell_type="LTE", cell_id='19736435', check_endc_call=True, bts_id=0, du_id=0):
        if not self.ue_rebooted:
            self.reboot_qualcomm_ue()
            self.ue_rebooted = True
        try:
            if check_endc_call:
                self._attach_ue_with_endc_check(bts_id=bts_id, du_id=du_id)
            else:
                self.attach_qualcomm_ue()
                time.sleep(15)
            self.sc_keywords.verify_cell_id(cell_type=cell_type, cell_id=cell_id)
        finally:
            self.detach_qualcomm_ue()

    def _attach_ue_with_endc_check(self, bts_id=0, du_id=0):
        self._start_ue_attach_observer(bts_id=bts_id, du_id=du_id)
        self.attach_qualcomm_ue()
        self._verify_ue_attach_to_5g_nsa()

    @staticmethod
    def start_dl_tcp_data_transfer(duration, expected_tput):
        data_transfer.start_data_transfer_on_real_ue(
            duration=duration, tput=expected_tput, dt_name='DT_DL', ue_alias='UE', direction='dl', protocol='tcp',
            parallel_streams='4', size_packet='1436B', buffer_client=None, buffer_server=None, interval='1', qci=None,
            linux_congestion='cubic', multi_radio_bearer=False)

    @staticmethod
    def start_ul_tcp_data_transfer(duration, expected_tput):
        data_transfer.start_data_transfer_on_real_ue(
            duration=duration, tput=expected_tput, dt_name='DT_UL', ue_alias='UE', direction='ul', protocol='tcp',
            parallel_streams='2', size_packet='1436B', buffer_client=None, buffer_server=None, interval='1', qci=None,
            linux_congestion=None, multi_radio_bearer=False)

    def start_bdir_tcp_data_transfer(self, duration, expected_dl_tput, expected_ul_tput, tolerance):
        self.attach_qualcomm_ue()
        try:
            self.start_dl_tcp_data_transfer(duration=duration, expected_tput=expected_dl_tput)
            self.start_ul_tcp_data_transfer(duration=duration, expected_tput=expected_ul_tput)
            time.sleep(10)  # Wait for throughput stabilization
            self.ue.await_data_transfer_finish(dt_name='DT_DL')
            self.ue.await_data_transfer_finish(dt_name='DT_UL')
        finally:
            self.detach_qualcomm_ue()
        self.ue.verify_average_throughput_with_deviation(dt_name='DT_DL', tput=expected_dl_tput, deviation=tolerance)
        self.ue.verify_average_throughput_with_deviation(dt_name='DT_UL', tput=expected_ul_tput, deviation=tolerance)

    def set_attenuation(self, configuration):
        """
        Set values to multiple attenuator's ports.
        :param configuration: attenuator configuration dictionary contained
        attenuator's port identifiers and corresponding attenuation values e.g.:
        configuration = {"port_identifiers":   [5, 6],
                         "attenuation_values": [20, 20]}
        :type  configuration: dict
        :return: None
        """
        self.attenuator_device.setup_attenuator(attenuator=self.tl.attenuator)
        for port_id, att_value in zip(configuration["port_identifiers"], configuration["attenuation_values"]):
            self.attenuator_device.set_attenuation(port=port_id, value=att_value)

    def _start_ue_attach_observer(self, bts_id=0, du_id=0, timeout=180):
        nsa_attach_pattern = r".*Received\smessages::e1ap::BearerContextInactivityNotification.*"
        btslog = GnbBtslogCollector()
        btslog.start_collecting_syslog()
        syslog = DeviceFactory.get_device(name=btslog.syslog_alias.format(bts_id, du_id))
        syslog.goto_state('SYSLOG', keep_state=False)
        self.observer = syslog.get_event(event_name="wait4",
                                         event_params={
                                              "detect_patterns": [nsa_attach_pattern],
                                              "till_occurs_times": 1})
        self.observer.start(timeout=timeout)

    def _verify_ue_attach_to_5g_nsa(self):
        try:
            MolerTest.sleep(15)  # Wait until attach log collection complete
            observer_state = self.observer.running()
            if observer_state:
                self.observer.cancel()
                raise Ue5gNsaAttachFailedException("UE attach to 5G NSA failed. Not found message: 'Received messages"
                                                   "::e1ap::BearerContextInactivityNotification' in syslog. "
                                                   "Please verify syslog manually.")
            else:
                logging.info("Detected successful attempt of UE attach to 5G NSA")
        finally:
            btslog = GnbBtslogCollector()
            btslog.stop_collecting_syslog()


class Ue5gNsaAttachFailedException(Exception):
    pass
