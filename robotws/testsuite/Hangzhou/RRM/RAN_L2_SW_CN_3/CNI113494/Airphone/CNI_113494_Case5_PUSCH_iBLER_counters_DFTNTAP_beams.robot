*** Settings ***
Documentation     Author:zhaoyang.xu@nokia-sbell.com
...
...               QC case full name:
...               Base on CB008247_D_b3_Case 127_Coexistence with multiple BWP_reuse_t2r4_TAS_CL_MIMO_4x4

Suite Setup       Common Suite Setup
Suite Teardown    Common Suite Teardown
Test Setup        Common Test Setup
Test Teardown     Common Test Teardown
Force Tags        CLOUD_5G_I_LO_AP_LO    AP    SBTS00    OPTION_RELATED_ARTIFACTS_5G    VARIANT_SANSA_FS_ECPRI_CMWV_TDD_TEMP
Test Timeout      90 minutes
Resource          ../../resources/sg11/internal_resource/robot/modify_configuration.robot
Resource          ../../resources/sg11/internal_resource/robot/internal_ap_operate.robot
Resource          ../../resources/sg11/internal_resource/robot/internal_gnb_operate.robot
Library     taf.transport.ssh    WITH NAME    TAF_SSH
Library           ta_a2a

*** Variables ***
${CONFIG_DIR_PATH}    ${CURDIR}/../../resources/sg11/internal_resource/config/
${SCFC_NAME}        CNI_113494_Case5.xml
${AIRPHONE_NAME}    AP_iphy_AEQE_LO_AP_LO_TDD_eCPRI_cmwv_SANSA_L1b_2S_1CC.xml
${WTS_NAME}         wts_CNI_113494_Case5.cfg
${COMAVALUE}    ${CURDIR}/log_check/ap_coma.txt
@{LOG_NAME_LIST}    gnb_snapshot    sosreport    tshark    egatelog\
${cellDepType}                                  text|SA+NSA|//*[@name\="cellDepType"]
${chBw}                                         text|100MHz|//*[@name\="chBw"]
${nrarfcn}                                      text|636000|//*[@name\="nrarfcn"]
${gscnOrSsPbchArfcn}                            text|1|//*[@name\="gscnOrSsPbchArfcn"]
${msg1FrequencyStart}                           text|14|//*[@name\="msg1FrequencyStart"]
${dlMimoMode}                                   text|4x4 or 4x2 Closed Loop Spatial Multiplexing|//*[@name\="dlMimoMode"]
${nrCellType}                                   text|8DL4UL|//*[@name\="nrCellType"]
${actDlSrsBm}                                   text|true|//*[@name\="actDlSrsBm"]
${actUlSrsBm}                                   text|true|//*[@name\="actUlSrsBm"]
${pucchModeSelect}                              text|longPucch|//*[@name\="pucchModeSelect"]
${actCDrx}                                      text|false|//*[@name\="actCDrx"]
${actFdmScheduling}                             text|true|//*[@name\="actFdmScheduling"]
${frameStructureType}                           text|semiStatic|//*[@name\="frameStructureType"]
${guardPeriodLength}                            text|2Symbols|//*[@name\="guardPeriodLength"]
${ulDlDataSlotRatio}                            text|3/7|//*[@name\="ulDlDataSlotRatio"]
${prachConfigurationIndex}                      text|98|//*[@name\="prachConfigurationIndex"]
${ssBurstSetPeriod}                             text|20|//*[@name\="ssBurstSetPeriod"]
${srsUePeriodicity}                             text|slots40|//*[@name\="srsUePeriodicity"]
${cSRS}                                         text|63|//*[@name\="cSRS"]
${bSRS}                                         text|2|//*[@name\="bSRS"]
${actUeCsirsCoexistCellCsirs}                   text|false|//*[@name\="actUeCsirsCoexistCellCsirs"]
${actDl256Qam}                                  text|true|//*[@name\="actDl256Qam"]
${actBeamforming}                               text|true|//*[@name\="actBeamforming"]
${numberOfRxBeamforming}                        text|4Rx|//*[@name\="numberOfRxBeamforming"]
${numberOfTransmittedSsBlocks_0}           text|6 beams|//*[contains(@distName, 'NRCELLGRP-0')]/*[@name\="numberOfTransmittedSsBlocks"]
${numberOfTransmittedSsBlocks_1}           text|6 beams|//*[contains(@distName, 'NRCELLGRP-1')]/*[@name\="numberOfTransmittedSsBlocks"]
${basicBeamSet}                                 text|beamSet_6|//*[@name\="basicBeamSet"]
${lowerEdgeAngle}                               text|120|//*[@name\="lowerEdgeAngle"]
${upperEdgeAngle}                               text|60|//*[@name\="upperEdgeAngle"]
${actCsirsMultiplexing}                         text|true|//*[@name\="actCsirsMultiplexing"]
${nrBtsBeamRefinementP2}                        text|false|//*[@name\="nrBtsBeamRefinementP2"]
${csiReportPeriodicity}                         text|slots320|//*[@name\="csiReportPeriodicity"]
#${csirsNumberWithinReportPeriod_Set1}           text|1|//*[@name\="csirsNumberWithinReportPeriod_Set1"]
#${csirsPower}                                   text|3|//*[@name\="csirsPower"]
#${maxCsirsNumber}                               text|2|//*[@name\="maxCsirsNumber"]
${ssPbchBlockPower}                             text|3|//*[@name\="ssPbchBlockPower"]
${actPowerSavingBWP}                            text|true|//*[@name\="actPowerSavingBWP"]
${pattern}    CA_P2_8x4_t2r4_n2
${ant5}                                         MRBTS-1/MNL-1/MNLENT-1/CELLMAPPING-1/LCELNR-1/CHANNELGROUP-2/CHANNEL-5
${ant6}                                         MRBTS-1/MNL-1/MNLENT-1/CELLMAPPING-1/LCELNR-1/CHANNELGROUP-2/CHANNEL-6
${ant7}                                         MRBTS-1/MNL-1/MNLENT-1/CELLMAPPING-1/LCELNR-1/CHANNELGROUP-2/CHANNEL-7
${ant8}                                         MRBTS-1/MNL-1/MNLENT-1/CELLMAPPING-1/LCELNR-1/CHANNELGROUP-2/CHANNEL-8
${miNrBeamforming2}    text|15min|//*[@name\="miNrBeamforming2"]
${miNrDlHarq}    text|15min|//*[@name\="miNrDlHarq"]
${miNrUlHarq}    text|15min|//*[@name\="miNrUlHarq"]
${miNrDlHarqLowSEMCS}    text|15min|//*[@name\="miNrDlHarqLowSEMCS"]
${miNrUlHarqLowSEMCS}    text|15min|//*[@name\="miNrUlHarqLowSEMCS"]
${miNrUlHarqOne}    text|15min|//*[@name\="miNrUlHarqOne"]
*** Test Cases ***
CNI_113494_Case5_PUSCH_iBLER_counters_for_Non-tapered_2D-DFT_beams
    Step1:Commission the above configuration on WebUI
    Step2:Attach a UE with TAS SRS and powerSaving capability
    Step3:Start Big DL Data Transfer and Check Switch To Large BWP
    Step4:Stop Data Traffic And Check Switch To Power Saving BWP
    Step5:ReStart Big DL Data Transfer and Check Switch To Large BWP
    Step6:Detach UE
