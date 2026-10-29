*** Settings ***
Documentation
...

Suite Setup       Common Suite Setup
#Suite Teardown    Common Suite Teardown
Test Setup        Common Test Setup
Test Teardown     Common Test Teardown
Force Tags        CLOUD_5G_I_MP_AP_LO    AP    CRT    SBTS00    RAN_5G_TDD    RAN_5G    owner_xueminm
Test Timeout      90 minutes
Resource          ../../resources/sg11/internal_resource/robot/modify_configuration.robot
Resource          ../../resources/sg11/internal_resource/robot/internal_ap_operate.robot
Resource          ../../resources/sg11/internal_resource/robot/internal_gnb_operate.robot
Resource          ../../resources/sg11/internal_resource/robot/internal_capture_log.robot
Library     taf.transport.ssh    WITH NAME    TAF_SSH
Library           ta_a2a

*** Variables ***
${CONFIG_DIR_PATH}    ${CURDIR}/config
${SCFC_NAME}   SCF_G_1cell_MP_LO.xml
${AIRPHONE_NAME}    iphy_D_1cell_AEQE.xml
${WTS_NAME}    wts_D_1cell.cfg
@{LOG_NAME_LIST}        egatelog
#gnb_snapshot
${cellDepType}                             text|SA+NSA|//*[@name\="cellDepType"]
${chBw}                                    text|100MHz|//*[@name\="chBw"]
${dlMimoMode}                              text|8x4 Closed Loop Spatial Multiplexing|//*[@name\="dlMimoMode"]
${actDlSrsBm}                              text|false|//*[@name\="actDlSrsBm"]
${actUlSrsBm}                              text|true|//*[@name\="actUlSrsBm"]
${actAperCsi}                              text|true|//*[@name\="actAperCsi"]
${nrCellType}                              text|8DL8UL|//*[@name\="nrCellType"]
${actUlOpenLoopPwrCtrl}                    text|false|//*[@name\="actUlOpenLoopPwrCtrl"]
${pucchModeSelect}                         text|longPucch|//*[@name\="pucchModeSelect"]
${numberOfRxBeamforming}                   text|8Rx|//*[@name\="numberOfRxBeamforming"]
${numberOfRxPucch}                         text|8Rx|//*[@name\="numberOfRxPucch"]
${actFdmScheduling}                        text|true|//*[@name\="actFdmScheduling"]
${actBeamforming}                          text|true|//*[@name\="actBeamforming"]
${nrBtsBeamRefinementP2}                   text|false|//*[@name\="nrBtsBeamRefinementP2"]
${actBbPoolTddFr1}                         text|true|//*[@name\="actBbPoolTddFr1"]
${actBbPoolTddFr1Enh}                      text|true|//*[@name\="actBbPoolTddFr1Enh"]
${basicBeamSet}                            text|beamSet_3_1|//*[@name\="basicBeamSet"]
${numberOfTransmittedSsBlocks}             text|4 beams|//*[@name\="numberOfTransmittedSsBlocks"]
${actShortBsrLimitAdaptation}              text|true|//*[@name\="actShortBsrLimitAdaptation"]
${actCsirsMultiplexing}                    text|true|//*[@name\="actCsirsMultiplexing"]
${actUlDftSOfdm}                           text|true|//*[@name\="actUlDftSOfdm"]
${actDl256Qam}                             text|true|//*[@name\="actDl256Qam"]
${actUl256Qam}                             text|true|//*[@name\="actUl256Qam"]
${actAdaptiveReTxResMcs}                   text|true|//*[@name\="actAdaptiveReTxResMcs"]
${minPctResourceReservedMcsDl}             text|50|//*[@name\="minPctResourceReservedMcsDl"]
${targetPctResourceReservedMcsDl}          text|100|//*[@name\="targetPctResourceReservedMcsDl"]
${actUlDataDmrsFdm}                        text|true|//*[@name\="actUlDataDmrsFdm"]
${ulDataDmrsFdmThres256QamMcs}             text|20|//*[@name\="ulDataDmrsFdmThres256QamMcs"]
${ulDataDmrsFdmThres64QamMcs}              text|20|//*[@name\="ulDataDmrsFdmThres64QamMcs"]
${ullaDeltaSinrMax}                        text|20|//*[@name\="ullaDeltaSinrMax"]
${ullaDeltaSinrMin}                        text|0|//*[@name\="ullaDeltaSinrMin"]
${targetPctResourceReservedMcsUl}          text|95|//*[@name\="targetPctResourceReservedMcsUl"]
${minPctResourceReservedMcsUl}             text|50|//*[@name\="minPctResourceReservedMcsUl"]
${miNrUlSignalQuality}                     text|5min|//*[@name\="miNrUlSignalQuality"]
${miNrMacPduTput}                          text|5min|//*[@name\="miNrMacPduTput"]
${miNrUlHarq}                              text|5min|//*[@name\="miNrUlHarq"]

