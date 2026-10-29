*** Settings ***
Documentation     Author: xuemin.ma@nokia-sbell.com
...
...               QC case full name:
...               CB008360_C_B2_case_135_IWK with MultipleDedicatedBWPs
...

Suite Setup       Common Suite Setup
#Suite Teardown    Common Suite Teardown
Test Setup        Common Test Setup
Test Teardown     Common Test Teardown
Force Tags        CLOUD_5G_I_BOO_AP_KLLL_SANSA_L1B_ECPRI_CMWV_TDD    AP    CRT    SBTS00    SBTS23R1    RAN_5G_TDD    RAN_5G    owner_xueminm
Test Timeout      60 minutes
Resource          ../../resources/sg11/internal_resource/robot/modify_configuration.robot
Resource          ../../resources/sg11/internal_resource/robot/internal_ap_operate.robot
Resource          ../../resources/sg11/internal_resource/robot/internal_gnb_operate.robot
Resource    ../../resources/KISS/robot/common_resource.robot
Resource    ../../resources/sg10/internal_resource/internal_resource.robot
Library     taf.transport.ssh    WITH NAME    TAF_SSH
Library           ta_a2a

*** Variables ***
${CONFIG_DIR_PATH}    ${CURDIR}/../../resources/sg11/internal_resource/config/
${SCFC_NAME}       gNB_scf_ASIL_ABIO_TDD_eCPRI_cmwv_SANSA_L1b_1S_1CC_MultipleDedicatedBWPs.xml
${AIRPHONE_NAME}    AP_iphy_AEQE_LO_AP_LO_TDD_eCPRI_cmwv_SANSA_L1b_1S_1CC_srs_135.xml
${WTS_NAME}       wts_config_ASIL_ABIO_TDD_eCPRI_cmwv_SANSA_L1b_1S_1CC_MultipleDedicatedBWPs.cfg
${COMAVALUE}    ${CURDIR}/../../resources/sg11/internal_resource/config/AP/ap_coma.txt
@{LOG_NAME_LIST}    gnb_snapshot    egatelog\
${cellDepType}                                  text|SA+NSA|//*[@name\="cellDepType"]
${chBw}                                         text|100MHz|//*[@name\="chBw"]
${nrarfcn}                                      text|632032|//*[@name\="nrarfcn"]
${gscnOrSsPbchArfcn}                            text|7830|//*[@name\="gscnOrSsPbchArfcn"]
#${dlMimoMode}                                   text|8x4 Closed Loop Spatial Multiplexing|//*[@name\="dlMimoMode"]
${dlMimoMode}                                   text|4x4 or 4x2 Closed Loop Spatial Multiplexing|//*[@name\="dlMimoMode"]
${nrCellType}                                   text|8DL8UL|//*[@name\="nrCellType"]
${actUlSrsBm}                                   text|true|//*[@name\="actUlSrsBm"]
${actUlMuMimo}                                  text|true|//*[@name\="actUlMuMimo"]
${ulMaxMuMimoLayer}                             text|4|//*[@name\="ulMaxMuMimoLayer"]
${ulMinPrbThreshold}                            text|50|//*[@name\="ulMinPrbThreshold"]
${ulMuMimoPrbThresholdAbsolute}                 text|15|//*[@name\="ulMuMimoPrbThresholdAbsolute"]
${ulMuMimoCorrThd}                              text|16|//*[@name\="ulMuMimoCorrThd"]
${ulMuMimoSinrThd}                              text|10|//*[@name\="ulMuMimoSinrThd"]
${ulMuMimoSpectralEffThd}                       text|1|//*[@name\="ulMuMimoSpectralEffThd"]
${ulMuMimoLinkAdaptionSwitch}                   text|MU-SINR estimation|//*[@name\="ulMuMimoLinkAdaptionSwitch"]
${frameStructureType}                           text|semiStatic|//*[@name\="frameStructureType"]
${guardPeriodLength}                            text|2Symbols|//*[@name\="guardPeriodLength"]
${ulDlDataSlotRatio}                            text|1/4|//*[@name\="ulDlDataSlotRatio"]
${prachConfigurationIndex}                      text|98|//*[@name\="prachConfigurationIndex"]
${srsUePeriodicity}                             text|slots40|//*[@name\="srsUePeriodicity"]
${cSRS}                                         text|63|//*[@name\="cSRS"]
${bSRS}                                         text|1|//*[@name\="bSRS"]
${actBeamforming}                               text|true|//*[@name\="actBeamforming"]
${basicBeamSet}                                 text|beamSet_6|//*[@name\="basicBeamSet"]
${msg1FrequencyStart}                           text|30|//*[@name\="msg1FrequencyStart"]
${actUlMuMimoTapering}                          text|false|//*[@name\="actUlMuMimoTapering"]
${actMultipleDedicatedBWPs}                     text|true|//*[@name\="actMultipleDedicatedBWPs"]
${actUlPtrs}                          text|false|//*[@name\="actUlPtrs"]
${actDlPtrs}                          text|false|//*[@name\="actDlPtrs"]
${ulDMRSAdditionalPosition}                          text|One additional DMRS|//*[@name\="ulDMRSAdditionalPosition"]
${pattern}    CA_P2_8x4_t2r4_n2_pusch_1layer
*** Test Cases ***
CB008360_C_B2_case_135_IWK with MultipleDedicatedBWPs
    Add GNB swconfig    0x580708:2 
    Step1:Commission the above configuration on WebUI
    Step2:Attach 4 SA UEs,1UE's capability is restricted in small bwp
    Step3:Push full buffer in UL
	Step4:2 ue pair patternid    

