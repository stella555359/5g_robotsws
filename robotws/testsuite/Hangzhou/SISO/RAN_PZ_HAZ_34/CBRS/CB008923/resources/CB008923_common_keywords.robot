*** Settings ***
Documentation
...    Author:wangqingqing & gaoshengqing
...    contact:qingqing.wang@nokia-sbell.com & melinda.gao@nokia-sbell.com
...    squad group:SG_08
...    Feature CB008923

Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/siso_common_case/step_keywords/5G/basic/bts_selenium.robot
Resource    ../../resources/cbrs_common_keywords.robot
Resource    ../../CB008498/resources/CB008498_common_keywords.robot
Resource    testsuite/Hangzhou/SISO/RAN_PZ_HAZ_34/CB005763/Resources/CB005763_keyword.robot
Library    DateTime
Library    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/lines/SG8/SG8_common.py
Variables    ../TestData/8923_variables.py

*** Variables ***
@{cell_id1}    ${1}
@{cell_id2}    ${2}
${CB008923_conf_path}    ${CURDIR}/conf
${CB008923_9_conf}    ${CB008923_conf_path}/CB008923-A_9.conf
${CB008923_4_conf}    ${CB008923_conf_path}/CB008923-A_4.conf
${CB008923_5_conf}    ${CB008923_conf_path}/CB008923-A_5.conf
${CB008923_A_10_conf}    ${CB008923_conf_path}/CB008923-A_10.conf
${CB008923_14_conf}    ${CB008923_conf_path}/CB008923-A_14.conf
${CB008923_B_21_conf}    ${CB008923_conf_path}/CB008923-B_21.conf
${CB008923_B_25_conf}    ${CB008923_conf_path}/CB008923-B_25.conf
${CB008923_D_conf}    ${CB008923_conf_path}/CB008923-D.conf
${CB008923_json_path}    ${CURDIR}/json
${disable_actcbrs_TL1000}    ${CB008923_json_path}/disable_actcbrs_TL1000.json
${enable_actcbrs_TL1000}    ${CB008923_json_path}/enable_actcbrs_TL1000.json
${disable_actcbrs}    ${CB008923_json_path}/disable_actcbrs.json
${enable_actcbrs}    ${CB008923_json_path}/enable_actcbrs.json
${throughput_dl_LTE}    300
${throughput_ul_LTE}    50
${target_throughput_ul}    12
${target_throughput_dl}    109
*** Keywords ***
Case Preparation
    ${SCF_2CC}    Replace String    ${Golden_SCF_Path}    SCF_    SCF_2CC_
    set suite variable  ${SCF_2CC}
    ${SCF_1CC}    Replace String    ${Golden_SCF_Path}    SCF_    SCF_CB008923-A_1CC_
    set suite variable  ${SCF_1CC}
    Commissioning SCF And Check RU On Air   scf_file_path=${SCF_2CC}
    &{fault_7313}     Create Dictionary     faultId=${7313}
    ${ALLOWED_FAULT}   Create List   @{ALLOWED_FAULT}   ${fault_7313}
    set suite variable  ${ALLOWED_FAULT}

Case Preparation CB008923-C
    Connect to eNB via ssl
    ${SCF_CB008923-C_4G}    Replace String    ${Golden_SCF_Path}    SCF_    SCF_CB008923-C_4G_
    COAM Commission with scf file    scf_file_path=${SCF_CB008923-C_4G}    connection=enblte    timeout=600    is_pdl_checking_needed=${if_pdl_check}
    Sleep    300s
    ${mrbtsID_enb}    ${lnbtsID}    Get mrbtsID and lnbtsID via SCF for eNB    scf_path=${SCF_CB008923-C_4G}
    log to console  ENB_MRBTS_ID:${mrbtsID_enb}, LNBTS_ID:${lnbtsID}
    set suite variable  ${mrbtsID_enb}
    set suite variable  ${lnbtsID}
    &{fault_6826}     Create Dictionary     faultId=${6826}
    &{fault_7313}     Create Dictionary     faultId=${7313}
    ${ALLOWED_FAULT}   Create List   @{ALLOWED_FAULT}   ${fault_6826}    ${fault_7313}
    set suite variable  ${ALLOWED_FAULT}
    Enblte close down

CB008923-C CBRS Test Setup
    [Arguments]    ${enable_delta_file}=${enable_actcbrs}
    CBRS Test Setup
    CBRS 4G Test Setup    enable_delta_file=${enable_delta_file}

CB008923-C CBRS Test Teardown
    [Arguments]    ${disable_delta_file}=${disable_actcbrs}
    CBRS 4G Test Teardown    disable_delta_file=${disable_delta_file}
    CBRS Test Teardown

Check CBRS only NR Call
    [Arguments]    ${duration}=${600}    ${target_avg_percent}=0.3    ${min_percent}=0.2
    ${tput_info_total}    create dictionary
    ${tput_cell}    get_tput_info_by_tool    cell_id=${1}    target_avg_percent=${target_avg_percent}
    ...    min_percent=${min_percent}    duration=${duration}    connection=GNB_OAM
    set to dictionary    ${tput_info_total}    ${1}    ${tput_cell}
    log to console    tput info for cell is: ${tput_cell}
    ${tput_cell_5G}    set variable    ${tput_8923_C_5G[1]}
    ${ue_index}    set variable    ${tput_cell_5G['ue_index']}
    ${ue_type}    translate_power_ue_type_from_testline    ue_index=${ue_index}
    make_call    tput_info=${tput_cell}    ue_index=${ue_index}
    ${tput_log}    power_ue.Collect Tput    ue_type=nokia_fastmile    duration=${duration}    check_source=Aasyslog
    check_tput_for_each_cell    tput_info=${tput_info_total}    cell_id=${1}    ue_index=${ue_index}    tput_log=${tput_log}
    ...    target_avg_percent=${target_avg_percent}    min_percent=${min_percent}
    traffic_stop_and_detach_ue    ue_index_list=${ue_index_list}

Check CBRS NR And LTE Call
    [Arguments]    ${duration}=${600}    ${target_avg_percent}=0.3    ${min_percent}=0.2
    ${tput_info_total}    create dictionary
    ${tput_cell}    get_tput_info_by_tool    cell_id=${1}    target_avg_percent=${target_avg_percent}
    ...    min_percent=${min_percent}    duration=${duration}    connection=GNB_OAM
    set to dictionary    ${tput_info_total}    ${1}    ${tput_cell}
    log to console    tput info for cell is: ${tput_cell}
    ${tput_cell_5G}    set variable    ${tput_8923_C_5G[1]}
    ${ue_index}    set variable    ${tput_cell_5G['ue_index']}
    ${ue_type}    translate_power_ue_type_from_testline    ue_index=${ue_index}
    ${ue_type_4G}    translate_power_ue_type_from_testline    ue_index=${1}
    make_call    tput_info=${tput_cell}    ue_index=${ue_index}
    make_call_4G    ue_type_4G=${ue_type_4G}    throughput_dl=${throughput_dl_LTE}    throughput_ul=${throughput_ul_LTE}    duration_call=1800
    ...    ue_index=${1}
    ${tput_log}    power_ue.Collect Tput    ue_type=nokia_fastmile    duration=${duration}    check_source=Aasyslog
    check_tput_for_each_cell    tput_info=${tput_info_total}    cell_id=${1}    ue_index=${ue_index}    tput_log=${tput_log}
    ...    target_avg_percent=${target_avg_percent}    min_percent=${min_percent}
    check_tput_for_4G_call    ue_type_4G=${ue_type_4G}    target_throughput_dl=${target_throughput_dl}
    ...    target_throughput_ul=${target_throughput_ul}    ue_index=${1}    duration=${duration}    target_avg_percent=${target_avg_percent}
    detach_for_4G_call    ue_type_4G=${ue_type_4G}    ue_index=${1}
    traffic_stop_and_detach_ue    ue_index_list=${ue_index_list}

