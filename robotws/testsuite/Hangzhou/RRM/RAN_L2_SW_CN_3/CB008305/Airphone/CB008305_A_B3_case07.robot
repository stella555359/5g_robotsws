# *** Settings ***
# Suite Setup    Common Suite Setup
# Suite Teardown    Common Suite Teardown
# Test Setup    Common Test Setup
# Test Teardown    Common Test Teardown
# Force Tags    CLOUD_5G_I_BO_AP_KL_SANSA_L1B_ECPRI_CMWV_TDD    owner_l3gao   AP    CRT    SBTS00    RAN_5G_TDD    RAN_5G
# Resource    ../../resources/KISS/robot/common_resource.robot
# Resource    ../../resources/sg10/internal_resource/internal_resource.robot
# Documentation     chbw change from 100mhz to 60mhz
# 
# *** Variables ***
# ${CONFIG_DIR_PATH}    ${CURDIR}/config
# ${SCFC_NAME}      SCFC_8305_case07.xml
# ${AIRPHONE_NAME}    IPHY_AEQB_1CELL.xml
# #${L1BYP_XML}      L1ByPTestModeConfiguration_case25_8ue.xml
# ${COMAVALUE}    ${CURDIR}/coma/8305_case05_dft.txt
# ${WTS_NAME}    wts_1086_7_TAS.cfg
# @{LOG_NAME_LIST}    gnb_snapshot
# ${UE_NUM}         2
# ${EGATE_TAG}      MUmimo
# ${BIP_TAG}    mumumo_bip
# &{GNBMIRRORINGCONFIG}    BB_SLOT_2='true'   BB_SLOT_1='false'    BB_SLOT_5='true'    SYSCOM_MIRRORING='true'
# ...    L2HI_MIRRORING='true'   L2RT_MIRRORING='true'   CPRT_MIRRORING='false'  NUMBER_OF_FILES=30
# 
# *** Test Cases ***
# CB008305_A_B4_case07_two_rank3_Ues_paired_and_SCID_check
#     Modify 8305 Swconfig
#     Modify l1bypass
# #    Active GNB L2 feature debug traces
#     Prepare gnb onair
#     Execute AP Command before attach
# 
#     Start capture gnb and ap syslog in 'SA_${UE_NUM}_ue' file
#     Wait '20s' for stable
#     Start collect bip log
#     Attach '${UE_NUM}' SA UE
#     Wait for '4s' to stop bip log with name'${BIP_TAG}_${UE_NUM}_rrc'
#     SA '${UE_NUM}' UE Data buffer send
#     Wait '25s' for stable
#     run keyword and continue on failure    Check '2' SA UE throughput
# #    Start collect bip log
# #    Wait for '4s' to stop bip log with name'SA_${UE_NUM}_${BIP_TAG}_fullbuffer'
# #    Wait '10s' for stable
#     Start collect ttitrace
#     Wait for '3s' to stop ttitrace with name'tti_SA_${UE_NUM}_ue_rank4'
#     Wait '20s' for stable
#     run keyword and continue on failure    Check '2' SA UE throughput
#     run keyword and continue on failure    check TP and bler with ttitrace   600    2    tti_SA_${UE_NUM}_ue_rank4   tti_case7_rank4_AP
#     run keyword and continue on failure    Check counters with Mulayer '8' layer
# 
#     Overide 2UE Rank3
#     Wait '10s' for stable
#     Start collect ttitrace
#     Wait for '3s' to stop ttitrace with name'tti_SA_${UE_NUM}_ue_rank3'
#     Wait '10s' for stable
#     run keyword and continue on failure    Check '2' SA UE throughput with rank3
#     run keyword and continue on failure    check TP and bler with ttitrace   400    2    tti_SA_${UE_NUM}_ue_rank3   tti_case7_rank3_AP
#     run keyword and continue on failure    Check counters with Mulayer '6' layer
# 
#     Airphone '${UE_NUM}' SA Stop Data Traffic And Detach UE
#     Stop capture gnb and ap syslog in 'SA_${UE_NUM}_ue' file
# 
# *** Keywords ***
# Modify l1bypass
#     copy_file    ${COMAVALUE}    ${test_log_directory()}/coma.py
#     Import Variables    ${test_log_directory()}/coma.py
#     Modify airphone l1bypass coma value for eight ue
#     ...    ${Hindex17}    ${Vindex5}     ${Hindex17}    ${Vindex5}
#     ...    ${Hindex10}    ${Vindex10}    ${Hindex10}    ${Vindex10}
#     ...    ${Hindex25}    ${Vindex7}    ${Hindex25}    ${Vindex7}
#     ...    ${Hindex17}    ${Vindex7}     ${Hindex17}    ${Vindex7}
#     ...    ${Hindex14}    ${Vindex8}     ${Hindex14}    ${Vindex8}
#     ...    ${Hindex10}    ${Vindex8}    ${Hindex10}    ${Vindex8}
#     ...    ${Hindex2}    ${Vindex8}    ${Hindex2}    ${Vindex8}
#     ...    ${Hindex21}    ${Vindex8}     ${Hindex21}    ${Vindex8}
# 
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
#     check_log_with_au2anlysis    ini_path=${CURDIR}/ini/${ini_file}.ini    log_need_to_check=i
#     ...   save_log_directory=${TEST_LOG_DIRECTORY()}/All/${tti_file}/
# 
# Wait for '${time}' to stop ttitrace with name'${tti_tag}'
#     sleep   ${time}
#     ${pcap_path}    Stop GNB Ttitrace With Streaming Mode
#     Decoder Tttirace From Pcap To Csv    ${pcap_path}      ${test_log_directory()}/All/${tti_tag}/tti
# 
# Modify 8305 Swconfig
# 	Add GNB swconfig    0x340000:3
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
# Check '${UE_NUM}' SA UE throughput with rank3
#     Wait until keyword succeeds    60s    5s    Verify '${UE_NUM}' SA UEs throughput with rank3
# 
# Verify multi NSA UEs throughput
#     : FOR    ${num}    IN RANGE    12    ${UE_NUM}+12
#     \    ${dl_throughput_pcell}    airphone_get_throughput_on_specific_scell    ue_id=${num}    scell_id=8    type=pdsch    tput_type=ave
#     \    ${ul_throughput_pcell}    airphone_get_throughput_on_specific_scell    ue_id=${num}    scell_id=8    type=pusch    tput_type=ave
#     \    should_be_true    ${dl_throughput_pcell}>1000000
# 
# Verify '${UE_NUM}' NSA UEs throughput
#     : FOR    ${num}    IN RANGE    12    ${UE_NUM}+12
#     \    ${dl_throughput_pcell}    airphone_get_throughput_on_specific_scell    ue_id=${num}    scell_id=8    type=pdsch    tput_type=ave
#     \    ${ul_throughput_pcell}    airphone_get_throughput_on_specific_scell    ue_id=${num}    scell_id=8    type=pusch    tput_type=ave
#     \    should_be_true    ${dl_throughput_pcell}>140000
# 
# Verify '${UE_NUM}' SA UEs throughput
#     : FOR    ${num}    IN RANGE    1    ${UE_NUM}+1
#     \    ${dl_throughput_pcell}    airphone_get_throughput_on_specific_scell    ue_id=${num}    scell_id=0    type=pdsch    tput_type=ave
#     \    ${ul_throughput_pcell}    airphone_get_throughput_on_specific_scell    ue_id=${num}    scell_id=0    type=pusch    tput_type=ave
#     \    should_be_true    ${dl_throughput_pcell}>678000
# 
# Verify '${UE_NUM}' SA UEs throughput with rank3
#     : FOR    ${num}    IN RANGE    1    ${UE_NUM}+1
#     \    ${dl_throughput_pcell}    airphone_get_throughput_on_specific_scell    ue_id=${num}    scell_id=0    type=pdsch    tput_type=ave
#     \    ${ul_throughput_pcell}    airphone_get_throughput_on_specific_scell    ue_id=${num}    scell_id=0    type=pusch    tput_type=ave
#     \    should_be_true    ${dl_throughput_pcell}>500000
# 
# Attach '${UE_NUM}' NSA UE and data buffer sent
#     : FOR    ${num}    IN RANGE    12    ${UE_NUM}+12
#     \   airphone_cleanup_egate_console_log
#     \   Airphone Nsa Attach    ${num}    profile_id=None
#     \   Wait '3s' for stabible
#     \   Collect AP egate log    ${EGATE_TAG}_${num}
#     \   run keyword and continue on failure     check_SRS_resource_and_PDSCH_scramblingID   ${EGATE_TAG}_${num}
#     \   NSA send ue '${num}' mutiple trf '5' for each '150M' DL data
#     \   NSA send ue '${num}' mutiple trf '1' for each '15M' UL data
# 
# Attach '${UE_NUM}' SA UE
#     : FOR    ${num}    IN RANGE    1    ${UE_NUM}+1
#     \   airphone_cleanup_egate_console_log
#     \   Log To Console   ${\n}-----register UE ${num} ------
#     \   Airphone SA Attach    ue_id=${num}
#     \   Airphone Set Traffic Type    ue_id=${num}    pdu_id=${num}    type=internal
#     \   Airphone Pdu Session Setup   ue_id=${num}    pdu_id=${num}   nwslice_id=1    gw_id=${num}
#     \   Wait '3s' for stabible
# #    \   run keyword and continue on failure     check_SRS_resource_and_PDSCH_scramblingID_SA   ${EGATE_TAG}_${num}
# 
# SA '${UE_NUM}' UE Data buffer send
#     : FOR    ${num}    IN RANGE    1    ${UE_NUM}+1
#     \   SA send mutiple trf dl data    ${num}    6   150M    ${num}
#     \   SA send mutiple trf ul data    ${num}    2   20M    ${num}
# 
# Airphone NSA Stop Data Traffic And Detach UE
#     : FOR    ${num}    IN RANGE    12    ${UE_NUM}+12
#     \    Airphone NSA Stop Data Traffic   ${num}    BI
#     \    Airphone NSA Detach    ${num}
# 
# Airphone '${UE_NUM}' SA Stop Data Traffic And Detach UE
#     : FOR    ${num}    IN RANGE    1    ${UE_NUM}+1
#     \   airphone_sa_detach    ue_id=${num}    timeout=5
#     \   Wait '4s' for stabible
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
#    airphone_execute_egate_command    bler_testmode_nr profile_id\=1 dl_bler\=100,2,3,4
#    airphone_execute_egate_command    ue_testmode_set_nr id\=1 scell\=0 testmode\=bler profile_id\=1 action\=activate
# 
# Overide 2UE Rank3
#     airphone_execute_egate_command    csi_override_testmode_nr profile_id\=2 cqi\=15 ri\=2
#     airphone_execute_egate_command    ue_testmode_set_nr id\=1 testmode\=csi_override action\=activate profile_id\=2
#     airphone_execute_egate_command    ue_testmode_set_nr id\=2 testmode\=csi_override action\=activate profile_id\=2
# 
# Check counters with Mulayer '${layer_num}' layer
#     run keyword if    ${layer_num}==8     check 8305 counter with MUlayer 8
#     run keyword if    ${layer_num}==6     check 8305 counter with MUlayer 6
# 
# Get 8305 counters
#     ${remaining_time}=    get_counter_file_remaining_time    counter_refresh_period=5min
#     Wait Throughput Timer    ${remaining_time}
#     ${PM_counter_file}=    download_latest_pmcounter    local_path=${TEST_LOG_DIRECTORY()}pmcounter${/}
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
#     set global variable    ${M55308C34011_PRB_DL_MU_MIMO_8LAYER}
#     set global variable    ${M55308C34010_PRB_DL_MU_MIMO_7LAYER}
#     set global variable    ${M55308C34009_PRB_DL_MU_MIMO_6LAYER}
#     set global variable    ${M55308C34008_PRB_DL_MU_MIMO_5LAYER}
#     set global variable    ${M55308C34007_PRB_DL_MU_MIMO_4LAYER}
#     set global variable    ${M55308C34006_PRB_DL_MU_MIMO_3LAYER}
#     set global variable    ${M55308C34005_PRB_DL_MU_MIMO_2LAYER}
#     set global variable    ${M55308C34004_PRB_DL_SU_MIMO_4LAYER}
#     set global variable    ${M55308C34003_PRB_DL_SU_MIMO_3LAYER}
#     set global variable    ${M55308C34002_PRB_DL_SU_MIMO_2LAYER}
#     set global variable    ${M55308C34001_PRB_DL_SU_MIMO_1LAYER}
#     set global variable    ${M55308C34015_PRB_DL_MU_MIMO_4PAIR_UE}
#     set global variable    ${M55308C34014_PRB_DL_MU_MIMO_3PAIR_UE}
#     set global variable    ${M55308C34013_PRB_DL_MU_MIMO_2PAIR_UE}
#     set global variable    ${M55308C34012_PRB_DL_MU_MIMO_NOPAIR_UE}
# 
# check 8305 counter with MUlayer 8
#     Get 8305 counters
#     run keyword and continue on failure    should_be_true    ${M55308C34011_PRB_DL_MU_MIMO_8LAYER}>0
#     run keyword and continue on failure    should_be_true    ${M55308C34010_PRB_DL_MU_MIMO_7LAYER}==0
#     run keyword and continue on failure    should_be_true    ${M55308C34009_PRB_DL_MU_MIMO_6LAYER}==0
#     run keyword and continue on failure    should_be_true    ${M55308C34008_PRB_DL_MU_MIMO_5LAYER}==0
#     run keyword and continue on failure    should_be_true    ${M55308C34007_PRB_DL_MU_MIMO_4LAYER}==0
#     run keyword and continue on failure    should_be_true    ${M55308C34006_PRB_DL_MU_MIMO_3LAYER}==0
#     run keyword and continue on failure    should_be_true    ${M55308C34005_PRB_DL_MU_MIMO_2LAYER}==0
#     run keyword and continue on failure    should_be_true    ${M55308C34004_PRB_DL_SU_MIMO_4LAYER}>=0
#     run keyword and continue on failure    should_be_true    ${M55308C34003_PRB_DL_SU_MIMO_3LAYER}==0
#     run keyword and continue on failure    should_be_true    ${M55308C34002_PRB_DL_SU_MIMO_2LAYER}==0
#     run keyword and continue on failure    should_be_true    ${M55308C34001_PRB_DL_SU_MIMO_1LAYER}>0
#     run keyword and continue on failure    should_be_true    ${M55308C34015_PRB_DL_MU_MIMO_4PAIR_UE}>=0
#     run keyword and continue on failure    should_be_true    ${M55308C34014_PRB_DL_MU_MIMO_3PAIR_UE}==0
#     run keyword and continue on failure    should_be_true    ${M55308C34013_PRB_DL_MU_MIMO_2PAIR_UE}>0
#     run keyword and continue on failure    should_be_true    ${M55308C34012_PRB_DL_MU_MIMO_NOPAIR_UE}>0
# 
# 
# check 8305 counter with MUlayer 6
#     Get 8305 counters
#     run keyword and continue on failure    should_be_true    ${M55308C34011_PRB_DL_MU_MIMO_8LAYER}==0
#     run keyword and continue on failure    should_be_true    ${M55308C34010_PRB_DL_MU_MIMO_7LAYER}==0
#     run keyword and continue on failure    should_be_true    ${M55308C34009_PRB_DL_MU_MIMO_6LAYER}>0
#     run keyword and continue on failure    should_be_true    ${M55308C34008_PRB_DL_MU_MIMO_5LAYER}==0
#     run keyword and continue on failure    should_be_true    ${M55308C34007_PRB_DL_MU_MIMO_4LAYER}==0
#     run keyword and continue on failure    should_be_true    ${M55308C34006_PRB_DL_MU_MIMO_3LAYER}==0
#     run keyword and continue on failure    should_be_true    ${M55308C34005_PRB_DL_MU_MIMO_2LAYER}==0
#     run keyword and continue on failure    should_be_true    ${M55308C34004_PRB_DL_SU_MIMO_4LAYER}==0
#     run keyword and continue on failure    should_be_true    ${M55308C34003_PRB_DL_SU_MIMO_3LAYER}>=0
#     run keyword and continue on failure    should_be_true    ${M55308C34002_PRB_DL_SU_MIMO_2LAYER}==0
#     run keyword and continue on failure    should_be_true    ${M55308C34001_PRB_DL_SU_MIMO_1LAYER}>0
#     run keyword and continue on failure    should_be_true    ${M55308C34015_PRB_DL_MU_MIMO_4PAIR_UE}==0
#     run keyword and continue on failure    should_be_true    ${M55308C34014_PRB_DL_MU_MIMO_3PAIR_UE}==0
#     run keyword and continue on failure    should_be_true    ${M55308C34013_PRB_DL_MU_MIMO_2PAIR_UE}>0
#     run keyword and continue on failure    should_be_true    ${M55308C34012_PRB_DL_MU_MIMO_NOPAIR_UE}>0