*** Keywords ***
Step4:2 ue pair patternid  
    Airphone Execute Egate Command    ue_deregister id\=3 by\=ue ue_deregister_type\=switch_off
	Airphone Execute Egate Command    ue_deregister id\=4 by\=ue ue_deregister_type\=switch_off
    airphone_execute_egate_command	bler_testmode_nr profile_id\=1 ul_bler\=100,100
	airphone_execute_egate_command	bler_testmode_nr profile_id\=2 ul_bler\=100,100
	Wait '1s' for stabible 
	airphone_execute_egate_command	ue_testmode_set_nr id\=1 scell\=0 testmode\=bler profile_id\=1 action\=activate
	airphone_execute_egate_command	ue_testmode_set_nr id\=2 scell\=0 testmode\=bler profile_id\=2 action\=activate
	Start collect ttitrace
    Wait for '2s' to stop ttitrace with name'tti'
	run keyword and continue on failure    check patternid is correct in ttitrace 
check patternid is correct in ttitrace                    
    check_log_with_au2anlysis    ini_path=${CURDIR}/ini/tti_ul_c135.ini    log_need_to_check=i    save_log_directory=${TEST_LOG_DIRECTORY()}/All	
Step1:Commission the above configuration on WebUI
    Start Collect GNB and AP Syslog in 'Step1_before_onair' File
	${CONFIG_DIR_PATH}    Set Variable    ${CONFIG_DIR_PATH}/${SW_BRANCH}
    change_iphy_rru_version    ${CONFIG_DIR_PATH}${/}${AIRPHONE_NAME}
    #Airphone Download L1ByPTestModeConfiguration from ABIL    ${test_log_directory()}/L1ByPTestModeConfiguration.xml
    #Set Pos By Modify L1ByPTestModeConfiguration    4    0    4    0    4    0    4    0    0
    #Set Pos By Modify L1ByPTestModeConfiguration    20    0    2    0    2    0    2    0    1
    #Set Pos By Modify L1ByPTestModeConfiguration    14    0    25    0    25    0    25    0    2
    #Set Pos By Modify L1ByPTestModeConfiguration    10    0    25    0    25    0    25    0    3
    #Airphone Upload L1ByPTestModeConfiguration to ASIK    ${test_log_directory()}/L1ByPTestModeConfiguration.xml
    modify_swconfig_by_CB008360    ${CONFIG_DIR_PATH}${/}${SCFC_NAME}
    ${scfc_path}    Set Variable    ${TEST_LOG_DIRECTORY()}${/}scfc.xml
    copy_file    ${CONFIG_DIR_PATH}/${SCFC_NAME}    ${scfc_path}
    del_elements_from_xml    xml_path=${scfc_path}    parameter=lteToNrFrameShift
    ${modify_list}    create list
    ...       ${cellDepType}    ${chBw}    ${nrarfcn}    ${gscnOrSsPbchArfcn}    ${nrCellType}
    ...       ${actUlSrsBm}    ${actUlMuMimo}    ${ulMaxMuMimoLayer}    ${actUlMuMimoTapering}    ${ulMinPrbThreshold}
    ...       ${ulMuMimoPrbThresholdAbsolute}    ${ulMuMimoCorrThd}    ${ulMuMimoSinrThd}    ${ulMuMimoSpectralEffThd}
    ...       ${ulMuMimoLinkAdaptionSwitch}    ${frameStructureType}    ${guardPeriodLength}    ${ulDlDataSlotRatio}
    ...       ${prachConfigurationIndex}    ${srsUePeriodicity}    ${cSRS}    ${bSRS}    ${actBeamforming}
    ...       ${basicBeamSet}    ${msg1FrequencyStart}    ${actUlMuMimoTapering}    ${actMultipleDedicatedBWPs}
    ...       ${actDlPtrs}    ${actUlPtrs}    ${ulDMRSAdditionalPosition}
    modify_xml    ${scfc_path}    ${scfc_path}    ${modify_list}
    Get and Update BSR File    par_of_bsr_name=AEQE_6_H6_ALN60_ARP60_P00_COVERAGE_00424_00001
    Modify TL VM And AP SCTP Configuration
    Perform Full Commission And Reach Onair With Log    ${scfc_path}    ${CONFIG_DIR_PATH}${/}${WTS_NAME}    reset_after_commission=${False}
    [Teardown]    Stop Collect GNB and AP Syslog in 'Step1_before_onair' File


