# *** Settings ***
# Documentation     Author: xuemin.ma@nokia-sbell.com
# ...
# ...               example case for RAN HZ L2 SW11. test step description in QC as below:
# ...
# ...               QC case full name:
# ...               CB007922_Case121_D_C4_multiUE_non_GB_vonr_bufferbased_and_blind_activation_withDRX
# ...
# 
# Test Timeout      60 minutes
# Suite Setup       Common Suite Setup
# #Suite Teardown    Common Suite Teardown
# Test Setup        Common Test Setup
# Test Teardown     Common Test Teardown
# Force Tags        CLOUD_5G_I_LO_AP_LO_SANSA_FS_ECPRI_CMWV_TDD    5G_RAN_TDD    RAN_5G    CRT    SBTS00    SBTS23R1
# ...    owner_jiangzhaona    AP
# Resource          ../resources/sg11/internal_resource/robot/modify_configuration.robot
# Library           ta_a2a
# 
# *** Variables ***
# ${CONFIG_DIR_PATH}    ${CURDIR}/../resources/sg11/internal_resource/config/
# ${UE_ID}          1
# ${PDU_ID}         1
# ${GW_ID}          1
# ${SLICE_ID}       1
# ${SCFC_NAME}      gNB_scf_ASIL_ABIO_TDD_eCPRI_cmwv_SANSA_L1b_4S_1CC.xml
# ${AIRPHONE_NAME}    AP_iphy_AEQE_LO_AP_LO_TDD_eCPRI_cmwv_SANSA_L1b_4S_1CC.xml
# ${WTS_NAME}       wts_config_ASIB_ABIO_TDD_eCPRI_cmwv_SANSA_L1b_4S_1CC.cfg
# @{LOG_NAME_LIST}    gnb_snapshot    sosreport    tshark    egatelog
# ${carrierAggregationSupportList}                text|ca_Fr1Tdd_Sa|//list[@name\="carrierAggregationSupportList"]/p
# ${actInterNumerologyCa}                         text|false|//*[@name\="actInterNumerologyCa"]
# ${flexibleCAMode}                               text|MixedCAMode|//*[@name\="flexibleCAMode"]
# ${pucchModeSelect}                              text|longPucch|//*[@name\="pucchModeSelect"]
# ${actBeamforming}                               text|true|//*[@name\="actBeamforming"]
# ${numberOfRxBeamforming}                        text|4Rx|//*[@name\="numberOfRxBeamforming"]
# ${nrBtsBeamRefinementP2}                        text|false|//*[@name\="nrBtsBeamRefinementP2"]
# ${numberOfTransmittedSsBlocks}                  text|6 beams|//*[@name\="numberOfTransmittedSsBlocks"]
# ${basicBeamSet}                                 text|beamSet_6|//*[@name\="basicBeamSet"]
# ${frameStructureType}                           text|tdLte|//*[@name\="frameStructureType"]
# ${guardPeriodLength}                            text|6Symbols|//*[@name\="guardPeriodLength"]
# ${lteToNrFrameShift}                            text|0ms|//*[@name\="lteToNrFrameShift"]
# ${prachConfigurationIndex}                      text|97|//*[@name\="prachConfigurationIndex"]
# ${ssBurstSetPeriod}                             text|20|//*[@name\="ssBurstSetPeriod"]
# ${cellDepType}                                  text|SA+NSA|//*[@name\="cellDepType"]
# ${maxNumScellsDl}                               text|1|//*[@name\="maxNumScellsDl"]
# ${actFdmScheduling}                             text|true|//*[@name\="actFdmScheduling"]
# ${actCDrx}                                      text|true|//*[@name\="actCDrx"]
# ${actCDrxVoNR}                                  text|true|//*[@name\="actCDrxVoNR"]
# ${actVoNR}                                      text|true|//*[@name\="actVoNR"]
# ${actEnhancedVoNR}                              text|true|//*[@name\="actEnhancedVoNR"]
# ${csiReportPeriodicity}                         text|slots320|//*[@name\="csiReportPeriodicity"]
# ${sCellAdditionMethod}                          text|blind|//*[@name\="sCellAdditionMethod"]
# ${sCellActivationMethod}                        text|blind|//*[@name\="sCellActivationMethod"]
# ${a1MeasSCellAddEnabled}                        text|rsrp|//*[@name\="a1MeasSCellAddEnabled"]
# ${actMeasBasedSCellAddition}                    text|true|//*[@name\="actMeasBasedSCellAddition"]
# ${sCellDeactivationTimerGNB}                    text|infinity|//*[@name\="sCellDeactivationTimerGNB"]
# ${chBw3}           text|80MHz|//*[contains(@distName, 'NRCELL-3')]/*[@name='chBw']
# ${chBw4}           text|80MHz|//*[contains(@distName, 'NRCELL-4')]/*[@name='chBw']
# ${dlMimoMode}    text|4x4 or 4x2 Closed Loop Spatial Multiplexing|//*[@name="dlMimoMode"]
# ${discardTimer}           text|1500ms|//*[contains(@distName, 'NRDRB-15')]/*[@name='discardTimer']
# *** Test Cases ***
# CB007922_Case121_D_C4_multiUE_non_GB_vonr_bufferbased_and_blind_activation_withDRX
#     Step 1: Set parameter and wait for onair
#     Step 2: Attach ue1 to 5QI-1 with blind addition and blind activation,start traffic for 5QI-1
#     Step 3: Attach ue2 to 5QI-6 with blind addition and blind activation,start traffic for 5QI-6
# 	Step 4: Check counter update correcttly
# 
# *** Keywords ***
# Step 1: Set parameter and wait for onair
#     Start Collect GNB and AP Syslog in 'step1_before_onair' File
#     ${CONFIG_DIR_PATH}    Set Variable    ${CONFIG_DIR_PATH}/${SW_BRANCH}
# 	change_iphy_rru_version        ${CONFIG_DIR_PATH}${/}${AIRPHONE_NAME}
# 	modify_swconfig_by_CB007922    ${CONFIG_DIR_PATH}${/}${SCFC_NAME}
# 	${scfc_path}                Set Variable                 ${TEST_LOG_DIRECTORY()}${/}scfc.xml
# 	copy_file          ${CONFIG_DIR_PATH}/${SCFC_NAME}     ${scfc_path}
# 	add_ca_relation_CB7922    ${scfc_path}
# 	add_vonr_extend_parameter_on_bts      xml_path=${scfc_path}
# 	add_drxprofile_list_in_cells    xml_path=${scfc_path}    profile_id=2
# 	...     drxInactivityTimer=4ms    drxLongCycle=40ms    drxOnDurationTimer=6ms    drxRetransTimerDl=0slot    drxRetransTimerUl=0slot
# 	${modify_list}      create list
#     ...     ${carrierAggregationSupportList}
#     ...     ${actInterNumerologyCa}
#     ...     ${flexibleCAMode}
#     ...     ${pucchModeSelect}
#     ...     ${actBeamforming}
#     ...     ${nrBtsBeamRefinementP2}
#     ...     ${numberOfTransmittedSsBlocks}
#     ...     ${basicBeamSet}
#     ...     ${frameStructureType}
#     ...     ${guardPeriodLength}
#     ...     ${lteToNrFrameShift}
#     ...     ${prachConfigurationIndex}
#     ...     ${ssBurstSetPeriod}
#     ...     ${cellDepType}
#     ...     ${maxNumScellsDl}
#     ...     ${actFdmScheduling}
#     ...     ${actCDrx}
#     ...     ${actCDrxVoNR}
#     ...     ${actVoNR}
#     ...     ${actEnhancedVoNR}
#     ...     ${csiReportPeriodicity}
#     ...     ${sCellAdditionMethod}
#     ...     ${sCellActivationMethod}
#     ...     ${a1MeasSCellAddEnabled}
#     ...     ${actMeasBasedSCellAddition}
#     ...     ${sCellDeactivationTimerGNB}
# 	...     ${chBw3}
# 	...     ${chBw4}
# 	...     ${dlMimoMode}
# 	...     ${discardTimer}
# 	...     ${numberOfRxBeamforming}
#     modify_xml  	    ${scfc_path}        ${scfc_path}         ${modify_list}
#     Modify TL VM And AP SCTP Configuration
# 	Perform Full Commission And Reach Onair
# 	...    ${scfc_path}
# 	...    ${CONFIG_DIR_PATH}${/}${WTS_NAME}
# 	...    reset_after_commission=${False}
#     [Teardown]    Stop Collect GNB and AP Syslog in 'step1_before_onair' File
# 
# add_ca_relation_CB7922
#     [Arguments]    ${scfc_path}
# 	comment  cell1 and cell2 is intra cell, cell2 and cell3 is inter cell, cell3 and cell4 is diff band cell
# 	add_nrrel_extend_parameter_on_cell    xml_path=${scfc_path}    cellid=1    lcrid=2
# 	add_nrrel_extend_parameter_on_cell    xml_path=${scfc_path}    cellid=2    lcrid=3
# 	add_nrrel_extend_parameter_on_cell    xml_path=${scfc_path}    cellid=3    lcrid=4
# 	add_nrrel_extend_parameter_on_cell    xml_path=${scfc_path}    cellid=4    lcrid=1
# 
# Step 2: Attach ue1 to 5QI-1 with blind addition and blind activation,start traffic for 5QI-1
#     Start Collect GNB and AP Syslog in 'step2_ue1_attach' File
#     #Start GNB BIP Log
#     #Start AP BIP Log
#     #Start GNB Ttitrace With Streaming Mode
#     airphone_set_traffic_type    ${UE_ID}    ${PDU_ID}    internal
# 	${ue_ability}    Obtain Ue Capability    vonr_n78
#     Airphone SA Attach    ue_id=${UE_ID}    ue_capability=${ue_ability}
#     Airphone Pdu Session Setup    ${UE_ID}    ${PDU_ID}    ${SLICE_ID}    ${GW_ID}
# 	check scell activated
# 	Airphone Pdu Session Modify    qosflows_to_add=2    by=amf    pass_regexp=Created FiveQi:Qfi mapping fiveQi 5 qfi 2
# 	Wait Throughput Timer    5
# 	Airphone Pdu Session Modify    qosflows_to_add=3    by=amf    pass_regexp=Created FiveQi:Qfi mapping fiveQi 1 qfi 3
# 	Wait Throughput Timer    5
# 	airphone_execute_egate_command    trf_data_start ue\=1 pdu\=1 qfi\=3 trf_id\=1 mbps\=5 dir\=dl seconds\=3600
#     #${pacp}=    Stop GNB Ttitrace With Streaming Mode    save_path=${TEST_LOG_DIRECTORY()}step2_ue1_attach
#     #Stop Gnb BIP Log    log_dir=${TEST_LOG_DIRECTORY()}${/}step2_ue1_attach${/}
#     #Stop AP BIP Log    log_dir=${TEST_LOG_DIRECTORY()}${/}step2_ue1_attach${/}
#     [Teardown]    Stop Collect GNB and AP Syslog in 'step2_ue1_attach' File
# 
# check scell activated
#     Wait Throughput Timer    10s
#     airphone_collect_egate_log_files      ${TEST_LOG_DIRECTORY()}/All    unzip=TRUE
#     check_log_with_au2anlysis    ini_path=${CURDIR}/A2A_log_Check/Case121_ScellActivate.ini
#     ...        log_need_to_check=u    save_log_directory=${TEST_LOG_DIRECTORY()}/All
# 
# check drx config
#     airphone_collect_egate_log_files      ${TEST_LOG_DIRECTORY()}/All    unzip=TRUE
#     check_log_with_au2anlysis    ini_path=${CURDIR}/A2A_log_Check/Case121_DrxConfig.ini
#     ...        log_need_to_check=u    save_log_directory=${TEST_LOG_DIRECTORY()}/All
# 
# Step 3: Attach ue2 to 5QI-6 with blind addition and blind activation,start traffic for 5QI-6
#     Start Collect GNB and AP Syslog in 'step3_ue2_attach' File
#     #Start GNB BIP Log
#     #Start AP BIP Log
#     #Start GNB Ttitrace With Streaming Mode
#     airphone_set_traffic_type    ue_id=2    pdu_id=1    type=internal
# 	${ue_ability}    Obtain Ue Capability    vonr_n78
#     Airphone SA Attach    ue_id=2    ue_capability=${ue_ability}
#     Airphone Pdu Session Setup    ue_id=2    pdu_id=1   nwslice_id=1     gw_id=2
#     Wait Throughput Timer    5
#     airphone_execute_egate_command    trf_data_start ue\=2 pdu\=1 qfi\=1 trf_id\=1 mbps\=175 dir\=dl seconds\=3600
#     airphone_execute_egate_command    trf_data_start ue\=2 pdu\=1 qfi\=1 trf_id\=2 mbps\=175 dir\=dl seconds\=3600
#     #${pacp}=    Stop GNB Ttitrace With Streaming Mode    save_path=${TEST_LOG_DIRECTORY()}step3_ue2_attach
#     #Stop Gnb BIP Log    log_dir=${TEST_LOG_DIRECTORY()}${/}step3_ue2_attach{/}
#     #Stop AP BIP Log    log_dir=${TEST_LOG_DIRECTORY()}${/}step3_ue2_attach{/}
#     [Teardown]    Stop Collect GNB and AP Syslog in 'step3_ue2_attach' File
# 
# Step 4: Check counter update correcttly
#     Start Collect GNB and AP Syslog in 'step4_check_counter' File
#     ${Pcell_dl_throughput_ue1} =    Airphone Get Throughput On Specific Scell    ue_id=1    scell_id=0    type=pdsch    tput_type=ave
#     ${Scell_dl_throughput_ue1} =    Airphone Get Throughput On Specific Scell    ue_id=1    scell_id=1    type=pdsch    tput_type=ave
#     ${Pcell_dl_throughput_ue2} =    Airphone Get Throughput On Specific Scell    ue_id=2    scell_id=0    type=pdsch    tput_type=ave
#     ${Scell_dl_throughput_ue2} =    Airphone Get Throughput On Specific Scell    ue_id=2    scell_id=1    type=pdsch    tput_type=ave
#     should be true    ${Pcell_dl_throughput_ue1}>0
# 	should be true    ${Pcell_dl_throughput_ue2}>0
#     should be true    ${Scell_dl_throughput_ue2}>0
# 	${remaining_time}=    get_counter_file_remaining_time    counter_refresh_period=1min
#     Wait Throughput Timer    ${remaining_time}
#     ${PM_counter_file}=    download_latest_pmcounter    local_path=${TEST_LOG_DIRECTORY()}step4_check_counter${/}
#     ${PM_counter_value5qi1_p}=    get_counter_value_from_counter_file    counter_file=${PM_counter_file}
#     ...    counter_id=M55310C01001    cell_id=1
#     ${PM_counter_value5qi1_s}=    get_counter_value_from_counter_file    counter_file=${PM_counter_file}
#     ...    counter_id=M55310C01001    cell_id=2
#     ${PM_counter_value5qi5_p}=    get_counter_value_from_counter_file    counter_file=${PM_counter_file}
#     ...    counter_id=M55310C01005    cell_id=1
#     ${PM_counter_value5qi5_s}=    get_counter_value_from_counter_file    counter_file=${PM_counter_file}
#     ...    counter_id=M55310C01005    cell_id=2
#     ${PM_counter_value5qi6_p}=    get_counter_value_from_counter_file    counter_file=${PM_counter_file}
# 	...    counter_id=M55310C01006    cell_id=1
#     ${PM_counter_value5qi6_s}=    get_counter_value_from_counter_file    counter_file=${PM_counter_file}
#     ...    counter_id=M55310C01006    cell_id=2
# 	should be true    ${PM_counter_value5qi1_p}>0
# 	should be true    ${PM_counter_value5qi1_s}==0
# 	should be true    ${PM_counter_value5qi5_p}==0
#     should be true    ${PM_counter_value5qi5_s}==0
#     should be true    ${PM_counter_value5qi6_p}>0
#     should be true    ${PM_counter_value5qi6_s}>0
#     [Teardown]    Stop Collect GNB and AP Syslog in 'step4_check_counter' File
