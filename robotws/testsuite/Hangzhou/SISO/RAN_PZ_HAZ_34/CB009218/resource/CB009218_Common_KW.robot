*** Settings ***
Documentation     author: Zhang Xuewen
...               Group: HGZ_SG5
...               contact: xuewen.zhang@nokia-sbell.com

Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/siso_common_case/variable/Variables_5G.robot
Resource    ${BASIC_PATH_5G}/5G_Setup_And_Teardown.robot
Resource      testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/siso_common_case/lib/step_keywords.robot

Resource    taf/rfrl/common_resources/robot/TTI_Trace.robot
Resource    ../../CB008238_A/resource/CB008238_Common_KW.robot
Library      ../../CB008238_A/lib/CB008238_TTI_Trace_Analysis.py

*** Variables ***
${ue_index}    0
${ui_version}    S30UI3.1.1
${log_capture_time}    2s
${ue_type}    nokia_cpe
${connection}    GNB_OAM

*** Keywords ***
Start L3Call and DL small packet
    [Arguments]    ${throughput}=10K    ${ue_index}=0
    Log to console    Start L3Call and DL small packet: ue_index=${ue_index}
    ${ue_type}    translate_power_ue_type_from_testline    ue_index=${ue_index}
    set test variable    ${ue_type}
    power_ue.Prepare UE    ue_type=${ue_type}    ue_index=${ue_index}
    #power_ue.Prepare UE    ue_type=${ue_type}    ue_index=${ue_index}    ui_version=${ui_version}
    ${5Grach_ed}    power_ue.UE Attach    ue_type=${ue_type}    ue_index=${ue_index}
    power_ue.Start traffic    ue_type=${ue_type}    direction=dl    throughput=${throughput}
    ...    protocol=udp    duration=600    ue_index=${ue_index}
#    power_ue.Start traffic    ue_type=${ue_type}    direction=ul    throughput=100M
#    ...    protocol=udp    duration=600    ue_index=${ue_index}
Stop L3Call and DL Traffic
    [Arguments]    ${ue_index}=0
    Log to console    Stop L3Call and DL Traffic ue_index=${ue_index}
    ${cell_list}   Create List   ${1}
    ${ue_index_list}   Create List   ${${ue_index}}
    ${ue_and_cell}   Create Dictionary   ${${ue_index}}   ${1}
    ue.UE Verify Peak Throughput   ue_index_list=${ue_index_list}   ue_and_cell=${ue_and_cell}
    ...   dl_exp=${0}   ul_exp=${0}   interval=10s   duration=${30}
    ...   actual_rate=0.1   du_index=0   gnb_ssl_connection=${connection}
    ...   is_need_to_capture_log=${False}   cell_and_peak_info=None
    ...   target_avg_percent=${0.01}   min_percent=${0.0}
    power_ue.Stop traffic    ue_type=${ue_type}    direction=dl    ue_index=${ue_index}
#    power_ue.Stop traffic    ue_type=${ue_type}    direction=ul    ue_index=${ue_index}
    power_ue.UE Detach  ue_type=${ue_type}    ue_index=${ue_index}

Modify prachConfigurationIndex Parameter
    [Arguments]    ${prachConfigurationIndex}=160
    Log to console    Modify prachConfigurationIndex Parameter
    Selenium Login And Disable Screen Lock
    ${currect_status}    selenium_coam.get_parameter_value    dist_name=MRBTS-${MRBTS_ID}/NRBTS-${NRBTS_ID}/NRCELL-1
    ...    filter_param=PRACH configuration index
    ...    abbr=prachConfigurationIndex
    ${modify_params}  create list
    ${cell_list}    Get All Cell Id
    FOR  ${cell_index}  IN  @{cell_list}
        ${item}  create dictionary  dist_name=MRBTS-${MRBTS_ID}/NRBTS-${NRBTS_ID}/NRCELL-${cell_index}
    ...    filter_param=PRACH configuration index  p_name=prachConfigurationIndex  value=${prachConfigurationIndex}
        append to list  ${modify_params}  ${item}
    END
    Run Keyword If    '${currect_status}'!='${prachConfigurationIndex}'
    ...    Modify Parameters On Webem    modify_params=${modify_params}
    Selenium Logout And Close Browser

