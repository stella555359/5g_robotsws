*** Settings ***
Documentation     Author: xuemin.ma@nokia-sbell.com
...     UE	CELL	CELL_SRS_NOISE	PORT_POWER	EXPECT_SINR	SINR_LEVEL
...     1	1	-200
...     2	2	---
...     3	3	-300


Suite Setup       Common Suite Setup
#Suite Teardown    Common Suite Teardown
Test Setup        Common Test Setup
Test Teardown     Common Test Teardown
Force Tags        CLOUD_5G_I_MP_AP_LOOO    AP    CRT    SBTS00    RAN_5G_TDD    RAN_5G    owner_xueminm
Test Timeout      120 minutes
Resource          ../../resources/sg11/internal_resource/robot/modify_configuration.robot
Resource          ../../resources/sg11/internal_resource/robot/internal_ap_operate.robot
Resource          ../../resources/sg11/internal_resource/robot/internal_gnb_operate.robot
Resource          ../../resources/sg11/internal_resource/robot/internal_capture_log.robot
Library           taf.transport.ssh    WITH NAME    TAF_SSH
Library           ta_a2a

*** Variables ***
${CONFIG_DIR_PATH}    ${CURDIR}/../../resources/sg11/internal_resource/config/
${SCFC_NAME}           gNB_scf_ASIM_ABIP_TDD_eCPRI_cmwv_SANSA_FS_3S_1CC_8D4U.xml
${AIRPHONE_NAME}       AP_iphy_AQQL_ASIM_ABIP_TDD_eCPRI_cmwv_SANSA_FS_3S_1CC_BOAM.xml
${WTS_NAME}            wts_config_ASIM_ABIP_TDD_eCPRI_cmwv_SANSA_FS_3S_1CC_UEs.cfg
@{LOG_NAME_LIST}      egatelog\    gnb_snapshot
${cellDepType}                    text|SA+NSA|//*[@name\="cellDepType"]
${chBw}                           text|100MHz|//*[@name\="chBw"]
${dlMimoMode}                     text|8x4 Closed Loop Spatial Multiplexing|//*[@name\="dlMimoMode"]
${nrCellType}                     text|8DL4UL|//*[@name\="nrCellType"]
${actUeCsirsCoexistCellCsirs}     text|false|//*[@name\="actUeCsirsCoexistCellCsirs"]
${actCsirsMultiplexing}           text|true|//*[@name\="actCsirsMultiplexing"]
${actDlSrsBm}                     text|true|//*[@name\="actDlSrsBm"]
${actUlSrsBm}                     text|true|//*[@name\="actUlSrsBm"]
${actDlSrsSubbandBm}              text|true|//*[@name\="actDlSrsSubbandBm"]
${actUlClosedLoopPwrCtrl}         text|disabled|//*[@name\="actUlClosedLoopPwrCtrl"]
${actCDrx}                        text|false|//*[@name\="actCDrx"]
${actFdmScheduling}               text|true|//*[@name\="actFdmScheduling"]
${actDlMuMimoEnh}                 text|false|//*[@name\="actDlMuMimoEnh"]
${actDl256Qam}                    text|false|//*[@name\="actDl256Qam"]
${actUl256Qam}                    text|false|//*[@name\="actUl256Qam"]
${actIncreasedFdmUsersPerSlot}    text|true|//*[@name\="actIncreasedFdmUsersPerSlot"]
${frameStructureType}             text|tdLte|//*[@name\="frameStructureType"]
${guardPeriodLength}              text|6Symbols|//*[@name\="guardPeriodLength"]
${lteToNrFrameShift}              text|3ms|//*[@name\="lteToNrFrameShift"]
${tdLteUlDlConfig}                text|tdLteConfig2|//*[@name\="tdLteUlDlConfig"]
${ulDlDataSlotRatio}              text|3/7|//*[@name\="ulDlDataSlotRatio"]
${prachConfigurationIndex}        text|98|//*[@name\="prachConfigurationIndex"]
${srsUePeriodicity}               text|slots20|//*[@name\="srsUePeriodicity"]
${cSRS}                           text|63|//*[@name\="cSRS"]
${bSRS}                           text|2|//*[@name\="bSRS"]
${srsPowerThresholdForDlBm}       text|-1500|//*[@name\="srsPowerThresholdForDlBm"]
${srsPowerThreshold}              text|-1500|//*[@name\="srsPowerThreshold"]
${wbSrsPowerThreshold}            text|-1300|//*[@name\="wbSrsPowerThreshold"]
${srsSinrThreshold}               text|-390|//*[@name\="srsSinrThreshold"]
${numWbSrsConfigSample}           text|100|//*[@name\="numWbSrsConfigSample"]
${numWbSrsReleaseSample}          text|80|//*[@name\="numWbSrsReleaseSample"]
${prbSampleHighLowPercentage}     text|80|//*[@name\="prbSampleHighLowPercentage"]
${prbRatioThreshold}              text|4|//*[@name\="prbRatioThreshold"]
${prbRatioHysteresis}             text|2|//*[@name\="prbRatioHysteresis"]
${srsTypeAllocForDlBm}            text|antenna switching or codebook|//*[@name\="srsTypeAllocForDlBm"]
${bfSubbandSize}                  text|16 PRBs|//*[@name\="bfSubbandSize"]
${maxNumUeSrs}                    text|4|//*[@name\="maxNumUeSrs"]
${seHysteresis}                   text|60|//*[@name\="seHysteresis"]
${actCustomBsr}                   text|true|//*[@name\="actCustomBsr"]
${customBeamSetName}              text|BSR_AQQL_6_H6_ALN60_ARP60_P11_COVERAGE_00776_00001|//*[@name\="customBeamSetName"]
${tiltOffset}                     text|0|//*[@name\="tiltOffset"]
${nrBtsBeamRefinementP2}          text|true|//*[@name\="nrBtsBeamRefinementP2"]
${maxCsirsNumber}                 text|2|//*[@name\="maxCsirsNumber"]
${csirsPower}                     text|3|//*[@name\="csirsPower"]
${actShortBsrLimitAdaptation}                     text|true|//*[@name\="actShortBsrLimitAdaptation"]

