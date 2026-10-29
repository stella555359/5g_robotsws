*** Settings ***
Documentation
...  author: menghua.luo
...  contact: menghua.luo@nokia-sbell.com

Resource   ../Resource/5GC000864_common.robot

Force Tags   SG_07   CA_5G_OAM    CIT   CIT_TRUNK   SBTS00   CIT_25R1   STATE_SW_UPLOADED
...    PY36  PY310
...      RAN_5G   RAN_5G_TDD   CRT_UTE   CLOUD_5G_CLASSICAL_ANDROID_ASIBL_ABILB1_AEQV_ENB   5G_RAN   5G_RAN_TDD

#Suite Setup        Cell Trace Suite Setup   PCMD_flag=true   case_path=${CURDIR}
Suite Setup        Cell Trace Suite Setup   PCMD_flag=true
Suite Teardown     Cell Trace Suite Teardown

Test Setup   Test Common Setup
Test Teardown   Test Common Teardown
Test Timeout   2h

*** Variables ***
${ENB_PATH}   MRBTS-${tl.enbs[0].instance_id}/LNBTS-${tl.enbs[0].global_bts_id}

*** Test Cases ***
[1]5GC000864_B_001_NSA_ClassicalgNB_Single_Trace_Session_Combining_Both_Cell_Trace_And_PCMD
    [Timeout]  1h
#    Check Session Setup
    Test Common Step   type=file_name
    Modify Parameter actCellTraceReport To False
    Modify Parameter actPCMDReport To False
    Validate and Activate Plan
#    Check Session Setup    setup=${false}

[1]5GC000864_B_002_NSA_ClassicalgNB_Single_Trace_Session_Combining_Both_Cell_Trace_And_PCMD_Deactivation_PCMD
    [Timeout]  1h
    ${emil_last_file}   Get Latest Trace File Name
    Modify Parameter actCellTraceReport To True
    Modify Parameter actPCMDReport To True
    Validate and Activate Plan
 #   Check Session Setup
    Test Common Step   type=file_name   emil_last_file=${emil_last_file}
    Modify Parameter actPCMDReport To False
    Validate and Activate Plan
#    Check Session Setup    setup=${false}

[1]5GC000864_B_003_NSA_ClassicalgNB_Single_Trace_Session_Combining_Both_Cell_Trace_And_PCMD_Deactivation_Cell_Trace
    [Timeout]  1h
    Modify Parameter actCellTraceReport To True
    Modify Parameter actPCMDReport To True
    Validate and Activate Plan
#    Check Session Setup
    Modify Parameter actCellTraceReport To False
    Validate and Activate Plan
#    Check Session Setup    setup=${false}
    Add Cell Trace DU Object   du_actPCMDReporting=true   du_typeNrDu=none
    ${emil_last_file}   Get Latest Trace File Name
    Modify Parameter actCellTraceReport To True
    Validate and Activate Plan
#    Check Session Setup
    Test Common Step   type=file_name   emil_last_file=${emil_last_file}

[1]5GC000864_B_007_NSA_ClassicalgNB_Single_Trace_Session_Combining_Both_Cell_Trace_And_PCMD_Active_Cell_Trace_Firstly
    [Timeout]  1h
    Commission Cell Trace CU and PCMD CU Flags
    Add Cell Trace DU Object   du_actPCMDReporting=true   du_typeNrDu=none
    Modify Parameter actCellTraceReport To True
    Modify Parameter actPCMDReport To True
    Validate and Activate Plan
 #   Check Session Setup
    Test Common Step   type=file_name