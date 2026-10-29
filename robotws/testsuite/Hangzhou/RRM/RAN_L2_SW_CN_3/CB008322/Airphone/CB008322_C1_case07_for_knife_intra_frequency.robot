*** Settings ***
Documentation     Author: shuihe
...
...               example case for RAN HZ L2 SW11. test step description in QC as below:
...
...               QC case full name:
...               CB008322_C1_case07_Coexist_with_UL_SRS_BF_cell_interFrequncy_handover
...

Test Timeout      60 minutes
Suite Setup       Common Suite Setup
Suite Teardown    Common Suite Teardown
Test Setup        Common Test Setup
#Test Teardown     Common Test Teardown
Force Tags        CLOUD_5G_I_LO_AP_LO_SANSA_FS_ECPRI_CMWV_TDD    5G_RAN_TDD    RAN_5G    CIT    SBTS00    SBTS23R1    Owner_shuihe
Resource          ../../resources/sg11/internal_resource/robot/modify_configuration.robot
Resource          ../../resources/sg11/internal_resource/robot/internal_ap_operate.robot
Resource          ../../resources/sg11/internal_resource/robot/internal_gnb_operate.robot
Resource          ../../resources/sg11/internal_resource/robot/internal_capture_log.robot
Library     taf.transport.ssh    WITH NAME    TAF_SSH
Library           ta_a2a																		 

*** Variables ***
${CONFIG_DIR_PATH}    ${CURDIR}/../../resources/sg11/internal_resource/config/
${UE_ID}          1
${PDU_ID}         1
${GW_ID}          1
${SLICE_ID}       1
#${SCFC_NAME}      SCF/SCFC_8322_C1_case07_ASIL_ABIO_TDD_eCPRI_cmwv_SANSA_4S_1CC.xml
${SCFC_NAME}      SCF/scfc_intra_frequency.xml
${AIRPHONE_NAME}    WTS/AP_iphy_AQQL_C1_case07.xml
#${WTS_NAME}       wts_config_ASIB_ABIO_TDD_eCPRI_cmwv_SANSA_L1b_4S_1CC.cfg
${WTS_NAME}       WTS/wts_config_ASIB_ABIO_intra_frequency.cfg
@{LOG_NAME_LIST}    gnb_snapshot    sosreport    tshark    egatelog

${dlMimoMode}                              text|4x4 or 4x2 Closed Loop Spatial Multiplexing|//*[@name\="dlMimoMode"]
${nrCellType}                              text|4DL4UL|//*[@name\="nrCellType"]
${actCsirsMultiplexing}                    text|true|//*[@name\="actCsirsMultiplexing"]
${actDlSrsBm}                              text|true|//*[@name\="actDlSrsBm"]
${actUlSrsBm}                              text|true|//*[@name\="actUlSrsBm"]
#${actDlSrsSubbandBm}                       text|true|//*[@name\="actDlSrsSubbandBm"]
${actUlClosedLoopPwrCtrl}                  text|disabled|//*[@name\="actUlClosedLoopPwrCtrl"]
${actCDrx}                                 text|false|//*[@name\="actCDrx"]
${srsUePeriodicity}                        text|slots160|//*[@name\="srsUePeriodicity"]
${cSRS}                                    text|49|//*[@name\="cSRS"]
${bSRS}                                    text|2|//*[@name\="bSRS"]
${srsPowerThresholdForDlBm}                text|-1270|//*[@name\="srsPowerThresholdForDlBm"]
${srsTypeAllocForDlBm}                     text|codebook|//*[@name\="srsTypeAllocForDlBm"]
${bfSubbandSize}                           text|8 PRBs|//*[@name\="bfSubbandSize"]
${maxNumUeSrs}                             text|4|//*[@name\="maxNumUeSrs"]
${srsQualityThreshold}                     text|-1200|//*[@name\="srsQualityThreshold"]
${prbRatioThreshold}                         text|16|//*[@name\="prbRatioThreshold"]
${srsUePeriodicityInput}                    text|slots20|//*[@name\="srsUePeriodicityInput"]
${srsUePeriodicityOutput}                   text|slots20|//*[@name\="srsUePeriodicityOutput"]
${numWbSrsConfigSample}                     text|30|//*[@name\="numWbSrsConfigSample"]
${prbSampleHighLowPercentage}               text|100|//*[@name\="prbSampleHighLowPercentage"]
${wbSrsPowerThreshold}                      text|-1200|//*[@name\="wbSrsPowerThreshold"]
${srsPowerThreshold}                        text|-1340|//*[@name\="srsPowerThreshold"]
${actCustomBsr}                             text|true|//*[@name\="actCustomBsr"]
${customBeamSetName}                        text|BSR_AQQL_6_H6_ALN60_ARP60_P11_COVERAGE_00776_00001|//*[@name\="customBeamSetName"]
#${ActFullRRCConfigurationSaHo}                             text|enabled|//*[@name\="ActFullRRCConfigurationSaHo"]