CB008923-C_16_CBSD_behavior_check_when_gNB_reset_master_is_NR
    Connect to eNB via ssl
    start SAS server
    Wait until keyword succeeds    5min    30s    verify all cells should be onair
    Wait until keyword succeeds    5min    30s    Verify all lte cells should be onair    connection=enblte
    coam.reset_site   connection=GNB_OAM
    Sleep    120s
    Wait until keyword succeeds    10min    30s    verify all cells should be onair
    Wait until keyword succeeds    5min    30s    Verify all lte cells should be onair    connection=enblte
    Check CBRS only NR Call    duration=${300}

CB008923-C_26_data_transfer_conducted_peak_throughput_NR_40MHz_LTE_20MHz
    Connect to eNB via ssl
    start SAS server
    Wait until keyword succeeds    5min    30s    verify all cells should be onair
    Wait until keyword succeeds    5min    30s    Verify all lte cells should be onair    connection=enblte
    Check CBRS only NR Call    duration=${300}    target_avg_percent=0.75    min_percent=0.55

CB008923-C_13_CBSD_behavior_check_when_RU_reset_master_is_NR
    Connect to eNB via ssl
    start SAS server
    Wait until keyword succeeds    5min    30s    verify all cells should be onair
    Wait until keyword succeeds    5min    30s    Verify all lte cells should be onair    connection=enblte
    Perform RU Reset
    Wait Until Keyword Succeeds    5min    30s    RU Should Be Offline
    Wait Until Keyword Succeeds    10min    30s    verify all cells should be onair
    Wait until keyword succeeds    5min    30s    Verify all lte cells should be onair    connection=enblte
    Check CBRS only NR Call    duration=${300}

CB008923-C_9_CBSD_behavior_check_when_RU_lock_unlock_master_is_NR
    Connect to eNB via ssl
    start SAS server
    Wait until keyword succeeds    5min    30s    verify all cells should be onair
    Wait until keyword succeeds    5min    30s    Verify all lte cells should be onair    connection=enblte
    Check CBRS NR And LTE Call    duration=${300}
    Modify the parameter on NR    dist_name=MRBTS-${mrbtsID}/EQM-1/APEQM-1/RMOD-1     parameter_name=administrativeState    value=Locked
    Wait Until Keyword Succeeds    3 min    3 sec    RU Should Be Locked
    Wait Until Keyword Succeeds    3 min    5 sec    Cell Should Be Disabled
    Modify the parameter on NR    dist_name=MRBTS-${mrbtsID}/EQM-1/APEQM-1/RMOD-1     parameter_name=administrativeState    value=Unlocked
    Wait Until Keyword Succeeds    4 min   3 sec    RU Should Be Unlocked
	Wait Until Keyword Succeeds    4 min   3 sec    Cell Should Be Enabled
    Wait until keyword succeeds    5min    30s    verify all cells should be onair
    Wait until keyword succeeds    5min    30s    Verify all lte cells should be onair    connection=enblte
    Check CBRS NR And LTE Call    duration=${300}

Case Preparation CB008923-B
    ${SCF_CB008923-B}    Replace String    ${Golden_SCF_Path}    SCF_    SCF_CB008923-B_
    set suite variable  ${SCF_CB008923-B}
    Commissioning SCF And Check RU On Air   scf_file_path=${SCF_CB008923-B}
    ${mrbtsID_enb}    ${lnbtsID}    Get mrbtsID and lnbtsID via SCF for eNB    scf_path=${SCF_CB008923-B}
    log to console  ENB_MRBTS_ID:${mrbtsID_enb}, LNBTS_ID:${lnbtsID}
    set suite variable  ${mrbtsID_enb}
    set suite variable  ${lnbtsID}
    &{fault_6826}     Create Dictionary     faultId=${6826}
    ${ALLOWED_FAULT}   Create List   @{ALLOWED_FAULT}   ${fault_6826}
    set suite variable  ${ALLOWED_FAULT}

CB008923-B CBRS Suite Setup
    CBRS Suite Setup    feature_scf_flag=${True}
    Case Preparation CB008923-B

CB008923-B CBRS Test Setup
    [Arguments]    ${enable_delta_file}=${enable_actcbrs_TL1000}
    CBRS Test Setup
    coam.perform_delta_recommissioning    delta_file=${enable_delta_file}    connection=GNB_OAM
    Sleep    60s

CB008923-B CBRS Test Teardown
    [Arguments]    ${disable_delta_file}=${disable_actcbrs_TL1000}
    coam.perform_delta_recommissioning    delta_file=${disable_delta_file}    connection=GNB_OAM
    Wait until keyword succeeds    5min    30s    Verify all lte cells should be disabled    connection=GNB_OAM
    CBRS Test Teardown

CB008923-B_13_CBSD_behavior_check_when_NR_RAT_reset
    start SAS server
    Wait until keyword succeeds    5min    30s    verify all cells should be onair
    Wait until keyword succeeds    5min    30s    Verify all lte cells should be onair    connection=GNB_OAM
    coam.rat_reset       rat_type=NR     timeout=300    connection=GNB_OAM
    Sleep    120s
    Wait until keyword succeeds    10min    30s    verify all cells should be onair
    Wait until keyword succeeds    5min    30s    Verify all lte cells should be onair    connection=GNB_OAM
    data_transfer_common    tput_self_define=${tput_define_B_13}    cell_id=${cell_id1}    loop_times=${1}    duration=${300}
    ...    target_avg_percent=0.5    min_percent=0.2

CB008923-B_11_CBSD_behavior_check_when_RU_reset
    start SAS server
    Wait until keyword succeeds    5min    30s    verify all cells should be onair
    Wait until keyword succeeds    5min    30s    Verify all lte cells should be onair    connection=GNB_OAM
    Perform RU Reset
    Wait Until Keyword Succeeds    5min    30s    RU Should Be Offline
    Sleep    60s
    Wait until keyword succeeds    8min    30s    verify all cells should be onair
    Wait until keyword succeeds    5min    30s    Verify all lte cells should be onair    connection=GNB_OAM
    data_transfer_common    tput_self_define=${tput_define_B_11}    cell_id=${cell_id1}    loop_times=${1}    duration=${300}
    ...    target_avg_percent=0.5    min_percent=0.2

CB008923-B_29_data_transfer_conducted_peak_throughput_NR_20MHz_LTE_10MHz
    start SAS server
    Wait until keyword succeeds    5min    30s    verify all cells should be onair
    Wait until keyword succeeds    5min    30s    Verify all lte cells should be onair    connection=GNB_OAM
    Sleep    60s
    data_transfer_common    tput_self_define=${tput_define_8923}    cell_id=${cell_id1}    loop_times=${1}    duration=${300}
    ...    target_avg_percent=0.5    min_percent=0.2