*** Keywords ***
Step1:Commission the above configuration on WebUI
    Start Collect GNB and AP Syslog in 'Step1_before_onair' File
	${CONFIG_DIR_PATH}    Set Variable    ${CONFIG_DIR_PATH}/${SW_BRANCH}
    change_iphy_rru_version    ${CONFIG_DIR_PATH}${/}${AIRPHONE_NAME}
    modify_swconfig_by_CB008247    ${CONFIG_DIR_PATH}${/}${SCFC_NAME}
    ${scfc_path}    Set Variable    ${TEST_LOG_DIRECTORY()}${/}scfc.xml
    copy_file    ${CONFIG_DIR_PATH}/${SCFC_NAME}    ${scfc_path}
#    add_xml_element     ${scfc_path}    ${scfc_path}     <p name="tiltOffset">0</p>|//*[@name\='beamSet']/item
#    add_all_elements    ${scfc_path}     NRCELL    mMimoAntArrayMode     Full 64TRX Array (4x8x2)
#    add_all_elements    ${scfc_path}     NRCELL    actUeCsirsCoexistCellCsirs    false
#    add_srsForBeamMgmt_list_in_cells    ${scfc_path}
#    add_bwplist_list_in_cells    ${scfc_path}
#    del_elements_from_xml    xml_path=${scfc_path}    parameter=lteToNrFrameShift
#	del_eles_from_xml    ${scfc_path}    ${ant5}
#    del_eles_from_xml    ${scfc_path}    ${ant6}
#    del_eles_from_xml    ${scfc_path}    ${ant7}
#    del_eles_from_xml    ${scfc_path}    ${ant8}
#    ${modify_list}    create list
#    ...       ${cellDepType}
#    ...       ${chBw}
#    ...       ${nrarfcn}
#    ...       ${gscnOrSsPbchArfcn}
#    ...       ${msg1FrequencyStart}
#    ...       ${dlMimoMode}
#    ...       ${nrCellType}
#    ...       ${actDlSrsBm}
#    ...       ${actUlSrsBm}
#    ...       ${pucchModeSelect}
#    ...       ${actCDrx}
#    ...       ${actFdmScheduling}
#    ...       ${frameStructureType}
#    ...       ${guardPeriodLength}
#    ...       ${ulDlDataSlotRatio}
#    ...       ${prachConfigurationIndex}
#    ...       ${ssBurstSetPeriod}
#    ...       ${srsUePeriodicity}
#    ...       ${cSRS}
#    ...       ${bSRS}
#    ...       ${actDl256Qam}
#    ...       ${actBeamforming}
#    ...       ${numberOfRxBeamforming}
#    ...       ${numberOfTransmittedSsBlocks_0}
#    ...       ${numberOfTransmittedSsBlocks_1}
#    ...       ${basicBeamSet}
#    ...       ${lowerEdgeAngle}
#    ...       ${upperEdgeAngle}
#    ...       ${actCsirsMultiplexing}
#    ...       ${nrBtsBeamRefinementP2}
#    ...       ${csiReportPeriodicity}
#    ...       ${ssPbchBlockPower}
#    ...       ${actPowerSavingBWP}
#	...    ${miNrBeamforming2}    ${miNrDlHarq}    ${miNrUlHarq}    ${miNrDlHarqLowSEMCS}    ${miNrUlHarqLowSEMCS}   ${miNrUlHarqOne}
#    modify_xml    ${scfc_path}    ${scfc_path}    ${modify_list}
    Modify TL VM And AP SCTP Configuration
    Perform Full Commission And Reach Onair    ${scfc_path}    ${CONFIG_DIR_PATH}${/}${WTS_NAME}    reset_after_commission=${False}
    [Teardown]    Stop Collect GNB and AP Syslog in 'Step1_before_onair' File
Step2:Attach a UE with TAS SRS and powerSaving capability
    Start Collect GNB and AP Syslog in 'Step2_attach_UE' File
	Start GNB Ttitrace With Streaming Mode
	Airphone Set Traffic Type    1    1    internal
    ${TAS_t2r4_n2}    Obtain Ue Capability    ${pattern}
    Airphone Sa Attach    ue_id=1    ue_capability=${TAS_t2r4_n2}
    Airphone Pdu Session Setup    ue_id=1    pdu_id=1    nwslice_id=1    gw_id=1
	...     pass_regexp=Bwp switch received from bwpId 1 to 2
	Wait Throughput Timer    30
    ${pacp}=    Stop GNB Ttitrace With Streaming Mode    save_path=${TEST_LOG_DIRECTORY()}${/}Step2_attach_UE${/}
	Decoder Tttirace From Pcap To Csv    ${pacp}    ${TEST_LOG_DIRECTORY()}${/}Step2_attach_UE${/}tti
    [Teardown]    Stop Collect GNB and AP Syslog in 'Step2_attach_UE' File
Step3:Start Big DL Data Transfer and Check Switch To Large BWP
    Start Collect GNB and AP Syslog in 'Step3_inject_buffer' File
	Start GNB Ttitrace With Streaming Mode
	Airphone Csi Override Testmode Nr    profile_id=1    cqi=15    ri=1    cri=1    li=1    pmi=500
	Airphone Execute Egate Command    ue_testmode_set_nr id\=1 testmode\=csi_override action\=activate profile_id\=1
    Airphone SA Start Data Traffic    1    DL    75M    trf_id=1    pdu_id=1    duration=${3600}
    Airphone SA Start Data Traffic    1    UL    50M    trf_id=1    pdu_id=1    duration=${3600}
	Wait Throughput Timer    5
    ${pacp}=    Stop GNB Ttitrace With Streaming Mode    save_path=${TEST_LOG_DIRECTORY()}${/}Step3_inject_buffer${/}
    ${save_log}=    Set Variable    ${TEST_LOG_DIRECTORY()}/Step3_inject_buffer
    airphone_collect_egate_log_files      ${save_log}   unzip=TRUE
	Decoder Tttirace From Pcap To Csv    ${pacp}    ${TEST_LOG_DIRECTORY()}${/}Step3_inject_buffer${/}check_patttern_id${/}tti
	${remaining_time}=    get_counter_file_remaining_time    counter_refresh_period=1min
    Wait Throughput Timer    ${remaining_time}
    ${PM_counter_file}=    download_latest_pmcounter    local_path=${TEST_LOG_DIRECTORY()}/Step3_inject_buffer${/}
    Check_CNI113494_iBler_match_Legacy_counters    ${PM_counter_file}
    [Teardown]    Stop Collect GNB and AP Syslog in 'Step3_inject_buffer' File
Step4:Stop Data Traffic And Check Switch To Power Saving BWP
    Start Collect GNB and AP Syslog in 'Step4_stop_data' File
    Airphone Sa Stop Data Traffic    ue_id=1    direction=dl    pdu_id=1    qfi_id=1
    Airphone Sa Stop Data Traffic    ue_id=1    direction=ul    pdu_id=1    qfi_id=1
	Start GNB Ttitrace With Streaming Mode
    Wait Throughput Timer    30
    ${pacp}=    Stop GNB Ttitrace With Streaming Mode    save_path=${TEST_LOG_DIRECTORY()}${/}Step4_stop_data${/}
    Decoder Tttirace From Pcap To Csv    ${pacp}    ${TEST_LOG_DIRECTORY()}${/}Step4_stop_data${/}check_patttern_id${/}tti
	airphone_collect_egate_log_files      ${TEST_LOG_DIRECTORY()}${/}Step4_stop_data${/}   unzip=TRUE
	${remaining_time}=    get_counter_file_remaining_time    counter_refresh_period=1min
    Wait Throughput Timer    ${remaining_time}
    ${PM_counter_file}=    download_latest_pmcounter    local_path=${TEST_LOG_DIRECTORY()}/Step4_stop_data${/}
    Check_CNI113494_iBler_match_Legacy_counters    ${PM_counter_file}
    [Teardown]    Stop Collect GNB and AP Syslog in 'Step4_stop_data' File
