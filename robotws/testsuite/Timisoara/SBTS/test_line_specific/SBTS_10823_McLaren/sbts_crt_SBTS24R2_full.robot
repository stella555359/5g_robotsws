*** Settings ***
Force Tags        QCD_MN_RAN    QCP_RAN_ST    CRT    CLOUD_SRAN_NLWG_2ASIL_2ABIA_2ABIO_1ABIN_1FRGY_1AHFB_1AHIB_1FXDB_AHCA_AHEH_AHEC    SBTS24R2
Library           XML  use_lxml=True
Resource          taf/rfrl/scrambling_logs_collector/Keywords.robot
Resource          ../../LOGS/LOGS__CB007833_BlackBox_check_24h_save_period_24R2.robot
Resource          ../../LOGS/LOGS__CB012370-C_Auto_and_scheduled_DC_triggered_from_WebEM_GUI_for_CP37_System_Module_FAN_Speed.robot
Resource          ../../LOGS/LOGS__Blackbox_log_creation.robot
Resource          ../../LOGS/LOGS__Snapshot_collection_from_dual_core_with_re_establishing.robot

Suite Teardown    Suite Teardown

*** Variables ***
${SCF_ID}         01

${COMMISSIONING_PATH}
    ...  /home/ute/MN/UTE/robotws/testsuite/Timisoara/SBTS/test_line_specific/SBTS_10823_McLaren/commissioning/SCF_01_SBTS24R2.xml

${NETACT_LAB}    &{srnclab1028}

*** Test Cases ***
[1]Automated__LOGS__Blackbox_log_creation
    [Setup]    Run Keywords    Set Test Variable    ${SNAPSHOT_EXTRACTED}    ${FALSE}
    ...    AND    Set Test Variable    ${RESET_TYPE}    power_reset
    ...    AND    Set Test Variable    ${RESET_DATE}
    ...    AND    Set Test Variable    ${BLACKBOX_INFO}
    ...    AND    Set Test Variable    ${MATCHES}
    ...    AND    Set Test Variable    ${check_blackbox_date}
    ...    AND    Set Test Variable    ${STARTUP_TIMEOUT}    10
    ...    AND    LOGS__Blackbox_log_creation.TC Setup
    ...    AND    Modify Resource Search Order    LOGS__Blackbox_log_creation
    ...    AND    Set Library Search Order    LOGS__Blackbox_log_creation
    [Timeout]    14400
    TC__LOGS__BlackBox
    [Teardown]    Run Keywords    LOGS__Blackbox_log_creation.TC Teardown
    ...    AND    Restore Resource Search Order

[1]Automated__LOGS__CB007833_BlackBox_check_24h_save_period
    [Setup]    Run Keywords    Set Test Variable    ${SNAPSHOT_TIMEOUT}    1200
    ...    AND    LOGS__CB007833_BlackBox_check_24h_save_period_24R2.TC Setup
    ...    AND    Modify Resource Search Order    LOGS__CB007833_BlackBox_check_24h_save_period_24R2
    ...    AND    Set Library Search Order    LOGS__CB007833_BlackBox_check_24h_save_period_24R2
    [Timeout]    172800
    TC_LOGS__CB007833_BlackBox_check_24h_save_period
    [Teardown]    Run Keywords    LOGS__CB007833_BlackBox_check_24h_save_period_24R2.TC Teardown
    ...    AND    Restore Resource Search Order

[1]Automated__LOGS__Snapshot_collection_from_dual_core_with_re_establishing
    [Setup]    Run Keywords    LOGS__Snapshot_collection_from_dual_core_with_re_establishing.TC Setup
    ...    AND    Modify Resource Search Order    LOGS__Snapshot_collection_from_dual_core_with_re_establishing
    ...    AND    Set Library Search Order    LOGS__Snapshot_collection_from_dual_core_with_re_establishing
    [Timeout]    14400
    TC__LOGS__Snapshot_collection_from_dual_core_with_re_establishing
    [Teardown]    Run Keywords    LOGS__Snapshot_collection_from_dual_core_with_re_establishing.TC Teardown
    ...    AND    Restore Resource Search Order

[1]Automated__LOGS__CB012370-C_Auto_and_scheduled_DC_triggered_from_WebEM_GUI_for_CP37_System_Module_FAN_Speed
    [Setup]    Run Keywords
    ...    LOGS__CB012370-C_Auto_and_scheduled_DC_triggered_from_WebEM_GUI_for_CP37_System_Module_FAN_Speed.TC Setup
    ...    AND    Modify Resource Search Order
    ...    LOGS__CB012370-C_Auto_and_scheduled_DC_triggered_from_WebEM_GUI_for_CP37_System_Module_FAN_Speed
    ...    AND    Set Library Search Order
    ...    LOGS__CB012370-C_Auto_and_scheduled_DC_triggered_from_WebEM_GUI_for_CP37_System_Module_FAN_Speed
    [Timeout]    14400
    TC__LOGS__CB012370-C_Auto_and_scheduled_DC_triggered_from_WebEM_GUI_for_CP37_System_Module_FAN_Speed
    [Teardown]    Run Keywords
    ...    LOGS__CB012370-C_Auto_and_scheduled_DC_triggered_from_WebEM_GUI_for_CP37_System_Module_FAN_Speed.TC Teardown
    ...    AND    Restore Resource Search Order

*** Keywords ***
Suite Teardown
    Run keyword and ignore error    Collect and send logs for scrambling verification
    ...    team_name=PZ3WRO5
    ...    input_logs_dir=${NONE}
