*** Settings ***
Documentation     Author: zhaoyang.xu@nokia-sbell.com

Suite Setup       Common Suite Setup
#Suite Teardown    Common Suite Teardown
Test Setup        Common Test Setup
Test Teardown     Common Test Teardown
Force Tags        CLOUD_5G_I_MP_AP_LO    AP    SBTS00    RAN_5G_TDD    RAN_5G    
Test Timeout      120 minutes
Resource          ../../resources/sg11/internal_resource/robot/modify_configuration.robot
Resource          ../../resources/sg11/internal_resource/robot/internal_ap_operate.robot
Resource          ../../resources/sg11/internal_resource/robot/internal_gnb_operate.robot
Resource          ../../resources/sg11/internal_resource/robot/internal_capture_log.robot
Library           taf.transport.ssh    WITH NAME    TAF_SSH
Library           ta_a2a

*** Variables ***
${CONFIG_DIR_PATH}    ${CURDIR}/../../resources/sg11/internal_resource/config/
${SCFC_NAME}          SCFC_8322_E1_case33_MP_AQQL_1S_1CC.xml
${AIRPHONE_NAME}      IPHY_AQQL_1CELL_APLO_MUMIMO_8_4.xml
${WTS_NAME}           wts_8322_1cell_SA_NSA.lua
@{LOG_NAME_LIST}      egatelog    gnb_snapshot
${cellDepType}                    text|SA+NSA|//*[@name\="cellDepType"]
${chBw}                           text|100MHz|//*[@name\="chBw"]
${dlMimoMode}                     text|8x4 Closed Loop Spatial Multiplexing|//*[@name\="dlMimoMode"]
${nrCellType}                     text|8DL4UL|//*[@name\="nrCellType"]
${actUeCsirsCoexistCellCsirs}     text|true|//*[@name\="actUeCsirsCoexistCellCsirs"]
${actCsirsMultiplexing}           text|true|//*[@name\="actCsirsMultiplexing"]
${actDlSrsBm}                     text|true|//*[@name\="actDlSrsBm"]
${actUlSrsBm}                     text|true|//*[@name\="actUlSrsBm"]
${actDlSrsSubbandBm}              text|true|//*[@name\="actDlSrsSubbandBm"]
${actSrsBeamFallbackByRetrx}      text|true|//*[@name\="actSrsBeamFallbackByRetrx"]
${actUlClosedLoopPwrCtrl}         text|disabled|//*[@name\="actUlClosedLoopPwrCtrl"]
${actCDrx}                        text|false|//*[@name\="actCDrx"]
${actFdmScheduling}               text|true|//*[@name\="actFdmScheduling"]
${actDl256Qam}                    text|false|//*[@name\="actDl256Qam"]
${actUl256Qam}                    text|false|//*[@name\="actUl256Qam"]
${actIncreasedFdmUsersPerSlot}    text|true|//*[@name\="actIncreasedFdmUsersPerSlot"]
${frameStructureType}             text|semiStatic|//*[@name\="frameStructureType"]
${guardPeriodLength}              text|2Symbols|//*[@name\="guardPeriodLength"]
${tdLteUlDlConfig}                text|tdLteConfig2|//*[@name\="tdLteUlDlConfig"]
${ulDlDataSlotRatio}              text|3/7|//*[@name\="ulDlDataSlotRatio"]
${prachConfigurationIndex}        text|98|//*[@name\="prachConfigurationIndex"]
${srsUePeriodicity}               text|slots80|//*[@name\="srsUePeriodicity"]
${cSRS}                           text|62|//*[@name\="cSRS"]
${bSRS}                           text|1|//*[@name\="bSRS"]
${srsPowerThresholdForDlBm}       text|-1200|//*[@name\="srsPowerThresholdForDlBm"]
${srsTypeAllocForDlBm}            text|antenna switching or codebook|//*[@name\="srsTypeAllocForDlBm"]
${bfSubbandSize}                  text|16 PRBs|//*[@name\="bfSubbandSize"]
${maxNumUeSrs}                    text|4|//*[@name\="maxNumUeSrs"]
#${srsQualityThreshold}            text|-1150|//*[@name\="srsQualityThreshold"]
${seHysteresis}                   text|50|//*[@name\="seHysteresis"]
${srsSinrThreshold}                text|-60|//*[@name\="srsSinrThreshold"]
${actCustomBsr}                   text|true|//*[@name\="actCustomBsr"]
${customBeamSetName}              text|BSR_AQQL_6_H6_ALN60_ARP60_N01_COVERAGE_00392_00001|//*[@name\="customBeamSetName"]
${tiltOffset}                     text|-1|//*[@name\="tiltOffset"]
${nrBtsBeamRefinementP2}          text|true|//*[@name\="nrBtsBeamRefinementP2"]
${maxCsirsNumber}                 text|2|//*[@name\="maxCsirsNumber"]
${csirsPower}                     text|0|//*[@name\="csirsPower"]
${miNrSrsQuality}                 text|15min|//*[@name\="miNrSrsQuality"]
${miNrBeamforming2}               text|15min|//*[@name\="miNrBeamforming2"]
${miNrDlHarq}                     text|15min|//*[@name\="miNrDlHarq"]
${miNrUlHarq}                     text|15min|//*[@name\="miNrUlHarq"]
${miNrDlHarqLowSEMCS}             text|15min|//*[@name\="miNrDlHarqLowSEMCS"]
${miNrUlHarqLowSEMCS}             text|15min|//*[@name\="miNrUlHarqLowSEMCS"]
${miNrUlHarqOne}                  text|15min|//*[@name\="miNrUlHarqOne"]
${csirsNumberWithinReportPeriod_Set1}     text|2|//*[@name\="csirsNumberWithinReportPeriod_Set1"]

