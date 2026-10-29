from robot.libraries.BuiltIn import BuiltIn
from taf.rfrl.utilities.logger.custom_logger import log_info_to_console
from taf.sbts.oam.coam.admin import admin


class QCIDHelper:
    """
    This class provides common functionality for test ID management across different
    MRBTS configurations. Each MRBTS folder should import this and provide its own
    QCID dictionary via variables.py.
    """

    def __init__(self, qcid_dict: dict[str, dict[str, str]]) -> None:
        self.qcid = qcid_dict
        self.admin = admin()

    @staticmethod
    def _robot_var(variable_name: str, default_value: str | None = None) -> str | None:
        """Get Robot Framework variable value."""
        return BuiltIn().get_variable_value(f"${{{variable_name}}}", default_value)

    def _get_branch(self, target_sw: str | None = None) -> str:
        """
        Determines the branch based on the software version.

        :param str target_sw: The target software version. If not provided, the current
            software version is retrieved using the `admin` module. Defaults to None.
        :return: The branch name.
        :rtype: str
        """
        if not target_sw:
            try:
                self.admin.setup_admin()
                sw_version = self.admin.get_sw_version()
            finally:
                self.admin.teardown_admin()
        else:
            sw_version = target_sw
        if any(trunk_indicator in sw_version for trunk_indicator in ["9999", "9990"]):
            return 'SBTS00'
        return sw_version.split("_")[0]

    def set_test_id(self, target_sw: str | None = None) -> str | None:
        """
        Determines and sets the test ID based on the branch and test name.

        :param str target_sw: The target software version. If not provided, the current
            software version is retrieved using the `admin` module. Defaults to None.
        :return: The test ID if found, otherwise None.
        :rtype: str
        """
        branch = self._get_branch(target_sw)
        test_id = self.qcid.get(branch, {}).get(self._robot_var("TEST_NAME").lower())
        if test_id:
            log_info_to_console(f"Selected Test id {test_id} for {self._robot_var('TEST_NAME')} and release {branch}")
            return test_id
        else:
            log_info_to_console(f"Couldn't find test id for {self._robot_var('TEST_NAME')} "
                                f"and {branch}. Test ID will be set to None")
            return None
