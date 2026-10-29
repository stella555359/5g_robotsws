*** Settings ***
Documentation     Author: lili.1.yu@nokia-sbell.com
...
...               QC case full name:
...               CB008247_D_b2_case124_Coexistence with DL CA_T+T_reuse_t1r2_TAS_CL_MIMO_p8X4_s4X2_uecsirs
...
...               This scenario describes when this feature is activated, for any CA case, NDM SRS is only configured to UE in TDD PCell.For
...               UE in Scell no NDM SRS is configured. Hence SRS based beamforming solutions are only applied to Pcell when the Pcell is TDD cell.
...               In Scell, no SRS based beamforming is applied, UE feedback-based GoB or codebook-based PMI beam is used.
Suite Setup       Common Suite Setup
Suite Teardown    Common Suite Teardown
Test Setup        Common Test Setup
Test Teardown     Common Test Teardown
Force Tags        CLOUD_5G_I_MP_AP_LOOO    AP    CRT    SBTS00    SBTS23R1    RAN_5G_TDD    RAN_5G
...    owner_lilyu
Test Timeout      90 minutes
Resource          ../../resources/sg11/internal_resource/robot/modify_configuration.robot
Resource          ../../resources/sg11/internal_resource/robot/internal_gnb_operate.robot
Resource          ../../resources/sg11/internal_resource/robot/internal_ap_operate.robot
*** Variables ***
${CONFIG_DIR_PATH}    ${CURDIR}/../../resources/sg11/internal_resource/config/
${SCFC_NAME}        gNB_scf_ASIM_ABIP_TDD_eCPRI_cmwv_SANSA_FS_4S_1CC_2.xml
${AIRPHONE_NAME}    AP_iphy_AEQE_MP_AP_LOOO_TDD_eCPRI_cmwv_SANSA_L1b_4S_1CC.xml
${WTS_NAME}         wts_config_ASIB_ABIO_TDD_eCPRI_cmwv_SANSA_L1b_4S_1CC.cfg

