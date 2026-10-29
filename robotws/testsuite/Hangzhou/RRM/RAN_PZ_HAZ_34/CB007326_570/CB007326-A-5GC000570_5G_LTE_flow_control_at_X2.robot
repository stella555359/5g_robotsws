*** Settings ***
Documentation     author: yifan hu
...                 contact: yifan.hu@nokia-sbell.com
...                 squad group: SG_03
...                 feature : CB007326

Force Tags    5G_SISO    RAN_5G    RAN_5G_TDD
...    PY36
...    CRT_UTE    STATE_SW_UPLOADED    CLOUD_5G_CLASSICAL_ANDROID_ASIKL_ABILB1_AWHHI_ENB    SBTS00    5G_RAN_TDD

Resource    ./Resources/CB007326-A-5GC000570_common_keyword.robot
Variables    ./Resources/variables_570.py


Suite Setup    Run Keywords
...    robot_common_operations.Common Suite Setup    AND
...    CI_interface.Common Suite Setup    AND
...    Pre Condition    AND
...    Set automatic rotation on UEs    AND
...    Adjust trunk gNB Attenuation    value1=${0}    AND
...    adjust the enb HBTE attenuation value    value_1=${0}    value_2=${0}

Suite Teardown    Run Keywords
...               robot_common_operations.Common Suite Teardown    AND
...               Run Keyword If Any Tests Failed
...               Run Keyword And Ignore Error    Common Suite Teardown for COAM   AND
...               Run Keyword And Ignore Error    COAM Teardown gnb connections


*** Variables ***
${gnb_path}    /tmp
${enb_path}    /tmp/
${tl_scf_file_name}    SCF_SBTS00.xml
${value_min}    70000
${value_max}    100000
${value1_max}    150000
@{allow_fault_list}    7107    7506    7101    4681

*** Test Cases ***
[1]CB011016-5G_003_Deactivate_Load-Based_Reduced_TX_Path_Power_Saving
    [Documentation]    This user scenario wants to cover deactivate load-based reduced TX path power saving function.
    ...                ADD CB011016-001 and CB011016-002 and CB011016-004 check point
    [Tags]     classical    CRT_TRUNK
    [Timeout]    4 hours
    [Setup]
    robot_common_operations.Common Case Setup    allowed_faults_ids=7107,7523,4681,7506
    AlarmWatchdog.add_allow_alarms    fault_id=${allow_fault_list}
    ${release_info}    Get gnb release info
    Comment    20250827 for test 4T2R Powersaving,need to delete 2R before test, the '2R' need to offline delete
    Run Keyword IF    '${release_info}' == 'SBTS25R2'   sleep    1s
    ...    ELSE    Common Case TestLine Setup    ModifySCF_Beforecommission=True
    ...                           scf_path=${tl_scf_dir_path}    golden_scf_name=${tl_scf_file_name}
    ...                           ParameterToDelete=${Delete_Mo_Online_GNB1_2RX}    ParamterToModify=${PARAMETERS_TO_Para_MODIFY_GNB1_2RX}
    ...                           ListParamterToModify=${PARAMETERS_TO_list_MODIFY_GNB1_2RX}
    Comment    set several kinds of different EnergySavingState scinariao
    Online change ANT and check EnergySavingState
    Comment    open powersaving and NSA attach check big traffic switch EnergySavingState
    Online modify parmeters    gnb_index=${0}    parameters_to_update=${PARAMETERS_TO_ONLINE_MODIFY_GNB1_004_2}
    ...    skip_parameter_relation_errors=False
