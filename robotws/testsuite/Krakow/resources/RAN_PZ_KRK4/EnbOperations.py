"""
Custom operations on eNB.

:copyright: Nokia Networks
:author: Rafal Kawa
:contact: rafal.kawa@nokia.com
:maintainer: rafal.kawa@nokia.com
"""

from taf.rfrl.bts.devices.dist_name_patterns import EnbDistNamePatterns
from taf.rfrl.bts.devices.du.commissioning import EnbCommissioning
from taf.rfrl.bts.devices.du.du_operations import EnbDuOperations
from taf.rfrl.bts.devices.ru.ru_operations import EnbRuOperations
from taf.rfrl.utilities.tl_config import load_moler_configuration_from_tl


class EnbOperations(object):
    """
    This class represents the operations that can be performed on an eNB.
    """

    def __init__(self):
        self._enb_du = None
        self._enb_ru = None
        self._enb_scf = None
        self.enb_dist_names = EnbDistNamePatterns()

    @property
    def enb_du(self):
        """
        Returns the EnbDuOperations instance.
        If the instance does not exist, it creates a new one and returns it.
        Returns:
            EnbDuOperations: The EnbDuOperations instance.
        """
        if self._enb_du is None:
            self._enb_du = EnbDuOperations()
        return self._enb_du

    @property
    def enb_ru(self):
        """
        Returns the EnbRuOperations instance.
        If the instance does not exist, it creates a new one and returns it.
        Returns:
            EnbRuOperations: The EnbRuOperations instance.
        """
        if self._enb_ru is None:
            self._enb_ru = EnbRuOperations()
        return self._enb_ru

    @property
    def enb_scf(self):
        """
        Returns the EnbCommissioning instance.
        If the instance does not exist, it creates a new one and returns it.
        Returns:
            EnbCommissioning: The EnbCommissioning instance.
        """
        if self._enb_scf is None:
            self._enb_scf = EnbCommissioning()
        return self._enb_scf

    @load_moler_configuration_from_tl()
    def power_on_enb(self, bts_id=0, du_id=0, cu_id=0, timeout=900):
        """
        Power on the eNB.

        Args:
            bts_id (int): The ID of the base transceiver station.
            du_id (int): The ID of the distributed unit.
            cu_id (int): The ID of the central unit.
            timeout (int): The maximum time to wait for the eNodeB to power on.

        Returns:
            None
        """
        self.enb_du.smods_power_on(cu_ids=[cu_id], bts_id=bts_id, du_id=du_id, check_status_before=True)
        self.enb_ru.radio_unit_power_on(bts_id=bts_id, du_id=du_id, check_status_before=True)
        self.enb_du.wait_unitl_connection_via_admin_is_possible(bts_id=bts_id, du_id=du_id, timeout=timeout)
        self.enb_du.wait_for_site_to_be_onair(bts_id=bts_id, du_id=du_id, timeout=timeout)

    @load_moler_configuration_from_tl()
    def set_nr_dc_carrier_frequency(self, frequency, bts_id=0, du_id=0):
        """
        Set the NR DC carrier frequency for the eNB.

        Args:
            frequency (str): The frequency to set.
            bts_id (int): The ID of the base transceiver station.
            du_id (int): The ID of the distributed unit.

        Returns:
            None
        """
        self.enb_scf.perform_object_recommissioning(
            dist_name=self.enb_scf.adjust_dist_name(
                dist_name=f"{self.enb_dist_names.bts_dist_name}/NRDCDPR-0/ENDCDMEASCONF-0", bts_id=bts_id, du_id=du_id),
            parameter=[{"parameterName": 'carrierFreqNrCell',
                        "operation": "update",
                        "value": frequency}],
            operation='update')

    def activate_endc_subscriber_profile_id_forwarding(self, value="true", bts_id=0, du_id=0):
        """
        Activate or deactivate the forwarding of the ENDC subscriber profile ID.

        Args:
            value (str): The value to set. Either "true" or "false".
            bts_id (int): The ID of the BTS.
            du_id (int): The ID of the DU.

        Returns:
            None
        """
        self.enb_scf.perform_configuration_parameter_recommissioning(
            dist_name=self.enb_scf.adjust_dist_name(
                dist_name=self.enb_dist_names.bts_dist_name, bts_id=bts_id, du_id=du_id),
            parameter="actEndcSpidFwd", operation="update", value=value, bts_id=bts_id, du_id=du_id)

    def set_default_nr_cell_for_dual_connectivity(self, lnrelgnbcell_id="0", lncel_id="1", bts_id=0, du_id=0,
                                                  timeout=180):
        """
        Specifies the default LNRELGNBCELL instance which shall be used for dual connectivity.

        Args:
            lnrelgnbcell_id (str): The identifier of LTE Neighbor Relation to gNB Cell.
            lncel_id (str): The identifier of LTE BTS Cell.
            bts_id (int): The ID of the BTS.
            du_id (int): The ID of the DU.
            timeout (int): Time to wait for positive procedure result.

        Returns:
            None
        """
        self.enb_scf.perform_configuration_parameter_recommissioning(
            dist_name=self.enb_scf.adjust_dist_name(
                dist_name=self.enb_dist_names.cell_dist_name.replace("LNCEL-{}", f"LNCEL-{lncel_id}"),
                bts_id=bts_id, du_id=du_id),
            parameter="defaultLnRelGnbCellId", operation="update", value=lnrelgnbcell_id, bts_id=bts_id, du_id=du_id,
            timeout=timeout)
