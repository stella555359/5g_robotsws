*** Settings ***
Documentation
...   author: Qin Zhixia
...   contact: zhixia.qin@nokia-sbell.com
...   this is a robot case about CB007858

Resource          ../../Resources/Classical/RRM_Common_Resource.robot
Resource          ../../T01/Resources/RRM2_RRM_Resource.robot


Force Tags        CRT
...               RAN_PZ_HAZ_1
...               RAN_PZ_HAZ1_SG02_ST_RRM
...               TA_LEVEL_22
...               RAN_5G
...               4G_ASIL_AKNB_ENB
...               STATE_SW_UPLOADED
...               SBTS00

Suite Setup       Common Suite Setup For RRM
Suite Teardown    Common Suite Teardown For RRM
Test Setup        Common Test Setup For RRM
#Test Teardown     Common Test Teardown For RRM
Test Teardown    Common Test Case Teardown with Scout    ${TESTLINE_NAME}
Test Timeout      60minutes
*** Variables ***
${SYNC_NAME_1}             MRBTS-283/MNL-1/MNLENT-1/SYNC-1
${TESTLINE_NAME}     10_5_UTESRAN001T283
*** Test Cases ***

[1][1.0] CB007858_RRM_05_Peak_throughput_with_SSF5_DL_256QAM_UL_64QAM_Modulation_BW20MHz
    [Tags]    QC_558112       QCD_MN_RAN      QCP_RAN_ST

     log to console    start to active SCF
     ${scf_file}  Set Variable   CB007858_case5
     Commissioning scf and wait on air   ${scf_file}
     Make call with DL Then Check Peak TP

#      [Teardown]    case teardown

[1][1.0] CB007858_RRM_01_Different_frame_structeres_configuraiton_with_eNB_timing_shifter_and_sfn_offset
    [Tags]    QC_558110       QCD_MN_RAN      QCP_RAN_ST

     log to console    start to Modify parameter manualFrameTimingAdjustment
     Modify manualFrameTimingAdjustment to 9900
     Make call with DLandUL Then Check TP

     Modify frameStartOffset to 9999
     Make call with DLandUL Then Check TP

     log to console    start to Modify parameter tddFrameConf
     Modify tddFrameConf to 1
     Make call with DLandUL Then Check TP

#      [Teardown]    case teardown

[1][1.0] CB007858_RRM_10_DL_UL_2CC_10MHZ_SU_DL_256QAM_UL_64QAM
    [Tags]    QC_558111       QCD_MN_RAN      QCP_RAN_ST

     log to console    start to active SCF
     ${scf_file}  Set Variable   CB007858_case10
     Commissioning scf and wait on air   ${scf_file}
     Make call with DLandUL Then Check TP
     Check Counter For CB007858 Case 10

#	 [Teardown]    case teardown

[1][1.0] CB010279_RRM_01_8T8R_DL_CA_3CC_UL_CA_2CC_Different_frame_structeres_configuraiton_with_eNB_timing_shifter_and_sfn_offset
    [Tags]    QC_558120       QCD_MN_RAN      QCP_RAN_ST

      log to console    start to active SCF
      ${scf_file}  Set Variable   CB010279_case1
      Commissioning scf and wait on air   ${scf_file}
      Make call with DLandUL Then Check TP
      Check Counter For CB010279

[1][1.0] CB010279_RRM_02_8T8R_DLCA_4CC_TM3_MRC_DL_256QAM_UL_64QAM
    [Tags]    QC_558119       QCD_MN_RAN      QCP_RAN_ST

      log to console    start to active SCF
      ${scf_file}  Set Variable   CB010279_case2
      Commissioning scf and wait on air   ${scf_file}
      Make call with DLandUL Then Check TP
      Check Counter For CB010279

*** Keywords ***
Coam gNB Online Modify multi By Rest
    [Arguments]    ${delta_file}
    [Documentation]    Author: gcao
    ...                Contact: ge.cao@nokia-sbell.com
    ...                The kw is used to online delete mo by rest.
    ...    | Input Parameters | Man. | Description |
    ...    | ${delta_file} | Yes |  Delta JSON or path to JSON file. |
    ...    | Return Value | Description |
    ...    | No | NA |
    ...
    ...    Example                                          | ${value}
    ...    | coam.perform_delta_recommissioning | ${delta_file}=/home/ute/a.json |
    coam.setup_admin    alias=update_mo
    ${res}=    coam.perform_delta_recommissioning    delta_file=${delta_file}
    ...                                              should_activate=${true}
    ...                                              timeout=${600}
    ...                                              connection=update_mo
    [Teardown]    coam.teardown    connection=update_mo

