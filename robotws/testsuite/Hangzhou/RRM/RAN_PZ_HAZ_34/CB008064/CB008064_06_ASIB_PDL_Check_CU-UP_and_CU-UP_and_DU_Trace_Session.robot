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
#ERR_WRN_start
Resource          testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/ERR_WRN_Check.robot
#ERR_WRN_end
*** Variables ***
${testline_name}    7_5_UTE5G402T921
${scf_file_path}    ${commissionings_path}/HGZ/${testline_name}
${Test_PC_IP}             ${tl.test_pc[0].default_ssh_connection_details.addr}
${Test_PC_username}       ${tl.test_pc[0].default_ssh_connection_details.username}
${Test_PC_password}       ${tl.test_pc[0].default_ssh_connection_details.password}


*** Test Cases ***
[1]CB008064_06_ASIB_PDL_Check_CU-UP_and_CU-UP_and_DU_Trace_Session
    [Documentation]    *****************
    ...    The purpose of this test is to verify 5 trace sessions covering: PCMD Only, Cell Trace Only, and PCMD + Cell Trace.
    ...    Trace reports are sent by gNB-CU-CP with multiple MBA (Management Based Activation) trace sessions and each
    ...    session is configured with jobType TraceOnly. All traces are sent to same TCE (Trace Controller Entity).
    ...    *******************
    [Tags]    HAZ3_T03
    [Setup]    Precondition
    [Teardown]    Teardown
    Run Keyword And Ignore error   Start BTSlogs Collection In Log Server
    ...      Test_PC_IP=${Test_PC_IP}    Test_PC_username=${Test_PC_username}
    ...      Test_PC_password=${Test_PC_password}
    ...      btslog_path=/tmp/btslog2      btslog_launcher=/opt/btslog/btslog_launcher
    ...      btslog_launcher_path=/opt/btslog/btslog
    #Step1: Config Add MOs
    Step2: Capture Log & Make L3 Call
    Step3: Check Log
    Step4: Lock&Unlock and Twice Check
    Run Keyword And Ignore error       Stop BTSlogs Collection And Download Logs To Log Server
    Run Keyword And Continue On Failure     Check ERR Or WRN From Syslog
    ...      sys_logs_path=${UTE_syslogs_path}      Expected_ERR_WRN_number=10000   Expected_ERR_WRN_diff_number=0
    ...      Expected_ERR_WRN_deviation=0.1
    ...      base_file=${Base_ERR_WRN_csv_path}       UTE_logs_path=${UTE_logs_path}
    ...      check_diff=${True}


*** Keywords ***
Step1: Config Add MOs
    @{add_paras}     create list    ${add_nrctrlts}    ${add_tceadm}    ${add_nrctrltsdu}    ${add_nrctrltscuup}
    ...    ${add_tce1}    ${add_tce2}    ${add_tce3}
    ...    ${add_nrmtracecu1}    ${add_nrmtracecu2}    ${add_nrmtracecu3}    ${add_nrmtracecu4}    ${add_nrmtracecu5}
    ...    ${add_nrmtracedu1}    ${add_nrmtracedu2}    ${add_nrmtracedu3}    ${add_nrmtracedu4}    ${add_nrmtracedu5}
    ...    ${add_nrmtracecuup1}    ${add_nrmtracecuup2}    ${add_nrmtracecuup3}    ${add_nrmtracecuup4}    ${add_nrmtracecuup5}
    FOR    ${add_para}    IN    @{add_paras}
        COAM Add ${add_para}
    END
    [Teardown]    admin_cli.teardown    connection=${connection}

Step2: Capture Log & Make L3 Call
    [Arguments]  ${twice_flag}=${false}
    log to console    Step2: Capture Log & Make L3 Call
    Start Wireshark Capture
    sleep    5s
    Make L3 Call    twice_flag=${twice_flag}
    Stop Wireshark Capture

Step3: Check Log
    log to console    Step3: Check Log
    ${CU_trace_list}     Create List    00:00:01    00:00:02    00:00:03    00:00:04    00:00:05
    ${DU_trace_list}     Create List    00:00:01    00:00:02    00:00:03    00:00:04    00:00:05
    ${CUUP_trace_list}     Create List    00:00:01    00:00:02    00:00:03    00:00:04    00:00:05
    Check TraceIds    trace_list=${CU_trace_list}
    Check TraceIds    trace_list=${DU_trace_list}    trace_type=Du
    Check TraceIds    trace_list=${CUUP_trace_list}    trace_type=CuUp

Step4: Lock&Unlock and Twice Check
    log to console    Step4: Lock&Unlock and Twice Check
    Lock&Unlock
#    Block&Unblock
    Step2: Capture Log & Make L3 Call    twice_flag=${true}
    Step3: Check Log
