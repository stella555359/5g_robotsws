*** Settings ***
Documentation
...    author: Qingqing Wang
...    contact: qingqing.1.wang@nokia-sbell.com
...    squad group: SG_08
...    feature : CB009453

Resource    testsuite/Timisoara/Handover/CBRS/Hangzhou/resources/RAN_PZ_HAZ_34/robot/coam_gnb_classical.robot
Resource    testsuite/Timisoara/Handover/CBRS/Hangzhou/resources/RAN_PZ_HAZ_34/robot/coam_siso_common.robot
Resource    testsuite/Timisoara/Handover/CBRS/Hangzhou/resources/RAN_PZ_HAZ_34/lines/SG8/SG8_common_keywords.robot
Resource    ../../resources/cbrs_common_keywords.robot
Variables    ../TestData/CB009453_variables.py

*** Variables ***
@{cell_id1}    ${1}
@{cell_id2}    ${2}
@{cell_id3}    ${3}
${MAX_LOOP1}   1
${MAX_LOOP2}    20
${MAX_LOOP_block_unlock}    5
${MAX_LOOP_ru_lock_unlock}    5
${sas_log_path}    ${CURDIR}/../../resources/SASSim_HZ/SAS_Sim.log
${conf_path}    ${CURDIR}/conf
${json_path}    ${CURDIR}/json
${proxy_conf_path}    ${CURDIR}/../../resources/Proxy_Config
${CB009453_50_conf}    ${conf_path}/CB009453_50.conf
${CB009453_40_conf}    ${conf_path}/CB009453_40.conf
${CB009453_60_conf}    ${conf_path}/CB009453_60.conf
${CB009453_70_conf}    ${conf_path}/CB009453_70.conf
${CB009453_HB500_110M_conf}    ${conf_path}/CB009453_HB500_110M.conf
${CB009453_maxEIRP_limited_conf}    ${conf_path}/CB009453_maxEIRP_limited.conf
${CB009453_ET_17_conf}    ${conf_path}/CB009453_ET_17.conf
${CB009453_ET_18_conf}    ${conf_path}/CB009453_ET_18.conf
${CB0010459_35503570_36103630_36803700_conf}    ${conf_path}/CB0010459_35503570_36103630_36803700.conf
${CB0010459_24_conf}    ${conf_path}/CB0010459_24.conf
${CB0010459_29_conf}    ${conf_path}/CB0010459_29.conf
${CB0010459_10_conf}    ${conf_path}/CB0010459_10.conf
${cbrsFreqPriority6_7_8}    ${json_path}/cbrsFreqPriority6_7_8.json
${cbrsFreqPriority6_7_8_TL996}    ${json_path}/cbrsFreqPriority6_7_8_TL996.json
${attach_cell1}    ${json_path}/attach_cell1.json
${attach_cell2}    ${json_path}/attach_cell2.json
${attach_cell3}    ${json_path}/attach_cell3.json
#${upgrade_to_40_json}    ${json_path}/upgrade_to_40.json


*** Keywords ***
CB009453 CBRS Suite Setup
    CBRS Suite Setup
    ${SCF_CB009453}    Replace String    ${Golden_SCF_Path}    SCF_     SCF_CB009453_
    set suite variable  ${SCF_CB009453}
    ${SCF_CB009453_30M_20M}    Replace String    ${Golden_SCF_Path}    SCF_     SCF_CB009453_30M_20M_
    set suite variable  ${SCF_CB009453_30M_20M}
    ${SCF_CB009453_40M_40M}    Replace String    ${Golden_SCF_Path}    SCF_     SCF_CB009453_40M_40M_
    set suite variable  ${SCF_CB009453_40M_40M}
    ${SCF_CB009453_1CC_40M}    Replace String    ${Golden_SCF_Path}    SCF_     SCF_CB009453_1CC_40M_
    set suite variable  ${SCF_CB009453_1CC_40M}
    ${SCF_CB009453_2CC_4D_4U}    Replace String    ${Golden_SCF_Path}    SCF_     SCF_CB009453_2CC_4D_4U_
    set suite variable  ${SCF_CB009453_2CC_4D_4U}
    ${SCF_CB009453_8DL_8UL}    Replace String    ${Golden_SCF_Path}    SCF_     SCF_CB009453_8DL_8UL_
    set suite variable  ${SCF_CB009453_8DL_8UL}
    ${SCF_CB0010459_common}    Replace String    ${Golden_SCF_Path}    .xml    _AEQM10459_common.xml
    set suite variable  ${SCF_CB0010459_common}
#    Commissioning SCF And Check RU On Air   scf_file_path=${SCF_CB009453}
#   &{fault_7313}     Create Dictionary     faultId=${7313}
#   ${ALLOWED_FAULT}   Create List   @{ALLOWED_FAULT}   ${fault_7313}
    set suite variable  ${ALLOWED_FAULT}

CB0010459 CIT CBRS Suite Setup
    CBRS Suite Setup    feature_scf_flag=${True}
    ${SCF_CB0010459}    Replace String    ${Golden_SCF_Path}    SCF_   SCF_CB0010459_
    set suite variable  ${SCF_CB0010459}
    Commissioning SCF And Check RU On Air   scf_file_path=${SCF_CB0010459}

CB009453_1_Activation of NR CBRS with two CBSD cells on one AEQM_40MHz+40MHz
#	ET CB009453_01_NR_activate_two_cell_with_max_bw
    Commissioning SCF And Check RU On Air   scf_file_path=${SCF_CB009453}
    start SAS server		config_name=${CB009453_maxEIRP_limited_conf}
	Activate feature CBRS By Coam
    Sleep    120s
    ${grant_info_cell1}    Get Grant Parameters By Coam
	${grant_info_cell2}    Get Grant Parameters By Coam    cellID=2
	${chBw_cell1}    Get NRCELL Value By Coam    class_name=NRCELL_A    pattern=chBw
	${chBw_cell2}    Get NRCELL Value By Coam    class_name=NRCELL_A    pattern=chBw	cellID=2
    Should be True    '${chBw_cell1}'=='40MHz'
	Should be True    '${chBw_cell2}'=='40MHz'
    Wait until keyword succeeds    10min    30s    verify all cells should be onair
#    coam.perform_delta_recommissioning    delta_file=${cell2_change_to_20_json}    connection=GNB_OAM
    selenium login and disable screen lock
    selenium_coam.set_parameter_value    dist_name=MRBTS-${mrbtsID}/NRBTS-${nrbtsID}/NRCELL-2/NRCBSDCELL-0
    ...    filter_param=Desired channel bandwidth    abbr=desiredChBw     new_value=20MHz
    selenium_coam.set_parameter_value    dist_name=MRBTS-${mrbtsID}/NRBTS-${nrbtsID}/NRCELL-2/NRCBSDCELL-0
    ...    filter_param=Bandwidth Part Profile distinguished name 2     abbr=bwpDN2
    ...    new_value=MRBTS-${mrbtsID}/NRBTS-${nrbtsID}/BWP_PROFILE-20
    selenium_coam.set_parameter_value    dist_name=MRBTS-${mrbtsID}/NRBTS-${nrbtsID}/NRCELL-2/NRCBSDCELL-0
    ...    filter_param=Channel bandwidth     abbr=chBw    new_value=20MHz
    selenium_coam.validate_plan
    selenium_coam.activate_plan    activate_plan_despite_errors=${True}
    Sleep    240s
	Check relinquish	grantid=${grant_info_cell2}[grantId]
	${grant_info_cell2_new}    Get Grant Parameters By Coam  cellID=2
    Should be True    '${grant_info_cell2_new}[grantId]'=='3570000000_3590000000'
    Wait until keyword succeeds    10min    30s    verify all cells should be onair
#    coam.perform_delta_recommissioning    delta_file=${cell1_change_to_30_json}    connection=GNB_OAM
    selenium login and disable screen lock
    selenium_coam.set_parameter_value    dist_name=MRBTS-${mrbtsID}/NRBTS-${nrbtsID}/NRCELL-1/NRCBSDCELL-0
    ...    filter_param=Desired channel bandwidth    abbr=desiredChBw     new_value=30MHz
    selenium_coam.set_parameter_value    dist_name=MRBTS-${mrbtsID}/NRBTS-${nrbtsID}/NRCELL-1/NRCBSDCELL-0
    ...    filter_param=Bandwidth Part Profile distinguished name 2     abbr=bwpDN2
    ...    new_value=MRBTS-${mrbtsID}/NRBTS-${nrbtsID}/BWP_PROFILE-30
    selenium_coam.set_parameter_value    dist_name=MRBTS-${mrbtsID}/NRBTS-${nrbtsID}/NRCELL-1/NRCBSDCELL-0
    ...    filter_param=Channel bandwidth     abbr=chBw    new_value=30MHz
    selenium_coam.validate_plan
    selenium_coam.activate_plan    activate_plan_despite_errors=${True}
    Sleep    240s
	Check relinquish	grantid=${grant_info_cell1}[grantId]
    Check no relinquish   grantid=${grant_info_cell2_new}[grantId]
	${grant_info_cell1_new}    Get Grant Parameters By Coam
    Should be True    '${grant_info_cell1_new}[grantId]'=='3600000000_3630000000'
    Wait until keyword succeeds    10min    30s    verify all cells should be onair
	Set qRxLevMin value    value=${-22}    cellid=2
	data_transfer_common    tput_self_define=${tput_define_30}    cell_id=${cell_id1}   loop_times=${1}    duration=${120}
    ...    target_avg_percent=0.95    min_percent=0.85

