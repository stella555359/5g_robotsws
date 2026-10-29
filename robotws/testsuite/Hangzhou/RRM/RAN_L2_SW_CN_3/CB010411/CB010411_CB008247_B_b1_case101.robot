# *** Settings ***
# Documentation     Author: jing.pan@nokia-sbell.com
# ...
# ...               QC case full name:
# ...               CB008247_B_b1_case101_UE specific CSI-RS allocation for cell with 8x4 CL-MIMO_Multi UE_t2r4_TAS_Supported
# ...
# ...               In case cell is configured to 8x4 CL-MIMO, an CSI-RS resource pool is created for UE specific CSI-RS resource allocation.
# ...               When an UE is admitted, firstly UE specific CSI-RS resource for resource pool is allocated to this UE.
# ...               If there are no free CSI-RS resource available in the pool, then cell specific CSI-RS is allocated to this UE
# 
# Suite Setup       AiC Common Suite Setup
# Suite Teardown    AiC Common Suite Teardown
# Test Setup        AiC Common Test Setup
# #Test Teardown     AiC Common Test Teardown
# Force Tags        CLOUD_5GC_dRNIC_1vDU_O_AP_LO    AP    SBTS00    RAN_5G_TDD    RAN_5G
# Test Timeout      60 minutes
# Resource          ../resources/KISS/robot/common_resource.robot
# Resource          ../resources/sg11/internal_resource/robot/modify_configuration.robot
# Resource          ../resources/sg11/internal_resource/robot/internal_gnb_operate.robot
# Resource          ../resources/sg11/internal_resource/robot/internal_ap_operate.robot
# 
# *** Variables ***
# ${CONFIG_DIR_PATH}    ${CURDIR}/../resources/sg11/internal_resource/config/vRan/
# ${DU_SCF}             scfc_VDU_10411.xml
# ${CU_SCF}             scfc_VCU_10411.xml
# ${AIRPHONE_NAME}      iphy_10411.xml
# ${WTS_NAME}           basic_setup_10411.cfg
# 
# ${COMAVALUE}          ${CURDIR}/log_check/ap_coma.txt
# ${UE1_ID}             1
# ${UE2_ID}             2
# @{LOG_NAME_LIST}      egatelog
# #@{LOG_NAME_LIST}    gnb_snapshot    ap_snapshot    egatelog
# 
# ${FILTER1}           ((dldata_pdcchsendreq) && !(3gpp.rnti == 65535)) && !(DlData_DciInfo.patternId_item == 101)
# ${FILTER2}           (((dldata_pdschsendreq) && !(3gpp.rnti == 65535))) && !(DlData_PdschGrant.patternId_item == 101)
# ${FILTER3}           DlData_CsiRsResource_t.density == 1
# @{title1}            DlData_DciInfo.patternId_item
# @{title2}            DlData_PdschGrant.patternId_item
# @{title3}            DlData_CsiRsResource_t.patternId_item
# 
# ${actBeamforming}        text|true|//*[@name\="actBeamforming"]
# ${bSRS}                  text|2|//*[@name\="bSRS"]
# ${cSRS}                  text|63|//*[@name\="cSRS"]
# ${srsUePeriodicity}      text|slots40|//*[@name\="srsUePeriodicity"]
# ${chBw}                  text|100MHz|//*[@name\="chBw"]
# ${actUlSrsBm}            text|true|//*[@name\="actUlSrsBm"]
# ${actDlSrsBm}            text|true|//*[@name\="actDlSrsBm"]
# ${nrCellType}            text|8DL4UL|//*[@name\="nrCellType"]
# ${dlMimoMode}            text|8x4 Closed Loop Spatial Multiplexing|//*[@name\="dlMimoMode"]
# ${nrBtsBeamRefinementP2}                 text|false|//*[@name\="nrBtsBeamRefinementP2"]
# ${csirsNumberWithinReportPeriod_Set1}    text|1|//*[@name\="csirsNumberWithinReportPeriod_Set1"]
# ${actCDrx}                               text|false|//*[@name\="actCDrx"]
# ${basicBeamSet}                          text|beamSet_6|//*[@name\="basicBeamSet"]
# ${numberOfTransmittedSsBlocks}           text|6 beams|//*[contains(@distName, 'NRCELLGRP')]/*[@name='numberOfTransmittedSsBlocks']
# ${frameStructureType}                    text|semiStatic|//*[@name\="frameStructureType"]
# ${prachConfigurationIndex}               text|98|//*[@name\="prachConfigurationIndex"]
# ${guardPeriodLength}                     text|2Symbols|//*[@name\="guardPeriodLength"]
# ${ulDlDataSlotRatio}                     text|3/7|//*[@name\="ulDlDataSlotRatio"]
# #${bwp_profile67}              attrib\=distName|replace('BWP_PROFILE-54', 'BWP_PROFILE-67')|//managedObject
# #${bwp_profile67_p}            text|replace('BWP_PROFILE-54', 'BWP_PROFILE-67')|//p
# #${bwp_profile6}               attrib\=distName|replace('BWP_PROFILE-5', 'BWP_PROFILE-6')|//managedObject
# #${bwp_profile6_p}             text|replace('BWP_PROFILE-5', 'BWP_PROFILE-6')|//p
# #${bwp_duration1}              text|2|//*[contains(@distName, 'BWP_PROFILE-6')]//item[1]/*[@name\='duration']
# #${bwp_duration3}              text|2|//*[contains(@distName, 'BWP_PROFILE-6')]//item[3]/*[@name\='duration']
# #${bwp_duration_dedi}          text|1|//*[contains(@distName, 'BWP_PROFILE-67/PDCCH-1/PDCCH_CONFIG_DEDICATED-1')]//*[@name\='duration']
# #${nPdcchCandidatesInAL16}     text|n0|//*[contains(@distName, 'BWP_PROFILE-6')]//*[@name\="numOfPdcchCandidatesInAL16"]
# #${nPdcchCandidatesInAL4_1}    text|n2|//*[contains(@distName, 'BWP_PROFILE-6')]//item[1]/*[@name\="numOfPdcchCandidatesInAL4"]
# #${nPdcchCandidatesInAL4_3}    text|n2|//*[contains(@distName, 'BWP_PROFILE-6')]//item[3]/*[@name\="numOfPdcchCandidatesInAL4"]
# #${nPdcchCandidatesInAL2_2}    text|n0|//*[contains(@distName, 'BWP_PROFILE-6')]//item[2]/*[@name\="numOfPdcchCandidatesInAL2"]
# #${nPdcchCandidatesInAL8}    text|n0|//*[contains(@distName, 'BWP_PROFILE-6')]//*[@name\="numOfPdcchCandidatesInAL8"]
# #${nPdcchCandidatesInAL4_2}
# #...     text|n4|//*[contains(@distName, 'BWP_PROFILE-67/PDCCH-1/PDCCH_CONFIG_COMMON-1')]//item[2]/*[@name\="numOfPdcchCandidatesInAL4"]
# 
# ${bwp_profile6}      text|MRBTS-1/NRBTS-1/BWP_PROFILE-6|//*[@name\="cellBwpList"]/item[1]/*[@name\="bwpDN"]
# ${bwp_profile67}     text|MRBTS-1/NRBTS-1/BWP_PROFILE-67|//*[@name\="cellBwpList"]/item[2]/*[@name\="bwpDN"]
# 
# 
# *** Test Cases ***
# CB008247_B_b1_case101_UE specific CSI-RS allocation for cell with 8x4 CL-MIMO_Multi UE_t2r4_TAS_Supported_vran
#     Step1:Commission the above configuration on WebUI
#     Step2:Attach 2UEs with t2r4
#     Step3:Inject full dl and ul data
# 
# *** Keywords ***
# Step1:Commission the above configuration on WebUI
#     Start Collect GNB and AP Syslog in 'Step1_before_onair' File
#     ${CONFIG_DIR_PATH}    Set Variable    ${CONFIG_DIR_PATH}/${SW_BRANCH}
# #    change_iphy_rru_version    ${CONFIG_DIR_PATH}${/}${AIRPHONE_NAME}
# #    modify_swconfig_by_CB008247    ${CONFIG_DIR_PATH}${/}${DU_SCF}
#     ${vDU_scfc_path}    Set Variable    ${TEST_LOG_DIRECTORY()}${/}scfc_VDU_10411.xml
#     copy_file    ${CONFIG_DIR_PATH}/${DU_SCF}   ${vDU_scfc_path}
# #    add_xml_element    ${vDU_scfc_path}   ${vDU_scfc_path}     <p name="tiltOffset">0</p>|//*[@name\='beamSet']/item
# #    add_all_elements   ${vDU_scfc_path}     NRCELL    mMimoAntArrayMode     Full 64TRX Array (4x8x2)
# #    add_all_elements   ${vDU_scfc_path}     NRCELL    actUeCsirsCoexistCellCsirs     true
# #    add_all_elements   ${vDU_scfc_path}     NRBTS    actChannelMapVal     Disabled
# #    add_srsForBeamMgmt_list_in_cells   ${vDU_scfc_path}
# #    add_periodicCsiAcquisition_list_in_cells   ${vDU_scfc_path}
#     ${modify_list}    create list    ${chBw}    ${nrCellType}
#     ...            ${dlMimoMode}    ${actUlSrsBm}    ${actDlSrsBm}    ${nrBtsBeamRefinementP2}    ${actBeamforming}
#     ...            ${csirsNumberWithinReportPeriod_Set1}    ${frameStructureType}    ${guardPeriodLength}    ${ulDlDataSlotRatio}
#     ...            ${prachConfigurationIndex}    ${numberOfTransmittedSsBlocks}    ${basicBeamSet}    ${bSRS}    ${cSRS}    ${srsUePeriodicity}
# #    ...            ${bwpProfile67}    ${bwp_profile67_p}    ${bwp_profile6}    ${bwp_profile6_p}    ${bwp_duration1}    ${bwp_duration3}
# #    ...            ${nPdcchCandidatesInAL16}    ${nPdcchCandidatesInAL4_1}    ${nPdcchCandidatesInAL4_3}    ${nPdcchCandidatesInAL2_2}
# #    ...            ${nPdcchCandidatesInAL8}    ${nPdcchCandidatesInAL4_2}    ${bwp_duration_dedi}
#     ...            ${bwp_profile6}    ${bwp_profile67}
#     modify_xml   ${vDU_scfc_path}   ${vDU_scfc_path}    ${modify_list}
#     Modify TL VM And AP SCTP Configuration
#     AIC Perform Full Commission And Reach Onair   ${vDU_scfc_path}    ${CONFIG_DIR_PATH}${/}${WTS_NAME}     ${CONFIG_DIR_PATH}/${CU_SCF}
#     [Teardown]    Stop Collect GNB and AP Syslog in 'Step1_before_onair' File
# 
# Step2:Attach 2UEs with t2r4
#     Start Collect GNB and AP Syslog in 'Step2_attach' File
#     Airphone Execute Egate Command    ul_sinr_testmode_nr profile_id\=5 sinr_target_srs\=120 noise_srs\=-1053
#     Airphone Execute Egate Command    ue_testmode_set_nr id\=${UE1_ID} testmode\=ul_sinr action\=activate profile_id\=5
#     Airphone Execute Egate Command    ue_testmode_set_nr id\=${UE2_ID} testmode\=ul_sinr action\=activate profile_id\=5
#     Attach SA ue with capability to 5g cell    2    CA_P2_8x4_t2r4_n2
#     ${save_log}=    Set Variable    ${TEST_LOG_DIRECTORY()}Step2_attach
#     airphone_collect_egate_log_files      ${save_log}   unzip=TRUE
#     check_log_with_au2anlysis    ini_path=${CURDIR}/log_check/rrc_t2r4_p4_2ue.ini    log_need_to_check=p    save_log_directory=${save_log}
# #    vran syslog capture    &{MASTER_CU}
#     [Teardown]    Stop Collect GNB and AP Syslog in 'Step2_attach' File
# 
# Step3:Inject full dl and ul data
#     Start Collect GNB and AP Syslog in 'Step3_inject_buffer' File
#     ${save_log}=    Set Variable    ${TEST_LOG_DIRECTORY()}Step3_inject_buffer
#     SA send multiple trf data    ${UE1_ID}    DL    175M    1
#     SA send multiple trf data    ${UE1_ID}    UL    25M    1
#     SA send multiple trf data    ${UE2_ID}    DL    175M    1
#     SA send multiple trf data    ${UE2_ID}    UL    25M    1
# 
#     Wait Throughput Timer    10
#     ${tput_ue1} =    Airphone Get Throughput On Specific Scell    ue_id=1   scell_id=0    type=pdsch    tput_type=ave
#     ${tput_ue2} =    Airphone Get Throughput On Specific Scell    ue_id=2   scell_id=0    type=pdsch    tput_type=ave
# 
#     ${trace_id}     VDU Start TTiTrace Log
#     Wait Throughput Timer    3
#     VDU Stop TTiTrace Log    ${trace_id}
#     Collet VDU and VCU syslog
#     VDU Decode TTiTrace Log    csv_dir=${save_log}/ttiTrace
#     check_log_with_au2anlysis    ini_path=${CURDIR}/log_check/tti_case101_APLO.ini    log_need_to_check=i    save_log_directory=${save_log}
# #    Check patterId in bip    ${save_log}
#     [Teardown]    Stop Collect GNB and AP Syslog in 'Step3_inject_buffer' File
# 
# 
# Check patterId in bip
#     [Arguments]    ${log_dir}
#     Convert BIP To CSV    ${log_dir}/tcpdump_L2L1_bip_filtering_off.pcap0    ${log_dir}/bip_pdcch.csv    ${FILTER1}    ${title1}
#     Convert BIP To CSV    ${log_dir}/tcpdump_L2L1_bip_filtering_off.pcap0    ${log_dir}/bip_pdsch.csv    ${FILTER2}    ${title2}
#     Convert BIP To CSV    ${log_dir}/tcpdump_L2L1_bip_filtering_off.pcap0    ${log_dir}/bip_csirs.csv    ${FILTER3}    ${title3}
#     Check Log With Au2anlysis    ini_path=${CURDIR}/log_check/bip_case102_pdcch.ini     log_need_to_check=i    save_log_directory=${log_dir}
#     Check Log With Au2anlysis    ini_path=${CURDIR}/log_check/bip_case102_pdsch.ini     log_need_to_check=i    save_log_directory=${log_dir}
#     Check Log With Au2anlysis    ini_path=${CURDIR}/log_check/bip_case102_csirs.ini     log_need_to_check=i    save_log_directory=${log_dir}
