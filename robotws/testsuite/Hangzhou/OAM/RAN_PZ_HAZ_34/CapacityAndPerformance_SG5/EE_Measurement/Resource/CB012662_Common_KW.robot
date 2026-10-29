*** Settings ***
Documentation     author: Zhang Xuewen
...               Group: HGZ_SG5
...               contact: xuewen.zhang@nokia-sbell.com

Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/siso_common_case/variable/Variables_5G.robot
Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/siso_common_case/step_keywords/5G/operate_cell_and_check.robot
Resource    ${BASIC_PATH_5G}/5G_Setup_And_Teardown.robot
Library           OperatingSystem
Library           Collections
Library     BuiltIn
Library    ../lib/excel_helper.py
Library           re

*** Variables ***
@{HEADER}    Test Type   RU Power Consumption   RU Index
@{tput_list}    1    5    10    20    30    50    100    200    300    400
...    500    600    700    800    900    1000    1200    1400
${connection}    GNB_OAM
${CFGFILE_PATH}         /opt/transformers.dynamic.nsn-net.net/gnb_configuration/Hangzhou/${testline_name}/
${counter_loops}    3
@{RF_LOAD_HEADER}    Counter   Name   HW   Medium\n30%   Busy\n50%   Full\n100%
@{RF_LOAD_TPUT_LIST}   10   500   1400
&{COUNTER_NAME_DICT}   M40002C0=ENERGY CONSUMPTION IN SM    M40002C1=ENERGY CONSUMPTION IN RF
...   M40002C2=ENERGY CONSUMPTION IN BTS    M40003C2=RU ENERGY CONSUMPTION
...   M40003C3=RU MIN PWR USAGE   M40003C4=RU ENERGY CONSUMPTION IN RF
...   M40003C5=RU MAX PWR USAGE    M40004C0=SM ENERGY CONSUMPTION
...   M40004C1=SM MIN PWR USAGE    M40004C2=SM AVG PWR USAGE
...   M40004C3=SM MAX PWR USAGE

*** Keywords ***
gNB.ReplaceDeltaID
    [Arguments]       ${DeltaPath}='NULL'    ${MRBTSID}=${MRBTS_ID}    ${NRBTSID}=${NRBTS_ID}
    ${timestamp}    robot.libraries.DateTime.Get Current Date    result_format=timestamp
    ${timestamp}    robot.libraries.DateTime.convert date    ${timestamp}    epoch
    ${timestamp}    evaluate    int(round(${timestamp} * 1000))
    ${MRBTSID}    Evaluate    str('${MRBTSID}')
    ${NRBTSID}    Evaluate    str('${NRBTSID}')
    ${MRBTSID}    Fetch From Right    ${MRBTSID}   MRBTS-
    ${NRBTSID}    Fetch From Right    ${NRBTSID}   NRBTS-

    ${MRBTSID}    set variable    MRBTS-${MRBTSID}
    ${NRBTSID}    set variable    NRBTS-${NRBTSID}
    run    cp ${DeltaPath} ${LOG_PATH}/Delta_${MRBTS_ID}_${timestamp}.py
    run    sed -i 's/MRBTS-[0-9]\\{0,10\\}/${MRBTSID}/g' ${LOG_PATH}/Delta_${MRBTS_ID}_${timestamp}.py
    run    sed -i 's/NRBTS-[0-9]\\{0,10\\}/${NRBTSID}/g' ${LOG_PATH}/Delta_${MRBTS_ID}_${timestamp}.py
    run keyword if  not '${DeltaPath}'=='NULL'       Import Variables        ${LOG_PATH}/Delta_${MRBTS_ID}_${timestamp}.py

TestSuilt.Start
    Log to Console   TestSuiltStart
    set test variable   ${LOG_PATH}    ${TS_CASE_LOG_PATH}
    #run keyword and ignore error    Import Variables       ${CFGFILE_PATH}TLDelta.py
    run keyword and ignore error    gNB.ReplaceDeltaID     DeltaPath=${CFGFILE_PATH}TLDelta.py