Step5:ReStart Big DL Data Transfer and Check Switch To Large BWP
    Start Collect GNB and AP Syslog in 'Step5_inject_buffer' File
	Start GNB Ttitrace With Streaming Mode
    Airphone SA Start Data Traffic    1    DL    50M    trf_id=1    pdu_id=1    duration=${3600}
    Airphone SA Start Data Traffic    1    UL    50M    trf_id=1    pdu_id=1    duration=${3600}
	Wait Throughput Timer    15
    ${pacp}=    Stop GNB Ttitrace With Streaming Mode    save_path=${TEST_LOG_DIRECTORY()}${/}Step5_inject_buffer${/}
    Decoder Tttirace From Pcap To Csv    ${pacp}    ${TEST_LOG_DIRECTORY()}${/}Step5_inject_buffer${/}check_patttern_id${/}tti
	airphone_collect_egate_log_files      ${TEST_LOG_DIRECTORY()}${/}Step5_inject_buffer${/}   unzip=TRUE
	${remaining_time}=    get_counter_file_remaining_time    counter_refresh_period=1min
    Wait Throughput Timer    ${remaining_time}
    ${PM_counter_file}=    download_latest_pmcounter    local_path=${TEST_LOG_DIRECTORY()}/Step5_inject_buffer${/}
    Check_CNI113494_iBler_match_Legacy_counters    ${PM_counter_file}
    [Teardown]    Stop Collect GNB and AP Syslog in 'Step5_inject_buffer' File
Step6:Detach UE
    Start Collect GNB and AP Syslog in 'Step6_detach_UE' File
    Wait Throughput Timer    120
	Start GNB Ttitrace With Streaming Mode
	Airphone Sa Detach    ue_id=1
	Wait Throughput Timer    15
    ${pacp}=    Stop GNB Ttitrace With Streaming Mode    save_path=${TEST_LOG_DIRECTORY()}${/}Step6_detach_UE${/}
    Decoder Tttirace From Pcap To Csv    ${pacp}    ${TEST_LOG_DIRECTORY()}${/}Step6_detach_UE${/}check_patttern_id${/}tti
	[Teardown]    Stop Collect GNB and AP Syslog in 'Step6_detach_UE' File
