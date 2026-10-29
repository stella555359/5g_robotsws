*** Settings ***
Force Tags    CLOUD_5G_I_LOO_AP_LOOO
...           RAN_5G_TDD_FDD   RAN_5G     CONFIGURED

Documentation       The purpose of this test case is to verify CB014583 new counters and impacted legacy counters.
...                 (QoS flows are released using NGAP: PDU Session Resource Release Request,
...                 PDU Session Resource Modify Request, UE Context Release Command) for TMO

...                 :author   :   Vikash Kumar
...                 :contact  :   vikash.20.kumar@nokia.com
...                 :Feature  :   CB014583

Resource          resources/Keywords/CB014583_keywords.robot

Suite Setup       Updated Suite Setup
Suite Teardown    Common Suite Teardown


*** Variables ***
${TOPOLOGY}             CLOUD_5G_I_LOO_AP_LOOO
${DL_RT}                10
${UL_RT}                5
${CELL1}                1
${CELL2}                2
${CELL3}                3
${CELL4}                4
${CELL7}                7
${CELL8}                8
${CELL10}               10
${CELL11}               11
${UL_PAT_48}            UE48: UDP UL TRF
@{UE_TMO}         1      2       3      4        5         6        7        8
...               21     22      23     24       25        26       27       28
...               31     32      33     34       35        36       37       38
...               41     42      43     44       45        46       47       48
${ATTACHE_UES}             ${AP_CONFIG_BASIC}/Attach_UE_TMO.lua
${5QI_ULDL_TRAFFIC}        ${AP_CONFIG_BASIC}/Traffic_Diff_5qi_CB014583_TMO.lua


*** Test Cases ***
[1][1.0] CB014583_4_verify_new_counters_and_impacted_legacy_counters_when_QFIs_are_released_using_NGAP_Pdu_Session_Resource_Release_Command_TMOUS
    [Tags]    QC_244239   QCD_MN_RAN    QCP_RAN_VRF
    [Documentation]     The purpose of this test case is to verify CB014583 new counters and impacted legacy counters.
    ...                 (QoS flows are released using NGAP: PDU Session Resource Release Command)
    [Setup]    Prepare For CB014583 TMO
    Sleep   30s
    slog.Start Syslog   ${Log_Path}     SysLogCapTMO4.LOG
    Pass Lua File For Attach    ${ATTACHE_UES}      ${UL_PAT_48}
    Sleep   30s
    Pass Lua File For 5QI       ${5QI_ULDL_TRAFFIC}
    Wait For Next Full Pm Interval
    All PDU Release For CB014583 5GC TMO
    All PDU Release For CB014583 NGRAN TMO
    All PDU Release For CB014583 CN TMO
    All PDU Release For CB014583 UE Lost TMO
    Wait For Next Full Pm Interval
    ${pm_counter_file}      Get Latest Unpacked Full Pm Counters File
    Set Test Variable       ${pm_counter_file}
    5GC PM Counters UE Release TMO      ${pm_counter_file}      ${CELL1}
    NGRAN PM Counters UE Release TMO    ${pm_counter_file}      ${CELL2}
    CN PM Counters UE Release TMO       ${pm_counter_file}      ${CELL3}
    5GC PM Counters UE Release TMO      ${pm_counter_file}      ${CELL7}
    NGRAN PM Counters UE Release TMO    ${pm_counter_file}      ${CELL8}
    CN PM Counters UE Release TMO       ${pm_counter_file}      ${CELL10}
    Special Counters For CB014583 Release For TMO       ${pm_counter_file}
    FOR     ${ueid}     IN    @{UE_TMO}
        UE Deregister Should Be Successful For SA       ${ueid}
        Log   De-Registered UE ${ueid}
    END
    [Teardown]      Run Keyword And Ignore Error        Common Tear Down For CB014583 TMO

