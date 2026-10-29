*** Settings ***
Force Tags    CLOUD_5G_I_MP_AP_LO
...           RAN_5G_TDD   RAN_5G     CONFIGURED

Documentation   :copyright: Nokia
...             :author   : Jenish
...             :contact  : jenish.valan@nokia.com
...             The aim of the feature is to validate the counters introduced in CB008159
...             for analysing network performance.

Resource    resources/Keywords/8159_keyword.robot

Suite Setup       Updated Suite Setup
Suite Teardown    Common Suite Teardown


*** Variables ***
${DELTA_DIR}        ${CURDIR}/config/scf
${TOPOLOGY}           CLOUD_5G_I_MP_AP_LO

*** Test Cases ***
[1][1.0] CB008159_B_16_Verify_counter_for_number_of_ERABs_release_due_to_User_Inactiviy
    [Documentation]      This testcase is used to verify counters for Number
    ...                  SgNB-initiated NSA ERABs that were releaseddue to bearer inactivity.
    [Tags]    QC_28282   QCD_MN_RAN    QCP_RAN_VRF
    [Setup]      Run Keywords     Link SCOUT SCF to Configuration ID for Reporting
    ...     AND     GNB Delta Commission     ${DELTA_DIR}/Delta_Configuration_CB008159_B_B22_TC16.json
    ...     AND     Start UTE WTS     basic_setup_MP_AP_LO.cfg
    ${Test_CaseNumber}     Set Variable    CB008159_B_B22_TC16
    ${Log_Path}      Create Log Directory    ${Test_CaseNumber}
    Log To Console          \nStarting the test.....
    Basic Bring Up
    Wait For Next Full Pm Interval
    LTE Attach Should Be Successful For NSA     11
    Trigger ENDC Connection And Verify SGNB Releasing ENDC Connection With Cause Userinactivity      11   1
    UE Detach Should Be Successful For NSA      11
    Wait For Next Full Pm Interval
    ${pm_counter_file}      Get Latest Unpacked Full Pm Counters File
    Verify Last Counters In File
    ...     M55112C06022   1     NX2CC_RAB_REL_INACT_SGNB
    ...     local_moid=PLMN-PLMN/MRBTS-1/NRBTS-1/NRCELL-1
    ...     file_path=${pm_counter_file}
    [Teardown]    Common Test Teardown For MP AP LO
