*** Settings ***
Documentation    This is common keywords for siso related cases
...              Please do not modify the file without notification to author

Resource      testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/siso_common_case/step_keywords/5G/ru_operation.robot
Resource      testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/siso_common_case/step_keywords/5G/recommissioning_and_make_throughput.robot
*** Variables ***

*** Keywords ***
General_Power_Consumption_and_Power_Saving_percentage_measured_in_Half_Load
    [Documentation]
    ...    *****************
    ...    [TEST PURPOSE] The purpose of this test is to verify Power Saving percentage measured in Half Load
    ...    ******************
    ...    History of changes
    ...    ******************
    ...    - 28.10.2020 - - Created
    ...    *******************
    ...    Owner_zhihao.shi@nokia-sbell.com
    [Arguments]  ${cell_id}=${1}    ${ue_index}=${0}    ${ul_tput}=100M    ${dl_tput}=300M
    @{split_version}    string.split string    ${Active_SW_version}    separator=_
    ${stream}    set variable     ${split_version}[0]
    Selenium Login And Disable Screen Lock    version=${stream}
    ${dl_tp}  ${ul_tp}  ${dl_exp}  ${ul_exp}    Calculate Send Tput And Expected Tput
    ...    peak_dl_tp=${dl_tput}    peak_ul_tp=${ul_tput}
    ${ue_type}    translate_power_ue_type_from_testline    ue_index=${ue_index}
    ${cell_mapping}    get_relation_mapping_between_cell_index_and_nrCellIdentity
    ${cell_id}    Convert To String    ${cell_mapping[${cell_id}]['nrCellIdentity']}
    ${cell_id}    Create List    ${cell_id}
    log to console   \n enable Power Saving mode
    Run Keyword If  '${stream}'!='SBTS22R2'
    ...    Check and Modify Single Parameter on WebUI    dist_name=MRBTS-${mrbtsID}/NRBTS-${nrbtsID}
    ...    filter_param=Activate micro discontinued transmission advanced    abbr=actMicroDTXAdvanced    new_value=false
    log to console   \n enable Power Saving mode
    Check and Modify Single Parameter on WebUI    dist_name=MRBTS-${mrbtsID}/NRBTS-${nrbtsID}
    ...    filter_param=Activate micro discontinued transmission    abbr=actMicroDTX    new_value=true
    sleep  20
    power_ue.Prepare UE    ue_type=${ue_type}    ue_index=${ue_index}
    ${5Grach_ed}    power_ue.UE Attach    ue_type=${ue_type}    ue_index=${ue_index}
    power_ue.Start traffic    ue_type=${ue_type}    direction=dl    throughput=${dl_tp}
    ...    protocol=udp    duration=360    ue_index=${ue_index}
    power_ue.Start traffic    ue_type=${ue_type}    direction=ul    throughput=${ul_tp}
    ...    protocol=udp    duration=360    ue_index=${ue_index}
    sleep  40
    ${tput_log}    power_ue.Collect Tput    ue_type=${ue_type}    duration=60
    ${output}    power_ue.Check Bi Tput   ue_type=${ue_type}    log=${tput_log}    cells=${cell_id}    ultarget_throughput=${ul_exp}
    ...    dltarget_throughput=${dl_exp}    target_avg_percent=0.1    min_percent=0.1
    log to console    ${output}
    ${power_enable_with_call}  Get RMOD Power Measurement
    power_ue.Stop traffic    ue_type=${ue_type}    direction=dl    ue_index=${ue_index}
    power_ue.Stop traffic    ue_type=${ue_type}    direction=ul    ue_index=${ue_index}
    power_ue.UE Detach  ue_type=${ue_type}    ue_index=${ue_index}
    log to console   \n disable Power Saving mode
    Check and Modify Single Parameter on WebUI    dist_name=MRBTS-${mrbtsID}/NRBTS-${nrbtsID}
    ...    filter_param=Activate micro discontinued transmission    abbr=actMicroDTX    new_value=false
    sleep  20
    power_ue.Prepare UE    ue_type=${ue_type}    ue_index=${ue_index}
    ${5Grach_ed}    power_ue.UE Attach    ue_type=${ue_type}    ue_index=${ue_index}
    power_ue.Start traffic    ue_type=${ue_type}    direction=dl    throughput=${dl_tp}
    ...    protocol=udp    duration=360    ue_index=${ue_index}
    power_ue.Start traffic    ue_type=${ue_type}    direction=ul    throughput=${ul_tp}
    ...    protocol=udp    duration=360    ue_index=${ue_index}
    sleep  40
    ${tput_log}    power_ue.Collect Tput    ue_type=${ue_type}    duration=60
    ${output}    power_ue.Check Bi Tput   ue_type=${ue_type}    log=${tput_log}    cells=${cell_id}    ultarget_throughput=${ul_exp}
    ...    dltarget_throughput=${dl_exp}    target_avg_percent=0.1    min_percent=0.1
    log to console    ${output}
    ${power_disable_with_call}  Get RMOD Power Measurement
    power_ue.Stop traffic    ue_type=${ue_type}    direction=dl    ue_index=${ue_index}
    power_ue.Stop traffic    ue_type=${ue_type}    direction=ul    ue_index=${ue_index}
    power_ue.UE Detach  ue_type=${ue_type}    ue_index=${ue_index}
    ${p_value}    Evaluate    "%.3f" % ((${power_disable_with_call}-${power_enable_with_call})/${power_disable_with_call})
    ${per_value}    Evaluate    ${p_value}*100
    log to console   \n Power Saving Percent with half load:${per_value}%
    should be true      0 < ${p_value} < 0.1
    [Teardown]  selenium logout and close browser
