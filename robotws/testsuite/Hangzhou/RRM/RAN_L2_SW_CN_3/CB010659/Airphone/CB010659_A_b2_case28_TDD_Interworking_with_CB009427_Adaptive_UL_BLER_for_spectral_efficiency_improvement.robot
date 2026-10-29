# *** Settings ***
# Documentation     Author: xuemin.mae@nokia-sbell.com
# ...
# ...               QC case full name:
# ...               CB010659_A_b2_case28_TDD_Interworking_with_CB009427_Adaptive_UL_BLER_for_spectral_efficiency_improvement
# 
# 
# Suite Setup       Common Suite Setup
# Suite Teardown    Common Suite Teardown
# Test Setup        Common Test Setup
# Test Teardown     Common Test Teardown
# Force Tags        CLOUD_5G_I_LL_AP_LO_SANSA_L1B_ECPRI_CMWV_TDD    AP    CRT    SBTS00    RAN_5G_TDD    RAN_5G    owner_xueminm
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
# ${gnb_swconfig}    gNB_swconfig_LL_AP_LO_TDD_eCPRI_cmwv_SANSA_FS_2S_1CC.txt
# ${SCFC_NAME}      gNB_scf_ASIL_ABIL_TDD_eCPRI_cmwv_SANSA_FS_2S_1CC.xml
# ${AIRPHONE_NAME}    AP_iphy_AEQE_ASIL_ABIO_TDD_eCPRI_cmwv_SANSA_FS_2S_1CC.xml
# ${WTS_NAME}       wts_config_ASIL_ABIO_TDD_eCPRI_cmwv_SANSA_FS_2S_1CC.cfg
# @{LOG_NAME_LIST}    gnb_snapshot    egatelog\
# ${cellDepType}                             text|SA+NSA|//*[@name\="cellDepType"]
# ${chBw}                                    text|100MHz|//*[@name\="chBw"]
# ${dlMimoMode}                              text|2x2 Closed Loop Spatial Multiplexing|//*[@name\="dlMimoMode"]
# ${ulMimoMode}                              text|Closed loop Spatial Multiplexing (2x2)|//*[@name\="ulMimoMode"]
# ${actDl256Qam}                             text|false|//*[@name\="actDl256Qam"]
# ${actUl256Qam}                             text|false|//*[@name\="actUl256Qam"]
# ${frameStructureType}                      text|tdLte|//*[@name\="frameStructureType"]
# ${guardPeriodLength}                       text|6Symbols|//*[@name\="guardPeriodLength"]
# ${lteToNrFrameShift}                       text|3ms|//*[@name\="lteToNrFrameShift"]
# ${tdLteUlDlConfig}                         text|tdLteConfig2|//*[@name\="tdLteUlDlConfig"]
# ${ulDlDataSlotRatio}                       text|3/7|//*[@name\="ulDlDataSlotRatio"]
# ${prachConfigurationIndex}                 text|98|//*[@name\="prachConfigurationIndex"]
# ${actAdaptiveReTxResMcs}                   text|true|//*[@name\="actAdaptiveReTxResMcs"]
# ${actAdaptiveReTxResMcsEnh}                text|true|//*[@name\="actAdaptiveReTxResMcsEnh"]
# ${minPctResourceReservedMcsDl}             text|50|//*[@name\="minPctResourceReservedMcsDl"]
# ${targetPctResourceReservedMcsDl}          text|100|//*[@name\="targetPctResourceReservedMcsDl"]
# ${minPctResourceReservedMcsUl}             text|50|//*[@name\="minPctResourceReservedMcsUl"]
# ${targetPctResourceReservedMcsUl}          text|100|//*[@name\="targetPctResourceReservedMcsUl"]
# ${ullaDeltaSinrMax}                        text|150|//*[@name\="ullaDeltaSinrMax"]
# ${ullaDeltaSinrMin}                        text|-300|//*[@name\="ullaDeltaSinrMin"]
# ${maxUlHarqTx}                             text|4|//*[@name\="maxUlHarqTx"]
# ${actAdaptiveUlBlerTarget}                 text|true|//*[@name\="actAdaptiveUlBlerTarget"]
# ${ullaBlerTargetSinrThreshold}             text|100|//*[@name\="ullaBlerTargetSinrThreshold"]
# ${ullaBlerTargetLowSinr}                   text|20|//*[@name\="ullaBlerTargetLowSinr"]
# ${ullaBlerTargetMcs0}                      text|10|//*[@name\="ullaBlerTargetMcs0"]
# ${bwp_profile87}                           attrib\=distName|replace('BWP_PROFILE-44', 'BWP_PROFILE-87')|//managedObject
# ${bwp_profile87_p}                         text|replace('BWP_PROFILE-44', 'BWP_PROFILE-87')|//p
# ${bwp_profile8}                            attrib\=distName|replace('BWP_PROFILE-0', 'BWP_PROFILE-8')|//managedObject
# ${bwp_profile8_p}                          text|replace('BWP_PROFILE-0', 'BWP_PROFILE-8')|//p
# ${bwp_duration1}                           text|7|//*[contains(@distName, 'BWP_PROFILE-8')]//item[1]/*[@name\='duration']
# ${bwp_duration3}                           text|7|//*[contains(@distName, 'BWP_PROFILE-8')]//item[3]/*[@name\='duration']
# ${bwp_duration_dedi}                       text|1|//*[contains(@distName, 'BWP_PROFILE-87/PDCCH-1/PDCCH_CONFIG_DEDICATED-1')]//*[@name\='duration']
# ${nPdcchCandidatesInAL16}                  text|n0|//*[contains(@distName, 'BWP_PROFILE-8')]//*[@name\="numOfPdcchCandidatesInAL16"]
# ${nPdcchCandidatesInAL4_1}                 text|n2|//*[contains(@distName, 'BWP_PROFILE-8')]//item[1]/*[@name\="numOfPdcchCandidatesInAL4"]
# ${nPdcchCandidatesInAL4_3}                 text|n2|//*[contains(@distName, 'BWP_PROFILE-8')]//item[3]/*[@name\="numOfPdcchCandidatesInAL4"]
# ${nPdcchCandidatesInAL4_2}
# ...    text|n4|//*[contains(@distName, 'BWP_PROFILE-87/PDCCH-1/PDCCH_CONFIG_COMMON-1')]//item[2]/*[@name\="numOfPdcchCandidatesInAL4"]
# ${nPdcchCandidatesInAL8}                   text|n0|//*[contains(@distName, 'BWP_PROFILE-8')]//*[@name\="numOfPdcchCandidatesInAL8"]
# ${nPdcchCandidatesInAL2_2}                 text|n0|//*[contains(@distName, 'BWP_PROFILE-8')]//item[2]/*[@name\="numOfPdcchCandidatesInAL2"]
# ${bwp_periodicity_1}                       text|sl10|//*[contains(@distName, 'BWP_PROFILE-8')]//item[1]/*[@name\='periodicity']
# ${bwp_periodicity_3}                       text|sl10|//*[contains(@distName, 'BWP_PROFILE-8')]//item[3]/*[@name\='periodicity']
# ${periodicity_dedi}                        text|sl1|//*[contains(@name, 'searchSpaceDedicated')]//item[1]/*[@name\='periodicity']
# ${tReorderingDl}                       text|ms300|//*[@name\="tReorderingDl"]
# ${tReorderingUl}                       text|ms300|//*[@name\="tReorderingUl"]
# @{Rdparameter}       0x9D0000:3
# ${ul_sinr_testmode_0}    ul_cell_noise_testmode_nr profile_id\=1 noise_pusch\=-490
# ${ul_sinr_testmode_1}    ul_cell_noise_testmode_nr profile_id\=1 noise_pusch\=-450
# ${ul_sinr_testmode_2}    ul_cell_noise_testmode_nr profile_id\=1 noise_pusch\=-390
# 
# *** Test Cases ***
# CB010659_A_b2_case28_TDD_Interworking_with_CB009427_Adaptive_UL_BLER_for_spectral_efficiency_improvement
#     Step1:Commission the above configuration on WebUI
#     Step2:Attach UE1
#     Step3:Enable UL BLER test mode to trigger all retransmissions
# 
# *** Keywords ***
# Step1:Commission the above configuration on WebUI
#     Start Collect GNB and AP Syslog in 'Step1_before_onair' File
# 	${CONFIG_DIR_PATH}    Set Variable    ${CONFIG_DIR_PATH}/${SW_BRANCH}
#     change_iphy_rru_version    ${CONFIG_DIR_PATH}${/}${AIRPHONE_NAME}
#     modify_swconfig_by_CB010659    ${CONFIG_DIR_PATH}${/}${SCFC_NAME}	@{Rdparameter}
#     ${scfc_path}    Set Variable    ${TEST_LOG_DIRECTORY()}${/}scfc.xml
#     copy_file    ${CONFIG_DIR_PATH}/${SCFC_NAME}    ${scfc_path}
#     add_xml_element     ${scfc_path}    ${scfc_path}     <p name="lteToNrFrameShift">3ms</p>|//*[@name\='tddFrameStructure']/item
#     add_xml_element     ${scfc_path}    ${scfc_path}     <p name="tdLteUlDlConfig">tdLteConfig2</p>|//*[@name\='tddFrameStructure']/item
#     ${modify_list}    create list
#     ...       ${cellDepType}    ${chBw}    ${dlMimoMode}    ${ulMimoMode}    ${actDl256Qam}    ${actUl256Qam}
#     ...       ${frameStructureType}    ${guardPeriodLength}    ${lteToNrFrameShift}    ${tdLteUlDlConfig}    ${prachConfigurationIndex}
#     ...       ${actAdaptiveReTxResMcsEnh}    ${minPctResourceReservedMcsDl}    ${targetPctResourceReservedMcsDl}    ${minPctResourceReservedMcsUl}
#     ...       ${targetPctResourceReservedMcsUl}    ${ullaDeltaSinrMax}    ${ullaDeltaSinrMin}     ${actAdaptiveReTxResMcs}
# 	...       ${maxUlHarqTx}
# 	#...       ${actAdaptiveUlBlerTarget}
#     #...       ${ullaBlerTargetSinrThreshold}    ${ullaBlerTargetLowSinr}    ${ullaBlerTargetMcs0}
# 	...       ${bwp_profile87}    ${bwp_profile87_p}    ${bwp_profile8}    ${bwp_profile8_p}
#     ...       ${bwp_duration1}    ${bwp_duration3}    ${nPdcchCandidatesInAL16}    ${nPdcchCandidatesInAL4_1}    ${nPdcchCandidatesInAL4_3}
#     ...       ${nPdcchCandidatesInAL4_2}    ${nPdcchCandidatesInAL8}    ${nPdcchCandidatesInAL2_2}    ${bwp_periodicity_1}
#     ...       ${bwp_periodicity_3}    ${bwp_duration_dedi}    ${periodicity_dedi}    ${tReorderingDl}    ${tReorderingUl}
#     modify_xml    ${scfc_path}    ${scfc_path}    ${modify_list}
#     Modify TL VM And AP SCTP Configuration
#     Get and Update BSR File
#     Perform Full Commission And Reach Onair    ${scfc_path}    ${CONFIG_DIR_PATH}${/}${WTS_NAME}    reset_after_commission=${False}
#     [Teardown]    Stop Collect GNB and AP Syslog in 'Step1_before_onair' File
# 
# modify_swconfig_by_CB010659
#     [Arguments]    ${gnb_swconfig_PATH}    @{Rdparameter}
#     setup_txt    src_file=${CONFIG_DIR_PATH}/${SW_BRANCH}/${gnb_swconfig}    save_path=${TEST_LOG_DIRECTORY()}${/}swconfig_gnb_ini.txt
#     :FOR    ${parameter}    IN    @{Rdparameter}
#     \    ${key}    ${value}    Split String    ${parameter}    :
#     \    run keyword and ignore error    delete txt node    ${key}
#     \    add txt node    ${parameter}
#     teardown_txt
#     GNB Upload Swconfig           ${TEST_LOG_DIRECTORY()}${/}swconfig_gnb_ini.txt
# 
# Step2:Attach UE1
#     Start Collect GNB and AP Syslog in 'Step2_attach' File
#     Start GNB BIP Log
#     airphone_sa_attach    ue_id=1
#     airphone_set_traffic_type    ue_id=1    pdu_id=1
#     airphone_pdu_session_setup    ue_id=1    pdu_id=1
#     Wait '5s' for stable running
#     Airphone SA Start Data Traffic    ue_id=1    direction=ul    throughput=140M    trf_id=1    pdu_id=1    duration=3600s
#     Airphone SA Start Data Traffic    ue_id=1    direction=dl    throughput=150M    trf_id=1    pdu_id=1    duration=3600s
#     Wait Throughput Timer    5
#     ${Dl_throughput} =    Airphone Sa Get Throughput    ue_id=1    direction=dl
#     ${Ul_throughput} =    Airphone Sa Get Throughput    ue_id=1    direction=ul
#     Stop Gnb BIP Log    log_dir=${TEST_LOG_DIRECTORY()}${/}Step2_attach${/}
#     ${save_log}=    Set Variable    ${TEST_LOG_DIRECTORY()}Step2_attach
#     Start GNB Ttitrace With Streaming Mode
#     Wait '5s' for stable running
#     ${pacp}=    Stop GNB Ttitrace With Streaming Mode    save_path=${save_log}
#     Decoder Tttirace From Pcap To Csv    ${pacp}    ${save_log}/tti
#     [Teardown]    Stop Collect GNB and AP Syslog in 'Step2_attach' File
# 
# Step3:Enable UL BLER test mode to trigger all retransmissions
#     Start Collect GNB and AP Syslog in 'Step3_retrans' File
#     Start GNB BIP Log
#     ${save_log}=    Set Variable    ${TEST_LOG_DIRECTORY()}Step3_retrans
#     Start GNB Ttitrace With Streaming Mode
#     airphone_execute_egate_command	${ul_sinr_testmode_0}
#     airphone_execute_egate_command	cell_testmode_set_nr cell_id\=1 gnb\=1 testmode\=ul_cell_noise profile_id\=1 action\=activate
#     Wait '4s' for stable running
#     airphone_execute_egate_command	cell_testmode_set_nr cell_id\=1 gnb\=1 testmode\=ul_cell_noise profile_id\=1 action\=deactivate
#     Wait '4s' for stable running
#     airphone_execute_egate_command	${ul_sinr_testmode_1}
#     airphone_execute_egate_command	cell_testmode_set_nr cell_id\=1 gnb\=1 testmode\=ul_cell_noise profile_id\=1 action\=activate
#     Wait '4s' for stable running
#     airphone_execute_egate_command	cell_testmode_set_nr cell_id\=1 gnb\=1 testmode\=ul_cell_noise profile_id\=1 action\=deactivate
#     Wait '4s' for stable running
#     airphone_execute_egate_command	${ul_sinr_testmode_2}
#     airphone_execute_egate_command	cell_testmode_set_nr cell_id\=1 gnb\=1 testmode\=ul_cell_noise profile_id\=1 action\=activate
#     Wait '4s' for stable running
#     airphone_execute_egate_command	cell_testmode_set_nr cell_id\=1 gnb\=1 testmode\=ul_cell_noise profile_id\=1 action\=deactivate
#     Wait '4s' for stable running
#     ${pacp}=    Stop GNB Ttitrace With Streaming Mode    save_path=${save_log}
#     Decoder Tttirace From Pcap To Csv    ${pacp}    ${save_log}/tti_re_9427
#     #check DeltaSinr skip when reserved mcs used
#     #check_log_with_au2anlysis    ini_path=${CURDIR}/log_check/case28_tti.ini    log_need_to_check=i
#     #...    save_log_directory=${TEST_LOG_DIRECTORY()}${/}Step3_retrans${/}
# 	check_not_delta_sinr_calculated    ${save_log}${/}tti_re_9427_ul.csv   
#     #check not all nok when adaptRetx applied
#     check_log_with_au2anlysis    ini_path=${CURDIR}/log_check/case28_tti_ok.ini    log_need_to_check=i
#     ...    save_log_directory=${TEST_LOG_DIRECTORY()}${/}Step3_retrans${/}
# 	Stop Gnb BIP Log    log_dir=${TEST_LOG_DIRECTORY()}${/}Step3_retrans${/}
#     [Teardown]    Stop Collect GNB and AP Syslog in 'Step3_retrans' File