CB009453_2_Activation of NR CBRS with two CBSD cells on one AEQM_30MHz+20MHz
	Commissioning SCF And Check RU On Air   scf_file_path=${SCF_CB009453_30M_20M}
	Activate feature CBRS By Coam
    Sleep    30s
    FOR    ${TEST_LOOP}    IN RANGE    0    ${MAX_LOOP1}
        ${date}=    Get Current Date        result_format=%Y-%m-%d_%H:%M:%S
        Log To Console    \n Iteration ${TEST_LOOP} in progress at: ${date}
		Run Keyword And Ignore Error    kill process for SAS server
		Sleep    10s
		start SAS server		config_name=${CB009453_maxEIRP_limited_conf}
		Sleep    120s
		${grant_info_cell1}    Get Grant Parameters By Coam
		${grant_info_cell2}    Get Grant Parameters By Coam    cellID=2
		Should be True    '${grant_info_cell1}[grantId]'=='3600000000_3630000000'
		Should be True    '${grant_info_cell2}[grantId]'=='3570000000_3590000000'
		Wait until keyword succeeds    10min    30s    verify all cells should be onair
#		coam.perform_delta_recommissioning    delta_file=${cell1_change_to_40_json}    connection=GNB_OAM
		selenium login and disable screen lock
		selenium_coam.set_parameter_value    dist_name=MRBTS-${mrbtsID}/NRBTS-${nrbtsID}/NRCELL-1/NRCBSDCELL-0
		...    filter_param=Desired channel bandwidth    abbr=desiredChBw     new_value=40MHz
		selenium_coam.set_parameter_value    dist_name=MRBTS-${mrbtsID}/NRBTS-${nrbtsID}/NRCELL-1/NRCBSDCELL-0
		...    filter_param=Bandwidth Part Profile distinguished name 2     abbr=bwpDN2
		...    new_value=MRBTS-${mrbtsID}/NRBTS-${nrbtsID}/BWP_PROFILE-40
		selenium_coam.set_parameter_value    dist_name=MRBTS-${mrbtsID}/NRBTS-${nrbtsID}/NRCELL-1/NRCBSDCELL-0
		...    filter_param=Channel bandwidth     abbr=chBw    new_value=40MHz
		selenium_coam.validate_plan
		selenium_coam.activate_plan    activate_plan_despite_errors=${True}
		Sleep    180s
		Check relinquish	grantid=${grant_info_cell1}[grantId]
		Check no relinquish   grantid=${grant_info_cell2}[grantId]
		${grant_info_cell1_new}    Get Grant Parameters By Coam
		Should be True    '${grant_info_cell1_new}[grantId]'=='3590000000_3630000000'
		Wait until keyword succeeds    10min    30s    verify all cells should be onair
#		coam.perform_delta_recommissioning    delta_file=${cell2_change_to_40_json}    connection=GNB_OAM
		selenium login and disable screen lock
		selenium_coam.set_parameter_value    dist_name=MRBTS-${mrbtsID}/NRBTS-${nrbtsID}/NRCELL-2/NRCBSDCELL-0
		...    filter_param=Desired channel bandwidth    abbr=desiredChBw     new_value=40MHz
		selenium_coam.set_parameter_value    dist_name=MRBTS-${mrbtsID}/NRBTS-${nrbtsID}/NRCELL-2/NRCBSDCELL-0
		...    filter_param=Bandwidth Part Profile distinguished name 2     abbr=bwpDN2
		...    new_value=MRBTS-${mrbtsID}/NRBTS-${nrbtsID}/BWP_PROFILE-40
		selenium_coam.set_parameter_value    dist_name=MRBTS-${mrbtsID}/NRBTS-${nrbtsID}/NRCELL-2/NRCBSDCELL-0
		...    filter_param=Channel bandwidth     abbr=chBw    new_value=40MHz
		selenium_coam.validate_plan
		selenium_coam.activate_plan    activate_plan_despite_errors=${True}
		Sleep    180s
		Check relinquish	grantid=${grant_info_cell2}[grantId]
		Check no relinquish   grantid=${grant_info_cell1_new}[grantId]
		${grant_info_cell2_new}    Get Grant Parameters By Coam		cellID=2
		Should be True    '${grant_info_cell2_new}[grantId]'=='3550000000_3590000000'
		Wait until keyword succeeds    10min    30s    verify all cells should be onair
#		coam.perform_delta_recommissioning    delta_file=${cells_recovery_to_30_20_json}    connection=GNB_OAM
		selenium login and disable screen lock
		selenium_coam.set_parameter_value    dist_name=MRBTS-${mrbtsID}/NRBTS-${nrbtsID}/NRCELL-1/NRCBSDCELL-0
		...    filter_param=Desired channel bandwidth    abbr=desiredChBw     new_value=30MHz
		selenium_coam.set_parameter_value    dist_name=MRBTS-${mrbtsID}/NRBTS-${nrbtsID}/NRCELL-1/NRCBSDCELL-0
		...    filter_param=Bandwidth Part Profile distinguished name 2     abbr=bwpDN2
		...    new_value=MRBTS-${mrbtsID}/NRBTS-${nrbtsID}/BWP_PROFILE-30
		selenium_coam.set_parameter_value    dist_name=MRBTS-${mrbtsID}/NRBTS-${nrbtsID}/NRCELL-1/NRCBSDCELL-0
		...    filter_param=Channel bandwidth     abbr=chBw    new_value=30MHz
		selenium_coam.set_parameter_value    dist_name=MRBTS-${mrbtsID}/NRBTS-${nrbtsID}/NRCELL-2/NRCBSDCELL-0
		...    filter_param=Desired channel bandwidth    abbr=desiredChBw     new_value=20MHz
		selenium_coam.set_parameter_value    dist_name=MRBTS-${mrbtsID}/NRBTS-${nrbtsID}/NRCELL-2/NRCBSDCELL-0
		...    filter_param=Bandwidth Part Profile distinguished name 2     abbr=bwpDN2
		...    new_value=MRBTS-${mrbtsID}/NRBTS-${nrbtsID}/BWP_PROFILE-20
		selenium_coam.set_parameter_value    dist_name=MRBTS-${mrbtsID}/NRBTS-${nrbtsID}/NRCELL-2/NRCBSDCELL-0
		...    filter_param=Channel bandwidth     abbr=chBw    new_value=20MHz
		selenium_coam.validate_plan
		selenium_coam.activate_plan    activate_plan_despite_errors=${True}
		Sleep    180s
		Wait until keyword succeeds    10min    30s    verify all cells should be onair
    END

CB009453_3_Online_add_one_higher_priority_CBRS_cell_when_only_40MHz_channel_block_available
    Commissioning SCF And Check RU On Air   scf_file_path=${SCF_CB009453_1CC_40M}
    Set cbrsFreqPriority value    value=4th priority
    Sleep    30s
    Activate feature CBRS By Coam
    Sleep    30s
    start SAS server	config_name=${CB009453_40_conf}
	Sleep    180s
    Wait until keyword succeeds    10min    30s    Check cell status
    FOR    ${TEST_LOOP}    IN RANGE    0    ${MAX_LOOP1}
		${grant_info_cell1}    Get Grant Parameters By Coam
		CB009453_common_keywords.Online Cell addition    file_path=${SCF_CB009453_40M_40M}
		Sleep    300s
		Wait until keyword succeeds    10min    30s    Check cell status    cellflag=${False}
		Wait until keyword succeeds    10min    30s    Check cell status	   cell_idx=${2}   cell_group_idx=${1}
		Wait Until Keyword Succeeds    2min    5s    Check Alarm in Alarm List    type=Active    faultId=6828
		${grant_info_cell2}    Get Grant Parameters By Coam		cellID=2
		CB009453_common_keywords.Online Cell deletion    deletion_cell=2    deletion_cellgrp=1
		Sleep    300s
		Wait until keyword succeeds    10min    30s    Check cell status
    END
	data_transfer_common    tput_self_define=${tput_define_40}    cell_id=${cell_id1}   loop_times=${1}    duration=${120}
	...    target_avg_percent=0.5    min_percent=0.2

CB009453_12_expand_V2_upgrade_combination_from 20MHz+20MHz_to_40MHz+40MHz
    Commissioning SCF And Check RU On Air   scf_file_path=${SCF_CB009453_40M_40M}
	start SAS server
	Set Frequency Channel Value By Coam    frequency_channel=${frequency_non_contigous_40MHz}
    Sleep    60s
	Activate feature CBRS By Coam
    Sleep    120s
    Wait until keyword succeeds    10min    30s    verify all cells should be onair
    ${grant_info_cell1}    Get Grant Parameters By Coam
	${grant_info_cell2}    Get Grant Parameters By Coam  cellID=2
#    Should be True    '${grant_info_cell2}[grantId]'=='3550000000_3570000000'
#    Should be True    '${grant_info_cell1}[grantId]'=='3580000000_3600000000'
	${chBw_cell1}    Get NRCELL Value By Coam    class_name=NRCELL_A    pattern=chBw
	${chBw_cell2}    Get NRCELL Value By Coam    class_name=NRCELL_A    pattern=chBw	cellID=2
    Should be True    '${chBw_cell1}'=='20MHz'
	Should be True    '${chBw_cell2}'=='20MHz'
	Set Frequency Channel Value By Coam    frequency_channel=${frequency_all}
    Sleep    60s
	${grant_info_cell1_new}    Get Grant Parameters By Coam
	${grant_info_cell2_new}    Get Grant Parameters By Coam  cellID=2
#    Should be True    '${grant_info_cell2_new}[grantId]'=='3550000000_3590000000'
#    Should be True    '${grant_info_cell1_new}[grantId]'=='3590000000_3630000000'
    Sleep   120s
	${chBw_cell1_new}    Get NRCELL Value By Coam    class_name=NRCELL_A    pattern=chBw
	${chBw_cell2_new}    Get NRCELL Value By Coam    class_name=NRCELL_A    pattern=chBw	cellID=2
    Should be True    '${chBw_cell1_new}'=='40MHz'
	Should be True    '${chBw_cell2_new}'=='40MHz'
    Wait until keyword succeeds    10min    30s    verify all cells should be onair

