# *** Settings ***
# Documentation
# ...               Author: xuemin.ma@nokia-sbell.com
# ...
# ...               QC case full name:CB007922_Case118_D_B_8_A3_rsrp_interRAT_ho_from_CA_to_LTE
# 
# 
# Test Timeout      60 minutes
# Suite Setup       Common Suite Setup
# Suite Teardown    Common Suite Teardown
# Test Setup        Common Test Setup
# Test Teardown     Common Test Teardown
# Force Tags        CLOUD_5G_I_BOO_AP_KLLL_SANSA_L1B_ECPRI_CMWV_TDD    5G_RAN_TDD    RAN_5G    SBTS22R3    Owner_xueminm    SBTS23R1
# Resource          ../resources/sg11/internal_resource/robot/modify_configuration.robot
# 
# *** Variables ***
# ${CONFIG_DIR_PATH}    ${CURDIR}/../resources/sg11/internal_resource/config/
# ${UE_ID}          1
# ${PDU_ID}         1
# ${GW_ID}          1
# ${SLICE_ID}       1
# ${SCFC_NAME}      gNB_scf_ASIB_ABIO_TDD_eCPRI_cmwv_SANSA_L1b_4S_1CC.xml
# ${AIRPHONE_NAME}    AP_iphy_AEQE_ASIB_ABIO_TDD_eCPRI_cmwv_SANSA_L1b_4S_1CC.xml
# ${WTS_NAME}    wts_config_ASIB_ABIO_TDD_eCPRI_cmwv_SANSA_L1b_4S_1CC_interRAT_HO.cfg
# ${B2_CMD}     ue_measurement_send_nr id\=1 meas_id\=4 event\=B2 srsrp_nr\=20 srsrq_nr\=20 ssinr_nr\=20
# ...           phycell_id\=11 nrsrp_nr\=60 nrsrq_nr\=32 nsinr_nr\=59
# @{LOG_NAME_LIST}    gnb_snapshot    sosreport    tshark    egatelog
# ${carrierAggregationSupportList}     text|ca_Fr1Tdd_Sa|//list[@name\="carrierAggregationSupportList"]/p
# ${actInterNumerologyCa}              text|false|//*[@name\="actInterNumerologyCa"]
# ${flexibleCAMode}                    text|MixedCAMode|//*[@name\="flexibleCAMode"]
# ${pucchModeSelect}                   text|longPucch|//*[@name\="pucchModeSelect"]
# ${actBeamforming}                    text|false|//*[@name\="actBeamforming"]
# ${nrBtsBeamRefinementP2}             text|false|//*[@name\="nrBtsBeamRefinementP2"]
# ${numberOfTransmittedSsBlocks}       text|1 beam|//*[@name\="numberOfTransmittedSsBlocks"]
# ${basicBeamSet}                      text|beamSet_1|//*[@name\="basicBeamSet"]
# ${dlMimoMode}                        text|4x4 or 4x2 Closed Loop Spatial Multiplexing|//*[@name\="dlMimoMode"]
# ${nrCellType}                        text|4DL4UL|//*[@name\="nrCellType"]
# ${cellDepType}                       text|SA|//*[@name\="cellDepType"]
# ${actCDrx}                           text|false|//*[@name\="actCDrx"]
# ${frameStructureType}                text|tdLte|//*[@name\="frameStructureType"]
# ${guardPeriodLength}                 text|6Symbols|//*[@name\="guardPeriodLength"]
# ${lteToNrFrameShift}                 text|0ms|//*[@name\="lteToNrFrameShift"]
# ${prachConfigurationIndex}           text|97|//*[@name\="prachConfigurationIndex"]
# ${ssBurstSetPeriod}                  text|20|//*[@name\="ssBurstSetPeriod"]
# ${actDl256Qam}                       text|false|//*[@name\="actDl256Qam"]
# ${sCellAdditionMethod}               text|covBasedA1|//*[@name\="sCellAdditionMethod"]
# ${maxNumScellsDl}                    text|1|//*[@name\="maxNumScellsDl"]
# ${actFdmScheduling}                  text|true|//*[@name\="actFdmScheduling"]
# ${sCellDeactivationBadRlqCount}      text|0|//*[@name\="sCellDeactivationBadRlqCount"]
# ${sCellActivationMethod}             text|blind|//*[@name\="sCellActivationMethod"]
# ${actInterRatHoSA}                   text|true|//*[@name\="actInterRatHoSA"]
# ${actInterRatHoSADlDataForward}      text|true|//*[@name\="actInterRatHoSADlDataForward"]
# ${a2MeashoEnabledSA}                 text|rsrp|//*[@name\="a2MeashoEnabledSA"]
# ${chBw}                              text|80MHz|//*[@name\="chBw"]
# ${agNbCuType}                        text|SA|//*[@name\="gNbCuType"]
# 
# *** Test Cases ***
# CB007922_Case118_D_B_8_A3_rsrp_interRAT_ho_from_CA_to_LTE
#     Step 1: Set parameter and wait for onair
#     Step 2: Attach ue to cell4 with covBasedA1 addition and blind activation
#     Step 3: Send ULDL traffic
#     Step 4: Perform UE handover to enb1 cell1
# 
# *** Keywords ***
# Step 1: Set parameter and wait for onair
#     Start Collect GNB and AP Syslog in 'step1_before_onair' File
#     ${CONFIG_DIR_PATH}    Set Variable    ${CONFIG_DIR_PATH}/${SW_BRANCH}
# 	change_iphy_rru_version        ${CONFIG_DIR_PATH}${/}${AIRPHONE_NAME}
# 	modify_swconfig_by_CB007922    ${CONFIG_DIR_PATH}${/}${SCFC_NAME}
# 	${scfc_path}                Set Variable                      ${TEST_LOG_DIRECTORY()}${/}scfc.xml
# 	copy_file          ${CONFIG_DIR_PATH}/${SCFC_NAME}     ${scfc_path}
# 	add_ca_relation_CB7922    ${scfc_path}
#     add_nradjecell_extend_parameter_on_cell    xml_path=${scfc_path}    index_id=1
#     add_nrrele_extend_parameter_on_cell    xml_path=${scfc_path}    cell_id=4    nrReleId=1
#     add_nrhoir_extend_parameter_on_cell    xml_path=${scfc_path}    nrHoirId=1
#     add_nrhoirDNList_in_cells    xml_path=${scfc_path}
#     add_xml_element     ${scfc_path}    ${scfc_path}     <p>eutra</p>|//*[@name\='raTypeList']
#     del_elements_from_xml    xml_path=${scfc_path}    parameter=configuredEpsTac
#     ${modify_list}      create list
#     ...        ${carrierAggregationSupportList}
#     ...        ${actInterNumerologyCa}
#     ...        ${flexibleCAMode}
#     ...        ${pucchModeSelect}
#     ...        ${actBeamforming}
#     ...        ${nrBtsBeamRefinementP2}
#     ...        ${numberOfTransmittedSsBlocks}
#     ...        ${basicBeamSet}
#     ...        ${nrCellType}
#     ...        ${cellDepType}
#     ...        ${actCDrx}
#     ...        ${frameStructureType}
#     ...        ${guardPeriodLength}
#     ...        ${lteToNrFrameShift}
#     ...        ${prachConfigurationIndex}
#     ...        ${ssBurstSetPeriod}
#     ...        ${actDl256Qam}
#     ...        ${sCellAdditionMethod}
#     ...        ${maxNumScellsDl}
#     ...        ${actFdmScheduling}
#     ...        ${sCellDeactivationBadRlqCount}
#     ...        ${sCellActivationMethod}
#     ...        ${actInterRatHoSA}
#     ...        ${chBw}
#     ...        ${agNbCuType}
#     ...        ${a2MeashoEnabledSA}
#     ...        ${actInterRatHoSADlDataForward}
# 	...        ${dlMimoMode}
#     modify_xml  	    ${scfc_path}        ${scfc_path}         ${modify_list}
#     Modify TL VM And AP SCTP Configuration
#     Perform Full Commission And Reach Onair
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
# _wait_until_sib1_received_and_setup_x2_connection
#     [Arguments]    ${timeout}=200
#     [Documentation]    This keyword is used to wait sib1 message for all cells then setup x2 connection
#     [Timeout]    ${timeout}
#     Log To Console    ...wait sib1 message for all cells then setup x2 connection...
#     _wait_until_sib1_received_for_all_cells    ${timeout}
# #    _set_up_x2_connction    ${timeout}
# 
# Step 2: Attach ue to cell4 with covBasedA1 addition and blind activation
#     Start Collect GNB and AP Syslog in 'step2_ue_attach' File
#     #Start GNB BIP Log
#     #Start AP BIP Log
#     Start GNB Ttitrace With Streaming Mode
#     Airphone Location Change    id=${UE_ID}    cell_id=4
# 	Airphone SA Attach    ue_id=${UE_ID}
# 	airphone_set_traffic_type    ${UE_ID}    ${PDU_ID}    internal
#     Airphone Pdu Session Setup    ${UE_ID}    ${PDU_ID}    ${SLICE_ID}    ${GW_ID}
#     Inquery UE'1' NR Measurement Identities
#     Airphone Measurement Send Nr    id=1    meas_id=2    event=A1    srsrp_nr=80
#     ...    pass_regexp=sCellToAddModList
# 	${pacp}=    Stop GNB Ttitrace With Streaming Mode    save_path=${TEST_LOG_DIRECTORY()}step2_ue_attach
# 	#Stop Gnb BIP Log    log_dir=${TEST_LOG_DIRECTORY()}${/}step2_ue_attach${/}
#     #Stop AP BIP Log    log_dir=${TEST_LOG_DIRECTORY()}${/}step2_ue_attach${/}
#     [Teardown]    Stop Collect GNB and AP Syslog in 'step2_ue_attach' File
# 
# Inquery UE'${u_id}' NR Measurement Identities
#     Wait Throughput Timer    3
#     airphone_execute_egate_command    ue_meas_cfg_disp id\=${u_id}
#     ...      pass_regexp=NR MEASUREMENT IDENTITIES
#     Wait Throughput Timer    3
# 
# Step 3: Send ULDL traffic
#     Start Collect GNB and AP Syslog in 'step3_data_traffic' File
#     #Start GNB BIP Log
#     #Start AP BIP Log
#     Start GNB Ttitrace With Streaming Mode
#     Internal send mutiple trf '2' for each '175M' DL data
#     #Stop Gnb BIP Log    log_dir=${TEST_LOG_DIRECTORY()}${/}step3_data_traffic${/}
#     #Stop AP BIP Log    log_dir=${TEST_LOG_DIRECTORY()}${/}step3_data_traffic${/}
#     ${pacp}=    Stop GNB Ttitrace With Streaming Mode    save_path=${TEST_LOG_DIRECTORY()}step3_data_traffic
#     ${Pcell_dl_throughput} =    Airphone Get Throughput On Specific Scell    ue_id=${UE_ID}    scell_id=0    type=pdsch    tput_type=ave
#     ${Scell_dl_throughput} =    Airphone Get Throughput On Specific Scell    ue_id=${UE_ID}    scell_id=1    type=pdsch    tput_type=ave
#     [Teardown]    Stop Collect GNB and AP Syslog in 'step3_data_traffic' File
# 
# Internal send mutiple trf '${number}' for each '${dl_data}' DL data
#     : FOR    ${num}    IN RANGE    1    ${number}+1
#     \    Airphone SA Start Data Traffic    ${UE_ID}    DL    ${dl_data}    pdu_id=${PDU_ID}    duration=6000s    trf_id=${num}
# 
# Step 4: Perform UE handover to enb1 cell1
#     Start Collect GNB and AP Syslog in 'step4_HO_to_enb1_1' File
#     #Start GNB BIP Log
#     #Start AP BIP Log
#     Start GNB Ttitrace With Streaming Mode
#     Inquery UE'1' NR Measurement Identities
#     Airphone Measurement Send Nr    id=1    meas_id=1    event=A2    srsrp_nr=40
#     Wait Throughput Timer    2
# 	Inquery UE'1' NR Measurement Identities
# 	airphone_execute_egate_command    ${B2_CMD}
# 	...     pass_regexp=Successful handover from EXT_ENB-2.4 to ENB-1.1
# 	Wait Throughput Timer    2
#     #Stop Gnb BIP Log    log_dir=${TEST_LOG_DIRECTORY()}${/}step4_HO_to_enb1_1${/}
#     #Stop AP BIP Log    log_dir=${TEST_LOG_DIRECTORY()}${/}step4_HO_to_enb1_1${/}
#     ${pacp}=    Stop GNB Ttitrace With Streaming Mode    save_path=${TEST_LOG_DIRECTORY()}step4_HO_to_enb1_1
#     [Teardown]    Stop Collect GNB and AP Syslog in 'step4_HO_to_enb1_1' File