#CB008305
${actDlMuMimoEnh}                 text|true|//*[@name\="actDlMuMimoEnh"]
${dlMuMimoCorrThd}                text|50|//*[@name\="dlMuMimoCorrThd"]
${dlMuMimoCqiThd}                 text|1|//*[@name\="dlMuMimoCqiThd"]
${dlMuMimoSpectralEffThd}         text|10|//*[@name\="dlMuMimoSpectralEffThd"]
${maxNumLayerPerMuRbg}            text|16|//*[@name\="dlMuMaxNumLayerPerMuRbg"]
${dlMuMimoRankAdaption}           text|adaptive|//*[@name\="dlMuMimoRankAdaption"]
${dlMuMimoTaperingH}              text|30dB|//*[@name\="dlMuMimoTaperingH"]
${dlMuMimoTaperingV}              text|20dB|//*[@name\="dlMuMimoTaperingV"]

#CB008360
${actUlMuMimo}                            text|true|//*[@name\="actUlMuMimo"]
${ulMaxMuMimoLayer}                       text|2|//*[@name\="ulMaxMuMimoLayer"]
${ulMinPrbThreshold}                      text|50|//*[@name\="ulMinPrbThreshold"]
${ulMuMimoPrbThresholdAbsolute}           text|20|//*[@name\="ulMuMimoPrbThresholdAbsolute"]
${ulMuMimoCorrThd}                        text|50|//*[@name\="ulMuMimoCorrThd"]
${ulMuMimoSinrThd}                        text|5|//*[@name\="ulMuMimoSinrThd"]
${ulMuMimoSpectralEffThd}                 text|10|//*[@name\="ulMuMimoSpectralEffThd"]
${actUlMuMimoTapering}                    text|true|//*[@name\="actUlMuMimoTapering"]
${ulMuMimoTaperingH}                      text|20dB|//*[@name\="ulMuMimoTaperingH"]
${ulMuMimoTaperingV}                      text|0dB|//*[@name\="ulMuMimoTaperingV"]
${ulMuMimoLinkAdaptionSwitch}             text|MU-SINR estimation|//*[@name\="ulMuMimoLinkAdaptionSwitch"]


${bwp_profile7}                   text|MRBTS-1/NRBTS-1/BWP_PROFILE-6|//*[@name\="cellBwpList"]/item[1]/*[@name\="bwpDN"]
${bwp_profile77}                  text|MRBTS-1/NRBTS-1/BWP_PROFILE-67|//*[@name\="cellBwpList"]/item[2]/*[@name\="bwpDN"]

${par_of_bsr_name}                BSR_AQQL_6_H6_ALN60_ARP60_N01_COVERAGE_00392_00001

${PROFILE2}    ul_mimo_srs_beam_pos_nr profile_id\=2 mode\=fixed init_quad_pos\=0 init_sub_quad_pos\=0 test_type\=SRS
...    multi_path_config\=true num_of_nlos_paths\=1 azimuth\=50 zenith\=40 srs_transmit_power_per_port\=-270,-270,-230,-230
${PROFILE3}    ul_mimo_srs_beam_pos_nr profile_id\=3 mode\=fixed init_quad_pos\=1 init_sub_quad_pos\=0 test_type\=SRS
...    multi_path_config\=true num_of_nlos_paths\=1 azimuth\=-20 zenith\=40 srs_transmit_power_per_port\=-270,-270,-230,-230
${PROFILE4}    ul_mimo_srs_beam_pos_nr profile_id\=4 mode\=fixed init_quad_pos\=2 init_sub_quad_pos\=0 test_type\=SRS
...    multi_path_config\=true num_of_nlos_paths\=1 azimuth\=-50 zenith\=-30 srs_transmit_power_per_port\=-270,-270,-230,-230
${PROFILE5}    ul_mimo_srs_beam_pos_nr profile_id\=5 mode\=fixed init_quad_pos\=3 init_sub_quad_pos\=0 test_type\=SRS
...    multi_path_config\=true num_of_nlos_paths\=1 azimuth\=20 zenith\=-30 srs_transmit_power_per_port\=-270,-270,-230,-230

${PROFILE6}    ul_mimo_srs_beam_pos_nr profile_id=6 mode=fixed init_quad_pos=1 init_sub_quad_pos=1 test_type=SRS
...                multi_path_config=true num_of_nlos_paths=1 azimuth=-30 zenith=5 srs_transmit_power_per_port=-600,-600,-600,-600

${UE_NUM}         10
${PDU_ID}         1
${GW_ID}          1
${SLICE_ID}       1

*** Test Cases ***
CNI_113494_Case12_Beam_type_iBLER_counters_when_all_types_of_BF_is_activated_in_cell
    Step1:Commission the above configuration on WebUI
    Step2:Attach UE
	Step3:DL and UL data transfer for UE
	Step4:Trigger Continues bler for UE


