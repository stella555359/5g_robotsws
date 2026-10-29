*** Settings ***
Documentation     Author: jing.pan@nokia-sbell.com
...
...               QC case full name:
...               CB008322_E2_case01_Coexistence_with_cDRX_CLPC_01
...		          When WB SRS is configured, gNB will configure fake DRX and disable CLPC for periodic SRS to UE;
...               When WB SRS is reconfigured to SB SRS, fake DRX will be released and CLPC for periodic SRS will be enabled to UE.

Suite Setup       Common Suite Setup
#Suite Teardown    Common Suite Teardown
Test Setup        Common Test Setup
Test Teardown     Common Test Teardown
Force Tags        CLOUD_5G_I_LO_AP_LO    AP    CRT    SBTS00    RAN_5G_TDD    RAN_5G    owner_mqin
Test Timeout      90 minutes
Resource          ../../resources/sg11/internal_resource/robot/modify_configuration.robot
Resource          ../../resources/sg11/internal_resource/robot/internal_ap_operate.robot
Resource          ../../resources/sg11/internal_resource/robot/internal_gnb_operate.robot
Resource          ../../resources/sg11/internal_resource/robot/internal_capture_log.robot
Library           taf.transport.ssh    WITH NAME    TAF_SSH
Library           ta_a2a

*** Variables ***
${CONFIG_DIR_PATH}    ${CURDIR}/../../resources/sg11/internal_resource/config/
${SCFC_NAME}          gNB_scf_ASIL_ABIO_TDD_eCPRI_cmwv_SANSA_FS_1S_1CC_8D4U.xml
${AIRPHONE_NAME}      AP_iphy_AQQL_ASIL_ABIO_TDD_eCPRI_cmwv_SANSA_FS_1S_1CC_BOAM.xml
${WTS_NAME}           wts_config_ASIL_ABIO_TDD_eCPRI_cmwv_SANSA_FS_1S_1CC.cfg
@{LOG_NAME_LIST}      egatelog\    gnb_snapshot    ap_snapshot
#    sosreport
#8322
${actDlSrsSubbandBm}              text|true|//*[@name\="actDlSrsSubbandBm"]
${bfSubbandSize}                  text|32 PRBs|//*[@name\="bfSubbandSize"]
${srsQualityThreshold}            text|-1200|//*[@name\="srsQualityThreshold"]
${maxNumUeSrs}                    text|4|//*[@name\="maxNumUeSrs"]

#E2
${actCDrx}                        text|true|//*[@name\="actCDrx"]
${actUlClosedLoopPwrCtrl}         text|puschSrs|//*[@name\="actUlClosedLoopPwrCtrl"]

