*** Settings ***
Documentation
...    author: Qingqing Wang
...    contact: qingqing.1.wang@nokia-sbell.com
...    squad group: SG_08
...    feature : CB008184

Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/siso_common_case/step_keywords/5G/basic/bts_selenium.robot
Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/siso_common_case/step_keywords/5G/basic/pre_analysis.robot
Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/siso_common_case/step_keywords/5G/basic/bts_coam.robot
Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/lines/SG8/SG8_common_keywords.robot
Resource    ../../resources/cbrs_common_keywords.robot
Library    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/lines/SG8/SG8_common.py
Variables    ../TestData/CB008184_variables.py

*** Variables ***
@{PA_Ports}    1    2    3    4

@{cell_id1}    ${1}
@{cell_id2}    ${2}
${CB008814_json_path}    ${CURDIR}/json
${disable_actcbrs}    ${CB008814_json_path}/disable_actcbrs.json
${enable_actcbrs}    ${CB008814_json_path}/enable_actcbrs.json
${attach_cell11}    ${CB008814_json_path}/attach_cell11.json
${attach_cell12}    ${CB008814_json_path}/attach_cell12.json
${attach_cell13}    ${CB008814_json_path}/attach_cell13.json
${CB008814_conf_path}    ${CURDIR}/conf
${CB008814_CA_conf}    ${CB008814_conf_path}/CB008814_CA.conf
${soap_sub_dir}    UnitOAM_SOAP_Startup_LBTS_*
*** Keywords ***
CB008814_Manual_SiSo_SM_BTS_Site_Reset
    start SAS server
    Wait until keyword succeeds    5min    30s    verify all cells should be onair
    FOR    ${i}    IN RANGE    0    3
        Connect to gnb coam via ssl
        coam.reset_site   connection=GNB_OAM
        Wait until keyword succeeds    10min    30s    verify all cells should be onair
        csn.reset_cache		
    END
    data_transfer_common    tput_self_define=${tput_define_reset}    cell_id=${cell_id1}    loop_times=${1}    duration=${300}
    ...    target_avg_percent=0.8    min_percent=0.5

get carrier freq from soap log
    [Arguments]    ${sub_dir}=*    ${ru_index}=${1}    ${asik_alias}=ASIK Master
    connect to common unit master    alias=${asik_alias}
    Connect to RU With Allocated IP    ru_index=${1}    ru_alias=RU_1
    ${soap_log_path}    Download soap Log from RU    ru_alias=RU_${ru_index}    sub_dir=${sub_dir}
    ${carrier_freq}    get_last_txarraycarrier_num    xml_file_path=${soap_log_path}
    [Return]    ${carrier_freq}

CB008814-B_1_10MHz_support_channelSpacing_structure_2CC
    ${SCF_CA}    Replace String    ${Golden_SCF_Path}    SCF_    SCF_CA_
    Commissioning SCF And Check RU On Air   scf_file_path=${SCF_CA}
    Activate feature CBRS By Coam
    start SAS server    config_name=${CB008814_CA_conf}
    Wait until keyword succeeds    5min    30s    verify all cells should be onair
    ${release}    Get program version based on gNB active version
    Selenium Login And Disable Screen Lock
    ${carrier_freq_cell1}    Get cell carrier freq
    ${carrier_freq_cell2}    Get cell carrier freq    cell_idx=${2}
    ${distance}    Get the diff    num1=${carrier_freq_cell1}    num2=${carrier_freq_cell2}
    ${diff}    Get the diff    num1=${distance}    num2=${9.99}
    Should be True    ${diff}<0.0001
    Set channelSpace2020 By webem    channelSpace2020=8730    flitervalue_channelSpace2020=Channel spacing between two cells
    Sleep    120s
    Wait until keyword succeeds    5min    30s    verify all cells should be onair
    ${carrier_freq_from_soap}   Run Keyword If   "${release}"=="SBTS23R3"    get carrier freq from soap log
    ...    ELSE    get carrier freq from soap log    sub_dir=${soap_sub_dir}
    ${carrier_freq_cell1_after}    Get cell carrier freq
    ${carrier_freq_cell2_after}    Get cell carrier freq    cell_idx=${2}
    ${distance}    Get the diff    num1=${carrier_freq_cell1_after}    num2=${carrier_freq_cell2_after}
    ${diff}    Get the diff    num1=${distance}    num2=${8.73}
    Should be True    ${diff}<0.0001
    ${tmp_carrier_freq_cell2}=   Evaluate    ${carrier_freq_cell2_after}*100
    ${distance}    Get the diff    num1=${carrier_freq_from_soap}    num2=${tmp_carrier_freq_cell2}
    Should be True    ${distance}<0.000001
    [Teardown]    Selenium Logout And Close Browser