${COMAVALUE}    ${CURDIR}/log_check/ap_coma.txt
${UE_ID}          1
${PDU_ID}         1
${GW_ID}          1
${SLICE_ID}       1
@{LOG_NAME_LIST}    gnb_snapshot    #sosreport    tshark    egatelog
${FILTER1}    ((dldata_pdcchsendreq) && !(3gpp.rnti == 65535)) && !(DlData_DciInfo.patternId_item == 101)
${FILTER2}    (((dldata_pdschsendreq) && !(3gpp.rnti == 65535))) && !(DlData_PdschGrant.patternId_item == 101)
${FILTER3}     DlData_CsiRsResource_t.density == 1
@{title1}    DlData_DciInfo.patternId_item
@{title2}    DlData_PdschGrant.patternId_item
@{title3}    DlData_CsiRsResource_t.patternId_item
${actCarrierAggregation}    text|true|//*[@name\="actCarrierAggregation"]
${actInterNumerologyCa}    text|true|//*[@name\="actInterNumerologyCa"]
${actPdschAtSsbSlots}    text|false|//*[@name\="actPdschAtSsbSlots"]
${sCellAdditionMethod}    text|covBasedA1|//*[@name\="sCellAdditionMethod"]
${sCellDeactivationTimerGNB}    text|infinity|//*[@name\="sCellDeactivationTimerGNB"]
${maxNumScellsDl}    text|1|//*[@name\="maxNumScellsDl"]
${sCellActivationMethod}    text|blind|//*[@name\="sCellActivationMethod"]
${sCellDeactivationBadRlqCount}    text|100|//*[@name\="sCellDeactivationBadRlqCount"]
${sCellGoodChannelQualityThreshold}    text|18|//*[@name\="sCellGoodChannelQualityThreshold"]
${sCellBadChannelQualityThreshold}    text|14|//*[@name\="sCellBadChannelQualityThreshold"]
${sCellChannelEstimationPeriod}    text|2000|//*[@name\="sCellChannelEstimationPeriod"]
${bSRS}    text|2|//*[@name\="bSRS"]
${cSRS}    text|49|//*[@name\="cSRS"]
${srsUePeriodicity}    text|slots40|//*[@name\="srsUePeriodicity"]
${chBw}    text|80MHz|//*[@name\="chBw"]
${rightEdgeAngle}    text|45|//*[@name\="rightEdgeAngle"]
${leftEdgeAngle}    text|45|//*[@name\="rightEdgeAngle"]
${actUlSrsBm_1}    text|true|//*[contains(@distName, 'NRCELL-1')]/*[@name='actUlSrsBm']
${actUlSrsBm_2}    text|true|//*[contains(@distName, 'NRCELL-2')]/*[@name='actUlSrsBm']
${actUlSrsBm_3}    text|false|//*[contains(@distName, 'NRCELL-3')]/*[@name='actUlSrsBm']
${actUlSrsBm_4}    text|false|//*[contains(@distName, 'NRCELL-4')]/*[@name='actUlSrsBm']
${actDlSrsBm_1}    text|true|//*[contains(@distName, 'NRCELL-1')]/*[@name='actDlSrsBm']
${actDlSrsBm_2}    text|true|//*[contains(@distName, 'NRCELL-2')]/*[@name='actDlSrsBm']
${actDlSrsBm_3}    text|false|//*[contains(@distName, 'NRCELL-3')]/*[@name='actDlSrsBm']
${actDlSrsBm_4}    text|false|//*[contains(@distName, 'NRCELL-4')]/*[@name='actDlSrsBm']
${nrCellType}    text|4DL4UL|//*[@name\="nrCellType"]
${dlMimoMode}    text|8x4 Closed Loop Spatial Multiplexing|//*[@name\="dlMimoMode"]
${nrBtsBeamRefinementP21}    text|true|//*[contains(@distName, 'NRCELL-1')]//p[@name\='nrBtsBeamRefinementP2']
${nrBtsBeamRefinementP22}    text|false|//*[contains(@distName, 'NRCELL-2')]//p[@name\='nrBtsBeamRefinementP2']
${maxCsirsNumber}    text|2|//*[@name\="maxCsirsNumber"]
${csirsNumberWithinReportPeriod_Set1}    text|1|//*[@name\="csirsNumberWithinReportPeriod_Set1"]
${actCDrx}    text|false|//*[@name\="actCDrx"]
${basicBeamSet}    text|beamSet_4_2|//*[@name\="basicBeamSet"]
${numberOfRxBeamforming}    text|4Rx|//*[@name\="numberOfRxBeamforming"]
${caConfigurationSupport}    text|2CCDL_2CCUL|//*[@name\="caConfigurationSupport"]
${numberOfTransmittedSsBlocks}    text|6 beams|//*[contains(@distName, 'NRCELLGRP')]/*[@name='numberOfTransmittedSsBlocks']
${frameStructureType}    text|tdLte|//*[@name\="frameStructureType"]
${prachConfigurationIndex}    text|98|//*[@name\="prachConfigurationIndex"]
${lteToNrFrameShift}          text|3ms|//*[@name\="lteToNrFrameShift"]
${guardPeriodLength}    text|6Symbols|//*[@name\="guardPeriodLength"]
${actPdschRmCsirsForTracking}    text|false|//*[@name\="actPdschRmCsirsForTracking"]
${bwp_profile8}     text|MRBTS-1/NRBTS-2/BWP_PROFILE-8|//*[@name\="cellBwpList"]/item[1]/*[@name\="bwpDN"]
${bwp_profile85}    text|MRBTS-1/NRBTS-2/BWP_PROFILE-85|//*[@name\="cellBwpList"]/item[2]/*[@name\="bwpDN"]
${actBbPoolTddFr1}               text|true|//*[@name\="actBbPoolTddFr1"]
${actShortBsrLimitAdaptation}    text|true|//*[@name\="actShortBsrLimitAdaptation"]
${actCsirsMultiplexing}          text|true|//*[@name\="actCsirsMultiplexing"]