[1][1.0] CB014583_5_verify_new_counters_and_impacted_legacy_counters_when_QFIs_are_released_using_NGAP_PDU_Session_Resource_Modify_Request_TMOUS
    [Tags]    QC_NEW   QCD_MN_RAN    QCP_RAN_VRF
    [Documentation]     The purpose of this test case is to verify CB014583 new counters and impacted legacy counters.
    ...                 (QoS flows are released using NGAP: PDU Session Resource Release Command)
    [Setup]    Prepare For CB014583 TMO
    Sleep   30s
    slog.Start Syslog   ${Log_Path}     SysLogCapTMO5.LOG
    Pass Lua File For Attach    ${ATTACHE_UES}      ${UL_PAT_48}
    Sleep   30s
    Pass Lua File For 5QI       ${5QI_ULDL_TRAFFIC}
    Wait For Next Full Pm Interval
    All PDU Modify For CB014583 5GC TMO
	All PDU Modify For CB014583 NGRAN TMO
	All PDU Modify For CB014583 UE LOST TMO
	All PDU Modify For CB014583 CN TMO
    Wait For Next Full Pm Interval
    ${pm_counter_file}      Get Latest Unpacked Full Pm Counters File
    Set Test Variable       ${pm_counter_file}
    5GC PM Counters TMO         ${pm_counter_file}      ${CELL1}
    NGRAN PM Counters TMO       ${pm_counter_file}      ${CELL2}
    CN PM Counters TMO          ${pm_counter_file}      ${CELL3}
    5GC PM Counters TMO         ${pm_counter_file}      ${CELL7}
    NGRAN PM Counters TMO       ${pm_counter_file}      ${CELL8}
    CN PM Counters TMO          ${pm_counter_file}      ${CELL10}
    Special Counters For CB014583 TMO       ${pm_counter_file}
    FOR     ${ueid}     IN    @{UE_TMO}
        UE Deregister Should Be Successful For SA       ${ueid}
        Log   De-Registered UE ${ueid}
    END
    [Teardown]      Run Keyword And Ignore Error        Common Tear Down For CB014583 TMO

[1][1.0] CB014583_6_verify_new_counters_and_impacted_legacy_counters_when_QFIs_are_released_using_NGAP_UE_Context_Release_Command_TMOUS
    [Tags]    QC_244699   QCD_MN_RAN    QCP_RAN_VRF
    [Documentation]     The purpose of this test case is to verify CB014583 new counters and impacted legacy counters.
    ...                 (QoS flows are released using NGAP: PDU Session Resource Release Command)
    [Setup]    Prepare For CB014583 TMO
    Sleep   30s
    slog.Start Syslog   ${Log_Path}     SysLogCapTMO6.LOG
    Pass Lua File For Attach    ${ATTACHE_UES}      ${UL_PAT_48}
    Sleep   30s
    Pass Lua File For 5QI       ${5QI_ULDL_TRAFFIC}
    Wait For Next Full Pm Interval
    All UE NG Context Release For CB014583 5GC For TMO
    All UE NG Context Release For CB014583 NGRAN For TMO
    All UE NG Context Release For CB014583 CN For TMO
    All UE NG Context Release For CB014583 UE Lost For TMO
    Wait For Next Full Pm Interval
    ${pm_counter_file}      Get Latest Unpacked Full Pm Counters File
    Set Test Variable       ${pm_counter_file}
    5GC PM Counters UE Release TMO      ${pm_counter_file}      ${CELL1}
    NGRAN PM Counters UE Release TMO    ${pm_counter_file}      ${CELL2}
    CN PM Counters UE Release TMO       ${pm_counter_file}      ${CELL3}
    5GC PM Counters UE Release TMO      ${pm_counter_file}      ${CELL7}
    NGRAN PM Counters UE Release TMO    ${pm_counter_file}      ${CELL8}
    CN PM Counters UE Release TMO       ${pm_counter_file}      ${CELL10}
    Special Counters For CB014583 Release For TMO       ${pm_counter_file}
    FOR     ${ueid}     IN    @{UE_TMO}
        UE Deregister Should Be Successful For SA       ${ueid}
        Log   De-Registered UE ${ueid}
    END
    [Teardown]      Run Keyword And Ignore Error        Common Tear Down For CB014583 TMO
