*** Settings ***
Documentation    Suite description
...   Author:      Geng Lishuo
...   Contact:     lishuo.geng@nokia-sbell.com
...   Squad Group: MMW_SG7
...   Feature:     CB013961
Suite Setup    Suite Setup For Aic BTS Env
Suite Teardown    Common Suite Teardown And Restore BTS Configuration Parameters Aic
Test Setup    Common Test Setup And Start To Capture Logs Aic
Test Teardown    Common Test Teardown And Stop Capture Logs Aic
Force Tags    5G_RAN    5G_RAN_TDD    RAN_5G_TDD    RAN_5G
Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/lines/MMW_SG7/Cloud_VRAN40/vDU.robot
Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/lines/MMW_SG8/resources_aic/DevHZ5_resource_aic_ST.robot
Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/lines/MMW_SG8/resources_aic/ST_robot_aic/DevHZ5_spark_ue.robot

*** Variables ***
${DEBUG}    True
${SNAPSHOT_FLAG}     pass:False,fail:False
${RESOURCES_LEAKAGE_FLAG}    ${False}
${TTITRACE_FLAG_DU1}    False
@{FAULTS_EXCLUDED_CHECKING}    7311

*** Test Cases ***
CB013961_A_B04_09_CR_response_grant_management_for_Ue_with_VoNR_1116_frame_structure
    [Tags]    TC09
    Adjust PA for Serving Cell
    Config 1116 Frame Structure and feature 13961 and feature 9189 For case9
    Cell22 block
    prepare and attach UE
    start UL traffic    ue_id=1    send_traffic=40K    interval_time=0.2    # buffer_size_Byte=1050B
    Set Test Variable    ${TTITRACE_FLAG_DU1}    True
    Capature TTI Trace for Cell21 On DU1    tti_tag=1_attach
    Make VONR call
    Capature TTI Trace for Cell21 On DU1    tti_tag=2_add_vonr
    Hang Up VONR call
    Capature TTI Trace for Cell21 On DU1    tti_tag=3_delete_vonr
    Set Test Variable    ${TTITRACE_FLAG_DU1}    False
    [Teardown]    Run Keywords    Stop UL traffic
    ...                           Detach UE
    ...                           All Cells Unlock
    ...                           Common Test Teardown And Stop Capture Logs Aic

CB013961_A_B03_07_CR_response_grant_management_for_Ue_with_dynamic_GBR_add_remove_1070_frame_structure
    [Tags]    TC07
    Adjust PA for Serving Cell
    Wait Until Keyword Succeeds    3 x    10 min    Config 1070 Frame Structure and feature 13961 and feature 9189 For case7
    Cell22 block
    prepare and attach UE
    start UL traffic    ue_id=1    send_traffic=40K    interval_time=0.2    # buffer_size_Byte=1050B
    Set Test Variable    ${TTITRACE_FLAG_DU1}    True
    Capature TTI Trace for Cell21 On DU1    tti_tag=1_attach
    Aic ST Add 5QI Bearer    5qi=3
    Capature TTI Trace for Cell21 On DU1    tti_tag=2_add_gbr
    Aic ST Delete 5QI Bearer    5qi=3
    Capature TTI Trace for Cell21 On DU1    tti_tag=3_delete_gbr
    Set Test Variable    ${TTITRACE_FLAG_DU1}    False
    [Teardown]    Run Keywords    Stop UL traffic
    ...                           Detach UE
    ...                           All Cells Unlock
    ...                           Common Test Teardown And Stop Capture Logs Aic

*** Keywords ***
Suite Setup For Aic BTS Env
    [Arguments]    ${scf}=SCF_vCUCNF00.xml
    Suite Setup BTS Env Aic   scf=${scf}

Config 1116 Frame Structure and feature 13961 and feature 9189 For case9
    Delta Commission Parameters Du    ${Frame_1116_0ms_13961_true_9189_true_du}
    Delta Commission Parameters Cu    ${CB009189_feature_on_cu}
    Sleep    60s
    Cells Should Be Onair Du    cell_id=21    timeout=1800    check_sib=${False}

Config 1070 Frame Structure and feature 13961 and feature 9189 For case7
    Delta Commission Parameters Du    ${Frame_1070_13961_true_9189_true_du}
    Delta Commission Parameters Cu    ${CB009189_feature_on_cu}
    Sleep    60s
    Cells Should Be Onair Du    cell_id=21    timeout=300    check_sib=${False}

Cell22 block
    Delta Commission Parameters Du  NRCELL-22:administrativeState=Locked
    Object Should Exist In Du  NRCELL-22:administrativeState=Locked

All Cells Unlock
    Delta Commission Parameters Du  NRCELL-22:administrativeState=Unlocked
    Object Should Exist In Du  NRCELL-22:administrativeState=Unlocked

Capature TTI Trace for Cell21 On DU1
    [Arguments]    ${tti_tag}
    start to capture gnb ttitrace Du1    cell=21    tti_tag=${tti_tag}
    sleep    15s
    stop capture gnb ttitrace Du1   tti_tag=${tti_tag}

Adjust PA for Serving Cell
    [Arguments]    ${cell_id}=21    ${pa_value}=10
    adjust pa all ports max value
    adjust_pa_for_cell_du1    cell_id=${cell_id}    value=${pa_value}