${csirsNumberWithinReportPeriod_Set1}                     text|2|//*[@name\="csirsNumberWithinReportPeriod_Set1"]
${bbmodBoardConfigType}           text|Auto|//*[@name\="bbmodBoardConfigType"]
${miNrSrsQuality}                 text|5min|//*[@name\="miNrSrsQuality"]
${miNrBeamforming2}               text|5min|//*[@name\="miNrBeamforming2"]
${msg1FrequencyStart}             text|6|//*[@name\="msg1FrequencyStart"]

${bwp_profile7}                   text|MRBTS-1/NRBTS-1/BWP_PROFILE-7|//*[@name\="cellBwpList"]/item[1]/*[@name\="bwpDN"]
${bwp_profile73}                  text|MRBTS-1/NRBTS-1/BWP_PROFILE-73|//*[@name\="cellBwpList"]/item[2]/*[@name\="bwpDN"]

${par_of_bsr_name}                BSR_AQQL_6_H6_ALN60_ARP60_P11_COVERAGE_00776_00001

${pattern}     CA_P2_8x4_t1r4_n1

${PROFILE11}    ul_mimo_srs_beam_pos_nr profile_id=11 mode=fixed init_quad_pos=1 init_sub_quad_pos=1 test_type=SRS
...        multi_path_config=true num_of_nlos_paths=1 azimuth=15 zenith=0 srs_transmit_power_per_port=-150,-150,-150,-150
${PROFILE12}    ul_mimo_srs_beam_pos_nr profile_id=12 mode=fixed init_quad_pos=1 init_sub_quad_pos=1 test_type=SRS
...        multi_path_config=true num_of_nlos_paths=1 azimuth=15 zenith=0 srs_transmit_power_per_port=-670,-670,-670,-670
${PROFILE13}    ul_mimo_srs_beam_pos_nr profile_id=13 mode=fixed init_quad_pos=1 init_sub_quad_pos=1 test_type=SRS
...        multi_path_config=true num_of_nlos_paths=1 azimuth=15 zenith=0 srs_transmit_power_per_port=-300,-300,-300,-300