#    Online modify NIDD on gnb    gnb_index=${0}    Modify_Para_Online=${PARAMETERS_TO_ONLINE_MODIFY_GNB1_004_2}
#    Online modify NIDD on gnb    gnb_index=${0}    Modify_Para_Online=${PARAMETERS_TO_ONLINE_MODIFY_GNB1_AMF_LOCK}
    Precondition for Sansumg UE    ue_type=${ue_type}    ui_version=S21UI3.1
    Check phone attach successfully
    power_ue.Start traffic    ue_type=${ue_type}    direction=dl
    ...    throughput=${Send_Tput_DL}    duration=${traffic_duration}    ue_index=${0}    protocol=udp
    Comment    20250620 lock AMF result in cell degrade  EnergySavingState back to notEnergySavingState,so unlock AMF when NSA attach and traffic
    Online modify parmeters    gnb_index=${0}    parameters_to_update=${PARAMETERS_TO_ONLINE_MODIFY_GNB1_004_3}
    ...    skip_parameter_relation_errors=False
    Wait until keyword succeeds    2 min    5s    Get EnergySavingState    status=notEnergySaving
    Comment    check big power when not into EnergySavingState
    Get many times RMOD Realtime Measurements    power_min=${200}    power_max=${230}
    power_ue.Stop traffic    ue_type=${ue_type}    direction=dl
    Wait until keyword succeeds    2 min    5s    Get EnergySavingState    status=reducedEnergySaving
    Comment    check big power when into EnergySavingState
    Get many times RMOD Realtime Measurements    power_min=${70}    power_max=${90}
    power_ue.UE Detach    ue_type=${ue_type}
    [Teardown]    run keywords
    ...    robot_common_operations.Common Case Teardown    AND
    ...    Run Keyword And Ignore Error    Tear down UE traffic and detach    AND
    ...    Case recover CB011016    AND
    ...    Check hanging resource for gnb    gnb_ips=${gnb_ips}    ute_log_path=${ute_log_path}    AND
    ...    Run Keyword And Ignore Error    Tear down the connections    AND
    ...    Run Keyword And Ignore Error    CI_interface.Common Case Teardown

#[1]CB007326_5G_A_5GC002098_C_Queuing_Delay_Discard_mechanism_with_UDP_transmission_check_on_COAM
#    [Documentation]
#    [Tags]    CRT_TRUNK    SBTS00
#    [Setup]    robot_common_operations.Common Case Setup
#    power_ue.Prepare UE    ue_type=${ue_type}
#    Modify NIDD parameter online   parameters_to_update=${PARAMETERS_TO_UPDATE}
#    Check the gnb cell status onair
#    SA L3 call attach with udp data and check PM counter
#    [Teardown]    run keywords
#    ...    robot_common_operations.Common Case Teardown    AND
#    ...    Run Keyword And Ignore Error    Tear down UE traffic and detach    AND
#    ...    Check hanging resource for gnb    gnb_ips=${gnb_ips}    ute_log_path=${ute_log_path}    AND
#    ...    Run Keyword And Ignore Error    Tear down the connections    AND
#    ...    Run Keyword And Ignore Error    CI_interface.Common Case Teardown

*** Keywords ***
Check counter for 004
    [Arguments]    ${value_min}=${value_min}    ${value_max}=${value_max}
    sleep    40s
    Check the PM counter CB011016
    ...    gnb_index=${0}    counter_id=${counter_id_003_gnb1}    dic_path=${counter_dic_path_003_gnb1}
    ...    value_min=${value_min}    value_max=${value_max}

Case recover CB011016
    Online modify NIDD on gnb    gnb_index=${0}    Modify_Para_Online=${PARAMETERS_TO_ONLINE_MODIFY_GNB1_004_1}
    Online modify NIDD on gnb    gnb_index=${0}    Modify_Para_Online=${PARAMETERS_TO_RESTORE}

Online change ANT and check EnergySavingState
    [Arguments]    ${paras}=${paras}    ${delta_file_name}=${epc_log_path}${PARAMETERS_DSM_JSON_FILE}
    Log to console    \n*** 20260126 disable CB008250,actPlmnAwareScheduler and actSliceAwareSchQosFairness result in pdl error***
    Online modify NIDD on gnb    gnb_index=${0}    Modify_Para_Online=${PARAMETERS_TO_ONLINE_MODIFY_GNB1_disable}
    Log to console    \n*** open CB011016, check EnergySavingState and counter with 4T2R***
    Online modify parameter amd check counter    Modify_Para_Online=${PARAMETERS_TO_ONLINE_MODIFY_GNB1}
    ...    Delete_Para_Online=${Delete_Para_Online_GNB1}
    ...    status=reducedEnergySaving    value_min=${value_min}    value_max=${value_max}
    Log to console    \n*** close CB011016, check EnergySavingState and Measurements with ANT12***
    Online modify parameter amd check Measurements    Modify_Para_Online=${PARAMETERS_TO_ONLINE_MODIFY_GNB1_004_1}
    ...    status=notEnergySaving    power_min=${100}    power_max=${110}
    Log to console    \n*** open CB011016, check EnergySavingState and counter with ANT13***
    Online modify parameter amd check Measurements    Modify_Para_Online=${PARAMETERS_TO_ONLINE_MODIFY_GNB1_ANT13}
    ...    status=reducedEnergySaving    power_min=${70}    power_max=${80}
    Log to console    \n*** close CB011016, check EnergySavingState and Measurements with ANT13***
    Online modify parameter amd check Measurements    Modify_Para_Online=${PARAMETERS_TO_ONLINE_MODIFY_GNB1_004_1}
    ...    status=notEnergySaving    power_min=${100}    power_max=${110}
    Log to console    \n*** open CB011016, check EnergySavingState and counter with ANT24***
    Online modify parameter amd check Measurements    Modify_Para_Online=${PARAMETERS_TO_ONLINE_MODIFY_GNB1_ANT24}
    ...    status=reducedEnergySaving    power_min=${70}    power_max=${80}
    Log to console    \n*** close CB011016, check EnergySavingState and Measurements with ANT24***
    Online modify parameter amd check Measurements    Modify_Para_Online=${PARAMETERS_TO_ONLINE_MODIFY_GNB1_004_1}
    ...    status=notEnergySaving    power_min=${100}    power_max=${110}
    Log to console    \n*** open CB011016, check EnergySavingState and counter with 4T4R***
    paras change on BTS    paras=${paras}    delta_file_name=${delta_file_name}
    Wait until keyword succeeds    10 min    20s    Check the cells status on air