RU energy consumption measurement based on UE DL throughput
    [Arguments]    ${ru_index}=${1}
    Log to console    \n********* RU${ru_index} energy consumption measurement based on UE DL throughput ***********
    log to console   Step1: Enable EE features manualy
    Get Ru Running Index From Configuration Index    ${ru_index}
    Step2: Check RU power via WebEM   ru_index=${ru_index}

Step2: Check RU power via WebEM
    [Arguments]    ${ru_index}=${1}
    Idle load(cell blocked)   ru_index=${ru_index}
    Low load(cell onair)   ru_index=${ru_index}
    DL UDP Tput(from 1Mbps to Max tput)   ru_index=${ru_index}

Idle load(cell blocked)
    [Arguments]    ${ru_index}=${1}
    Log to console    \n********* Idle load(cell blocked) ***********

    Modify Parameter On BTS With Activate    dist_name=MRBTS-${MRBTS_ID}/NRBTS-${NRBTS_ID}
    ...    parameter=shutdownNogNBCellTmr    value=0
    ${cell_id_list}   get all cell id  ${ru_index}
    # Step 1: block all nr cells, 1 cell = 1 min
    Selenium Login And Disable Screen Lock
    ${energySavingMode}    selenium_coam.get_parameter_value    dist_name=MRBTS-${MRBTS_ID}/EQM-1/APEQM-1/RMOD-${ru_index}
    ...    filter_param=Energy Saving Mode Activation
    ...    abbr=energySavingMode
    FOR    ${idx}    IN    @{cell_id_list}
        selenium_coam.block cell    cell_idx=${idx}
        ${cellgrp_id}    Get Cell Group From Cell    cell_id=${idx}
        Wait Until Keyword Succeeds    3 min    10 sec    Cell Should Be Blocked
        ...    cell_idx=${idx}    cell_group_idx=${cellgrp_id}
        Wait Until Keyword Succeeds    30s    3s    Verify BTS Alarm Exist
        ...    fault_id=49    fault_name=Cell blocked
    END
    Run keyword if   '${energySavingMode}'=='DEEPSLEEP'
    ...   Wait Until Keyword Succeeds    9 min    30 sec    RU Status Info Should Be as Expect   ru_index=${ru_index}   powerState=SLEEP
    # Step 2: check RU power via WebEM
    ${power_meassure_1}  Get RMOD Power Measurement via WebEM   ru_index=${ru_index}
    Create Or Append Excel File   ${TS_CASE_LOG_PATH}/power_measure_ru${ru_index}.xlsx    idle_load
    ...   ${power_meassure_1}    ${ru_index}
    [Teardown]    Selenium Logout And Close Browser

Low load(cell onair)
    [Arguments]    ${ru_index}=${1}
    Log to console    \n********* Low load(cell onair) ***********
    Selenium Login And Disable Screen Lock
    ${cell_id_list}   get all cell id  ${ru_index}
    # Step 1: unblock all nr cells, 1 cell = 1 min
    ${cell_num}    get length  ${cell_id_list}
    ${check_alarm}  set variable if  ${cell_num}==1  ${True}  ${False}
    FOR  ${block_id}  IN  @{cell_id_list}
        ${operate_list}    create list    ${block_id}
        UnBlock Cells and check status   block_list=${operate_list}   check_alarm=${check_alarm}    gnb_type='${gNb_CuType}'
    END
    # Step 2: check RU power via WebEM
    ${power_meassure_1}  Get RMOD Power Measurement via WebEM   ru_index=${ru_index}
    Create Or Append Excel File   ${TS_CASE_LOG_PATH}/power_measure_ru${ru_index}.xlsx    low_load
    ...   ${power_meassure_1}    ${ru_index}
    [Teardown]    Selenium Logout And Close Browser

