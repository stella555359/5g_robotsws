"""
Setups class for CB008490 test suite

:copyright:     Nokia Networks
:author:        Piotr Brzezicki
:maintainer:    Piotr Brzezicki
:contact:       piotr.brzezicki@nokia.com
:team:          VRF_KRK_T06
"""
from typing import List, Any

from taf.rfrl.utilities.logger import custom_logger as logger
from taf.rfrl.utilities.robot.decorators import log_as_robot_keyword
from taf.rfrl.utilities.robot.general import run_robot_keyword

from .variables.common import MY_UE_ALIAS_UE1, RUN_COMMON_STEPS, COLLECT_RU_CONSOLE_LOG
from .common import RfAttenuator
from .bts_logs import start_utf_logs_collection
from .pcap.collecting import log_mcshark_plugin_presence
from .ue import require_and_reboot_ue, detach_nrdc_ue
from .commissioning import run_commissioning
from .suite_specific import (configure_as_encryption_on_mn_and_sn_gnbs, RuData)
from .alarms import get_and_set_alarm_variables, Alarms


class Setups:

    CHECK_TRUCK_ROLL = False

    @log_as_robot_keyword
    def cb008490_suite_setup(self, ue_in_use: bool = True) -> None:
        """
        Keyword for Suite Setup. Performs full commissioning and common steps
        """
        logger.log_banner_to_console("CB008490 Suite Setup")
        run_commissioning()
        self.run_common_suite_setup()
        if ue_in_use:
            RfAttenuator().setup_all_attenuators()
            log_mcshark_plugin_presence()

    @log_as_robot_keyword
    def cb008490_kpi_bench_test_setup(self) -> None:
        """
        CB008490 KPI Bench Test Setup
        """
        self.run_common_preconditions()
        detach_nrdc_ue()

    @log_as_robot_keyword
    def cb008490_test_setup(self, ue_alias: str = MY_UE_ALIAS_UE1, disable_as_encryption: bool = True,
                            ru: str = 'AEQP', reboot_ue: bool = False) -> None:
        """
        CB008490 Test Setup

        :param ue_alias: taf.ue alias
        :param disable_as_encryption: True if nr-rrc messages verification in PCAP is needed
        :param ru: RU name from RU_DATA to use for test. Cell from this RU will be used for UE attach
        :param reboot_ue: True if UE reboot is needed, False otherwise
        """
        from taf.rfrl.utilities.test_config import set_test_case_log_path

        logger.log_banner_to_console(f"CB008490 Test Setup")
        set_test_case_log_path()
        self.run_common_preconditions(collect_ru_console_log=COLLECT_RU_CONSOLE_LOG)
        if disable_as_encryption:
            configure_as_encryption_on_mn_and_sn_gnbs(False)

        require_and_reboot_ue(ue_alias=ue_alias, reboot_ue=reboot_ue)
        detach_nrdc_ue(ue_alias=ue_alias)

        if RUN_COMMON_STEPS:
            Alarms().watch_alarms_during_test()
            start_utf_logs_collection()

        RuData().use_ru_cell_as_pcell(ru_name=ru)

    @log_as_robot_keyword
    def run_common_preconditions(self, collect_syslog: bool = False,
                                 custom_taf_tl_config: Any = None,
                                 raise_exception_when_setup_ru_console_fail: bool = False,
                                 collect_ru_console_log: bool = False,
                                 custom_allowed_alarms: List[Any] | None = None) -> None:
        """
        Runs common preconditions if RUN_COMMON_STEPS is set to true.
        :param collect_syslog: True to collect syslog
        :param custom_taf_tl_config: custom taf tl_config
        :param raise_exception_when_setup_ru_console_fail: Raise exception if setup fails
        :param collect_ru_console_log: True to collect ru_console_log
        :param custom_allowed_alarms: custom allowed alarms
        """
        if RUN_COMMON_STEPS:
            get_and_set_alarm_variables(custom_allowed_alarms=custom_allowed_alarms)
            keyword = 'Common Preconditions'
            logger.log_info_to_console(f"Running Keyword: {keyword}")
            run_robot_keyword(keyword, collect_syslog, custom_taf_tl_config,
                              raise_exception_when_setup_ru_console_fail,
                              collect_ru_console_log)

    @log_as_robot_keyword
    def run_common_preconditions_with_watching_alarms(self, collect_syslog: bool = True,
                                                      custom_taf_tl_config: Any = None,
                                                      raise_exception_when_ru_console_fail: bool = False,
                                                      custom_allowed_alarms: List[Any] | None = None) -> None:
        """
        Runs common preconditions with watching alarms if RUN_COMMON_STEPS is set to true.
        :param collect_syslog: True to collect syslog
        :param custom_taf_tl_config: custom taf tl_config
        :param raise_exception_when_ru_console_fail: Raise exception if setup fails
        :param custom_allowed_alarms: custom allowed alarms
        """
        if RUN_COMMON_STEPS:
            get_and_set_alarm_variables(custom_allowed_alarms=custom_allowed_alarms)
            keyword = 'Common Preconditions With Watching Alarms'
            logger.log_info_to_console(f"Running Keyword: {keyword}")
            run_robot_keyword(keyword, collect_syslog, custom_taf_tl_config,
                              raise_exception_when_ru_console_fail)

    @log_as_robot_keyword
    def run_common_suite_setup(self) -> None:
        """
        Executes the Common Suite Setup keyword if RUN_COMMON_STEPS is set to true.

        :return: None
        """
        if RUN_COMMON_STEPS:
            keyword = 'Common Suite Setup'
            logger.log_info_to_console(f"Running Keyword: {keyword}")
            run_robot_keyword(keyword, Setups.CHECK_TRUCK_ROLL)
