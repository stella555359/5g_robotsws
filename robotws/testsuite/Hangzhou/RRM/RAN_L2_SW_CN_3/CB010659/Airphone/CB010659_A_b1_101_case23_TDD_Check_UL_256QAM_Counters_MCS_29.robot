# *** Settings ***
# Documentation     Author: xuemin.mae@nokia-sbell.com
# ...
# ...               QC case full name:
# ...               CB010659_A_b1_101_case23_TDD_Check_UL_256QAM_Counters_MCS_29
# ...               initial mcs is restrict to 5 by 0x580367:0x20
# ...               data traffice is not full for retransmission using initail mcs
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
# ${chBw}                                    text|70 MHz|//*[@name\="chBw"]
# ${dlMimoMode}                              text|2x2 Closed Loop Spatial Multiplexing|//*[@name\="dlMimoMode"]
# ${ulMimoMode}                              text|Closed loop Spatial Multiplexing (2x2)|//*[@name\="ulMimoMode"]
# ${actDl256Qam}                             text|false|//*[@name\="actDl256Qam"]
# ${actUl256Qam}                             text|true|//*[@name\="actUl256Qam"]
# ${frameStructureType}                      text|tdLte|//*[@name\="frameStructureType"]
# ${guardPeriodLength}                       text|6Symbols|//*[@name\="guardPeriodLength"]
# ${lteToNrFrameShift}                       text|3ms|//*[@name\="lteToNrFrameShift"]
# ${tdLteUlDlConfig}                         text|tdLteConfig2|//*[@name\="tdLteUlDlConfig"]
# ${ulDlDataSlotRatio}                       text|3/7|//*[@name\="ulDlDataSlotRatio"]
# ${prachConfigurationIndex}                 text|98|//*[@name\="prachConfigurationIndex"]
# ${actAdaptiveReTxResMcs}                   text|true|//*[@name\="actAdaptiveReTxResMcs"]
# ${actAdaptiveReTxResMcsEnh}                text|true|//*[@name\="actAdaptiveReTxResMcsEnh"]
# ${minPctResourceReservedMcsDl}             text|50|//*[@name\="minPctResourceReservedMcsDl"]
# ${targetPctResourceReservedMcsDl}          text|75|//*[@name\="targetPctResourceReservedMcsDl"]
# ${minPctResourceReservedMcsUl}             text|50|//*[@name\="minPctResourceReservedMcsUl"]
# ${targetPctResourceReservedMcsUl}          text|75|//*[@name\="targetPctResourceReservedMcsUl"]
# ${ullaDeltaSinrMax}                        text|0|//*[@name\="ullaDeltaSinrMax"]
# ${ullaDeltaSinrMin}                        text|0|//*[@name\="ullaDeltaSinrMin"]
# ${maxUlHarqTx}                             text|4|//*[@name\="maxUlHarqTx"]
# ${bwp_profile84}                           attrib\=distName|replace('BWP_PROFILE-44', 'BWP_PROFILE-84')|//managedObject
# ${bwp_profile84_p}                         text|replace('BWP_PROFILE-44', 'BWP_PROFILE-84')|//p
# ${bwp_profile8}                            attrib\=distName|replace('BWP_PROFILE-0', 'BWP_PROFILE-8')|//managedObject
# ${bwp_profile8_p}                          text|replace('BWP_PROFILE-0', 'BWP_PROFILE-8')|//p
# ${bwp_duration1}                           text|7|//*[contains(@distName, 'BWP_PROFILE-8')]//item[1]/*[@name\='duration']
# ${bwp_duration3}                           text|7|//*[contains(@distName, 'BWP_PROFILE-8')]//item[3]/*[@name\='duration']
# ${bwp_duration_dedi}                       text|1|//*[contains(@distName, 'BWP_PROFILE-84/PDCCH-1/PDCCH_CONFIG_DEDICATED-1')]//*[@name\='duration']
# ${nPdcchCandidatesInAL16}                  text|n0|//*[contains(@distName, 'BWP_PROFILE-8')]//*[@name\="numOfPdcchCandidatesInAL16"]
# ${nPdcchCandidatesInAL4_1}                 text|n2|//*[contains(@distName, 'BWP_PROFILE-8')]//item[1]/*[@name\="numOfPdcchCandidatesInAL4"]
# ${nPdcchCandidatesInAL4_3}                 text|n2|//*[contains(@distName, 'BWP_PROFILE-8')]//item[3]/*[@name\="numOfPdcchCandidatesInAL4"]
# ${nPdcchCandidatesInAL4_2}
# ...    text|n2|//*[contains(@distName, 'BWP_PROFILE-84/PDCCH-1/PDCCH_CONFIG_COMMON-1')]//item[2]/*[@name\="numOfPdcchCandidatesInAL4"]
# ${nPdcchCandidatesInAL8}                   text|n0|//*[contains(@distName, 'BWP_PROFILE-8')]//*[@name\="numOfPdcchCandidatesInAL8"]
# ${nPdcchCandidatesInAL2_2}                 text|n0|//*[contains(@distName, 'BWP_PROFILE-8')]//item[2]/*[@name\="numOfPdcchCandidatesInAL2"]
# ${bwp_periodicity_1}                       text|sl10|//*[contains(@distName, 'BWP_PROFILE-8')]//item[1]/*[@name\='periodicity']
# ${bwp_periodicity_3}                       text|sl10|//*[contains(@distName, 'BWP_PROFILE-8')]//item[3]/*[@name\='periodicity']
# ${periodicity_dedi}                        text|sl1|//*[contains(@name, 'searchSpaceDedicated')]//item[1]/*[@name\='periodicity']
# @{Rdparameter}       0x9D0000:3    0x580367:0x20
# ${ul_sinr_testmode_0}    ul_cell_noise_testmode_nr profile_id\=1 noise_pusch\=-370
# ${ul_sinr_testmode_1}    ul_cell_noise_testmode_nr profile_id\=1 noise_pusch\=-360
# 
# *** Test Cases ***
# CB010659_A_b1_101_case23_TDD_Check_UL_256QAM_Counters_MCS_29
#     Step1:Commission the above configuration on WebUI
#     Step2:Attach UE1
#     Step3:Trigger UL_HARQ_Retrans
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
# 	...       ${bwp_profile84}    ${bwp_profile84_p}    ${bwp_profile8}    ${bwp_profile8_p}    ${bwp_duration1}    ${bwp_duration3}
# 	...       ${bwp_duration_dedi}    ${nPdcchCandidatesInAL16}    ${nPdcchCandidatesInAL4_1}    ${nPdcchCandidatesInAL4_3}
# 	...       ${nPdcchCandidatesInAL4_2}    ${nPdcchCandidatesInAL8}    ${nPdcchCandidatesInAL2_2}    ${bwp_periodicity_1}
# 	...       ${bwp_periodicity_3}    ${periodicity_dedi}
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
#     airphone_execute_egate_command    set_pdu_param ue\=1 pdu\=1 trf_type\=internal
#     airphone_pdu_session_setup    ue_id=1    pdu_id=1
#     Wait '5s' for stable running
#     Airphone SA Start Data Traffic    ue_id=1    direction=ul    throughput=70M    trf_id=1    pdu_id=1    duration=3600s
#     Wait Throughput Timer    5
#     Stop Gnb BIP Log    log_dir=${TEST_LOG_DIRECTORY()}${/}Step2_attach${/}
#     ${save_log}=    Set Variable    ${TEST_LOG_DIRECTORY()}Step2_attach
#     Start GNB Ttitrace With Streaming Mode
#     Wait '5s' for stable running
#     ${pacp}=    Stop GNB Ttitrace With Streaming Mode    save_path=${save_log}
#     Decoder Tttirace From Pcap To Csv    ${pacp}    ${save_log}/tti
#     [Teardown]    Stop Collect GNB and AP Syslog in 'Step2_attach' File
# 
# Step3:Trigger UL_HARQ_Retrans
#     Start Collect GNB and AP Syslog in 'Step3_retrans' File
#     Start GNB BIP Log
#     ${remaining_time}=    get_counter_file_remaining_time    counter_refresh_period=5min
#     Wait Throughput Timer    ${remaining_time}
#     ${save_log}=    Set Variable    ${TEST_LOG_DIRECTORY()}Step3_retrans
#     Start GNB Ttitrace With Streaming Mode
#     airphone_execute_egate_command	${ul_sinr_testmode_0}
#     airphone_execute_egate_command	cell_testmode_set_nr cell_id\=1 gnb\=1 testmode\=ul_cell_noise profile_id\=1 action\=activate
#     Wait '5s' for stable running
#     airphone_execute_egate_command	cell_testmode_set_nr cell_id\=1 gnb\=1 testmode\=ul_cell_noise profile_id\=1 action\=deactivate
#     Wait '5s' for stable running
#     airphone_execute_egate_command	${ul_sinr_testmode_1}
#     airphone_execute_egate_command	cell_testmode_set_nr cell_id\=1 gnb\=1 testmode\=ul_cell_noise profile_id\=1 action\=activate
#     Wait '5s' for stable running
#     airphone_execute_egate_command	cell_testmode_set_nr cell_id\=1 gnb\=1 testmode\=ul_cell_noise profile_id\=1 action\=deactivate
#     Wait '5s' for stable running
#     ${pacp}=    Stop GNB Ttitrace With Streaming Mode    save_path=${save_log}
# 
#     ${remaining_time}=    get_counter_file_remaining_time    counter_refresh_period=5min
#     Wait Throughput Timer    ${remaining_time}
#     ${PM_counter_file}=    download_latest_pmcounter    local_path=${TEST_LOG_DIRECTORY()}Step3_retrans${/}
# 
# 	${PM_M55302C14029}=    get_counter_value_from_counter_file    counter_file=${PM_counter_file}
# 	...    counter_id=M55302C14029    cell_id=1
# 	${PM_M55302C12029}=    get_counter_value_from_counter_file    counter_file=${PM_counter_file}
# 	...    counter_id=M55302C12029    cell_id=1
# 	${PM_M55303C23029}=    get_counter_value_from_counter_file    counter_file=${PM_counter_file}
# 	...    counter_id=M55303C23029    cell_id=1
# 	${PM_M55304C10029}=    get_counter_value_from_counter_file    counter_file=${PM_counter_file}
# 	...    counter_id=M55304C10029    cell_id=1
# 	${PM_M55302C14005}=    get_counter_value_from_counter_file    counter_file=${PM_counter_file}
# 	...    counter_id=M55302C14005    cell_id=1
# 	${PM_M55302C12005}=    get_counter_value_from_counter_file    counter_file=${PM_counter_file}
# 	...    counter_id=M55302C12005    cell_id=1
# 	${PM_M55303C23005}=    get_counter_value_from_counter_file    counter_file=${PM_counter_file}
# 	...    counter_id=M55303C23005    cell_id=1
# 	${PM_M55304C10005}=    get_counter_value_from_counter_file    counter_file=${PM_counter_file}
# 	...    counter_id=M55304C10005    cell_id=1
#     Decoder Tttirace From Pcap To Csv    ${pacp}    ${save_log}/tti_re
# 
# #    Get ttitrace value
#     ${tti_mcs29_success}    read csv columns     ${save_log}/tti_re_ul.csv    ulFdSchedData.redundancyVersion
#     ...        filter=((ulHarqRxData.crcResult=OK)&(ulFdSchedData.rrmUlUsedMcs=29))
#     ${tti_M55302C14029}     Evaluate    len(${tti_mcs29_success})
#     ${tti_mcs29_unsuccess_last_reTx}    read csv columns     ${save_log}/tti_re_ul.csv    ulFdSchedData.redundancyVersion
#     ...        filter=((ulHarqRxData.crcResult=NOK)&(ulFdSchedData.rrmUlUsedMcs=29)&(ulFdSchedData.txNumber=4))
#     ${tti_M55302C12029}     Evaluate    len(${tti_mcs29_unsuccess_last_reTx})
#     ${tti_mcs29_rank2}    read csv columns     ${save_log}/tti_re_ul.csv    ulFdSchedData.redundancyVersion
#     ...        filter=((ulFdSchedData.rrmUlUsedMcs=29)&(ulFdSchedData.numOfLayers=RANK2))
#     ${tti_M55303C23029}     Evaluate    len(${tti_mcs29_rank2})
#     ${tti_mcs29_tbsize}    read csv columns     ${save_log}/tti_re_ul.csv    ulFdSchedData.tbSize
#     ...        filter=ulFdSchedData.rrmUlUsedMcs=29    calculator=sum
#     ${tti_M55304C10029}     Evaluate    int(float(${tti_mcs29_tbsize})/8)
# 
# #    Check PM counter value and ttitrace value
#     should be true    ${PM_M55302C14029}==${tti_M55302C14029}
#     should be true    ${PM_M55302C12029}==${tti_M55302C12029}
#     should be true    ${PM_M55303C23029}==${tti_M55303C23029}
#     should be true    ${PM_M55304C10029}==${tti_M55304C10029}
# 
# #    Check AdaptiveReTxResMcs works
# 	${tti_mcs29_crc_ok}    read csv columns     ${TEST_LOG_DIRECTORY()}Step3_retrans/tti_re_ul.csv    ulHarqRxData.crcResult
#     ...        filter=((ulHarqRxData.crcResult=OK)&(ulFdSchedData.rrmUlUsedMcs=29))
# 	${ttiCount_tti_mcs29_crc_ok}     Evaluate    len(${tti_mcs29_crc_ok})
# 	should be true   ${ttiCount_tti_mcs29_crc_ok} > 0
# 	Stop Gnb BIP Log    log_dir=${TEST_LOG_DIRECTORY()}${/}Step3_retrans${/}
#     [Teardown]    Stop Collect GNB and AP Syslog in 'Step3_retrans' File
