# *** Settings ***
# Suite Setup    Common Suite Setup
# #Suite Teardown    Common Suite Teardown
# Test Setup    Common Test Setup
# #Test Teardown    Common Test Teardown
# Force Tags    CLOUD_5G_I_BOO_AP_KLLL_SANSA_L1B_ECPRI_CMWV_TDD    owner_l3gao   AP    CRT
# ...    SBTS00    SBTS23R1    RAN_5G_TDD
# Resource    ../../resources/KISS/robot/common_resource.robot
# Resource    ../../resources/sg10/internal_resource/internal_resource.robot
# Documentation     maxDlHarqTx=8
# ...               0x340000=15      # as PM counter period update to 15/15=1min
# 
# *** Variables ***
# ${CONFIG_DIR_PATH}    ${CURDIR}/config
# ${SCFC_NAME}     SCFC_87957_case02_AQQL_AP_KLLL.xml
# ${AIRPHONE_NAME}    IPHY_AQQL_2ABIL_1CELL_case02_configure1.xml
# ${COMAVALUE}    ${CURDIR}/coma/8701_coma_dft.txt
# ${WTS_NAME}    wts_87957_case02_16ue.cfg
# @{LOG_NAME_LIST}    gnb_snapshot
# ${UE_NUM}         16
# ${EGATE_TAG}      MUmimo
# ${BIP_TAG}    mumumo_bip
# &{GNBMIRRORINGCONFIGS}    BB_SLOT_2='false'   BB_SLOT_1='false'    BB_SLOT_5='true'    SYSCOM_MIRRORING='true'
# ...    L2HI_MIRRORING='true'   L2RT_MIRRORING='true'   CPRT_MIRRORING='false'  NUMBER_OF_FILES=30
# @{Rdparameter}    0x340000:15     0x580587:16     0x580450:6     0x5801c8:0
# ${TP_sum}    0
# ${peak}  788
# 
# *** Test Cases ***
# CB0087957_Case02_16UEs_8Pos_rank2_pairing_SA_bandwith60_semistatic14
#     step1: gNB and AP prepair
#     step2: attach 16UEs with 8Pos and check pairing
# #    step3: attach 16UEs with 8Pos and check pairing with bler
# #    step4: attach 16UEs with 8Pos mixdata and check pairing with bler
# 
# *** Keywords ***
# step1: gNB and AP prepair
#     Modify 8701 Swconfig
#     Modify l1bypass
#     Prepare gnb onair
# 
# step2: attach 16UEs with 8Pos and check pairing
#     Start capture gnb and ap syslog in '16ue_8pos' file
#     Attach '${UE_NUM}' SA UE
#     SA '${UE_NUM}' UE Data buffer send
#     Airphone override to rank2
#     Wait '3s' for stable
#     run keyword and continue on failure    Check 16UEs_8Pos throughput     90000
#     run keyword and continue on failure    Get 87957 counter
#     log to console   ttitrace capture about 120s
#     Wait '120s' for stable
#     Airphone '${UE_NUM}' SA Stop Data Traffic And Detach UE
#     log to console  ${\n}---capture snapshot---
#     Collect GNB SnapShot     target_file_name=${test_log_directory()}/All/gnb_comon_16UE_in_8Pos_snapshot.zip
#     log to console    stop syslog and check wrn
#     Stop capture gnb and ap syslog in '16ue_8pos' file
# 
# step3: attach 16UEs with 8Pos and check pairing with bler
#     Start capture gnb and ap syslog in '16ue_8pos_bler' file
#     Attach '${UE_NUM}' SA UE
#     SA '${UE_NUM}' UE Data buffer send
#     Airphone override to rank2
#     add bler to UE1
#     Wait '3s' for stable
#     run keyword and continue on failure    Check 16UEs_8Pos throughput mixdata     60000
#     run keyword and continue on failure    Get 87957 counter
#     log to console   ttitrace capture about 120s
#     Wait '120s' for stable
#     Airphone '${UE_NUM}' SA Stop Data Traffic And Detach UE
#     log to console  ${\n}---capture snapshot---
#     Collect GNB SnapShot     target_file_name=${test_log_directory()}/All/gnb_comon_16UE_in_8Pos_snapshot_bler.zip
#     log to console    stop syslog and check wrn
#     Stop capture gnb and ap syslog in '16ue_8pos_bler' file
# 
# step4: attach 16UEs with 8Pos mixdata and check pairing with bler
#     Start capture gnb and ap syslog in '16ue_8pos_mixdata_bler' file
#     Attach '${UE_NUM}' SA UE
#     SA '${UE_NUM}' UE Data buffer send mixdata
#     Airphone override to rank2
#     add bler to UE1
#     Wait '3s' for stable
#     run keyword and continue on failure    Check 16UEs_8Pos throughput     90000
#     run keyword and continue on failure    Get 87957 counter
#     log to console   ttitrace capture about 120s
#     Wait '120s' for stable
#     Airphone '${UE_NUM}' SA Stop Data Traffic And Detach UE
#     log to console  ${\n}---capture snapshot---
#     Collect GNB SnapShot     target_file_name=${test_log_directory()}/All/gnb_comon_16UE_in_8Pos_snapshot_bler_mixdata.zip
#     log to console    stop syslog and check wrn
#     Stop capture gnb and ap syslog in '16ue_8pos_mixdata_bler' file
# 
# add bler to UE1
#     airphone_execute_egate_command    bler_testmode_nr profile_id\=1 dl_bler\=20,2,3,4,5   #add bler
#     airphone_execute_egate_command    ue_testmode_set_nr id\=1 scell\=0 testmode\=bler profile_id\=2 action\=activate
#     airphone_execute_egate_command    bler_testmode_nr profile_id\=2 dl_bler\=20,2,3,4,5   #add bler
#     airphone_execute_egate_command    ue_testmode_set_nr id\=1 scell\=0 testmode\=bler profile_id\=2 action\=activate
# 
# Modify l1bypass
#     copy_file    ${COMAVALUE}    ${test_log_directory()}/coma.py
#     Import Variables    ${test_log_directory()}/coma.py
#     Modify airphone l1bypass coma value for eight ue
#     ...    ${Hindex13}    ${Vindex7}    ${Hindex13}    ${Vindex7}
#     ...    ${Hindex6}     ${Vindex7}    ${Hindex6}    ${Vindex7}
#     ...    ${Hindex25}    ${Vindex7}    ${Hindex25}    ${Vindex7}
#     ...    ${Hindex17}    ${Vindex7}     ${Hindex17}    ${Vindex7}
#     ...    ${Hindex14}    ${Vindex8}     ${Hindex14}    ${Vindex8}
#     ...    ${Hindex10}    ${Vindex8}    ${Hindex10}    ${Vindex8}
#     ...    ${Hindex2}     ${Vindex8}    ${Hindex2}    ${Vindex8}
#     ...    ${Hindex21}    ${Vindex8}     ${Hindex21}    ${Vindex8}
# 
# Airphone override to rank2
#     airphone_execute_egate_command    csi_override_testmode_nr profile_id\=6 cqi\=15 ri\=1
#     : FOR    ${num}    IN RANGE    1    ${UE_NUM}+1
#     \    airphone_execute_egate_command    ue_testmode_set_nr id\=${num} testmode\=csi_override action\=activate profile_id\=6
# 
# Wait for '${time}' to stop ttitrace with name'${tti_tag}'
#     sleep   ${time}
#     ${pcap_path}    Stop GNB Ttitrace With Streaming Mode    name=${tti_tag}
#     Decoder Tttirace From Pcap To Csv    ${pcap_path}      ${test_log_directory()}/All/${tti_tag}/tti
# 
# Modify 8701 Swconfig
# 	Add GNB swconfig    @{Rdparameter}
# 
# Check 16UEs_8Pos throughput
#     [Arguments]     ${throughput}
#     Wait until keyword succeeds    48s    8s    Verify 16UEs_8Pos throughput     ${throughput}
# 
# Check 16UEs_8Pos throughput mixdata
#     [Arguments]     ${throughput}
#     Wait until keyword succeeds    48s    8s    Verify 16UEs_8Pos throughput mixdata     ${throughput}
# 
# Verify 16UEs_8Pos throughput mixdata
#     [Arguments]    ${target_cell_throughput}
#     ${UEs_TP_DL}   create list
#     ${UEs_TP_UL}   create list
#     : FOR    ${num}    IN RANGE    1    ${UE_NUM}+1
#     \    ${dl_throughput_pcell}    airphone_get_throughput_on_specific_scell    ue_id=${num}    scell_id=0    type=pdsch    tput_type=ave
#     \    ${ul_throughput_pcell}    airphone_get_throughput_on_specific_scell    ue_id=${num}    scell_id=0    type=pusch    tput_type=ave
#     \    run keyword and continue on failure     should_be_true    ${dl_throughput_pcell}>${target_cell_throughput}    #250000
#     \    append to list    ${UEs_TP_DL}    ${dl_throughput_pcell}
#     \    append to list    ${UEs_TP_UL}    ${ul_throughput_pcell}
#     log to console    16UEs_DL_TP_total are ${UEs_TP_DL}
#     log to console    16UEs_UL_TP_total are ${UEs_TP_UL}
# 
# Verify 16UEs_8Pos throughput
#     [Arguments]    ${target_cell_throughput}
#     ${UEs_TP_DL}   create list
#     ${UEs_TP_UL}   create list
#     : FOR    ${num}    IN RANGE    1    ${UE_NUM}+1
#     \    ${dl_throughput_pcell}    airphone_get_throughput_on_specific_scell    ue_id=${num}    scell_id=0    type=pdsch    tput_type=ave
#     \    ${ul_throughput_pcell}    airphone_get_throughput_on_specific_scell    ue_id=${num}    scell_id=0    type=pusch    tput_type=ave
#     \    run keyword and continue on failure     should_be_true    ${dl_throughput_pcell}>${target_cell_throughput}    #250000
#     \    append to list    ${UEs_TP_DL}    ${dl_throughput_pcell}
#     \    append to list    ${UEs_TP_UL}    ${ul_throughput_pcell}
#     log to console    16UEs_DL_TP_total are ${UEs_TP_DL}
#     log to console    16UEs_UL_TP_total are ${UEs_TP_UL}
# 
# Attach '${UE_NUM}' SA UE
#     : FOR    ${num}    IN RANGE    1    ${UE_NUM}+1
#     \   airphone_cleanup_egate_console_log
#     \   ${num_new}    evaluate    ${num}%10+1
#     \   Log To Console   ${\n}-----register UE ${num} ------
#     \   Airphone SA Attach    ue_id=${num}
#     \   Airphone Set Traffic Type    ue_id=${num}    pdu_id=${num_new}    type=internal
#     \   Airphone Pdu Session Setup   ue_id=${num}    pdu_id=${num_new}   nwslice_id=1    gw_id=${num}
#     \   Wait '1s' for stable
# #    \   run keyword and continue on failure     check_SRS_resource_and_PDSCH_scramblingID_SA   ${EGATE_TAG}_${num}
# 
# SA '${UE_NUM}' UE Data buffer send
#     : FOR    ${num}    IN RANGE    1    ${UE_NUM}+1
#     \   ${num_new}    evaluate    ${num}%10+1
#     \   SA send mutiple trf dl data    ${num}    2   150M    ${num_new}
#     \   SA send mutiple trf ul data    ${num}    1   13M    ${num_new}
#     \   Log To Console   ${\n}-----data sent to UE ${num} ------
# 
# SA '${UE_NUM}' UE Data buffer send mixdata
#     : FOR    ${num}    IN RANGE    1    ${UE_NUM}+1
#     \   ${num_new}    evaluate    ${num}%10+1    #for pdu id
#     \    run keyword if     ${num}<3    SA send mutiple trf dl data    ${num}    1   10M    ${num_new}
#     \    run keyword if     ${num}>3    SA send mutiple trf dl data    ${num}    2   150M    ${num_new}
#     \   SA send mutiple trf ul data    ${num}    1   13M    ${num_new}
#     \   Log To Console   ${\n}-----data sent to UE ${num} ------
# 
# Airphone '${UE_NUM}' SA Stop Data Traffic
#     : FOR    ${num}    IN RANGE    1    ${UE_NUM}+1
#     \    Airphone SA Stop Data Traffic     ${num}     BI    ${num}
# 
# Airphone '${UE_NUM}' SA Stop Data Traffic And Detach UE
#     : FOR    ${num}    IN RANGE    1    ${UE_NUM}+1
# #    \   Airphone SA Stop Data Traffic     ${num}     BI    ${num}
# #    \   Airphone SA Stop Data Traffic     ${num}     DL    ${num}
#     \   airphone_sa_detach    ue_id=${num}    timeout=5
#     \   Wait '2s' for stabible
#     \   log to console    detach ue${num} and stop data
# 
# check_SRS_resource_and_PDSCH_scramblingID_SA
#     [Arguments]    ${EGATE_TAG}
#     check_log_with_au2anlysis    ${CURDIR}/ini/check_SRS_resource_and_PDSCH_scramblingID_8701_case02.ini    p
#     ...   save_log_directory=${TEST_LOG_DIRECTORY()}/All/${EGATE_TAG}_egate
# 
# Check mupair in ttitrace
#     check_log_with_au2anlysis    ini_path=${CURDIR}/ini/8701_case02_mupair.ini    log_need_to_check=i
#     ...    save_log_directory=${TEST_LOG_DIRECTORY()}/All
# 
# Overide UE bler
#    airphone_execute_egate_command    bler_testmode_nr profile_id\=1 dl_bler\=100,2,3,4,5,6
#    airphone_execute_egate_command    ue_testmode_set_nr id\=1 scell\=0 testmode\=bler profile_id\=1 action\=activate
#    airphone_execute_egate_command    ue_testmode_set_nr id\=2 scell\=0 testmode\=bler profile_id\=1 action\=activate
#    airphone_execute_egate_command    ue_testmode_set_nr id\=3 scell\=0 testmode\=bler profile_id\=1 action\=activate
#    airphone_execute_egate_command    ue_testmode_set_nr id\=4 scell\=0 testmode\=bler profile_id\=1 action\=activate
# 
# Overide UE1 Rank1
#     airphone_execute_egate_command    csi_override_testmode_nr profile_id\=2 cqi\=15 ri\=0
#     airphone_execute_egate_command    ue_testmode_set_nr id\=1 testmode\=csi_override action\=activate profile_id\=2
# 
# Get 87957 counter
#     Log To Console   wait for 120s for counter
#     Wait '120s' for stable
#     Log To Console   start to capture counter
#     ${PRB_DL_SU_MIMO_LAYER_list}   create list
#     ${PRB_DL_MU_MIMO_LAYER_list}   create list
#     ${remaining_time}=    get_counter_file_remaining_time    counter_refresh_period=1min
#     log to console    ${remaining_time}
#     Wait Throughput Timer    ${remaining_time}
#     ${PM_counter_file}=    download_latest_pmcounter    local_path=${TEST_LOG_DIRECTORY()}pmcounter${/}
#     : FOR    ${num}    IN RANGE    1    5
# 	\    ${result}=    get_counter_value_from_counter_file    counter_file=${PM_counter_file}
#     ...    counter_id=M55308C3400${num}    cell_id=1
#     \    set suite variable     ${PRB_DL_SU_MIMO_${num}LAYER}     ${result}
#     \    append to list    ${PRB_DL_SU_MIMO_LAYER_list}    ${PRB_DL_SU_MIMO_${num}LAYER}
#     \    log to console    ${PRB_DL_SU_MIMO_LAYER_list}
#     : FOR    ${num}    IN RANGE    5    10
# 	\    ${result}=    get_counter_value_from_counter_file    counter_file=${PM_counter_file}
#     ...    counter_id=M55308C3400${num}    cell_id=1
#     \    ${num_layer}   evaluate   ${num}-3
#     \    set suite variable     ${PRB_DL_MU_MIMO_${num_layer}LAYER}     ${result}
#     \    append to list    ${PRB_DL_MU_MIMO_LAYER_list}    ${PRB_DL_MU_MIMO_${num_layer}LAYER}
#     \    log to console    ${PRB_DL_MU_MIMO_LAYER_list}
#     : FOR    ${num}    IN RANGE    10    12
# 	\    ${result}=    get_counter_value_from_counter_file    counter_file=${PM_counter_file}
#     ...    counter_id=M55308C340${num}    cell_id=1
#     \    ${num_layer}   evaluate   ${num}-3
#     \    set suite variable     ${PRB_DL_MU_MIMO_${num_layer}LAYER}     ${result}
#     \    append to list    ${PRB_DL_MU_MIMO_LAYER_list}    ${PRB_DL_MU_MIMO_${num_layer}LAYER}
#     \    log to console    ${PRB_DL_MU_MIMO_LAYER_list}
#     : FOR    ${num}    IN RANGE    16    24
# 	\    ${result}=    get_counter_value_from_counter_file    counter_file=${PM_counter_file}
#     ...    counter_id=M55308C340${num}    cell_id=1
#     \    ${num_layer}   evaluate   ${num}-7
#     \    set suite variable     ${PRB_DL_MU_MIMO_${num_layer}LAYER}     ${result}
#     \    log to console    ${PRB_DL_MU_MIMO_${num_layer}LAYER}
#     \    append to list    ${PRB_DL_MU_MIMO_LAYER_list}    ${PRB_DL_MU_MIMO_${num_layer}LAYER}
#     \    log to console    ${PRB_DL_MU_MIMO_LAYER_list}
#     log to console    SUlayer 1_2_3_4 ${PRB_DL_SU_MIMO_LAYER_list}
#     log to console    MUlayer 2_3_4_5_6_7_8_9_10_11_12_13_14_15_16 ${PRB_DL_MU_MIMO_LAYER_list}
# 
#     ${MAC_DTCH_CELL_THP_DL_MAX}=    get_counter_value_from_counter_file    counter_file=${PM_counter_file}
#     ...    counter_id=M55309C12001    cell_id=1
#     ${Cell1_TP_total}    evaluate    ${MAC_DTCH_CELL_THP_DL_MAX}*8/1024/1024
#     log to console    ${Cell1_TP_total}
# 
# check TP and bler with ttitrace
#     [Arguments]    ${throughput}    ${time_avg}    ${tti_file}    ${ini_file}
#     ${a}  get_ues_tbsize_by_sfn   ${test_log_directory()}/All/${tti_file}/tti_dl.csv
#     ...        ${test_log_directory()}/All/${tti_file}/tti_dl_new.csv   ${time_avg}   filter=dlFdSchedData.ackNack\=ACK
#     @{keys}  Get Dictionary Keys   ${a}
#     : FOR      ${key}     IN     @{keys}
#     \    ${result}   evaluate  ${a[${key}]}/${time_avg}/1024/1000
#     \    log to console   result is ${result}
#     \    log to console   target TP is ${throughput}
#     \    should be true  ${result}>${throughput}
#     check_log_with_au2anlysis    ini_path=${CURDIR}/ini/${ini_file}.ini    log_need_to_check=i
#     ...   save_log_directory=${TEST_LOG_DIRECTORY()}/All/${tti_file}/