CB009453_19_Frequency Selection Algorithm_desiredChBw_40+40_channelblock_70MHz_available
    Commissioning SCF And Check RU On Air   scf_file_path=${SCF_CB009453_40M_40M}
	start SAS server   config_name=${CB009453_70_conf}
    Activate feature CBRS By Coam
	Sleep    10s
	${grant_info_cell1}    Get Grant Parameters By Coam
    ${grant_info_cell2}    Get Grant Parameters By Coam   	cellID=2
    Should be True    '${grant_info_cell2}[grantId]'=='3550000000_3590000000'
    Wait until keyword succeeds    10min    30s    verify all cells should be onair
# 	ET CB009453_08_NR_delete_cell_impact_existent_cell_bw#######
	cbrs_common_keywords.Online Cell deletion    deletion_cell=2   deletion_cellgrp=1
	Sleep    180s
    Check relinquish   grantid=${grant_info_cell2}[grantId]
    Check relinquish   grantid=${grant_info_cell1}[grantId]
    ${grant_info_cell1_new}    Get Grant Parameters By Coam
    Should be True    '${grant_info_cell1_new}[grantId]'=='3550000000_3590000000'
	Wait until keyword succeeds    10min    30s    Check cell status

CB009453_20_MaxEIRP_check_celltype_from_4DL4UL_to_8DL4UL
    Commissioning SCF And Check RU On Air   scf_file_path=${SCF_CB009453_40M_40M}
    Activate feature CBRS By Coam
    Sleep    30s
    start SAS server
    Wait until keyword succeeds    10min    30s    verify all cells should be onair
    ${grant_info_cell1}    Get Grant Parameters By Coam
	${grant_info_cell2}    Get Grant Parameters By Coam		cellID=2
	Should be True    '${grant_info_cell1}[maxEirp]'=='24.1'
	Should be True    '${grant_info_cell2}[maxEirp]'=='24.1'
    Online delete object
    Sleep    420s
    ${grant_info_cell1_new}    Get Grant Parameters By Coam
    ${grant_info_cell2_new}    Get Grant Parameters By Coam	   cellID=2
	Check relinquish	grantid=${grant_info_cell1}[grantId]
    Check relinquish	grantid=${grant_info_cell2}[grantId]
	Should be True    '${grant_info_cell1_new}[maxEirp]'=='27.1'
	Should be True    '${grant_info_cell2_new}[maxEirp]'=='27.1'
    Wait until keyword succeeds    10min    30s    verify all cells should be onair
    selenium login and disable screen lock
    Online add object    ${SCF_CB009453_40M_40M}
    Online add object    ${SCF_CB009453_40M_40M}    cellID=2
	Online Modify Celltype 	    cellID=1	 celltype=8DL4UL
    Online modify celltype      cellID=2     celltype=8DL4UL
	selenium_coam.validate_plan
    selenium_coam.activate_plan		activate_plan_despite_errors=${True}    timeout=180
	selenium logout and close browser
	Sleep    420s
    Wait until keyword succeeds    10min    30s    verify all cells should be onair
	Commissioning SCF And Check RU On Air   scf_file_path=${SCF_CB009453_8DL_8UL}
    Activate feature CBRS By Coam
    Sleep    30s
    Wait until keyword succeeds    10min    30s    verify all cells should be onair
	Set qRxLevMin value    value=${-22}    cellid=2
	data_transfer_common    tput_self_define=${tput_define_40}    cell_id=${cell_id1}   loop_times=${1}    duration=${120}
	...    target_avg_percent=0.2    min_percent=0.2
    Commissioning SCF And Check RU On Air   scf_file_path=${SCF_CB009453_40M_40M}

CB009453_6_Verify_CBSD_cells_behavior_when_online_modify_cbrsFreqPriority
# ET case17
	Commissioning SCF And Check RU On Air   scf_file_path=${SCF_CB009453_40M_40M}
	Set querySasServerPeriod By Coam     value=${3}
	start SAS server   config_name=${CB009453_ET_17_conf}
    Activate feature CBRS By Coam
    Wait until keyword succeeds    10min    30s    verify all cells should be onair
	${grant_info_cell1}    Get Grant Parameters By Coam
	${grant_info_cell2}    Get Grant Parameters By Coam    cellID=2
	Should be True    '${grant_info_cell1}[grantId]'=='3590000000_3610000000'
    Should be True    '${grant_info_cell2}[grantId]'=='3550000000_3590000000'
	Sleep    200s
	${grant_info_cell1_new}    Get Grant Parameters By Coam
	Check relinquish  	 grantid=${grant_info_cell1}[grantId]
    Check no relinquish   grantid=${grant_info_cell2}[grantId]
    Should be True    '${grant_info_cell1_new}[grantId]'=='3610000000_3650000000'
    Wait until keyword succeeds    10min    30s    verify all cells should be onair
    Set cbrsFreqPriority value    value=top priority
	Sleep    50s
	${grant_info_cell1}    Get Grant Parameters By Coam
	${grant_info_cell2}    Get Grant Parameters By Coam    cellID=2
	Should be True    '${grant_info_cell1}[grantId]'=='3550000000_3590000000'
    Should be True    '${grant_info_cell2}[grantId]'=='3590000000_3630000000'
    Wait until keyword succeeds    10min    30s    verify all cells should be onair

CB009453_14_CBSD_behavior_check_when_gNB_reset
# ET case16
	Commissioning SCF And Check RU On Air   scf_file_path=${SCF_CB009453_40M_40M}
	start SAS server   config_name=${CB009453_HB500_110M_conf}
    Activate feature CBRS By Coam
    Sleep    20s
    ${grant_info_cell1}    Get Grant Parameters By Coam
	${grant_info_cell2}    Get Grant Parameters By Coam    cellID=2
	Should be True    '${grant_info_cell1}[grantId]'=='3590000000_3630000000'
    Should be True    '${grant_info_cell2}[grantId]'=='3550000000_3570000000'
    Wait until keyword succeeds    10min    30s    verify all cells should be onair
	Sleep    60s
	${grant_info_cell2_new_1}    Get Grant Parameters By Coam    cellID=2
	Check termination  	 grantid_new=${grant_info_cell2_new_1}[grantId]		grantid_old=${grant_info_cell2}[grantId]
    Check no relinquish   grantid=${grant_info_cell1}[grantId]
    Should be True    '${grant_info_cell2_new_1}[grantId]'=='3630000000_3650000000'
    Wait until keyword succeeds    10min    30s    verify all cells should be onair
	Sleep    300s
	${grant_info_cell1_new}    Get Grant Parameters By Coam
	${grant_info_cell2_new_2}    Get Grant Parameters By Coam    cellID=2
	Should be True    '${grant_info_cell1_new}[grantId]'=='3650000000_3690000000'
    Should be True    '${grant_info_cell2_new_2}[grantId]'=='3590000000_3630000000'
    Wait until keyword succeeds    10min    30s    verify all cells should be onair
    Perform BTS Site Reset
    Sleep    30s
    COAM Wait gnb And Cells ready    timeout=110min    gnb_type='${gNb_CuType}'

CB009453_15_CBSD_behavior_check_when_RU_reset
# ET case18
	Commissioning SCF And Check RU On Air   scf_file_path=${SCF_CB009453_40M_40M}
	start SAS server   config_name=${CB009453_ET_18_conf}
    Activate feature CBRS By Coam
    Wait until keyword succeeds    10min    30s    verify all cells should be onair
	${grant_info_cell1}    Get Grant Parameters By Coam
	${grant_info_cell2}    Get Grant Parameters By Coam    cellID=2
	${status}  run keyword and return status      Should be True    '${grant_info_cell1}[grantId]'=='3590000000_3630000000'
    Run Keyword If    ${status}==False
    ...    Should be True    '${grant_info_cell2}[grantId]'=='3590000000_3630000000'
	Sleep    120s
	${grant_info_cell1_new}    Get Grant Parameters By Coam
	${grant_info_cell2_new}    Get Grant Parameters By Coam     cellID=2
    Run Keyword If    ${status}==False
    ...    Should be True    '${grant_info_cell2_new}[grantId]'=='3630000000_3650000000'
    Run Keyword If    ${status}==True
    ...    Should be True    '${grant_info_cell1_new}[grantId]'=='3630000000_3650000000'
    Wait until keyword succeeds    10min    30s    verify all cells should be onair
    CB009453_common_keywords.Perform RU Reset
	Sleep    240s
	Wait until keyword succeeds    10min    30s    verify all cells should be onair

CB009453_KPI_Auto_BTS_site_reset
	start SAS server
    Activate feature CBRS By Coam
    Sleep    30s
    FOR    ${TEST_LOOP}    IN RANGE    0    ${MAX_LOOP2}
        ${date}=    Get Current Date        result_format=%Y-%m-%d_%H:%M:%S
        Log To Console    \n GNB Reset Iteration ${TEST_LOOP} in progress at: ${date}
        Perform BTS Site Reset
        Sleep    30s
        COAM Wait gnb And Cells ready    timeout=110min    gnb_type='${gNb_CuType}'
    END

CB009453_KPI_RU_reset_from_GUI
	start SAS server
    Activate feature CBRS By Coam
    Sleep    30s
	FOR    ${TEST_LOOP}    IN RANGE    0    ${MAX_LOOP2}
        ${date}=    Get Current Date        result_format=%Y-%m-%d_%H:%M:%S
        Log To Console    \n GNB Reset Iteration ${TEST_LOOP} in progress at: ${date}
        CB009453_common_keywords.Perform RU Reset
		Sleep    420s
		Wait until keyword succeeds    10min    30s    verify all cells should be onair
    END

