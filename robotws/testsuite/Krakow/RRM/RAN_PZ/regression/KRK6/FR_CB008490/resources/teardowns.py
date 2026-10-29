"""
Teardowns class for CB008490 test suite

:copyright:     Nokia Networks
:author:        Piotr Brzezicki
:maintainer:    Piotr Brzezicki
:contact:       piotr.brzezicki@nokia.com
:team:          VRF_KRK_T06
"""
from taf.rfrl.bts.devices.du.du_operations import GnbDuOperations
from taf.rfrl.procedures.resources.python.setups_and_teardowns_keywords import add_metadata_to_report_for_all_btss
from taf.rfrl.utilities.logger import custom_logger as logger
from taf.rfrl.utilities.robot.decorators import log_as_robot_keyword
from taf.rfrl.utilities.robot.general import get_builtin_value, run_robot_keyword, set_robot_suite_variable

from .alarms import Alarms
from .pcap.collecting import stop_tcpdump_on_btses
from .suite_specific import get_snapshot_if_suite_setup_failed
from .common import run_and_warn_on_exception
from .variables.common import MY_UE_ALIAS_UE1, RUN_COMMON_STEPS
from .bts_logs import stop_utf_logs_collection
from .ue import detach_nrdc_ue


class Teardowns:

    @log_as_robot_keyword
    def cb008490_suite_teardown(self) -> None:
        """
        KW for Suite Teardown. Performs common steps
        """
        logger.log_banner_to_console(f"CB008490 Suite Teardown")

        self.run_common_suite_teardown()
        get_snapshot_if_suite_setup_failed(bts_id=1)

    @log_as_robot_keyword
    def run_common_postconditions(self, collect_syslog: bool = False,
                                  collect_snapshot_from_ru: bool = False,
                                  collect_mandatory_logs: str = "on_failure") -> None:
        """
        Execute common postconditions and control mandatory logs collection.
        :param collect_syslog: True to collect syslog in test teardown.
        :param collect_snapshot_from_ru: True to collect snapshot from RU in test teardown.
        :param collect_mandatory_logs: Mode controlling mandatory logs collection ("always", "on_failure", "never")
        :return: None
        """
        if RUN_COMMON_STEPS:
            _set_collect_mandatory_logs_robot_variable(collect_mandatory_logs)
            GnbDuOperations().connect(force=True)
            kw = 'Common Postconditions'
            logger.log_info_to_console(f"Running Keyword: {kw}")
            run_robot_keyword(kw, collect_syslog, collect_snapshot_from_ru)
        else:
            run_and_warn_on_exception(add_metadata_to_report_for_all_btss())

    @log_as_robot_keyword
    def cb008490_test_teardown(self, ue_alias: str = MY_UE_ALIAS_UE1,
                               collect_mandatory_logs: str = "on_failure") -> None:
        """
        CB008490 test teardown. Detaches UE, stops UTF logs, runs common postconditions and collects snapshot on
        failure.

        :param ue_alias: UE alias used for detach operation.
        :param collect_mandatory_logs: Mode controlling mandatory logs collection ("always", "on_failure", "never")
        :return: None
        """
        logger.log_banner_to_console(f"CB008490 Test Teardown")
        run_and_warn_on_exception(detach_nrdc_ue)(ue_alias=ue_alias)
        run_and_warn_on_exception(stop_tcpdump_on_btses)

        if RUN_COMMON_STEPS:
            stop_utf_logs_collection()
            self.run_common_postconditions(collect_mandatory_logs=collect_mandatory_logs)
            Alarms().stop_watching_alarms_for_all_btses()

    @log_as_robot_keyword
    def run_common_suite_teardown(self) -> None:
        """
        Executes the Common Suite Teardown keyword if RUN_COMMON_STEPS is set to true.

        :return: None
        """
        if RUN_COMMON_STEPS:
            kw = 'Common Suite Teardown'
            logger.log_info_to_console(f"Running Keyword: {kw}")
            run_robot_keyword(kw)


@log_as_robot_keyword
def _set_collect_mandatory_logs_robot_variable(collect_mandatory_logs: str):
    mode = str(collect_mandatory_logs).strip().lower()

    if mode not in {"always", "on_failure", "never"}:
        logger.log_warn_to_console(
            f"Unsupported collect_mandatory_logs='{collect_mandatory_logs}', defaulting to 'on_failure'"
        )
        mode = "on_failure"

    if mode == "always":
        collect_flag = True
    elif mode == "never":
        collect_flag = False
    else:  # "on_failure"
        test_status = str(get_builtin_value("TEST_STATUS") or "").strip().upper()
        collect_flag = test_status != "PASS"

    set_robot_suite_variable('COLLECT_MANDATORY_LOGS', collect_flag)
