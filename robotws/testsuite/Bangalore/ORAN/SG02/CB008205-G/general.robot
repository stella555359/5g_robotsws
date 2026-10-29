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
Force Tags    CRT  FL00    QCD_MN_RAN   QCP_RAN_VRF
Suite Teardown    Suite Postconditions

*** Variables ***
&{[1][1.0]_CB009196-B_Verification_of_O-RU_M-Plane_version_check_when_supported_M-Plane_version_value_is_higher}    QC_ID_FL00=QC_31130
&{[1][1.0]_CB009196-C_Handling_of_O-RU_fault_notification_for_faults_28,30,16,25,23_&_21}    QC_ID_FL00=QC_31129
&{[1][1.0]_CB009196_Verification_of_miOranRuTxStats_miOranTrxStats_miOranEpeStats_and_miRxWindowStats}    QC_ID_FL00=QC_31128

${LOGGING_ENB_SYSLOG}=             True
${LOGGING_IPHY_SYSLOG}=            False
${LOGGING_ADMIN_LOG}=              True
${LOGGING_ADMIN_INFOMODEL_LOG}=    True
${LOGGING_EMSSIM_LOG}=             False

*** Test Cases ***

TC_01_O-RU M-plane version check when supported M-plane version is higher than O-DU
    [Tags]    CRT    QCD_MN_RAN    QCP_RAN_VRF    TC01
    ${out}    set variable
    ...    ${OUTPUT_DIR}/TC_01_O-RU M-plane version check when supported M-plane version is higher than O-DU
    set test variable    ${out}
    OperatingSystem.create directory     ${out}
    TC_01_O-RU M-plane version check when supported M-plane version is higher than O-DU
    RP Settings
    FSM Access Close Connection
    [Teardown]    run keywords
    ...    reportingportal_Keywords.Set QC_Tag
    ...    Test Postconditions Without WTSSIM S1
    ...    CB008205-G.Test Teardown
    ...    CB008205-G.Link SCOUT SCF to Configuration ID for Reporting

Counter_verification_miOranTrxStats_miRxWindowStats_miOranEpeStats_miOranRuTxStats
    [Tags]    CRT    QCD_MN_RAN    QCP_RAN_VRF    TC02
    ${out}    set variable
    ...    ${OUTPUT_DIR}/Counter_verification_miOranTrxStats_miRxWindowStats_miOranEpeStats_miOranRuTxStats
    set test variable    ${out}
    OperatingSystem.create directory     ${out}
    Counter_verification_miOranTrxStats_miRxWindowStats_miOranEpeStats_miOranRuTxStats
    RP Settings
    FSM Access Close Connection
    [Teardown]    run keywords
    ...    reportingportal_Keywords.Set QC_Tag
    ...    Test Postconditions Without WTSSIM S1
    ...    CB008205-G.Test Teardown
    ...    CB008205-G.Link SCOUT SCF to Configuration ID for Reporting

Alarms_UNKNOWNsources_and_Alarms_25_28_30_16_21_23_gen_and_cancel
    [Tags]    CRT    QCD_MN_RAN    QCP_RAN_VRF    TC03
    ${out}    set variable
    ...    ${OUTPUT_DIR}/Alarms_UNKNOWNsources_and_Alarms_25_28_30_16_21_23_gen_and_cancel
    set test variable    ${out}
    OperatingSystem.create directory     ${out}
    Alarms_UNKNOWNsources_and_Alarms_25_28_30_16_21_23_gen_and_cancel
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
