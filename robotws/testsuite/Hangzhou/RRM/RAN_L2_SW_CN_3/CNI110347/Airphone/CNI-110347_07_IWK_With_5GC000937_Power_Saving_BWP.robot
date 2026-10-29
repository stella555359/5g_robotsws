*** Settings ***
Documentation     Author: zhaoyang.xu@nokia-sbell.com
...
...               QC case full name:
...               CNI-110347_07_IWK_With_5GC000937_Power_Saving_BWP

Suite Setup       Common Suite Setup
Suite Teardown    Common Suite Teardown
Test Setup        Common Test Setup
Test Teardown     Common Test Teardown
Force Tags        CLOUD_5G_I_LO_AP_LO    CRT    SBTS00    OPTION_RELATED_ARTIFACTS_5G    VARIANT_SANSA_FS_ECPRI_CMWV_TDD_TEMP
Test Timeout      60 minutes
Resource          ../../resources/sg11/internal_resource/robot/modify_configuration.robot
Resource          ../../resources/sg11/internal_resource/robot/internal_ap_operate.robot
Resource          ../../resources/sg11/internal_resource/robot/internal_gnb_operate.robot
Library           taf.transport.ssh    WITH NAME    TAF_SSH
Library           ta_a2a
Library          ${CURDIR}/log_check/Check_CNI110347_function.py

*** Variables ***
${CONFIG_DIR_PATH}    ${CURDIR}/../../resources/sg11/internal_resource/config/
${SCFC_NAME}      scf_CNI_110347_case7.xml
${AIRPHONE_NAME}    AP_iphy_AEQE_LO_AP_LO_TDD_eCPRI_cmwv_SANSA_FS_1S_1CC_CNI_110347.xml
${WTS_NAME}       wts_config_ASIL_ABIO_TDD_eCPRI_cmwv_SANSA_FS_1S_1CC_CNI_110347.cfg
${COMAVALUE}    ${CURDIR}/../../resources/sg11/internal_resource/config/AP/ap_coma.txt
@{LOG_NAME_LIST}    gnb_snapshot    egatelog
${cellDepType}                                  text|SA+NSA|//*[@name\="cellDepType"]
${chBw}                                         text|100MHz|//*[@name\="chBw"]
${nrarfcn}                                      text|636666|//*[@name\="nrarfcn"]
${gscnOrSsPbchArfcn}                            text|7880|//*[@name\="gscnOrSsPbchArfcn"]
${dlMimoMode}                                   text|8x4 Closed Loop Spatial Multiplexing|//*[@name\="dlMimoMode"]
${nrCellType}                                   text|8DL8UL|//*[@name\="nrCellType"]
${actUlSrsBm}                                   text|true|//*[@name\="actUlSrsBm"]
${actUlMuMimo}                                  text|true|//*[@name\="actUlMuMimo"]
${ulMaxMuMimoLayer}                             text|4|//*[@name\="ulMaxMuMimoLayer"]
${actUlMuMimoTapering}                          text|false|//*[@name\="actUlMuMimoTapering"]
${ulMinPrbThreshold}                            text|50|//*[@name\="ulMinPrbThreshold"]
${ulMuMimoPrbThresholdAbsolute}                 text|15|//*[@name\="ulMuMimoPrbThresholdAbsolute"]
${ulMuMimoCorrThd}                              text|50|//*[@name\="ulMuMimoCorrThd"]
${ulMuMimoCorrThd2}                              text|45|//*[@name\="ulMuMimoCorrThd2"]
${ulMuMimoSinrThd}                              text|10|//*[@name\="ulMuMimoSinrThd"]
${ulMuMimoSpectralEffThd}                       text|1|//*[@name\="ulMuMimoSpectralEffThd"]
${ulMuMimoLinkAdaptionSwitch}                   text|MU-SINR estimation|//*[@name\="ulMuMimoLinkAdaptionSwitch"]
${cSRS}                                         text|51|//*[@name\="cSRS"]
${bSRS}                                         text|2|//*[@name\="bSRS"]
${actBeamforming}                               text|true|//*[@name\="actBeamforming"]
${basicBeamSet}                                 text|beamSet_6|//*[@name\="basicBeamSet"]
${actPowerSavingBWP}                            text|true|//*[@name\="actPowerSavingBWP"]
${tiltOffset}                                   text|0|//*[@name\="tiltOffset"]
${ulSinrDiffThreshold}                          text|30|//*[@name\="ulSinrDiffThreshold"]

