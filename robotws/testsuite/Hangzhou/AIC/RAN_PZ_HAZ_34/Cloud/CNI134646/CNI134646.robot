*** Settings ***
Force Tags    PY36
Documentation
...    Author: Charlotte Wu
...    Contact: charlotte.wu@nokia-sbell.com
...    Group: VRF_HAZ3_2
...    Feature: CNI134646

Suite Setup         run keywords    Setup Suite For Cloud    AND    Set_scf_name_for_cases
Test Setup          Setup Test For Cloud
Test Teardown       Teardown Test For Cloud
Suite Teardown      Teardown Suite For Cloud
Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/lines/SG8/SG08_keywords_cloud.robot
Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/CI_Operations/CI_interface.robot

*** Variables ***
${scf_path_cu}    ${commissionings_path}/HGZ/${testline_name}/gnbs_0/cu
${scf_path_du}    ${commissionings_path}/HGZ/${testline_name}/gnbs_0/dus_0
${UE_RSSI_PUSCH_LEVEL_Prefix}    M55303C0
${UE_RSSI_PUSCH_LEVEL_Start}    7001
${UE_RSSI_PUSCH_LEVEL_End}    7045
${UE_RSSI_PUSCH_BIN_Prefix}    M55386C0000
${UE_RSSI_PUSCH_BIN_Start}    1
${UE_RSSI_PUSCH_BIN_End}    5
${MRBTS_ID}    37314
${UE_RSSI_PUSCH_LEVEL_DIM}    MRBTS-${MRBTS_ID}/NRBTS-${MRBTS_ID}/NRCELL-3
${UE_RSSI_PUSCH_BIN_DIM}    MRBTS-${MRBTS_ID}/NRBTS-${MRBTS_ID}/NRCELL-3/NRPMQAP-1

*** Test Cases ***
[1]CNI_134646_A_1_PUSCH_RSSI_counter_validation_Cloud
    Basic_L3_call
    ${UE_RSSI_PUSCH_LEVEL}    Check Counters    counter_prefix=${UE_RSSI_PUSCH_LEVEL_Prefix}
    ...    counter_start=${UE_RSSI_PUSCH_LEVEL_Start}    counter_end=${UE_RSSI_PUSCH_LEVEL_End}
    ...    counter_dimension=${UE_RSSI_PUSCH_LEVEL_DIM}
    ${UE_RSSI_PUSCH_BIN}    Check Counters    counter_prefix=${UE_RSSI_PUSCH_BIN_Prefix}
    ...    counter_start=${UE_RSSI_PUSCH_BIN_Start}    counter_end=${UE_RSSI_PUSCH_BIN_End}
    ...    counter_dimension=${UE_RSSI_PUSCH_BIN_DIM}
    Check Sum Equality    ${UE_RSSI_PUSCH_LEVEL}    ${UE_RSSI_PUSCH_BIN}

*** Keywords ***
Basic_L3_call
    [Arguments]    ${ue_index}=${0}    ${dl_tp}=50    ${ul_tp}=3    ${duration}=600    ${target_avg_percent}=0.9
    [Documentation]    params ${dl_tp}, ${ul_tp} unit:Mbits/sec
    log to console    \n***Prepare UE***
    ${ue_type}    translate_power_ue_type_from_testline    ue_index=${ue_index}
    power_ue.Prepare UE    ue_type=${ue_type}    ue_index=${ue_index}

    log to console    \n***UE Detach ***
    power_ue.UE Detach  ue_type=${ue_type}    ue_index=${ue_index}

    log to console    \n***UE Attach***
    power_ue.UE Attach    ue_type=${ue_type}    ue_index=${ue_index}     log_type=aasyslog

    log to console    \n***start traffic***
    ${start_traffic_duration}    evaluate    ${duration}+${60}
    power_ue.Start traffic    ue_type=${ue_type}    direction=dl    throughput=${dl_tp}Mbits/sec
    ...    duration=${start_traffic_duration}    ue_index=${ue_index}
    power_ue.Start traffic    ue_type=${ue_type}    direction=ul    throughput=${ul_tp}Mbits/sec
    ...    duration=${start_traffic_duration}    ue_index=${ue_index}
    ${Tput_logs}    power_ue.Collect Tput    ue_type=${ue_type}    duration=${duration}

    log to console    \n***Stop traffic ***
    power_ue.Stop traffic    ue_type=${ue_type}    direction=dl    ue_index=${ue_index}
    power_ue.Stop traffic    ue_type=${ue_type}    direction=ul    ue_index=${ue_index}

    log to console    \n***check tput ***
    power_ue.Check Tput    ue_type=${ue_type}    direction=dl    target_throughput=${dl_tp}    log=${Tput_logs}
    ...    target_avg_percent=${target_avg_percent}    ue_index=${ue_index}
    power_ue.Check Tput    ue_type=${ue_type}    direction=ul    target_throughput=${ul_tp}    log=${Tput_logs}
    ...    target_avg_percent=${target_avg_percent}    ue_index=${ue_index}

# ***UE Detach ***
#    power_ue.UE Detach  ue_type=${ue_type}    ue_index=${ue_index}
    log to console    \nBasic_L3_call test passed

Set_scf_name_for_cases
    set suite variable    ${scf_name_cu_AVQE_AQQC}    SCF_SBTS${release_cu}_${version_cu}_AVQE_AQQC.xml
    set suite variable    ${scf_name_du_AVQE_AQQC}    SCF_SBTS${release_du}_${version_du}_AVQE_AQQC.xml

Check Counters
    [Arguments]    ${counter_prefix}    ${counter_start}    ${counter_end}    ${counter_dimension}
    ${counter_values}    Create List
    FOR    ${counter}    IN RANGE    ${counter_start}    ${counter_end}
        ${counter_string}    Set Variable    ${counter_prefix}${counter}
        log to console    Checking counter: ${counter_string}
        ${counter_value_dict}    Get Pointed Counter For vDU    counter_id=${counter_string}    dimension_dn=${counter_dimension}
        ${counter_value}    Get From Dictionary    ${counter_value_dict}[0]    value
        Append To List    ${counter_values}    ${counter_value}
        # Add your counter checking logic here
    END
    [Return]    ${counter_values}

Check Sum Equality
    [Arguments]    ${list1}    ${list2}
    ${sum1}    Evaluate    sum([int(x) for x in ${list1}])
    ${sum2}    Evaluate    sum([int(x) for x in ${list2}])
    Should Not Be Equal    '${sum2}'    0    The sum of the second list is zero.
    Should Be Equal    ${sum1}    ${sum2}    The sums of the two lists are not equal.