${cmd_1_00}    ul_mimo_srs_beam_pos_nr profile_id=1 mode=fixed init_quad_pos=1 init_sub_quad_pos=0 test_type=SRS multi_path_config=true
${cmd_002_001}    num_of_nlos_paths=1 azimuth=14 zenith=-2 srs_transmit_power_per_port=-100,-100,-100,-100
${cmd_002_002}    num_of_nlos_paths=1 azimuth=15 zenith=0 srs_transmit_power_per_port=-350,-500,-350,-500
${cmd_002_003}    num_of_nlos_paths=1 azimuth=15 zenith=0 srs_transmit_power_per_port=-700,-700,-700,-700
${cmd_003}    subband_config_subband_prb_size=16
${cmd_004}    subband_config_stepsize_azimuth=2 subband_config_stepsize_zenith=2 subband_config_start_prb=1 subband_config_num_of_prb=216
${cmd_2_00}    ul_mimo_srs_beam_pos_nr profile_id=2 mode=fixed init_quad_pos=0 init_sub_quad_pos=0 test_type=SRS multi_path_config=true
${cmd_1_20}    ul_mimo_srs_beam_pos_nr profile_id=1 mode=fixed init_quad_pos=2 init_sub_quad_pos=0 test_type=SRS multi_path_config=true
${cmd_2_20}    ul_mimo_srs_beam_pos_nr profile_id=2 mode=fixed init_quad_pos=2 init_sub_quad_pos=0 test_type=SRS multi_path_config=true

*** Test Cases ***
CB008322_C1_case07_Coexist_with_UL_SRS_BF_cell_interFrequncy_handover
    Step 1: Set parameter and wait for onair
    Step 2: Attach CA UE to cell2
    #Step 3: Initiate big DL data transfer for UE
	Step 4_for_knife: Perform UE handover to gnb2 cell1
	#Step 5: Perform UE handover to gnb2 cell2

*** Keywords ***
Step 1: Set parameter and wait for onair
    Start Capture GNB and AP Syslog in 'step1_before_onair' File
    ${CONFIG_DIR_PATH}    Set Variable    ${CONFIG_DIR_PATH}/${SW_BRANCH}
	change_iphy_rru_version        ${CURDIR}/config/${SW_BRANCH}${/}${AIRPHONE_NAME}
	modify_swconfig_by_CB007922    ${CURDIR}/config/${SW_BRANCH}${/}${SCFC_NAME}
	modify_swconfig_by_CB008322    ${CURDIR}/config/${SW_BRANCH}${/}${SCFC_NAME}
	${scfc_path}                Set Variable                          ${TEST_LOG_DIRECTORY()}${/}scfc.xml
	copy_file          ${CURDIR}/config/${SW_BRANCH}${/}${SCFC_NAME}     ${scfc_path}
	${modify_list}      create list
    ...       ${dlMimoMode}    ${nrCellType}    ${actCsirsMultiplexing}
    ...       ${actDlSrsBm}    ${actUlSrsBm}    ${actUlClosedLoopPwrCtrl}
    ...       ${actCDrx}    ${srsUePeriodicity}    ${cSRS}    ${bSRS}
    ...       ${srsPowerThresholdForDlBm}    ${srsTypeAllocForDlBm}    ${bfSubbandSize}    ${maxNumUeSrs}
    ...       ${srsQualityThreshold}
	...      ${prbRatioThreshold}    ${srsUePeriodicityInput}    ${srsUePeriodicityOutput}    ${numWbSrsConfigSample}
	...      ${prbSampleHighLowPercentage}    ${wbSrsPowerThreshold}    ${srsPowerThreshold}   ${actCustomBsr}    ${customBeamSetName}
	#...      ${ActFullRRCConfigurationSaHo}
    modify_xml  	    ${scfc_path}        ${scfc_path}         ${modify_list}
    Modify TL VM And AP SCTP Configuration
	Get and Update BSR File    par_of_bsr_name=BSR_AQQL_6_H6_ALN60_ARP60_P11_COVERAGE_00776_00001
	Add L2PS Deubg Logs
	#Perform Full Commission And Reach Onair
	Perform Full Commission And Reach Onair With Log
	...    ${scfc_path}
	...    ${CURDIR}/config/${SW_BRANCH}${/}${WTS_NAME}
	...    reset_after_commission=${False}
    [Teardown]    run keyword and continue on failure    Stop Capture GNB and AP Syslog in 'step1_before_onair' File