#CNI-110347_Bell_Canada
${MCC}                                          text|302|//*[@name\="mcc"]
${MNC}                                          text|610|//*[@name\="mnc"]
${frameStructureType}                           text|tdLte|//*[@name\="frameStructureType"]
${guardPeriodLength}                            text|6Symbols|//*[@name\="guardPeriodLength"]
${lteToNrFrameShift}                            text|3ms|//*[@name\="lteToNrFrameShift"]
${tdLteUlDlConfig}                              text|tdLteConfig2|//*[@name\="tdLteUlDlConfig"]
${ulDlDataSlotRatio}                            text|1/4|//*[@name\="ulDlDataSlotRatio"]
${prachConfigurationIndex}                      text|98|//*[@name\="prachConfigurationIndex"]
${srsUePeriodicity}                             text|slots40|//*[@name\="srsUePeriodicity"]
${msg1FrequencyStart}                           text|30|//*[@name\="msg1FrequencyStart"]
${actCaWimaxInterferenceAvoidance}              text|true|//*[@name\="actCaWimaxInterferenceAvoidance"]

${pattern}    CA_P2_8x4_t2r4_n2

*** Test Cases ***
CNI-110347_07_IWK_With_5GC000937_Power_Saving_BWP
    Step1:Commission the above configuration on WebUI
    Step2:Attach a UE with TAS SRS and powerSaving capability
    Step3:Start Big DL Data Transfer and Check Switch To Large BWP
	Step4:Check CNI110347 function in TTItrace
    Step5:Stop Data Traffic And Check Switch To Power Saving BWP
    Step6:ReStart Big DL Data Transfer and Check Switch To Large BWP
    Step7:Detach UE

*** Keywords ***
Step1:Commission the above configuration on WebUI
    Start Collect GNB and AP Syslog in 'Step1_before_onair' File
    ${CONFIG_DIR_PATH}    Set Variable    ${CONFIG_DIR_PATH}/${SW_BRANCH}
    change_iphy_rru_version    ${CONFIG_DIR_PATH}${/}${AIRPHONE_NAME}
    modify_swconfig_by_CB008360    ${CONFIG_DIR_PATH}${/}${SCFC_NAME}
    ${scfc_path}    Set Variable    ${TEST_LOG_DIRECTORY()}${/}scfc.xml
    copy_file    ${CONFIG_DIR_PATH}/${SCFC_NAME}    ${scfc_path}
    ${modify_list}    create list
    ...    ${cellDepType}    ${chBw}    ${nrarfcn}    ${gscnOrSsPbchArfcn}
	...    ${dlMimoMode}    ${nrCellType}    ${actUlSrsBm}    ${actUlMuMimo}
    ...    ${ulMaxMuMimoLayer}    ${actUlMuMimoTapering}    ${ulMinPrbThreshold}
    ...    ${ulMuMimoPrbThresholdAbsolute}    ${ulMuMimoCorrThd}    ${ulMuMimoCorrThd2}
	...    ${ulMuMimoSinrThd}    ${ulMuMimoSpectralEffThd}    ${ulMuMimoLinkAdaptionSwitch}
    ...    ${cSRS}    ${bSRS}    ${actBeamforming}    ${basicBeamSet}
    ...    ${actPowerSavingBWP}    ${tiltOffset}    ${ulSinrDiffThreshold}
    ...    ${MCC}     ${MNC}
    ...    ${frameStructureType}    ${guardPeriodLength}    ${lteToNrFrameShift}    ${ulDlDataSlotRatio}
    ...    ${prachConfigurationIndex}    ${srsUePeriodicity}    ${msg1FrequencyStart}
    ...    ${actCaWimaxInterferenceAvoidance}
   # modify_xml    ${scfc_path}    ${scfc_path}    ${modify_list}
    Modify TL VM And AP SCTP Configuration
    Get and Update BSR File    par_of_bsr_name=AEQE_6_H6_ALN60_ARP60_P00_COVERAGE_00424_00001
    Perform Full Commission And Reach Onair With Log    ${scfc_path}    ${CONFIG_DIR_PATH}${/}${WTS_NAME}    reset_after_commission=${False}
    [Teardown]    Stop Collect GNB and AP Syslog in 'Step1_before_onair' File

Step2:Attach a UE with TAS SRS and powerSaving capability
    Start Collect GNB and AP Syslog in 'Step2_attach_UE' File
    #Start GNB BIP Log
	Airphone Set Traffic Type    1    1    internal
    ${TAS_t2r4_n2}    Obtain Ue Capability    ${pattern}
    Airphone Sa Attach    ue_id=1    ue_capability=${TAS_t2r4_n2}
    Airphone Pdu Session Setup    ue_id=1    pdu_id=1    nwslice_id=1    gw_id=1
	...     pass_regexp=Bwp switch received from bwpId 1 to 2
    #Stop Gnb BIP Log    log_dir=${TEST_LOG_DIRECTORY()}${/}Step2_attach_UE${/}
    [Teardown]    Stop Collect GNB and AP Syslog in 'Step2_attach_UE' File

