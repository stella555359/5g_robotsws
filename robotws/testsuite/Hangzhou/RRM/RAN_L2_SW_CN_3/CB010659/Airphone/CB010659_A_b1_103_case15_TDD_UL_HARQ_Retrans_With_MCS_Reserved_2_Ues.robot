# *** Settings ***
# Documentation     Author: zhaona.jiang@nokia-sbell.com
# ...
# ...               QC case full name:
# ...               CB010659_A_b1_103_case15_TDD_UL_HARQ_Retrans_With_MCS_Reserved_2_Ues
# ...               DESCRIPTION:
# ...               This test aims at checking gNB behavior when 2 UEs are receiving UL traffic and retransmission with reserved MCS occurs.
# 
# Suite Setup       Common Suite Setup
# Suite Teardown    Common Suite Teardown
# Test Setup        Common Test Setup
# Test Teardown     Common Test Teardown
# Force Tags        CLOUD_5G_I_LL_AP_LO_SANSA_L1B_ECPRI_CMWV_TDD    AP    CRT    SBTS00    RAN_5G_TDD    RAN_5G    owner_zhajiang
# Test Timeout      150 minutes
# Resource          ../../resources/sg11/internal_resource/robot/modify_configuration.robot
# Resource          ../../resources/sg11/internal_resource/robot/internal_ap_operate.robot
# Resource          ../../resources/sg11/internal_resource/robot/internal_gnb_operate.robot
# Resource          ../../resources/sg11/internal_resource/robot/internal_capture_log.robot
# 
# *** Variables ***
# ${CONFIG_DIR_PATH}       ${CURDIR}/../../resources/sg11/internal_resource/config/
# ${gnb_swcfg_src_file}    gNB_swconfig_LL_AP_LO_TDD_eCPRI_cmwv_SANSA_FS_2S_1CC.txt
# &{rad_para_dict}         0x9D0000=15    0x580367=0x10000
# 
# ${SCFC_NAME}             gNB_scf_ASIL_ABIL_TDD_eCPRI_cmwv_SANSA_FS_2S_1CC.xml
# ${AIRPHONE_NAME}         AP_iphy_AEQE_ASIL_ABIO_TDD_eCPRI_cmwv_SANSA_FS_2S_1CC.xml
# ${WTS_NAME}              wts_config_ASIL_ABIO_TDD_eCPRI_cmwv_SANSA_FS_2S_1CC.cfg
# ${COMAVALUE}             ${CURDIR}/../../resources/sg11/internal_resource/config/AP/ap_coma.txt
# @{LOG_NAME_LIST}         gnb_snapshot    sosreport    egatelog\
# 
# ${actAdaptiveReTxResMcs}                   text|true|//*[@name\="actAdaptiveReTxResMcs"]
# ${actAdaptiveReTxResMcsEnh}                text|true|//*[@name\="actAdaptiveReTxResMcsEnh"]
# ${minPctResourceReservedMcsDl}             text|50|//*[@name\="minPctResourceReservedMcsDl"]
# ${targetPctResourceReservedMcsDl}          text|75|//*[@name\="targetPctResourceReservedMcsDl"]
# ${minPctResourceReservedMcsUl}             text|50|//*[@name\="minPctResourceReservedMcsUl"]
# ${targetPctResourceReservedMcsUl}          text|75|//*[@name\="targetPctResourceReservedMcsUl"]
# ${maxUlHarqTx}                             text|4|//*[@name\="maxUlHarqTx"]
# ${ullaDeltaSinrMin}              text|0|//*[@name\="ullaDeltaSinrMin"]
# ${ullaDeltaSinrMax}              text|0|//*[@name\="ullaDeltaSinrMax"]
# ${dllaDeltaCqiMax}               text|0|//*[@name\="dllaDeltaCqiMax"]
# ${dllaDeltaCqiMin}               text|0|//*[@name\="dllaDeltaCqiMin"]
# 
# ${cellDepType}                   text|SA+NSA|//*[@name\="cellDepType"]
# ${chBw}                          text|100MHz|//*[@name\="chBw"]
# ${dlMimoMode}                    text|2x2 Closed Loop Spatial Multiplexing|//*[@name\="dlMimoMode"]
# ${ulMimoMode}                    text|Closed loop Spatial Multiplexing (2x2)|//*[@name\="ulMimoMode"]
# ${actUl256Qam}                   text|true|//*[@name\="actUl256Qam"]
# ${frameStructureType}            text|tdLte|//*[@name\="frameStructureType"]
# ${prachConfigurationIndex}       text|97|//*[@name\="prachConfigurationIndex"]
# ${ulDlDataSlotRatio}             text|1/4|//*[@name\="ulDlDataSlotRatio"]
# ${guardPeriodLength}             text|6Symbols|//*[@name\="guardPeriodLength"]
# 
# ${bwp_duration0_1}               text|9|//*[contains(@distName, 'BWP_PROFILE-0')]//item[1]/*[@name\='duration']
# ${bwp_duration0_3}               text|9|//*[contains(@distName, 'BWP_PROFILE-0')]//item[3]/*[@name\='duration']
# ${bwp_periodicity0_1}            text|sl10|//*[contains(@distName, 'BWP_PROFILE-0')]//item[1]/*[@name\='periodicity']
# ${bwp_periodicity0_3}            text|sl10|//*[contains(@distName, 'BWP_PROFILE-0')]//item[3]/*[@name\='periodicity']
# ${bwp_slotOffset0_1}             text|4|//*[contains(@distName, 'BWP_PROFILE-0')]//item[1]/*[@name\='slotOffset']
# ${bwp_slotOffset0_3}             text|4|//*[contains(@distName, 'BWP_PROFILE-0')]//item[3]/*[@name\='slotOffset']
# ${bwp_duration44_1}              text|9|//*[contains(@distName, 'BWP_PROFILE-44')]//item[1]/*[@name\='duration']
# ${bwp_duration44_3}              text|9|//*[contains(@distName, 'BWP_PROFILE-44')]//item[3]/*[@name\='duration']
# ${bwp_periodicity44_1}           text|sl10|//*[contains(@distName, 'BWP_PROFILE-44')]//item[1]/*[@name\='periodicity']
# ${bwp_periodicity44_3}           text|sl10|//*[contains(@distName, 'BWP_PROFILE-44')]//item[3]/*[@name\='periodicity']
# ${bwp_slotOffset44_1}            text|4|//*[contains(@distName, 'BWP_PROFILE-44')]//item[1]/*[@name\='slotOffset']
# ${bwp_slotOffset44_3}            text|4|//*[contains(@distName, 'BWP_PROFILE-44')]//item[3]/*[@name\='slotOffset']
# ${dutation_dedi1}                text|1|//*[contains(@name, 'coresetDedicated')]//item[1]/*[@name\='duration']
# ${dutation_dedi2}                text|1|//*[contains(@name, 'searchSpaceDedicated')]//item[1]/*[@name\='duration']
# ${periodicity_dedi}              text|sl1|//*[contains(@name, 'searchSpaceDedicated')]//item[1]/*[@name\='periodicity']
# ${slotOffset_dedi}               text|0|//*[contains(@name, 'searchSpaceDedicated')]//item[1]/*[@name\='slotOffset']
# ${ue1}                           1
# ${ue2}                           2
# ${scell}                         0
# ${pattern}                       CA_P2_8x4_t2r4_n2
# 
# *** Test Cases ***
# CB010659_A_b1_103_case15_TDD_UL_HARQ_Retrans_With_MCS_Reserved_2_Ues
#     Step1:Commission configuration on WebUI
#     Step2:Attach UEs and send UL buffer
#     Step3:Trigger UL_HARQ_Retrans
#     Step4:Last for 1 hour check stability
#     Step5:Detach ues
# 
# *** Keywords ***
# Step1:Commission configuration on WebUI
#     Start Collect GNB and AP Syslog in 'Step1_before_onair' File
# 	${CONFIG_DIR_PATH}    Set Variable    ${CONFIG_DIR_PATH}/${SW_BRANCH}
#     change_iphy_rru_version    ${CONFIG_DIR_PATH}${/}${AIRPHONE_NAME}
#     modify_gnb_swconfig_by_10659    ${CONFIG_DIR_PATH}${/}${gnb_swcfg_src_file}    ${rad_para_dict}
#     ${scfc_path}    Set Variable    ${TEST_LOG_DIRECTORY()}${/}scfc.xml
#     copy_file    ${CONFIG_DIR_PATH}/${SCFC_NAME}    ${scfc_path}
#     add_xml_element     ${scfc_path}    ${scfc_path}     <p name="lteToNrFrameShift">0ms</p>|//*[@name\='tddFrameStructure']/item
#     add_xml_element     ${scfc_path}    ${scfc_path}     <p name="tdLteUlDlConfig">tdLteConfig2</p>|//*[@name\='tddFrameStructure']/item
#     ${modify_list}    create list
#     ...         ${actAdaptiveReTxResMcs}    ${actAdaptiveReTxResMcsEnh}    ${minPctResourceReservedMcsDl}    ${targetPctResourceReservedMcsDl}
#     ...         ${minPctResourceReservedMcsUl}    ${targetPctResourceReservedMcsUl}    ${maxUlHarqTx}    ${ullaDeltaSinrMin}    ${ullaDeltaSinrMax}
#     ...         ${dllaDeltaCqiMax}    ${dllaDeltaCqiMin}    ${cellDepType}    ${chBw}    ${dlMimoMode}    ${ulMimoMode}    ${actUl256Qam}
#     ...         ${frameStructureType}    ${prachConfigurationIndex}    ${ulDlDataSlotRatio}    ${guardPeriodLength}    ${bwp_duration0_1}
#     ...         ${bwp_duration0_3}    ${bwp_periodicity0_1}    ${bwp_periodicity0_3}    ${bwp_slotOffset0_1}    ${bwp_slotOffset0_3}
#     ...         ${bwp_duration44_1}    ${bwp_duration44_3}    ${bwp_periodicity44_1}    ${bwp_periodicity44_3}    ${bwp_slotOffset44_1}
#     ...         ${bwp_slotOffset44_3}    ${dutation_dedi1}    ${dutation_dedi2}    ${periodicity_dedi}    ${slotOffset_dedi}
#     modify_xml    ${scfc_path}    ${scfc_path}    ${modify_list}
#     Modify TL VM And AP SCTP Configuration
#     Get and Update BSR File
#     Perform Full Commission And Reach Onair With Log    ${scfc_path}    ${CONFIG_DIR_PATH}${/}${WTS_NAME}    reset_after_commission=${False}
#     [Teardown]    run keyword and continue on failure    Stop Collect GNB and AP Syslog in 'Step1_before_onair' File
# 
# Step2:Attach UEs and send UL buffer
#     Start capture gnb and ap syslog in 'Step2_attach' File
#     Attach SA ue with capability to 5g cell    1    CA_P2_8x4_t2r4_n2
#     Airphone NSA Attach    11
#     Airphone SA Start Data Traffic    1    UL    50M    trf_id=1    pdu_id=1    duration=${7200}
#     Airphone NSA Start Data Traffic    11     UL    100M    duration=${7200}
#     Wait Throughput Timer    3
#     ${ue1_ul_tput}=    Airphone Get Throughput On Specific Scell    1    0    pusch
#     ${ue11_ul_tput}=    Airphone Get Throughput On Specific Scell    11    8    pusch
#     ${save_log}=    Set Variable    ${TEST_LOG_DIRECTORY()}Step2_attach
#     Start GNB Ttitrace With Streaming Mode
#     Wait Throughput Timer    3
#     ${pacp}=    Stop GNB Ttitrace With Streaming Mode    save_path=${save_log}
# 	Decoder Tttirace From Pcap To Csv    ${pacp}    ${save_log}${/}tti
# 	check_log_with_au2anlysis    ini_path=${CURDIR}/log_check/case15_tti_step2.ini     log_need_to_check=i    save_log_directory=${save_log}
# 	${counter_file}    download PM counter file    ${save_log}
# 	${UL_thp_counter}=    get_counter_value_from_counter_file    counter_file=${counter_file}   counter_id=M55309C12002   cell_id=1
# 	should be true    ${UL_thp_counter} > 0
#     airphone_collect_egate_log_files      ${save_log}   unzip=TRUE
#     [Teardown]    Run Keyword And Ignore Error    Stop capture gnb and ap syslog in 'Step2_attach' file
# 
# Step3:Trigger UL_HARQ_Retrans
#     Start capture gnb and ap syslog in 'Step3_trigger_retrx' file
#     #Start GNB BIP Log
#     Start GNB Ttitrace With Streaming Mode
#     ul_cell_noise_testmode_deactive    profile_id=1
#     ul_cell_noise_testmode_active    profile_id=1    noise_pusch=-500
#     Wait Throughput Timer    3
#     ${ue1_ul_tput}=    Airphone Get Throughput On Specific Scell    1    0    pusch
#     ${ue11_ul_tput}=    Airphone Get Throughput On Specific Scell    11    8    pusch
#     ${save_log}=    Set Variable    ${TEST_LOG_DIRECTORY()}Step3_trigger_retrx
#     Start GNB Ttitrace With Streaming Mode
#     Wait Throughput Timer    3
#     ${pacp}=    Stop GNB Ttitrace With Streaming Mode    save_path=${save_log}
# 	Decoder Tttirace From Pcap To Csv    ${pacp}    ${save_log}/tti_re
# 	should be true    ${ue1_ul_tput}>15000
# 	should be true    ${ue11_ul_tput}>20000
# 	csv_split_with_rnti_and_retransmission    ${save_log}${/}tti_re_ul.csv
# 	check_log_with_au2anlysis    ini_path=${CURDIR}/log_check/case15_tti_step3.ini     log_need_to_check=i    save_log_directory=${save_log}
# 	check_10659_retx_prb    ${save_log}${/}tti_re_ul.csv    75    50
# 	check_10659_256qam_mcs30_counter    ${save_log}
# 	[Teardown]    Run Keyword And Ignore Error    Stop capture gnb and ap syslog in 'Step3_trigger_retrx' file
# 
# Step4:Last for 1 hour check stability
#     Start capture gnb and ap syslog in 'Step4_stability' file
#     Wait Throughput Timer    3600
#     ${ue1_ul_tput}=    Airphone Get Throughput On Specific Scell    1    0    pusch
#     ${ue11_ul_tput}=    Airphone Get Throughput On Specific Scell    11    8    pusch
#     ${save_log}=    Set Variable    ${TEST_LOG_DIRECTORY()}Step4_stability
#     Start GNB Ttitrace With Streaming Mode
#     Wait Throughput Timer    3
#     ${pacp}=    Stop GNB Ttitrace With Streaming Mode    save_path=${save_log}
# 	Decoder Tttirace From Pcap To Csv    ${pacp}    ${save_log}/tti_re
# 	csv_split_with_rnti_and_retransmission    ${save_log}${/}tti_re_ul.csv
# 	should be true    ${ue1_ul_tput}>15000
# 	should be true    ${ue11_ul_tput}>20000
# 	check_log_with_au2anlysis    ini_path=${CURDIR}/log_check/case15_tti_step3.ini     log_need_to_check=i    save_log_directory=${save_log}
# 	check_10659_retx_prb    ${save_log}${/}tti_re_ul.csv    75    50
# 	check_10659_256qam_mcs30_counter    ${save_log}
# 	[Teardown]    Run Keyword And Ignore Error    Stop capture gnb and ap syslog in 'Step4_stability' file
# 
# Step5:Detach ues
#     Airphone SA Detach    1
#     Airphone NSA Detach    11
# 
# 
# check_10659_256qam_mcs30_counter
#     [Arguments]    ${save_log}
#     ${counter_file}    download PM counter file    ${save_log}
#     ${THP_UL_MAX}=    get_counter_value_from_counter_file    counter_file=${counter_file}   counter_id=M55309C12002   cell_id=1
#     ${PUSCH_CP_SUCC_ANY_256TBL_MCS_30}=    get_counter_value_from_counter_file    counter_file=${counter_file}   counter_id=M55302C14030   cell_id=1
# 	${PUSCH_CP_RANK2_256TBL_MCS_30}=    get_counter_value_from_counter_file    counter_file=${counter_file}   counter_id=M55303C23030   cell_id=1
# 	${PUSCH_CP_INIRE_VOL_256TBL_MCS30}=    get_counter_value_from_counter_file    counter_file=${counter_file}   counter_id=M55304C10030   cell_id=1
#     should be true    ${THP_UL_MAX} > 6000000
#     should be true    ${PUSCH_CP_SUCC_ANY_256TBL_MCS_30} > 0
#     should be true    ${PUSCH_CP_RANK2_256TBL_MCS_30} > 0
#     should be true    ${PUSCH_CP_INIRE_VOL_256TBL_MCS30} > 0
# 
# check_10659_retx_prb
#     [Arguments]    ${ttitrace_path}    ${targetUl}    ${minUl}
#     ${numOfPrb_init}    read csv columns       ${ttitrace_path}    ulFdSchedData.numOfPrb
#     ...    filter=(ulFdSchedData.txNumber=1 )&(ulHarqRxData.crcResult=NOK)&(ulHarqRxData.dtx=NON_DTX)
#     ${CandRetx}    ${MinRetx}    ${MaxRetx}    ${Status}    ${numOfPrb_retx}    ${rePerPrbInitTx}    ${rePerPrbReTx}    ${version}
#     ...    read csv columns       ${ttitrace_path}
#     ...    ulFdSchedData.PRBCandRetx    ulFdSchedData.PRBMinRetx    ulFdSchedData.PRBMaxCodeRateRetx    ulFdSchedData.adaptRetxStatus
#     ...    ulFdSchedData.numOfPrb    ulFdSchedData.rePerPrbInitTx    ulFdSchedData.rePerPrbReTx    ulFdSchedData.redundancyVersion
#     ...    filter=(ulFdSchedData.txNumber=2 )&(ulFdSchedData.adaptRetxStatus=APPLY)
#     ${avg_prb_init}     evaluate    math.ceil(float(sum(${numOfPrb_init})/len(${numOfPrb_init})))       math
#     ${avg_can_retx}     evaluate    math.ceil(float(sum(${CandRetx})/len(${CandRetx})))                 math
#     ${avg_min_retx}     evaluate    math.ceil(float(sum(${MinRetx})/len(${MinRetx})))                   math
#     ${prb_kinds}        evaluate    len(list(set(${numOfPrb_init})))
#     ${res1}             evaluate    math.ceil(float(${avg_prb_init}*${targetUl}/100))                   math
#     ${res2}             evaluate    math.ceil(float(${avg_prb_init}*${minUl}/100))                      math
#     ${res3}             evaluate    ${rePerPrbInitTx}==${rePerPrbReTx}
#     should be true      ${res1}-1<=${avg_can_retx}<=${res1}+1
#     should be true      ${res2}-1<=${avg_min_retx}<=${res2}+1
#     should be true      ${res3}