CB008923-B_9_CBSD_behavior_check_when_NR_cell_block_unblock
    start SAS server
    Wait until keyword succeeds    8min    30s    verify all cells should be onair
    Wait until keyword succeeds    5min    30s    Verify all lte cells should be onair    connection=GNB_OAM
    ${grant_info_nr_old}    Get Grant Parameters By Coam
    ${grantId_lte_old}    Get Parameter value via COAM    class_name=CBSDCEL_R    pattern=grantId    connection=GNB_OAM
    data_transfer_common    tput_self_define=${tput_define_B_9}    cell_id=${cell_id1}    loop_times=${1}    duration=${120}
    ...    target_avg_percent=0.5    min_percent=0.2
    Selenium Login And Disable Screen Lock
    Get X2 link shutdown waiting time
    ${block_list}    Create List    1
    Block cells and check status    block_list=${block_list}   check_alarm=${False}    gnb_type='${gNb_CuType}'
    Sleep    20s
    Verify all lte cells should be onair    connection=GNB_OAM
    ${grant_info_nr_new}    Get Grant Parameters By Coam
    ${grantId_lte_new}    Get Parameter value via COAM    class_name=CBSDCEL_R    pattern=grantId    connection=GNB_OAM
    Should be True    '${grant_info_nr_new}[grantId]'=='${grant_info_nr_old}[grantId]'
    Should be True    '${grantId_lte_new}'=='${grantId_lte_old}'
    UnBlock Cells and check status    block_list=${block_list}   check_alarm=${False}    gnb_type='${gNb_CuType}'
    Sleep    20s
    ${grant_info_nr_new}    Get Grant Parameters By Coam
    ${grantId_lte_new}    Get Parameter value via COAM    class_name=CBSDCEL_R    pattern=grantId    connection=GNB_OAM
    Should be True    '${grant_info_nr_new}[grantId]'=='${grant_info_nr_old}[grantId]'
    Should be True    '${grantId_lte_new}'=='${grantId_lte_old}'
    data_transfer_common    tput_self_define=${tput_define_B_9}    cell_id=${cell_id1}    loop_times=${1}    duration=${120}
    ...    target_avg_percent=0.5    min_percent=0.2
    ${ltecbsdid}    Get Parameter value via COAM    class_name=CBSD_R   pattern=assignedCbsdId    connection=GNB_OAM
    Check No relinquishmentRequest procedure    cbsdid=${ltecbsdid}
    [Teardown]    Selenium Logout And Close Browser

CB008923-B_3_Migration of a NR only site to a NR-LTE RF sharing site with AEQM
    ${SCF_1CC}    Replace String    ${Golden_SCF_Path}    SCF_    SCF_CB008923-B_NR_only_
    COAM Commission with scf file    scf_file_path=${SCF_1CC}    timeout=600    is_pdl_checking_needed=${if_pdl_check}
    Sleep    300s
    Activate feature CBRS By Coam
    start SAS server
    Wait until keyword succeeds    5min    30s    verify all cells should be onair
    COAM Commission with scf file    scf_file_path=${SCF_CB008923-B}    timeout=600    is_pdl_checking_needed=${if_pdl_check}
    Sleep    300s
    Activate feature CBRS By Coam
    Sleep    60s
    coam.perform_delta_recommissioning    delta_file=${enable_actcbrs_TL1000}    connection=GNB_OAM
    Sleep    60s
    Wait until keyword succeeds    5min    30s    verify all cells should be onair
    Wait until keyword succeeds    5min    30s    Verify all lte cells should be onair    connection=GNB_OAM
    data_transfer_common    tput_self_define=${tput_define_8923}    cell_id=${cell_id1}    loop_times=${1}    duration=${300}
    ...    target_avg_percent=0.5    min_percent=0.2

Online add LTE cell
    [Arguments]    ${file_path}    ${addition_cell_lte}=194  ${lcrId_lte}=1    ${connection}=GNB_OAM
    ${activate_plan_despite_errors}    set variable if    ${if_pdl_check}    ${False}    ${True}
    Connect to gnb coam via ssl    connection=${connection}
    selenium login and disable screen lock
    selenium_coam.load_commissioning_file_and_check_load_status    file_path=${file_path}
    log to console    add lte object
    selenium_coam.add_object    object_name=MRBTS-${mrbtsID}/LNBTS-${lnbtsID}
    ...    object_class_name=LNCEL    plan_to_copy_from=CONF-1
    ...    copy_from=MRBTS-${mrbtsID}/LNBTS-${lnbtsID}/LNCEL-${addition_cell_lte}
    ...    include_subobject=${True}   id_value=${addition_cell_lte}    timeout=15
    selenium_coam.add_object    object_name=MRBTS-${mrbtsID}/MNL-1/MNLENT-1/CELLMAPPING-1
    ...    object_class_name=LCELL    plan_to_copy_from=CONF-1
    ...    copy_from=MRBTS-${mrbtsID}/MNL-1/MNLENT-1/CELLMAPPING-1/LCELL-${lcrId_lte}
    ...    include_subobject=${True}   id_value=${lcrId_lte}    timeout=15
    selenium_coam.set_parameter_value    dist_name=MRBTS-${mrbtsID}/LNBTS-${lnbtsID}/LNCEL-${addition_cell_lte}
    ...    filter_param=Local cell resource ID    abbr=lcrId    new_value=${lcrId_lte}
    log to console    begin to validate
    selenium_coam.validate_plan
    log to console    begin to activate
    selenium_coam.activate_plan    activate_plan_despite_errors=${activate_plan_despite_errors}    timeout=300
    [Return]  selenium logout and close browser

CB008923-B_25_online_add_one_higher_LTE_cell_under_RFS
    ${stamp_case_start}    Get Timestamp For Current Time
    ${SCF_CB008923-B_25}    Replace String    ${Golden_SCF_Path}    SCF_    SCF_CB008923-B_25_
    COAM Commission with scf file  scf_file_path=${SCF_CB008923-B_25}    timeout=600    is_pdl_checking_needed=${if_pdl_check}
    sleep    300s
    start SAS server    config_name=${CB008923_B_25_conf}
    Wait until keyword succeeds    5min    30s    verify all cells should be onair
    Wait until keyword succeeds    5min    30s    Verify all lte cells should be onair    connection=GNB_OAM
    ${grant_info_nr_old}    Get Grant Parameters By Coam
    ${SCF_2LTE}    Replace String    ${Golden_SCF_Path}    SCF_    SCF_2LTECell_
    Online add LTE cell    file_path=${SCF_2LTE}
    Sleep    100s
    Modify the parameter on NR    dist_name=MRBTS-${mrbtsID_enb}/LNBTS-${lnbtsID}/LNCEL-194/CBSDCEL-0
    ...    parameter_name=cbrsFreqPriority    value=2nd priority
    Sleep    30s
	Wait until keyword succeeds    5min    30s    Verify all cells should be disabled
    Wait until keyword succeeds    5min    30s    Verify all lte cells should be onair    connection=GNB_OAM
    Wait Until Keyword Succeeds    5min    5s    Check Alarm in Alarm List    type=Active    faultId=6828
    ...    stamp_case_start=${stamp_case_start}    Supplementary=No available frequency.    expect=${True}
    Check relinquishment Success Message    grantId=${grant_info_nr_old}[grantId]
    coam.perform_delta_recommissioning    delta_file=${disable_actcbrs_TL1000}    connection=GNB_OAM
    Sleep    60s
    Wait until keyword succeeds    5min    30s    Verify all lte cells should be disabled    connection=GNB_OAM
    ${GrantOperationState_LTE}    Get Parameter value via COAM    class_name=CBSDCEL_R    pattern=grantOperationState    connection=GNB_OAM
    Should be True    '${GrantOperationState_LTE}' == 'Idle'

