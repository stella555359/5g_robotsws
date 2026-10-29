"""
Keywords for Feature: enable feature flags in configuration file.

:author: Arkadiusz Kowalczyk
:contact: arkadiusz.kowalczyk@nokia.com

"""
from taf.rfrl.bts.devices.generic_bts import login_logout_GUI
from taf.rfrl.bts.devices.du.du_operations import GnbDuOperations as GnbBbu


class ScfOperations(GnbBbu):

    @login_logout_GUI
    def enable_act_category_alarms_parameter(self, bts_id=0, du_id=0):
        dist = "MRBTS-{}/MNL-1/MNLENT-1/FMCADM-1"
        param = "Activate Category Alarms"
        value = "true"
        self.gui_coam.set_parameter_value(
            dist_name=self.adjust_dist_name(dist_name=dist, bts_id=bts_id, du_id=du_id),
            filter_param=param,
            new_value=value,
            sbts=self.gui_alias.format(bts_id, du_id))

    @login_logout_GUI
    def enable_detection_of_unstable_ecpri_link(self, bts_id=0, du_id=0):
        dist = "MRBTS-{}/MNL-1/MNLENT-1/FEATCADM-1"
        param = "Activate detection of unstable eCPRI links"
        value = "true"
        self.gui_coam.set_parameter_value(
            dist_name=self.adjust_dist_name(dist_name=dist, bts_id=bts_id, du_id=du_id),
            filter_param=param,
            new_value=value,
            sbts=self.gui_alias.format(bts_id, du_id))