DL UDP Tput(from 1Mbps to Max tput)
    [Arguments]    ${ru_index}=${1}    ${connection}=GNB_OAM
    Log to console    \n********* DL UDP Tput(from 1Mbps to Max tput) ***********
    # Selenium Login And Disable Screen Lock
    ${cell_id_list}   get all cell id  ${ru_index}
    # Step 1: unblock all nr cells, 1 cell = 1 min
    ${cell_num}    get length  ${cell_id_list}
    ${check_alarm}  set variable if  ${cell_num}==1  ${True}  ${False}
    # ${tput_list}    create list    ${1}   ${5}   ${1400}
    FOR  ${dl_tput}  IN  @{tput_list}
        Start L3Call and Send packets   throughput=${dl_tput}M    ue_index=0   buffer_size=64   cell_index=${cell_id_list}[0]   direction=dl
        Selenium Login And Disable Screen Lock
        ${power_meassure_1}  Get RMOD Power Measurement via WebEM   ru_index=${ru_index}
        Selenium Logout And Close Browser
        Create Or Append Excel File   ${TS_CASE_LOG_PATH}/power_measure_ru${ru_index}.xlsx    ${dl_tput}Mbps
        ...   ${power_meassure_1}    ${ru_index}
        Run Keyword And Ignore Error    Stop L3Call and Traffic   ue_index=0   direction=dl
    END

Get RMOD Power Measurement via Webem
     [Arguments]    ${interval}=1min   ${ru_index}=${1}
     ${rmod_power_measure}  Convert to number  0
     #skip the first interval
     Sleep  ${interval}
     FOR  ${i}  IN RANGE  ${counter_loops}
          ${rmod_power}     Get master real time measurements via Webem for RMOD    interval=${interval}   ru_index=${ru_index}
          ${rmod_power_measure}  Evaluate  ${rmod_power_measure}+${rmod_power}
          Sleep  ${interval}
     END
     ${rmod_average}   Evaluate   ${rmod_power_measure}/${counter_loops}
     ${rmod_power}   Convert to number   ${rmod_average}    1
     log   \nrmod_power_average = ${rmod_power}     console=yes
     [Return]    ${rmod_power}


Get Ru Running Index From Configuration Index
    [Arguments]    ${ru_index}=1
    Selenium Login And Disable Screen Lock
    ${hw_info}   selenium_coam.get_bts_start_up_view_info   cell='NR cells'
    Set Test Variable    ${rmod_running_index}    ${None}
    FOR    ${item}    IN    @{hw_info['Hardware']}
        Log    ${item}
        ${rmod_index_str}    Evaluate    "RMOD-{}".format(${ru_index})
        Run Keyword If    "${rmod_index_str}" in "${item}"    Get Last Number    ${item}    ${rmod_running_index}
    END
    Return From Keyword    ${rmod_running_index}
    [Teardown]    Selenium Logout And Close Browser

Get Last Number
    [Arguments]    ${item}    ${rmod_running_index}
    ${pattern}    Set Variable    (\\d+)[^\\d]*$
    ${match}    Evaluate    re.search('${pattern}', '${item}')   re
    Run Keyword If    ${match}    Set Test Variable    ${rmod_running_index}    ${match.group(1)}
    Run Keyword If    ${match}    Log    rmod_running_index: ${rmod_running_index}
    run keyword if  not ${match}    Log    rmod_running_index no found!

Get master real time measurements via Webem for RMOD
    [Arguments]    ${interval}=1min   ${ru_index}=${1}
    ${content}    selenium_coam.get real time measurements    object_names=RMOD
    # ${value_list}    get dictionary values    ${content['RMOD/RMOD_R-${rmod_running_index}']}
    ${time_list}    get dictionary keys   ${content['RMOD/RMOD_R-${rmod_running_index}']}
    sort list    ${time_list}
    ${status}    ${last_time}   run keyword and ignore error    set variable    ${time_list[-1]}
    Connect to Common Unit Master
    ${current_time}   get time from gnb
    ${end_time}    robot.libraries.DateTime.add_time_to_date    ${last_time}    ${interval}
    ${diff}    robot.libraries.DateTime.subtract_date_from_date    ${end_time}    ${current_time}
    ${diff1}    robot.libraries.DateTime.subtract_time_from_time    ${diff}    ${interval}
    should be true    ${diff1}<0
    ${wait_time}=  evaluate  ${diff1} + 60
    Set Suite Variable    ${wait_time}
    ${power_voltage}    get_from_dictionary   ${content['RMOD/RMOD_R-${rmod_running_index}']}   ${last_time}
    ${Voltage}    get_from_dictionary    ${power_voltage}    Voltage
    ${Power}    get_from_dictionary    ${power_voltage}    Power
    [Return]     ${Power}

