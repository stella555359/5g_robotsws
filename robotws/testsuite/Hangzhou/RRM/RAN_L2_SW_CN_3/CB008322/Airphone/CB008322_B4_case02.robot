# *** Settings ***
# Documentation     Author: xuemin.ma@nokia-sbell.com
# ...
# ...               QC case full name:
# ...               CB008322_B4_case01_IWK_CB007459_Supporting SPID UEs_4NSA_UEs
# 
# Suite Setup       Common Suite Setup
# #Suite Teardown    Common Suite Teardown
# Test Setup        Common Test Setup
# Test Teardown     Common Test Teardown
# Force Tags        CLOUD_5G_I_LO_AP_LO_SANSA_FS_ECPRI_CMWV_TDD    AP    CRT    SBTS00    RAN_5G_TDD    RAN_5G    owner_xueminm
# Test Timeout      90 minutes
# Resource          ../../resources/sg11/internal_resource/robot/modify_configuration.robot
# Resource          ../../resources/sg11/internal_resource/robot/internal_ap_operate.robot
# Resource          ../../resources/sg11/internal_resource/robot/internal_gnb_operate.robot
# Resource          ../../resources/sg11/internal_resource/robot/internal_capture_log.robot
# Library           taf.transport.ssh    WITH NAME    TAF_SSH
# Library           ta_a2a
# 
# *** Variables ***
# ${CONFIG_DIR_PATH}    ${CURDIR}/../../resources/sg11/internal_resource/config/
# ${SCFC_NAME}          gNB_scf_ASIL_ABIO_TDD_eCPRI_cmwv_SANSA_FS_1S_1CC_8D4U.xml
# ${AIRPHONE_NAME}      AP_iphy_AQQL_ASIL_ABIO_TDD_eCPRI_cmwv_SANSA_FS_1S_1CC.xml
# ${WTS_NAME}           wts_config_ASIL_ABIO_TDD_eCPRI_cmwv_SANSA_FS_1S_1CC.cfg
# @{LOG_NAME_LIST}      egatelog\    gnb_snapshot
# #    ap_snapshot    sosreport
# ${cellDepType}                    text|SA+NSA|//*[@name\="cellDepType"]
# ${chBw}                           text|100MHz|//*[@name\="chBw"]
# ${dlMimoMode}                     text|4x4 or 4x2 Closed Loop Spatial Multiplexing|//*[@name\="dlMimoMode"]
# ${nrCellType}                     text|8DL4UL|//*[@name\="nrCellType"]
# ${actUeCsirsCoexistCellCsirs}     text|false|//*[@name\="actUeCsirsCoexistCellCsirs"]
# ${actCsirsMultiplexing}           text|true|//*[@name\="actCsirsMultiplexing"]
# ${actDlSrsBm}                     text|true|//*[@name\="actDlSrsBm"]
# ${actUlSrsBm}                     text|false|//*[@name\="actUlSrsBm"]
# ${actDlSrsSubbandBm}              text|true|//*[@name\="actDlSrsSubbandBm"]
# ${actUlClosedLoopPwrCtrl}         text|disabled|//*[@name\="actUlClosedLoopPwrCtrl"]
# ${actCDrx}                        text|false|//*[@name\="actCDrx"]
# ${actFdmScheduling}               text|true|//*[@name\="actFdmScheduling"]
# ${frameStructureType}             text|tdLte|//*[@name\="frameStructureType"]
# ${guardPeriodLength}              text|6Symbols|//*[@name\="guardPeriodLength"]
# ${lteToNrFrameShift}              text|0ms|//*[@name\="lteToNrFrameShift"]
# ${tdLteUlDlConfig}                text|tdLteConfig2|//*[@name\="tdLteUlDlConfig"]
# ${ulDlDataSlotRatio}              text|3/7|//*[@name\="ulDlDataSlotRatio"]
# ${prachConfigurationIndex}        text|97|//*[@name\="prachConfigurationIndex"]
# ${srsUePeriodicity}               text|slots80|//*[@name\="srsUePeriodicity"]
# ${cSRS}                           text|62|//*[@name\="cSRS"]
# ${bSRS}                           text|2|//*[@name\="bSRS"]
# ${srsPowerThresholdForDlBm}       text|-1200|//*[@name\="srsPowerThresholdForDlBm"]
# ${srsTypeAllocForDlBm}            text|antenna switching or codebook|//*[@name\="srsTypeAllocForDlBm"]
# ${bfSubbandSize}                  text|16 PRBs|//*[@name\="bfSubbandSize"]
# ${maxNumUeSrs}                    text|2|//*[@name\="maxNumUeSrs"]
# ${srsQualityThreshold}            text|-1150|//*[@name\="srsQualityThreshold"]
# ${actCustomBsr}                   text|true|//*[@name\="actCustomBsr"]
# ${customBeamSetName}              text|BSR_AQQL_6_H6_ALN60_ARP60_P11_COVERAGE_00776_00001|//*[@name\="customBeamSetName"]
# ${actIncreasedFdmUsersPerSlot}    text|true|//*[@name\="actIncreasedFdmUsersPerSlot"]
# ${actDlMuMimoEnh}                 text|false|//*[@name\="actDlMuMimoEnh"]
# ${actDl256Qam}                    text|false|//*[@name\="actDl256Qam"]
# ${actUl256Qam}                    text|false|//*[@name\="actUl256Qam"]
# ${actSpid}                        text|true|//*[@name\="actSPID"]
# ${actUlOpenLoopPwrCtrl}           text|true|//*[@name\="actUlOpenLoopPwrCtrl"]
# ${pMaxNROwnCell}                  text|23|//*[@name\="pMaxNROwnCell"]
# ${p0NominalPucch}                 text|-80|//*[@name\="p0NominalPucch"]
# ${p0NominalPucchF1F3}             text|-108|//*[@name\="p0NominalPucchF1F3"]
# ${p0NominalPusch}                 text|-74|//*[@name\="p0NominalPusch"]
# ${p0NominalSrs}                   text|-80|//*[@name\="p0NominalSrs"]
# ${par_of_bsr_name}                BSR_AQQL_6_H6_ALN60_ARP60_P11_COVERAGE_00776_00001
# 
# ${CP_UE_rdSktSpId}    17
# ${CP_UE_rdSktPlmnId_ini}    1261976
# ${CP_UE_rdUlPowerControl}    True
# ${CP_UE_rdNsaInactTimer}     1200
# ${CP_UE_rdActInactDetNSAUe}     True
# 
# ${profile_3}    csi_override_testmode_nr profile_id=3 cqi_mode=fixed cqi=15 ri_mode=fixed ri=0
# ${Act_profile_3}    ue_testmode_set_nr id=1 testmode=csi_override profile_id=3 action=activate
# ${Deact_profile_3}    ue_testmode_set_nr id=1 testmode=csi_override profile_id=3 action=deactivate
# ${profile_2}    csi_override_testmode_nr profile_id=2 cqi_mode=fixed cqi=15 ri_mode=fixed ri=3
# ${Act_profile_2}    ue_testmode_set_nr id=1 testmode=csi_override profile_id=2 action=activate
# ${Deact_profile_2}    ue_testmode_set_nr id=1 testmode=csi_override profile_id=2 action=deactivate
# 
# ${PROFILE1}    ul_mimo_srs_beam_pos_nr profile_id=1 mode=fixed init_quad_pos=1 init_sub_quad_pos=1 test_type=SRS
# ...        multi_path_config=true num_of_nlos_paths=1 azimuth=15 zenith=0 srs_transmit_power_per_port=-300,-300,-300,-300
# ${PROFILE11}    ul_mimo_srs_beam_pos_nr profile_id=11 mode=fixed init_quad_pos=1 init_sub_quad_pos=1 test_type=SRS
# ...        multi_path_config=true num_of_nlos_paths=1 azimuth=15 zenith=0 srs_transmit_power_per_port=-180,-180,-180,-180
# 
# *** Test Cases ***
# CB008322_B4_case02_IWK_CB007459_Supporting SPID UEs_SANSA_UE_mix
#     Step1:Commission the above configuration on WebUI
#     Step2:Attach 1SA UE1, 1NSA UE2,start full bufer
#     Step3:Attach NSA UE3 with SPID matching rdSktSpId
#     Step4:Attach NSA UE4 with SPID non-matching rdSktSpId
#     Step5:Override UE1’s rank below threshold
#     Step6:Stop buffer for UE3
# 	Step7:Restart buffer for UE3,Recover UE1’s rank
# 	Step8:Stop UE4’s buffer
# 
# *** Keywords ***
# Step1:Commission the above configuration on WebUI
#     Start capture GNB and AP Syslog in 'Step1_before_onair' File
#     Change RandD parameters     CPUE_addons_snowfish    ${CP_UE_rdSktSpId}    ${CP_UE_rdSktPlmnId_ini}    ${CP_UE_rdUlPowerControl}
#     ...        ${CP_UE_rdNsaInactTimer}    ${CP_UE_rdActInactDetNSAUe}
#     Change RandD parameters     CPUE_addons_xeon    ${CP_UE_rdSktSpId}    ${CP_UE_rdSktPlmnId_ini}    ${CP_UE_rdUlPowerControl}
#     ...        ${CP_UE_rdNsaInactTimer}    ${CP_UE_rdActInactDetNSAUe}
#     Change RandD parameters     CPUE_addons_marlin    ${CP_UE_rdSktSpId}    ${CP_UE_rdSktPlmnId_ini}    ${CP_UE_rdUlPowerControl}
#     ...        ${CP_UE_rdNsaInactTimer}    ${CP_UE_rdActInactDetNSAUe}
# 	${CONFIG_DIR_PATH}    Set Variable    ${CONFIG_DIR_PATH}/${SW_BRANCH}
# 	${mod_iphy}    create list     text|2|//NumberOfSubCellsDL
#     modify xml     ${CONFIG_DIR_PATH}${/}${AIRPHONE_NAME}      ${CONFIG_DIR_PATH}${/}${AIRPHONE_NAME}    ${mod_iphy}
#     change_iphy_rru_version    ${CONFIG_DIR_PATH}${/}${AIRPHONE_NAME}
#     modify_swconfig_by_CB008322    ${CONFIG_DIR_PATH}${/}${SCFC_NAME}
#     ${scfc_path}    Set Variable    ${TEST_LOG_DIRECTORY()}${/}scfc.xml
#     copy_file    ${CONFIG_DIR_PATH}/${SCFC_NAME}    ${scfc_path}
# 	add_xml_element     ${scfc_path}    ${scfc_path}     <p name="lteToNrFrameShift">3ms</p>|//*[@name\='tddFrameStructure']/item
#     add_xml_element     ${scfc_path}    ${scfc_path}     <p name="tdLteUlDlConfig">tdLteConfig2</p>|//*[@name\='tddFrameStructure']/item
#     ${modify_list}    create list
# 	...    ${cellDepType}    ${chBw}    ${dlMimoMode}    ${nrCellType}    ${actUeCsirsCoexistCellCsirs}    ${actCsirsMultiplexing}
# 	...    ${actDlSrsBm}    ${actUlSrsBm}    ${actDlSrsSubbandBm}     ${actUlClosedLoopPwrCtrl}    ${actCDrx}    ${actFdmScheduling}
# 	...    ${frameStructureType}    ${guardPeriodLength}    ${lteToNrFrameShift}    ${tdLteUlDlConfig}    ${ulDlDataSlotRatio}
# 	...    ${prachConfigurationIndex}    ${srsUePeriodicity}    ${cSRS}    ${bSRS}    ${srsPowerThresholdForDlBm}    ${srsTypeAllocForDlBm}
# 	...    ${bfSubbandSize}    ${maxNumUeSrs}    ${srsQualityThreshold}    ${actCustomBsr}    ${customBeamSetName}    ${actIncreasedFdmUsersPerSlot}
# 	...    ${actDlMuMimoEnh}    ${actDl256Qam}    ${actUl256Qam}    ${actSpid}    ${actUlOpenLoopPwrCtrl}    ${pMaxNROwnCell}
# 	...    ${p0NominalPucch}    ${p0NominalPucchF1F3}    ${p0NominalPusch}    ${p0NominalSrs}
#     modify_xml    ${scfc_path}    ${scfc_path}    ${modify_list}
#     Modify TL VM And AP SCTP Configuration
#     Get and Update BSR File    ${par_of_bsr_name}
# 	Add L2PS Deubg Logs
#     Perform Full Commission And Reach Onair With Log    ${scfc_path}    ${CONFIG_DIR_PATH}${/}${WTS_NAME}    reset_after_commission=${False}
# 	[Teardown]    Stop capture GNB and AP Syslog in 'Step1_before_onair' File
# 
# Add L2PS Deubg Logs
#     ${debuglogs}    create list    level=DBG\n    L2.L2_PS.DEBUG=1\n    L2.L2_PS.DL.SUBBAND_BEAMFORMING=1\n    L2.L2_PS.SRS_BASED_BM=1\n
# 	Active L2ps Feature Debug Traces    ${debuglogs}
# 	TAF_SSH.connect to    192.168.255.1   toor4nsn    oZPS0POrRieRtu   alias=bsh
# 	TAF_SSH.execute    rm /ffs/run/HashContainer*    connection=bsh
# 
# modify_swconfig_by_CB008322
#     comment     https://confluence.ext.net.nokia.com/pages/viewpage.action?spaceKey=AirPhoneWTS&title=AirPhone+Alignment+to+gNB+L1L2+Interface
#     [Arguments]    ${scfc_file}
# 	${local_save_path}=     Download All Common Config Files From Golden Server
# 	${path_gnb}=            Find Match GNB swconfig Golden Files    ${scfc_file}    ${local_save_path}
# 	${path_ap}=             Find Match AP swconfig Golden Files    ${scfc_file}     ${local_save_path}
#     setup_txt    src_file=${path_gnb}    save_path=${TEST_LOG_DIRECTORY()}${/}swconfig_gnb_ini.txt
# 	add_txt_node    0x340000:1        #as PM counter period update to 15/15=1min
# 	#add_txt_node    0x5901EB:1        #rdForceEnablingWidebandTasSrs use for  itf_l2_ps_user_usermodifyreq.isWBTasConfigured_item_0=1
# 	#add_txt_node    0x5805ae:1        #Flag to enable or disable dynamic Wb/Sb Srs Switch
# 	add_txt_node    0x580556:2100     #rdStartPatternId=2100(Default Value is 5000)
# 	add_txt_node    0x5901E6:160     #rdMinSrsUePeriodicity=slots40(Default Value is 80slots)
# 	add_txt_node    0x5805b5:10       #rdNumSrsCheck
# 	#add_txt_node    0x5805b4:0x14     #rdPeriodSrsCheck=20(Default Value is 20)
# 	add_txt_node    0x5805b0:100       #rdSrsBufPercent=50(Default Value is 70)
# 	add_txt_node    0x58076c:15       #rdWbSrsPrbTresh=20(Default Value is 45)
# 	add_txt_node    0x58076d:90        #rdWbSrsPrbProh=50(Defalut Value is 20)
# 	add_txt_node    0x580762:70       #rdWbSrsSeTresh
# 	add_txt_node    0x5900CA:0x134198       # rdSktPlmnId
#     add_txt_node    0x5900CB:17         # rdSktSpId
#     add_txt_node    0x5900CC:1     		#rdULPowerControl
#     add_txt_node    0x5900CD:150		#rdP0NominalPucch=-52
#     add_txt_node    0x5900CE:142		#rdP0NominalPucchF1F3=-60
#     add_txt_node    0x5900CF:114		#rdP0NominalPusch=-88
# 	add_txt_node    0x5900D0:206		#rdP0NominalSrs=4
# 	add_txt_node    0x5900D1:1		    #rdAlpha
# 	add_txt_node    0x5900D2:82		    #rdInitialPreambleReceivedTargetPower
# 	add_txt_node    0x5900D3:31		    #rdPMaxNROwnCell
# 	add_txt_node    0x5900cDF:1		    #rdActProactUlScheduling
#     teardown_txt
# 	setup_txt    src_file=${path_ap}    save_path=${TEST_LOG_DIRECTORY()}${/}swconfig_ap_ini.txt
#     teardown_txt
#     GNB Upload Swconfig           ${TEST_LOG_DIRECTORY()}${/}swconfig_gnb_ini.txt
#     airphone_upload_swconfig      ${TEST_LOG_DIRECTORY()}${/}swconfig_ap_ini.txt
# 
# Step2:Attach 1SA UE1, 1NSA UE2,start full bufer
#     Start Collect GNB and AP Syslog in 'Step2_attach_UE12' File
#     Start GNB BIP Log
# 	airphone_sa_attach    ue_id=1
#     airphone_set_traffic_type    ue_id=1    pdu_id=1
#     airphone_pdu_session_setup    ue_id=1    pdu_id=1
#     Wait '2s' for stable running
#     Airphone SA Start Data Traffic    ue_id=1    direction=dl    throughput=175M    trf_id=1    pdu_id=1    duration=7200s
# 	Airphone SA Start Data Traffic    ue_id=1    direction=dl    throughput=175M    trf_id=2    pdu_id=1    duration=7200s
# 	Airphone Execute Egate Command    ${PROFILE1}
#     Airphone Execute Egate Command    ue_testmode_set_nr id\=1 testmode\=ul_mimo_srs_beam_pos action\=activate profile_id\=1
# 	Airphone Nsa Attach    ue_id=12
# 	Airphone NSA Start Data Traffic    12     DL    175M    duration=${7200}    trf_id=1
# 	Airphone NSA Start Data Traffic    12     DL    175M    duration=${7200}    trf_id=2
# 	Airphone Execute Egate Command    ${PROFILE1}
#     Airphone Execute Egate Command    ue_testmode_set_nr id\=12 testmode\=ul_mimo_srs_beam_pos action\=activate profile_id\=1
#     Stop Gnb BIP Log    log_dir=${TEST_LOG_DIRECTORY()}${/}Step2_attach_UE12${/}
#     [Teardown]    Stop Collect GNB and AP Syslog in 'Step2_attach_UE12' File
# 
# Attach UE"${ue_id}" with SPID="${spid}"
#     Airphone Execute Egate Command    ue_enb_param id\=${ue_id} spid\=${spid}
#     Airphone Nsa Attach    ue_id=${ue_id}
# 
# Set UE'${ue_id}' to UE'${ue_id_end}' position
#     : FOR    ${u_id}    IN RANGE    ${ue_id}    ${ue_id_end}+1
#     \    Airphone Execute Egate Command    ${PROFILE1}
#     \    Airphone Execute Egate Command    ue_testmode_set_nr id\=${u_id} testmode\=ul_mimo_srs_beam_pos action\=activate profile_id\=1
#     \    Wait '2s' for stable running
# 
# Step3:Attach NSA UE3 with SPID matching rdSktSpId
#     Start Collect GNB and AP Syslog in 'Step3_attach_1ue_match_spid' File
#     ${save_log}=    Set Variable    ${TEST_LOG_DIRECTORY()}Step3_attach_1ue_match_spid
#     Start GNB BIP Log
#     Attach UE"13" with SPID="17"
# 	Airphone NSA Start Data Traffic    13     DL    175M    duration=${7200}    trf_id=1
# 	Airphone NSA Start Data Traffic    13     DL    175M    duration=${7200}    trf_id=2
# 	Airphone Execute Egate Command    ${PROFILE11}
#     Airphone Execute Egate Command    ue_testmode_set_nr id\=13 testmode\=ul_mimo_srs_beam_pos action\=activate profile_id\=11
#     Stop Gnb BIP Log    log_dir=${save_log}
#     airphone_collect_egate_log_files      ${save_log}   unzip=TRUE
#     run keyword and continue on failure    check_log_with_au2anlysis    ini_path=${CURDIR}/log_check/B4_case02_rrc_spid_ue.ini
#     ...    log_need_to_check=p    save_log_directory=${save_log}
#     [Teardown]    Stop Collect GNB and AP Syslog in 'Step3_attach_1ue_match_spid' File
# 
# Step4:Attach NSA UE4 with SPID non-matching rdSktSpId
#     Start Collect GNB and AP Syslog in 'Step4_attach_1ue_non_match_spid' File
#     ${save_log}=    Set Variable    ${TEST_LOG_DIRECTORY()}Step4_attach_1ue_non_match_spid
#     Start GNB BIP Log
#     Airphone Nsa Attach    ue_id=14
# 	Wait '5s' for stable running
# 	Airphone NSA Start Data Traffic    14     DL    175M    duration=${7200}    trf_id=1
# 	Airphone NSA Start Data Traffic    14     DL    175M    duration=${7200}    trf_id=2
# 	Airphone Execute Egate Command    ${PROFILE1}
#     Airphone Execute Egate Command    ue_testmode_set_nr id\=14 testmode\=ul_mimo_srs_beam_pos action\=activate profile_id\=1
#     Stop Gnb BIP Log    log_dir=${save_log}
# 	airphone_collect_egate_log_files      ${save_log}   unzip=TRUE
# 	${rnti_list}    file match all   ${save_log}/egate_console.log.001   crnti: (\\d+)
# 	Set test Variable	 ${rnti_1} 	${rnti_list[0]}
# 	${rnti_list_2}    file match all   ${save_log}/egate_console.log.001   newUE-Identity (\\d+)
# 	Set test Variable	 ${rnti_2} 	${rnti_list_2[0]}
# 	Set test Variable	 ${rnti_3} 	${rnti_list_2[1]}
# 	Set test Variable	 ${rnti_4} 	${rnti_list_2[2]}
# 	Start GNB Ttitrace With Streaming Mode
# 	Wait '3s' for stable running
# 	${pacp}=    Stop GNB Ttitrace With Streaming Mode    save_path=${save_log}
# 	Decoder Tttirace From Pcap To Csv    ${pacp}    ${save_log}/tti
# 	run keyword and continue on failure    spill_value_of_srsswitchmeas    ${save_log}/tti_dl.csv    ${save_log}/target_dl.csv
# 	# check UE1/2 rt,UE 3/4 DFT
# 	run keyword and continue on failure
# 	...    check_log_with_au2anlysis    ini_path=${CURDIR}/log_check/B4_case02_tti_step4.ini    log_need_to_check=i
#     ...    save_log_directory=${save_log}
#     [Teardown]    Stop Collect GNB and AP Syslog in 'Step4_attach_1ue_non_match_spid' File
# 
# Step5:Override UE1’s rank below threshold
#     Start Collect GNB and AP Syslog in 'Step5_override_rank1' File
#     ${save_log}=    Set Variable    ${TEST_LOG_DIRECTORY()}Step5_override_rank1
#     Start GNB BIP Log
#     airphone_execute_egate_command    ${profile_3}
# 	airphone_execute_egate_command    ${Act_profile_3}
# 	Wait '5s' for stable running
#     Stop Gnb BIP Log    log_dir=${save_log}
# 	Start GNB Ttitrace With Streaming Mode
# 	Wait '3s' for stable running
# 	${pacp}=    Stop GNB Ttitrace With Streaming Mode    save_path=${save_log}
# 	Decoder Tttirace From Pcap To Csv    ${pacp}    ${save_log}/tti
# 	run keyword and continue on failure    spill_value_of_srsswitchmeas    ${save_log}/tti_dl.csv    ${save_log}/target_dl.csv
# 	#
# 	run keyword and continue on failure
# 	...    check_log_with_au2anlysis    ini_path=${CURDIR}/log_check/B4_case02_tti_step5.ini    log_need_to_check=i
#     ...    save_log_directory=${save_log}
#     [Teardown]    Stop Collect GNB and AP Syslog in 'Step5_override_rank1' File
# 
# Step6:Stop buffer for UE3
#     Start Collect GNB and AP Syslog in 'Step6_stop_ue3_buffer' File
#     ${save_log}=    Set Variable    ${TEST_LOG_DIRECTORY()}Step6_stop_ue3_buffer
#     Start GNB BIP Log
#     Airphone Nsa Stop Data Traffic    ue_id=13    direction=dl    bearer_id=2
#     Stop Gnb BIP Log    log_dir=${save_log}
# 	Start GNB Ttitrace With Streaming Mode
# 	Wait '3s' for stable running
# 	${pacp}=    Stop GNB Ttitrace With Streaming Mode    save_path=${save_log}
# 	Decoder Tttirace From Pcap To Csv    ${pacp}    ${save_log}/tti
# 	run keyword and continue on failure    spill_value_of_srsswitchmeas    ${save_log}/tti_dl.csv    ${save_log}/target_dl.csv
# 	run keyword and continue on failure
# 	...    check_log_with_au2anlysis    ini_path=${CURDIR}/log_check/B4_case02_tti_step6.ini    log_need_to_check=i
#     ...    save_log_directory=${save_log}
#     [Teardown]    Stop Collect GNB and AP Syslog in 'Step6_stop_ue3_buffer' File
# 
# Step7:Restart buffer for UE3,Recover UE1’s rank
#     Start Collect GNB and AP Syslog in 'Step7_recover_ue3_buffer_UE1_rank' File
#     ${save_log}=    Set Variable    ${TEST_LOG_DIRECTORY()}Step7_recover_ue3_buffer_UE1_rank
#     Start GNB BIP Log
# 	Airphone NSA Start Data Traffic    13     DL    175M    duration=${7200}    trf_id=1
# 	Airphone NSA Start Data Traffic    13     DL    175M    duration=${7200}    trf_id=2
# 	airphone_execute_egate_command    ${profile_2}
# 	airphone_execute_egate_command    ${Act_profile_2}
# 	Wait '3s' for stable running
#     Stop Gnb BIP Log    log_dir=${save_log}
# 	Start GNB Ttitrace With Streaming Mode
# 	Wait '3s' for stable running
# 	${pacp}=    Stop GNB Ttitrace With Streaming Mode    save_path=${save_log}
# 	Decoder Tttirace From Pcap To Csv    ${pacp}    ${save_log}/tti
# 	run keyword and continue on failure    spill_value_of_srsswitchmeas    ${save_log}/tti_dl.csv    ${save_log}/target_dl.csv
# 	run keyword and continue on failure
# 	...    check_log_with_au2anlysis    ini_path=${CURDIR}/log_check/B4_case02_tti_step7.ini    log_need_to_check=i
#     ...    save_log_directory=${save_log}
#     [Teardown]    Stop Collect GNB and AP Syslog in 'Step7_recover_ue3_buffer_UE1_rank' File
# 
# Step8:Stop UE4’s buffer
#     Start Collect GNB and AP Syslog in 'Step8_stop_ue4_buffer' File
#     ${save_log}=    Set Variable    ${TEST_LOG_DIRECTORY()}Step8_stop_ue4_buffer
#     Start GNB BIP Log
#     Airphone Nsa Stop Data Traffic    ue_id=14    direction=dl    bearer_id=2
#     Stop Gnb BIP Log    log_dir=${save_log}
# 	Start GNB Ttitrace With Streaming Mode
# 	Wait '3s' for stable running
# 	${pacp}=    Stop GNB Ttitrace With Streaming Mode    save_path=${save_log}
# 	Decoder Tttirace From Pcap To Csv    ${pacp}    ${save_log}/tti
# 	run keyword and continue on failure    spill_value_of_srsswitchmeas    ${save_log}/tti_dl.csv    ${save_log}/target_dl.csv
# 	run keyword and continue on failure
# 	...    check_log_with_au2anlysis    ini_path=${CURDIR}/log_check/B4_case02_tti_step8.ini    log_need_to_check=i
#     ...    save_log_directory=${save_log}
#     [Teardown]    Stop Collect GNB and AP Syslog in 'Step8_stop_ue4_buffer' File
