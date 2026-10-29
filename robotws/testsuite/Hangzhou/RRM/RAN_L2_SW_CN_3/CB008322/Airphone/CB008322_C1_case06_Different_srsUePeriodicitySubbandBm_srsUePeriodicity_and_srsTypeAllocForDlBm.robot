# *** Settings ***
# Documentation     Author: shuiheng.he@nokia-sbell.com
# ...
# ...               QC case full name:
# ...               CB008322_C1_case06_Coexist_with_UL_SRS_BF_Different_ rdMinSrsUePeriodicity _srsUePeriodicity_and_srsTypeAllocForDlBm
# ...
# 
# Suite Setup       Common Suite Setup
# Suite Teardown    Common Suite Teardown
# Test Setup        Common Test Setup
# #Test Teardown     Common Test Teardown
# Force Tags        CLOUD_5G_I_LO_AP_LO_SANSA_FS_ECPRI_CMWV_TDD    AP    CRT    SBTS00    RAN_5G_TDD    RAN_5G    owner_shuihe
# Test Timeout      90 minutes
# Resource          ../../resources/sg11/internal_resource/robot/modify_configuration.robot
# Resource          ../../resources/sg11/internal_resource/robot/internal_ap_operate.robot
# Resource          ../../resources/sg11/internal_resource/robot/internal_gnb_operate.robot
# Resource          ../../resources/sg11/internal_resource/robot/internal_capture_log.robot
# Library     taf.transport.ssh    WITH NAME    TAF_SSH
# Library           ta_a2a
# 
# *** Variables ***
# ${CONFIG_DIR_PATH}    ${CURDIR}/../../resources/sg11/internal_resource/config/
# ${SCFC_NAME}    gNB_scf_ASIL_ABIO_TDD_eCPRI_cmwv_SANSA_FS_1S_1CC.xml
# ${AIRPHONE_NAME}    AP_iphy_AQQL_ASIL_ABIO_TDD_eCPRI_cmwv_SANSA_FS_1S_1CC.xml
# ${WTS_NAME}       wts_config_ASIL_ABIO_TDD_eCPRI_cmwv_SANSA_FS_1S_1CC.cfg
# @{LOG_NAME_LIST}      gnb_snapshot    ap_snapshot    egatelog
# ${cellDepType}                             text|SA+NSA|//*[@name\="cellDepType"]
# ${chBw}                                    text|100MHz|//*[@name\="chBw"]
# ${dlMimoMode}                              text|4x4 or 4x2 Closed Loop Spatial Multiplexing|//*[@name\="dlMimoMode"]
# ${nrCellType}                              text|4DL4UL|//*[@name\="nrCellType"]
# ${actUeCsirsCoexistCellCsirs}              text|false|//*[@name\="actUeCsirsCoexistCellCsirs"]
# ${actCsirsMultiplexing}                    text|true|//*[@name\="actCsirsMultiplexing"]
# ${actDlSrsBm}                              text|true|//*[@name\="actDlSrsBm"]
# ${actUlSrsBm}                              text|true|//*[@name\="actUlSrsBm"]
# ${actDlSrsSubbandBm}                       text|true|//*[@name\="actDlSrsSubbandBm"]
# ${actUlClosedLoopPwrCtrl}                  text|disabled|//*[@name\="actUlClosedLoopPwrCtrl"]
# ${actCDrx}                                 text|false|//*[@name\="actCDrx"]
# ${actFdmScheduling}                        text|true|//*[@name\="actFdmScheduling"]
# ${frameStructureType}                      text|semiStatic|//*[@name\="frameStructureType"]
# ${guardPeriodLength}                       text|2Symbols|//*[@name\="guardPeriodLength"]
# ${ulDlDataSlotRatio}                       text|1/4|//*[@name\="ulDlDataSlotRatio"]
# ${prachConfigurationIndex}                 text|98|//*[@name\="prachConfigurationIndex"]
# ${srsUePeriodicity}                        text|slots40|//*[@name\="srsUePeriodicity"]
# ${cSRS}                                    text|63|//*[@name\="cSRS"]
# ${bSRS}                                    text|2|//*[@name\="bSRS"]
# ${srsPowerThresholdForDlBm}                text|-1200|//*[@name\="srsPowerThresholdForDlBm"]
# ${srsTypeAllocForDlBm}                     text|codebook|//*[@name\="srsTypeAllocForDlBm"]
# ${bfSubbandSize}                           text|8 PRBs|//*[@name\="bfSubbandSize"]
# ${maxNumUeSrs}                             text|4|//*[@name\="maxNumUeSrs"]
# ${srsQualityThreshold}                     text|-1200|//*[@name\="srsQualityThreshold"]
# 
# ${FILTER1}    uldata_srsreceivereq
# @{title1}    UlData_srsBwvReportRequest_t.numPatternId
# ${srsPowerThresholdForUlBm}                 text|-1320|//*[@name\="srsPowerThresholdForUlBm"]
# ${dllaDeltaCqiMax}                          text|0|//*[@name\="dllaDeltaCqiMax"]
# ${dllaDeltaCqiMin}                          text|0|//*[@name\="dllaDeltaCqiMin"]
# ${dllaDeltaCqiStepdown}                     text|0|//*[@name\="dllaDeltaCqiStepdown"]
# ${actIncreasedFdmUsersPerSlot}              text|true|//*[@name\="actIncreasedFdmUsersPerSlot"]
# ${actDlMuMimoEnh}                           text|true|//*[@name\="actDlMuMimoEnh"]
# ${cmd_1_00}    ul_mimo_srs_beam_pos_nr profile_id=1 mode=fixed init_quad_pos=0 init_sub_quad_pos=0 test_type=SRS multi_path_config=true
# ${cmd_002_001}    num_of_nlos_paths=1 azimuth=15 zenith=0 srs_transmit_power_per_port=-350,-500,-350,-500
# ${cmd_002_002}    num_of_nlos_paths=1 azimuth=45 zenith=0 srs_transmit_power_per_port=-350,-500,-350,-500
# ${cmd_003}    subband_config_subband_prb_size=16
# ${cmd_004}    subband_config_stepsize_azimuth=2 subband_config_stepsize_zenith=2 subband_config_start_prb=1 subband_config_num_of_prb=216
# ${cmd_2_00}    ul_mimo_srs_beam_pos_nr profile_id=2 mode=fixed init_quad_pos=0 init_sub_quad_pos=0 test_type=SRS multi_path_config=true
# ${cmd_1_22}    ul_mimo_srs_beam_pos_nr profile_id=1 mode=fixed init_quad_pos=2 init_sub_quad_pos=2 test_type=SRS multi_path_config=true
# ${cmd_2_22}    ul_mimo_srs_beam_pos_nr profile_id=2 mode=fixed init_quad_pos=2 init_sub_quad_pos=2 test_type=SRS multi_path_config=true
# 
# *** Test Cases ***
# CB008322_C1_case06_Coexist_with_UL_SRS_BF_Different_ rdMinSrsUePeriodicity _srsUePeriodicity_and_srsTypeAllocForDlBm
#     Step1:Commission the above configuration on WebUI
#     Step2:SA UE with t2r4 capability attach to cell1
#     Step3:Do Traffic to make the UEs be configured as wide band SRS
#     Step4:Triger sub-band TAS SRS by buffer
# 	Step5:Return to RT beam
# 
# *** Keywords ***
# Step1:Commission the above configuration on WebUI
#     Start Capture GNB and AP Syslog in 'Step1_before_onair' File
# 	${CONFIG_DIR_PATH}    Set Variable    ${CONFIG_DIR_PATH}/${SW_BRANCH}
#     change_iphy_rru_version    ${CONFIG_DIR_PATH}${/}${AIRPHONE_NAME}
#     modify_swconfig_by_CB008322    ${CONFIG_DIR_PATH}${/}${SCFC_NAME}
#     ${scfc_path}    Set Variable    ${TEST_LOG_DIRECTORY()}${/}scfc.xml
#     copy_file    ${CONFIG_DIR_PATH}/${SCFC_NAME}    ${scfc_path}
#     #del_elements_from_xml    xml_path=${scfc_path}    parameter=lteToNrFrameShift
#     #del_elements_from_xml    xml_path=${scfc_path}    parameter=tdLteUlDlConfig
#     #add_bwplist_list_in_cells_new    ${scfc_path}    key_4
# #    add_xml_element     ${scfc_path}    ${scfc_path}
# #    ...    <p name="srsPowerThresholdForUlBm">1320</p>|//*[matches(@distName, 'MRBTS-1/NRBTS-1/NRCELL-1']
#     add_element_from_xml    ${scfc_path}    MRBTS-1/NRBTS-1/NRCELL-1    srsPowerThresholdForUlBm    1320
#     ${modify_list}    create list
# 	...      ${cellDepType}    ${chBw}    ${dlMimoMode}    ${nrCellType}    ${actUeCsirsCoexistCellCsirs}
# 	...      ${actCsirsMultiplexing}    ${actDlSrsBm}    ${actUlSrsBm}    ${actUlClosedLoopPwrCtrl}    ${actCDrx}    ${actFdmScheduling}
# 	#...      ${frameStructureType}    ${guardPeriodLength}    ${ulDlDataSlotRatio}    ${prachConfigurationIndex}
# 	...      ${srsUePeriodicity}    ${cSRS}    ${bSRS}     ${srsPowerThresholdForDlBm}
# 	...      ${srsTypeAllocForDlBm}
# 	...      ${actDlSrsSubbandBm}    ${bfSubbandSize}    ${maxNumUeSrs}    ${srsQualityThreshold}
# 	...      ${dllaDeltaCqiMax}    ${dllaDeltaCqiMin}    ${dllaDeltaCqiStepdown}    ${actIncreasedFdmUsersPerSlot}    ${actDlMuMimoEnh}
#     modify_xml    ${scfc_path}    ${scfc_path}    ${modify_list}
#     Modify TL VM And AP SCTP Configuration
#     #Get and Update BSR File    par_of_bsr_name=BSR_AQQL_6_H6_ALN60_ARP60_N01_COVERAGE_00392_00001
# 	Get and Update BSR File    par_of_bsr_name=BSR_AQQL_6_H6_ALN60_ARP60_P11_COVERAGE_00776_00001
#     Add L2PS Deubg Logs
# 	Perform Full Commission And Reach Onair With Log    ${scfc_path}    ${CONFIG_DIR_PATH}${/}${WTS_NAME}    reset_after_commission=${False}
#     #Start GNB BIP Log
#     #Wait Throughput Timer    5
#     ${save_log}=    Set Variable    ${TEST_LOG_DIRECTORY()}Step1_before_onair
#     #Stop Gnb BIP Log    log_dir=${save_log}
# 	#Convert BIP To CSV    ${TEST_LOG_DIRECTORY()}/cellSetup0.pcap    ${save_log}/cellsetup.csv    ${FILTER1}    ${title1}
#     #run keyword and continue on failure    check_log_with_au2anlysis    ini_path=${CURDIR}/log_check/C1_case01_bip_step1.ini    log_need_to_check=i
#     #...    save_log_directory=${save_log}
#     [Teardown]    Stop Capture GNB and AP Syslog in 'Step1_before_onair' File
# 
# modify_swconfig_by_CB008322
#     comment     https://confluence.ext.net.nokia.com/pages/viewpage.action?spaceKey=AirPhoneWTS&title=AirPhone+Alignment+to+gNB+L1L2+Interface
#     [Arguments]    ${scfc_file}
# 	${local_save_path}=     Download All Common Config Files From Golden Server
# 	${path_gnb}=            Find Match GNB swconfig Golden Files    ${scfc_file}    ${local_save_path}
# 	${path_ap}=             Find Match AP swconfig Golden Files    ${scfc_file}     ${local_save_path}
#     setup_txt    src_file=${path_gnb}    save_path=${TEST_LOG_DIRECTORY()}${/}swconfig_gnb_ini.txt
# 	add_txt_node    0x340000:5         #as PM counter period update to 15/15=1min
#     #add_txt_node    0x580556:0x834        #rdStartPatternId
# 	add_txt_node    0x5805ae:1       #Flag to enable or disable dynamic Wb/Sb Srs Switch
# 	add_txt_node    0x590103:2       #whether codebook SRS is reused for TAS SRS
# 	#add_txt_node    0x5900FD:0x1       #The maximum number of SRS resource that can use same SRS symbol for frame structure defined in 5GC001208
# 	#add_txt_node    0x590128:0x1       #The maximum number of SRS resource that can use same SRS symbol for frame structure defined in 5GC001116
# 	#add_txt_node    0x590127:0x1       #The maximum number of SRS resource that can use same SRS symbol for frame structure defined in 5GC001208
# 	add_txt_node    0x58076c:0x10       #the percentage of scheduled PRB
# 	add_txt_node    0x5901E6:40         #wideband periodic
# 	add_txt_node    0x5805B5:5         #rdNumSrsCheck
# 	add_txt_node    0x5805B0:80         #rdSrsBufPercent
#     teardown_txt
# 	setup_txt    src_file=${path_ap}    save_path=${TEST_LOG_DIRECTORY()}${/}swconfig_ap_ini.txt
# #    add_txt_node    0x70690:1         #enable 1086 and 8247
#     teardown_txt
#     GNB Upload Swconfig           ${TEST_LOG_DIRECTORY()}${/}swconfig_gnb_ini.txt
#     airphone_upload_swconfig      ${TEST_LOG_DIRECTORY()}${/}swconfig_ap_ini.txt
# 
# Step2:SA UE with t2r4 capability attach to cell1
#     Start Capture GNB and AP Syslog in 'Step2_attach' File
#     run keyword and continue on failure    Attach SA ue with capability to 5g cell    2    CA_P2_8x4_t2r4_n2
# 	Attach SA ue with capability    3    CA_P2_8x4_noTas_n2
# 	airphone_set_traffic_type    3    1    internal
# 	Airphone Pdu Session Setup    3    1    1    2
# 	: FOR    ${i}    IN RANGE    11     13
# 	\    Airphone NSA Attach    ${i}
# 	#ul_mimo_srs_beam_pos_active_test_type_srs    ue=1    profile=1    init=0    sub=0
#     #ul_mimo_srs_beam_pos_active_test_type_srs    ue=2    profile=2    init=1    sub=0
# 	Airphone Execute Egate Command    ${cmd_1_00} ${cmd_002_001}
# 	Airphone Execute Egate Command    ${cmd_2_00} ${cmd_002_002}
# 	Airphone Execute Egate Command    ue_testmode_set_nr id\=1 testmode\=ul_mimo_srs_beam_pos action\=activate profile_id\=profile_id scell\=0
# 	Airphone Execute Egate Command    ${cmd_1_22} ${cmd_002_001}
# 	Airphone Execute Egate Command    ${cmd_2_22} ${cmd_002_002}
# 	Airphone Execute Egate Command    ue_testmode_set_nr id\=2 testmode\=ul_mimo_srs_beam_pos action\=activate profile_id\=profile_id scell\=0
#     ${save_log}=    Set Variable    ${TEST_LOG_DIRECTORY()}Step2_attach
#     airphone_collect_egate_log_files      ${TEST_LOG_DIRECTORY()}Step2_attach   unzip=TRUE
# 	${rnti_sa_list}    file match all   ${TEST_LOG_DIRECTORY()}${/}Step2_attach${/}/egate_console.log.001   crnti: (\\d+)
# 	Set test Variable	 ${rnti_1} 	${rnti_sa_list[0]}
# 	Set test Variable	 ${rnti_2} 	${rnti_sa_list[1]}
# 	Set test Variable	 ${rnti_3} 	${rnti_sa_list[2]}
# 	${rnti_nsa_list}    file match all   ${TEST_LOG_DIRECTORY()}${/}Step2_attach${/}/egate_console.log.001   newUE-Identity (\\d+)
# 	Set test Variable	 ${rnti_4} 	${rnti_nsa_list[0]}
# 	Set test Variable	 ${rnti_5} 	${rnti_nsa_list[1]}
# 	#run keyword and continue on failure	check_log_with_au2anlysis  ini_path=${CURDIR}/log_check/C1_case04_RRC_step2.ini
#     # ...	 log_need_to_check=p	save_log_directory=${TEST_LOG_DIRECTORY()}Step2_attach
#     [Teardown]    Stop Capture GNB and AP Syslog in 'Step2_attach' File
# 	
# ul_mimo_srs_beam_pos_active_test_type_srs
#     [Arguments]    ${ue}    ${profile}    ${init}    ${sub}    ${scell}=0    ${step}=10    ${puxch}=0    ${u}=trigger_puxch_update
#     ...    ${iq}=init_quad_pos    ${sq}=init_sub_quad_pos    ${m}=multi_path_config    ${mu_path}=0    ${p}=profile_id    ${y}=test_type
#     ...    ${t}=SRS
#     airphone_execute_egate_command
#     ...    ul_mimo_srs_beam_pos_nr ${p}\=${profile} mode\=fixed ${iq}\=${init} ${sq}\=${sub} step\=${step} ${u}\=${puxch} 
#    ...    ${m}\=${mu_path} ${y}\=${t}
# 	airphone_execute_egate_command
# 	...    ue_testmode_set_nr id\=${ue} testmode\=ul_mimo_srs_beam_pos action\=activate profile_id\=${profile} scell\=${scell}
# 
# 
# Step3:Do Traffic to make the UEs be configured as wide band SRS
#     Start Capture GNB and AP Syslog in 'Step3_Do_DL_Traffic' File
# 	Log To Console    \n\r==================the beginning of traffic commands==================\n\r
# 	#Wait Throughput Timer    120
#     : FOR    ${i}    IN RANGE    11     13
# 	\    Airphone NSA Start Data Traffic    ${i}    DL    150M    duration=${3600}    trf_id=1
# 	#\    Airphone NSA Start Data Traffic    ${i}    UL    50M    duration=${3600}    trf_id=1
# 	\    Airphone NSA Start Data Traffic    ${i}    DL    150M    duration=${3600}    trf_id=2
# 	\    Airphone NSA Start Data Traffic    ${i}    UL    50M    duration=${3600}    trf_id=2
# 	: FOR    ${i}    IN RANGE    1    2     
#     \    Airphone SA Start Data Traffic    3    DL    150M    trf_id=${i}    pdu_id=1    duration=${3600}
#     #\    Airphone SA Start Data Traffic    3    UL    50M    trf_id=${i}    pdu_id=1    duration=${3600}
# 	: FOR    ${i}    IN RANGE    1    2
# 	\    Airphone SA Start Data Traffic    1    DL    150M    trf_id=${i}    pdu_id=1    duration=${3600}
#     \    Airphone SA Start Data Traffic    1    UL    50M    trf_id=${i}    pdu_id=1    duration=${3600}
# 	: FOR    ${i}    IN RANGE    1    2
# 	\    Airphone SA Start Data Traffic    2    DL    150M    trf_id=${i}    pdu_id=1    duration=${3600}
#     \    Airphone SA Start Data Traffic    2    UL    50M    trf_id=${i}    pdu_id=1    duration=${3600}
# 	Log To Console    \n\r==================the ending of traffic commands==================\n\r
#     #airphone_execute_egate_command    csi_override_testmode_nr profile_id\=1 cqi\=1
#     #airphone_execute_egate_command    ue_testmode_set_nr id\=4 testmode\=csi_override action\=activate profile_id\=1
# 	#airphone_execute_egate_command    ue_testmode_set_nr id\=5 testmode\=csi_override action\=activate profile_id\=1
#     Start GNB Ttitrace With Streaming Mode
#     Wait Throughput Timer    2
#     ${save_log}=    Set Variable    ${TEST_LOG_DIRECTORY()}Step3_Do_DL_Traffic
#     ${pacp}=    Stop GNB Ttitrace With Streaming Mode    save_path=${save_log}
#     Decoder Tttirace From Pcap To Csv    ${pacp}    ${save_log}/tti
# 	Start GNB BIP Log
#     Wait Throughput Timer    1
#     ${save_log}=    Set Variable    ${TEST_LOG_DIRECTORY()}Step3_Do_DL_Traffic
#     Stop Gnb BIP Log    log_dir=${save_log}
# 	Convert BIP To CSV    ${save_log}/tcpdump_L2L1_bip_filtering_off.pcap0    ${save_log}/bip.csv    ${FILTER1}    ${title1}
# 	run keyword and continue on failure    spill_value_of_srsswitchmeas    ${save_log}/tti_dl.csv    ${save_log}/target_dl.csv
# 	run keyword and continue on failure    check_log_with_au2anlysis
#     ...    ini_path=${CURDIR}/log_check/C1_case06_tti_dl_step3.ini    log_need_to_check=i    save_log_directory=${save_log}
# 	run keyword and continue on failure    check_log_with_au2anlysis
#     ...    ini_path=${CURDIR}/log_check/C1_case06_tti_ul_step3.ini    log_need_to_check=i    save_log_directory=${save_log}
# 	#${tput}    get DL UL tput from PM counter    ${save_log}
#     #run keyword and continue on failure    should be true    ${tput}[0]>850
# 	#run keyword and continue on failure    should be true    ${tput}[1]>130
#     [Teardown]    run keyword and continue on failure    Stop Capture GNB and AP Syslog in 'Step3_Do_DL_Traffic' File
# 
# Step4:Triger sub-band TAS SRS by buffer
# 	Start Capture GNB and AP Syslog in 'Step4_triger_subband_tas_srs' File
#     airphone_execute_egate_command    csi_override_testmode_nr profile_id\=1 ri\=1
#     airphone_execute_egate_command    ue_testmode_set_nr id\=1 testmode\=csi_override action\=activate profile_id\=1
# 	Start GNB Ttitrace With Streaming Mode
#     Wait Throughput Timer    2
#     ${save_log}=    Set Variable    ${TEST_LOG_DIRECTORY()}Step4_triger_subband_tas_srs
#     ${pacp}=    Stop GNB Ttitrace With Streaming Mode    save_path=${save_log}
#     Decoder Tttirace From Pcap To Csv    ${pacp}    ${save_log}/tti
# 	Start GNB BIP Log
#     Wait Throughput Timer    3
#     ${save_log}=    Set Variable    ${TEST_LOG_DIRECTORY()}Step4_triger_subband_tas_srs
#     Stop Gnb BIP Log    log_dir=${save_log}
# 	Convert BIP To CSV    ${save_log}/tcpdump_L2L1_bip_filtering_off.pcap0    ${save_log}/bip.csv    ${FILTER1}    ${title1}
# 	run keyword and continue on failure    spill_value_of_srsswitchmeas    ${save_log}/tti_dl.csv    ${save_log}/target_dl.csv
#     run keyword and continue on failure    check_log_with_au2anlysis
#     ...    ini_path=${CURDIR}/log_check/C1_case06_tti_dl_step4.ini    log_need_to_check=i    save_log_directory=${save_log}
# 	run keyword and continue on failure    check_log_with_au2anlysis
#     ...    ini_path=${CURDIR}/log_check/C1_case06_tti_ul_step3.ini    log_need_to_check=i    save_log_directory=${save_log}
#     [Teardown]    run keyword and continue on failure    Stop Capture GNB and AP Syslog in 'Step4_triger_subband_tas_srs' File
# 
# Step5:Return to RT beam
#     Start Capture GNB and AP Syslog in 'Step5_Return_to_RT_beam' File
#     airphone_execute_egate_command    csi_override_testmode_nr profile_id\=1 ri\=3
#     airphone_execute_egate_command    ue_testmode_set_nr id\=1 testmode\=csi_override action\=activate profile_id\=1
# 	Start GNB Ttitrace With Streaming Mode
#     Wait Throughput Timer    2
#     ${save_log}=    Set Variable    ${TEST_LOG_DIRECTORY()}Step5_Return_to_RT_beam
#     ${pacp}=    Stop GNB Ttitrace With Streaming Mode    save_path=${save_log}
#     Decoder Tttirace From Pcap To Csv    ${pacp}    ${save_log}/tti
# 	Start GNB BIP Log
#     Wait Throughput Timer    3
#     ${save_log}=    Set Variable    ${TEST_LOG_DIRECTORY()}Step5_Return_to_RT_beam
#     Stop Gnb BIP Log    log_dir=${save_log}
# 	Convert BIP To CSV    ${save_log}/tcpdump_L2L1_bip_filtering_off.pcap0    ${save_log}/bip.csv    ${FILTER1}    ${title1}
# 	run keyword and continue on failure    spill_value_of_srsswitchmeas    ${save_log}/tti_dl.csv    ${save_log}/target_dl.csv
#     run keyword and continue on failure    check_log_with_au2anlysis
#     ...    ini_path=${CURDIR}/log_check/C1_case06_tti_dl_step5.ini    log_need_to_check=i    save_log_directory=${save_log}
# 	run keyword and continue on failure    check_log_with_au2anlysis
#     ...    ini_path=${CURDIR}/log_check/C1_case06_tti_ul_step3.ini    log_need_to_check=i    save_log_directory=${save_log}
# 	#${tput}    get DL UL tput from PM counter    ${save_log}
#     #run keyword and continue on failure    should be true    ${tput}[0]>850
# 	#run keyword and continue on failure    should be true    ${tput}[1]>130
#     [Teardown]    run keyword and continue on failure    Stop Capture GNB and AP Syslog in 'Step5_Return_to_RT_beam' File
# 
# Add L2PS Deubg Logs	
#     ${debuglogs}    create list    level=DBG\n    L2.L2_PS.DEBUG=1\n    L2.L2_PS.DL.SUBBAND_BEAMFORMING=1\n    L2.L2_PS.SRS_BASED_BM=1\n 
# 	Active L2ps Feature Debug Traces    ${debuglogs}
# 	TAF_SSH.connect to    192.168.255.1   toor4nsn    oZPS0POrRieRtu   alias=bsh
# 	TAF_SSH.execute    rm /ffs/run/HashContainer*    connection=bsh
# 
# get DL UL tput from PM counter
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
#     [Return]    ${DL_throughput}    ${UL_throughput}