modify_swconfig_by_CB008322
    comment     https://confluence.ext.net.nokia.com/pages/viewpage.action?spaceKey=AirPhoneWTS&title=AirPhone+Alignment+to+gNB+L1L2+Interface
    [Arguments]    ${scfc_file}
	${local_save_path}=     Download All Common Config Files From Golden Server
	${path_gnb}=            Find Match GNB swconfig Golden Files    ${scfc_file}    ${local_save_path}
	${path_ap}=             Find Match AP swconfig Golden Files    ${scfc_file}     ${local_save_path}
    setup_txt    src_file=${path_gnb}    save_path=${TEST_LOG_DIRECTORY()}${/}swconfig_gnb_ini.txt
	add_txt_node    0x340000:5         #as PM counter period update to 15/15=1min
	#add_txt_node    0x5805ae:1       #Flag to enable or disable dynamic Wb/Sb Srs Switch
	add_txt_node    0x590103:2       #whether codebook SRS is reused for TAS SRS
	#add_txt_node    0x58076c:0x10       #the percentage of scheduled PRB
	#add_txt_node    0x5901E6:20         #wideband periodic
	#add_txt_node    0x5805B5:30         #rdNumSrsCheck
	#add_txt_node    0x5805B0:100         #rdSrsBufPercent
	#add_txt_node    0x5901E8:1     #CPRT rdActCB009496
    add_txt_node    0x600013:1     # BOAM_RAT_ADAPT
    add_txt_node    0x19040F:1     # BOAM_FRONTHAUL
    #add_txt_node    0x42008E:1     # BOAM DCS
    #add_txt_node    0x88004B:0             # L1FH rdEnableSktMvp, 0 for 9496; 1 for SKTMVP
    #add_txt_node    0x880x31:14 	  #L1FH rdBwvTxOpportunities, 14 for 9496;  3 for SKTMVP
    #add_txt_node    0x580556:65535   #L2PS rdStartPatternId, 65535 for 9496
	add_txt_node    0x580789:0x1       #rdEnableNiddFor8322
	#add_txt_node    0x580776:0x1       #This flag is used to control DL MU-MIMO interworking with subband BWVs
	add_txt_node    0x5808FF:0x0       #This flag is used to control DL MU-MIMO interworking with subband BWVs
	add_txt_node    0x5808FE:20       #This flag is used to control DL MU-MIMO interworking with subband BWVs
    teardown_txt
	setup_txt    src_file=${path_ap}    save_path=${TEST_LOG_DIRECTORY()}${/}swconfig_ap_ini.txt
    teardown_txt
    GNB Upload Swconfig           ${TEST_LOG_DIRECTORY()}${/}swconfig_gnb_ini.txt
    airphone_upload_swconfig      ${TEST_LOG_DIRECTORY()}${/}swconfig_ap_ini.txt

Step 2: Attach CA UE to cell2
    Start Capture GNB and AP Syslog in 'step2_ue_attach' File
    Start GNB Ttitrace With Streaming Mode
    Airphone Location Change    id=${UE_ID}    cell_id=2
    airphone_set_traffic_type    ${UE_ID}    ${PDU_ID}    internal
    Airphone SA Attach    ue_id=${UE_ID}
    Airphone Pdu Session Setup    ${UE_ID}    ${PDU_ID}    ${SLICE_ID}    ${GW_ID}
    #Airphone Measurement Send Nr    id=1    meas_id=3    event=A1    srsrp_nr=80
	#...    pass_regexp=sCellToAddModList
	Wait Throughput Timer    10
	Airphone Execute Egate Command    ${cmd_1_00} ${cmd_002_001}
	Airphone Execute Egate Command    ue_testmode_set_nr id\=1 testmode\=ul_mimo_srs_beam_pos action\=activate profile_id\=1 scell\=0
    ${pacp}=    Stop GNB Ttitrace With Streaming Mode    save_path=${TEST_LOG_DIRECTORY()}step2_ue_attach
	airphone_collect_egate_log_files      ${TEST_LOG_DIRECTORY()}step2_ue_attach   unzip=TRUE
	${rnti_list}    file match all   ${TEST_LOG_DIRECTORY()}${/}step2_ue_attach${/}/egate_console.log.001   crnti: (\\d+)
	Set test Variable	 ${rnti_1} 	${rnti_list[0]}
    [Teardown]    run keyword and continue on failure    Stop Capture GNB and AP Syslog in 'step2_ue_attach' File

