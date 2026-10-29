# *** Settings ***
# Test Timeout    60 minutes
# Suite Setup    Common Suite Setup
# Suite Teardown    Common Suite Teardown
# Test Setup    Common Test Setup
# Test Teardown    Common Test Teardown
# Force Tags   owner_pennwang    AP    SBTS23R1
# ...   CLOUD_5G_I_BO_AP_KL_SANSA_L1B_ECPRI_CMWV_TDD
# Resource    ../../resources/KISS/robot/common_resource.robot
# Resource    ../../resources/sg10/internal_resource/internal_resource.robot
# 
# 
# *** Variables ***
# ${GNB_SWCONFIG_NAME}    gnb_swconfig.txt
# ${AP_SWCONFIG_NAME}    ap_swconfig.txt
# ${CONFIG_DIR_PATH}    ${CURDIR}/config
# ${SCFC_NAME}      SCFC_8247_case17.xml
# ${AIRPHONE_NAME}    IPHY_AEQB_1CELL.xml
# @{LOG_NAME_LIST}    gnb_snapshot    sosreport    egatelog
# ${COMAVALUE}    ${CURDIR}/coma/case17.txt
# ${WTS_NAME}    BO_AP_KL_SANSA_L1B_ECPRI_CMWV_TDD_new.cfg
# ${UE_ID}          30
# ${UE_ID2}          31
# ${BIP_TAG}    srs
# ${FILTER}    ((dldata_pdcchsendreq) && !(3gpp.rnti == 65535)) && !(DlData_DciInfo.patternId_item == 101)
# ${FILTER1}    (((dldata_pdschsendreq) && !(3gpp.rnti == 65535))) && !(DlData_PdschGrant.patternId_item == 101)
# @{titles}    DlData_DciInfo.patternId_item
# @{titles1}    DlData_PdschGrant.patternId_item
# 
# *** Test Cases ***
# CB008247_A_b3_case17_OL_4x4_90M_Codebook_SRS_best_beam_determination_twoUE_NSA
#     Check patter and codebook usage is correct
# 
# 
# 
# *** Keywords ***
# Check patter and codebook usage is correct
#     :FOR    ${h}     IN RANGE      22    23
#     \    get value of v    ${h}
# 
# get value of v
#     [Arguments]    ${h}
#     :FOR    ${v}     IN RANGE      12    13
#     \    Set Global Variable    ${h}
#     \    Set Global Variable    ${v}
#     \    Check different v and h match with patter id
# 
# Check different v and h match with patter id
#     Modify l1byptestmodeconfiguration on ap
# #    Reboot gnb and ap via ssh
# #    Start Wts And Wait Bts Until Onair     ${CONFIG_DIR_PATH}/${SW_BRANCH}/WTS/${WTS_NAME}    timeout=1800
#     Prepare gnb onair
#     airphone_cleanup_egate_console_log
#     Start capture gnb and ap syslog in 'after_onair' file
#     Attach two NSA UE
#     NSA send data 2UE
#     Start collect ttitrace
#     Wait for '2s' to stop ttitrace with name'switch'
#     Start collect bip log
#     Wait for '2s' to stop bip log with name'bip_h${h}v${v}'
#     run keyword and continue on failure    Check two nsa UE throughput
#     Airphone NSA Stop Data Traffic And Detach UE
#     Stop egate log and unzip with name'h${h}v${v}'
#     Stop capture gnb and ap syslog in 'after_onair' file
#     run keyword and continue on failure    Check srs usage is codebook in rrc
#     run keyword and continue on failure    Check patter id is correct in ttitrace
#     run keyword and continue on failure    Check patter id is correct in bip
# 
# 
# Modify l1byptestmodeconfiguration on ap
#     copy_file    ${COMAVALUE}    ${test_log_directory()}/coma.py
#     Import Variables    ${test_log_directory()}/coma.py
#     ${h1}    Evaluate    ${h}-18
#     ${v1}    Evaluate    ${v}-4
#     Set Global Variable    ${h1}
#     Set Global Variable    ${v1}
#     ${patter_id1}    Evaluate    1024+29*${v}+${h}
#     ${patter_id2}    Evaluate    1024+29*${v1}+${h1}
#     Set Global Variable    ${patter_id1}
#     Set Global Variable    ${patter_id2}
#     log to console    h${h}v${v}_${patter_id1}
#     log to console    h${h1}v${v1}_${patter_id2}
#     ${extra_modify}    create list
#     ...    text|18|//*[@TestProfile\="Profile-2"]//srsNumCountSwitchProfile
#     ...    text|${Hindex${h}}|//*[@TestProfile\="Profile-1"]//UeId[@ueid\="1"]//NrRxBfCumulSpatialCovMatHPlus45
#     ...    text|${Hindex${h}}|//*[@TestProfile\="Profile-1"]//UeId[@ueid\="1"]//NrRxBfCumulSpatialCovMatHNegative45
#     ...    text|${Vindex${v}}|//*[@TestProfile\="Profile-1"]//UeId[@ueid\="1"]//NrRxBfCumulSpatialCovMatVPlus45
#     ...    text|${Vindex${v}}|//*[@TestProfile\="Profile-1"]//UeId[@ueid\="1"]//NrRxBfCumulSpatialCovMatVNegative45
#     ...    text|${Hindex${h1}}|//*[@TestProfile\="Profile-2"]//UeId[@ueid\="1"]//NrRxBfCumulSpatialCovMatHPlus45
#     ...    text|${Hindex${h1}}|//*[@TestProfile\="Profile-2"]//UeId[@ueid\="1"]//NrRxBfCumulSpatialCovMatHNegative45
#     ...    text|${Vindex${v1}}|//*[@TestProfile\="Profile-2"]//UeId[@ueid\="1"]//NrRxBfCumulSpatialCovMatVPlus45
#     ...    text|${Vindex${v1}} |//*[@TestProfile\="Profile-2"]//UeId[@ueid\="1"]//NrRxBfCumulSpatialCovMatVNegative45
#     Modify airphone l1bypass    ${Hindex${h}}    ${Vindex${v}}    ${Hindex${h1}}    ${Vindex${v1}} 
#    ...       srsNumCountSwitchProfile=18
#     ...    extra_modify=${extra_modify}
# 
# 
# Check srs usage is codebook in rrc
#     check_log_with_au2anlysis    ${CURDIR}/ini/rrc_srs_usage_codebook_NSA.ini    p    
#    ...    save_log_directory=${TEST_LOG_DIRECTORY()}/All/egate_h${h}v${v}
# 
# Check patter id is correct in ttitrace
#     check_log_with_au2anlysis    ${CURDIR}/ini/tti_dl_case15.ini    i    
#    ...    save_log_directory=${TEST_LOG_DIRECTORY()}/All
#     check_log_with_au2anlysis    ${CURDIR}/ini/tti_ul_case15.ini    i    
#    ...    save_log_directory=${TEST_LOG_DIRECTORY()}/All
# 
# Check patter id is correct in bip
#     Convert BIP To CSV    ${TEST_LOG_DIRECTORY()}/All/bip_h${h}v${v}/tcpdump_L2L1_bip_filtering_off.pcap0
#     ...    ${TEST_LOG_DIRECTORY()}/All/bip_h${h}v${v}/bip_pdcch.csv    ${FILTER}    ${titles}
#     Convert BIP To CSV    ${TEST_LOG_DIRECTORY()}/All/bip_h${h}v${v}/tcpdump_L2L1_bip_filtering_off.pcap0
#     ...    ${TEST_LOG_DIRECTORY()}/All/bip_h${h}v${v}/bip_pdsch.csv    ${FILTER1}    ${titles1}
#     Check Log With Au2anlysis    ${CURDIR}/ini/bip_case15_pdcch.ini     i    
#    ...    save_log_directory=${TEST_LOG_DIRECTORY()}/All/bip_h${h}v${v}
#     Check Log With Au2anlysis    ${CURDIR}/ini/bip_case15_pdsch.ini     i    
#    ...    save_log_directory=${TEST_LOG_DIRECTORY()}/All/bip_h${h}v${v}
# 
# Attach two NSA UE
#     : FOR    ${num}    IN RANGE    30    32
#     \   Airphone Nsa Attach    ${num}    profile_id=None
#     \   wait '3s' for stabible
# 
# 
# NSA send data 2UE
#     : FOR    ${num}    IN RANGE    30    32
#     \    run keyword if    ${num}<33   NSA send ue '${num}' mutiple trf '4' for each '150M' DL data
#     \    run keyword if    ${num}<33   NSA send ue '${num}' mutiple trf '2' for each '30M' UL data
# 
# 
# Airphone NSA Stop Data Traffic And Detach UE
#     : FOR    ${num}    IN RANGE    30    32
#     \    Airphone NSA Stop Data Traffic   ${num}    DL
#     \    Airphone NSA Stop Data Traffic   ${num}    UL
#     \    Airphone NSA Detach    ${num}
# 
# Check two nsa UE throughput
#     ${dl_tput1}   ${ul_tput1}    Obtain one nsa ue dl and ul throught    30
#     ${dl_tput2}   ${ul_tput2}    Obtain one nsa ue dl and ul throught    31
#     should be true    ${dl_tput1}+${dl_tput2}>520000
#     should be true    ${ul_tput1}+${ul_tput2}>8000
# 
# Obtain one nsa ue dl and ul throught
#     [Arguments]    ${ue_id}
#     ${dl_tput}    airphone_nsa_get_throughput    ${ue_id}    dl
#     ${ul_tput}    airphone_nsa_get_throughput    ${ue_id}    ul
#     [return]     ${dl_tput}    ${ul_tput}
