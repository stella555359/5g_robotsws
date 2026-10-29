*** Settings ***
Force Tags   QCD_MN_RAN    QCP_RAN_ST    CRT    CLOUD_SRAN_NLWG_1ASIB_1ABIA_1ABIN_1ABIO_1ASIA_3ABIA_1AHCA_1AHIB_1AHEH_2AHEB_1AHLOA_1FRHC   SBTS24R3
Library      XML  use_lxml=True
Resource     taf/rfrl/scrambling_logs_collector/Keywords.robot
Resource     ../../LOGS/LOGS__CNI-93136_CNI-93789_Diagnostic_logs_from_secondary_common_unit_related_to_warm_reset.robot
Resource     ../../LOGS/LOGS__CB012370-B_Full_DC_triggered_from_WebEM_and_auto_DC_for_CP33_Secondary_core_connectivity.robot
Resource     ../../LOGS/LOGS__LTE3266-A-d_Snapshot_Troubleshooting_RF_SOAP_log.robot
Resource     ../../LOGS/LOGS__CB009077_FRM5_RU_check.robot
Resource     ../../LOGS/LOGS__CB010655_FRM5_RU_BBOX5_File_enhancements_Check.robot

Suite Teardown    Suite Teardown

*** Variables ***
${SCF_ID}         01

${COMMISSIONING_PATH}
    ...   /home/ute/MN/UTE/robotws/testsuite/Timisoara/SBTS/test_line_specific/SBTS_10825_Ford/commissioning/SCF_01_SBTS24R3.xml

*** Test Cases ***
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
    ...    LOGS__CB012370-B_Full_DC_triggered_from_WebEM_and_auto_DC_for_CP33_Secondary_core_connectivity.TC Setup
    ...    AND    Modify Resource Search Order
    ...    LOGS__CB012370-B_Full_DC_triggered_from_WebEM_and_auto_DC_for_CP33_Secondary_core_connectivity
    ...    AND    Set Library Search Order
    ...    LOGS__CB012370-B_Full_DC_triggered_from_WebEM_and_auto_DC_for_CP33_Secondary_core_connectivity
    [Timeout]    14400
    TC__LOGS__CB012370-B_Full_DC_triggered_from_WebEM_and_auto_DC_for_CP33_Secondary_core_connectivity
    [Teardown]    Run Keywords
    ...    LOGS__CB012370-B_Full_DC_triggered_from_WebEM_and_auto_DC_for_CP33_Secondary_core_connectivity.TC Teardown
    ...    AND    Restore Resource Search Order

[1]Automated__LOGS__LTE3266-A-d_Snapshot_Troubleshooting_RF_SOAP_log
    [Setup]    Run Keywords    LOGS__LTE3266-A-d_Snapshot_Troubleshooting_RF_SOAP_log.TC Setup
    ...    AND    Modify Resource Search Order    LOGS__LTE3266-A-d_Snapshot_Troubleshooting_RF_SOAP_log
    ...    AND    Set Library Search Order    LOGS__LTE3266-A-d_Snapshot_Troubleshooting_RF_SOAP_log
    [Timeout]    14400
    TC__LOGS__LTE3266-A-d_Snapshot_Troubleshooting_RF_SOAP_log
    [Teardown]    Run Keywords    LOGS__LTE3266-A-d_Snapshot_Troubleshooting_RF_SOAP_log.TC Teardown
    ...    AND    Restore Resource Search Order

[1]Automated__LOGS__CB009077_FRM5_RU_check
    [Setup]    Run Keywords    LOGS__CB009077_FRM5_RU_check.TC Setup
    ...    AND    Set Library Search Order    LOGS__CB009077_FRM5_RU_check
    ...    AND    Modify Resource Search Order    LOGS__CB009077_FRM5_RU_check
    [Timeout]    14400
    TC_LOGS__CB009077_FRM5_RU_check
    [Teardown]    Run Keywords    LOGS__CB009077_FRM5_RU_check.TC Teardown
    ...    AND    Restore Resource Search Order

[1]Automated__LOGS__CB010655_FRM5_RU_BBOX5_File_Enhancements_Check
    [Setup]    Run Keywords    LOGS__CB010655_FRM5_RU_BBOX5_File_enhancements_Check.TC Setup
    ...    AND    Set Library Search Order    LOGS__CB010655_FRM5_RU_BBOX5_File_enhancements_Check
    ...    AND    Modify Resource Search Order    LOGS__CB010655_FRM5_RU_BBOX5_File_enhancements_Check
    [Timeout]    14400
    TC__LOGS__CB010655_FRM5_RU_BBOX5_File_enhancements_Check
    [Teardown]    Run Keywords    LOGS__CB010655_FRM5_RU_BBOX5_File_enhancements_Check.TC Teardown
    ...    AND    Restore Resource Search Order

*** Keywords ***
Suite Teardown
    Run keyword and ignore error    Collect and send logs for scrambling verification
    ...    team_name=PZ3WRO5
    ...    input_logs_dir=${NONE}