${FILTER1}    (itf_l2_ps_cell_cellsetupreq)||(ulcell_setupreq)
@{title1}    itf_l2_ps_cell_BfSetup.actDlSrsSubbandBm    itf_l2_ps_cell_DlSubbandBmConfig.bfSubbandSize
...    itf_l2_ps_cell_DlSubbandBmConfig.srsPowerThreshold
...    itf_l2_ps_cell_DlSubbandBmConfig.srsSinrThreshold       itf_l2_ps_cell_DlSubbandBmConfig.maxNumUeSrs
...    itf_l2_ps_cell_DlSubbandBmConfig.rtBeamStartPid    itf_l2_ps_cell_DlSubbandBmConfig.numOfRtBeamPid
...    itf_l2_ps_cell_DlSubbandBmConfig.dlMaxBeamsPerSlot    itf_l2_ps_cell_DlSubbandBmConfig.dlMaxBeamsPerSymbol

@{value_list_level_cell_1}
@{value_list_level_cell_2}
@{value_list_level_cell_3}

@{value_list_level_sb_cell_1}
@{value_list_level_sb_cell_2}
@{value_list_level_sb_cell_3}

${profile_3}    csi_override_testmode_n2 profile_id=3 cqi_mode=fixed cqi=15 ri_mode=fixed ri=1
${Act_profile_3}    ue_testmode_set_nr id=1 testmode=csi_override profile_id=3 action=activate

*** Test Cases ***
CB008322_G5_case02_UE-related_SINR_for_WB_SRS_Counter
    Step1:Commission the above configuration on WebUI
    Step2:RANK4 UE1~3 with t1r4 capability attach to cell1 or cell2 or cell3
    Step3:UE1-3 send DL data with full buffer
    Step4:Override SINR of UE1-3 to different level
	Step5:Override UE1-3 to RANK1

