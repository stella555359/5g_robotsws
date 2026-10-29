*** Settings ***
Documentation    This is common keywords for siso KPI related cases
...              Please do not modify the file without notification to author
...              Author: zhao nana
...              Contact: nana.zhao@nokia-sbell.com
...              Squard: MMW2

Library    ./get_average_time.py
Library    taf.config.testline.info.testline_info.TestlineInfo    WITH NAME    testline_info
Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/coam_gnb_classical.robot
#Resource    ../../../../../resources/common/coam_cu.robot
Resource    ../../common/siso_cloud_coam_common_keyword.robot
Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/robot_common_operations/interface.robot

*** Variables ***
${SUCCESS_TIMES}              0
${FAILED_TIMES}               0
${MAX_FAILED_TIMES}           5
${TS_CASE_LOG_PATH}           /home/ute/TAF/Case_Logs/
${SNAPSHOT_TIMEOUT}           300
${RAP_NUMBER}

@{TOTAL_STARTUP_TIME_LIST}
@{BEGIN_RESET_TIME}
@{AFTER_RESET_TIME}


*** Keywords ***
Multi_DU_Cases_Common_Coam_Cloud_Suite_Setup
    robot_common_operations.Common Suite Setup
    FOR    ${index}    IN RANGE    ${RAP_NUMBER}
        ssh.reset cache
        Cloud DU connect to gnb coam via ssl    connection=GNB_OAM_${index}    bts_host=${tl.gnbs[0].dus[${index}].f1_m_ip_addr}
    END

Multi_DU_Cases_Common_Coam_Cloud_Suite_Teardown
    robot_common_operations.Common Suite Teardown
    FOR    ${index}    IN RANGE    ${RAP_NUMBER}
        COAM Teardown gnb connections    connection=GNB_OAM_${index}
        ssh.reset cache
    END

Multi_DU_Cases_Common_Coam_Cloud_Recover_Env
    [Documentation]    Author: yanfen chen
    ...   This keyword is to check if du is lost, then
    ...   power off/on DU to recover it.
    FOR    ${index}    IN RANGE    ${RAP_NUMBER}
        ${ping_output}  Run  ping -c 1 -W 10 ${tl.gnbs[0].dus[${index}].f1_m_ip_addr}
        ${status}    run keyword and return status    Should contain      ${ping_output}   1 packets transmitted, 0 received
        ${du_index}     set variable    ${index}
        run keyword if    '${status}'=='True'    DU_Power_and_Wait_onair    du_index=${du_index}
    END

DU_Power_and_Wait_onair
    [Documentation]    Author: yanfen chen
    ...   This keyword power off and power on DU
    ...   and wait cell on air
    [Arguments]    ${connection}=GNB_OAM    ${du_index}=0
    Perform Site Power Off    du_index=${du_index}
    sleep    5s
    Perform Site Power On    du_index=${du_index}
    Wait Until Keyword Succeeds    3min    30s    Cloud DU connect to gnb coam via ssl    connection=GNB_OAM_${du_index}
    ...    bts_host=${tl.gnbs[0].dus[${du_index}].f1_m_ip_addr}
    run keyword and ignore error    Wait Until Keyword Succeeds    10min    1min    Verify all cells should be onair 
    ...    connection=GNB_OAM_${du_index}
    Catch_DU_Snapshot    connection=GNB_OAM_${du_index}
    #COAM Teardown gnb connections    connection=GNB_OAM_${du_index}

Multi_DU_Cases_Common_Wait_all_Cells_onair_cloud_Coam
    [Documentation]    Author: zhao nana
    ...   This keyword is to check all cells online
    [Arguments]    ${connection}=GNB_OAM
    FOR    ${index}    IN RANGE    ${RAP_NUMBER}
        ${status}    run keyword and return status
        ...    Wait Until Keyword Succeeds    10min    30s    Verify all cells should be onair    connection=GNB_OAM_${index}
        Run Keyword If    '${status}' == 'False'    Catch_DU_Snapshot    connection=GNB_OAM_${index}
        ...    ELSE    Run keywords    Get_Time_And_Append_list
        should be true    ${status}
    END
    [Return]    ${status}