Commissioning scf and wait on air
   [Arguments]         ${scf_file}
   Commissioning SCF And Check On Air    ${scf_file}
   wait until keyword succeeds    10 min    30 sec    Verify LTE cells should be onair

Stop call
    run keyword and ignore error  ute_ue.Detach Ue  UE_0


Make call with DL Then Check Peak TP
    log to console    start make DL call
    run keyword and ignore error    ute_ue.Require UE    UE_0    capabilities=Qualcomm
    ute_ue.Attach UE    UE_0
    ute_ue.Log Ue Info    UE_0
    ute_ue.Start Data Transfer    DT_1    UE_0    DL
    ...  duration=70s    throughput=160Mbits/sec    protocol=udp    packet_size=1024B
    ute_ue.Await Data Transfer Finish    DT_1
    log to console    get average throughput
    ute_ue.get average throughput    DT_1    omit=30    end=60
    ute_ue.Detach Ue  UE_0
    ute_ue.verify average throughput    DT_1    90Mbits/sec

Make call with DLandUL Then Check TP
    run keyword and ignore error   ute_ue.Require UE    UE_0    capabilities=Qualcomm
    ute_ue.Attach UE    UE_0
    ute_ue.Log Ue Info    UE_0
    ute_ue.Start Data Transfer    DT_1    UE_0    DL
    ...   duration=60s    throughput=200Mbits/sec    protocol=udp    packet_size=1024B
    ute_ue.Start Data Transfer    DT_2    UE_0    UL
    ...   duration=60s    throughput=20Mbits/sec    protocol=udp    packet_size=1024B
    ute_ue.Await Data Transfer Finish    DT_1
    ute_ue.Await Data Transfer Finish    DT_2
    ute_ue.get average throughput    DT_1
    ute_ue.get average throughput    DT_2
    ute_ue.Detach Ue  UE_0
    ute_ue.verify average throughput    DT_1    1Mbits/sec
    ute_ue.verify average throughput    DT_2    1Mbits/sec

Check Counter For CB007858 Case 10
    Log to console    check counter
    Sleep    900s
    ${pi_list}=  Create List    M8011C222    M8011C223     M8011C224    M8011C225
    ${expect_value}    Set Variable    10000
    FOR  ${counter_ID}  IN  @{pi_list}
           ${counter_id_value_list}    Check counter value   counter_ID=${counter_ID}
           ...                                               expect_value=${expect_value}
    END

Check Counter For CB010279
    Log to console    check counter
    Sleep    900s
    ${pi_list}=  Create List    M8011C222    M8011C224
    ${expect_value}    Set Variable    10000
    FOR  ${counter_ID}  IN  @{pi_list}
           ${counter_id_value_list}    Check counter value   counter_ID=${counter_ID}
           ...                                               expect_value=${expect_value}
    END

Modify manualFrameTimingAdjustment to 9900
    COAM_Admin.set parameter value    dist_name=${SYNC_NAME_1}
      ...                               parameter=manualFrameTimingAdjustment
      ...                               new_value=99000000

    wait until keyword succeeds    10 min    30 sec    Verify LTE cells should be onair
Modify tddFrameConf to 1
     ${file_path}    set variable    ${CURDIR}/tddFrameConf.json
     Coam gNB Online Modify multi By Rest    delta_file=${file_path}
     wait until keyword succeeds    10 min    30 sec    Verify LTE cells should be onair

Modify frameStartOffset to 9999
     ${file_path}    set variable    ${CURDIR}/frameStartOffset.json
     Coam gNB Online Modify multi By Rest    delta_file=${file_path}
     wait until keyword succeeds    10 min    30 sec    Verify LTE cells should be onair

Case Teardown
    Common Test Teardown For RRM
    Run Keyword And Ignore Error    Stop call

