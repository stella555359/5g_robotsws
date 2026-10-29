# *** Settings ***
# Documentation     example case for RAN HZ L2 SW11. test step description in QC as below:
# ...
# ...               QC case full name:
# ...               CB007922_case30_D_9_unLock_of_Pcell_on_ABIO
# ...
# ...               This user scenario describes the Cell Lock with Graceful Cell Shutdown on PCell for UEs configured for Carrier Aggregation.
# 
# Suite Setup       Common Suite Setup
# #Suite Teardown    Common Suite Teardown
# Test Setup        Common Test Setup
# #Test Teardown     Common Test Teardown
# Force Tags        CLOUD_5G_I_LO_AP_LO_SANSA_FS_ECPRI_CMWV_TDD    5G_RAN_TDD    RAN_5G    CRT    SBTS00    SBTS23R1    ownerbylilyu
# Test Timeout      60 minutes
# Resource          ../resources/sg11/internal_resource/robot/modify_configuration.robot
# Library           taf.sbts.oam.coam.admin    WITH NAME    TAF_ADMIN
# Library           ta_a2a
# Library           string
# Library           taf.sbts.oam.coam.admin    WITH NAME    admin
# 
# *** Variables ***
# ${CONFIG_DIR_PATH}    ${CURDIR}/../resources/sg11/internal_resource/config/
# ${JSON_DIR_PATH}    ${CURDIR}/config
# ${UE_ID}          1
# ${PDU_ID}         1
# ${BEAR_ID}        2
# ${GW_ID}          1
# ${SLICE_ID}       1
# ${pmi_cmd}        csi_override_testmode_nr profile_id=1 cqi_mode=fixed cqi=15 ri_mode=fixed ri=1 pmi_mode=fixed pmi=500
#                   ...    cri_mode=fixed cri=1 li_mode=fixed li=1
# ${SCFC_NAME}        gNB_scf_ASIL_ABIO_TDD_eCPRI_cmwv_SANSA_L1b_4S_1CC.xml
# ${AIRPHONE_NAME}    AP_iphy_AEQE_LO_AP_LO_TDD_eCPRI_cmwv_SANSA_L1b_4S_1CC.xml
# ${WTS_NAME}         wts_config_ASIB_ABIO_TDD_eCPRI_cmwv_SANSA_L1b_4S_1CC.cfg
# @{LOG_NAME_LIST}    gnb_snapshot    sosreport    tshark    egatelog
# ${actInterNumerologyCa}    text|false|//*[@name\="actInterNumerologyCa"]
# ${flexibleCAMode}    text|MixedCAMode|//*[@name\="flexibleCAMode"]
# ${pucchModeSelect}    text|longPucch|//*[@name\="pucchModeSelect"]
# ${actBeamforming}    text|true|//*[@name\="actBeamforming"]
# ${cellDepType}    text|SA+NSA|//*[@name\="cellDepType"]
# ${actCDrx}        text|false|//*[@name\="actCDrx"]
# ${frameStructureType}    text|tdLte|//*[@name\="frameStructureType"]
# ${guardPeriodLength}    text|6Symbols|//*[@name\="guardPeriodLength"]
# ${lteToNrFrameShift}    text|0ms|//*[@name\="lteToNrFrameShift"]
# ${prachConfigurationIndex}    text|97|//*[@name\="prachConfigurationIndex"]
# ${sCellAdditionMethod}    text|blind|//*[@name\="sCellAdditionMethod"]
# ${actFdmScheduling}    text|true|//*[@name\="actFdmScheduling"]
# ${sCellActivationMethod}    text|blind|//*[@name\="sCellActivationMethod"]
# ${sCellDeactivationTimerGNB}    text|infinity|//*[@name\="sCellDeactivationTimerGNB"]
# ${chBw}    text|80MHz|//*[@name\="chBw"]
# ${dlMimoMode}    text|8x4 Closed Loop Spatial Multiplexing|//*[@name\="dlMimoMode"]
# ${actGrflShdn}    text|true|//*[@name\="actGrflShdn"]
# ${shutdownStepAmount}    text|6|//*[@name\="shutdownStepAmount"]
# ${shutdownWindow}    text|60|//*[@name\="shutdownWindow"]
# ${administrativestate1}    text|Unlocked|//*[contains(@distName, 'NRCELL-1')]/*[@name='administrativeState']
# ${numberOfRxBeamforming}    text|4Rx|//*[@name\="numberOfRxBeamforming"]
# 
# *** Test Cases ***
# CB007922_case30_D_9_unLock_of_Pcell_on_ABIO
#     Step1:Commission the above configuration on WebUI
#     Step2:ue attach to cell1,and push data
#     Step3:online change administrativestate1=shutingdown,ue release after 60s
#     Step4:online change administrativestate1=unlock,ue can attach again
#     Step5:Detach UE
# 
# *** Keywords ***
# Step1:Commission the above configuration on WebUI
#     Start Collect GNB and AP Syslog in 'step1_before_onair' File
#     ${CONFIG_DIR_PATH}    Set Variable    ${CONFIG_DIR_PATH}/${SW_BRANCH}
#     change_iphy_rru_version    ${CONFIG_DIR_PATH}${/}${AIRPHONE_NAME}
#     modify_swconfig_by_CB007922    ${CONFIG_DIR_PATH}${/}${SCFC_NAME}
#     ${scfc_path}    Set Variable    ${TEST_LOG_DIRECTORY()}${/}scfc.xml
#     copy_file    ${CONFIG_DIR_PATH}/${SCFC_NAME}    ${scfc_path}
#     #Related parameters of dlmimomode
#     add_periodiccsiacquisition_list_in_cells    ${scfc_path}
#     #add CA
#     add_ca_relation_CB7922    ${scfc_path}
#     ${modify_list}    create list    ${actInterNumerologyCa}    ${flexibleCAMode}    ${pucchModeSelect}    ${actBeamforming}    ${cellDepType}
#     ...    ${actCDrx}    ${frameStructureType}    ${guardPeriodLength}    ${lteToNrFrameShift}    ${prachConfigurationIndex}
#     ...    ${sCellAdditionMethod}    ${chBw}    ${actFdmScheduling}    ${sCellActivationMethod}    ${dlMimoMode}    ${sCellDeactivationTimerGNB}
#     ...    ${actGrflShdn}     ${shutdownStepAmount}    ${shutdownWindow}    ${administrativestate1}    ${numberOfRxBeamforming}
#     modify_xml    ${scfc_path}    ${scfc_path}    ${modify_list}
#     Modify TL VM And AP SCTP Configuration
#     Perform Full Commission And Reach Onair    ${scfc_path}    ${CONFIG_DIR_PATH}${/}${WTS_NAME}    reset_after_commission=${False}
#     [Teardown]    Stop Collect GNB and AP Syslog in 'step1_before_onair' File
# 
# Step2:ue attach to cell1,and push data
#     Start Collect GNB and AP Syslog in 'step2_ue_attach_SA' File
#     #Start GNB BIP Log
#     #Start AP BIP Log
#     #open beaforming
#     airphone_execute_egate_command
#     ...    beam_control_testmode_nr profile_id\=1 ueBeamIndexInitial\=0,1,2,3,4,5,6,7 ssbeam_bestbeam\=0 ssbeam_rsrp_best\=-44 ssbeam_rsrp_avg\=-70
#     airphone_execute_egate_command    ue_testmode_set_nr id\=1 testmode\=beam_control action\=activate profile_id\=1 beamaction\=attach scell\=0,1
#     Airphone Sa Attach    ue_id=${UE_ID}
#     #set pmi
#     airphone_execute_egate_command    ${pmi_cmd}
#     airphone_execute_egate_command    ue_testmode_set_nr id\=1 testmode\=csi_override action\=activate profile_id\=1
#     airphone_set_traffic_type    ${UE_ID}    ${PDU_ID}    internal
#     Airphone Pdu Session Setup    ${UE_ID}    ${PDU_ID}    ${SLICE_ID}    ${UE_ID}
#     #start enough data
#     Airphone SA Start Data Traffic    ${UE_ID}    DL    175M    trf_id=1    pdu_id=${PDU_ID}    duration=${3600}
#     Airphone SA Start Data Traffic    ${UE_ID}    DL    175M    trf_id=2    pdu_id=${PDU_ID}    duration=${3600}
#     Airphone SA Start Data Traffic    ${UE_ID}    DL    175M    trf_id=3    pdu_id=${PDU_ID}    duration=${3600}
#     #Start GNB Ttitrace With Streaming Mode
#     #Wait Throughput Timer    5
#     #${pacp}=    Stop GNB Ttitrace With Streaming Mode    save_path=${TEST_LOG_DIRECTORY()}step2_ue_attach_SA
#     #check thp
#     Wait Throughput Timer    20
#     ${Pcell_dl_throughput} =    Airphone Get Throughput On Specific Scell    ue_id=${UE_ID}    scell_id=0    type=pdsch    tput_type=ave
#     ${Scell_dl_throughput} =    Airphone Get Throughput On Specific Scell    ue_id=${UE_ID}    scell_id=1    type=pdsch    tput_type=ave
#     should be true    ${Pcell_dl_throughput} > 0
#     should be true    ${Scell_dl_throughput} > 0
#     #Stop Gnb BIP Log    log_dir=${TEST_LOG_DIRECTORY()}${/}step2_ue_attach_SA${/}
#     #Stop AP BIP Log    log_dir=${TEST_LOG_DIRECTORY()}${/}step2_ue_attach_SA${/}
#     #Decoder Tttirace From Pcap To Csv    ${pacp}    ${TEST_LOG_DIRECTORY()}step2_ue_attach_SA/output
#     [Teardown]    Stop Collect GNB and AP Syslog in 'step2_ue_attach_SA' File
# 
# Step3:online change administrativestate1=shutingdown,ue release after 60s
#     Start Collect GNB and AP Syslog in 'step3_shuttingdown' File
#     #Start GNB BIP Log
#     #Start AP BIP Log
#     #online change parameter
#     log    ${JSON_DIR_PATH}/${SW_BRANCH}/JSON/
#     TAF_ADMIN.connect to    bts_host=192.168.255.129    bts_port=443    use_ssl=True    name=online
#     TAF_ADMIN.perform_parameter_recommissioning
#     ...    dist_name=MRBTS-1/NRBTS-2/NRCELL-1    parameter=administrativeState    operation=update    value=Shutting Down
#     ...    skip_parameter_relation_errors=True    connection=online
#     TAF_ADMIN.teardown admin    connection=online
# 
#     #get scfc.xml from gnb to check the status of administrativestate-pcell
#     #get scfc.xml from gnb
#     Wait Throughput Timer    120
#     ${scfc_online_path}    Set Variable    ${TEST_LOG_DIRECTORY()}step3_shuttingdown
#     admin.Setup Admin
#     admin.get_current_scf_file    local_dir_path=${scfc_online_path}    file_name=scfc_online.xml
#     admin.Teardown Admin
#     #check current cell status
#     ${scfc_online}    Set Variable   ${scfc_online_path}${/}scfc_online.xml
#     ${administrativestate1_xpath}    Evaluate Xml Xpath    source_xml=${scfc_online}
#     ...    xpath=string(text|//*[contains(@distName, 'NRCELL-1')]/*[@name='administrativeState'])
#     Should Be Equal    ${administrativestate1_xpath}    Locked
# 
#     #check UE status
#     airphone_collect_egate_log_files      ${TEST_LOG_DIRECTORY()}step3_shuttingdown   unzip=TRUE
#     check_log_with_au2anlysis    ini_path=${CURDIR}/A2A_log_Check/RRC_UE_Detached.ini    log_need_to_check=u
#     ...    save_log_directory=${TEST_LOG_DIRECTORY()}step3_shuttingdown
#     #Stop Gnb BIP Log    log_dir=${TEST_LOG_DIRECTORY()}${/}step3_shuttingdown${/}
#     #Stop AP BIP Log    log_dir=${TEST_LOG_DIRECTORY()}${/}step3_shuttingdown${/}
#     #Decoder Tttirace From Pcap To Csv    ${pacp}    ${TEST_LOG_DIRECTORY()}step3_shuttingdown/output
#     [Teardown]    Stop Collect GNB and AP Syslog in 'step3_shuttingdown' File
# 
# Step4:online change Administrative state1=unlock,ue can attach again
#     Start Collect GNB and AP Syslog in 'step4_unlock' File
#     #Start GNB BIP Log
#     #Start AP BIP Log
#     #online change Administrative state1=unlock
#     TAF_ADMIN.connect to    bts_host=192.168.255.129    bts_port=443    use_ssl=True    name=online
#     TAF_ADMIN.perform_parameter_recommissioning
#     ...    dist_name=MRBTS-1/NRBTS-2/NRCELL-1    parameter=administrativeState    operation=update    value=Unlocked
#     ...    skip_parameter_relation_errors=True    connection=online
#     TAF_ADMIN.teardown admin    connection=online
#     Wait Throughput Timer    30
#     Airphone Sa Attach    ue_id=${UE_ID}
#     airphone_set_traffic_type    ${UE_ID}    ${PDU_ID}    internal
#     Airphone Pdu Session Setup    ${UE_ID}    ${PDU_ID}    ${SLICE_ID}    ${UE_ID}
#     #start enough data
#     Airphone SA Start Data Traffic    ${UE_ID}    DL    175M    trf_id=1    pdu_id=${PDU_ID}    duration=${3600}
#     Airphone SA Start Data Traffic    ${UE_ID}    DL    175M    trf_id=2    pdu_id=${PDU_ID}    duration=${3600}
#     Airphone SA Start Data Traffic    ${UE_ID}    DL    175M    trf_id=3    pdu_id=${PDU_ID}    duration=${3600}
#     #Start GNB Ttitrace With Streaming Mode
#     #Wait Throughput Timer    5
#     #${pacp}=    Stop GNB Ttitrace With Streaming Mode    save_path=${TEST_LOG_DIRECTORY()}step2_ue_attach_SA
#     #check thp is normal
#     Wait Throughput Timer    20
#     ${Pcell_dl_throughput} =    Airphone Get Throughput On Specific Scell    ue_id=${UE_ID}    scell_id=0    type=pdsch    tput_type=ave
#     ${Scell_dl_throughput} =    Airphone Get Throughput On Specific Scell    ue_id=${UE_ID}    scell_id=1    type=pdsch    tput_type=ave
#     should be true    ${Pcell_dl_throughput} > 0
#     should be true    ${Scell_dl_throughput} > 0
#     #Stop Gnb BIP Log    log_dir=${TEST_LOG_DIRECTORY()}${/}step4_unlock${/}
#     #Stop AP BIP Log    log_dir=${TEST_LOG_DIRECTORY()}${/}step4_unlock${/}
#     #Decoder Tttirace From Pcap To Csv    ${pacp}    ${TEST_LOG_DIRECTORY()}sstep4_unlock/output
#     [Teardown]    Stop Collect GNB and AP Syslog in 'step4_unlock' File
# 
# Step5:Detach UE
#     Comment    Start Collect GNB and AP Syslog in 'step5_Detach UE' File
#     airphone_sa_stop_data_traffic    ${UE_ID}    DL    pdu_id=${PDU_ID}
#     airphone_sa_detach    ${UE_ID}
#     [Teardown]    Stop Collect GNB and AP Syslog in 'step5_Detach UE' File
# 
# add_ca_relation_CB7922
#     [Arguments]    ${scfc_path}
#     #L2RT intra band CA Cell2&Cell3 Inter L2RT inter band CA Cell4&Cell1 Intra L2RT intra band CA Cell1&Cell2 Intra L2RT inter band CA Cell3&Cell4
#     add_nrrel_extend_parameter_on_cell    xml_path=${scfc_path}    cellid=1    lcrid=2
#     add_nrrel_extend_parameter_on_cell    xml_path=${scfc_path}    cellid=2    lcrid=3
#     add_nrrel_extend_parameter_on_cell    xml_path=${scfc_path}    cellid=3    lcrid=4
#     add_nrrel_extend_parameter_on_cell    xml_path=${scfc_path}    cellid=4    lcrid=1
# 
# 
# 
