*** Settings ***
Documentation     Author: zhaona.jiang@nokia-sbell.com
...
...               QC case full name:
...               CB008247_B_b1_case104_UE specific CSI-RS allocation for cell with 8x4 CL-MIMO_Multi UE_t1r2_TAS_Supported_No_Enough_UE_CSI-RS
...
...               In case cell is configured to 8x4 CL-MIMO, an CSI-RS resource pool is created for UE specific CSI-RS resource allocation.
...               When an UE is admitted, firstly UE specific CSI-RS resource for resource pool is allocated to this UE.
...               If there are no free CSI-RS resource available in the pool, then cell specific CSI-RS is allocated to this UE

Suite Setup       Common Suite Setup
Suite Teardown    Common Suite Teardown
Test Setup        Common Test Setup
Test Teardown     Common Test Teardown
Force Tags        CLOUD_5G_I_LO_AP_LO_SANSA_FS_ECPRI_CMWV_TDD    AP    CRT    SBTS00    SBTS23R1    RAN_5G_TDD    RAN_5G    AP_REG
...    owner_jiangzhaona
Test Timeout      120 minutes
Resource          ../../resources/sg11/internal_resource/robot/modify_configuration.robot
Resource          ../../resources/sg11/internal_resource/robot/internal_gnb_operate.robot
Resource          ../../resources/sg11/internal_resource/robot/internal_ap_operate.robot

*** Variables ***
${CONFIG_DIR_PATH}    ${CURDIR}/../../resources/sg11/internal_resource/config/
${SCFC_NAME}        gNB_scf_ASIL_ABIO_TDD_eCPRI_cmwv_SANSA_L1b_2S_1CC.xml
${AIRPHONE_NAME}    AP_iphy_AEQE_LO_AP_LO_TDD_eCPRI_cmwv_SANSA_L1b_2S_1CC.xml
${WTS_NAME}         wts_config_ASIB_ABIO_TDD_eCPRI_cmwv_SANSA_L1b_2S_1CC.cfg
${COMAVALUE}    ${CURDIR}/log_check/ap_coma.txt
${UE1_ID}          1
${PDU_ID}         1
${GW_ID}          1
${SLICE_ID}       1
@{LOG_NAME_LIST}    gnb_snapshot    sosreport    tshark    egatelog
${FILTER1}    ((dldata_pdcchsendreq) && !(3gpp.rnti == 65535)) && !(DlData_DciInfo.patternId_item == 101)
${FILTER2}    (((dldata_pdschsendreq) && !(3gpp.rnti == 65535))) && !(DlData_PdschGrant.patternId_item == 101)
${FILTER3}     DlData_CsiRsResource_t.density == 1
@{title1}    DlData_DciInfo.patternId_item
@{title2}    DlData_PdschGrant.patternId_item
@{title3}    DlData_CsiRsResource_t.patternId_item

