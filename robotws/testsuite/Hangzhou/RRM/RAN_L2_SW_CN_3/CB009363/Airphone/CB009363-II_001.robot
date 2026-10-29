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
Library      Collections

*** Variables ***
${CONFIG_DIR_PATH}    ${CURDIR}/config
${SCFC_NAME}   SCF_D_1cell_MP_LO.xml
${AIRPHONE_NAME}    iphy_D_1cell_AEQE.xml
${WTS_NAME}    wts_D_1cell.cfg
@{LOG_NAME_LIST}        egatelog    gnb_snapshot
${cellDepType}                             text|SA+NSA|//*[@name\="cellDepType"]
${chBw}                                    text|100MHz|//*[@name\="chBw"]
${dlMimoMode}                              text|4x4 or 4x2 Closed Loop Spatial Multiplexing|//*[@name\="dlMimoMode"]
${actDlSrsBm}                              text|false|//*[@name\="actDlSrsBm"]
${actUlSrsBm}                              text|true|//*[@name\="actUlSrsBm"]
${pucchModeSelect}                         text|longPucch|//*[@name\="pucchModeSelect"]
${numberOfRxBeamforming}                   text|8Rx|//*[@name\="numberOfRxBeamforming"]
${numberOfRxPucch}                         text|8Rx|//*[@name\="numberOfRxPucch"]
${nrCellType}                              text|8DL8UL|//*[@name\="nrCellType"]
${actFdmScheduling}                        text|true|//*[@name\="actFdmScheduling"]
${actBeamforming}                          text|true|//*[@name\="actBeamforming"]
${nrBtsBeamRefinementP2}                   text|false|//*[@name\="nrBtsBeamRefinementP2"]
${actBbPoolTddFr1}                         text|true|//*[@name\="actBbPoolTddFr1"]
${actBbPoolTddFr1Enh}                      text|true|//*[@name\="actBbPoolTddFr1Enh"]
${basicBeamSet}                            text|beamSet_3_1|//*[@name\="basicBeamSet"]
${actHighSpeedCell}                        text|true|//*[@name\="actHighSpeedCell"]
${actShortBsrLimitAdaptation}              text|true|//*[@name\="actShortBsrLimitAdaptation"]
${numberOfTransmittedSsBlocks}             text|4 beams|//*[@name\="numberOfTransmittedSsBlocks"]
${bSRS}                                    text|3|//*[@name\="bSRS"]
${cSRS}                                    text|63|//*[@name\="cSRS"]
${srsUePeriodicity}                        text|slots40|//*[@name\="srsUePeriodicity"]
${ulDMRSAdditionalPosition}                text|Automatic|//*[@name\="ulDMRSAdditionalPosition"]


${PROFILE1}    ue_ta_nr profile_id=1 ue_fo_velocity=VELOCITY_LEAVING_GNB_AT_350KMPH
${SET_PROFILE1}    ue_testmode_set_nr id=1 testmode=ta profile_id=1 action=activate

${PROFILE2}    beam_control_testmode_nr profile_id=1 ueBeamIndexInitial=2,3,0,1 ssbeam_bestbeam=2 ssbeam_rsrp_best=-45 ssbeam_rsrp_avg=-120
${SET_PROFILE2}    ue_testmode_set_nr id=1 testmode=beam_control action=activate profile_id=1 beamaction=attach

${bip_filter}    (uldata_prachreceiveind)||(uldata_prachreceivereq)||(dldata_pdschsendreql1sw)||(dldata_pdcchsendreql1sw)
...    ||(uldata_puschreceiverespharqul1sw) ||(uldata_puschreceiveresplol1sw)||(uldata_puschreceivereq)

@{bip_title}    UlData_detectedPrachPreambles_t.prachPreambleIndex     UlData_prachReceiveReqOccasion_t.ceAxCIndex_item
...    DlData_PdschGrantL1sw.rachStatus    UlData_puschReceiveReqGrant_t.rachStatus     DlData_DciInfoL1sw.rachStatus
...    UlData_eCpriConfigStruct_t.numCeAxCIndex     UlData_eCpriConfigStruct_t.patternId_item

*** Test Cases ***
CB009363-II_001_high_speed_cell_random_access
    Step1:Commission the above configuration on WebUI
	Step2:Configure High Speed for UE and Prepare SSB Beam Attach
	Step3:Attach UE and start buffer