${cellDepType}                    text|SA+NSA|//*[@name\="cellDepType"]
${chBw}                           text|100MHz|//*[@name\="chBw"]
${dlMimoMode}                     text|4x4 or 4x2 Closed Loop Spatial Multiplexing|//*[@name\="dlMimoMode"]
${nrCellType}                     text|8DL4UL|//*[@name\="nrCellType"]
${actUeCsirsCoexistCellCsirs}     text|false|//*[@name\="actUeCsirsCoexistCellCsirs"]
${actCsirsMultiplexing}           text|true|//*[@name\="actCsirsMultiplexing"]
${actDlSrsBm}                     text|true|//*[@name\="actDlSrsBm"]
${actUlSrsBm}                     text|false|//*[@name\="actUlSrsBm"]
${actFdmScheduling}               text|true|//*[@name\="actFdmScheduling"]
${frameStructureType}             text|tdLte|//*[@name\="frameStructureType"]
${guardPeriodLength}              text|6Symbols|//*[@name\="guardPeriodLength"]
${lteToNrFrameShift}              text|3ms|//*[@name\="lteToNrFrameShift"]
${tdLteUlDlConfig}                text|tdLteConfig2|//*[@name\="tdLteUlDlConfig"]
${ulDlDataSlotRatio}              text|1/4|//*[@name\="ulDlDataSlotRatio"]
${prachConfigurationIndex}        text|98|//*[@name\="prachConfigurationIndex"]
${srsUePeriodicity}               text|slots160|//*[@name\="srsUePeriodicity"]
${cSRS}                           text|63|//*[@name\="cSRS"]
${bSRS}                           text|2|//*[@name\="bSRS"]
${srsPowerThresholdForDlBm}       text|-1000|//*[@name\="srsPowerThresholdForDlBm"]
${srsTypeAllocForDlBm}            text|antenna switching or codebook|//*[@name\="srsTypeAllocForDlBm"]
${bfSubbandSize}                  text|32 PRBs|//*[@name\="bfSubbandSize"]
${maxNumUeSrs}                    text|4|//*[@name\="maxNumUeSrs"]
${actCustomBsr}                   text|true|//*[@name\="actCustomBsr"]
${customBeamSetName}              text|BSR_AQQL_6_H6_ALN60_ARP60_P11_COVERAGE_00776_00001|//*[@name\="customBeamSetName"]
${actIncreasedFdmUsersPerSlot}    text|true|//*[@name\="actIncreasedFdmUsersPerSlot"]
${actDlMuMimoEnh}                 text|false|//*[@name\="actDlMuMimoEnh"]
${actDl256Qam}                    text|true|//*[@name\="actDl256Qam"]
${actUl256Qam}                    text|true|//*[@name\="actUl256Qam"]
${dllaDeltaCqiMax}                text|0|//*[@name\="dllaDeltaCqiMax"]
#${miNrMacSduReport}              text|15min|//*[@name\="miNrMacSduReport"]
${bwp_profile8}                   text|MRBTS-1/NRBTS-1/BWP_PROFILE-8|//*[@name\="cellBwpList"]/item[1]/*[@name\="bwpDN"]
${bwp_profile85}                  text|MRBTS-1/NRBTS-1/BWP_PROFILE-85|//*[@name\="cellBwpList"]/item[2]/*[@name\="bwpDN"]
${seThreshold}                        text|80|//*[@name\="seThreshold"]
${seHysteresis}                       text|50|//*[@name\="seHysteresis"]
${rankThreshold}                      text|2|//*[@name\="rankThreshold"]
${channelStabilityThreshold}          text|20|//*[@name\="channelStabilityThreshold"]
${prbSampleHighLowPercentage}         text|100|//*[@name\="prbSampleHighLowPercentage"]
${rlqGoodPercentage}                  text|100|//*[@name\="rlqGoodPercentage"]
${numWbSrsConfigSample}               text|60|//*[@name\="numWbSrsConfigSample"]
${numWbSrsReleaseSample}              text|60|//*[@name\="numWbSrsReleaseSample"]
${srsSinrThreshold}                   text|-400|//*[@name\="srsSinrThreshold"]
${tiltOffset}                     text|0|//*[@name\="tiltOffset"]
${par_of_bsr_name}                BSR_AQQL_6_H6_ALN60_ARP60_P11_COVERAGE_00776_00001
${pattern}                        CA_P2_8x4_t2r4_n2

${PROFILE1}    ul_mimo_srs_beam_pos_nr profile_id=1 mode=fixed init_quad_pos=1 init_sub_quad_pos=1 test_type=SRS
...        multi_path_config=true num_of_nlos_paths=1 azimuth=30 zenith=0 srs_transmit_power_per_port=-150,-150,-150,-150
${PROFILE2}    ul_mimo_srs_beam_pos_nr profile_id=1 mode=fixed init_quad_pos=1 init_sub_quad_pos=1 test_type=SRS
...        multi_path_config=true num_of_nlos_paths=1 azimuth=30 zenith=0 srs_transmit_power_per_port=-350,-350,-350,-350
${SET_PROFILE1}    ue_testmode_set_nr id=11 testmode=ul_mimo_srs_beam_pos action=activate profile_id=1
${FILTER1}    (itf_l2_ps_cell_cellsetupreq)||(ulcell_setupreq)
@{title1}    UlCell_SetupReq_t.pSRSBwvAct    itf_l2_ps_cell_BfSetup.actDlSrsBm    itf_l2_ps_cell_BfSetup.actDlSrsSubbandBm
...    itf_l2_ps_cell_DlSubbandBmConfig.bfSubbandSize
...    itf_l2_ps_cell_DlSubbandBmConfig.maxNumUeSrs
*** Test Cases ***
CB008322_E2_case01_Coexistence_with_cDRX_CLPC_01
    Step1:Commission the above configuration on WebUI
    Step2:UE with t2r4 capability attach to cell-1
    Step3:Send DL full buffer to UE-1
    Step4:Stop Data transfer to UE-1