Modify Parameter On BTS With Activate
    [Arguments]    ${dist_name}    ${parameter}    ${value}    ${connection}=GNB_OAM
    coam.perform_parameter_recommissioning    dist_name=${dist_name}
    ...    parameter=${parameter}    value=${value}    operation=update
    ...    skip_parameter_relation_errors=true    connection=${connection}

Verify BTS Alarm Exist
    [Documentation]    Author: jian.1.chen@nokia-sbell.com
    ...    fault_id : 50    fault_name: BTS blocked
    [Arguments]    ${fault_id}    ${fault_name}    ${fault_info}=None    ${connection}=GNB_OAM
    Connect to gnb coam via ssl
    @{alarm_list}    coam.get_active_alarms    connection=${connection}
    Should Contain    '${alarm_list}'    'faultId': ${fault_id}
    Should Contain    '${alarm_list}'    'faultName': '${fault_name}'
    Run Keyword If    '${fault_info}'!='None'    Should Contain    '${alarm_list}'    'supplAlarmInfo': '${fault_info}'


Start L3Call and Send packets
    [Arguments]    ${throughput}=10K    ${ue_index}=0   ${buffer_size}=1400B   ${duration}=900
    ...   ${cell_index}=1   ${direction}=dl
    Log to console    Start L3Call and Send packets: ue_index=${ue_index} throughput=${throughput}
    ${ue_type}    translate_power_ue_type_from_testline    ue_index=${ue_index}
    #power_ue.Prepare UE    ue_type=${ue_type}    ue_index=${ue_index}    ui_version=${ui_version}
    wait until keyword succeeds   3x   1min    UE start traffic with retry    ue_type=${ue_type}    ue_index=${ue_index}
    ...   direction=${direction}    throughput=${throughput}    buffer_size=${buffer_size}   cell_index=${cell_index}
    ...   duration=${duration}


UE start traffic with retry
     [Arguments]    ${ue_type}=huawei   ${throughput}=10K    ${ue_index}=0   ${buffer_size}=1400B   ${duration}=900
    ...   ${cell_index}=1   ${direction}=dl
    Log to console    UE start traffic with retry: ue_index=${ue_index}
    Run Keyword And Ignore Error    ute_ue.stop_using_ue   UE_${ue_index}
    Run Keyword And Ignore Error    power_ue.Prepare UE    ue_type=${ue_type}    ue_index=${ue_index}
    ${5Grach_ed}    power_ue.UE Attach    ue_type=${ue_type}    ue_index=${ue_index}
    power_ue.Start traffic    ue_type=${ue_type}    direction=${direction}    throughput=${throughput}
    ...    protocol=udp    duration=${duration}    ue_index=${ue_index}    buffer_size=${buffer_size}
    ${cell_list}   Create List   ${${cell_index}}
    ${ue_index_list}   Create List   ${${ue_index}}
    ${ue_and_cell}   Create Dictionary   ${${ue_index}}   ${${cell_index}}
    ${res}     Run Keyword And Return Status    ue.UE Verify Peak Throughput   ue_index_list=${ue_index_list}   ue_and_cell=${ue_and_cell}
    ...   dl_exp=${0}   ul_exp=${1}   interval=10s   duration=${30}
    ...   actual_rate=0.1   du_index=0   gnb_ssl_connection=${connection}
    ...   is_need_to_capture_log=${False}   cell_and_peak_info=None
    ...   target_avg_percent=${0.001}   min_percent=${0.0}
    # Run Keyword If    '${res}'=='False'     Stop L3Call and Traffic   ue_index=${ue_index}   direction=${direction}

Stop L3Call and Traffic
    [Arguments]    ${ue_index}=0   ${direction}=dl
    Log to console    Stop L3Call and ${direction} Traffic ue_index=${ue_index}
    ${ue_type}    translate_power_ue_type_from_testline    ue_index=${ue_index}
    #power_ue.Prepare UE    ue_type=${ue_type}    ue_index=${ue_index}
    power_ue.Stop traffic    ue_type=${ue_type}    direction=${direction}    ue_index=${ue_index}
    power_ue.UE Detach  ue_type=${ue_type}    ue_index=${ue_index}
    Run Keyword And Ignore Error    ute_ue.stop_using_ue   UE_${ue_index}