*** Test Cases ***
CB008247_D_b2_case124_Coexistence with DL CA_T+T_reuse_t1r2_TAS_CL_MIMO_p8X4_s4X2_uecsirs
    Step1:Commission the above configuration on WebUI
    Step2:UE1 attach nr cell with no tas capability
    step3:Send A1 and Start UL DL data traffic
    step4:Change the HV direction
    Step5:Detach UE

*** Keywords ***
Step1:Commission the above configuration on WebUI
    Start Collect GNB and AP Syslog in 'Step1_before_onair' File
    ${CONFIG_DIR_PATH}    Set Variable    ${CONFIG_DIR_PATH}/${SW_BRANCH}
    change_iphy_rru_version    ${CONFIG_DIR_PATH}${/}${AIRPHONE_NAME}
    modify_swconfig_by_CB008247    ${CONFIG_DIR_PATH}${/}${SCFC_NAME}    p8
    ${scfc_path}    Set Variable    ${TEST_LOG_DIRECTORY()}${/}scfc.xml
    copy_file    ${CONFIG_DIR_PATH}/${SCFC_NAME}    ${scfc_path}
    add_xml_element     ${scfc_path}    ${scfc_path}     <p name="tiltOffset">0</p>|//*[@name\='beamSet']/item
	add_xml_element     ${scfc_path}    ${scfc_path}     <p name="upperEdgeAngle">60</p>|//*[@name\='beamSet']/item
	add_xml_element     ${scfc_path}    ${scfc_path}     <p name="lowerEdgeAngle">120</p>|//*[@name\='beamSet']/item
    add_all_elements    ${scfc_path}     NRBTS    actBbPoolTddFr1AlgEnh    true
    add_all_elements    ${scfc_path}     NRBTS    actBbPoolTddFr1Enh    true
    add_ca_relation_CB8247    ${scfc_path}
    ${modify_list}    create list    ${nrCellType}    ${maxCsirsNumber}    ${numberOfRxBeamforming}
    ...            ${csirsNumberWithinReportPeriod_Set1}    ${frameStructureType}    ${guardPeriodLength}
    ...            ${prachConfigurationIndex}    ${numberOfTransmittedSsBlocks}    ${basicBeamSet}    ${bSRS}    ${srsUePeriodicity}
    ...            ${actUlSrsBm_1}
    ...            ${actUlSrsBm_2}
    ...            ${actUlSrsBm_3}
    ...            ${actUlSrsBm_4}
    ...            ${actDlSrsBm_1}
    ...            ${actDlSrsBm_2}
    ...            ${actDlSrsBm_3}
    ...            ${actDlSrsBm_4}
    ...            ${sCellDeactivationTimerGNB}
    ...            ${actPdschRmCsirsForTracking}
    ...            ${nrBtsBeamRefinementP21}
    ...            ${nrBtsBeamRefinementP22}
    ...            ${caConfigurationSupport}
    ...            ${actCarrierAggregation}
    ...            ${actInterNumerologyCa}
    ...            ${actPdschAtSsbSlots}
    ...            ${sCellAdditionMethod}
    ...            ${maxNumScellsDl}
    ...            ${sCellActivationMethod}
    ...            ${sCellDeactivationBadRlqCount}
    ...            ${sCellGoodChannelQualityThreshold}
    ...            ${sCellBadChannelQualityThreshold}
    ...            ${sCellChannelEstimationPeriod}
    ...            ${lteToNrFrameShift}
    ...            ${chBw}
    ...            ${cSRS}
    ...    ${bwp_profile8}
    ...    ${bwp_profile85}
    ...    ${actBbPoolTddFr1}
    ...    ${actShortBsrLimitAdaptation}
    ...    ${actCsirsMultiplexing}
    ...    ${dlMimoMode}
    modify_xml    ${scfc_path}    ${scfc_path}    ${modify_list}
    Modify TL VM And AP SCTP Configuration
    Perform Full Commission And Reach Onair With Log    ${scfc_path}    ${CONFIG_DIR_PATH}${/}${WTS_NAME}
    [Teardown]    Stop Collect GNB and AP Syslog in 'Step1_before_onair' File