Step 3: Initiate big DL data transfer for UE
    Start Capture GNB and AP Syslog in 'step3_send_data' File
    Start GNB Ttitrace With Streaming Mode
    Airphone SA Start Data Traffic    ${UE_ID}    DL    175M    trf_id=1    pdu_id=${PDU_ID}    duration=${3600}
    Airphone SA Start Data Traffic    ${UE_ID}    DL    175M    trf_id=2    pdu_id=${PDU_ID}    duration=${3600}
	Airphone SA Start Data Traffic    ${UE_ID}    DL    175M    trf_id=3    pdu_id=${PDU_ID}    duration=${3600}
	Airphone SA Start Data Traffic    ${UE_ID}    DL    175M    trf_id=4    pdu_id=${PDU_ID}    duration=${3600}
	Airphone SA Start Data Traffic    ${UE_ID}    DL    175M    trf_id=5    pdu_id=${PDU_ID}    duration=${3600}
	Airphone SA Start Data Traffic    ${UE_ID}    UL    175M     trf_id=1    pdu_id=${PDU_ID}    duration=${3600}
    Wait Throughput Timer    2
	${pacp}=    Stop GNB Ttitrace With Streaming Mode    save_path=${TEST_LOG_DIRECTORY()}step3_send_data
	${save_log}=    Set Variable    ${TEST_LOG_DIRECTORY()}step3_send_data
	Decoder Tttirace From Pcap To Csv    ${pacp}    ${save_log}/tti
	Start GNB BIP Log
	Wait Throughput Timer    1
    Stop Gnb BIP Log    log_dir=${save_log}
	run keyword and continue on failure    spill_value_of_srsswitchmeas    ${save_log}/tti_dl.csv    ${save_log}/target_dl.csv
	run keyword and continue on failure    check_log_with_au2anlysis
    ...    ini_path=${CURDIR}/log_check/C1_case07_tti_dl_step3.ini    log_need_to_check=i    save_log_directory=${save_log}
	run keyword and continue on failure    check_log_with_au2anlysis
    ...    ini_path=${CURDIR}/log_check/C1_case07_tti_ul_step3.ini    log_need_to_check=i    save_log_directory=${save_log}
    #${Pcell_dl_throughput} =    Airphone Get Throughput On Specific Scell    ue_id=${UE_ID}    scell_id=0    type=pdsch    tput_type=ave
    #${Scell_dl_throughput} =    Airphone Get Throughput On Specific Scell    ue_id=${UE_ID}    scell_id=1    type=pdsch    tput_type=ave
	airphone_collect_egate_log_files      ${TEST_LOG_DIRECTORY()}step3_send_data   unzip=TRUE
    [Teardown]    run keyword and continue on failure    Stop Capture GNB and AP Syslog in 'step3_send_data' File