Create Or Append Excel File
    [Arguments]    ${file_name}    ${column1}    ${column2}    ${column3}
    ${file_exists}    Run Keyword And Return Status    File Should Exist    ${file_name}
    Run Keyword If    ${file_exists}    Append To Existing Excel File    ${file_name}    ${column1}    ${column2}    ${column3}
    ...    ELSE    Create New Excel File    ${file_name}    ${column1}    ${column2}    ${column3}

Create New Excel File
    [Arguments]    ${file_name}    ${column1}    ${column2}    ${column3}
    ${wb}    Create Workbook
    ${worksheet_title}    Get Active Worksheet Title    ${wb}
    Append To Worksheet   ${wb}    ${worksheet_title}    ${HEADER}
    Set Worksheet    ${wb}    ${worksheet_title}    ${column1}    ${column2}    ${column3}
    Save Workbook    ${wb}    ${file_name}

Append To Existing Excel File
    [Arguments]    ${file_name}    ${column1}    ${column2}    ${column3}
    ${wb}    Load Workbook    ${file_name}
    ${worksheet_title}    Get Active Worksheet Title    ${wb}
    ${row}    Create List    ${column1}    ${column2}    ${column3}
    Append To Worksheet   ${wb}    ${worksheet_title}    ${row}
    Save Workbook    ${wb}    ${file_name}

Set Worksheet
    [Arguments]    ${workbook}    ${worksheet_title}    ${column1}    ${column2}    ${column3}
    ${headers}    Create List    ${column1}    ${column2}    ${column3}
    Append To Worksheet     ${workbook}    ${worksheet_title}    ${headers}

RU energy consumption counters based on RF load with UE
    [Arguments]    ${ru_index}=${1}
    Log to console    \n********* RU energy consumption counters based on RF load with UE ***********
    log to console   Step1: Enable EE measurement features
    Modify Parameter On BTS With Activate    dist_name=MRBTS-${MRBTS_ID}/MNL-1/MNLENT-1/FEATCADM-1
    ...    parameter=actPowerMeter    value=true
    Modify Parameter On BTS With Activate    dist_name=MRBTS-${MRBTS_ID}/MNL-1/MNLENT-1/PMMNL-1
    ...    parameter=mtBtsEnergyMonitoring    value=15min
    Modify Parameter On BTS With Activate    dist_name=MRBTS-${MRBTS_ID}/MNL-1/MNLENT-1/PMMNL-1
    ...    parameter=mtSBTSRfmEnergyMonitoring    value=15min
    Modify Parameter On BTS With Activate    dist_name=MRBTS-${MRBTS_ID}/MNL-1/MNLENT-1/PMMNL-1
    ...    parameter=mtSBTSSmEnergyMonitoring    value=15min
    Step2: Check RU power measurement based on RF load   ru_index=${ru_index}

Step2: Check RU power measurement based on RF load
    [Arguments]    ${ru_index}=${1}    ${connection}=GNB_OAM
    Log to console    \n********* Step2: Check RU power measurement based on RF load ***********
    # Selenium Login And Disable Screen Lock
    ${cell_id_list}   get all cell id  ${ru_index}
    # Step 1: unblock all nr cells, 1 cell = 1 min
    ${cell_num}    get length  ${cell_id_list}
    ${ru_index_type_mapping}    Get All RU Type Mapping Index
    ${ru_num}    get length  ${ru_index_type_mapping}
    # ${tput_list}    create list    ${1}   ${5}   ${1400}
    FOR  ${dl_tput}  IN  @{RF_LOAD_TPUT_LIST}
        Log to console    \n********* Checking RU power measurement for DL traffic:${dl_tput}Mbps ***********
        Start L3Call and Send packets   throughput=${dl_tput}M    ue_index=0   buffer_size=64
        ...   cell_index=${cell_id_list}[0]   direction=dl   duration=3600
        sleep    20min
        &{dict_counter_values}    Get RF Power Counter Values via Webem   ru_num=${ru_num}
        Create Or Append Excel File For Counter Values
        ...    ${TS_CASE_LOG_PATH}/power_measure.xlsx    ${dict_counter_values}   ${ru_index_type_mapping}
        Run Keyword And Ignore Error    Stop L3Call and Traffic   ue_index=0   direction=dl
    END
    set_excel_border   ${TS_CASE_LOG_PATH}/power_measure.xlsx
    set_excel_background   ${TS_CASE_LOG_PATH}/power_measure.xlsx