Step2:Attach 4 SA UEs,1UE's capability is restricted in small bwp
    Start Collect GNB and AP Syslog in 'Step2_attach' File
    #Start GNB BIP Log
	airphone_execute_egate_command
    ...    csi_override_testmode_nr profile_id\=1 cqi_mode\=fixed cqi\=15 ri_mode\=fixed ri\=1 pmi_mode\=fixed pmi\=0
    Wait Throughput Timer    3
    airphone_execute_egate_command
    ...    ue_testmode_set_nr id\=1 testmode\=csi_override action\=activate profile_id\=1 scell\=0
    Wait Throughput Timer    3
    Airphone SA Attach    ue_id=1
    airphone_set_traffic_type    1    1    internal
    Airphone Pdu Session Setup    1    1    1    1
	airphone_execute_egate_command
    ...    ul_mimo_srs_beam_pos_nr profile_id\=1 mode\=fixed init_quad_pos\=3 init_sub_quad_pos\=3 step\=10 trigger_puxch_update\=0
	airphone_execute_egate_command    ue_testmode_set_nr id\=1 testmode\=ul_mimo_srs_beam_pos action\=activate profile_id\=1 scell\=0

    airphone_execute_egate_command
    ...    ue_testmode_set_nr id\=2 testmode\=csi_override action\=activate profile_id\=1 scell\=0
    Wait Throughput Timer    3
    Airphone SA Attach    ue_id=2
    airphone_set_traffic_type    2    1    internal
    Airphone Pdu Session Setup    2    1    1    2    
	airphone_execute_egate_command
    ...    ul_mimo_srs_beam_pos_nr profile_id\=2 mode\=fixed init_quad_pos\=2 init_sub_quad_pos\=2 step\=10 trigger_puxch_update\=0
	airphone_execute_egate_command    ue_testmode_set_nr id\=2 testmode\=ul_mimo_srs_beam_pos action\=activate profile_id\=2 scell\=0	
    
	airphone_execute_egate_command
    ...    ue_testmode_set_nr id\=3 testmode\=csi_override action\=activate profile_id\=1 scell\=0
	Airphone SA Attach    ue_id=3
    airphone_set_traffic_type    3    1    internal
    Airphone Pdu Session Setup    3    1    1    3 	
	airphone_execute_egate_command
    ...    ul_mimo_srs_beam_pos_nr profile_id\=10 mode\=fixed init_quad_pos\=1 init_sub_quad_pos\=1 step\=10 trigger_puxch_update\=0
	airphone_execute_egate_command    ue_testmode_set_nr id\=3 testmode\=ul_mimo_srs_beam_pos action\=activate profile_id\=10 scell\=0
    
	airphone_execute_egate_command
    ...    ue_testmode_set_nr id\=4 testmode\=csi_override action\=activate profile_id\=1 scell\=0
	Airphone SA Attach    ue_id=4
    airphone_set_traffic_type    4    1    internal
    Airphone Pdu Session Setup    4    1    1    4 	
	airphone_execute_egate_command
    ...    ul_mimo_srs_beam_pos_nr profile_id\=5 mode\=fixed init_quad_pos\=0 init_sub_quad_pos\=0 step\=10 trigger_puxch_update\=0
	airphone_execute_egate_command    ue_testmode_set_nr id\=4 testmode\=ul_mimo_srs_beam_pos action\=activate profile_id\=5 scell\=0	
    #Stop Gnb BIP Log    log_dir=${TEST_LOG_DIRECTORY()}${/}Step2_attach${/}
    airphone_collect_egate_log_files      ${TEST_LOG_DIRECTORY()}${/}Step2_attach${/}   unzip=TRUE
	${rnti_list}    file match all   ${TEST_LOG_DIRECTORY()}${/}Step2_attach${/}/egate_console.log.001   crnti: (\\d+)
	Set test Variable	 ${rnti_1} 	${rnti_list[0]}
	Set test Variable	 ${rnti_2} 	${rnti_list[1]}
	Set test Variable	 ${rnti_3} 	${rnti_list[2]}
	Set test Variable	 ${rnti_4} 	${rnti_list[3]}
	run keyword and continue on failure    check_log_with_au2anlysis    ini_path=${CURDIR}/log_check/case135_rrc_small_bwp.ini
    ...    log_need_to_check=p    save_log_directory=${TEST_LOG_DIRECTORY()}${/}Step2_attach${/}
    [Teardown]    Stop Collect GNB and AP Syslog in 'Step2_attach' File