Step 4: Perform UE handover to gnb2 cell1
	Start Capture GNB and AP Syslog in 'step4_HO_to_gnb2_1' File
	${save_log}=    Set Variable    ${TEST_LOG_DIRECTORY()}step4_HO_to_gnb2_1
    Inquery UE'1' NR Measurement Identities
	${cmd}=    Set Variable    ue_measurement_send_nr id=1 meas_id=1 event=A2 srsrp_nr=45
    airphone_execute_egate_command    ${cmd}
	Inquery UE'1' NR Measurement Identities
	${cmd}=    Set Variable    ue_measurement_send_nr id=1 meas_id=1 event=A3 srsrp_nr=30 phycell_id=50 nrsrp_nr=80
	Start GNB Ttitrace With Streaming Mode
	airphone_execute_egate_command    ${cmd}    pass_regexp=Intra-eNB handover from EXT_ENB-2.2 to EXT_ENB-2.1 performed
	wait Throughput Timer    5
	${pacp}=    Stop GNB Ttitrace With Streaming Mode    save_path=${TEST_LOG_DIRECTORY()}step4_HO_to_gnb2_1
	Decoder Tttirace From Pcap To Csv    ${pacp}    ${save_log}/tti
	#Start GNB BIP Log
	#Wait Throughput Timer    1
    #Stop Gnb BIP Log    log_dir=${save_log}
	run keyword and continue on failure    delete_ho_interim    ${save_log}/tti_ul.csv    ${save_log}/tti_without_ho_interim_ul.csv
	run keyword and continue on failure    spill_value_of_srsswitchmeas    ${save_log}/tti_dl.csv    ${save_log}/target_dl.csv
	run keyword and continue on failure    check_log_with_au2anlysis
    ...    ini_path=${CURDIR}/log_check/C1_case07_tti_dl_step4.ini    log_need_to_check=i    save_log_directory=${save_log}
	run keyword and continue on failure    check_log_with_au2anlysis
    ...    ini_path=${CURDIR}/log_check/C1_case07_tti_ul_step4.ini    log_need_to_check=i    save_log_directory=${save_log}
	Run Keyword And Ignore Error    Airphone Get Throughput On Specific Scell    ue_id=${UE_ID}    scell_id=0    type=pdsch    tput_type=ave
	airphone_collect_egate_log_files      ${TEST_LOG_DIRECTORY()}step4_HO_to_gnb2_1   unzip=TRUE
    [Teardown]    run keyword and continue on failure    Stop Capture GNB and AP Syslog in 'step4_HO_to_gnb2_1' File

Inquery UE'${u_id}' NR Measurement Identities
    Wait Throughput Timer    3
    airphone_execute_egate_command    ue_meas_cfg_disp id\=${u_id}
    ...      pass_regexp=NR MEASUREMENT IDENTITIES
    Wait Throughput Timer    3

Step 5: Perform UE handover to gnb2 cell2
    Start Capture GNB and AP Syslog in 'step5_HO_back_to_gnb2_2' File
	${save_log}=    Set Variable    ${TEST_LOG_DIRECTORY()}step5_HO_back_to_gnb2_2
    Inquery UE'1' NR Measurement Identities
    ${cmd}=    Set Variable    ue_measurement_send_nr id=1 meas_id=5 event=A2 srsrp_nr=40
    airphone_execute_egate_command    ${cmd}
	Inquery UE'1' NR Measurement Identities
	${cmd}=    Set Variable    ue_measurement_send_nr id=1 meas_id=8 event=A3 srsrp_nr=30 phycell_id=51 nrsrp_nr=80
	Start GNB Ttitrace With Streaming Mode	
	airphone_execute_egate_command    ${cmd}    pass_regexp=Intra-eNB handover from EXT_ENB-2.1 to EXT_ENB-2.2 performed
	wait Throughput Timer    5
	${pacp}=    Stop GNB Ttitrace With Streaming Mode    save_path=${TEST_LOG_DIRECTORY()}step5_HO_back_to_gnb2_2
	Decoder Tttirace From Pcap To Csv    ${pacp}    ${save_log}/tti
	Inquery UE'1' NR Measurement Identities	
	wait Throughput Timer    2
	${Pcell_dl_throughput} =    Airphone Get Throughput On Specific Scell    ue_id=${UE_ID}    scell_id=0    type=pdsch    tput_type=ave
	#Start GNB BIP Log
	#Wait Throughput Timer    1
    #Stop Gnb BIP Log    log_dir=${save_log}
	run keyword and continue on failure    delete_ho_interim    ${save_log}/tti_ul.csv    ${save_log}/tti_without_ho_interim_ul.csv
	run keyword and continue on failure    spill_value_of_srsswitchmeas    ${save_log}/tti_dl.csv    ${save_log}/target_dl.csv
	run keyword and continue on failure    check_log_with_au2anlysis
    ...    ini_path=${CURDIR}/log_check/C1_case07_tti_dl_step4.ini    log_need_to_check=i    save_log_directory=${save_log}
	run keyword and continue on failure    check_log_with_au2anlysis
    ...    ini_path=${CURDIR}/log_check/C1_case07_tti_ul_step5.ini    log_need_to_check=i    save_log_directory=${save_log}
	airphone_collect_egate_log_files      ${TEST_LOG_DIRECTORY()}step5_HO_back_to_gnb2_2   unzip=TRUE
    [Teardown]    run keyword and continue on failure    Stop Capture GNB and AP Syslog in 'step5_HO_back_to_gnb2_2' File

