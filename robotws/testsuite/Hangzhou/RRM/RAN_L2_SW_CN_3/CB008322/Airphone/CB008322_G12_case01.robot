# *** Settings ***
# Documentation     Author: xuemin.ma@nokia-sbell.com
# ...
# 
# Suite Setup       Common Suite Setup
# #Suite Teardown    Common Suite Teardown
# Test Setup        Common Test Setup
# Test Teardown     Common Test Teardown
# Force Tags        CLOUD_5G_I_LO_AP_LO_SANSA_FS_ECPRI_CMWV_TDD    AP    CRT    SBTS00    RAN_5G_TDD    RAN_5G    owner_xueminm
# Test Timeout      90 minutes
# Resource          ../../resources/sg11/internal_resource/robot/modify_configuration.robot
# Resource          ../../resources/sg11/internal_resource/robot/internal_ap_operate.robot
# Resource          ../../resources/sg11/internal_resource/robot/internal_gnb_operate.robot
# Resource          ../../resources/sg11/internal_resource/robot/internal_capture_log.robot
# Library           taf.transport.ssh    WITH NAME    TAF_SSH
# Library           ta_a2a
# 
# *** Variables ***
# ${CONFIG_DIR_PATH}    ${CURDIR}/../../resources/sg11/internal_resource/config/
# ${SCFC_NAME}          gNB_scf_ASIL_ABIO_TDD_eCPRI_cmwv_SANSA_FS_1S_1CC_8D4U.xml
# ${AIRPHONE_NAME}      iphy_CB008322_G12_case01.xml
# ${WTS_NAME}           wts_config_ASIL_ABIO_TDD_eCPRI_cmwv_SANSA_FS_1S_1CC.cfg
# ${local_endpoint_path}    ${CURDIR}/JSON/custom_AQQL_l1low_endpoint_types.json
# @{LOG_NAME_LIST}      egatelog    gnb_snapshot    
# ${cellDepType}                    text|SA+NSA|//*[@name\="cellDepType"]
# ${chBw}                           text|100MHz|//*[@name\="chBw"]
# ${dlMimoMode}                     text|8x4 Closed Loop Spatial Multiplexing|//*[@name\="dlMimoMode"]
# ${nrCellType}                     text|8DL4UL|//*[@name\="nrCellType"]
# ${actUeCsirsCoexistCellCsirs}     text|false|//*[@name\="actUeCsirsCoexistCellCsirs"]
# ${actCsirsMultiplexing}           text|true|//*[@name\="actCsirsMultiplexing"]
# ${actDlSrsBm}                     text|true|//*[@name\="actDlSrsBm"]
# ${actUlSrsBm}                     text|false|//*[@name\="actUlSrsBm"]
# ${actDlSrsSubbandBm}              text|true|//*[@name\="actDlSrsSubbandBm"]
# ${actSrsBeamFallbackByRetrx}      text|true|//*[@name\="actSrsBeamFallbackByRetrx"]
# ${actUlClosedLoopPwrCtrl}         text|disabled|//*[@name\="actUlClosedLoopPwrCtrl"]
# ${actCDrx}                        text|false|//*[@name\="actCDrx"]
# ${actFdmScheduling}               text|true|//*[@name\="actFdmScheduling"]
# ${actDlMuMimoEnh}                 text|false|//*[@name\="actDlMuMimoEnh"]
# ${actDl256Qam}                    text|false|//*[@name\="actDl256Qam"]
# ${actUl256Qam}                    text|false|//*[@name\="actUl256Qam"]
# ${actIncreasedFdmUsersPerSlot}    text|true|//*[@name\="actIncreasedFdmUsersPerSlot"]
# ${frameStructureType}             text|tdLte|//*[@name\="frameStructureType"]
# ${guardPeriodLength}              text|6Symbols|//*[@name\="guardPeriodLength"]
# ${lteToNrFrameShift}              text|3ms|//*[@name\="lteToNrFrameShift"]
# ${tdLteUlDlConfig}                text|tdLteConfig2|//*[@name\="tdLteUlDlConfig"]
# ${ulDlDataSlotRatio}              text|3/7|//*[@name\="ulDlDataSlotRatio"]
# ${prachConfigurationIndex}        text|98|//*[@name\="prachConfigurationIndex"]
# ${srsUePeriodicity}               text|slots20|//*[@name\="srsUePeriodicity"]
# ${cSRS}                           text|62|//*[@name\="cSRS"]
# ${bSRS}                           text|2|//*[@name\="bSRS"]
# ${srsPowerThresholdForDlBm}       text|-1200|//*[@name\="srsPowerThresholdForDlBm"]
# ${srsTypeAllocForDlBm}            text|antenna switching or codebook|//*[@name\="srsTypeAllocForDlBm"]
# ${bfSubbandSize}                  text|8 PRBs|//*[@name\="bfSubbandSize"]
# ${maxNumUeSrs}                    text|4|//*[@name\="maxNumUeSrs"]
# ${srsQualityThreshold}            text|-1150|//*[@name\="srsQualityThreshold"]
# ${seHysteresis}                   text|60|//*[@name\="seHysteresis"]
# ${srsSinrThreshold}                text|-400|//*[@name\="srsSinrThreshold"]
# ${actCustomBsr}                   text|true|//*[@name\="actCustomBsr"]
# ${customBeamSetName}              text|BSR_AQQL_6_H6_ALN60_ARP60_P11_COVERAGE_00776_00001|//*[@name\="customBeamSetName"]
# ${tiltOffset}                     text|0|//*[@name\="tiltOffset"]
# ${nrBtsBeamRefinementP2}          text|true|//*[@name\="nrBtsBeamRefinementP2"]
# ${maxCsirsNumber}                 text|2|//*[@name\="maxCsirsNumber"]
# ${csirsPower}                     text|3|//*[@name\="csirsPower"]
# ${miNrSrsQuality}                 text|5min|//*[@name\="miNrSrsQuality"]
# ${miNrBeamforming2}               text|5min|//*[@name\="miNrBeamforming2"]
# ${csirsNumberWithinReportPeriod_Set1}                     text|2|//*[@name\="csirsNumberWithinReportPeriod_Set1"]
# ${bwp_profile7}                   text|MRBTS-1/NRBTS-1/BWP_PROFILE-7|//*[@name\="cellBwpList"]/item[1]/*[@name\="bwpDN"]
# ${bwp_profile77}                  text|MRBTS-1/NRBTS-1/BWP_PROFILE-77|//*[@name\="cellBwpList"]/item[2]/*[@name\="bwpDN"]
# 
# ${par_of_bsr_name}                BSR_AQQL_6_H6_ALN60_ARP60_P11_COVERAGE_00776_00001
# 
# ${FILTER1}    (itf_l2_ps_cell_cellsetupreq)||(ulcell_setupreq)
# @{title1}    itf_l2_ps_cell_BfSetup.actDlSrsSubbandBm    itf_l2_ps_cell_DlSubbandBmConfig.bfSubbandSize
# ...    itf_l2_ps_cell_DlSubbandBmConfig.rtBeamStartPid    itf_l2_ps_cell_DlSubbandBmConfig.numOfRtBeamPid
# ...    itf_l2_ps_cell_DlSubbandBmConfig.dlMaxBeamsPerSlot    itf_l2_ps_cell_DlSubbandBmConfig.dlMaxBeamsPerSymbol
# ...    UlCell_pSRSBwvConfig_t.maxRtBwvDownloadPerSlot
# 
# *** Test Cases ***
# CB008322_G12_case01_RU and L1 capability handling
#     Step1:Commission the above configuration on WebUI
#     Step2:Attach 4UE and start full buffer
# 
# *** Keywords ***
# Step1:Commission the above configuration on WebUI
#     Start capture GNB and AP Syslog in 'Step1_before_onair' File
# 	${CONFIG_DIR_PATH}    Set Variable    ${CONFIG_DIR_PATH}/${SW_BRANCH}
#     change_iphy_rru_version    ${CONFIG_DIR_PATH}${/}${AIRPHONE_NAME}
#     Modify Airphone endpointConfig    ${local_endpoint_path}
#     Wts Execute Aashell Command   
# 	...   confmgmtdefscli set --domain NrUeDlPhy --name radPdcchApplyToSeparateStreams_AP --value 1 --change-type persistent --timeout 5
#     modify_swconfig_by_CB008322    ${CONFIG_DIR_PATH}${/}${SCFC_NAME}
#     ${scfc_path}    Set Variable    ${TEST_LOG_DIRECTORY()}${/}scfc.xml
#     copy_file    ${CONFIG_DIR_PATH}/${SCFC_NAME}    ${scfc_path}
# 	add_xml_element     ${scfc_path}    ${scfc_path}     <p name="lteToNrFrameShift">3ms</p>|//*[@name\='tddFrameStructure']/item
#     add_xml_element     ${scfc_path}    ${scfc_path}     <p name="tdLteUlDlConfig">tdLteConfig2</p>|//*[@name\='tddFrameStructure']/item
#     add_periodicCsiAcquisition_list_in_cells    ${scfc_path}
#     ${modify_list}    create list
#     ...    ${cellDepType}    ${chBw}    ${dlMimoMode}    ${nrCellType}    ${actUeCsirsCoexistCellCsirs}    ${actCsirsMultiplexing}
#     ...    ${actDlSrsBm}    ${actUlSrsBm}    ${actDlSrsSubbandBm}    ${actUlClosedLoopPwrCtrl}    ${actCDrx}    ${actFdmScheduling}
#     ...    ${actDlMuMimoEnh}    ${actDl256Qam}    ${actUl256Qam}    ${actIncreasedFdmUsersPerSlot}    ${frameStructureType}
#     ...    ${guardPeriodLength}    ${lteToNrFrameShift}    ${tdLteUlDlConfig}    ${ulDlDataSlotRatio}    ${prachConfigurationIndex}
#     ...    ${srsUePeriodicity}    ${cSRS}    ${bSRS}    ${srsPowerThresholdForDlBm}    ${srsTypeAllocForDlBm}    ${bfSubbandSize}
#     ...    ${maxNumUeSrs}    ${srsQualityThreshold}    ${actCustomBsr}    ${customBeamSetName}    ${actSrsBeamFallbackByRetrx}
#     ...    ${tiltOffset}    ${nrBtsBeamRefinementP2}    ${maxCsirsNumber}    ${csirsPower}     ${csirsNumberWithinReportPeriod_Set1}
#     ...    ${bwp_profile7}    ${bwp_profile77}    ${seHysteresis}   ${srsSinrThreshold}
#     ...    ${miNrSrsQuality}    ${miNrBeamforming2}
#     modify_xml    ${scfc_path}    ${scfc_path}    ${modify_list}
#     Modify TL VM And AP SCTP Configuration
#     Get and Update BSR File    ${par_of_bsr_name}
# 	Add L2PS Deubg Logs
#     Perform Full Commission And Reach Onair With Log    ${scfc_path}    ${CONFIG_DIR_PATH}${/}${WTS_NAME}    reset_after_commission=${False}
# 	[Teardown]    Stop capture GNB and AP Syslog in 'Step1_before_onair' File
# 
# Add L2PS Deubg Logs
#     ${debuglogs}    create list    level=DBG\n    L2.L2_PS.DEBUG=1\n    L2.L2_PS.DL.SUBBAND_BEAMFORMING=1\n    L2.L2_PS.SRS_BASED_BM=1\n
# 	Active L2ps Feature Debug Traces    ${debuglogs}
# 	TAF_SSH.connect to    192.168.255.1   toor4nsn    oZPS0POrRieRtu   alias=bsh
# 	TAF_SSH.execute    rm /ffs/run/HashContainer*    connection=bsh
# 
# modify_swconfig_by_CB008322
#     comment     https://confluence.ext.net.nokia.com/pages/viewpage.action?spaceKey=AirPhoneWTS&title=AirPhone+Alignment+to+gNB+L1L2+Interface
#     [Arguments]    ${scfc_file}
# 	${local_save_path}=     Download All Common Config Files From Golden Server
# 	${path_gnb}=            Find Match GNB swconfig Golden Files    ${scfc_file}    ${local_save_path}
# 	${path_ap}=             Find Match AP swconfig Golden Files    ${scfc_file}     ${local_save_path}
#     setup_txt    src_file=${path_gnb}    save_path=${TEST_LOG_DIRECTORY()}${/}swconfig_gnb_ini.txt
# 	add_txt_node    0x340000:1        #as PM counter period update to 15/15=1min
# 	add_txt_node    0x580477:1       #The UL CoMa log enabling flag(rdUlSrsCoMaLogEnabled)
#     add_txt_node    0x580264:1          #The DL CoMa log enabling flag(rdDlSrsLogControl, bit0)
#     teardown_txt
# 	setup_txt    src_file=${path_ap}    save_path=${TEST_LOG_DIRECTORY()}${/}swconfig_ap_ini.txt
#     teardown_txt
#     GNB Upload Swconfig           ${TEST_LOG_DIRECTORY()}${/}swconfig_gnb_ini.txt
#     airphone_upload_swconfig      ${TEST_LOG_DIRECTORY()}${/}swconfig_ap_ini.txt
# 
# Modify Airphone endpointConfig
#     [Arguments]    ${local_endpoint_path}     ${target_path}=/rom/simmode/custom_AQQL_l1low_endpoint_types.json
#     TAF_SSH.connect to     192.168.200.1   toor4nsn    oZPS0POrRieRtu    alias=iphy
#     TAF_SSH.upload file    ${local_endpoint_path}       ${target_path}    connection=iphy
#     TAF_SSH.Disconnect     connection=iphy
# 
# Step2:Attach 4UE and start full buffer
#     Start Collect GNB and AP Syslog in 'Step2_attach' File
#     ${save_log}=    Set Variable    ${TEST_LOG_DIRECTORY()}Step2_attach
#     Start GNB BIP Log
#     Attach SA ue with capability to 5g cell    4    CA_P2_8x4_t2r4_n2
#     Wait '3s' for stable running
#     : FOR    ${u_id}    IN RANGE    1    5
#     \    Airphone SA Start Data Traffic    ue_id=${u_id}    direction=dl    throughput=175M    trf_id=1    duration=7200
#     \    Airphone SA Start Data Traffic    ue_id=${u_id}    direction=dl    throughput=175M    trf_id=2    duration=7200
# 	\    Airphone SA Start Data Traffic    ue_id=${u_id}    direction=dl    throughput=175M    trf_id=3    duration=7200
# 	\    Airphone SA Start Data Traffic    ue_id=${u_id}    direction=dl    throughput=175M    trf_id=4    duration=7200
#     \    Airphone Sa Start Data Traffic    ue_id=${u_id}    direction=ul    throughput=175M    trf_id=1    duration=7200
#     Wait '10s' for stable running
#     : FOR    ${u_id}    IN RANGE    1    5
#     \    ${Dl_throughput} =    Airphone Sa Get Throughput    ue_id=${u_id}    direction=dl
#     \    ${Ul_throughput} =    Airphone Sa Get Throughput    ue_id=${u_id}    direction=ul
#     Capture ttitrace    ${save_log}
#     Stop Gnb BIP Log    log_dir=${save_log}
#     Convert BIP To CSV    ${TEST_LOG_DIRECTORY()}/cellSetup0.pcap    ${save_log}/cellsetup.csv    ${FILTER1}    ${title1}
#     [Teardown]    Stop Collect GNB and AP Syslog in 'Step2_attach' File
# 
# Set UE'${ue_id}' to UE'${ue_id_end}' position
#     : FOR    ${u_id}    IN RANGE    ${ue_id}    ${ue_id_end}+1
#     \    Airphone Execute Egate Command    ${PROFILE1}
#     \    Airphone Execute Egate Command    ue_testmode_set_nr id\=${u_id} testmode\=ul_mimo_srs_beam_pos action\=activate profile_id\=1
#     \    Wait '2s' for stable running
# 
# Capture ttitrace
#     [Arguments]    ${save_log}
#     Start GNB Ttitrace With Streaming Mode
#     Wait '2s' for stable running
#     ${pacp}=    Stop GNB Ttitrace With Streaming Mode    save_path=${save_log}
#     Decoder Tttirace From Pcap To Csv    ${pacp}    ${save_log}/tti
#     run keyword and continue on failure    spill_value_of_srsswitchmeas    ${save_log}/tti_dl.csv    ${save_log}/target_dl.csv
