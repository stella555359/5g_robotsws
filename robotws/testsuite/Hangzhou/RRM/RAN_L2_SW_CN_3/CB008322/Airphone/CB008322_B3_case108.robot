*** Settings ***
Documentation     Author: mao.qin@nokia-sbell.com
...
...               QC case full name:
...               CB008322_B3_case108_wide_band_TAS_SRS_configuration_algorithm_pool_multiple_cells
...               

Suite Setup       Common Suite Setup
Suite Teardown    Common Suite Teardown
Test Setup        Common Test Setup
Test Teardown     Common Test Teardown
Force Tags        CLOUD_5G_I_LO_AP_LOOO    AP    CRT    SBTS00    RAN_5G_TDD    RAN_5G
Test Timeout      90 minutes
Resource          ../../resources/sg11/internal_resource/robot/modify_configuration.robot
Resource          ../../resources/sg11/internal_resource/robot/internal_ap_operate.robot
Resource          ../../resources/sg11/internal_resource/robot/internal_gnb_operate.robot
Resource          ../../resources/sg11/internal_resource/robot/internal_capture_log.robot
Library           taf.transport.ssh    WITH NAME    TAF_SSH
Library           ta_a2a

*** Variables ***
${CONFIG_DIR_PATH}     ${CURDIR}/../../resources/sg11/internal_resource/config/
${SCFC_NAME}           gNB_scf_ASIL_ABIO_TDD_eCPRI_cmwv_SANSA_FS_3S_1CC_8D4U.xml
${AIRPHONE_NAME}       AP_iphy_AQQL_ASIL_ABIO_TDD_eCPRI_cmwv_SANSA_FS_3S_1CC_BOAM.xml
${WTS_NAME}            wts_config_ASIL_ABIO_TDD_eCPRI_cmwv_SANSA_FS_3S_1CC_UEs.cfg
${SWCONFIG_NAME}       swconfig_CB008322.txt
${AP_SWCONFIG_NAME}    ap_swconfig_CB008322.txt
@{LOG_NAME_LIST}       ap_snapshot    egatelog\    gnb_snapshot
${cellDepType}                      text|SA+NSA|//*[@name\="cellDepType"]
${actSpatialStreamPooling}          text|true|//*[@name\="actSpatialStreamPooling"]
${actTddPrePooling}                 text|true|//*[@name\="actTddPrePooling"]
${chBw}                             text|100MHz|//*[@name\="chBw"]
${dlMimoMode}                       text|4x4 or 4x2 Closed Loop Spatial Multiplexing|//*[@name\="dlMimoMode"]
${nrCellType}                       text|8DL4UL|//*[@name\="nrCellType"]
${actUeCsirsCoexistCellCsirs}       text|false|//*[@name\="actUeCsirsCoexistCellCsirs"]
${actCsirsMultiplexing}             text|true|//*[@name\="actCsirsMultiplexing"]
${actDlSrsBm}                       text|true|//*[@name\="actDlSrsBm"]
${actUlSrsBm}                       text|true|//*[@name\="actUlSrsBm"]
${actDlSrsSubbandBm}                text|true|//*[@name\="actDlSrsSubbandBm"]
${actUlClosedLoopPwrCtrl}           text|disabled|//*[@name\="actUlClosedLoopPwrCtrl"]
${actCDrx}                          text|false|//*[@name\="actCDrx"]
${actFdmScheduling}                 text|true|//*[@name\="actFdmScheduling"]
${frameStructureType}               text|semiStatic|//*[@name\="frameStructureType"]
${guardPeriodLength}                text|2Symbols|//*[@name\="guardPeriodLength"]
#${lteToNrFrameShift}                text|0ms|//*[@name\="lteToNrFrameShift"]
${ulDlDataSlotRatio}                text|1/4|//*[@name\="ulDlDataSlotRatio"]
${prachConfigurationIndex}          text|98|//*[@name\="prachConfigurationIndex"]
${srsUePeriodicity}                 text|slots40|//*[@name\="srsUePeriodicity"]
${cSRS}                             text|63|//*[@name\="cSRS"]
${bSRS}                             text|2|//*[@name\="bSRS"]
${srsPowerThresholdForDlBm}         text|-1200|//*[@name\="srsPowerThresholdForDlBm"]
${srsTypeAllocForDlBm}              text|antenna switching or codebook|//*[@name\="srsTypeAllocForDlBm"]
${bfSubbandSize}                    text|16 PRBs|//*[@name\="bfSubbandSize"]
${maxNumUeSrs}                      text|4|//*[@name\="maxNumUeSrs"]
${srsQualityThreshold}              text|-1200|//*[@name\="srsQualityThreshold"]
#${bwp_profile7}                     text|MRBTS-1/NRBTS-1/BWP_PROFILE-7|//*[@name\="cellBwpList"]/item[1]/*[@name\="bwpDN"]
#${bwp_profile73}                    text|MRBTS-1/NRBTS-1/BWP_PROFILE-73|//*[@name\="cellBwpList"]/item[2]/*[@name\="bwpDN"]
${actCustomBsr}                     text|true|//*[@name\="actCustomBsr"]
${customBeamSetName}                text|BSR_AQQL_6_H6_ALN60_ARP60_P11_COVERAGE_00776_00001|//*[@name\="customBeamSetName"]
${actIncreasedFdmUsersPerSlot}      text|true|//*[@name\="actIncreasedFdmUsersPerSlot"]
${actDlMuMimoEnh}                   text|false|//*[@name\="actDlMuMimoEnh"]
${actDl256Qam}                      text|true|//*[@name\="actDl256Qam"]
${actUl256Qam}                      text|true|//*[@name\="actUl256Qam"]
#${miNrMacSduReport}                 text|15min|//*[@name\="miNrMacSduReport"]
${actShortBsrLimitAdaptation}       text|true|//*[@name\="actShortBsrLimitAdaptation"]
${actBbPoolTddFr1}                  text|true|//*[@name\="actBbPoolTddFr1"]
${allowSlowPrbPoolingStatNdmSrs}    text|true|//*[@name\="allowSlowPrbPoolingStatNdmSrs"]
${actBbPoolExtensionTddFr1}         text|true|//*[@name\="actBbPoolExtensionTddFr1"]
${bbmodBoardConfigType}             text|LTETDD_NRTDD|//*[@name\="bbmodBoardConfigType"]
#${SystemInformationTargetRate}      text|251|//*[@name\="SystemInformationTargetRate"]
${prbSampleHighLowPercentage}       text|80|//*[@name\="prbSampleHighLowPercentage"]
${prbRatioThreshold}                text|4|//*[@name\="prbRatioThreshold"]
${prbRatioHysteresis}               text|2|//*[@name\="prbRatioHysteresis"]
${srsSinrThreshold}                 text|-400|//*[@name\="srsSinrThreshold"]
${tiltOffset}                       text|0|//*[@name\="tiltOffset"]
${par_of_bsr_name}                BSR_AQQL_6_H6_ALN60_ARP60_P11_COVERAGE_00776_00001
${pattern1}                       CA_P2_8x4_t2r4_n2
${pattern2}                       CA_P2_8x4_t1r4_n1 
${pattern3}                       CA_P2_8x4_t4r4_n4
${pattern4}                       CA_P2_8x4_noTas_n2
${pattern5}                       TDD_NSA_CA_NoRefinebeam

