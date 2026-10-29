*** Settings ***
Resource      testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/siso_common_case/step_keywords/Cloud/cloud_prach.robot
Resource      testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/siso_common_case/step_keywords/Cloud/cloud_ru.robot

*** Keywords ***
Cloud_General_SiSo_E2E_system_setup_with_data_transfer_for_conducted_multicarrier_MADE2_radio
    [Arguments]  ${prach_index_list}    ${ue_num_each_call}=1    ${duration}=${60}
    ...    ${suite_name}=default    ${test_name}=default    ${gnb_index}=0    ${vdu_index}=0
    ...    ${mobile_network_system}=NR    ${check_wait_time}=${60}    ${scf_path}=${Golden_VDU_SCF_Path}
    [Documentation]    *****************
    ...    - [TEST PURPOSE] The purpose of this keyword is to check if calibration of beamforming can be activated
    ...    - [TEST PROCEDURE] The test procedure is as follows:
    ...        1. Modify prach.
    ...        2. Make L3 call for every prach.
    ...        3. Lock the cell during L3 call.
    ...        4. Unlock the cell during L3 call.
    ...    - [EXPECTED RESULTS] Make L3call success for every prach and lock/unlock cell is normal during L3 call.
    ...
    ...    | =Input Parameters= | =Mandatory= | =Description= |
    ...    | prach_index_list | Yes | The list of prach index. |
    ...    | ue_num_each_call | No | The number of UE for each call. Default value is 1. |
    ...    | duration | No | The duration of the test. Default value is 60. |
    ...    | mobile_network_system | No | The mobile network system. Default value is NR. |
    ...    | check_wait_time | No | The check wait time. Default value is 60. |
    ...    | vdu_index | No | The vDU index. Default value is 0. |
    ...    | gnb_index | No | The gNB index. Default value is 0. |
    ...    | suite_name | No | The suite name used for customed peak rate. Default value is default. |
    ...    | test_name | No | The test name used for customed peak rate. Default value is default. |

    ...    *******************
    ...    History of changes
    ...    ******************
    ...    - 21.06.2024 - - Created
    ...    *******************
    ...    * Owner: shifu.lan@nokia-sbell.com
    ...    * Group: VRF_HAZ4_T04
    ...    *******************
    ${cell_list}    vDU Get Cell List From Webem    gnb_index=${gnb_index}    vdu_index=${vdu_index}
    ${modify_prach_cell_list}    Get Modify Prach Cell List    cell_list=${cell_list}    gnb_index=${gnb_index}    vdu_index=${vdu_index}
    FOR    ${prach_index}    IN    @{prach_index_list}
        log to console    modify prach index to ${prach_index}
        Modify Prach Index Via Webem    cell_list=${modify_prach_cell_list}    prach_index=${prach_index}
        ...    gnb_index=${gnb_index}    vdu_index=${vdu_index}
        Run Keyword And Continue On Failure    Cloud UE L3 Call And Throughput    cell_list=${modify_prach_cell_list}    duration=${duration}
        ...    ue_num_for_call_per_cell=${ue_num_each_call}    test_name=${test_name}    suite_name=${suite_name}
    END
    FOR    ${cell_id}    IN    @{cell_list}
        ${lock_cell_list}    Create List    ${cell_id}
        ${new_cell_list}    Get Cell List Except Specific Cell    cell_list=${cell_list}    cell_id=${cell_id}
        ${ue_index_list}    ${cell_and_peak_info}    Cloud UE L3 Call Preparation    cell_list=${new_cell_list}    duration=${duration}
        Simple Ue Prepare    ue_index_list=${ue_index_list}    scf_path=${scf_path}    mobile_network_system=${mobile_network_system}
        ${ue_and_cell}    Simple Ue Attach and Start Traffic    ue_index_list=${ue_index_list}    cell_and_peak_info=${cell_and_peak_info}
        ...    mobile_network_system=${mobile_network_system}    scf_path=${scf_path}    duration=${duration}
        sleep    ${check_wait_time}
        ${tput_log_before_lock}    Cloud Collect Tput from VDU    duration=${duration}
        Cloud UE Verify Peak Throughput    ue_index_list=${ue_index_list}    ue_and_cell=${ue_and_cell}
        ...    cell_and_peak_info=${cell_and_peak_info}    log=${tput_log_before_lock}
        ...    mobile_network_system=${mobile_network_system}

        # Lock cell
        log to console    \nLock the cell ${lock_cell_list} on vDU
        Lock Cell on vDU    vdu_index=${vdu_index}    gnb_index=${gnb_index}     cell_id=${lock_cell_list}
        Wait Until Keyword Succeeds    3min    5s    vDU Cells Status Should Be As Expected     cells_id_list=${lock_cell_list}
        ...    vdu_index=${vdu_index}    gnb_index=${gnb_index}    administrative_state=Locked    operational_state=disabled
        ...   availability_status=off line    blocking_state=Unblocked
        sleep    ${check_wait_time}
        ${tput_log_during_lock}    Cloud Collect Tput from VDU    duration=${duration}
        Cloud UE Verify Peak Throughput    ue_index_list=${ue_index_list}    ue_and_cell=${ue_and_cell}
        ...    cell_and_peak_info=${cell_and_peak_info}    log=${tput_log_during_lock}
        ...    mobile_network_system=${mobile_network_system}

        # Unlock cell
        log to console    \nUnlock the cell ${lock_cell_list} on vDU
        Unlock Cell on vDU    vdu_index=${vdu_index}    gnb_index=${gnb_index}    cell_id=${lock_cell_list}
        log to console    All Cells Should Be Onair For All vDUs
        Wait Until Keyword Succeeds    15min    5s    All Cells Should Be Onair For All vDUs

        sleep    ${check_wait_time}
        ${tput_log_after_ulock}    Cloud Collect Tput from VDU    duration=${duration}
        Cloud UE Verify Peak Throughput    ue_index_list=${ue_index_list}    ue_and_cell=${ue_and_cell}
        ...    cell_and_peak_info=${cell_and_peak_info}    log=${tput_log_after_ulock}
        ...    mobile_network_system=${mobile_network_system}
        Simple Ue Stop DL UL Traffic    ue_index_list=${ue_index_list}
        Simple Ue Detach    ue_index_list=${ue_index_list}
    END
