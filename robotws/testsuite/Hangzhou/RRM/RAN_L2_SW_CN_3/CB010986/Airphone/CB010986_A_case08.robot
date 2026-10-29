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
# ${qty}        NR_Angle_of_Arrival
# *** Test Cases ***
# CB010986_A_case08_UL_AoA_based_on_SRS_DFT_beam_Online_change_ulAoAMonitorWindow
#     Step1:Commission the above configuration on WebUI
#     Step2:Attach 10 UE and trigger AoA report
#     Step3:Tirgger E-CID Measurement Initiation Request from LMF with measurement
#     Step4:Online change ulAoAMonitorWindow from 100ms to 500ms
#     Step5:Tirgger E-CID Measurement Initiation Request from LMF with measurement
#  #   Step6:Online change ulAoAMonitorWindow to 1s and trigger invalid srs beam
#     Step7:Online change ulAoAMonitorWindow to 100ms and trigger invalid srs normal
#     Step8:Detach ue
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
#     add_all_elements    ${scfc_path}     NRBTS    nrEcidMeasSupervisionTimer     3000
#     add_lcsToGcsTranslate_list_in_cell    ${scfc_path}
#     ${modify_list}    create list
#     ...       ${cellDepType}    ${chBw}    ${dlMimoMode}    ${nrCellType}    ${actUlSrsBm}    ${actUlMuMimo}    ${actBeamforming}    ${actDlSrsBm}
#     ...       ${ulDMRSAdditionalPosition}    ${actUlPtrs}    ${actBbPoolExtensionTddFr1}    ${numOfSubSectors}    ${actSuperCell}
#     ...       ${actExternalAntennaBF}    ${frameStructureType}    ${guardPeriodLength}    ${lteToNrFrameShift}    ${prachConfigurationIndex}
# #    ...       ${actUlNrEcIdPosMethod}    ${actUlNrEcIdAoa}    ${ulAoAMonitorWindow}
#     modify_xml    ${scfc_path}    ${scfc_path}    ${modify_list}
#     Modify TL VM And AP SCTP Configuration
#     Get and Update BSR File    par_of_bsr_name=AEQE_6_H6_ALN60_ARP60_P00_COVERAGE_00424_00001
#     Perform Full Commission And Reach Onair With Log    ${scfc_path}    ${CONFIG_DIR_PATH}${/}${WTS_NAME}    reset_after_commission=${False}
#     [Teardown]    Stop Collect GNB and AP Syslog in 'Step1_before_onair' File
# 
# Step2:Attach 10 UE and trigger AoA report
#     Start capture gnb and ap syslog in 'Step2' file
#     #Start GNB BIP Log
#     ${save_log}=    Set Variable    ${TEST_LOG_DIRECTORY()}Step2
# 	Attach SA ue with capability to 5g cell    10    ${pattern}
#     set_ue_position    10
#     send ul and dl data
#     #Stop Gnb BIP Log    log_dir=${TEST_LOG_DIRECTORY()}${/}Step2_attach${/}
# 	Start GNB Ttitrace With Streaming Mode
#     Wait Throughput Timer    2
#     ${pacp}=    Stop GNB Ttitrace With Streaming Mode    save_path=${save_log}
# 	Decoder Tttirace From Pcap To Csv    ${pacp}    ${save_log}${/}tti
# 	run keyword and continue on failure    check_log_with_au2anlysis    ini_path=${CURDIR}/log_check/case08_tti.ini    log_need_to_check=i
#     ...    save_log_directory=${save_log}
#     [Teardown]    Stop capture gnb and ap syslog in 'Step2' file
# 
# Step3:Tirgger E-CID Measurement Initiation Request from LMF with measurement
#     Start capture gnb and ap syslog in 'Step3' file
#     ${save_log}=    Set Variable    ${TEST_LOG_DIRECTORY()}Step3
#     Start collect cplane bip    l2_l3
#     trigger E-CID Measurement Initiation request for all ues
#     Stop collect cplane bip    l2_l3    ${save_log}
#     Convert BIP To CSV    ${save_log}/l2_l3.pcap    ${save_log}/bip_cplane.csv    ${FILTER2}    ${title2}
#     Check Log With Au2anlysis    ini_path=${CURDIR}/log_check/bip_case08.ini     log_need_to_check=i    save_log_directory=${save_log}
#     [Teardown]    Stop capture gnb and ap syslog in 'Step3' file
# 
# Step4:Online change ulAoAMonitorWindow from 100ms to 500ms
#     Start capture gnb and ap syslog in 'Step4' file
#     Perform Online Change Parameter Value    MRBTS-1/NRBTS-2/NRCELL-1    ulAoaMonitorWindow    500    update
#     [Teardown]    Stop capture gnb and ap syslog in 'Step4' File
# 
# Step5:Tirgger E-CID Measurement Initiation Request from LMF with measurement
#     Start capture gnb and ap syslog in 'Step5' file
#     ${save_log}=    Set Variable    ${TEST_LOG_DIRECTORY()}Step5
#     Start collect cplane bip    l2_l3
#     trigger E-CID Measurement Initiation request for all ues
#     Stop collect cplane bip    l2_l3    ${save_log}
#     Convert BIP To CSV    ${save_log}/l2_l3.pcap    ${save_log}/bip_cplane.csv    ${FILTER2}    ${title2}
#     Check Log With Au2anlysis    ini_path=${CURDIR}/log_check/bip_case08.ini     log_need_to_check=i    save_log_directory=${save_log}
#     [Teardown]    Stop capture gnb and ap syslog in 'Step5' file
# 
# Step6:Online change ulAoAMonitorWindow to 1s and trigger invalid srs beam
#     Start capture gnb and ap syslog in 'Step6' file
#     ${save_log}=    Set Variable    ${TEST_LOG_DIRECTORY()}Step6
#     Perform Online Change Parameter Value    MRBTS-1/NRBTS-2/NRCELL-1    ulAoaMonitorWindow    1000    update
#     Wait Throughput Timer    10
#     Start collect cplane bip    l2_l3
#     trigger DFT beam invalid
#     Wait Throughput Timer    5
#     Start GNB Ttitrace With Streaming Mode
#     Wait Throughput Timer    2
#     ${pacp}=    Stop GNB Ttitrace With Streaming Mode    save_path=${save_log}
# 	Decoder Tttirace From Pcap To Csv    ${pacp}    ${save_log}${/}tti
#     trigger E-CID Measurement Initiation request for all ues    pass_regexp=Received ECID Measurement Failure
#     Stop collect cplane bip    l2_l3    ${save_log}
#     Convert BIP To CSV    ${save_log}/l2_l3.pcap    ${save_log}/bip_cplane.csv    ${FILTER2}    ${title2}
#     Check Log With Au2anlysis    ini_path=${CURDIR}/log_check/bip_case05.ini     log_need_to_check=i    save_log_directory=${save_log}
#     [Teardown]    Stop capture gnb and ap syslog in 'Step6' file
# 
# Step7:Online change ulAoAMonitorWindow to 100ms and trigger invalid srs normal
#     Start capture gnb and ap syslog in 'Step7' file
#     ${save_log}=    Set Variable    ${TEST_LOG_DIRECTORY()}Step7
#     Perform Online Change Parameter Value    MRBTS-1/NRBTS-2/NRCELL-1    ulAoaMonitorWindow    100    update
#     Wait Throughput Timer    10
#     set_ue_position    10
#     Start collect cplane bip    l2_l3
#     trigger E-CID Measurement Initiation request for all ues
#     Stop collect cplane bip    l2_l3    ${save_log}
#     Convert BIP To CSV    ${save_log}/l2_l3.pcap    ${save_log}/bip_cplane.csv    ${FILTER2}    ${title2}
#     Check Log With Au2anlysis    ini_path=${CURDIR}/log_check/bip_case08.ini     log_need_to_check=i    save_log_directory=${save_log}
#     [Teardown]    Stop capture gnb and ap syslog in 'Step7' file
# 
# Step8:Detach ue
#     Run Keyword And Ignore Error    Detach '10'UE
# 
# modify_iphy
#     [Arguments]    ${CONFIG_DIR_PATH}
#     remove_xml_element     ${CONFIG_DIR_PATH}${/}${AIRPHONE_NAME}     ${TEST_LOG_DIRECTORY()}${/}iphy_mod1.xml    //refinedBeams
#     modify xml    ${TEST_LOG_DIRECTORY()}${/}iphy_mod1.xml    ${TEST_LOG_DIRECTORY()}${/}iphy_mod2.xml  text|advancedSRS|//ulFeatures
#     change_iphy_rru_version    ${TEST_LOG_DIRECTORY()}${/}iphy_mod2.xml
# 
# trigger E-CID Measurement Initiation request for all ues
#     [Arguments]    ${pass_regexp}=Received ECID Measurement Response
#     :FOR    ${i}    IN RANGE     1    11
#     \    airphone_execute_egate_command
#     ...    lmf_send_ecid_meas_req id\=1 ue\=${i} nrppa_transaction_id\=1 lmf_ue_measurement_id\=1 report_characteristics\=OnDemand meas_qty\=${qty}
#     ...    pass_regexp=${pass_regexp}
#     Wait Throughput Timer    1
# 
# set_ue_position
#     [Arguments]    ${num}=1
#     :FOR    ${i}    IN RANGE     0    ${num}
#     \    ${subQ}    Evaluate    ${i}%4
#     \    ${Q}       Evaluate    int(${i}/4)
#     \    ${p}       Evaluate    ${i}+1
#     \    ${profile}    Catenate    ul_mimo_srs_beam_pos_nr profile_id=${p} mode=fixed init_quad_pos=${Q} init_sub_quad_pos=${subQ} test_type=SRS
#     ...    multi_path_config=1 num_of_nlos_paths=1 azimuth=3 zenith=0 srs_transmit_power_per_port=-400,-400,-500,-500
#     \    airphone_execute_egate_command    ${profile}
#     \    airphone_execute_egate_command    ue_testmode_set_nr id\=${p} testmode\=ul_mimo_srs_beam_pos action\=activate profile_id\=${p}
#     Wait Throughput Timer    2
# 
# send ul and dl data
#     :FOR    ${u}    IN RANGE     1    11
#      \    Airphone SA Start Data Traffic    ${u}    UL    100M    trf_id=1    pdu_id=1    duration=${7200}
#      \    Airphone SA Start Data Traffic    ${u}    DL    100M    trf_id=1    pdu_id=1    duration=${7200}
# 
# trigger DFT beam invalid
#     ${profile12}    Catenate    ul_mimo_srs_beam_pos_nr profile_id=12 mode=fixed init_quad_pos=3 init_sub_quad_pos=0 test_type=SRS
#     ...    multi_path_config=1 num_of_nlos_paths=1 azimuth=3 zenith=0 srs_transmit_power_per_port=-840,-840,-840,-840
#     airphone_execute_egate_command    ${profile12}
#     :FOR    ${i}    IN RANGE     0    10
#     \    ${u}       Evaluate    ${i}+1
#     \    airphone_execute_egate_command    ue_testmode_set_nr id\=${u} testmode\=ul_mimo_srs_beam_pos action\=activate profile_id\=12
# 