${actUlSrsBm}    text|true|//*[@name\="actUlSrsBm"]
${actDlSrsBm}    text|true|//*[@name\="actDlSrsBm"]
${actCsirsMultiplexing}    text|true|//*[@name\="actCsirsMultiplexing"]
${actFdmScheduling}    text|true|//*[@name\="actFdmScheduling"]
${chBw}    text|60MHz|//*[@name\="chBw"]
${bSRS}    text|0|//*[@name\="bSRS"]
${cSRS}    text|13|//*[@name\="cSRS"]
${srsUePeriodicity}    text|slots10|//*[@name\="srsUePeriodicity"]
${numberOfTransmittedSsBlocks}    text|6 beams|//*[contains(@distName, 'NRCELLGRP')]/*[@name='numberOfTransmittedSsBlocks']
${basicBeamSet}    text|beamSet_6|//*[@name\="basicBeamSet"]
${nrCellType}    text|8DL4UL|//*[@name\="nrCellType"]
${dlMimoMode}    text|8x4 Closed Loop Spatial Multiplexing|//*[@name\="dlMimoMode"]
${nrBtsBeamRefinementP2}    text|false|//*[@name\="nrBtsBeamRefinementP2"]
${maxCsirsNumber}    text|2|//*[@name\="maxCsirsNumber"]
${csirsNumberWithinReportPeriod_Set1}    text|1|//*[@name\="csirsNumberWithinReportPeriod_Set1"]
${actCDrx}    text|false|//*[@name\="actCDrx"]
${frameStructureType}    text|semiStatic|//*[@name\="frameStructureType"]
${guardPeriodLength}    text|2Symbols|//*[@name\="guardPeriodLength"]
${prachConfigurationIndex}    text|98|//*[@name\="prachConfigurationIndex"]
${ulDlDataSlotRatio}    text|1/4|//*[@name\="ulDlDataSlotRatio"]
${type0CoresetConfigIndex}    text|2|//*[@name\="type0CoresetConfigurationIndex"]
${bwp_profile50}    attrib\=distName|replace('BWP_PROFILE-54', 'BWP_PROFILE-50')|//managedObject
${bwp_profile50_p}    text|replace('BWP_PROFILE-54', 'BWP_PROFILE-50')|//p
${bwp_duration1}    text|3|//*[contains(@distName, 'BWP_PROFILE-5')]//item[1]/*[@name\='duration']
${bwp_duration3}    text|3|//*[contains(@distName, 'BWP_PROFILE-5')]//item[3]/*[@name\='duration']
${bwp_duration_dedi}    text|1|//*[contains(@distName, 'BWP_PROFILE-50/PDCCH-1/PDCCH_CONFIG_DEDICATED-1')]//*[@name\='duration']
${nPdcchCandidatesInAL16}    text|n0|//*[contains(@distName, 'BWP_PROFILE-5')]//*[@name\="numOfPdcchCandidatesInAL16"]
${nPdcchCandidatesInAL4_1}    text|n2|//*[contains(@distName, 'BWP_PROFILE-5')]//item[1]/*[@name\="numOfPdcchCandidatesInAL4"]
${nPdcchCandidatesInAL4_3}    text|n2|//*[contains(@distName, 'BWP_PROFILE-5')]//item[3]/*[@name\="numOfPdcchCandidatesInAL4"]
${nPdcchCandidatesInAL4_2}
...    text|n4|//*[contains(@distName, 'BWP_PROFILE-50/PDCCH-1/PDCCH_CONFIG_COMMON-1')]//item[2]/*[@name\="numOfPdcchCandidatesInAL4"]
${nPdcchCandidatesInAL8}    text|n0|//*[contains(@distName, 'BWP_PROFILE-5')]//*[@name\="numOfPdcchCandidatesInAL8"]
${nPdcchCandidatesInAL2_2}    text|n0|//*[contains(@distName, 'BWP_PROFILE-5')]//item[2]/*[@name\="numOfPdcchCandidatesInAL2"]
${bwp_dedi_size}    text|48|//*[contains(@distName, 'BWP_PROFILE-50/PDCCH-1/PDCCH_CONFIG_DEDICATED-1')]//*[@name\='size']
${nPdcchCandidatesInAL4_dedi}    text|n2|//*[contains(@name, 'searchSpaceDedicated')]//item[2]/*[@name\='numOfPdcchCandidatesInAL4']
${csiReportPeriodicity}    text|slots160|//*[@name\="csiReportPeriodicity"]

*** Test Cases ***
CB008247_B_b1_case104_UE specific CSI-RS allocation for cell with 8x4 CL-MIMO_Multi UE_t1r2_TAS_Supported_No_Enough_UE_CSI-RS
    Step1:Commission the above configuration on WebUI
    Step2:attach 2ue with t4r4 3ue with t2r4
    Step3:Inject full dl and ul data
    Step4:Detach UE

