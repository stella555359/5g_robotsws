*** Settings ***
Documentation     Author: zhaona.jiang@nokia-sbell.com...
...               QC case full name:
...               CB010659_B_case34_TDD_SA_NSA_Retrans_UEs_paired_with_Retrans_UEs_CB006062

Suite Setup       Common Suite Setup
#Suite Teardown    Common Suite Teardown
Test Setup        Common Test Setup
Test Teardown     Common Test Teardown
Force Tags        CLOUD_5G_I_LO_AP_LO_SANSA_FS_ECPRI_CMWV_TDD    AP    CRT    SBTS00    SBTS23R1    RAN_5G_TDD    RAN_5G    owner_jiangzhaona
Test Timeout      90 minutes
Resource          ../../resources/sg11/internal_resource/robot/modify_configuration.robot
Resource          ../../resources/sg11/internal_resource/robot/internal_ap_operate.robot
Resource          ../../resources/sg11/internal_resource/robot/internal_gnb_operate.robot
Resource          ../../resources/sg11/internal_resource/robot/internal_capture_log.robot
Library           ../../resources/sg11/internal_resource/python/for_specific_feature/CB010659_check_maxCoedeRatePRB.py
Library           ../../resources/sg11/internal_resource/python/for_specific_feature/CB010659_check_reTx_status_and_reservedMCS.py

*** Variables ***
${CONFIG_DIR_PATH}    ${CURDIR}/../../resources/sg11/internal_resource/config/
${SCFC_NAME}          gNB_scf_ASIB_ABIO_AEQE_TDD_eCPRI_cmwv_SANSA_1CC_FS.xml
${AIRPHONE_NAME}      AP_iphy_AEQE_LO_AP_LO_TDD_eCPRI_cmwv_SANSA_L1b_1S_1CC_srs_B.xml
${WTS_NAME}           wts_config_ASIL_ABIO_TDD_eCPRI_cmwv_SANSA_L1b_1S_1CC.cfg
${COMAVALUE}          ${CURDIR}/../../resources/sg11/internal_resource/config/AP/ap_coma.txt
@{LOG_NAME_LIST}      egatelog\

${cellDepType}                              text|SA+NSA|//*[@name\="cellDepType"]
${chBw}                                     text|80MHz|//*[@name\="chBw"]
${cSRS}                                     text|51|//*[@name\="cSRS"]
${dlMimoMode}                               text|8x4 Closed Loop Spatial Multiplexing|//*[@name\="dlMimoMode"]
${nrCellType}                               text|8DL8UL|//*[@name\="nrCellType"]
${actUlMuMimo}                              text|true|//*[@name\="actUlMuMimo"]
${actUlDataDmrsFdm}                         text|true|//*[@name\="actUlDataDmrsFdm"]
${ulDataDmrsFdmThres64QamMcs}               text|20|//*[@name\="ulDataDmrsFdmThres64QamMcs"]
${ulDataDmrsFdmThres256QamMcs}              text|20|//*[@name\="ulDataDmrsFdmThres256QamMcs"]
${ulMaxMuMimoLayer}                         text|4|//*[@name\="ulMaxMuMimoLayer"]
${actUlMuMimoTapering}                      text|false|//*[@name\="actUlMuMimoTapering"]
${ulMuMimoTaperingH}                        text|20dB|//*[@name\="ulMuMimoTaperingH"]
${ulMuMimoTaperingV}                        text|25dB|//*[@name\="ulMuMimoTaperingV"]
${frameStructureType}                       text|tdLte|//*[@name\="frameStructureType"]
${ulDlDataSlotRatio}                        text|1/4|//*[@name\="ulDlDataSlotRatio"]
${guardPeriodLength}                        text|6Symbols|//*[@name\="guardPeriodLength"]
${prachConfigurationIndex}                  text|97|//*[@name\="prachConfigurationIndex"]
${lteToNrFrameShift}                        text|0ms|//*[@name\="lteToNrFrameShift"]
${tdLteUlDlConfig}                          text|tdLteConfig2|//*[@name\="tdLteUlDlConfig"]
${ullaDeltaSinrMax}                         text|0|//*[@name\="ullaDeltaSinrMax"]
${ullaDeltaSinrMin}                         text|0|//*[@name\="ullaDeltaSinrMin"]
${ulMuMimoCorrThd}                          text|50|//*[@name\="ulMuMimoCorrThd"]
${ulMuMimoCorrThd2}                         text|45|//*[@name\="ulMuMimoCorrThd2"]
${bwpDN1}                                   text|MRBTS-1/NRBTS-2/BWP_PROFILE-4|//*[contains(@name,'cellBwpList')]//item[1]/*[@name\='bwpDN']
${bwpDN2}                                   text|MRBTS-1/NRBTS-2/BWP_PROFILE-75|//*[contains(@name,'cellBwpList')]//item[2]/*[@name\='bwpDN']
${tiltOffset}                               text|0|//*[@name\="tiltOffset"]
${ulSinrDiffThreshold}                      text|30|//*[@name\="ulSinrDiffThreshold"]
${ulMuMimoLinkAdaptionSwitch}               text|MCS compensation|//*[@name\="ulMuMimoLinkAdaptionSwitch"]
${actUl256Qam}                              text|true|//*[@name\="actUl256Qam"]
${prbThreshRangeOne}                        text|50|//*[@name\="prbThreshRangeOne"]
${prbThreshRangeThree}                      text|50|//*[@name\="prbThreshRangeThree"]
${prbThreshRangeTwo}                        text|50|//*[@name\="prbThreshRangeTwo"]