Check_CNI113494_iBler_match_Legacy_counters
    [Arguments]    ${PM_counter_file}
	Log To Console    \n---------CNI_113494_PDSCH_initial_counter----------
	Log To Console    SSB_BEAM:M55330C00043,REFINED_BEAM:M55330C00047,PMI_BEAM:M55330C00030
	Log To Console    DFTNTAP_BEAM:M55330C00036,DFTTAP_BEAM:M55330C00032,SUBBAND_BEAM:M55330C00040
	${PDSCH_INI_Counter_list}    create list   M55330C00043    M55330C00047     M55330C00030   M55330C00036    M55330C00032   M55330C00040
    ${PDSCH_INI_All_Beam_counter_cell1}    	create list
    ${PDSCH_INI_All_Beam_counter_cell2}    	create list
    FOR    ${counter_id}    IN    @{PDSCH_INI_Counter_list}
    ${PDSCH_INI_cell1}    get_counter_value_from_counter_file    counter_file=${PM_counter_file}    counter_id=${counter_id}    cell_id=1
    append to list    ${PDSCH_INI_All_Beam_counter_cell1}    ${PDSCH_INI_cell1}
    ${PDSCH_INI_cell2}    get_counter_value_from_counter_file    counter_file=${PM_counter_file}    counter_id=${counter_id}    cell_id=2
    append to list    ${PDSCH_INI_All_Beam_counter_cell2}    ${PDSCH_INI_cell2}
	END
	Log To Console    PDSCH_INI_SSB_refined_PMI_DFTN_DFT_SUB_beam_counter_cell1:${PDSCH_INI_All_Beam_counter_cell1}
	Log To Console    PDSCH_INI_SSB_refined_PMI_DFTN_DFT_SUB_beam_counter_cell2:${PDSCH_INI_All_Beam_counter_cell2}
	${PDSCH_INI_counter_Sum_cell1}    Evaluate    sum(${PDSCH_INI_All_Beam_counter_cell1})
	${PDSCH_INI_counter_Sum_cell2}    Evaluate    sum(${PDSCH_INI_All_Beam_counter_cell2})
    Log To Console    \n----------------------end-------------------------
	Log To Console    \n---------CNI_113494_PDSCH_initial_Successful_counter----------
	Log To Console    SSB_BEAM:M55330C00044,REFINED_BEAM:M55330C00048,PMI_BEAM:M55330C00031
	Log To Console    DFTNTAP_BEAM:M55330C00037,DFTTAP_BEAM:M55330C00033,SUBBAND_BEAM:M55330C00041
	${PDSCH_SUC_Counter_list}    create list   M55330C00044    M55330C00048     M55330C00031   M55330C00037    M55330C00033    M55330C00041
    ${PDSCH_SUC_All_Beam_counter_cell1}    	create list
    ${PDSCH_SUC_All_Beam_counter_cell2}    	create list
    FOR    ${counter_id}    IN    @{PDSCH_SUC_Counter_list}
    ${PDSCH_SUC_cell1}    get_counter_value_from_counter_file    counter_file=${PM_counter_file}    counter_id=${counter_id}    cell_id=1
    append to list    ${PDSCH_SUC_All_Beam_counter_cell1}    ${PDSCH_SUC_cell1}
    ${PDSCH_SUC_cell2}    get_counter_value_from_counter_file    counter_file=${PM_counter_file}    counter_id=${counter_id}    cell_id=2
    append to list    ${PDSCH_SUC_All_Beam_counter_cell2}    ${PDSCH_SUC_cell2}
	END
	Log To Console    PDSCH_SUC_SSB_refined_PMI_DFTN_DFT_SUB_beam_counter_cell1:${PDSCH_SUC_All_Beam_counter_cell1}
	Log To Console    PDSCH_SUC_SSB_refined_PMI_DFTN_DFT_SUB_beam_counter_cell2:${PDSCH_SUC_All_Beam_counter_cell2}
	${PDSCH_SUC_counter_Sum_cell1}    Evaluate    sum(${PDSCH_SUC_All_Beam_counter_cell1})
	${PDSCH_SUC_counter_Sum_cell2}    Evaluate    sum(${PDSCH_SUC_All_Beam_counter_cell2})
	Log To Console    \n----------------------end-------------------------
    Log To Console    \n---------CNI_113494_PUSCH_initial_counter------------------
	Log To Console    SSB_BEAM:M55330C00045,REFINED_BEAM:M55330C00028,DFTNTAP_BEAM:M55330C00038,DFTTAP_BEAM:M55330C00034
	${PUSCH_INI_Counter_list}    create list   M55330C00045    M55330C00028     M55330C00038   M55330C00034
    ${PUSCH_INI_All_Beam_counter_cell1}    	create list
    ${PUSCH_INI_All_Beam_counter_cell2}    	create list
    FOR    ${counter_id}    IN    @{PUSCH_INI_Counter_list}
    ${PUSCH_INI_cell1}    get_counter_value_from_counter_file    counter_file=${PM_counter_file}    counter_id=${counter_id}    cell_id=1
    append to list    ${PUSCH_INI_All_Beam_counter_cell1}    ${PUSCH_INI_cell1}
    ${PUSCH_INI_cell2}    get_counter_value_from_counter_file    counter_file=${PM_counter_file}    counter_id=${counter_id}    cell_id=2
    append to list    ${PUSCH_INI_All_Beam_counter_cell2}    ${PUSCH_INI_cell2}
	END
	Log To Console    PUSCH_INI_SSB_refined_DFTN_DFT_beam_counter_cell1:${PUSCH_INI_All_Beam_counter_cell1}
	Log To Console    PUSCH_INI_SSB_refined_DFTN_DFT_beam_counter_cell2:${PUSCH_INI_All_Beam_counter_cell2}
	${PUSCH_INI_counter_Sum_cell1}    Evaluate    sum(${PUSCH_INI_All_Beam_counter_cell1})
	${PUSCH_INI_counter_Sum_cell2}    Evaluate    sum(${PUSCH_INI_All_Beam_counter_cell2})
    Log To Console    \n----------------------end-------------------------
	Log To Console    \n---------CNI_113494_PUSCH_Successful_initial_counter------------------
	Log To Console    SSB_BEAM:M55330C00046,REFINED_BEAM:M55330C00029,DFTNTAP_BEAM:M55330C00039,DFTTAP_BEAM:M55330C00035
	${PUSCH_SUC_Counter_list}    create list   M55330C00046    M55330C00029     M55330C00039   M55330C00035
    ${PUSCH_SUC_All_Beam_counter_cell1}    	create list
    ${PUSCH_SUC_All_Beam_counter_cell2}    	create list
    FOR    ${counter_id}    IN    @{PUSCH_SUC_Counter_list}
    ${PUSCH_SUC_cell1}    get_counter_value_from_counter_file    counter_file=${PM_counter_file}    counter_id=${counter_id}    cell_id=1
    append to list    ${PUSCH_SUC_All_Beam_counter_cell1}    ${PUSCH_SUC_cell1}
    ${PUSCH_SUC_cell2}    get_counter_value_from_counter_file    counter_file=${PM_counter_file}    counter_id=${counter_id}    cell_id=2
    append to list    ${PUSCH_SUC_All_Beam_counter_cell2}    ${PUSCH_SUC_cell2}
	END
	Log To Console    PUSCH_SUC_SSB_refined_DFTN_DFT_beam_counter_cell1:${PUSCH_SUC_All_Beam_counter_cell1}
	Log To Console    PUSCH_SUC_SSB_refined_DFTN_DFT_beam_counter_cell2:${PUSCH_SUC_All_Beam_counter_cell2}
	${PUSCH_SUC_counter_Sum_cell1}    Evaluate    sum(${PUSCH_SUC_All_Beam_counter_cell1})
	${PUSCH_SUC_counter_Sum_cell2}    Evaluate    sum(${PUSCH_SUC_All_Beam_counter_cell2})
    Log To Console    \n----------------------end-------------------------
	Log To Console    \n----Legacy_PDSCH_INITX_64TBL_MCS_00-28_and_256TBL_MCS_00-27_and_LOWSE_MCS_00-28----------
	Log To Console    PDSCH_INITX_64TBL_MCS_00-28:M55300C00000----M55300C00028
	Log To Console    PDSCH_INITX_256TBL_MCS_00-27:M55300C04000---M55300C04027
	Log To Console    PDSCH_INITX_LOWSE_MCS_00-28:M55366C01000----M55366C01028
    ${PDSCH_INITX_64TBL_MCS_00_28_cell1}    	create list
    ${PDSCH_INITX_64TBL_MCS_00_28_cell2}    	create list
    ${PDSCH_INITX_256TBL_MCS_00_27_cell1}    	create list
    ${PDSCH_INITX_256TBL_MCS_00_27_cell2}    	create list
    ${PDSCH_INITX_LOWSE_MCS_00_28_cell1}    	create list
    ${PDSCH_INITX_LOWSE_MCS_00_28_cell2}    	create list
	FOR    ${i}    IN RANGE     0     29
	${index}     evaluate     "${i}".zfill(2)                     #1bit change to 2bit,0 change to 00
	${64_value}     get_counter_value_from_counter_file    counter_file=${PM_counter_file}     counter_id=M55300C000${index}    cell_id=1
	append to list     ${PDSCH_INITX_64TBL_MCS_00_28_cell1}   ${64_value}
	${LOW_value}     get_counter_value_from_counter_file    counter_file=${PM_counter_file}     counter_id=M55366C010${index}    cell_id=1
	append to list     ${PDSCH_INITX_LOWSE_MCS_00_28_cell1}   ${LOW_value}
	${64_value}     get_counter_value_from_counter_file    counter_file=${PM_counter_file}     counter_id=M55300C000${index}    cell_id=2
	append to list     ${PDSCH_INITX_64TBL_MCS_00_28_cell2}   ${64_value}
	${LOW_value}     get_counter_value_from_counter_file    counter_file=${PM_counter_file}     counter_id=M55366C010${index}    cell_id=2
	append to list     ${PDSCH_INITX_LOWSE_MCS_00_28_cell2}   ${LOW_value}
	END
	FOR    ${i}    IN RANGE     0     28
	${index}     evaluate     "${i}".zfill(2)                     #1bit change to 2bit,0 change to 00
	${256_value}     get_counter_value_from_counter_file    counter_file=${PM_counter_file}     counter_id=M55300C040${index}    cell_id=1
	append to list     ${PDSCH_INITX_256TBL_MCS_00_27_cell1}   ${256_value}
	${256_value}     get_counter_value_from_counter_file    counter_file=${PM_counter_file}     counter_id=M55300C040${index}    cell_id=2
	append to list     ${PDSCH_INITX_256TBL_MCS_00_27_cell2}   ${256_value}
	END
	Log To Console    PDSCH_INITX_64TBL_MCS_00_28_cell1:${PDSCH_INITX_64TBL_MCS_00_28_cell1}
    Log To Console    PDSCH_INITX_64TBL_MCS_00_28_cell2:${PDSCH_INITX_64TBL_MCS_00_28_cell2}
    Log To Console    PDSCH_INITX_256TBL_MCS_00_27_cell1:${PDSCH_INITX_256TBL_MCS_00_27_cell1}
    Log To Console    PDSCH_INITX_256TBL_MCS_00_27_cell2:${PDSCH_INITX_256TBL_MCS_00_27_cell2}
    Log To Console    PDSCH_INITX_LOWSE_MCS_00_28_cell1:${PDSCH_INITX_LOWSE_MCS_00_28_cell1}
    Log To Console    PDSCH_INITX_LOWSE_MCS_00_28_cell2:${PDSCH_INITX_LOWSE_MCS_00_28_cell2}
	${PDSCH_INITX_64TBL_Sum_cell1}    Evaluate    sum(${PDSCH_INITX_64TBL_MCS_00_28_cell1})
	${PDSCH_INITX_64TBL_Sum_cell2}    Evaluate    sum(${PDSCH_INITX_64TBL_MCS_00_28_cell2})
	${PDSCH_INITX_256TBL_Sum_cell1}    Evaluate    sum(${PDSCH_INITX_256TBL_MCS_00_27_cell1})
	${PDSCH_INITX_256TBL_Sum_cell2}    Evaluate    sum(${PDSCH_INITX_256TBL_MCS_00_27_cell2})
	${PDSCH_INITX_LOWSE_Sum_cell1}    Evaluate    sum(${PDSCH_INITX_LOWSE_MCS_00_28_cell1})
	${PDSCH_INITX_LOWSE_Sum_cell2}    Evaluate    sum(${PDSCH_INITX_LOWSE_MCS_00_28_cell2})
    ${PDSCH_LG_INITX_Sum_cell1}    Evaluate    ${PDSCH_INITX_64TBL_Sum_cell1}+${PDSCH_INITX_256TBL_Sum_cell1}+${PDSCH_INITX_LOWSE_Sum_cell1}
    ${PDSCH_LG_INITX_Sum_cell2}    Evaluate    ${PDSCH_INITX_64TBL_Sum_cell2}+${PDSCH_INITX_256TBL_Sum_cell2}+${PDSCH_INITX_LOWSE_Sum_cell2}
    Log To Console    \n----------------------end-------------------------
	Log To Console    \n----Legacy_PDSCH_SUCC_64TBL_MCS_00-28_and_256TBL_MCS_00-27_and_LOWSE_MCS_00-28----------
	Log To Console    PDSCH_SUC_64TBL_MCS_00-28:M55300C01000-----M55300C01028
	Log To Console    PDSCH_SUC_256TBL_MCS_00-27:M55300C05000---M55300C05027
	Log To Console    PDSCH_SUC_LOWSE_MCS_00-28:M55366C02000----M55366C02028
    ${PDSCH_SUC_64TBL_MCS_00_28_cell1}    	create list
    ${PDSCH_SUC_64TBL_MCS_00_28_cell2}    	create list
    ${PDSCH_SUC_256TBL_MCS_00_27_cell1}    	create list
    ${PDSCH_SUC_256TBL_MCS_00_27_cell2}    	create list
    ${PDSCH_SUC_LOWSE_MCS_00_28_cell1}    	create list
    ${PDSCH_SUC_LOWSE_MCS_00_28_cell2}    	create list
	FOR    ${i}    IN RANGE     0     29
	${index}     evaluate     "${i}".zfill(2)                     #1bit change to 2bit,0 change to 00
	${64_value}     get_counter_value_from_counter_file    counter_file=${PM_counter_file}     counter_id=M55300C010${index}    cell_id=1
	append to list     ${PDSCH_SUC_64TBL_MCS_00_28_cell1}   ${64_value}
	${LOW_value}     get_counter_value_from_counter_file    counter_file=${PM_counter_file}     counter_id=M55366C020${index}    cell_id=1
	append to list     ${PDSCH_SUC_LOWSE_MCS_00_28_cell1}   ${LOW_value}
	${64_value}     get_counter_value_from_counter_file    counter_file=${PM_counter_file}     counter_id=M55300C010${index}    cell_id=2
	append to list     ${PDSCH_SUC_64TBL_MCS_00_28_cell2}   ${64_value}
	${LOW_value}     get_counter_value_from_counter_file    counter_file=${PM_counter_file}     counter_id=M55366C020${index}    cell_id=2
	append to list     ${PDSCH_SUC_LOWSE_MCS_00_28_cell2}   ${LOW_value}
	END
	FOR    ${i}    IN RANGE     0     28
	${index}     evaluate     "${i}".zfill(2)                     #1bit change to 2bit,0 change to 00
	${256_value}     get_counter_value_from_counter_file    counter_file=${PM_counter_file}     counter_id=M55300C050${index}    cell_id=1
	append to list     ${PDSCH_SUC_256TBL_MCS_00_27_cell1}   ${256_value}
	${256_value}     get_counter_value_from_counter_file    counter_file=${PM_counter_file}     counter_id=M55300C050${index}    cell_id=2
	append to list     ${PDSCH_SUC_256TBL_MCS_00_27_cell2}   ${256_value}
	END
	Log To Console    PDSCH_SUC_64TBL_MCS_00_28_cell1:${PDSCH_SUC_64TBL_MCS_00_28_cell1}
    Log To Console    PDSCH_SUC_64TBL_MCS_00_28_cell2:${PDSCH_SUC_64TBL_MCS_00_28_cell2}
    Log To Console    PDSCH_SUC_256TBL_MCS_00_27_cell1:${PDSCH_SUC_256TBL_MCS_00_27_cell1}
    Log To Console    PDSCH_SUC_256TBL_MCS_00_27_cell2:${PDSCH_SUC_256TBL_MCS_00_27_cell2}
    Log To Console    PDSCH_SUC_LOWSE_MCS_00_28_cell1:${PDSCH_SUC_LOWSE_MCS_00_28_cell1}
    Log To Console    PDSCH_SUC_LOWSE_MCS_00_28_cell2:${PDSCH_SUC_LOWSE_MCS_00_28_cell2}
	${PDSCH_SUC_64TBL_Sum_cell1}    Evaluate    sum(${PDSCH_SUC_64TBL_MCS_00_28_cell1})
	${PDSCH_SUC_64TBL_Sum_cell2}    Evaluate    sum(${PDSCH_SUC_64TBL_MCS_00_28_cell2})
	${PDSCH_SUC_256TBL_Sum_cell1}    Evaluate    sum(${PDSCH_SUC_256TBL_MCS_00_27_cell1})
	${PDSCH_SUC_256TBL_Sum_cell2}    Evaluate    sum(${PDSCH_SUC_256TBL_MCS_00_27_cell2})
	${PDSCH_SUC_LOWSE_Sum_cell1}    Evaluate    sum(${PDSCH_SUC_LOWSE_MCS_00_28_cell1})
	${PDSCH_SUC_LOWSE_Sum_cell2}    Evaluate    sum(${PDSCH_SUC_LOWSE_MCS_00_28_cell2})
    ${PDSCH_LG_SUC_Sum_cell1}    Evaluate    ${PDSCH_SUC_64TBL_Sum_cell1}+${PDSCH_SUC_256TBL_Sum_cell1}+${PDSCH_SUC_LOWSE_Sum_cell1}
    ${PDSCH_LG_SUC_Sum_cell2}    Evaluate    ${PDSCH_SUC_64TBL_Sum_cell2}+${PDSCH_SUC_256TBL_Sum_cell2}+${PDSCH_SUC_LOWSE_Sum_cell2}
    Log To Console    \n----------------------end-------------------------
	Log To Console    \n----Legacy_PUSCH_CP_INI_64TBL_MCS_00-28_and_PUSCH_DFT_INI_64TBL_MCS_00-27------
	Log To Console    \n----Legacy_PUSCH_CP_INI_256TBL_MCS_00-27_and_PUSCH_CP_INI_LOWSE_MCS_00-28------
	Log To Console    \n----Legacy_PUSCH_DFT_INI_64TBL_SAG_R2_and_PUSCH_DFT_INI_64TBL_SAG_R4------
	Log To Console    PUSCH_CP_INI_64TBL_MCS_00-28:M55302C00000----M55302C00028
	Log To Console    PUSCH_DFT_INI_64TBL_MCS_00-27:M55302C06000----M55302C06027
	Log To Console    PUSCH_CP_INI_256TBL_MCS_00-27:M55302C11000-----M55302C11027
	Log To Console    PUSCH_CP_INI_LOWSE_MCS_00-28:M55367C01000----M55367C01028
	Log To Console    PUSCH_DFT_INI_64TBL_SAG_R2:M55370C00007
	Log To Console    PUSCH_DFT_INI_64TBL_SAG_R4:M55370C00013
    ${PUSCH_CP_INI_64TBL_MCS_00_28_cell1}    	create list
    ${PUSCH_CP_INI_64TBL_MCS_00_28_cell2}    	create list
    ${PUSCH_DFT_INI_64TBL_MCS_00_27_cell1}    	create list
    ${PUSCH_DFT_INI_64TBL_MCS_00_27_cell2}    	create list
    ${PUSCH_CP_INI_256TBL_MCS_00_27_cell1}    	create list
    ${PUSCH_CP_INI_256TBL_MCS_00_27_cell2}    	create list
    ${PUSCH_CP_INI_LOWSE_MCS_00_28_cell1}    	create list
    ${PUSCH_CP_INI_LOWSE_MCS_00_28_cell2}    	create list
	FOR    ${i}    IN RANGE     0     29
	${index}     evaluate     "${i}".zfill(2)                     #1bit change to 2bit,0 change to 00
	${CP_64_value}     get_counter_value_from_counter_file    counter_file=${PM_counter_file}     counter_id=M55302C000${index}    cell_id=1
	append to list     ${PUSCH_CP_INI_64TBL_MCS_00_28_cell1}   ${CP_64_value}
	${LOW_value}     get_counter_value_from_counter_file    counter_file=${PM_counter_file}     counter_id=M55367C010${index}    cell_id=1
	append to list     ${PUSCH_CP_INI_LOWSE_MCS_00_28_cell1}   ${LOW_value}
	${CP_64_value}     get_counter_value_from_counter_file    counter_file=${PM_counter_file}     counter_id=M55302C000${index}    cell_id=2
	append to list     ${PUSCH_CP_INI_64TBL_MCS_00_28_cell2}   ${CP_64_value}
	${LOW_value}     get_counter_value_from_counter_file    counter_file=${PM_counter_file}     counter_id=M55367C010${index}    cell_id=2
	append to list     ${PUSCH_CP_INI_LOWSE_MCS_00_28_cell2}   ${LOW_value}
	END
	FOR    ${i}    IN RANGE     0     28
	${index}     evaluate     "${i}".zfill(2)                     #1bit change to 2bit,0 change to 00
	${DFT_64}     get_counter_value_from_counter_file    counter_file=${PM_counter_file}     counter_id=M55302C060${index}    cell_id=1
	append to list     ${PUSCH_DFT_INI_64TBL_MCS_00_27_cell1}   ${DFT_64}
	${256_value}     get_counter_value_from_counter_file    counter_file=${PM_counter_file}     counter_id=M55302C110${index}    cell_id=1
	append to list     ${PUSCH_CP_INI_256TBL_MCS_00_27_cell1}   ${256_value}
	${DFT_64}     get_counter_value_from_counter_file    counter_file=${PM_counter_file}     counter_id=M55302C060${index}    cell_id=2
	append to list     ${PUSCH_DFT_INI_64TBL_MCS_00_27_cell2}   ${DFT_64}
	${256_value}     get_counter_value_from_counter_file    counter_file=${PM_counter_file}     counter_id=M55302C110${index}    cell_id=2
	append to list     ${PUSCH_CP_INI_256TBL_MCS_00_27_cell2}   ${256_value}
	END
	${INI_SAG_R2_C1}     get_counter_value_from_counter_file    counter_file=${PM_counter_file}     counter_id=M55370C00007    cell_id=1
	${INI_SAG_R4_C1}     get_counter_value_from_counter_file    counter_file=${PM_counter_file}     counter_id=M55370C00013    cell_id=1
	${INI_SAG_R2_C2}     get_counter_value_from_counter_file    counter_file=${PM_counter_file}     counter_id=M55370C00007    cell_id=2
	${INI_SAG_R4_C2}     get_counter_value_from_counter_file    counter_file=${PM_counter_file}     counter_id=M55370C00013    cell_id=2
    Log To Console    PUSCH_CP_INI_64TBL_MCS_00_28_cell1:${PUSCH_CP_INI_64TBL_MCS_00_28_cell1}
    Log To Console    PUSCH_CP_INI_64TBL_MCS_00_28_cell2:${PUSCH_CP_INI_64TBL_MCS_00_28_cell2}
    Log To Console    PUSCH_DFT_INI_64TBL_MCS_00_27_cell1:${PUSCH_DFT_INI_64TBL_MCS_00_27_cell1}
    Log To Console    PUSCH_DFT_INI_64TBL_MCS_00_27_cell2:${PUSCH_DFT_INI_64TBL_MCS_00_27_cell2}
    Log To Console    PUSCH_CP_INI_256TBL_MCS_00_27_cell1:${PUSCH_CP_INI_256TBL_MCS_00_27_cell1}
    Log To Console    PUSCH_CP_INI_256TBL_MCS_00_27_cell2:${PUSCH_CP_INI_256TBL_MCS_00_27_cell2}
    Log To Console    PUSCH_CP_INI_LOWSE_MCS_00_28_cell1:${PUSCH_CP_INI_LOWSE_MCS_00_28_cell1}
    Log To Console    PUSCH_CP_INI_LOWSE_MCS_00_28_cell2:${PUSCH_CP_INI_LOWSE_MCS_00_28_cell2}
    Log To Console    PUSCH_DFT_INI_64TBL_SAG_R2_cell1:${INI_SAG_R2_C1}
    Log To Console    PUSCH_DFT_INI_64TBL_SAG_R2_cell2:${INI_SAG_R2_C2}
    Log To Console    PUSCH_DFT_INI_64TBL_SAG_R4_cell1:${INI_SAG_R4_C1}
    Log To Console    PUSCH_DFT_INI_64TBL_SAG_R4_cell2:${INI_SAG_R4_C2}
	${CP_INI_64TBL_Sum_cell1}    Evaluate    sum(${PUSCH_CP_INI_64TBL_MCS_00_28_cell1})
	${CP_INI_64TBL_Sum_cell2}    Evaluate    sum(${PUSCH_CP_INI_64TBL_MCS_00_28_cell2})
	${DFT_INI_64TBL_Sum_cell1}    Evaluate    sum(${PUSCH_DFT_INI_64TBL_MCS_00_27_cell1})
	${DFT_INI_64TBL_Sum_cell2}    Evaluate    sum(${PUSCH_DFT_INI_64TBL_MCS_00_27_cell2})
	${CP_INI_256TBL_Sum_cell1}    Evaluate    sum(${PUSCH_CP_INI_256TBL_MCS_00_27_cell1})
	${CP_INI_256TBL_Sum_cell2}    Evaluate    sum(${PUSCH_CP_INI_256TBL_MCS_00_27_cell2})
	${CP_INI_LOWSE_Sum_cell1}    Evaluate    sum(${PUSCH_CP_INI_LOWSE_MCS_00_28_cell1})
	${CP_INI_LOWSE_Sum_cell2}    Evaluate    sum(${PUSCH_CP_INI_LOWSE_MCS_00_28_cell2})
    ${PUSCH_LG_INI_Sum_cell1_tmp}    Evaluate    ${CP_INI_64TBL_Sum_cell1}+${DFT_INI_64TBL_Sum_cell1}+${CP_INI_256TBL_Sum_cell1}
    ${PUSCH_LG_INI_Sum_cell1}    Evaluate    ${PUSCH_LG_INI_Sum_cell1_tmp}+${CP_INI_LOWSE_Sum_cell1}+${INI_SAG_R2_C1}+${INI_SAG_R4_C1}
    ${PUSCH_LG_INI_Sum_cell2_tmp}    Evaluate    ${CP_INI_64TBL_Sum_cell2}+${DFT_INI_64TBL_Sum_cell2}+${CP_INI_256TBL_Sum_cell2}
    ${PUSCH_LG_INI_Sum_cell2}    Evaluate    ${PUSCH_LG_INI_Sum_cell2_tmp}+${CP_INI_LOWSE_Sum_cell2}+${INI_SAG_R2_C2}+${INI_SAG_R4_C2}
    Log To Console    \n----------------------end-------------------------
	Log To Console    \n----Legacy_PUSCH_CP_SUCC_64TBL_MCS_00-28_and_PUSCH_DFT_SUCC_64TBL_MCS_00-27------
	Log To Console    \n----Legacy_PUSCH_CP_SUCC_256TBL_MCS_00-27_and_PUSCH_CP_SUCC_LOWSE_MCS_00-28------
	Log To Console    \n----Legacy_PUSCH_DFT_SUCC_64TBL_SAG_R2_and_PUSCH_DFT_SUCC_64TBL_SAG_R4------
	Log To Console    PUSCH_CP_SUCC_64TBL_MCS_00-28:M55302C04000----M55302C04028
	Log To Console    PUSCH_DFT_SUCC_64TBL_MCS_00-27:M55302C08000----M55302C08027
	Log To Console    PUSCH_CP_SUCC_256TBL_MCS_00-27:M55302C13000---M55302C13027
	Log To Console    PUSCH_CP_SUCC_LOWSE_MCS_00-28:M55367C02000---M55367C02028
	Log To Console    PUSCH_DFT_SUCC_64TBL_SAG_R2:M55370C00009
	Log To Console    PUSCH_DFT_SUCC_64TBL_SAG_R4:M55370C00015
    ${PUSCH_CP_SUC_64TBL_MCS_00_28_cell1}    	create list
    ${PUSCH_CP_SUC_64TBL_MCS_00_28_cell2}    	create list
    ${PUSCH_DFT_SUC_64TBL_MCS_00_27_cell1}    	create list
    ${PUSCH_DFT_SUC_64TBL_MCS_00_27_cell2}    	create list
    ${PUSCH_CP_SUC_256TBL_MCS_00_27_cell1}    	create list
    ${PUSCH_CP_SUC_256TBL_MCS_00_27_cell2}    	create list
    ${PUSCH_CP_SUC_LOWSE_MCS_00_28_cell1}    	create list
    ${PUSCH_CP_SUC_LOWSE_MCS_00_28_cell2}    	create list
	FOR    ${i}    IN RANGE     0     29
	${index}     evaluate     "${i}".zfill(2)                     #1bit change to 2bit,0 change to 00
	${CP_64_value}     get_counter_value_from_counter_file    counter_file=${PM_counter_file}     counter_id=M55302C040${index}    cell_id=1
	append to list     ${PUSCH_CP_SUC_64TBL_MCS_00_28_cell1}   ${CP_64_value}
	${LOW_value}     get_counter_value_from_counter_file    counter_file=${PM_counter_file}     counter_id=M55367C020${index}    cell_id=1
	append to list     ${PUSCH_CP_SUC_LOWSE_MCS_00_28_cell1}   ${LOW_value}
	${CP_64_value}     get_counter_value_from_counter_file    counter_file=${PM_counter_file}     counter_id=M55302C040${index}    cell_id=2
	append to list     ${PUSCH_CP_SUC_64TBL_MCS_00_28_cell2}   ${CP_64_value}
	${LOW_value}     get_counter_value_from_counter_file    counter_file=${PM_counter_file}     counter_id=M55367C020${index}    cell_id=2
	append to list     ${PUSCH_CP_SUC_LOWSE_MCS_00_28_cell2}   ${LOW_value}
	END
	FOR    ${i}    IN RANGE     0     28
	${index}     evaluate     "${i}".zfill(2)                     #1bit change to 2bit,0 change to 00
	${DFT_64}     get_counter_value_from_counter_file    counter_file=${PM_counter_file}     counter_id=M55302C080${index}    cell_id=1
	append to list     ${PUSCH_DFT_SUC_64TBL_MCS_00_27_cell1}   ${DFT_64}
	${256_value}     get_counter_value_from_counter_file    counter_file=${PM_counter_file}     counter_id=M55302C130${index}    cell_id=1
	append to list     ${PUSCH_CP_SUC_256TBL_MCS_00_27_cell1}   ${256_value}
	${DFT_64}     get_counter_value_from_counter_file    counter_file=${PM_counter_file}     counter_id=M55302C080${index}    cell_id=2
	append to list     ${PUSCH_DFT_SUC_64TBL_MCS_00_27_cell2}   ${DFT_64}
	${256_value}     get_counter_value_from_counter_file    counter_file=${PM_counter_file}     counter_id=M55302C130${index}    cell_id=2
	append to list     ${PUSCH_CP_SUC_256TBL_MCS_00_27_cell2}   ${256_value}
	END
	${SUC_SAG_R2_C1}     get_counter_value_from_counter_file    counter_file=${PM_counter_file}     counter_id=M55370C00009    cell_id=1
	${SUC_SAG_R4_C1}     get_counter_value_from_counter_file    counter_file=${PM_counter_file}     counter_id=M55370C00015    cell_id=1
	${SUC_SAG_R2_C2}     get_counter_value_from_counter_file    counter_file=${PM_counter_file}     counter_id=M55370C00009    cell_id=2
	${SUC_SAG_R4_C2}     get_counter_value_from_counter_file    counter_file=${PM_counter_file}     counter_id=M55370C00015    cell_id=2
    Log To Console    PUSCH_CP_SUC_64TBL_MCS_00_28_cell1:${PUSCH_CP_SUC_64TBL_MCS_00_28_cell1}
    Log To Console    PUSCH_CP_SUC_64TBL_MCS_00_28_cell2:${PUSCH_CP_SUC_64TBL_MCS_00_28_cell2}
    Log To Console    PUSCH_DFT_SUC_64TBL_MCS_00_27_cell1:${PUSCH_DFT_SUC_64TBL_MCS_00_27_cell1}
    Log To Console    PUSCH_DFT_SUC_64TBL_MCS_00_27_cell2:${PUSCH_DFT_SUC_64TBL_MCS_00_27_cell2}
    Log To Console    PUSCH_CP_SUC_256TBL_MCS_00_27_cell1:${PUSCH_CP_SUC_256TBL_MCS_00_27_cell1}
    Log To Console    PUSCH_CP_SUC_256TBL_MCS_00_27_cell2:${PUSCH_CP_SUC_256TBL_MCS_00_27_cell2}
    Log To Console    PUSCH_CP_SUC_LOWSE_MCS_00_28_cell1:${PUSCH_CP_SUC_LOWSE_MCS_00_28_cell1}
    Log To Console    PUSCH_CP_SUC_LOWSE_MCS_00_28_cell2:${PUSCH_CP_SUC_LOWSE_MCS_00_28_cell2}
    Log To Console    PUSCH_DFT_SUC_64TBL_SAG_R2_cell1:${SUC_SAG_R2_C1}
    Log To Console    PUSCH_DFT_SUC_64TBL_SAG_R2_cell2:${SUC_SAG_R2_C2}
    Log To Console    PUSCH_DFT_SUC_64TBL_SAG_R4_cell1:${SUC_SAG_R4_C1}
    Log To Console    PUSCH_DFT_SUC_64TBL_SAG_R4_cell2:${SUC_SAG_R4_C2}
	${CP_SUC_64TBL_Sum_cell1}    Evaluate    sum(${PUSCH_CP_SUC_64TBL_MCS_00_28_cell1})
	${CP_SUC_64TBL_Sum_cell2}    Evaluate    sum(${PUSCH_CP_SUC_64TBL_MCS_00_28_cell2})
	${DFT_SUC_64TBL_Sum_cell1}    Evaluate    sum(${PUSCH_DFT_SUC_64TBL_MCS_00_27_cell1})
	${DFT_SUC_64TBL_Sum_cell2}    Evaluate    sum(${PUSCH_DFT_SUC_64TBL_MCS_00_27_cell2})
	${CP_SUC_256TBL_Sum_cell1}    Evaluate    sum(${PUSCH_CP_SUC_256TBL_MCS_00_27_cell1})
	${CP_SUC_256TBL_Sum_cell2}    Evaluate    sum(${PUSCH_CP_SUC_256TBL_MCS_00_27_cell2})
	${CP_SUC_LOWSE_Sum_cell1}    Evaluate    sum(${PUSCH_CP_SUC_LOWSE_MCS_00_28_cell1})
	${CP_SUC_LOWSE_Sum_cell2}    Evaluate    sum(${PUSCH_CP_SUC_LOWSE_MCS_00_28_cell2})
    ${PUSCH_LG_SUC_Sum_cell1_tmp}    Evaluate    ${CP_SUC_64TBL_Sum_cell1}+${DFT_SUC_64TBL_Sum_cell1}+${CP_SUC_256TBL_Sum_cell1}
    ${PUSCH_LG_SUC_Sum_cell1}    Evaluate    ${PUSCH_LG_SUC_Sum_cell1_tmp}+${CP_SUC_LOWSE_Sum_cell1}+${SUC_SAG_R2_C1}+${SUC_SAG_R4_C1}
    ${PUSCH_LG_SUC_Sum_cell2_tmp}    Evaluate    ${CP_SUC_64TBL_Sum_cell2}+${DFT_SUC_64TBL_Sum_cell2}+${CP_SUC_256TBL_Sum_cell2}
    ${PUSCH_LG_SUC_Sum_cell2}    Evaluate    ${PUSCH_LG_SUC_Sum_cell2_tmp}+${CP_SUC_LOWSE_Sum_cell2}+${SUC_SAG_R2_C2}+${SUC_SAG_R4_C2}
    Log To Console    \n----------------------end-------------------------
    Log To Console    \n----------------------All Counter Summary-------------------------
	Log To Console    \n----------Check PDSCH All Beam Type iBler counter in Cell1--------
	Log To Console    PDSCH_INI_All_beam_type_counter_Sum_cell1:${PDSCH_INI_counter_Sum_cell1}
	Log To Console    PDSCH_SUC_All_beam_type_counter_Sum_cell1:${PDSCH_SUC_counter_Sum_cell1}
    Log To Console    PDSCH_INI_64TBL_256TBL_LOWSE_legacy_counter_cell1:${PDSCH_LG_INITX_Sum_cell1}
    Log To Console    PDSCH_SUC_64TBL_256TBL_LOWSE_legacy_counter_cell1:${PDSCH_LG_SUC_Sum_cell1}
    run keyword and continue on failure    should_be_true    ${PDSCH_INI_counter_Sum_cell1}==${PDSCH_LG_INITX_Sum_cell1}
    run keyword and continue on failure    should_be_true    ${PDSCH_SUC_counter_Sum_cell1}==${PDSCH_LG_SUC_Sum_cell1}
    Log To Console    \n----------Check PDSCH All Beam Type iBler counter in Cell2--------
	Log To Console    PDSCH_INI_All_beam_type_counter_Sum_cell2:${PDSCH_INI_counter_Sum_cell2}
	Log To Console    PDSCH_SUC_All_beam_type_counter_Sum_cell2:${PDSCH_SUC_counter_Sum_cell2}
    Log To Console    PDSCH_INI_64TBL_256TBL_LOWSE_legacy_counter_cell2:${PDSCH_LG_INITX_Sum_cell2}
    Log To Console    PDSCH_SUC_64TBL_256TBL_LOWSE_legacy_counter_cell2:${PDSCH_LG_SUC_Sum_cell2}
    run keyword and continue on failure    should_be_true    ${PDSCH_INI_counter_Sum_cell2}==${PDSCH_LG_INITX_Sum_cell2}
    run keyword and continue on failure    should_be_true    ${PDSCH_SUC_counter_Sum_cell2}==${PDSCH_LG_SUC_Sum_cell2}
	Log To Console    \n----------Check PUSCH All Beam Type iBler counter in Cell1--------
    Log To Console    PUSCH_INI_All_beam_type_counter_Sum_cell1:${PUSCH_INI_counter_Sum_cell1}
    Log To Console    PUSCH_SUC_All_beam_type_counter_Sum_cell1:${PUSCH_SUC_counter_Sum_cell1}
    Log To Console    PUSCH_INI_CP_DFT_64TBL_256TBL_LOWSE_SAG_legacy_counter_cell1:${PUSCH_LG_INI_Sum_cell1}
    Log To Console    PUSCH_SUC_CP_DFT_64TBL_256TBL_LOWSE_SAG_legacy_counter_cell1:${PUSCH_LG_SUC_Sum_cell1}
    run keyword and continue on failure    should_be_true    ${PUSCH_INI_counter_Sum_cell1}==${PUSCH_LG_INI_Sum_cell1}
    run keyword and continue on failure    should_be_true    ${PUSCH_SUC_counter_Sum_cell1}==${PUSCH_LG_SUC_Sum_cell1}
	Log To Console    \n----------Check PUSCH All Beam Type iBler counter in Cell2--------
    Log To Console    PUSCH_INI_All_beam_type_counter_Sum_cell2:${PUSCH_INI_counter_Sum_cell2}
    Log To Console    PUSCH_SUC_All_beam_type_counter_Sum_cell2:${PUSCH_SUC_counter_Sum_cell2}
    Log To Console    PUSCH_INI_CP_DFT_64TBL_256TBL_LOWSE_SAG_legacy_counter_cell2:${PUSCH_LG_INI_Sum_cell2}
    Log To Console    PUSCH_SUC_CP_DFT_64TBL_256TBL_LOWSE_SAG_legacy_counter_cell2:${PUSCH_LG_SUC_Sum_cell2}
    run keyword and continue on failure    should_be_true    ${PUSCH_INI_counter_Sum_cell2}==${PUSCH_LG_INI_Sum_cell2}
    run keyword and continue on failure    should_be_true    ${PUSCH_SUC_counter_Sum_cell2}==${PUSCH_LG_SUC_Sum_cell2}