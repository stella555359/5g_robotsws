*** Settings ***
Documentation    This is common keywords for siso related cases
...              Please do not modify the file without notification to author

Resource      testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/siso_common_case/step_keywords/5G/basic/bts_selenium.robot
Resource      testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/siso_common_case/step_keywords/5G/ru_operation.robot
Resource      testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/siso_common_case/step_keywords/5G/recommissioning_and_make_throughput.robot
Resource      testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/siso_common_case/step_keywords/Common/basic/simple_ue.robot

*** Keywords ***
General_SiSo_Peak_Throughput_Check_With_Static_DVM_2.5W_AQQY
    [Documentation]
    ...    *****************
    ...    [TEST PURPOSE] The purpose of this case is to check peak throughput with static DVM when 2.5W is used.
    ...    ******************
    ...    History of changes
    ...   ticket:https://jiradc.ext.net.nokia.com/browse/LEOPARD-1892
    ...    ******************
    ...    - 27.03.2024 - - Created
    ...    *******************
    ...    Owner_kaihui.fan@nokia-sbell.com
    [Arguments]    ${ru_index}=1    ${connection}=GNB_OAM   ${suite_name}=default    ${test_name}=default
    ...    ${duration}=${600}  ${upload_duration}=${True}   ${target_avg_percent}=0.95   ${min_percent}=0.8
    ${cell_list}    get all cell id   ru_index=${ru_index}
    ${ue_index_list}    ${cell_list}    Get UE List for Given Cell List    cell_list=${cell_list}
    log to console   generate peak information before make call
    ${cell_and_peak_info}    generate peak information     cell_list=${cell_list}    duration=${duration}
    ...    suite_name=${suite_name}    test_name=${test_name}   l3_avg_rate=${target_avg_percent}  l3_min_rate=${min_percent}
    FOR  ${cell_id}  IN  @{cell_list}
        ${cell_id}    convert to string    ${cell_id}
        ${cell_info}    get from dictionary    ${cell_and_peak_info}    ${cell_id}
        ${origin_dl_tp}   get from dictionary   ${cell_info}    dl_tp
        ${new_dl_tp}=   Evaluate   float(${origin_dl_tp.split('M')[0]})*float(0.5)
    END
    ${new_dl_tp_str}   Convert To String   ${new_dl_tp}
    log to console   \nMake Dl 50*% traffic before change PMAX
    ${status}    ${ue_and_cell}    run keyword and ignore error   Ue Attach and Start DL UL Traffic
    ...    ue_index_list=${ue_index_list}    dl_tp=${new_dl_tp_str}M
    ...    direction=DL  duration=${duration}
    Sleep   60s
    log to console    \nCheck Papsu Voltage And Ru Power With Avg Value
    ${P1_rupower_value}  Check Papsu Voltage And Ru Power With Avg Value   papsu_expect_value=45   ru_index=${ru_index}
    log to console   \nVerify Throughput and STOP DL traffic before change PMAX
    UE Verify Peak Throughput    ue_index_list=${ue_index_list}  direction=DL
    ...    ue_and_cell=${ue_and_cell}    duration=${60}
    ...    target_avg_percent=${target_avg_percent}    min_percent=${min_percent}   upload_duration=${upload_duration}
    Ue Stop DL UL Traffic and Detach
    ...    ue_index_list=${ue_index_list}   direction=DL
    Change pMax Value  pMax_value=29   ru_index=${ru_index}
    log to console   \nMake Dl 50% traffic after change PMAX to 29dB
    ${status}    ${ue_and_cell}    run keyword and ignore error   Ue Attach and Start DL UL Traffic
    ...    ue_index_list=${ue_index_list}    dl_tp=${new_dl_tp_str}M
    ...    direction=DL  duration=${duration}
    Sleep   60s
    log to console   \nCheck Papsu Voltage And Ru Power With Avg Value after change PMAX to 29dB
    ${P2_rupower_value}  Check Papsu Voltage And Ru Power With Avg Value   papsu_expect_value=42   ru_index=${ru_index}
    Should Be True  ${P1_rupower_value}>${P2_rupower_value}   msg=P1 value < P2 value
    log to console   \nVerify Throughput and STOP DL traffic after change PMAX to 29dB
    UE Verify Peak Throughput    ue_index_list=${ue_index_list}  direction=DL
    ...    ue_and_cell=${ue_and_cell}    duration=${60}
    ...    target_avg_percent=${target_avg_percent}    min_percent=${min_percent}   upload_duration=${upload_duration}
    [Teardown]  run keywords  run keyword and ignore error  csn.disconnect    connection=ASIK Master  AND
    ...    COAM Teardown gnb connections    connection=${connection}  AND
    ...   run keyword and ignore error  Ue Stop DL UL Traffic and Detach
    ...    ue_index_list=${ue_index_list}   direction=DL