${ul_bler}          bler_testmode_nr profile_id=1 ul_bler=100,100,100,50
${Act_ul_bler}      ue_testmode_set_nr id=1 testmode=bler profile_id=1 action=activate
${Deact_ul_bler}    ue_testmode_set_nr id=1 testmode=bler profile_id=1 action=deactivate

${ul_sinr}          ul_cell_noise_testmode_nr profile_id=2 noise_pusch=-900
${Act_ul_sinr}      cell_testmode_set_nr cell_id=1 gnb=1 testmode=ul_cell_noise profile_id=2 action=activate
${Deact_ul_sinr}    cell_testmode_set_nr cell_id=1 gnb=1 testmode=ul_cell_noise profile_id=2 action=deactivate

*** Test Cases ***
CB009363-G_005_adaptive_retransmission_scheme_basic_alhorithm_without_change_of_modulation_in_UL
    Step1:Commission the above configuration on WebUI
	Step2:Attach UE
	Step3:Start traffic and activate UL SINR and UL BLER

*** Keywords ***
Step1:Commission the above configuration on WebUI
    Start Capture GNB and AP Syslog in 'Step1_before_onair' File
    ${CONFIG_DIR_PATH}    Set Variable    ${CONFIG_DIR_PATH}/${SW_BRANCH}
    change_iphy_rru_version    ${CONFIG_DIR_PATH}${/}${AIRPHONE_NAME}
    modify_swconfig    ${CONFIG_DIR_PATH}${/}${SCFC_NAME}
    ${scfc_path}    Set Variable    ${TEST_LOG_DIRECTORY()}${/}scfc.xml
    copy_file    ${CONFIG_DIR_PATH}/${SCFC_NAME}    ${scfc_path}
    ${modify_list}    create list
	...      ${cellDepType}    ${chBw}    ${dlMimoMode}    ${actDlSrsBm}    ${actUlSrsBm}    ${actAperCsi}    ${nrCellType}                       
	...      ${actUlOpenLoopPwrCtrl}    ${pucchModeSelect}    ${numberOfRxBeamforming}    ${numberOfRxPucch}    ${actFdmScheduling}                 
	...      ${actBeamforming}    ${nrBtsBeamRefinementP2}    ${actBbPoolTddFr1}    ${actBbPoolTddFr1Enh}    ${basicBeamSet}                     
	...      ${numberOfTransmittedSsBlocks}    ${actShortBsrLimitAdaptation}    ${actCsirsMultiplexing}    ${actUlDftSOfdm}                    
	...      ${actDl256Qam}    ${actUl256Qam}    ${actAdaptiveReTxResMcs}    ${minPctResourceReservedMcsDl}    ${targetPctResourceReservedMcsDl}   
	...      ${actUlDataDmrsFdm}     ${ullaDeltaSinrMax}    ${ullaDeltaSinrMin}   
	...      ${ulDataDmrsFdmThres256QamMcs}    ${ulDataDmrsFdmThres64QamMcs}                  
	...      ${targetPctResourceReservedMcsUl}    ${minPctResourceReservedMcsUl}    ${miNrUlSignalQuality}    ${miNrMacPduTput}    ${miNrUlHarq} 
    modify_xml    ${scfc_path}    ${scfc_path}    ${modify_list}
    Modify TL VM And AP SCTP Configuration
	Get and Update BSR File    par_of_bsr_name=AEQE_6_H6_ALN60_ARP60_P00_COVERAGE_00424_00001
	Perform Full Commission And Reach Onair With Log    ${scfc_path}    ${CONFIG_DIR_PATH}${/}${WTS_NAME}    reset_after_commission=${False}
    ${save_log}=    Set Variable    ${TEST_LOG_DIRECTORY()}Step1_before_onair
    [Teardown]    Stop Capture GNB and AP Syslog in 'Step1_before_onair' File

