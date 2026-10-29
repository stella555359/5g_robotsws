# *** Settings ***
# Documentation     Author: zhaona.jiang@nokia-sbell.com...
# ...               QC case full name:
# ...               CB008360_B_B2a_case_115_case 2 8DL8UL, 16UE rank1 pair
# 
# Suite Setup       Common Suite Setup
# Suite Teardown    Common Suite Teardown
# Test Setup        Common Test Setup
# Test Teardown     Common Test Teardown
# Force Tags        CLOUD_5G_I_LO_AP_LO_SANSA_FS_ECPRI_CMWV_TDD    AP    CRT    SBTS00    SBTS23R1    RAN_5G_TDD    RAN_5G    owner_jiangzhaona
# Test Timeout      90 minutes
# Resource          ../../resources/sg11/internal_resource/robot/modify_configuration.robot
# Resource          ../../resources/sg11/internal_resource/robot/internal_ap_operate.robot
# Resource          ../../resources/sg11/internal_resource/robot/internal_gnb_operate.robot
# Resource          ../../resources/sg11/internal_resource/robot/internal_capture_log.robot
# Resource    ${CURDIR}/Check_CNI113494_iBler.robot
# 
# *** Variables ***
# ${CONFIG_DIR_PATH}    ${CURDIR}/../../resources/sg11/internal_resource/config/
# #${SCFC_NAME}         8360_112_8d8u.xml
# ${SCFC_NAME}          scfc_8360_7113_16ue.xml
# ${AIRPHONE_NAME}      IPHY_10.xml
# #${AIRPHONE_NAME}     AP_iphy_AEQE_LO_AP_LO_TDD_eCPRI_cmwv_SANSA_L1b_1S_1CC_srs_B.xml
# ${WTS_NAME}           wts_config_AQQL_ASIB_ABIO_TDD_eCPRI_cmwv_SANSA_L1b_1S_1CC_20ue.cfg
# 
# @{LOG_NAME_LIST}      gnb_snapshot    sosreport    egatelog\
# 
# ${chBw}                                         text|100MHz|//*[@name\="chBw"]
# ${nrCellType}                                   text|8DL8UL|//*[@name\="nrCellType"]
# ${actUlMuMimo}                                  text|true|//*[@name\="actUlMuMimo"]
# ${ulMaxMuMimoLayer}                             text|4|//*[@name\="ulMaxMuMimoLayer"]
# ${actUlMuMimoTapering}                          text|false|//*[@name\="actUlMuMimoTapering"]
# ${frameStructureType}                           text|tdLte|//*[@name\="frameStructureType"]
# ${guardPeriodLength}                            text|4Symbols|//*[@name\="guardPeriodLength"]
# ${lteToNrFrameShift}                            text|0ms|//*[@name\="lteToNrFrameShift"]
# ${prachConfigurationIndex}                      text|97|//*[@name\="prachConfigurationIndex"]
# ${maxNumPuschAllocationPerSlot}                 text|16|//*[@name\="maxNumPuschAllocationPerSlot"]
# ${actBbPoolTddFr1}                              text|true|//*[@name\="actBbPoolTddFr1"]
# ${actShortBsrLimitAdaptation}                   text|true|//*[@name\="actShortBsrLimitAdaptation"]
# ${allowSlowPrbPoolingStatNdmSrs}                text|true|//*[@name\="allowSlowPrbPoolingStatNdmSrs"]
# ${pattern}     t2r4_n2_pusch_1layer
# 
# 
# *** Test Cases ***
# CNI_113494_Case7_PUSCH_iBLER_counters_for_tapered_2D-DFT_beams_CB008360
#     Step1:Commission the above configuration on WebUI
#     Step2:Attach 16 sa ue with rank1 and check 
#     Step3:Wait 3 min check counter again
# #	Step4:Detach ues
# 
# *** Keywords ***
# Step1:Commission the above configuration on WebUI
#     Start Collect GNB and AP Syslog in 'Step1_before_onair' File
# 	${CONFIG_DIR_PATH}    Set Variable    ${CONFIG_DIR_PATH}/${SW_BRANCH}
#     change_iphy_rru_version    ${CONFIG_DIR_PATH}${/}${AIRPHONE_NAME}
#     modify_swconfig_by_CB008360    ${CONFIG_DIR_PATH}${/}${SCFC_NAME}
#     ${scfc_path}    Set Variable    ${TEST_LOG_DIRECTORY()}${/}scfc.xml
#     copy_file    ${CONFIG_DIR_PATH}/${SCFC_NAME}    ${scfc_path}
#     ${modify_list}    create list
#     ...    ${chBw}    ${nrCellType}    ${actUlMuMimo}    ${ulMaxMuMimoLayer}    ${actUlMuMimoTapering}
#     ...    ${actUlMuMimoTapering}    ${frameStructureType}    ${guardPeriodLength}
# 	...    ${maxNumPuschAllocationPerSlot}    ${actBbPoolTddFr1}    ${actShortBsrLimitAdaptation}    ${allowSlowPrbPoolingStatNdmSrs}
#     modify_xml    ${scfc_path}    ${scfc_path}    ${modify_list}
#     add_all_elements    ${scfc_path}     NRPMRNL    miNrSrsQuality     15min
#     add_all_elements    ${scfc_path}     NRPMRNL    miNrBeamforming2     15min
#     add_all_elements    ${scfc_path}     NRPMRNL    miNrDlHarq     15min
#     add_all_elements    ${scfc_path}     NRPMRNL    miNrUlHarq     15min
#     add_all_elements    ${scfc_path}     NRPMRNL    miNrDlHarqLowSEMCS     15min
#     add_all_elements    ${scfc_path}     NRPMRNL    miNrUlHarqLowSEMCS     15min
#     add_all_elements    ${scfc_path}     NRPMRNL    miNrUlHarqOne     15min
#     Modify TL VM And AP SCTP Configuration
# 	Get and Update BSR File    par_of_bsr_name=AEQE_6_H6_ALN60_ARP60_P00_COVERAGE_00424_00001
#     Perform Full Commission And Reach Onair With Log    ${scfc_path}    ${CONFIG_DIR_PATH}${/}${WTS_NAME}    reset_after_commission=${False}
#     [Teardown]    Stop Collect GNB and AP Syslog in 'Step1_before_onair' File
# 
# Step2:Attach 16 sa ue with rank1 and check
#     Start capture gnb and ap syslog in 'Step2_attach' file
#     Attach SA ue with capability to 5g cell    16    ${pattern}
#     set pos for 16ue
#     ues send ul data
#     Wait Throughput Timer    3
#     get ul thp by egate
#     ${save_log}=    Set Variable    ${TEST_LOG_DIRECTORY()}Step2_attach
# 	${counter_file}    download PM counter file    ${save_log}
# 	${UL_thp_counter}=    get_counter_value_from_counter_file    counter_file=${counter_file}   counter_id=M55309C12002   cell_id=1
# 	${PAIR_UE_PUSCH}=    get_counter_value_from_counter_file    counter_file=${counter_file}   counter_id=M55308C35010   cell_id=1
# 	${ELIG_UE_PUSCH}=    get_counter_value_from_counter_file    counter_file=${counter_file}   counter_id=M55308C35011   cell_id=1
# 	should be true    ${UL_thp_counter} > 30000000
# 	should be true    ${PAIR_UE_PUSCH} > 200000
# 	should be true    ${ELIG_UE_PUSCH} > 200000
#     [Teardown]    Stop capture gnb and ap syslog in 'Step2_attach' file
# 
# Step3:Wait 3 min check counter again
#     Start capture gnb and ap syslog in 'Step3' file
#     Wait Throughput Timer    180
#     ${save_log}=    Set Variable    ${TEST_LOG_DIRECTORY()}Step3
#     ${counter_file}    download PM counter file    ${save_log}
# 	${UL_thp_counter}=    get_counter_value_from_counter_file    counter_file=${counter_file}   counter_id=M55309C12002   cell_id=1
# 	${PAIR_UE_PUSCH}=    get_counter_value_from_counter_file    counter_file=${counter_file}   counter_id=M55308C35010   cell_id=1
# 	${ELIG_UE_PUSCH}=    get_counter_value_from_counter_file    counter_file=${counter_file}   counter_id=M55308C35011   cell_id=1
# 	should be true    ${UL_thp_counter} > 30000000
# 	should be true    ${PAIR_UE_PUSCH} > 200000
# 	should be true    ${ELIG_UE_PUSCH} > 200000
#     ${save_log}=    Set Variable    ${TEST_LOG_DIRECTORY()}PM_check2
# 	${remaining_time}=    get_counter_file_remaining_time    counter_refresh_period=1min
#     Wait Throughput Timer    ${remaining_time}
#     ${PM_counter_file}=    download_latest_pmcounter    local_path=${save_log}${/}
# 	Check_CNI113494_iBler_match_Legacy_counters_1cell    ${PM_counter_file}
# 	[Teardown]    Stop capture gnb and ap syslog in 'Step3' file
# 
# Step4:Detach ues
#     Detach '16'UE
# 
# set pos for 16ue
#     :FOR    ${s}    IN RANGE     0    4
#     \    set init pos with sub${s}
# 
# set init pos with sub${s}
#     ${ue}    evaluate    ${s}*4+1
#     :FOR    ${i}    IN RANGE     0    4
#         \    ul_mimo_srs_beam_pos_active    ue=${ue}    profile=${ue}    init=${i}    sub=${s}    step=5
#         \    ${ue}    evaluate    ${ue}+1
# 
# ues send ul data
#     :FOR    ${u}    IN RANGE     1    17
#      \    Airphone SA Start Data Traffic    ${u}    UL    80M    trf_id=1    pdu_id=1    duration=${7200}
# 
# get ul thp by egate
#     :FOR    ${u}    IN RANGE     1    17
#     \    ${ue_ul_tput}=    Airphone Get Throughput On Specific Scell    ${u}    0    pusch    current
#     \    Log To Console    ue${u} thp is ${ue_ul_tput}