*** Keywords ***
Step1:Commission the above configuration on WebUI
    Start capture GNB and AP Syslog in 'Step1_before_onair' File
	${CONFIG_DIR_PATH}    Set Variable    ${CONFIG_DIR_PATH}/${SW_BRANCH}
    change_iphy_rru_version    ${CONFIG_DIR_PATH}${/}${AIRPHONE_NAME}

    modify_swconfig_by_CB008322    ${CONFIG_DIR_PATH}${/}${SCFC_NAME}
    ${scfc_path}    Set Variable    ${TEST_LOG_DIRECTORY()}${/}scfc.xml
    copy_file    ${CONFIG_DIR_PATH}/${SCFC_NAME}    ${scfc_path}
    ${modify_list}    create list
    ...    ${cellDepType}    ${chBw}    ${dlMimoMode}    ${nrCellType}    ${actUeCsirsCoexistCellCsirs}    ${actCsirsMultiplexing}
    ...    ${actDlSrsBm}    ${actUlSrsBm}    ${actDlSrsSubbandBm}    ${actUlClosedLoopPwrCtrl}    ${actCDrx}    ${actFdmScheduling}
    ...    ${actDl256Qam}    ${actUl256Qam}    ${actIncreasedFdmUsersPerSlot}    ${frameStructureType}
    ...    ${guardPeriodLength}    ${tdLteUlDlConfig}    ${ulDlDataSlotRatio}    ${prachConfigurationIndex}
    ...    ${srsUePeriodicity}    ${cSRS}    ${bSRS}    ${srsPowerThresholdForDlBm}    ${srsTypeAllocForDlBm}    ${bfSubbandSize}
    ...    ${maxNumUeSrs}    ${actCustomBsr}    ${customBeamSetName}    ${actSrsBeamFallbackByRetrx}
    ...    ${tiltOffset}    ${nrBtsBeamRefinementP2}    ${maxCsirsNumber}    ${csirsPower}     ${csirsNumberWithinReportPeriod_Set1}
    ...    ${bwp_profile7}    ${bwp_profile77}    ${seHysteresis}   ${srsSinrThreshold}
    ...    ${miNrSrsQuality}    ${miNrBeamforming2}    ${miNrDlHarq}    ${miNrUlHarq}    ${miNrDlHarqLowSEMCS}    ${miNrUlHarqLowSEMCS}
	...    ${miNrUlHarqOne}
	...    ${actDlMuMimoEnh}    ${dlMuMimoCorrThd}    ${dlMuMimoCqiThd}    ${dlMuMimoSpectralEffThd}    ${maxNumLayerPerMuRbg}
	...    ${dlMuMimoRankAdaption}    ${dlMuMimoTaperingH}     ${dlMuMimoTaperingV}
	...    ${actUlMuMimo}    ${ulMaxMuMimoLayer}     ${ulMinPrbThreshold}    ${ulMuMimoPrbThresholdAbsolute} 
	...    ${ulMuMimoCorrThd}    ${ulMuMimoSinrThd}    ${ulMuMimoSpectralEffThd}    ${actUlMuMimoTapering}
	...    ${ulMuMimoTaperingH}    ${ulMuMimoTaperingV}    ${ulMuMimoLinkAdaptionSwitch}
	
    modify_xml    ${scfc_path}    ${scfc_path}    ${modify_list}
    Modify TL VM And AP SCTP Configuration
    Get and Update BSR File    ${par_of_bsr_name}
    Perform Full Commission And Reach Onair With Log    ${scfc_path}    ${CONFIG_DIR_PATH}${/}${WTS_NAME}    reset_after_commission=${False}
	[Teardown]    Stop capture GNB and AP Syslog in 'Step1_before_onair' File


modify_swconfig_by_CB008322    
    [Arguments]    ${scfc_file}
	${local_save_path}=     Download All Common Config Files From Golden Server
	${path_gnb}=            Find Match GNB swconfig Golden Files    ${scfc_file}    ${local_save_path}
	${path_ap}=             Find Match AP swconfig Golden Files    ${scfc_file}     ${local_save_path}
    setup_txt    src_file=${path_gnb}    save_path=${TEST_LOG_DIRECTORY()}${/}swconfig_gnb_ini.txt
	add_txt_node    0x9D0000:15        #as PM counter period update to 5/1=5min
	add_txt_node    0x580776:1       #rdDlMuSbBfMode
    #add_txt_node    0x5805ba:0x21    #The minimum PRB of PDSCH to allow the transmission with subband beams.
	add_txt_node    0x580717:0		# rdPdcchApplyToSeparateStreams, default=true
	add_txt_node    0x5805bf:0x20    #rdRtBeamHarqNackPercent	
	add_txt_node    0x580265:1   #rdNumberOfUeCsirsSymbol
    teardown_txt

	setup_txt    src_file=${path_ap}    save_path=${TEST_LOG_DIRECTORY()}${/}swconfig_ap_ini.txt
    teardown_txt
    GNB Upload Swconfig           ${TEST_LOG_DIRECTORY()}${/}swconfig_gnb_ini.txt
    airphone_upload_swconfig      ${TEST_LOG_DIRECTORY()}${/}swconfig_ap_ini.txt

Step2:Attach UE
    Start Collect GNB and AP Syslog in 'Step2_attach' File
    Create SRS_pos profile
    Start GNB Ttitrace With Streaming Mode	
    FOR    ${ID}   IN RANGE    1    ${UE_NUM}+1
    ${UE_ID}    SetVariable    ${ID}
    ${GW_ID}    SetVariable    ${ID}
    Airphone Sa Attach    ue_id=${UE_ID}	
    airphone_set_traffic_type    ${UE_ID}    ${PDU_ID}    internal
    Airphone Pdu Session Setup    ${UE_ID}    ${PDU_ID}    ${SLICE_ID}    ${GW_ID}
    END	
    set SA UEs Position
    Wait Throughput Timer    1
    ${pacp}=    Stop GNB Ttitrace With Streaming Mode    save_path=${TEST_LOG_DIRECTORY()}/step2_ue_attach
    Decoder Tttirace From Pcap To Csv    ${pacp}    ${TEST_LOG_DIRECTORY()}step2_ue_attach/output	
    [Teardown]    Stop Collect GNB and AP Syslog in 'Step2_attach' File


Create SRS_pos profile
    Airphone Execute Egate Command    ${PROFILE2}
    Airphone Execute Egate Command    ${PROFILE3}
    Airphone Execute Egate Command    ${PROFILE4}	
    Airphone Execute Egate Command    ${PROFILE5}
    Airphone Execute Egate Command    ${PROFILE6}	

set SA UEs Position
    Airphone Execute Egate Command    ue_testmode_set_nr id\=1 testmode\=ul_mimo_srs_beam_pos action\=activate profile_id\=2
    Airphone Execute Egate Command    ue_testmode_set_nr id\=2 testmode\=ul_mimo_srs_beam_pos action\=activate profile_id\=2	
    Airphone Execute Egate Command    ue_testmode_set_nr id\=3 testmode\=ul_mimo_srs_beam_pos action\=activate profile_id\=2	
    Airphone Execute Egate Command    ue_testmode_set_nr id\=4 testmode\=ul_mimo_srs_beam_pos action\=activate profile_id\=2
    Airphone Execute Egate Command    ue_testmode_set_nr id\=5 testmode\=ul_mimo_srs_beam_pos action\=activate profile_id\=2
    Airphone Execute Egate Command    ue_testmode_set_nr id\=6 testmode\=ul_mimo_srs_beam_pos action\=activate profile_id\=2
    Airphone Execute Egate Command    ue_testmode_set_nr id\=7 testmode\=ul_mimo_srs_beam_pos action\=activate profile_id\=2
    Airphone Execute Egate Command    ue_testmode_set_nr id\=8 testmode\=ul_mimo_srs_beam_pos action\=activate profile_id\=3
    Airphone Execute Egate Command    ue_testmode_set_nr id\=9 testmode\=ul_mimo_srs_beam_pos action\=activate profile_id\=6
    Airphone Execute Egate Command    ue_testmode_set_nr id\=10 testmode\=ul_mimo_srs_beam_pos action\=activate profile_id\=6	
	
