*** Settings ***
Documentation     Author: zhaona.jiang@nokia-sbell.com
...
...               QC case full name:
...               CB008305_regression_robust_case03_TDD_antport and cdm group check
...
#
Suite Setup       Common Suite Setup
Suite Teardown    Common Suite Teardown
Test Setup        Common Test Setup
Test Teardown     Common Test Teardown
Force Tags        CLOUD_5G_I_LO_AP_LO_SANSA_FS_ECPRI_CMWV_TDD    AP    CRT    SBTS00    SBTS23R1    RAN_5G_TDD    RAN_5G
Test Timeout      120 minutes
Resource          ../../resources/sg11/internal_resource/robot/modify_configuration.robot
Resource          ../../resources/sg11/internal_resource/robot/internal_ap_operate.robot
Resource          ../../resources/sg11/internal_resource/robot/internal_gnb_operate.robot
Resource          ../../resources/sg11/internal_resource/robot/internal_capture_log.robot
Library           ../../resources/sg10/internal_resource/lib/pdcch_dci_decode.py
#
*** Variables ***
${CONFIG_DIR_PATH}    ${CURDIR}/../../resources/sg11/internal_resource/config/
${SCFC_NAME}          sg10_bwp_3_1116.xml
${AIRPHONE_NAME}      AP_iphy_AEQE_LO_AP_LO_TDD_eCPRI_cmwv_SANSA_L1b_1S_1CC_srs_B.xml
#${WTS_NAME}           8305_MU_MIMO.lua
${WTS_NAME}           wts_config_ASIL_ABIO_TDD_eCPRI_cmwv_SANSA_L1b_1S_1CC.cfg
${COMAVALUE}          ${CURDIR}/../../resources/sg11/internal_resource/config/AP/ap_coma.txt
@{LOG_NAME_LIST}      gnb_snapshot    egatelog\
#
${chBw}                           text|100MHz|//*[@name\="chBw"]
${dlMimoMode}                     text|8x4 Closed Loop Spatial Multiplexing|//*[@name\="dlMimoMode"]
${nrCellType}                     text|8DL4UL|//*[@name\="nrCellType"]
${actDlMuMimoEnh}                 text|true|//*[@name\="actDlMuMimoEnh"]
${dlMuMimoCorrThd}                text|33|//*[@name\="dlMuMimoCorrThd"]
${dlMuMimoCqiThd}                 text|0|//*[@name\="dlMuMimoCqiThd"]
${dlMuMimoSpectralEffThd}         text|10|//*[@name\="dlMuMimoSpectralEffThd"]
${maxNumLayerPerMuRbg}            text|8|//*[@name\="dlMuMaxNumLayerPerMuRbg"]
${dlMuMimoRankAdaption}           text|disabled|//*[@name\="dlMuMimoRankAdaption"]
${dlMuMimoTaperingH}              text|25dB|//*[@name\="dlMuMimoTaperingH"]
${dlMuMimoTaperingV}              text|NoTapering|//*[@name\="dlMuMimoTaperingV"]
${actBeamforming}                 text|true|//*[@name\="actBeamforming"]
${basicBeamSet}                   text|beamSet_6|//*[@name\="basicBeamSet"]
${numberOfTransmittedSsBlocks}    text|6 beams|//*[contains(@distName, 'NRCELLGRP')]/*[@name='numberOfTransmittedSsBlocks']
${actDl256Qam}                    text|false|//*[@name\="actDl256Qam"]
${actBbPoolExtensionTddFr1}       text|false|//*[@name\="actBbPoolExtensionTddFr1"]
${miNrRelReportCu}                text|disabled|//*[@name\="miNrRelReportCu"]
${actFdmScheduling}                             text|true|//*[@name\="actFdmScheduling"]
${frameStructureType}                           text|tdLte|//*[@name\="frameStructureType"]
${guardPeriodLength}                            text|6Symbols|//*[@name\="guardPeriodLength"]
${lteToNrFrameShift}                            text|0ms|//*[@name\="lteToNrFrameShift"]
${prachConfigurationIndex}                      text|97|//*[@name\="prachConfigurationIndex"]
${actDlSrsBm}                                   text|true|//*[@name\="actDlSrsBm"]
${srsUePeriodicity}                             text|slots40|//*[@name\="srsUePeriodicity"]
${cSRS}                                         text|42|//*[@name\="cSRS"]
${bSRS}                                         text|2|//*[@name\="bSRS"]
${nrBtsBeamRefinementP2}                        text|false|//*[@name\="nrBtsBeamRefinementP2"]
${msg1FrequencyStart}                           text|2|//*[@name\="msg1FrequencyStart"]
${actUlMuMimoTapering}                          text|false|//*[@name\="actUlMuMimoTapering"]
${schedulBSD}                                   text|100ms|//*[@name\="schedulBSD"]
${miNrCellUtilPerPLMN}                          text|15min|//*[@name\="miNrCellUtilPerPLMN"]
${actCsirsMultiplexing}                         text|false|//*[@name\="actCsirsMultiplexing"]
${actCustomBsr}                                 text|true|//*[@name\="actCustomBsr"]
${actDlDataDmrsFdm}                             text|true|//*[@name\="actDlDataDmrsFdm"]
${ullaDeltaSinrMax}                             text|5|//*[@name\="ullaDeltaSinrMax"]
${ullaDeltaSinrMin}                             text|-5|//*[@name\="ullaDeltaSinrMin"]
${bwp_profile7}       text|MRBTS-1/NRBTS-1/BWP_PROFILE-7|//*[@name\="cellBwpList"]/item[1]/*[@name\="bwpDN"]
${bwp_profile73}      text|MRBTS-1/NRBTS-1/BWP_PROFILE-73|//*[@name\="cellBwpList"]/item[2]/*[@name\="bwpDN"]
${pattern}            CA_P2_8x4_t2r4_n2
${UE1_ID}         1
${UE2_ID}         2
#
#
*** Test Cases ***
CB008305_regression_robust_case03_TDD_antport and cdm group check
    Step1:Commission the above configuration on WebUI
    Step2:UE1 1layer UE2 3layer DL MU
    Step3:Check dmrs port
    Step4:Make dl bler check again
