*** Settings ***
Documentation     Author: shuiheng.he@nokia-sbell.com

...               QC case full name:
...               CB008305_case124_C_1_Interworking_with_DL_CA_T_T_2CC_2UE_2C4_DL_power_control_disable_rank...
...
...               This case is to verify the DL MU-MIMO only applies to PCell in TDD.
Suite Setup       Common Suite Setup
Suite Teardown    Common Suite Teardown
Test Setup        Common Test Setup
Test Teardown     Common Test Teardown
Force Tags        CLOUD_5G_I_MP_AP_LO    AP    CRT    SBTS00    RAN_5G_TDD    RAN_5G
Test Timeout      90 minutes
Resource          ../../resources/sg11/internal_resource/robot/modify_configuration.robot
Resource          ../../resources/sg11/internal_resource/robot/internal_gnb_operate.robot
Resource          ../../resources/sg11/internal_resource/robot/internal_ap_operate.robot
Library           ta_a2a

*** Variables ***
${CONFIG_DIR_PATH}    ${CURDIR}/../../resources/sg11/internal_resource/config/
${SCFC_NAME}          gNB_scf_ASIL_ABIO_TDD_eCPRI_cmwv_SANSA_L1b_2S_1CC_8305_case124.xml
${AIRPHONE_NAME}      AP_iphy_AEQE_LO_AP_LO_TDD_eCPRI_cmwv_SANSA_L1b_2S_1CC_B.xml
${WTS_NAME}           wts_config_ASIB_ABIO_TDD_eCPRI_cmwv_SANSA_L1b_2S_1CC.cfg
${COMAVALUE}          ${CURDIR}/../../resources/sg11/internal_resource/config/AP/ap_coma.txt
@{LOG_NAME_LIST}    gnb_snapshot    sosreport    tshark    egatelog
${FILTER1}    ((dldata_pdcchsendreq) && !(3gpp.rnti == 65535)) && !(DlData_DciInfo.patternId_item == 101)
${FILTER2}    (((dldata_pdschsendreq) && !(3gpp.rnti == 65535))) && !(DlData_PdschGrant.patternId_item == 101)
${FILTER3}     DlData_CsiRsResource_t.density == 1
@{title1}      DlData_DciInfo.patternId_item
@{title2}      DlData_PdschGrant.patternId_item
@{title3}      DlData_CsiRsResource_t.patternId_item

${actCarrierAggregation}    text|true|//*[@name\="actCarrierAggregation"]
${actInterNumerologyCa}     text|true|//*[@name\="actInterNumerologyCa"]
${actPdschAtSsbSlots}       text|false|//*[@name\="actPdschAtSsbSlots"]
${sCellAdditionMethod}      text|blind|//*[@name\="sCellAdditionMethod"]
${maxNumScellsDl}           text|1|//*[@name\="maxNumScellsDl"]
${sCellActivationMethod}    text|blind|//*[@name\="sCellActivationMethod"]
${sCellDeactivationTimerGNB}    text|infinity|//*[@name\="sCellDeactivationTimerGNB"]
${bSRS}                     text|2|//*[@name\="bSRS"]
${cSRS1}                    text|63|//*[contains(@distName, 'NRCELL-1')]//p[@name\='cSRS']
${cSRS2}                    text|49|//*[contains(@distName, 'NRCELL-2')]//p[@name\='cSRS']
${srsUePeriodicity}         text|slots40|//*[@name\="srsUePeriodicity"]
${chBw1}           text|100MHz|//*[contains(@distName, 'NRCELL-1')]/*[@name='chBw']
${chBw2}           text|80MHz|//*[contains(@distName, 'NRCELL-2')]/*[@name='chBw']
${actUlSrsBm_1}    text|true|//*[contains(@distName, 'NRCELL-1')]/*[@name='actUlSrsBm']
${actUlSrsBm_2}    text|true|//*[contains(@distName, 'NRCELL-2')]/*[@name='actUlSrsBm']
${actDlSrsBm_1}    text|true|//*[contains(@distName, 'NRCELL-1')]/*[@name='actDlSrsBm']
${actDlSrsBm_2}    text|true|//*[contains(@distName, 'NRCELL-2')]/*[@name='actDlSrsBm']
${nrCellType}    text|8DL4UL|//*[@name\="nrCellType"]
${dlMimoMode1}    text|8x4 Closed Loop Spatial Multiplexing|//*[contains(@distName, 'NRCELL-1')]/*[@name='dlMimoMode']
${dlMimoMode2}    text|8x4 Closed Loop Spatial Multiplexing|//*[contains(@distName, 'NRCELL-2')]/*[@name='dlMimoMode']
${nrBtsBeamRefinementP2}    text|false|//*[@name\="nrBtsBeamRefinementP2"]
${maxCsirsNumber}    text|1|//*[@name\="maxCsirsNumber"]
${csirsNumberWithinReportPeriod_Set1}    text|1|//*[@name\="csirsNumberWithinReportPeriod_Set1"]
${actCDrx}                      text|false|//*[@name\="actCDrx"]
${basicBeamSet}                 text|beamSet_6|//*[@name\="basicBeamSet"]
${caConfigurationSupport}       text|2CCDL_2CCUL|//*[@name\="caConfigurationSupport"]
${numberOfTransmittedSsBlocks}
...    text|6 beams|//*[contains(@distName, 'NRCELLGRP')]/*[@name='numberOfTransmittedSsBlocks']
${frameStructureType}              text|semiStatic|//*[@name\="frameStructureType"]
${prachConfigurationIndex}         text|98|//*[@name\="prachConfigurationIndex"]
${guardPeriodLength}               text|2Symbols|//*[@name\="guardPeriodLength"]
${ulDlDataSlotRatio}               text|1/4|//*[@name\="ulDlDataSlotRatio"]
${actPdschRmCsirsForTracking}      text|false|//*[@name\="actPdschRmCsirsForTracking"]

