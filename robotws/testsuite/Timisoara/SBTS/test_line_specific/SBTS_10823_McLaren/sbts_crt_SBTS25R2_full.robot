*** Settings ***
Documentation     TCs McLaren
Force Tags        QCD_MN_RAN    QCP_RAN_VRF    CRT    CLOUD_SRAN_NLWG_2ASIL_2ABIA_2ABIO_1ABIN_1FRGY_1AHFB_1AHIB_1FXDB_AHCA_AHEH_AHEC    SBTS00
Library           XML  use_lxml=True
Resource          taf/rfrl/scrambling_logs_collector/Keywords.robot

Resource          ../../LOGS/LOGS__CB007833_BlackBox_check_24h_save_period.robot
Resource          ../../LOGS/LOGS__Blackbox_log_creation.robot
Resource          ../../LOGS/LOGS__CB009077_Store_location_data_in_SMOD_BBMOD_and_preventParamModifList_check.robot
Resource          ../../LOGS/LOGS__CB012370-C_Auto_and_scheduled_DC_triggered_from_WebEM_GUI_for_CP37_System_Module_FAN_Speed_new.robot
Resource          ../../LOGS/LOGS__Snapshot_collection_from_dual_core_with_re_establishing.robot
Resource          ../../LOGS/LOGS__CNI-93136_CNI-93789_Diagnostic_logs_from_secondary_common_unit_related_to_warm_reset.robot

Suite Teardown    Suite Teardown

*** Variables ***
${SCF_ID}         01

${COMMISSIONING_PATH}  /home/ute/testline_configuration/10_18_UTESRANCLOUD1823/node1/SCF_01_SBTS25R2.xml

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
    ...    AND    LOGS__CB007833_BlackBox_check_24h_save_period.TC Setup
    ...    AND    Modify Resource Search Order    LOGS__CB007833_BlackBox_check_24h_save_period
    ...    AND    Set Library Search Order    LOGS__CB007833_BlackBox_check_24h_save_period
    [Timeout]    172800
    TC_LOGS__CB007833_BlackBox_check_24h_save_period
    [Teardown]    Run Keywords    LOGS__CB007833_BlackBox_check_24h_save_period.TC Teardown
    ...    AND    Restore Resource Search Order

[1]Automated__LOGS__Snapshot_collection_from_dual_core_with_re_establishing
    [Setup]    Run Keywords    LOGS__Snapshot_collection_from_dual_core_with_re_establishing.TC Setup
    ...    AND    Modify Resource Search Order    LOGS__Snapshot_collection_from_dual_core_with_re_establishing
    ...    AND    Set Library Search Order    LOGS__Snapshot_collection_from_dual_core_with_re_establishing
    [Timeout]    14400
    TC__LOGS__Snapshot_collection_from_dual_core_with_re_establishing
    [Teardown]    Run Keywords    LOGS__Snapshot_collection_from_dual_core_with_re_establishing.TC Teardown
    ...    AND    Restore Resource Search Order

[1]Automated__LOGS__CB009077_Store_location_data_in_SMOD_BBMOD_and_preventParamModifList_check
    [Setup]    Run Keywords    LOGS__CB009077_Store_location_data_in_SMOD_BBMOD_and_preventParamModifList_check.TC Setup
    ...    AND    Modify Resource Search Order    LOGS__CB009077_Store_location_data_in_SMOD_BBMOD_and_preventParamModifList_check
    ...    AND    Set Library Search Order    LOGS__CB009077_Store_location_data_in_SMOD_BBMOD_and_preventParamModifList_check
    [Timeout]    14400
    TC__LOGS__CB009077_Store_location_data_in_SMOD_BBMOD_and_preventParamModifList_check
    [Teardown]    Run Keywords    LOGS__CB009077_Store_location_data_in_SMOD_BBMOD_and_preventParamModifList_check.TC Teardown
    ...    AND    Restore Resource Search Order

[1]Automated__LOGS__CB012370-C_Auto_and_scheduled_DC_triggered_from_WebEM_GUI_for_CP37_System_Module_FAN_Speed
    [Setup]    Run Keywords
    ...    LOGS__CB012370-C_Auto_and_scheduled_DC_triggered_from_WebEM_GUI_for_CP37_System_Module_FAN_Speed_new.TC Setup
    ...    AND    Modify Resource Search Order
    ...    LOGS__CB012370-C_Auto_and_scheduled_DC_triggered_from_WebEM_GUI_for_CP37_System_Module_FAN_Speed_new
    ...    AND    Set Library Search Order
    ...    LOGS__CB012370-C_Auto_and_scheduled_DC_triggered_from_WebEM_GUI_for_CP37_System_Module_FAN_Speed_new
    [Timeout]    14400
    TC__LOGS__CB012370-C_Auto_and_scheduled_DC_triggered_from_WebEM_GUI_for_CP37_System_Module_FAN_Speed_new
    [Teardown]    Run Keywords
    ...    LOGS__CB012370-C_Auto_and_scheduled_DC_triggered_from_WebEM_GUI_for_CP37_System_Module_FAN_Speed_new.TC Teardown
    ...    AND    Restore Resource Search Order

[1]Automated__LOGS__CNI-93136_CNI-93789_Diagnostic_logs_from_secondary_common_unit_related_to_warm_reset
    [Setup]    Run Keywords
    ...    LOGS__CNI-93136_CNI-93789_Diagnostic_logs_from_secondary_common_unit_related_to_warm_reset.TC Setup
    ...    AND    Modify Resource Search Order
    ...    LOGS__CNI-93136_CNI-93789_Diagnostic_logs_from_secondary_common_unit_related_to_warm_reset
    ...    AND    Set Library Search Order
    ...    LOGS__CNI-93136_CNI-93789_Diagnostic_logs_from_secondary_common_unit_related_to_warm_reset
    [Timeout]    14400
    TC__LOGS__CNI-93136_CNI-93789_Diagnostic_logs_from_secondary_common_unit_related_to_warm_reset
    [Teardown]    Run Keywords
    ...    LOGS__CNI-93136_CNI-93789_Diagnostic_logs_from_secondary_common_unit_related_to_warm_reset.TC Teardown
    ...    AND    Restore Resource Search Order

*** Keywords ***
Suite Teardown
    Run keyword and ignore error    Collect and send logs for scrambling verification
    ...    team_name=VRFTSR5
    ...    input_logs_dir=${NONE}
