*** Settings ***
Documentation  Tests for BMW
Force Tags        QCD_MN_RAN    QCP_RAN_VRF    CRT    CLOUD_SRAN_NL_10832_ASIL_ABIQ_2ABIN_FRHC_AHFB_AHLOA    SBTS00
Library           XML  use_lxml=True
Resource          taf/rfrl/scrambling_logs_collector/Keywords.robot
Resource          ../../LOGS/LOGS__CB008626_FullWithoutRFLogs_Snapshot_With_Filter_Keywords.robot
Resource          ../../LOGS/LOGS__CB008626_B_Configuration_change_history_improvement.robot
Resource          ../../LOGS/LOGS__CB010239-C_Full_DC_and_diagnostic_report_verification.robot
Resource          ../../LOGS/LOGS__CNI-90327_AaTrblServer_configuration_formalization.robot
Resource          ../../LOGS/LOGS_CB010545_AdminCLI_snapshot_Full_coverage.robot
Resource          ../../LOGS/LOGS__CNI-93026_03_Logs_present_in_new_SSD_location.robot
#Resource          ../../TRACE/CB008779.robot
#Resource          ../../TRACE/LTE1308.robot
#Resource          ../../TRACE/CB006590-A_Get_active_UEs.robot
#Resource          ../../TRACE/CB006590-C_IP_Traffic_Capturing.robot
#Resource          ../../TRACE/CB006590-C_L1_IQ_Data_Capturing.robot
#Resource          ../../TRACE/CB006590-B_Get_active_UEs.robot
#Resource          ../../TRACE/CB006590-B_Reset_5G_Cell_Group.robot
#Resource          ../../TRACE/CB008411.robot

Suite Teardown    Suite Teardown

*** Variables ***
${SCF_ID}         01
${COMMISSIONING_PATH}
    ...    /home/ute/MN/UTE/robotws/testsuite/Timisoara/SBTS/test_line_specific/SBTS_10832_BMW/commissioning/SCF_01_TRUNK.xml

${NETACT_LAB}    &{srnclab1028}

*** Test Cases ***
LOGS__CNI-93026_03_Logs_present_in_new_SSD_location
    [Setup]    Run Keywords    LOGS__CNI-93026_03_Logs_present_in_new_SSD_location.TC Setup
    ...    AND    Modify Resource Search Order    LOGS__CNI-93026_03_Logs_present_in_new_SSD_location
    ...    AND    Set Library Search Order    LOGS__CNI-93026_03_Logs_present_in_new_SSD_location
    [Timeout]    14400
    TC__LOGS__CNI-93026_03_Logs_present_in_new_SSD_location
    [Teardown]    Run Keywords    LOGS__CNI-93026_03_Logs_present_in_new_SSD_location.TC Teardown
    ...    AND    Restore Resource Search Order

[1]Automated__LOGS__CB008626_FullWithoutRFLogs_Snapshot_With_Filter_Keywords
    [Setup]    Run Keywords    LOGS__CB008626_FullWithoutRFLogs_Snapshot_With_Filter_Keywords.TC Setup
    ...    AND    Modify Resource Search Order    LOGS__CB008626_FullWithoutRFLogs_Snapshot_With_Filter_Keywords
    ...    AND    Set Library Search Order    LOGS__CB008626_FullWithoutRFLogs_Snapshot_With_Filter_Keywords
    [Timeout]    14400
    TC__LOGS__CB008626_FullWithoutRFLogs_Snapshot_With_Filter_Keywords
    [Teardown]    Run Keywords    LOGS__CB008626_FullWithoutRFLogs_Snapshot_With_Filter_Keywords.TC Teardown
    ...    AND    Restore Resource Search Order

[1]09_CB008626_B_Configuration_change_history_improvement
    [Setup]    Run Keywords    LOGS__CB008626_B_Configuration_change_history_improvement.TC Setup
    ...    AND    Modify Resource Search Order    LOGS__CB008626_B_Configuration_change_history_improvement
    ...    AND    Set Library Search Order    LOGS__CB008626_B_Configuration_change_history_improvement
    [Timeout]    14400
    TC__LOGS__CB008626_B_Configuration_change_history_improvement
    [Teardown]    Run Keywords    LOGS__CB008626_B_Configuration_change_history_improvement.TC Teardown
    ...    AND    Restore Resource Search Order

[1]Automated__LOGS__CB010239-C_Full_DC_and_diagnostic_report_verification
    [Setup]    Run Keywords    LOGS__CB010239-C_Full_DC_and_diagnostic_report_verification.TC Setup
    ...    AND    Modify Resource Search Order    LOGS__CB010239-C_Full_DC_and_diagnostic_report_verification
    ...    AND    Set Library Search Order    LOGS__CB010239-C_Full_DC_and_diagnostic_report_verification
    [Timeout]    14400
    TC__LOGS__CB010239-C_Full_DC_and_diagnostic_report_verification
    [Teardown]    Run Keywords    LOGS__CB010239-C_Full_DC_and_diagnostic_report_verification.TC Teardown
    ...    AND    Restore Resource Search Order

