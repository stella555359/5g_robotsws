# *** Settings ***
# Documentation     
# ...
# 
# Suite Setup       Common Suite Setup
# #Suite Teardown    Common Suite Teardown
# Test Setup        Common Test Setup
# #Test Teardown     Common Test Teardown
# Force Tags        CLOUD_5G_I_MP_AP_LO    AP    CRT    SBTS00    RAN_5G_TDD    RAN_5G    owner_xueminm
# Test Timeout      90 minutes
# Resource          ../../resources/sg11/internal_resource/robot/modify_configuration.robot
# Resource          ../../resources/sg11/internal_resource/robot/internal_ap_operate.robot
# Resource          ../../resources/sg11/internal_resource/robot/internal_gnb_operate.robot
# Resource          ../../resources/sg11/internal_resource/robot/internal_capture_log.robot
# Library     taf.transport.ssh    WITH NAME    TAF_SSH
# Library           ta_a2a
# 
# *** Variables ***
# ${CONFIG_DIR_PATH}    ${CURDIR}/../../resources/sg11/internal_resource/config/
# ${SCFC_NAME}    gNB_scf_ASIM_ABIP_AVQL_TDD_72e_srs_false.xml
# ${AIRPHONE_NAME}    AP_iphy_gNB_scf_ASIM_ABIP_AVQL_TDD_72e_srs_false.xml
# ${WTS_NAME}       wts_config_72e.cfg
# 
# @{LOG_NAME_LIST}      gnb_snapshot    egatelog
# 
# ${ECPRI72E}  	Ecpri72eUL
# ${BETAEC}	13
# ${XEC}	14
# ${chBw}                                    text|100MHz|//*[@name\="chBw"]
# ${actDlSrsBm}                              text|false|//*[@name\="actDlSrsBm"]
# ${actUlSrsBm}                              text|false|//*[@name\="actUlSrsBm"]
# ${actFullPwrMode}                          text|true|//*[@name\="actFullPwrMode"]
# ${dlMimoMode}                              text|4x4 or 4x2 Closed Loop Spatial Multiplexing|//*[@name\="dlMimoMode"]
# ${numberOfRxBeamforming}                   text|8Rx|//*[@name\="numberOfRxBeamforming"]
# ${numberOfRxPucch}                         text|4Rx|//*[@name\="numberOfRxPucch"]
# ${nrCellType}                              text|4DL2UL|//*[@name\="nrCellType"]
# ${actFdmScheduling}                        text|true|//*[@name\="actFdmScheduling"]
# ${actBeamforming}                          text|true|//*[@name\="actBeamforming"]
# ${nrBtsBeamRefinementP2}                   text|false|//*[@name\="nrBtsBeamRefinementP2"]
# ${actCustomBsr}                            text|true|//*[@name\="actCustomBsr"]
# ${customBeamSetName}                       text|BSR_AVQL_6_H6_ALN60_ARP60_P00_COVERAGE_00424_00002|//*[@name\="customBeamSetName"]
# ${basicBeamSet}                            text|beamSet_6|//*[@name\="basicBeamSet"]
# ${numberOfTransmittedSsBlocks}             text|6 beams|//*[@name\="numberOfTransmittedSsBlocks"]
# 
# ${FILTER1}    (itf_l2_ps_cell_cellsetupreq)||(ulcell_setupreq)
# @{title1}    itf_l2_ps_cell_CellSetupReq_t.actEcpri72e    itf_l2_ps_cell_CellSetupReq_t.numberOfRxBeamforming
# ...    itf_l2_ps_cell_BfSetup.numberOfRxPucch
# 
# *** Test Cases ***
# CB010708_A1_case001_B102_Rank1_and_PMI_Measurement_on_8RX_SRS_actFullPwrMode
#     Get and Update BSR File    par_of_bsr_name=BSR_AVQL_6_H6_ALN60_ARP60_P00_COVERAGE_00424_00002
#     Modify vendor file 72e and full commission for onair
# 	Step2:Attach UE and start buffer
# 
# *** Keywords ***
# Step1:Commission the above configuration on WebUI
#     Start Capture GNB and AP Syslog in 'Step1_before_onair' File
#     ${CONFIG_DIR_PATH}    Set Variable    ${CONFIG_DIR_PATH}/${SW_BRANCH}
#     change_iphy_rru_version     ${CONFIG_DIR_PATH}${/}${AIRPHONE_NAME}
# #    modify_swconfig    ${CONFIG_DIR_PATH}${/}${SCFC_NAME}
#     ${scfc_path}    Set Variable    ${TEST_LOG_DIRECTORY()}${/}scfc.xml
#     copy_file    ${CONFIG_DIR_PATH}${/}${SCFC_NAME}    ${scfc_path}
#     ${modify_list}    create list
# 	...      ${chBw}    ${actDlSrsBm}    ${actUlSrsBm}    ${dlMimoMode}    ${numberOfRxBeamforming}
# 	...      ${numberOfRxPucch}    ${actFdmScheduling}    ${actBeamforming}    ${nrBtsBeamRefinementP2}
# 	...      ${nrCellType}    ${actCustomBsr}    ${customBeamSetName}    ${basicBeamSet}    ${numberOfTransmittedSsBlocks}
#     modify_xml    ${scfc_path}    ${scfc_path}    ${modify_list}
# 	modify_vendor_file_for_72eUL
#     Modify TL VM And AP SCTP Configuration
# 	Get and Update BSR File    par_of_bsr_name=BSR_AVQL_6_H6_ALN60_ARP60_P00_COVERAGE_00424_00002
# 	Perform Full Commission And Reach Onair With Log    ${scfc_path}    ${CONFIG_DIR_PATH}${/}${WTS_NAME}    reset_after_commission=${False}
#     ${save_log}=    Set Variable    ${TEST_LOG_DIRECTORY()}Step1_before_onair
#     [Teardown]    Stop Capture GNB and AP Syslog in 'Step1_before_onair' File
# 	
# Modify vendor file 72e and full commission for onair
#     [Arguments]    ${wait_bts_timeout}=2000    ${wait_rru_timeout}=800    ${wait_onair_timeout}=800
#     Start capture gnb and ap syslog in 'before_onair' file
#     Change iphy rru version    ${CONFIG_DIR_PATH}/${SW_BRANCH}/${AIRPHONE_NAME}
#     OperatingSystem.Run And Return Rc And Output
#     ...    sshpass -p ${AP_ASIK.password} ssh ${AP_ASIK.username}@${AP_ASIK.ip} 'reboot'
#     Wait '10s' for stable
#     ${scfc_path}    Set variable    ${CONFIG_DIR_PATH}/${SW_BRANCH}/${SCFC_NAME}
#     ${cfg_path}    Set variable    ${CONFIG_DIR_PATH}/${SW_BRANCH}/${WTS_NAME}
# 	${modify_list}    create list
# 	...      ${chBw}    ${actDlSrsBm}    ${actUlSrsBm}    ${dlMimoMode}    ${numberOfRxBeamforming}
# 	...      ${numberOfRxPucch}    ${actFdmScheduling}    ${actBeamforming}    ${nrBtsBeamRefinementP2}
# 	...      ${nrCellType}    ${actCustomBsr}    ${customBeamSetName}    ${basicBeamSet}    ${numberOfTransmittedSsBlocks}
#     modify_xml    ${scfc_path}    ${scfc_path}    ${modify_list}
#     ${new_scfc}    GNB_BASE.Change Vlan Id In Scfc    ${scfc_path}    ${test_log_directory()}/full_commission/
#     Configure TL VM ETH3
#     TAF_ADMIN.Setup Admin
#     ${vendor_path}    Set Variable    ${test_log_directory()}/vendor_ini.xml
#     TAF_ADMIN.Download Vendor File    ${vendor_path} 
#     Modify Vendor betaec XML File    ${vendor_path}
#     Modify Vendor xec XML File    ${vendor_path} 
#     Modify Vendor 72e XML File    ${vendor_path}
#     TAF_ADMIN.Set Vendor File    ${vendor_path}
#     ${connission_status}    Run Keyword And Return Status    TAF_ADMIN.Perform Commissioning
#     ...    bts_id=${GNB_IP}
#     ...    scf_file=${new_scfc}
#     ...    skip_parameter_relation_errors=True
#     ...    should_activate=True
#     ...    timeout=300     
#     Log to console    Full Commissioning is ${connission_status}
#     TAF_ADMIN.teardown admin
#     Wait '120s' for stable
#     Run Keyword And Ignore Error    Start collect 'cellsetup' tcpdump
#     ${bts_status}=    Run Keyword And Return Status    Wait Unit Bts Configured    ${wait_bts_timeout}
#     ${rru_status}=    Run Keyword And Return Status    Wait Until RRU Configured    ${wait_rru_timeout}
#     ${onair_status}=    Run Keyword And Return Status    Start Wts And Wait Bts Until Onair     ${cfg_path}
#     ...    timeout=${wait_onair_timeout}
#     Stop capture gnb and ap syslog in 'before_onair' file
#     Log To Console    BTS is onAir now
#     Run Keyword And Ignore Error    Stop collect 'cellsetup' tcpdump
# 
# modify_vendor_file_for_72eUL
# 	TAF_ADMIN.Setup Admin
#     ${vendor_path}    Set Variable    ${TEST_LOG_DIRECTORY()}/vendor_ini.xml
#     TAF_ADMIN.Download Vendor File    ${vendor_path} 
#     Modify Vendor betaec XML File    ${vendor_path}
#     Modify Vendor xec XML File    ${vendor_path} 
#     Modify Vendor 72e XML File    ${vendor_path}
#     TAF_ADMIN.Set Vendor File    ${vendor_path}
# 	TAF_ADMIN.teardown admin
# 
# Modify Vendor 72e XML File 
#     [Arguments]    ${vendor_path} 
#     ${vendor_list72e}    Set Variable    text|${ECPRI72E}|//*[@name\="actEcpri72e"]  
#     Modify Xml    ${vendor_path}    ${vendor_path}    ${vendor_list72e}  
# 	
# Modify Vendor betaec XML File 
#     [Arguments]    ${vendor_path}  
#     ${vendor_listbetaec}    Set Variable    text|${BETAEC}|//*[@name\="betaEc"]  
#     Modify Xml    ${vendor_path}    ${vendor_path}    ${vendor_listbetaec} 
# 	
# Modify Vendor xec XML File 
#     [Arguments]    ${vendor_path} 
#     ${vendor_listxec}    Set Variable    text|${XEC}|//*[@name\="xEc"]  
#     Modify Xml    ${vendor_path}    ${vendor_path}    ${vendor_listxec} 
# 
# Step2:Attach UE and start buffer
#     Start Collect GNB and AP Syslog in 'Step2_attach' File
# 	${save_log}=    Set Variable    ${TEST_LOG_DIRECTORY()}Step2_attach
#     Start GNB BIP Log
# 
# 	Attach SA '3'ue to 5g cell
#     Wait '5s' for stable running
#     SA send multiple trf data    1    DL    175M    3
# 	SA send multiple trf data    1    UL    175M    1
# 	SA send multiple trf data    2    DL    175M    3
# 	SA send multiple trf data    2    UL    175M    1
# 	SA send multiple trf data    3    DL    175M    3
# 	SA send multiple trf data    3    UL    175M    1
# 	Start GNB Ttitrace With Streaming Mode
#     Wait '3s' for stable running
#     ${pacp}=    Stop GNB Ttitrace With Streaming Mode    save_path=${save_log}
#     Stop Gnb BIP Log    log_dir=${save_log}
#     Decoder Tttirace From Pcap To Csv    ${pacp}    ${save_log}/tti
# 
# 	#get tput from PM counter
#     ${remaining_time}=    get_counter_file_remaining_time    counter_refresh_period=5min
#     Wait Throughput Timer    ${remaining_time}
#     ${PM_counter_file}=    download_latest_pmcounter    local_path=${TEST_LOG_DIRECTORY()}Step2_attach${/}
#     ${FULL_PWR}=             get_counter_value_from_counter_file    counter_file=${PM_counter_file}    counter_id=M55114C01501    cell_id=1
# 	${FULL_PWR1}=            get_counter_value_from_counter_file    counter_file=${PM_counter_file}    counter_id=M55114C01502    cell_id=1
# 	${FULL_PWR2}=            get_counter_value_from_counter_file    counter_file=${PM_counter_file}    counter_id=M55114C01503    cell_id=1
# 	${DENOM_UE_FULL_PWR}=    get_counter_value_from_counter_file    counter_file=${PM_counter_file}    counter_id=M55114C01505    cell_id=1
# 	
# 	#check cell set up bip
#     Convert BIP To CSV    ${TEST_LOG_DIRECTORY()}ALL${/}cellSetup.pcap    ${save_log}/A1_case01_cellsetup.csv    ${FILTER1}    ${title1}
# 	[Teardown]    Stop Collect GNB and AP Syslog in 'Step2_attach' File