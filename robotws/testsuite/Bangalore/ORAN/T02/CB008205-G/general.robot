*** Settings ***
Documentation
...    Author: rubina.nath@nokia.com
...    Maintainer: anagha.chenniga@nokia.com
...    Test Description for CB008205: This feature is firstly supported in ASIL + ABIO to introduce the general Nokia
...    world market O-RAN compliant O-CDU with FDD eCPRI interface (CAT-A) for FDD NR or FDD LTE.
...    Subitem -B is related to NR FDD technology.
...    CB009196-SR: Split covered: CB009196-A/B/C/D positive scenarios for counter verification, SFP monitoring
...    and alarm generation and cancellation for ORAN specific and alarms with unknown fault sources.
...    Group in charge: I_MN_RAN_RD_VRF_BLR1_T02_TITANS_SQD_GMS <I_MN_RAN_RD_VRF_BLR1_T02_TITANS_SQD@internal.nsn.com>

Library    taf.sw.scout    WITH NAME    scout
Resource    ./resources/CB008205-G.robot
Resource    ./testsuite/Bangalore/ORAN/resources/robot/reportingportal_Keywords.robot

Suite Setup    Suite Preconditions
Test Setup    ORAN Preconditions
Test Teardown    Test Postconditions Without WTSSIM S1
Force Tags    CRT  FL00    SBTS25R2    SBTS25R3    QCD_MN_RAN   QCP_RAN_VRF
Suite Teardown    Suite Postconditions

*** Variables ***
&{[1]CB009196-B_Verification_of_O-RU_M-Plane_version_check_when_supported_M-Plane_version_value_is_higher}    QC_ID_FL00=QC_175070
&{[1]CB009196-C_Handling_of_O-RU_fault_notification_for_faults_28,30,16,25,23_&_21}    QC_ID_FL00=QC_175059    QC_ID_SBTS25R2=218609
...    QC_ID_SBTS26R2=302785     QC_ID_SBTS26R1=247039
&{[1]CB009196_Verification_of_miOranRuTxStats_miOranTrxStats_miOranEpeStats_and_miRxWindowStats_counters_activation}    QC_ID_FL00=QC_174960
...    QC_ID_SBTS25R2=218605
&{[1]CB008967-F-SR_To_verify_different_TEMP_values_with_backdoor_command_for_certain_time_and_check_for_faults}    QC_ID_FL00=QC_235374
...    QC_ID_SBTS25R3=217499

${LOGGING_ENB_SYSLOG}=             True
${LOGGING_IPHY_SYSLOG}=            False
${LOGGING_ADMIN_LOG}=              True
${LOGGING_ADMIN_INFOMODEL_LOG}=    True
${LOGGING_EMSSIM_LOG}=             False

*** Test Cases ***

[1]CB009196-B_Verification_of_O-RU_M-Plane_version_check_when_supported_M-Plane_version_value_is_higher
    [Tags]    CRT    QCD_MN_RAN    QCP_RAN_VRF    TC01
    ${out}    set variable
    ...    ${OUTPUT_DIR}/TC_01_O-RU M-plane version check when supported M-plane version is higher than O-DU
    set test variable    ${out}
    OperatingSystem.create directory     ${out}
    [1]CB009196-B_Verification_of_O-RU_M-Plane_version_check_when_supported_M-Plane_version_value_is_higher
    RP Settings
    FSM Access Close Connection
    [Teardown]    run keywords
    ...    reportingportal_Keywords.Set QC_Tag
    ...    Test Postconditions Without WTSSIM S1
    ...    CB008205-G.Test Teardown
    ...    CB008205-G.Link SCOUT SCF to Configuration ID for Reporting

[1]CB009196_Verification_of_miOranRuTxStats_miOranTrxStats_miOranEpeStats_and_miRxWindowStats_counters_activation
    [Tags]    CRT    QCD_MN_RAN    QCP_RAN_VRF    TC02
    ${out}    set variable
    ...    ${OUTPUT_DIR}/Counter_verification_miOranTrxStats_miRxWindowStats_miOranEpeStats_miOranRuTxStats
    set test variable    ${out}
    OperatingSystem.create directory     ${out}
    [1]CB009196_Verification_of_miOranRuTxStats_miOranTrxStats_miOranEpeStats_and_miRxWindowStats_counters_activation
    RP Settings
    FSM Access Close Connection
    [Teardown]    run keywords
    ...    reportingportal_Keywords.Set QC_Tag
    ...    Test Postconditions Without WTSSIM S1
    ...    CB008205-G.Test Teardown
    ...    CB008205-G.Link SCOUT SCF to Configuration ID for Reporting

[1]CB009196-C_Handling_of_O-RU_fault_notification_for_faults_28,30,16,25,23_&_21
    [Tags]    CRT    QCD_MN_RAN    QCP_RAN_VRF    TC03
    ${out}    set variable
    ...    ${OUTPUT_DIR}/Alarms_UNKNOWNsources_and_Alarms_25_28_30_16_21_23_gen_and_cancel
    set test variable    ${out}
    OperatingSystem.create directory     ${out}
    [1]CB009196-C_Handling_of_O-RU_fault_notification_for_faults_28,30,16,25,23_&_21
    RP Settings
    FSM Access Close Connection
    [Teardown]    run keywords
    ...    reportingportal_Keywords.Set QC_Tag
    ...    Test Postconditions Without WTSSIM S1
    ...    CB008205-G.Test Teardown
    ...    CB008205-G.Link SCOUT SCF to Configuration ID for Reporting

[1]CB008967-F-SR_To_verify_different_TEMP_values_with_backdoor_command_for_certain_time_and_check_for_faults
    [Tags]    CRT    QCD_MN_RAN    QCP_RAN_VRF    TC04
    ${out}    set variable
    ...    ${OUTPUT_DIR}/CB008967F
    set test variable    ${out}
    OperatingSystem.create directory     ${out}
    [1]CB008967-F-SR_To_verify_different_TEMP_values_with_backdoor_command_for_certain_time_and_check_for_faults
    RP Settings
    FSM Access Close Connection
    [Teardown]    run keywords
    ...    reportingportal_Keywords.Set QC_Tag
    ...    Test Postconditions Without WTSSIM S1
    ...    CB008205-G.Test Teardown
    ...    CB008205-G.Link SCOUT SCF to Configuration ID for Reporting

*** Keywords ***
FSM Access Close Connection
    [Arguments]    ${alias}=fsm_access
    Teardown Enb Fsm Access    alias=${alias}