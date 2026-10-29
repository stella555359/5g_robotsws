*** Settings ***
Documentation
...    author: 'VRF Ulm Team #4'
...    Team: 'MN RAN RD VRF ULM 4'
...    Email: 'OU_MN_RAN_RD_VRF_ULM_4_53245007@internal.nsn.com'
...    Description: Test Suite for CB008806-USC4(B30+B31),5(B32),6(B33)

Resource          CB008806-B_Keywords.robot

Suite Setup       Prepare TL for CB008806-B
Suite Teardown    Sqd65 Common Teardown

Test Setup        Perform Precondition of Test Scenario
Test Teardown     Perform Postconditions of Test Scenario


*** Test Cases ***

[1]CB008806_B_B30_B31_Activation_of_cell_trace_content_on_target_gNB
   [Documentation]  CP-UE sends Cell Trace and PCMD tracing messages to Trace Controller Master Services (LOM)
   ...              LOM collects and forwards these messages to TCE (external tool: UTE ta_pcmd running on test pc)
   [Tags]  B30  B31
   Perform NG Handover
   Sleep   10s       reason=CB008411 CT/PCMD records bundling
   Verify Cell Trace NG Handover
   Verify PCMD Trace NG Handover

[1]CB008806_B_B32_No_cell_trace_content_on_target_gNB_in_case_of_actIntraNrNgHo_disabled
   [Documentation]  In addtion to B30/31 celll trace for Handover Failure needs to be verified
   ...              by feat flag deactivation
   [Tags]  B32
   Disable intra-NR NG based handover
   Perform NG Handover Failure
   Sleep   10s       reason=CB008411 CT/PCMD records bundling
   Verify Cell Trace NG Handover Failure
   Verify PCMD Trace NG Handover Failure

[1]CB008806_B_B33_Deactivation_of_cell_trace_content_on_target_gNB_via_actCellTraceReport
   [Documentation]  Disable cell tracing: actCellTraceReport
   ...              Perform test scenario of CB008806-B_B30_B31_Activation_of_cell_trace_content_on_target_gNB
   [Tags]  B33
   Enable NG Handover
   Disable Cell Tracing
   Perform NG Handover
   Sleep   10s       reason=CB008411 CT/PCMD records bundling
   Verify Empty Trace
