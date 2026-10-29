import logging
import time
from taf.rfrl.bts.devices.du.du_operations import GnbDuOperations as GnbBbu
from taf.rfrl.bts.devices.exceptions import InvalidParameterValue, ValidationError
from taf.rfrl.bts.devices.generic_bts import login_logout_GUI
from taf.rfrl.bts.connections import device_aliases as connection_names
from taf.rfrl.utilities.tl_config import load_moler_configuration_from_tl
from moler.device import DeviceFactory


class ConfigurationOperations(GnbBbu):

    @login_logout_GUI
    def change_parameter(self, dist, param, value, bts_id=0, du_id=0):
        self.gui_coam.set_parameter_value(
            dist_name=self.adjust_dist_name(dist_name=dist, bts_id=bts_id, du_id=du_id),
            filter_param=param,
            new_value=value,
            sbts=self.gui_alias.format(bts_id, du_id))

    @login_logout_GUI
    def activate_plan(self, bts_id=0, du_id=0):
        gui_alias = self.gui_alias.format(bts_id, du_id)
        self.gui_coam.validate_plan(sbts=gui_alias)
        self.gui_coam.activate_plan(sbts=gui_alias)
        logging.info("Waiting for activation")
        time.sleep(30)

    @login_logout_GUI
    def try_change_parameter_to_incorrect_value(self, dist, param, value, bts_id=0, du_id=0):
        gui_alias = self.gui_alias.format(bts_id, du_id)
        parameter_value = self.gui_coam.get_parameter_value(
            dist_name=self.adjust_dist_name(dist_name=dist, bts_id=bts_id, du_id=du_id),
            filter_param=param,
            sbts=gui_alias)
        self.verify_if_parameter_changed_to_incorrect_value_via_gui(
            dist_name=self.adjust_dist_name(dist_name=dist, bts_id=bts_id, du_id=du_id),
            parameter=param,
            value=value)
        self.gui_coam.undo_changes(sbts=gui_alias)
        self.verify_parameter_after_change(dist=dist, param=param, value=parameter_value)

    @login_logout_GUI
    def verify_parameter_after_change(self, dist, param, value, bts_id=0, du_id=0):
        gui_alias = self.gui_alias.format(bts_id, du_id)
        parameter_value = self.gui_coam.get_parameter_value(
            dist_name=self.adjust_dist_name(dist_name=dist, bts_id=bts_id, du_id=du_id),
            filter_param=param, sbts=gui_alias)
        if parameter_value != value:
            raise InvalidParameterValue("{} value should be: {}, but is: {}".format(param, value, parameter_value))
        self.gui_coam.validate_plan(sbts=gui_alias)
        if self.gui_coam.get_relation_errors(sbts=gui_alias) or self.gui_coam.get_hardware_errors(sbts=gui_alias) \
                or self.gui_coam.get_definition_errors(sbts=gui_alias):
            raise ValidationError

    @login_logout_GUI
    def save_and_verify_report(self, bts_id=0, du_id=0):
        report_path = self.gui_coam.save_report(sbts=self.gui_alias.format(bts_id, du_id))
        self.check_report(report_path=report_path)

    @load_moler_configuration_from_tl()
    def check_report(self, report_path, gnb_id=0, du_id=0):
        vm = DeviceFactory.get_device(format(connection_names.ws_du.format(self.bts_type, gnb_id, du_id)))
        unzip_cmd = vm.get_cmd(cmd_name="unzip", cmd_params={'zip_file': report_path, 'options': '-o'})
        cat_cmd = vm.get_cmd(cmd_name="cat", cmd_params={'path': "report-data.txt", 'options': " | grep result"})
        unzip_cmd()
        results = cat_cmd()['LINES']
        if results[0].find("successfully") == -1 or results[1].find("successfully") == -1:
            raise Exception("Report check failed")
