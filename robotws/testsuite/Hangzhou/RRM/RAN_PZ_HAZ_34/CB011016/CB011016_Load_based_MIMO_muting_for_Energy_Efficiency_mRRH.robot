*** Settings ***
Resource    ./Resources/CB011016_common_keywords.robot
Variables    ./Resources/CB011016_variables.py

Documentation
...   author: xiaodan.li
...   contact: xiaodan.li@nokia-sbell.com
...   squad group: SG_03
...   Feature CB011016

Suite Setup    Run Keywords
...               Common Suite Setup for COAM    AND
...               Adjust gNB_RU Attenuation    AND
...               get_release_check_result    AND
...               Load SCF with different release

Suite Teardown    Run Keywords
...               Run Keyword And Ignore Error    Common Suite Teardown for COAM   AND
...               Run Keyword And Ignore Error    COAM Teardown gnb connections

*** Variables ***
${golden_scf_name_gnb1}    7326_784_SCF_gnb2.xml
${golden_scf_name}    7326_784_SCF_gnb2
${epc_log_path}    /opt/workspace/CRT/Master/Case_Logs/
${scf_path}    /opt/workspace/CRT/Master/SCF_file/
${duration}    900
${dl_throughput_big}    800M
${bts_host}    ${tl.gnbs[${0}].cu.oam_ssh_connection_details.addr}
@{expected_value_008_gnb1}    ${1000}
${value_min_004_gnb1}    60000
${value_max_004_gnb1}    70000
${value1_min_004_gnb1}    80000
${value1_max_004_gnb1}    98000

*** Test Cases ***
[1]CB011016-5G_003_Deactivate_Load-Based_Reduced_TX_Path_Power_Saving
    [Documentation]    This user scenario wants to cover deactivate load-based reduced TX path power saving function.
    ...                ADD CB011016-001 and CB011016-002 and CB011016-004 check point
    [Tags]     classical    CRT_TRUNK
    [Setup]    robot_common_operations.Common Case Setup    allowed_faults_ids=7311
    Online change ANT and check EnergySavingState
    Online modify NIDD on gnb    gnb_index=${1}    Modify_Para_Online=${PARAMETERS_TO_ONLINE_MODIFY_GNB2_004_2}
    Precondition for Sansumg UE    ue_type=${ue_type}    ui_version=S21UI3.1
    Check UE device exist
    Adjust gNB_RU Attenuation    gnb2_cell2_value=${0}
    Attach and check power UE    ue_type=${ue_type}    gnb_index=${1}
    power_ue.Start traffic    ue_type=${ue_type}    direction=dl    duration=${duration}
    ...    throughput=${dl_throughput_big}    iperf_port=${iperf_port}
    Wait until keyword succeeds    2 min    5s    Get EnergySavingState    status=notEnergySaving
    Get many times RMOD Realtime Measurements    power_min=${180}    power_max=${200}
    power_ue.Stop traffic    ue_type=${ue_type}    direction=dl
    power_ue.UE Detach    ue_type=${ue_type}
    Wait until keyword succeeds    2 min    5s    Get EnergySavingState    status=reducedEnergySaving
    Get many times RMOD Realtime Measurements    power_min=${60}    power_max=${70}
    [Teardown]    run keywords
    ...    Run Keyword And Ignore Error    Common UE teardown    AND
    ...    Case recover CB011016 004    AND
    ...    Common Case Teardown for COAM


#[1]CB011016-5G_008_Activate_Load-Based_Reduced_TX_Path_Power_Saving_interworking_with_EIRP
#    [Documentation]    This user scenario wants to cover activate the load-based reduced TX path power saving in
#    ...                Micro-Cell and trigger half TX path switch off in micro-RRU and interworking with EIRP.
#    [Setup]    robot_common_operations.Common Case Setup
#    Prepare to caculate PM counter    period=start
#    Online modify NIDD on gnb    gnb_index=${0}    Modify_Para_Online=${PARAMETERS_TO_ONLINE_MODIFY_GNB1_008}
#    sleep    30s
#    Get EnergySavingState    status=reducedEnergySaving    cell_index=${3}
#    Prepare to caculate PM counter    period=end
#    Check counter for 008
#    [Teardown]    run keywords
#    ...    Case recover CB011016    AND
#    ...    Common Case Teardown for COAM
#
#[1]CB011016-5G_009_SiSo_Cell_lock_and_unlock_SA
#    [Documentation]    The purpose of this test case is to verify cell and group cell lock/ unlock functionality.
#    [Setup]    robot_common_operations.Common Case Setup
#    Online modify cell parameter and check energysavingstate
#    ...    Modify_Para_Online=${PARAMETERS_TO_ONLINE_MODIFY_GNB1_004}    status=reducedEnergySaving
#    Online modify cell parameter and check energysavingstate
#    ...    Modify_Para_Online=${PARAMETERS_TO_ONLINE_MODIFY_GNB1_009}    status=notEnergySaving
#    Online modify cell parameter and check energysavingstate
#    ...    Modify_Para_Online=${PARAMETERS_TO_ONLINE_MODIFY_GNB1_009_1}    status=reducedEnergySaving
#    Online modify cell parameter and check energysavingstate
#    ...    Modify_Para_Online=${PARAMETERS_TO_ONLINE_MODIFY_GNB1_009_2}    status=notEnergySaving
#    Online modify cell parameter and check energysavingstate
#    ...    Modify_Para_Online=${PARAMETERS_TO_ONLINE_MODIFY_GNB1_009_3}    status=reducedEnergySaving
#    [Teardown]    run keywords
#    ...    Case recover CB011016    AND
#    ...    Common Case Teardown for COAM
#