CB008923-B_21_online_modify_supportedSpectrumV2_to_expand_bandwidth
    ${stamp_case_start}    Get Timestamp For Current Time
    ${SCF_CB008923-B_21}    Replace String    ${Golden_SCF_Path}    SCF_    SCF_CB008923-B_21_
    COAM Commission with scf file  scf_file_path=${SCF_CB008923-B_21}    timeout=600    is_pdl_checking_needed=${if_pdl_check}
    sleep    300s
    start SAS server    config_name=${CB008923_B_21_conf}
    Wait until keyword succeeds    5min    30s    verify all cells should be onair
    Wait until keyword succeeds    5min    30s    Verify all lte cells should be onair    connection=GNB_OAM
    Set Frequency Channel Value By Coam    frequency_channel=${frequency_first_8}
    Sleep    200s
    Wait until keyword succeeds    5min    30s    verify all cells should be onair
    ${nrcell_grantid}    Get NRCBSDCELL_R value via COAM    pattern=grantId
    Should be True    '${nrcell_grantid}'=='3550000000_3590000000'
    Verify all lte cells should be disabled    connection=GNB_OAM
    Check Alarm in Alarm List    type=Active    faultId=6827
    ...    stamp_case_start=${stamp_case_start}    Supplementary=No available frequency.    expect=${True}

CB008923-B_33_verify_preemption_between_LTE_and_NR_cells
    Set Frequency Channel Value By Coam    frequency_channel=${frequency_3570_3590}
    Sleep    30s
    Modify the parameter on NR    dist_name=MRBTS-${mrbtsID_enb}/LNBTS-${lnbtsID}/CBSD-1
    ...    parameter_name=supportedSpectrumV2    value=${frequency_3570_3590}
    Sleep    30s
    Set cbrsFreqPriority value    value=2nd priority
    Modify the parameter on NR    dist_name=MRBTS-${mrbtsID_enb}/LNBTS-${lnbtsID}/LNCEL-193/CBSDCEL-0
    ...    parameter_name=cbrsFreqPriority    value=3rd priority
    coam.perform_delta_recommissioning    delta_file=${disable_actcbrs_TL1000}    connection=GNB_OAM
    Sleep    60s
    ${stamp_case_start}    Get Timestamp For Current Time
    start SAS server
    Wait until keyword succeeds    5min    30s    verify all cells should be onair
    Sleep    120s
    Verify all lte cells should be disabled    connection=GNB_OAM
    coam.perform_delta_recommissioning    delta_file=${enable_actcbrs_TL1000}    connection=GNB_OAM
    Wait Until Keyword Succeeds    5min    5s    Check Alarm in Alarm List    type=Active    faultId=6827
    ...    stamp_case_start=${stamp_case_start}    Supplementary=No available frequency.    expect=${True}
    Verify all lte cells should be disabled    connection=GNB_OAM
    ${grant_info_nr_old}    Get Grant Parameters By Coam
    Should be True    '${grant_info_nr_old}[grantId]'=='3570000000_3590000000'
    Set Frequency Channel Value By Coam    frequency_channel=${frequency_first_8}
    Sleep    60s
    Wait until keyword succeeds    5min    30s    verify all cells should be onair
    ${grant_info_nr}    Get Grant Parameters By Coam
    Should be True   '${grant_info_nr}[grantId]'=='3550000000_3570000000' or '${grant_info_nr}[grantId]'=='3560000000_3580000000'
    Check relinquishment Success Message    grantId=${grant_info_nr_old}[grantId]
    Wait until keyword succeeds    5min    30s    Verify all lte cells should be onair    connection=GNB_OAM
    ${grantId_lte}    Get Parameter value via COAM    class_name=CBSDCEL_R    pattern=grantId    connection=GNB_OAM
    Run Keyword If    '${grant_info_nr}[grantId]'=='3550000000_3570000000'
    ...    Should be True    '${grantId_lte}'=='3570000000_3580000000' or '${grantId_lte}'=='3580000000_3590000000'
    ...    ELSE    Should be True    '${grantId_lte}'=='3550000000_3560000000' or '${grantId_lte}'=='3580000000_3590000000'

CB008923-E_2_CBSD Cell Activation - TS version 2.0_under_SBTS_RFS
    start SAS server    path=${sas_2_0}
    Wait until keyword succeeds    5min    30s    verify all cells should be onair
    Wait until keyword succeeds    5min    30s    Verify all lte cells should be onair    connection=GNB_OAM

