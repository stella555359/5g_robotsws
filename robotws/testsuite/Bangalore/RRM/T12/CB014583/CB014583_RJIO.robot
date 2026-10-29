*** Settings ***
Force Tags    CLOUD_5G_O_E_AP_LOOO
...           RAN_5G_TDD_FDD   RAN_5G     CONFIGURED
Documentation       The purpose of this test case is to verify CB014583 new counters and impacted legacy counters.
...                 (QoS flows are released using NGAP: PDU Session Resource Release Request,
...                 PDU Session Resource Modify Request, UE Context Release Command) for RJIO
...                 :author   :   Vikash Kumar
...                 :contact  :   vikash.20.kumar@nokia.com
Resource          resources/Keywords/CB014583_keywords.robot

Suite Setup       Updated Suite Setup
Suite Teardown    Common Suite Teardown


*** Variables ***
${TOPOLOGY}             CLOUD_5G_O_E_AP_LOOO
${DL_RT}                10
${UL_RT}                5
${CELL1}                1
${CELL2}                2
${CELL3}                3
${CELL4}                4
${CELL5}                5
${CELL6}                6
@{UE_RJIO}         1     2       3      4        5         6        7        8     9     10
...               11     12      13     14       15        16       17       18
...               19     20      21     22       23        24
${UE_25}                25
${QFI3}                  3


*** Test Cases ***
[1][1.0] CB014583_1_verify_new_counters_and_impacted_legacy_counters_when_QFIs_are_released_using_NGAP_Pdu_Session_Resource_Release_Command_RJIO
    [Tags]    QC_243563    QCD_MN_RAN    QCP_RAN_VRF
    [Documentation]     The purpose of this test case is to verify CB014583 new counters and impacted legacy counters.
    ...                 (QoS flows are released using NGAP: PDU Session Resource Release Command)
    [Setup]    Prepare For CB014583 RJIO
    Sleep   30s
    slog.Start Syslog   ${Log_Path}     SysLogCapRJIO.LOG
    Pass Lua File For Attach
    wtsrunner.UE Disp
    Pass Lua File For 5QI
    Wait For Next Full Pm Interval
    All PDU Release For CB014583 5GC
    All PDU Release For CB014583 NGRAN
    All PDU Release For CB014583 CN
    All PDU Release For CB014583 UE Lost
    Wait For Next Full Pm Interval
    ${pm_counter_file}      Get Latest Unpacked Full Pm Counters File
    Set Test Variable       ${pm_counter_file}
    5GC PM Counters Release          ${pm_counter_file}     ${CELL1}
    NGRAN PM Counters Release        ${pm_counter_file}     ${CELL2}
    CN PM Counters Release           ${pm_counter_file}     ${CELL3}
    5GC PM Counters Release          ${pm_counter_file}     ${CELL4}
    NGRAN PM Counters Release        ${pm_counter_file}     ${CELL5}
    CN PM Counters Release           ${pm_counter_file}     ${CELL6}
    Special Counters For CB014583 Release     ${pm_counter_file}
    FOR     ${ueid}     IN    @{UE_RJIO}
        UE Deregister Should Be Successful For SA       ${ueid}
        Log   De-Registered UE ${ueid}
    END
    Sleep    5s
    LOG TO CONSOLE    \n Starting case for EDA...
    UE Register Should Be Successful For SA    ${UE_25}
    trf_data_start    ue=${UE_25}    pdu=1    qfi=1    trf_id=1    mbps=10    dir=dl
    trf_data_start    ue=${UE_25}    pdu=1    qfi=1    trf_id=2    mbps=5    dir=ul
    Modify PDU Session For UE To Add    ${UE_25}
    trf_data_start    ue=${UE_25}    pdu=1    qfi=2   dir=dl  kbps=900    protocol=tcp  seconds=3600
    trf_data_start    ue=${UE_25}    pdu=1    qfi=2   dir=ul  kbps=900    protocol=tcp  seconds=3600
    Modify PDU Session For UE To Add    ${UE_25}     ${QFI3}
    trf_data_start    ue=${UE_25}   pdu=1    qfi=3    dir=dl    rtp_codec=g711m    seconds=3600
    Sleep    2s
    trf_data_start    ue=${UE_25}    pdu=1    qfi=3    dir=ul    rtp_codec=g711m    seconds=3600
    Sleep    2s
    trf_data_start    ue=${UE_25}    pdu=1    qfi=3    dir=dl    kbps=300    protocol=udp    seconds=3600
	Sleep    2s
	trf_data_start    ue=${UE_25}    pdu=1    qfi=3    dir=ul    kbps=300    protocol=udp    seconds=3600
    Wait For Next Full Pm Interval
    Normal PDU Release for EDA    ${UE_25}
    Wait For Next Full Pm Interval
    ${pm_counter_file}      Get Latest Unpacked Full Pm Counters File
    Set Test Variable       ${pm_counter_file}
    Validate Counter For Normal Release
    [Teardown]    Run Keyword And Ignore Error          Common Tear Down For CB014583 RJIO

