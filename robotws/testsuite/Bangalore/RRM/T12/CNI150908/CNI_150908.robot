*** Settings ***
Force Tags    CLOUD_5G_O_E_AP_LOOO
...           RAN_5G_TDD_FDD   RAN_5G     CONFIGURED

Documentation       The purpose of this test case is to verify CNI150908 new counters and impacted legacy counters.
...                 (QoS flows are released using NGAP: PDU Session Resource Release Request,
...                 PDU Session Resource Modify Request, UE Context Release Command) for RJIO

...                 :author   :   Vijaylakshmi
...                 :contact  :   vijaylakshmi.vijaylakshmi@nokia.com
...                 :Feature  :

Resource          resources/Keywords/CNI150908_keywords.robot

Suite Setup       Updated Suite Setup
Suite Teardown    Common Suite Teardown


*** Variables ***
${DL_RT}                10
${UL_RT}                5
${CELL1}                1
${CELL2}                2
${CELL3}                3
${CELL4}                4
${CELL5}                5
${CELL6}                6
@{UE_RJIO}              1       2       3       4       5       6       7       8       9       10      11      12


*** Test Cases ***
[1][1.0] CNI-150908_A_1_Verify_QosFlow_Release_due_to_Radio_Connection_With_UE_Lost
    [Tags]    QC_NEW2   QCD_MN_RAN    QCP_RAN_VRF
    [Documentation]     The purpose of this test case is to verify the below nonPMQAP,
    ...      5QI1, PMQAP Qos Flow that are released due to Connection with Ue Lost where
    ...      the release is initiated by gNB due to "Radionetwork:Radio connection with UE lost"
    ...      (QoS flows are released using NGAP: UE CONTEXT RELEASE REQUEST )
    [Setup]    Prepare For CNI150908 RJIO
    Log To Console      Start Emil Log
    Sleep   30s
    FOR     ${ueid}     IN    @{UE_RJIO}
        UE Register Should Be Successful For SA     ${ueid}
        Log    Starting Downlink and Uplink Traffic for UE ${ueid}
        DL Traffic Should Be Successful CNI150908    ${DL_RT}    ${ueid}     QFI=1     fiveQI=9
        Modify PDU Session For UE To Add    ${ueid}      2
        Sleep   5
        DL Traffic Should Be Successful CNI150908    ${DL_RT}    ${ueid}     QFI=2     fiveQI=5
        Modify PDU Session For UE To Add    ${ueid}      3
        Sleep   5
        DL Traffic Should Be Successful CNI150908    ${DL_RT}    ${ueid}     QFI=3     fiveQI=1
        Log To Console      Starting Dl and Ul Traffic for UE ${ueid} for diff Qos
    END
    wtsrunner.UE Disp
    Sleep   60s
    Wait For Next Full Pm Interval
    CNI Related RLF Testmode Command
    FOR     ${ueid}     IN    @{UE_RJIO}
        CNI Related UE Testmode Command     id=${ueid}
    END
    Wait For Next Full Pm Interval
    ${pm_counter_file}      Get Latest Unpacked Full Pm Counters File
    Set Test Variable       ${pm_counter_file}
	CNI PM Counters		    ${pm_counter_file} 		${CELL1}
	CNI PM Counters		    ${pm_counter_file} 		${CELL2}
	CNI PM Counters		    ${pm_counter_file} 		${CELL3}
    CNI PM Counters         ${pm_counter_file}      ${CELL4}
    CNI PM Counters         ${pm_counter_file}      ${CELL5}
    CNI PM Counters         ${pm_counter_file}      ${CELL6}
    FOR     ${ueid}     IN    @{UE_RJIO}
        UE Deregister Should Be Successful For SA       ${ueid}
        Log   De-Registered UE ${ueid}
    END
    [Teardown]    Run Keyword And Ignore Error          Common Tear Down For CNI150908 RJIO
