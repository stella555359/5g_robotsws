*** Settings ***
Documentation
...    author: Chen Dandan
...    contact: dandan.chen@nokia-sbell.com
...    squad group: NSB_MN_RAN_RD_VRF_HAZ3_07
Suite Setup       Common Suite Setup And Setup BTS env
Suite Teardown    Common Suite Teardown And Restore BTS Configuration Parameters
Test Setup        Common Test Setup And Start To Capture Logs
Test Teardown     Common Test Teardown And Stop Capture Logs
Force Tags        release-SBTS25R2    tl-7_5_UTE5G402T2470
Resource          testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/lines/MMW_SG8/resources/DevHZ5_resource_ST.robot
Resource          testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/lines/MMW_SG8/resources/ST_robot/L3_call/DevHZ5_spark_ue.robot

*** Variables ***
${BTS_STARTUP_RETRY}  0
${BTS_NUMBER}    1
${SYSCOM_FLAG}    ${False}
${timeout}    1200
#${file}    /home/ute/MN/UTE/robotws/testsuite/Hangzhou/RRM/RAN_PZ_HAZ_34/CB008761/test_data/SBTS00/SCellActivationTrainingConfiguration.json
${file}    ${CURDIR}/test_data/SBTS00/SCellActivationTrainingConfiguration.json
@{FAULTS_EXCLUDED_CHECKING}    2002
*** Test Cases ***
CB008761-ET-M022_ASIM_SPARK_2UEs_testing
    [Documentation]
    ...    1. This user scenario describes activation of CB008761 feature on ASIM.
    ...    3. Test Case Steps:
    ...           a. get state when cell on air
    ...           b. disable/enable feature flag, check mlTrainingState state
    ...           c. preparework and wait trained success
    ...           d. check counter after trained for pcell TDD
    ...           h. lock unlock one TDD cell, check state
    ...           h. lock all TDD cell, check state
    ...    4. Expected Results:
    ...           a. mlTrainingState state set to Training when at least one TDD cell setup
    ...           b. mlTrainingState state set to Training when feature enable
    ...           c. set mlTrainingStartTime and wait training success
    ...           d. pcell TDD UE, counter as expected
    ...           h. lock unlock one TDD cell, state still available
    ...           h. lock all TDD cell, state change to Idle
    [Tags]    QC_x    CA_LABEL-TF(1_100M_TDD_n78+1_20M_FDD_n28)
    online modify flag and check state
    preparework for training
    Clear Counter Files
    adjust pa all ports max value
    adjust_pa_for_cell    cell_id=6    value=10
    adjust_pa_for_cell    cell_id=5    value=40
    adjust_pa_for_cell    cell_id=4    value=40
    Make two Spark UE
    wait until keyword succeeds    9200    600s    Get mlstate    expect_state=Trained    expect_inference=available
    log to console    Current expect_state: Trained
    Stop UL And DL traffic    ue_id=1    apn_address=dxdata1
    Stop UL And DL traffic    ue_id=2    apn_address=dxdata1
    Detach UE    ue_id=1
    Detach UE    ue_id=2
    Check Counters    ${PM_Counters_Check_N1}
    Clear Counter Files
    Make two Spark UE
    Stop UL And DL traffic    ue_id=1    apn_address=dxdata1
    Stop UL And DL traffic    ue_id=2    apn_address=dxdata1
    Detach UE    ue_id=1
    Detach UE    ue_id=2
    Check Counters    ${PM_Counters_Check_after_trained}
    lock unlock all cells and check training state

*** Keywords ***
online modify flag and check state
    wait until keyword succeeds    300    20s    Cells Should Be Onair     cell_id=all    timeout=${timeout}
    log to console    online modify flag and check state
    Get mlstate    expect_state=Training    expect_inference=unavailable
    Delta Commission Parameters    ${PARAMS_actMLScellAct_disable}
    wait until keyword succeeds    300    20s    Cells Should Be Onair     cell_id=all    timeout=${timeout}
    Get mlstate    expect_state=Idle    expect_inference=unavailable
    Delta Commission Parameters    ${PARAMS_actMLScellAct_enable}
    wait until keyword succeeds    300    20s    Cells Should Be Onair     cell_id=all    timeout=${timeout}
    Get mlstate    expect_state=Training    expect_inference=unavailable

