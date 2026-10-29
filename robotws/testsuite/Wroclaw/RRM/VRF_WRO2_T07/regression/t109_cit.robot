*** Settings ***
Documentation    All T109 CIT regression TCs shall be added here for fully automated regression testing.

Force Tags    CA_5G_RRM   STATE_SW_UPLOADED   RAN_5G   RAN_5G_FDD   RAN_5G_FDD_MP   RAN_5G_MP
...           CIT   CLOUD_5G_CLASSICAL_SA_4xANDROID_ASIK_ABIL_3xAHLOA_ENB
...           SBTS22R4   SBTS23R1   SBTS00

Library          taf.ue
Library          taf.ccs.aashell
Library          testsuite.Wroclaw.RRM.VRF_WRO2_T07.resources.hanging_resources.ResourceUsage     ${False}
Library          testsuite/Wroclaw/RRM/VRF_WRO2_T07/resources/testline_preparation.py
Library          testsuite/Wroclaw/RRM/VRF_WRO2_T07/resources/logs/btslog.py   WITH NAME   wro_6_btslog
Library          testsuite/Wroclaw/RRM/VRF_WRO2_T07/classical/feature_CB007781/A/resources/keywords_7781.py  WITH NAME  keywords_7781
Library          testsuite/Wroclaw/RRM/resources/TestCaseRequirement.py
Resource         testsuite/Wroclaw/RRM/VRF_WRO2_T07/classical/feature_5GC000431/resources/keywords_431.robot
Resource         testsuite/Wroclaw/RRM/VRF_WRO2_T07/classical/5GC000501/resources/keywords_501.robot
Resource         taf/rfrl/common_resources/common_step/interface.robot
Resource         testsuite/Wroclaw/RRM/VRF_WRO2_T07/resources/reports/reporting_portal.robot

Suite Setup       Run keywords
...               prepare_testline     second_wind=${True}        AND
...               Add nrpgrp object

Test Setup        Run keywords
...               wro_6_btslog.start_btslog_on_local_machine                   AND
...               Upload runtime ini to gnb

Test Teardown     Run keywords
...               wro_6_btslog.teardown_btslog                                 AND
...               Run keyword if test failed    AdminUtils.collect_snapshot                                 AND
...               Run Keyword and Ignore Error    Add scout external execution id to the reporting portal

Suite Teardown    Run keyword and ignore error   interface.Common step trigger


*** Variables ***
# TODO: NEW VARIABLES (USE FOR EDA)
${GCS_CELL_ID}            1
${CALL_FLAG}              call   #call/no_call
&{START_UE}               call=Start call   no_call=Attach
&{STOP_UE}                call=Stop call    no_call=Detach
${CHECK_TYPE}             NAA    #NAA/ANTL
&{BEFORE_CHECK}           NAA=Measure RX power on UE before shutdown  ANTL=Start Power Measurement in Webem
&{WHILE_CHECK}            NAA=Measure RX power on UE while shutdown   ANTL=Stop Power Measurement in Webem
${DEPLOYMENT_MODE}        NSA    #SA/NSA
&{RSRP_KEY_MAP}           NSA=nrDbm  SA=dbm
&{JSON_KEY_TL_MAP}        50078=(NRCell1)  50096=(51997-01)  41810=(AHPMDB1)  55200=(55200-00)
# TODO: ANTL MONITORING IN WEBEM IS MORE STABLE WHEN ${SHUTDOWN_WINDOW}/${SHUTDOWN_STEP_AMOUNT} equals 10
${SHUTDOWN_WINDOW}        ${180}   #(6, 12, 18…, 180 sec)
${SHUTDOWN_STEP_AMOUNT}   ${6}     #(1,2,3….16)
${DEVIATION}              ${1}     #deviation for every shutdown step [dB] (3dB +- deviation)


*** Test Cases ***
[1]5GC000431_A_15_Un-suspend_Load-Based_Power_Saving
    [Tags]   CDRT
    [Setup]  Setup A7
    [1]5GC000431_A_15_Un-suspend_Load-Based_Power_Saving


5GC000501_A_24_Graceful_Cell_shutdown_for_concurrent_mode_NSA_and_SA_configuration_parameters_check_and_UE_release_handling
    [Setup]     Run keywords
    ...         wro_6_btslog.start_btslog_on_local_machine                                             AND
    ...         Require Ue  ${UE_ALIAS}  capabilities=REAL_UE_NSA
    [1.0] 5GC000501_A_24_Graceful_Cell_shutdown_for_concurrent_mode_NSA_and_SA_configuration_parameters_check_and_UE_release_handling
    [Teardown]  Run keywords
    ...         Detach Ue      ${UE_ALIAS}                                                             AND
    ...         stop_data_transfer_if_active                                                           AND
    ...         Stop Using Ue  ${UE_ALIAS}                                                             AND
    ...         AdminUtils.unlock_all_cells                                                            AND
    ...         wro_6_btslog.teardown_btslog                                                           AND
    ...         Run keyword if test failed  AdminUtils.collect_snapshot                                AND
    ...         Run Keyword and Ignore Error  Add scout external execution id to the reporting portal