*** Keywords ***
Step1:Commission the above configuration on WebUI
    Start Collect GNB and AP Syslog in 'Step1_before_onair' File
    ${CONFIG_DIR_PATH}    Set Variable    ${CONFIG_DIR_PATH}/${SW_BRANCH}
    change_iphy_rru_version    ${CONFIG_DIR_PATH}${/}${AIRPHONE_NAME}
    #Airphone Download L1ByPTestModeConfiguration from ABIL    ${test_log_directory()}/L1ByPTestModeConfiguration.xml
    #Modify L1ByPTestModeConfiguration    5    5    0    0
    #Airphone Upload L1ByPTestModeConfiguration to ASIK    ${test_log_directory()}/L1ByPTestModeConfiguration.xml
    modify_swconfig_by_CB008247    ${CONFIG_DIR_PATH}${/}${SCFC_NAME}    1csirs
    ${scfc_path}    Set Variable    ${TEST_LOG_DIRECTORY()}${/}scfc.xml
    copy_file    ${CONFIG_DIR_PATH}/${SCFC_NAME}    ${scfc_path}
    add_xml_element     ${scfc_path}    ${scfc_path}     <p name="tiltOffset">0</p>|//*[@name\='beamSet']/item
    add_all_elements    ${scfc_path}     NRCELL    mMimoAntArrayMode     Full 64TRX Array (4x8x2)
    add_srsForBeamMgmt_list_in_cells    ${scfc_path}
    add_periodicCsiAcquisition_list_in_cells    ${scfc_path}
    add_all_elements    ${scfc_path}     NRCELL    actUeCsirsCoexistCellCsirs     true
    add_all_elements    ${scfc_path}     NRBTS    actChannelMapVal     Disabled
    del_elements_from_xml    xml_path=${scfc_path}    parameter=lteToNrFrameShift
    del_elements_from_xml    xml_path=${scfc_path}    parameter=tdLteUlDlConfig
    ${modify_list}    create list    ${chBw}    ${dlMimoMode}    ${actUlSrsBm}    ${actDlSrsBm}    ${nrCellType}    ${nrBtsBeamRefinementP2}
    ...            ${csirsNumberWithinReportPeriod_Set1}    ${frameStructureType}    ${guardPeriodLength}    ${ulDlDataSlotRatio}
    ...            ${prachConfigurationIndex}    ${numberOfTransmittedSsBlocks}    ${basicBeamSet}    ${bSRS}    ${cSRS}    ${srsUePeriodicity}
    ...            ${actFdmScheduling}    ${bwp_profile50}    ${bwp_profile50_p}    ${bwp_duration1}    ${bwp_duration3}    ${nPdcchCandidatesInAL16}
    ...            ${nPdcchCandidatesInAL4_1}    ${nPdcchCandidatesInAL4_3}    ${nPdcchCandidatesInAL4_2}    ${nPdcchCandidatesInAL8}
    ...            ${nPdcchCandidatesInAL2_2}    ${bwp_duration_dedi}    ${actCsirsMultiplexing}    ${maxCsirsNumber}    ${bwp_dedi_size}
    ...            ${nPdcchCandidatesInAL4_dedi}    ${csiReportPeriodicity}
    modify_xml    ${scfc_path}    ${scfc_path}    ${modify_list}
    Modify TL VM And AP SCTP Configuration
    Perform Full Commission And Reach Onair With Log    ${scfc_path}    ${CONFIG_DIR_PATH}${/}${WTS_NAME}
    [Teardown]    Stop Collect GNB and AP Syslog in 'Step1_before_onair' File

Step2:attach 2ue with t4r4 3ue with t2r4
    Start Collect GNB and AP Syslog in 'Step2_attach' File
    #Start GNB BIP Log    bip_use_admin_api=true
    Attach SA ue with capability to 5g cell    2    CA_P2_8x4_t4r4_n4
    Attach SA ue with capability to 5g cell    3    CA_P2_8x4_t2r4_n2    3
    ${save_log}=    Set Variable    ${TEST_LOG_DIRECTORY()}Step2_attach
    #Stop Gnb BIP Log    log_dir=${save_log}${/}
    airphone_collect_egate_log_files      ${save_log}   unzip=TRUE
    check_log_with_au2anlysis    ini_path=${CURDIR}/log_check/rrc_case104.ini    log_need_to_check=p    save_log_directory=${save_log}
    [Teardown]    Stop Collect GNB and AP Syslog in 'Step2_attach' File

