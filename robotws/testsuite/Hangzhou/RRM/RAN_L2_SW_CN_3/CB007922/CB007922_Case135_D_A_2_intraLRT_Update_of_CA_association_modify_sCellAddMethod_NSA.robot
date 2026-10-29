# *** Settings ***
# Documentation     Author: zhaona.jiang@nokia-sbell.com
# ...
# ...               QC case full name:
# ...               CB007922_Case135_D_A_2_intraLRT_Update_of_CA_association_modify_sCellAddMethod_NSA
# ...
# ...               This user scenario describes the successful operations, deletion or addition of CA association between PSCell and SCell.
# 
# Suite Setup       Common Suite Setup
# Suite Teardown    Common Suite Teardown
# Test Setup        Common Test Setup
# Test Teardown     Common Test Teardown
# Force Tags        CLOUD_5G_I_BOO_AP_KLLL_SANSA_L1B_ECPRI_CMWV_TDD    5G_RAN_TDD    RAN_5G    SBTS22R4    SBTS23R1
# ...    owner_jiangzhaona    AP
# Test Timeout      90 minutes
# Resource          ../resources/sg11/internal_resource/robot/modify_configuration.robot
# Library           taf.sbts.oam.coam.admin    WITH NAME    TAF_ADMIN
# Library           ta_a2a
# 
# *** Variables ***
# ${CONFIG_DIR_PATH}    ${CURDIR}/../resources/sg11/internal_resource/config/
# ${JSON_DIR_PATH}    ${CURDIR}/config
# ${SCFC_NAME}      gNB_scf_ASIB_ABIO_TDD_eCPRI_cmwv_SANSA_L1b_4S_1CC.xml
# ${AIRPHONE_NAME}    AP_iphy_AEQE_ASIB_ABIO_TDD_eCPRI_cmwv_SANSA_L1b_4S_1CC.xml
# ${WTS_NAME}       wts_config_ASIB_ABIO_TDD_eCPRI_cmwv_SANSA_L1b_4S_1CC.cfg
# ${UE1_ID}        11
# ${UE2_ID}        12
# ${PDU_ID}         1
# ${GW_ID}          1
# ${SLICE_ID}       1
# @{LOG_NAME_LIST}    gnb_snapshot    sosreport    tshark    egatelog
# #${carrierAggregationSupportList}    text|ca_Fr1Tdd_Sa|//list[@name\="carrierAggregationSupportList"]/p
# ${actInterNumerologyCa}    text|true|//*[@name\="actInterNumerologyCa"]
# ${flexibleCAMode}    text|MixedCAMode|//*[@name\="flexibleCAMode"]
# ${pucchModeSelect}    text|longPucch|//*[@name\="pucchModeSelect"]
# ${actBeamforming}    text|true|//*[@name\="actBeamforming"]
# ${numberOfTransmittedSsBlocks}    text|6 beams|//*[contains(@distName, 'NRCELLGRP')]/*[@name='numberOfTransmittedSsBlocks']
# ${basicBeamSet}    text|beamSet_6|//*[@name\="basicBeamSet"]
# ${actPdschAtSsbSlots}    text|false|//*[@name\="actPdschAtSsbSlots"]
# ${cellDepType}    text|SA+NSA|//*[@name\="cellDepType"]
# ${actCDrx}        text|false|//*[@name\="actCDrx"]
# ${frameStructureType}    text|tdLte|//*[@name\="frameStructureType"]
# ${guardPeriodLength}    text|6Symbols|//*[@name\="guardPeriodLength"]
# ${lteToNrFrameShift}    text|0ms|//*[@name\="lteToNrFrameShift"]
# ${prachConfigurationIndex}    text|97|//*[@name\="prachConfigurationIndex"]
# ${tdLteUlDlConfig}      text|tdLteConfig2|//*[@name\="tdLteUlDlConfig"]
# ${ssBurstSetPeriod}    text|20|//*[@name\="ssBurstSetPeriod"]
# ${sCellAdditionMethod}    text|blind|//*[@name\="sCellAdditionMethod"]
# ${maxNumScellsDl}    text|1|//*[@name\="maxNumScellsDl"]
# ${actFdmScheduling}    text|true|//*[@name\="actFdmScheduling"]
# ${sCellActivationMethod}    text|blind|//*[@name\="sCellActivationMethod"]
# ${sCellDeactivationTimerGNB}    text|infinity|//*[@name\="sCellDeactivationTimerGNB"]
# ${chBw}           text|80MHz|//*[@name="chBw"]
# ${dlMimoMode}    text|4x4 or 4x2 Closed Loop Spatial Multiplexing|//*[@name="dlMimoMode"]
# ${BEAM_SET}     beam_control_testmode_nr profile_id\=1 ueBeamIndexInitial\=5,0,1,2,3,4 ssbeam_bestbeam\=5 ssbeam_rsrp_best\=-44 ssbeam_rsrp_avg\=-50
# 
# *** Test Cases ***
# CB007922_Case135_D_A_2_intraLRT_Update_of_CA_association_modify_sCellAddMethod_NSA_bak
#     Step1:Commission the above configuration on WebUI
#     Step2:Attach new UE-1 to TDD FR1 NR cell
#     Step3:Send dl and ul data
#     Step4:Deletion of CA relation definition
#     Step5:Attach new UE-2 to TDD FR1 NR cell
#     Step6:Detach UE-1 and UE-2 from the network
#     Step7:Attach new UE-1 to TDD FR1 NR cell again
#     Step8:Reconfigured in a way that optional sCellAdditionMethod parameter is set to blind
#     Step9:Attach UE-2 to TDD FR1 NR cell
#     Step10:Detach UE-1 from the network
#     Step11:Attach new UE-1 to TDD FR1 NR cell again
#     Step6:Detach UE-1 and UE-2 from the network
# 
# CB007922_Case135_D_A_2_intraLRT_Update_of_CA_association_modify_sCellAddMethod_NSA
#     Step1:Commission the above configuration on WebUI
#     Step2:Attach new UE-1 to TDD FR1 NR cell
#     Step3:Send dl and ul data
#     Step4:Deletion of CA relation definition
#     Step5:Attach new UE-2 to TDD FR1 NR cell
#     Step6:Detach UE-1 and UE-2 from the network
#     Step7:Attach new UE-1 to TDD FR1 NR cell again
#     Step8:Reconfigured in a way that optional sCellAdditionMethod parameter is set to blind
#     Step9:Attach UE-2 to TDD FR1 NR cell
#     Step10:Detach UE-1 from the network
#     Step11:Attach new UE-1 to TDD FR1 NR cell again
#     Step6:Detach UE-1 and UE-2 from the network
# 
# *** Keywords ***
# Step1:Commission the above configuration on WebUI
#     Start Collect GNB and AP Syslog in 'step1_before_onair' File
#     ${CONFIG_DIR_PATH}    Set Variable    ${CONFIG_DIR_PATH}/${SW_BRANCH}
#     change_iphy_rru_version    ${CONFIG_DIR_PATH}${/}${AIRPHONE_NAME}
#     modify_swconfig_by_CB007922    ${CONFIG_DIR_PATH}${/}${SCFC_NAME}
#     ${scfc_path}    Set Variable    ${TEST_LOG_DIRECTORY()}${/}scfc.xml
#     copy_file    ${CONFIG_DIR_PATH}/${SCFC_NAME}    ${scfc_path}
#     add_ca_relation_CB7922    ${scfc_path}
#     ${modify_list}    create list    ${actInterNumerologyCa}    ${flexibleCAMode}    ${pucchModeSelect}    ${actBeamforming}
#     ...    ${numberOfTransmittedSsBlocks}    ${basicBeamSet}    ${cellDepType}    ${actCDrx}    ${frameStructureType}    ${guardPeriodLength}
#     ...    ${lteToNrFrameShift}    ${prachConfigurationIndex}    ${ssBurstSetPeriod}    ${dlMimoMode}    ${actPdschAtSsbSlots}
#     ...    ${tdLteUlDlConfig}    ${sCellActivationMethod}    ${sCellAdditionMethod}    ${maxNumScellsDl}    ${actFdmScheduling}
#     ...    ${chBw}    ${sCellDeactivationTimerGNB}
#     modify_xml    ${scfc_path}    ${scfc_path}    ${modify_list}
#     Modify TL VM And AP SCTP Configuration
#     Perform Full Commission And Reach Onair    ${scfc_path}    ${CONFIG_DIR_PATH}${/}${WTS_NAME}    reset_after_commission=${False}
#     [Teardown]    Stop Collect GNB and AP Syslog in 'step1_before_onair' File
# 
# Step2:Attach new UE-1 to TDD FR1 NR cell
#     Start Collect GNB and AP Syslog in 'step2_attach' File
#     #Start GNB BIP Log
#     #Start AP BIP Log
#     Airphone Nsa Attach    ue_id=${UE1_ID}    cell_id=1
#     Set UE_${UE1_ID} SSB Beam
#     #Stop Gnb BIP Log    log_dir=${TEST_LOG_DIRECTORY()}${/}step2_ue_attach${/}
#     #Stop AP BIP Log    log_dir=${TEST_LOG_DIRECTORY()}${/}step2_ue_attach${/}
#     [Teardown]    Stop Collect GNB and AP Syslog in 'step2_attach' File
# 
# Step3:Send dl and ul data
#     Start Collect GNB and AP Syslog in 'step3_send_data' File
#     Airphone Nsa Start Data Traffic    ${UE1_ID}    DL    175M    trf_id=1    duration=${3600}
#     Airphone Nsa Start Data Traffic    ${UE1_ID}    DL    175M    trf_id=2    duration=${3600}
# 	Airphone Nsa Start Data Traffic    ${UE1_ID}    DL    175M    trf_id=3    duration=${3600}
# 	Airphone Nsa Start Data Traffic    ${UE1_ID}    DL    175M    trf_id=4    duration=${3600}
# 	Airphone Nsa Start Data Traffic    ${UE1_ID}    UL    25M    trf_id=5    duration=${3600}
#     Check step3_send_data tti
#     ${Pcell_dl_throughput} =    Airphone Get Throughput On Specific Scell    ue_id=${UE1_ID}    scell_id=8    type=pdsch    tput_type=ave
#     ${Scell_dl_throughput} =    Airphone Get Throughput On Specific Scell    ue_id=${UE1_ID}    scell_id=9    type=pdsch    tput_type=ave
# 	${Total_thp}    evaluate    ${Pcell_dl_throughput}+${Scell_dl_throughput}
# 	should be true    ${Pcell_dl_throughput} > 0
#     should be true    ${Scell_dl_throughput} > 0
#     should be true    ${Total_thp} > 620000
#     [Teardown]    Stop Collect GNB and AP Syslog in 'step3_send_data' File
# 
# Step4:Deletion of CA relation definition
#     Start Collect GNB and AP Syslog in 'step4_delete_ca' File
#     TAF_ADMIN.connect to    bts_host=192.168.255.129    bts_port=443    use_ssl=True    name=online
# 	TAF_ADMIN.perform_parameter_recommissioning    dist_name=MRBTS-1/NRBTS-2/NRDU-1
# 	...    parameter=carrierAggregationSupportList    operation=delete    value=ca_Fr1Tdd_NSa
# 	...    skip_parameter_relation_errors=True    connection=online
#     TAF_ADMIN.teardown admin    connection=online
#     Check step4_delete_ca tti
#     ${Pcell_dl_throughput} =    Airphone Get Throughput On Specific Scell    ue_id=${UE1_ID}    scell_id=8    type=pdsch    tput_type=ave
#     ${Scell_dl_throughput} =    Airphone Get Throughput On Specific Scell    ue_id=${UE1_ID}    scell_id=9    type=pdsch    tput_type=ave
# 	should be true    ${Pcell_dl_throughput} > 0
#     should be true    ${Scell_dl_throughput} > 0
#     [Teardown]    Stop Collect GNB and AP Syslog in 'step4_delete_ca' File
# 
# Step5:Attach new UE-2 to TDD FR1 NR cell
#     Start Collect GNB and AP Syslog in 'step5_attach_new_ue' File
#     Airphone Nsa Attach    ue_id=${UE2_ID}    cell_id=1
#     Set UE_${UE2_ID} SSB Beam
#     Airphone Nsa Start Data Traffic    ${UE2_ID}    DL    175M    trf_id=1    duration=${3600}
#     Airphone Nsa Start Data Traffic    ${UE2_ID}    DL    175M    trf_id=2    duration=${3600}
# 	Airphone Nsa Start Data Traffic    ${UE2_ID}    DL    175M    trf_id=3    duration=${3600}
# 	Airphone Nsa Start Data Traffic    ${UE2_ID}    DL    175M    trf_id=4    duration=${3600}
# 	Airphone Nsa Start Data Traffic    ${UE2_ID}    UL    25M    trf_id=5    duration=${3600}
#     Check step5_attach_new_ue tti
#     ${Pcell_dl_throughput} =    Airphone Get Throughput On Specific Scell    ue_id=${UE2_ID}    scell_id=8    type=pdsch    tput_type=ave
#     airphone_execute_egate_command    ue_stats_nr id\=12 type\=pdsch scell\=9    fail_regexp=CellIndex-9
#     should be true    ${Pcell_dl_throughput} > 160000
#     [Teardown]    Stop Collect GNB and AP Syslog in 'step5_attach_new_ue' File
# 
# Step6:Detach UE-1 and UE-2 from the network
#     Start Collect GNB and AP Syslog in 'step6_detach' File
#     airphone_nsa_detach_all
#     [Teardown]    Stop Collect GNB and AP Syslog in 'step6_detach' File
# 
# Step7:Attach new UE-1 to TDD FR1 NR cell again
#     Start Collect GNB and AP Syslog in 'step7_attach_ue1' File
#     Airphone Nsa Attach    ue_id=${UE1_ID}    cell_id=1
#     Set UE_${UE1_ID} SSB Beam
#     Airphone Nsa Start Data Traffic    ${UE1_ID}    DL    175M    trf_id=1    duration=${3600}
#     Airphone Nsa Start Data Traffic    ${UE1_ID}    DL    175M    trf_id=2    duration=${3600}
# 	Airphone Nsa Start Data Traffic    ${UE1_ID}    DL    175M    trf_id=3    duration=${3600}
# 	Airphone Nsa Start Data Traffic    ${UE1_ID}    UL    25M    trf_id=5    duration=${3600}
#     Check step7_attach_ue1 tti
#     ${Pcell_dl_throughput} =    Airphone Get Throughput On Specific Scell    ue_id=${UE1_ID}    scell_id=8    type=pdsch    tput_type=ave
#     airphone_execute_egate_command    ue_stats_nr id\=${UE1_ID} type\=pdsch scell\=9    fail_regexp=CellIndex-9
#     should be true    ${Pcell_dl_throughput} > 400000
#     [Teardown]    Stop Collect GNB and AP Syslog in 'step7_attach_ue1' File
# 
# Step8:Reconfigured in a way that optional sCellAdditionMethod parameter is set to blind
#     Start Collect GNB and AP Syslog in 'step8_update_ca_param' File
#     Online recommissioning with delta json file    ${JSON_DIR_PATH}/${SW_BRANCH}/JSON/delta_A_1a_case1.json
#     Start GNB Ttitrace With Streaming Mode
#     Check step8_update_ca_param tti
#     ${Pcell_dl_throughput} =    Airphone Get Throughput On Specific Scell    ue_id=${UE1_ID}    scell_id=8    type=pdsch    tput_type=ave
#     should be true    ${Pcell_dl_throughput} > 400000
#     airphone_execute_egate_command    ue_stats_nr id\=${UE1_ID} type\=pdsch scell\=9    fail_regexp=CellIndex-9
#     [Teardown]    Stop Collect GNB and AP Syslog in 'step8_update_ca_param' File
# 
# Step9:Attach UE-2 to TDD FR1 NR cell
#     Start Collect GNB and AP Syslog in 'step9_attach_ue2' File
#     Airphone Nsa Attach    ue_id=${UE2_ID}    cell_id=1
#     Set UE_${UE1_ID} SSB Beam
#     Airphone Nsa Start Data Traffic    ${UE2_ID}    DL    175M    trf_id=1    duration=${3600}
#     Airphone Nsa Start Data Traffic    ${UE2_ID}    DL    175M    trf_id=2    duration=${3600}
# 	Airphone Nsa Start Data Traffic    ${UE2_ID}    DL    175M    trf_id=3    duration=${3600}
# 	Airphone Nsa Start Data Traffic    ${UE2_ID}    UL    25M    trf_id=5    duration=${3600}
#     Check step9_attach_ue2 tti
#     ${Pcell_dl_throughput} =    Airphone Get Throughput On Specific Scell    ue_id=${UE2_ID}    scell_id=8    type=pdsch    tput_type=ave
#     ${Scell_dl_throughput} =    Airphone Get Throughput On Specific Scell    ue_id=${UE2_ID}    scell_id=9    type=pdsch    tput_type=ave
# 	should be true    ${Pcell_dl_throughput} > 0
#     should be true    ${Scell_dl_throughput} > 0
#     [Teardown]    Stop Collect GNB and AP Syslog in 'step9_attach_ue2' File
# 
# Step10:Detach UE-1 from the network
#     Start Collect GNB and AP Syslog in 'step10_detach_ue1' File
#     airphone_nsa_detach    ue_id=${UE1_ID}
#     [Teardown]    Stop Collect GNB and AP Syslog in 'step10_detach_ue1' File
# 
# Step11:Attach new UE-1 to TDD FR1 NR cell again
#     Start Collect GNB and AP Syslog in 'step11_attach_ue1' File
#     Airphone Nsa Attach    ue_id=${UE1_ID}    cell_id=1
#     Set UE_${UE1_ID} SSB Beam
#     Airphone Nsa Start Data Traffic    ${UE1_ID}    DL    175M    trf_id=1    duration=${3600}
#     Airphone Nsa Start Data Traffic    ${UE1_ID}    DL    175M    trf_id=2    duration=${3600}
# 	Airphone Nsa Start Data Traffic    ${UE1_ID}    DL    175M    trf_id=3    duration=${3600}
# 	Airphone Nsa Start Data Traffic    ${UE1_ID}    UL    25M    trf_id=5    duration=${3600}
#     Check step11_attach_ue1 tti
# 	Wait Until Keyword Succeeds    90s    5s    check thp
#     #${Pcell_dl_throughput} =    Airphone Get Throughput On Specific Scell    ue_id=${UE1_ID}    scell_id=8    type=pdsch    tput_type=ave
#     #${Scell_dl_throughput} =    Airphone Get Throughput On Specific Scell    ue_id=${UE1_ID}    scell_id=9    type=pdsch    tput_type=ave
# 	#Wait Throughput Timer    5
# 	#should be true    ${Pcell_dl_throughput} > 0
#     #should be true    ${Scell_dl_throughput} > 0
#     [Teardown]    Stop Collect GNB and AP Syslog in 'step11_attach_ue1' File
# 
# 
# 
# Set UE_${UE_ID} SSB Beam
#     airphone_execute_egate_command    ${BEAM_SET}
#     airphone_execute_egate_command
#     ...    ue_testmode_set_nr id\=${UE_ID} testmode\=beam_control action\=activate profile_id\=1 beamaction\=attach scell\=secondary
# 
# Check ${ttipath} tti
#     Start GNB Ttitrace With Streaming Mode
#     Wait Throughput Timer    5
#     ${save_log}=    Set Variable    ${TEST_LOG_DIRECTORY()}${ttipath}
# 	${pacp}=    Stop GNB Ttitrace With Streaming Mode    save_path=${save_log}
# 	Decoder Tttirace From Pcap To Csv    ${pacp}    ${save_log}/tti
#     check_log_with_au2anlysis    ini_path=${CURDIR}/A2A_log_Check/tti_dl.ini    log_need_to_check=i    save_log_directory=${save_log}
# 
# 
# 
# check thp
#     ${Pcell_dl_throughput} =    Airphone Get Throughput On Specific Scell    ue_id=${UE1_ID}    scell_id=8    type=pdsch    tput_type=ave
#     ${Scell_dl_throughput} =    Airphone Get Throughput On Specific Scell    ue_id=${UE1_ID}    scell_id=9    type=pdsch    tput_type=ave
# 	should be true    ${Pcell_dl_throughput} > 0
#     should be true    ${Scell_dl_throughput} > 0