Create Or Append Excel File For Counter Values
    [Arguments]    ${file_name}    ${dict_counter_values}    ${ru_index_type_mapping}
    ${file_exists}    Run Keyword And Return Status    File Should Exist    ${file_name}
    Run Keyword If    ${file_exists}    Append To Existing Excel File For Counter Values
    ...    ${file_name}    ${dict_counter_values}
    ...    ELSE    Create New Excel File For Counter Values
    ...    ${file_name}    ${dict_counter_values}    ${ru_index_type_mapping}

Create New Excel File For Counter Values
    [Arguments]    ${file_name}    ${dict_counter_values}    ${ru_index_type_mapping}
    ${wb}    Create Workbook
    ${worksheet_title}    Get Active Worksheet Title    ${wb}
    Append To Worksheet   ${wb}    ${worksheet_title}    ${RF_LOAD_HEADER}
    save workbook   ${wb}   ${file_name}
    set_excel_header   ${file_name}
    ${Counter}   Create List
    ${Name}   Create List
    ${HW}   Create List
    FOR  ${item}  IN  @{dict_counter_values.keys()}
         ${counter_key}  set variable if  '_' in '${item}'   ${item.split('_')[0]}  ${item}
         Append To List     ${Counter}    ${counter_key}
         ${counter_name}    Get From Dictionary    ${COUNTER_NAME_DICT}    ${counter_key}
         Append To List     ${Name}   ${counter_name}
         Run Keyword If   'M40002' in '${counter_key}'   Append To List     ${HW}   Common
         ${HW_name}    Run Keyword If   'M40003' in '${counter_key}'
         ...   Get From Dictionary    ${ru_index_type_mapping}    ${item.split('_')[1]}
         Run Keyword If   'M40003' in '${counter_key}'   Append To List     ${HW}   ${HW_name}-${item.split('_')[1]}
         Run Keyword If   'M40004' in '${counter_key}'   Append To List     ${HW}   ASIB-1
    END
    write_column_to_excel   ${file_name}    A2    ${Counter}
    write_column_to_excel   ${file_name}    B2    ${Name}
    write_column_to_excel   ${file_name}    C2    ${HW}
    merge_cells_if_equal   ${file_name}    A
    merge_cells_if_equal   ${file_name}    B
    write_column_to_excel   ${file_name}    D2    ${dict_counter_values.values()}
    set test variable   ${COLUMN_START_LETTER}    D

Append To Existing Excel File For Counter Values
    [Arguments]    ${file_name}    ${dict_counter_values}
    ${COLUMN_START_LETTER}   increment_column_letter   ${COLUMN_START_LETTER}   ${1}
    set test variable   ${COLUMN_START_LETTER}
    write_column_to_excel   ${file_name}    ${COLUMN_START_LETTER}2    ${dict_counter_values.values()}

Create Empty Ordered Dictionary
    ${ordered_dict}    Evaluate    collections.OrderedDict()    modules=collections
    [Return]    ${ordered_dict}

