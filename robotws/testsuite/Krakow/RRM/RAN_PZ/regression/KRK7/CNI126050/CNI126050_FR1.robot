*** Settings ***
Documentation
...    Test suite for regression testing for feature CNI126050-FR1
...    authors: Jakub Bialon, Lubomir Krzeminski
...    maintainer: Jakub Bialon
...    group: RAN_PZ_KRK_SG_7
...    contact: jakub.bialon@nokia.com

Resource    resources/keywordsFR1.robot

Suite Setup    Run Keywords    Common Suite Setup With OnAir Test Line Preparation    AND
...                            Install pandas with pip
Suite Teardown    Common Suite Teardown
Test Setup    Common Preconditions With Watching Alarms
Test Teardown    Common Postconditions With Watching Alarms


*** Test Cases ***
CNI-126050-03_PM_counters_are_enabled_with_L3_call
    [Tags]   TC01
    celloperations.Block Cell    cell_id=${186}
    ute_ue.Require UE    ue_alias=${DEFAULT_UE_ALIAS}
    ...                  capabilities=REAL_ANDROID_UE
    Start UL Data Transfer
    Start Generator With Settings    frequency_val=1871.81MHZ
    ...                              amplitude_val=-20DBM
    ...                              bandwidth_val=2.7MHZ
    ${web_time_stamp_UL}=    toolsFR1.Schedule Delay    delay=3.5
    Await UL Transfer Finish And Verify Throughput
    Start DL Data Transfer
    Start Generator With Settings    frequency_val=1872.08MHZ
    ...                              amplitude_val=-20DBM
    ...                              bandwidth_val=0.18MHZ
    ${web_time_stamp_DL}=    toolsFR1.Schedule Delay    delay=3.5
    Await DL Transfer Finish And Verify Throughput
    Sleep    5min    reason=Waiting for counter collection
    ${pm_counters_path_UL}=    Download And Find Required Pm Counters    time_stamp=${web_time_stamp_UL}
    ...                                                                  out_dir_path=/home/ute/logs
    ${pm_counters_path_DL}=    Download And Find Required Pm Counters    time_stamp=${web_time_stamp_DL}
    ...                                                                  out_dir_path=/home/ute/logs
    toolsFR1.compare_test_vector_and_pm_counters    test_vector_path=${VECTOR_UL_PATH}
    ...                                             pm_counters_path=${pm_counters_path_UL}
    toolsFR1.compare_test_vector_and_pm_counters    test_vector_path=${VECTOR_DL_PATH}
    ...                                             pm_counters_path=${pm_counters_path_DL}
    [Teardown]    Run Keywords    ute_ue.Detach UE    ${DEFAULT_UE_ALIAS}    AND
    ...                           toolsFR1.turn_off_generator    generator_ip=${GENERATOR_IP}    AND
    ...                           celloperations.Unblock Cell    cell_id=${186}
