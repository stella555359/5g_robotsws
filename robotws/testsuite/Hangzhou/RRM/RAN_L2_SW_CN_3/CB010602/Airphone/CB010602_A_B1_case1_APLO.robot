# 
# *** Settings ***
# Documentation     Author: jing.pan@nokia-sbell.com
# ...
# ...               QC case full name:
# ...               CB010602_A_B1_case1_Rank_4_8X4_CL(Cell CSI RS)_SRS_based_beamforming_extension_new_interface
# ...               CNI-84878 has already supported power balancing for rank=4 UE with cell specific CSI-RS.
# ...               CB0010602 extends to support power balancing for rank=3 UE with cell specific CSI-RS.
# 
# 
# Suite Setup       Common Suite Setup
# Suite Teardown    Common Suite Teardown
# Test Setup        Common Test Setup
# Test Teardown     Common Test Teardown
# Force Tags        CLOUD_5G_I_LO_AP_LO_SANSA_FS_ECPRI_CMWV_TDD    AP    CRT    SBTS00    RAN_5G_TDD    RAN_5G
# Test Timeout      60 minutes
# Resource          ../../resources/sg11/internal_resource/robot/modify_configuration.robot
# Resource          ../../resources/sg11/internal_resource/robot/internal_gnb_operate.robot
# Resource          ../../resources/sg11/internal_resource/robot/internal_ap_operate.robot
# 
# *** Variables ***
# ${UE1_ID}         1
# ${UE2_ID}         2
# ${PDU_ID}         1
# ${GW_ID}          1
# ${SLICE_ID}       1
# ${FILTER1}            ((dldata_pdschsendreq)||(DlData_CsiRsResource_t.density == 1)) && !(3gpp.rnti == 65535)
# ${CONFIG_DIR_PATH}    ${CURDIR}/../../resources/sg11/internal_resource/config/
# ${SCFC_NAME}          gNB_scf_ASIM_ABIP_AEQE_TDD_eCPRI_cmwv_SANSA_1CC_FS.xml
# ${AIRPHONE_NAME}      AP_iphy_AEQE_LO_AP_LO_TDD_eCPRI_cmwv_SANSA_L1b_1S_1CC_srs_B.xml
# ${WTS_NAME}           wts_config_ASIL_ABIO_TDD_eCPRI_cmwv_SANSA_L1b_1S_1CC.cfg
# 
# @{LOG_NAME_LIST}      gnb_snapshot    sosreport    egatelog\
# ${actCsirsBeamPowerBalance}                     text|false|//*[@name\="actCsirsBeamPowerBalance"]
# ${actPdschBeamPowerBalance}                     text|true|//*[@name\="actPdschBeamPowerBalance"]
# ${beamPowerOffsetThreshold}                     text|15|//*[@name\="beamPowerOffsetThreshold"]
# ${cell_specific}                                text|false|//*[@name\="actUeCsirsCoexistCellCsirs"]
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
# ${pattern}    CA_P2_8x4_t2r4_n2
# @{title1}    DlData_PdschGrant.bestBeamPowerOffset    3gpp.rnti    DlData_PdschGrant.closedLoop3gppCodebook    DlData_PdschGrant.numOfLayers
# ...          DlData_PdschGrant.patternId_item    DlData_CsiRsResource_t.patternId_item    DlData_CsiRsResource_t.csiBestBeamPowerOffset
# ...          DlData_CsiRsResource_t.csiRsConfig        DlData_CsiRsResource_t.density
# ${profile1}    ul_mimo_srs_beam_pos_nr profile_id=1 mode=fixed init_quad_pos=3 init_sub_quad_pos=0 test_type=SRS multi_path_config=1
# ...            num_of_nlos_paths=1 azimuth=3 zenith=0 srs_transmit_power_per_port=-400,-400,-500,-500
# 
# *** Test Cases ***
# CB010602_A_B1_case1_Rank_4_8X4_CL_SRS_based_beamforming_extension_new_interface
#     Step1: Commission the above configuration on WebUI
#     Step2: Attach UE rank=4 send buffer and capture logs
#     Step3: Check bip log
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
#     ...       ${actCsirsBeamPowerBalance}    ${actPdschBeamPowerBalance}    ${beamPowerOffsetThreshold}
#     ...       ${chBw}    ${dlMimoMode}    ${nrCellType}    ${actDlSrsBm}    ${pucchModeSelect}    ${frameStructureType}    ${guardPeriodLength}
#     ...       ${lteToNrFrameShift}      ${actBeamforming}    ${basicBeamSet}    ${nrBtsBeamRefinementP2}    ${actDl256Qam}    ${cell_specific}
#     modify_xml    ${scfc_path}    ${scfc_path}    ${modify_list}
#     Modify TL VM And AP SCTP Configuration
#     Get and Update BSR File    par_of_bsr_name=AEQE_6_H6_ALN60_ARP60_P00_COVERAGE_00424_000
#     Perform Full Commission And Reach Onair With Log    ${scfc_path}    ${CONFIG_DIR_PATH}${/}${WTS_NAME}    reset_after_commission=${False}
#     [Teardown]    Stop Collect GNB and AP Syslog in 'Step1_before_onair' File
# 
# Step2: Attach UE rank=4 send buffer and capture logs
#     Start Collect GNB and AP Syslog in 'Step2_attach' File
#     Attach SA ue with capability to 5g cell    1    ${pattern}
#     csi_override_testmode_active    ueid=1    profile_id=1   ri=3
#     excute_cmd_for_multi_path
#     SA send multiple trf data    ${UE1_ID}    DL    175M    4
#     ${save_log}=    Set Variable    ${TEST_LOG_DIRECTORY()}Step2_attach
#     Start GNB Ttitrace With Streaming Mode
#     Wait Throughput Timer    2
#     ${pacp}=    Stop GNB Ttitrace With Streaming Mode    save_path=${save_log}
#     Decoder Tttirace From Pcap To Csv    ${pacp}    ${save_log}/tti
# 	Start GNB BIP Log
#     Wait Throughput Timer    2
#     Stop Gnb BIP Log    log_dir=${save_log}
#     airphone_collect_egate_log_files      ${save_log}   unzip=TRUE
#     ${trace_id}    DCAP start collect log      10.0.1.2        enb_trace_profile=dcap-lite-default      bts_trace_profile=dcap-lite-default
#     DCAP stop collect log    ${trace_id}
#     [Teardown]    Stop Collect GNB and AP Syslog in 'Step2_attach' File
# 
# Step3: Check bip log
#     ${log_dir}=    Set Variable    ${TEST_LOG_DIRECTORY()}Step2_attach
#     sleep    15    reason=Wait for big log collection
#     Convert BIP To CSV    ${log_dir}/tcpdump_L2L1_bip_filtering_off.pcap1    ${log_dir}/bip_case1_UE1.csv    ${FILTER1}    ${title1}
#     Check Log With Au2anlysis    ini_path=${CURDIR}/log_check/bip_case1_UE1.ini     log_need_to_check=i    save_log_directory=${log_dir}
# 
# excute_cmd_for_multi_path
#     airphone_execute_egate_command    ${profile1}
#     airphone_execute_egate_command    ue_testmode_set_nr id\=1 testmode\=ul_mimo_srs_beam_pos action\=activate profile_id\=1
# 