${PROFILE1}    ul_mimo_srs_beam_pos_nr profile_id=1 mode=fixed init_quad_pos=1 init_sub_quad_pos=1 test_type=SRS
...        multi_path_config=true num_of_nlos_paths=1 azimuth=30 zenith=0 srs_transmit_power_per_port=-200,-200,-200,-200
${PROFILE2}    ul_mimo_srs_beam_pos_nr profile_id=2 mode=fixed init_quad_pos=1 init_sub_quad_pos=1 test_type=SRS
...        multi_path_config=true num_of_nlos_paths=1 azimuth=30 zenith=0 srs_transmit_power_per_port=-200,-200,-200,-200
${SET_PROFILE1}    ue_testmode_set_nr id=11 testmode=ul_mimo_srs_beam_pos action=activate profile_id=1

*** Test Cases ***
CB008322_B3_case108_wide_band_TAS_SRS_configuration_algorithm_pool_multiple_cells
    Step1:Commission the above configuration on WebUI
    Step2:UEs attach to cells
    Step3:Send DL full buffer to UEs
    Step4:UEs SRS Switch
	Step5:Detach UEs

*** Keywords ***
Step1:Commission the above configuration on WebUI
    Start Collect GNB and AP Syslog in 'Step1_before_onair' File
    ${CONFIG_DIR_PATH}    Set Variable    ${CONFIG_DIR_PATH}/${SW_BRANCH}
    #${mod_iphy}    create list     text|2|//NumberOfSubCellsDL
    #modify xml     ${CONFIG_DIR_PATH}${/}${AIRPHONE_NAME}      ${CONFIG_DIR_PATH}${/}${AIRPHONE_NAME}    ${mod_iphy}
    change_iphy_rru_version    ${CONFIG_DIR_PATH}${/}${AIRPHONE_NAME}
    modify_swconfig_by_CB008322    ${CONFIG_DIR_PATH}${/}${SCFC_NAME}
    ${scfc_path}    Set Variable    ${TEST_LOG_DIRECTORY()}${/}scfc.xml
    copy_file    ${CONFIG_DIR_PATH}/${SCFC_NAME}    ${scfc_path}
    #del_elements_from_xml    xml_path=${scfc_path}    parameter=lteToNrFrameShift
    #del_elements_from_xml    xml_path=${scfc_path}    parameter=tdLteUlDlConfig
    add_bwplist_list_in_cells_new    ${scfc_path}    key_4
    ${modify_list}    create list
    ...      ${cellDepType}    ${actSpatialStreamPooling}    ${actTddPrePooling}  
	...      ${chBw}                    ${dlMimoMode}                  ${nrCellType}                
    ...      ${actUeCsirsCoexistCellCsirs}    ${actCsirsMultiplexing}    ${actDlSrsBm}                  ${actUlSrsBm}
    ...      ${actDlSrsSubbandBm}
    ...      ${actUlClosedLoopPwrCtrl}        ${actCDrx}                 ${actFdmScheduling}            ${frameStructureType}
    ...      ${guardPeriodLength}
    ...      ${ulDlDataSlotRatio}    ${prachConfigurationIndex}     ${srsUePeriodicity}
    ...      ${cSRS}                          ${bSRS}                    ${srsPowerThresholdForDlBm}    ${srsTypeAllocForDlBm}
    ...      ${bfSubbandSize}           ${maxNumUeSrs}                 ${srsQualityThreshold} 
    ...      ${actCustomBsr}                  ${customBeamSetName}       ${actIncreasedFdmUsersPerSlot}
    ...      ${actDlMuMimoEnh}                ${actDl256Qam}             ${actUl256Qam}     
    ...      ${actShortBsrLimitAdaptation}    ${actBbPoolTddFr1}         ${allowSlowPrbPoolingStatNdmSrs}
    ...      ${actBbPoolExtensionTddFr1}      ${bbmodBoardConfigType}
    ...      ${prbSampleHighLowPercentage}    ${prbRatioThreshold}        ${prbRatioHysteresis}
    ...      ${srsSinrThreshold}
    ...      ${tiltOffset}
    modify_xml    ${scfc_path}    ${scfc_path}    ${modify_list}
    Modify TL VM And AP SCTP Configuration
    Get and Update BSR File    ${par_of_bsr_name}
    Add L2PS Deubg Logs
    Perform Full Commission And Reach Onair With Log    ${scfc_path}    ${CONFIG_DIR_PATH}${/}${WTS_NAME}    reset_after_commission=${False}
    [Teardown]    Stop Collect GNB and AP Syslog in 'Step1_before_onair' File