CB008814_LTE_call
    [Arguments]    ${ue_index}=${0}    ${duration}=5m    ${throughput_dl}=350    ${throughput_ul}=50    ${target_throughput_dl}=280
    ...    ${target_throughput_ul}=11.8
    ${ue_type_4G}    translate_power_ue_type_from_testline    ue_index=${ue_index}
    make_call_4G    ue_type_4G=${ue_type_4G}    throughput_dl=${throughput_dl}    throughput_ul=${throughput_ul}    duration_call=1800
    ...    ue_index=${ue_index}
    sleep    300s
    stop_traffic_and_detach_for_4G_call    ue_type_4G=${ue_type_4G}    ue_index=${ue_index}
    check_tput_for_4G_call    ue_type_4G=${ue_type_4G}    target_throughput_dl=${target_throughput_dl}
    ...    target_throughput_ul=${target_throughput_ul}    ue_index=${0}    duration=5m    min_percent=0.1    ignore_time=60
    [Teardown]    run keyword and ignore error    stop_traffic_and_detach_for_4G_call    ue_type_4G=${ue_type_4G}    ue_index=${ue_index}

Manual_SiSo_CALL_LTE_data_call_3CC_10MHz+10MHz+20MHz
    start SAS server
    Wait until keyword succeeds    8min    30s    Verify all lte cells should be onair    connection=GNB_OAM
    coam.perform_delta_recommissioning    delta_file=${attach_cell11}    connection=GNB_OAM
    sleep    20
    CB008814_LTE_call
    coam.perform_delta_recommissioning    delta_file=${attach_cell12}    connection=GNB_OAM
    sleep    90
    CB008814_LTE_call    target_throughput_dl=136    target_throughput_ul=4.8
    coam.perform_delta_recommissioning    delta_file=${attach_cell13}    connection=GNB_OAM
    sleep    90
    CB008814_LTE_call    target_throughput_dl=136    target_throughput_ul=4.8

CB008184_Manual_SiSo_SM_LTE Cell_block_unblock
    start SAS server
    Wait until keyword succeeds    8min    30s    Verify all lte cells should be onair    connection=GNB_OAM
    Wait Until keyword Succeeds    3x    10s    Selenium Login And Disable Screen Lock
    ${cell_id_list}    create list    ${11}    ${12}    ${13}
    Block LTE cells and check status    block_list=${cell_id_list}
    sleep  60
    UnBlock LTE cells and check status    block_list=${cell_id_list}
    Wait until keyword succeeds    5min    30s    Verify all lte cells should be onair    connection=GNB_OAM
    coam.perform_delta_recommissioning    delta_file=${attach_cell11}    connection=GNB_OAM
    sleep    20
    CB008814_LTE_call
    coam.perform_delta_recommissioning    delta_file=${attach_cell12}    connection=GNB_OAM
    sleep    90
    CB008814_LTE_call    target_throughput_dl=136    target_throughput_ul=4.8
    coam.perform_delta_recommissioning    delta_file=${attach_cell13}    connection=GNB_OAM
    sleep    90
    CB008814_LTE_call    target_throughput_dl=136    target_throughput_ul=4.8
    [Teardown]    Selenium Logout And Close Browser