*** Keywords ***
Common Case TestLine Setup for CB011016
    [Arguments]    ${golden_scf_name}    ${gnb_index}=${1}
    Common Case TestLine Setup with singe BTS    gnb_index=${gnb_index}    ModifySCF_Beforecommission=True
    ...    golden_scf_name=${golden_scf_name}    ListParamterToModify=${LIST_TO_MODIFY_GNB2}
    ...    ParamterToModify=${PARAMETERS_TO_MODIFY_GNB2}    scf_path=${scf_path}
    Wait until keyword succeeds    20 min    20s
    ...    Check the cells status on air    bts_host=${bts_host${gnb_index}}   connection=gnb${gnb_index}

Load SCF with different release
    ${release}=    Get sagnb release title
    Common Case TestLine Setup for CB011016    golden_scf_name=${golden_scf_name}_${release}.xml

Check counter for 004
    [Arguments]    ${value_min}=${value_min_004_gnb1}    ${value_max}=${value_max_004_gnb1}
    sleep    60s
    RUN KEYWORD IF    '${check_result}' == 'True'    Check the PM counter CB011016
    ...    gnb_index=${1}    counter_id=${counter_id_003_gnb1}    dic_path=${counter_dic_path_003_gnb1_Trunk}
    ...    value_min=${value_min}    value_max=${value_max}
    ...    ELSE    Check the PM counter CB011016
    ...    gnb_index=${1}    counter_id=${counter_id_003_gnb1}    dic_path=${counter_dic_path_003_gnb1}
    ...    value_min=${value_min}    value_max=${value_max}

Check counter for 008
    sleep    60s
    Run keyword if    '${check_result}' == 'True'    Check the PM counter should be greater than 1
    ...    gnb_index=${0}    counter_id=${counter_id_008_gnb1}    dic_path=${counter_dic_path_008_gnb1_Trunk}
    ...    value=${expected_value_008_gnb1}
    ...    ELSE    Check the PM counter should be greater than 1
    ...    gnb_index=${0}    counter_id=${counter_id_008_gnb1}    dic_path=${counter_dic_path_008_gnb1}
    ...    value=${expected_value_008_gnb1}

