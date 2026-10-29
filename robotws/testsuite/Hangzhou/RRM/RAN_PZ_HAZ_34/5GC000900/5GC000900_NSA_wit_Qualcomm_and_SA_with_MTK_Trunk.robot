*** Settings ***
Documentation     author: Yuan Hongyan
...               contact: hongyan.1.yuan@nokia-sbell.com
...               Cases in 5GC000900 that requires one mixed cell and  two UE:
...               MTK UE for SA access, and Qualcomm UE for NSA access.
Suite Setup       Run Keywords    robot_common_operations.Common Suite Setup    AND    Setup The Suite
Suite Teardown    Run Keywords    robot_common_operations.Common Suite Teardown    AND   Teardown The Suite
Force Tags        RAN_5G  RAN_5G_TDD   RAN_5G_FDD   5G_RAN   5G_RAN_TDD   5G_RAN_FDD   STATE_SW_UPLOADED
...    PY36
...               SBTS00    SBTS22R2   CLOUD_5G_CLASSICAL_ANDROID_ASIBL_ABINB1_3xAHLOA_ENB   SG_01
Resource          Resources/5GC000900_Resources.robot

*** Test Cases ***

[1][1.0] 5GC000900_AA_05_Single_NSA_UE_And_Single_SA_UE_Attach_To_DualMode_Cell
    [Documentation]  Main test Steps:
    ...   1) Wait until Cell on air (NG + X2 all available)
    ...   2) NSA L3 Call with Huawei SigSpark
    ...   3) SA L3 call with Huawei SigSpark
    ...   4) Verifiy throughput
    [Tags]    CIT_20A    CRT_TRUNK    CIT_20B    CIT_21A    CIT_21B    CIT_22R1    CIT_22R2    CRT_22R3    CRT_22R4
    [Setup]    Run Keywords    robot_common_operations.Common Case Setup    allowed_faults_ids=7107,7305,7523    AND    TestCase.CommonStart
    [Teardown]    TestCase.CommonStop
    TC.5GC000900_AA_05_Single_NSA_UE_And_Single_SA_UE_Attach_To_DualMode_Cell

[1][1.0] 5GC000900_B_007_Cell_Reconfiguration_when_Access_Mode_Change_between_NSA_and_Mixed
    [Documentation]  Main test Steps:
    ...   1) NSA scf loded, check cell on air
    ...   2) Switch celldepmode from NSA to Both, and check on air.
    ...   3) SA L3 call with DL traffic using Huawei SigSpark
    ...   4) NSA L3 call with DL traffic using Huawei SigSpark
    ...   5) Switch celldepmode from Both to NSA, and check on air.
    ...   6) Previous NSA L3 call shouldn't be stopped.
    ...   7) Restart NSA L3 call with DL traffic
    [Tags]    CRT_20A    CRT_20B    CRT_21A
    [Setup]    Setup Case
    [Teardown]    Teardown My Case   recover_scf=no
    TC.5GC000900_B_007_Cell_Reconfiguration_when_Access_Mode_Change_between_NSA_and_Mixed


[1]5GC000900_B_005_Mixed_Mode_Cell_Setup_When_NSA_Succeed_but_SA_Fail
    [Documentation]  Main test Steps:
    ...   1) loded 900 B05 SCF, cell on air but SA cell Degraded
    ...   2) check fault 7103 SA cell activation fault 7100 failed raised
    ...   3) check NSA UE attach OK and start traffic
    ...   4) check SA UE attach fail
    [Tags]           CRT_TRUNK    CRT_21A    CRT_21B    CRT_22R1    CRT_22R2    CRT_22R4
    [Setup]  Run Keywords    robot_common_operations.Common Case Setup    allowed_faults_ids=7107,7305,7523    AND    Setup Case For B05
    [Teardown]  Run Keywords    TestCase.CommonStop
    [Timeout]
    TC.5GC000900_B_005_Mixed_Mode_Cell_Setup_When_NSA_Succeed_but_SA_Fail

*** Keywords ***
Lock Cell
    [Arguments]   ${cell_idx}=1    ${timeout}=300
    ${cell_info}=    selenium_coam.get_cell_info    cell_idx=${cell_idx}
    log    ${cell_info}and ${cell_info['Status']['Administrative state']}
    run keyword if    '${cell_info['Status']['Administrative state']}'=="Unlocked"    run keywords
    ...    selenium_coam.lock_cell    cell_idx=${cell_idx}    timeout=${timeout}
    ...    AND    Sleep  4min
    ${cell_info}=    selenium_coam.get_cell_info  cell_idx=${cell_idx}
    should be true    '${cell_info['Status']['Administrative state']}'=="Locked"

Change Cell Mode from SA to NSA
    COAM_WebEM.Login
    selenium_coam.set_parameter_value    dist_name=${MRBTS_ID}/${NRBTS_ID}/NRCELL-1    filter_param=Cell deployment type   new_value=NSA
    selenium_coam.set_parameter_value   dist_name=${MRBTS_ID}/${NRBTS_ID}/NRCELL-1  filter_param=Configured EPS tracking area code  new_value=0
    selenium_coam.delete_parameter    dist_name=${MRBTS_ID}/${NRBTS_ID}/NRCELL-1  filter_param=Tracking Area distinguished name
    COAM_WebEM.ValidateAndActiveParameters
    COAM_WebEM.Logout
    Check if Cell On Air

Change Cell Mode from NSA to SA
    COAM_WebEM.Login
    selenium_coam.set_parameter_value    dist_name=${MRBTS_ID}/${NRBTS_ID}/NRCELL-1    filter_param=Cell deployment type  new_value=SA
    selenium_coam.set_parameter_value    dist_name=${MRBTS_ID}/${NRBTS_ID}/NRCELL-1    filter_param=Tracking Area distinguished name
    ...    new_value=${MRBTS_ID}/${NRBTS_ID}/TRACKINGAREA-200
    selenium_coam.delete_parameter    dist_name=${MRBTS_ID}/${NRBTS_ID}/NRCELL-1  filter_param=Configured EPS tracking area code
    COAM_WebEM.ValidateAndActiveParameters
    COAM_WebEM.Logout
    Check if Cell On Air

Check if Traffic Stopped
    ${DL}    run keyword and return status    Get DLTP Percent
    ${UL}    run keyword and return status    Get ULTP Percent
    should not be true    ${DL}
    should not be true    ${UL}

Check if UE released
    [Documentation]  check if  UeContextReleaseComplete is in CRRT log.
    [Arguments]    ${pattern}=UeContextReleaseComplete
    gNB.Connect
    gNB.Check info in log or zipped log    logname=/tmp/node_0xe005/tmp/startup_cp_rt.log
    ...    ziplogname=/ffs/run/logs/0xe005_aasyslog/startup_cp_rt.log.xz
    ...    pattern=${pattern}    connection=${ALIAS_ASIK_SLAVE}
    gNB.Disconnect




