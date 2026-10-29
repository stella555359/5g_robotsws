import logging

from moler.util.moler_test import MolerTest
from testsuite.Krakow.RRM.RAN_PZ.regression.KRK4.CB008127.resources.GnbOperations import GnbOperations
from testsuite.Krakow.RRM.RAN_PZ.regression.KRK4.CB008127.resources.PcapAnalyzer import SgNBModReqAckAnalyzer
from testsuite.Krakow.RRM.RAN_PZ.regression.KRK4.resources.HpePdu import HpePdu
from testsuite.Krakow.RRM.RAN_PZ.regression.KRK4.resources.MediaTek import MediaTek
from testsuite.Krakow.RRM.RAN_PZ.regression.KRK4.resources.Positioner import Positioner


class CustomKeywords(object):
    """
    The CustomKeywords class provides a set of custom methods for handling various operations related to the gNB.
    """

    def __init__(self):
        """
        Initializes the CustomKeywords class.
        """
        self._mod_req_ack = None
        self._gnb_operations = None
        self._positioner = None
        self._mediatek = None
        self._pdu = None

    @property
    def mod_req_ack(self):
        """
        Returns the SgNBModReqAckAnalyzer object.

        If the object is not already created, it creates a new instance of SgNBModReqAckAnalyzer
        and returns it. Otherwise, it returns the existing instance.

        Returns:
            SgNBModReqAckAnalyzer: The SgNBModReqAckAnalyzer object.
        """
        if self._mod_req_ack is None:
            self._mod_req_ack = SgNBModReqAckAnalyzer()
        return self._mod_req_ack

    @property
    def gnb_operations(self):
        """
        Returns the GnbOperations instance.
        If the instance does not exist, it creates a new one and returns it.
        Returns:
            GnbOperations: The GnbOperations instance.
        """
        if self._gnb_operations is None:
            self._gnb_operations = GnbOperations()
        return self._gnb_operations

    @property
    def positioner(self):
        """
        Returns the positioner object.

        If the positioner object is not already created, it creates a new instance of the Positioner class.

        Returns:
            Positioner: The positioner object.
        """
        if self._positioner is None:
            self._positioner = Positioner()
        return self._positioner

    @property
    def mediatek(self):
        """
        Returns an instance of the MediaTek class.

        If the instance does not exist, it creates a new instance and returns it.

        Returns:
            MediaTek: An instance of the MediaTek class.
        """
        if self._mediatek is None:
            self._mediatek = MediaTek()
        return self._mediatek

    @property
    def pdu(self):
        """
        Returns the HpePdu object.

        If the HpePdu object is not already created, it creates a new instance and returns it.

        Returns:
            HpePdu: The HpePdu object.
        """
        if self._pdu is None:
            self._pdu = HpePdu()
        return self._pdu

    def check_if_measurement_profile_settings_used_for_event(self, pcap_name=None, pcap_dir=None, json_path=None,
                                                             profile_id="1", event_name="eventA1", configuration="rsrp",
                                                             nrcell_id="1", nrhoif_id=None, bts_id=0, du_id=0):
        """
        Checks if the measurement profile settings are used for a specific event.

        Args:
            pcap_name (str): The name of the pcap file.
            pcap_dir (str): The directory path of the pcap file.
            json_path (str): The path to the JSON file.
            profile_id (str): The ID of the profile. Default is "1".
            event_name (str): The name of the event. Default is "eventA1".
            configuration (str): The configuration type. Default is "rsrp".
            nrcell_id (str): The ID of the NR cell. Default is "1".
            nrhoif_id (str): The ID of the NRHOIF. Default is None.
            bts_id (int): The ID of the BTS. Default is 0.
            du_id (int): The ID of the DU. Default is 0.

        Raises:
            MeasurementProfileSettingsException: If the measurement profile settings do not match
            the measurement quantities from the pcap.

        Returns:
            None
        """
        profile_type_mapping = {"IAF": ("eventA1", "eventA2"),
                                "IEF": ("eventA3", "eventA4", "eventA5")}
        profile_type = [profile for profile, events in profile_type_mapping.items() if event_name in events][0]
        enabled_ho_config = self.gnb_operations.get_event_enabled_configuration_for_ho(
            event_name=event_name, nrcell_id=nrcell_id, nrhoif_id=nrhoif_id, bts_id=bts_id, du_id=du_id)

        profile_settings = self.gnb_operations.get_from_scf_profile_parameters_ssb_for_ho(
            event_name=event_name, configuration=configuration, profile_type=profile_type, profile_id=profile_id)
        meas_quantities = self.mod_req_ack.get_from_pcap_measurement_quantities_ssb_for_ho(
            event_name=event_name, configuration=configuration, pcap_name=pcap_name, pcap_dir=pcap_dir,
            json_path=json_path)
        if meas_quantities == profile_settings:
            logging.info(f"\n\tPassed: Measurement profile 'NRMEASPR_{profile_type}-{profile_id}' settings: "
                         f"'{profile_settings}' for '{event_name}' enabled handover configuration:'{enabled_ho_config}'"
                         f" were detected in pcap: '{meas_quantities}'. Path: {self.mod_req_ack.processed_file_path}")
        else:
            raise MeasurementProfileSettingsException(
                f"Error: Measurement profile 'NRMEASPR_{profile_type}-{profile_id}' settings: '{profile_settings}' "
                f"for '{event_name}' enabled handover configuration: '{enabled_ho_config} does not match measurement "
                f"quantities from pcap: '{meas_quantities}'. Path: {self.mod_req_ack.processed_file_path}")

    def attach_ue_with_source_cell_ru_rotation(self, pcap_name="TRIGGER_A2.pcap", initial_angle=-20, rotation_angle=30,
                                               wait_after_attach=2, wait_after_rotation=3, ue_id=0, ue_serial_com="69",
                                               detach_ue=True, bts_id=0, du_id=0, cu_id=0):
        """
        Attaches a UE with a source cell RU rotation.

        This method attaches a UE and rotates the source cell in the RU. It starts a TCP dump before the operation
        and stops it afterward. If specified, it also detaches the UE after the operation.

        Parameters:
            pcap_name (str): The name of the pcap file. Default is "TRIGGER_A2.pcap".
            initial_angle (int): The initial angle to set for the positioner. Default is -20.
            rotation_angle (int): The angle to rotate the source cell. Default is 30.
            wait_after_attach (int): The time to wait after attaching the UE. Default is 2.
            wait_after_rotation (int): The time to wait after rotating the source cell. Default is 3.
            ue_id (int): The ID of the UE. Default is 0.
            ue_serial_com (str): The serial COM id of the UE. Default is "69".
            detach_ue (bool): Flag to detach the UE after rotation. Default is True.
            bts_id (int): The ID of the BTS. Default is 0.
            du_id (int): The ID of the DU. Default is 0.
            cu_id (int): The ID of the CU. Default is 0.

        Returns:
            None
            """
        # Master gNB good conditions if angle == -20
        # Slave  gNB good conditions if angle == 30
        self.positioner.set_angle(angle=initial_angle)
        self.positioner.set_angle(angle=initial_angle)
        try:
            self._start_smod_tcpdump(pcap_name, bts_id, du_id, cu_id)
            self.mediatek.attach(ue_id=ue_id, serial_com=ue_serial_com)
            MolerTest.sleep(float(wait_after_attach))
            if rotation_angle:
                self.positioner.set_angle(angle=rotation_angle)
                MolerTest.sleep(wait_after_rotation)
        finally:
            self._stop_smod_tcpdump(ue_id, ue_serial_com, detach_ue)

    def rotate_source_cell_ru(self, pcap_name="TRIGGER_A1.pcap", rotation_angle=-20, ue_id=0, ue_serial_com="69",
                              wait_after_rotation=5, detach_ue=True, bts_id=0, du_id=0, cu_id=0):
        """
        Rotate the source cell RU.

        Args:
            pcap_name (str): Name of the pcap file. Default is "TRIGGER_A1.pcap".
            rotation_angle (int): Angle to rotate the source cell. Default is -20.
            ue_id (int): ID of the UE. Default is 0.
            ue_serial_com (str): Serial COM of the UE. Default is "69".
            wait_after_rotation (int): Time to wait after rotating the source cell. Default is 5.
            detach_ue (bool): Flag to detach the UE after rotation. Default is True.
            bts_id (int): ID of the BTS. Default is 0.
            du_id (int): ID of the DU. Default is 0.
            cu_id (int): ID of the CU. Default is 0.
        """
        try:
            self._start_smod_tcpdump(pcap_name, bts_id, du_id, cu_id)
            self.positioner.set_angle(angle=rotation_angle)
            MolerTest.sleep(wait_after_rotation)
        finally:
            self._stop_smod_tcpdump(ue_id, ue_serial_com, detach_ue)

    def check_a4_measurements(self, nrcell_id, pcap_name, pcap_dir=None, profile_id="1", nrhoif_id="1", bts_id=0,
                              du_id=0):
        """
        Check A4 measurements for a given NR cell.

        Args:
            nrcell_id (str): NR cell ID.
            pcap_name (str): Name of the pcap file.
            pcap_dir (str, optional): Directory path of the pcap file. Defaults to None.
            profile_id (str, optional): Measurement profile ID. Defaults to "1".
            nrhoif_id (str, optional): NR HOIF ID. Defaults to "1".
            bts_id (int, optional): BTS ID. Defaults to 0.
            du_id (int, optional): DU ID. Defaults to 0.
        """
        activation_attempts = self.gnb_operations.get_max_a4_activation_attempts(nrcell_id=nrcell_id, bts_id=bts_id,
                                                                                 du_id=du_id)
        a4_predecessor_msg = "MEAS_A4_ACTIVATION"
        a4_successor_msg = "MEAS_A4_REMOVAL"
        self.mod_req_ack.check_number_of_messages_in_pcap(expected_num=activation_attempts * 2, pcap_name=pcap_name,
                                                          pcap_dir=pcap_dir)
        msg_files = self.mod_req_ack.save_message_pairs_to_separate_files(
            msg_pairs=self.mod_req_ack.group_messages_in_pairs(pcap_name=pcap_name, pcap_dir=pcap_dir),
            predecessor_name=a4_predecessor_msg,
            successor_name=a4_successor_msg)
        path_a4_1st_activation = msg_files["INTERVAL_0"].get(a4_predecessor_msg)
        a4_meas_id = self.mod_req_ack.get_meas_id_of_event_from_mod_req_ack(event_name="eventA4",
                                                                            json_path=path_a4_1st_activation)

        self.check_if_measurement_profile_settings_used_for_event(json_path=path_a4_1st_activation,
                                                                  profile_id=profile_id, event_name="eventA4",
                                                                  configuration="rsrq", nrcell_id=nrcell_id,
                                                                  nrhoif_id=nrhoif_id, bts_id=bts_id, du_id=du_id)
        self._validate_a4_measurements_per_interval(msg_files=msg_files, a4_meas_id=a4_meas_id,
                                                    a4_predecessor_msg=a4_predecessor_msg,
                                                    a4_successor_msg=a4_successor_msg)

    def reboot_mediatek_ue(self, expected_state="off", pdu_id=0, port_id=0):
        """
        Reboots the MediaTek UE.

        Args:
            expected_state (str, optional): The expected state of the pdu port. Defaults to "off".
            pdu_id (int, optional): The ID of the PDU. Defaults to 0.
            port_id (int, optional): The ID of the port. Defaults to 0.
        """
        self.pdu.reset_pdu_port(expected_state=expected_state, pdu_id=pdu_id, port_id=port_id)
        MolerTest.sleep(90)  # Wait until reboot procedure finished

    def _validate_a4_measurements_per_interval(self, msg_files, a4_meas_id, a4_predecessor_msg, a4_successor_msg):
        """
        Validates A4 measurements for each interval.

        Args:
            msg_files (dict): A dictionary containing message files for each interval.
            a4_meas_id (str): The A4 measurement ID to validate.
            a4_predecessor_msg (str): The predecessor message for A4 measurement.
            a4_successor_msg (str): The successor message for A4 measurement.
        """
        for interval, files in msg_files.items():
            logging.info(f"\n\tVerification of A4 measurements from '{interval}':")
            self.mod_req_ack.check_if_event_measurement_id_added(event_name="eventA4", event_meas_id=a4_meas_id,
                                                                 json_path=files.get(a4_predecessor_msg))
            self.mod_req_ack.check_event_meas_id_in_remove_list(event_name="eventA4", event_meas_id=a4_meas_id,
                                                                json_path=files.get(a4_successor_msg))

    def _start_smod_tcpdump(self, pcap_name, bts_id, du_id, cu_id):
        """
        Starts SMOD TCP dump with the given parameters.

        Args:
            pcap_name (str): The name of the pcap file.
            bts_id (int): The BTS ID.
            du_id (int): The DU ID.
            cu_id (int): The CU ID.
        """
        self.gnb_operations.start_smod_tcpdump(pcap_name=pcap_name, interface="any", msg_filter="sctp",
                                               bts_id=bts_id, du_id=du_id, cu_id=cu_id)

    def _stop_smod_tcpdump(self, ue_id, ue_serial_com, detach_ue):
        """
        Stops the SMOD TCP dump and performs additional operations if specified.

        Args:
            ue_id (int): The ID of the UE.
            ue_serial_com (str): The serial communication port of the UE.
            detach_ue (bool): Flag indicating whether to detach the UE.

        Returns:
            None
        """
        self.gnb_operations.stop_smod_tcpdump()
        if detach_ue:
            self.mediatek.detach(ue_id=ue_id, serial_com=ue_serial_com)
        self.gnb_operations.download_pcap_from_smod_to_output_dir()


class MeasurementProfileSettingsException(Exception):
    """
    Exception raised for errors related to measurement profile settings.
    """
    pass