Change pMax Value
    [Arguments]    ${pMax_value}    ${ru_index}=1
    selenium login and disable screen lock
    ${cell_lists_per_ru}    Get All Cell Id    ru_index=${ru_index}
    FOR  ${cell_id}  IN  @{cell_lists_per_ru}
        Check and Modify Single Parameter on WebUI    dist_name=MRBTS-${mrbtsID}/NRBTS-${nrbtsID}/NRCELL-${cell_id}
        ...    filter_param=Maximum output power    abbr=pMax     new_value=${pMax_value}
    END
    Wait until keyword succeeds    10min    30s    verify all cells should be onair
    [Teardown]    selenium logout and close browser

Check Papsu Voltage And Ru Power With Avg Value
    [Arguments]    ${papsu_expect_value}=${45}   ${ru_index}=1
    Connect to Common Unit Master
    log to console    login RU
    Connect to RU With Allocated IP    ru_index=${ru_index}    ru_alias=RU_${ru_index}
    ${sudo}    csn.execute    command=which sudo    connection=RU_${ru_index}
    ${sudo}    Replace String    ${sudo}    \r\n    ${EMPTY}
    log to console    operate under shell client...
    log to console    send / action create ConfigAccess /ca /module
    ${cmd}   Set Variable  echo "/ action create ConfigAccess /ca /module"|${sudo} frmonShellClient 127.0.0.1 2000
    ${output}  csn.execute  command=${cmd}    connection=RU_${ru_index}
    sleep    2s
    log to console    send / action create Psu /papsu1 /rf/papsu1
    ${cmd}   Set Variable  echo "/ action create Psu /papsu1 /rf/papsu1"|${sudo} frmonShellClient 127.0.0.1 2000
    ${output}  csn.execute  command=${cmd}    connection=RU_${ru_index}
    sleep    2s
    log to console    send  / action create Psu /papsu2 /rf/papsu2
    ${cmd}   Set Variable  echo "/ action create Psu /papsu2 /rf/papsu2"|${sudo} frmonShellClient 127.0.0.1 2000
    ${output}  csn.execute  command=${cmd}    connection=RU_${ru_index}
    sleep    2s
    log to console    \n calculate papsu Voltage avg
    ${total_papsu_value}   Set Variable   ${0}
    FOR  ${times}  IN RANGE  1  11
        ${papsu1_value}   Get Single Measure Value  echo "/papsu1 action measure"|${sudo} frmonShellClient 127.0.0.1 2000  ${ru_index}
        ${papsu2_value}   Get Single Measure Value  echo "/papsu2 action measure"|${sudo} frmonShellClient 127.0.0.1 2000  ${ru_index}
        ${total_papsu_value}=   Evaluate  ${total_papsu_value}+${papsu1_value}+${papsu2_value}
        Sleep  1s
    END
    ${avg_papsu_value}=  Evaluate  ${total_papsu_value}/20
    ${round_papsu_value}=  Evaluate  round(${avg_papsu_value})
    log to console    / action create PsuMeasurements /rf_psu /rf/psu
    ${cmd}   Set Variable  echo "/ action create PsuMeasurements /rf_psu /rf/psu"|${sudo} frmonShellClient 127.0.0.1 2000
    ${output}  csn.execute  command=${cmd}    connection=RU_${ru_index}
    log to console    \n calculate RU Power avg
    ${total_rupower_value}   Set Variable   ${0}
    FOR  ${times}  IN RANGE  1  21
        ${ru_power_value}   Get Single Measure Value
        ...   echo "/rf_psu action measure"|${sudo} frmonShellClient 127.0.0.1 2000  ${ru_index}
        ${total_rupower_value}=   Evaluate  ${total_rupower_value}+${ru_power_value}
        Sleep  2s
    END
    ${avg_rupower_value}=  Evaluate  float(${total_rupower_value})/20
    ${round_rupower_value}=  Evaluate  round(${avg_rupower_value})
    log to console    \nGet Avg Value:round_papsu_value is ${round_papsu_value} and round_rupower_value is ${round_rupower_value}
    Should Be Equal As Strings    ${round_papsu_value}   ${papsu_expect_value}
    [Return]    ${round_rupower_value}
    [Teardown]       run keywords     run keyword and ignore error    csn.Disconnect  connection=RU_${ru_index}  AND
    ...   run keyword and ignore error    csn.Disconnect  connection=ASIK Master

Get Single Measure Value
    [Arguments]    ${cmd}   ${ru_index}=1
    ${output}  csn.execute  command=${cmd}    connection=RU_${ru_index}
    sleep    2s
    ${papsu1}    Set Variable    ${output.split('\r\n')[0].split(' ')[-1]}
    ${papsu1}    Evaluate    float(${papsu1})
    [Return]    ${papsu1}