Step2:UEs attach to cells
    Start capture GNB and AP Syslog in 'Step2_attach' File
   	${ue_capability}    Obtain Ue Capability    ${pattern5}
	#Start GNB BIP Log
    FOR    ${i}    IN RANGE    11    17
        Airphone Nsa Attach    ue_id=${i}    cell_id=1    ue_nr_capabilities=${ue_capability}
    END

    FOR    ${i}    IN RANGE    17    23
        Airphone Nsa Attach    ue_id=${i}    cell_id=2    ue_nr_capabilities=${ue_capability}
    END

    FOR    ${i}    IN RANGE    23    31
        Airphone Nsa Attach    ue_id=${i}    cell_id=3    ue_nr_capabilities=${ue_capability}
    END

    FOR    ${i}    IN RANGE    11    31
    	Set UEi position    ${i}
    END
	#Stop Gnb BIP Log    log_dir=${TEST_LOG_DIRECTORY()}${/}Step2_attach${/}
    ${save_log}=    Set Variable    ${TEST_LOG_DIRECTORY()}Step2_attach
    Start GNB Ttitrace With Streaming Mode
    Wait '5s' for stable running
    ${pacp}=    Stop GNB Ttitrace With Streaming Mode    save_path=${save_log}
    Decoder Tttirace From Pcap To Csv    ${pacp}    ${save_log}/tti
	airphone_collect_egate_log_files      ${TEST_LOG_DIRECTORY()}${/}Step2_attach${/}   unzip=TRUE
	#${rnti_list}    file match all   ${TEST_LOG_DIRECTORY()}${/}Step2_attach${/}/egate_console.log.001   crnti: (\\d+)
	${rnti_list}    file match all   ${TEST_LOG_DIRECTORY()}${/}Step2_attach${/}/egate_console.log.001   newUE-Identity (\\d+)
	Set test Variable    ${rnti_1}    ${rnti_list[0]}
	Set test Variable    ${rnti_2}    ${rnti_list[1]}
	Set test Variable    ${rnti_3}    ${rnti_list[2]}
	Set test Variable    ${rnti_4}    ${rnti_list[3]}
	Set test Variable    ${rnti_5}    ${rnti_list[4]}
	Set test Variable    ${rnti_6}    ${rnti_list[5]}
	Set test Variable    ${rnti_7}    ${rnti_list[6]}
	Set test Variable    ${rnti_8}    ${rnti_list[7]}
	Set test Variable    ${rnti_9} 	  ${rnti_list[8]}
	Set test Variable    ${rnti_10}    ${rnti_list[9]}
	Set test Variable    ${rnti_11}    ${rnti_list[10]}
	Set test Variable    ${rnti_12}    ${rnti_list[11]}
	Set test Variable    ${rnti_13}    ${rnti_list[12]}
	Set test Variable    ${rnti_14}    ${rnti_list[13]}
	Set test Variable    ${rnti_15}    ${rnti_list[14]}
	Set test Variable    ${rnti_16}    ${rnti_list[15]}
	Set test Variable    ${rnti_17}    ${rnti_list[16]}
	Set test Variable    ${rnti_18}    ${rnti_list[17]}
	Set test Variable    ${rnti_19}    ${rnti_list[18]}
	Set test Variable    ${rnti_20}    ${rnti_list[19]}
    [Teardown]    Stop capture GNB and AP Syslog in 'Step2_attach' File

