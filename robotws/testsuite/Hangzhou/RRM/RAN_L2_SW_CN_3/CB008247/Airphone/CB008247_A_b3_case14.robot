# *** Settings ***
# Test Timeout    60 minutes
# Suite Setup    Common Suite Setup
# Suite Teardown    Common Suite Teardown
# Test Setup    Common Test Setup
# Test Teardown    Common Test Teardown
# Force Tags    owner_pennwang    AP    SBTS00    RAN_5G_TDD    RAN_5G    SBTS23R1
# Resource    ../../resources/KISS/robot/common_resource.robot
# Resource    ../../resources/sg10/internal_resource/internal_resource.robot
# 
# 
# *** Variables ***
# ${CONFIG_DIR_PATH}    ${CURDIR}/config
# ${SCFC_NAME}      SCFC_8247_case15.xml
# ${AIRPHONE_NAME}    IPHY_AEQB_1CELL.xml
# @{LOG_NAME_LIST}    gnb_snapshot    sosreport    egatelog
# ${COMAVALUE}    ${CURDIR}/coma/case15.txt
# ${WTS_NAME}    BO_AP_KL_SANSA_L1B_ECPRI_CMWV_TDD.cfg
# ${BIP_TAG}    srs
# ${FILTER}    ((dldata_pdcchsendreq) && !(3gpp.rnti == 65535)) && !(DlData_DciInfo.patternId_item == 101)
# ${FILTER1}    (((dldata_pdschsendreq) && !(3gpp.rnti == 65535))) && !(DlData_PdschGrant.patternId_item == 101)
# @{titles}    DlData_DciInfo.patternId_item
# @{titles1}    DlData_PdschGrant.patternId_item
# 
# 
# *** Test Cases ***
# CB008247_A_b3_case14_CL_4x4_90M_Codebook_SRS_best_beam_determination_for_CSI_RS_PDSCH_PDCCH_SA
#     Check patter and codebook usage is correct
# 
# 
# 
# *** Keywords ***
# Check patter and codebook usage is correct
#     :FOR    ${h}     IN RANGE      1    2
#     \    get value of v    ${h}
# 
# get value of v
#     [Arguments]    ${h}
#     :FOR    ${v}     IN RANGE      1    2
#     \    Set Global Variable    ${h}
#     \    Set Global Variable    ${v}
#     \    Check different v and h match with patter id
# 
# Check different v and h match with patter id
#     Modify l1byptestmodeconfiguration on ap
#     Modify 8247 Swconfig
# #    Reboot gnb and ap via ssh
# #    Start Wts And Wait Bts Until Onair     ${CONFIG_DIR_PATH}/${SW_BRANCH}/WTS/${WTS_NAME}    timeout=1800
#     Prepare gnb onair
#     airphone_cleanup_egate_console_log
#     Start capture gnb and ap syslog in 'after_onair' file
#     Start collect bip log
#     :FOR    ${id}     IN RANGE      1    11
#     \    Attach SA ue to 5g cell    No_tas_SRS_Ports_PerResource4    ${id}    PDU_ID=${id}    GW_ID=${id}
#     \    Wait '2s' for stabible
#     :FOR    ${id}     IN RANGE      1    11
#     \    Wait '2s' for stabible
#     \    SA send dl and ul data    ${id}    number=1    dl_data=100M    ul_data=5M    pdu_id=${id}
#     Wait for '0s' to stop bip log with name'bip_h${h}v${v}'
#     Detach '10' UE
#     Stop egate log and unzip with name'h${h}v${v}'
#     Stop capture gnb and ap syslog in 'after_onair' file
#     run keyword and continue on failure    Check srs usage is codebook in rrc
# #    run keyword and continue on failure    Check patter id is correct in bip
# 
# 
# Modify l1byptestmodeconfiguration on ap
#     copy_file    ${COMAVALUE}    ${test_log_directory()}/coma.py
#     Import Variables    ${test_log_directory()}/coma.py
#     ${h1}    Evaluate    ${h}+23
#     ${v1}    Evaluate    ${v}+12
#     Set Global Variable    ${h1}
#     Set Global Variable    ${v1}
#     ${patter_id1}    Evaluate    1024+29*${v}+${h}
#     ${patter_id2}    Evaluate    1024+29*${v1}+${h1}
#     Set Global Variable    ${patter_id1}
#     Set Global Variable    ${patter_id2}
#     log to console    h${h}v${v}_${patter_id1}
#     log to console    h${h1}v${v1}_${patter_id2}
#     ${extra_modify}    create list
# #    ...    text|15|//*[@TestProfile\="Profile-2"]//srsNumCountSwitchProfile
#     ...    text|${Hindex${h}}|//*[@TestProfile\="Profile-1"]//UeId[@ueid\="1"]//NrRxBfCumulSpatialCovMatHPlus45
#     ...    text|${Hindex${h}}|//*[@TestProfile\="Profile-1"]//UeId[@ueid\="1"]//NrRxBfCumulSpatialCovMatHNegative45
#     ...    text|${Vindex${v}}|//*[@TestProfile\="Profile-1"]//UeId[@ueid\="1"]//NrRxBfCumulSpatialCovMatVPlus45
#     ...    text|${Vindex${v}}|//*[@TestProfile\="Profile-1"]//UeId[@ueid\="1"]//NrRxBfCumulSpatialCovMatVNegative45
#     ...    text|${Hindex${h1}}|//*[@TestProfile\="Profile-2"]//UeId[@ueid\="1"]//NrRxBfCumulSpatialCovMatHPlus45
#     ...    text|${Hindex${h1}}|//*[@TestProfile\="Profile-2"]//UeId[@ueid\="1"]//NrRxBfCumulSpatialCovMatHNegative45
#     ...    text|${Vindex${v1}}|//*[@TestProfile\="Profile-2"]//UeId[@ueid\="1"]//NrRxBfCumulSpatialCovMatVPlus45
#     ...    text|${Vindex${v1}} |//*[@TestProfile\="Profile-2"]//UeId[@ueid\="1"]//NrRxBfCumulSpatialCovMatVNegative45
#     ...    text|${Hindex${h}}|//*[@TestProfile\="Profile-1"]//UeId[@ueid\="2"]//NrRxBfCumulSpatialCovMatHPlus45
#     ...    text|${Hindex${h}}|//*[@TestProfile\="Profile-1"]//UeId[@ueid\="2"]//NrRxBfCumulSpatialCovMatHNegative45
#     ...    text|${Vindex${v}}|//*[@TestProfile\="Profile-1"]//UeId[@ueid\="2"]//NrRxBfCumulSpatialCovMatVPlus45
#     ...    text|${Vindex${v}}|//*[@TestProfile\="Profile-1"]//UeId[@ueid\="2"]//NrRxBfCumulSpatialCovMatVNegative45
#     ...    text|${Hindex${h1}}|//*[@TestProfile\="Profile-2"]//UeId[@ueid\="2"]//NrRxBfCumulSpatialCovMatHPlus45
#     ...    text|${Hindex${h1}}|//*[@TestProfile\="Profile-2"]//UeId[@ueid\="2"]//NrRxBfCumulSpatialCovMatHNegative45
#     ...    text|${Vindex${v1}}|//*[@TestProfile\="Profile-2"]//UeId[@ueid\="2"]//NrRxBfCumulSpatialCovMatVPlus45
#     ...    text|${Vindex${v1}} |//*[@TestProfile\="Profile-2"]//UeId[@ueid\="2"]//NrRxBfCumulSpatialCovMatVNegative45
#     ...    text|${Hindex${h}}|//*[@TestProfile\="Profile-1"]//UeId[@ueid\="3"]//NrRxBfCumulSpatialCovMatHPlus45
#     ...    text|${Hindex${h}}|//*[@TestProfile\="Profile-1"]//UeId[@ueid\="3"]//NrRxBfCumulSpatialCovMatHNegative45
#     ...    text|${Vindex${v}}|//*[@TestProfile\="Profile-1"]//UeId[@ueid\="3"]//NrRxBfCumulSpatialCovMatVPlus45
#     ...    text|${Vindex${v}}|//*[@TestProfile\="Profile-1"]//UeId[@ueid\="3"]//NrRxBfCumulSpatialCovMatVNegative45
#     ...    text|${Hindex${h1}}|//*[@TestProfile\="Profile-2"]//UeId[@ueid\="3"]//NrRxBfCumulSpatialCovMatHPlus45
#     ...    text|${Hindex${h1}}|//*[@TestProfile\="Profile-2"]//UeId[@ueid\="3"]//NrRxBfCumulSpatialCovMatHNegative45
#     ...    text|${Vindex${v1}}|//*[@TestProfile\="Profile-2"]//UeId[@ueid\="3"]//NrRxBfCumulSpatialCovMatVPlus45
#     ...    text|${Vindex${v1}} |//*[@TestProfile\="Profile-2"]//UeId[@ueid\="3"]//NrRxBfCumulSpatialCovMatVNegative45
#     Modify airphone l1bypass    ${Hindex${h}}    ${Vindex${v}}    ${Hindex${h1}}    ${Vindex${v1}}    srsNumCountSwitchProfile=15
#     ...    extra_modify=${extra_modify}
# 
# 
# Check srs usage is codebook in rrc
#     check_log_with_au2anlysis    ${CURDIR}/ini/rrc_srs_usage_codebook.ini    p    save_log_directory=${TEST_LOG_DIRECTORY()}/All/egate_h${h}v${v}
# 
# 
# Check patter id is correct in bip
#     Convert BIP To CSV    ${TEST_LOG_DIRECTORY()}/All/bip_h${h}v${v}/tcpdump_L2L1_bip_filtering_off.pcap0
#     ...    ${TEST_LOG_DIRECTORY()}/All/bip_h${h}v${v}/bip_pdcch.csv    ${FILTER}    ${titles}
#     Convert BIP To CSV    ${TEST_LOG_DIRECTORY()}/All/bip_h${h}v${v}/tcpdump_L2L1_bip_filtering_off.pcap0
#     ...    ${TEST_LOG_DIRECTORY()}/All/bip_h${h}v${v}/bip_pdsch.csv    ${FILTER1}    ${titles1}
#     Check Log With Au2anlysis    ${CURDIR}/ini/bip_case15_pdcch.ini     i    save_log_directory=${TEST_LOG_DIRECTORY()}/All/bip_h${h}v${v}
#     Check Log With Au2anlysis    ${CURDIR}/ini/bip_case15_pdsch.ini     i    save_log_directory=${TEST_LOG_DIRECTORY()}/All/bip_h${h}v${v}
# 
