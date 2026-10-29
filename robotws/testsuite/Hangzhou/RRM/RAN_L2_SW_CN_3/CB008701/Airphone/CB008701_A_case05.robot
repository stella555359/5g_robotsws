# *** Settings ***
# Suite Setup    Common Suite Setup
# Suite Teardown    Common Suite Teardown
# Test Setup    Common Test Setup
# Test Teardown    Common Test Teardown
# Force Tags    CLOUD_5G_I_BO_AP_KL_SANSA_L1B_ECPRI_CMWV_TDD    owner_changyli   AP    CRT    SBTS00    RAN_5G_TDD    RAN_5G
# Resource    ../../resources/KISS/robot/common_resource.robot
# Resource    ../../resources/sg10/internal_resource/internal_resource.robot
# 
# 
# *** Variables ***
# ${CONFIG_DIR_PATH}    ${CURDIR}/config
# ${SCFC_NAME}     SCFC_8701_case05_config1.xml
# ${AIRPHONE_NAME}    IPHY_AQQL_2ABIL_1CELL.xml
# #${AIRPHONE_NAME}    IPHY_AQQL_1ABIL_1CELL.xml #config2
# #${AIRPHONE_NAME}    IPHY_AQQL_2ABIL_1CELL.xml #config1
# ${COMAVALUE}    ${CURDIR}/coma/8701_coma_dft.txt
# ${WTS_NAME}    wts_8701_case05.cfg
# ${UE_ID1}          1
# ${PDU_ID1}         1
# ${GW_ID1}          1
# ${SLICE_ID}       1
# ${UE_NUM}         4
# ${EGATE_TAG}      MUmimo
# ${BIP_TAG}    mumumo_bip
# &{GNBMIRRORINGCONFIGS}    BB_SLOT_2='true'    SYSCOM_MIRRORING='true'   L2HI_MIRRORING='true'   L2RT_MIRRORING='true'
# ...    CPRT_MIRRORING='false'    NUMBER_OF_FILES=30
# @{LOG_NAME_LIST}    gnb_snapshot    sosreport    egatelog
# @{Rdparameter}    0x420062:1  0x800057:0
# 
# *** Test Cases ***
# CB008701_A_B1_case05_4UEs_rank_4_4_4_4_dlMuMimoRankAdaption_Disabled_3TAS_1codebook
#     Modify 8305 Swconfig
#     Modify l1bypass
# #    Active GNB L2 feature debug traces
#     Prepare gnb onair
#     Execute AP Command before attach
# 
#     Start capture gnb and ap syslog in 'after_onair' file
#     Attach '${UE_NUM}' NSA UE and data buffer sent
#     Wait '15s' for stable
#     Start collect bip log
#     Wait for '1s' to stop bip log with name'${BIP_TAG}'
#     Start collect ttitrace
#     Wait for '3s' to stop ttitrace with name'NSA_${UE_NUM}_ue'
#     run keyword and continue on failure    check TP and bler with ttitrace   120    2    NSA_${UE_NUM}_ue
#     ...    8701_case05_ttitrace
#     run keyword and continue on failure    Check SRS resource and PDSCH scramblingID    MUmimo_11
#     run keyword and continue on failure    Check SRS resource and PDSCH scramblingID    MUmimo_12
#     run keyword and continue on failure    Check SRS resource and PDSCH scramblingID    MUmimo_13
#     run keyword and continue on failure    Check SRS resource codebook and PDSCH scramblingID   MUmimo_14
#     run keyword and continue on failure    Check NSA UE throughput
#     Check counters
#     Airphone NSA Stop Data Traffic And Detach UE
#     Stop capture gnb and ap syslog in 'after_onair' file
# 
# 
# *** Keywords ***
# Modify l1bypass
#     copy_file    ${COMAVALUE}    ${test_log_directory()}/coma.py
#     Import Variables    ${test_log_directory()}/coma.py
#     Modify airphone l1bypass coma value for eight ue
#     ...    ${Hindex12}    ${Vindex8}    ${Hindex13}    ${Vindex7}
#     ...    ${Hindex6}    ${Vindex4}    ${Hindex10}    ${Vindex8}
#     ...    ${Hindex23}    ${Vindex9}    ${Hindex6}    ${Vindex7}
#     ...    ${Hindex16}    ${Vindex7}    ${Hindex2}    ${Vindex8}
#     ...    ${Hindex12}    ${Vindex8}    ${Hindex25}    ${Vindex7}
#     ...    ${Hindex6}    ${Vindex4}     ${Hindex21}    ${Vindex8}
#     ...    ${Hindex23}    ${Vindex9}     ${Hindex17}    ${Vindex7}
#     ...    ${Hindex16}    ${Vindex7}     ${Hindex14}    ${Vindex8}
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
# #    \    should be true  ${result}>${throughput}
#     check_log_with_au2anlysis    ini_path=${CURDIR}/ini/${ini_file}.ini    log_need_to_check=i
#     ...   save_log_directory=${TEST_LOG_DIRECTORY()}/All/${tti_file}/
# 
# Wait for '${time}' to stop ttitrace with name'${tti_tag}'
#     sleep   ${time}
#     ${pcap_path}    Stop GNB Ttitrace With Streaming Mode
#     Decoder Tttirace From Pcap To Csv    ${pcap_path}      ${test_log_directory()}/All/${tti_tag}/tti
# 
# Modify 8305 Swconfig
# 	Add GNB swconfig    0x420062:1  0x800057:0
# 	Add GNB swconfig     0x10040:1
#     Add GNB swconfig     0x10041:1
#     Add GNB swconfig     0x1003F:1
#     Add GNB swconfig     0x1007C:1
#     Modify GNB swconfig    0x1002A:1
# 
# Check SRS resource and PDSCH scramblingID
#     [Arguments]    ${EGATE_TAG}
#     check_log_with_au2anlysis    ${CURDIR}/ini/check_SRS_resource_and_PDSCH_scramblingID_8701_case02.ini    p
#     ...   save_log_directory=${TEST_LOG_DIRECTORY()}/All/${EGATE_TAG}_egate
# 
# Check SRS resource codebook and PDSCH scramblingID
#     [Arguments]    ${EGATE_TAG}
#     check_log_with_au2anlysis    ${CURDIR}/ini/check_SRS_resource_and_PDSCH_scramblingID_8701_case05.ini    p
#     ...   save_log_directory=${TEST_LOG_DIRECTORY()}/All/${EGATE_TAG}_egate
# 
# Check counters
#     ${remaining_time}=    get_counter_file_remaining_time    counter_refresh_period=5min
#     Wait Throughput Timer    ${remaining_time}
#     ${PM_counter_file}=    download_latest_pmcounter    local_path=${TEST_LOG_DIRECTORY()}pmcounter${/}
# 	${M55308C34023_PRB_DL_MU_MIMO_16LAYER}=    get_counter_value_from_counter_file    counter_file=${PM_counter_file}
#     ...    counter_id=M55308C34023    cell_id=1
#     ${M55308C34015_PRB_DL_MU_MIMO_4PAIR_UE}=    get_counter_value_from_counter_file    counter_file=${PM_counter_file}
#     ...    counter_id=M55308C34015   cell_id=1
#     log to console     ${M55308C34023_PRB_DL_MU_MIMO_16LAYER}
#     log to console     ${M55308C34015_PRB_DL_MU_MIMO_4PAIR_UE}
#     should_be_true    ${M55308C34023_PRB_DL_MU_MIMO_16LAYER}>0
#     should_be_true    ${M55308C34015_PRB_DL_MU_MIMO_4PAIR_UE}>0
# 
# Attach NSA 8 UEs
#     : FOR    ${num}    IN RANGE    12    ${UE_NUM}+1
#     \   Airphone Nsa Attach    ${num}    profile_id=None
#     \   Wait '10s' for stable
# 
# 
# NSA send data 8 UEs
#     : FOR    ${num}    IN RANGE    11    ${UE_NUM}+1
#     \   NSA send ue '${num}' mutiple trf '1' for each '150M' DL data
#     \   NSA send ue '${num}' mutiple trf '2' for each '150M' DL data
#     \   NSA send ue '${num}' mutiple trf '1' for each '30M' UL data
# 
# Check NSA UE throughput
#     Wait until keyword succeeds    60s    5s    Verify multi NSA UEs throughput
# 
# 
# Verify multi NSA UEs throughput
#     : FOR    ${num}    IN RANGE    11    ${UE_NUM}+11
#     \    ${dl_throughput_pcell}    airphone_get_throughput_on_specific_scell    ue_id=${num}    scell_id=8
#     \    ...    type=pdsch    tput_type=ave
#     \    should_be_true    ${dl_throughput_pcell}>20000
# 
# 
# Attach '${UE_NUM}' NSA UE and data buffer sent
#     : FOR    ${num}    IN RANGE    11    ${UE_NUM}+11
#     \   airphone_cleanup_egate_console_log
#     \   Airphone Nsa Attach    ${num}    profile_id=None
#     \   Wait '3s' for stabible
#     \   NSA send ue '${num}' mutiple trf '2' for each '175M' DL data
#     \   NSA send ue '${num}' mutiple trf '1' for each '5M' UL data
#     \   Collect AP egate log    ${EGATE_TAG}_${num}
# 
# Airphone NSA Stop Data Traffic And Detach UE
#     : FOR    ${num}    IN RANGE    11    ${UE_NUM}+11
#     \    Airphone NSA Stop Data Traffic   ${num}    DL
#     \    Airphone NSA Stop Data Traffic   ${num}    UL
#     \    Airphone NSA Detach    ${num}
# 
# Execute AP Command before attach
#     airphone_cleanup_egate_console_log
#     Airphone Setup X2 Connection
# 
# 