Step3:Send DL full buffer to UEs
    Start capture GNB and AP Syslog in 'Step3_send_data' File
    FOR    ${i}    IN RANGE    11    15
        Send trf for UE NSA    ${i}    dl    100M    1
    END

    FOR    ${i}    IN RANGE    17    21
        Send trf for UE NSA    ${i}    dl    100M    1
    END
    
    FOR    ${i}    IN RANGE    23    27
        Send trf for UE NSA    ${i}    dl    100M    1
    END
    Send trf for UE NSA    15    dl    5M    1
	Send trf for UE NSA    16    dl    5M    1
	Send trf for UE NSA    21    dl    5M    1
	Send trf for UE NSA    22    dl    5M    1
	Send trf for UE NSA    27    dl    5M    1
	Send trf for UE NSA    28    dl    5M    1
	Send trf for UE NSA    29    dl    5M    1
    Send trf for UE NSA    30    dl    5M    1
	#Start GNB BIP Log
	Start GNB Ttitrace With Streaming Mode
	Wait '1s' for stable running
	${save_log}=    Set Variable    ${TEST_LOG_DIRECTORY()}Step3_send_data
	${pacp}=    Stop GNB Ttitrace With Streaming Mode    save_path=${save_log}
	#Stop Gnb BIP Log    log_dir=${TEST_LOG_DIRECTORY()}${/}Step3_send_data${/}
	Decoder Tttirace From Pcap To Csv    ${pacp}    ${save_log}/tti
	run keyword and continue on failure
	...    check_log_with_au2anlysis    ini_path=${CURDIR}/log_check/CB008322_B3_case108_step3_tti.ini    log_need_to_check=i
    ...    save_log_directory=${save_log}
    #${DL_throughput}    get tput from PM counter
	#run keyword and continue on failure
	#    ...    should be true    ${DL_throughput}>900
	[Teardown]    Stop capture GNB and AP Syslog in 'Step3_send_data' File