#
*** Keywords ***
Step1:Commission the above configuration on WebUI
    Start Capture GNB and AP Syslog in 'Step1_before_onair' File
	${CONFIG_DIR_PATH}    Set Variable    ${CONFIG_DIR_PATH}/${SW_BRANCH}
    change_iphy_rru_version    ${CONFIG_DIR_PATH}${/}${AIRPHONE_NAME}
    modify_swconfig_by_CB008305    ${CONFIG_DIR_PATH}${/}${SCFC_NAME}
    ${scfc_path}    Set Variable    ${TEST_LOG_DIRECTORY()}${/}scfc.xml
    copy_file    ${CONFIG_DIR_PATH}/${SCFC_NAME}    ${scfc_path}
    ${modify_list}    create list
    ...       ${chBw}    ${dlMimoMode}    ${nrCellType}    ${actFdmScheduling}    ${actDlMuMimoEnh}    ${dlMuMimoCorrThd}    ${dlMuMimoCqiThd}
    ...       ${dlMuMimoSpectralEffThd}    ${maxNumLayerPerMuRbg}    ${dlMuMimoRankAdaption}    ${dlMuMimoTaperingH}    ${dlMuMimoTaperingV}
    ...       ${frameStructureType}    ${guardPeriodLength}    ${lteToNrFrameShift}    ${prachConfigurationIndex}    ${srsUePeriodicity}
    ...       ${cSRS}    ${bSRS}    ${actBeamforming}    ${basicBeamSet}    ${numberOfTransmittedSsBlocks}    ${nrBtsBeamRefinementP2}
    ...       ${msg1FrequencyStart}    ${schedulBSD}    ${miNrCellUtilPerPLMN}    ${actDlSrsBm}    ${actCsirsMultiplexing}    ${actDl256Qam}
    ...       ${bwp_profile7}    ${bwp_profile73}     ${actCustomBsr}    ${actDlDataDmrsFdm}      ${ullaDeltaSinrMax}      ${ullaDeltaSinrMin}
    ...       ${actBbPoolExtensionTddFr1}    ${miNrRelReportCu}
    modify_xml    ${scfc_path}    ${scfc_path}    ${modify_list}
    add_xml_element     ${scfc_path}    ${scfc_path}
	...     <p name="customBeamSetName">BSR_AEQE_6_H6_ALN60_ARP60_P00_COVERAGE_00424_00001</p>|//*[@name\='beamSet']/item[1]
    Modify TL VM And AP SCTP Configuration
    Get and Update BSR File    par_of_bsr_name=AEQE_6_H6_ALN60_ARP60_P00_COVERAGE_00424_00001
    Perform Full Commission And Reach Onair With Log    ${scfc_path}    ${CONFIG_DIR_PATH}${/}${WTS_NAME}    reset_after_commission=${False}
    [Teardown]    run keyword and continue on failure    Stop Capture GNB and AP Syslog in 'Step1_before_onair' File