*** Keywords ***
Step1:Commission the above configuration on WebUI
    Start capture GNB and AP Syslog in 'Step1_before_onair' File
	${CONFIG_DIR_PATH}    Set Variable    ${CONFIG_DIR_PATH}/${SW_BRANCH}
    change_iphy_rru_version    ${CONFIG_DIR_PATH}${/}${AIRPHONE_NAME}
    modify_swconfig_by_CB008322    ${CONFIG_DIR_PATH}${/}${SCFC_NAME}
    ${scfc_path}    Set Variable    ${TEST_LOG_DIRECTORY()}${/}scfc.xml
    copy_file    ${CONFIG_DIR_PATH}/${SCFC_NAME}    ${scfc_path}
	add_xml_element     ${scfc_path}    ${scfc_path}     <p name="lteToNrFrameShift">3ms</p>|//*[@name\='tddFrameStructure']/item
    add_xml_element     ${scfc_path}    ${scfc_path}     <p name="tdLteUlDlConfig">tdLteConfig2</p>|//*[@name\='tddFrameStructure']/item
    add_periodicCsiAcquisition_list_in_cells    ${scfc_path}
    ${modify_list}    create list
    ...    ${cellDepType}                       ${actCDrx}                             ${srsUePeriodicity}
    ...    ${chBw}                              ${actFdmScheduling}                    ${cSRS}
    ...    ${dlMimoMode}                        ${actDlMuMimoEnh}                      ${bSRS}
    ...    ${nrCellType}                        ${actDl256Qam}                         ${srsPowerThresholdForDlBm}
    ...    ${actUeCsirsCoexistCellCsirs}        ${actUl256Qam}                         ${srsPowerThreshold}
    ...    ${actCsirsMultiplexing}              ${actIncreasedFdmUsersPerSlot}         ${wbSrsPowerThreshold}
    ...    ${actDlSrsBm}                        ${frameStructureType}                  ${srsTypeAllocForDlBm}
    ...    ${actUlSrsBm}                        ${guardPeriodLength}                   ${bfSubbandSize}
    ...    ${actDlSrsSubbandBm}                 ${lteToNrFrameShift}                   ${maxNumUeSrs}
    ...    ${actUlClosedLoopPwrCtrl}            ${tdLteUlDlConfig}                     ${seHysteresis}
    ...    ${ulDlDataSlotRatio}                 ${customBeamSetName}                   ${actCustomBsr}
    ...    ${prachConfigurationIndex}           ${tiltOffset}                          ${csirsPower}
    ...    ${nrBtsBeamRefinementP2}             ${maxCsirsNumber}                      ${miNrSrsQuality}
    ...    ${csirsNumberWithinReportPeriod_Set1}     ${bwp_profile7}    ${bwp_profile73}
	...    ${srsSinrThreshold}                  ${miNrBeamforming2}     ${bbmodBoardConfigType}
	...    ${msg1FrequencyStart}	${numWbSrsConfigSample}    ${numWbSrsReleaseSample}
	...    ${actShortBsrLimitAdaptation}
    ...    ${prbSampleHighLowPercentage}        ${prbRatioThreshold}                   ${prbRatioHysteresis}
    modify_xml    ${scfc_path}    ${scfc_path}    ${modify_list}
    Modify TL VM And AP SCTP Configuration
    Get and Update BSR File    ${par_of_bsr_name}
	Add L2PS Deubg Logs
    Perform Full Commission And Reach Onair With Log    ${scfc_path}    ${CONFIG_DIR_PATH}${/}${WTS_NAME}    reset_after_commission=${False}
	[Teardown]    Stop capture GNB and AP Syslog in 'Step1_before_onair' File

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
	add_txt_node    0x340000:1        #as PM counter period update to 5/1=5min
	add_txt_node    0x580477:1       #The UL CoMa log enabling flag(rdUlSrsCoMaLogEnabled)
    add_txt_node    0x580264:1          #The DL CoMa log enabling flag(rdDlSrsLogControl, bit0)
    add_txt_node    0x600018:0        #rdUlUpFragmentationEnable
    teardown_txt
	setup_txt    src_file=${path_ap}    save_path=${TEST_LOG_DIRECTORY()}${/}swconfig_ap_ini.txt
    teardown_txt
    GNB Upload Swconfig           ${TEST_LOG_DIRECTORY()}${/}swconfig_gnb_ini.txt
    airphone_upload_swconfig      ${TEST_LOG_DIRECTORY()}${/}swconfig_ap_ini.txt

Step2:RANK4 UE1~3 with t1r4 capability attach to cell1 or cell2 or cell3
    Start Collect GNB and AP Syslog in 'Step2_attach' File
    ${save_log}=    Set Variable    ${TEST_LOG_DIRECTORY()}Step2_attach
    Start GNB BIP Log
    Set cell'1' noise_srs as '-200'
    Attach SA ue with capability to 5g cell    1    CA_P2_8x4_t1r4_n1
	Set UE'1' to UE'1' power with profile'11'
    Wait '3s' for stable running

    Airphone Execute Egate Command    ue_change_location id\=2 enb\=2 cell\=2
	${ue_cap}    Obtain Ue Capability    ${pattern}
    airphone_sa_attach    ue_id=2    ue_capability=${ue_cap}
    airphone_set_traffic_type    ue_id=2    pdu_id=1
    airphone_pdu_session_setup    ue_id=2    pdu_id=1    gw_id=2
	Wait '3s' for stable running

	Airphone Execute Egate Command    ue_change_location id\=3 enb\=2 cell\=3
	Set cell'3' noise_srs as '-300'
	${ue_cap}    Obtain Ue Capability    ${pattern}
    airphone_sa_attach    ue_id=3    ue_capability=${ue_cap}
    airphone_set_traffic_type    ue_id=3    pdu_id=1
    airphone_pdu_session_setup    ue_id=3    pdu_id=1    gw_id=3
	Wait '3s' for stable running
	Set UE'3' to UE'3' power with profile'13'

    [Teardown]    Stop Collect GNB and AP Syslog in 'Step2_attach' File