Perform RU Reset
    [Arguments] 	${connection}=GNB_OAM
    ${ru_index_list}  Get All RU Index    connection=${connection}
    selenium login and disable screen lock
    FOR  ${ru_index}  IN  @{ru_index_list}
        log to console    \n***RF Module index ${ru_index} Reset from GUI***
        ${ru_index}  Convert To Integer    ${ru_index}
        selenium_coam.reset_ru  ru_index=${ru_index}
        Wait Until Keyword Succeeds    10min    5s    RU Should Be Offline    ru_index=${ru_index}    connection=${connection}
    END
    Selenium Logout And Close Browser

Online delete object
    selenium login and disable screen lock
	log to console  delete object
    selenium_coam.remove_object    object_name=MRBTS-${mrbtsID}/MNL-1/MNLENT-1/CELLMAPPING-1/LCELNR-1/CHANNELGROUP-2  timeout=15
	selenium_coam.remove_object    object_name=MRBTS-${mrbtsID}/MNL-1/MNLENT-1/CELLMAPPING-1/LCELNR-2/CHANNELGROUP-2  timeout=15
    Online modify celltype
    Online modify celltype      cellID=2
	selenium_coam.validate_plan
    selenium_coam.activate_plan		activate_plan_despite_errors=${True}    timeout=180
	[Teardown]    Selenium Logout And Close Browser

Online Modify Celltype
   [Documentation]
   [Arguments]     ${cellID}=1      ${celltype}=4DL4UL
    log to console  modify celltype
	selenium_coam.set_parameter_value    dist_name=MRBTS-${mrbtsID}/NRBTS-${nrbtsID}/NRCELL-${cellID}
	...    filter_param=NR Cell type    abbr=nrCellType     new_value=${celltype}

Online add object
    [Documentation]
    [Arguments]    ${file_path}     ${cellID}=1		 ${addition_CHANNELGROUP}=2   ${connection}=GNB_OAM
    ${new_conf_name}    SG8_common.get_file_name    file_path=${file_path}
    ${new_conf}    Replace String    ${new_conf_name}    SCF_    CONF-1_SCF_
    ${release}    Get program version based on gNB active version
    ${new_conf_1}=   Run Keyword If   "${release}"=="SBTS24R3"
    ...     Set Variable     CONF-1
    ...     ELSE    Set Variable       ${new_conf}
    ${activate_plan_despite_errors}    set variable if    ${if_pdl_check}    ${False}    ${True}
    Connect to gnb coam via ssl    connection=${connection}
    selenium_coam.load_commissioning_file_and_check_load_status    file_path=${file_path}
    get_planned_parameter_value    dist_name=MRBTS-${mrbtsID}  filter_param=BTS name  abbr=btsName
    ...    bts_configuration=Current
    log to console  add cell1 CHANNELGROUP-2
    selenium_coam.add_object    object_name=MRBTS-${mrbtsID}/MNL-1/MNLENT-1/CELLMAPPING-1/LCELNR-${cellID}
    ...    object_class_name=CHANNELGROUP    plan_to_copy_from=${new_conf_1}
    ...    copy_from=MRBTS-${mrbtsID}/MNL-1/MNLENT-1/CELLMAPPING-1/LCELNR-${cellID}/CHANNELGROUP-2
    ...    include_subobject=${True}   id_value=${addition_CHANNELGROUP}    timeout=15