Step3:DL and UL data transfer for UE
    Start Collect GNB and AP Syslog in 'step3_UL_DL_data' File
    FOR    ${UE_ID}    IN RANGE    1    8
    Airphone SA Start Data Traffic    ${UE_ID}    DL    175M    trf_id=1    pdu_id=${PDU_ID}    duration=${3600}
    Airphone SA Start Data Traffic    ${UE_ID}    DL    175M    trf_id=2    pdu_id=${PDU_ID}    duration=${3600}
    Airphone SA Start Data Traffic    ${UE_ID}    DL    175M    trf_id=3    pdu_id=${PDU_ID}    duration=${3600}	
    Airphone SA Start Data Traffic    ${UE_ID}    UL    150M    trf_id=1    pdu_id=${PDU_ID}    duration=${3600}
    Airphone SA Start Data Traffic    ${UE_ID}    UL    150M    trf_id=2    pdu_id=${PDU_ID}    duration=${3600}	
    END	
    #send small data to UE9 and UE10
    Airphone SA Start Data Traffic    8    DL    10M    trf_id=1    pdu_id=${PDU_ID}    duration=${3600}	
    Airphone SA Start Data Traffic    8    UL    10M    trf_id=1    pdu_id=${PDU_ID}    duration=${3600}	
    Airphone SA Start Data Traffic    9    DL    10M    trf_id=1    pdu_id=${PDU_ID}    duration=${3600}	
    Airphone SA Start Data Traffic    9    UL    10M    trf_id=1    pdu_id=${PDU_ID}    duration=${3600}	
    Airphone SA Start Data Traffic    10    DL    150M    trf_id=1    pdu_id=${PDU_ID}    duration=${3600}	
    Airphone SA Start Data Traffic    10    UL    150M    trf_id=1    pdu_id=${PDU_ID}    duration=${3600}	
	
    Wait Throughput Timer    15
    FOR    ${UE_ID}    IN RANGE    1    ${UE_NUM}+1	
    ${Dl_throughput} =    Airphone Sa Get Throughput    ue_id=${UE_ID}    direction=dl
    ${Ul_throughput} =    Airphone Sa Get Throughput    ue_id=${UE_ID}    direction=ul	
    END		
	Start GNB Ttitrace With Streaming Mode
	Wait Throughput Timer    1
    ${pacp}=    Stop GNB Ttitrace With Streaming Mode    save_path=${TEST_LOG_DIRECTORY()}/step3_UL_DL_data
    Decoder Tttirace From Pcap To Csv    ${pacp}    ${TEST_LOG_DIRECTORY()}/step3_UL_DL_data/output
	
	${remaining_time}=    get_counter_file_remaining_time    counter_refresh_period=1min
    Wait Throughput Timer    ${remaining_time}
    ${PM_counter_file}=    download_latest_pmcounter    local_path=${TEST_LOG_DIRECTORY()}/step3_UL_DL_data${/}
    Check_CNI113494_iBler_match_Legacy_counters    ${PM_counter_file}	
    [Teardown]    Stop Collect GNB and AP Syslog in 'step3_UL_DL_data' File	
	
	


Step4:Trigger Continues bler for UE
    Start Collect GNB and AP Syslog in 'Step4_bler' File
    ${save_log}=    Set Variable    ${TEST_LOG_DIRECTORY()}/Step4_bler
    Airphone Execute Egate Command    bler_testmode_nr profile_id\=8 dl_bler\=700,100,100
    Airphone Execute Egate Command    ue_testmode_set_nr id\=8 scell\=0 testmode\=bler profile_id\=5 action\=activate
    Wait Throughput Timer    15	
    Start GNB Ttitrace With Streaming Mode
    Wait '1s' for stable running
    ${pacp}=    Stop GNB Ttitrace With Streaming Mode    save_path=${save_log}
    Decoder Tttirace From Pcap To Csv    ${pacp}    ${save_log}/tti_bler
	
	${remaining_time}=    get_counter_file_remaining_time    counter_refresh_period=1min
    Wait Throughput Timer    ${remaining_time}
    ${PM_counter_file}=    download_latest_pmcounter    local_path=${TEST_LOG_DIRECTORY()}/Step4_bler${/}
    Check_CNI113494_iBler_match_Legacy_counters    ${PM_counter_file}	
	
    [Teardown]    Stop Collect GNB and AP Syslog in 'Step4_bler' File
	


