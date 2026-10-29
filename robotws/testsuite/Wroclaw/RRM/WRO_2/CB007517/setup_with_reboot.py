from SSHLibrary.abstractclient import SSHClientException
from robot.api import logger
from robot.errors import ExecutionFailed
from robot.libraries.BuiltIn import BuiltIn
from ta5g_setups_and_teardowns.setups_and_teardowns import SetupsAndTeardowns
from ta5g_testline_management import ta5g_testline_management
from taf.internal.sbts.admin.exceptions import AdminApiProcedureFailureException
from ute_async.exception import EmptyResult
from ute_common_abstract_core.aliases_registry import aliases_registry
from ute_common_store.exception import AliasError
from testsuite.Wroclaw.RRM.WRO_2.resources.messaging import stop_capturing_messages


class setup_with_reboot(object):
    def __init__(self):
        self.retries = 4
        self.tl = ta5g_testline_management()
        self.builtin = BuiltIn()
        self.setups = SetupsAndTeardowns()

    def run_setup_and_reboot_if_failed(self, *keywords):
        """
        Temporary solution to be used only in CB007517 testcases using ta_messaging library
        :param keywords: List of keywords to be run in loop in the same format as in Run Keywords
        :return: None
        """
        for trial in range(1, self.retries+1):
            status = True
            try:
                self._run_keywords(keywords)
            except ExecutionFailed:
                status = False
            if status is False:
                self._teardown_processes_and_aliases()
                # every second reboot method should vary from gentle reboot via admin to hard reboot via PDU
                if trial % 2 == 1:
                    try:
                        self._admin_reset(trial)
                    except (EmptyResult, AdminApiProcedureFailureException, SSHClientException):
                        self._pdu_reset(trial)
                else:
                    self._pdu_reset(trial)
                self.tl.wait_for_testline_icmp_echo_replies_and_ssh_services()
            else:
                break
        else:
            self._run_keywords(keywords)

    def _admin_reset(self, trial):
        logger.info(msg="Reset {}/{} via admin".format(trial, self.retries), also_console=True)
        self.tl.trigger_site_reset()

    def _pdu_reset(self, trial):
        logger.info(msg="Reset {}/{} via PDU".format(trial, self.retries), also_console=True)
        self.tl.reset_testline()

    def _teardown_processes_and_aliases(self):
        for method in (self.setups.stop_default_logging,
                       self.setups.ta5g_egate_instance.teardown_egate_and_collect_logs,
                       self.setups.ta5g_egate_instance.copy_egate_console_log_to_output_dir,
                       stop_capturing_messages,
                       aliases_registry().clear):
            try:
                method()
            except (ExecutionFailed, AliasError):
                logger.warn("Cannot execute teardown method: {}".format(method))

    def _run_keywords(self, keywords):
        logger.info(msg="Running keywords: {}".format(keywords), also_console=True)
        self.builtin.run_keywords(*keywords)