Step4:UEs SRS Switch
    Start capture GNB and AP Syslog in 'Step4_srs_switch' File
	FOR    ${i}    IN RANGE    11    31
	    Airphone Nsa Stop Data Traffic    ${i}    dl
    END
    Send trf for UE NSA    11    dl    5M    1
	Send trf for UE NSA    12    dl    5M    1	
    FOR    ${i}    IN RANGE    13    17
        Send trf for UE NSA    ${i}    dl    100M    1
    END
	Send trf for UE NSA    17    dl    5M    1
	Send trf for UE NSA    18    dl    5M    1	
    FOR    ${i}    IN RANGE    19    23
        Send trf for UE NSA    ${i}    dl    100M    1
    END
    Send trf for UE NSA    23    dl    5M    1
    Send trf for UE NSA    24    dl    5M    1
    Send trf for UE NSA    25    dl    5M    1
    Send trf for UE NSA    26    dl    5M    1	
    FOR    ${i}    IN RANGE    27    31
        Send trf for UE NSA    ${i}    dl    100M    1
    END
    #Start GNB BIP Log
    Start GNB Ttitrace With Streaming Mode
    Wait '1s' for stable running
    ${save_log}=    Set Variable    ${TEST_LOG_DIRECTORY()}Step4_srs_switch
    ${pacp}=    Stop GNB Ttitrace With Streaming Mode    save_path=${save_log}
    #Stop Gnb BIP Log    log_dir=${TEST_LOG_DIRECTORY()}${/}Step4_srs_switch${/}
    Decoder Tttirace From Pcap To Csv    ${pacp}    ${save_log}/tti
    run keyword and continue on failure
    ...    check_log_with_au2anlysis    ini_path=${CURDIR}/log_check/CB008322_B3_case108_step4_tti.ini    log_need_to_check=i
    ...    save_log_directory=${save_log}
    #${DL_throughput}    get tput from PM counter
    #run keyword and continue on failure
    #    ...    should be true    ${DL_throughput}>900
    [Teardown]    Stop capture GNB and AP Syslog in 'Step4_srs_switch' File