${actAdaptiveReTxResMcs}                    text|true|//*[@name\="actAdaptiveReTxResMcs"]
${actAdaptiveReTxResMcsEnh}                 text|true|//*[@name\="actAdaptiveReTxResMcsEnh"]
${minPctResourceReservedMcsDl}              text|50|//*[@name\="minPctResourceReservedMcsDl"]
${targetPctResourceReservedMcsDl}           text|75|//*[@name\="targetPctResourceReservedMcsDl"]
${minPctResourceReservedMcsUl}              text|50|//*[@name\="minPctResourceReservedMcsUl"]
${targetPctResourceReservedMcsUl}           text|75|//*[@name\="targetPctResourceReservedMcsUl"]
${maxUlHarqTx}                              text|4|//*[@name\="maxUlHarqTx"]
${pattern}                                  CA_P2_8x4_t2r4_n2_pusch_1layer
@{Rdparameter}                              0x340000:15    0x58061A:1

*** Test Cases ***
CB010659_B_case34_TDD_SA_NSA_Retrans_UEs_paired_with_Retrans_UEs_CB006062
    Step1:Commission the above configuration on WebUI
    Step2:Attach sa and nsa ue
	Step3:trigger retransmission
	Step4:Online change param
	Step5:Detach all ues


*** Keywords ***
Step1:Commission the above configuration on WebUI
    Start Collect GNB and AP Syslog in 'Step1_before_onair' File
	${CONFIG_DIR_PATH}    Set Variable    ${CONFIG_DIR_PATH}/${SW_BRANCH}
    change_iphy_rru_version    ${CONFIG_DIR_PATH}${/}${AIRPHONE_NAME}
    modify_swconfig_by_CB010659    ${CONFIG_DIR_PATH}${/}${SCFC_NAME}	@{Rdparameter}
    ${scfc_path}    Set Variable    ${TEST_LOG_DIRECTORY()}${/}scfc.xml
    copy_file    ${CONFIG_DIR_PATH}/${SCFC_NAME}    ${scfc_path}
    ${modify_list}    create list
    ...    ${cellDepType}    ${chBw}    ${dlMimoMode}    ${nrCellType}    ${actUlMuMimo}    ${ulMaxMuMimoLayer}    ${actUlMuMimoTapering}
    ...    ${ulMuMimoTaperingH}    ${ulMuMimoTaperingV}    ${frameStructureType}    ${guardPeriodLength}    ${actUlDataDmrsFdm}
    ...    ${ulDlDataSlotRatio}    ${prachConfigurationIndex}    ${lteToNrFrameShift}    ${tdLteUlDlConfig}    ${bwpDN1}    ${bwpDN2}
    ...    ${cSRS}    ${ullaDeltaSinrMax}    ${ullaDeltaSinrMin}    ${ulMuMimoCorrThd}    ${tiltOffset}    ${ulSinrDiffThreshold}
    ...    ${ulMuMimoCorrThd2}    ${ulMuMimoLinkAdaptionSwitch}    ${actAdaptiveReTxResMcs}    ${actAdaptiveReTxResMcsEnh}    ${actUl256Qam}
    ...    ${minPctResourceReservedMcsDl}    ${targetPctResourceReservedMcsDl}    ${minPctResourceReservedMcsUl}    ${targetPctResourceReservedMcsUl}
    ...    ${ullaDeltaSinrMax}    ${maxUlHarqTx}   ${ulDataDmrsFdmThres64QamMcs}    ${ulDataDmrsFdmThres256QamMcs}    ${prbThreshRangeOne}
    ...    ${prbThreshRangeThree}    ${prbThreshRangeTwo}
    modify_xml    ${scfc_path}    ${scfc_path}    ${modify_list}
    Modify TL VM And AP SCTP Configuration
	Get and Update BSR File    par_of_bsr_name=AEQE_6_H6_ALN60_ARP60_P00_COVERAGE_00424_000
    Perform Full Commission And Reach Onair With Log    ${scfc_path}    ${CONFIG_DIR_PATH}${/}${WTS_NAME}    reset_after_commission=${False}
    [Teardown]    Stop Collect GNB and AP Syslog in 'Step1_before_onair' File