*** Keywords ***
Step1:Commission the above configuration on WebUI
    Start capture GNB and AP Syslog in 'Step1_before_onair' File
    ${CONFIG_DIR_PATH}    Set Variable    ${CONFIG_DIR_PATH}/${SW_BRANCH}
    #${mod_iphy}    create list     text|2|//NumberOfSubCellsDL
    #modify xml     ${CONFIG_DIR_PATH}${/}${AIRPHONE_NAME}      ${CONFIG_DIR_PATH}${/}${AIRPHONE_NAME}    ${mod_iphy}
    change_iphy_rru_version    ${CONFIG_DIR_PATH}${/}${AIRPHONE_NAME}
    modify_swconfig_by_CB008322    ${CONFIG_DIR_PATH}${/}${SCFC_NAME}
    ${scfc_path}    Set Variable    ${TEST_LOG_DIRECTORY()}${/}scfc.xml
    copy_file    ${CONFIG_DIR_PATH}/${SCFC_NAME}    ${scfc_path}
    add_xml_element     ${scfc_path}    ${scfc_path}     <p name="lteToNrFrameShift">3ms</p>|//*[@name\='tddFrameStructure']/item
    add_xml_element     ${scfc_path}    ${scfc_path}     <p name="tdLteUlDlConfig">tdLteConfig2</p>|//*[@name\='tddFrameStructure']/item
    add_drxprofile_list_in_cells    xml_path=${scfc_path}    profile_id=1
    ...    drxHarqRttTimerDl=0symbols    drxHarqRttTimerUl=0symbols
	...    drxInactivityTimer=4ms    drxLongCycle=40ms    drxOnDurationTimer=10ms    drxRetransTimerDl=0slot    drxRetransTimerUl=0slot
    add_xml_element    ${scfc_path}    ${scfc_path}
    ...    <p name="nrUlClpcProfileDN">MRBTS-1/NRBTS-1/NRULCLPC_PROFILE-0</p>|//*[@distName='MRBTS-1/NRBTS-1/NRCELL-1']
    add_nrulclpc_profile_obj_on_nrbts    ${scfc_path}    0
    ${modify_list}    create list
    ...    ${actDlSrsSubbandBm}             ${bfSubbandSize}           ${srsQualityThreshold}         ${maxNumUeSrs}
    ...    ${actCDrx}                       ${actUlClosedLoopPwrCtrl}
    ...    ${cellDepType}                   ${chBw}                    ${dlMimoMode}                  ${nrCellType}
    ...    ${actUeCsirsCoexistCellCsirs}    ${actCsirsMultiplexing}    ${actDlSrsBm}                  ${actUlSrsBm}
    ...    ${actFdmScheduling}              ${frameStructureType}      ${guardPeriodLength}           ${lteToNrFrameShift}
    ...    ${tdLteUlDlConfig}               ${ulDlDataSlotRatio}       ${prachConfigurationIndex}     ${srsUePeriodicity}
    ...    ${cSRS}                          ${bSRS}                    ${srsPowerThresholdForDlBm}    ${srsTypeAllocForDlBm}
    ...    ${actCustomBsr}                  ${customBeamSetName}       ${actIncreasedFdmUsersPerSlot}
    ...    ${bfSubbandSize}                 ${maxNumUeSrs}
    ...    ${bwp_profile8}                  ${bwp_profile85}
    ...    ${seThreshold}                   ${seHysteresis}                 ${rankThreshold} 
    ...    ${channelStabilityThreshold}     ${prbSampleHighLowPercentage}
    ...    ${rlqGoodPercentage}             ${numWbSrsConfigSample}         ${numWbSrsReleaseSample}
    ...    ${srsSinrThreshold}
    ...    ${tiltOffset}
    modify_xml    ${scfc_path}    ${scfc_path}    ${modify_list}
    Wts Execute Aashell Command     
    ...   confmgmtdefscli set --domain NrUeDlPhy --name radPdcchApplyToSeparateStreams_AP --value 1 --change-type persistent --timeout 5
    Modify TL VM And AP SCTP Configuration
    Get and Update BSR File     ${par_of_bsr_name}
    Add L2PS Deubg Logs
    Perform Full Commission And Reach Onair With Log    ${scfc_path}    ${CONFIG_DIR_PATH}${/}${WTS_NAME}    reset_after_commission=${False}
    [Teardown]    Stop capture GNB and AP Syslog in 'Step1_before_onair' File

