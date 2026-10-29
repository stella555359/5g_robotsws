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
# [1]CB007538_03_PCMD_content_related_to_PHR_FR2
#     [Documentation]    *****************
#     ...  DU ChannelStateInfoReportTraceRecord, CaSCellChannelStateInfoReportTraceRecord, PowerHeadroomTraceRecord,
#     ...  CaSCellPowerHeadroomTraceRecord, BeamReportTraceRecord, BeamUsageTraceRecord
#     ...  CB007538_07_PCMD_and_trace_record_for_UE_call_type_FR2
#     ...    *******************
#     [Tags]
#     [Setup]    Precondition
#     [Teardown]    Teardown
# #    Step1: Config Add MOs
#     Step2: Capture Log & Make L3 Call
#     Step3: Check Log
#     Step4: Lock&Unlock and Twice Check
# 
# [1]CB007538_07_PCMD_and_trace_record_for_UE_call_type_FR2
#     [Documentation]    *****************
#     ...  gNB-CU CA Configuration Record - shall contain the new IE: ARFCN; support for SA shall be added.
#     ...  DU CA Configuration Record - shall contain the new IE: ARFCN, PRB bandwidth
#     ...    *******************
#     [Tags]
#     [Setup]    Run Keyword And Ignore Error    robot_common_operations.Common case setup
# 
#     [Teardown]    Teardown
# #    Step1: Config Add MOs
#     Step2: Capture Log & Make L3 Call
#     Check ueCallType
#     Lock&Unlock
#     Step2: Capture Log & Make L3 Call
#     Check ueCallType
# 
# 
# 
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
#     Check CB007538    group_name=csiReportRecord
#     Check CB007538    group_name=caSCellCsiReportRecord
#     Check CB007538    group_name=pwrHeadroomRecord
#     Check CB007538    group_name=beamReportRecord
#     Check CB007538    group_name=beamUsageRecord
#     Check CB007538    group_name=caSCellBeamUsageRecord
#     Check CB007538    group_name=ueCallType
# 
# Step4: Lock&Unlock and Twice Check
#     log to console    Step4: Lock&Unlock and Twice Check
#     Lock&Unlock
# #    Block&Unblock
#     Step2: Capture Log & Make L3 Call    twice_flag=${true}
#     Step3: Check Log