Step2:Attach sa and nsa ue
    Start Collect GNB and AP Syslog in 'Step2_attach' File
    Airphone NSA Attach    11
    Attach SA ue with capability to 5g cell    1    CA_P2_8x4_t2r4_n2
    ul_mimo_srs_beam_pos_active    ue=11    profile=1    init=0    sub=0    scell=8
    ul_mimo_srs_beam_pos_active    ue=1    profile=2    init=1    sub=0
    Airphone SA Start Data Traffic    1    UL    150M    trf_id=1    pdu_id=1    duration=${7200}
    Airphone NSA Start Data Traffic    11     UL    100M    duration=${7200}
    ${ue1_ul_tput}=    Airphone Get Throughput On Specific Scell    11    8    pusch
    ${ue2_ul_tput}=    Airphone Get Throughput On Specific Scell    1    0    pusch
    ${save_log}=    Set Variable    ${TEST_LOG_DIRECTORY()}Step2_attach
    Start GNB Ttitrace With Streaming Mode
    Wait Throughput Timer    3
    ${pacp}=    Stop GNB Ttitrace With Streaming Mode    save_path=${save_log}
	Decoder Tttirace From Pcap To Csv    ${pacp}    ${save_log}${/}tti
	check_log_with_au2anlysis    ini_path=${CURDIR}/log_check/case34_tti_step2.ini    log_need_to_check=i    save_log_directory=${save_log}

    [Teardown]    Stop Collect GNB and AP Syslog in 'Step2_attach' File

Step3:trigger retransmission
    Start Collect GNB and AP Syslog in 'Step3_retx' File
    #Start GNB BIP Log
    ul_cell_noise_testmode_deactive    profile_id=1
    ul_cell_noise_testmode_active    profile_id=1    noise_pusch=-450
    #ul_sinr_pusch_active    ue_id=1    profile_id=2    sinr_pusch=-411
    Wait Throughput Timer    3
    ${ue1_ul_tput}=    Airphone Get Throughput On Specific Scell    11    8    pusch
    ${ue2_ul_tput}=    Airphone Get Throughput On Specific Scell    1    0    pusch
    ${save_log}=    Set Variable    ${TEST_LOG_DIRECTORY()}Step3_retx
    Start GNB Ttitrace With Streaming Mode
    Wait Throughput Timer    3
    ${pacp}=    Stop GNB Ttitrace With Streaming Mode    save_path=${save_log}
	Decoder Tttirace From Pcap To Csv    ${pacp}    ${save_log}/tti_re
	check_log_with_au2anlysis    ini_path=${CURDIR}/log_check/case34_tti_step3.ini    log_need_to_check=i    save_log_directory=${save_log}
    #run keyword and continue on failure   check_reTx_status_and_reservedMCS   ${save_log}${/}tti_re_ul.csv   0.75   0.5
	run keyword and continue on failure   check_maxCodeRatePRB   ${save_log}${/}tti_re_ul.csv   1.3
	run keyword and continue on failure   check_10659_retx_prb    ${save_log}${/}tti_re_ul.csv    75    50
	[Teardown]    Stop Collect GNB and AP Syslog in 'Step3_retx' File

