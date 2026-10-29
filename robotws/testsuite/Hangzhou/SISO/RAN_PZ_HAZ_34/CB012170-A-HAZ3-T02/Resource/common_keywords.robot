*** Settings ***
Documentation    This is common keywords for CB012170 case
...              Please do not modify the file without notification to author
...              Contact: jiangrong.wang@nokia-sbell.com
...              Squard: RAN_PZ_HAZ3_SG02

Library     testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/python/throughput/nrdim_throughput/interface.py
#Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/siso_common_case/step_keywords/Common/scf_comm_operation.robot
#Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/siso_common_case/step_keywords/Common/basic/simple_ue.robot
Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/siso_common_case/cases/5G/Cell/General_SiSo_Cell_block_and_unblock.robot
Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/coam_gnb_classical.robot
Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/power_ue/power_ue.robot
Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/robot_common_operations/interface.robot
Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/siso_common_case/step_keywords/5G/basic/bts_coam.robot
Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/CI_Operations/CI_interface.robot
Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/siso_common_case/variable/Variables_5G.robot
Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/siso_common_case/cases/5G//5G_Setup_And_Teardown.robot
Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/bts/common/selenium.robot
Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/siso_common_case/cases/5G/E2E_SiSo_RU_lock_and_unlock_gNB.robot

#Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/lines/MMW_SG5/robot/siso_common_keywords.robot
#Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/lines/MMW_SG5/class_monitor.robot

*** KeyWords ***

Lock RU and Check Status
    [Arguments]    ${ru_list}    ${all_cell}=${true}    ${gnb_type}=NSA
    FOR    ${c_list}    IN    @{ru_list}
         Perform RU lock via rest api      ru_idx=${c_list}      timeout=90
    END
    FOR    ${c_list}    IN    @{ru_list}
         Wait until keyword succeeds    3min    20 sec    RU Should Be Locked    ru_index=${c_list}
    END
    Run keyword If    ${all_cell} and '${gnb_type}' =='NSA'
    ...   Wait until keyword succeeds    3min    20 sec    Expect Fault Should Present    faultId=7300
    Run keyword If    ${all_cell} and '${gnb_type}' =='NSA'
    ...   Wait until keyword succeeds    3min    20 sec    Expect Fault Should Present    faultId=7319

Unlock RU and Check Status
    [Arguments]    ${allowed_faults}    ${ru_list}
    FOR    ${c_list}    IN    @{ru_list}
         Perform RU unlock via rest api    ru_idx=${c_list}
    END
    COAM Wait for gnb ready and cell setup
    FOR    ${c_list}    IN    @{ru_list}
         RU Should Be Unlocked    ru_index=${c_list}
    END
    Wait until keyword succeeds    3min    20 sec    Unexpect Alarm Should Not Exist    allowed_faults=${allowed_faults}


Check cell EnergySaving state via COAM
    [Arguments]    ${cellID}=1    ${class_name}=NRCELL_R    ${connection}=GNB_OAM
    ...         ${expect_energySavingState}=notEnergySaving
    ${managed_objects}   coam.get_managed_objects   class_name=${class_name}   connection=${connection}
    FOR  ${cellinfo}   IN  @{managed_objects}
         ${nrcell_r}    Run Keyword If   ${cellinfo['distName'].count('NRCELL_R-${cellID}')} > 0
         ...   set variable    ${cellinfo['distName']}
         exit for loop if   ${cellinfo['distName'].count('NRCELL_R-${cellID}')} > 0
    END
    ${cell_specific_info}   coam.get_cell_specific_info   cell_id=${nrcell_r}   connection=${connection}
    ${energy_State}   set variable   ${cell_specific_info['energySavingState']}
    Should Be Equal As Strings    ${energy_State}   ${expect_energySavingState}

Online change actSSBBoostInmMIMOMuting
    [Arguments]    ${value}=true
    Log To Console    \n-------------Online change actSSBBoostInmMIMOMuting to True--------------
    Modify Parameter On BTS With Activate    dist_name=MRBTS-${MRBTS_ID}/NRBTS-${NRBTS_ID}
    ...    parameter=actSSBBoostInmMIMOMuting    value=${value}
    CI_commssion.Verify all cells should be Online

