# *** Settings ***
# Documentation     Author: zhaona.jiang@nokia-sbell.com
# 
# Suite Setup       Common Suite Setup
# #Suite Teardown    Common Suite Teardown
# Test Setup        Common Test Setup
# Test Teardown     Common Test Teardown
# Force Tags        CLOUD_5G_I_LO_AP_LO    AP    CRT    SBTS00    RAN_5G_TDD    RAN_5G
# Test Timeout      60 minutes
# Resource          ../../resources/sg11/internal_resource/robot/modify_configuration.robot
# Resource          ../../resources/sg11/internal_resource/robot/internal_ap_operate.robot
# Resource          ../../resources/sg11/internal_resource/robot/internal_gnb_operate.robot
# Resource          ../../resources/sg11/internal_resource/robot/internal_capture_log.robot
# 
# *** Variables ***
# ${CONFIG_DIR_PATH}    ${CURDIR}/../../resources/sg11/internal_resource/config/
# ${SCFC_NAME}          gNB_scf_ASIL_ABIO_TDD_eCPRI_cmwv_SANSA_L1b_1S_1CC_A.xml
# ${AIRPHONE_NAME}      AP_iphy_AEQE_LO_AP_LO_TDD_eCPRI_cmwv_SANSA_L1b_1S_1CC_srs.xml
# ${WTS_NAME}           wts_config_ASIL_ABIO_TDD_eCPRI_cmwv_SANSA_L1b_1S_1CC.cfg
# @{LOG_NAME_LIST}      gnb_snapshot    egatelog\
# ${cellDepType}                                  text|SA+NSA|//*[@name\="cellDepType"]
# ${chBw}                                         text|100MHz|//*[@name\="chBw"]
# ${ulMimoMode}                                   text|Closed loop Spatial Multiplexing (2x2)|//*[@name\="ulMimoMode"]
# ${dlMimoMode}                                   text|2x2 Closed Loop Spatial Multiplexing|//*[@name\="dlMimoMode"]
# ${nrCellType}                                   text|8DL4UL|//*[@name\="nrCellType"]
# ${actBeamforming}                               text|true|//*[@name\="actBeamforming"]
# ${actUlSrsBm}                                   text|true|//*[@name\="actUlSrsBm"]
# ${actUlMuMimo}                                  text|false|//*[@name\="actUlMuMimo"]
# ${actDlSrsBm}                                   text|false|//*[@name\="actDlSrsBm"]
# ${ulDMRSAdditionalPosition}                     text|One additional DMRS|//*[@name\="ulDMRSAdditionalPosition"]
# ${actUlPtrs}                                    text|false|//*[@name\="actUlPtrs"]
# ${actBbPoolExtensionTddFr1}                     text|false|//*[@name\="actBbPoolExtensionTddFr1"]
# ${numOfSubSectors}                              text|0sub-sector|//*[@name\="numOfSubSectors"]
# ${actSuperCell}                                 text|false|//*[@name\="actSuperCell"]
# ${actExternalAntennaBF}                         text|false|//*[@name\="actExternalAntennaBF"]
# # 1116
# ${frameStructureType}                           text|tdLte|//*[@name\="frameStructureType"]
# ${guardPeriodLength}                            text|6Symbols|//*[@name\="guardPeriodLength"]
# ${lteToNrFrameShift}                            text|0ms|//*[@name\="lteToNrFrameShift"]
# ${prachConfigurationIndex}                      text|97|//*[@name\="prachConfigurationIndex"]
# #10986
# ${actUlNrEcIdPosMethod}                         text|true|//*[@name\="actUlNrEcIdPosMethod"]
# ${actUlNrEcIdAoa}                               text|true|//*[@name\="actUlNrEcIdAoa"]
# ${ulAoAMonitorWindow}                           text|100ms|//*[@name\="ulAoAMonitorWindow"]
# #${BearingAngle}
# #${DowntiltAngle
# #${SlantAngle}
# #${actUlNrEcIdTAdv}
# ${UE1_ID}     1
# ${pattern}    CA_P2_8x4_t2r4_n2
# ${FILTER1}    itf_l2_ps_cell_cellsetupreq_t
# @{title1}     itf_l2_ps_cell_CellSetupReq_t.ulAoAMonitorWindow_item
# ${FILTER2}    (itf_l2_ps_user_userranmeasurementreq)||(itf_l2_ps_user_userranmeasurementresp)
# @{title2}     itf_l2_ps_user_UserRanMeasurementReq_t.angleOfArrivalNrRequired    itf_l2_ps_user_AngleOfArrivalNrResult.aoaNrStatus
# ...           itf_l2_ps_user_AoaResult.aoaH    itf_l2_ps_user_AoaResult.aoaV    itf_l2_ps_user_UserRanMeasurementReq_t.tAdvMeasRequired
# ...           itf_l2_ps_user_TimingAdvanceMeasurementResult.tAdvStatus
# ${profile1}    ul_mimo_srs_beam_pos_nr profile_id=1 mode=fixed init_quad_pos=3 init_sub_quad_pos=0 test_type=SRS multi_path_config=1
# ...            num_of_nlos_paths=1 azimuth=3 zenith=0 srs_transmit_power_per_port=-400,-400,-500,-500
# 
# *** Test Cases ***
# CB010986_A_case06_UL_AoA_based_on_SRS_DFT_beam_measurement_quantity_not_match
#     Step1:Commission the above configuration on WebUI
#     Step2:Attach 1UE with fix AoA position and send traffic
#     Step3:Tirgger E-CID Measurement Initiation Request from LMF with measurement
#     Step4:Detach ue
# 
# *** Keywords ***
# Step1:Commission the above configuration on WebUI
#     Start Collect GNB and AP Syslog in 'Step1_before_onair' File
# 	${CONFIG_DIR_PATH}    Set Variable    ${CONFIG_DIR_PATH}/${SW_BRANCH}
#     modify_iphy    ${CONFIG_DIR_PATH}
#     modify_swconfig_by_CB008360    ${CONFIG_DIR_PATH}${/}${SCFC_NAME}
#     ${scfc_path}    Set Variable    ${TEST_LOG_DIRECTORY()}${/}scfc.xml
#     copy_file    ${CONFIG_DIR_PATH}/${SCFC_NAME}    ${scfc_path}
#     add_all_elements    ${scfc_path}     NRCELL    actUlNrEcIdAoa     true
#     add_all_elements    ${scfc_path}     NRCELL    actUlNrEcIdPosMethod     true
#     add_all_elements    ${scfc_path}     NRCELL    ulAoaMonitorWindow     100
#     add_all_elements    ${scfc_path}     NRBTS     nrEcidMeasSupervisionTimer     3000
#     add_all_elements    ${scfc_path}     NRCELL    actUlNrEcIdTAdv     false
#     add_lcsToGcsTranslate_list_in_cell    ${scfc_path}
#     ${modify_list}    create list
#     ...       ${cellDepType}    ${chBw}    ${dlMimoMode}    ${nrCellType}    ${actUlSrsBm}    ${actUlMuMimo}    ${actBeamforming}    ${actDlSrsBm}
#     ...       ${ulDMRSAdditionalPosition}    ${actUlPtrs}    ${actBbPoolExtensionTddFr1}    ${numOfSubSectors}    ${actSuperCell}
#     ...       ${actExternalAntennaBF}    ${frameStructureType}    ${guardPeriodLength}    ${lteToNrFrameShift}    ${prachConfigurationIndex}
#     modify_xml    ${scfc_path}    ${scfc_path}    ${modify_list}
#     Modify TL VM And AP SCTP Configuration
#     Get and Update BSR File    par_of_bsr_name=AEQE_6_H6_ALN60_ARP60_P00_COVERAGE_00424_00001
#     Perform Full Commission And Reach Onair With Log    ${scfc_path}    ${CONFIG_DIR_PATH}${/}${WTS_NAME}    reset_after_commission=${False}
#     [Teardown]    Stop Collect GNB and AP Syslog in 'Step1_before_onair' File
# 
# Step2:Attach 1UE with fix AoA position and send traffic
#     Start capture gnb and ap syslog in 'Step2' file
#     #Start GNB BIP Log
#     ${save_log}=    Set Variable    ${TEST_LOG_DIRECTORY()}Step2
# 	Attach SA ue with capability to 5g cell    1    ${pattern}
#     set_ue_position    ue_id=1    profile=${profile1}
#     Airphone SA Start Data Traffic    1    UL    175M    trf_id=1    pdu_id=1    duration=${3600}
#     Airphone SA Start Data Traffic    1    DL    175M    trf_id=1    pdu_id=1    duration=${3600}
#     #Stop Gnb BIP Log    log_dir=${TEST_LOG_DIRECTORY()}${/}Step2_attach${/}
# 	Start GNB Ttitrace With Streaming Mode
#     Wait Throughput Timer    5
#     ${pacp}=    Stop GNB Ttitrace With Streaming Mode    save_path=${save_log}
# 	Decoder Tttirace From Pcap To Csv    ${pacp}    ${save_log}${/}tti
# 	run keyword and continue on failure    check_log_with_au2anlysis    ini_path=${CURDIR}/log_check/case01_tti.ini    log_need_to_check=i
#     ...    save_log_directory=${save_log}
#     [Teardown]    Stop capture gnb and ap syslog in 'Step2' file
# 
# Step3:Tirgger E-CID Measurement Initiation Request from LMF with measurement
#     Start capture gnb and ap syslog in 'Step3' file
#     ${save_log}=    Set Variable    ${TEST_LOG_DIRECTORY()}Step3
#     Start collect cplane bip    l2_l3
#     trigger E-CID Measurement Initiation request    meas_qty=NR_Angle_of_Arrival,NR_Timing_Advance
#     Wait Throughput Timer    1
#     Stop collect cplane bip    l2_l3    ${save_log}
#     Convert BIP To CSV    ${save_log}/l2_l3.pcap    ${save_log}/bip_cplane.csv    ${FILTER2}    ${title2}
#     Check Log With Au2anlysis    ini_path=${CURDIR}/log_check/bip_case06.ini     log_need_to_check=i    save_log_directory=${save_log}
#     [Teardown]    Stop capture gnb and ap syslog in 'Step3' file
# 
# Step4:Detach ue
#     airphone_sa_detach    ${UE1_ID}
# 
# modify_iphy
#     [Arguments]    ${CONFIG_DIR_PATH}
#     remove_xml_element     ${CONFIG_DIR_PATH}${/}${AIRPHONE_NAME}     ${TEST_LOG_DIRECTORY()}${/}iphy_mod1.xml    //refinedBeams
#     modify xml    ${TEST_LOG_DIRECTORY()}${/}iphy_mod1.xml    ${TEST_LOG_DIRECTORY()}${/}iphy_mod2.xml  text|advancedSRS|//ulFeatures
#     change_iphy_rru_version    ${TEST_LOG_DIRECTORY()}${/}iphy_mod2.xml
# 
# trigger E-CID Measurement Initiation request
#     [Arguments]    ${ue_id}=1    ${meas_qty}=NR_Angle_of_Arrival    ${tid}=1    ${pass_regexp}=Received ECID Measurement Response
#     ${cmd}    Catenate    lmf_send_ecid_meas_req id=1 ue=${ue_id} nrppa_transaction_id=${tid} lmf_ue_measurement_id=${tid}
#     ...    report_characteristics=OnDemand meas_qty=${meas_qty}
#     airphone_execute_egate_command    ${cmd}    pass_regexp=${pass_regexp}
#     Wait Throughput Timer    1
# 
# set_ue_position
#     [Arguments]    ${ue_id}=1    ${profile}=${profile1}    ${p_id}=1
#     airphone_execute_egate_command    ${profile}
#     airphone_execute_egate_command    ue_testmode_set_nr id\=${ue_id} testmode\=ul_mimo_srs_beam_pos action\=activate profile_id\=${p_id}
# 
# 