Step2:UE with t2r4 capability attach to cell-1
    Start capture GNB and AP Syslog in 'Step2_attach' File
    #Start GNB BIP Log
    Attach SA ue with capability to 5g cell    1    ${pattern}
    Set UEi position    1
    Override UEi to DL RANKj and CQIk    1    2    15
    SA send multiple trf data    1    DL    20M    1
    #Stop Gnb BIP Log    log_dir=${TEST_LOG_DIRECTORY()}${/}Step2_attach${/}
    ${save_log}=    Set Variable    ${TEST_LOG_DIRECTORY()}Step2_attach
    Start GNB Ttitrace With Streaming Mode
    Wait '3s' for stable running
    ${pacp}=    Stop GNB Ttitrace With Streaming Mode    save_path=${save_log}
    Decoder Tttirace From Pcap To Csv    ${pacp}    ${save_log}/tti
    run keyword and continue on failure    spill_value_of_srsswitchmeas    ${save_log}/tti_dl.csv    ${save_log}/target_dl.csv

    airphone_collect_egate_log_files      ${TEST_LOG_DIRECTORY()}${/}Step2_attach${/}   unzip=TRUE
    ${rnti_list}    file match all   ${TEST_LOG_DIRECTORY()}${/}Step2_attach${/}/egate_console.log.001   crnti: (\\d+)
    Set test Variable	 ${rnti_1} 	${rnti_list[0]}

#check log: UE-1/2,SB SRS, fake DRX will be released and CLPC for periodic SRS will be enabled
    [Teardown]    Stop capture GNB and AP Syslog in 'Step2_attach' File

Step3:Send DL full buffer to UE-1
    Start capture GNB and AP Syslog in 'Step3' File
    ${save_log}=    Set Variable    ${TEST_LOG_DIRECTORY()}Step3
    #Start GNB BIP Log
#    Start GNB Ttitrace With Streaming Mode
    SA send multiple trf data    1    DL    150M    3
    Wait '2s' for stable running
#    ${pacp}=    Stop GNB Ttitrace With Streaming Mode    save_path=${save_log}
    #Stop Gnb BIP Log    log_dir=${TEST_LOG_DIRECTORY()}${/}Step3${/}

    Start GNB Ttitrace With Streaming Mode
    Wait '2s' for stable running
    ${pacp}=    Stop GNB Ttitrace With Streaming Mode    save_path=${save_log}
    Decoder Tttirace From Pcap To Csv    ${pacp}    ${save_log}/tti
    run keyword and continue on failure    spill_value_of_srsswitchmeas    ${save_log}/tti_dl.csv    ${save_log}/target_dl.csv

    ${remaining_time}=    get_counter_file_remaining_time    counter_refresh_period=1min
    Wait Throughput Timer    ${remaining_time}
    Wait '660s' for stable running
    ${PM_counter_file}=    download_latest_pmcounter    local_path=${TEST_LOG_DIRECTORY()}Step3${/}
    Set Suite Variable    ${PM_counter_file}
    ${PM_counter_M55308C11001_3}=    get_counter_value_from_counter_file    counter_file=${PM_counter_file}
    ...    counter_id=M55308C11001     cell_id=1

    airphone_collect_egate_log_files      ${save_log}   unzip=TRUE
    run keyword and continue on failure    check_log_with_au2anlysis    ini_path=${CURDIR}/log_check/E2_01_step3_rrc.ini
    ...    log_need_to_check=p    save_log_directory=${save_log}

    run keyword and continue on failure
	...    check_log_with_au2anlysis    ini_path=${CURDIR}/log_check/E2_01_step3_tti.ini    log_need_to_check=i
    ...    save_log_directory=${save_log}
    should be true     ${PM_counter_M55308C11001_3} == 600000
    [Teardown]    Stop capture GNB and AP Syslog in 'Step3' File
	
Step4:Stop Data transfer to UE-1
    Start capture GNB and AP Syslog in 'Step4' File
    ${save_log}=    Set Variable    ${TEST_LOG_DIRECTORY()}Step4

    #Start GNB BIP Log
