*** Settings ***
Force Tags    CLOUD_5G_I_MP_AP_LO
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
${SA_UEID}        1
${TOPOLOGY}           CLOUD_5G_I_MP_AP_LO

*** Test Cases ***
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


*** Keywords ***
Make SA Call
    [Documentation]    This is L3 Call specific to this testcase.
    [Arguments]    ${SA_UEID}=${SA_UEID}    ${gw_ID}=${gw_ID}
    Enable Internal TG   1  1
    Sleep   20s
    wtsrunner.Ue Register   id=${SA_UEID}
    Sleep   30s
    wtsrunner.Ue Pdu Session Setup    pdu=${Pdu_session_ID}    ue=${SA_UEID}
    ...    nwslice=${nwslice_ID}       gw=${gw_ID}
    Sleep   30s
