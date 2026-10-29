# *** Settings ***
# Documentation     Author: shuiheng.he@nokia-sbell.com
# ...
# ...               QC case full name:
# ...               CB008305_case123_B_4_PM counters for DL MU-MIMO
# ...
# 
# Suite Setup       Common Suite Setup
# Suite Teardown    Common Suite Teardown
# Test Setup        Common Test Setup
# Test Teardown     Common Test Teardown
# Force Tags        CLOUD_5G_I_BO_AP_KL_SANSA_L1B_ECPRI_CMWV_TDD    AP    CRT    SBTS00    RAN_5G_TDD    RAN_5G    owner_shuihe
# Test Timeout      90 minutes
# Resource          ../../resources/sg11/internal_resource/robot/modify_configuration.robot
# Resource          ../../resources/sg11/internal_resource/robot/internal_ap_operate.robot
# Resource          ../../resources/sg11/internal_resource/robot/internal_gnb_operate.robot
# Library     taf.transport.ssh    WITH NAME    TAF_SSH
# Library           ta_a2a
# 
# *** Variables ***
# ${CONFIG_DIR_PATH}    ${CURDIR}/../../resources/sg11/internal_resource/config/
# ${SCFC_NAME}      gNB_scf_ASIB_ABIO_TDD_eCPRI_cmwv_SANSA_L1b_1S_1CC_20Mhz.xml
# ${AIRPHONE_NAME}    AP_iphy_AEQE_ASIB_ABIO_TDD_eCPRI_cmwv_SANSA_L1b_1S_1CC.xml
# ${WTS_NAME}       wts_config_ASIB_ABIO_TDD_eCPRI_cmwv_SANSA_L1b_1S_1CC.cfg
# ${COMAVALUE}    ${CURDIR}/../../resources/sg11/internal_resource/config/AP/ap_coma.txt
# @{LOG_NAME_LIST}    gnb_snapshot    sosreport    egatelog\
# ${cellDepType}                                  text|SA+NSA|//*[@name\="cellDepType"]
# ${chBw}                                         text|20MHz|//*[@name\="chBw"]
# ${dlMimoMode}                                   text|8x4 Closed Loop Spatial Multiplexing|//*[@name\="dlMimoMode"]
# ${nrCellType}                                   text|8DL4UL|//*[@name\="nrCellType"]
# ${actFdmScheduling}                             text|true|//*[@name\="actFdmScheduling"]
# ${actUlSrsBm}                                   text|true|//*[@name\="actUlSrsBm"]
# ${actUlMuMimo}                                  text|true|//*[@name\="actUlMuMimo"]
# ${ulMaxMuMimoLayer}                             text|2|//*[@name\="ulMaxMuMimoLayer"]
# ${ulMinPrbThreshold}                            text|50|//*[@name\="ulMinPrbThreshold"]
# ${ulMuMimoPrbThresholdAbsolute}                 text|20|//*[@name\="ulMuMimoPrbThresholdAbsolute"]
# ${ulMuMimoCorrThd}                              text|5|//*[@name\="ulMuMimoCorrThd"]
# ${ulMuMimoSinrThd}                              text|5|//*[@name\="ulMuMimoSinrThd"]
# ${ulMuMimoSpectralEffThd}                       text|1|//*[@name\="ulMuMimoSpectralEffThd"]
# ${ulMuMimoLinkAdaptionSwitch}                   text|MU-SINR estimation|//*[@name\="ulMuMimoLinkAdaptionSwitch"]
# ${frameStructureType}                           text|tdLte|//*[@name\="frameStructureType"]
# ${guardPeriodLength}                            text|6Symbols|//*[@name\="guardPeriodLength"]
# ${lteToNrFrameShift}                            text|0ms|//*[@name\="lteToNrFrameShift"]
# ${prachConfigurationIndex}                      text|97|//*[@name\="prachConfigurationIndex"]
# ${srsUePeriodicity}                             text|slots40|//*[@name\="srsUePeriodicity"]
# ${cSRS}                                         text|49|//*[@name\="cSRS"]
# ${bSRS}                                         text|2|//*[@name\="bSRS"]
# ${actBeamforming}                               text|true|//*[@name\="actBeamforming"]
# ${basicBeamSet}                                 text|beamSet_6|//*[@name\="basicBeamSet"]
# ${nrBtsBeamRefinementP2}                        text|false|//*[@name\="nrBtsBeamRefinementP2"]
# ${msg1FrequencyStart}                           text|2|//*[@name\="msg1FrequencyStart"]
# ${actUlMuMimoTapering}                          text|false|//*[@name\="actUlMuMimoTapering"]
# ${schedulBSD}                                   text|100ms|//*[@name\="schedulBSD"]
# ${miNrCellUtilPerPLMN}                           text|15min|//*[@name\="miNrCellUtilPerPLMN"]
# ${dlMuMimoRankAdaption}                         text|always|//*[@name\="dlMuMimoRankAdaption"]
# ${pattern}    CA_P2_8x4_t2r4_n2
# ${pattern002}    vonr_n78
# 
# *** Test Cases ***
# CB008305_case123_B_4_PM counters for DL MU-MIMO
#     Step1:Commission the above configuration on WebUI
#     Step2:Attach 4 NonGBR UEs Aad 1 GBR UE
#     Step3:Push full buffer in DL And Make GBR Call
#     Step4:Online modify maxNumLayerPerMuRbg=6 to check counter
#     Step5:Online modify maxNumLayerPerMuRbg=4 to check counter
# 
# *** Keywords ***
# Step1:Commission the above configuration on WebUI
#     Start Collect GNB and AP Syslog in 'Step1_before_onair' File
# 	${CONFIG_DIR_PATH}    Set Variable    ${CONFIG_DIR_PATH}/${SW_BRANCH}
#     change_iphy_rru_version    ${CONFIG_DIR_PATH}${/}${AIRPHONE_NAME}
#     Airphone Download L1ByPTestModeConfiguration from ABIL    ${test_log_directory()}/L1ByPTestModeConfiguration.xml
#     Set Pos By Modify L1ByPTestModeConfiguration    15    6    15    6    15    6    15    6    0
#     Set Pos By Modify L1ByPTestModeConfiguration    12    6    12    6    12    6    12    6    1
#     Set Pos By Modify L1ByPTestModeConfiguration    6    0    6    0    6    0    6    0    2
#     Set Pos By Modify L1ByPTestModeConfiguration    21    0    21    0    21    0    21    0    3
#     Set Pos By Modify L1ByPTestModeConfiguration    21    0    21    0    21    0    21    0    4
#     Airphone Upload L1ByPTestModeConfiguration to ASIK    ${test_log_directory()}/L1ByPTestModeConfiguration.xml
#     modify_swconfig_by_CB008305    ${CONFIG_DIR_PATH}${/}${SCFC_NAME}
#     ${scfc_path}    Set Variable    ${TEST_LOG_DIRECTORY()}${/}scfc.xml
#     copy_file    ${CONFIG_DIR_PATH}/${SCFC_NAME}    ${scfc_path}
#     add_vonr_extend_parameter_on_bts    xml_path=${scfc_path}
#     ${modify_list}    create list
#     ...       ${cellDepType}    ${chBw}    ${dlMimoMode}    ${nrCellType}    ${actFdmScheduling}    ${actUlSrsBm}    ${actUlMuMimo}
#     ...       ${ulMaxMuMimoLayer}    ${actUlMuMimoTapering}
#     ...       ${ulMinPrbThreshold}    ${ulMuMimoPrbThresholdAbsolute}    ${ulMuMimoCorrThd}    ${ulMuMimoSinrThd}    ${ulMuMimoSpectralEffThd}
#     ...       ${ulMuMimoLinkAdaptionSwitch}    ${frameStructureType}    ${guardPeriodLength}    ${lteToNrFrameShift}    ${prachConfigurationIndex}
#     ...       ${srsUePeriodicity}    ${cSRS}    ${bSRS}    ${actBeamforming}    ${basicBeamSet}    ${nrBtsBeamRefinementP2}    ${msg1FrequencyStart}
#     ...       ${schedulBSD}    ${miNrCellUtilPerPLMN}    ${dlMuMimoRankAdaption}
#     modify_xml    ${scfc_path}    ${scfc_path}    ${modify_list}
#     add_xml_element     ${scfc_path}    ${scfc_path}     <p name="pdcpDelayThreshRetxMode">disabled</p>|//*[contains(@distName, 'NRDRB_PDCP-3')]
#     add_xml_element     ${scfc_path}    ${scfc_path}     <p name="discardTimer">1500ms</p>|//*[contains(@distName, 'NRDRB-15')]
#     add_xml_element     ${scfc_path}    ${scfc_path}     <p name="schedulBSD">50ms</p>|//*[contains(@distName, 'NRDRB_MAC-3')]
#     Modify TL VM And AP SCTP Configuration
#     Perform Full Commission And Reach Onair With Log    ${scfc_path}    ${CONFIG_DIR_PATH}${/}${WTS_NAME}    reset_after_commission=${False}
#     [Teardown]    Stop Collect GNB and AP Syslog in 'Step1_before_onair' File
# 
# modify_swconfig_by_CB008350_Case123
#     comment     https://confluence.ext.net.nokia.com/pages/viewpage.action?spaceKey=AirPhoneWTS&title=AirPhone+Alignment+to+gNB+L1L2+Interface
#     [Arguments]    ${scfc_file}    ${add_node1}=none    ${add_node2}=none    ${add_node3}=none    ${add_node4}=rdSrsCodebookAndTas0
# 	${local_save_path}=     Download All Common Config Files From Golden Server
# 	${path_gnb}=            Find Match GNB swconfig Golden Files    ${scfc_file}    ${local_save_path}
# 	${path_ap}=             Find Match AP swconfig Golden Files    ${scfc_file}     ${local_save_path}
#     setup_txt    src_file=${path_gnb}    save_path=${TEST_LOG_DIRECTORY()}${/}swconfig_gnb_ini.txt
# 	add_txt_node    0x340000:15         #as PM counter period update to 15/15=1min
# 	add_txt_node    0x580264:0x3        #rdDlSrsLogControl
# 	add_txt_node    0x58037c:1          #rdSINRusedForRank1LA
# 	add_txt_node    0x580543:0x46        #rdRescaledSuSINR
#     teardown_txt
# 	setup_txt    src_file=${path_ap}    save_path=${TEST_LOG_DIRECTORY()}${/}swconfig_ap_ini.txt
#     add_txt_node    0x70690:1         #enable 1086 and 8247
#     teardown_txt
#     GNB Upload Swconfig           ${TEST_LOG_DIRECTORY()}${/}swconfig_gnb_ini.txt
#     airphone_upload_swconfig      ${TEST_LOG_DIRECTORY()}${/}swconfig_ap_ini.txt
# 
# Step2:Attach 4 NonGBR UEs Aad 1 GBR UE
#     Start Collect GNB and AP Syslog in 'Step2_attach' File
#     Start GNB BIP Log
#     run keyword and continue on failure    Attach SA ue with capability to 5g cell    1    CA_P2_8x4_t2r4_n2
#     run keyword and continue on failure    Attach SA ue with capability to 5g cell From 2    1    CA_P2_8x4_t2r4_n2
#     run keyword and continue on failure    Attach SA ue with capability to 5g cell From 3    1    CA_P2_8x4_t2r4_n2
#     run keyword and continue on failure    Attach SA ue with capability to 5g cell From 4    1    CA_P2_8x4_t2r4_n2
#     run keyword and continue on failure    Attach SA ue with capability to 5g cell From 5    1    vonr_n78
#     Wait Throughput Timer    5
#     Stop Gnb BIP Log    log_dir=${TEST_LOG_DIRECTORY()}${/}Step2_attach${/}
#     airphone_collect_egate_log_files      ${TEST_LOG_DIRECTORY()}${/}Step2_attach${/}   unzip=TRUE
#     [Teardown]    Stop Collect GNB and AP Syslog in 'Step2_attach' File
# 
# Step3:Push full buffer in DL And Make GBR Call
#     Start Collect GNB and AP Syslog in 'Step3' File
#     Start GNB BIP Log
#     : FOR    ${i}    IN RANGE    1     5
#     \    Airphone SA Start Data Traffic    ${i}    DL    150M    trf_id=1    pdu_id=1    duration=${3600}
#     \    Airphone SA Start Data Traffic    ${i}    DL    150M    trf_id=1    pdu_id=1    duration=${3600}
#     \    Airphone SA Start Data Traffic    ${i}    DL    150M    trf_id=1    pdu_id=1    duration=${3600}
#     \    Airphone SA Start Data Traffic    ${i}    DL    150M    trf_id=1    pdu_id=1    duration=${3600}
#     \    Airphone SA Start Data Traffic    ${i}    DL    150M    trf_id=1    pdu_id=1    duration=${3600}
#     airphone_execute_egate_command    ue_pdu_session_modify ue\=5 pdu\=1 qosflows_to_add\=2 by\=amf
#     ...    pass_regexp=Created FiveQi:Qfi mapping fiveQi 5 qfi 2
#     Wait Throughput Timer    5
#     airphone_execute_egate_command    ue_pdu_session_modify ue\=5 pdu\=1 qosflows_to_add\=3 by\=amf
#     ...    pass_regexp=Created FiveQi:Qfi mapping fiveQi 1 qfi 3
#     Wait Throughput Timer    8
#     airphone_execute_egate_command    trf_data_start ue\=5 pdu\=1 qfi\=3 trf_id\=1 mbps\=70 dir\=dl protocol\=tcp seconds\=3600
#     Airphone Csi Override Testmode Nr    profile_id=1    cqi=15    ri=1    cri=1    li=1    pmi=500
#     Airphone Execute Egate Command    ue_testmode_set_nr id\=5 testmode\=csi_override action\=activate profile_id\=1
#     Stop Gnb BIP Log    log_dir=${TEST_LOG_DIRECTORY()}${/}Step3_inject_buffer${/}
#     ${Dl_throughput_ue1} =    Airphone Sa Get Throughput    ue_id=1    direction=dl
#     ${Dl_throughput_ue2} =    Airphone Sa Get Throughput    ue_id=2    direction=dl
#     ${Dl_throughput_ue3} =    Airphone Sa Get Throughput    ue_id=3    direction=dl
#     ${Dl_throughput_ue4} =    Airphone Sa Get Throughput    ue_id=4    direction=dl
#     ${Dl_throughput_ue5} =    Airphone Sa Get Throughput    ue_id=5    direction=dl
#     Start GNB Ttitrace With Streaming Mode
#     Wait Throughput Timer    4
#     ${save_log}=    Set Variable    ${TEST_LOG_DIRECTORY()}Step3
#     ${pacp}=    Stop GNB Ttitrace With Streaming Mode    save_path=${save_log}
#     Decoder Tttirace From Pcap To Csv    ${pacp}    ${save_log}/tti
#     run keyword and continue on failure    check_log_with_au2anlysis
#     ...    ini_path=${CURDIR}/log_check/tti_case123_step3.ini    log_need_to_check=i    save_log_directory=${save_log}
#     Check MU8layer, 4PairUE, 5QI1, Legacy PM counter
#     [Teardown]    Stop Collect GNB and AP Syslog in 'Step3' File
# 
# Check MU8layer, 4PairUE, 5QI1, Legacy PM counter
#     ${remaining_time}=    get_counter_file_remaining_time    counter_refresh_period=1min
#     ${remaining_time}     evaluate    ${remaining_time}+10
#     Wait Throughput Timer    ${remaining_time}
#     ${PM_counter_file}=    download_latest_pmcounter    local_path=${TEST_LOG_DIRECTORY()}Step2${/}
#     ${PM_counter_8layer_value}=    get_counter_value_from_counter_file
#     ...   counter_file=${PM_counter_file}
#     ...   counter_id=M55308C34011
#     ...   cell_id=1
#     ${PM_counter_4pairUE_value}=    get_counter_value_from_counter_file
#     ...   counter_file=${PM_counter_file}
#     ...   counter_id=M55308C34015
#     ...   cell_id=1
#     ${PM_counter_usedPrb_value}=    get_counter_value_from_counter_file
#     ...   counter_file=${PM_counter_file}
#     ...   counter_id=M55308C10001
#     ...   cell_id=1
#     run keyword and continue on failure    Should Be True    ${PM_counter_8layer_value} > 700000
#     run keyword and continue on failure    Should Be True    ${PM_counter_4pairUE_value} > 700000
#     run keyword and continue on failure    Should Be True    ${PM_counter_usedPrb_value} > 2500000
#     ${PM_counter_availPrb_value}=    get_counter_value_from_counter_file
#     ...   counter_file=${PM_counter_file}
#     ...   counter_id=M55308C10003
#     ...   cell_id=1
#     run keyword and continue on failure    Should Be True    ${PM_counter_availPrb_value} > 4000000
#     ${PM_counter_MaxAllocPrb_value}=    get_counter_value_from_counter_file
#     ...   counter_file=${PM_counter_file}
#     ...   counter_id=M55308C20001
#     ...   cell_id=1
#     run keyword and continue on failure    Should Be True    ${PM_counter_MaxAllocPrb_value} == 51
#     ${PM_counter_usedPrbPlmn_value}=    get_counter_value_from_counter_file
#     ...   counter_file=${PM_counter_file}
#     ...   counter_id=M55338C00001
#     ...   cell_id=1
#     run keyword and continue on failure    Should Be True    ${PM_counter_availPrb_value} > 2500000
#     ${PM_counter_5qi1_value}=    get_counter_value_from_counter_file
#     ...   counter_file=${PM_counter_file}
#     ...   counter_id=M55308C23002
#     ...   cell_id=1
#     run keyword and continue on failure    Should Be True    ${PM_counter_5qi1_value} > 600000
#     [Return]    ${PM_counter_8layer_value}    ${PM_counter_4pairUE_value}
# 
# Step4:Online modify maxNumLayerPerMuRbg=6 to check counter
#     Start Collect GNB and AP Syslog in 'Step4' File
#     Start GNB BIP Log
#     COAM.Connect To    bts_host=192.168.255.129    bts_port=443    use_ssl=True    name=online
#     COAM.perform_parameter_recommissioning    dist_name=MRBTS-1/NRBTS-2/NRCELL-1/NRDLMUMIMO-1    parameter=dlMuMaxNumLayerPerMuRbg
#     ...    operation=update    value=6    skip_parameter_relation_errors=True    should_activate=True    connection=online
#     Wait until keyword succeeds    600s    30s    Verify BTS Is Onair
#     COAM.teardown admin    connection=online
#     Wait Throughput Timer    30
#     Check MU6layer and 3PairUE PM counter
#     Stop Gnb BIP Log    log_dir=${TEST_LOG_DIRECTORY()}${/}Step4${/}
#     Start GNB Ttitrace With Streaming Mode
#     Wait Throughput Timer    5
#     ${pacp}=    Stop GNB Ttitrace With Streaming Mode    save_path=${TEST_LOG_DIRECTORY()}${/}Step4_se_higher${/}
#     Decoder Tttirace From Pcap To Csv    ${pacp}    ${TEST_LOG_DIRECTORY()}${/}Step4${/}tti
#     [Teardown]    Stop Collect GNB and AP Syslog in 'Step4' File
# 
# Check MU6layer and 3PairUE PM counter
#     ${remaining_time}=    get_counter_file_remaining_time    counter_refresh_period=1min
#     ${remaining_time}     evaluate    ${remaining_time}+10
#     Wait Throughput Timer    ${remaining_time}
#     ${PM_counter_file}=    download_latest_pmcounter    local_path=${TEST_LOG_DIRECTORY()}Step3${/}
#     ${PM_counter_6layer_value}=    get_counter_value_from_counter_file
#     ...   counter_file=${PM_counter_file}
#     ...   counter_id=M55308C34009
#     ...   cell_id=1
#     ${PM_counter_3pairUE_value}=    get_counter_value_from_counter_file
#     ...   counter_file=${PM_counter_file}
#     ...   counter_id=M55308C34014
#     ...   cell_id=1
#     run keyword and continue on failure    Should Be True    ${PM_counter_6layer_value} > 900000
#     run keyword and continue on failure    Should Be True    ${PM_counter_3pairUE_value} > 900000
#     [Return]    ${PM_counter_6layer_value}    ${PM_counter_3pairUE_value}
# 
# Step5:Online modify maxNumLayerPerMuRbg=4 to check counter
#     Start Collect GNB and AP Syslog in 'Step5' File
#     Start GNB BIP Log
#     COAM.Connect To    bts_host=192.168.255.129    bts_port=443    use_ssl=True    name=online
#     COAM.perform_parameter_recommissioning    dist_name=MRBTS-1/NRBTS-2/NRCELL-1/NRDLMUMIMO-1    parameter=dlMuMaxNumLayerPerMuRbg
#     ...    operation=update    value=4    skip_parameter_relation_errors=True    should_activate=True    connection=online
#     Wait until keyword succeeds    600s    30s    Verify BTS Is Onair
#     COAM.teardown admin    connection=online
#     Wait Throughput Timer    30
#     Check MU4layer and 2PairUE PM counter
#     Wait Throughput Timer    8
#     Stop Gnb BIP Log    log_dir=${TEST_LOG_DIRECTORY()}${/}Step5${/}
#     Start GNB Ttitrace With Streaming Mode
#     Wait Throughput Timer    5
#     ${Ul_throughput_ue1} =    Airphone Sa Get Throughput    ue_id=1    direction=ul
#     ${Ul_throughput_ue2} =    Airphone Sa Get Throughput    ue_id=2    direction=ul
#     ${pacp}=    Stop GNB Ttitrace With Streaming Mode    save_path=${TEST_LOG_DIRECTORY()}${/}Step5${/}
#     Decoder Tttirace From Pcap To Csv    ${pacp}    ${TEST_LOG_DIRECTORY()}${/}Step5${/}tti
#     [Teardown]    Stop Collect GNB and AP Syslog in 'Step5' File
# 
# Check MU4layer and 2PairUE PM counter
#     ${remaining_time}=    get_counter_file_remaining_time    counter_refresh_period=1min
#     ${remaining_time}     evaluate    ${remaining_time}+10
#     Wait Throughput Timer    ${remaining_time}
#     ${PM_counter_file}=    download_latest_pmcounter    local_path=${TEST_LOG_DIRECTORY()}Step4${/}
#     ${PM_counter_4layer_value}=    get_counter_value_from_counter_file
#     ...   counter_file=${PM_counter_file}
#     ...   counter_id=M55308C34007
#     ...   cell_id=1
#     ${PM_counter_2pairUE_value}=    get_counter_value_from_counter_file
#     ...   counter_file=${PM_counter_file}
#     ...   counter_id=M55308C34013
#     ...   cell_id=1
#     run keyword and continue on failure    Should Be True    ${PM_counter_4layer_value} > 2600000
#     run keyword and continue on failure    Should Be True    ${PM_counter_2pairUE_value} > 2600000
#     [Return]    ${PM_counter_4layer_value}    ${PM_counter_2pairUE_value}
# 
# Attach SA ue with capability to 5g cell From 2
#     [Arguments]    ${uenum}    ${pattern}    ${from}=2
#     ${ue_ability}    Obtain Ue Capability    ${pattern}
#     : FOR    ${num}    IN RANGE    ${from}    ${uenum}+${from}
#     \    ${attach_status}=    run keyword and return status    Airphone SA Attach    ue_id=${num}    timeout=60    ue_capability=${ue_ability}
#     \    Run Keyword If    '${attach_status}'=='False'    Airphone SA Attach    ue_id=${num}    timeout=60    ue_capability=${ue_ability}
#     \    airphone_set_traffic_type    ${num}    1    internal
#     \    ${pdu_status}=    run keyword and return status    Airphone Pdu Session Setup    ${num}    1    1    ${num}
#     \    ${newNum}=    evaluate    ${num}+8
#     \    Run Keyword If    '${pdu_status}'=='False'    Airphone Pdu Session Setup    ${num}    1    1    ${newNum}
#     \    Wait '2s' for stable running
# 
# Attach SA ue with capability to 5g cell From 3
#     [Arguments]    ${uenum}    ${pattern}    ${from}=3
#     ${ue_ability}    Obtain Ue Capability    ${pattern}
#     : FOR    ${num}    IN RANGE    ${from}    ${uenum}+${from}
#     \    ${attach_status}=    run keyword and return status    Airphone SA Attach    ue_id=${num}    timeout=60    ue_capability=${ue_ability}
#     \    Run Keyword If    '${attach_status}'=='False'    Airphone SA Attach    ue_id=${num}    timeout=60    ue_capability=${ue_ability}
#     \    airphone_set_traffic_type    ${num}    1    internal
#     \    ${pdu_status}=    run keyword and return status    Airphone Pdu Session Setup    ${num}    1    1    ${num}
#     \    ${newNum}=    evaluate    ${num}+8
#     \    Run Keyword If    '${pdu_status}'=='False'    Airphone Pdu Session Setup    ${num}    1    1    ${newNum}
#     \    Wait '2s' for stable running
# 
# Attach SA ue with capability to 5g cell From 4
#     [Arguments]    ${uenum}    ${pattern}    ${from}=4
#     ${ue_ability}    Obtain Ue Capability    ${pattern}
#     : FOR    ${num}    IN RANGE    ${from}    ${uenum}+${from}
#     \    ${attach_status}=    run keyword and return status    Airphone SA Attach    ue_id=${num}    timeout=60    ue_capability=${ue_ability}
#     \    Run Keyword If    '${attach_status}'=='False'    Airphone SA Attach    ue_id=${num}    timeout=60    ue_capability=${ue_ability}
#     \    airphone_set_traffic_type    ${num}    1    internal
#     \    ${pdu_status}=    run keyword and return status    Airphone Pdu Session Setup    ${num}    1    1    ${num}
#     \    ${newNum}=    evaluate    ${num}+8
#     \    Run Keyword If    '${pdu_status}'=='False'    Airphone Pdu Session Setup    ${num}    1    1    ${newNum}
#     \    Wait '2s' for stable running
# 
# Attach SA ue with capability to 5g cell From 5
#     [Arguments]    ${uenum}    ${pattern}    ${from}=5
#     ${ue_ability}    Obtain Ue Capability    ${pattern}
#     : FOR    ${num}    IN RANGE    ${from}    ${uenum}+${from}
#     \    ${attach_status}=    run keyword and return status    Airphone SA Attach    ue_id=${num}    timeout=60    ue_capability=${ue_ability}
#     \    Run Keyword If    '${attach_status}'=='False'    Airphone SA Attach    ue_id=${num}    timeout=60    ue_capability=${ue_ability}
#     \    airphone_set_traffic_type    ${num}    1    internal
#     \    ${pdu_status}=    run keyword and return status    Airphone Pdu Session Setup    ${num}    1    1    ${num}
#     \    ${newNum}=    evaluate    ${num}+8
#     \    Run Keyword If    '${pdu_status}'=='False'    Airphone Pdu Session Setup    ${num}    1    1    ${newNum}
#     \    Wait '2s' for stable running
# 