Step5:Detach UEs
    Start capture GNB and AP Syslog in 'Step5_detach' File
    FOR    ${i}    IN RANGE    11    31
	    	Airphone Nsa Detach    ue_id=${i}
    END
    [Teardown]    Stop capture GNB and AP Syslog in 'Step5_detach' File

Send trf for UE NSA
    [Arguments]    ${ue_id}    ${DLorUL}    ${mbps}    ${number}
    FOR    ${num}    IN RANGE    1    ${number}+1
        Airphone Nsa Start Data Traffic    ${ue_id}    ${DLorUL}    ${mbps}    trf_id=${num}    bearer_id=2    duration=3600
    END

Set UEi position
    [Arguments]    ${ue_id}
    airphone_execute_egate_command    ${PROFILE2}
	airphone_execute_egate_command
    ...    ue_testmode_set_nr id\=${ue_id} testmode\=ul_mimo_srs_beam_pos action\=activate profile_id\=2

Override UEi to DL RANKj and CQIk
    [Arguments]    ${ue_id}    ${ranki}    ${cqii}
	airphone_execute_egate_command
   	...    csi_override_testmode_nr profile_id\=${ue_id}+1 ri_mode\=fixed ri\=${ranki} cqi_mode\=fixed cqi\=${cqii}
	airphone_execute_egate_command
	...    ue_testmode_set_nr id\=${ue_id} testmode\=csi_override action\=activate profile_id\=${ue_id}+1
	
Stop UE DL Traffic
    [Arguments]    ${ue_id}
    airphone_sa_stop_data_traffic    ${ue_id}    DL

modify_swconfig_by_CB008322
    comment     https://confluence.ext.net.nokia.com/pages/viewpage.action?spaceKey=AirPhoneWTS&title=AirPhone+Alignment+to+gNB+L1L2+Interface
    [Arguments]    ${scfc_file}
    ${local_save_path}=     Download All Common Config Files From Golden Server
    ${path_gnb}=            Find Match GNB swconfig Golden Files    ${scfc_file}    ${local_save_path}
    ${path_ap}=             Find Match AP swconfig Golden Files    ${scfc_file}     ${local_save_path}
    ${CONFIG_DIR_PATH2}    Set Variable    ${CONFIG_DIR_PATH}/${SW_BRANCH}
    #${path_gnb}    Set Variable     ${CONFIG_DIR_PATH2}${/}${SWCONFIG_NAME}
    #${path_ap}    Set Variable     ${CONFIG_DIR_PATH2}${/}${AP_SWCONFIG_NAME}
    setup_txt    src_file=${path_gnb}    save_path=${TEST_LOG_DIRECTORY()}${/}swconfig_gnb_ini.txt
    add_txt_node    0x58079e:0        #rdWbSrsConstraintTimer
    teardown_txt
    setup_txt    src_file=${path_ap}    save_path=${TEST_LOG_DIRECTORY()}${/}swconfig_ap_ini.txt
    teardown_txt
    GNB Upload Swconfig           ${TEST_LOG_DIRECTORY()}${/}swconfig_gnb_ini.txt
    airphone_upload_swconfig      ${TEST_LOG_DIRECTORY()}${/}swconfig_ap_ini.txt
	
Add L2PS Deubg Logs	
    ${debuglogs}    create list    level=DBG\n    L2.L2_PS.DEBUG=1\n    L2.L2_PS.DL.SUBBAND_BEAMFORMING=1\n    L2.L2_PS.SRS_BASED_BM=1\n 
	Active L2ps Feature Debug Traces    ${debuglogs}
	TAF_SSH.connect to    192.168.255.1   toor4nsn    oZPS0POrRieRtu   alias=bsh
	TAF_SSH.execute    rm /ffs/run/HashContainer*    connection=bsh
