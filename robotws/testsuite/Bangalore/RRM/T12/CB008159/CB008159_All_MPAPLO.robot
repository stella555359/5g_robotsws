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
${NSA_UEID_11}        11
${TOPOLOGY}           CLOUD_5G_I_MP_AP_LO
${SA_UEID}            1
${DELTA_DIR}          ${CURDIR}/config/scf

*** Test Cases ***
[1][1.0] CB008159_A_1_Verify_counter_for_number_of_ERABs_release_initiated_by_MeNB_with_cause_misc_unspecified
    [Documentation]      This testcase is used to verify counters for Number MeNB-initiated NSA ERABs released
    ...                  due to failure misc: unspecified.
    [Tags]    QC_28280   QCD_MN_RAN    QCP_RAN_VRF
    ${Test_CaseNumber}     Set Variable    CB008159_A_B2_TC1
    Link SCOUT SCF to Configuration ID for Reporting
    ${Log_Path}      Create Log Directory    ${Test_CaseNumber}
    Log To Console          Starting the test.....
    Start UTE WTS      basic_setup_MP_AP_LO.cfg
    Basic Bring Up
    Wait For Next Full Pm Interval
    Make ENDC Call
    Trigger LTE-NR Dual Connectivity Release From MeNB With Misc Unspecified Cause    ${NSA_UEID_11}
    UE Detach Should Be Successful For NSA      ${NSA_UEID_11}
    Wait For Next Full Pm Interval
    ${pm_counter_file}      Get Latest Unpacked Full Pm Counters File
    Verify Last Counters In File
    ...     M55112C06010   1     NX2CC_RAB_REL_MISC_USPC_MENB
    ...     local_moid=PLMN-PLMN/MRBTS-1/NRBTS-1/NRCELL-1
    ...     file_path=${pm_counter_file}
    [Teardown]      Common Test Teardown For MP AP LO

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

[1][1.0] CB008159_C_25_Verify_counter_for_number_of_in_session_QoS_flows_release_with_normal_causes_via_NGAP_PDUSessionResourceReleaseCommand
    [Documentation]    CB008159 TC C_B22_TC25
    [Tags]    QC_28285   QCD_MN_RAN    QCP_RAN_VRF
    ${Test_CaseNumber}     Set Variable    CB008159_C_TC25
    Link SCOUT SCF to Configuration ID for Reporting
    ${Log_Path}        Create Log Directory    ${Test_CaseNumber}
    Log To Console     \nStarting the test.....
    Start UTE WTS     basic_setup_MP_AP_LO.cfg
    Basic Bring Up
    Wait For Next Full Pm Interval
    Make SA Call    ${SA_UEID}    ${gw_ID}
    Traffic Should Be Successful For SA    5    2    ${SA_UEID}
    Release QoS Flow Using PDUSessionResourceReleaseCommand With Normal Cause    ${SA_UEID}
    Release PDU Session By AMF    ${SA_UEID}
    UE Deregister Should Be Successful For SA
    Wait For Next Full Pm Interval
    ${pm_counter_file}      Get Latest Unpacked Full Pm Counters File
    Verify Last Counters In File
    ...     M55125C09025   1     NG_FLOW_REL_NORMAL_INSESSION
    ...     local_moid=PLMN-PLMN/MRBTS-1/NRBTS-1/NRCELL-1
    ...     file_path=${pm_counter_file}
    [Teardown]    Common Test Teardown For MP AP LO