modify_swconfig
    comment     https://confluence.ext.net.nokia.com/pages/viewpage.action?spaceKey=AirPhoneWTS&title=AirPhone+Alignment+to+gNB+L1L2+Interface
    [Arguments]    ${scfc_file}
	${local_save_path}=     Download All Common Config Files From Golden Server
	${path_gnb}=            Find Match GNB swconfig Golden Files    ${scfc_file}    ${local_save_path}
	${path_ap}=             Find Match AP swconfig Golden Files    ${scfc_file}     ${local_save_path}
    setup_txt    src_file=${path_gnb}    save_path=${TEST_LOG_DIRECTORY()}${/}swconfig_gnb_ini.txt
	add_txt_node    0x9D0000:5          #as PM counter period update to 15/15=1min
	add_txt_node    0x420068:7    #rdTddPoolingFeaturesEnable
    add_txt_node    0x580180:0    #rdHARQDisableIncrRedundancyUl 0x580180=0 (default)
    add_txt_node    0x580678:6    # Defines the maximum number of NACKs received at gNB for a HARQ process
    teardown_txt
	setup_txt    src_file=${path_ap}    save_path=${TEST_LOG_DIRECTORY()}${/}swconfig_ap_ini.txt
    #add_txt_node    0x70690:1         #enable 1086 and 8247
    teardown_txt
    GNB Upload Swconfig           ${TEST_LOG_DIRECTORY()}${/}swconfig_gnb_ini.txt
    airphone_upload_swconfig      ${TEST_LOG_DIRECTORY()}${/}swconfig_ap_ini.txt

Step2:Attach UE
    Start capture GNB and AP Syslog in 'Step2_attach' File
	${save_log}=    Set Variable    ${TEST_LOG_DIRECTORY()}Step2_attach
	Start GNB BIP Log
	Attach SA ue with capability to 5g cell    1    CA_P2_8x4_t2r4_n2
    Wait '5s' for stable running
    Stop Gnb BIP Log    log_dir=${save_log}
	[Teardown]    Stop capture GNB and AP Syslog in 'Step2_attach' File

Step3:Start traffic and activate UL SINR and UL BLER
    Start capture GNB and AP Syslog in 'Step3' File
	${save_log}=    Set Variable    ${TEST_LOG_DIRECTORY()}Step3
	Start GNB BIP Log
	Airphone Sa Start Data Traffic    ue_id=1    direction=ul    throughput=175M    trf_id=1    duration=7200
	Airphone Sa Start Data Traffic    ue_id=1    direction=ul    throughput=175M    trf_id=2    duration=7200
	Airphone Sa Start Data Traffic    ue_id=1    direction=dl    throughput=175M    trf_id=1    duration=7200
	Wait Throughput Timer    15
    Airphone Execute Egate Command    ${ul_bler}       
	Airphone Execute Egate Command    ${Act_ul_bler}   	
	Airphone Execute Egate Command    ${ul_sinr}       
	Airphone Execute Egate Command    ${Act_ul_sinr}  
    Wait '5s' for stable running	
    Capture ttitrace    3s    ${save_log}    step3
    Stop Gnb BIP Log    log_dir=${save_log}

	${remaining_time}=    get_counter_file_remaining_time    counter_refresh_period=5min
    Wait Throughput Timer    ${remaining_time}
    ${PM_counter_file}=    download_latest_pmcounter    local_path=${TEST_LOG_DIRECTORY()}Step3${/}
	${UNSUCC_256TBL_MCS_31}     get_counter_value_from_counter_file    counter_file=${PM_counter_file}     counter_id=M55302C12031    cell_id=1
	${Rank1_256TBL_MCS_31}      get_counter_value_from_counter_file    counter_file=${PM_counter_file}     counter_id=M55303C22031    cell_id=1
	should be true    ${UNSUCC_256TBL_MCS_31} > 0
	#should be true    ${Rank1_256TBL_MCS_31} > 0
    run keyword and continue on failure    check_log_with_au2anlysis
    ...    ini_path=${CURDIR}/log_check/G_case05_tti.ini    log_need_to_check=i    save_log_directory=${save_log}
	[Teardown]    Stop capture GNB and AP Syslog in 'Step3' File

Capture ttitrace
    [Arguments]    ${time}    ${save_log}     ${file_tag}
    Start GNB Ttitrace With Streaming Mode
    sleep    ${time}
    ${pacp}=    Stop GNB Ttitrace With Streaming Mode    save_path=${save_log}
    Decoder Tttirace From Pcap To Csv    ${pacp}    ${save_log}/${file_tag}

