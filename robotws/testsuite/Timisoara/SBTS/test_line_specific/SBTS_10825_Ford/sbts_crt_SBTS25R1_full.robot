*** Settings ***
Documentation  Tests on FORD
Force Tags   QCD_MN_RAN    QCP_RAN_VRF    CRT    CLOUD_SRAN_NLWG_1ASIB_1ABIA_1ABIN_1ABIO_1ASIA_3ABIA_1AHCA_1AHIB_1AHEH_2AHEB_1AHLOA_1FRHC   SBTS25R1
Library      XML  use_lxml=True
Resource     taf/rfrl/scrambling_logs_collector/Keywords.robot
Resource     ../../LOGS/LOGS__Snapshot_BBOX5_File_Check.robot
Resource     ../../LOGS/LOGS__CNI-93136_CNI-93789_Diagnostic_logs_from_secondary_common_unit_related_to_warm_reset.robot
Resource     ../../LOGS/LOGS__CB012370-B_Full_DC_triggered_from_WebEM_and_auto_DC_for_CP33_Secondary_core_connectivity_new.robot
Resource     ../../LOGS/LOGS__CB010655_FRM5_RU_BBOX5_File_enhancements_Check_new.robot
Resource     ../../LOGS/LOGS__CB007615-SR-A-B3-Get_the_date_and_time_value_before_the_last_reset.robot
Resource     ../../LOGS/LOGS__CB010699_Collect_Local_SCREL.robot

Suite Teardown    Suite Teardown

*** Variables ***
${SCF_ID}         01
${COMMISSIONING_PATH}
    ...   /home/ute/MN/UTE/robotws/testsuite/Timisoara/SBTS/test_line_specific/SBTS_10825_Ford/commissioning/SCF_01_SBTS25R1.xml
${NETACT_LAB}    &{srnclab1015}

*** Test Cases ***
[1]Automated__LOGS__CB006622_Snapshot_BBOX5_File_Check
    [Setup]    Run Keywords    Set Test Variable    ${SNAPSHOT_TIMEOUT}    2400
    ...    AND    LOGS__Snapshot_BBOX5_File_Check.TC Setup
    ...    AND    Modify Resource Search Order    LOGS__Snapshot_BBOX5_File_Check
    ...    AND    Set Library Search Order    LOGS__Snapshot_BBOX5_File_Check
    [Timeout]    14400
    TC_LOGS__Snapshot_BBOX5_File_Check
    [Teardown]    Run Keywords    LOGS__Snapshot_BBOX5_File_Check.TC Teardown
    ...    AND    Restore Resource Search Order

[1]Automated__LOGS__CNI-93136_CNI-93789_Diagnostic_logs_from_secondary_common_unit_related_to_warm_reset
    [Setup]    Run Keywords
    ...    LOGS__CNI-93136_CNI-93789_Diagnostic_logs_from_secondary_common_unit_related_to_warm_reset.TC Setup
    ...    AND    Modify Resource Search Order    LOGS__CNI-93136_CNI-93789_Diagnostic_logs_from_secondary_common_unit_related_to_warm_reset
    ...    AND    Set Library Search Order    LOGS__CNI-93136_CNI-93789_Diagnostic_logs_from_secondary_common_unit_related_to_warm_reset
    [Timeout]    14400
    TC__LOGS__CNI-93136_CNI-93789_Diagnostic_logs_from_secondary_common_unit_related_to_warm_reset
    [Teardown]    Run Keywords
    ...    LOGS__CNI-93136_CNI-93789_Diagnostic_logs_from_secondary_common_unit_related_to_warm_reset.TC Teardown
    ...    AND    Restore Resource Search Order

[1]Automated__LOGS__CB012370-B_Full_DC_triggered_from_WebEM_and_auto_DC_for_CP33_Secondary_core_connectivity
    [Setup]    Run Keywords
    ...    LOGS__CB012370-B_Full_DC_triggered_from_WebEM_and_auto_DC_for_CP33_Secondary_core_connectivity_new.TC Setup
    ...    AND    Modify Resource Search Order
    ...    LOGS__CB012370-B_Full_DC_triggered_from_WebEM_and_auto_DC_for_CP33_Secondary_core_connectivity_new
    ...    AND    Set Library Search Order
    ...    LOGS__CB012370-B_Full_DC_triggered_from_WebEM_and_auto_DC_for_CP33_Secondary_core_connectivity_new
    [Timeout]    14400
    TC__LOGS__CB012370-B_Full_DC_triggered_from_WebEM_and_auto_DC_for_CP33_Secondary_core_connectivity_new
    [Teardown]    Run Keywords
    ...    LOGS__CB012370-B_Full_DC_triggered_from_WebEM_and_auto_DC_for_CP33_Secondary_core_connectivity_new.TC Teardown
    ...    AND    Restore Resource Search Order

[1]Automated__LOGS__CB010655_FRM5_RU_BBOX5_File_Enhancements_Check
    [Setup]    Run Keywords    LOGS__CB010655_FRM5_RU_BBOX5_File_enhancements_Check_new.TC Setup
    ...    AND    Set Library Search Order    LOGS__CB010655_FRM5_RU_BBOX5_File_enhancements_Check_new
    ...    AND    Modify Resource Search Order    LOGS__CB010655_FRM5_RU_BBOX5_File_enhancements_Check_new
    [Timeout]    14400
    TC__LOGS__CB010655_FRM5_RU_BBOX5_File_enhancements_Check_new
    [Teardown]    Run Keywords    LOGS__CB010655_FRM5_RU_BBOX5_File_enhancements_Check_new.TC Teardown
    ...    AND    Restore Resource Search Order

[1]Automated__LOGS__CB007615-SR-A-B3-Get_the_date_and_time_value_before_the_last_reset
    [Setup]    Run Keywords    LOGS__CB007615-SR-A-B3-Get_the_date_and_time_value_before_the_last_reset.TC Setup
    ...    AND    Set Library Search Order    LOGS__CB007615-SR-A-B3-Get_the_date_and_time_value_before_the_last_reset
    ...    AND    Modify Resource Search Order    LOGS__CB007615-SR-A-B3-Get_the_date_and_time_value_before_the_last_reset
    [Timeout]    14400
    TC__LOGS__CB007615-SR-A-B3-Get_the_date_and_time_value_before_the_last_reset
    [Teardown]    Run Keywords    LOGS__CB007615-SR-A-B3-Get_the_date_and_time_value_before_the_last_reset.TC Teardown
    ...    AND    Restore Resource Search Order

[1]Automated__LOGS__CB010699_Collect_Local_SCREL
    [Setup]    Run Keywords    LOGS__CB010699_Collect_Local_SCREL.TC Setup
    ...    AND    Modify Resource Search Order    LOGS__CB010699_Collect_Local_SCREL
    ...    AND    Set Library Search Order    LOGS__CB010699_Collect_Local_SCREL
    [Timeout]    14400
    TC__LOGS__CB010699_Collect_Local_SCREL
    [Teardown]    Run Keywords    LOGS__CB010699_Collect_Local_SCREL.TC Teardown
    ...    AND    Restore Resource Search Order

*** Keywords ***
Suite Teardown
    Run keyword and ignore error    Collect and send logs for scrambling verification
    ...    team_name=PZ3WRO5
    ...    input_logs_dir=${NONE}
    Run keyword and ignore error    Collect and send logs for scrambling verification   team_name=NOKIA_SCREL
    ...    input_logs_dir=${NONE}
    ...    log_purpose=CB010699-SR