Step4:Online change param
    Start capture gnb and ap syslog in 'Step4_change_nidd' file
    ${save_log}=    Set Variable    ${TEST_LOG_DIRECTORY()}Step4_change_nidd
    Online recommissioning with delta json file    ${CURDIR}/JSON/Delta_Configuration_scf_prbThresh_20.json
    Start GNB Ttitrace With Streaming Mode
    Wait Throughput Timer    2
    ${pacp}=    Stop GNB Ttitrace With Streaming Mode    save_path=${save_log}
    Decoder Tttirace From Pcap To Csv    ${pacp}    ${save_log}/tti_re
    #run keyword and continue on failure   check_reTx_status_and_reservedMCS   ${save_log}${/}tti_re_ul.csv   0.75   0.5
	run keyword and continue on failure   check_maxCodeRatePRB   ${save_log}${/}tti_re_ul.csv   1.3   
	check_10659_retx_prb    ${save_log}${/}tti_re_ul.csv    75    50
    check_log_with_au2anlysis    ini_path=${CURDIR}/log_check/case34_tti_step4.ini     log_need_to_check=i    save_log_directory=${save_log}
    [Teardown]    Run Keyword And Ignore Error    Stop capture gnb and ap syslog in 'Step4_change_nidd' file

Step5:Detach all ues
    Airphone SA Detach    1
    Airphone NSA Detach    11


check counter
    [Arguments]    ${log_dir}
    ${counter_file}=    download_latest_pmcounter    local_path=${TEST_LOG_DIRECTORY()}${log_dir}/
	${UL_thp_counter}=    get_counter_value_from_counter_file    counter_file=${counter_file}   counter_id=M55309C12002   cell_id=1
	${PAIR_UE_PUSCH}=    get_counter_value_from_counter_file    counter_file=${counter_file}   counter_id=M55308C35010   cell_id=1
	${ELIG_UE_PUSCH}=    get_counter_value_from_counter_file    counter_file=${counter_file}   counter_id=M55308C35011   cell_id=1
	run keyword and continue on failure    should be true    ${UL_thp_counter} > 10000000
	run keyword and continue on failure    should be true    ${PAIR_UE_PUSCH} > 70000
	run keyword and continue on failure    should be true    ${ELIG_UE_PUSCH} > 85000
	run keyword and continue on failure    should be true    int(${ELIG_UE_PUSCH}/${PAIR_UE_PUSCH})==1

check_10659_retx_prb
    [Arguments]    ${ttitrace_path}    ${targetUl}    ${minUl}
    ${numOfPrb_init}    read csv columns       ${ttitrace_path}    ulFdSchedData.numOfPrb
    ...    filter=(ulFdSchedData.txNumber=1 )&(ulHarqRxData.crcResult=NOK)&(ulHarqRxData.dtx=NON_DTX)
    ${CandRetx}    ${MinRetx}    ${MaxRetx}    ${Status}    ${numOfPrb_retx}    ${rePerPrbInitTx}    ${rePerPrbReTx}    ${version}
    ...    read csv columns       ${ttitrace_path}
    ...    ulFdSchedData.PRBCandRetx    ulFdSchedData.PRBMinRetx    ulFdSchedData.PRBMaxCodeRateRetx    ulFdSchedData.adaptRetxStatus
    ...    ulFdSchedData.numOfPrb    ulFdSchedData.rePerPrbInitTx    ulFdSchedData.rePerPrbReTx    ulFdSchedData.redundancyVersion
    ...    filter=(ulFdSchedData.txNumber=2 )&(ulFdSchedData.adaptRetxStatus=APPLY)
    ${avg_prb_init}     evaluate    math.ceil(float(sum(${numOfPrb_init})/len(${numOfPrb_init})))       math
    ${avg_can_retx}     evaluate    math.ceil(float(sum(${CandRetx})/len(${CandRetx})))                 math
    ${avg_min_retx}     evaluate    math.ceil(float(sum(${MinRetx})/len(${MinRetx})))                   math
    ${prb_kinds}        evaluate    len(list(set(${numOfPrb_init})))
    ${res1}             evaluate    math.ceil(float(${avg_prb_init}*${targetUl}/100))                   math
    ${res2}             evaluate    math.ceil(float(${avg_prb_init}*${minUl}/100))                      math
    ${res3}             evaluate    ${rePerPrbInitTx}==${rePerPrbReTx}
    should be true      ${res1}-1<=${avg_can_retx}<=${res1}+1
    should be true      ${res2}-1<=${avg_min_retx}<=${res2}+1
    should be true      ${res3}
