*** Settings ***
Documentation    All CIT regression TCs shall be added here for fully automated regression testing.

Force Tags    CDRT   CA_5G_RRM   STATE_SW_UPLOADED   PY36
...           RAN_5G    RAN_5G_FDD    RAN_5G_FDD_CD    RAN_5G_FDD_MP    RAN_5G_FDD_MP_CUSTOMER   RAN_5G_MP
...           SBTS00__WITH__CIT   CLOUD_5G_CLASSICAL_SA_VIAVI_ASIBL_ABILB1_3xAHCA_ENB

Library          taf.ccs.aashell
Library          testsuite.Wroclaw.RRM.VRF_WRO2_T07.resources.hanging_resources.ResourceUsage     ${False}
Library          testsuite.Wroclaw.RRM.VRF_WRO2_T07.resources.testline_preparation    WITH NAME    testline_preparation
Library          testsuite.Wroclaw.RRM.VRF_WRO2_T07.resources.logs.tcpdump.tcpdump_smod.TcpdumpSmod    WITH NAME    TcpdumpSmod
Library          testsuite/Wroclaw/RRM/VRF_WRO2_T07/resources/rue/adb_utils.py
Library          testsuite/Wroclaw/RRM/VRF_WRO2_T07/resources/logs/btslog.py
Resource         testsuite/Wroclaw/RRM/VRF_WRO2_T07/classical/5GC000723_5GC000728/resources/keywords_723.robot
Resource         testsuite/Wroclaw/RRM/VRF_WRO2_T07/classical/5GC000723_5GC000728/resources/keywords_728.robot
Resource         testsuite/Wroclaw/RRM/VRF_WRO2_T07/classical/5GC001178/resources/keywords_1178_BB.robot
Resource         testsuite/Wroclaw/RRM/VRF_WRO2_T07/classical/5GC001178/resources/keywords_1178_BE.robot
Resource         taf/rfrl/common_resources/common_step/interface.robot
Resource        testsuite/Wroclaw/RRM/VRF_WRO2_T07/resources/reports/reporting_portal.robot

Suite Setup     testline_preparation.prepare_testline     second_wind=${True}

Suite Teardown  Run keywords
...             Get active alarms                                               AND
...             Run keyword and ignore error   interface.Common step trigger

Test Setup      start_btslog_on_local_machine

Test Teardown   Run Keywords
...             testline_preparation.what_is_wrong_with_pdu                     AND
...             testline_preparation.wake_up_samurai                            AND
...             TcpdumpSmod.teardown_tcpdump_on_smod                            AND
...             Run keyword if test failed    AdminUtils.collect_snapshot       AND
...             stop_and_collect_btslog                                         AND
...             Run Keyword and Ignore Error    Add scout external execution id to the reporting portal


*** Test Cases ***
# T119_preparation
#     Set Network Mode   3   NR_only


[1]5GC001178_BE_6_SR_handling_10UE_UL_DL_20MHz_bandwidth
    [1]5GC001178_BE_6_SR_handling_10UE_UL_DL_20MHz_bandwidth


[1]5GC001178_BE_7_MCS_Reduction_4UEs_DL_goodRC_20MHz_bandwidth
    [Tags]   SBTS22R4__WITH__CIT
    ...      SBTS23R1__WITH__CIT
    [1]5GC001178_BE_7_MCS_Reduction_4UEs_DL_goodRC_20MHz_bandwidth


[1]5GC001178_BE_13_Proactive_scheduling_4UEs_20MHz_bandwidth
    [Tags]   SBTS22R4__WITH__CIT
    ...      SBTS23R1__WITH__CIT
    [1]5GC001178_BE_13_Proactive_scheduling_4UEs_20MHz_bandwidth
