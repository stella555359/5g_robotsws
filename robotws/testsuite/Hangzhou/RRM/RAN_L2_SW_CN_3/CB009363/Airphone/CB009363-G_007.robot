*** Settings ***
Documentation
...    value of 1 corresponds to 0dB, no power control
...    value of 0 corresponds to -1 dB used in CLPC
...    value of 2 corresponds to +1 dB used in CLPC
...    value of 3 corresponds to +3 dB used in CLPC


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
@{LOG_NAME_LIST}        egatelog    gnb_snapshot
${cellDepType}                             text|SA+NSA|//*[@name\="cellDepType"]
${chBw}                                    text|100MHz|//*[@name\="chBw"]
${dlMimoMode}                              text|8x4 Closed Loop Spatial Multiplexing|//*[@name\="dlMimoMode"]
${actDlSrsBm}                              text|false|//*[@name\="actDlSrsBm"]
${actUlSrsBm}                              text|true|//*[@name\="actUlSrsBm"]
${actAperCsi}                              text|true|//*[@name\="actAperCsi"]
${nrCellType}                              text|8DL8UL|//*[@name\="nrCellType"]
${pucchModeSelect}                         text|longPucch|//*[@name\="pucchModeSelect"]
${numberOfRxBeamforming}                   text|8Rx|//*[@name\="numberOfRxBeamforming"]
${numberOfRxPucch}                         text|8Rx|//*[@name\="numberOfRxPucch"]
${actFdmScheduling}                        text|true|//*[@name\="actFdmScheduling"]
${actBeamforming}                          text|true|//*[@name\="actBeamforming"]
${nrBtsBeamRefinementP2}                   text|false|//*[@name\="nrBtsBeamRefinementP2"]
${actBbPoolTddFr1}                         text|true|//*[@name\="actBbPoolTddFr1"]
${actBbPoolTddFr1Enh}                      text|true|//*[@name\="actBbPoolTddFr1Enh"]
${actUlDataDmrsFdm}                        text|true|//*[@name\="actUlDataDmrsFdm"]
${actUlOpenLoopPwrCtrl}                    text|true|//*[@name\="actUlOpenLoopPwrCtrl"]
${basicBeamSet}                            text|beamSet_4|//*[@name\="basicBeamSet"]
${numberOfTransmittedSsBlocks}             text|4 beams|//*[@name\="numberOfTransmittedSsBlocks"]
${actShortBsrLimitAdaptation}              text|true|//*[@name\="actShortBsrLimitAdaptation"]
${actCsirsMultiplexing}                    text|true|//*[@name\="actCsirsMultiplexing"]
${actUlDftSOfdm}                           text|true|//*[@name\="actUlDftSOfdm"]
${actDl256Qam}                             text|true|//*[@name\="actDl256Qam"]
${actUl256Qam}                             text|true|//*[@name\="actUl256Qam"]
${actUlClosedLoopPwrCtrl}                  text|puschSrs|//*[@name\="actUlClosedLoopPwrCtrl"]

${cell_noise}        ul_cell_noise_testmode_nr profile_id=1 noise_pusch=-700
${Set_cell_noise}    cell_testmode_set_nr gnb=1 cell_id=1 testmode=ul_cell_noise profile_id=1 action=activate

${phr}         phr_override_testmode_nr profile_id=1 phr_mode=Fixed phr_start=-5 phr_min=-5 phr_max=-5
${Set_phr}     ue_testmode_set_nr id=1 testmode=phr_override action=activate profile_id=1

${FILTER1}    dldata_pdcchsendreq
@{title1}     dci.dci01.TPCforScheduledPUSCH

*** Test Cases ***
CB009363-G_007_uplink_closed_loop_power_control_for_PUSCH
    Step1:Commission the above configuration on WebUI
    Step2:Attach UE
    Step3:Adjust sinr_pusch
    Step4:Detach UE1
    Step5:Attach UE with phr_override
    Step6:Adjust pusch sinr again