Modify actEnhancedPDSCHSchSplSlot Parameter
    [Arguments]    ${actEnhancedPDSCHSchSplSlot}=false
    Log to console    Modify actEnhancedPDSCHSchSplSlot Parameter to ${actEnhancedPDSCHSchSplSlot}
    Selenium Login And Disable Screen Lock
    ${currect_status}    selenium_coam.get_parameter_value    dist_name=MRBTS-${MRBTS_ID}/NRBTS-${NRBTS_ID}/NRCELL-1
    ...    filter_param=Activate enhanced PDSCH scheduling on special slot
    ...    abbr=actEnhancedPDSCHSchSplSlot
    ${modify_params}  create list
    ${cell_list}    Get All Cell Id
    FOR  ${cell_index}  IN  @{cell_list}
        ${item}  create dictionary  dist_name=MRBTS-${MRBTS_ID}/NRBTS-${NRBTS_ID}/NRCELL-${cell_index}
    ...    filter_param=Activate enhanced PDSCH scheduling on special slot
    ...    p_name=actEnhancedPDSCHSchSplSlot  value=${actEnhancedPDSCHSchSplSlot}
        append to list  ${modify_params}  ${item}
    END
    Run Keyword If    '${currect_status}'!='${actEnhancedPDSCHSchSplSlot}'
    ...    Run keywords
    ...    Modify Parameters On Webem    modify_params=${modify_params}
    ...    AND    cell reset to make parameter affective
    COAM Wait gnb And Cells ready    timeout=5min
    Selenium Logout And Close Browser

Setup_Env.Connect to DU
    csn.connect_to      hostname=${tl.gnbs[0].dus[0].airscale.common_units[0].lmp_connection.addr}
    ...                 username=${tl.gnbs[0].dus[0].airscale.common_units[0].lmp_connection.username}
    ...                 password=${tl.gnbs[0].dus[0].airscale.common_units[0].lmp_connection.password}    alias=DU_conn

Create default connection for ASOE
    [Documentation]  Author: Ding Binmei 5G_PZ_MMW_HZ_1_SG
    ...    Description: Create default connection for event trace log capturing
    ...                 If 1514 feature is enabled and HW type for base band is not ABIO, then event trace will be captured on ABIL slave,
    ...                 otherwise on ABIL master
    [Arguments]  ${hw_slot}=${1}
    Setup_Env.Connect to DU
    log to console    ${hw_slot}

Start TTI trace log capturing for ASOE
    [Documentation]    Author: Ding Binmei 5G_PZ_MMW_HZ_1_SG
    ...                Description: 1. Clear the log folder /var/eventsTrace
    ...                             2. Start TTI trace process
    ...               2020/1/15 Ren Biyao: add ${hw_slot} to extend for both left and right AMIA configurantion.
    ...               In left of AMIA support slot 1, 2, 3. In right of AMIA support slot 5, 6, 7.
    ...               2020/3/12 Ding Binmei: Extend keyword to support log capturing on user provided ABIL, if user would
    ...               like to capturing event trace log from other ABIL, then can set connection alias for ${connection_for_abil},
    ...               It will capturing on ABIL master by default
    [Arguments]  ${hw_slot}=${1}
    Create default connection for ASOE    hw_slot=${hw_slot}
    tti2.prepare_for_tti_trace_log_capturing    connection=DU_conn
    tti2.start_tti_trace    connection=DU_conn

Stop TTI trace log capturing for ASOE
    [Documentation]    Author: Ding Binmei 5G_PZ_MMW_HZ_1_SG
    ...                Description: Kill TTI trace process
    ...               2020/3/12 Ding Binmei: Extend keyword to support log capturing on user provided ABIL, if user would
    ...               like to capturing event trace log from other ABIL, then can set connection alias for ${connection_for_abil},
    ...               It will capturing on ABIL master by default
    tti2.stop_tti_trace    connection=DU_conn

Convert ASOE TTI trace log and download combined csv logs to test pc
    [Documentation]    Author: Ding Binmei  5G_PZ_MMW_HZ_1_SG
    ...                Description:
    ...                             1. ${local_path} Refers to the test case log path in test pc
    ...                             2. Convert bin files to csv files
    ...                             3. Combine multiple CSV files to one csv file for UL and DL direction
    ...                             4. Will return the local file path as a dict with UL and DL csv file paths in test pc.
    ...                                Example output: {'UL':'XXXX', 'DL':'XXXX'}
    ...                2020-3-12 Ding Binmei: Added ${is_need_to_close_connection} to let user decide whether need to disconnect ssh connection
    ...                         Add ${connection_for_abil} and ${connection_for_asik} to extend keyword to support for log capturing on other ABIL
    ...                         It will support log capturing on ABIL master by default

    [Arguments]    ${local_path}=${TS_CASE_LOG_PATH}    ${is_need_to_close_connection}=${False}
    ${csv_path}    tti2.convert_tti_trace_to_csv    connection=DU_conn
    ${csv_file_path_ul}    tti2.combine_csv_files_to_one    csv_log_path=${csv_path}    direction=ul    connection=DU_conn
    ${csv_file_path_dl}    tti2.combine_csv_files_to_one    csv_log_path=${csv_path}    direction=dl    connection=DU_conn
    ${remote_files}    Create list    ${csv_file_path_ul}     ${csv_file_path_dl}
    ssh.download file    remote_path=${remote_files}    local_path=${local_path}    connection=DU_conn
    Run keyword if    ${is_need_to_close_connection}
    ...    Run keyword and ignore error    Run keywords    ssh.disconnect    connection=DU_conn    AND
    ...                    ssh.disconnect    connection=DU_conn

    @{csv_file_name_ul}    Split string    ${csv_file_path_ul}    /
    @{csv_file_name_dl}    Split string    ${csv_file_path_dl}    /
    &{local_csv_file_path}    create dictionary
    Set to dictionary    ${local_csv_file_path}    UL    ${local_path}/${csv_file_name_ul}[-1]
    Set to dictionary    ${local_csv_file_path}    DL    ${local_path}/${csv_file_name_dl}[-1]
    [Return]    ${local_csv_file_path}