Step3:Start Big DL Data Transfer and Check Switch To Large BWP
    Start Collect GNB and AP Syslog in 'Step3_inject_buffer' File
    #Start GNB BIP Log
	Airphone Csi Override Testmode Nr    profile_id=1    cqi=15    ri=1    cri=1    li=1    pmi=500
	Airphone Execute Egate Command    ue_testmode_set_nr id\=1 testmode\=csi_override action\=activate profile_id\=1
    Airphone SA Start Data Traffic    1    DL    170M    trf_id=1    pdu_id=1    duration=${3600}
    Airphone SA Start Data Traffic    1    UL    170M    trf_id=1    pdu_id=1    duration=${3600}
	Wait Throughput Timer    10
    #Stop Gnb BIP Log    log_dir=${TEST_LOG_DIRECTORY()}${/}Step3_inject_buffer${/}
	Start GNB Ttitrace With Streaming Mode
    Wait Throughput Timer    3
    ${pacp}=    Stop GNB Ttitrace With Streaming Mode    save_path=${TEST_LOG_DIRECTORY()}${/}Step3_inject_buffer${/}
    Decoder Tttirace From Pcap To Csv    ${pacp}    ${TEST_LOG_DIRECTORY()}${/}Step3_inject_buffer${/}tti
    [Teardown]    Stop Collect GNB and AP Syslog in 'Step3_inject_buffer' File

Step4:Check CNI110347 function in TTItrace
	#DL slot6,7,16,17 no data used in PDSCH
	#DL slot5,15 have data used in PDSCH
	#UL slot8,9 and 18 have data used in PUSCH
    ${dl_ttitrace_path}    Set Variable    ${TEST_LOG_DIRECTORY()}${/}Step3_inject_buffer${/}tti_dl.csv
	${ul_ttitrace_path}    Set Variable    ${TEST_LOG_DIRECTORY()}${/}Step3_inject_buffer${/}tti_ul.csv
	${CNI110347_DL_check_point}    Check_Slot6_7_And_Slot16_17_PDSCH_no_used_data    ${dl_ttitrace_path}
	${CNI110347_UL_check_point}    Check_Slot8_9_And_Slot18_PUSCH_Used_data    ${ul_ttitrace_path}
	log    ${CNI110347_DL_check_point}
	log    ${CNI110347_UL_check_point}
	run keyword and continue on failure    should_be_true    ${CNI110347_DL_check_point}
	run keyword and continue on failure    should_be_true    ${CNI110347_UL_check_point}


Step5:Stop Data Traffic And Check Switch To Power Saving BWP
    Start Collect GNB and AP Syslog in 'Step5_stop_data' File
    #Start GNB BIP Log
    Airphone Sa Stop Data Traffic    ue_id=1    direction=dl    pdu_id=1    qfi_id=1
    Airphone Sa Stop Data Traffic    ue_id=1    direction=ul    pdu_id=1    qfi_id=1
    Wait Throughput Timer    10
    #Stop Gnb BIP Log    log_dir=${TEST_LOG_DIRECTORY()}${/}Step5_stop_data${/}
	Start GNB Ttitrace With Streaming Mode
    Wait Throughput Timer    3
    ${pacp}=    Stop GNB Ttitrace With Streaming Mode    save_path=${TEST_LOG_DIRECTORY()}${/}Step5_stop_data${/}
    Decoder Tttirace From Pcap To Csv    ${pacp}    ${TEST_LOG_DIRECTORY()}${/}Step5_stop_data${/}tti
    [Teardown]    Stop Collect GNB and AP Syslog in 'Step5_stop_data' File

Step6:ReStart Big DL Data Transfer and Check Switch To Large BWP
    Start Collect GNB and AP Syslog in 'Step6_inject_buffer' File
    #Start GNB BIP Log
    Airphone SA Start Data Traffic    1    DL    150M    trf_id=1    pdu_id=1    duration=${3600}
	Wait Throughput Timer    10
    #Stop Gnb BIP Log    log_dir=${TEST_LOG_DIRECTORY()}${/}Step6_inject_buffer${/}
	Start GNB Ttitrace With Streaming Mode
    Wait Throughput Timer    3
    ${pacp}=    Stop GNB Ttitrace With Streaming Mode    save_path=${TEST_LOG_DIRECTORY()}${/}Step6_inject_buffer${/}
    Decoder Tttirace From Pcap To Csv    ${pacp}    ${TEST_LOG_DIRECTORY()}${/}Step6_inject_buffer${/}tti
	airphone_collect_egate_log_files      ${TEST_LOG_DIRECTORY()}${/}Step6_inject_buffer${/}   unzip=TRUE
	check_log_with_au2anlysis    ini_path=${CURDIR}/log_check/bwp_switch.ini    log_need_to_check=u
	...    save_log_directory=${TEST_LOG_DIRECTORY()}${/}Step6_inject_buffer${/}
    [Teardown]    Stop Collect GNB and AP Syslog in 'Step6_inject_buffer' File

Step7:Detach UE
    Start Collect GNB and AP Syslog in 'Step7_detach_UE' File
    #Start GNB BIP Log
	Airphone Sa Detach    ue_id=1
    #Stop Gnb BIP Log    log_dir=${TEST_LOG_DIRECTORY()}${/}Step7_detach_UE${/}
	[Teardown]    Stop Collect GNB and AP Syslog in 'Step7_detach_UE' File
