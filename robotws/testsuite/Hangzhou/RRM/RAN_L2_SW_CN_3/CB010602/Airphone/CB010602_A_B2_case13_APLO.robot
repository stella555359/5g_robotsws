# *** Settings ***
# Documentation     Author: zhaona.jiang@nokia-sbell.com
# ...
# ...               QC case full name:
# ...               CB010602_A_B2_case13_Rank3_8X4_CL_SRS based beamforming extension IWK EIRP
# 
# Suite Setup       Common Suite Setup
# Suite Teardown    Common Suite Teardown
# Test Setup        Common Test Setup
# Test Teardown     Common Test Teardown
# Force Tags         CLOUD_5G_I_LO_AP_LO_SANSA_FS_ECPRI_CMWV_TDD    AP    CRT    SBTS00    RAN_5G_TDD    RAN_5G
# Test Timeout      60 minutes
# Resource          ../../resources/sg11/internal_resource/robot/modify_configuration.robot
# Resource          ../../resources/sg11/internal_resource/robot/internal_ap_operate.robot
# Resource          ../../resources/sg11/internal_resource/robot/internal_gnb_operate.robot
# 
# *** Variables ***
# ${UE1_ID}         1
# ${PDU_ID}         1
# ${GW_ID}          1
# ${SLICE_ID}       1
# ${FILTER1}    ((dldata_pdschsendreq)||(DlData_CsiRsResource_t.density == 1)) && !(3gpp.rnti == 65535)
# @{title1}    DlData_PdschGrant.bestBeamPowerOffset    3gpp.rnti    DlData_PdschGrant.closedLoop3gppCodebook    DlData_PdschGrant.numOfLayers
# ...          DlData_PdschGrant.patternId_item    DlData_CsiRsResource_t.patternId_item    DlData_CsiRsResource_t.csiBestBeamPowerOffset
# ...          DlData_CsiRsResource_t.csiRsConfig    DlData_CsiRsResource_t.density    DlData_PdschGrant.pdschPrecodingOption4x4
# ${CONFIG_DIR_PATH}    ${CURDIR}/../../resources/sg11/internal_resource/config/
# ${SCFC_NAME}          gNB_scf_ASIB_ABIO_AEQE_TDD_eCPRI_cmwv_SANSA_1CC_FS.xml
# ${AIRPHONE_NAME}      AP_iphy_AEQE_LO_AP_LO_TDD_eCPRI_cmwv_SANSA_L1b_1S_1CC_srs_B.xml
# ${WTS_NAME}           wts_config_ASIL_ABIO_TDD_eCPRI_cmwv_SANSA_L1b_1S_1CC.cfg
# 
# @{LOG_NAME_LIST}      gnb_snapshot    ap_snapshot    egatelog\
# ${chBw}                                         text|100MHz|//*[@name\="chBw"]
# ${dlMimoMode}                                   text|8x4 Closed Loop Spatial Multiplexing|//*[@name\="dlMimoMode"]
# ${nrCellType}                                   text|8DL8UL|//*[@name\="nrCellType"]
# ${actDlSrsBm}                                   text|true|//*[@name\="actDlSrsBm"]
# ${pucchModeSelect}                              text|longPucch|//*[@name\="pucchModeSelect"]
# ${frameStructureType}                           text|tdLte|//*[@name\="frameStructureType"]
# ${guardPeriodLength}                            text|6Symbols|//*[@name\="guardPeriodLength"]
# ${lteToNrFrameShift}                            text|0ms|//*[@name\="lteToNrFrameShift"]
# ${prachConfigurationIndex}                      text|97|//*[@name\="prachConfigurationIndex"]
# ${actBeamforming}                               text|true|//*[@name\="actBeamforming"]
# ${basicBeamSet}                                 text|beamSet_6|//*[@name\="basicBeamSet"]
# ${nrBtsBeamRefinementP2}                        text|false|//*[@name\="nrBtsBeamRefinementP2"]
# ${actDl256Qam}                                  text|true|//*[@name\="actDl256Qam"]
# ${actUeCsirsCoexistCellCsirs}                   text|true|//*[@name\="actUeCsirsCoexistCellCsirs"]
# ${actPdschBeamPowerBalance}                     text|true|//*[@name\="actPdschBeamPowerBalance"]
# ${actCsirsBeamPowerBalance}                     text|true|//*[@name\="actCsirsBeamPowerBalance"]
# ${beamPowerOffsetThreshold}                     text|15|//*[@name\="beamPowerOffsetThreshold"]
# ${actEirpControl}                               text|true|//*[@name\="actEirpControl"]
# ${eirpControlTimeAveragingWindow}               text|1|//*[@name\="eirpControlTimeAveragingWindow"]
# ${bwpDN1}                                   text|MRBTS-1/NRBTS-2/BWP_PROFILE-4|//*[contains(@name,'cellBwpList')]//item[1]/*[@name\='bwpDN']
# ${bwpDN2}                                   text|MRBTS-1/NRBTS-2/BWP_PROFILE-75|//*[contains(@name,'cellBwpList')]//item[2]/*[@name\='bwpDN']
# ${tiltOffset}                               text|0|//*[@name\="tiltOffset"]
# ${pattern}                                      CA_P2_8x4_t2r4_n2
# ${profile1}    ul_mimo_srs_beam_pos_nr profile_id=1 mode=fixed init_quad_pos=3 init_sub_quad_pos=0 test_type=SRS multi_path_config=1
# ...            num_of_nlos_paths=1 azimuth=3 zenith=0 srs_transmit_power_per_port=-400,-400,-500,-500
# *** Test Cases ***
# CB010602_A_B2_case13_Rank3_8X4_CL_SRS based beamforming extension IWK EIRP
#     Step1: Commission the above configuration on WebUI
#     Step2: Attach UE rank=4 send buffer and capture logs
#     Step3: Check bip log
#     Step4: Change rank=3 for cover counter
#     Step5: Detach UE
# 
# *** Keywords ***
# Step1: Commission the above configuration on WebUI
#     Start Collect GNB and AP Syslog in 'Step1_before_onair' File
#     ${CONFIG_DIR_PATH}    Set Variable    ${CONFIG_DIR_PATH}/${SW_BRANCH}
#     ${mod_iphy}    create list     text|advancedSRS|//ulFeatures
#     modify xml     ${CONFIG_DIR_PATH}${/}${AIRPHONE_NAME}      ${CONFIG_DIR_PATH}${/}${AIRPHONE_NAME}    ${mod_iphy}
#     change_iphy_rru_version    ${CONFIG_DIR_PATH}${/}${AIRPHONE_NAME}
#     modify_swconfig_by_CB010602    ${CONFIG_DIR_PATH}${/}${SCFC_NAME}
#     ${scfc_path}    Set Variable    ${TEST_LOG_DIRECTORY()}${/}scfc.xml
#     copy_file    ${CONFIG_DIR_PATH}/${SCFC_NAME}    ${scfc_path}
#     ${modify_list}    create list
#     ...       ${chBw}    ${dlMimoMode}    ${nrCellType}    ${actDlSrsBm}    ${prachConfigurationIndex}    ${pucchModeSelect}
#     ...       ${frameStructureType}    ${guardPeriodLength}    ${lteToNrFrameShift}    ${actBeamforming}    ${basicBeamSet}
#     ...       ${nrBtsBeamRefinementP2}    ${actDl256Qam}    ${actPdschBeamPowerBalance}     ${beamPowerOffsetThreshold}
#     ...       ${actCsirsBeamPowerBalance}    ${actEirpControl}    ${eirpControlTimeAveragingWindow}    ${actUeCsirsCoexistCellCsirs}
#     ...       ${bwpDN1}    ${bwpDN2}    ${tiltOffset}
#     modify_xml    ${scfc_path}    ${scfc_path}    ${modify_list}
#     Modify TL VM And AP SCTP Configuration
#     Get and Update BSR File    par_of_bsr_name=AEQE_6_H6_ALN60_ARP60_P00_COVERAGE_00424_000
#     Perform Full Commission And Reach Onair With Log    ${scfc_path}    ${CONFIG_DIR_PATH}${/}${WTS_NAME}    reset_after_commission=${False}
#     [Teardown]    Stop Collect GNB and AP Syslog in 'Step1_before_onair' File
# 
# Step2: Attach UE rank=4 send buffer and capture logs
#     Start Collect GNB and AP Syslog in 'Step2' File
# #    ul_sinr_testmode_active    ue_id=1    profile_id=1    sinr_srs=10    sinr_pucch=-300    noise_srs=-1053
#     Attach SA ue with capability to 5g cell    1    CA_P2_8x4_t2r4_n2
#     excute_cmd_for_multi_path
# #    ul_mimo_srs_beam_pos_active    ue=1    profile=1    init=1    sub=0    mu_path=1
#     SA send multiple trf data    ${UE1_ID}    DL    175M    4
#     ${save_log}=    Set Variable    ${TEST_LOG_DIRECTORY()}Step2
#     Start GNB BIP Log
#     Wait Throughput Timer    1
#     Stop Gnb BIP Log    log_dir=${save_log}
#     Start GNB Ttitrace With Streaming Mode
#     Wait Throughput Timer    2
#     ${pacp}=    Stop GNB Ttitrace With Streaming Mode    save_path=${save_log}
#     Decoder Tttirace From Pcap To Csv    ${pacp}    ${save_log}/tti
#     airphone_collect_egate_log_files      ${save_log}   unzip=TRUE
#     [Teardown]    Stop Collect GNB and AP Syslog in 'Step2' File
# 
# Step3: Check bip log
#     ${log_dir}=    Set Variable    ${TEST_LOG_DIRECTORY()}Step2
#     Convert BIP To CSV    ${log_dir}/tcpdump_L2L1_bip_filtering_off.pcap0    ${log_dir}/bip_case13_step3.csv    ${FILTER1}    ${title1}
#     Check Log With Au2anlysis    ini_path=${CURDIR}/log_check/bip_case13_step3.ini     log_need_to_check=i    save_log_directory=${log_dir}
#     ${counter_file}    download PM counter file    ${log_dir}
# 	${BEAM_PWR_OFFSET_RI4_INDEX8}=    get_counter_value_from_counter_file    counter_file=${counter_file}   counter_id=M55305C14019   cell_id=1
# 	${dL_thp_counter}=    get_counter_value_from_counter_file    counter_file=${counter_file}   counter_id=M55309C12001   cell_id=1
# 	should be true    ${BEAM_PWR_OFFSET_RI4_INDEX8} > 40000
# 	should be true    ${BEAM_PWR_OFFSET_RI4_INDEX8} < 84001
# 	should be true    ${dL_thp_counter} > 78000000
# 
# Step4: Change rank=3 for cover counter
#     Start Collect GNB and AP Syslog in 'Step4_rank3' File
#     airphone_override_deactive
#     airphone_override_active    2
#     ${save_log}=    Set Variable    ${TEST_LOG_DIRECTORY()}Step4_rank3
#     Start GNB BIP Log
#     Wait Throughput Timer    2
#     Stop Gnb BIP Log    log_dir=${save_log}
#     Convert BIP To CSV    ${save_log}/tcpdump_L2L1_bip_filtering_off.pcap0    ${save_log}/bip_case13_step4.csv    ${FILTER1}    ${title1}
#     Check Log With Au2anlysis    ini_path=${CURDIR}/log_check/bip_case13_step4.ini     log_need_to_check=i    save_log_directory=${save_log}
#     ${counter_file}    download PM counter file    ${save_log}
# 	${BEAM_PWR_OFFSET_RI3_INDEX5}=    get_counter_value_from_counter_file    counter_file=${counter_file}   counter_id=M55305C14006   cell_id=1
# 	${dL_thp_counter}=    get_counter_value_from_counter_file    counter_file=${counter_file}   counter_id=M55309C12001   cell_id=1
# #	should be true    ${BEAM_PWR_OFFSET_RI3_INDEX5} > 40000
# #	should be true    ${dL_thp_counter} > 78000000
#     [Teardown]    Stop Collect GNB and AP Syslog in 'Step4_rank3' File
# 
# Step5: Detach UE
#     Start Collect GNB and AP Syslog in 'Step4_detach' File
#     airphone_sa_stop_data_traffic    ${UE1_ID}   DL    pdu_id=1
#     airphone_sa_detach    ${UE1_ID}
#     [Teardown]    Stop Collect GNB and AP Syslog in 'Step4_detach' File
# 
# send ${UENUM}ues buffer
#     : FOR    ${ueId}    IN RANGE    1    ${UENUM}+1
#     \    SA send multiple trf data    ${ueId}    DL    175M    1
# #    \    SA send multiple trf data    ${ueId}    UL    10M    1
# 
# airphone_override_active
#     [Arguments]    ${i}
#     Airphone Execute Egate Command
#     ...    csi_override_testmode_nr profile_id\=1 cqi_mode\=fixed cqi\=15 ri_mode\=fixed ri\=${i} cri_mode\=fixed cri\=1 li_mode\=fixed li\=${i}
#     #csi_override_testmode_nr profile_id=1 cqi_mode=fixed cqi=15 ri_mode=fixed ri=2 pmi_mode=fixed pmi=500 cri_mode=fixed cri=1 li_mode=fixed li=2
#     Airphone Execute Egate Command    ue_testmode_set_nr id\=${UE1_ID} testmode\=csi_override action\=activate profile_id\=1
# 
# airphone_override_deactive
#     Airphone Execute Egate Command    ue_testmode_set_nr id\=${UE1_ID} testmode\=csi_override action\=deactivate profile_id\=1
# 
# excute_cmd_for_multi_path
#     airphone_execute_egate_command    ${profile1}
#     airphone_execute_egate_command    ue_testmode_set_nr id\=1 testmode\=ul_mimo_srs_beam_pos action\=activate profile_id\=1
