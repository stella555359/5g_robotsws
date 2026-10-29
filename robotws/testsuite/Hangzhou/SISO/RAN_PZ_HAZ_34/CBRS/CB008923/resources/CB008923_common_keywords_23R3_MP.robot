*** Settings ***
Documentation
...    Author:wangqingqing & gaoshengqing
...    contact:qingqing.wang@nokia-sbell.com & melinda.gao@nokia-sbell.com
...    squad group:SG_08
...    Feature CB008923

Resource    CB008923_common_keywords.robot

*** Variables ***
${disable_cbrs_TL1000}    ${CB008923_json_path}/disable_actcbrs_actnrcbrs_TL1000.json
${enable_cbrs_TL1000}    ${CB008923_json_path}/enable_actcbrs_actnrcbrs_TL1000.json
${disable_actcbrs_TL1000}    ${CB008923_json_path}/disable_actcbrs_TL1000.json
${enable_actcbrs_TL1000}    ${CB008923_json_path}/enable_actcbrs_TL1000.json

*** Keywords ***
Commission SCF According btsname
    [Arguments]    ${btsName}    ${config_id}
    ${SCF_upload}    Replace String    ${Golden_SCF_Path}    .xml    _AEQM${config_id}.xml
    Set Test Variable    ${SCF_upload}
    ${config_on_bts}    Fetch From Right    ${btsName}    AEQM
    Run Keyword If    '${config_on_bts}'!='${config_id}'   TL1000 Commission SCF   scf_file_path=${SCF_upload}

TL1000 Commission SCF
    [Arguments]    ${scf_file_path}
    Commissioning SCF And Check RU On Air   scf_file_path=${scf_file_path}
    sleep    30s

CB008923-B_33_verify_preemption_between_LTE_and_NR_cells_23R3_MP
    coam.perform_delta_recommissioning    delta_file=${enable_cbrs_TL1000}    connection=GNB_OAM
    Sleep    30s
    ${mrbtsID_enb}    ${lnbtsID}    Get mrbtsID and lnbtsID via SCF for eNB    scf_path=${SCF_upload}
    log to console  ENB_MRBTS_ID:${mrbtsID_enb}, LNBTS_ID:${lnbtsID}
    Set Frequency Channel Value By Coam    frequency_channel=${frequency_3570_3610}
    Sleep    30s
    Modify the parameter on NR    dist_name=MRBTS-${mrbtsID_enb}/LNBTS-${lnbtsID}/CBSD-1
    ...    parameter_name=supportedSpectrumV2    value=${frequency_3570_3610}
    Sleep    30s
    Set cbrsFreqPriority value    value=2nd priority
    Modify the parameter on NR    dist_name=MRBTS-${mrbtsID_enb}/LNBTS-${lnbtsID}/LNCEL-191/CBSDCEL-0
    ...    parameter_name=cbrsFreqPriority    value=3rd priority
    coam.perform_delta_recommissioning    delta_file=${disable_actcbrs_TL1000}    connection=GNB_OAM
    Sleep    60s
    ${stamp_case_start}    Get Timestamp For Current Time
    start SAS server
    Wait until keyword succeeds    10min    30s    verify all cells should be onair
    Sleep    120s
    Verify all lte cells should be disabled    connection=GNB_OAM
    coam.perform_delta_recommissioning    delta_file=${enable_actcbrs_TL1000}    connection=GNB_OAM
    Wait Until Keyword Succeeds    5min    5s    Check Alarm in Alarm List    type=Active    faultId=6827
    ...    stamp_case_start=${stamp_case_start}    Supplementary=No available frequency.    expect=${True}
    Verify all lte cells should be disabled    connection=GNB_OAM
    ${grant_info_nr_old}    Get Grant Parameters By Coam
    Should be True    '${grant_info_nr_old}[grantId]'=='3570000000_3610000000'
    Set Frequency Channel Value By Coam    frequency_channel=${frequency_3550_3610}
    Sleep    60s
    Wait until keyword succeeds    10min    30s    verify all cells should be onair
    ${grant_info_nr}    Get Grant Parameters By Coam
    Should be True   '${grant_info_nr}[grantId]'=='3550000000_3590000000' or '${grant_info_nr}[grantId]'=='3570000000_3610000000'
    Check relinquishment Success Message    grantId=${grant_info_nr_old}[grantId]
    Wait until keyword succeeds    5min    30s    Verify all lte cells should be onair    connection=GNB_OAM
    ${grantId_lte}    Get Parameter value via COAM    class_name=CBSDCEL_R    pattern=grantId    connection=GNB_OAM
    Run Keyword If    '${grant_info_nr}[grantId]'=='3550000000_3590000000'
    ...    Should be True    '${grantId_lte}'=='3590000000_3610000000'
    ...    ELSE    Should be True    '${grantId_lte}'=='3550000000_3570000000'
    [Teardown]    coam.perform_delta_recommissioning    delta_file=${disable_cbrs_TL1000}    connection=GNB_OAM