Check_CNI113494_iBler_match_Legacy_counters
    [Arguments]    ${PM_counter_file}	
	Log To Console    \n---------CNI_113494_PDSCH_initial_counter----------
	Log To Console    SSB_BEAM:M55330C00043,REFINED_BEAM:M55330C00047,PMI_BEAM:M55330C00030
	Log To Console    DFTNTAP_BEAM:M55330C00036,DFTTAP_BEAM:M55330C00032,SUBBAND_BEAM:M55330C00040
	${PDSCH_INI_Counter_list}    create list   M55330C00043    M55330C00047     M55330C00030   M55330C00036    M55330C00032    M55330C00040 
    ${PDSCH_INI_All_Beam_counter_cell1}    	create list
    FOR    ${counter_id}    IN    @{PDSCH_INI_Counter_list}
    ${PDSCH_INI_cell1}    get_counter_value_from_counter_file    counter_file=${PM_counter_file}    counter_id=${counter_id}    cell_id=1    
    append to list    ${PDSCH_INI_All_Beam_counter_cell1}    ${PDSCH_INI_cell1}
	END
	Log To Console    PDSCH_INI_SSB_refined_PMI_DFTN_DFT_SUB_beam_counter_cell1:${PDSCH_INI_All_Beam_counter_cell1}
	${PDSCH_INI_counter_Sum_cell1}    Evaluate    sum(${PDSCH_INI_All_Beam_counter_cell1})	
    Log To Console    \n----------------------end-------------------------


	Log To Console    \n---------CNI_113494_PDSCH_initial_Successful_counter----------
	Log To Console    SSB_BEAM:M55330C00044,REFINED_BEAM:M55330C00048,PMI_BEAM:M55330C00031
	Log To Console    DFTNTAP_BEAM:M55330C00037,DFTTAP_BEAM:M55330C00033,SUBBAND_BEAM:M55330C00041
	${PDSCH_SUC_Counter_list}    create list   M55330C00044    M55330C00048     M55330C00031   M55330C00037    M55330C00033    M55330C00041 
    ${PDSCH_SUC_All_Beam_counter_cell1}    	create list
    FOR    ${counter_id}    IN    @{PDSCH_SUC_Counter_list}
    ${PDSCH_SUC_cell1}    get_counter_value_from_counter_file    counter_file=${PM_counter_file}    counter_id=${counter_id}    cell_id=1    
    append to list    ${PDSCH_SUC_All_Beam_counter_cell1}    ${PDSCH_SUC_cell1}
	END
	Log To Console    PDSCH_SUC_SSB_refined_PMI_DFTN_DFT_SUB_beam_counter_cell1:${PDSCH_SUC_All_Beam_counter_cell1}
	${PDSCH_SUC_counter_Sum_cell1}    Evaluate    sum(${PDSCH_SUC_All_Beam_counter_cell1})	
	Log To Console    \n----------------------end-------------------------
	

			
    Log To Console    \n---------CNI_113494_PUSCH_initial_counter------------------
	Log To Console    SSB_BEAM:M55330C00045,REFINED_BEAM:M55330C00028,DFTNTAP_BEAM:M55330C00038,DFTTAP_BEAM:M55330C00034
	${PUSCH_INI_Counter_list}    create list   M55330C00045    M55330C00028     M55330C00038   M55330C00034
    ${PUSCH_INI_All_Beam_counter_cell1}    	create list
    FOR    ${counter_id}    IN    @{PUSCH_INI_Counter_list}
    ${PUSCH_INI_cell1}    get_counter_value_from_counter_file    counter_file=${PM_counter_file}    counter_id=${counter_id}    cell_id=1    
    append to list    ${PUSCH_INI_All_Beam_counter_cell1}    ${PUSCH_INI_cell1}
	END	
	Log To Console    PUSCH_INI_SSB_refined_DFTN_DFT_beam_counter_cell1:${PUSCH_INI_All_Beam_counter_cell1}
	${PUSCH_INI_counter_Sum_cell1}    Evaluate    sum(${PUSCH_INI_All_Beam_counter_cell1})
    Log To Console    \n----------------------end-------------------------
	
	Log To Console    \n---------CNI_113494_PUSCH_Successful_initial_counter------------------
	Log To Console    SSB_BEAM:M55330C00046,REFINED_BEAM:M55330C00029,DFTNTAP_BEAM:M55330C00039,DFTTAP_BEAM:M55330C00035
	${PUSCH_SUC_Counter_list}    create list   M55330C00046    M55330C00029     M55330C00039   M55330C00035
    ${PUSCH_SUC_All_Beam_counter_cell1}    	create list
    FOR    ${counter_id}    IN    @{PUSCH_SUC_Counter_list}
    ${PUSCH_SUC_cell1}    get_counter_value_from_counter_file    counter_file=${PM_counter_file}    counter_id=${counter_id}    cell_id=1    
    append to list    ${PUSCH_SUC_All_Beam_counter_cell1}    ${PUSCH_SUC_cell1}
	END		
	Log To Console    PUSCH_SUC_SSB_refined_DFTN_DFT_beam_counter_cell1:${PUSCH_SUC_All_Beam_counter_cell1}	
	${PUSCH_SUC_counter_Sum_cell1}    Evaluate    sum(${PUSCH_SUC_All_Beam_counter_cell1})
    Log To Console    \n----------------------end-------------------------

	
	Log To Console    \n----Legacy_PDSCH_INITX_64TBL_MCS_00-28_and_256TBL_MCS_00-27_and_LOWSE_MCS_00-28----------
	Log To Console    PDSCH_INITX_64TBL_MCS_00-28:M55300C00000----M55300C00028
	Log To Console    PDSCH_INITX_256TBL_MCS_00-27:M55300C04000---M55300C04027
	Log To Console    PDSCH_INITX_LOWSE_MCS_00-28:M55366C01000----M55366C01028
    ${PDSCH_INITX_64TBL_MCS_00_28_cell1}    	create list
    ${PDSCH_INITX_256TBL_MCS_00_27_cell1}    	create list
    ${PDSCH_INITX_LOWSE_MCS_00_28_cell1}    	create list
	
	FOR    ${i}    IN RANGE     0     29
	${index}     evaluate     "${i}".zfill(2)                     #1bit change to 2bit,0 change to 00
	${64_value}     get_counter_value_from_counter_file    counter_file=${PM_counter_file}     counter_id=M55300C000${index}    cell_id=1
	append to list     ${PDSCH_INITX_64TBL_MCS_00_28_cell1}   ${64_value}
	${LOW_value}     get_counter_value_from_counter_file    counter_file=${PM_counter_file}     counter_id=M55366C010${index}    cell_id=1
	append to list     ${PDSCH_INITX_LOWSE_MCS_00_28_cell1}   ${LOW_value}
	END

	FOR    ${i}    IN RANGE     0     28
	${index}     evaluate     "${i}".zfill(2)                     #1bit change to 2bit,0 change to 00
	${256_value}     get_counter_value_from_counter_file    counter_file=${PM_counter_file}     counter_id=M55300C040${index}    cell_id=1
	append to list     ${PDSCH_INITX_256TBL_MCS_00_27_cell1}   ${256_value}
	END	
	Log To Console    PDSCH_INITX_64TBL_MCS_00_28_cell1:${PDSCH_INITX_64TBL_MCS_00_28_cell1}
    Log To Console    PDSCH_INITX_256TBL_MCS_00_27_cell1:${PDSCH_INITX_256TBL_MCS_00_27_cell1}
    Log To Console    PDSCH_INITX_LOWSE_MCS_00_28_cell1:${PDSCH_INITX_LOWSE_MCS_00_28_cell1}
	${PDSCH_INITX_64TBL_Sum_cell1}    Evaluate    sum(${PDSCH_INITX_64TBL_MCS_00_28_cell1})
	${PDSCH_INITX_256TBL_Sum_cell1}    Evaluate    sum(${PDSCH_INITX_256TBL_MCS_00_27_cell1})		
	${PDSCH_INITX_LOWSE_Sum_cell1}    Evaluate    sum(${PDSCH_INITX_LOWSE_MCS_00_28_cell1})
    ${PDSCH_LG_INITX_Sum_cell1}    Evaluate    ${PDSCH_INITX_64TBL_Sum_cell1}+${PDSCH_INITX_256TBL_Sum_cell1}+${PDSCH_INITX_LOWSE_Sum_cell1}		
    Log To Console    \n----------------------end-------------------------

	Log To Console    \n----Legacy_PDSCH_SUCC_64TBL_MCS_00-28_and_256TBL_MCS_00-27_and_LOWSE_MCS_00-28----------
	Log To Console    PDSCH_SUC_64TBL_MCS_00-28:M55300C01000-----M55300C01028
	Log To Console    PDSCH_SUC_256TBL_MCS_00-27:M55300C05000---M55300C05027
	Log To Console    PDSCH_SUC_LOWSE_MCS_00-28:M55366C02000----M55366C02028
    ${PDSCH_SUC_64TBL_MCS_00_28_cell1}    	create list
    ${PDSCH_SUC_256TBL_MCS_00_27_cell1}    	create list
    ${PDSCH_SUC_LOWSE_MCS_00_28_cell1}    	create list
	
	FOR    ${i}    IN RANGE     0     29
	${index}     evaluate     "${i}".zfill(2)                     #1bit change to 2bit,0 change to 00
	${64_value}     get_counter_value_from_counter_file    counter_file=${PM_counter_file}     counter_id=M55300C010${index}    cell_id=1
	append to list     ${PDSCH_SUC_64TBL_MCS_00_28_cell1}   ${64_value}
	${LOW_value}     get_counter_value_from_counter_file    counter_file=${PM_counter_file}     counter_id=M55366C020${index}    cell_id=1
	append to list     ${PDSCH_SUC_LOWSE_MCS_00_28_cell1}   ${LOW_value}		
	END

	FOR    ${i}    IN RANGE     0     28
	${index}     evaluate     "${i}".zfill(2)                     #1bit change to 2bit,0 change to 00
	${256_value}     get_counter_value_from_counter_file    counter_file=${PM_counter_file}     counter_id=M55300C050${index}    cell_id=1
	append to list     ${PDSCH_SUC_256TBL_MCS_00_27_cell1}   ${256_value}
	END	
	Log To Console    PDSCH_SUC_64TBL_MCS_00_28_cell1:${PDSCH_SUC_64TBL_MCS_00_28_cell1}
    Log To Console    PDSCH_SUC_256TBL_MCS_00_27_cell1:${PDSCH_SUC_256TBL_MCS_00_27_cell1}
    Log To Console    PDSCH_SUC_LOWSE_MCS_00_28_cell1:${PDSCH_SUC_LOWSE_MCS_00_28_cell1}
	${PDSCH_SUC_64TBL_Sum_cell1}    Evaluate    sum(${PDSCH_SUC_64TBL_MCS_00_28_cell1})
	${PDSCH_SUC_256TBL_Sum_cell1}    Evaluate    sum(${PDSCH_SUC_256TBL_MCS_00_27_cell1})		
	${PDSCH_SUC_LOWSE_Sum_cell1}    Evaluate    sum(${PDSCH_SUC_LOWSE_MCS_00_28_cell1})		
    ${PDSCH_LG_SUC_Sum_cell1}    Evaluate    ${PDSCH_SUC_64TBL_Sum_cell1}+${PDSCH_SUC_256TBL_Sum_cell1}+${PDSCH_SUC_LOWSE_Sum_cell1}	
    Log To Console    \n----------------------end-------------------------


	Log To Console    \n----Legacy_PUSCH_CP_INI_64TBL_MCS_00-28_and_PUSCH_DFT_INI_64TBL_MCS_00-27------
	Log To Console    \n----Legacy_PUSCH_CP_INI_256TBL_MCS_00-27_and_PUSCH_CP_INI_LOWSE_MCS_00-28------
	Log To Console    \n----Legacy_PUSCH_DFT_INI_64TBL_SAG_R2_and_PUSCH_DFT_INI_64TBL_SAG_R4------	
	Log To Console    PUSCH_CP_INI_64TBL_MCS_00-28:M55302C00000----M55302C00028
	Log To Console    PUSCH_DFT_INI_64TBL_MCS_00-27:M55302C06000----M55302C06027
	Log To Console    PUSCH_CP_INI_256TBL_MCS_00-27:M55302C11000-----M55302C11027
	Log To Console    PUSCH_CP_INI_LOWSE_MCS_00-28:M55367C01000----M55367C01028
	Log To Console    PUSCH_DFT_INI_64TBL_SAG_R2:M55370C00007
	Log To Console    PUSCH_DFT_INI_64TBL_SAG_R4:M55370C00013	
	
	
    ${PUSCH_CP_INI_64TBL_MCS_00_28_cell1}    	create list
    ${PUSCH_DFT_INI_64TBL_MCS_00_27_cell1}    	create list
    ${PUSCH_CP_INI_256TBL_MCS_00_27_cell1}    	create list	
    ${PUSCH_CP_INI_LOWSE_MCS_00_28_cell1}    	create list
	
	FOR    ${i}    IN RANGE     0     29
	${index}     evaluate     "${i}".zfill(2)                     #1bit change to 2bit,0 change to 00
	${CP_64_value}     get_counter_value_from_counter_file    counter_file=${PM_counter_file}     counter_id=M55302C000${index}    cell_id=1
	append to list     ${PUSCH_CP_INI_64TBL_MCS_00_28_cell1}   ${CP_64_value}
	${LOW_value}     get_counter_value_from_counter_file    counter_file=${PM_counter_file}     counter_id=M55367C010${index}    cell_id=1
	append to list     ${PUSCH_CP_INI_LOWSE_MCS_00_28_cell1}   ${LOW_value}		
	END

	FOR    ${i}    IN RANGE     0     28
	${index}     evaluate     "${i}".zfill(2)                     #1bit change to 2bit,0 change to 00
	${DFT_64}     get_counter_value_from_counter_file    counter_file=${PM_counter_file}     counter_id=M55302C060${index}    cell_id=1
	append to list     ${PUSCH_DFT_INI_64TBL_MCS_00_27_cell1}   ${DFT_64}	
	${256_value}     get_counter_value_from_counter_file    counter_file=${PM_counter_file}     counter_id=M55302C110${index}    cell_id=1
	append to list     ${PUSCH_CP_INI_256TBL_MCS_00_27_cell1}   ${256_value}
	END	
	
	${INI_SAG_R2_C1}     get_counter_value_from_counter_file    counter_file=${PM_counter_file}     counter_id=M55370C00007    cell_id=1	
	${INI_SAG_R4_C1}     get_counter_value_from_counter_file    counter_file=${PM_counter_file}     counter_id=M55370C00013    cell_id=1

    Log To Console    PUSCH_CP_INI_64TBL_MCS_00_28_cell1:${PUSCH_CP_INI_64TBL_MCS_00_28_cell1}
    Log To Console    PUSCH_DFT_INI_64TBL_MCS_00_27_cell1:${PUSCH_DFT_INI_64TBL_MCS_00_27_cell1}
    Log To Console    PUSCH_CP_INI_256TBL_MCS_00_27_cell1:${PUSCH_CP_INI_256TBL_MCS_00_27_cell1}		
    Log To Console    PUSCH_CP_INI_LOWSE_MCS_00_28_cell1:${PUSCH_CP_INI_LOWSE_MCS_00_28_cell1}
    Log To Console    PUSCH_DFT_INI_64TBL_SAG_R2_cell1:${INI_SAG_R2_C1}
    Log To Console    PUSCH_DFT_INI_64TBL_SAG_R4_cell1:${INI_SAG_R4_C1}
	${CP_INI_64TBL_Sum_cell1}    Evaluate    sum(${PUSCH_CP_INI_64TBL_MCS_00_28_cell1})
	${DFT_INI_64TBL_Sum_cell1}    Evaluate    sum(${PUSCH_DFT_INI_64TBL_MCS_00_27_cell1})	
	${CP_INI_256TBL_Sum_cell1}    Evaluate    sum(${PUSCH_CP_INI_256TBL_MCS_00_27_cell1})	
	${CP_INI_LOWSE_Sum_cell1}    Evaluate    sum(${PUSCH_CP_INI_LOWSE_MCS_00_28_cell1})
	
    ${PUSCH_LG_INI_Sum_cell1_tmp}    Evaluate    ${CP_INI_64TBL_Sum_cell1}+${DFT_INI_64TBL_Sum_cell1}+${CP_INI_256TBL_Sum_cell1}
    ${PUSCH_LG_INI_Sum_cell1}    Evaluate    ${PUSCH_LG_INI_Sum_cell1_tmp}+${CP_INI_LOWSE_Sum_cell1}+${INI_SAG_R2_C1}+${INI_SAG_R4_C1}

    Log To Console    \n----------------------end-------------------------	
	

	Log To Console    \n----Legacy_PUSCH_CP_SUCC_64TBL_MCS_00-28_and_PUSCH_DFT_SUCC_64TBL_MCS_00-27------
	Log To Console    \n----Legacy_PUSCH_CP_SUCC_256TBL_MCS_00-27_and_PUSCH_CP_SUCC_LOWSE_MCS_00-28------
	Log To Console    \n----Legacy_PUSCH_DFT_SUCC_64TBL_SAG_R2_and_PUSCH_DFT_SUCC_64TBL_SAG_R4------	
	Log To Console    PUSCH_CP_SUCC_64TBL_MCS_00-28:M55302C04000----M55302C04028
	Log To Console    PUSCH_DFT_SUCC_64TBL_MCS_00-27:M55302C08000----M55302C08027
	Log To Console    PUSCH_CP_SUCC_256TBL_MCS_00-27:M55302C13000---M55302C13027
	Log To Console    PUSCH_CP_SUCC_LOWSE_MCS_00-28:M55367C02000---M55367C02028
	Log To Console    PUSCH_DFT_SUCC_64TBL_SAG_R2:M55370C00009
	Log To Console    PUSCH_DFT_SUCC_64TBL_SAG_R4:M55370C00015
	
	
    ${PUSCH_CP_SUC_64TBL_MCS_00_28_cell1}    	create list
    ${PUSCH_DFT_SUC_64TBL_MCS_00_27_cell1}    	create list
    ${PUSCH_CP_SUC_256TBL_MCS_00_27_cell1}    	create list	
    ${PUSCH_CP_SUC_LOWSE_MCS_00_28_cell1}    	create list

	
	FOR    ${i}    IN RANGE     0     29
	${index}     evaluate     "${i}".zfill(2)                     #1bit change to 2bit,0 change to 00
	${CP_64_value}     get_counter_value_from_counter_file    counter_file=${PM_counter_file}     counter_id=M55302C040${index}    cell_id=1
	append to list     ${PUSCH_CP_SUC_64TBL_MCS_00_28_cell1}   ${CP_64_value}
	${LOW_value}     get_counter_value_from_counter_file    counter_file=${PM_counter_file}     counter_id=M55367C020${index}    cell_id=1
	append to list     ${PUSCH_CP_SUC_LOWSE_MCS_00_28_cell1}   ${LOW_value}
		
	END

	FOR    ${i}    IN RANGE     0     28
	${index}     evaluate     "${i}".zfill(2)                     #1bit change to 2bit,0 change to 00
	${DFT_64}     get_counter_value_from_counter_file    counter_file=${PM_counter_file}     counter_id=M55302C080${index}    cell_id=1
	append to list     ${PUSCH_DFT_SUC_64TBL_MCS_00_27_cell1}   ${DFT_64}	
	${256_value}     get_counter_value_from_counter_file    counter_file=${PM_counter_file}     counter_id=M55302C130${index}    cell_id=1
	append to list     ${PUSCH_CP_SUC_256TBL_MCS_00_27_cell1}   ${256_value}
	END	
	
	${SUC_SAG_R2_C1}     get_counter_value_from_counter_file    counter_file=${PM_counter_file}     counter_id=M55370C00009    cell_id=1	
	${SUC_SAG_R4_C1}     get_counter_value_from_counter_file    counter_file=${PM_counter_file}     counter_id=M55370C00015    cell_id=1


    Log To Console    PUSCH_CP_SUC_64TBL_MCS_00_28_cell1:${PUSCH_CP_SUC_64TBL_MCS_00_28_cell1}
    Log To Console    PUSCH_DFT_SUC_64TBL_MCS_00_27_cell1:${PUSCH_DFT_SUC_64TBL_MCS_00_27_cell1}
    Log To Console    PUSCH_CP_SUC_256TBL_MCS_00_27_cell1:${PUSCH_CP_SUC_256TBL_MCS_00_27_cell1}		
    Log To Console    PUSCH_CP_SUC_LOWSE_MCS_00_28_cell1:${PUSCH_CP_SUC_LOWSE_MCS_00_28_cell1}

    Log To Console    PUSCH_DFT_SUC_64TBL_SAG_R2_cell1:${SUC_SAG_R2_C1}
    Log To Console    PUSCH_DFT_SUC_64TBL_SAG_R4_cell1:${SUC_SAG_R4_C1}
	${CP_SUC_64TBL_Sum_cell1}    Evaluate    sum(${PUSCH_CP_SUC_64TBL_MCS_00_28_cell1})
	${DFT_SUC_64TBL_Sum_cell1}    Evaluate    sum(${PUSCH_DFT_SUC_64TBL_MCS_00_27_cell1})	
	${CP_SUC_256TBL_Sum_cell1}    Evaluate    sum(${PUSCH_CP_SUC_256TBL_MCS_00_27_cell1})	
	${CP_SUC_LOWSE_Sum_cell1}    Evaluate    sum(${PUSCH_CP_SUC_LOWSE_MCS_00_28_cell1})

	
    ${PUSCH_LG_SUC_Sum_cell1_tmp}    Evaluate    ${CP_SUC_64TBL_Sum_cell1}+${DFT_SUC_64TBL_Sum_cell1}+${CP_SUC_256TBL_Sum_cell1}
    ${PUSCH_LG_SUC_Sum_cell1}    Evaluate    ${PUSCH_LG_SUC_Sum_cell1_tmp}+${CP_SUC_LOWSE_Sum_cell1}+${SUC_SAG_R2_C1}+${SUC_SAG_R4_C1}	
    Log To Console    \n----------------------end-------------------------	
	
    Log To Console    \n----------------------All Counter Summary-------------------------
	Log To Console    \n----------Check PDSCH All Beam Type iBler counter in Cell1--------
	Log To Console    PDSCH_INI_All_beam_type_counter_Sum_cell1:${PDSCH_INI_counter_Sum_cell1}
	Log To Console    PDSCH_SUC_All_beam_type_counter_Sum_cell1:${PDSCH_SUC_counter_Sum_cell1}
    Log To Console    PDSCH_INI_64TBL_256TBL_LOWSE_legacy_counter_cell1:${PDSCH_LG_INITX_Sum_cell1}
    Log To Console    PDSCH_SUC_64TBL_256TBL_LOWSE_legacy_counter_cell1:${PDSCH_LG_SUC_Sum_cell1}
    run keyword and continue on failure    should_be_true    ${PDSCH_INI_counter_Sum_cell1}==${PDSCH_LG_INITX_Sum_cell1}   
    run keyword and continue on failure    should_be_true    ${PDSCH_SUC_counter_Sum_cell1}==${PDSCH_LG_SUC_Sum_cell1}   

	
	Log To Console    \n----------Check PUSCH All Beam Type iBler counter in Cell1--------	
    Log To Console    PUSCH_INI_All_beam_type_counter_Sum_cell1:${PUSCH_INI_counter_Sum_cell1}
    Log To Console    PUSCH_SUC_All_beam_type_counter_Sum_cell1:${PUSCH_SUC_counter_Sum_cell1}		
    Log To Console    PUSCH_INI_CP_DFT_64TBL_256TBL_LOWSE_SAG_legacy_counter_cell1:${PUSCH_LG_INI_Sum_cell1}	
    Log To Console    PUSCH_SUC_CP_DFT_64TBL_256TBL_LOWSE_SAG_legacy_counter_cell1:${PUSCH_LG_SUC_Sum_cell1}
    run keyword and continue on failure    should_be_true    ${PUSCH_INI_counter_Sum_cell1}==${PUSCH_LG_INI_Sum_cell1}   
    run keyword and continue on failure    should_be_true    ${PUSCH_SUC_counter_Sum_cell1}==${PUSCH_LG_SUC_Sum_cell1} 		
	