#
#
Step2:UE1 1layer UE2 3layer DL MU
    Start capture gnb and ap syslog in 'Step2' file
	#Start GNB BIP Log
    ${save_log}=    Set Variable    ${TEST_LOG_DIRECTORY()}Step2
    Attach SA ue with capability to 5g cell    2    ${pattern}
    ul_mimo_srs_beam_pos_active    ue=1    profile=1    init=0    sub=0    step=5    scell=0
    ul_mimo_srs_beam_pos_active    ue=2    profile=2    init=3    sub=2    step=5    scell=0
    Wait Throughput Timer    3
    csi_override_testmode_active    ${UE1_ID}    1    0
    csi_override_testmode_active    ${UE2_ID}    2    2
    Wait Throughput Timer    3
    SA send multiple trf data    ${UE1_ID}    DL    175M    4
    SA send multiple trf data    ${UE1_ID}    UL    175M    1
    SA send multiple trf data    ${UE2_ID}    DL    175M    4
    SA send multiple trf data    ${UE2_ID}    UL    175M    1
  # Start GNB BIP Log
  # Stop Gnb BIP Log    log_dir=${save_log}
    Start GNB Ttitrace With Streaming Mode
    Wait Throughput Timer    2
    ${ue1_ul_tput}=    Airphone Get Throughput On Specific Scell    1    0    pusch    current
    ${ue1_dl_tput}=    Airphone Get Throughput On Specific Scell    1    0    pdsch    current
    ${ue2_ul_tput}=    Airphone Get Throughput On Specific Scell    2    0    pusch    current
    ${ue2_dl_tput}=    Airphone Get Throughput On Specific Scell    2    0    pdsch    current
    ${pacp}=    Stop GNB Ttitrace With Streaming Mode    save_path=${save_log}
	Decoder Tttirace From Pcap To Csv    ${pacp}    ${save_log}${/}tti
	${counter_file}    download PM counter file    ${save_log}
	${UL_thp_counter}=    get_counter_value_from_counter_file    counter_file=${counter_file}   counter_id=M55309C12002   cell_id=1
	${DL_thp_counter}=    get_counter_value_from_counter_file    counter_file=${counter_file}   counter_id=M55309C12001   cell_id=1
	Run Keyword And Ignore Error    should be true    ${UL_thp_counter} > 17000000
	Run Keyword And Ignore Error    should be true    ${DL_thp_counter} > 120000000
    [Teardown]    Run Keyword And Ignore Error    Stop capture gnb and ap syslog in 'Step2' file
#
Step3:Check dmrs port
   Start capture gnb and ap syslog in 'Step2' file
   ${save_log}=    Set Variable    ${TEST_LOG_DIRECTORY()}Step2
#	csi_override_testmode_deactive    ${UE2_ID}    3
   csi_override_testmode_active    ${UE2_ID}    2    2
   Wait Throughput Timer    3
   Start GNB Ttitrace With Streaming Mode
   ${pacp}=    Stop GNB Ttitrace With Streaming Mode    save_path=${save_log}
#	Decoder Tttirace From Pcap To Csv    ${pacp}    ${save_log}${/}tti
    ${log_dir}=    Set Variable    ${TEST_LOG_DIRECTORY()}Step2
    run keyword and continue on failure    Decode_PDCCH_Dciinfo    ${log_dir}/tti_dl.csv
    run keyword and continue on failure
	...    check_log_with_au2anlysis    ini_path=${CURDIR}/log_check/case03_step3.ini     log_need_to_check=i    save_log_directory=${log_dir}
#
   [Teardown]    Run Keyword And Ignore Error    Stop capture gnb and ap syslog in 'Step2' file
#
Step4:Make dl bler check again
    Start capture gnb and ap syslog in 'Step4' file
    ${save_log}=    Set Variable    ${TEST_LOG_DIRECTORY()}Step4
    #Start GNB BIP Log
    UE1 send dl bler
    UE2 send dl bler
    #Stop Gnb BIP Log    log_dir=${save_log}
    Start GNB Ttitrace With Streaming Mode
    ${ue1_ul_tput}=    Airphone Get Throughput On Specific Scell    1    0    pusch    current
    ${ue1_dl_tput}=    Airphone Get Throughput On Specific Scell    1    0    pdsch    current
    ${ue2_ul_tput}=    Airphone Get Throughput On Specific Scell    2    0    pusch    current
    ${ue2_dl_tput}=    Airphone Get Throughput On Specific Scell    2    0    pdsch    current
    Wait Throughput Timer    2
    ${pacp}=    Stop GNB Ttitrace With Streaming Mode    save_path=${save_log}
	Decoder Tttirace From Pcap To Csv    ${pacp}    ${save_log}${/}tti
	run keyword and continue on failure    Decode_PDCCH_Dciinfo    ${save_log}/tti_dl.csv
    run keyword and continue on failure
	...    check_log_with_au2anlysis    ini_path=${CURDIR}/log_check/case03_step4.ini     log_need_to_check=i    save_log_directory=${save_log}
#
    [Teardown]    Run Keyword And Ignore Error    Stop capture gnb and ap syslog in 'Step4' file
#
#
UE${i} send dl bler
    airphone_execute_egate_command    bler_testmode_nr profile_id\=1 dl_bler\=100,50,0,0
    airphone_execute_egate_command    ue_testmode_set_nr id\=${i} scell\=0 testmode\=bler profile_id\=1 action\=activate