Step2:UE1 attach nr cell with no tas capability
    Start Collect GNB and AP Syslog in 'Step2_attach' File
    Airphone Execute Egate Command    ul_sinr_testmode_nr profile_id\=2 noise_pucch\=-1052
    Airphone Execute Egate Command    ue_testmode_set_nr id\=1 testmode\=ul_sinr action\=activate profile_id\=2
	Airphone Csi Override Testmode Nr    profile_id=1    cqi=15    ri=4    cri=1    li=1    pmi=500
    Airphone Execute Egate Command    ue_testmode_set_nr id\=${UE_ID} testmode\=csi_override action\=activate profile_id\=1
	${ue_ability}    Obtain Ue Capability    CA_P2_8x4_t1r2_n1
	Airphone SA Attach    ue_id=${UE_ID}       ue_capability=${ue_ability}
	Airphone Set Traffic Type    ${UE_ID}    1    internal
    Airphone Pdu Session Setup    ue_id=${UE_ID}    pdu_id=1    nwslice_id=1    gw_id=1
    airphone_collect_egate_log_files      ${TEST_LOG_DIRECTORY()}${/}Step2_attach${/}   unzip=TRUE
    run keyword and continue on failure     check_log_with_au2anlysis    ini_path=${CURDIR}/log_check/TAS_t1r2_n1_srs_usage.ini
    ...    log_need_to_check=p    save_log_directory=${TEST_LOG_DIRECTORY()}${/}Step2_attach${/}
    [Teardown]    Stop Collect GNB and AP Syslog in 'Step2_attach' File

Step3:Send A1 and Start UL DL data traffic
    Start Collect GNB and AP Syslog in 'Step3_inject_buffer' File
    #Start GNB BIP Log
    Airphone Measurement Send Nr    id=${UE_ID}    meas_id=1    event=A1    srsrp_nr=80    pass_regexp=sCellToAddModList
    Airphone SA Start Data Traffic    ${UE_ID}    DL    175M    trf_id=1    pdu_id=1    duration=${3600}
    Airphone SA Start Data Traffic    ${UE_ID}    DL    175M    trf_id=2    pdu_id=1    duration=${3600}
    Airphone SA Start Data Traffic    ${UE_ID}    DL    175M    trf_id=3    pdu_id=1    duration=${3600}
    Airphone SA Start Data Traffic    ${UE_ID}    DL    175M    trf_id=4    pdu_id=1    duration=${3600}
    Airphone SA Start Data Traffic    ${UE_ID}    DL    175M    trf_id=5    pdu_id=1    duration=${3600}
    Airphone SA Start Data Traffic    ${UE_ID}    DL    175M    trf_id=6    pdu_id=1    duration=${3600}
    Airphone SA Start Data Traffic    ${UE_ID}    UL    50M    trf_id=1    pdu_id=1    duration=${3600}
    #Wait Throughput Timer    5
    ${save_log}=    Set Variable    ${TEST_LOG_DIRECTORY()}Step3_inject_buffer
    #Stop Gnb BIP Log    log_dir=${save_log}${/}
    Wait Throughput Timer    180
    ${Pcell_dl_throughput} =    Airphone Get Throughput On Specific Scell    ue_id=${UE_ID}    scell_id=0    type=pdsch    tput_type=ave
    ${Scell_dl_throughput} =    Airphone Get Throughput On Specific Scell    ue_id=${UE_ID}    scell_id=1    type=pdsch    tput_type=ave
    should be true    ${Pcell_dl_throughput} > 100000
    should be true    ${Scell_dl_throughput} > 100000
    Start GNB Ttitrace With Streaming Mode
    Wait Throughput Timer    3
    ${pacp}=    Stop GNB Ttitrace With Streaming Mode    save_path=${TEST_LOG_DIRECTORY()}Step3_inject_buffer
    Decoder Tttirace From Pcap To Csv    ${pacp}    ${TEST_LOG_DIRECTORY()}Step3_inject_buffer/output
    run keyword if    '${SW_VERSION}'=='SBTS22R3'   Set Suite Variable	 ${filter_name}    dlSrsBmBestBeamPatternIdOnly
    run keyword if    '${SW_VERSION}'=='SBTS22R4'   Set Suite Variable	 ${filter_name}    dlSrsBmBestBeamPatternId
    run keyword if    '${SW_VERSION}'=='SBTS23R1'   Set Suite Variable	 ${filter_name}    dlSrsBmBestBeamPatternId
    run keyword if    '${SW_VERSION}'=='SBTS23R2'   Set Suite Variable	 ${filter_name}    dlSrsBmBestBeamPatternId
    run keyword if    '${SW_VERSION}'=='SBTS00'     Set Suite Variable	 ${filter_name}    dlSrsBmBestBeamPatternId
    run keyword and continue on failure    check_log_with_au2anlysis    ini_path=${CURDIR}/log_check/case124_tti_dl_patternid_APLO.ini
    ...    log_need_to_check=i    save_log_directory=${TEST_LOG_DIRECTORY()}Step3_inject_buffer
    run keyword and continue on failure    check_log_with_au2anlysis    ini_path=${CURDIR}/log_check/case124_tti_ul_patternid_APLO.ini
    ...    log_need_to_check=i    save_log_directory=${TEST_LOG_DIRECTORY()}Step3_inject_buffer
    [Teardown]    Stop Collect GNB and AP Syslog in 'Step3_inject_buffer' File