CB008814-AC_2_Online_add_one_higher_priority_CBRS_cell_when_only_20MHz_channel_block_available_2CC
    Set Frequency Channel Value By Coam    frequency_channel=${frequency_3550_3570}
    sleep  30
    Set cbrsFreqPriority value    value=3rd priority
    start SAS server
    Wait until keyword succeeds    5min    30s    verify all cells should be onair
    ${SCF_20M_20M}    Replace String    ${Golden_SCF_Path}    SCF_    SCF_20M_20M_
    Online Cell addition    file_path=${SCF_20M_20M}
    Sleep    60s
    Set cbrsFreqPriority value    value=2nd priority    cellid=2
    ${stamp_case_start}    Get Timestamp For Current Time
    sleep  30
    Wait until keyword succeeds    5min    30s    Check cell status    cellflag=${False} 
    Wait until keyword succeeds    5min    30s    Check cell status	   cell_idx=${2}   cell_group_idx=${1}
    Wait Until Keyword Succeeds    2min    5s    Check Alarm in Alarm List    type=Active    faultId=6828
    ...    stamp_case_start=${stamp_case_start}    Supplementary=No available frequency.    expect=${True}
    data_transfer_common    tput_self_define=${tput_define_AC_2}    cell_id=${cell_id2}    loop_times=${1}    duration=${300}
    ...    target_avg_percent=0.5    min_percent=0.3

make_call_CPE
    [Documentation]    use pointed ue to make call
    ...  :param  tput_info: dict, should contain dl_tp and ul_tp. E.G
    ...          {
    ...              'dl_tp': '500M',
    ...              'ul_tp': '50M',
    ...          }
    [Arguments]    ${tput_info}    ${ue_index}=0    ${protocol}=udp
    ...    ${alias}=ASIK MASTER    ${duration_call}=${1800}    ${process_num}=1
    ${ue_type}    translate_power_ue_type_from_testline    ue_index=${ue_index}
    run keyword and ignore error    power_ue.Prepare UE    ue_type=${ue_type}    ue_index=${ue_index}
    power_ue.UE Attach    ue_type=${ue_type}    ue_index=${ue_index}    attach_mode=5G_${gNb_CuType}
    ${status}    run keyword and return status     Get Length    ${ue_index_list}
    run keyword if    ${status}==False    create empty list
    Run Keyword If   ${ue_index} not in ${ue_index_list}    append to list    ${ue_index_list}    ${ue_index}
    ${iperf_type}  set variable if  '${ue_type}'=='huawei'    via_app    via_command
    ${dl_tp}    set variable    ${tput_info['dl_tp']}
    ${ul_tp}    set variable    ${tput_info['ul_tp']}
    log to console    start dl traffic...
    nokia_fastmile.Start traffic    direction=dl    duration=${duration_call}    throughput=${dl_tp}
    ...    protocol=${protocol}    ue_index=${ue_index}	
    log to console    start ul traffic...
    nokia_fastmile.Start traffic    direction=ul    duration=${duration_call}    throughput=${ul_tp}
    ...    protocol=${protocol}    ue_index=${ue_index}    iperf_type=${iperf_type}     process_num=${process_num}

CB008814 2cc call
    [Arguments]    ${tput_expect}   ${duration}=${300}    ${tput_from}=tool    ${target_avg_percent}=0.3    ${min_percent}=0.2
    ...    ${process_num}=1
    ${tput_define}    get_self_define_tput_by_release    tput_info=${tput_expect}
    Set qRxLevMin value    value=${-35}    cellid=1
    sleep  10
    Set qRxLevMin value    value=${-22}    cellid=2
    sleep  10
    ${tput_info_total}    create dictionary
    ${tput_cell1}    run keyword if    '${tput_from}'=='tool'    get_tput_info_by_tool    cell_id=${1}    target_avg_percent=${target_avg_percent}   
    ...    min_percent=${min_percent}    duration=${duration}    connection=GNB_OAM    ELSE    set variable    ${tput_define[1]}
    set to dictionary    ${tput_info_total}    ${1}    ${tput_cell1}
    log to console    tput info for cell1 is: ${tput_cell1}
    ${ue_index1}    set variable    ${tput_define[1]['ue_index']}
    ${ue_type1}    translate_power_ue_type_from_testline    ue_index=${ue_index1}
    make_call    tput_info=${tput_cell1}    ue_index=${ue_index1}    process_num_ul=${process_num}
    sleep  10
    Set qRxLevMin value    value=${-22}    cellid=1
    sleep  10
    Set qRxLevMin value    value=${-35}    cellid=2
    sleep  10
    ${tput_cell2}    run keyword if    '${tput_from}'=='tool'    get_tput_info_by_tool    cell_id=${2}    target_avg_percent=${target_avg_percent}   
    ...    min_percent=${min_percent}    ue_index=${1}    duration=${duration}    connection=GNB_OAM
    ...    ELSE    set variable    ${tput_define[2]}
    set to dictionary    ${tput_info_total}    ${2}    ${tput_cell2}
    log to console    tput info for cell2 is: ${tput_cell2}
    ${ue_index2}    set variable    ${tput_define[2]['ue_index']}
    ${ue_type2}    translate_power_ue_type_from_testline    ue_index=${ue_index2}
    make_call_CPE    tput_info=${tput_cell2}    ue_index=${ue_index2}    process_num=${process_num}
    ${tput_log1}    power_ue.Collect Tput    ue_type=nokia_fastmile    duration=${duration}    check_source=Aasyslog
    ${tput_log2}    power_ue.Collect Tput    ue_type=nokia_fastmile    duration=${duration}    check_source=Aasyslog
    check_tput_for_each_cell    tput_info=${tput_info_total}    cell_id=${1}    ue_index=${ue_index1}    tput_log=${tput_log1}
    ...    target_avg_percent=${target_avg_percent}    min_percent=${min_percent}
    check_tput_for_each_cell    tput_info=${tput_info_total}    cell_id=${2}    ue_index=${ue_index2}    tput_log=${tput_log2}
    ...    target_avg_percent=${target_avg_percent}    min_percent=${min_percent}
    [Teardown]    run keyword and ignore error    traffic_stop_and_detach_ue    ue_index_list=${ue_index_list}

