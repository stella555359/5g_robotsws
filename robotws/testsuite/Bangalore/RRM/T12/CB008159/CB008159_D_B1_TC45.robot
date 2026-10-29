*** Settings ***
Force Tags    CLOUD_5G_I_LO_AP_LO
...           CRT   RAN_5G_TDD   RAN_5G    SBTS00     SBTS23R2   CONFIGURED

Documentation   :copyright: Nokia
...             :author   : Jenish
...             :contact  : jenish.valan@nokia.com
...             The aim of the feature is to validate the counters introduced in CB008159
...             for analysing network performance.

Resource    resources/Keywords/8159_keyword.robot

Suite Setup       Updated Suite Setup
Suite Teardown    Common Suite Teardown


*** Variables ***
${UE_ID}            1
${DELTA_DIR}        ${CURDIR}/config/scf


*** Test Cases ***
[1][1.0] CB008159_D_45_Verify_counter_for_VoNR_QoS_flow_setup_timer_measurement_when_VoNR_is_setup_via_NGAP_PDU_RESOURCE_MODIFY_REQUEST
    [Documentation]      This testcase is used to make VoNR  call using  NGAP: PDU RESOURCE MODIFY REQUEST
    ...                  and verify the counters for Time to setup 5QI1 QosFlow in a measurement period
    ...                  and Maximum time to setup 5QI1 QosFlow in a measurement period.
    [Tags]    QC_28283   QCD_MN_RAN    QCP_RAN_VRF
    [Setup]      Run Keywords     Create Basic Interface On UTE
    ...     AND     Link SCOUT SCF to Configuration ID for Reporting
    ...     AND     GNB Delta Commission     ${DELTA_DIR}/Delta_Configuration_CB008159_D_B1_TC45.json
    ...     AND     Start UTE WTS      basic_setup_CB008159_D_B1_TC45.cfg
    ${Test_CaseNumber}     Set Variable     CB008159_D_B1_TC45
    ${Log_Path}      Create Log Directory    ${Test_CaseNumber}
    Log To Console          Starting the test.....
    Basic Bring Up
	Wait For Next Full Pm Interval
    Register And Establish GBR And Non-GBR Calls
    Stop Data Traffic For SA    ${UE_ID}
    UE Deregister Should Be Successful For SA
    Wait For Next Full Pm Interval
    ${pm_counter_file}      Get Latest Unpacked Full Pm Counters File
    Verify Last Counters In File
    ...     M55125C09030    >0     NG_FLOW_SETUP_TIME_5QI1
    ...     M55125C09031    >0     NG_FLOW_SETUP_TIME_MAX_5QI1
    ...     local_moid=PLMN-PLMN/MRBTS-1/NRBTS-1/NRCELL-1
    ...     file_path=${pm_counter_file}
    [Teardown]    Run Keyword And Ignore Error    Common Test Teardown For 8159


*** Keywords ***
Register And Establish GBR And Non-GBR Calls
    [Documentation]    This keyword shall register UE and establish GBR and Non-GBR data calls
    Enable Internal TG   1  1
    UE Register should be Successful for SA
    Sleep   10s
    Traffic Should Be Successful For SA
    Sleep   10s
    UE Modification Should Be Successful    1   1   2
    Sleep   10s
    Trigger TCP Data   1   1   3   2
    Sleep   10s
    UE Modification Should Be Successful    1   1   3
    Sleep   20s
    Trigger VoNR Data   1   1   3   3   amr_wb_18_25