step4:Change the HV direction
    Start Collect GNB and AP Syslog in 'Step4_change_HV' File
    Wait Throughput Timer    300
    Start GNB Ttitrace With Streaming Mode
    Wait Throughput Timer    3
    ${pacp}=    Stop GNB Ttitrace With Streaming Mode    save_path=${TEST_LOG_DIRECTORY()}Step4_change_HV
    Decoder Tttirace From Pcap To Csv    ${pacp}    ${TEST_LOG_DIRECTORY()}Step4_change_HV/output
    run keyword and continue on failure    check_log_with_au2anlysis    ini_path=${CURDIR}/log_check/case124_tti_dl_patternid_change_APLO.ini
    ...    log_need_to_check=i    save_log_directory=${TEST_LOG_DIRECTORY()}Step4_change_HV
    run keyword and continue on failure    check_log_with_au2anlysis    ini_path=${CURDIR}/log_check/case124_tti_ul_patternid_change_APLO.ini
    ...    log_need_to_check=i    save_log_directory=${TEST_LOG_DIRECTORY()}Step4_change_HV
    [Teardown]    Stop Collect GNB and AP Syslog in 'Step4_change_HV' File

Step5:Detach UE
    Start Collect GNB and AP Syslog in 'Step5_detach' File
    airphone_sa_stop_data_traffic    ${UE_ID}   DL    pdu_id=1
    airphone_sa_detach    ${UE_ID}
    [Teardown]    Stop Collect GNB and AP Syslog in 'Step5_detach' File

add_ca_relation_CB8247
    [Arguments]    ${scfc_path}
    add_nrrel_extend_parameter_on_cell    xml_path=${scfc_path}    cellid=1    lcrid=2
    add_nrrel_extend_parameter_on_cell    xml_path=${scfc_path}    cellid=2    lcrid=3
    add_nrrel_extend_parameter_on_cell    xml_path=${scfc_path}    cellid=3    lcrid=4
    add_nrrel_extend_parameter_on_cell    xml_path=${scfc_path}    cellid=4    lcrid=1