Check Case CB008923-A 5 CBRS Process
    [Arguments]    ${groupId_need}=${True}    ${groupType_need}=${True}    ${NRCBSDID}=1    ${ru_index}=1
    Get Correct Register Parameters Value By Coam    groupId_need=${groupId_need}    groupType_need=${groupType_need}
    ...    NRCBSDID=${NRCBSDID}    ru_index=${ru_index}
    ${cbsdId}    Get From Dictionary    dictionary=${cbsdIds}    key=${NRCBSDID}
    Set test variable    ${cbsdId}
    prepare_to_check_message_from_start
    Check if message is found in saslog    tag=${register_info}
    Check if message is found in saslog    tag={\"registrationResponse\":.*"cbsdId": "${cbsdId}(.NR)?".*\"responseCode\": 0.*
    Check if message is found in saslog    tag={\"grantRequest\":.*\"cbsdId\":\"${cbsdId}(.NR)?\".*
    Check if message is found in saslog    tag={\"grantResponse\":.*"cbsdId": "${cbsdId}(.NR)?".*"responseCode": 0.*
    Check if message is found in saslog    tag={\"heartbeatRequest\":.*\"cbsdId\":\"${cbsdId}(.NR)?\".*
    Check if message is found in saslog    tag={\"heartbeatResponse\":.*"cbsdId": "${cbsdId}(.NR)?".*\"responseCode\": 0.*
    Check if message is found in saslog    tag={\"relinquishmentRequest\":.*
    Check if message is found in saslog    tag={\"relinquishmentResponse\":.*
    Check if message is found in saslog    tag={\"relinquishmentRequest\":.*
    Check if message is found in saslog    tag={\"relinquishmentResponse\":.*
    Check if message is found in saslog    tag={\"grantRequest\":.*\"cbsdId\":\"${cbsdId}(.NR)?\".*
    Check if message is found in saslog    tag={\"grantResponse\":.*"cbsdId": "${cbsdId}(.NR)?".*"responseCode": 0.*
    [Teardown]    end_to_check

CB008923-A_5_Online_delete_the_higher_priority_CBRS_cell_when_only_20MHz_PAL_channel_block_available
    Set cbrsFreqPriority value    value=2nd priority
    Set cbrsFreqPriority value    value=3rd priority    cellid=2
    Set qRxLevMin value    value=${-40}    cellid=2
    Sleep    60s
    start SAS server    config_name=${CB008923_5_conf}
    Wait until keyword succeeds    10min    30s    verify all cells should be onair
    ${grant_info_coam_cell1}    Get Grant Parameters By Coam
    Should be True    '${grant_info_coam_cell1}[grantChannelType]'=='PAL'
	${grant_info_coam_cell2}    Get Grant Parameters By Coam    cellID=2
    Should be True    '${grant_info_coam_cell2}[grantChannelType]'=='GAA'
    Online Cell deletion
    Sleep    60s
    Wait until keyword succeeds    3min    30s    verify all cells should be onair
    ${grant_info_coam_cell2}    Get Grant Parameters By Coam    cellID=2
    Should be True    '${grant_info_coam_cell2}[grantChannelType]'=='PAL'
    Wait Until Keyword Succeeds    2min    10s    Check Case CB008923-A 5 CBRS Process    groupId_need=${False}    groupType_need=${False}
    data_transfer_common    tput_self_define=${tput_define_A_5}    cell_id=${cell_id2}    loop_times=${1}    duration=${120}
    ...    target_avg_percent=0.5    min_percent=0.2

CB008923-A_4_Online_add_one_higher_priority_CBRS_cell_when_only_20MHz_channel_block_available
    COAM Commission with scf file    scf_file_path=${SCF_1CC}    timeout=600    is_pdl_checking_needed=${if_pdl_check}
    Sleep    300s
    Activate feature CBRS By Coam
    Set cbrsFreqPriority value    value=3rd priority
    Sleep    60s
    ${stamp_case_start}    Get Timestamp For Current Time
    start SAS server    config_name=${CB008923_4_conf}
    Wait until keyword succeeds    5min    30s    verify all cells should be onair
    Check Register Success Message    groupId_need=${False}    groupType_need=${False}
    Online Cell addition    file_path=${SCF_2CC}
    Sleep    60s
    Wait until keyword succeeds    5min    30s    Check cell status
    Wait until keyword succeeds    5min    30s    Check cell status	   cell_idx=${2}   cell_group_idx=${1}   cellflag=${False}
    Wait Until Keyword Succeeds    2min    5s    Check Alarm in Alarm List    type=Active    faultId=6828
    ...    stamp_case_start=${stamp_case_start}    Supplementary=No available frequency.    expect=${True}
    Set cbrsFreqPriority value    value=2nd priority    cellid=2
    Wait until keyword succeeds    5min    30s    Check cell status    cellflag=${False}
    Wait until keyword succeeds    5min    30s    Check cell status	   cell_idx=${2}   cell_group_idx=${1}
    Wait Until Keyword Succeeds    2min    5s    Check Alarm in Alarm List    type=Active    faultId=6828
    ...    stamp_case_start=${stamp_case_start}    Supplementary=No available frequency.    expect=${True}
    Set qRxLevMin value    value=${-22}    cellid=1
    Set qRxLevMin value    value=${-40}    cellid=2
    Sleep    60s
    data_transfer_common    tput_self_define=${tput_define_8923}    cell_id=${cell_id2}    loop_times=${1}    duration=${120}
    ...    target_avg_percent=0.5    min_percent=0.2

CB008923-A_8_Verify_CBSD_cells_behavior_when_online_modify_desirePmax
    Set Frequency Channel Value By Coam    frequency_channel=${frequency_first_8}
    Sleep    60s
    start SAS server
    Wait until keyword succeeds    5min    30s    verify all cells should be onair
    ${grant_info_coam_cell1_old}    Get Grant Parameters By Coam
    ${grant_info_coam_cell2_old}    Get Grant Parameters By Coam    cellID=2
    Set test variable    ${grantId_1}    ${grant_info_coam_cell1_old}[grantId]
    Set test variable    ${grantId_2}    ${grant_info_coam_cell2_old}[grantId]
    Selenium Login And Disable Screen Lock
    Set desiredPmax By WEBEM    value=20
    Sleep    60s
    Wait until keyword succeeds    5min    30s    verify all cells should be onair
    ${grant_info_coam_cell1_tmp}    Get Grant Parameters By Coam
    ${grant_info_coam_cell2_tmp}    Get Grant Parameters By Coam    cellID=2
    Should be True    '${grant_info_coam_cell1_old}[maxEirp]'!='${grant_info_coam_cell1_tmp}[maxEirp]'
    Should be True    '${grant_info_coam_cell2_old}[maxEirp]'=='${grant_info_coam_cell2_tmp}[maxEirp]'
    Check CB008923-A_8 Message    groupId_need=${False}    groupType_need=${False}
    Check CB008923-A_8 no impact cell2
    [Teardown]    Selenium Logout And Close Browser

Check CB008923-A_8 Message
    [Arguments]    ${groupId_need}=${True}    ${groupType_need}=${True}    ${NRCBSDID}=1    ${ru_index}=1
    Get Correct Register Parameters Value By Coam    groupId_need=${groupId_need}    groupType_need=${groupType_need}
    ...    NRCBSDID=${NRCBSDID}    ru_index=${ru_index}
    ${cbsdId}    Get From Dictionary    dictionary=${cbsdIds}    key=${NRCBSDID}
    ${grantResp}    Set variable
    ...    {\"grantResponse\":.*"grantId": \"${grantId_1}"\.*\"responseCode\": 0.*"grantId": \"${grantId_2}"\.*\"responseCode\": 0.*
    prepare_to_check_message_from_start
    Check if message is found in saslog    tag=${register_info}
    Check if message is found in saslog    tag={\"registrationResponse\":.*\"cbsdId\": \"${cbsdId}(.NR)?\".*\"responseCode\": 0.*
    Check if message is found in saslog    tag={\"spectrumInquiryRequest\":.*\"cbsdId\":\"${cbsdId}(.NR)?\".*
    Check if message is found in saslog    tag={\"spectrumInquiryResponse\":.*"cbsdId": "${cbsdId}(.NR)?".*\"responseCode\": 0.*
    Check if message is found in saslog    tag={\"grantRequest\":.*
    Check if message is found in saslog    tag=${grantResp}
    Check if message is found in saslog    tag={\"heartbeatRequest\":.*\"cbsdId\":\"${cbsdId}(.NR)?\".*
    Check if message is found in saslog    tag={\"heartbeatResponse\":.*"cbsdId": "${cbsdId}(.NR)?".*\"responseCode\": 0.*
    Check if message is found in saslog    tag={\"relinquishmentRequest\":.*
    Check if message is found in saslog    tag={\"relinquishmentResponse\":.*"grantId": \"${grantId_1}"\.*\"responseCode\": 0.*
    Check if message is found in saslog    tag={\"grantRequest\":.*
    Check if message is found in saslog    tag={\"grantResponse\":.*"grantId": \"${grantId_1}"\.*\"responseCode\": 0.*
    [Teardown]    end_to_check

Check CB008923-A_8 no impact cell2
    prepare_to_check_message_from_start
    Check if message is not found in saslog    tag={\"relinquishmentResponse\":.*"grantId": \"${grantId_2}"\.*\"responseCode\": 0.*
    Check if message is not found in saslog    tag={\"grantResponse\":.*"grantId": \"${grantId_2}"\.*\"responseCode\": 0.*
    [Teardown]    end_to_check

CB008923-A_13_data_transfer_conducted_2CC_4D4U_SA
    start SAS server
    Wait until keyword succeeds    5min    30s    verify all cells should be onair
    Set qRxLevMin value    value=${-40}    cellid=1
    Set qRxLevMin value    value=${-22}    cellid=2
    data_transfer_common    tput_self_define=${tput_define_8923}    cell_id=${cell_id1}    loop_times=${1}    duration=${300}
    Set qRxLevMin value    value=${-22}    cellid=1
    Set qRxLevMin value    value=${-40}    cellid=2
    Sleep    60s
    data_transfer_common    tput_self_define=${tput_define_8923}    cell_id=${cell_id2}    loop_times=${1}    duration=${300}

CB008923-A_10_Cell_block_and_unblock
    start SAS server    config_name=${CB008923_A_10_conf}
    Wait until keyword succeeds    5min    30s    verify all cells should be onair
    ${grant_info_cell1_old}    Get Grant Parameters By Coam
    ${grant_info_cell2_old}    Get Grant Parameters By Coam    cellID=2
    Selenium Login And Disable Screen Lock
    Get X2 link shutdown waiting time
    ${block_list}    Create List    1
    Block cells and check status    block_list=${block_list}   check_alarm=${False}    gnb_type='${gNb_CuType}'
    ${grant_info_cell1_new}    Get Grant Parameters By Coam
    ${grant_info_cell2_new}    Get Grant Parameters By Coam    cellID=2
    Should be True    '${grant_info_cell1_old}[grantId]'=='${grant_info_cell1_new}[grantId]'
    Should be True    '${grant_info_cell2_old}[grantId]'=='${grant_info_cell2_new}[grantId]'
    UnBlock Cells and check status    block_list=${block_list}   check_alarm=${False}    gnb_type='${gNb_CuType}'
    ${grant_info_cell1_new}    Get Grant Parameters By Coam
    ${grant_info_cell2_new}    Get Grant Parameters By Coam    cellID=2
    Should be True    '${grant_info_cell1_old}[grantId]'=='${grant_info_cell1_new}[grantId]'
    Should be True    '${grant_info_cell2_old}[grantId]'=='${grant_info_cell2_new}[grantId]'
    Set qRxLevMin value    value=${-40}    cellid=1
    Set qRxLevMin value    value=${-22}    cellid=2
    data_transfer_common    tput_self_define=${tput_define_8923}    cell_id=${cell_id1}    loop_times=${1}    duration=${120}
    ...    target_avg_percent=0.5    min_percent=0.2
    Sleep    60s
    Block cells and check status    block_list=${block_list}   check_alarm=${False}    gnb_type='${gNb_CuType}'
    Sleep    180s
    ${grant_info_cell1_new}    Get Grant Parameters By Coam
    ${grant_info_cell2_new}    Get Grant Parameters By Coam    cellID=2
    Should be True    '${grant_info_cell1_old}[grantId]'=='${grant_info_cell1_new}[grantId]'
    Should be True    '${grant_info_cell2_old}[grantId]'=='${grant_info_cell2_new}[grantId]'
    Sleep    120s
    ${grant_info_cell1_new}    Get Grant Parameters By Coam
    ${grant_info_cell2_new}    Get Grant Parameters By Coam    cellID=2
    Sleep    60s
    Should be True    '${grant_info_cell2_old}[grantId]'=='${grant_info_cell2_new}[grantId]'
    Should be True    '${grant_info_cell1_new}[grantId]'=='None'
    UnBlock Cells and check status    block_list=${block_list}   check_alarm=${False}    gnb_type='${gNb_CuType}'
    ${grant_info_cell1_new}    Get Grant Parameters By Coam
    ${grant_info_cell2_new}    Get Grant Parameters By Coam    cellID=2
    Should be True    '${grant_info_cell1_new}[grantId]'!='None'
    Should be True    '${grant_info_cell2_old}[grantId]'=='${grant_info_cell2_new}[grantId]'
    data_transfer_common    tput_self_define=${tput_define_8923}    cell_id=${cell_id1}    loop_times=${1}    duration=${120}
    ...    target_avg_percent=0.5    min_percent=0.2
    Set qRxLevMin value    value=${-22}    cellid=1
    Set qRxLevMin value    value=${-40}    cellid=2
    Sleep    60s
    data_transfer_common    tput_self_define=${tput_define_8923}    cell_id=${cell_id2}    loop_times=${1}    duration=${120}
    ...    target_avg_percent=0.5    min_percent=0.2
    [Teardown]    Selenium Logout And Close Browser

CB008923-A_7_Online_modify_supportedSpectrumV2_when_two_CBSD_cells_with_different_priority
    start SAS server
    ${stamp_case_start}    Get Timestamp For Current Time
    Wait until keyword succeeds    5min    30s    verify all cells should be onair
    Selenium Login And Disable Screen Lock
    Modify fre_priority by WebEM without validate    cellID=1    freq_priority=2nd priority
    Modify fre_priority by WebEM without validate    cellID=2    freq_priority=3rd priority
    Modify SpectrumV2 by webEM without validate    fre_channel=${frequency_first_4}
    Modify querySASserver_period by WebEM without validate
    selenium_coam.validate_plan
    selenium_coam.activate_plan    activate_plan_despite_errors=${True}
    sleep    180
    Wait until keyword succeeds    5min    30s    Check cell status
    Wait until keyword succeeds    5min    30s    Check cell status	   cell_idx=${2}   cell_group_idx=${1}   cellflag=${False}
    log to console    \n+++ check cell-1 onair and granted with 20Mhz +++
    ${grant_cell1_info_coam}    Get Grant Parameters By Coam    cellID=1
    ${grantID_cell1_20MHz}    Set variable    ${grant_cell1_info_coam}[grantId]
    should be equal    '${grantID_cell1_20MHz}'    '3550000000_3570000000'
    Wait until keyword succeeds    5min    30s    Check cell de-active status	   cell_idx=${1}   cell_group_idx=${0}    cellflag=${True}
    log to console    \n+++ check cell-2 isn't onair with fault 6828 +++
    Wait until keyword succeeds    5min    30s    Check cell de-active status	   cell_idx=${2}   cell_group_idx=${1}    cellflag=${False}
    Wait Until Keyword Succeeds    2min    5s    Check Alarm in Alarm List    type=Active    faultId=6828    stamp_case_start=${stamp_case_start}
    ...    Supplementary=No available frequency.
#    Set Frequency Channel Value    frequency_channel=${frequency_first_8_3550_3590}
    Set Frequency Channel Value By Coam    frequency_channel=${frequency_first_8}
    sleep    180
    ${grant_cell1_info_coam}    Get Grant Parameters By Coam    cellID=1
    ${grantID_cell1_40MHz}    Set variable    ${grant_cell1_info_coam}[grantId]
    should be equal    ${grantID_cell1_40MHz}    ${grantID_cell1_20MHz}
    log to console    \n+++ check cell-2 onair and granted with 20Mhz +++
    Wait Until Keyword Succeeds    2min    5s    Check Alarm in Alarm List    faultId=6828
    ...    stamp_case_start=${stamp_case_start}    expect=${False}
    Wait until keyword succeeds    5min    30s    Check cell de-active status	cell_idx=${2}   cell_group_idx=${1}    cellflag=${True}
    ${grant_cell2_info_coam}    Get Grant Parameters By Coam    cellID=2
    should be equal    '${grant_cell2_info_coam}[grantId]'    '3570000000_3590000000'
    verify all cells should be onair
    [Teardown]    Run Keywords    Set Frequency Channel Value By Coam    frequency_channel=${frequency_all}    AND
    ...    Selenium Logout And Close Browser

CB008923-A_9_Verify_CBSD_cells_behavior_when_online_modify_cbrsFreqPriority
    [Arguments]    ${NRCBSDID}=1    ${ru_index}=1    ${groupId_need}=${True}    ${groupType_need}=${True}
    start SAS server    config_name=${CB008923_9_conf}
    Wait until keyword succeeds    5min    30s    verify all cells should be onair
    Selenium Login And Disable Screen Lock
    Modify frequency type by WebEM without validate    freq_type=PAL
    Modify querySASserver_period by WebEM without validate
    Modify fre_priority by WebEM without validate    cellID=1    freq_priority=3rd priority
    Modify fre_priority by WebEM without validate    cellID=2    freq_priority=2nd priority
    selenium_coam.validate_plan
    selenium_coam.activate_plan    activate_plan_despite_errors=${True}
    sleep    180
    Wait until keyword succeeds    5min    30s    verify all cells should be onair
    ${grant_cell1_info_coam}    Get Grant Parameters By Coam    cellID=1
    should be equal    '${grant_cell1_info_coam}[grantChannelType]'    'GAA'
    ${grant_cell2_info_coam}    Get Grant Parameters By Coam    cellID=2
    should be equal    '${grant_cell2_info_coam}[grantChannelType]'    'PAL'
    log to console     \n+++ start set cbrsFreqPriority=top priority for cell1 +++
    Set cbrsFreqPriority value    value=top priority
    sleep    100
    ${grant_cell1}    Get grant ID    cellID=1
    ${grant_cell2}    Get grant ID    cellID=2
    log    ${grant_cell1}
    log    ${grant_cell2}
    Get Correct Register Parameters Value By Coam    groupId_need=${groupId_need}    groupType_need=${groupType_need}
    ...    NRCBSDID=${NRCBSDID}    ru_index=${ru_index}
    ${cbsdId}    Get From Dictionary    dictionary=${cbsdIds}    key=${NRCBSDID}
    Set test variable    ${cbsdId}
    prepare_to_check_message_from_start
    Check if message is found in saslog    tag=${register_info}
    Wait until keyword succeeds    5min    30s    verify all cells should be onair
    check if message is found in saslog    tag={\"relinquishmentRequest":.*"grantId":"${grant_cell1}".*"grantId":"${grant_cell2}".*
    check if message is found in saslog
    ...    tag={\"relinquishmentResponse":.*"grantId": "${grant_cell1}".*"responseCode": 0.*"grantId": "${grant_cell2}".*"responseCode": 0.*
    ${grant_cell1_info_coam}    Get Grant Parameters By Coam    cellID=1
    should be equal    '${grant_cell1_info_coam}[grantChannelType]'    'PAL'
    ${grant_cell2_info_coam}    Get Grant Parameters By Coam    cellID=2
    should be equal    '${grant_cell2_info_coam}[grantChannelType]'    'GAA'
    Wait until keyword succeeds    5min    30s    verify all cells should be onair
    Set qRxLevMin value    value=${-40}    cellid=1
    Set qRxLevMin value    value=${-22}    cellid=2
    data_transfer_common    tput_self_define=${tput_define_8923_A_9}    cell_id=${cell_id1}    loop_times=${1}    duration=${300}

    Set qRxLevMin value    value=${-22}    cellid=1
    Set qRxLevMin value    value=${-40}    cellid=2
    Sleep    60s
    data_transfer_common    tput_self_define=${tput_define_8923_A_9}    cell_id=${cell_id2}    loop_times=${1}    duration=${300}

    [Teardown]    Selenium Logout And Close Browser

CB008923-A_14_Online_modify_channelSpace2020_when_continuous_CA_enable
    ${SCF_CA_14}    Replace String    ${Golden_SCF_Path}    SCF_    SCF_CA_14_
    COAM Commission with scf file    scf_file_path=${SCF_CA_14}    timeout=600    is_pdl_checking_needed=${if_pdl_check}
    start SAS server    config_name=${CB008923_14_conf}
    Wait until keyword succeeds    5min    30s    verify all cells should be onair
    Selenium Login And Disable Screen Lock
    ${grant_cell1}    Get grant ID
    ${grant_cell2}    Get grant ID    cellID=2
    log to console    \n+++ check the central frequency of two CBSDcell is 20MHz +++
    ${distance}    ${carrier_freq_cell1_origin}    ${carrier_freq_cell2_origin}    Get the central frequency of two CBSD cell diff
    ${diff}    Get the diff between two number    number1=${distance}    number2=${19.98}
    Should be True    ${diff}<0.0001
    log to console    \n+++ check the central frequency of two CBSDcell is 19.2MHz +++
    ${release}    Get program version based on gNB active version
    ${flitervalue}=   Run Keyword If   "${release}"=="master"
    ...     Set Variable       Channel spacing between two cells
    ...     ELSE    Set Variable     Channel space between contiguous 20MHz spectrums
    ${value}=   Run Keyword If   "${release}"=="master"
    ...     Set Variable       19200
    ...     ELSE    Set Variable     19.2MHz
    Set channelSpace2020 By webem    channelSpace2020=${value}    flitervalue_channelSpace2020=${flitervalue}
    sleep   100s
    ${carrier_freq_cell1_after}    Get cell carrier freq
    ${carrier_freq_cell2_after}    Get cell carrier freq    cell_idx=${2}
    log to console    \n+++ judge scell +++
    ${result_cell1}    check whether two item are same    item1=${carrier_freq_cell1_origin}    item2=${carrier_freq_cell1_after}
    ${result_cell2}    check whether two item are same    item1=${carrier_freq_cell2_origin}    item2=${carrier_freq_cell2_after}
    ${distance_1}    Get the diff between two number    number1=${carrier_freq_cell1_after}    number2=${carrier_freq_cell2_after}
    ${diff}    Get the diff between two number    number1=${distance_1}    number2=${19.2}
    Should Be True    ${diff}<0.0001
    log to console    \n+++ check grantID of impacted CBSD cell should be unchanged +++
    ${grant_cell1_updated}    Get grant ID
    ${grant_cell2_updated}    Get grant ID    cellID=2
    Run Keyword If    ${result_cell1}==${True}
    ...    Should Be True    '${grant_cell1}'=='${grant_cell1_updated}'    msg=The grant shall be kept unchanged for the impacted CBSD cell
    Run Keyword If    ${result_cell2}==${True}
    ...    Should Be True    '${grant_cell2}'=='${grant_cell2_updated}'    msg=The grant shall be kept unchanged for the impacted CBSD cell
    ${new_value}=   Run Keyword If   "${release}"=="master"
    ...     Set Variable       0
    ...     ELSE    Set Variable     20MHz
    Set channelSpace2020 By webem    channelSpace2020=${new_value}    flitervalue_channelSpace2020=${flitervalue}
    sleep    100s
    ${distance}    ${carrier_freq_cell1_origin}    ${carrier_freq_cell2_origin}    Get the central frequency of two CBSD cell diff
    ${diff}    Get the diff between two number    number1=${distance}    number2=${19.98}
    Should Be True    ${diff}<0.0001
    [Teardown]    Selenium Logout And Close Browser

CB008923-A_20_Online_modify_desiredPmax when CBSD cell blocked
    [Arguments]    ${groupId_need}=${True}    ${groupType_need}=${True}    ${cell_id}=1
    ...    ${NRCBSDCELLID}=0    ${NRCBSDID}=1    ${ru_index}=1
    COAM Commission with scf file    scf_file_path=${SCF_2CC}    timeout=600    is_pdl_checking_needed=${if_pdl_check}
    Sleep    300s
    Activate feature CBRS By Coam
    start SAS server
    ${stamp_case_start}    Get Timestamp For Current Time
    Selenium Login And Disable Screen Lock
    Wait until keyword succeeds    5min    30s    verify all cells should be onair
    ${grant_cell1}    Get grant ID    cellID=1
    Close Start Up View
    log to console    \n+++ start block cell1 +++
    selenium_coam.block_cell    cell_idx=${cell_id}
    ${cellgrp_id}   Get Cell Group From Cell   cell_id=${cell_id}
    Wait Until Keyword Succeeds   3 min  10 sec   Cell Should Be Blocked   cell_idx=${cell_id}   cell_group_idx=${cellgrp_id}
    Wait Until Keyword Succeeds    2min    5s    Check Alarm in Alarm List    type=Active    faultId=49    stamp_case_start=${stamp_case_start}
    log to console    \n+++ set desiredPmax to trigger relinquish for cell1 +++
    selenium_coam.set_parameter_value    dist_name=MRBTS-${mrbtsID}/NRBTS-${nrbtsID}/NRCELL-${cell_id}/NRCBSDCELL-${NRCBSDCELLID}
    ...    filter_param=Desired maximum output power    abbr=desiredPmax    new_value=20
    selenium_coam.validate_plan
    selenium_coam.activate_plan    activate_plan_despite_errors=${True}
    sleep    100
    Get Correct Register Parameters Value By Coam    groupId_need=${groupId_need}    groupType_need=${groupType_need}
    ...    NRCBSDID=${NRCBSDID}    ru_index=${ru_index}
    ${cbsdId}    Get From Dictionary    dictionary=${cbsdIds}    key=${NRCBSDID}
    Set test variable    ${cbsdId}
    prepare_to_check_message_from_start
    Check if message is found in saslog    tag=${register_info}
    Check if message is found in saslog    tag={\"relinquishmentRequest\":.*\"cbsdId\":\"${cbsdId}(.NR)?\".*\"grantId":"${grant_cell1}".*
    Check if message is found in saslog
    ...    tag={"relinquishmentResponse":.*"cbsdId": "${cbsdId}(.NR)?".*"grantId": "${grant_cell1}".*"responseCode": 0.*
    selenium_coam.unblock_cell    cell_idx=${cell_id}
    Wait Until Keyword Succeeds   5 min  10 sec   cell should be unblocked   cell_idx=${cell_id}    cell_group_idx=${cellgrp_id}
    Wait Until Keyword Succeeds    2min  5s  Check Alarm in Alarm List    expect=${False}    faultId=49    stamp_case_start=${stamp_case_start}
    prepare_to_check_message_from_start
    Check if message is found in saslog    tag={\"spectrumInquiryRequest\":.*\"cbsdId\":\"${cbsdId}(.NR)?\".*
    Check if message is found in saslog    tag={\"spectrumInquiryResponse\":.*"cbsdId": "${cbsdId}(.NR)?".*\"responseCode\": 0.*
    [Teardown]    Selenium Logout And Close Browser

CB008923_grant_successful_with_truncated
    ${SCF_CA_D}    Replace String    ${Golden_SCF_Path}    SCF_    SCF_CA_D_
    COAM Commission with scf file    scf_file_path=${SCF_CA_D}    timeout=600    is_pdl_checking_needed=${if_pdl_check}
    #    Modify querySASserver_period by WebEM without validate    period=5
    start SAS server    config_name=${CB008923_D_conf}
    Wait until keyword succeeds    5min    30s    verify all cells should be onair
    ${grant_info_coam_cell1}    Get Grant Parameters By Coam
    ${grantId_1}    Set variable    ${grant_info_coam_cell1}[grantId]
    log to console    check Grant is successful
    prepare to check message from start
    Check if message is found in saslog    tag={\"grantRequest\":.*
    Check if message is found in saslog    tag={\"grantResponse\":.*"grantId": \"${grantId_1}"\.*\"responseCode\": 0.*
    sleep    5min
    log to console     SI will trigger after querySasServerPeriod--5min expired
    ${req_SI}    Set variable    {\"spectrumInquiryRequest\":.*\"inquiredSpectrum\":.*\"lowFrequency\":3560000000.*\"highFrequency\":3600000000.*
    ${resp_SI}    Set variable    {\"spectrumInquiryResponse\":.*"availableChannel":.*\"lowFrequency\": 3560000000.*\"highFrequency\": 3600000000.*
    check if message is found in saslog    tag=${req_SI}
    check if message is found in saslog    tag=${resp_SI}
    Wait until keyword succeeds    5min    30s    verify all cells should be onair
    data_transfer_common    tput_self_define=${tput_define_8923}    cell_id=${cell_id1}    loop_times=${1}    duration=${300}

check whether two item are same
    [Arguments]    ${item1}=None    ${item2}=None
    ${status}     Run Keyword And Return Status    should be equal    ${item1}    ${item2}
    ${result}    Set Variable If    ${status}==${True}    True    False
    [Return]    ${result}

Modify frequency type by WebEM without validate
    [Arguments]    ${NRCBSDID}=1    ${freq_type}=PAL
    selenium_coam.set_parameter_value    dist_name=MRBTS-${mrbtsID}/NRBTS-${nrbtsID}/NRCBSD-${NRCBSDID}
    ...    filter_param=CBRS frequency type    abbr=cbrsFreqType    new_value=${freq_type}

Modify fre_priority by WebEM without validate
    [Arguments]    ${cellID}=1    ${NRCBSDCELLID}=0    ${freq_priority}=top priority
    selenium_coam.set_parameter_value  dist_name=MRBTS-${mrbtsID}/NRBTS-${nrbtsID}/NRCELL-${cellID}/NRCBSDCELL-${NRCBSDCELLID}
    ...    filter_param=CBRS cell priority for spectrum assignment    abbr=cbrsFreqPriority    new_value=${freq_priority}

Modify SpectrumV2 by webEM without validate
    [Arguments]     ${NRCBSDID}=1    ${fre_channel}=${none}
    selenium_coam.set_parameter_value  dist_name=MRBTS-${mrbtsID}/NRBTS-${nrbtsID}/NRCBSD-${NRCBSDID}    filter_param=Supported spectrum V2
    ...    abbr=supportedSpectrumV2    new_value=${fre_channel}

Modify querySASserver_period by WebEM without validate
    [Arguments]    ${NRCBRSPRID}=1    ${period}=3
    selenium_coam.set_parameter_value    dist_name=MRBTS-${mrbtsID}/NRBTS-${nrbtsID}/NRCBRSPR-${NRCBRSPRID}
    ...    filter_param=Query SAS server period    abbr=querySasServerPeriod    new_value=${period}

Modify channelspace2020 by WebEM without validate
    [Arguments]    ${NRCBRSPRID}=1    ${channel_space}=20MHz
    selenium_coam.set_parameter_value  dist_name=MRBTS-${mrbtsID}/NRBTS-${nrbtsID}/NRCBRSPR-${NRCBRSPRID}
    ...    filter_param=Channel space between contiguous 20MHz spectrums    abbr=channelSpace2020    new_value=${channel_space}

Modify desiredChBw by WebEM without validate
    [Arguments]    ${cell_id}=1    ${NRCBSDCELLID}=0    ${desiredChBw}=20MHz
        selenium_coam.set_parameter_value    dist_name=MRBTS-${mrbtsID}/NRBTS-${nrbtsID}/NRCELL-${cell_id}/NRCBSDCELL-${NRCBSDCELLID}
    ...    filter_param=Desired channel bandwidth   abbr=desiredChBw    new_value=${desiredChBw}

Get grant ID
    [Arguments]    ${cellID}=1
    ${grant_cell_info_coam}    Get Grant Parameters By Coam    cellID=${cellID}
    ${grant_cell}    Set Variable    ${grant_cell_info_coam}[grantId]
    [Return]    ${grant_cell}

Get the central frequency of two CBSD cell diff
    ${carrier_freq_cell1_origin}    Get cell carrier freq
    ${carrier_freq_cell2_origin}    Get cell carrier freq    cell_idx=${2}
    ${diff}    Get the diff between two number    number1=${carrier_freq_cell1_origin}    number2=${carrier_freq_cell2_origin}
    [Return]    ${diff}    ${carrier_freq_cell1_origin}    ${carrier_freq_cell2_origin}

Check cell de-active status
    [Arguments]  ${cell_idx}=${1}   ${cell_group_idx}=${0}   ${timeout}=10   ${cellflag}=${True}    ${connection}=GNB_OAM
    ${subcell_status}=  coam_siso_common.Get Cell Status      cell_idx=${cell_idx}
    ...                                      cell_group_idx=${cell_group_idx}
    ...                                      timeout=${timeout}
    ...                                      connection=${connection}
    Run Keyword If    '${cellflag}'=='True'    Should Be Equal As Strings   ${subcell_status["operationalState"]}   enabled
    ...    ELSE    Should Be Equal As Strings   ${subcell_status["operationalState"]}     disabled
    Should Be Equal As Strings   ${subcell_status["administrativeState"]}  Unlocked
    Run Keyword If    '${cellflag}'=='True'    Should Be Equal As Strings   ${subcell_status["availabilityStatus"]}  None
    ...    ELSE    Should Be Equal As Strings   ${subcell_status["availabilityStatus"]}    off line