Step3:Push full buffer in UL
    Start Collect GNB and AP Syslog in 'Step3_data' File
    #Start GNB BIP Log
    FOR    ${u_id}    IN RANGE   1    5
        Airphone SA Start Data Traffic    ${u_id}    UL    170M    trf_id=1    pdu_id=1    duration=${3600}
        Airphone SA Start Data Traffic    ${u_id}    UL    170M    trf_id=2    pdu_id=1    duration=${3600}
    END
    #Stop Gnb BIP Log    log_dir=${TEST_LOG_DIRECTORY()}${/}Step3_data${/}
    Start GNB Ttitrace With Streaming Mode
    Wait Throughput Timer    5
    ${pacp}=    Stop GNB Ttitrace With Streaming Mode    save_path=${TEST_LOG_DIRECTORY()}${/}Step3_data${/}
    Decoder Tttirace From Pcap To Csv    ${pacp}    ${TEST_LOG_DIRECTORY()}${/}Step3_data${/}tti_135
    run keyword and continue on failure    check_log_with_au2anlysis    ini_path=${CURDIR}/log_check/case135_tti_small_bwp_FS.ini
    ...    log_need_to_check=i    save_log_directory=${TEST_LOG_DIRECTORY()}${/}Step3_data${/}
    ${remaining_time}=    get_counter_file_remaining_time    counter_refresh_period=1min
    Wait Throughput Timer    ${remaining_time}
    ${PM_counter_file}=    download_latest_pmcounter    local_path=${TEST_LOG_DIRECTORY()}Step3_data${/}
    Set Suite Variable    ${PM_counter_file}
	${PM_counter_value_M55308C28004}=    get_counter_value_from_counter_file    counter_file=${PM_counter_file}
    ...    counter_id=M55308C28004    cell_id=1
    ${PM_counter_value_M55308C28008}=    get_counter_value_from_counter_file    counter_file=${PM_counter_file}
    ...    counter_id=M55308C28008    cell_id=1
    should be true     ${PM_counter_value_M55308C28004} == 1
    should be true     ${PM_counter_value_M55308C28008} == 3
    [Teardown]    Stop Collect GNB and AP Syslog in 'Step3_data' File
Online change actSrsUlBeamFallbackByRetrx to true
    TAF_ADMIN.connect to    bts_host=192.168.255.129    bts_port=443    use_ssl=True    name=online
    Perform online change value    MRBTS-1/NRBTS-2/NRCELL-1    actSrsUlBeamFallbackByRetrx    true    online
    Wait '2s' for stabible
    TAF_ADMIN.teardown admin    connection=online
