# *** Settings ***
# Suite Setup    Common Suite Setup
# Suite Teardown    Common Suite Teardown
# Test Setup    Common Test Setup
# Test Teardown    Common Test Teardown
# Force Tags    CLOUD_5G_I_BOO_AP_KLLL_SANSA_L1B_ECPRI_CMWV_TDD    owner_l10wang   AP    CRT    SBTS00    SBTS23R1
# ...    RAN_5G_TDD    RAN_5G
# Resource    ../../resources/KISS/robot/common_resource.robot
# Resource    ../../resources/sg10/internal_resource/internal_resource.robot
# 
# 
# *** Variables ***
# ${CONFIG_DIR_PATH}    ${CURDIR}/config
# ${SCFC_NAME}     SCFC_8701_90M_case7.xml
# ${AIRPHONE_NAME}    IPHY_AQQL_2ABIL_1CELL.xml
# ${COMAVALUE}    ${CURDIR}/coma/8701_coma_dft.txt
# ${WTS_NAME}    wts_8701_case7.cfg
# @{LOG_NAME_LIST}     egatelog
# @{LOG_NAME_LIST}    gnb_snapshot
# ${UE_NUM_SA}         5
# ${UE_NUM_NSA}         3
# ${EGATE_TAG}      MUmimo
# &{GNBMIRRORINGCONFIG}    BB_SLOT_2='true'    SYSCOM_MIRRORING='true'   L2HI_MIRRORING='true'   L2RT_MIRRORING='true'
# ...    CPRT_MIRRORING='false'    NUMBER_OF_FILES=30
# @{Rdparameter}    0x420062:1  0x800057:0
# 
# *** Test Cases ***
# CB008701_A_B301_case07_2SU_withGBR_6MU_with_nonGBR_and_dlMuMimoRankAdaption_Disabled_tapering_SA_NSA
#     Modify 8305 Swconfig
#     Modify l1bypass
#     Prepare gnb onair
#     Execute AP Command before attach
#     Start capture gnb and ap syslog in 'SA_NSA_ue' file
#     Attach '${UE_NUM_SA}' SA UE and data buffer sent
#     Send GBR and Non GBR data to SA UE
#     Attach '${UE_NUM_NSA}' NSA UE and data buffer sent
#     Wait '20s' for stable
#     Start collect ttitrace
#     Wait for '3s' to stop ttitrace with name'SA_NSA_ue'
#     Check mupair in ttitrace
#     Check SA UE throughput
#     Check NSA UE throughput
# 	Airphone SA Stop Data Traffic And Detach UE
#     Airphone NSA Stop Data Traffic And Detach UE
#     Stop capture gnb and ap syslog in 'SA_NSA_ue' file
# 
# *** Keywords ***
# Check UE '${num}' rrc log aperidic
#     Airphone_collect_egate_log_files    ${TEST_LOG_DIRECTORY()}/All/egate_UE_${num}    unzip=TRUE
#     ${ret}     file match all       ${TEST_LOG_DIRECTORY()}/All/egate_UE_${num}/egate_console.log    .*crnti: (\\d+)
#     set suite variable     ${ue_rnti}    ${ret[0]}
#     check_log_with_au2anlysis  ini_path=${CURDIR}/ini/RRC_AperidicSRS_SA.ini    log_need_to_check=p
#    ...    save_log_directory=${TEST_LOG_DIRECTORY()}/All/egate_UE_${num}
#    
# Check UE '${num}' rrc log AperidicSRS
#     Airphone_collect_egate_log_files    ${TEST_LOG_DIRECTORY()}/All/egate_UE_${num}    unzip=TRUE
#     check_log_with_au2anlysis  ini_path=${CURDIR}/ini/check_SRS_resource_and_PDSCH_scramblingID_8701_case02.ini
#     ...    log_need_to_check=p    save_log_directory=${TEST_LOG_DIRECTORY()}/All/egate_UE_${num}
# 
# Check mupair in ttitrace
#     check_log_with_au2anlysis    ini_path=${CURDIR}/ini/tti_dl_mumimo_case7.ini    log_need_to_check=i
#     ...    save_log_directory=${TEST_LOG_DIRECTORY()}/All/SA_NSA_ue
# Modify l1bypass
#     copy_file    ${COMAVALUE}    ${test_log_directory()}/coma.py
#     Import Variables    ${test_log_directory()}/coma.py
#     Modify airphone l1bypass coma value for eight ue
#     ...    ${Hindex13}    ${Vindex7}    ${Hindex13}    ${Vindex7}
#     ...    ${Hindex10}    ${Vindex8}    ${Hindex10}    ${Vindex8}
#     ...    ${Hindex6}    ${Vindex7}    ${Hindex6}    ${Vindex7}
#     ...    ${Hindex2}    ${Vindex8}    ${Hindex2}    ${Vindex8}
#     ...    ${Hindex25}    ${Vindex7}    ${Hindex25}    ${Vindex7}
#     ...    ${Hindex21}    ${Vindex8}     ${Hindex21}    ${Vindex8}
#     ...    ${Hindex17}    ${Vindex7}     ${Hindex17}    ${Vindex7}
#     ...    ${Hindex14}    ${Vindex8}     ${Hindex14}    ${Vindex8}
# 
# 
# Wait for '${time}' to stop ttitrace with name'${tti_tag}'
#     sleep   ${time}
#     ${pcap_path}    Stop GNB Ttitrace With Streaming Mode
#     Decoder Tttirace From Pcap To Csv    ${pcap_path}      ${test_log_directory()}/All/${tti_tag}/tti
# 
# Modify 8305 Swconfig
# 	Add GNB swconfig    0x420062:1  0x800057:0
# 
# Attach NSA 8 UEs
#     : FOR    ${num}    IN RANGE    11    ${UE_NUM}+1
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
#     : FOR    ${num}    IN RANGE    12    12+3
#     \    ${dl_throughput_pcell}    airphone_get_throughput_on_specific_scell    ue_id=${num}    scell_id=8    type=pdsch    tput_type=ave
#     \    should_be_true    ${dl_throughput_pcell}>330000
# 
# 
# Check SA UE throughput
#     Wait until keyword succeeds    60s    5s    Verify multi SA UEs throughput
# 
# Verify multi SA UEs throughput
#     : FOR    ${num}    IN RANGE    1    3+1
#     \    ${dl_throughput_pcell}    airphone_get_throughput_on_specific_scell    ue_id=${num}    scell_id=0    type=pdsch    tput_type=ave
#     \    should_be_true    ${dl_throughput_pcell}>450000
# 
# 
# Attach '${UE_NUM_NSA}' NSA UE and data buffer sent
#     : FOR    ${num}    IN RANGE    12    12+3
#     \   airphone_cleanup_egate_console_log
#     \   Airphone Nsa Attach    ${num}    profile_id=None
#     \   UE '${num}' send RANK2
#     \   Wait '3s' for stabible
#     \   Collect AP egate log    ${EGATE_TAG}_${num}
#  #   \   Check UE '${num}' rrc log AperidicSRS
#     \   NSA send ue '${num}' mutiple trf '3' for each '175M' DL data
# 
# 
# 
# Airphone NSA Stop Data Traffic And Detach UE
#     : FOR    ${num}    IN RANGE    11    12+1
#     \    Airphone NSA Stop Data Traffic   ${num}    DL
#     \    Airphone NSA Stop Data Traffic   ${num}    UL
#     \    Airphone NSA Detach    ${num}
# 
# Airphone SA Stop Data Traffic And Detach UE
#     : FOR    ${num}    IN RANGE    1    ${UE_NUM_SA}+1
#     \    Airphone SA Stop Data Traffic     ${num}     BI    ${num}
#     \    Airphone SA Detach    ue_id=${num}
# 
# 
# Attach '${UE_NUM_SA}' SA UE and data buffer sent
#     : FOR    ${num}    IN RANGE    1    ${UE_NUM_SA}+1
#     \   airphone_cleanup_egate_console_log
#     \   Airphone SA Attach    ue_id=${num}
#     \   Wait '2s' for stabible
#     \   Airphone Set Traffic Type    ue_id=${num}    pdu_id= ${num}    type=internal
#     \   Airphone Pdu Session Setup    ue_id=${num}   pdu_id=${num}   nwslice_id=1   gw_id=${num}
# 	\   UE '${num}' send RANK2
#     \   Wait '3s' for stabible
# #    \   Check UE '${num}' rrc log aperidic
# 
# Send GBR and Non GBR data to SA UE
#     : FOR    ${num}    IN RANGE    1    3+1
#     \    SA send mutiple trf dl data    ${num}    4   175M   ${num}
#     : FOR    ${num}    IN RANGE    4    4+2
#     \    airphone_execute_egate_command    ue_pdu_session_modify ue\=${num} pdu\=${num} qosflows_to_add\=2 by\=amf
#     \    Wait '5s' for stabible
#     \    airphone_execute_egate_command    ue_pdu_session_modify ue\=${num} pdu\=${num} qosflows_to_add\=3 by\=amf
#     \    Wait '5s' for stabible
#     \    airphone_execute_egate_command    trf_data_start ue\=${num} pdu\=${num} qfi\=3 trf_id\=1 mbps\=5 dir\=dl
#     \    Wait '5s' for stabible
# 
# Execute AP Command before attach
#     airphone_cleanup_egate_console_log
#     Airphone Setup X2 Connection
# 
# 
# UE '${ue_id}' send RANK2
#     airphone_execute_egate_command    csi_override_testmode_nr profile_id\=1 cqi\=15 cqi_mode\=fixed ri\=1 ri_mode\=fixed
#     airphone_execute_egate_command    ue_testmode_set_nr id\=${ue_id} testmode\=csi_override action\=activate profile_id\=1 scell\=0
# 
