import logging

from moler.device import DeviceFactory
from taf.rfrl.bts.connections.device_aliases import syslog_bts_du
from taf.rfrl.bts.devices.du.combined.observers import GenericObservers
from taf.rfrl.bts.devices.du.du_operations import GnbDuOperations
from taf.rfrl.utilities.tl_config import load_moler_configuration_from_tl
from taf.rfrl.utilities.logger.custom_logger import log_info_to_console
from testsuite.Krakow.RRM.RAN_PZ.regression.KRK4.CB008127.resources.GnbOperations import GnbOperations


class CustomObservers(GenericObservers):
    """
    CustomObservers class represents a collection of custom observers for monitoring specific events in a system.
    """

    def __init__(self, bts_type='GNB'):
        """
        Initializes the CustomObservers object.
        """
        super().__init__(bts_type)
        self.ief_profile_selected = False
        self.iaf_profile_selected = False
        self.meas_profile_used = False
        self.secondary_quantity_evaluated = False
        self.handover_succeeded = False
        self._sgnb_addition_observer = None
        self.source_cell_band = None
        self.source_nrcell_id = None
        self.target_nrcell_id = None
        self.target_physical_cell_id = None
        self.target_cell_band = None
        self.target_cell_arfcn = None
        self._gnb_operations = None
        self._du_operations = None

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
    def du_operations(self):
        """
        Returns the GnbDuOperations instance.
        If the instance does not exist, it creates a new one and returns it.
        Returns:
            GnbDuOperations: The GnbDuOperations instance.
        """
        if self._du_operations is None:
            self._du_operations = GnbDuOperations()
        return self._du_operations

    @load_moler_configuration_from_tl()
    def start_selected_iaf_profile_observer(self, source_cell_id, mapping_profile_id, mapping_profile_type="MA_NSA",
                                            mapping_profile_name="nrMeasPrMaNsa", meas_profile_name="NrMeasPrIaf",
                                            meas_profile_id=None, gnb_id=0, du_id=0, timeout=900):
        """
        Starts the Measurement IntraFreq Profile observer.

        Args:
            source_cell_id (str): The ID of the source cell.
            mapping_profile_id (str): The ID of the mapping profile.
            mapping_profile_type (str, optional): The type of the measurement mapping profile. Defaults to "MA_NSA".
            mapping_profile_name (str, optional): The name of the measurement mapping profile. Default "nrMeasPrMaNsa".
            meas_profile_name (str, optional): The name of the measurement profile. Defaults to "NrMeasPrIaf".
            meas_profile_id (int, optional): The ID of the measurement profile. If not provided, it will be obtained
                from the mapping profile. Defaults to None.
            gnb_id (int, optional): The ID of the GNB. Defaults to 0.
            du_id (int, optional): The ID of the DU. Defaults to 0.
            timeout (float, optional): The timeout value in seconds. Defaults to 900.
        """
        self._get_source_cell_params(source_cell_id=source_cell_id, gnb_id=gnb_id, du_id=du_id)
        if not meas_profile_id:
            meas_profile_id = self.gnb_operations.get_iaf_meas_profile_id_from_mapping_profile(
                mapping_profile_id=mapping_profile_id, mapping_profile_type=mapping_profile_type, bts_id=gnb_id,
                du_id=du_id)
        _re_mapping = r"MeasurementProfilesUtils.cpp:\d+ Selected measurement profile mapping ID \({}Id\) {} " \
                      r"for band {}, cell: {}.*".format(mapping_profile_name, mapping_profile_id, self.source_cell_band,
                                                        self.source_nrcell_id)
        _re_profile = (
            rf"SelectedMeasurementProfiles.cpp:\d+ IntraFreqProfile {meas_profile_name}Ptr was set to: "
            rf"{meas_profile_id}"
            if self.du_operations.get_bts_sw_release_name() < "SBTS26R1"
            else rf"SelectedMeasurementProfiles.cpp:\d+ Marking IntraFreq profile {meas_profile_id} as used")
        device_name = self.syslog_alias.format(gnb_id, du_id)
        if 'selected_iaf_profile' not in self.observers:
            self.observers['selected_iaf_profile'] = {}

        logging.info("Start measurement IntraFreqProfile observer on device {}".format(device_name))
        sys_device = DeviceFactory.get_device(name=device_name)

        syslog_selected_profile = sys_device.get_event(
            event_name="wait4",
            event_params={"detect_patterns": [_re_mapping, _re_profile],
                          "match": 'sequence',
                          "till_occurs_times": 1}
        )

        self.observers['selected_iaf_profile'][device_name] = syslog_selected_profile

        syslog_selected_profile.add_event_occurred_callback(
            callback=self._selected_iaf_profile_callback,
            callback_params={'mapping_profile_name': mapping_profile_name,
                             'mapping_profile_id': mapping_profile_id,
                             'source_cell_band': self.source_cell_band,
                             'source_cell_id': self.source_nrcell_id,
                             'meas_profile_name': meas_profile_name,
                             'meas_profile_id': meas_profile_id}
        )

        syslog_selected_profile.start(timeout=float(timeout))

    @load_moler_configuration_from_tl()
    def start_selected_ief_profile_observer(self, source_cell_id, target_cell_id, mapping_profile_id,
                                            mapping_profile_type="MA_NSA", mapping_profile_name="nrMeasPrMaNsa",
                                            meas_profile_name="NrMeasPrIef", meas_profile_id=None, gnb_id=0, du_id=0,
                                            target_gnb_id=1, target_du_id=0, timeout=900):
        """
        Starts the Measurement InterFreq Profile observer.

        Args:
            source_cell_id (str): The ID of the source cell.
            target_cell_id (str): The ID of the target cell.
            mapping_profile_id (str): The ID of the mapping profile.
            mapping_profile_type (str, optional): The type of the measurement mapping profile. Defaults to "MA_NSA".
            mapping_profile_name (str, optional): The name of the measurement mapping profile. Default "nrMeasPrMaNsa".
            meas_profile_name (str, optional): The name of the measurement profile. Defaults to "NrMeasPrIef".
            meas_profile_id (int, optional): The ID of the measurement profile. Defaults to None.
            gnb_id (int, optional): The ID of the GNB. Defaults to 0.
            du_id (int, optional): The ID of the DU. Defaults to 0.
            target_gnb_id (int, optional): The ID of the target GNB. Defaults to 1.
            target_du_id (int, optional): The ID of the target DU. Defaults to 0.
            timeout (int, optional): The timeout value in seconds. Defaults to 900.
        """
        self._get_source_cell_params(source_cell_id=source_cell_id, gnb_id=gnb_id, du_id=du_id)
        self._get_target_cell_params(target_cell_id=target_cell_id, target_gnb_id=target_gnb_id,
                                     target_du_id=target_du_id)
        if not meas_profile_id:
            self.gnb_operations.get_ief_meas_profile_id_from_mapping_profile(
                mapping_profile_id=mapping_profile_id, target_cell_id=target_cell_id, bts_id=0, du_id=0,
                mapping_profile_type=mapping_profile_type, target_gnb_id=1, target_du_id=1)
        _re_mapping = r"MeasurementProfilesUtils.cpp:\d+ Selected measurement profile mapping ID \({}Id\) {} " \
                      r"for band {}, cell: {}.*".format(mapping_profile_name, mapping_profile_id, self.source_cell_band,
                                                        self.source_nrcell_id)
        _re_profile = (
            rf".*SelectedMeasurementProfiles.cpp:\d+ InterFreqProfile {meas_profile_name}Ptr was set to: "
            rf"{meas_profile_id} for band {self.target_cell_band} and freq {self.target_cell_arfcn}"
            if self.du_operations.get_bts_sw_release_name() < "SBTS26R1"
            else rf"SelectedMeasurementProfiles.cpp:\d+ Marking InterFreq profile {meas_profile_id} as used: band "
                 rf"{self.target_cell_band}, freq {self.target_cell_arfcn}")
        device_name = self.syslog_alias.format(gnb_id, du_id)
        if 'selected_ief_profile' not in self.observers:
            self.observers['selected_ief_profile'] = {}

        logging.info("Start measurement InterFreqProfile observer on device {}".format(device_name))
        sys_device = DeviceFactory.get_device(name=device_name)

        syslog_selected_profile = sys_device.get_event(
            event_name="wait4",
            event_params={"detect_patterns": [_re_mapping, _re_profile],
                          "match": 'sequence',
                          "till_occurs_times": 1}
        )

        self.observers['selected_ief_profile'][device_name] = syslog_selected_profile

        syslog_selected_profile.add_event_occurred_callback(
            callback=self._selected_ief_profile_callback,
            callback_params={'mapping_profile_name': mapping_profile_name,
                             'mapping_profile_id': mapping_profile_id,
                             'source_cell_band': self.source_cell_band,
                             'source_cell_id': self.source_nrcell_id,
                             'meas_profile_name': meas_profile_name,
                             'meas_profile_id': meas_profile_id,
                             'target_cell_band': self.target_cell_band,
                             'target_cell_freq': self.target_cell_arfcn}
        )

        syslog_selected_profile.start(timeout=float(timeout))

    @load_moler_configuration_from_tl()
    def start_measurement_a3_rsrq_combined_evaluation_observer(self, source_cell_id, target_cell_id,
                                                               mapping_profile_name="nrMeasPrMaNsa",
                                                               mapping_profile_id="1", meas_profile_type="IEF",
                                                               meas_profile_id="1", gnb_id=0, du_id=0,
                                                               target_gnb_id=1, target_du_id=0, timeout=900):
        """
        Starts the measurement A3 RSRQ combined evaluation observer.

        Args:
            source_cell_id (str): The ID of the source cell.
            target_cell_id (str): The ID of the target cell.
            mapping_profile_name (str, optional): The name of the mapping profile. Defaults to "nrMeasPrMaNsa".
            mapping_profile_id (str, optional): The ID of the mapping profile. Defaults to "1".
            meas_profile_type (str, optional): The type of the measurement profile. Defaults to "IEF".
            meas_profile_id (str, optional): The ID of the measurement profile. Defaults to "1".
            gnb_id (int, optional): The ID of the GNB. Defaults to 0.
            du_id (int, optional): The ID of the DU. Defaults to 0.
            target_gnb_id (int, optional): The ID of the target GNB. Defaults to 1.
            target_du_id (int, optional): The ID of the target DU. Defaults to 0.
            timeout (int, optional): The timeout value in seconds. Defaults to 900.
        """
        self._get_source_cell_params(source_cell_id=source_cell_id, gnb_id=gnb_id, du_id=du_id)
        self._get_target_cell_params(target_cell_id=target_cell_id, target_gnb_id=target_gnb_id,
                                     target_du_id=target_du_id)
        _re_mapping_profile = r"Selected measurement profile mapping ID \({}Id\) {} for band {}, cell: {}.*".format(
            mapping_profile_name, mapping_profile_id, self.source_cell_band, self.source_nrcell_id)
        _re_selected_meas_profile = r"Using nrMeasPrIef for ssbFrequency {} found in {} {} nrMeasPrIefList, cell: {}" \
                                    r"".format(self.target_cell_arfcn, mapping_profile_name, mapping_profile_id,
                                               self.source_nrcell_id)
        _measurement_evaluation_flow = self._get_measurement_a3_evaluation_flow(
            meas_profile_id=meas_profile_id, meas_profile_type=meas_profile_type, configuration="rsrp",
            bts_id=gnb_id, du_id=du_id)

        device_name = self.syslog_alias.format(gnb_id, du_id)
        if 'secondary_quantity_evaluation' not in self.observers:
            self.observers['secondary_quantity_evaluation'] = {}
        logging.info(f"Start measurement A3 secondary quantity evaluation observer on device {device_name}")
        if 'selected_profile_during_evaluation' not in self.observers:
            self.observers['selected_profile_during_evaluation'] = {}
        logging.info(f"Start measurement profile observer during secondary quantity evaluation on device {device_name}")

        sys_device = DeviceFactory.get_device(name=device_name)
        syslog_secondary_quantity_evaluation = sys_device.get_event(
            event_name="wait4",
            event_params={"detect_patterns": _measurement_evaluation_flow,
                          "match": 'sequence',
                          "till_occurs_times": 1}
        )
        syslog_selected_profile = sys_device.get_event(
            event_name="wait4",
            event_params={"detect_patterns": [_re_mapping_profile, _re_selected_meas_profile],
                          "match": 'sequence',
                          "till_occurs_times": 1}
        )

        self.observers['secondary_quantity_evaluation'][device_name] = syslog_secondary_quantity_evaluation
        self.observers['selected_profile_during_evaluation'][device_name] = syslog_selected_profile

        syslog_secondary_quantity_evaluation.add_event_occurred_callback(
            callback=self._secondary_quantity_evaluation_callback,
            callback_params={'meas_name': "A3"}
        )
        syslog_selected_profile.add_event_occurred_callback(
            callback=self._selected_profile_during_evaluation_callback,
            callback_params={'meas_profile_type': meas_profile_type,
                             'meas_profile_id': meas_profile_id,
                             'meas_name': "A3"}
        )

        syslog_secondary_quantity_evaluation.start(timeout=float(timeout))
        syslog_selected_profile.start(timeout=float(timeout))

    @load_moler_configuration_from_tl()
    def start_inter_freq_handover_observer(self, source_cell_id, target_cell_id, gnb_id=0, du_id=0, target_gnb_id=1,
                                           target_du_id=0, timeout=900):
        """
        Starts an observer for inter-frequency handover.

        Args:
            source_cell_id (str): The ID of the source cell.
            target_cell_id (str): The ID of the target cell.
            gnb_id (int, optional): The ID of the GNB. Defaults to 0.
            du_id (int, optional): The ID of the DU. Defaults to 0.
            target_gnb_id (int, optional): The ID of the target GNB. Defaults to 1.
            target_du_id (int, optional): The ID of the target DU. Defaults to 0.
            timeout (int, optional): The timeout value in seconds. Defaults to 900.
        """
        self._get_source_cell_params(source_cell_id=source_cell_id, gnb_id=gnb_id, du_id=du_id)
        self._get_target_cell_params(target_cell_id=target_cell_id, target_gnb_id=target_gnb_id,
                                     target_du_id=target_du_id)
        _re_handover_success = r"Update for inter-GNB relation from source cell:{} to target cell:{} with PhyCellId" \
                               r":<LOG_SCRAM_\d+>{}</LOG_SCRAM_\d+> with ssbFrequency: {} with new status: " \
                               r"hoSucceeded".format(self.source_nrcell_id, self.target_nrcell_id,
                                                     self.target_physical_cell_id, self.target_cell_arfcn)
        device_name = self.syslog_alias.format(gnb_id, du_id)

        if 'handover_succeeded' not in self.observers:
            self.observers['handover_succeeded'] = {}

        logging.info("Start inter frequency handover observer on device {}".format(device_name))
        sys_device = DeviceFactory.get_device(name=device_name)

        syslog_ho_succeeded = sys_device.get_event(
            event_name="wait4",
            event_params={"detect_patterns": [_re_handover_success],
                          "match": 'all',
                          "till_occurs_times": 1}
        )

        self.observers['handover_succeeded'][device_name] = syslog_ho_succeeded

        syslog_ho_succeeded.add_event_occurred_callback(
            callback=self._ief_ho_succeeded_callback,
            callback_params={'target_cell': self.target_nrcell_id,
                             'source_cell': self.source_nrcell_id}
        )

        syslog_ho_succeeded.start(timeout=float(timeout))

    def start_sgnb_addition_success_observer(self, timeout=900, bts_id=0, du_id=0):
        """
        Starts the observer for SgNbAddition success events.

        Args:
            timeout (int): Timeout value in seconds (default: 900).
            bts_id (int): BTS ID (default: 0).
            du_id (int): DU ID (default: 0).
        """
        re_success = r"PCMD Record for SgNbAdditionResultReason in SgNbAddition record : SgNbAdditionResult:success"
        sys_device = DeviceFactory.get_device(name=syslog_bts_du.format("GNB", bts_id, du_id))
        observer_sgnb_additions = sys_device.get_event(
            event_name="wait4",
            event_params={"detect_patterns": [re_success],
                          "match": 'all'})
        self._sgnb_addition_observer = observer_sgnb_additions
        observer_sgnb_additions.start(timeout=timeout)

    def count_successful_sgnb_addition_results(self):
        """
        Counts the number of successful SgNbAdditionResult occurrences in the syslog.

        Returns:
            int: The number of successful SgNbAdditionResult occurrences.
        """
        self._sgnb_addition_observer.break_event()
        occurrences = self._sgnb_addition_observer.result()
        logging.info(f"Found SgNbAdditionResult:success in syslog: '{occurrences}'")
        return len(occurrences)

    def verify_selected_iaf_measurement_profile(self):
        """
        Verifies if intra-frequency measurement profile is selected.

        Raises:
            MeasurementProfileObserverException: If 'selected_iaf_profile' observer is not set
            or if the required IAF measurement profile is not found in the syslog.
        """
        if self.observers.get('selected_iaf_profile') is None:
            raise MeasurementProfileObserverException("Please first run 'start_selected_iaf_profile_observer' ")
        if self.iaf_profile_selected:
            self.iaf_profile_selected = False
        else:
            self.iaf_profile_selected = False
            raise MeasurementProfileObserverException(f"Error: Not found in syslog required IAF measurement profile")

    def verify_selected_ief_measurement_profile(self):
        """
        Verifies if inter-frequency measurement profile is selected.

        Raises:
            MeasurementProfileObserverException: If the 'selected_ief_profile' observer is not set
            or if the required IEF measurement profile is not found in the syslog.
        """
        if self.observers.get('selected_ief_profile') is None:
            raise MeasurementProfileObserverException("Please first run 'start_selected_ief_profile_observer' ")
        if self.ief_profile_selected:
            self.ief_profile_selected = False
        else:
            self.ief_profile_selected = False
            raise MeasurementProfileObserverException(f"Error: Not found in syslog required IEF measurement profile")

    def verify_measurement_a3_rsrq_combined_evaluation(self):
        """
        Verifies the measurement A3 rsrqCombined evaluation procedure.

        Raises:
            MeasurementProfileObserverException: If 'secondary_quantity_evaluation' observer is not found or if the
            verification fails.
        """
        if self.observers.get('secondary_quantity_evaluation') is None:
            raise MeasurementProfileObserverException(
                "Please first run 'start_measurement_a3_rsrq_combined_evaluation_observer' ")
        if self.secondary_quantity_evaluated and self.meas_profile_used:
            self.secondary_quantity_evaluated = False
            self.meas_profile_used = False
        else:
            self.secondary_quantity_evaluated = False
            self.meas_profile_used = False
            raise MeasurementProfileObserverException(f"Error: Verification of measurement A3 rsrqCombined evaluation "
                                                      f"procedure failed")

    def verify_inter_freq_handover_succeeded(self):
        """
        Verifies if the inter-frequency handover has succeeded.

        Raises:
            InterFrequencyHandoverFailedException: If the handover has failed.
            Exception: If 'start_inter_freq_handover_observer' has not been run before.
        """
        if self.observers.get('handover_succeeded') is None:
            raise Exception("Please first run 'start_inter_freq_handover_observer' ")
        if self.handover_succeeded:
            self.handover_succeeded = False
        else:
            self.handover_succeeded = False
            raise InterFrequencyHandoverFailedException()

    def _selected_iaf_profile_callback(self, mapping_profile_name, mapping_profile_id, source_cell_band,
                                       source_cell_id, meas_profile_name, meas_profile_id):
        """
        Callback function for when an IntraFreqProfile is selected.

        Args:
            mapping_profile_name (str): The name of the mapping profile.
            mapping_profile_id (str): The ID of the mapping profile.
            source_cell_band (str): The band of the source cell.
            source_cell_id (str): The ID of the source cell.
            meas_profile_name (str): The name of the measurement profile.
            meas_profile_id (str): The ID of the measurement profile.
        """
        log_info_to_console(f"\nSelected measurement mapping profile {mapping_profile_name}: "
                            f"{mapping_profile_id} for band: {source_cell_band} and cell: {source_cell_id}"
                            f"\nSelected measurement IntraFreqProfile '{meas_profile_name}: {meas_profile_id}'")
        self.iaf_profile_selected = True

    def _selected_ief_profile_callback(self, mapping_profile_name, mapping_profile_id, source_cell_band,
                                       source_cell_id, meas_profile_name, meas_profile_id, target_cell_band,
                                       target_cell_freq):
        """
        Callback function called when an InterFreqProfile is selected for measurement.

        Args:
            mapping_profile_name (str): The name of the mapping profile.
            mapping_profile_id (str): The ID of the mapping profile.
            source_cell_band (str): The band of the source cell.
            source_cell_id (str): The ID of the source cell.
            meas_profile_name (str): The name of the measurement profile.
            meas_profile_id (str): The ID of the measurement profile.
            target_cell_band (str): The band of the target cell.
            target_cell_freq (int): The frequency of the target cell.
        """
        log_info_to_console(f"\nSelected measurement mapping profile {mapping_profile_name}: "
                            f"{mapping_profile_id} for band: {source_cell_band} and cell: {source_cell_id}"
                            f"\nSelected measurement InterFreqProfile {meas_profile_name}: {meas_profile_id} "
                            f"for band {target_cell_band} and freq {target_cell_freq}")
        self.ief_profile_selected = True

    def _secondary_quantity_evaluation_callback(self, meas_name):
        """
        Callback function for evaluating secondary quantities.

        Args:
            meas_name (str): The name of the measurement.

        Returns:
            None
        """
        log_info_to_console(f"\nMeasurement {meas_name} secondary quantity evaluation and validation completed.")
        self.secondary_quantity_evaluated = True

    def _selected_profile_during_evaluation_callback(self, meas_name, meas_profile_type, meas_profile_id):
        """
        Callback function called when a measurement profile is selected during evaluation.

        Args:
            meas_name (str): The name of the measurement.
            meas_profile_type (str): The type of the measurement profile.
            meas_profile_id (str): The ID of the measurement profile.

        Returns:
            None
        """
        log_info_to_console(f"\nMeasurement profile {meas_profile_type}: {meas_profile_id} was used "
                            f"during {meas_name} secondary quantity evaluation.")
        self.meas_profile_used = True

    def _ief_ho_succeeded_callback(self, target_cell, source_cell):
        """
        Callback function for successful Inter Frequency handover.

        Args:
            target_cell (str): The ID of the target cell.
            source_cell (str): The ID of the source cell.
        """
        log_info_to_console("\nInter Frequency handover succeeded from cell_id:{} to cell_id:{}".format(source_cell,
                                                                                                        target_cell))
        self.handover_succeeded = True

    def _get_measurement_a3_evaluation_flow(self, meas_profile_id, meas_profile_type="IEF", configuration="rsrp",
                                            bts_id=0, du_id=0):
        """
        Get the measurement A3 evaluation flow.

        Args:
            meas_profile_id (str): The measurement profile ID.
            meas_profile_type (str, optional): The measurement profile type. Defaults to "IEF".
            configuration (str, optional): The configuration. Defaults to "rsrp".
            bts_id (int, optional): The BTS ID. Defaults to 0.
            du_id (int, optional): The DU ID. Defaults to 0.

        Returns:
            list: A list containing the regular expressions for configuration, event inspector, and report status.
        """
        ho_params = self._get_ssb_params_for_ho(event_name="eventA3", configuration=configuration,
                                                meas_profile_type=meas_profile_type, meas_profile_id=meas_profile_id,
                                                bts_id=bts_id, du_id=du_id)
        re_config = r"A3 inter frequency measurement profile rsrp config is used for rsrqCombined evaluation"
        re_event_inspector = r"A3 hysteresis = {}, A3 offset =.*{}.*, isRsrpMeasResultValid = true".format(
            ho_params.get("a3HysteresisSsbRsrp"), ho_params.get("a3OffsetSsbRsrp"))
        return [re_config, re_event_inspector]

    def _get_ssb_params_for_ho(self, event_name="eventA3", configuration="rsrp", meas_profile_type="IEF",
                               meas_profile_id="1", bts_id=0, du_id=0):
        """
        Retrieves SSB parameters of event for handover.

        Args:
            event_name (str): Name of the event. Default is "eventA3".
            configuration (str): Configuration type. Default is "rsrp".
            meas_profile_type (str): Measurement profile type. Default is "IEF".
            meas_profile_id (str): Measurement profile ID. Default is "1".
            bts_id (int): BTS ID. Default is 0.
            du_id (int): DU ID. Default is 0.

        Returns:
            dict: SSB parameters of event for handover.
        """
        return self.gnb_operations.get_from_scf_profile_parameters_ssb_for_ho(
            event_name=event_name, configuration=configuration, profile_type=meas_profile_type,
            profile_id=meas_profile_id, bts_id=bts_id, du_id=du_id)

    def _get_source_cell_params(self, source_cell_id, gnb_id, du_id):
        """
        Retrieves the parameters of the source cell based on the provided cell ID, GNB ID, and DU ID.

        Args:
            source_cell_id (str): The ID of the source cell.
            gnb_id (str): The ID of the GNB.
            du_id (str): The ID of the DU.

        Returns:
            dict: A dictionary containing the parameters of the source cell.
        """
        source_cell_params = self._get_cell_params(nrcell_id=source_cell_id, bts_id=gnb_id, du_id=du_id)
        logging.info(f"SourceCell parameters for observer: '{source_cell_params}'")
        self.source_cell_band = source_cell_params.get("freqBandIndicatorNR")
        self.source_nrcell_id = source_cell_params.get("nrCellIdentity")

    def _get_target_cell_params(self, target_cell_id, target_gnb_id, target_du_id):
        """
        Retrieves the parameters of the target cell based on the provided cell ID, GNB ID, and DU ID.

        Args:
            target_cell_id (str): The ID of the target cell.
            target_gnb_id (int): The ID of the target GNB.
            target_du_id (int): The ID of the target DU.

        Returns:
            dict: A dictionary containing the parameters of the target cell.
        """
        target_cell_params = self._get_cell_params(nrcell_id=target_cell_id, bts_id=target_gnb_id, du_id=target_du_id)
        logging.info(f"TargetCell parameters for observer: '{target_cell_params}'")
        self.target_cell_band = target_cell_params.get("freqBandIndicatorNR")
        self.target_cell_arfcn = target_cell_params.get("arfcnSsbPbch")
        self.target_nrcell_id = target_cell_params.get("nrCellIdentity")
        self.target_physical_cell_id = target_cell_params.get("physCellId")

    def _get_cell_params(self, nrcell_id, bts_id=0, du_id=0):
        """
        Get the cell parameters for a given NR cell ID.

        Args:
            nrcell_id (str): The NR cell ID.
            bts_id (int, optional): The BTS ID. Defaults to 0.
            du_id (int, optional): The DU ID. Defaults to 0.

        Returns:
            dict: The cell parameters for the given NR cell ID.
        """
        return self.gnb_operations.get_nrcell_params_for_profile_observer(nrcell_id=nrcell_id, bts_id=bts_id,
                                                                          du_id=du_id)


class MeasurementProfileObserverException(Exception):
    """
    Exception raised for errors related to the MeasurementProfileObserver class.
    """
    pass


class InterFrequencyHandoverFailedException(Exception):
    """
    Exception raised when an inter-frequency handover fails.
    """
    pass
