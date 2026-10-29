# *** Settings ***
# Suite Setup    Common Suite Setup
# Suite Teardown    Common Suite Teardown
# Test Setup    Common Test Setup
# Test Teardown    Common Test Teardown
# Force Tags    CLOUD_5G_I_BO_AP_KL_SANSA_L1B_ECPRI_CMWV_TDD    owner_yuqq   AP    CRT    SBTS00    RAN_5G_TDD    RAN_5G
# Resource    ../../resources/KISS/robot/common_resource.robot
# Resource    ../../resources/sg10/internal_resource/internal_resource.robot
# 
# 
# *** Variables ***
# ${CONFIG_DIR_PATH}    ${CURDIR}/config
# ${SCFC_NAME}      SCFC_8701_case03.xml
# ${AIRPHONE_NAME}    IPHY_AQQL_2ABIL_1CELL_case03.xml
# ${COMAVALUE}    ${CURDIR}/coma/8701_coma_dft.txt
# ${WTS_NAME}    wts_8701_case03.cfg
# @{LOG_NAME_LIST}    gnb_snapshot
# ${SA_UE_NUM}         2
# ${NSA_UE_NUM}         2
# ${EGATE_TAG}      MUmimo
# ${BIP_TAG}    mumumo_bip
# ${tti_tag}    ttitrace
# ${sys_tag}    sys
# ${tti_bler}   startdlber
# ${tti_stopbler}    stopdlbler
# &{GNBMIRRORINGCONFIGS}    BB_SLOT_2='false'   BB_SLOT_1='false'    BB_SLOT_5='true'    SYSCOM_MIRRORING='true'
# ...    L2HI_MIRRORING='true'   L2RT_MIRRORING='true'   CPRT_MIRRORING='false'  NUMBER_OF_FILES=30
# @{Rdparameter}     0x420062:1
# 
# *** Test Cases ***
# CB008701_A_B1_case03_4UEs_rank_4_4_4_4with_nonGBR_paired_with_dlMuMimoRankAdaption_Adaptive_2TAS_2codebook_SA_NSA
#     Modify 8701 Swconfig
#     Modify l1bypass
#     Prepare gnb onair
#     Execute AP Command before attach
#     Start capture gnb and ap syslog in '${sys_tag}' file
#     Attach '${NSA_UE_NUM}' NSA UE and data buffer sent
# 	Attach '${SA_UE_NUM}' SA UE and data buffer sent
#     Wait '25s' for stable
# #    Start collect bip log
# #    Wait for '4s' to stop bip log with name'${BIP_TAG}'
#     run keyword and continue on failure    Check '${NSA_UE_NUM}' NSA UE throughput
# 	run keyword and continue on failure    Check '${SA_UE_NUM}' SA UE throughput
#     Start collect ttitrace
#     Wait for '3s' to stop ttitrace with name'${tti_tag}'
# 	run keyword and continue on failure    Check mupair in ttitrace
# 	UE send dl bler
# 	Start collect ttitrace
#     Wait for '3s' to stop ttitrace with name'${tti_bler}'
# 	run keyword and continue on failure    Check ReservedMcs in ttitrace
#     Airphone NSA Stop Data Traffic And Detach UE
# 	Airphone SA Stop Data Traffic And Detach UE
#     Stop capture gnb and ap syslog in '${sys_tag}' file
# 
# *** Keywords ***
# Modify l1bypass
#     copy_file    ${COMAVALUE}    ${test_log_directory()}/coma.py
#     Import Variables    ${test_log_directory()}/coma.py
#     Modify airphone l1bypass coma value for eight ue
#     ...    ${Hindex13}    ${Vindex7}    ${Hindex13}    ${Vindex7}
#     ...    ${Hindex6}    ${Vindex7}    ${Hindex6}    ${Vindex7}
#     ...    ${Hindex25}    ${Vindex7}    ${Hindex25}    ${Vindex7}
#     ...    ${Hindex17}    ${Vindex7}     ${Hindex17}    ${Vindex7}
#     ...    ${Hindex14}    ${Vindex8}     ${Hindex14}    ${Vindex8}
#     ...    ${Hindex10}    ${Vindex8}    ${Hindex10}    ${Vindex8}
#     ...    ${Hindex2}    ${Vindex8}    ${Hindex2}    ${Vindex8}
#     ...    ${Hindex21}    ${Vindex8}     ${Hindex21}    ${Vindex8}
# 
# UE send dl bler
# 	airphone_execute_egate_command    bler_testmode_nr profile_id\=1 dl_bler\=100,2,3,4 
# 	airphone_execute_egate_command    ue_testmode_set_nr id\=1 scell\=0 testmode\=bler profile_id\=1 action\=activate 
# 	
# UE stop dl bler
# 	airphone_execute_egate_command    ue_testmode_set_nr id\=1 scell\=0 testmode\=bler profile_id\=1 action\=deactivate
# 
# Check mupair in ttitrace
#     check_log_with_au2anlysis    ini_path=${CURDIR}/ini/tti_dl_case3.ini    log_need_to_check=i    
# 	...     save_log_directory=${TEST_LOG_DIRECTORY()}/All/${tti_tag}
# 
# Check ReservedMcs in ttitrace
# 	check_log_with_au2anlysis    ini_path=${CURDIR}/ini/tti_dl_case13_reservedMCS.ini    log_need_to_check=i
#     ...    save_log_directory=${TEST_LOG_DIRECTORY()}/All/${tti_bler}
# 
# check TP and bler with ttitrace
#     [Arguments]    ${throughput}    ${time_avg}    ${tti_file}    ${ini_file}
#     ${a}  get_ues_tbsize_by_sfn   ${test_log_directory()}/All/${tti_file}/tti_dl.csv
#     ...        ${test_log_directory()}/All/${tti_file}/tti_dl_new.csv   ${time_avg}   filter=dlFdSchedData.ackNack\=ACK
#     @{keys}  Get Dictionary Keys   ${a}
#     : FOR      ${key}     IN     @{keys}
#     \    ${result}   evaluate  ${a[${key}]}/${time_avg}/1024/1000
#     \    log to console   result is ${result}
#     \    log to console   TP is ${throughput}
#     \    should be true  ${result}>${throughput}
# #    check_log_with_au2anlysis    ini_path=${CURDIR}/ini/${ini_file}.ini    log_need_to_check=i
# #    ...   save_log_directory=${TEST_LOG_DIRECTORY()}/All/${tti_file}/
# 
# Wait for '${time}' to stop ttitrace with name'${tti_tag}'
#     sleep   ${time}
#     ${pcap_path}    Stop GNB Ttitrace With Streaming Mode
#     Decoder Tttirace From Pcap To Csv    ${pcap_path}      ${test_log_directory()}/All/${tti_tag}/tti
# 
# Modify 8701 Swconfig
# 	Add GNB swconfig    0x420062:1
# 
# Check NSA UE throughput
#     Wait until keyword succeeds    60s    5s    Verify multi NSA UEs throughput
# 
# Check '${UE_NUM}' NSA UE throughput
#     Wait until keyword succeeds    60s    5s    Verify '${UE_NUM}' NSA UEs throughput
# 
# Check '${UE_NUM}' SA UE throughput
#     Wait until keyword succeeds    60s    5s    Verify '${UE_NUM}' SA UEs throughput
# 
# Verify multi NSA UEs throughput
#     : FOR    ${num}    IN RANGE    12    ${UE_NUM}+12
#     \    ${dl_throughput_pcell}    airphone_get_throughput_on_specific_scell    ue_id=${num}    scell_id=8    type=pdsch    tput_type=ave
#     \    should_be_true    ${dl_throughput_pcell}>350000
# 
# Verify '${NSA_UE_NUM}' NSA UEs throughput
#     : FOR    ${num}    IN RANGE    12    ${NSA_UE_NUM}+12
#     \    ${dl_throughput_pcell}    airphone_get_throughput_on_specific_scell    ue_id=${num}    scell_id=8    type=pdsch    tput_type=ave
#     \    should_be_true    ${dl_throughput_pcell}>350000
# 	
# Verify '${SA_UE_NUM}' SA UEs throughput
#     : FOR    ${num}    IN RANGE    1    ${SA_UE_NUM}+1
#     \    ${dl_throughput_pcell}    airphone_get_throughput_on_specific_scell    ue_id=${num}    scell_id=0    type=pdsch    tput_type=ave
#     \    should_be_true    ${dl_throughput_pcell}>350000
# 
# Attach '${NSA_UE_NUM}' NSA UE and data buffer sent
#     : FOR    ${num}    IN RANGE    12    ${NSA_UE_NUM}+12
#     \   airphone_cleanup_egate_console_log
#     \   Airphone Nsa Attach    ${num}    profile_id=None
#     \   Wait '3s' for stabible
#     \   Collect AP egate log    ${EGATE_TAG}_${num}
#     \   run keyword and continue on failure     check_SRS_resource_and_PDSCH_scramblingID   ${EGATE_TAG}_${num}
#     \   NSA send ue '${num}' mutiple trf '3' for each '150M' DL data
#     \   NSA send ue '${num}' mutiple trf '1' for each '15M' UL data
# 
# Attach '${SA_UE_NUM}' SA UE and data buffer sent
# 	: FOR    ${num}    IN RANGE    1    ${SA_UE_NUM}+1
#     \   airphone_cleanup_egate_console_log
#     \   Airphone SA Attach    ue_id=${num}
#     \   Wait '2s' for stabible
#     \   Airphone Set Traffic Type    ue_id=${num}    pdu_id= ${num}    type=internal
#     \   Airphone Pdu Session Setup    ue_id=${num}   pdu_id=${num}   nwslice_id=1   gw_id=${num}
#     \   Wait '3s' for stabible
#     \   SA send mutiple trf dl data    ${num}    3    175M   ${num}
#     \   SA send mutiple trf ul data    ${num}    1    20M   ${num}
# 
# Airphone NSA Stop Data Traffic And Detach UE
#     : FOR    ${num}    IN RANGE    12    ${NSA_UE_NUM}+12
#     \    Airphone NSA Stop Data Traffic   ${num}    BI
#     \    Airphone NSA Detach    ${num}
# 
# Airphone SA Stop Data Traffic And Detach UE
#     : FOR    ${num}    IN RANGE    1    ${SA_UE_NUM}+1
#     \    Airphone SA Stop Data Traffic     ${num}     BI    ${num}
#     \    Airphone SA Detach    ue_id=${num}
# 
# Execute AP Command before attach
#     airphone_cleanup_egate_console_log
#     Airphone Setup X2 Connection
# 
# check_SRS_resource_and_PDSCH_scramblingID
#     [Arguments]    ${EGATE_TAG}
#     check_log_with_au2anlysis    ${CURDIR}/ini/check_SRS_resource_and_PDSCH_scramblingID_8701_case02.ini    p
#     ...   save_log_directory=${TEST_LOG_DIRECTORY()}/All/${EGATE_TAG}_egate
# 
# #Check mupair in ttitrace
# #    check_log_with_au2anlysis    ini_path=${CURDIR}/ini/8701_case02_mupair.ini    log_need_to_check=i
# #    ...    save_log_directory=${TEST_LOG_DIRECTORY()}/All
# 
# Check counters
#     ${remaining_time}=    get_counter_file_remaining_time    counter_refresh_period=5min
#     Wait Throughput Timer    ${remaining_time}
#     ${PM_counter_file}=    download_latest_pmcounter    local_path=${TEST_LOG_DIRECTORY()}pmcounter${/}
# 	${M55308C34023_PRB_DL_MU_MIMO_16LAYER}=    get_counter_value_from_counter_file    counter_file=${PM_counter_file}
#     ...    counter_id=M55308C34023    cell_id=1
# 	${M55308C34022_PRB_DL_MU_MIMO_15LAYER}=    get_counter_value_from_counter_file    counter_file=${PM_counter_file}
#     ...    counter_id=M55308C34022    cell_id=1
# 	${M55308C34021_PRB_DL_MU_MIMO_14LAYER}=    get_counter_value_from_counter_file    counter_file=${PM_counter_file}
#     ...    counter_id=M55308C34021    cell_id=1
# 	${M55308C34020_PRB_DL_MU_MIMO_13LAYER}=    get_counter_value_from_counter_file    counter_file=${PM_counter_file}
#     ...    counter_id=M55308C34020    cell_id=1
# 	${M55308C34019_PRB_DL_MU_MIMO_12LAYER}=    get_counter_value_from_counter_file    counter_file=${PM_counter_file}
#     ...    counter_id=M55308C34019    cell_id=1
# 	${M55308C34018_PRB_DL_MU_MIMO_11LAYER}=    get_counter_value_from_counter_file    counter_file=${PM_counter_file}
#     ...    counter_id=M55308C34018    cell_id=1
# 	${M55308C34017_PRB_DL_MU_MIMO_10LAYER}=    get_counter_value_from_counter_file    counter_file=${PM_counter_file}
#     ...    counter_id=M55308C34017    cell_id=1
# 	${M55308C34016_PRB_DL_MU_MIMO_9LAYER}=    get_counter_value_from_counter_file    counter_file=${PM_counter_file}
#     ...    counter_id=M55308C34016    cell_id=1
#     #CB008305
# 	${M55308C34011_PRB_DL_MU_MIMO_8LAYER}=    get_counter_value_from_counter_file    counter_file=${PM_counter_file}
#     ...    counter_id=M55308C34011    cell_id=1
# 	${M55308C34010_PRB_DL_MU_MIMO_7LAYER}=    get_counter_value_from_counter_file    counter_file=${PM_counter_file}
#     ...    counter_id=M55308C34010    cell_id=1
# 	${M55308C34009_PRB_DL_MU_MIMO_6LAYER}=    get_counter_value_from_counter_file    counter_file=${PM_counter_file}
#     ...    counter_id=M55308C34009    cell_id=1
# 	${M55308C34008_PRB_DL_MU_MIMO_5LAYER}=    get_counter_value_from_counter_file    counter_file=${PM_counter_file}
#     ...    counter_id=M55308C34008    cell_id=1
#  	${M55308C34007_PRB_DL_MU_MIMO_4LAYER}=    get_counter_value_from_counter_file    counter_file=${PM_counter_file}
#     ...    counter_id=M55308C34007    cell_id=1
#   	${M55308C34006_PRB_DL_MU_MIMO_3LAYER}=    get_counter_value_from_counter_file    counter_file=${PM_counter_file}
#     ...    counter_id=M55308C34006    cell_id=1
#   	${M55308C34005_PRB_DL_MU_MIMO_2LAYER}=    get_counter_value_from_counter_file    counter_file=${PM_counter_file}
#     ...    counter_id=M55308C34005    cell_id=1
#   	${M55308C34004_PRB_DL_SU_MIMO_4LAYER}=    get_counter_value_from_counter_file    counter_file=${PM_counter_file}
#     ...    counter_id=M55308C34004   cell_id=1
#   	${M55308C34003_PRB_DL_SU_MIMO_3LAYER}=    get_counter_value_from_counter_file    counter_file=${PM_counter_file}
#     ...    counter_id=M55308C34003   cell_id=1
#     ${M55308C34002_PRB_DL_SU_MIMO_2LAYER}=    get_counter_value_from_counter_file    counter_file=${PM_counter_file}
#     ...    counter_id=M55308C34002   cell_id=1
#     ${M55308C34001_PRB_DL_SU_MIMO_1LAYER}=    get_counter_value_from_counter_file    counter_file=${PM_counter_file}
#     ...    counter_id=M55308C34001   cell_id=1
# 
# 	${M55308C34027_PRB_DL_MU_MIMO_8PAIR_UE}=    get_counter_value_from_counter_file    counter_file=${PM_counter_file}
#     ...    counter_id=M55308C34024   cell_id=1
# 	${M55308C34026_PRB_DL_MU_MIMO_7PAIR_UE}=    get_counter_value_from_counter_file    counter_file=${PM_counter_file}
#     ...    counter_id=M55308C34024   cell_id=1
# 	${M55308C34025_PRB_DL_MU_MIMO_6PAIR_UE}=    get_counter_value_from_counter_file    counter_file=${PM_counter_file}
#     ...    counter_id=M55308C34024   cell_id=1
# 	${M55308C34024_PRB_DL_MU_MIMO_5PAIR_UE}=    get_counter_value_from_counter_file    counter_file=${PM_counter_file}
#     ...    counter_id=M55308C34024   cell_id=1
#     #CB008305
# 	${M55308C34015_PRB_DL_MU_MIMO_4PAIR_UE}=    get_counter_value_from_counter_file    counter_file=${PM_counter_file}
#     ...    counter_id=M55308C34015   cell_id=1
# 	${M55308C34014_PRB_DL_MU_MIMO_3PAIR_UE}=    get_counter_value_from_counter_file    counter_file=${PM_counter_file}
#     ...    counter_id=M55308C34014   cell_id=1
# 	${M55308C34013_PRB_DL_MU_MIMO_2PAIR_UE}=    get_counter_value_from_counter_file    counter_file=${PM_counter_file}
#     ...    counter_id=M55308C34013   cell_id=1
# 	${M55308C34012_PRB_DL_MU_MIMO_NOPAIR_UE}=    get_counter_value_from_counter_file    counter_file=${PM_counter_file}
#     ...    counter_id=M55308C34012  cell_id=1
# 
# 	${M55308C34028_TOT_MU_MIMO_PAIR_UE_PDSCH}=   get_counter_value_from_counter_file    counter_file=${PM_counter_file}
#     ...    counter_id=M55308C34028  cell_id=1
# 	${M55308C34029_TOT_MU_MIMO_ELIG_UE_PDSCH}=   get_counter_value_from_counter_file    counter_file=${PM_counter_file}
#     ...    counter_id=M55308C34029  cell_id=1
# 
#     log to console     ${M55308C34023_PRB_DL_MU_MIMO_16LAYER}
#     log to console     ${M55308C34022_PRB_DL_MU_MIMO_15LAYER}
#     log to console     ${M55308C34021_PRB_DL_MU_MIMO_14LAYER}
#     log to console     ${M55308C34020_PRB_DL_MU_MIMO_13LAYER}
#     log to console     ${M55308C34019_PRB_DL_MU_MIMO_12LAYER}
#     log to console     ${M55308C34018_PRB_DL_MU_MIMO_11LAYER}
#     log to console     ${M55308C34017_PRB_DL_MU_MIMO_10LAYER}
#     log to console     ${M55308C34016_PRB_DL_MU_MIMO_9LAYER}
#     log to console     ${M55308C34011_PRB_DL_MU_MIMO_8LAYER}
#     log to console     ${M55308C34010_PRB_DL_MU_MIMO_7LAYER}
#     log to console     ${M55308C34009_PRB_DL_MU_MIMO_6LAYER}
#     log to console     ${M55308C34008_PRB_DL_MU_MIMO_5LAYER}
#     log to console     ${M55308C34007_PRB_DL_MU_MIMO_4LAYER}
#     log to console     ${M55308C34006_PRB_DL_MU_MIMO_3LAYER}
#     log to console     ${M55308C34005_PRB_DL_MU_MIMO_2LAYER}
#     log to console     ${M55308C34004_PRB_DL_SU_MIMO_4LAYER}
#     log to console     ${M55308C34003_PRB_DL_SU_MIMO_3LAYER}
#     log to console     ${M55308C34002_PRB_DL_SU_MIMO_2LAYER}
#     log to console     ${M55308C34001_PRB_DL_SU_MIMO_1LAYER}
#     log to console     ${M55308C34027_PRB_DL_MU_MIMO_8PAIR_UE}
#     log to console     ${M55308C34026_PRB_DL_MU_MIMO_7PAIR_UE}
#     log to console     ${M55308C34025_PRB_DL_MU_MIMO_6PAIR_UE}
#     log to console     ${M55308C34024_PRB_DL_MU_MIMO_5PAIR_UE}
#     log to console     ${M55308C34015_PRB_DL_MU_MIMO_4PAIR_UE}
#     log to console     ${M55308C34014_PRB_DL_MU_MIMO_3PAIR_UE}
#     log to console     ${M55308C34013_PRB_DL_MU_MIMO_2PAIR_UE}
#     log to console     ${M55308C34012_PRB_DL_MU_MIMO_NOPAIR_UE}
#     log to console     ${M55308C34028_TOT_MU_MIMO_PAIR_UE_PDSCH}
#     log to console     ${M55308C34029_TOT_MU_MIMO_ELIG_UE_PDSCH}