${actTddPrePooling}                text|false|//*[@name\="actTddPrePooling"]
#${actUEPoolingTDD}                 text|false|//*[@name\="actUEPoolingTDD"]
${actSpatialStreamPooling}          text|false|//*[@name\="actSpatialStreamPooling"]
${actIncreasedFdmUsersPerSlot}      text|true|//*[@name\="actIncreasedFdmUsersPerSlot"]
${maxNumPdschAllocationPerSlot}     text|16|//*[@name\="maxNumPdschAllocationPerSlot"]
${actDlMuMimoEnh}                   text|true|//*[@name\="actDlMuMimoEnh"]
${actCustomBsr}                     text|true|//*[@name\="actCustomBsr"]
@{remove_list}    //*[contains(@distName, 'NRCELL-1')]//p[@name\='csirsNumberWithinReportPeriod_Set1']
...           //*[contains(@distName, 'NRCELL-1')]//p[@name\='csirsPower']
...           //*[contains(@distName, 'NRCELL-1')]//p[@name\='maxCsirsNumber']
${bwp_profile57}    attrib\=distName|replace('BWP_PROFILE-54', 'BWP_PROFILE-57')|//managedObject
${bwp_profile57_p}    text|replace('BWP_PROFILE-54', 'BWP_PROFILE-57')|//p
${nPdcchCandidatesInAL4_1}
...    text|n2|//*[contains(@distName, 'BWP_PROFILE-57/PDCCH-1/PDCCH_CONFIG_COMMON-1')]//item[1]/*[@name\="numOfPdcchCandidatesInAL4"]
${nPdcchCandidatesInAL8_1}
...    text|n0|//*[contains(@distName, 'BWP_PROFILE-57/PDCCH-1/PDCCH_CONFIG_COMMON-1')]//item[1]/*[@name\="numOfPdcchCandidatesInAL8"]
${nPdcchCandidatesInAL16_1}
...    text|n0|//*[contains(@distName, 'BWP_PROFILE-57/PDCCH-1/PDCCH_CONFIG_COMMON-1')]//item[1]/*[@name\="numOfPdcchCandidatesInAL16"]
${nPdcchCandidatesInAL2_2}
...    text|n0|//*[contains(@distName, 'BWP_PROFILE-57/PDCCH-1/PDCCH_CONFIG_COMMON-1')]//item[2]/*[@name\="numOfPdcchCandidatesInAL2"]
${nPdcchCandidatesInAL4_2}
...    text|n4|//*[contains(@distName, 'BWP_PROFILE-57/PDCCH-1/PDCCH_CONFIG_COMMON-1')]//item[2]/*[@name\="numOfPdcchCandidatesInAL4"]
${nPdcchCandidatesInAL8_2}
...    text|n0|//*[contains(@distName, 'BWP_PROFILE-57/PDCCH-1/PDCCH_CONFIG_COMMON-1')]//item[2]/*[@name\="numOfPdcchCandidatesInAL8"]
${nPdcchCandidatesInAL4_3}
...    text|n2|//*[contains(@distName, 'BWP_PROFILE-57/PDCCH-1/PDCCH_CONFIG_COMMON-1')]//item[3]/*[@name\="numOfPdcchCandidatesInAL4"]
${nPdcchCandidatesInAL8_3}
...    text|n0|//*[contains(@distName, 'BWP_PROFILE-57/PDCCH-1/PDCCH_CONFIG_COMMON-1')]//item[3]/*[@name\="numOfPdcchCandidatesInAL8"]
${nPdcchCandidatesInAL16_3}
...     text|n0|//*[contains(@distName, 'BWP_PROFILE-57/PDCCH-1/PDCCH_CONFIG_COMMON-1')]//item[3]/*[@name\="numOfPdcchCandidatesInAL16"]
${nrarfcn_2}
...     text|638700|//*[contains(@distName, 'MRBTS-1/NRBTS-2/NRCELL-2')]/*[@name\="nrarfcn"]

