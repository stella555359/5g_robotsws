*** Settings ***
Documentation    This is common keywords for siso related cases
...              Please do not modify the file without notification to author

Library       taf.ul.power_ue    WITH NAME    ul_power_ue
Library       testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/siso_common_case/lib/mcs_config.py
Resource      testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/siso_common_case/step_keywords/5G/recommissioning_and_make_throughput.robot
*** Variables ***

*** Keywords ***
Multi_Cell_configuration_interation_with_Beamforming_and_Carrier_Aggregation
    [Documentation]
    ...    *****************
    ...    [TEST PURPOSE] Purpose of this case is to validate the Intra Band Carrier Aggregation on single RFM, cover
    ...    both DL and UL CA, check multi Cell Beamforming function interaciton, check CP_Beamset with all Cusotmized,
    ...    Dynamic, DFT, DFTTapring, DTFTapingUL, MMSE beamforming on multi cells.
    ...    ******************
    ...    History of changes
    ...    ******************
    ...    - 04.06.2024 - - Created
    ...    *******************
    ...    Owner_tingting.zhong@nokia-sbell.com
    [Arguments]    ${pcell_percent}=1    ${scell_percent}=1    ${scf_path}=${Case_SCF_Path}    ${direction}=dl
    ...    ${suite_name}=default   ${test_name}=default    ${scf_path}=${Case_SCF_Path}
    check_mcs_by_csv    scf_path=${scf_path}
    ${cell_list}    Get All Cell Id
    ${cell_and_peak_info}    Generate Peak Information    cell_list=${cell_list}
    ...    suite_name=${suite_name}    test_name=${test_name}
    ${ue_index_list}    ${get_cell_list}    Get UE List for Given Cell List    cell_list=${cell_list}    ue_num_each_call=${1}
    ...    scf_path=${scf_path}
    ${new_cell_and_peak_info}    Generate CA Throughput    cell_and_peak_info=${cell_and_peak_info}
    ...    pcell_id=${get_cell_list[0]}   pcell_percent=${pcell_percent}    scell_percent=${scell_percent}
    CA UE Call And Throughput With Loop    ue_index_list=${ue_index_list}
    ...    cell_list=${cell_list}    cell_and_peak_info=${new_cell_and_peak_info}    direction=${direction}
    ...    attach_cell_id=${get_cell_list[0]}

Generate CA Throughput
    [Arguments]  ${cell_and_peak_info}    ${pcell_id}=1    ${pcell_percent}=1    ${scell_percent}=1    ${duration}=${300}
    ${new_cell_and_peak_info}    Create Dictionary
    FOR    ${cell_id}    IN    @{cell_and_peak_info.keys()}
        ${cell_id}    Convert To String    ${cell_id}
        ${peak_info}    Get From Dictionary    ${cell_and_peak_info}    ${cell_id}
        ${percent}    Set Variable If    '${cell_id}'=='${pcell_id}'    ${pcell_percent}    ${scell_percent}
        ${peak_dl_tp}    Evaluate    ${peak_info['peak_dl_tp']}*${percent}
        Set To Dictionary    ${peak_info}    peak_dl_tp=${peak_dl_tp}
        ${peak_ul_tp}    Evaluate    ${peak_info['peak_ul_tp']}*${percent}
        Set To Dictionary    ${peak_info}    peak_ul_tp=${peak_ul_tp}
        Set To Dictionary    ${peak_info}    duration=${duration}
        ${peak_info}    Get From Dictionary    ${cell_and_peak_info}    ${cell_id}
        Set To Dictionary    ${new_cell_and_peak_info}    ${cell_id}    ${peak_info}
    END
    Log To Console    new cell_and_peak_info: ${cell_and_peak_info}
    [Return]    ${new_cell_and_peak_info}

CA UE Call And Throughput
    [Arguments]    ${ue_index_list}    ${cell_list}    ${cell_and_peak_info}    ${direction}    ${attach_cell_id}
    ...    ${duration}=${300}    ${reboot_limit_time}=${1}
    ${dl_tp}    Set Variable    ${0}
    ${ul_tp}    Set Variable    ${0}
    FOR    ${cell_id}    IN    @{cell_list}
        ${cell_id}    Convert To String    ${cell_id}
        ${peak_info}    Get From Dictionary    ${cell_and_peak_info}    ${cell_id}
        ${dl_tp}    Evaluate    ${peak_info['peak_dl_tp']}+${dl_tp}
        ${ul_tp}    Evaluate    ${peak_info['peak_ul_tp']}+${ul_tp}
    END
    ${status}    ${ue_and_cell}    run keyword and ignore error    Ue Attach and Start DL UL Traffic
    ...    ue_index_list=${ue_index_list}    dl_tp=${dl_tp}M  ul_tp=${ul_tp}M
    ...    direction=${direction}    attach_cell_id=${attach_cell_id}    duration=${duration}    direction=${direction}
    ${ue_reboot_flag}    set variable if    '${status}'=='PASS'    ${False}    ${True}
    should be equal as strings    ${status}    PASS    msg=attach failed
    ${ue_and_cell}    create dictionary    ${ue_index_list[0]}_1=${cell_list[0]}    ${ue_index_list[0]}_2=${cell_list[1]}
    ${status}    ${all_tput}    run keyword and ignore error    UE Verify Peak Throughput    ue_index_list=${ue_and_cell.keys()}
    ...    ue_and_cell=${ue_and_cell}    cell_and_peak_info=${cell_and_peak_info}    duration=${duration}
    ...    direction=${direction}
    ${ue_reboot_flag}    set variable if    '${status}'=='PASS'    ${ue_reboot_flag}    ${True}
    should be equal as strings    ${status}    PASS    msg=verify throughput failed
    [Teardown]    Run Keywords   Ue Stop DL UL Traffic and Detach    ue_index_list=${ue_index_list}
    ...    reboot_ue=${ue_reboot_flag}    reboot_limit_time=${reboot_limit_time}    AND
    ...    Teardown UEs    ue_index_list=${ue_index_list}

CA UE Call And Throughput With Loop
    [Arguments]  ${ue_index_list}    ${cell_list}    ${cell_and_peak_info}    ${direction}    ${attach_cell_id}
    ...    ${duration}=${300}    ${reboot_limit_time}=${1}    ${loop_times}=${2}
    ${status}    set variable    PASS
    FOR    ${i}    IN RANGE    ${loop_times}
        log to console    \n***CA UE Call And Throughput ${i+1}***
        ${status}    ${repr}    run keyword and ignore error    CA UE Call And Throughput    ue_index_list=${ue_index_list}
        ...    cell_list=${cell_list}    cell_and_peak_info=${cell_and_peak_info}    direction=${direction}
        ...    attach_cell_id=${attach_cell_id}    duration=${duration}
        ...    reboot_limit_time=${reboot_limit_time}
        exit for loop if    '${status}'=='PASS'
    END
    should be true    '${status}'=='PASS'    msg=${repr}
