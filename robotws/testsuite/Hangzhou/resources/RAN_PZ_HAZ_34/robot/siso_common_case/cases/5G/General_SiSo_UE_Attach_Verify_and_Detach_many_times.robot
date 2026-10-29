*** Settings ***
Documentation    This is common keywords for siso related cases
...              Please do not modify the file without notification to author

Library       testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/siso_common_case/lib/kpi_calculate.py
Resource      testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/siso_common_case/step_keywords/5G/basic/ue.robot
*** Variables ***

*** Keywords ***
General_SiSo_UE_Attach_Verify_and_Detach_many_times
    [Documentation]
    ...    *****************
    ...    [TEST PURPOSE] Purpose of this case to check ue attach
    ...    ******************
    ...    History of changes
    ...    ******************
    ...    - 02.03.2022 - - Created
    ...    - 07.05.2022 - - Modify verify to check pm kpi
    ...    - 08.06.2022 - - Add new kpi
    ...    *******************
    ...    Owner_tingting.zhong@nokia-sbell.com
    [Arguments]  ${total_times}=${50}    ${duration}=10    ${connection}=GNB_OAM
    ...    ${5013a_ratio}=${90}    ${5022a_ratio}=${100}    ${5009a_ratio}=${100}    ${5021a_ratio}=${100}
    ...    ${5006a_ratio}=${0}
    coam.reset_site    connection=${connection}    graceful_cell_shutdown=${False}
    coam wait gnb and cells ready    timeout=15min    gnb_type='${gNb_CuType}'
    ${cell_list}    get all cell id    connection=${connection}
    FOR    ${cell}    IN    @{cell_list}
        ${new_cell_list}    create list    ${cell}
        ${ue_index_list}    ${new_cell_list}    Get UE List for Given Cell List    cell_list=${new_cell_list}    ue_num_each_call=1
        exit for loop if    ${ue_index_list}!=${None}
    END
    ${ue_index}    set variable    ${ue_index_list[0]}
    ${cell_id}    set variable    ${new_cell_list[0]}
    ${ue_type}    translate_power_ue_type_from_testline    ue_index=${ue_index}
    FOR    ${itime}    IN RANGE    1    ${total_times}+1
        Log to console    \n---------------------\nue attach detach: ${itime}/${total_times}
        run keyword and ignore error    power_ue.Prepare UE    ue_type=${ue_type}    ue_index=${ue_index}
        ${5Grach_ed}    power_ue.UE Attach    ue_type=${ue_type}    ue_index=${ue_index}
        run keyword and ignore error    power_ue.UE Detach  ue_type=${ue_type}    ue_index=${ue_index}
    END
    ${all_cell_flag}    set variable    ${True}
    FOR    ${cell}    IN    @{cell_list}
        ${pass_radio}     ${numerator}    ${denominator}    rach_setup_success_ratio    cell_id=${cell}    connection=${connection}
        ${pass_radio}    convert to number    ${pass_radio}
        log to console    \nCELL_${cell}_NR_5013A: ${numerator}/${denominator}=${pass_radio}%
        ${pass_radio_2}     ${numerator}    ${denominator}     rach_setup_success_ratio_2    cell_id=${cell}    connection=${connection}
        ${pass_radio_2}    convert to number    ${pass_radio_2}
        log to console    \nCELL_${cell}_NR_5022A: ${numerator}/${denominator}=${pass_radio_2}%,
        ${pass_radio_5}     ${numerator}    ${denominator}    rach_setup_success_ratio_5    cell_id=${cell}    connection=${connection}
        ${pass_radio_5}    convert to number    ${pass_radio_5}
        log to console    \nCELL_${cell}_NR_5009A: ${numerator}/${denominator}=${pass_radio_5}%
        ${status}    run keyword if    '${cell}'=='${cell_id}'
        ...    run keyword and return status    should be true
        ...    ${pass_radio}>=${5013a_ratio} and ${pass_radio_2}>=${5022a_ratio} and ${pass_radio_5}>=${5009a_ratio}
        ...    ELSE    run keyword and return status    should be true
        ...    ${pass_radio}==${0} and ${pass_radio_2}==${0} and ${pass_radio_5}==${0}
        ${all_cell_flag}    set variable if    ${status}    ${all_cell_flag}    ${False}
        continue for loop if    '${gNb_CuType}'!='NSA'
        ${pass_radio_3}     ${numerator}    ${denominator}    rach_setup_success_ratio_3    cell_id=${cell}    connection=${connection}
        ${pass_radio_3}    convert to number    ${pass_radio_3}
        log to console    \nCELL_${cell}_NR_5021A: ${numerator}/${denominator}=${pass_radio_3}%
        ${pass_radio_4}     ${numerator}    ${denominator}    rach_setup_success_ratio_4   cell_id=${cell}    connection=${connection}
        ${pass_radio_4}    convert to number    ${pass_radio_4}
        log to console    \nCELL_${cell}_NR_5006A: ${numerator}/${denominator}=${pass_radio_4}%
        ${status}    run keyword if    '${cell}'=='${cell_id}'
        ...    run keyword and return status    should be true    ${pass_radio_3}>=${5021a_ratio} and ${pass_radio_4}<=${5006a_ratio}
        ...    ELSE    run keyword and return status    should be true    ${pass_radio_3}==${0} and ${pass_radio_4}==${0}
        ${all_cell_flag}    set variable if    ${status}    ${all_cell_flag}    ${False}
    END
    should be true    ${all_cell_flag}