#    Start GNB Ttitrace With Streaming Mode
    Stop UE DL Traffic    1
    Wait '1s' for stable running
    SA send multiple trf data    1    DL    30M    1
    Wait '1s' for stable running
    #Stop Gnb BIP Log    log_dir=${TEST_LOG_DIRECTORY()}${/}Step4${/}

    Start GNB Ttitrace With Streaming Mode
    Wait '2s' for stable running
    ${pacp}=    Stop GNB Ttitrace With Streaming Mode    save_path=${save_log}
    Decoder Tttirace From Pcap To Csv    ${pacp}    ${save_log}/tti
    run keyword and continue on failure    spill_value_of_srsswitchmeas    ${save_log}/tti_dl.csv    ${save_log}/target_dl.csv

    ${remaining_time}=    get_counter_file_remaining_time    counter_refresh_period=1min
    Wait Throughput Timer    ${remaining_time}
    Wait '660s' for stable running
    ${PM_counter_file}=    download_latest_pmcounter    local_path=${TEST_LOG_DIRECTORY()}Step4${/}
    Set Suite Variable    ${PM_counter_file}
    ${PM_counter_M55308C11001_4}=    get_counter_value_from_counter_file    counter_file=${PM_counter_file}
    ...    counter_id=M55308C11001     cell_id=1

    run keyword and continue on failure
	...    check_log_with_au2anlysis    ini_path=${CURDIR}/log_check/E2_01_step4_tti.ini    log_need_to_check=i
    ...    save_log_directory=${save_log}

    should be true     ${PM_counter_M55308C11001_4} < 600000
    [Teardown]    Stop capture GNB and AP Syslog in 'Step4' File


Stop UE DL Traffic
    [Arguments]    ${ue_id}
    airphone_sa_stop_data_traffic    ${ue_id}    DL

Override UEi to DL RANKj and CQIk
    [Arguments]    ${ue_id}    ${ranki}    ${cqii}
    airphone_execute_egate_command
   	...    csi_override_testmode_nr profile_id\=${ue_id} ri_mode\=fixed ri\=${ranki} cqi_mode\=fixed cqi\=${cqii}
    airphone_execute_egate_command
    ...    ue_testmode_set_nr id\=${ue_id} testmode\=csi_override action\=activate profile_id\=${ue_id}
	
Set UE SRS power
    [Arguments]    ${ue_id}    ${srspower}
    airphone_execute_egate_command
    ...    ul_sinr_testmode_nr profile_id\=${ue_id} sinr_target_srs\=${srspower}
    airphone_execute_egate_command
    ...    ue_testmode_set_nr id\=${ue_id} testmode\=ul_sinr action\=activate profile_id\=${ue_id}

Set UEi position
    [Arguments]    ${ue_id}
    airphone_execute_egate_command    ${PROFILE1}
    airphone_execute_egate_command
    ...    ue_testmode_set_nr id\=${ue_id} testmode\=ul_mimo_srs_beam_pos action\=activate profile_id\=1
    
Add L2PS Deubg Logs	
    ${debuglogs}    create list    level=DBG\n    L2.L2_PS.DEBUG=1\n    L2.L2_PS.DL.SUBBAND_BEAMFORMING=1\n    L2.L2_PS.SRS_BASED_BM=1\n 
    Active L2ps Feature Debug Traces    ${debuglogs}
    TAF_SSH.connect to    192.168.255.1   toor4nsn    oZPS0POrRieRtu   alias=bsh
    TAF_SSH.execute    rm /ffs/run/HashContainer*    connection=bsh

modify_swconfig_by_CB008322
    comment     https://confluence.ext.net.nokia.com/pages/viewpage.action?spaceKey=AirPhoneWTS&title=AirPhone+Alignment+to+gNB+L1L2+Interface
    [Arguments]    ${scfc_file}
    ${local_save_path}=     Download All Common Config Files From Golden Server
    ${path_gnb}=            Find Match GNB swconfig Golden Files    ${scfc_file}    ${local_save_path}
    ${path_ap}=             Find Match AP swconfig Golden Files    ${scfc_file}     ${local_save_path}
    setup_txt    src_file=${path_gnb}    save_path=${TEST_LOG_DIRECTORY()}${/}swconfig_gnb_ini.txt
    #add_txt_node    0x340000:5             #as PM counter period update to 15/15=1min
    add_txt_node    0x58076b:0x64          #rdNumWbSrsCorrExpiry=100(Defalut Value is 60)
    #add_txt_node    0x5901EA:1            #fake DRX
    #add_txt_node    0x580717:0             #rdPdcchApplyToSeparateStreams
    teardown_txt
    setup_txt    src_file=${path_ap}    save_path=${TEST_LOG_DIRECTORY()}${/}swconfig_ap_ini.txt
    teardown_txt
    GNB Upload Swconfig           ${TEST_LOG_DIRECTORY()}${/}swconfig_gnb_ini.txt
    airphone_upload_swconfig      ${TEST_LOG_DIRECTORY()}${/}swconfig_ap_ini.txt
