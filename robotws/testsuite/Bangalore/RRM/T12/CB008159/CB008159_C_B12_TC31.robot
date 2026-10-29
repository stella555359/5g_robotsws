*** Settings ***
Force Tags    CLOUD_5G_I_LO_AP_LO
...           RAN_5G_TDD   RAN_5G     CONFIGURED

Documentation   :copyright: Nokia
...             :author   : rfch37
...             :contact  : anandapriya.mani@nokia.com
...             The aim of the feature is to validate the counters introduced in CB008159
...             for analysing network performance.

Resource    resources/Keywords/8159_keyword.robot

Suite Setup       Updated Suite Setup
Suite Teardown    Common Suite Teardown


*** Variables ***
${SAUE_ID}        1


*** Test Cases ***
[1][1.0] CB008159_C_31_Verify_counter_for_no_of_InSession_QoSFlows_release_by_AMF_via_UEContextReleaseCommand_cause_RN_radio_connnection_with_UE_lost
    [Documentation]    CB008159 TC C_B12_TC31
    [Tags]    QC_28284   QCD_MN_RAN    QCP_RAN_VRF
    ${Test_CaseNumber}     Set Variable     CB008159_C_TC31
    Link SCOUT SCF to Configuration ID for Reporting
    ${Log_Path}        Create Log Directory    ${Test_CaseNumber}
    Log To Console     Starting the test.....
    Start UTE WTS      basic_setup.cfg
    Basic Bring Up
    Wait For Next Full Pm Interval
    Make SA Call    ${SAUE_ID}    ${gw_ID}
    Traffic Should Be Successful For SA    5    2    ${SAUE_ID}
    Radio Connection Ue Lost By AMF    ${SAUE_ID}
    UE Deregister Should Be Successful For SA
    Wait For Next Full Pm Interval
    ${pm_counter_file}      Get Latest Unpacked Full Pm Counters File
    Verify Last Counters In File
    ...     M55125C09027   1     NG_FLOW_REL_AMF_UE_LOST_INSESN
    ...     local_moid=PLMN-PLMN/MRBTS-1/NRBTS-1/NRCELL-1
    ...     file_path=${pm_counter_file}
    [Teardown]    Run Keyword And Ignore Error    Common Test Teardown For 8159


*** Keywords ***
Make SA Call
    [Documentation]    This is SA Call Specific to this testcase.
    [Arguments]    ${SAUE_ID}=${SAUE_ID}    ${gw_ID}=${gw_ID}
    Enable Internal TG   1  1
    Sleep   20s
    wtsrunner.Ue Register   id=${SAUE_ID}
    Sleep   30s
    wtsrunner.Ue Pdu Session Setup    pdu=${Pdu_session_ID}    ue=${SAUE_ID}
    ...    nwslice=${nwslice_ID}       gw=${gw_ID}
    Sleep   30s
