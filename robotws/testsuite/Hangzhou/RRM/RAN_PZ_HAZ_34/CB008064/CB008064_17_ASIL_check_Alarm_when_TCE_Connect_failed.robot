*** Settings ***

Documentation
...   author: y6lu
...   contact: lu.yu@nokia-sbell.com
...   squad group: MMW_SG3
...   Feature CB008064 in 5G23R4 program

Force Tags    CRT_TRUNK    CRT_23R4
...   PY36

Suite Setup    robot_common_operations.Common Suite Setup
Suite Teardown    Run Keyword     robot_common_operations.Common Suite Teardown
Test Timeout

Resource    Resources/CB008064_keyword.robot

*** Variables ***
${testline_name}    7_5_UTE5G402T921
${scf_file_path}    ${commissionings_path}/HGZ/${testline_name}
${UE_TYPE}    askey

*** Test Cases ***
[1]CB008064_17_ASIL_check_Alarm_when_TCE_Connect_failed
    [Documentation]    *****************
    ...    The purpose of this test is to verify 5 trace sessions covering: PCMD Only, Cell Trace Only, and PCMD + Cell Trace.
    ...    Trace reports are sent by gNB-CU-CP with multiple MBA (Management Based Activation) trace sessions and each
    ...    session is configured with jobType TraceOnly. All traces are sent to same TCE (Trace Controller Entity).
    ...    *******************
    [Tags]    HAZ3_T03
    [Setup]    Precondition
    [Teardown]    Teardown
    #Step1: Config Add MOs & check
    Step2: Capture Log & Make L3 Call
    Step3: Check Log


*** Keywords ***
Step1: Config Add MOs & check
    Precondition

Step2: Capture Log & Make L3 Call
    Start Wireshark Capture
    Make L3 Call      UE_TYPE=${UE_TYPE}
    Stop Wireshark Capture

Step3: Check Log
    ${CU_trace_list}     Create List    00:00:01    00:00:02    00:00:03    00:00:04    00:00:05
    #${DU_trace_list}     Create List    00:00:01    00:00:02    00:00:03    00:00:04    00:00:05
    Check TraceIds    trace_list=${CU_trace_list}
    #Check TraceIds    trace_list=${DU_trace_list}    trace_type=Du
