import logging

from moler.device import DeviceFactory
from taf.internal.sbts.admin.exceptions import AdminApiProcedureTimeoutException
from taf.rfrl.bts.connections.device_aliases import ssh_cu_unit
from taf.rfrl.bts.devices.dist_name_patterns import GnbDistNamePatterns
from taf.rfrl.bts.devices.du.alarm_verification import GnbAlarmVerification
from taf.rfrl.bts.devices.du.cell_operations import GnbCellOperations
from taf.rfrl.bts.devices.du.commissioning import GnbCommissioning
from taf.rfrl.bts.devices.du.du_operations import GnbDuOperations
from taf.rfrl.utilities.robot.general import get_builtin_value
from taf.rfrl.utilities.tl_config import load_moler_configuration_from_tl
from taf.rfrl.utilities.transfer_files import download_files


class GnbOperations(object):
    """
    Class representing GNB operations.

    Attributes:
        _timeout_cmd (int): Timeout for commands in seconds.
        _device_smod (None): SMOD device.
        _device_smod_name (None): SMOD device name.
        _pcap_name (None): Name of the pcap file to save captured traffic.
        _cmd_tcpdump (None): TCP dump command.
        _cell_params (dict): Dictionary to store cell parameters.
        _log_path (str): Path to the log directory.
        _gnb_distname (GnbDistNamePatterns): GNB dist name patterns.
        _du_operations (None): DU operations.
        _gnb_cell (None): GNB cell operations.
        _gnb_scf (None): GNB commissioning operations.
        _gnb_alarm (None): GNB alarm verification operations.
    """

    def __init__(self):
        """
        Initializes a new instance of the GnbOperations class.
        """
        self._timeout_cmd = 900
        self._device_smod = None
        self._device_smod_name = None
        self._pcap_name = None
        self._cmd_tcpdump = None
        self._cell_params = {}
        self._log_path = get_builtin_value('LOG_PATH')
        self._gnb_distname = GnbDistNamePatterns()
        self._du_operations = None
        self._gnb_cell = None
        self._gnb_scf = None
        self._gnb_alarm = None

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

    @property
    def gnb_cell(self):
        """
        Returns the GnbCellOperations instance.
        If the instance doesn't exist, it creates a new one and returns it.
        Returns:
            GnbCellOperations: The GnbCellOperations instance.
        """
        if self._gnb_cell is None:
            self._gnb_cell = GnbCellOperations()
        return self._gnb_cell

    @property
    def gnb_scf(self):
        """
        Returns the GnbCommissioning instance.
        If the instance doesn't exist, it creates a new one and returns it.
        Returns:
            GnbCommissioning: The GnbCommissioning object for GNB SCF operations.
        """
        if self._gnb_scf is None:
            self._gnb_scf = GnbCommissioning()
        return self._gnb_scf

    @property
    def gnb_alarm(self):
        """
        Returns the GnbAlarmVerification object.
        If the instance doesn't exist, it creates a new one and returns it.
        Returns:
            GnbAlarmVerification: The GnbAlarmVerification object.
        """
        if self._gnb_alarm is None:
            self._gnb_alarm = GnbAlarmVerification()
        return self._gnb_alarm

    @load_moler_configuration_from_tl()
    def start_smod_tcpdump(self, pcap_name="SMOD_SCTP.pcap", interface="any", msg_filter="sctp", bts_id=0, du_id=0,
                           cu_id=0):
        """
        Starts capturing network traffic using tcpdump on the specified interface.

        Args:
            pcap_name (str): Name of the pcap file to save the captured traffic. Default is "SMOD_SCTP.pcap".
            interface (str): Interface on which to capture the traffic. Default is "any".
            msg_filter (str): Filter to apply on captured messages. Default is "sctp".
            bts_id (int): ID of the BTS. Default is 0.
            du_id (int): ID of the DU. Default is 0.
            cu_id (int): ID of the CU. Default is 0.

        Returns:
            None
        """
        self._create_smod_device(bts_id=bts_id, du_id=du_id, cu_id=cu_id)
        self._pcap_name = pcap_name
        self._create_smod_sniffer(interface=interface, msg_filter=msg_filter)
        self._cmd_tcpdump.start(timeout=self._timeout_cmd)

    def stop_smod_tcpdump(self):
        """
        Stops the smod tcpdump.
        """
        self._cmd_tcpdump.break_cmd()

    def download_pcap_from_smod_to_output_dir(self):
        """
        Downloads a pcap file from the SMOD to the output directory.
        """
        download_files(local_dir=self._log_path, remote_file=self._pcap_name, device_name=self._device_smod_name,
                       remote_dir="/tmp/", from_state="FCT", timeout=self._timeout_cmd, remove_source_file=True)

    def get_event_enabled_configuration_for_ho(self, event_name="eventA1", nrcell_id="1", nrhoif_id=None, bts_id=0,
                                               du_id=0):
        """
        Retrieves the enabled configuration for a specific event in handover.

        Args:
            event_name (str): The name of the event. Default is "eventA1".
            nrcell_id (str): The ID of the NR cell. Default is 1.
            nrhoif_id (str): The ID of the NR HOIF. Default is None.
            bts_id (int): The ID of the BTS. Default is 0.
            du_id (int): The ID of the DU. Default is 0.

        Returns:
            enabled_config (str): The enabled configuration for the specified event.

        Raises:
            NotFoundInScfException: If the 'NRHOIF' object matched to the given 'NRCELL' is not found in BTS SCF.
        """
        enabled_config = None
        structure_mapping = {"nrcell_params": {"eventA1": "a1MeashoEnabled",
                                               "eventA2": "a2MeashoEnabled"},
                             "nrhoif_params": {"eventA3": "a3MeasEnabled",
                                               "eventA4": "a4MeasHigherPrioFreqEnabled",
                                               "eventA5": "a5MeasEnabled"}}
        self._save_cell_params(cell_id=nrcell_id, bts_id=bts_id, du_id=du_id)
        if event_name in structure_mapping["nrcell_params"].keys():
            enabled_config = self._cell_params[nrcell_id].get(structure_mapping["nrcell_params"].get(event_name))
        else:
            nrhoif_pattern = f"NRCELL-{nrcell_id}/NRHOIF-{nrhoif_id}"
            nrhoif_objects = self._get_object_from_scf(object_class_name="com.nokia.srbts.nrbts:NRHOIF",
                                                       bts_id=bts_id, du_id=du_id)
            for nrhoif in nrhoif_objects:
                if nrhoif_pattern in nrhoif.get("dist_name"):
                    enabled_config = nrhoif["params"].get(structure_mapping["nrhoif_params"].get(event_name))
            if not enabled_config:
                raise NotFoundInScfException(f"Error: Not found 'NRHOIF-{nrhoif_id}' object "
                                             f"matched to given 'NRCELL-{nrcell_id}' in BTS SCF")
        return enabled_config

    def get_from_scf_profile_parameters_ssb_for_ho(self, event_name="eventA1", configuration="rsrp", profile_type="IAF",
                                                   profile_id="1", bts_id=0, du_id=0):
        """
        Retrieves the measurement profile parameters for SSB in handover.

        Args:
            event_name (str): The name of the event. Default is "eventA1".
            configuration (str): The configuration to retrieve. Default is "rsrp".
            profile_type (str): The type of the measurement profile. Default is "IAF".
            profile_id (str): The ID of the profile. Default is "1".
            bts_id (int): The ID of the BTS. Default is 0.
            du_id (int): The ID of the DU. Default is 0.

        Returns:
            param_value: The value of the retrieved parameter.

        """
        param_structure = {"eventA1": {"rsrp": "a1MeashoSsbRsrp",
                                       "rsrq": "a1MeashoSsbRsrq"},
                           "eventA2": {"rsrp": "a2MeashoSsbRsrp",
                                       "rsrq": "a2MeashoSsbRsrq"},
                           "eventA3": {"rsrp": "a3MeasSsbRsrp",
                                       "rsrq": "a3MeasSsbRsrq"},
                           "eventA4": {"rsrp": "a4MeasHigherPrioFreqSsbRsrp",
                                       "rsrq": "a4MeasHigherPrioFreqSsbRsrq"},
                           "eventA5": {"rsrp": "a5MeasSsbRsrp",
                                       "rsrq": "a5MeasSsbRsrq"}}
        profile = self._get_measurement_profile_object_from_scf(
            profile_type=profile_type, profile_id=profile_id, bts_id=bts_id, du_id=du_id)
        return profile["params"][param_structure[event_name].get(configuration)][0]

    def get_nrcell_params_for_profile_observer(self, nrcell_id, bts_id=0, du_id=0):
        """
        Retrieves the NR cell parameters for measurement profile observer.

        Args:
            nrcell_id (str): The ID of the NR cell.
            bts_id (int): The ID of the BTS. Default is 0.
            du_id (int): The ID of the DU. Default is 0.

        Returns:
            cell_params_for_observer (dict): Dictionary containing the NR cell parameters.
        """
        param_names = ["nrCellIdentity", "freqBandIndicatorNR", "arfcnSsbPbch", "physCellId"]
        cell_params_for_observer = dict()
        self._save_cell_params(cell_id=nrcell_id, bts_id=bts_id, du_id=du_id)
        for param in param_names:
            cell_params_for_observer[param] = self._cell_params[nrcell_id].get(param)
        return cell_params_for_observer

    def count_duration_of_all_meas_a4_intervals(self, nrcell_id, bts_id=0, du_id=0):
        """
        Counts the duration of all A4 measurement intervals.

        Args:
            nrcell_id (str): The ID of the NR cell.
            bts_id (int): The ID of the BTS. Default is 0.
            du_id (int): The ID of the DU. Default is 0.

        Returns:
            duration (int): The duration of all A4 measurement intervals.
        """
        timer_retry = self.get_timer_value(timer_name="a4_retry", nrcell_id=nrcell_id, bts_id=bts_id, du_id=du_id)
        timer_supervision = self.get_timer_value(timer_name="a4_supervision", nrcell_id=nrcell_id, bts_id=bts_id,
                                                 du_id=du_id)
        activation_attempts = self.get_max_a4_activation_attempts(nrcell_id=nrcell_id, bts_id=bts_id, du_id=du_id)
        # All A4 intervals duration: (from A4 meas activation to A4 MeasId removal) * activation_attempts
        duration = (timer_retry + timer_supervision) * activation_attempts
        return duration + 1

    def get_max_a4_activation_attempts(self, nrcell_id, bts_id=0, du_id=0):
        """
        Retrieves the maximum number of A4 activation attempts.

        Args:
            nrcell_id (str): The ID of the NR cell.
            bts_id (int): The ID of the BTS. Default is 0.
            du_id (int): The ID of the DU. Default is 0.

        Returns:
            max_attempts (int): The maximum number of A4 activation attempts.
        """
        self._save_cell_params(cell_id=nrcell_id, bts_id=bts_id, du_id=du_id)
        return int(self._cell_params[nrcell_id].get("a4MeasMaxNumber"))

    def activate_mobility_to_higher_priority_freq(self, value="NSA", bts_id=0, du_id=0):
        """
        Activates mobility to higher priority frequency.

        Args:
            value (str): The value to set. Default is "NSA".
            bts_id (int): The ID of the BTS. Default is 0.
            du_id (int): The ID of the DU. Default is 0.
        """
        self.gnb_scf.perform_configuration_parameter_recommissioning(
            dist_name=self._gnb_distname.bts_dist_name,
            parameter="actHigherPrioFreqHo",
            operation='update',
            value=value,
            bts_id=bts_id,
            du_id=du_id)

    def define_a4_threshold_for_ssb_rsrq(self, threshold, profile_type="IEF", profile_id="1", profile_group_id="1",
                                         bts_id=0, du_id=0):
        """
        Defines the A4 threshold for SSB RSRQ.

        Args:
            threshold (str): The threshold value.
            profile_type (str): The type of the profile. Default is "IEF".
            profile_id (str): The ID of the profile. Default is "1".
            profile_group_id (str): The ID of the profile group. Default is "1".
            bts_id (int): The ID of the BTS. Default is 0.
            du_id (int): The ID of the DU. Default is 0.
        """
        self.update_meas_profile_param_from_structure(param_name="a4ThresholdSsbRsrq", param_value=threshold,
                                                      structure_name="a4MeasHigherPrioFreqSsbRsrq",
                                                      profile_type=profile_type, profile_id=profile_id,
                                                      profile_group_id=profile_group_id, bts_id=bts_id, du_id=du_id)

    def define_a3_offset_ssb_rsrp(self, offset, profile_type="IEF", profile_id="1", profile_group_id="1",
                                  bts_id=0, du_id=0):
        """
        Defines the A3 offset for SSB RSRP.

        Args:
            offset (str): The offset value.
            profile_type (str): The type of the profile. Default is "IEF".
            profile_id (str): The ID of the profile. Default is "1".
            profile_group_id (str): The ID of the profile group. Default is "1".
            bts_id (int): The ID of the BTS. Default is 0.
            du_id (int): The ID of the DU. Default is 0.
        """
        self.update_meas_profile_param_from_structure(param_name="a3OffsetSsbRsrp", param_value=offset,
                                                      structure_name="a3MeasSsbRsrp", profile_type=profile_type,
                                                      profile_id=profile_id, profile_group_id=profile_group_id,
                                                      bts_id=bts_id, du_id=du_id)

    def define_subscriber_profile_id_in_mapping_profile(self, spid="256", profile_type="MA_NSA", profile_id="11",
                                                        profile_group_id="1", remove_param=False, bts_id=0, du_id=0):
        """
        Defines the subscriber profile ID in the measurement mapping profile.

        Args:
            spid (str): The subscriber profile ID. Default is "256".
            profile_type (str): The type of the measurement mapping profile. Default is "MA_NSA".
            profile_id (str): The ID of the measurement mapping profile. Default is "11".
            profile_group_id (str): The ID of the measurement profile group. Default is "1".
            remove_param (bool): Whether to remove the parameter. Default is False.
            bts_id (int): The ID of the BTS. Default is 0.
            du_id (int): The ID of the DU. Default is 0.
        """
        self._update_meas_profile_parameter(remove_param=remove_param, param_name="spid", param_value=spid,
                                            profile_type=profile_type, profile_id=profile_id,
                                            profile_group_id=profile_group_id, bts_id=bts_id, du_id=du_id)

    def define_last_subscriber_profile_id_in_mapping_profile(self, spid_last="256", profile_type="MA_NSA",
                                                             profile_id="11", profile_group_id="1", remove_param=False,
                                                             bts_id=0, du_id=0):
        """
        Defines the last subscriber profile ID in the mapping profile.

        Args:
            spid_last (str): The last subscriber profile ID. Default is "256".
            profile_type (str): The type of the profile. Default is "MA_NSA".
            profile_id (str): The ID of the profile. Default is "11".
            profile_group_id (str): The ID of the profile group. Default is "1".
            remove_param (bool): Whether to remove the parameter. Default is False.
            bts_id (int): The ID of the BTS. Default is 0.
            du_id (int): The ID of the DU. Default is 0.
        """
        self._update_meas_profile_parameter(remove_param=remove_param, param_name="spidLast", param_value=spid_last,
                                            profile_type=profile_type, profile_id=profile_id,
                                            profile_group_id=profile_group_id, bts_id=bts_id, du_id=du_id)

    def enable_measurement_configuration_for_ho(self, event_name="eventA3", config="rsrp", nrcell_id=1,
                                                nrhoif_id=None, bts_id=0, du_id=0):
        """
        Enables measurement configuration for handover.

        Args:
            event_name (str): The name of the event triggering the measurement configuration. Default is "eventA3".
            config (str): The configuration parameter value. Default is "rsrp".
            nrcell_id (str): The ID of the NR cell. Default is 1.
            nrhoif_id (int): The ID of the NRHOIF. Default is None.
            bts_id (int): The ID of the BTS. Default is 0.
            du_id (int): The ID of the DU. Default is 0.
        """
        structure_mapping = {"nrcell_params": {"eventA1": "a1MeashoEnabled",
                                               "eventA2": "a2MeashoEnabled"},
                             "nrhoif_params": {"eventA3": "a3MeasEnabled",
                                               "eventA4": "a4MeasHigherPrioFreqEnabled",
                                               "eventA5": "a5MeasEnabled"}}
        if event_name in structure_mapping["nrcell_params"].keys():
            self._update_nrcell_parameter(parameter_name=structure_mapping["nrcell_params"].get(event_name),
                                          nrcell_id=nrcell_id, parameter_value=config, bts_id=bts_id, du_id=du_id)
        else:
            self._update_nrhoif_parameter(parameter_name=structure_mapping["nrhoif_params"].get(event_name),
                                          nrcell_id=nrcell_id, nrhoif_id=nrhoif_id, parameter_value=config,
                                          bts_id=bts_id, du_id=du_id)

    def get_timer_value(self, timer_name="a4_retry", **kwargs):
        """
        Get the value of a timer.

        Args:
            timer_name (str): The name of the timer. Defaults to "a4_retry".
            **kwargs: Additional keyword arguments to be passed to the timer function.

        Returns:
            The value of the timer.

        Raises:
            NotImplementedError: If the timer function is not implemented.
        """
        name = f"_get_timer_{timer_name}"
        if hasattr(self, name):
            get_timer = getattr(self, name)
            if callable(get_timer):
                return get_timer(**kwargs)
        else:
            raise NotImplementedError(f"Error: '{name}' is not implemented!")

    def activate_subscriber_profile_id(self, value="true", bts_id=0, du_id=0):
        """
        Activates the subscriber profile ID.

        Args:
            value (str, optional): The value to set for the activation. Defaults to "true".
            bts_id (int, optional): The BTS ID. Defaults to 0.
            du_id (int, optional): The DU ID. Defaults to 0.
        """
        self.gnb_scf.perform_configuration_parameter_recommissioning(
            dist_name=self._gnb_distname.bts_dist_name,
            parameter="actSPID",
            operation='update',
            value=value,
            bts_id=bts_id,
            du_id=du_id)

    def get_iaf_meas_profile_id_from_mapping_profile(self, mapping_profile_id, mapping_profile_type="MA_NSA", bts_id=0,
                                                     du_id=0):
        """
        Retrieves the IAF measurement profile ID from the given measurement mapping profile.

        Args:
            mapping_profile_id (str): The ID of the measurement mapping profile.
            mapping_profile_type (str, optional): The type of the measurement mapping profile. Defaults to "MA_NSA".
            bts_id (int, optional): The ID of the BTS. Defaults to 0.
            du_id (int, optional): The ID of the DU. Defaults to 0.

        Returns:
            str: The IAF measurement profile ID extracted from the mapping profile.

        """
        mapping_profile = self._get_measurement_profile_object_from_scf(
            profile_type=mapping_profile_type, profile_id=mapping_profile_id, bts_id=bts_id, du_id=du_id)["params"]
        meas_profile_dn = mapping_profile.get("nrMeasPrIafDN")
        return meas_profile_dn.split("NRMEASPR_IAF-")[-1]

    def get_ief_meas_profile_id_from_mapping_profile(self, mapping_profile_id, target_cell_id, bts_id=0, du_id=0,
                                                     mapping_profile_type="MA_NSA", target_gnb_id=1, target_du_id=1):
        """
        Retrieves the IEF measurement profile ID from the measurement mapping profile.

        Args:
            mapping_profile_id (str): The ID of the measurement mapping profile.
            target_cell_id (str): The ID of the target cell.
            bts_id (int, optional): The ID of the BTS. Defaults to 0.
            du_id (int, optional): The ID of the DU. Defaults to 0.
            mapping_profile_type (str, optional): The type of the mapping profile. Defaults to "MA_NSA".
            target_gnb_id (int, optional): The ID of the target GNB. Defaults to 1.
            target_du_id (int, optional): The ID of the target DU. Defaults to 1.

        Returns:
            str: The IEF measurement profile ID.
        """
        self._save_cell_params(cell_id=target_cell_id, bts_id=target_gnb_id, du_id=target_du_id)
        mapping_profile = self._get_measurement_profile_object_from_scf(
            profile_type=mapping_profile_type, profile_id=mapping_profile_id, bts_id=bts_id, du_id=du_id)["params"]
        target_cell_arfcn = self._cell_params[target_cell_id].get("arfcnSsbPbch")
        dedicated_profile_dn = self._get_ief_meas_profile_dn_associated_with_ssb_frequency(
            mapping_profile_object=mapping_profile, target_cell_arfcn=target_cell_arfcn)
        meas_profile_dn = dedicated_profile_dn if dedicated_profile_dn else mapping_profile.get("nrMeasPrIefDefaultDN")
        return meas_profile_dn.split("NRMEASPR_IEF-")[-1]

    def get_power_class_capabilities(self, mapping_profile_id, mapping_profile_type="MA_NSA", bts_id=0, du_id=0):
        """
        Retrieves the power class capabilities for a given measurement mapping profile.

        Args:
            mapping_profile_id (str): The ID of the measurement mapping profile.
            mapping_profile_type (str, optional): The type of the measurement mapping profile. Defaults to "MA_NSA".
            bts_id (int, optional): The ID of the BTS. Defaults to 0.
            du_id (int, optional): The ID of the DU. Defaults to 0.

        Returns:
            list: The power class capability list.
        """
        mapping_profile = self._get_measurement_profile_object_from_scf(profile_type=mapping_profile_type,
                                                                        profile_id=mapping_profile_id, bts_id=bts_id,
                                                                        du_id=du_id)["params"]
        return mapping_profile.get("pcCapabilityList")

    def update_power_class_capabilities(self, mapping_profile_id, capabilities_structure, operation="update",
                                        mapping_profile_type="MA_NSA", profile_group_id="1", bts_id=0, du_id=0):
        """
        Update the power class capabilities of a measurement mapping profile.

        Args:
            mapping_profile_id (int): The ID of the measurement mapping profile.
            capabilities_structure (dict): The structure containing the power class capabilities.
            operation (str, optional): The operation to perform. Defaults to "update".
            mapping_profile_type (str, optional): The type of the measurement mapping profile. Defaults to "MA_NSA".
            profile_group_id (str, optional): The ID of the measurement profile group. Defaults to "1".
            bts_id (int, optional): The ID of the BTS. Defaults to 0.
            du_id (int, optional): The ID of the DU. Defaults to 0.
        """
        self._update_meas_profile_structure(structure_object=capabilities_structure, structure_name="pcCapabilityList",
                                            profile_id=mapping_profile_id, profile_type=mapping_profile_type,
                                            profile_group_id=profile_group_id, operation=operation, bts_id=bts_id,
                                            du_id=du_id)

    def update_plmn_list_in_mapping_profile(self, mapping_profile_id, plmn_structure, operation="update",
                                            mapping_profile_type="MA_NSA", profile_group_id="1", bts_id=0, du_id=0):
        """
        Update the PLMN list in the mapping profile.

        Args:
            mapping_profile_id (str): The ID of the measurement mapping profile.
            plmn_structure (dict): The structure object containing the PLMN list.
            operation (str, optional): The operation to perform. Defaults to "update".
            mapping_profile_type (str, optional): The type of the measurement mapping profile. Defaults to "MA_NSA".
            profile_group_id (str, optional): The ID of the measurement profile group. Defaults to "1".
            bts_id (int, optional): The ID of the BTS. Defaults to 0.
            du_id (int, optional): The ID of the DU. Defaults to 0.
        """
        self._update_meas_profile_structure(structure_object=plmn_structure, structure_name="nrPlmnDNList",
                                            profile_id=mapping_profile_id, profile_type=mapping_profile_type,
                                            profile_group_id=profile_group_id, operation=operation, bts_id=bts_id,
                                            du_id=du_id)

    def define_nr_plmn_object(self, nr_plmn_id, operation="create", mcc="1", mnc="1", mnc_length="2", bts_id=0,
                              du_id=0, timeout=900):
        """
        Defines an NR PLMN object with the specified parameters.

        Args:
            nr_plmn_id (str): The ID of the NR PLMN.
            operation (str, optional): The operation to perform on the NR PLMN object. Defaults to "create".
            mcc (str, optional): The Mobile Country Code (MCC) of the NR PLMN. Defaults to "1".
            mnc (str, optional): The Mobile Network Code (MNC) of the NR PLMN. Defaults to "1".
            mnc_length (str, optional): The length of the MNC. Defaults to "2".
            bts_id (int, optional): The ID of the BTS. Defaults to 0.
            du_id (int, optional): The ID of the DU. Defaults to 0.
            timeout (int, optional): The timeout value in seconds. Defaults to 900.
        """
        delta_plmn = [{
            "distName": self.gnb_scf.adjust_dist_name(
                dist_name=f"{self._gnb_distname.bts_dist_name}/NRPLMN-{nr_plmn_id}", bts_id=bts_id, du_id=du_id),
            "operation": operation,
            "parameters": [
                {
                    "operation": "update",
                    "parameterName": "mcc",
                    "value": mcc
                },
                {
                    "operation": "update",
                    "parameterName": "mnc",
                    "value": mnc
                },
                {
                    "operation": "update",
                    "parameterName": "mncLength",
                    "value": mnc_length
                },
                {
                    "operation": "update",
                    "parameterName": "nrPlmnId",
                    "value": nr_plmn_id
                }]}]
        self.gnb_alarm.allow_alarm(alarm=["No X2 link available", "No X2 link available for a specific LTEENB"],
                                   bts_id=bts_id, du_id=du_id)
        self.gnb_scf.perform_bts_delta_commissioning(delta=delta_plmn, bts_id=bts_id, du_id=du_id)
        self.du_operations.wait_unitl_connection_via_admin_is_possible(timeout=timeout, bts_id=bts_id, du_id=du_id)
        self.du_operations.wait_for_site_to_be_onair(timeout=timeout, bts_id=bts_id, du_id=du_id)
        self.gnb_cell.wait_for_all_cells_to_be_onair(cell_type="all", timeout=timeout, interval=30, bts_id=bts_id,
                                                     du_id=du_id)

    def _get_timer_a4_supervision(self, nrcell_id, bts_id=0, du_id=0):
        """
        Get the A4 supervision timer for a specific cell.

        Args:
            nrcell_id (str): The ID of the cell.
            bts_id (int, optional): The ID of the BTS. Defaults to 0.
            du_id (int, optional): The ID of the DU. Defaults to 0.

        Returns:
            float: The A4 supervision timer in miliseconds.
        """
        self._save_cell_params(cell_id=nrcell_id, bts_id=bts_id, du_id=du_id)
        return float(self._cell_params[nrcell_id].get("a4Fr2SupervisionTimer")) / 1000

    def _get_timer_a4_retry(self, nrcell_id, bts_id=0, du_id=0):
        """
        Get the A4 retry timer for a specific cell.

        Args:
            nrcell_id (str): The ID of the NR cell.
            bts_id (int, optional): The ID of the BTS. Defaults to 0.
            du_id (int, optional): The ID of the DU. Defaults to 0.

        Returns:
            float: The A4 retry timer value.
        """
        self._save_cell_params(cell_id=nrcell_id, bts_id=bts_id, du_id=du_id)
        return float(self._cell_params[nrcell_id].get("a4RetryTimer"))

    def _update_meas_profile_parameter(self, param_name, param_value, remove_param=False, profile_type="IEF",
                                       profile_id="1", profile_group_id="1", bts_id=0, du_id=0):
        """
        Update or remove a measurement profile parameter.

        Args:
            param_name (str): The name of the parameter to update or remove.
            param_value (str): The value to update the parameter with.
            remove_param (bool, optional): Whether to remove the parameter. Defaults to False.
            profile_type (str, optional): The type of the measurement profile. Defaults to "IEF".
            profile_id (str, optional): The ID of the measurement profile. Defaults to "1".
            profile_group_id (str, optional): The ID of the measurement profile group. Defaults to "1".
            bts_id (int, optional): The ID of the BTS. Defaults to 0.
            du_id (int, optional): The ID of the DU. Defaults to 0.
        """
        self.gnb_scf.perform_configuration_parameter_recommissioning(
            dist_name=self.gnb_scf.adjust_dist_name(
                dist_name=f"{self._gnb_distname.bts_dist_name}/NRMEAS_PROFILE-{profile_group_id}/"
                          f"NRMEASPR_{profile_type}-{profile_id}", bts_id=bts_id, du_id=du_id),
            parameter=param_name,
            operation='delete' if remove_param else "update",
            value=param_value,
            bts_id=bts_id,
            du_id=du_id)

    def update_meas_profile_param_from_structure(self, param_name, param_value, structure_name, remove_param=False,
                                                 profile_type="IEF", profile_id="1", profile_group_id="1", bts_id=0,
                                                 du_id=0):
        """
        Updates a measurement profile parameter from a given structure.

        Args:
            param_name (str): The name of the parameter to be updated.
            param_value (any): The new value of the parameter.
            structure_name (str): The name of the structure containing the parameter.
            remove_param (bool, optional): Whether to remove the parameter. Defaults to False.
            profile_type (str, optional): The type of the measurement profile. Defaults to "IEF".
            profile_id (str, optional): The ID of the measurement profile. Defaults to "1".
            profile_group_id (str, optional): The ID of the measurement profile group. Defaults to "1".
            bts_id (int, optional): The ID of the BTS. Defaults to 0.
            du_id (int, optional): The ID of the DU. Defaults to 0.
        """
        structure = self._get_measurement_profile_object_from_scf(
            profile_type=profile_type, profile_id=profile_id, bts_id=bts_id, du_id=du_id)["params"].get(
            structure_name)[0]
        logging.info(f"Structure '{structure_name}' from 'NRMEASPR_{profile_type}-{profile_id}'"
                     f" before update: '{structure}'")
        if remove_param:
            del structure[param_name]
        else:
            structure.update({param_name: param_value})
        self._update_meas_profile_structure(structure_name=structure_name, structure_object=structure,
                                            profile_type=profile_type, profile_id=profile_id,
                                            profile_group_id=profile_group_id, bts_id=bts_id, du_id=du_id)

    def _update_meas_profile_structure(self, structure_name, structure_object, profile_id="1", profile_type="IEF",
                                       profile_group_id="1", operation="update", bts_id=0, du_id=0):
        """
        Update the measurement profile structure.

        Args:
            structure_name (str): The name of the structure.
            structure_object (list or dict): The object containing the structure information.
            profile_id (str, optional): The ID of the measurement profile. Defaults to "1".
            profile_type (str, optional): The type of the measurement profile. Defaults to "IEF".
            profile_group_id (str, optional): The ID of the measurement profile group. Defaults to "1".
            operation (str, optional): The operation to perform. Defaults to "update".
            bts_id (int, optional): The ID of the BTS. Defaults to 0.
            du_id (int, optional): The ID of the DU. Defaults to 0.
        """
        recommissioning_structure = [{"parameterName": structure_name,
                                      "operation": operation,
                                      "value": structure_object if isinstance(structure_object, list) else [
                                          structure_object]}]

        self.gnb_scf.perform_object_recommissioning(
            dist_name=self.gnb_scf.adjust_dist_name(
                dist_name=f"{self._gnb_distname.bts_dist_name}/NRMEAS_PROFILE-{profile_group_id}/"
                          f"NRMEASPR_{profile_type}-{profile_id}", bts_id=bts_id, du_id=du_id),
            parameter=recommissioning_structure,
            operation="update")

    def _update_nrcell_parameter(self, nrcell_id, parameter_name, parameter_value, bts_id=0, du_id=0):
        """
        Update the parameter value of a specific NRCELL.

        Args:
            nrcell_id (str): The ID of the NRCELL.
            parameter_name (str): The name of the parameter to update.
            parameter_value (str): The new value of the parameter.
            bts_id (int, optional): The ID of the BTS. Defaults to 0.
            du_id (int, optional): The ID of the DU. Defaults to 0.
        """
        self.gnb_scf.perform_configuration_parameter_recommissioning(
            dist_name=self.gnb_scf.adjust_dist_name(
                dist_name=f"{self._gnb_distname.bts_dist_name}/NRCELL-{nrcell_id}",
                bts_id=bts_id, du_id=du_id),
            parameter=parameter_name,
            operation='update',
            value=parameter_value,
            bts_id=bts_id,
            du_id=du_id)

    def _update_nrhoif_parameter(self, nrcell_id, nrhoif_id, parameter_name, parameter_value, bts_id=0, du_id=0):
        """
        Update the specified parameter for NRHOIF in NRCELL.

        Args:
            nrcell_id (str): NRCELL ID.
            nrhoif_id (int): NRHOIF ID.
            parameter_name (str): Name of the parameter to be updated.
            parameter_value (str): Value to be set for the parameter.
            bts_id (int, optional): BTS ID. Defaults to 0.
            du_id (int, optional): DU ID. Defaults to 0.
        """
        self.gnb_scf.perform_configuration_parameter_recommissioning(
            dist_name=self.gnb_scf.adjust_dist_name(
                dist_name=f"{self._gnb_distname.bts_dist_name}/NRCELL-{nrcell_id}/NRHOIF-{nrhoif_id}",
                bts_id=bts_id, du_id=du_id),
            parameter=parameter_name,
            operation='update',
            value=parameter_value,
            bts_id=bts_id,
            du_id=du_id)

    def _get_measurement_profile_object_from_scf(self, profile_type="IAF", profile_id="1", bts_id=0, du_id=0):
        """
        Retrieves the measurement profile object from the SCF based on the given parameters.

        Args:
            profile_type (str): The type of the measurement profile. Default is "IAF".
            profile_id (str): The ID of the measurement profile. Default is "1".
            bts_id (int): The ID of the BTS. Default is 0.
            du_id (int): The ID of the DU. Default is 0.

        Returns:
            dict: The measurement profile object retrieved from the SCF.

        Raises:
            NotFoundInScfException: If the profile is not found in the BTS SCF.
        """
        found_profile = None
        pattern_profile = f"NRMEASPR_{profile_type}-{profile_id}"
        profiles = self._get_object_from_scf(object_class_name=f"com.nokia.srbts.nrbts:NRMEASPR_{profile_type}",
                                             bts_id=bts_id, du_id=du_id)
        for profile in profiles:
            if pattern_profile in profile.get("dist_name"):
                found_profile = profile
                return found_profile
        if not found_profile:
            raise NotFoundInScfException(f"Error: Not found profile '{pattern_profile}' in BTS SCF")

    def _get_cell_params(self, cell_id, bts_id=0, du_id=0):
        """
        Get the cell parameters for a specific cell.

        Args:
            cell_id (str): The ID of the cell.
            bts_id (int, optional): The ID of the BTS. Defaults to 0.
            du_id (int, optional): The ID of the DU. Defaults to 0.

        Returns:
            dict: A dictionary containing the cell parameters.
        """
        return self.gnb_cell.get_cell_parameters(cell_id=cell_id, bts_id=bts_id, du_id=du_id)

    def _get_object_from_scf(self, object_class_name, export_type="configurationAndRuntimeObjects",
                             bts_id=0, du_id=0, timeout=180, max_attempts=3):
        """
        Retrieves an object from the SCF based on the specified parameters.

        Args:
            object_class_name (str): The name of the object class to retrieve.
            export_type (str, optional): The export type. Defaults to "configurationAndRuntimeObjects".
            bts_id (int, optional): The BTS ID. Defaults to 0.
            du_id (int, optional): The DU ID. Defaults to 0.
            timeout (int, optional): The timeout value in seconds. Defaults to 180.
            max_attempts (int, optional): The maximum number of attempts to retrieve the object. Defaults to 3.

        Returns:
            list: List of dicts consist of SCF object.

        Raises:
            Exception: If the SCF object could not be retrieved after the maximum number of attempts.
        """
        scf_object = None
        while max_attempts > 0:
            try:
                scf_object = self.gnb_scf.get_all_params_under_class_name(class_name=object_class_name,
                                                                          scf_export_type=export_type, bts_id=bts_id,
                                                                          du_id=du_id, timeout=timeout)
            except AdminApiProcedureTimeoutException:
                max_attempts -= 1
                logging.info(f"AdminApiProcedureTimeoutException occurred during "
                             f"attempt of get '{object_class_name}' object from SCF")
            else:
                return scf_object
        if not scf_object:
            raise NotFoundInScfException("Failed to retrieve SCF object.")

    def _create_smod_device(self, bts_id=0, du_id=0, cu_id=0):
        """
        Creates an SMOD device if it doesn't already exist.

        Args:
            bts_id (int): The BTS ID.
            du_id (int): The DU ID.
            cu_id (int): The CU ID.
        """
        if not self._device_smod:
            self._device_smod_name = ssh_cu_unit.format("GNB", bts_id, du_id, cu_id)
            self._device_smod = DeviceFactory.get_device(name=self._device_smod_name, initial_state='FCT')

    def _create_smod_sniffer(self, interface="any", msg_filter="sctp"):
        """
        Creates a sniffer using tcpdump to capture network traffic.

        Args:
            interface (str): The network interface to capture traffic on. Default is "any".
            msg_filter (str): The filter to apply to captured messages. Default is "sctp".

        Returns:
            None
        """
        self._cmd_tcpdump = self._device_smod.get_cmd(cmd_name="tcpdump", cmd_params={
            "options": "-i {} -s0 -w /tmp/{} {} -v".format(interface, self._pcap_name, msg_filter)})

    def _save_cell_params(self, cell_id, bts_id=0, du_id=0):
        """
        Save the cell parameters for the given cell ID.

        Args:
            cell_id (str): The ID of the cell.
            bts_id (int, optional): The ID of the BTS. Defaults to 0.
            du_id (int, optional): The ID of the DU. Defaults to 0.
        """
        if cell_id not in self._cell_params.keys():
            self._cell_params[cell_id] = self._get_cell_params(cell_id=cell_id, bts_id=bts_id, du_id=du_id)

    @staticmethod
    def _get_ief_meas_profile_dn_associated_with_ssb_frequency(mapping_profile_object, target_cell_arfcn):
        """
        Get the IEF measurement profile distname associated with the given SSB frequency.

        Args:
            mapping_profile_object (dict): The mapping profile object containing the NR measurement profiles.
            target_cell_arfcn (int): The target SSB frequency.

        Returns:
            str or None: The IEF measurement profile distname associated with the SSB frequency, or None if not found.
        """
        ief_list = mapping_profile_object.get("nrMeasPrIefList", [])
        return next(
            (structure.get("nrMeasPrIefDN") for structure in ief_list if target_cell_arfcn in structure.values()), None)


class NotFoundInScfException(Exception):
    """
    Exception raised when a specific item is not found in the SCF.
    """
    pass
