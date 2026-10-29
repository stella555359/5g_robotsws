# *** Settings ***
# Documentation     Author: zhaona.jiang@nokia-sbell.com
# ...
# ...               QC case full name:
# ...               CB010602_A_B2_case15_Rank4_8X4_CL_SRS based beamforming extension dft beam fallback refine beam
# 
# Suite Setup       Common Suite Setup
# Suite Teardown    Common Suite Teardown
# Test Setup        Common Test Setup
# Test Teardown     Common Test Teardown
# Force Tags        CLOUD_5G_I_BOO_AP_KLLL_SANSA_L1B_ECPRI_CMWV_TDD    AP    CRT    SBTS00    SBTS23R1    RAN_5G_TDD    RAN_5G
# Test Timeout      60 minutes
# Resource          ../../resources/sg11/internal_resource/robot/modify_configuration.robot
# Resource          ../../resources/sg11/internal_resource/robot/internal_gnb_operate.robot
# Resource          ../../resources/sg11/internal_resource/robot/internal_ap_operate.robot
# 
# *** Variables ***
# ${CONFIG_DIR_PATH}    ${CURDIR}/../../resources/sg11/internal_resource/config/
# ${SCFC_NAME}          gNB_scf_ASIB_ABIO_AEQE_TDD_eCPRI_cmwv_SANSA_1CC_FS.xml
# ${AIRPHONE_NAME}      AP_iphy_AEQE_LO_AP_LO_TDD_eCPRI_cmwv_SANSA_L1b_1S_1CC_srs_B.xml
# ${WTS_NAME}           wts_config_ASIL_ABIO_TDD_eCPRI_cmwv_SANSA_L1b_1S_1CC.cfg
# ${COMAVALUE}          ${CONFIG_DIR_PATH}/AP/ap_coma.txt
# @{LOG_NAME_LIST}      gnb_snapshot    sosreport    tshark    egatelog
# ${FILTER1}    ((dldata_pdschsendreq)||(DlData_CsiRsResource_t.density == 1)) && !(3gpp.rnti == 65535)
# @{title1}    DlData_PdschGrant.bestBeamPowerOffset    3gpp.rnti    DlData_PdschGrant.closedLoop3gppCodebook    DlData_PdschGrant.numOfLayers
# ...          DlData_PdschGrant.patternId_item    DlData_CsiRsResource_t.patternId_item    DlData_CsiRsResource_t.csiBestBeamPowerOffset
# ...          DlData_CsiRsResource_t.csiRsConfig
# 
# ${actUlSrsBm}                            text|true|//*[@name\="actUlSrsBm"]
# ${actDlSrsBm}                            text|true|//*[@name\="actDlSrsBm"]
# ${actCsirsMultiplexing}                  text|false|//*[@name\="actCsirsMultiplexing"]
# ${actFdmScheduling}                      text|true|//*[@name\="actFdmScheduling"]
# ${chBw}                                  text|20MHz|//*[@name\="chBw"]
# ${bSRS}                                  text|0|//*[@name\="bSRS"]
# ${cSRS}                                  text|12|//*[@name\="cSRS"]
# ${srsUePeriodicity}                      text|slots10|//*[@name\="srsUePeriodicity"]
# ${numberOfTransmittedSsBlocks}           text|6 beams|//*[contains(@distName, 'NRCELLGRP')]/*[@name='numberOfTransmittedSsBlocks']
# ${basicBeamSet}                          text|beamSet_6|//*[@name\="basicBeamSet"]
# ${nrCellType}                            text|8DL8UL|//*[@name\="nrCellType"]
# ${dlMimoMode}                            text|8x4 Closed Loop Spatial Multiplexing|//*[@name\="dlMimoMode"]
# ${nrBtsBeamRefinementP2}                 text|false|//*[@name\="nrBtsBeamRefinementP2"]
# ${maxCsirsNumber}                        text|2|//*[@name\="maxCsirsNumber"]
# ${csirsNumberWithinReportPeriod_Set1}    text|1|//*[@name\="csirsNumberWithinReportPeriod_Set1"]
# ${actCDrx}                               text|false|//*[@name\="actCDrx"]
# ${frameStructureType}                    text|semiStatic|//*[@name\="frameStructureType"]
# ${guardPeriodLength}                     text|2Symbols|//*[@name\="guardPeriodLength"]
# ${prachConfigurationIndex}               text|98|//*[@name\="prachConfigurationIndex"]
# ${ulDlDataSlotRatio}                     text|1/4|//*[@name\="ulDlDataSlotRatio"]
# ${type0CoresetConfigIndex}               text|2|//*[@name\="type0CoresetConfigurationIndex"]
# ${nPdcchCandidatesInAL2}       text|n0|//*[contains(@distName, 'BWP_PROFILE-5')]//*[@name\="numOfPdcchCandidatesInAL2"]
# ${nPdcchCandidatesInAL4}       text|n2|//*[contains(@distName, 'BWP_PROFILE-5')]//*[@name\="numOfPdcchCandidatesInAL4"]
# ${nPdcchCandidatesInAL8}       text|n0|//*[contains(@distName, 'BWP_PROFILE-5')]//*[@name\="numOfPdcchCandidatesInAL8"]
# ${nPdcchCandidatesInAL16}      text|n0|//*[contains(@distName, 'BWP_PROFILE-5')]//*[@name\="numOfPdcchCandidatesInAL16"]
# ${periodicity_comm1}           text|sl5|//*[contains(@distName, 'BWP_PROFILE-75')]//item[1]/*[@name\='periodicity']
# ${periodicity_comm3}           text|sl5|//*[contains(@distName, 'BWP_PROFILE-75')]//item[3]/*[@name\='periodicity']
# ${periodicity_ded}             text|sl1|//*[contains(@distName, 'BWP_PROFILE-75/PDCCH-1/PDCCH_CONFIG_DEDICATED-1')]//*[@name\='periodicity']
# ${nPdcchCandidatesInAL4_d}     text|n2|//*[contains(@distName, 'BWP_PROFILE-75')]//item[2]/*[@name\="numOfPdcchCandidatesInAL4"]
# ${bwp_duration1}               text|3|//*[contains(@distName, 'BWP_PROFILE-75')]//item[1]/*[@name\='duration']
# ${bwp_duration3}               text|3|//*[contains(@distName, 'BWP_PROFILE-75')]//item[3]/*[@name\='duration']
# ${duration_dedi}               text|1|//*[contains(@distName, 'BWP_PROFILE-75/PDCCH-1/PDCCH_CONFIG_DEDICATED-1')]//*[@name\='duration']
# ${slotOffset}                  text|0|//*[contains(@distName, 'BWP_PROFILE-75')]//*[@name\='slotOffset']
# ${bwp_dedi_size}               text|48|//*[contains(@distName, 'BWP_PROFILE-75/PDCCH-1/PDCCH_CONFIG_DEDICATED-1')]//*[@name\='size']
# #${frameStructureType}                    text|tdLte|//*[@name\="frameStructureType"]
# #${guardPeriodLength}                     text|6Symbols|//*[@name\="guardPeriodLength"]
# #${lteToNrFrameShift}                     text|0ms|//*[@name\="lteToNrFrameShift"]
# #${prachConfigurationIndex}               text|97|//*[@name\="prachConfigurationIndex"]
# ${bwpDN1}                                text|MRBTS-1/NRBTS-2/BWP_PROFILE-5|//*[contains(@name,'cellBwpList')]//item[1]/*[@name\='bwpDN']
# ${bwpDN2}                                text|MRBTS-1/NRBTS-2/BWP_PROFILE-75|//*[contains(@name,'cellBwpList')]//item[2]/*[@name\='bwpDN']
# ${csiReportPeriodicity}                  text|slots160|//*[@name\="csiReportPeriodicity"]
# ${actUeCsirsCoexistCellCsirs}            text|true|//*[@name\="actUeCsirsCoexistCellCsirs"]
# ${actPdschBeamPowerBalance}              text|true|//*[@name\="actPdschBeamPowerBalance"]
# ${actCsirsBeamPowerBalance}              text|true|//*[@name\="actCsirsBeamPowerBalance"]
# ${beamPowerOffsetThreshold}              text|15|//*[@name\="beamPowerOffsetThreshold"]
# ${actShortBsrLimitAdaptation}            text|true|//*[@name\="actShortBsrLimitAdaptation"]
# ${profile1}    ul_mimo_srs_beam_pos_nr profile_id=1 mode=fixed init_quad_pos=3 init_sub_quad_pos=0 test_type=UL_MIMO multi_path_config=1
# ...            num_of_nlos_paths=1 azimuth=3 zenith=0 srs_transmit_power_per_port=-400,-400,-500,-500
# 
# *** Test Cases ***
# CB010602_A_B2_case15_Rank4_8X4_CL_SRS based beamforming extension dft beam fallback refine beam
#     Step1:Commission the above configuration on WebUI
#     Step2:attach 2ue with t4r4 3ue with t2r4
#     Step3:Inject dl and ul data
#     Step4:Detach UE
# 
# *** Keywords ***
# Step1:Commission the above configuration on WebUI
#     Start Collect GNB and AP Syslog in 'Step1_before_onair' File
#     ${CONFIG_DIR_PATH}    Set Variable    ${CONFIG_DIR_PATH}/${SW_BRANCH}
#     change_iphy_rru_version    ${CONFIG_DIR_PATH}${/}${AIRPHONE_NAME}
#     modify_swconfig_by_CB010602    ${CONFIG_DIR_PATH}${/}${SCFC_NAME}    1csirs
#     ${scfc_path}    Set Variable    ${TEST_LOG_DIRECTORY()}${/}scfc.xml
#     copy_file    ${CONFIG_DIR_PATH}/${SCFC_NAME}    ${scfc_path}
#     del_elements_from_xml    xml_path=${scfc_path}    parameter=lteToNrFrameShift
#     del_elements_from_xml    xml_path=${scfc_path}    parameter=tdLteUlDlConfig
#     ${modify_list}    create list    ${chBw}    ${dlMimoMode}    ${actUlSrsBm}    ${actDlSrsBm}    ${nrCellType}    ${nrBtsBeamRefinementP2}
#     ...            ${csirsNumberWithinReportPeriod_Set1}    ${frameStructureType}    ${guardPeriodLength}    ${ulDlDataSlotRatio}
#     ...            ${prachConfigurationIndex}    ${numberOfTransmittedSsBlocks}    ${basicBeamSet}    ${srsUePeriodicity}    ${bSRS}    ${cSRS}
#     ...            ${actFdmScheduling}    ${actUeCsirsCoexistCellCsirs}    ${actPdschBeamPowerBalance}    ${actCsirsBeamPowerBalance}
#     ...            ${csiReportPeriodicity}    ${beamPowerOffsetThreshold}    ${bwpDN1}    ${bwpDN2}    ${actCsirsMultiplexing}
#     ...            ${actShortBsrLimitAdaptation}    ${maxCsirsNumber}    ${type0CoresetConfigIndex}    ${nPdcchCandidatesInAL2}
#     ...            ${nPdcchCandidatesInAL4}    ${nPdcchCandidatesInAL8}    ${nPdcchCandidatesInAL16}    ${periodicity_comm1}    ${periodicity_comm3}
#     ...            ${periodicity_ded}    ${nPdcchCandidatesInAL4_d}    ${bwp_duration1}    ${bwp_duration3}    ${duration_dedi}    ${slotOffset}
#     ...            ${bwp_dedi_size}
#     modify_xml    ${scfc_path}    ${scfc_path}    ${modify_list}
#     Modify TL VM And AP SCTP Configuration
#     Get and Update BSR File    par_of_bsr_name=AEQE_6_H6_ALN60_ARP60_P00_COVERAGE_00424_000
#     Perform Full Commission And Reach Onair With Log    ${scfc_path}    ${CONFIG_DIR_PATH}${/}${WTS_NAME}
#     [Teardown]    Stop Collect GNB and AP Syslog in 'Step1_before_onair' File
# 
# Step2:attach 2ue with t4r4 3ue with t2r4
#     Start Collect GNB and AP Syslog in 'Step2_attach' File
#     Start GNB BIP Log
# #    Attach SA ue with capability to 5g cell    3    CA_P2_8x4_t4r4_n4
#     Attach SA ue with capability to 5g cell    2    CA_P2_8x4_t4r4_n4
#     Attach SA ue with capability to 5g cell    3    CA_P2_8x4_t2r4_n2    3
#     excute_cmd_for_multi_path
#     ${save_log}=    Set Variable    ${TEST_LOG_DIRECTORY()}Step2_attach
#     Stop Gnb BIP Log    log_dir=${save_log}${/}
#     airphone_collect_egate_log_files      ${save_log}   unzip=TRUE
#     check_log_with_au2anlysis    ini_path=${CURDIR}/log_check/rrc_case15.ini    log_need_to_check=p    save_log_directory=${save_log}
#     [Teardown]    Stop Collect GNB and AP Syslog in 'Step2_attach' File
# 
# Step3:Inject dl and ul data
#     Start Collect GNB and AP Syslog in 'Step3_inject_buffer' File
#     send 5ues buffer
#     Start GNB BIP Log
#     Wait Throughput Timer    3
#     ${save_log}=    Set Variable    ${TEST_LOG_DIRECTORY()}Step3_inject_buffer
#     Stop Gnb BIP Log    log_dir=${save_log}${/}
#     Start GNB Ttitrace With Streaming Mode
#     Wait Throughput Timer    3
#     ${pacp}=    Stop GNB Ttitrace With Streaming Mode    save_path=${save_log}
#     Decoder Tttirace From Pcap To Csv    ${pacp}    ${save_log}/tti
#     Check beamOffset in bip    ${save_log}
#     ${counter_file}    download PM counter file    ${save_log}
# 	${BEAM_PWR_OFFSET_RI4_INDEX8}=    get_counter_value_from_counter_file    counter_file=${counter_file}   counter_id=M55305C14019   cell_id=1
# 	should be true    ${BEAM_PWR_OFFSET_RI4_INDEX8} > 40000
# 	should be true    ${BEAM_PWR_OFFSET_RI4_INDEX8} < 84001
#     ${trace_id}    DCAP start collect log      10.0.1.2        enb_trace_profile=dcap-lite-default      bts_trace_profile=dcap-lite-default
#     DCAP stop collect log    ${trace_id}
#     [Teardown]    Stop Collect GNB and AP Syslog in 'Step3_inject_buffer' File
# 
# Step4:Detach UE
#     Start Collect GNB and AP Syslog in 'Step4_detach' File
#     #Stop '5'UE DL Traffic
#     Detach '5'UE
#     [Teardown]    Stop Collect GNB and AP Syslog in 'Step4_detach' File
# 
# send ${UENUM}ues buffer
#     : FOR    ${ueId}    IN RANGE    1    ${UENUM}+1
#     \    SA send multiple trf data    ${ueId}    DL    10M    1
#     \    SA send multiple trf data    ${ueId}    UL    10M    1
# 
# Check beamOffset in bip
#     [Arguments]    ${log_dir}
#     Convert BIP To CSV    ${log_dir}/tcpdump_L2L1_bip_filtering_off.pcap0    ${log_dir}/bip_case15.csv    ${FILTER1}    ${title1}
#     Check Log With Au2anlysis    ini_path=${CURDIR}/log_check/bip_case15.ini     log_need_to_check=i    save_log_directory=${log_dir}
# 
# excute_cmd_for_multi_path
#     airphone_execute_egate_command    ${profile1}
#     airphone_execute_egate_command    ue_testmode_set_nr id\=1 testmode\=ul_mimo_srs_beam_pos action\=activate profile_id\=1
#     airphone_execute_egate_command    ue_testmode_set_nr id\=2 testmode\=ul_mimo_srs_beam_pos action\=activate profile_id\=1
#     airphone_execute_egate_command    ue_testmode_set_nr id\=3 testmode\=ul_mimo_srs_beam_pos action\=activate profile_id\=1
#     airphone_execute_egate_command    ue_testmode_set_nr id\=4 testmode\=ul_mimo_srs_beam_pos action\=activate profile_id\=1
#     airphone_execute_egate_command    ue_testmode_set_nr id\=5 testmode\=ul_mimo_srs_beam_pos action\=activate profile_id\=1