Delete temp csv tti file on ASOE
    [Arguments]    ${hw_slot}=1
    Create default connection for ASOE    hw_slot=${hw_slot}
    ${output_cmd}    Run Keyword And Ignore Error    csn.execute    command=ls /tmp/*.csv;rm /tmp/*.csv
    ...    connection=DU_conn    timeout=60s
    Run keyword and ignore error    csn.disconnect    connection=DU_conn

Activation_and_Deactivation_Enhanced_PDSCH_Scheduling_on_Speical_slot_for_Frame_Structure_8406
    [Arguments]    ${ue_type}=nokia_cpe
    Set Test Variable     ${ue_type}    ${ue_type}
    ${special_slots}    create list    ${3}   ${7}   ${13}   ${17}
#    ${expected_SLIVs}    create list    ${53}   ${96}   ${53}   ${96}
    ${expected_SLIVs}    create list    ${57}   ${96}   ${57}   ${96}
    Modify actEnhancedPDSCHSchSplSlot Parameter    actEnhancedPDSCHSchSplSlot=true
    coam wait gnb and cells ready    timeout=15min    gnb_type='${gNb_CuType}'
    sleep    5s
    ${cell_list}    create list    ${1}
    CB009218_Common_KW.Start L3Call and DL small packet    throughput=1000M
    Start Syve TTI Traces in Streaming mode   trace_ip=${dest_ip}
    Sleep    ${log_capture_time}
    ${tti_trace}=    Stop TTI Traces in Streaming mode
    ...  tti_trace_path=${TS_CASE_LOG_PATH}
    Convert TTI trace from pcap to excelCsv         ${tti_trace}  output_file_path=${TS_CASE_LOG_PATH}/sample_ttitrace
    ...   options=-d dl
    set test variable    ${local_csv_file_path}   ${TS_CASE_LOG_PATH}/sample_ttitrace.dl.csv
    CB009218_Common_KW.Stop L3Call and DL Traffic

    ${tti_ana}   get_tti_analyzer    ${local_csv_file_path}
    ${check}=   Call Method    ${tti_ana}    check_SLIV_in_dlFdSchedData
    ...   special_slots=${special_slots}   expected_SLIVs=${expected_SLIVs}
    Should be True   ${check}
    Modify actEnhancedPDSCHSchSplSlot Parameter    actEnhancedPDSCHSchSplSlot=false
    coam wait gnb and cells ready    timeout=15min    gnb_type='${gNb_CuType}'
    CB009218_Common_KW.Start L3Call and DL small packet    throughput=1000M
    Start Syve TTI Traces in Streaming mode   trace_ip=${dest_ip}
    Sleep    ${log_capture_time}
    ${tti_trace}=    Stop TTI Traces in Streaming mode
    ...  tti_trace_path=${TS_CASE_LOG_PATH}
    Convert TTI trace from pcap to excelCsv         ${tti_trace}  output_file_path=${TS_CASE_LOG_PATH}/sample_ttitrace
    ...   options=-d dl
    set test variable    ${local_csv_file_path}   ${TS_CASE_LOG_PATH}/sample_ttitrace.dl.csv
    CB009218_Common_KW.Stop L3Call and DL Traffic

    ${tti_ana}   get_tti_analyzer    ${local_csv_file_path}
    ${check}=   Call Method    ${tti_ana}    check_SLIV_in_dlFdSchedData
    ...   special_slots=${special_slots}   expected_SLIVs=${expected_SLIVs}
    Should be True   '${check}'=='False'

cell reset to make parameter affective
    ####due to CB014093 feature
    @{split_version}    string.split string    ${Active_SW_version}    separator=_
    ${stream}    set variable     ${split_version}[0]
    ${cell_list}    Get All Cell Id
    FOR  ${cell_index}  IN  @{cell_list}
        run keyword if    '${stream}'=='SBTS26R1'    selenium_coam.reset_cell    cell_idx=${cell_index}
    END
    sleep    10s