Get RF Power Counter Values via Webem
    [Arguments]    ${interval}=15min     ${ru_num}=1
    Selenium Login And Disable Screen Lock
    run keyword and ignore error    selenium_coam.close_start_up_view_window
    &{dict_counter_values}    Create Empty Ordered Dictionary
    Log to console    \n********* start getting counter value: M40002C0 M40002C1 M40002C2 ***********
    ${content}    Get PM Counter content via Webem    counter_id=M40002C0
    ${time_list}    get dictionary keys   ${content}
    sort list    ${time_list}
    ${status}    ${last_time}   run keyword and ignore error    set variable    ${time_list[-1]}
    ${M40002C0}    Get PM Counter value via Webem    counter_id=M40002C0    counter_time=${last_time}
    ${M40002C1}    Get PM Counter value via Webem    counter_id=M40002C1    counter_time=${last_time}
    ${M40002C2}    Get PM Counter value via Webem    counter_id=M40002C2    counter_time=${last_time}
    set to dictionary    ${dict_counter_values}    M40002C0    ${M40002C0}
    set to dictionary    ${dict_counter_values}    M40002C1    ${M40002C1}
    set to dictionary    ${dict_counter_values}    M40002C2    ${M40002C2}

    Log to console    \n********* start getting counter value: M40003C2 M40003C3 M40003C4 M40003C5 ***********
    FOR    ${ru_index}    IN RANGE   1    ${ru_num+1}
        ${M40003C2}     Get PM Counter value via Webem    counter_id=M40003C2    counter_time=${last_time}
        ...    full_path=[${testline_name}] MRBTS-${MRBTS_ID}/EQM-1/APEQM-1/RMOD-${ru_index}/SBTS_RFM_Energy_Monitoring/RU_ENERGY_CONSUMPTION
        set to dictionary    ${dict_counter_values}    M40003C2_${ru_index}    ${M40003C2}
    END
    FOR    ${ru_index}    IN RANGE   1    ${ru_num+1}
        ${M40003C3}     Get PM Counter value via Webem    counter_id=M40003C3    counter_time=${last_time}
        ...    full_path=[${testline_name}] MRBTS-${MRBTS_ID}/EQM-1/APEQM-1/RMOD-${ru_index}/SBTS_RFM_Energy_Monitoring/RU_MIN_PWR_USAGE
        set to dictionary    ${dict_counter_values}    M40003C3_${ru_index}    ${M40003C3}
    END
    FOR    ${ru_index}    IN RANGE   1    ${ru_num+1}
        ${M40003C4}     Get PM Counter value via Webem    counter_id=M40003C4    counter_time=${last_time}
        ...    full_path=[${testline_name}] MRBTS-${MRBTS_ID}/EQM-1/APEQM-1/RMOD-${ru_index}/SBTS_RFM_Energy_Monitoring/RU_AVG_PWR_USAGE
        set to dictionary    ${dict_counter_values}    M40003C4_${ru_index}    ${M40003C4}
    END
    FOR    ${ru_index}    IN RANGE   1    ${ru_num+1}
        ${M40003C5}     Get PM Counter value via Webem    counter_id=M40003C5    counter_time=${last_time}
        ...    full_path=[${testline_name}] MRBTS-${MRBTS_ID}/EQM-1/APEQM-1/RMOD-${ru_index}/SBTS_RFM_Energy_Monitoring/RU_MAX_PWR_USAGE
        set to dictionary    ${dict_counter_values}    M40003C5_${ru_index}    ${M40003C5}
    END
    run keyword and ignore error    selenium_coam.refresh_page

    Log to console    \n********* start getting counter value: M40004C0 M40004C1 M40004C2 M40004C3 ***********
    ${M40004C0}    Get PM Counter value via Webem    counter_id=M40004C0    counter_time=${last_time}
    ${M40004C1}    Get PM Counter value via Webem    counter_id=M40004C1    counter_time=${last_time}
    ${M40004C2}    Get PM Counter value via Webem    counter_id=M40004C2    counter_time=${last_time}
    ${M40004C3}    Get PM Counter value via Webem    counter_id=M40004C3    counter_time=${last_time}
    set to dictionary    ${dict_counter_values}    M40004C0    ${M40004C0}
    set to dictionary    ${dict_counter_values}    M40004C1    ${M40004C1}
    set to dictionary    ${dict_counter_values}    M40004C2    ${M40004C2}
    set to dictionary    ${dict_counter_values}    M40004C3    ${M40004C3}
    [Return]     &{dict_counter_values}
    [Teardown]    selenium logout and close browser

Get PM Counter value via Webem
    [Arguments]    ${counter_id}    ${counter_time}   ${dist_name}=${None}    ${counter_type}=BTS
    ...    ${full_path}=${None}
    ${content}    Get PM Counter content via Webem    counter_id=${counter_id}   dist_name=${dist_name}
    ...     counter_type=${counter_type}    full_path=${full_path}
    ${STRING_VAR}    get_from_dictionary    ${content}    ${counter_time}
    ${INT_VAR}    Convert To Integer    ${STRING_VAR}
    [Return]    ${INT_VAR}
