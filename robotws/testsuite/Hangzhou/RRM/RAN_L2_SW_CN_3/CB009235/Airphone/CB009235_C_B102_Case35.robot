# *** Settings ***
# Documentation     Author: jing.pan@nokia-sbell.com
# ...
# ...               QC case full name:
# ...               CB009235_C_B102_Case35_Enhanced_PM_counters_MU_MIMO_PAIR_DL_FAIL_SE
# ...               base on CB008305_regression_robust_case03_TDD_antport and cdm group check
# ...
# 
# Suite Setup       Common Suite Setup
# Suite Teardown    Common Suite Teardown
# Test Setup        Common Test Setup
# Test Teardown     Common Test Teardown
# Force Tags        CLOUD_5G_I_LO_AP_LO_SANSA_FS_ECPRI_CMWV_TDD    AP    CRT    SBTS00    RAN_5G_TDD    RAN_5G
# Test Timeout      60 minutes
# Resource          ../../resources/sg11/internal_resource/robot/modify_configuration.robot
# Resource          ../../resources/sg11/internal_resource/robot/internal_ap_operate.robot
# Resource          ../../resources/sg11/internal_resource/robot/internal_gnb_operate.robot
# Resource          ../../resources/sg11/internal_resource/robot/internal_capture_log.robot
# Library           ../../resources/sg10/internal_resource/lib/pdcch_dci_decode.py
# 
# *** Variables ***
# ${CONFIG_DIR_PATH}    ${CURDIR}/../../resources/sg11/internal_resource/config/
# ${SCFC_NAME}          sg10_bwp_3_1116.xml
# ${AIRPHONE_NAME}      AP_iphy_AEQE_LO_AP_LO_TDD_eCPRI_cmwv_SANSA_L1b_1S_1CC_srs_B.xml
# ${WTS_NAME}           wts_config_ASIL_ABIO_TDD_eCPRI_cmwv_SANSA_L1b_1S_1CC.cfg
# ${COMAVALUE}          ${CURDIR}/../../resources/sg11/internal_resource/config/AP/ap_coma.txt
# @{LOG_NAME_LIST}      gnb_snapshot    sosreport    egatelog\
# 
# ${chBw}                           text|100MHz|//*[@name\="chBw"]
# ${dlMimoMode}                     text|8x4 Closed Loop Spatial Multiplexing|//*[@name\="dlMimoMode"]
# ${nrCellType}                     text|8DL4UL|//*[@name\="nrCellType"]
# ${actDlMuMimoEnh}                 text|true|//*[@name\="actDlMuMimoEnh"]
# ${dlMuMimoCorrThd}                text|33|//*[@name\="dlMuMimoCorrThd"]
# ${dlMuMimoCqiThd}                 text|0|//*[@name\="dlMuMimoCqiThd"]
# ${dlMuMimoSpectralEffThd}         text|20|//*[@name\="dlMuMimoSpectralEffThd"]
# ${maxNumLayerPerMuRbg}            text|8|//*[@name\="dlMuMaxNumLayerPerMuRbg"]
# ${dlMuMimoRankAdaption}           text|disabled|//*[@name\="dlMuMimoRankAdaption"]
# ${dlMuMimoTaperingH}              text|25dB|//*[@name\="dlMuMimoTaperingH"]
# ${dlMuMimoTaperingV}              text|NoTapering|//*[@name\="dlMuMimoTaperingV"]
# ${actBeamforming}                 text|true|//*[@name\="actBeamforming"]
# ${basicBeamSet}                   text|beamSet_6|//*[@name\="basicBeamSet"]
# ${numberOfTransmittedSsBlocks}    text|6 beams|//*[contains(@distName, 'NRCELLGRP')]/*[@name='numberOfTransmittedSsBlocks']
# ${actDl256Qam}                    text|false|//*[@name\="actDl256Qam"]
# 
# ${actFdmScheduling}                             text|true|//*[@name\="actFdmScheduling"]
# ${frameStructureType}                           text|tdLte|//*[@name\="frameStructureType"]
# ${guardPeriodLength}                            text|6Symbols|//*[@name\="guardPeriodLength"]
# ${lteToNrFrameShift}                            text|0ms|//*[@name\="lteToNrFrameShift"]
# ${prachConfigurationIndex}                      text|97|//*[@name\="prachConfigurationIndex"]
# ${actDlSrsBm}                                   text|true|//*[@name\="actDlSrsBm"]
# ${srsUePeriodicity}                             text|slots40|//*[@name\="srsUePeriodicity"]
# ${cSRS}                                         text|42|//*[@name\="cSRS"]
# ${bSRS}                                         text|2|//*[@name\="bSRS"]
# ${nrBtsBeamRefinementP2}                        text|false|//*[@name\="nrBtsBeamRefinementP2"]
# ${msg1FrequencyStart}                           text|2|//*[@name\="msg1FrequencyStart"]
# ${actUlMuMimoTapering}                          text|false|//*[@name\="actUlMuMimoTapering"]
# ${schedulBSD}                                   text|100ms|//*[@name\="schedulBSD"]
# ${miNrCellUtilPerPLMN}                          text|15min|//*[@name\="miNrCellUtilPerPLMN"]
# ${actCsirsMultiplexing}                         text|false|//*[@name\="actCsirsMultiplexing"]
# ${actCustomBsr}                                 text|true|//*[@name\="actCustomBsr"]
# ${actDlDataDmrsFdm}                             text|true|//*[@name\="actDlDataDmrsFdm"]
# ${bwp_profile7}       text|MRBTS-1/NRBTS-1/BWP_PROFILE-7|//*[@name\="cellBwpList"]/item[1]/*[@name\="bwpDN"]
# ${bwp_profile73}      text|MRBTS-1/NRBTS-1/BWP_PROFILE-73|//*[@name\="cellBwpList"]/item[2]/*[@name\="bwpDN"]
# ${pattern}            CA_P2_8x4_t2r4_n2
# ${UE1_ID}         1
# ${UE2_ID}         2
# 
# 
# *** Test Cases ***
# CB009235_C_B102_Case35_Enhanced_PM_counters_MU_MIMO_PAIR_DL_FAIL_SE
#     Step1:Commission the above configuration on WebUI
#     Step2:UE1 1layer UE2 3layer DL MU
#     Step3:Change UE position to low correlation
# 
# *** Keywords ***
# Step1:Commission the above configuration on WebUI
#     Start Capture GNB and AP Syslog in 'Step1_before_onair' File
#     ${CONFIG_DIR_PATH}    Set Variable    ${CONFIG_DIR_PATH}/${SW_BRANCH}
#     change_iphy_rru_version    ${CONFIG_DIR_PATH}${/}${AIRPHONE_NAME}
#     modify_swconfig_by_CB009235_C    ${CONFIG_DIR_PATH}${/}${SCFC_NAME}
#     ${scfc_path}    Set Variable    ${TEST_LOG_DIRECTORY()}${/}scfc.xml
#     copy_file    ${CONFIG_DIR_PATH}/${SCFC_NAME}    ${scfc_path}
#     ${modify_list}    create list
#     ...       ${chBw}    ${dlMimoMode}    ${nrCellType}    ${actFdmScheduling}    ${actDlMuMimoEnh}    ${dlMuMimoCorrThd}    ${dlMuMimoCqiThd}
#     ...       ${dlMuMimoSpectralEffThd}    ${maxNumLayerPerMuRbg}    ${dlMuMimoRankAdaption}    ${dlMuMimoTaperingH}    ${dlMuMimoTaperingV}
#     ...       ${frameStructureType}    ${guardPeriodLength}    ${lteToNrFrameShift}    ${prachConfigurationIndex}    ${srsUePeriodicity}
#     ...       ${cSRS}    ${bSRS}    ${actBeamforming}    ${basicBeamSet}    ${numberOfTransmittedSsBlocks}    ${nrBtsBeamRefinementP2}
#     ...       ${msg1FrequencyStart}    ${schedulBSD}    ${miNrCellUtilPerPLMN}    ${actDlSrsBm}    ${actCsirsMultiplexing}    ${actDl256Qam}
#     ...       ${bwp_profile7}    ${bwp_profile73}     ${actCustomBsr}    ${actDlDataDmrsFdm}
#     modify_xml    ${scfc_path}    ${scfc_path}    ${modify_list}
#     add_xml_element     ${scfc_path}    ${scfc_path}
#     ...     <p name="customBeamSetName">BSR_AEQE_6_H6_ALN60_ARP60_P00_COVERAGE_00424_00001</p>|//*[@name\='beamSet']/item[1]
#     Modify TL VM And AP SCTP Configuration
#     Get and Update BSR File    par_of_bsr_name=AEQE_6_H6_ALN60_ARP60_P00_COVERAGE_00424_00001
#     Perform Full Commission And Reach Onair With Log    ${scfc_path}    ${CONFIG_DIR_PATH}${/}${WTS_NAME}    reset_after_commission=${False}
#     [Teardown]    run keyword and continue on failure    Stop Capture GNB and AP Syslog in 'Step1_before_onair' File
# 
# Step2:UE1 1layer UE2 3layer DL MU
#     Start capture gnb and ap syslog in 'Step2' file
#     #Start GNB BIP Log
#     ${save_log}=    Set Variable    ${TEST_LOG_DIRECTORY()}Step2
#     Attach SA ue with capability to 5g cell    2    ${pattern}
#     ul_mimo_srs_beam_pos_active    ue=1    profile=1    init=0    sub=0    step=5    scell=0
#     ul_mimo_srs_beam_pos_active    ue=2    profile=2    init=0    sub=4    step=5    scell=0
#     Wait Throughput Timer    3
#     csi_override_testmode_active    ${UE1_ID}    1    0
#     csi_override_testmode_active    ${UE2_ID}    2    2
#     Wait Throughput Timer    3
#     SA send multiple trf data    ${UE1_ID}    DL    175M    3
#     SA send multiple trf data    ${UE1_ID}    UL    175M    1
#     SA send multiple trf data    ${UE2_ID}    DL    175M    3
#     SA send multiple trf data    ${UE2_ID}    UL    175M    1
# #    Stop Gnb BIP Log    log_dir=${save_log}
#     Start GNB Ttitrace With Streaming Mode
#     Wait Throughput Timer    5
#     ${pacp}=    Stop GNB Ttitrace With Streaming Mode    save_path=${save_log}
#     Decoder Tttirace From Pcap To Csv    ${pacp}    ${save_log}${/}tti
# 
#     ${remaining_time}=    get_counter_file_remaining_time    counter_refresh_period=1min
#     Wait Throughput Timer    ${remaining_time}
#     ${PM_counter_file}=    download_latest_pmcounter    local_path=${save_log}${/}
#     Set Suite Variable    ${PM_counter_file}
#     ${DL_SUCC}=           get_counter_value_from_counter_file    counter_file=${PM_counter_file}    counter_id=M55308C34030     cell_id=1
#     ${FAIL_BWP}=          get_counter_value_from_counter_file    counter_file=${PM_counter_file}    counter_id=M55308C34031     cell_id=1
#     ${FAIL_TRAF_TYPE}=    get_counter_value_from_counter_file    counter_file=${PM_counter_file}    counter_id=M55308C34032     cell_id=1
#     ${FAIL_SRS_BEAM}=     get_counter_value_from_counter_file    counter_file=${PM_counter_file}    counter_id=M55308C34033     cell_id=1
#     ${FAIL_LOW_CQI}=      get_counter_value_from_counter_file    counter_file=${PM_counter_file}    counter_id=M55308C34034     cell_id=1
#     ${FAIL_LOW_PRB}=      get_counter_value_from_counter_file    counter_file=${PM_counter_file}    counter_id=M55308C34035     cell_id=1
#     ${FAIL_HIGH_CORR}=    get_counter_value_from_counter_file    counter_file=${PM_counter_file}    counter_id=M55308C34036     cell_id=1
#     ${FAIL_SE}=           get_counter_value_from_counter_file    counter_file=${PM_counter_file}    counter_id=M55308C34037     cell_id=1
#     ${FAIL_OTHER}=        get_counter_value_from_counter_file    counter_file=${PM_counter_file}    counter_id=M55308C34038     cell_id=1
#     run keyword and continue on failure    should be true    ${DL_SUCC}== 0
#     run keyword and continue on failure    should be true    ${FAIL_BWP}== 0
#     run keyword and continue on failure    should be true    ${FAIL_TRAF_TYPE}== 0
#     run keyword and continue on failure    should be true    ${FAIL_SRS_BEAM}== 0
#     run keyword and continue on failure    should be true    ${FAIL_LOW_CQI}== 0
#     run keyword and continue on failure    should be true    ${FAIL_LOW_PRB}== 0
#     run keyword and continue on failure    should be true    ${FAIL_HIGH_CORR}== 168000
#     run keyword and continue on failure    should be true    ${FAIL_SE}== 0
#     run keyword and continue on failure    should be true    ${FAIL_OTHER}== 0
#     [Teardown]    Run Keyword And Ignore Error    Stop capture gnb and ap syslog in 'Step2' file
# 
# 
# Step3:Change UE position to low correlation
#     Start capture gnb and ap syslog in 'Step3' file
#     ${save_log}=    Set Variable    ${TEST_LOG_DIRECTORY()}Step3
# #    Start GNB BIP Log
#     ul_mimo_srs_beam_pos_active    ue=1    profile=1    init=0    sub=0    step=5    scell=0
#     ul_mimo_srs_beam_pos_active    ue=2    profile=2    init=3    sub=2    step=5    scell=0
# #    Stop Gnb BIP Log    log_dir=${save_log}
#     Start GNB Ttitrace With Streaming Mode
#     Wait Throughput Timer    5
#     ${pacp}=    Stop GNB Ttitrace With Streaming Mode    save_path=${save_log}
#     Decoder Tttirace From Pcap To Csv    ${pacp}    ${save_log}${/}tti
# 
#     ${ue1_ul_tput}=    Airphone Get Throughput On Specific Scell    1    0    pusch    current
#     ${ue1_dl_tput}=    Airphone Get Throughput On Specific Scell    1    0    pdsch    current
#     ${ue2_ul_tput}=    Airphone Get Throughput On Specific Scell    2    0    pusch    current
#     ${ue2_dl_tput}=    Airphone Get Throughput On Specific Scell    2    0    pdsch    current
# 
#     ${remaining_time}=    get_counter_file_remaining_time    counter_refresh_period=1min
#     Wait Throughput Timer    ${remaining_time}
#     ${PM_counter_file}=    download_latest_pmcounter    local_path=${save_log}${/}
#     Set Suite Variable    ${PM_counter_file}
#     ${DL_SUCC}=           get_counter_value_from_counter_file    counter_file=${PM_counter_file}    counter_id=M55308C34030     cell_id=1
#     ${FAIL_BWP}=          get_counter_value_from_counter_file    counter_file=${PM_counter_file}    counter_id=M55308C34031     cell_id=1
#     ${FAIL_TRAF_TYPE}=    get_counter_value_from_counter_file    counter_file=${PM_counter_file}    counter_id=M55308C34032     cell_id=1
#     ${FAIL_SRS_BEAM}=     get_counter_value_from_counter_file    counter_file=${PM_counter_file}    counter_id=M55308C34033     cell_id=1
#     ${FAIL_LOW_CQI}=      get_counter_value_from_counter_file    counter_file=${PM_counter_file}    counter_id=M55308C34034     cell_id=1
#     ${FAIL_LOW_PRB}=      get_counter_value_from_counter_file    counter_file=${PM_counter_file}    counter_id=M55308C34035     cell_id=1
#     ${FAIL_HIGH_CORR}=    get_counter_value_from_counter_file    counter_file=${PM_counter_file}    counter_id=M55308C34036     cell_id=1
#     ${FAIL_SE}=           get_counter_value_from_counter_file    counter_file=${PM_counter_file}    counter_id=M55308C34037     cell_id=1
#     ${FAIL_OTHER}=        get_counter_value_from_counter_file    counter_file=${PM_counter_file}    counter_id=M55308C34038     cell_id=1
#     run keyword and continue on failure    should be true    ${DL_SUCC}>0
#     run keyword and continue on failure    should be true    ${FAIL_BWP}== 0
#     run keyword and continue on failure    should be true    ${FAIL_TRAF_TYPE}== 0
#     run keyword and continue on failure    should be true    ${FAIL_SRS_BEAM}== 0
#     run keyword and continue on failure    should be true    ${FAIL_LOW_CQI}== 0
#     run keyword and continue on failure    should be true    ${FAIL_LOW_PRB}== 0
#     run keyword and continue on failure    should be true    ${FAIL_HIGH_CORR}== 0
#     run keyword and continue on failure    should be true    ${FAIL_SE}> 160000
#     run keyword and continue on failure    should be true    ${FAIL_OTHER}== 0
#     [Teardown]    Run Keyword And Ignore Error    Stop capture gnb and ap syslog in 'Step3' file
# 
# 
# UE${i} send dl bler
#     airphone_execute_egate_command    bler_testmode_nr profile_id\=1 dl_bler\=100,80,3,4
#     airphone_execute_egate_command    ue_testmode_set_nr id\=${i} scell\=0 testmode\=bler profile_id\=1 action\=activate
# 
# modify_swconfig_by_CB009235_C
#     comment     https://confluence.ext.net.nokia.com/pages/viewpage.action?spaceKey=AirPhoneWTS&title=AirPhone+Alignment+to+gNB+L1L2+Interface
#     [Arguments]    ${scfc_file}
#     ${local_save_path}=     Download All Common Config Files From Golden Server
#     #${path_gnb}=            QC Find Match GNB swconfig Golden Files    ${scfc_file}    ${local_save_path}
#     ${path_gnb}=            Find Match GNB swconfig Golden Files    ${scfc_file}    ${local_save_path}
#     setup_txt    src_file=${path_gnb}    save_path=${TEST_LOG_DIRECTORY()}${/}swconfig_gnb_ini.txt
#     #add_txt_node   0x340000:15          #as PM counter period update to 15/15=1min
# 	add_txt_node   0x9D0000:15          #as PM counter period update to 15/15=1min
#     add_txt_node   0x580264:0x3         #coma log
#     add_txt_node   0x580477:1           #print beam calc log
#     add_txt_node   0x580542:0x5         #rdDlMuMimoSpectralEffPerUeThd
#     teardown_txt
#     GNB Upload Swconfig           ${TEST_LOG_DIRECTORY()}${/}swconfig_gnb_ini.txt