*** Keywords ***
Step1:Commission the above configuration on WebUI
    Start Capture GNB and AP Syslog in 'Step1_before_onair' File
    ${CONFIG_DIR_PATH}    Set Variable    ${CONFIG_DIR_PATH}/${SW_BRANCH}
    change_iphy_rru_version    ${CONFIG_DIR_PATH}${/}${AIRPHONE_NAME}
    modify_swconfig    ${CONFIG_DIR_PATH}${/}${SCFC_NAME}
    ${scfc_path}    Set Variable    ${TEST_LOG_DIRECTORY()}${/}scfc.xml
    copy_file    ${CONFIG_DIR_PATH}/${SCFC_NAME}    ${scfc_path}
    ${modify_list}    create list
	...      ${cellDepType}                    ${nrBtsBeamRefinementP2}
	...      ${chBw}                           ${actBbPoolTddFr1}
	...      ${dlMimoMode}                     ${actBbPoolTddFr1Enh}
	...      ${actDlSrsBm}                     ${actUlDataDmrsFdm}
	...      ${actUlSrsBm}                     ${actUlOpenLoopPwrCtrl}
	...      ${actAperCsi}                     ${basicBeamSet}
	...      ${nrCellType}                     ${numberOfTransmittedSsBlocks}
	...      ${pucchModeSelect}                ${actShortBsrLimitAdaptation}
	...      ${numberOfRxBeamforming}          ${actCsirsMultiplexing}
	...      ${numberOfRxPucch}                ${actUlDftSOfdm}
	...      ${actFdmScheduling}               ${actDl256Qam}
	...      ${actBeamforming}                 ${actUl256Qam}
	...      ${actUlClosedLoopPwrCtrl}
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
	Attach SA ue with capability to 5g cell    1    SA_UE_NR_CAPA_FULL_7220_2200_9363
    Wait '5s' for stable running
	Airphone Sa Start Data Traffic    ue_id=1    direction=ul    throughput=5M    trf_id=1    duration=7200
	Airphone Sa Start Data Traffic    ue_id=1    direction=dl    throughput=5M    trf_id=1    duration=7200
	Wait '5s' for stable running
	Capture ttitrace    3s    ${save_log}    step2_1
    Airphone Execute Egate Command    ${cell_noise}
    Airphone Execute Egate Command    ${Set_cell_noise}
	Wait '5s' for stable running
	Capture ttitrace    3s    ${save_log}    step2_2
	[Teardown]    Stop capture GNB and AP Syslog in 'Step2_attach' File

Step3:Adjust sinr_pusch
    Start capture GNB and AP Syslog in 'Step3' File
	${save_log}=    Set Variable    ${TEST_LOG_DIRECTORY()}Step3
	Start GNB BIP Log
	Start GNB Ttitrace With Streaming Mode
	airhone_execute_command_and_wait_for_data    script file\=${CURDIR}/JSON/sinr_pusch.lua
	Wait '15s' for stable running
	${pacp}=    Stop GNB Ttitrace With Streaming Mode    save_path=${save_log}
    Stop Gnb BIP Log    log_dir=${save_log}
	Decoder Tttirace From Pcap To Csv    ${pacp}    ${save_log}/tti
    run keyword and continue on failure
    ...    check_log_with_au2anlysis    ini_path=${CURDIR}/log_check/G_case07_tti.ini    log_need_to_check=i
    ...    save_log_directory=${save_log}
	[Teardown]    Stop capture GNB and AP Syslog in 'Step3' File

Step4:Detach UE1
    Start capture GNB and AP Syslog in 'Step4_detach_ue1' File
    Detach '1'UE
	[Teardown]    Stop capture GNB and AP Syslog in 'Step4_detach_ue1' File

Step5:Attach UE with phr_override
    Start capture GNB and AP Syslog in 'Step5_attach' File
    ${save_log}=    Set Variable    ${TEST_LOG_DIRECTORY()}Step5_attach
	Airphone Execute Egate Command    ${phr}
	Airphone Execute Egate Command    ${Set_phr}
	Attach SA ue with capability to 5g cell    1    SA_UE_NR_CAPA_FULL_7220_2200_9363
    Wait '5s' for stable running
	Airphone Sa Start Data Traffic    ue_id=1    direction=ul    throughput=5M    trf_id=1    duration=7200
	Airphone Sa Start Data Traffic    ue_id=1    direction=dl    throughput=5M    trf_id=1    duration=7200
	[Teardown]    Stop capture GNB and AP Syslog in 'Step5_attach' File

Step6:Adjust pusch sinr again
    Start capture GNB and AP Syslog in 'Step6' File
    ${save_log}=    Set Variable    ${TEST_LOG_DIRECTORY()}Step6
    Start GNB BIP Log
	Start GNB Ttitrace With Streaming Mode
	airhone_execute_command_and_wait_for_data    script file\=${CURDIR}/JSON/sinr_pusch.lua
	Wait '15s' for stable running
	${pacp}=    Stop GNB Ttitrace With Streaming Mode    save_path=${save_log}
    Stop Gnb BIP Log    log_dir=${save_log}
	Decoder Tttirace From Pcap To Csv    ${pacp}    ${save_log}/tti
    run keyword and continue on failure
    ...    check_log_with_au2anlysis    ini_path=${CURDIR}/log_check/G_case07_tti_2.ini    log_need_to_check=i
    ...    save_log_directory=${save_log}
	[Teardown]    Stop capture GNB and AP Syslog in 'Step6' File

Capture ttitrace
    [Arguments]    ${time}    ${save_log}     ${file_tag}
    Start GNB Ttitrace With Streaming Mode
    sleep    ${time}
    ${pacp}=    Stop GNB Ttitrace With Streaming Mode    save_path=${save_log}
    Decoder Tttirace From Pcap To Csv    ${pacp}    ${save_log}/${file_tag}
