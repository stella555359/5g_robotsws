# *** Settings ***
# Suite Setup    Common Suite Setup
# Suite Teardown    Common Suite Teardown
# Test Setup    Common Test Setup
# Test Teardown    Common Test Teardown
# Force Tags    CLOUD_5G_I_BO_AP_KL_SANSA_L1B_ECPRI_CMWV_TDD    owner_l10wang   AP    CRT    SBTS00    RAN_5G_TDD    RAN_5G    SBTS23R1
# Resource    ../../resources/KISS/robot/common_resource.robot
# Resource    ../../resources/sg10/internal_resource/internal_resource.robot
# 
# 
# *** Variables ***
# ${CONFIG_DIR_PATH}    ${CURDIR}/config
# ${SCFC_NAME}     SCFC_8701_case04_config2.xml
# ${AIRPHONE_NAME}    IPHY_AQQL_1ABIL_1CELL.xml
# ${COMAVALUE}    ${CURDIR}/coma/8701_coma_dft.txt
# ${WTS_NAME}    wts_8701_case4.cfg
# @{LOG_NAME_LIST}     egatelog
# @{LOG_NAME_LIST}    gnb_snapshot
# ${UE_NUM}         4
# ${SLICE_ID}     1
# ${EGATE_TAG}      MUmimo
# &{GNBMIRRORINGCONFIGS}    BB_SLOT_2='true'    SYSCOM_MIRRORING='true'   L2HI_MIRRORING='true'   L2RT_MIRRORING='true'   CPRT_MIRRORING='false'
# ...    NUMBER_OF_FILES=30
# @{Rdparameter}    0x420062:1  0x800057:0
# 
# *** Test Cases ***
# CB008701_A_B1_case04_4UEs_rank_4_4_4_4_dlMuMimoRankAdaption_Disabled_1TAS_3codebook
#     Modify 8305 Swconfig
#     Modify l1bypass
#     Prepare gnb onair
#     Execute AP Command before attach
#     Start capture gnb and ap syslog in 'SA_${UE_NUM}_ue' file
#     Attach '${UE_NUM}' SA UE and data buffer sent
#     Wait '15s' for stable
#     Start collect ttitrace
#     wait for '5s' to stop ttitrace with name'SA_${UE_NUM}_ue'
#     Check Srs Resource
#     Check mupair in ttitrace
#     Check SA UE throughput
#     UE send dl bler
#     Airphone SA Stop Data Traffic And Detach UE
#     Check counters
#     Stop capture gnb and ap syslog in 'SA_${UE_NUM}_ue' file
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
# 
# Wait for '${time}' to stop ttitrace with name'${tti_tag}'
#     sleep   ${time}
#     ${pcap_path}    Stop GNB Ttitrace With Streaming Mode
#     Decoder Tttirace From Pcap To Csv    ${pcap_path}      ${test_log_directory()}/All/${tti_tag}/tti
# 
# Check mupair in ttitrace
#     check_log_with_au2anlysis    ini_path=${CURDIR}/ini/tti_dl_mumimo.ini    log_need_to_check=i
#     ...    save_log_directory=${TEST_LOG_DIRECTORY()}/All/SA_${UE_NUM}_ue
# 
# Modify 8305 Swconfig
# 	Add GNB swconfig    0x420062:1  0x800057:0
# 	Add GNB swconfig     0x10040:1
#     Add GNB swconfig     0x10041:1
#     Add GNB swconfig     0x1003F:1
#     Add GNB swconfig     0x1007C:1
#     Add GNB swconfig    0x1002A:1
# 
# Attach NSA 8 UEs
#     : FOR    ${num}    IN RANGE    12    ${UE_NUM}+1
#     \   Airphone Nsa Attach    ${num}    profile_id=None
#     \   Wait '10s' for stable
# 
# UE send dl bler
#     airphone_execute_egate_command    bler_testmode_nr profile_id\=1 dl_bler\=100,2,3,4
#     airphone_execute_egate_command    ue_testmode_set_nr id\=1 scell\=0 testmode\=bler profile_id\=1 action\=activate
#     Start collect ttitrace
#     wait for '5s' to stop ttitrace with name'SA_${UE_NUM}_ue_bler'
# 
# Check SA UE throughput
#     Wait until keyword succeeds    60s    5s    Verify multi SA UEs throughput
# 
# Verify multi SA UEs throughput
#     : FOR    ${num}    IN RANGE    1    ${UE_NUM}+1
#     \    ${dl_throughput_pcell}    airphone_get_throughput_on_specific_scell    ue_id=${num}    scell_id=0    type=pdsch    tput_type=ave
#     \    should_be_true    ${dl_throughput_pcell}>440000
# 
# 
# Airphone SA Stop Data Traffic And Detach UE
#     : FOR    ${num}    IN RANGE    1    ${UE_NUM}+1
#     \    Airphone SA Stop Data Traffic     ${num}     BI    ${num}
#     \    Airphone SA Detach    ue_id=${num}
# 
# 
# Attach '${UE_NUM}' SA UE and data buffer sent
#     : FOR    ${num}    IN RANGE    1    ${UE_NUM}+1
#     \   airphone_cleanup_egate_console_log
#     \   Airphone SA Attach    ue_id=${num}
#     \   Wait '2s' for stabible
#     \   Airphone Set Traffic Type    ue_id=${num}    pdu_id= ${num}    type=internal
#     \   Airphone Pdu Session Setup    ue_id=${num}   pdu_id=${num}   nwslice_id=1   gw_id=${num}
#     \   Wait '3s' for stabible
#     \   Collect AP egate log    ${EGATE_TAG}_${num}
#     \   SA send mutiple trf dl data    ${num}    4    175M   ${num}
#     \   SA send mutiple trf ul data    ${num}    1    20M   ${num}
# 
# 
# Check Srs Resource
#     ${ret}     file match all       ${TEST_LOG_DIRECTORY()}/All/MUmimo_1_egate/egate_console.log         .*crnti: (\\d+)
#     set suite variable     ${ue_rnti}    ${ret[0]}
#     run keyword and continue on failure    check_log_with_au2anlysis  ini_path=${CURDIR}/ini/RRC_AperidicSRS_SA.ini    log_need_to_check=p
#    ...    save_log_directory=${TEST_LOG_DIRECTORY()}/All/MUmimo_1_egate
#     ${ret}     file match all       ${TEST_LOG_DIRECTORY()}/All/MUmimo_2_egate/egate_console.log         .*crnti: (\\d+)
#     set suite variable     ${ue_rnti}    ${ret[0]}
#     run keyword and continue on failure    check_log_with_au2anlysis  ini_path=${CURDIR}/ini/RRC_peridicSRS_SA.ini    log_need_to_check=p
#    ...    save_log_directory=${TEST_LOG_DIRECTORY()}/All/MUmimo_2_egate
# 
# Execute AP Command before attach
#     airphone_cleanup_egate_console_log
#     Airphone Setup X2 Connection
# 
# 
# Check counters
#     ${remaining_time}=    get_counter_file_remaining_time    counter_refresh_period=5min
#     Wait Throughput Timer    ${remaining_time}
#     ${PM_counter_file}=    download_latest_pmcounter    local_path=${TEST_LOG_DIRECTORY()}pmcounter${/}
# 	${M55308C34023_PRB_DL_MU_MIMO_16LAYER}=    get_counter_value_from_counter_file    counter_file=${PM_counter_file}
#     ...    counter_id=M55308C34023    cell_id=1
#     run keyword and continue on failure    should_be_true     ${M55308C34023_PRB_DL_MU_MIMO_16LAYER}>0
