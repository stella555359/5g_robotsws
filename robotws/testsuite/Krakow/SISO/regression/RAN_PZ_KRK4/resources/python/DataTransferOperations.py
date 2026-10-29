"""
Operations on Data Transfer.

:copyright: Nokia Networks
:author: Rafal Kawa
:contact: rafal.kawa@nokia.com
:maintainer: rafal.kawa@nokia.com
"""

import logging
import time

from taf.rfrl.ue.helpers import data_transfer
from taf.rfrl.utilities.robot.general import get_builtin_instance
from testsuite.Krakow.resources.RAN_PZ_KRK4.EnbOperations import EnbOperations
from testsuite.Krakow.SISO.regression.RAN_PZ_KRK4.resources.python.antenna_monitoring_validator import \
    get_current_bts_datetime


class DataTransferOperations(object):
    """
    A class to handle data transfer operations.

    Attributes:
        ue_controlled (bool): Indicates if the UE is controlled.
        ue: Instance of the UE.
        _enb_operations: Instance of EnbOperations, initially set to None.
    """

    def __init__(self):
        """
        Initializes the DataTransferOperations class.
        """
        self.ue_controlled = False
        self.ue = get_builtin_instance("ue")
        self._enb_operations = None

    @property
    def enb_operations(self):
        """
        Returns the EnbOperations instance.
        If the instance does not exist, it creates a new one and returns it.

        Returns:
            EnbOperations: The EnbOperations instance.
        """
        if self._enb_operations is None:
            self._enb_operations = EnbOperations()
        return self._enb_operations

    def attach_ue(self, reboot_ue=True):
        """
        Attaches the UE. If the UE is not controlled, it requires and reboots the UE before attaching.

        Args:
            reboot_ue (bool): Reboot UE before attach. Defaults to True.
        """
        if not self.ue_controlled:
            self.ue.require_ue("UE", "REAL_UE")
            self.ue_controlled = True
        if reboot_ue:
            self.ue.reboot_ue("UE", 120)
        self.ue.attach_ue("UE")

    def detach_ue(self):
        """
        Detaches the UE.
        """
        self.ue.detach_ue("UE")

    def perform_ue_attach_with_nr_state_verification(self, lnrelgnbcell_id=None, lncel_id=None, reboot_ue=True,
                                                     expected_nr_state="5G_NSA"):
        """
        Attaches the UE and verifies its NR state. Optionally sets the default NR cell for dual connectivity.

        Args:
            lnrelgnbcell_id (str, optional): NR cell ID for dual connectivity. Defaults to None.
            lncel_id (str, optional): Cell ID for dual connectivity. Defaults to None.
            reboot_ue (bool, optional): Reboot UE before attach. Defaults to True.
            expected_nr_state (str, optional): Expected NR state after attach. Defaults to "5G_NSA".

        Raises:
            UE5GAttachException: If the UE's NR state does not match the expected state.
        """
        if lnrelgnbcell_id and lncel_id:
            self.enb_operations.set_default_nr_cell_for_dual_connectivity(lnrelgnbcell_id, lncel_id)
        try:
            self.attach_ue(reboot_ue)
            ue_info = self.ue.get_ue_info("UE")
            logging.info(f"ue_info: {ue_info}")
            if ue_info.get("nr_state") != expected_nr_state:
                raise UE5GAttachException(expected_nr_state, ue_info.get("nr_state"))
        finally:
            self.detach_ue()

    def start_dl_tcp_data_transfer(self, duration, expected_tput, tolerance, dt_name="DT_DL"):
        """
        Starts a downlink TCP data transfer on the UE.

        Args:
            duration (str): Duration of the data transfer.
            expected_tput (str): Expected throughput.
            tolerance (str): Tolerance for throughput deviation.
            dt_name (str): Name of the data transfer operation. Default is "DT_DL".
        """
        data_transfer.start_data_transfer_on_real_ue(
            duration=duration, tput=expected_tput, dt_name=dt_name, ue_alias='UE', direction='dl', protocol='tcp',
            parallel_streams='4', size_packet='1436', buffer_client=None, buffer_server=None, interval='1', qci=None,
            linux_congestion='cubic', multi_radio_bearer=False)
        time.sleep(10)  # Wait for throughput stabilization
        self.ue.await_data_transfer_finish(dt_name=dt_name)
        self.ue.verify_average_throughput_with_deviation(dt_name=dt_name, tput=expected_tput, deviation=tolerance)

    def start_ul_tcp_data_transfer(self, duration, expected_tput, tolerance, dt_name="DT_UL"):
        """
        Starts an uplink TCP data transfer on the UE.

        Args:
            duration (str): Duration of the data transfer.
            expected_tput (str): Expected throughput.
            tolerance (str): Tolerance for throughput deviation.
            dt_name (str): Name of the data transfer operation. Default is "DT_UL".
        """
        data_transfer.start_data_transfer_on_real_ue(
            duration=duration, tput=expected_tput, dt_name=dt_name, ue_alias='UE', direction='ul', protocol='tcp',
            parallel_streams='2', size_packet='1436', buffer_client=None, buffer_server=None, interval='1', qci=None,
            linux_congestion=None, multi_radio_bearer=False)
        time.sleep(10)  # Wait for throughput stabilization
        self.ue.await_data_transfer_finish(dt_name=dt_name)
        self.ue.verify_average_throughput_with_deviation(dt_name=dt_name, tput=expected_tput, deviation=tolerance)

    def start_tcp_data_transfer(self, duration, tolerance, expected_dl_tput=None, expected_ul_tput=None,
                                lnrelgnbcell_id=None, lncel_id=None):
        """
        Starts a TCP data transfer - DL TCP if expected_dl_tput provided, then UL TCP if expected_ul_tput provided.
        Optionally set a default NR cell for dual connectivity on eNB before data transfer.

        Args:
            duration (str): Duration of the data transfer.
            tolerance (str): Tolerance for throughput deviation.
            expected_dl_tput (str, optional): Expected downlink throughput.
            expected_ul_tput (str, optional): Expected uplink throughput.
            lnrelgnbcell_id (str, optional): NR cell ID for dual connectivity.
            lncel_id (str, optional): Cell ID for dual connectivity.
        """
        transfer_timestamps = {}
        if lnrelgnbcell_id and lncel_id:
            self.enb_operations.set_default_nr_cell_for_dual_connectivity(lnrelgnbcell_id=lnrelgnbcell_id,
                                                                          lncel_id=lncel_id)
        self.attach_ue()
        try:
            if expected_dl_tput:
                dl_start_time = get_current_bts_datetime()
                self.start_dl_tcp_data_transfer(duration=duration, expected_tput=expected_dl_tput, tolerance=tolerance)
                dl_end_time = get_current_bts_datetime()
                transfer_timestamps["DL"] = {"start_time": dl_start_time, "end_time": dl_end_time}
            if expected_ul_tput:
                ul_start_time = get_current_bts_datetime()
                self.start_ul_tcp_data_transfer(duration=duration, expected_tput=expected_ul_tput, tolerance=tolerance)
                ul_end_time = get_current_bts_datetime()
                transfer_timestamps["UL"] = {"start_time": ul_start_time, "end_time": ul_end_time}
        finally:
            self.detach_ue()
        return transfer_timestamps

    def start_multi_sector_tcp_data_transfer_dl_and_ul(self, sectors_dt_info, duration="60s"):
        """
        Starts TCP data transfer for multiple sectors in both downlink and uplink directions.

        Args:
            sectors_dt_info (dict): Dictionary containing sector information for data transfer.
            duration (str): Duration of the data transfer. Defaults to 60s.
        """
        for sector in sectors_dt_info:
            self.start_tcp_data_transfer(
                duration=duration, expected_dl_tput=sectors_dt_info[sector]["downlink"],
                expected_ul_tput=sectors_dt_info[sector]["uplink"], tolerance=sectors_dt_info[sector]["deviation"],
                lnrelgnbcell_id=sectors_dt_info[sector]["lnrelgnbcell_id"], lncel_id=sectors_dt_info[sector]["lncel_id"]
            )


class UE5GAttachException(Exception):
    """Exception raised for 5G attach procedure failure."""

    def __init__(self, expected_nr_state, actual_nr_state):
        self.expected_nr_state = expected_nr_state
        self.actual_nr_state = actual_nr_state
        super().__init__(f"UE attach to 5G failed. Expected NR state: {expected_nr_state}, actual: {actual_nr_state}")