Step3:Inject full dl and ul data
    Start Collect GNB and AP Syslog in 'Step3_inject_buffer' File
    send 5ues buffer
    #Start GNB BIP Log    bip_use_admin_api=true
    Wait Throughput Timer    3
    ${save_log}=    Set Variable    ${TEST_LOG_DIRECTORY()}Step3_inject_buffer
    #Stop Gnb BIP Log    log_dir=${save_log}${/}
    Start GNB Ttitrace With Streaming Mode
    Wait Throughput Timer    5
    ${pacp}=    Stop GNB Ttitrace With Streaming Mode    save_path=${save_log}
    Decoder Tttirace From Pcap To Csv    ${pacp}    ${save_log}/tti
    run keyword if    '${SW_VERSION}'=='SBTS22R3'   Set Suite Variable	 ${filter_name}    dlSrsBm1stBestBeamPatternId
    run keyword if    '${SW_VERSION}'=='SBTS22R4'   Set Suite Variable	 ${filter_name}    dlSrsBmBestBeamPatternId
    run keyword if    '${SW_VERSION}'=='SBTS23R1'   Set Suite Variable	 ${filter_name}    dlSrsBmBestBeamPatternId
    run keyword if    '${SW_VERSION}'=='SBTS23R2'   Set Suite Variable	 ${filter_name}    dlSrsBmBestBeamPatternId
    run keyword if    '${SW_VERSION}'=='SBTS00'     Set Suite Variable	 ${filter_name}    dlSrsBmBestBeamPatternId
    check_log_with_au2anlysis    ini_path=${CURDIR}/log_check/tti_case104_APLO.ini    log_need_to_check=i    save_log_directory=${save_log}
    #Check patterId in bip    ${save_log}
    [Teardown]    Stop Collect GNB and AP Syslog in 'Step3_inject_buffer' File


Step0:attach 7ues
    Start Collect GNB and AP Syslog in 'Step2_attach' File
    ${save_log}=    Set Variable    ${TEST_LOG_DIRECTORY()}Step2_attach
    Attach SA '7'ue to 5g cell
    airphone_collect_egate_log_files      ${save_log}   unzip=TRUE
    [Teardown]    Stop Collect GNB and AP Syslog in 'Step2_attach' File

Step4:Detach UE
    Start Collect GNB and AP Syslog in 'Step4_detach' File
    #Stop '5'UE DL Traffic
    Detach '5'UE
    [Teardown]    Stop Collect GNB and AP Syslog in 'Step4_detach' File

send ${UENUM}ues buffer
    FOR    ${ueId}    IN RANGE    1    ${UENUM}+1
        SA send multiple trf data    ${ueId}    DL    10M    1
        SA send multiple trf data    ${ueId}    UL    10M    1
    END

Check patterId in bip
    [Arguments]    ${log_dir}
    Convert BIP To CSV    ${log_dir}/tcpdump_L2L1_bip_filtering_off.pcap0    ${log_dir}/bip_pdcch.csv    ${FILTER1}    ${title1}
    Convert BIP To CSV    ${log_dir}/tcpdump_L2L1_bip_filtering_off.pcap0    ${log_dir}/bip_pdsch.csv    ${FILTER2}    ${title2}
    Convert BIP To CSV    ${log_dir}/tcpdump_L2L1_bip_filtering_off.pcap0    ${log_dir}/bip_csirs.csv    ${FILTER3}    ${title3}
    Check Log With Au2anlysis    ini_path=${CURDIR}/log_check/bip_case104_pdcch.ini     log_need_to_check=i    save_log_directory=${log_dir}
    Check Log With Au2anlysis    ini_path=${CURDIR}/log_check/bip_case104_pdsch.ini     log_need_to_check=i    save_log_directory=${log_dir}
    Check Log With Au2anlysis    ini_path=${CURDIR}/log_check/bip_case104_csirs.ini     log_need_to_check=i    save_log_directory=${log_dir}