get CB012170 counters value
    [Arguments]   ${connection}=GNB_OAM    ${timeout}=${60}
    Connect to Common Unit Master    alias=ASIK Master
    ${count_path}    Set Variable   BTS/MRBTS-${MRBTS_ID}/NRBTS-${NRBTS_ID}/NRCELL-${random_cell_id}/NREIRP
    ${value_list}    Create List
    ${convert_counters}    Catenate    SEPARATOR=,    @{EIRP_counters_list}
    Log to console    Wait Until Next Counter Update
    Wait Until Next Counter Update 561
    ${counter_groups}    coam.get_pm_counters    counter_ids=${convert_counters}    connection=${connection}
    ...    timeout=${timeout}
    ${counter_group_keys} =    Split String    ${count_path}    /
    FOR    ${group}    IN     @{counter_group_keys}
        ${counter_groups} =    Get From Dictionary    ${counter_groups}    ${group}
    END
    Set test variable    ${counter_groups}
    FOR    ${counter_name}    IN    @{EIRP_counters_list}
        ${counter_value}   get CB012170 counter Recent value   counter_name=${counter_name}
        append to list    ${value_list}    ${counter_value}
    END
    log to console    EIRP PM counters are ${value_list}
    [return]    ${value_list}

get CB012170 counter Recent value
    [Arguments]   ${counter_name}
    ${counter_values} =    Get From Dictionary    ${counter_groups}    ${counter_name}
    ${key_list} =     Get Dictionary Keys    ${counter_values}
    ${latest_value} =    Get From Dictionary    ${counter_values}    ${key_list[-1]}
    [return]    ${latest_value}


Compare counters
    [Arguments]    ${counters_1}    ${counters_2}
    ${counters_1_length}    Get Length    ${counters_1}
    ${counters_2_length}    Get Length    ${counters_2}
    Log To Console    \n-------------Compare counters--------------
    Should Be True    ${counters_1_length} == ${counters_2_length}
    FOR    ${counter_index}    IN RANGE    ${counters_1_length}
        Should Be True    ${counters_2}[${counter_index}] > ${counters_1}[${counter_index}]
    END


Get EIRP PM counters
    Log To Console    \n-------------Get EIRP PM counters--------------
    ${EIRP_counters_list}   create list
    FOR    ${num}    IN RANGE    0    8
        append to list    ${EIRP_counters_list}    M55324C0040${num}
    END
    FOR    ${num}    IN RANGE    1    61
        ${counter_id}    set variable if     ${num} < 10    M55324C0010${num}    M55324C001${num}
        append to list    ${EIRP_counters_list}    ${counter_id}
    END
    FOR    ${num}    IN RANGE    1    61
        ${counter_id}    set variable if     ${num} < 10    M55324C0020${num}    M55324C002${num}
        append to list    ${EIRP_counters_list}    ${counter_id}
    END
    FOR    ${num}    IN RANGE    1    61
        ${counter_id}    set variable if     ${num} < 10    M55324C0050${num}    M55324C005${num}
        append to list    ${EIRP_counters_list}    ${counter_id}
    END
    FOR    ${num}    IN RANGE    1    61
        ${counter_id}    set variable if     ${num} < 10    M55324C0060${num}    M55324C006${num}
        append to list    ${EIRP_counters_list}    ${counter_id}
    END
    FOR    ${num}    IN RANGE    1    61
        ${counter_id}    set variable if     ${num} < 10    M55324C0070${num}    M55324C007${num}
        append to list    ${EIRP_counters_list}    ${counter_id}
    END
    ${eirp_cell_counter_list}    create list   M55324C00800  M55324C00801  M55324C00802  M55324C00464
    ${counters_length}    Get Length    ${eirp_cell_counter_list}
    FOR  ${counter_index}  IN RANGE    ${counters_length}
        append to list    ${EIRP_counters_list}    ${eirp_cell_counter_list}[${counter_index}]
    END
    log to console    EIRP PM counters are ${EIRP_counters_list}
    Set test variable    ${EIRP_counters_list}

Modify Parameter On BTS With Activate
    [Arguments]    ${dist_name}    ${parameter}    ${value}    ${connection}=GNB_OAM
    coam.perform_parameter_recommissioning    dist_name=${dist_name}
    ...    parameter=${parameter}    value=${value}    operation=update
    ...    skip_parameter_relation_errors=true    connection=${connection}

case setup
    Wait Until Keyword Succeeds    1 min    3 sec    Connect to gnb coam via ssl
    CI_interface.Common Case Setup
    robot_common_operations.Common Case Setup

case teardown
    run keyword and ignore error    COAM Teardown gnb connections
    CI_interface.Common Case Teardown
    robot_common_operations.Common Case Teardown
    #Run Keyword And Continue On Failure    Check for unexpected alarms
    #Run Keyword And Continue On Failure    Save Coam Snapshot
    #Run keyword and ignore error    COAM Teardown gnb connections
    #Run keyword and ignore error    CI_interface.Common Case Teardown

suit setup
    SISO Coam Suite Setup
    #Wait Until Keyword Succeeds    1 min    3 sec    Connect to gnb coam via ssl

#Disable CB012170


#Check bip when enable CB012170

#Check bip when disable CB012170

