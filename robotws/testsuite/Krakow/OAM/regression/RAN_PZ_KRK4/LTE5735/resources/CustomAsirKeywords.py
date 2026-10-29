import logging
from taf.rfrl.bts.devices.asir.asir_operations import GnbAsirHubOperations, login_logout
from taf.rfrl.utilities.robot.general import get_builtin_value, set_robot_test_variable


class CustomAsirKeywords(GnbAsirHubOperations):

    @login_logout
    def validate_runtime_parameter_viewer(self, bts_id=0):
        active_objects = self._get_active_objects()
        for obj in active_objects:
            if obj['moc'] == 'ASI' and any("ASI_R-" in elem for elem in obj['children']):
                logging.info("RunTime parameter(ASI_R) visible in current delta plan {}".format(obj['children']))
                return True
        raise ValueError("RunTime parameter(ASI_R) not visible in current delta plan")

    @login_logout
    def validate_configuration_parameter_viewer(self, bts_id=0):
        active_objects = self._get_active_objects()
        for obj in active_objects:
            if obj['moc'] == 'ASI' and any("ANTMOD-" in elem for elem in obj['children']):
                logging.info("Configuration parameter(ANTMOD) visible in current delta plan {}".
                             format(obj['children']))
                return True
        raise ValueError("Configuration parameter(ANTMOD) not visible in current delta plan")

    def verify_all_hubs_are_enabled_and_not_commissioned(self):
        self.verify_hubmod_status(
            hub_ids=get_builtin_value('all_hub_ids'),
            expected_statuses={'operationalState': 'enabled', 'commissioned': 'No'})

    def verify_software_version_is_visible(self):
        all_sw_packages = self.get_all_software_packages()
        self._verify_is_sbts_version(all_sw_packages)

    @staticmethod
    def _verify_is_sbts_version(sw_versions):
        contain_sbts = False
        for sw_version_info in sw_versions:
            if 'SBTS' in sw_version_info['sw_version']:
                contain_sbts = True

        if not contain_sbts:
            raise ValueError("Cannot find 'SBTS' software in output of 'get_all_software_packages': {}".
                             format(sw_versions))

    def check_number_of_hub_ids(self):
        all_hub_ids = self.get_all_hub_ids()
        set_robot_test_variable('all_hub_ids', all_hub_ids)
