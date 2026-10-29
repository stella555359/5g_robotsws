from robot.api import logger
from robot.libraries.BuiltIn import BuiltIn
from ta5g_enb.html_method_logger import log_method_name
from ta5g_global_var import IPHY0_LMP_IP
from ta5g_iphy.ta_inner import Iphy


class IphyExtension(Iphy):
    @log_method_name
    def put_iphy_swconfig_file(self, input_filepath, remote_host=None, iphy_lmp_ip=IPHY0_LMP_IP):
        destination_filepath = '/rom/swconfig.txt'
        try:
            self._ute_fsmaccess_instance.setup_wts_fsm_access(
                host=iphy_lmp_ip, remote_host=remote_host, fallback_prompt='#'
            )
            self._ute_fsmaccess_instance.put_wts_file(source=input_filepath, destination=destination_filepath)
            cmd = "crasign {0}; craverify {0}*".format(destination_filepath)
            out = self._ute_fsmaccess_instance.execute_command_on_wts(cmd=cmd)
            BuiltIn().should_be_equal(out, "good signature", msg=out)
            logger.console("AP: swconfig modified")
        finally:
            self._ute_fsmaccess_instance.teardown_wts_fsm_access()
