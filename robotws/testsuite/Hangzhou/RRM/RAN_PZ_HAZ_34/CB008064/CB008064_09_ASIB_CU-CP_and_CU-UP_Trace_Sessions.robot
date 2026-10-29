# *** Settings ***
# 
# Documentation
# ...   author: y6lu
# ...   contact: lu.yu@nokia-sbell.com
# ...   squad group: MMW_SG3
# ...   Feature CB008064 in 5G23R4 program
# 
# Force Tags    CRT_TRUNK    CRT_23R4
# ...   PY36
# 
# Suite Setup    robot_common_operations.Common Suite Setup
# Suite Teardown    robot_common_operations.Common Suite Teardown
# Test Timeout
# 
# Resource    Resources/CB008064_keyword.robot
# 
# *** Variables ***
# 
# *** Test Cases ***
# [1]CB008064_09_ASIB_CU-CP_and_CU-UP_Trace_Sessions
#     [Documentation]    *****************
#     ...    The purpose of this test is to verify 5 trace sessions covering: PCMD Only, Cell Trace Only, and PCMD + Cell Trace.
#     ...    Trace reports are sent by gNB-CU-CP with multiple MBA (Management Based Activation) trace sessions and each
#     ...    session is configured with jobType TraceOnly. All traces are sent to same TCE (Trace Controller Entity).
#     ...    *******************
#     [Tags]
#     [Setup]    Precondition
#     [Teardown]    Teardown
#     Step1: Config Add MOs
#     Step2: Capture Log & Make L3 Call
#     Step3: Check Log
# 
# 
# *** Keywords ***
# Step1: Config Add MOs
#     @{add_paras}     create list    ${add_nrctrlts}    ${add_tceadm}    ${add_nrctrltsdu}    ${add_nrctrltscuup}
# 	...    ${add_tce1}    ${add_tce2}    ${add_tce3}
#     ...    ${add_nrmtracecu1}    ${add_nrmtracecu2}    ${add_nrmtracecu3}    ${add_nrmtracecu4}    ${add_nrmtracecu5}
#     #...    ${add_nrmtracedu1}    ${add_nrmtracedu2}    ${add_nrmtracedu3}    ${add_nrmtracedu4}    ${add_nrmtracedu5}
#     ...    ${add_nrmtracecuup1}    ${add_nrmtracecuup2}    ${add_nrmtracecuup3}    ${add_nrmtracecuup4}    ${add_nrmtracecuup5}
#     #...    ${add_subscriber_trace}
#     FOR    ${add_para}    IN    @{add_paras}
#         COAM Add ${add_para}
#     END
# 
# Step2: Capture Log & Make L3 Call
#     Start Wireshark Capture
#     Make L3 Call
#     Stop Wireshark Capture
# 
# Step3: Check Log
#     ${CU_trace_list}     Create List    00:00:01    00:00:02    00:00:03    00:00:04    00:00:05
#     ${CUUP_trace_list}     Create List    00:00:01    00:00:02    00:00:03    00:00:04    00:00:05
#     #${DU_trace_list}     Create List    00:00:01    00:00:02    00:00:03    00:00:04    00:00:05
#     Check TraceIds    trace_list=${CU_trace_list}
#     Check TraceIds    trace_list=${CUUP_trace_list}    trace_type=CuUp
#     #Check TraceIds    trace_list=${DU_trace_list}    trace_type=Du