##    AlarmWatchdog.add_allow_alarms    fault_id=${allow_fault_list}
#    Modify NIDD parameter online    parameters_to_update=${PARAMETERS_TO_ONLINE_MODIFY_GNB1_4T4R}
#    Check the gnb RU status ready
#    Online modify parameter amd check Measurements    Add_Mo_Online=${Add_Mo_Online_GNB1_4T4R}
#    ...    status=reducedEnergySaving    power_min=${70}    power_max=${90}
    check Measurements    status=reducedEnergySaving    power_min=${70}    power_max=${90}
##    AlarmWatchdog.remove_allow_alarms    fault_id=${allow_fault_list}
    Log to console    \n*** close CB011016, check EnergySavingState and Measurements with ANT34***
    Online modify parameter amd check counter    Modify_Para_Online=${PARAMETERS_TO_ONLINE_MODIFY_GNB1_004_1}
    ...    status=notEnergySaving    value_min=${value_max}    value_max=${value1_max}



Online modify parameter amd check counter
    [Arguments]    ${Modify_Para_Online}    ${Delete_Para_Online}='NULL'    ${status}=reducedEnergySaving
    ...    ${value_min}=${value_min}    ${value_max}=${value_max}
    Online modify NIDD on gnb    gnb_index=${0}    Modify_Para_Online=${Modify_Para_Online}    Delete_Para_Online=${Delete_Para_Online}
    sleep    40s
    Get EnergySavingState    status=${status}
    Prepare to caculate PM counter    period=start    counter_time=900
    Prepare to caculate PM counter    period=end    counter_time=900
    Check counter for 004    value_min=${value_min}    value_max=${value_max}

check Measurements
    [Arguments]    ${power_min}=${0}    ${power_max}=${0}    ${status}=reducedEnergySaving    ${RU_index}=${1}
    sleep    40s
    Get EnergySavingState    status=${status}
    Get many times RMOD Realtime Measurements    RU_index=${RU_index}    power_min=${power_min}    power_max=${power_max}

Online modify parameter amd check Measurements
    [Arguments]    ${Modify_Para_Online}='NULL'    ${Add_Mo_Online}='NULL'    ${Delete_Para_Online}='NULL'
    ...    ${power_min}=${0}    ${power_max}=${0}
    ...    ${status}=reducedEnergySaving    ${RU_index}=${1}
    Online modify NIDD on gnb    gnb_index=${0}    Modify_Para_Online=${Modify_Para_Online}
    ...    Add_Mo_Online=${Add_Mo_Online}    Delete_Para_Online=${Delete_Para_Online}
    sleep    40s
    Get EnergySavingState    status=${status}
    Get many times RMOD Realtime Measurements    RU_index=${RU_index}    power_min=${power_min}    power_max=${power_max}

Get many times RMOD Realtime Measurements
    [Arguments]    ${RU_index}=${1}    ${power_min}=${0}    ${power_max}=${0}
    sleep    120s
    Prepare to caculate PM counter    period=start    counter_time=60
    Prepare to caculate PM counter    period=end    counter_time=60
    FOR    ${index}    IN RANGE    ${5}
        ${power}    Get RMOD Realtime Measurements    RU_index=${RU_index}
        should be true    ${power_min}<=${power}<=${power_max}
        sleep    60s
    END

 Get gnb release info
    ${release_info}    Get sagnb release
    set suite variable    ${release_info}    ${release_info.split('_')[0]}
    [Return]    ${release_info}