Set cell'${cell_id}' noise_srs as '${srs_noise_value}'
	Airphone Execute Egate Command    ul_cell_noise_testmode_nr profile_id\=${cell_id} noise_srs\=${srs_noise_value}
	Airphone Execute Egate Command    cell_testmode_set_nr cell_id\=${cell_id} gnb\=2 testmode\=ul_cell_noise profile_id\=${cell_id} action\=activate
	Wait '2s' for stable running

Step3:UE1-3 send DL data with full buffer
    Start Collect GNB and AP Syslog in 'Step3_data' File
    ${save_log}=    Set Variable    ${TEST_LOG_DIRECTORY()}Step3_data
    #Start GNB BIP Log
    FOR    ${u_id}    IN RANGE    1    4
        Airphone SA Start Data Traffic    ue_id=${u_id}    direction=dl    throughput=175M    trf_id=1    duration=7200
        Airphone SA Start Data Traffic    ue_id=${u_id}    direction=dl    throughput=175M    trf_id=2    duration=7200
	    Airphone SA Start Data Traffic    ue_id=${u_id}    direction=dl    throughput=175M    trf_id=3    duration=7200
	    Airphone SA Start Data Traffic    ue_id=${u_id}    direction=dl    throughput=175M    trf_id=4    duration=7200
	    Airphone SA Start Data Traffic    ue_id=${u_id}    direction=dl    throughput=175M    trf_id=5    duration=7200
	    Airphone SA Start Data Traffic    ue_id=${u_id}    direction=dl    throughput=175M    trf_id=6    duration=7200
        Airphone Sa Start Data Traffic    ue_id=${u_id}    direction=ul    throughput=175M    trf_id=1    duration=7200
    END
    Wait '10s' for stable running
    FOR    ${u_id}    IN RANGE    1    4
        ${Dl_throughput} =    Airphone Sa Get Throughput    ue_id=${u_id}    direction=dl
        ${Ul_throughput} =    Airphone Sa Get Throughput    ue_id=${u_id}    direction=ul
    END
    Capture ttitrace    ${save_log}
    #Stop Gnb BIP Log    log_dir=${save_log}
#    run keyword and continue on failure
#    ...    check_log_with_au2anlysis    ini_path=${CURDIR}/log_check/G5_case02_tti.ini    log_need_to_check=i
#    ...    save_log_directory=${save_log}
    [Teardown]    Stop Collect GNB and AP Syslog in 'Step3_data' File

Step4:Override SINR of UE1-3 to different level
	Start Collect GNB and AP Syslog in 'Step4' File
    ${save_log}=    Set Variable    ${TEST_LOG_DIRECTORY()}Step4
#    Set UE'1' to UE'1' power with profile'11'
#	 Set UE'3' to UE'3' power with profile'13'
	${remaining_time}=    get_counter_file_remaining_time    counter_refresh_period=5min
    Wait Throughput Timer    ${remaining_time}
    Wait Throughput Timer    600s
    ${PM_counter_file}=    download_latest_pmcounter    local_path=${TEST_LOG_DIRECTORY()}Step4${/}
	FOR    ${i}    IN RANGE     178     203
	    ${index}     evaluate     "${i}".zfill(2)
	    ${value}     get_counter_value_from_counter_file    counter_file=${PM_counter_file}     counter_id=M55371C00${index}    cell_id=1
	     append to list     ${value_list_level_cell_1}   ${value}
	    ${value}     get_counter_value_from_counter_file    counter_file=${PM_counter_file}     counter_id=M55371C00${index}    cell_id=2
	     append to list     ${value_list_level_cell_2}   ${value}
	    ${value}     get_counter_value_from_counter_file    counter_file=${PM_counter_file}     counter_id=M55371C00${index}    cell_id=3
	     append to list     ${value_list_level_cell_3}   ${value}
    END
    log     ${value_list_level_cell_1}
	log     ${value_list_level_cell_2}
	log     ${value_list_level_cell_3}
    Capture ttitrace    ${save_log}
	${SINR_LEVEL_value_cell_1}    Evaluate    sum(${value_list_level_cell_1})
	${SINR_LEVEL_value_cell_2}    Evaluate    sum(${value_list_level_cell_2})
	${SINR_LEVEL_value_cell_3}    Evaluate    sum(${value_list_level_cell_3})
    should be true    ${SINR_LEVEL_value_cell_1} > 7000
    should be true    ${SINR_LEVEL_value_cell_2} > 7000
    should be true    ${SINR_LEVEL_value_cell_3} > 7000
    [Teardown]    Stop Collect GNB and AP Syslog in 'Step4' File

