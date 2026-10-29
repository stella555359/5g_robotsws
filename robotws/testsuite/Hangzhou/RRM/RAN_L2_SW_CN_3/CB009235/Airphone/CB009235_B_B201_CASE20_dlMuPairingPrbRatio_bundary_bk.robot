# *** Settings ***
# Documentation     Author: shuiheng.he@nokia-sbell.com
# ...
# ...               QC case full name:
# ...               CB009235_B_B201_CASE20_dlMuAware_dlMuPairingPrbRatio_algo_and_bundary_value_check
# ...
# 
# Suite Setup       Common Suite Setup
# Suite Teardown    Common Suite Teardown
# Test Setup        Common Test Setup
# Test Teardown     Common Test Teardown
# 
# Force Tags        CLOUD_5G_I_MP_AP_LO    AP    CRT    SBTS00    RAN_5G_TDD    RAN_5G    owner_shuihe
# Test Timeout      90 minutes
# Resource          ../../resources/sg11/internal_resource/robot/modify_configuration.robot
# Resource          ../../resources/sg11/internal_resource/robot/internal_ap_operate.robot
# Resource          ../../resources/sg11/internal_resource/robot/internal_gnb_operate.robot
# Resource          ../../resources/sg11/internal_resource/robot/internal_capture_log.robot
# 
# *** Variables ***
# ${CONFIG_DIR_PATH}                         ${CURDIR}/config
# ${SCFC_NAME}                               SCFC_9235_B_case20.xml
# ${AIRPHONE_NAME}                           IPHY_AQQL_1CELL_APLO_8x4_case20.xml
# ${WTS_NAME}                                wts_9235_1cell_SA_NSA_case20.lua
# ${UE_NUM}                                  68
# @{LOG_NAME_LIST}                           gnb_snapshot    ap_snapshot    egatelog
# ${actMuAwareTdSch}                         text|true|//*[@name\="actMuAwareTdSch"]
# ${dlMuAwareCorrThd}                        text|10|//*[@name\="dlMuAwareCorrThd"]
# ${dlMuAwarePrbRatio}                       text|100|//*[@name\="dlMuAwarePrbRatio"]
# ${dlMuMaxNumLayerPerMuRbg}                 text|16|//*[@name\="dlMuMaxNumLayerPerMuRbg"]
# ${dlMuMimoCorrThd}                         text|33|//*[@name\="dlMuMimoCorrThd"]
# ${dlMuMimoCqiThd}                          text|1|//*[@name\="dlMuMimoCqiThd"]
# ${dlMuMimoRankAdaption}                    text|adaptive|//*[@name\="dlMuMimoRankAdaption"]
# ${dlMuMimoSpectralEffThd}                  text|10|//*[@name\="dlMuMimoSpectralEffThd"]
# ${dlMuMimoTaperingH}                       text|25dB|//*[@name\="dlMuMimoTaperingH"]
# ${dlMuMimoTaperingV}                       text|NoTapering|//*[@name\="dlMuMimoTaperingV"]
# ${dlMuPairingPrbRatio}                     text|100|//*[@name\="dlMuPairingPrbRatio"]
# ${miNrCellUtilization}                     text|15min|//*[@name\="miNrCellUtilization"]
# 
# ${cellDepType}                             text|SA+NSA|//*[@name\="cellDepType"]
# ${chBw}                                    text|100MHz|//*[@name\="chBw"]
# ${dlMimoMode}                              text|8x4 Closed Loop Spatial Multiplexing|//*[@name\="dlMimoMode"]
# ${nrCellType}                              text|8DL4UL|//*[@name\="nrCellType"]
# ${actUeCsirsCoexistCellCsirs}              text|false|//*[@name\="actUeCsirsCoexistCellCsirs"]
# ${actCsirsMultiplexing}                    text|true|//*[@name\="actCsirsMultiplexing"]
# ${actDlSrsBm}                              text|true|//*[@name\="actDlSrsBm"]
# ${actUlSrsBm}                              text|true|//*[@name\="actUlSrsBm"]
# ${actDlSrsSubbandBm}                       text|true|//*[@name\="actDlSrsSubbandBm"]
# ${actUlClosedLoopPwrCtrl}                  text|pucchPuschSrs|//*[@name\="actUlClosedLoopPwrCtrl"]
# ${actCDrx}                                 text|true|//*[@name\="actCDrx"]
# ${actFdmScheduling}                        text|true|//*[@name\="actFdmScheduling"]
# ${frameStructureType}                      text|semiStatic|//*[@name\="frameStructureType"]
# ${guardPeriodLength}                       text|2Symbols|//*[@name\="guardPeriodLength"]
# ${ulDlDataSlotRatio}                       text|1/4|//*[@name\="ulDlDataSlotRatio"]
# ${prachConfigurationIndex}                 text|98|//*[@name\="prachConfigurationIndex"]
# ${srsUePeriodicity}                        text|slots40|//*[@name\="srsUePeriodicity"]
# ${cSRS}                                    text|63|//*[@name\="cSRS"]
# ${bSRS}                                    text|0|//*[@name\="bSRS"]
# ${srsPowerThresholdForDlBm}                text|-1200|//*[@name\="srsPowerThresholdForDlBm"]
# ${srsTypeAllocForDlBm}                     text|antenna switching or codebook|//*[@name\="srsTypeAllocForDlBm"]
# ${bfSubbandSize}                           text|8 PRBs|//*[@name\="bfSubbandSize"]
# ${maxNumUeSrs}                             text|4|//*[@name\="maxNumUeSrs"]
# ${srsQualityThreshold}                     text|-1200|//*[@name\="srsQualityThreshold"]
# ${FILTER1}    uldata_srsreceivereq
# @{title1}    3gpp.rnti    frame.time    3gpp.sfn    3gpp.slot    UlData_srsReceiveReqSubcell_t.srsSuMimoEnable
# ...          UlData_srsReceiveReqSubcell_t.srsBmEnable    UlData_srsReceiveReqSubcell_t.srsBwvEnable    UlData_srsReceiveReqUes_t.transmissionComb
# ...          UlData_srsBmStruct_t.transmissionComb    UlData_srsBwvStruct_t.transmissionComb
# ...          UlData_srsReceiveReqUes_t.powerOffsetSrsToPuschPerAllocatedRe    UlData_srsBmCsInfo_t.bmCyclicShift
# ...          UlData_srsBmCombShiftPairs_t.transmissionCombId
# ${srsPowerThresholdForUlBm}                 text|-1200|//*[@name\="srsPowerThresholdForUlBm"]
# ${dllaDeltaCqiMax}                          text|0|//*[@name\="dllaDeltaCqiMax"]
# ${dllaDeltaCqiMin}                          text|0|//*[@name\="dllaDeltaCqiMin"]
# ${dllaDeltaCqiStepdown}                     text|0|//*[@name\="dllaDeltaCqiStepdown"]
# ${actIncreasedFdmUsersPerSlot}              text|true|//*[@name\="actIncreasedFdmUsersPerSlot"]
# ${actDlMuMimoEnh}                           text|true|//*[@name\="actDlMuMimoEnh"]
# ${actCsirsBeamPowerBalance}                 text|false|//*[@name\="actCsirsBeamPowerBalance"]
# ${comb}                                     text|comb4|//*[@name\="comb"]
# ${actUl256Qam}                              text|true|//*[@name\="actUl256Qam"]
# ${actDl256Qam}                              text|true|//*[@name\="actDl256Qam"]
# ${bwp_profile5}      text|MRBTS-1/NRBTS-1/BWP_PROFILE-5|//*[@name\="cellBwpList"]/item[1]/*[@name\="bwpDN"]
# ${bwp_profile52}     text|MRBTS-1/NRBTS-1/BWP_PROFILE-52|//*[@name\="cellBwpList"]/item[2]/*[@name\="bwpDN"]
# ${maxNumPdschAllocationPerSlot}             text|8|//*[@name\="maxNumPdschAllocationPerSlot"]
# ${maxNumPuschAllocationPerSlot}             text|8|//*[@name\="maxNumPuschAllocationPerSlot"]
# ${prbRatioHysteresis}                         text|5|//*[@name\="prbRatioHysteresis"]
# ${prbRatioThreshold}                         text|6|//*[@name\="prbRatioThreshold"]
# 
# ${PROFILE2}    ul_mimo_srs_beam_pos_nr profile_id\=2 mode\=fixed init_quad_pos\=0 init_sub_quad_pos\=0 test_type\=SRS
# ...    multi_path_config\=true num_of_nlos_paths\=1 azimuth\=50 zenith\=-15 srs_transmit_power_per_port\=-320,-320,-250,-250
# ${PROFILE3}    ul_mimo_srs_beam_pos_nr profile_id\=3 mode\=fixed init_quad_pos\=0 init_sub_quad_pos\=1 test_type\=SRS
# ...    multi_path_config\=true num_of_nlos_paths\=1 azimuth\=45 zenith\=-26 srs_transmit_power_per_port\=-320,-320,-250,-250
# ${PROFILE4}    ul_mimo_srs_beam_pos_nr profile_id\=4 mode\=fixed init_quad_pos\=0 init_sub_quad_pos\=2 test_type\=SRS
# ...    multi_path_config\=true num_of_nlos_paths\=1 azimuth\=40 zenith\=-15 srs_transmit_power_per_port\=-320,-320,-250,-250
# ${PROFILE5}    ul_mimo_srs_beam_pos_nr profile_id\=5 mode\=fixed init_quad_pos\=0 init_sub_quad_pos\=3 test_type\=SRS
# ...    multi_path_config\=true num_of_nlos_paths\=1 azimuth\=35 zenith\=-26 srs_transmit_power_per_port\=-320,-320,-250,-250
# ${PROFILE6}    ul_mimo_srs_beam_pos_nr profile_id\=6 mode\=fixed init_quad_pos\=0 init_sub_quad_pos\=0 test_type\=SRS
# ...    multi_path_config\=true num_of_nlos_paths\=1 azimuth\=30 zenith\=-15 srs_transmit_power_per_port\=-320,-320,-250,-250
# ${PROFILE7}    ul_mimo_srs_beam_pos_nr profile_id\=7 mode\=fixed init_quad_pos\=0 init_sub_quad_pos\=1 test_type\=SRS
# ...    multi_path_config\=true num_of_nlos_paths\=1 azimuth\=25 zenith\=-26 srs_transmit_power_per_port\=-320,-320,-250,-250
# ${PROFILE8}    ul_mimo_srs_beam_pos_nr profile_id\=8 mode\=fixed init_quad_pos\=3 init_sub_quad_pos\=2 test_type\=SRS
# ...    multi_path_config\=true num_of_nlos_paths\=1 azimuth\=20 zenith\=-15 srs_transmit_power_per_port\=-320,-320,-250,-250
# ${PROFILE9}    ul_mimo_srs_beam_pos_nr profile_id\=9 mode\=fixed init_quad_pos\=3 init_sub_quad_pos\=3 test_type\=SRS
# ...    multi_path_config\=true num_of_nlos_paths\=1 azimuth\=15 zenith\=-26 srs_transmit_power_per_port\=-320,-320,-250,-250
# ${PROFILE10}    ul_mimo_srs_beam_pos_nr profile_id\=10 mode\=fixed init_quad_pos\=3 init_sub_quad_pos\=0 test_type\=SRS
# ...    multi_path_config\=true num_of_nlos_paths\=1 azimuth\=10 zenith\=-15 srs_transmit_power_per_port\=-320,-320,-250,-250
# ${PROFILE11}    ul_mimo_srs_beam_pos_nr profile_id\=11 mode\=fixed init_quad_pos\=3 init_sub_quad_pos\=1 test_type\=SRS
# ...    multi_path_config\=true num_of_nlos_paths\=1 azimuth\=5 zenith\=-26 srs_transmit_power_per_port\=-320,-320,-250,-250
# ${PROFILE12}    ul_mimo_srs_beam_pos_nr profile_id\=12 mode\=fixed init_quad_pos\=3 init_sub_quad_pos\=2 test_type\=SRS
# ...    multi_path_config\=true num_of_nlos_paths\=1 azimuth\=0 zenith\=-15 srs_transmit_power_per_port\=-320,-320,-250,-250
# ${PROFILE13}    ul_mimo_srs_beam_pos_nr profile_id\=13 mode\=fixed init_quad_pos\=3 init_sub_quad_pos\=3 test_type\=SRS
# ...    multi_path_config\=true num_of_nlos_paths\=1 azimuth\=-5 zenith\=-26 srs_transmit_power_per_port\=-320,-320,-250,-250
# ${PROFILE14}    ul_mimo_srs_beam_pos_nr profile_id\=14 mode\=fixed init_quad_pos\=1 init_sub_quad_pos\=0 test_type\=SRS
# ...    multi_path_config\=true num_of_nlos_paths\=1 azimuth\=-10 zenith\=-15 srs_transmit_power_per_port\=-320,-320,-250,-250
# ${PROFILE15}    ul_mimo_srs_beam_pos_nr profile_id\=15 mode\=fixed init_quad_pos\=1 init_sub_quad_pos\=1 test_type\=SRS
# ...    multi_path_config\=true num_of_nlos_paths\=1 azimuth\=-15 zenith\=-26 srs_transmit_power_per_port\=-320,-320,-250,-250
# ${PROFILE16}    ul_mimo_srs_beam_pos_nr profile_id\=16 mode\=fixed init_quad_pos\=1 init_sub_quad_pos\=2 test_type\=SRS
# ...    multi_path_config\=true num_of_nlos_paths\=1 azimuth\=-20 zenith\=-15 srs_transmit_power_per_port\=-320,-320,-250,-250
# ${PROFILE17}    ul_mimo_srs_beam_pos_nr profile_id\=17 mode\=fixed init_quad_pos\=1 init_sub_quad_pos\=3 test_type\=SRS
# ...    multi_path_config\=true num_of_nlos_paths\=1 azimuth\=-25 zenith\=-26 srs_transmit_power_per_port\=-320,-320,-250,-250
# ${PROFILE18}    ul_mimo_srs_beam_pos_nr profile_id\=18 mode\=fixed init_quad_pos\=1 init_sub_quad_pos\=0 test_type\=SRS
# ...    multi_path_config\=true num_of_nlos_paths\=1 azimuth\=-30 zenith\=-15 srs_transmit_power_per_port\=-320,-320,-250,-250
# ${PROFILE19}    ul_mimo_srs_beam_pos_nr profile_id\=19 mode\=fixed init_quad_pos\=2 init_sub_quad_pos\=0 test_type\=SRS
# ...    multi_path_config\=true num_of_nlos_paths\=1 azimuth\=-35 zenith\=-26 srs_transmit_power_per_port\=-320,-320,-250,-250
# ${PROFILE20}    ul_mimo_srs_beam_pos_nr profile_id\=20 mode\=fixed init_quad_pos\=2 init_sub_quad_pos\=1 test_type\=SRS
# ...    multi_path_config\=true num_of_nlos_paths\=1 azimuth\=-40 zenith\=-15 srs_transmit_power_per_port\=-320,-320,-250,-250
# ${PROFILE21}    ul_mimo_srs_beam_pos_nr profile_id\=21 mode\=fixed init_quad_pos\=2 init_sub_quad_pos\=2 test_type\=SRS
# ...    multi_path_config\=true num_of_nlos_paths\=1 azimuth\=-45 zenith\=-26 srs_transmit_power_per_port\=-320,-320,-250,-250
# ${PROFILE22}    ul_mimo_srs_beam_pos_nr profile_id\=22 mode\=fixed init_quad_pos\=2 init_sub_quad_pos\=3 test_type\=SRS
# ...    multi_path_config\=true num_of_nlos_paths\=1 azimuth\=-50 zenith\=-15 srs_transmit_power_per_port\=-320,-320,-250,-250
# ${PROFILE23}    ul_mimo_srs_beam_pos_nr profile_id\=23 mode\=fixed init_quad_pos\=0 init_sub_quad_pos\=0 test_type\=SRS
# 
# ...    multi_path_config\=true num_of_nlos_paths\=1 azimuth\=57 zenith\=-22 srs_transmit_power_per_port\=-320,-320,-250,-250
# ${PROFILE24}    ul_mimo_srs_beam_pos_nr profile_id\=24 mode\=fixed init_quad_pos\=0 init_sub_quad_pos\=1 test_type\=SRS
# ...    multi_path_config\=true num_of_nlos_paths\=1 azimuth\=47 zenith\=-19 srs_transmit_power_per_port\=-320,-320,-250,-250
# ${PROFILE25}    ul_mimo_srs_beam_pos_nr profile_id\=25 mode\=fixed init_quad_pos\=0 init_sub_quad_pos\=2 test_type\=SRS
# ...    multi_path_config\=true num_of_nlos_paths\=1 azimuth\=37 zenith\=-22 srs_transmit_power_per_port\=-320,-320,-250,-250
# ${PROFILE26}    ul_mimo_srs_beam_pos_nr profile_id\=26 mode\=fixed init_quad_pos\=0 init_sub_quad_pos\=3 test_type\=SRS
# ...    multi_path_config\=true num_of_nlos_paths\=1 azimuth\=27 zenith\=-19 srs_transmit_power_per_port\=-320,-320,-250,-250
# ${PROFILE27}    ul_mimo_srs_beam_pos_nr profile_id\=27 mode\=fixed init_quad_pos\=3 init_sub_quad_pos\=0 test_type\=SRS
# ...    multi_path_config\=true num_of_nlos_paths\=1 azimuth\=17 zenith\=-22 srs_transmit_power_per_port\=-320,-320,-250,-250
# ${PROFILE28}    ul_mimo_srs_beam_pos_nr profile_id\=28 mode\=fixed init_quad_pos\=3 init_sub_quad_pos\=1 test_type\=SRS
# ...    multi_path_config\=true num_of_nlos_paths\=1 azimuth\=7 zenith\=-19 srs_transmit_power_per_port\=-320,-320,-250,-250
# ${PROFILE29}    ul_mimo_srs_beam_pos_nr profile_id\=29 mode\=fixed init_quad_pos\=3 init_sub_quad_pos\=2 test_type\=SRS
# ...    multi_path_config\=true num_of_nlos_paths\=1 azimuth\=-3 zenith\=-22 srs_transmit_power_per_port\=-320,-320,-250,-250
# ${PROFILE30}    ul_mimo_srs_beam_pos_nr profile_id\=30 mode\=fixed init_quad_pos\=3 init_sub_quad_pos\=3 test_type\=SRS
# ...    multi_path_config\=true num_of_nlos_paths\=1 azimuth\=-13 zenith\=-19 srs_transmit_power_per_port\=-320,-320,-250,-250
# ${PROFILE31}    ul_mimo_srs_beam_pos_nr profile_id\=31 mode\=fixed init_quad_pos\=1 init_sub_quad_pos\=0 test_type\=SRS
# ...    multi_path_config\=true num_of_nlos_paths\=1 azimuth\=-23 zenith\=-22 srs_transmit_power_per_port\=-320,-320,-250,-250
# ${PROFILE32}    ul_mimo_srs_beam_pos_nr profile_id\=32 mode\=fixed init_quad_pos\=1 init_sub_quad_pos\=1 test_type\=SRS
# ...    multi_path_config\=true num_of_nlos_paths\=1 azimuth\=-33 zenith\=-19 srs_transmit_power_per_port\=-320,-320,-250,-250
# ${PROFILE33}    ul_mimo_srs_beam_pos_nr profile_id\=33 mode\=fixed init_quad_pos\=1 init_sub_quad_pos\=2 test_type\=SRS
# ...    multi_path_config\=true num_of_nlos_paths\=1 azimuth\=-43 zenith\=-22 srs_transmit_power_per_port\=-320,-320,-250,-250
# ${PROFILE34}    ul_mimo_srs_beam_pos_nr profile_id\=34 mode\=fixed init_quad_pos\=2 init_sub_quad_pos\=3 test_type\=SRS
# ...    multi_path_config\=true num_of_nlos_paths\=1 azimuth\=-53 zenith\=-19 srs_transmit_power_per_port\=-320,-320,-250,-250
# ${PROFILE35}    ul_mimo_srs_beam_pos_nr profile_id\=35 mode\=fixed init_quad_pos\=2 init_sub_quad_pos\=0 test_type\=SRS
# ...    multi_path_config\=true num_of_nlos_paths\=1 azimuth\=-63 zenith\=-22 srs_transmit_power_per_port\=-320,-320,-250,-250
# 
# *** Test Cases ***
# CB009235_B_B201_CASE20_dlMuAware_dlMuPairingPrbRatio_algo_and_bundary_value_check
#     Step1:Commission the above configuration on WebUI
#     Step2:attach 68 ues at 34 pos
#     Step3:Do Traffic for dlMuPairingPrbRatio100 benchmark
#     Step4:Online change dlMuPairingPrbRatio into 70
# 	Step5:Online change dlMuPairingPrbRatio into 51
# 	Step6:Online change dlMuPairingPrbRatio into 30
# 	Step7:Online change dlMuPairingPrbRatio into 0
# 	#Step8:Detach all UEs
# 
# *** Keywords ***
# Step1:Commission the above configuration on WebUI
#     Start Capture GNB and AP Syslog in 'Step1_before_onair' File
# 	${CONFIG_DIR_PATH}    Set Variable    ${CONFIG_DIR_PATH}/${SW_BRANCH}
#     change_iphy_rru_version    ${CONFIG_DIR_PATH}${/}WTS${/}${AIRPHONE_NAME}
# 	#change_iphy_rru_version    ${CONFIG_DIR_PATH}${/}${AIRPHONE_NAME}
#     modify_swconfig_by_CB008322    ${CURDIR}/config/${SW_BRANCH}${/}SCF${/}${SCFC_NAME}
# 	#Add RD
#     ${scfc_path}    Set Variable    ${TEST_LOG_DIRECTORY()}${/}scfc.xml
#     copy_file    ${CONFIG_DIR_PATH}${/}SCF${/}${SCFC_NAME}    ${scfc_path}
# 	#del_elements_from_xml    xml_path=${scfc_path}    parameter=lteToNrFrameShift
#     ${modify_list}    create list
#     ...      ${actMuAwareTdSch}    ${dlMuAwareCorrThd}    ${dlMuAwarePrbRatio}    ${dlMuMaxNumLayerPerMuRbg}    ${dlMuMimoCorrThd}
#     ...      ${dlMuMimoCqiThd}    ${dlMuMimoRankAdaption}    ${dlMuMimoSpectralEffThd}    ${dlMuMimoTaperingH}    ${dlMuMimoTaperingV}
#     ...      ${dlMuPairingPrbRatio}    ${miNrCellUtilization}
# 	#...      ${cellDepType}    ${chBw}    ${dlMimoMode}    ${nrCellType}    ${actUeCsirsCoexistCellCsirs}
# 	#...      ${actCsirsMultiplexing}    ${actDlSrsBm}    ${actUlSrsBm}    ${actUlClosedLoopPwrCtrl}    ${actCDrx}    ${actFdmScheduling}
#    	#...      ${frameStructureType}    ${guardPeriodLength}    ${ulDlDataSlotRatio}    ${prachConfigurationIndex}
# 	#...      ${srsUePeriodicity}    ${cSRS}    ${bSRS}     ${srsPowerThresholdForDlBm}
# 	#...      ${srsTypeAllocForDlBm}
# 	#...      ${actDlSrsSubbandBm}    ${bfSubbandSize}    ${maxNumUeSrs}    ${srsQualityThreshold}
# 	#...      ${dllaDeltaCqiMax}    ${dllaDeltaCqiMin}    ${dllaDeltaCqiStepdown}    ${actIncreasedFdmUsersPerSlot}    ${actDlMuMimoEnh}
# 	#...      ${actCsirsBeamPowerBalance}    ${comb}    ${actUl256Qam}    ${actDl256Qam}    ${bwp_profile5}    ${bwp_profile52}
# 	#...      ${maxNumPdschAllocationPerSlot}    ${maxNumPuschAllocationPerSlot}    ${prbRatioHysteresis}    ${prbRatioThreshold}
#     modify_xml    ${scfc_path}    ${scfc_path}    ${modify_list}
#     Modify TL VM And AP SCTP Configuration
#     Get and Update BSR File    par_of_bsr_name=BSR_AQQL_6_H6_ALN60_ARP60_N01_COVERAGE_00392_00001
# 	#Get and Update BSR File    par_of_bsr_name=BSR_AQQL_6_H6_ALN60_ARP60_P11_COVERAGE_00776_00001
#     #Add L2PS Deubg Logs	
# 	#Perform Full Commission And Reach Onair With Log    ${scfc_path}    ${CONFIG_DIR_PATH}${/}${WTS_NAME}    reset_after_commission=${False}
# 	Perform Full Commission And Reach Onair With Log    ${scfc_path}    ${CURDIR}/config/${SW_BRANCH}${/}WTS${/}${WTS_NAME}
#     ...    reset_after_commission=${False}
#     #Prepare gnb onair
# 	${save_log}=    Set Variable    ${TEST_LOG_DIRECTORY()}Step1_before_onair
#     [Teardown]    Stop Capture GNB and AP Syslog in 'Step1_before_onair' File
# 
# modify_swconfig_by_CB008322
#     comment     https://confluence.ext.net.nokia.com/pages/viewpage.action?spaceKey=AirPhoneWTS&title=AirPhone+Alignment+to+gNB+L1L2+Interface
#     [Arguments]    ${scfc_file}
# 	${local_save_path}=     Download All Common Config Files From Golden Server
# 	${path_gnb}=            Find Match GNB swconfig Golden Files    ${scfc_file}    ${local_save_path}
# 	${path_ap}=             Find Match AP swconfig Golden Files    ${scfc_file}     ${local_save_path}
#     setup_txt    src_file=${path_gnb}    save_path=${TEST_LOG_DIRECTORY()}${/}swconfig_gnb_ini.txt
# 	add_txt_node   0x9D0000:15        #as PM counter period update to 15/15=1min, 0x340000 was replaced by 0x9D0000
# 	#add_txt_node    0x580789:0x1       #rdEnableNiddFor8322
# 	add_txt_node    0x580776:0x1       #rdDlMuSbBfMode,This flag is used to control DL MU-MIMO interworking with subband BWVs
# 	add_txt_node    0x58077e:1   #This R&D parameter enables ttiTrace for DL Mu aware scheduling information
#     add_txt_node    0x580539:9   #Num UE threshold,to collect trace
# 	add_txt_node    0x600018:0        #set rdUlUpFragmentationEnable false to avoid crash
#     teardown_txt
# 	setup_txt    src_file=${path_ap}    save_path=${TEST_LOG_DIRECTORY()}${/}swconfig_ap_ini.txt
#     teardown_txt
#     GNB Upload Swconfig           ${TEST_LOG_DIRECTORY()}${/}swconfig_gnb_ini.txt
#     airphone_upload_swconfig      ${TEST_LOG_DIRECTORY()}${/}swconfig_ap_ini.txt
# 
# Step2:attach 68 ues at 34 pos
#     Start Capture GNB and AP Syslog in 'Step2_attach' File
# 	${save_log}=    Set Variable    ${TEST_LOG_DIRECTORY()}Step2_attach
#     Attach '${UE_NUM}' SA UEs
# 	Create SRS_pos profile
# 	set '${UE_NUM}' SA UEs Pos
# 	Start GNB Ttitrace With Streaming Mode
# 	Wait Throughput Timer    1
# 	${pacp}=    Stop GNB Ttitrace With Streaming Mode    save_path=${save_log}
#     Decoder Tttirace From Pcap To Csv    ${pacp}    ${save_log}/tti
#     airphone_collect_egate_log_files      ${TEST_LOG_DIRECTORY()}Step2_attach   unzip=TRUE
# 	${rnti_sa_list}    file match all   ${TEST_LOG_DIRECTORY()}${/}Step2_attach${/}/egate_console.log.001   crnti: (\\d+)
# 	#${rnti_nsa_list}    file match all   ${TEST_LOG_DIRECTORY()}${/}Step2_attach${/}/egate_console.log.001   newUE-Identity (\\d+)
# 	#Set test Variable	 ${rnti_5} 	${rnti_nsa_list[0]}
#     [Teardown]    Stop Capture GNB and AP Syslog in 'Step2_attach' File
# 
# Attach '${UE_NUM_SA}' SA UEs
#     : FOR    ${num}    IN RANGE    1    ${UE_NUM_SA}+1
#     \    Attach SA ue with capability    ${num}    CA_P2_8x4_t2r4_n2
# 	\    ${gw_pdu_r}    evaluate    ${num}%10+1
# 	\    airphone_set_traffic_type   ${num}    ${gw_pdu_r}    internal
# 	\    Airphone Pdu Session Setup    ${num}    ${gw_pdu_r}    1    ${gw_pdu_r}
# 	\    Wait Throughput Timer    0.1
# 
# Create SRS_pos profile
#     : FOR    ${num}    IN RANGE    2    36    #34pos
#     \    airphone_execute_egate_command    ${PROFILE${num}}
# 
# set '${UE_NUM}' SA UEs Pos   #per position 2ues
#     log to console    ste ues pos
#     : FOR    ${num}    IN RANGE    1    35
#     \    ${num_r}    evaluate    ${num}+1
#     \    airphone_execute_egate_command    ue_testmode_set_nr id\=${num} testmode\=ul_mimo_srs_beam_pos action\=activate profile_id\=${num_r}
#     : FOR    ${num}    IN RANGE    35    69
#     \    ${num_r}    evaluate    ${num}-33
#     \    airphone_execute_egate_command    ue_testmode_set_nr id\=${num} testmode\=ul_mimo_srs_beam_pos action\=activate profile_id\=${num_r}
# 
# 
# Step3:Do Traffic for dlMuPairingPrbRatio100 benchmark
#     Start Capture GNB and AP Syslog in 'Step3_dlMuPairingPrbRatio100' File
# 	Log To Console    \n\r==================the beginning of traffic commands==================\n\r
# 	${save_log}=    Set Variable    ${TEST_LOG_DIRECTORY()}Step3_dlMuPairingPrbRatio100
# 	: FOR    ${i}    IN RANGE    1    69
# 	\   ${gw_pdu_r}    evaluate    ${i}%10+1
#     \    Airphone SA Start Data Traffic    ${i}    DL    50k    trf_id=1    pdu_id=${gw_pdu_r}    duration=${3600}
# 	\    Airphone SA Start Data Traffic    ${i}    UL    50M    trf_id=1    pdu_id=${gw_pdu_r}    duration=${3600}
# 	Log To Console    \n\r==================the ending of traffic commands==================\n\r    
#     Start GNB Ttitrace With Streaming Mode
# 	Wait Throughput Timer    0.5
# 	${pacp}=    Stop GNB Ttitrace With Streaming Mode    save_path=${save_log}
#     Decoder Tttirace From Pcap To Csv    ${pacp}    ${save_log}/tti
# 	run keyword and continue on failure    check_log_with_au2anlysis
#     ...    ini_path=${CURDIR}/ini/case02_tti_dl.ini    log_need_to_check=i    save_log_directory=${save_log}
# 	${tput_MuCounter}    get DL UL tput from PM counter and get MU counter    ${save_log}
#     #run keyword and continue on failure    should be true    ${tput}[0]>850
# 	#run keyword and continue on failure    should be true    ${tput}[1]>130
#     [Teardown]    run keyword and continue on failure    Stop Capture GNB and AP Syslog in 'Step3_dlMuPairingPrbRatio100' File
# 
# Step4:Online change dlMuPairingPrbRatio into 70
# 	Start Capture GNB and AP Syslog in 'Step4_dlMuPairingPrbRatio70' File
# 	COAM.Connect To    bts_host=192.168.255.129    bts_port=443    use_ssl=True    name=online
#     COAM.perform_parameter_recommissioning    dist_name=MRBTS-1/NRBTS-1/NRCELL-1/NRDLMUMIMO-1    parameter=dlMuPairingPrbRatio
#     ...    operation=update    value=70    skip_parameter_relation_errors=True    should_activate=True    connection=online
#     Wait until keyword succeeds    600s    30s    Verify BTS Is Onair
# 	Start GNB Ttitrace With Streaming Mode
#     Wait Throughput Timer    0.5
#     ${save_log}=    Set Variable    ${TEST_LOG_DIRECTORY()}Step4_dlMuPairingPrbRatio70
#     ${pacp}=    Stop GNB Ttitrace With Streaming Mode    save_path=${save_log}
#     Wait Throughput Timer    2
# 	Decoder Tttirace From Pcap To Csv    ${pacp}    ${save_log}/tti
# 	run keyword and continue on failure    check_log_with_au2anlysis
#     ...    ini_path=${CURDIR}/ini/case02_tti_dl.ini    log_need_to_check=i    save_log_directory=${save_log}
# 	${tput_MuCounter}    get DL UL tput from PM counter and get MU counter    ${save_log}
#     [Teardown]    run keyword and continue on failure    Stop Capture GNB and AP Syslog in 'Step4_dlMuPairingPrbRatio70' File
# 
# Step5:Online change dlMuPairingPrbRatio into 51
# 	Start Capture GNB and AP Syslog in 'Step5_dlMuPairingPrbRatio51' File
# 	COAM.Connect To    bts_host=192.168.255.129    bts_port=443    use_ssl=True    name=online
#     COAM.perform_parameter_recommissioning    dist_name=MRBTS-1/NRBTS-1/NRCELL-1/NRDLMUMIMO-1    parameter=dlMuPairingPrbRatio
#     ...    operation=update    value=51    skip_parameter_relation_errors=True    should_activate=True    connection=online
#     Wait until keyword succeeds    600s    30s    Verify BTS Is Onair
# 	Start GNB Ttitrace With Streaming Mode
#     Wait Throughput Timer    0.5
#     ${save_log}=    Set Variable    ${TEST_LOG_DIRECTORY()}Step5_dlMuPairingPrbRatio51
#     ${pacp}=    Stop GNB Ttitrace With Streaming Mode    save_path=${save_log}
#     Wait Throughput Timer    2
# 	Decoder Tttirace From Pcap To Csv    ${pacp}    ${save_log}/tti
# 	run keyword and continue on failure    check_log_with_au2anlysis
#     ...    ini_path=${CURDIR}/ini/case02_tti_dl.ini    log_need_to_check=i    save_log_directory=${save_log}
# 	${tput_MuCounter}    get DL UL tput from PM counter and get MU counter    ${save_log}
#     [Teardown]    run keyword and continue on failure    Stop Capture GNB and AP Syslog in 'Step5_dlMuPairingPrbRatio51' File
# 
# Step6:Online change dlMuPairingPrbRatio into 30
# 	Start Capture GNB and AP Syslog in 'Step6_dlMuPairingPrbRatio30' File
# 	COAM.Connect To    bts_host=192.168.255.129    bts_port=443    use_ssl=True    name=online
#     COAM.perform_parameter_recommissioning    dist_name=MRBTS-1/NRBTS-1/NRCELL-1/NRDLMUMIMO-1    parameter=dlMuPairingPrbRatio
#     ...    operation=update    value=30    skip_parameter_relation_errors=True    should_activate=True    connection=online
#     Wait until keyword succeeds    600s    30s    Verify BTS Is Onair
# 	Start GNB Ttitrace With Streaming Mode
#     Wait Throughput Timer    0.5
#     ${save_log}=    Set Variable    ${TEST_LOG_DIRECTORY()}Step6_dlMuPairingPrbRatio30
#     ${pacp}=    Stop GNB Ttitrace With Streaming Mode    save_path=${save_log}
#     Wait Throughput Timer    2
# 	Decoder Tttirace From Pcap To Csv    ${pacp}    ${save_log}/tti
# 	run keyword and continue on failure    check_log_with_au2anlysis
#     ...    ini_path=${CURDIR}/ini/case02_tti_dl.ini    log_need_to_check=i    save_log_directory=${save_log}
# 	${tput_MuCounter}    get DL UL tput from PM counter and get MU counter    ${save_log}
#     [Teardown]    run keyword and continue on failure    Stop Capture GNB and AP Syslog in 'Step6_dlMuPairingPrbRatio30' File
# 
# Step7:Online change dlMuPairingPrbRatio into 0
# 	Start Capture GNB and AP Syslog in 'Step7_dlMuPairingPrbRatio0' File
# 	COAM.Connect To    bts_host=192.168.255.129    bts_port=443    use_ssl=True    name=online
#     COAM.perform_parameter_recommissioning    dist_name=MRBTS-1/NRBTS-1/NRCELL-1/NRDLMUMIMO-1    parameter=dlMuPairingPrbRatio
#     ...    operation=update    value=0    skip_parameter_relation_errors=True    should_activate=True    connection=online
#     Wait until keyword succeeds    600s    30s    Verify BTS Is Onair
# 	Start GNB Ttitrace With Streaming Mode
#     Wait Throughput Timer    0.5
#     ${save_log}=    Set Variable    ${TEST_LOG_DIRECTORY()}Step7_dlMuPairingPrbRatio0
#     ${pacp}=    Stop GNB Ttitrace With Streaming Mode    save_path=${save_log}
#     Wait Throughput Timer    2
# 	Decoder Tttirace From Pcap To Csv    ${pacp}    ${save_log}/tti
# 	run keyword and continue on failure    check_log_with_au2anlysis
#     ...    ini_path=${CURDIR}/ini/case02_tti_dl.ini    log_need_to_check=i    save_log_directory=${save_log}
# 	${tput_MuCounter}    get DL UL tput from PM counter and get MU counter    ${save_log}
#     [Teardown]    run keyword and continue on failure    Stop Capture GNB and AP Syslog in 'Step7_dlMuPairingPrbRatio0' File
# 
# Step8:Detach all UEs
#     Start capture GNB and AP Syslog in 'Step8_Detach_all_UEs' File
#     : FOR    ${i}    IN RANGE    1    69
#     \    Detach UE    ${i}
#     [Teardown]    Stop capture GNB and AP Syslog in 'Step8_Detach_all_UEs' File
# 
# Add L2PS Deubg Logs
#     ${debuglogs}    create list    level=DBG\n    L2.L2_PS.DEBUG=1\n    L2.L2_PS.DL.SUBBAND_BEAMFORMING=1\n    L2.L2_PS.SRS_BASED_BM=1\n
# 	Active L2ps Feature Debug Traces    ${debuglogs}
# 	TAF_SSH.connect to    192.168.255.1   toor4nsn    oZPS0POrRieRtu   alias=bsh
# 	TAF_SSH.execute    rm /ffs/run/HashContainer*    connection=bsh
# 
# get DL UL tput from PM counter and get MU counter
#     [Arguments]    ${log_dir}    ${cell}=1
#     ${remaining_time}=    get_counter_file_remaining_time    counter_refresh_period=1min
#     ${remaining_time}     evaluate    ${remaining_time}+60
#     Wait Throughput Timer    ${remaining_time}
#     ${PM_counter_file}=    download_latest_pmcounter    local_path=${log_dir}${/}
#     ${PM_counter_DL_value}=    get_counter_value_from_counter_file
#     ...   counter_file=${PM_counter_file}
#     ...   counter_id=M55309C12001
#     ...   cell_id=${cell}
#     ${DL_throughput}    evaluate    ${PM_counter_DL_value}*8/1024/1024
# 	${PM_counter_UL_value}=    get_counter_value_from_counter_file
#     ...   counter_file=${PM_counter_file}
#     ...   counter_id=M55309C12002
#     ...   cell_id=${cell}
#     ${UL_throughput}    evaluate    ${PM_counter_UL_value}*8/1024/1024
# 	${PM_counter_16layers}=    get_counter_value_from_counter_file    counter_file=${PM_counter_file}    counter_id=M55308C34023    cell_id=${cell}
# 	${PM_counter_14layers}=    get_counter_value_from_counter_file    counter_file=${PM_counter_file}    counter_id=M55308C34021    cell_id=${cell}
# 	${PM_counter_12layers}=    get_counter_value_from_counter_file    counter_file=${PM_counter_file}    counter_id=M55308C34019    cell_id=${cell}
# 	${PM_counter_10layers}=    get_counter_value_from_counter_file    counter_file=${PM_counter_file}    counter_id=M55308C34017    cell_id=${cell}
# 	${PM_counter_8layers}=    get_counter_value_from_counter_file    counter_file=${PM_counter_file}    counter_id=M55308C34011    cell_id=${cell}
# 	${PM_counter_6layers}=    get_counter_value_from_counter_file    counter_file=${PM_counter_file}    counter_id=M55308C34009    cell_id=${cell}
# 	${PM_counter_4layers}=    get_counter_value_from_counter_file    counter_file=${PM_counter_file}    counter_id=M55308C34007    cell_id=${cell}
#     [Return]    ${DL_throughput}    ${UL_throughput}    ${PM_counter_16layers}    ${PM_counter_14layers}    ${PM_counter_12layers}
# 	...    ${PM_counter_10layers}    ${PM_counter_8layers}    ${PM_counter_6layers}   ${PM_counter_4layers}
# 
# Stop UE DL Traffic
#     [Arguments]    ${ue_id}
#     airphone_sa_stop_data_traffic    ${ue_id}    DL
# 	
# Detach UE
#     [Arguments]    ${ue_id} 
#     airphone_sa_detach    ue_id=${ue_id}    timeout=30