*** Test Cases ***
CB008305_case124_C_1_Interworking_with_DL_CA_T_T_2CC_2UE_2C4_DL_power_control_disable_rank_adaption_64pipe_interL2RT_SA
    Step1:Commission the above configuration on WebUI
    Step2:UE attach nr cell
    Step3:Push full buffer in DL
    Step4:Detach UE

*** Keywords ***
Step1:Commission the above configuration on WebUI
    Start Collect GNB and AP Syslog in 'Step1_before_onair' File
    ${CONFIG_DIR_PATH}    Set Variable    ${CONFIG_DIR_PATH}/${SW_BRANCH}
    change_iphy_rru_version    ${CONFIG_DIR_PATH}${/}${AIRPHONE_NAME}
    modify_swconfig_by_CB008247    ${CONFIG_DIR_PATH}${/}${SCFC_NAME}    p8
    ${scfc_path}    Set Variable    ${TEST_LOG_DIRECTORY()}${/}scfc.xml
    copy_file    ${CONFIG_DIR_PATH}/${SCFC_NAME}    ${scfc_path}
    add_all_elements    ${scfc_path}     NRCELL    actUlSrsBm     true
    add_all_elements    ${scfc_path}     NRCELL    actDlSrsBm     true
    add_xml_element     ${scfc_path}    ${scfc_path}     <p name="tiltOffset">0</p>|//*[@name\='beamSet']/item
    add_all_elements    ${scfc_path}     NRCELL    mMimoAntArrayMode     Full 64TRX Array (4x8x2)
    add_srsForBeamMgmt_list_in_cells    ${scfc_path}
    add_periodicCsiAcquisition_list_in_cells    ${scfc_path}
    del_elements_from_xml    xml_path=${scfc_path}    parameter=lteToNrFrameShift
    del_elements_from_xml    xml_path=${scfc_path}    parameter=tdLteUlDlConfig
    add_all_elements    ${scfc_path}     NRCELL    actUeCsirsCoexistCellCsirs    false
    add_ca_relation_CB8247    ${scfc_path}
    ${modify_list}    create list    ${nrCellType}    ${nrBtsBeamRefinementP2}    ${maxCsirsNumber}
    ...            ${csirsNumberWithinReportPeriod_Set1}    ${frameStructureType}    ${guardPeriodLength}    ${ulDlDataSlotRatio}
    ...            ${prachConfigurationIndex}    ${numberOfTransmittedSsBlocks}    ${basicBeamSet}    ${bSRS}    ${srsUePeriodicity}
    ...            ${actUlSrsBm_1}
    ...            ${actUlSrsBm_2}
    ...            ${actDlSrsBm_1}
    ...            ${actDlSrsBm_2}
    ...            ${actPdschRmCsirsForTracking}
    ...            ${caConfigurationSupport}
    ...            ${actCarrierAggregation}
    ...            ${actInterNumerologyCa}
    ...            ${actPdschAtSsbSlots}
    ...            ${sCellAdditionMethod}
    ...            ${maxNumScellsDl}
    ...            ${sCellActivationMethod}
    ...            ${sCellDeactivationTimerGNB}
    ...            ${dlMimoMode1}
    ...            ${dlMimoMode2}
    ...            ${chBw1}
    ...            ${chBw2}
    ...            ${cSRS1}
    ...            ${cSRS2}
    ...            ${bwpProfile57}
    ...            ${bwp_profile57_p}
    ...            ${nPdcchCandidatesInAL16_1}
    ...            ${nPdcchCandidatesInAL8_1}
    ...            ${nPdcchCandidatesInAL4_1}
    ...            ${nPdcchCandidatesInAL2_2}
    ...            ${nPdcchCandidatesInAL8_2}
    ...            ${nPdcchCandidatesInAL4_2}
    ...            ${nPdcchCandidatesInAL16_3}
    ...            ${nPdcchCandidatesInAL8_3}
    ...            ${nPdcchCandidatesInAL4_3}
    ...            ${nrarfcn_2}
    ...            ${actDlMuMimoEnh}
    ...            ${actTddPrePooling}