Get_Time_And_Append_list
    [Arguments]    ${time_list}=${AFTER_RESET_TIME}
    ${time}=    Get Time    epoch
    Append to list    ${time_list}    ${time}

Multi_DU_Cases_Common_Caclulate_Startup_time
    [Arguments]    ${adjust_time}=0    ${MAX_TIME}=0
    @{startup_time}    Create list
    FOR    ${index}    IN RANGE    ${RAP_NUMBER}
        ${time}=    Calculate_timestamp    time1=${BEGIN_RESET_TIME[${index}]}    time2=${AFTER_RESET_TIME[${index}]}    time3=${adjust_time}
        Run Keyword If    '${time}' > '${MAX_TIME}'    Catch_DU_Snapshot    connection=GNB_OAM_${index}
        Append to list    ${startup_time}    ${time}
    END
    [Return]    ${startup_time}

Multi_DU_Cases_Common_After_Device_Reset_Procedure
    [Arguments]    ${status}='PASS'    ${time_list}=timelist
    Remove Values From List    ${BEGIN_RESET_TIME}    @{BEGIN_RESET_TIME}
    Remove Values From List    ${AFTER_RESET_TIME}    @{AFTER_RESET_TIME}
    run keyword if    '${status}'=='PASS'    Run keywords
    ...    caculate_success_times    AND    combine_startup_time_list    timelist=${time_list}
    ...    ELSE    Run keywords    caculate_failed_times
    Should be true    ${FAILED_TIMES} <= ${MAX_FAILED_TIMES}

Multi_DU_Cases_Common_Get_Rap_Number
    ${raps}    testline_info.get_du_list    ${tl}
    ${RAP_NUMBER}    Get Length    ${raps}
    set suite variable    ${RAP_NUMBER}
    log to console    rap number is ${RAP_NUMBER}

Catch_DU_Snapshot
    [Arguments]    ${connection}=connection
    COAM Save snapshot via rest api    ${connection}    timeout=${SNAPSHOT_TIMEOUT}

check_startup_success_rate
    [Arguments]    ${criteria}=0.97
    log to console      Success finish ${SUCCESS_TIMES} in  ${RESET_REPEAT_TIMES} times.PASS rate: (${SUCCESS_TIMES}/${RESET_REPEAT_TIMES})*100%
    ${SUCCESS_TIMES} =    Convert To Number    ${SUCCESS_TIMES}
    ${RESET_REPEAT_TIMES} =    Convert To Number    ${RESET_REPEAT_TIMES}
    Should Be True    ${SUCCESS_TIMES}/${RESET_REPEAT_TIMES} >= ${criteria}

Calculate_timestamp
    [Arguments]    ${time1}=before_time    ${time2}=after_time    ${time3}=0
    ${timediff}    Evaluate    ${time2}-${time1}-${time3}
    [Return]    ${timediff}

check_gnb_startup_time
    [arguments]    ${startup_time_list}    ${criteria_avg}=420    ${criteria_max}=450
    Log To Console    start to check gnb cell startup time
    sort list      ${startup_time_list}
    ${startup_time_biggest}      get from list      ${startup_time_list}    -1
    ${startup_avg_time}    get_average_time.calculate_avg_list    ${startup_time_list}
    ${result}    Evaluate    ${startup_time_biggest} <= ${criteria_max}
    ${status}    Evaluate    ${startup_avg_time} <= ${criteria_avg}
    log to console    actual max time is ${startup_time_biggest}, criteria max time is ${criteria_max}
    log to console    actual avg time is ${startup_avg_time}, criteria avg time is ${criteria_avg}
    Should Be True    ${result}
    Should Be True    ${status}

