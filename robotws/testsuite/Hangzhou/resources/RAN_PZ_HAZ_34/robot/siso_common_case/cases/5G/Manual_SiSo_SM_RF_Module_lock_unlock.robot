*** Settings ***
Documentation    This is common keywords for siso related cases
...              Please do not modify the file without notification to author

Resource      testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/siso_common_case/step_keywords/5G/basic/bts_coam.robot
*** Variables ***

*** Keywords ***
Manual_SiSo_SM_RF_Module_lock_unlock
    [Documentation]
    ...    *****************
    ...    [TEST PURPOSE] The purpose of this test case is to verify that radio module
    ...    and OAM behaves correctly during procedure of locking and unlocking.
    ...    ******************
    ...    History of changes
    ...    ******************
    ...    - 2022.6.30 - - Created
    ...    *******************
    ...    Owner_jiayi.tang@nokia-sbell.com
    [Arguments]     ${ue_index}=0    ${power_reset}=False
    ...    ${dl_tp}=100MKbits/sec    ${apn_address}=dxdata1    ${duration}=600    ${ul_tp}=100MKbits/sec    ${iperf_type}=via_app
    ...    ${log_duration}=3m    ${ul_target}=100    ${dl_target}=100    ${avg_percent}=0.5    ${min_percent}=0.5
    ${ru_index_list}    get all ru index
    Selenium Login And Disable Screen Lock
    ${ue_type}    translate_power_ue_type_from_testline    ue_index=${ue_index}
    set suite variable     ${ue_type}
    ${list_of_cell_ids}    Get List of NR Cell ID
    set suite variable     ${list_of_cell_ids}
    power_ue.Prepare UE    ue_index=${ue_index}    ue_type=${ue_type}    power_reset=${power_reset}
    FOR  ${lock_id}  IN  @{ru_index_list}
        Sleep    3s
        Make Call and Check TP    ue_index=${ue_index}    power_reset=${power_reset}    dl_tp=${dl_tp}    apn_address=${apn_address}
        ...    duration=${duration}
        ...    ul_tp=${ul_tp}    ul_target=${ul_target}    dl_target=${dl_target}    avg_percent=${avg_percent}    min_percent=${min_percent}
        ${operate_list}    create list    ${lock_id}
        Lock all RUs SISO    ru_index_list=${operate_list}
        Sleep    3s
        Unlock all RUs SISO    ru_index_list=${operate_list}
        Sleep    3s    
        ${log}    power_ue.Collect Tput    ue_type=${ue_type}    duration=${log_duration}
        power_ue.Check Bi Tput    ue_type=${ue_type}    log=${log}    cells=${list_of_cell_ids}
        ...    ultarget_throughput=${ul_target}    dltarget_throughput=${dl_target}
        ...    target_avg_percent=${avg_percent}    min_percent=${min_percent}
        log to console    \n***Stop traffic***
        power_ue.Stop traffic    ue_type=${ue_type}    ue_index=${ue_index}    direction=dl    apn_address=${apn_address}
        power_ue.Stop traffic    ue_type=${ue_type}    ue_index=${ue_index}    direction=ul    apn_address=${apn_address}
        log to console    \n***UE Detach***
        power_ue.UE Detach    ue_type=${ue_type}    ue_index=${ue_index}    power_reset=${power_reset}
    END
    [Teardown]    Manual_SiSo_SM_RF_Module_lock_unlock_Teardown

Make Call and Check TP
    [Arguments]    ${ue_index}=0    ${power_reset}=False
    ...    ${dl_tp}=100MKbits/sec    ${apn_address}=dxdata1    ${duration}=600    ${ul_tp}=100MKbits/sec    ${iperf_type}=via_app
    ...    ${log_duration}=3m    ${ul_target}=100    ${dl_target}=100    ${avg_percent}=0.5    ${min_percent}=0.5
    log to console  \n***Start Call***
    csn.reset_cache
    ${5Grach_ed_0}    power_ue.UE Attach    ue_index=${ue_index}    ue_type=${ue_type}    log_type=Aasyslog    power_reset=${power_reset}
    power_ue.Verify attach    ue_type=${ue_type}   5Grach_ed=${5Grach_ed_0}    4G_check=False
    log to console    \n***Start traffic***
    power_ue.Start traffic    ue_type=${ue_type}    ue_index=${ue_index}    direction=dl    throughput=${dl_tp}
    ...    apn_address=${apn_address}    duration=${duration}
    power_ue.Start traffic    ue_type=${ue_type}    ue_index=${ue_index}    direction=ul     throughput=${ul_tp}
    ...    apn_address=${apn_address}    duration=${duration}    iperf_type=${iperf_type}
    ${log}    power_ue.Collect Tput    ue_type=${ue_type}    duration=${log_duration}
    ${all_tp}    power_ue.Check Bi Tput    ue_type=${ue_type}    log=${log}    cells=${list_of_cell_ids}
    ...    ultarget_throughput=${ul_target}    dltarget_throughput=${dl_target}
    ...    target_avg_percent=${avg_percent}    min_percent=${min_percent}

Manual_SiSo_SM_RF_Module_lock_unlock_Teardown
    Selenium Logout And Close Browser