Check termination
    [Arguments]    ${grantid_new}		${grantid_old}
	prepare_to_check_message_from_start
    Check if message is found in saslog    tag={\"heartbeatResponse\":.*"grantId": \"${grantid_old}"\.*\"responseCode\": 500.*
    Check if message is found in saslog    tag={\"heartbeatRequest\":.*\"grantId\":\"${grantid_new}".*}
    Check if message is found in saslog    tag={\"heartbeatResponse\":.*\"grantId": \"${grantid_new}"\.*\"responseCode\": 0.*

Check relinquish
    [Arguments]    ${grantid}
	prepare_to_check_message_from_start
    Check if message is found in saslog    tag={\"heartbeatResponse\":.*"grantId": \"${grantid}"\.*\"responseCode\": 0.*
    Check if message is found in saslog    tag={\"relinquishmentRequest\":.*\"grantId\":\"${grantId}".*}
    Check if message is found in saslog    tag={\"relinquishmentResponse\":.*\"grantId": \"${grantid}"\.*\"responseCode\": 0.*
    [Teardown]    end_to_check

Check no relinquish
    [Arguments]    ${grantid}
    prepare_to_check_message_from_start
    Check if message is not found in saslog    tag={\"relinquishmentRequest\":.*\"grantId":\"${grantid}"\.*
    [Teardown]    end_to_check

Set querySasServerPeriod By Coam
    [Arguments]    ${value}    ${NRCBRSPR}=1    ${connection}=GNB_OAM
    coam.perform_parameter_recommissioning        dist_name=MRBTS-${mrbtsID}/NRBTS-${nrbtsID}/NRCBRSPR-${NRCBRSPR}
    ...                                            parameter=querySasServerPeriod
    ...                                            value=${value}
    ...                                            operation=update
    ...                                            skip_parameter_relation_errors=${True}
    ...                                            connection=${connection}

Online Cell deletion
    [Arguments]  ${deletion_cell}=1  ${deletion_cellgrp}=0
    ${activate_plan_despite_errors}    set variable if    ${if_pdl_check}    ${False}    ${True}
#    Connect to gnb coam via ssl    connection=${connection}
    ${cell_grp}  Get All Cell Group Id
    selenium login and disable screen lock
    log to console  delete object
    selenium_coam.remove_object    object_name=MRBTS-${mrbtsID}/MNL-1/MNLENT-1/CELLMAPPING-1/LCELNR-${deletion_cell}    timeout=15
    selenium_coam.remove_object    object_name=MRBTS-${mrbtsID}/NRBTS-${nrbtsID}/NRCELL-${deletion_cell}    timeout=15
    selenium_coam.remove_object    object_name=MRBTS-${mrbtsID}/NRBTS-${nrbtsID}/NRCELLGRP-${deletion_cellgrp}    timeout=15
    ${cell_grp_len}    get length    ${cell_grp}
    FOR    ${index}    IN RANGE    ${cell_grp_len}
        ${value}    selenium_coam.get_parameter_value     dist_name=MRBTS-${mrbtsID}/NRBTS-${nrbtsID}/NRDU-1
        ...    abbr=refNrCellGroup    filter_param=Reference to cell group
        ...    node_index=${index}
        run keyword if    '${value}'=='${deletion_cellgrp}'    selenium_coam.remove_element
        ...    dist_name=MRBTS-${mrbtsID}/NRBTS-${nrbtsID}/NRDU-1
        ...    abbr=refNrCellGroup    filter_param=Reference to cell group
        ...    node_index=${index}
    END
    selenium_coam.validate_plan
    selenium_coam.activate_plan    activate_plan_despite_errors=${activate_plan_despite_errors}
#    COAM Check GNB cell on air
    [Teardown]    Selenium Logout And Close Browser

TL30 Commission SCF According btsname
    [Arguments]    ${btsName}    ${config_id}
    ${cell_grp}  Get All Cell Group Id
    ${len}    get length    ${cell_grp}
    ${SCF_upload}    Replace String    ${Golden_SCF_Path}    .xml    _AEQM${config_id}.xml
    Set Test Variable    ${SCF_upload}
    ${config_on_bts}    Fetch From Right    ${btsName}    AEQM
    Run Keyword If    '${config_on_bts}'!='${config_id}' or ${len}!=3   Commission SCF and enable actnrcbrs   scf_file_path=${SCF_upload}

Online Cell addition
    [Documentation]  Online last Cell addition deletion via webem
    [Arguments]    ${file_path}    ${addition_cell}=2  ${addition_cellgrp}=1
    ${new_conf_name}    SG8_common.get_file_name    file_path=${file_path}
    ${new_conf}    Replace String    ${new_conf_name}    SCF_    CONF-1_SCF_
    ${release}    Get program version based on gNB active version
    ${new_conf_1}=   Run Keyword If   "${release}"=="SBTS24R3"
    ...     Set Variable     CONF-1
    ...     ELSE    Set Variable       ${new_conf}
    ${activate_plan_despite_errors}    set variable if    ${if_pdl_check}    ${False}    ${True}
#    Connect to gnb coam via ssl    connection=${connection}
    ${cell_grp}  Get All Cell Group Id
    selenium login and disable screen lock
    selenium_coam.load_commissioning_file_and_check_load_status    file_path=${file_path}
    get_planned_parameter_value    dist_name=MRBTS-${mrbtsID}  filter_param=BTS name  abbr=btsName
    ...    bts_configuration=Current
    log to console  add object
    selenium_coam.add_object    object_name=MRBTS-${mrbtsID}/MNL-1/MNLENT-1/CELLMAPPING-1
    ...    object_class_name=LCELNR    plan_to_copy_from=${new_conf_1}
    ...    copy_from=MRBTS-${mrbtsID}/MNL-1/MNLENT-1/CELLMAPPING-1/LCELNR-${addition_cell}
    ...    include_subobject=${True}   id_value=${addition_cell}    timeout=15
    Sleep    30s
    selenium_coam.add_object    object_name=MRBTS-${mrbtsID}/NRBTS-${nrbtsID}
    ...    object_class_name=NRCELL    plan_to_copy_from=${new_conf_1}
    ...    copy_from=MRBTS-${mrbtsID}/NRBTS-${nrbtsID}/NRCELL-${addition_cell}
    ...    include_subobject=${True}   id_value=${addition_cell}    timeout=15
    Sleep    30s
    selenium_coam.add_object    object_name=MRBTS-${mrbtsID}/NRBTS-${nrbtsID}
    ...    object_class_name=NRCELLGRP    plan_to_copy_from=${new_conf_1}
    ...    copy_from=MRBTS-${mrbtsID}/NRBTS-${nrbtsID}/NRCELLGRP-${addition_cellgrp}
    ...    id_value=${addition_cellgrp}    timeout=15
    selenium_coam.set_parameter_value    dist_name=MRBTS-${mrbtsID}/NRBTS-${nrbtsID}/NRCELL-${addition_cell}
    ...    filter_param=Local cell resource ID    abbr=lcrId    new_value=${2}
    selenium_coam.add_element    dist_name=MRBTS-${mrbtsID}/NRBTS-${nrbtsID}/NRDU-1
    ...    abbr=refNrCellGroup    filter_param=Reference to cell group
    ...    timeout=15
    Sleep    30s
    selenium_coam.set_parameter_value    dist_name=MRBTS-${mrbtsID}/NRBTS-${nrbtsID}/NRDU-1
    ...    filter_param=Reference to cell group     new_value=${1}
    ...    node_index=${1}
    selenium_coam.validate_plan
    selenium_coam.activate_plan    activate_plan_despite_errors=${activate_plan_despite_errors}
	[Teardown]    Selenium Logout And Close Browser

CB010459_4_Online_Reconfigure_2*20MHz_8D4U_to_3*20MHz_4D4U
	Commissioning SCF And Check RU On Air   scf_file_path=${SCF_CB009453_1CC_40M}
	start SAS server
	Activate feature CBRS By Coam
    Wait until keyword succeeds    10min    30s    verify all cells should be onair
	log to console  start modify celltype
    selenium login and disable screen lock
    selenium_coam.remove_object    object_name=MRBTS-${mrbtsID}/MNL-1/MNLENT-1/CELLMAPPING-1/LCELNR-1/CHANNELGROUP-2  timeout=15
#	selenium_coam.remove_object    object_name=MRBTS-${mrbtsID}/MNL-1/MNLENT-1/CELLMAPPING-1/LCELNR-2/CHANNELGROUP-2  timeout=15
    Online modify celltype
	log to console  start add new cell
	Online add Cell		file_path=${SCF_CB009453_2CC_4D_4U}
	selenium_coam.validate_plan
    selenium_coam.activate_plan		activate_plan_despite_errors=${True}
	[Teardown]    Selenium Logout And Close Browser
    Sleep    240s
    Wait until keyword succeeds    10min    30s    verify all cells should be onair

Online add Cell
    [Arguments]    ${file_path}    ${addition_cell}=2  ${addition_cellgrp}=1    ${connection}=GNB_OAM
    ${new_conf_name}    SG8_common.get_file_name    file_path=${file_path}
    ${new_conf}    Replace String    ${new_conf_name}    SCF_    CONF-1_SCF_
    ${release}    Get program version based on gNB active version
    ${new_conf_1}=   Run Keyword If   "${release}"=="SBTS24R3"
    ...     Set Variable     CONF-1
    ...     ELSE    Set Variable       ${new_conf}
    Wait Until Keyword Succeeds    5min    30s    Connect to gnb coam via ssl    connection=${connection}
    ${cell_grp}  Get All Cell Group Id
    ${cell_grp_len}    get length    ${cell_grp}
    ${cell_grp_len}=   Evaluate    ${cell_grp_len}+1
    selenium_coam.load_commissioning_file_and_check_load_status    file_path=${file_path}    timeout=${300}
    get_planned_parameter_value    dist_name=MRBTS-${mrbtsID}  filter_param=BTS name  abbr=btsName
    ...    bts_configuration=Current
    log to console  add object
    selenium_coam.add_object    object_name=MRBTS-${mrbtsID}/MNL-1/MNLENT-1/CELLMAPPING-1
    ...    object_class_name=LCELNR    plan_to_copy_from=${new_conf_1}
    ...    copy_from=MRBTS-${mrbtsID}/MNL-1/MNLENT-1/CELLMAPPING-1/LCELNR-${addition_cell}
    ...    include_subobject=${True}   id_value=${addition_cell}    timeout=15
    Sleep    5s
    selenium_coam.add_object    object_name=MRBTS-${mrbtsID}/NRBTS-${nrbtsID}
    ...    object_class_name=NRCELL    plan_to_copy_from=${new_conf_1}
    ...    copy_from=MRBTS-${mrbtsID}/NRBTS-${nrbtsID}/NRCELL-${addition_cell}
    ...    include_subobject=${True}   id_value=${addition_cell}    timeout=15
    Sleep    5s
    selenium_coam.add_object    object_name=MRBTS-${mrbtsID}/NRBTS-${nrbtsID}
    ...    object_class_name=NRCELLGRP    plan_to_copy_from=${new_conf_1}
    ...    copy_from=MRBTS-${mrbtsID}/NRBTS-${nrbtsID}/NRCELLGRP-${addition_cellgrp}
    ...    id_value=${addition_cellgrp}    timeout=15
    Sleep    5s
    ${lcrId}   Convert To Integer   ${addition_cell}
    selenium_coam.set_parameter_value    dist_name=MRBTS-${mrbtsID}/NRBTS-${nrbtsID}/NRCELL-${addition_cell}
    ...    filter_param=Local cell resource ID    abbr=lcrId    new_value=${lcrId}
    # recover NRDU-1 as prev
    selenium_coam.add_element    dist_name=MRBTS-${mrbtsID}/NRBTS-${nrbtsID}/NRDU-1
    ...    abbr=refNrCellGroup    filter_param=Reference to cell group
    ...    timeout=15
    FOR  ${i}  IN RANGE    0    ${cell_grp_len}
        selenium_coam.set_parameter_value    dist_name=MRBTS-${mrbtsID}/NRBTS-${nrbtsID}/NRDU-1
        ...    filter_param=Reference to cell group     new_value=${i}
        ...    node_index=${i}
    END

Recovery ENV Case 11
    Connect to gnb coam via ssl
    Perform RU unlock via rest api
    wait until keyword succeeds    5min    30s    RU Should Be Unlocked
    Wait until keyword succeeds    10min    30s    verify all cells should be onair
    csn.reset_cache
    Sleep    30s

CB010459_11_General_SiSo_RU_lock_unlock
	start SAS server
    Wait until keyword succeeds    10min    10s    verify all cells should be onair
    FOR  ${i}  IN RANGE    0    ${MAX_LOOP_ru_lock_unlock}
        Connect to gnb coam via ssl
        Perform RU lock via rest api    timeout=${120}
        wait until keyword succeeds    5min    30s    RU Should Be Locked
        Sleep    30s
        Perform RU unlock via rest api     timeout=${120}
        wait until keyword succeeds    5min    30s    RU Should Be Unlocked
        Wait until keyword succeeds    10min    30s    verify all cells should be onair
        csn.reset_cache
        Sleep    30s
    END
    coam.perform_delta_recommissioning    delta_file=${attach_cell1}    connection=GNB_OAM
    Sleep    10s
    data_transfer_common    tput_self_define=${tput_define}    cell_id=${cell_id1}   loop_times=${1}    duration=${300}
    ...    target_avg_percent=0.95    min_percent=0.85
    coam.perform_delta_recommissioning    delta_file=${attach_cell2}    connection=GNB_OAM
    Sleep    10s
    data_transfer_common    tput_self_define=${tput_define}    cell_id=${cell_id2}   loop_times=${1}    duration=${300}
    ...    target_avg_percent=0.95    min_percent=0.85
    coam.perform_delta_recommissioning    delta_file=${attach_cell3}    connection=GNB_OAM
    Sleep    10s
    data_transfer_common    tput_self_define=${tput_define}    cell_id=${cell_id3}   loop_times=${1}    duration=${300}
    ...    target_avg_percent=0.95    min_percent=0.85
    [Teardown]    Run Keyword And Ignore Error    Recovery ENV Case 11

CB010459_29_Online_add_one_new_cell_to_satify_HW_BandWidth_limitation
    start SAS server    config_name=${CB0010459_29_conf}
    ${stamp_case_start}    Get Timestamp For Current Time
    Wait until keyword succeeds    10min    30s    check cell status by cellid    cellid=999    status=enabled    cell_type=nr
    ${grant_info_cell1}    Get Grant Parameters By Coam
    Should be True    '${grant_info_cell1}[grantId]'=='3550000000_3570000000'
    Wait Until Keyword Succeeds    8min    5s    Check Alarm in Alarm List    type=Active    faultId=6828
    ...    stamp_case_start=${stamp_case_start}    Supplementary=No available frequency.    expect=${True}
    Sleep    30s
    selenium login and disable screen lock
    Online add Cell    file_path=${SCF_CB0010459_common}    addition_cell=3    addition_cellgrp=2
    selenium_coam.set_parameter_value    dist_name=MRBTS-${mrbtsID}/NRBTS-${nrbtsID}/NRCELL-3/NRCBSDCELL-0
    ...    filter_param=CBRS cell priority for spectrum assignment    abbr=cbrsFreqPriority    new_value=8th priority
    selenium_coam.set_parameter_value    dist_name=MRBTS-${mrbtsID}/NRBTS-${nrbtsID}/NRCELL-3/NRCBSDCELL-0
    ...    filter_param=Maximum allowed grant power reduction    abbr=maxGrantPwrRed    new_value=10
    selenium_coam.validate_plan
    Wait Until Keyword Succeeds    5x     20s    selenium_coam.activate_plan    activate_plan_despite_errors=${True}    timeout=${600}
    Wait until keyword succeeds    10min    10s    verify all cells should be onair
    ${grant_info_cell3}    Get Grant Parameters By Coam    cellID=3
    Should be True    '${grant_info_cell3}[grantId]'=='3610000000_3630000000'
    ${grant_info_cell2}    Get Grant Parameters By Coam    cellID=2
    Should be True    '${grant_info_cell2}[grantId]'=='3680000000_3700000000'
    [Teardown]    Selenium Logout And Close Browser

CB010459_13_data_transfer_3x20MHz_C1_C3_above_110MHz
    AlarmWatchdog.add_allow_alarms    fault_id=49
    start SAS server
    Wait until keyword succeeds    10min    30s    verify all cells should be onair
    FOR    ${i}    IN RANGE    0    ${MAX_LOOP_block_unlock}
        Selenium Login And Disable Screen Lock
        Get X2 link shutdown waiting time
        ${block_list}    Create List    1    2    3
        Block cells and check status    block_list=${block_list}   check_alarm=${False}    gnb_type='${gNb_CuType}'
        Sleep    30s
        UnBlock Cells and check status    block_list=${block_list}   check_alarm=${False}    gnb_type='${gNb_CuType}'
        Selenium Logout And Close Browser
        Sleep    30s
    END
#    coam.perform_delta_recommissioning    delta_file=${attach_cell1}    connection=GNB_OAM
#    Sleep    10s
#    data_transfer_common    tput_self_define=${tput_define}    cell_id=${cell_id1}   loop_times=${1}    duration=${300}
#     ...    target_avg_percent=0.98    min_percent=0.85
    coam.perform_delta_recommissioning    delta_file=${attach_cell2}    connection=GNB_OAM
    Sleep    10s
    data_transfer_common    tput_self_define=${tput_define}    cell_id=${cell_id2}   loop_times=${1}    duration=${300}
    ...    target_avg_percent=0.98    min_percent=0.85
    coam.perform_delta_recommissioning    delta_file=${attach_cell3}    connection=GNB_OAM
    Sleep    10s
    data_transfer_common    tput_self_define=${tput_define}    cell_id=${cell_id3}   loop_times=${1}    duration=${300}
    ...    target_avg_percent=0.98    min_percent=0.85
    [Teardown]    Run keywords    Run Keyword And Ignore Error    UnBlock Cells and check status   block_list=${block_list}
    ...    check_alarm=${False}  gnb_type='${gNb_CuType}'    AND   Selenium Logout And Close Browser
    AlarmWatchdog.remove_allow_alarms    fault_id=49

Check Case CB010459_24 CBRS Process
    [Arguments]    ${grantId}
    prepare_to_check_message_from_start
    Check if message is found in saslog    tag={\"heartbeatRequest\":.*
    Check if message is found in saslog    tag={\"heartbeatResponse\":.*\"responseCode\": 500.*
    Check if message is found in saslog    tag={\"relinquishmentRequest\":.*\"grantId\":\"${grantId}\"}]}
    Check if message is found in saslog    tag={\"relinquishmentResponse\":.*\"grantId\": \"${grantId}\".*\"responseCode\": 0.*
    [Teardown]    end_to_check

CB010459_24_Verify_HW_BandWidth_Limitation_when_C2_got_terminated
    coam.perform_delta_recommissioning    delta_file=${cbrsFreqPriority6_7_8_TL996}    connection=GNB_OAM
    start SAS server    config_name=${CB0010459_24_conf}
    ${stamp_case_start}    Get Timestamp For Current Time
    Wait until keyword succeeds    10min    10s    verify all cells should be onair
    ${grant_info_cell2_old}    Get Grant Parameters By Coam    cellID=2
    ${grant_info_cell3_old}    Get Grant Parameters By Coam    cellID=3
    Sleep    240s
    Wait until keyword succeeds    10min    10s    verify all cells should be onair
    Check Case CB010459_24 CBRS Process    grantId=${grant_info_cell3_old}[grantId]
    Check no relinquish   grantid=${grant_info_cell2_old}[grantId]

Check Case CB010459_26 CBRS Process
    [Arguments]    ${grantId}    ${grantId_2}
    prepare_to_check_message_from_start
    Check if message is found in saslog    tag={\"relinquishmentRequest\":.*\"grantId\":\"${grantId}\"}]}
    Check if message is found in saslog    tag={\"relinquishmentResponse\":.*\"grantId\": \"${grantId}\".*\"responseCode\": 0.*
    Check if message is found in saslog    tag={\"relinquishmentRequest\":.*\"grantId\":\"${grantId_2}\"}]}
    Check if message is found in saslog    tag={\"relinquishmentResponse\":.*\"grantId\": \"${grantId_2}\".*\"responseCode\": 0.*
    Check if message is found in saslog    tag={\"grantRequest\":.*
    Check if message is found in saslog    tag={\"grantResponse\":.*"grantId": "${grantId}".*\"responseCode\": 0.*
    [Teardown]    end_to_check

Check Case CB010459_10 CBRS Process
    [Arguments]    ${grantId}
    prepare_to_check_message_from_start
    Check if message is found in saslog    tag={\"relinquishmentRequest\":.*\"grantId\":\"${grantId}\"}]}
    Check if message is found in saslog    tag={\"relinquishmentResponse\":.*\"grantId\": \"${grantId}\".*\"responseCode\": 0.*
    Check if message is found in saslog    tag={\"relinquishmentRequest\":.*\"grantId\":\"${grantId}\"}]}
    Check if message is found in saslog    tag={\"relinquishmentResponse\":.*\"grantId\": \"${grantId}\".*\"responseCode\": 0.*
    Check if message is found in saslog    tag={\"grantRequest\":.*
    Check if message is found in saslog    tag={\"grantResponse\":.*"grantId": "${grantId}".*\"responseCode\": 0.*
    [Teardown]    end_to_check

CB010459_10_Online_add_higher_priority_cell_when_only_20MHz_PAL_available
    start SAS server    config_name=${CB0010459_10_conf}
    Wait until keyword succeeds    10min    30s    verify all cells should be onair
    ${grant_info_cell1}    Get Grant Parameters By Coam
    Should be True    '${grant_info_cell1}[grantId]'=='3550000000_3570000000'
    ${stamp_case_start}    Get Timestamp For Current Time
    cbrs_common_keywords.Online Cell addition    file_path=${SCF_CB0010459_common}    addition_cell=2    addition_cellgrp=1
    Wait until keyword succeeds    10min    30s    check cell status by cellid    cellid=998    status=enabled    cell_type=nr
    Wait Until Keyword Succeeds    5min    5s    Check Alarm in Alarm List    type=Active    faultId=6828
    ...    stamp_case_start=${stamp_case_start}    Supplementary=No available frequency.    expect=${True}
    check cell status by cellid    cellid=999    status=disabled    cell_type=nr
    ${grant_info_cell2}    Get Grant Parameters By Coam    cellID=2
    Should be True    '${grant_info_cell2}[grantId]'=='3550000000_3570000000'
    Sleep    60s
    cbrs_common_keywords.Online Cell addition    file_path=${SCF_CB0010459_common}    addition_cell=3    addition_cellgrp=2
    Wait until keyword succeeds    10min    30s    check cell status by cellid    cellid=997    status=enabled    cell_type=nr
    Wait Until Keyword Succeeds    5min    5s    Check Alarm in Alarm List    type=Active    faultId=6828
    ...    stamp_case_start=${stamp_case_start}    Supplementary=No available frequency.    expect=${True}
    check cell status by cellid    cellid=999    status=disabled    cell_type=nr
    check cell status by cellid    cellid=998    status=disabled    cell_type=nr
    Sleep    60s
    Wait Until Keyword Succeeds    5min    30s    Check Case CB010459_10 CBRS Process    grantId=${grant_info_cell1}[grantId]
    ${grant_info_cell3}    Get Grant Parameters By Coam    cellID=3
    Should be True    '${grant_info_cell3}[grantId]'=='3550000000_3570000000'

CB010459_26_Verify_HW_BandWidth_Limitation_when_C2_deleted
    coam.perform_delta_recommissioning    delta_file=${cbrsFreqPriority6_7_8_TL996}    connection=GNB_OAM
    start SAS server    config_name=${CB0010459_35503570_36103630_36803700_conf}
    Wait until keyword succeeds    10min    30s    verify all cells should be onair
    ${grant_info_cell1}    Get Grant Parameters By Coam
    ${grant_info_cell2}    Get Grant Parameters By Coam    cellID=2
    ${grant_info_cell3}    Get Grant Parameters By Coam    cellID=3
    cbrs_common_keywords.Online Cell deletion    deletion_cell=2    deletion_cellgrp=1
    Sleep    180s
    Wait until keyword succeeds    5min    30s    verify all cells should be onair
    ${grant_info_cell1_new}    Get Grant Parameters By Coam
    ${grant_info_cell3_new}    Get Grant Parameters By Coam    cellID=3
    Should be True    '${grant_info_cell1_new}[grantId]'=='${grant_info_cell1}[grantId]'
    Should be True    '${grant_info_cell3_new}[grantId]'=='${grant_info_cell2}[grantId]'
    Check Case CB010459_26 CBRS Process    grantId=${grant_info_cell2}[grantId]    grantId_2=${grant_info_cell3}[grantId]

Check Case CB010459_27 CBRS Process
    [Arguments]    ${grantId}    ${grantId_2}
    prepare_to_check_message_from_start
    Check if message is found in saslog    tag={\"relinquishmentRequest\":.*\"grantId\":\"${grantId}\"}]}
    Check if message is found in saslog    tag={\"relinquishmentResponse\":.*\"grantId\": \"${grantId}\".*\"responseCode\": 0.*
    Check if message is found in saslog    tag={\"relinquishmentRequest\":.*\"grantId\":\"${grantId_2}\"}]}
    Check if message is found in saslog    tag={\"relinquishmentResponse\":.*\"grantId\": \"${grantId_2}\".*\"responseCode\": 0.*
    Check if message is found in saslog    tag={\"grantRequest\":.*
    Check if message is found in saslog    tag={\"grantResponse\":.*"grantId": "${grantId_2}".*\"responseCode\": 0.*
    Check if message is found in saslog    tag={\"grantRequest\":.*
    Check if message is found in saslog    tag={\"grantResponse\":.*"grantId": "${grantId}".*\"responseCode\": 0.*
    [Teardown]    end_to_check

CB010459_27_Verify_HW_BandWidth_Limitation_when_C2_blocked_till_grant_relinquished
    AlarmWatchdog.add_allow_alarms    fault_id=49
    coam.perform_delta_recommissioning    delta_file=${cbrsFreqPriority6_7_8}    connection=GNB_OAM
    start SAS server    config_name=${CB0010459_35503570_36103630_36803700_conf}
    Wait until keyword succeeds    10min    30s    verify all cells should be onair
    ${grant_info_cell1}    Get Grant Parameters By Coam
    ${grant_info_cell2}    Get Grant Parameters By Coam    cellID=2
    ${grant_info_cell3}    Get Grant Parameters By Coam    cellID=3
    Selenium Login And Disable Screen Lock
    Get X2 link shutdown waiting time
    ${block_list}    Create List    2
    Block cells and check status    block_list=${block_list}   check_alarm=${False}    gnb_type='${gNb_CuType}'
    Sleep    60s
    ${grant_info_cell1_new}    Get Grant Parameters By Coam
    ${grant_info_cell2_new}    Get Grant Parameters By Coam    cellID=2
    ${grant_info_cell3_new}    Get Grant Parameters By Coam    cellID=3
    Should be True    '${grant_info_cell1_new}[grantId]'=='${grant_info_cell1}[grantId]'
    Should be True    '${grant_info_cell2_new}[grantId]'=='${grant_info_cell2}[grantId]'
    Should be True    '${grant_info_cell3_new}[grantId]'=='None'
#    Sleep    60s
#    ${grant_info_cell1_new}    Get Grant Parameters By Coam
#    ${grant_info_cell2_new}    Get Grant Parameters By Coam    cellID=2
#    ${grant_info_cell3_new}    Get Grant Parameters By Coam    cellID=3
#    Should be True    '${grant_info_cell1_new}[grantId]'=='${grant_info_cell1}[grantId]'
#    Should be True    '${grant_info_cell2_new}[grantId]'=='${grant_info_cell2}[grantId]'
#    Should be True    '${grant_info_cell3_new}[grantId]'=='None'
    Sleep    240s
    ${grant_info_cell1_new}    Get Grant Parameters By Coam
    ${grant_info_cell2_new}    Get Grant Parameters By Coam    cellID=2
    ${grant_info_cell3_new}    Get Grant Parameters By Coam    cellID=3
    Should be True    '${grant_info_cell1_new}[grantId]'=='${grant_info_cell1}[grantId]'
    Should be True    '${grant_info_cell2_new}[grantId]'=='None'
    Should be True    '${grant_info_cell3_new}[grantId]'=='${grant_info_cell2}[grantId]'
    UnBlock Cells and check status    block_list=${block_list}   check_alarm=${False}    gnb_type='${gNb_CuType}'
    ${grant_info_cell1_new}    Get Grant Parameters By Coam
    ${grant_info_cell2_new}    Get Grant Parameters By Coam    cellID=2
    ${grant_info_cell3_new}    Get Grant Parameters By Coam    cellID=3
    Should be True    '${grant_info_cell1_new}[grantId]'=='${grant_info_cell1}[grantId]'
    Should be True    '${grant_info_cell2_new}[grantId]'=='${grant_info_cell3}[grantId]'
    Should be True    '${grant_info_cell3_new}[grantId]'=='${grant_info_cell2}[grantId]'
    Check Case CB010459_27 CBRS Process    grantId=${grant_info_cell3}[grantId]    grantId_2=${grant_info_cell2}[grantId]
    [Teardown]    Run keywords    Run Keyword And Ignore Error    UnBlock Cells and check status   block_list=${block_list}
    ...    check_alarm=${False}  gnb_type='${gNb_CuType}'    AND   Selenium Logout And Close Browser
    AlarmWatchdog.remove_allow_alarms    fault_id=49

CB010459_30_Verify_HW_BandWidth_Limitation_consider_deactive_cell_which_has_grant
    AlarmWatchdog.add_allow_alarms    fault_id=49
    coam.perform_delta_recommissioning    delta_file=${cbrsFreqPriority6_7_8}    connection=GNB_OAM
    start SAS server    config_name=${CB0010459_35503570_36103630_36803700_conf}
    Wait until keyword succeeds    10min    30s    verify all cells should be onair
    ${grant_info_cell2}    Get Grant Parameters By Coam    cellID=2
    ${grant_info_cell3}    Get Grant Parameters By Coam    cellID=3
    Selenium Login And Disable Screen Lock
    Get X2 link shutdown waiting time
    ${block_list}    Create List    2
#    ${block_list}    Create List    2    3
    Block cells and check status    block_list=${block_list}   check_alarm=${False}    gnb_type='${gNb_CuType}'
    Sleep    30s
    ${old_desiredPmax}    Get desiredPmax By Coam    cellID=2
    Set desiredPmax By WEBEM    value=12    cellID=2
    Sleep    120s
    ${grant_info_cell2_new}    Get Grant Parameters By Coam    cellID=2
    Should be True    '${grant_info_cell2_new}[grantId]'=='None'
    Check relinquish    grantid=${grant_info_cell2}[grantId]
#    selenium_coam.unblock_cell    cell_idx=3
#    Wait until keyword succeeds    5min    5s    check cell status by cellid    cellid=997    status=enabled    cell_type=nr
    Sleep    300s
    Wait until keyword succeeds    5min    5s    check cell status by cellid    cellid=997    status=enabled    cell_type=nr
    ${grant_info_cell3_new}    Get Grant Parameters By Coam    cellID=3
    Should be True    '${grant_info_cell3_new}[grantId]'=='${grant_info_cell2}[grantId]'
    Set desiredPmax By WEBEM    value=${old_desiredPmax}    cellID=2
    Sleep    120s
    selenium_coam.unblock_cell    cell_idx=2
    Wait until keyword succeeds    10min    30s    verify all cells should be onair
    ${grant_info_cell2_new}    Get Grant Parameters By Coam    cellID=2
    Should be True    '${grant_info_cell2_new}[grantId]'=='${grant_info_cell3}[grantId]'
    Check relinquish    grantid=${grant_info_cell3}[grantId]
    [Teardown]    Run keywords    Run Keyword And Ignore Error    UnBlock Cells and check status   block_list=${block_list}
    ...    check_alarm=${False}  gnb_type='${gNb_CuType}'    AND    Selenium Logout And Close Browser
    AlarmWatchdog.remove_allow_alarms    fault_id=49

online Reconfigure 3_20MHz_4D4U to 2_20MHz_8D4U
    [Arguments]    ${file_path}    ${deletion_cell}=3    ${deletion_cellgrp}=2
    ${new_conf_name}    SG8_common.get_file_name    file_path=${file_path}
    ${new_conf_1}    Replace String    ${new_conf_name}    SCF_    CONF-1_SCF_
    ${cell_grp}  Get All Cell Group Id
    ${cell_grp_len}    get length    ${cell_grp}
    selenium login and disable screen lock
    selenium_coam.load_commissioning_file_and_check_load_status    file_path=${file_path}
    get_planned_parameter_value    dist_name=MRBTS-${mrbtsID}  filter_param=BTS name  abbr=btsName
    ...    bts_configuration=Current
   FOR  ${cellID}  IN RANGE    1    3
#        selenium_coam.add_object    object_name=MRBTS-${mrbtsID}/MNL-1/MNLENT-1/CELLMAPPING-1/LCELNR-${cellID}
#        ...    object_class_name=CHANNELGROUP    plan_to_copy_from=${new_conf_1}
#        ...    copy_from=MRBTS-${mrbtsID}/MNL-1/MNLENT-1/CELLMAPPING-1/LCELNR-${cellID}/CHANNELGROUP-2
#        ...    include_subobject=${True}   id_value=${addition_CHANNELGROUP}    timeout=15
        log to console  modify celltype
        selenium_coam.set_parameter_value    dist_name=MRBTS-${mrbtsID}/NRBTS-${nrbtsID}/NRCELL-${cellID}
        ...    filter_param=NR Cell type    abbr=nrCellType     new_value=8DL4UL
    END
    log to console  delete cell3
    selenium_coam.remove_object    object_name=MRBTS-${mrbtsID}/MNL-1/MNLENT-1/CELLMAPPING-1/LCELNR-${deletion_cell}    timeout=15
    selenium_coam.remove_object    object_name=MRBTS-${mrbtsID}/NRBTS-${nrbtsID}/NRCELL-${deletion_cell}   timeout=15
    selenium_coam.remove_object    object_name=MRBTS-${mrbtsID}/NRBTS-${nrbtsID}/NRCELLGRP-${deletion_cellgrp}    timeout=15
    FOR    ${index}    IN RANGE    ${cell_grp_len}
        ${value}    selenium_coam.get_parameter_value     dist_name=MRBTS-${mrbtsID}/NRBTS-${nrbtsID}/NRDU-1
        ...    abbr=refNrCellGroup    filter_param=Reference to cell group
        ...    node_index=${index}
        run keyword if    '${value}'=='${deletion_cellgrp}'    selenium_coam.remove_element
        ...    dist_name=MRBTS-${mrbtsID}/NRBTS-${nrbtsID}/NRDU-1
        ...    abbr=refNrCellGroup    filter_param=Reference to cell group
        ...    node_index=${index}
    END
    selenium_coam.validate_plan
    Wait Until Keyword Succeeds    5x     20s    selenium_coam.activate_plan    activate_plan_despite_errors=${True}    timeout=${600}
    [Teardown]    Selenium Logout And Close Browser

online Reconfigure 2_20MHz_8D4U to 3_20MHz_4D4U
    [Arguments]    ${file_path}    ${addition_cell}=3    ${addition_cellgrp}=2
    selenium login and disable screen lock
    FOR  ${cellID}  IN RANGE    1    3
    #    selenium_coam.remove_object    object_name=MRBTS-${mrbtsID}/MNL-1/MNLENT-1/CELLMAPPING-1/LCELNR-${cellID}/CHANNELGROUP-2  timeout=15
        log to console  modify celltype
        selenium_coam.set_parameter_value    dist_name=MRBTS-${mrbtsID}/NRBTS-${nrbtsID}/NRCELL-${cellID}
        ...    filter_param=NR Cell type    abbr=nrCellType     new_value=4DL4UL
    END
    Online add Cell    file_path=${file_path}    addition_cell=${addition_cell}    addition_cellgrp=${addition_cellgrp}
    selenium_coam.validate_plan
    Wait Until Keyword Succeeds    5x     20s    selenium_coam.activate_plan    activate_plan_despite_errors=${True}    timeout=${600}
	[Teardown]    Selenium Logout And Close Browser

CB010459_7_Online_Reconfigure_3x20MHz_4D4U_to_2x20MHz_8D4U
    Wait Until Keyword Succeeds    5min    30s    Connect to gnb coam via ssl    connection=GNB_OAM
    ${cell_grp_old}  Get All Cell Group Id
    ${cell_grp_len_old}    get length    ${cell_grp_old}
	start SAS server
    Wait until keyword succeeds    10min    30s    verify all cells should be onair
    online Reconfigure 3_20MHz_4D4U to 2_20MHz_8D4U    file_path=${SCF_CB009453_40M_40M}
    Sleep    30s
    Wait until keyword succeeds    10min    30s    verify all cells should be onair
    online Reconfigure 2_20MHz_8D4U to 3_20MHz_4D4U    file_path=${SCF_upload}
    Sleep    30s
    Wait until keyword succeeds    10min    30s    verify all cells should be onair
    Sleep    30s
    ${cell_grp_new}  Get All Cell Group Id
    ${cell_grp_len_new}    get length    ${cell_grp_new}
    Should be True    ${cell_grp_len_old}==${cell_grp_len_new}
#    Commissioning SCF And Check RU On Air   scf_file_path=${SCF_CB009453_8DL_8UL}
#    Activate feature CBRS By Coam
#    Sleep    30s
#    Wait until keyword succeeds    10min    30s    verify all cells should be onair
    Set qRxLevMin value    value=${-22}    cellid=3
    Set qRxLevMin value    value=${-22}    cellid=2
    Set qRxLevMin value    value=${-65}    cellid=1
    data_transfer_common    tput_self_define=${tput_define}    cell_id=${cell_id1}   loop_times=${1}    duration=${300}
    ...    target_avg_percent=0.2    min_percent=0.2

Online Change CBRS Flag
    [Arguments]  ${actNrCbrs}
    log to console    online change NR CBRS
    selenium_coam.set_parameter_value  dist_name=MRBTS-${mrbtsID}/NRBTS-${nrbtsID}    filter_param=Activate NR CBRS
    ...    abbr=actNrCbrs    new_value=${actNrCbrs}

Online delete Cell
    [Arguments]  ${deletion_cell}=2  ${deletion_cellgrp}=1
    ${activate_plan_despite_errors}    set variable if    ${if_pdl_check}    ${False}    ${True}
    ${cell_grp}  Get All Cell Group Id
    log to console  delete cell
    selenium_coam.remove_object    object_name=MRBTS-${mrbtsID}/MNL-1/MNLENT-1/CELLMAPPING-1/LCELNR-${deletion_cell}    timeout=15
    selenium_coam.remove_object    object_name=MRBTS-${mrbtsID}/NRBTS-${nrbtsID}/NRCELL-${deletion_cell}    timeout=15
    selenium_coam.remove_object    object_name=MRBTS-${mrbtsID}/NRBTS-${nrbtsID}/NRCELLGRP-${deletion_cellgrp}    timeout=15
    ${cell_grp_len}    get length    ${cell_grp}
    FOR    ${index}    IN RANGE    ${cell_grp_len}
        ${value}    selenium_coam.get_parameter_value     dist_name=MRBTS-${mrbtsID}/NRBTS-${nrbtsID}/NRDU-1
        ...    abbr=refNrCellGroup    filter_param=Reference to cell group
        ...    node_index=${index}
        run keyword if    '${value}'=='${deletion_cellgrp}'    selenium_coam.remove_element
        ...    dist_name=MRBTS-${mrbtsID}/NRBTS-${nrbtsID}/NRDU-1
        ...    abbr=refNrCellGroup    filter_param=Reference to cell group
        ...    node_index=${index}
    END

CB010459_Verify_online_modification_desiredPmax_maxEIRP_same_as_before
    Commissioning SCF And Check RU On Air   scf_file_path=${SCF_CB009453}
    Activate feature CBRS By Coam
    Sleep    30s
    start SAS server
    Wait until keyword succeeds    10min    30s    verify all cells should be onair
	${grant_info_cell1}    Get Grant Parameters By Coam
	${grant_info_cell2}    Get Grant Parameters By Coam 	cellID=2
	Selenium Login And Disable Screen Lock
    Online Change desiredPmax maxGrantPwrRed And antennaGain
    ...    desiredPmax=25
    ...    antennaGain=6
    ...    maxGrantPwrRed=3
	Selenium Logout And Close Browser
	Sleep    60s
	${grant_info_cell1_new}    Get Grant Parameters By Coam
	${grant_info_cell2_new}    Get Grant Parameters By Coam 	cellID=2
	Should be True    '${grant_info_cell1_new}[maxEirp]'=='24.1'
	Should be True    '${grant_info_cell2_new}[maxEirp]'=='19.1'
	Check no relinquish   grantid=${grant_info_cell1}[grantId]
	Check relinquish	grantid=${grant_info_cell2}[grantId]
    Wait until keyword succeeds    10min    30s    verify all cells should be onair

load_scf
    start SAS server
	FOR    ${TEST_LOOP}    IN RANGE    0    20
        log to console    ++++ start test loop ${TEST_LOOP} ++++
        Commissioning SCF And Check RU On Air   scf_file_path=${SCF_CB009453_40M_40M}
        Activate feature CBRS By Coam
		Wait until keyword succeeds    8min    30s    verify all cells should be onair
        ${alarm_status}    Run Keyword And Return Status    Unexpect Alarm Should Not Exist   allowed_faults=@{ALLOWED_FAULT}
        should be true    ${alarm_status}
        Sleep    60s
        ${history_alarm_status}    Run Keyword And Return Status    Unexpect History Alarm Should Not Exist
        ...    allowed_faults=@{ALLOWED_HISTORY_FAULT}
        should be true    ${history_alarm_status}
        csn.reset_cache
    END


CB010459_21_Online_modify_objectlocking_parameters
    Commissioning SCF And Check RU On Air   scf_file_path=${SCF_CB009453_40M_40M}
    Activate feature CBRS By Coam
    Sleep    30s
    Start SAS server
    Wait until keyword succeeds    10min    20s    verify all cells should be onair
	${grant_info_cell1}    Get Grant Parameters By Coam
    ${physcellid_pre}   Get physcellid By Coam
    modify physcellid by Coam    value=${753}
    sleep    5s
    Wait until keyword succeeds    10min    20s    verify all cells should be onair
    Check no relinquish		grantid=${grant_info_cell1}[grantId]
    modify physcellid by Coam    value=${999}
    sleep    5s

CB005763-DC_Dying_Gasp_alarm_check_ecpri_AQQJ
    [Arguments]    ${gnb_index}=${0}    ${du_index}=${0}
    AlarmWatchdog.add_allow_alarms    fault_id=10
    AlarmWatchdog.add_allow_alarms    fault_id=4589
    Commissioning SCF And Check RU On Air   scf_file_path=${SCF_CB009453_40M_40M}
    Activate feature CBRS By Coam
    Sleep    30s
    Start SAS server
    Wait until keyword succeeds    10min    20s    verify all cells should be onair
    ${model}    set variable    ${tl.gnbs[${gnb_index}].dus[${du_index}].rus[1].pdu_port.pdu.__class__.__name__}
    ${address}    set variable    ${tl.gnbs[${gnb_index}].dus[${du_index}].rus[1].pdu_port.pdu.addr}
    ${port}    set variable    ${tl.gnbs[${gnb_index}].dus[${du_index}].rus[1].pdu_port.port_no}
    log to console    model is ${model}, pb ip is ${address}, pb port is ${port}
    pdu.Setup Pdu    model=${model}   host=${address}    alias=pdu_ru_2
    pdu.power off    port=${port}    pdu_device=pdu_ru_2
    Wait Until Keyword Succeeds    5 min    10 sec    Check Specific Alarm in Alarm List    type=Active
    ...    faultId=10    Supplementary=RU connection was lost in runtime;RU power loss
    pdu.power on    port=${port}    pdu_device=pdu_ru_2
    Wait Until Keyword Succeeds    5 min    10 sec    Verify all cells should be onair
    [Teardown]    run keyword and ignore error    Perform RU Power On    ru_index=${2}
