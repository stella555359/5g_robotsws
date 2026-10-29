from taf.rfrl.bts.devices.du.du_operations import GnbDuOperations
from taf.rfrl.bts.devices.ru.ru_operations import GnbRuOperations
from taf.rfrl.utilities.tl_config import load_moler_configuration_from_tl


class GnbPower(object):
    """
    This class represents the operations that can be performed on a gNB.
    """

    def __init__(self):
        self._gnb_du = None
        self._gnb_ru = None
        self._gnb_scf = None

    @property
    def gnb_du(self):
        """
        Returns the GnbDuOperations instance.
        If the instance does not exist, it creates a new one and returns it.
        Returns:
            GnbDuOperations: The GnbDuOperations instance.
        """
        if self._gnb_du is None:
            self._gnb_du = GnbDuOperations()
        return self._gnb_du

    @property
    def gnb_ru(self):
        """
        Returns the GnbRuOperations instance.
        If the instance does not exist, it creates a new one and returns it.
        Returns:
            GnbRuOperations: The GnbRuOperations instance.
        """
        if self._gnb_ru is None:
            self._gnb_ru = GnbRuOperations()
        return self._gnb_ru

    @load_moler_configuration_from_tl()
    def power_on_gnb(self, bts_id=0, du_id=0, cu_id=0, wait_for_onair=False, connection_timeout=900,
                     onair_timeout=900):
        """
        Power on a gNB.

        Args:
            bts_id (int): The ID of the BTS station - related to Test Line configuration.
            du_id (int): The ID of the DU - related to Test Line configuration.
            cu_id (int): The ID of the CU - related to Test Line configuration.
            wait_for_onair (bool): Wait for OnAir status if True.
            connection_timeout (int): The maximum time to wait for admin connection.
            onair_timeout (int): The maximum time to wait for OnAir status.

        Returns:
            None
        """
        self.gnb_du.smods_power_on(cu_ids=[cu_id], bts_id=bts_id, du_id=du_id, check_status_before=True)
        self.gnb_ru.radio_unit_power_on(bts_id=bts_id, du_id=du_id, check_status_before=True)
        self.gnb_du.wait_unitl_connection_via_admin_is_possible(bts_id=bts_id, du_id=du_id, timeout=connection_timeout)
        if wait_for_onair:
            self.gnb_du.wait_for_site_to_be_onair(bts_id=bts_id, du_id=du_id, timeout=onair_timeout)