*** Keywords ***
Step1:Commission the above configuration on WebUI
    Start Capture GNB and AP Syslog in 'Step1_before_onair' File
    ${CONFIG_DIR_PATH}    Set Variable    ${CONFIG_DIR_PATH}/${SW_BRANCH}
    change_iphy_rru_version    ${CONFIG_DIR_PATH}${/}${AIRPHONE_NAME}
    modify_swconfig    ${CONFIG_DIR_PATH}${/}${SCFC_NAME}
    ${scfc_path}    Set Variable    ${TEST_LOG_DIRECTORY()}${/}scfc.xml
    copy_file    ${CONFIG_DIR_PATH}/${SCFC_NAME}    ${scfc_path}
    ${modify_list}    create list
	...      ${cellDepType}    ${chBw}    ${dlMimoMode}    ${actDlSrsBm}    ${actUlSrsBm}    ${pucchModeSelect}
	...      ${numberOfRxBeamforming}    ${numberOfRxPucch}    ${nrCellType}    ${actFdmScheduling}    ${actBeamforming}
	...      ${nrBtsBeamRefinementP2}    ${actBbPoolTddFr1}    ${actBbPoolTddFr1Enh}    ${basicBeamSet}   ${actHighSpeedCell}
	...      ${actShortBsrLimitAdaptation}    ${numberOfTransmittedSsBlocks}    ${ulDMRSAdditionalPosition}
	...      ${bSRS}    ${cSRS}    ${srsUePeriodicity}
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
	add_txt_node    0x9D0000:5         #as PM counter period update to 15/15=1min
	add_txt_node    0x580759:1
	add_txt_node    0x600018:1        #RdUlUpFragmentationEnable,Flag for enabling UL UserPlane dynamic fragmentation (CB008941)
	add_txt_node    0x59017D:10       #rdSrsBwFraction,The flag to control available aperiodic SRS bandwidth comparing to PUSCH bandwidth.
	teardown_txt
	setup_txt    src_file=${path_ap}    save_path=${TEST_LOG_DIRECTORY()}${/}swconfig_ap_ini.txt
    #add_txt_node    0x70690:1         #enable 1086 and 8247
    teardown_txt
    GNB Upload Swconfig           ${TEST_LOG_DIRECTORY()}${/}swconfig_gnb_ini.txt
    airphone_upload_swconfig      ${TEST_LOG_DIRECTORY()}${/}swconfig_ap_ini.txt

step2:online modify_configuration
	 Online recommissioning with delta json file    ${CURDIR}/JSON/delta_i7_8792.json

Step2:Configure High Speed for UE and Prepare SSB Beam Attach
    Start Collect GNB and AP Syslog in 'Step2_set' File
	${save_log}=    Set Variable    ${TEST_LOG_DIRECTORY()}Step2_set
    Airphone Execute Egate Command    ${PROFILE1}
    Airphone Execute Egate Command    ${SET_PROFILE1}
    Airphone Execute Egate Command    ${PROFILE2}
    Airphone Execute Egate Command    ${SET_PROFILE2}
    Wait Throughput Timer    15
	[Teardown]    Stop Collect GNB and AP Syslog in 'Step2_set' File

Step3:Attach UE and start buffer
    Start Collect GNB and AP Syslog in 'Step3_attach' File
	${save_log}=    Set Variable    ${TEST_LOG_DIRECTORY()}Step3_attach
	Start GNB BIP Log
	Wait '5s' for stable running
	Attach SA ue with capability to 5g cell    1    CA_P2_8x4_t2r4_n2
	Wait '5s' for stable running
	Stop Gnb BIP Log    log_dir=${save_log}
    SA send multiple trf data    1    DL    175M    2
    SA send multiple trf data    1    UL    175M    1
    Wait Throughput Timer    15
    Capture ttitrace    3s    ${save_log}    step3
    run keyword and continue on failure   Convert BIP To CSV    ${save_log}/tcpdump_L2L1_bip_filtering_off.pcap0
	...    ${save_log}/Attach_bip.csv    ${bip_filter}    ${bip_title}
	check_log_with_au2anlysis    ini_path=${CURDIR}/log_check/II_case01_bip.ini    log_need_to_check=i        save_log_directory=${save_log}
	[Teardown]    Stop Collect GNB and AP Syslog in 'Step3_attach' File

Capture ttitrace
    [Arguments]    ${time}    ${save_log}     ${file_tag}
    Start GNB Ttitrace With Streaming Mode
    sleep    ${time}
    ${pacp}=    Stop GNB Ttitrace With Streaming Mode    save_path=${save_log}
    Decoder Tttirace From Pcap To Csv    ${pacp}    ${save_log}/${file_tag}