#    ...            ${actUEPoolingTDD}
    ...            ${actIncreasedFdmUsersPerSlot}
    ...            ${maxNumPdschAllocationPerSlot}
    ...            ${actSpatialStreamPooling}
    ...            ${actCustomBsr} 
    modify_xml    ${scfc_path}    ${scfc_path}    ${modify_list}
    add_xml_element    ${scfc_path}    ${scfc_path}
    ...    <p name="srsTypeAllocForDlBm">antenna switching or codebook</p>|//*[@name='srsForBeamMgmt']/item
    add_xml_element     ${scfc_path}    ${scfc_path}
    ...     <p name="customBeamSetName">BSR_AEQE_6_H6_ALN60_ARP60_P00_COVERAGE_00424_00001</p>|//*[@name\='beamSet']/item[1]    
    Modify TL VM And AP SCTP Configuration
    Get and Update BSR File    par_of_bsr_name=AEQE_6_H6_ALN60_ARP60_P00_COVERAGE_00424_00001
    Perform Full Commission And Reach Onair With Log    ${scfc_path}    ${CONFIG_DIR_PATH}${/}${WTS_NAME}
    [Teardown]    Stop Collect GNB and AP Syslog in 'Step1_before_onair' File

Step2:UE attach nr cell
    Start Collect GNB and AP Syslog in 'Step2_attach' File
#    Start GNB BIP Log
    Attach SA ue with capability to 5g cell    2    CA_P2_8x4_noTas_n2

    Wait Throughput Timer    3
    csi_override_testmode_active    1    1    1
    csi_override_testmode_active    2    2    1

#    Stop Gnb BIP Log    log_dir=${TEST_LOG_DIRECTORY()}${/}Step2_attach${/}
    airphone_collect_egate_log_files      ${TEST_LOG_DIRECTORY()}${/}Step2_attach${/}   unzip=TRUE
    [Teardown]    Stop Collect GNB and AP Syslog in 'Step2_attach' File

Step3:Push full buffer in DL
    Start Collect GNB and AP Syslog in 'Step3' File
#    Start GNB BIP Log    
    ul_mimo_srs_beam_pos_active    ue=1    profile=1    init=0    sub=0    step=5    scell=0
    ul_mimo_srs_beam_pos_active    ue=2    profile=2    init=1    sub=2    step=5    scell=0
    
    SA send multiple trf data    1    DL    150M    6
    SA send multiple trf data    2    DL    150M    6
    run keyword and continue on failure    Wait Until Keyword Succeeds    120s    2s    check thp
    #Stop Gnb BIP Log    log_dir=${TEST_LOG_DIRECTORY()}${/}Step3${/}
    ${dl_tput_ue1} =    Airphone Get Throughput On Specific Scell    ue_id=1   scell_id=0    type=pdsch    tput_type=ave
    ${dl_tput_ue2} =    Airphone Get Throughput On Specific Scell    ue_id=2   scell_id=0    type=pdsch    tput_type=ave
    Start GNB Ttitrace With Streaming Mode
    Wait Throughput Timer    4
    ${save_log}=    Set Variable    ${TEST_LOG_DIRECTORY()}Step3
    ${pacp}=    Stop GNB Ttitrace With Streaming Mode    save_path=${save_log}
    Decoder Tttirace From Pcap To Csv    ${pacp}    ${save_log}/tti
    get ttiTrace file number    ${save_log}/
    run keyword and continue on failure    check_log_with_au2anlysis
    ...    ini_path=${CURDIR}/log_check/tti_case124.ini    log_need_to_check=i    save_log_directory=${save_log}
    [Teardown]    Stop Collect GNB and AP Syslog in 'Step3' File

