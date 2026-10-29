# *** Settings ***
# 
# Documentation
# ...   author: hongyfu
# ...   contact: hongye.fu@nokia-sbell.com
# ...   squad group: MMW_SG3
# ...   Feature CB008911 in 5G24R1 program
# 
# Force Tags    CRT_TRUNK    CRT_24R1
# ...   PY36
# 
# Suite Setup    robot_common_operations.Common Suite Setup
# Suite Teardown    robot_common_operations.Common Suite Teardown
# Test Timeout
# 
# Resource    Resources/CB008911_keyword.robot
# 
# *** Variables ***
# 
# *** Test Cases ***
# [1]CB008911_01_PCMD_records_from_gNB-DU_during_SCell_addition_in_case_of_SgNB_Addition_TDD_FR2_NSA
#     [Documentation]    *****************
#     ...  gNB-CU CA Configuration Record - shall contain the new IE: ARFCN; support for SA shall be added.
#     ...  DU CA Configuration Record - shall contain the new IE: ARFCN, PRB bandwidth
#     ...    *******************
#     [Tags]
#     [Setup]    Precondition
#     [Teardown]    Teardown
# #    Step1: Config Add MOs
#     Step2: Capture Log & Make L3 Call
#     Step3: Check Log
#     Step4: Lock&Unlock and Twice Check
# 
# 
# *** Keywords ***
# Step1: Config Add MOs
#     @{add_paras}     create list    ${add_nrctrlts}    ${add_tceadm}    ${add_nrctrltsdu}    ${add_nrctrltscuup}
#     ...    ${add_tce1}    ${add_tce2}    ${add_tce3}
#     ...    ${add_nrmtracecu1}    ${add_nrmtracecu2}    ${add_nrmtracecu3}    ${add_nrmtracecu4}    ${add_nrmtracecu5}
#     ...    ${add_nrmtracedu1}    ${add_nrmtracedu2}    ${add_nrmtracedu3}    ${add_nrmtracedu4}    ${add_nrmtracedu5}
#     ...    ${add_nrmtracecuup1}    ${add_nrmtracecuup2}    ${add_nrmtracecuup3}    ${add_nrmtracecuup4}    ${add_nrmtracecuup5}
#     FOR    ${add_para}    IN    @{add_paras}
#         COAM Add ${add_para}
#     END
#     [Teardown]    admin_cli.teardown    connection=${connection}
# 
# Step2: Capture Log & Make L3 Call
#     [Arguments]  ${twice_flag}=${false}
#     log to console    Step2: Capture Log & Make L3 Call
#     Start Wireshark Capture
#     sleep    5s
#     Make L3 Call    twice_flag=${twice_flag}
#     Stop Wireshark Capture
# 
# Step3: Check Log
#     log to console    Step3: Check Log
# #    ${CU_trace_list}     Create List    00:00:01    00:00:02    00:00:03    00:00:04    00:00:05
# #    ${DU_trace_list}     Create List    00:00:01    00:00:02    00:00:03    00:00:04    00:00:05
# #    ${CUUP_trace_list}     Create List    00:00:01    00:00:02    00:00:03    00:00:04    00:00:05
# #    Check TraceIds    trace_list=${CU_trace_list}
# #    Check TraceIds    trace_list=${DU_trace_list}    trace_type=Du
# #    Check TraceIds    trace_list=${CUUP_trace_list}    trace_type=CuUp
#     Check SetupSCells   trace_type=Du
#     Check SetupSCells   trace_type=Cu
# 
# Step4: Lock&Unlock and Twice Check
#     log to console    Step4: Lock&Unlock and Twice Check
#     Lock&Unlock
# #    Block&Unblock
#     Step2: Capture Log & Make L3 Call    twice_flag=${true}
#     Step3: Check Log
