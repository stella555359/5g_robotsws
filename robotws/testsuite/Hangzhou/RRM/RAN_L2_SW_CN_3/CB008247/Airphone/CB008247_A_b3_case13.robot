# *** Settings ***
# Test Timeout    60 minutes
# Suite Setup    Common Suite Setup
# Suite Teardown    Common Suite Teardown
# Test Setup    Common Test Setup
# Test Teardown    Common Test Teardown
# Force Tags    owner_pennwang    AP    CRT    SBTS00    RAN_5G_TDD    RAN_5G    SBTS22R4    SBTS23R1
# ...   CLOUD_5G_I_BO_AP_KL_SANSA_L1B_ECPRI_CMWV_TDD
# Resource    ../../resources/KISS/robot/common_resource.robot
# Resource    ../../resources/sg10/internal_resource/internal_resource.robot
# 
# 
# *** Variables ***
# ${CONFIG_DIR_PATH}    ${CURDIR}/config
# ${SCFC_NAME}      SCFC_8247_case13.xml
# ${AIRPHONE_NAME}    IPHY_AEQB_1CELL.xml
# @{LOG_NAME_LIST}    gnb_snapshot    sosreport    egatelog
# ${COMAVALUE}    ${CURDIR}/coma/case15.txt
# ${WTS_NAME}    BO_AP_KL_SANSA_L1B_ECPRI_CMWV_TDD.cfg
# ${UE_ID}          1
# ${UE_ID2}          2
# ${BIP_TAG}    srs
# ${FILTER}    ((dldata_pdcchsendreq) && !(3gpp.rnti == 65535)) && !(DlData_DciInfo.patternId_item == 101)
# ${FILTER1}    (((dldata_pdschsendreq) && !(3gpp.rnti == 65535))) && !(DlData_PdschGrant.patternId_item == 101)
# @{titles}    DlData_DciInfo.patternId_item
# @{titles1}    DlData_PdschGrant.patternId_item
# @{titles}   DlData_DciInfo.patternId_item    DlData_DciInfo.patternId_item
# 
# *** Test Cases ***
# CB008247_A_b3_case13_OL_4x4_90M_best_beam_determination_oneue_Codebook_SRS_oneue_TAS_SRS_SA
#     Modify l1bypass
#     Modify 8247 Swconfig
#     Prepare gnb onair
#     airphone_cleanup_egate_console_log
#     Start capture gnb and ap syslog in 'after_onair' file
#     Start collect bip log
#     Start collect ttitrace
#     Attach SA ue to 5g cell    No_tas_SRS_Ports_PerResource4    ${UE_ID}
#     Attach SA ue to 5g cell    t4r4_n4    ${UE_ID2}    PDU_ID=2    GW_ID=2
#     SA send dl and ul data    ${UE_ID}    number=6    dl_data=175M    ul_data=20M
#     SA send dl and ul data    ${UE_ID2}    number=7    dl_data=175M    ul_data=20M    pdu_id=2
#     Wait for '0s' to stop ttitrace with name'switch'
#     Wait for '0s' to stop bip log with name'bip'
#     run keyword and continue on failure    Check ue tput is correct
#     Detach '2' UE
#     Stop egate log and unzip with name'egate'
#     run keyword and continue on failure    Stop capture gnb and ap syslog in 'after_onair' file
#     run keyword and continue on failure    Check srs usage in rrc
#     run keyword and continue on failure    Check patter id is correct in ttitrace
#     run keyword and continue on failure    Check patter id is correct in bip
# 
# 
# 
# *** Keywords ***
# Modify l1bypass
#     copy_file    ${COMAVALUE}    ${test_log_directory()}/coma.py
#     Import Variables    ${test_log_directory()}/coma.py
#     ${extra_modify}    create list
#     ...    text|16|//ComaMultiplier
#     Modify airphone l1bypass coma value for eight ue
#     ...    ${Hindex1}    ${Vindex2}    ${Hindex3}    ${Vindex4}
#     ...    ${Hindex1}    ${Vindex2}    ${Hindex3}    ${Vindex4}
#     ...    ${Hindex1}    ${Vindex2}    ${Hindex3}    ${Vindex4}
#     ...    ${Hindex1}    ${Vindex2}    ${Hindex3}    ${Vindex4}
#     ...    ${Hindex9}    ${Vindex8}    ${Hindex24}    ${Vindex9}
#     ...    ${Hindex8}    ${Vindex3}    ${Hindex0}    ${Vindex0}
#     ...    ${Hindex17}    ${Vindex6}    ${Hindex0}    ${Vindex0}
#     ...    ${Hindex24}    ${Vindex9}    ${Hindex8}    ${Vindex0}
#     ...    srsNumCountSwitchProfile1=18
#     ...    extra_modify=${extra_modify}
#     ${patter_id1}    Evaluate    1024+27*2+1
#     ${patter_id2}    Evaluate    1024+27*4+3
#     Set Global Variable    ${patter_id1}
#     Set Global Variable    ${patter_id2}
#     Set test Variable    ${h}    1
#     Set test Variable    ${v}    2
#     Set test Variable    ${h1}    3
#     Set test Variable    ${v1}    4
#     log to console    h1v2_${patter_id1}
#     log to console    h3v4_${patter_id2}
# 
# Check srs usage in rrc
#     check_log_with_au2anlysis    ${CURDIR}/ini/rrc_srs_usage_case13.ini    p    save_log_directory=${TEST_LOG_DIRECTORY()}/All/egate_egate
# 
# Check patter id is correct in ttitrace
#     ${path}    List Files In Directory    ${TEST_LOG_DIRECTORY()}/All    switch_dl.*csv
#     ${path_tti}    set variable    ${path}[0]
#     check_log_with_au2anlysis    ${CURDIR}/ini/tti_dl_case15.ini    i    save_log_directory=${TEST_LOG_DIRECTORY()}/All
#     check_log_with_au2anlysis    ${CURDIR}/ini/tti_ul_case15.ini    i    save_log_directory=${TEST_LOG_DIRECTORY()}/All
# 
# Check patter id is correct in bip
#     Convert BIP To CSV    ${TEST_LOG_DIRECTORY()}/All/bip/tcpdump_L2L1_bip_filtering_off.pcap0
#     ...    ${TEST_LOG_DIRECTORY()}/All/bip/bip_pdcch.csv    ${FILTER}    ${titles}
#     Convert BIP To CSV    ${TEST_LOG_DIRECTORY()}/All/bip/tcpdump_L2L1_bip_filtering_off.pcap0
#     ...    ${TEST_LOG_DIRECTORY()}/All/bip/bip_pdsch.csv    ${FILTER1}    ${titles1}
#     Check Log With Au2anlysis    ${CURDIR}/ini/bip_case15_pdcch.ini     i    save_log_directory=${TEST_LOG_DIRECTORY()}/All/bip
#     Check Log With Au2anlysis    ${CURDIR}/ini/bip_case15_pdsch.ini     i    save_log_directory=${TEST_LOG_DIRECTORY()}/All/bip
# 
# Check ue tput is correct
#     ${dl_tput1}    ${ul_tput1}    Obtain one sa ue dl and ul throught    ${UE_ID}
#     ${dl_tput2}    ${ul_tput2}    Obtain one sa ue dl and ul throught    ${UE_ID2}    pdu_id=2
#     should be true    ${dl_tput1}>340000
#     should be true    ${dl_tput2}>340000
#     should be true    ${ul_tput1}+${ul_tput2}>16000