preparework for training
    log to console    preparework for training
    Execute Cmd On Pc  sudo timedatectl set-timezone Etc/UTC
    put_enb_file    ${file}    /tmp/
    execute cmd on bts  mv /tmp/SCellActivationTrainingConfiguration.json /rom/ml_data/bundle/SCellActivation_*/SCellActivation/
    ${time}=    Get Time    format=%H:%M
    log to console    Current time: ${time}
    ${hour}=    Evaluate    int(str("${time}").split(":")[0].split(" ")[1])
    ${minute}=    Evaluate    int(str("${time}").split(":")[1])
    log to console    Current hour: ${hour}, Current minute: ${minute}
    ${set_hour1}=    Evaluate    ${hour}+1
    ${set_hour2}=    Evaluate    ${hour}+2
    Run Keyword If    ${minute} >= 30    Delta Commission Parameters
    ...    MNL-1/MNLENT-1/FEATCADM-1/MLCADM-1:mlTrainingParams:mlTrainingStartTime=${set_hour2}
    Run Keyword If    ${minute} < 30    Delta Commission Parameters
    ...    MNL-1/MNLENT-1/FEATCADM-1/MLCADM-1:mlTrainingParams:mlTrainingStartTime=${set_hour1}
    sleep    120s
    wait until keyword succeeds    1200    60s    Cells Should Be Onair     cell_id=all    timeout=${timeout}

Make two Spark UE
    log to console    Make two Spark UE
    Prepare and attach UE    ue_id=1    apn=dxdata1
    Start UL And DL traffic    ue_id=1    send_traffic_ul=20M    send_traffic_dl=700M    apn_address=dxdata1
    Prepare and attach UE    ue_id=2    apn=dxdata1
    Start UL And DL traffic    ue_id=2    send_traffic_ul=20M    send_traffic_dl=700M    apn_address=dxdata1
    sleep    60s
    Wait Until Keyword Succeeds    120s    10s    Collect And Check Tput    cells=6    ue_id=1    dl_target_tp=10M    ul_target_tp=1M
    Wait Until Keyword Succeeds    120s    10s    Collect And Check Tput    cells=6    ue_id=2    dl_target_tp=10M    ul_target_tp=1M
    Wait Until Keyword Succeeds    120s    10s    Collect And Check Tput    cells=5    ue_id=1    dl_target_tp=1M
    Wait Until Keyword Succeeds    120s    10s    Collect And Check Tput    cells=5    ue_id=2    dl_target_tp=1M
    Wait Until Keyword Succeeds    120s    10s    Collect And Check Tput    cells=4    ue_id=1    dl_target_tp=1M
    Wait Until Keyword Succeeds    120s    10s    Collect And Check Tput    cells=4    ue_id=2    dl_target_tp=1M

lock unlock all cells and check training state
    log to console    lock unlock all cells and check training state
    Lock NRCell6
    Unlock NRCell6
    wait until keyword succeeds    300    20s    Cells Should Be Onair     cell_id=6    timeout=${timeout}
    Lock NRCell5
    Unlock NRCell5
    wait until keyword succeeds    300    20s    Cells Should Be Onair     cell_id=5    timeout=${timeout}
    Lock NRCell4
    Unlock NRCell4
    wait until keyword succeeds    300    20s    Cells Should Be Onair     cell_id=4    timeout=${timeout}
    Get mlstate    expect_state=Trained    expect_inference=available
    Lock NRCell4
    Lock NRCell5
    Lock NRCell6
    Get mlstate    expect_state=Idle    expect_inference=unavailable
    Unlock NRCell4
    Unlock NRCell5
    Unlock NRCell6
    wait until keyword succeeds    1200    60s    Cells Should Be Onair     cell_id=all    timeout=${timeout}
    Get mlstate    expect_state=Training    expect_inference=unavailable

Get mlstate
    [Arguments]    ${expect_state}=Training    ${expect_inference}=unavailable
    ${mlTrainingState}    Get Scf Parameter Value    NRDU-1:mlScellActParamSet1:mlTrainingState
    Should Be Equal    ${mlTrainingState}    ${expect_state}
    ${mlinferencestate-4}    Get Scf Parameter Value    NRCELL-4:mlScellActParamSet2:mlInferenceState
    Should Be Equal    ${mlinferencestate-4}    ${expect_inference}
    ${mlinferencestate-5}    Get Scf Parameter Value    NRCELL-5:mlScellActParamSet2:mlInferenceState
    Should Be Equal    ${mlinferencestate-5}    ${expect_inference}
    ${mlinferencestate-6}    Get Scf Parameter Value    NRCELL-6:mlScellActParamSet2:mlInferenceState
    Should Be Equal    ${mlinferencestate-6}    ${expect_inference}