[1][1.0] CB014583_2_verify_new_counters_and_impacted_legacy_counters_when_QFIs_are_released_using_NGAP_PDU_Session_Resource_Modify_Request_RJIO
    [Tags]    QC_236989     QCD_MN_RAN       QCP_RAN_VRF
    [Documentation]     The purpose of this test case is to verify CB014583 new counters and impacted legacy counters.
    ...                 (QoS flows are released using NGAP: PDU Session Resource Modify Request)
    [Setup]    Prepare For CB014583 RJIO
    Log To Console      Start Emil Log
    Sleep   30s
    slog.Start Syslog   ${Log_Path}     SysLogCapRJIO.LOG
    Pass Lua File For Attach
    wtsrunner.UE Disp
    Pass Lua File For 5QI
    wtsrunner.UE Disp
    Sleep   60s
    Wait For Next Full Pm Interval
    All PDU Modify For CB014583 5GC
    All PDU Modify For CB014583 NGRAN
    All PDU Modify For CB014583 CN
    All PDU Modify For CB014583 UE LOST
    Wait For Next Full Pm Interval
    ${pm_counter_file}      Get Latest Unpacked Full Pm Counters File
    Set Test Variable       ${pm_counter_file}
    5GC PM Counters         ${pm_counter_file}     ${CELL1}
    NGRAN PM Counters       ${pm_counter_file}     ${CELL2}
    CN PM Counters          ${pm_counter_file}     ${CELL3}
    5GC PM Counters         ${pm_counter_file}     ${CELL4}
    NGRAN PM Counters       ${pm_counter_file}     ${CELL5}
    CN PM Counters          ${pm_counter_file}     ${CELL6}
    Special Counters For CB014583   ${pm_counter_file}
    FOR     ${ueid}     IN    @{UE_RJIO}
        UE Deregister Should Be Successful For SA       ${ueid}
        Log   De-Registered UE ${ueid}
    END
    LOG TO CONSOLE    \n Starting case for EDA...
    UE Register Should Be Successful For SA    ${UE_25}
    trf_data_start    ue=${UE_25}    pdu=1    qfi=1    trf_id=1    mbps=10    dir=dl
    trf_data_start    ue=${UE_25}    pdu=1    qfi=1    trf_id=2    mbps=5    dir=ul
    Modify PDU Session For UE To Add    ${UE_25}
    trf_data_start    ue=${UE_25}    pdu=1    qfi=2   dir=dl  kbps=900    protocol=tcp  seconds=3600
    trf_data_start    ue=${UE_25}    pdu=1    qfi=2   dir=ul  kbps=900    protocol=tcp  seconds=3600
    Modify PDU Session For UE To Add    ${UE_25}     ${QFI3}
    trf_data_start    ue=${UE_25}    pdu=1    qfi=3    dir=dl    rtp_codec=g711m    seconds=3600
    Sleep    2s
    trf_data_start    ue=${UE_25}    pdu=1    qfi=3    dir=ul    rtp_codec=g711m    seconds=3600
    Sleep    2s
    trf_data_start    ue=${UE_25}    pdu=1    qfi=3    dir=dl    kbps=300    protocol=udp    seconds=3600
	Sleep    2s
	trf_data_start    ue=${UE_25}    pdu=1    qfi=3    dir=ul    kbps=300    protocol=udp    seconds=3600
    Wait For Next Full Pm Interval
    Normal PDU Resouce Modify For EDA    ${UE_25}
    Wait For Next Full Pm Interval
    ${pm_counter_file}      Get Latest Unpacked Full Pm Counters File
    Set Test Variable       ${pm_counter_file}
    Validate Counter For Normal Release
    [Teardown]    Run Keyword And Ignore Error          Common Tear Down For CB014583 RJIO