Step4:Detach UE
    Start Collect GNB and AP Syslog in 'Step4_detach' File
    FOR    ${UE_ID}    IN RANGE    1     3
        airphone_sa_stop_data_traffic    ${UE_ID}   DL    pdu_id=1
        airphone_sa_detach    ${UE_ID}
    END
    [Teardown]    Stop Collect GNB and AP Syslog in 'Step4_detach' File


add_ca_relation_CB8247
    [Arguments]    ${scfc_path}
    add_nrrel_extend_parameter_on_cell    xml_path=${scfc_path}    cellid=1    lcrid=2

Modify L1ByPTestModeConfiguration For 8305
    [Arguments]    ${H0}    ${V0}    ${H1}    ${V1}    ${H2}    ${V2}    ${H3}    ${V3}    ${ue}=0
    ...        ${srsNumCountSwitchProfile1}=0    ${srsNumCountSwitchProfile2}=0
    ...        ${srsNumCountSwitchProfile1}=0    ${srsNumCountSwitchProfile2}=0    ${srsNumCountSwitchProfile3}=0    ${srsNumCountSwitchProfile4}=0
    ...        ${puschNumCountSwitch1}=0    ${puschNumCountSwitch2}=0    ${puschNumCountSwitch3}=0    ${puschNumCountSwitch4}=0
    ...        ${UlRank1}=1    ${UlRank2}=1    ${UlRank3}=1    ${UlRank4}=1
    ...        ${Sinr1}=33    ${Sinr2}=33    ${Sinr3}=33    ${Sinr4}=33
    ...        ${ulPmiRank1Sinr1}=22    ${ulPmiRank1Sinr2}=22    ${ulPmiRank1Sinr3}=22    ${ulPmiRank1Sinr4}=22
    ...        ${ifenable}=1
    ...        ${ComaMultiplier}=4
    copy_file    ${COMAVALUE}    ${test_log_directory()}/coma.py
    Import Variables    ${test_log_directory()}/coma.py
    ${original_xml}    set variable    ${test_log_directory()}/L1ByPTestModeConfiguration.xml
    ${modify_list0} =    create list    @{empty}
    ${list0}    create list
    ...    text|${Hindex${H0}}|//*[@TestProfile\="Profile-1"]//UeId[@ueid\="${ue}"]//NrRxBfCumulSpatialCovMatHPlus45
    ...    text|${Hindex${H0}}|//*[@TestProfile\="Profile-1"]//UeId[@ueid\="${ue}"]//NrRxBfCumulSpatialCovMatHNegative45
    ...    text|${Vindex${V0}}|//*[@TestProfile\="Profile-1"]//UeId[@ueid\="${ue}"]//NrRxBfCumulSpatialCovMatVPlus45
    ...    text|${Vindex${V0}}|//*[@TestProfile\="Profile-1"]//UeId[@ueid\="${ue}"]//NrRxBfCumulSpatialCovMatVNegative45
    ...    text|${Hindex${H1}}|//*[@TestProfile\="Profile-2"]//UeId[@ueid\="${ue}"]//NrRxBfCumulSpatialCovMatHPlus45
    ...    text|${Hindex${H1}}|//*[@TestProfile\="Profile-2"]//UeId[@ueid\="${ue}"]//NrRxBfCumulSpatialCovMatHNegative45
    ...    text|${Vindex${V1}}|//*[@TestProfile\="Profile-2"]//UeId[@ueid\="${ue}"]//NrRxBfCumulSpatialCovMatVPlus45
    ...    text|${Vindex${V1}}|//*[@TestProfile\="Profile-2"]//UeId[@ueid\="${ue}"]//NrRxBfCumulSpatialCovMatVNegative45
    ...    text|${Hindex${H2}}|//*[@TestProfile\="Profile-3"]//UeId[@ueid\="${ue}"]//NrRxBfCumulSpatialCovMatHPlus45
    ...    text|${Hindex${H2}}|//*[@TestProfile\="Profile-3"]//UeId[@ueid\="${ue}"]//NrRxBfCumulSpatialCovMatHNegative45
    ...    text|${Vindex${V2}}|//*[@TestProfile\="Profile-3"]//UeId[@ueid\="${ue}"]//NrRxBfCumulSpatialCovMatVPlus45
    ...    text|${Vindex${V2}}|//*[@TestProfile\="Profile-3"]//UeId[@ueid\="${ue}"]//NrRxBfCumulSpatialCovMatVNegative45
    ...    text|${Hindex${H3}}|//*[@TestProfile\="Profile-4"]//UeId[@ueid\="${ue}"]//NrRxBfCumulSpatialCovMatHPlus45
    ...    text|${Hindex${H3}}|//*[@TestProfile\="Profile-4"]//UeId[@ueid\="${ue}"]//NrRxBfCumulSpatialCovMatHNegative45
    ...    text|${Vindex${V3}}|//*[@TestProfile\="Profile-4"]//UeId[@ueid\="${ue}"]//NrRxBfCumulSpatialCovMatVPlus45
    ...    text|${Vindex${V3}}|//*[@TestProfile\="Profile-4"]//UeId[@ueid\="${ue}"]//NrRxBfCumulSpatialCovMatVNegative45
    ${modify_list0}    Combine Lists    ${modify_list0}    ${list0}
    ${modify_list1}    create list
    ...    text|${ifenable}|//*[@FormatVersion\="1"]//enable_5GC002396
    ...    text|${ComaMultiplier}|//*[@FormatVersion\="1"]//ComaMultiplier
    ...    text|${srsNumCountSwitchProfile1}|//*[@TestProfile\="Profile-1"]//srsNumCountSwitchProfile
    ...    text|${srsNumCountSwitchProfile2}|//*[@TestProfile\="Profile-2"]//srsNumCountSwitchProfile
    ...    text|${srsNumCountSwitchProfile3}|//*[@TestProfile\="Profile-3"]//srsNumCountSwitchProfile
    ...    text|${srsNumCountSwitchProfile4}|//*[@TestProfile\="Profile-4"]//srsNumCountSwitchProfile
    ...    text|${puschNumCountSwitch1}|//*[@TestProfile\="Profile-1"]//puschNumCountSwitchProfile
    ...    text|${puschNumCountSwitch2}|//*[@TestProfile\="Profile-2"]//puschNumCountSwitchProfile
    ...    text|${puschNumCountSwitch3}|//*[@TestProfile\="Profile-3"]//puschNumCountSwitchProfile
    ...    text|${puschNumCountSwitch4}|//*[@TestProfile\="Profile-4"]//puschNumCountSwitchProfile
    ...    text|${UlRank1}|//*[@TestProfile\="Profile-1"]//UlRank
    ...    text|${UlRank2}|//*[@TestProfile\="Profile-2"]//UlRank
    ...    text|${UlRank3}|//*[@TestProfile\="Profile-3"]//UlRank
    ...    text|${UlRank4}|//*[@TestProfile\="Profile-4"]//UlRank
    ...    text|${Sinr1}|//*[@TestProfile\="Profile-1"]//Sinr
    ...    text|${Sinr2}|//*[@TestProfile\="Profile-2"]//Sinr
    ...    text|${Sinr3}|//*[@TestProfile\="Profile-3"]//Sinr
    ...    text|${Sinr4}|//*[@TestProfile\="Profile-4"]//Sinr
    ...    text|${ulPmiRank1Sinr1}|//*[@TestProfile\="Profile-1"]//ulPmiRank1Sinr
    ...    text|${ulPmiRank1Sinr2}|//*[@TestProfile\="Profile-2"]//ulPmiRank1Sinr
    ...    text|${ulPmiRank1Sinr3}|//*[@TestProfile\="Profile-3"]//ulPmiRank1Sinr
    ...    text|${ulPmiRank1Sinr4}|//*[@TestProfile\="Profile-4"]//ulPmiRank1Sinr
    ${modify_list}    Combine Lists    ${modify_list0}    ${modify_list1}
    Modify Xml    ${original_xml}    ${original_xml}    ${modify_list}

get ttiTrace file number
    [Arguments]    ${tti_log_path}
    ${files}     List Files In Directory      ${tti_log_path}          tti_dl*.csv
    ${tti_num}       evaluate        len(${files})
    ${tti_name}      set variable if     ${tti_num} ==1        tti_dl.csv       tti_dl.0.csv
    set global variable  ${tti_name}

check thp
    FOR    ${UE_ID}    IN RANGE    1    3
    ${Pcell_dl_throughput} =    Airphone Get Throughput On Specific Scell    ue_id=${UE_ID}    scell_id=0    type=pdsch    tput_type=ave
    should be true    ${Pcell_dl_throughput} > 190000
    END