CB008923-B_3_Migration of a NR only site to a NR-LTE RF sharing site with AEQM_23R3_MP
    start SAS server
    Wait until keyword succeeds    8min    30s    verify all cells should be onair
    ${SCF_CB008923}    Replace String    ${Golden_SCF_Path}    .xml    _AEQM8923_concurrent.xml
    set suite variable  ${SCF_CB008923}
    COAM Commission with scf file    scf_file_path=${SCF_CB008923}    timeout=600    is_pdl_checking_needed=${if_pdl_check}
    Sleep    300s
    coam.perform_delta_recommissioning    delta_file=${enable_cbrs_TL1000}    connection=GNB_OAM
    Sleep    60s
    Wait until keyword succeeds    10min    30s    verify all cells should be onair
    Wait until keyword succeeds    5min    30s    Verify all lte cells should be onair    connection=GNB_OAM
    data_transfer_common    tput_self_define=${tput_define_23R3}    cell_id=${cell_id1}    loop_times=${1}    duration=${120}    
    ...    target_avg_percent=0.5    min_percent=0.2
    [Teardown]    coam.perform_delta_recommissioning    delta_file=${disable_cbrs_TL1000}    connection=GNB_OAM

CB008923-B_9_CBSD_behavior_check_when_NR_cell_block_unblock_23R3_MP
    coam.perform_delta_recommissioning    delta_file=${enable_cbrs_TL1000}    connection=GNB_OAM
    start SAS server
    Wait until keyword succeeds    8min    30s    verify all cells should be onair
    Wait until keyword succeeds    5min    30s    Verify all lte cells should be onair    connection=GNB_OAM
    ${grant_info_nr_old}    Get Grant Parameters By Coam
    ${grantId_lte_old}    Get Parameter value via COAM    class_name=CBSDCEL_R    pattern=grantId    connection=GNB_OAM
    data_transfer_common    tput_self_define=${tput_define_23R3}    cell_id=${cell_id1}    loop_times=${1}    duration=${120}    
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
    data_transfer_common    tput_self_define=${tput_define_23R3}    cell_id=${cell_id1}    loop_times=${1}    duration=${120}    
    ...    target_avg_percent=0.5    min_percent=0.2
    ${ltecbsdid}    Get Parameter value via COAM    class_name=CBSD_R   pattern=assignedCbsdId    connection=GNB_OAM
    Check No relinquishmentRequest procedure    cbsdid=${ltecbsdid}
    [Teardown]    Run Keywords    coam.perform_delta_recommissioning    delta_file=${disable_cbrs_TL1000}    connection=GNB_OAM    AND
    ...    Selenium Logout And Close Browser

CB008923-A_7_Online_modify_supportedSpectrumV2_when_two_CBSD_cells_with_different_priority_23R3_MP
    [Arguments]    ${NRCBSDCELLID}=0    ${NRCBSDID}=1
    start SAS server
    ${stamp_case_start}    Get Timestamp For Current Time
    Wait until keyword succeeds    5min    30s    verify all cells should be onair
    Selenium Login And Disable Screen Lock
    Modify fre_priority by WebEM without validate    cellID=1    freq_priority=2nd priority
    Modify fre_priority by WebEM without validate    cellID=2    freq_priority=3rd priority
    Modify SpectrumV2 by webEM without validate    fre_channel=${frequency_first_8_3550_3590}
    Modify querySASserver_period by WebEM without validate
    selenium_coam.validate_plan
    selenium_coam.activate_plan    activate_plan_despite_errors=${True}
    sleep    180
    Wait until keyword succeeds    5min    30s    Check cell status 
    Wait until keyword succeeds    5min    30s    Check cell status	   cell_idx=${2}   cell_group_idx=${1}   cellflag=${False}
    ${grant_cell1_info_coam}    Get Grant Parameters By Coam    cellID=1
    ${grantID_cell1}    Set variable    ${grant_cell1_info_coam}[grantId]
    should be equal    '${grantID_cell1}'    '3550000000_3590000000'
    Wait until keyword succeeds    5min    30s    Check cell de-active status	   cell_idx=${1}   cell_group_idx=${0}    cellflag=${True}
    Wait until keyword succeeds    5min    30s    Check cell de-active status	   cell_idx=${2}   cell_group_idx=${1}    cellflag=${False}
    Wait Until Keyword Succeeds    2min    5s    Check Alarm in Alarm List    type=Active    faultId=6828    stamp_case_start=${stamp_case_start}
    ...    Supplementary=No available frequency.
    Set Frequency Channel Value By Coam    frequency_channel=${frequency_first_16}
    sleep    180
    ${grant_cell1_info_coam}    Get Grant Parameters By Coam    cellID=1
    ${grantID_cell1_new}    Set variable    ${grant_cell1_info_coam}[grantId]
    should be equal    ${grantID_cell1_new}    ${grantID_cell1}
    Wait Until Keyword Succeeds    2min    5s    Check Alarm in Alarm List    faultId=6828
    ...    stamp_case_start=${stamp_case_start}    expect=${False}
    Wait until keyword succeeds    5min    30s    Check cell de-active status	cell_idx=${2}   cell_group_idx=${1}    cellflag=${True}
    ${grant_cell2_info_coam}    Get Grant Parameters By Coam    cellID=2
    should be equal    '${grant_cell2_info_coam}[grantId]'    '3590000000_3630000000'
    verify all cells should be onair
    [Teardown]    Run Keywords    Set Frequency Channel Value By Coam    frequency_channel=${frequency_all}    AND
    ...    Selenium Logout And Close Browser