[1][1.0] CB014583_3_verify_new_counters_and_impacted_legacy_counters_when_QFIs_are_released_using_NGAP_UE_Context_Release_Command_RJIO
    [Tags]     QC_243564  QCD_MN_RAN    QCP_RAN_VRF
    [Documentation]     The purpose of this test case is to verify CB014583 new counters and impacted legacy counters.
    ...                 (QoS flows are released using NGAP: UE Context Release Command)
    [Setup]    Prepare For CB014583 RJIO
    Log To Console      Start Emil Log
    slog.Start Syslog   ${Log_Path}     SysLogCapRJIO.LOG
    Pass Lua File For Attach
    wtsrunner.UE Disp
    Pass Lua File For 5QI
    wtsrunner.UE Disp
    Sleep   60s
    Wait For Next Full Pm Interval
    All UE NG Context Release For CB014583 5GC
    All UE NG Context Release For CB014583 NGRAN
    All UE NG Context Release For CB014583 CN
    All UE NG Context Release For CB014583 UE Lost
    Wait For Next Full Pm Interval
    ${pm_counter_file}      Get Latest Unpacked Full Pm Counters File
    Set Test Variable       ${pm_counter_file}
    5GC PM Counters Release          ${pm_counter_file}    ${CELL1}
    NGRAN PM Counters Release        ${pm_counter_file}     ${CELL2}
    CN PM Counters Release           ${pm_counter_file}     ${CELL3}
    5GC PM Counters Release          ${pm_counter_file}    ${CELL4}
    NGRAN PM Counters Release        ${pm_counter_file}     ${CELL5}
    CN PM Counters Release           ${pm_counter_file}     ${CELL6}
    Special Counters For CB014583 Release     ${pm_counter_file}
    FOR     ${ueid}     IN    @{UE_RJIO}
        UE Deregister Should Be Successful For SA       ${ueid}
        Log   De-Registered UE ${ueid}
    END
    Sleep    5s
    LOG TO CONSOLE    \n Starting case for EDA...
    UE Register Should Be Successful For SA    ${UE_25}
    trf_data_start    ue=${UE_25}    pdu=1    qfi=1    trf_id=1    mbps=10    dir=dl
    trf_data_start    ue=${UE_25}    pdu=1    qfi=1    trf_id=2    mbps=5    dir=ul
    Modify PDU Session For UE To Add    ${UE_25}
    trf_data_start    ue=${UE_25}    pdu=1    qfi=2   dir=dl  kbps=900    protocol=tcp  seconds=3600
    trf_data_start    ue=${UE_25}    pdu=1    qfi=2   dir=ul  kbps=900    protocol=tcp  seconds=3600
    Modify PDU Session For UE To Add    ${UE_25}     ${QFI3}
    trf_data_start    ue=${UE_25}    pdu=1    qfi=3    dir=dl    rtp_codec=g711m    seconds=3600
    Sleep    2s
    trf_data_start    ue=${UE_25}    pdu=1    qfi=3    dir=ul    rtp_codec=g711m    seconds=3600
    Sleep    2s
    trf_data_start    ue=${UE_25}    pdu=1    qfi=3    dir=dl    kbps=300    protocol=udp    seconds=3600
	Sleep    2s
	trf_data_start    ue=${UE_25}    pdu=1    qfi=3    dir=ul    kbps=300    protocol=udp    seconds=3600
    Wait For Next Full Pm Interval
    ue_ng_ctx_release    id=${UE_25}   by=amf    cause=NAS_normal_release
    Wait For Next Full Pm Interval
    ${pm_counter_file}      Get Latest Unpacked Full Pm Counters File
    Set Test Variable       ${pm_counter_file}
    Validate Counter For Normal Release
    [Teardown]    Run Keyword And Ignore Error          Common Tear Down For CB014583 RJIO


*** Keywords ***
Normal PDU Release for EDA
    [Documentation]    normal pdu release
    [Arguments]    ${UE}
    amf_ue_pdu_release_param    id=1    ue=${UE}    cause=NAS_normal_release
    ue_pdu_session_release      ue=${UE}    pdu=1    by=amf

Normal PDU Resouce Modify For EDA
    [Documentation]    PDU resource modification
    [Arguments]    ${UE}
    amf_ue_pdu_modify_param    id=1    ue=${UE}    action=override_ie qos_flow_to_del_cause=NAS_normal_release
    ue_pdu_session_modify    ue=1    pdu=1    qosflows_to_del=2    by=amf