[1]Automated__LOGS__CNI-90327_AaTrblServer_configuration_formalization
    [Setup]    Run Keywords    LOGS__CNI-90327_AaTrblServer_configuration_formalization.TC Setup
    ...    AND    Modify Resource Search Order    LOGS__CNI-90327_AaTrblServer_configuration_formalization
    ...    AND    Set Library Search Order    LOGS__CNI-90327_AaTrblServer_configuration_formalization
    [Timeout]    14400
    TC__LOGS__CNI-90327_AaTrblServer_configuration_formalization
    [Teardown]    Run Keywords    LOGS__CNI-90327_AaTrblServer_configuration_formalization.TC Teardown
    ...    AND    Restore Resource Search Order

[1]CB010545_AdminCLI_snapshot_Full_coverage
    [Setup]    Run Keywords    LOGS_CB010545_AdminCLI_snapshot_Full_coverage.TC Setup
    ...    AND    Modify Resource Search Order    LOGS_CB010545_AdminCLI_snapshot_Full_coverage
    ...    AND    Set Library Search Order    LOGS_CB010545_AdminCLI_snapshot_Full_coverage
    [Timeout]    14400
    TC__LOGS_CB010545_AdminCLI_snapshot_Full_coverage
    [Teardown]    Run Keywords    LOGS_CB010545_AdminCLI_snapshot_Full_coverage.TC Teardown
    ...    AND    Restore Resource Search Order

#Configuration of LTE2202 (Cell Trace with MAC extensions) and LTE3333 (PCMD) content in the same Trace Session
#    [Tags]    ReTest
#    [Setup]     Run Keywords    CB008779.TC Setup
#    ...    AND    Modify Resource Search Order    CB008779
#    ...    AND    Set Library Search Order    CB008779
#    [Timeout]    45min
#    CB008779 verification
#    [Teardown]  Run Keywords    CB008779.TC Teardown
#    ...    AND    Restore Resource Search Order
#
#Immediate MDT Basic Operation
##    [Tags]    ReTest
#    [Setup]     Run Keywords    LTE1308.TC Setup
#    ...    AND    Modify Resource Search Order    LTE1308
#    ...    AND    Set Library Search Order    LTE1308
#    [Timeout]    30min
#    LTE1308 Immediate MDT Basic Operation
#    [Teardown]  Run Keywords    LTE1308.TC Teardown
#    ...    AND    Restore Resource Search Order
#
#L1 IQ data capture commands with WebEM Remote Tool
##    [Tags]    ReTest
#    [Timeout]    60min
#    [Setup]    Run Keywords     CB006590-C_IP_Traffic_Capturing.CB006590 Setup
#    ...    AND    Modify Resource Search Order    CB006590-C_IP_Traffic_Capturing
#    ...    AND    Set Library Search Order    CB006590-C_IP_Traffic_Capturing
#    L1 IQ data capture commands with WebEM Remote Tool
#    [Teardown]    Run Keywords     CB006590-C_IP_Traffic_Capturing.CB006590 Teardown
#    ...    AND    Restore Resource Search Order
#
#Number of active UE per cell monitor with WebEM Remote tool
##    [Tags]    ReTest
#    [Timeout]    60min
#    [Setup]    Run Keywords    CB006590-C_IP_Traffic_Capturing.CB006590 Setup
#    ...    AND    Modify Resource Search Order    CB006590-C_IP_Traffic_Capturing
#    ...    AND    Set Library Search Order    CB006590-C_IP_Traffic_Capturing
#    ActiveUEs with WebEM Remote Tool
#    [Teardown]    Run Keywords     CB006590-C_IP_Traffic_Capturing.CB006590 Teardown
#    ...    AND    Restore Resource Search Order
#
#CB008411 Activation of the Subscriber Trace with PCMD content
##    [Tags]    ReTest
#    [Setup]     Run Keywords     CB008411.CB008411 setup
#    ...    AND    Modify Resource Search Order    CB008411
#    ...    AND    Set Library Search Order    CB008411
#    [Timeout]    90min
#    Activation of the Subscriber Trace with PCMD content related to CB008411
#    [Teardown]  Run Keywords     CB008411.CB008411 teardown
#    ...    AND    Restore Resource Search Order

*** Keywords ***
Suite Teardown
    Run keyword and ignore error    Collect and send logs for scrambling verification
    ...    team_name=VRFTSR5
    ...    input_logs_dir=${NONE}