caculate_success_times
    ${times}    Evaluate    ${SUCCESS_TIMES}+1
    set suite variable    ${SUCCESS_TIMES}    ${times}

caculate_failed_times
    ${times}    Evaluate    ${FAILED_TIMES}+1
    set suite variable    ${FAILED_TIMES}    ${times}

combine_startup_time_list
    [Arguments]     ${timelist}
    ${TOTAL_STARTUP_TIME_LIST}    combine lists    ${TOTAL_STARTUP_TIME_LIST}    ${timelist}
    set suite variable     @{TOTAL_STARTUP_TIME_LIST}

Verify first cell onair
    [Documentation]    Author: helen.1.chen
    ...                Description: verify first the cell status should be correct.
    [Arguments]    ${connection}=GNB_OAM
    Log to console    Verify first cell is on air
    ${cell_info}   coam.get_subcells_status   timeout=20    connection=${connection}
    ${cell_info_dictionary}    get dictionary values    ${cell_info}
    ${cell_info_list}    get from list    ${cell_info_dictionary}    0
    ${cell_status}    First cell should be onair    cell_info_list=${cell_info_list}
    Should Be Equal As Strings    ${cell_status}     True

First cell should be onair
    [Documentation]    Author: helen.1.chen
    [Arguments]   ${cell_info_list}
    ${cell_list}    Get Dictionary Keys    ${cell_info_list}
    FOR  ${cell}  IN   @{cell_list}
        ${eachcell}    Get from Dictionary    ${cell_info_list}    ${cell}
        ${cell_status}    Run Keyword And Return Status    Check_Cell_Status    check_cell=${eachcell}
        exit for loop if    '${cell_status}' == 'True'
    END
    [Return]    ${cell_status}

Check_Cell_Status
    [Arguments]    ${check_cell}
    Should Be Equal As Strings    ${check_cell['NRCELL_R']['administrativeState']}     Unlocked
    Should Be Equal As Strings    ${check_cell['NRCELL_R']['availabilityStatus']}   Online
    Should Be Equal As Strings    ${check_cell['NRCELL_R']['operationalState']}   Enabled

Multi_DU_Cases_Common_Wait_first_Cell_onair_cloud_Coam
    [Documentation]    Author: zhao nana
    ...   This keyword is to check all cells onlIN RANGEe
    [Arguments]    ${connection}=GNB_OAM
    FOR    ${index}    IN RANGE    ${RAP_NUMBER}
       ${status}    run keyword and return status
        ...    Wait Until Keyword Succeeds    10m    30s    Verify first cell onair    connection=GNB_OAM_${index}
       Run Keyword If    '${status}' == 'False'    Catch_DU_Snapshot    connection=GNB_OAM_${index}
        ...    ELSE    Run keywords    Get_Time_And_Append_list
       should be true    ${status}
    END
    [Return]    ${status}

Check_Lock_UnLock_Cell_Status
    [Arguments]    ${cell_status}    ${cell_index}    ${connection}
	${cell_info}    coam.get_cell_specific_info    cell_id=${object}${cell_index}    connection=${connection}
    ${cell_info_dict}    get from dictionary    ${cell_info}    status
    Run Keyword If    '${cell_status}' == 'Locked'    run keywords
    ...    Should Be Equal As Strings    ${cell_info_dict['administrativeState']}   ${cell_status}
    ...    AND    Should Be Equal As Strings    ${cell_info_dict['availabilityStatus']}   Offline
    ...    AND    Should Be Equal As Strings    ${cell_info_dict['operationalState']}   Disabled
    Run Keyword If    '${cell_status}' == 'Unlocked'    run keywords
    ...    Should Be Equal As Strings    ${cell_info_dict['administrativeState']}   ${cell_status}
    ...    AND    Should Be Equal As Strings    ${cell_info_dict['availabilityStatus']}   Online
    ...    AND    Should Be Equal As Strings    ${cell_info_dict['operationalState']}   Enabled