Set UE'${ue_id}' to UE'${ue_id_end}' power with profile'${p_id}'
    FOR    ${u_id}    IN RANGE    ${ue_id}    ${ue_id_end}+1
        Run Keyword If  ${p_id}==11   Airphone Execute Egate Command    ${PROFILE11}
        Run Keyword If  ${p_id}==12   Airphone Execute Egate Command    ${PROFILE12}
        Run Keyword If  ${p_id}==13   Airphone Execute Egate Command    ${PROFILE13}
        Airphone Execute Egate Command    ue_testmode_set_nr id\=${u_id} testmode\=ul_mimo_srs_beam_pos action\=activate profile_id\=${p_id}
        Wait '2s' for stable running
    END

Capture ttitrace
    [Arguments]    ${save_log}
    Start GNB Ttitrace With Streaming Mode
    Wait '2s' for stable running
    ${pacp}=    Stop GNB Ttitrace With Streaming Mode    save_path=${save_log}
    Decoder Tttirace From Pcap To Csv    ${pacp}    ${save_log}/tti
    run keyword and continue on failure    spill_value_of_srsswitchmeas    ${save_log}/tti_dl.csv    ${save_log}/target_dl.csv

Step5:Override UE1-3 to RANK1
    Start Collect GNB and AP Syslog in 'Step5_rank1' File
    ${save_log}=    Set Variable    ${TEST_LOG_DIRECTORY()}Step5_rank1
	FOR    ${u_id}    IN RANGE    1    4
        airphone_execute_egate_command    csi_override_testmode_nr profile_id\=8 cqi_mode\=fixed cqi\=15 ri_mode\=fixed ri\=0
        airphone_execute_egate_command    ue_testmode_set_nr id\=${u_id} testmode\=csi_override profile_id\=8 action\=activate
    END
    Wait '2s' for stable running
    Capture ttitrace    ${save_log}
	${remaining_time}=    get_counter_file_remaining_time    counter_refresh_period=5min
    Wait Throughput Timer    ${remaining_time}
    Wait Throughput Timer    600s
    ${PM_counter_file}=    download_latest_pmcounter    local_path=${TEST_LOG_DIRECTORY()}Step5_rank1${/}
	FOR    ${i}    IN RANGE     178     203
	    ${index}     evaluate     "${i}".zfill(2)
	    ${value}     get_counter_value_from_counter_file    counter_file=${PM_counter_file}     counter_id=M55371C00${index}    cell_id=1
	     append to list     ${value_list_level_sb_cell_1}   ${value}
	    ${value}     get_counter_value_from_counter_file    counter_file=${PM_counter_file}     counter_id=M55371C00${index}    cell_id=2
	     append to list     ${value_list_level_sb_cell_2}   ${value}
	    ${value}     get_counter_value_from_counter_file    counter_file=${PM_counter_file}     counter_id=M55371C00${index}    cell_id=3
	     append to list     ${value_list_level_sb_cell_3}   ${value}
    END
    log    ${value_list_level_sb_cell_1}
	log    ${value_list_level_sb_cell_2}
	log    ${value_list_level_sb_cell_3}
    [Teardown]    Stop Collect GNB and AP Syslog in 'Step5_rank1' File