Add L2PS Deubg Logs	
    ${debuglogs}    create list    level=DBG\n    L2.L2_PS.DEBUG=1\n    L2.L2_PS.DL.SUBBAND_BEAMFORMING=1\n    L2.L2_PS.SRS_BASED_BM=1\n 
	Active L2ps Feature Debug Traces    ${debuglogs}
	TAF_SSH.connect to    192.168.255.1   toor4nsn    oZPS0POrRieRtu   alias=bsh
	TAF_SSH.execute    rm /ffs/run/HashContainer*    connection=bsh

Step 4_for_knife: Perform UE handover to gnb2 cell1
	Start Capture GNB and AP Syslog in 'step4_HO_to_gnb2_1' File
	Log To Console    \n\r==================the beginning of HO==================\n\r
	${save_log}=    Set Variable    ${TEST_LOG_DIRECTORY()}step4_HO_to_gnb2_1
	wait Throughput Timer    120
	Airphone SA Start Data Traffic    ${UE_ID}    DL    175M    trf_id=1    pdu_id=${PDU_ID}    duration=${3600}
    Airphone SA Start Data Traffic    ${UE_ID}    DL    175M    trf_id=2    pdu_id=${PDU_ID}    duration=${3600}
	Airphone SA Start Data Traffic    ${UE_ID}    DL    175M    trf_id=3    pdu_id=${PDU_ID}    duration=${3600}
	Airphone SA Start Data Traffic    ${UE_ID}    DL    175M    trf_id=4    pdu_id=${PDU_ID}    duration=${3600}
    Airphone SA Start Data Traffic    ${UE_ID}    DL    175M    trf_id=5    pdu_id=${PDU_ID}    duration=${3600}
	Airphone SA Start Data Traffic    ${UE_ID}    UL    175M     trf_id=1    pdu_id=${PDU_ID}    duration=${3600}
	#Wait Throughput Timer    10
	#Start GNB BIP Log
	#Wait Throughput Timer    4
	#Stop Gnb BIP Log    log_dir=${save_log}
    Inquery UE'1' NR Measurement Identities
	${cmd}=    Set Variable    ue_measurement_send_nr id=1 meas_id=1 event=A2 srsrp_nr=45
    airphone_execute_egate_command    ${cmd}
	Inquery UE'1' NR Measurement Identities
	${cmd}=    Set Variable    ue_measurement_send_nr id=1 meas_id=1 event=A3 srsrp_nr=30 phycell_id=50 nrsrp_nr=80
	#Start GNB Ttitrace With Streaming Mode
	airphone_execute_egate_command    ${cmd}    pass_regexp=Intra-eNB handover from EXT_ENB-2.2 to EXT_ENB-2.1 performed
	Log To Console    \n\r==================the end of HO==================\n\r
	wait Throughput Timer    5
	#${pacp}=    Stop GNB Ttitrace With Streaming Mode    save_path=${TEST_LOG_DIRECTORY()}step4_HO_to_gnb2_1
	#Decoder Tttirace From Pcap To Csv    ${pacp}    ${save_log}/tti
	#Start GNB BIP Log
	#Wait Throughput Timer    1
    #Stop Gnb BIP Log    log_dir=${save_log}
	run keyword and continue on failure    delete_ho_interim    ${save_log}/tti_ul.csv    ${save_log}/tti_without_ho_interim_ul.csv
	run keyword and continue on failure    spill_value_of_srsswitchmeas    ${save_log}/tti_dl.csv    ${save_log}/target_dl.csv
	run keyword and continue on failure    check_log_with_au2anlysis
    ...    ini_path=${CURDIR}/log_check/C1_case07_tti_dl_step4.ini    log_need_to_check=i    save_log_directory=${save_log}
	run keyword and continue on failure    check_log_with_au2anlysis
    ...    ini_path=${CURDIR}/log_check/C1_case07_tti_ul_step4.ini    log_need_to_check=i    save_log_directory=${save_log}
	Run Keyword And Ignore Error    Airphone Get Throughput On Specific Scell    ue_id=${UE_ID}    scell_id=0    type=pdsch    tput_type=ave
	airphone_collect_egate_log_files      ${TEST_LOG_DIRECTORY()}step4_HO_to_gnb2_1   unzip=TRUE
    [Teardown]    run keyword and continue on failure    Stop Capture GNB and AP Syslog in 'step4_HO_to_gnb2_1' File