General_SiSo_E2E_system_setup_with_data_transfer_conducted (max MCS L3 call)_2CC_30MHz+40MHz
    ${SCF_30M_40M}    Replace String    ${Golden_SCF_Path}    SCF_    SCF_30M_40M_
    Commissioning SCF And Check RU On Air   scf_file_path=${SCF_30M_40M}
    Activate feature CBRS By Coam
    start SAS server
    Wait until keyword succeeds    5min    30s    verify all cells should be onair
    sleep  30
    data_transfer_common    tput_self_define=${tput_define_30_40}    cell_id=${cell_id2}    loop_times=${1}    duration=${300}
    ...    target_avg_percent=0.98    min_percent=0.85    process_num_ul=5

General_SiSo_E2E_system_setup_with_data_transfer_conducted (max MCS L3 call)_2CC_40MHz+40MHz__new_frame_prachConfig_A2
    ${SCF_40M_40M}    Replace String    ${Golden_SCF_Path}    SCF_    SCF_40M_40M_
    Commissioning SCF And Check RU On Air   scf_file_path=${SCF_40M_40M}
    Activate feature CBRS By Coam
    start SAS server
    Wait until keyword succeeds    5min    30s    verify all cells should be onair
    sleep  30
    log to console    SET PA
    Set PA Value For Pointed Port    PA_Port_List=${PA_Ports}    value=${20}
    CB008814 2cc call    tput_expect=${tput_define}    duration=${300}    target_avg_percent=0.95
    ...    min_percent=0.85    process_num=5
    [Teardown]    Set PA Value For Pointed Port    PA_Port_List=${PA_Ports}    value=${15}


CB008814_Manual_SiSo_SM_RF_Module_lock_unlock
    ${SCF_20M_40M}    Replace String    ${Golden_SCF_Path}    SCF_    SCF_20M_40M_
    Commissioning SCF And Check RU On Air   scf_file_path=${SCF_20M_40M}
    Activate feature CBRS By Coam
    start SAS server
    Wait until keyword succeeds    5min    30s    verify all cells should be onair
#    CB008814 2cc call    duration=${120}
    Wait Until keyword Succeeds    3x    10s    Selenium Login And Disable Screen Lock
    selenium_coam.lock_ru    ru_index=${1}
    sleep  15
    wait until keyword succeeds    5min    20sec    RU Should Be Locked    ru_index=${1}
    sleep  60
    selenium_coam.unlock_ru    ru_index=${1}
    sleep  15
    wait until keyword succeeds    10min    20sec    RU Should Be Unlocked    ru_index=${1}
    sleep  30
    Wait until keyword succeeds    5min    30s    verify all cells should be onair
    CB008814 2cc call    tput_expect=${tput_define_lock}    duration=${300}
    ...    target_avg_percent=0.95    min_percent=0.85    process_num=5
    [Teardown]    Selenium Logout And Close Browser