Online change ANT and check EnergySavingState
    Log to console    \n*** open CB011016, check EnergySavingState and counter with 4T4R***
    Online modify parameter amd check Measurements
    ...    Modify_Para_Online=${PARAMETERS_TO_ONLINE_MODIFY_GNB2_004}    status=reducedEnergySaving    power_min=${60}    power_max=${70}
    Log to console    \n*** close CB011016, check EnergySavingState and Measurements with ANT34***
    Online modify parameter amd check counter    Modify_Para_Online=${PARAMETERS_TO_ONLINE_MODIFY_GNB2_004_1}
    ...    status=notEnergySaving    value_min=${value1_min_004_gnb1}    value_max=${value1_max_004_gnb1}
    Log to console    \n*** open CB011016, check EnergySavingState and counter with 4T2R***
    Online modify NIDD on gnb    gnb_index=${1}    Modify_Para_Online=${PARAMETERS_TO_ONLINE_MODIFY_GNB2_004_4T2R}
    Online modify parameter amd check counter    Modify_Para_Online=${PARAMETERS_TO_ONLINE_MODIFY_GNB2_004}
    ...    Delete_Mo_Online=${Delete_Mo_Online_GNB2_004}
    ...    status=reducedEnergySaving    value_min=${value_min_004_gnb1}    value_max=${value_max_004_gnb1}
    Log to console    \n*** close CB011016, check EnergySavingState and Measurements with ANT12***
    Online modify parameter amd check Measurements    Modify_Para_Online=${PARAMETERS_TO_ONLINE_MODIFY_GNB2_004_1}
    ...    status=notEnergySaving    power_min=${80}    power_max=${100}
    Log to console    \n*** open CB011016, check EnergySavingState and counter with ANT13***
    Online modify parameter amd check Measurements    Modify_Para_Online=${PARAMETERS_TO_ONLINE_MODIFY_GNB2_004_ANT13}
    ...    status=reducedEnergySaving    power_min=${60}    power_max=${70}
    Log to console    \n*** close CB011016, check EnergySavingState and Measurements with ANT13***
    Online modify parameter amd check Measurements    Modify_Para_Online=${PARAMETERS_TO_ONLINE_MODIFY_GNB2_004_1}
    ...    status=notEnergySaving    power_min=${80}    power_max=${100}
    Log to console    \n*** open CB011016, check EnergySavingState and counter with ANT24***
    Online modify parameter amd check Measurements    Modify_Para_Online=${PARAMETERS_TO_ONLINE_MODIFY_GNB2_004_ANT24}
    ...    status=reducedEnergySaving    power_min=${60}    power_max=${70}
    Log to console    \n*** close CB011016, check EnergySavingState and Measurements with ANT24***
    Online modify parameter amd check Measurements    Modify_Para_Online=${PARAMETERS_TO_ONLINE_MODIFY_GNB2_004_1}
    ...    status=notEnergySaving    power_min=${80}    power_max=${100}


Online modify parameter amd check counter
    [Arguments]    ${Modify_Para_Online}    ${status}=reducedEnergySaving    ${Delete_Mo_Online}='NULL'
    ...    ${value_min}=${value_min}    ${value_max}=${value_max}
    Online modify NIDD on gnb    gnb_index=${1}    Modify_Para_Online=${Modify_Para_Online}    Delete_Mo_Online=${Delete_Mo_Online}
    sleep    40s
    Get EnergySavingState    status=${status}
    Prepare to caculate PM counter    period=start    counter_time=900
    Prepare to caculate PM counter    period=end    counter_time=900
    Check counter for 004    value_min=${value_min}    value_max=${value_max}

Online modify parameter amd check Measurements
    [Arguments]    ${Modify_Para_Online}='NULL'    ${Add_Mo_Online}='NULL'    ${Delete_Mo_Online}='NULL'
    ...    ${power_min}=${0}    ${power_max}=${0}
    ...    ${status}=reducedEnergySaving    ${RU_index}=${2}
    Wait until keyword succeeds    5X    10s    Online modify NIDD on gnb    gnb_index=${1}    Modify_Para_Online=${Modify_Para_Online}
    ...    Add_Mo_Online=${Add_Mo_Online}    Delete_Mo_Online=${Delete_Mo_Online}
    sleep    40s
    Get EnergySavingState    status=${status}
    Get many times RMOD Realtime Measurements    RU_index=${RU_index}    power_min=${power_min}    power_max=${power_max}

Get many times RMOD Realtime Measurements
    [Arguments]    ${RU_index}=${2}    ${power_min}=${0}    ${power_max}=${0}    ${gnb_index}=${1}
    sleep    120s
    Prepare to caculate PM counter    period=start    counter_time=60
    Prepare to caculate PM counter    period=end    counter_time=60
    FOR    ${index}    IN RANGE    ${5}
        ${power}    Get RMOD Realtime Measurements    RU_index=${RU_index}    gnb_index=${gnb_index}
        should be true    ${power_min}<=${power}<=${power_max}
        sleep    60s
    END

Online modify cell parameter and check energysavingstate
    [Arguments]    ${Modify_Para_Online}    ${status}=reducedEnergySaving
    Connect to gnb coam via ssl
    COAM Update several parameters via rest api    parameters_to_update_via_api=${Modify_Para_Online}
    wait until keyword succeeds    2 min    5s   Get EnergySavingState    status=${status}    cell_index=${3}
    [Teardown]    Run Keyword And Ignore Error    COAM Teardown gnb connections

Case recover CB011016 004
    Modify NIDD parameter online    parameters_to_update=${PARAMETERS_TO_ONLINE_RECOVERY_GNB2_004}

Case recover CB011016
    Online modify NIDD on gnb    gnb_index=${0}    Modify_Para_Online=${PARAMETERS_TO_ONLINE_RECOVERY_GNB1_008}