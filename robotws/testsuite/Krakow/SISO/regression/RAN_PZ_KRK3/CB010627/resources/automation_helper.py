import logging
import re
from taf.rfrl.bts.devices.asir.asir_operations import GnbAsirHubOperations
from taf.rfrl.bts.devices.du.du_operations import GnbDuOperations
from taf.rfrl.bts.helpers.sw_versions import SbtsSwVersion


class AsirHelper(GnbAsirHubOperations):

    def _show_all_active_asir_webem_alarms(self):
        return self.get_active_asir_webem_alarms()

    def verify_if_fault_4480_antmod_not_detected_is_active_on_awhqc(self, ant_id):
        active_alarms = self._show_all_active_asir_webem_alarms()
        for alarm in active_alarms:
            if alarm['source_object'] == 'ASI-1/ASI_R-1/ANTMOD_R-{}'.format(ant_id) and alarm['fault_id'] == 4480 and \
                    alarm['fault_name'] == 'ANTMOD not detected':
                return True
        return False


class BtsHelper(GnbDuOperations):

    def get_current_sw_release(self):
        """
        Get current SW release for BTS
        :return: SW release version
        """
        sw_version = self.get_bts_sw_version()
        sw_release = SbtsSwVersion(sw_version).release
        return sw_release

    def _get_current_config_name(self):
        return self.get_gnb_parameter_value_via_gui(dist_name="MRBTS-77146", param_name="BTS name",
                                                    param_abbr="btsName")

    def _is_config_active_on_bts(self, config_name):
        full_config_name = self._get_current_config_name().lower()
        if config_name.lower() in full_config_name:
            return True
        else:
            return False

    def is_config1_active_on_bts(self):
        return self._is_config_active_on_bts(config_name="config1")

    def is_config2_active_on_bts(self):
        return self._is_config_active_on_bts(config_name="config2")
