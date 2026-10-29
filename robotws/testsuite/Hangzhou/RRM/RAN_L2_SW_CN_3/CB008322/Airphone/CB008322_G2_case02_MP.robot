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
# ${SCFC_NAME}      gNB_scf_ASIM_ABIP_TDD_eCPRI_cmwv_SANSA_FS_1S_1CC_8D4U.xml
# ${AIRPHONE_NAME}      AP_iphy_AQQL_ASIM_ABIP_TDD_eCPRI_cmwv_SANSA_FS_1S_1CC_8D4U.xml
# ${WTS_NAME}           wts_config_ASIM_ABIP_TDD_eCPRI_cmwv_SANSA_FS_1S_1CC_UEs.cfg
# @{LOG_NAME_LIST}      egatelog     gnb_snapshot
# #    ap_snapshot    sosreport
# ${cellDepType}                    text|SA+NSA|//*[@name\="cellDepType"]
# ${chBw}                           text|80MHz|//*[@name\="chBw"]
# ${dlMimoMode}                     text|8x4 Closed Loop Spatial Multiplexing|//*[@name\="dlMimoMode"]
# ${nrCellType}                     text|8DL4UL|//*[@name\="nrCellType"]
# ${actUeCsirsCoexistCellCsirs}     text|false|//*[@name\="actUeCsirsCoexistCellCsirs"]
# ${actCsirsMultiplexing}           text|true|//*[@name\="actCsirsMultiplexing"]
# ${actDlSrsBm}                     text|true|//*[@name\="actDlSrsBm"]
# ${actUlSrsBm}                     text|true|//*[@name\="actUlSrsBm"]
# ${actDlSrsSubbandBm}              text|true|//*[@name\="actDlSrsSubbandBm"]
# ${actUeCsirsCoexistCellCsirs}     text|false|//*[@name\="actUeCsirsCoexistCellCsirs"]
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
# ${srsUePeriodicity}               text|slots40|//*[@name\="srsUePeriodicity"]
# ${cSRS}                           text|51|//*[@name\="cSRS"]
# ${bSRS}                           text|2|//*[@name\="bSRS"]
# ${srsTypeAllocForDlBm}            text|antenna switching or codebook|//*[@name\="srsTypeAllocForDlBm"]
# ${bfSubbandSize}                  text|32 PRBs|//*[@name\="bfSubbandSize"]
# ${maxNumUeSrs}                    text|4|//*[@name\="maxNumUeSrs"]
# ${srsPowerThresholdForDlBm}       text|-1500|//*[@name\="srsPowerThresholdForDlBm"]
# ${srsPowerThreshold}              text|-1500|//*[@name\="srsPowerThreshold"]
# ${wbSrsPowerThreshold}            text|-1300|//*[@name\="wbSrsPowerThreshold"]
# ${srsSinrThreshold}               text|200|//*[@name\="srsSinrThreshold"]
# ${seHysteresis}                   text|60|//*[@name\="seHysteresis"]
# ${actCustomBsr}                   text|true|//*[@name\="actCustomBsr"]
# ${customBeamSetName}              text|BSR_AQQL_6_H6_ALN60_ARP60_P11_COVERAGE_00776_00001|//*[@name\="customBeamSetName"]
# ${tiltOffset}                     text|0|//*[@name\="tiltOffset"]
# ${nrBtsBeamRefinementP2}          text|true|//*[@name\="nrBtsBeamRefinementP2"]
# ${maxCsirsNumber}                 text|2|//*[@name\="maxCsirsNumber"]
# ${csirsPower}                     text|3|//*[@name\="csirsPower"]
# ${miNrSrsQuality}                 text|5min|//*[@name\="miNrSrsQuality"]
# ${miNrBeamforming2}               text|5min|//*[@name\="miNrBeamforming2"]
# ${csirsNumberWithinReportPeriod_Set1}                     text|2|//*[@name\="csirsNumberWithinReportPeriod_Set1"]
# ${bwp_profile8}                   text|MRBTS-1/NRBTS-1/BWP_PROFILE-8|//*[@name\="cellBwpList"]/item[1]/*[@name\="bwpDN"]
# ${bwp_profile85}                  text|MRBTS-1/NRBTS-1/BWP_PROFILE-85|//*[@name\="cellBwpList"]/item[2]/*[@name\="bwpDN"]
# 
# ${par_of_bsr_name}                BSR_AQQL_6_H6_ALN60_ARP60_P11_COVERAGE_00776_00001
# 
# ${PROFILE_noise}         ul_cell_noise_testmode_nr profile_id=2 noise_srs=-300
# ${ACT_PROFILE_noise}        cell_testmode_set_nr  cell_id=1 gnb=2 testmode=ul_cell_noise profile_id=2 action=activate
# ${PROFILE1}     ul_mimo_srs_beam_pos_nr profile_id=1 mode=fixed init_quad_pos=1 init_sub_quad_pos=1 test_type=SRS
# ...        multi_path_config=true num_of_nlos_paths=1 azimuth=15 zenith=0 srs_transmit_power_per_port=-200,-200,-200,-300
# 
# 
# *** Test Cases ***
# CB008322_G2_case02_dynamic_fallback_with_Sinr_validation
#     Step1:Commission the above configuration on WebUI
#     Step2:Attach UE and start full buffer
# 
# 
# *** Keywords ***
# Step1:Commission the above configuration on WebUI
#     Start capture GNB and AP Syslog in 'Step1_before_onair' File
# 	${CONFIG_DIR_PATH}    Set Variable    ${CONFIG_DIR_PATH}/${SW_BRANCH}
#     change_iphy_rru_version    ${CONFIG_DIR_PATH}${/}${AIRPHONE_NAME}
#     Wts Execute Aashell Command
# 	...   confmgmtdefscli set --domain NrUeDlPhy --name radPdcchApplyToSeparateStreams_AP --value 1 --change-type persistent --timeout 5
#     modify_swconfig_by_CB008322    ${CONFIG_DIR_PATH}${/}${SCFC_NAME}
#     ${scfc_path}    Set Variable    ${TEST_LOG_DIRECTORY()}${/}scfc.xml
#     copy_file    ${CONFIG_DIR_PATH}/${SCFC_NAME}    ${scfc_path}
# 	add_xml_element     ${scfc_path}    ${scfc_path}     <p name="lteToNrFrameShift">3ms</p>|//*[@name\='tddFrameStructure']/item
#     add_xml_element     ${scfc_path}    ${scfc_path}     <p name="tdLteUlDlConfig">tdLteConfig2</p>|//*[@name\='tddFrameStructure']/item
#     add_periodicCsiAcquisition_list_in_cells    ${scfc_path}
#     ${modify_list}    create list
#     ...    ${cellDepType}                     ${actUlClosedLoopPwrCtrl}          ${tdLteUlDlConfig}
#     ...    ${chBw}                            ${actCDrx}                         ${ulDlDataSlotRatio}
#     ...    ${dlMimoMode}                      ${actFdmScheduling}                ${prachConfigurationIndex}
#     ...    ${nrCellType}                      ${actDlMuMimoEnh}                  ${srsUePeriodicity}
#     ...    ${actUeCsirsCoexistCellCsirs}      ${actDl256Qam}                     ${cSRS}
#     ...    ${actCsirsMultiplexing}            ${actUl256Qam}                     ${bSRS}
#     ...    ${actDlSrsBm}                      ${actIncreasedFdmUsersPerSlot}     ${csirsPower}
#     ...    ${actUlSrsBm}                      ${frameStructureType}              ${srsTypeAllocForDlBm}
#     ...    ${actDlSrsSubbandBm}               ${guardPeriodLength}               ${bfSubbandSize}
#     ...    ${lteToNrFrameShift}               ${maxNumUeSrs}
#     ...    ${srsPowerThresholdForDlBm}        ${actCustomBsr}                    ${miNrSrsQuality}
#     ...    ${srsPowerThreshold}               ${customBeamSetName}               ${miNrBeamforming2}
#     ...    ${wbSrsPowerThreshold}             ${tiltOffset}                      ${csirsNumberWithinReportPeriod_Set1}
#     ...    ${srsSinrThreshold}                ${nrBtsBeamRefinementP2}           ${bwp_profile8}
#     ...    ${seHysteresis}                    ${maxCsirsNumber}                  ${bwp_profile85}
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
# 	add_txt_node    0x800070:1         #rdRtBwvDowngradeMethod default:1,1.The number of BWVs is aligned with the request from 5G-L2-PS
# 	add_txt_node    0x600018:0        #rdUlUpFragmentationEnable
#     teardown_txt
# 	setup_txt    src_file=${path_ap}    save_path=${TEST_LOG_DIRECTORY()}${/}swconfig_ap_ini.txt
#     teardown_txt
#     GNB Upload Swconfig           ${TEST_LOG_DIRECTORY()}${/}swconfig_gnb_ini.txt
#     airphone_upload_swconfig      ${TEST_LOG_DIRECTORY()}${/}swconfig_ap_ini.txt
# 
# Step2:Attach UE and start full buffer
#     Start Collect GNB and AP Syslog in 'Step2_attach' File
#     ${save_log}=    Set Variable    ${TEST_LOG_DIRECTORY()}Step2_attach
#     Start GNB BIP Log
#     Airphone Execute Egate Command    ${PROFILE_noise}
#     Airphone Execute Egate Command    ${ACT_PROFILE_noise}
#     Attach SA ue with capability to 5g cell    1    CA_P2_8x4_t1r4_n1
#     Wait '3s' for stable running
# 	Set UE'1' to UE'1' position
# 	Start GNB Ttitrace With Streaming Mode
#     SA send multiple trf data    1    DL    175M    8
#     SA send multiple trf data    1    UL    175M    2
#     Wait Throughput Timer    3
# 	${pacp}=    Stop GNB Ttitrace With Streaming Mode    save_path=${save_log}
#     Decoder Tttirace From Pcap To Csv    ${pacp}    ${save_log}/tti
#     run keyword and continue on failure    spill_value_of_srsswitchmeas    ${save_log}/tti_dl.csv    ${save_log}/target_dl_srs.csv
#     ${Dl_throughput} =    Airphone Sa Get Throughput    ue_id=1    direction=dl
#     ${Ul_throughput} =    Airphone Sa Get Throughput    ue_id=1    direction=ul
#     Stop Gnb BIP Log    log_dir=${save_log}
#     run keyword and continue on failure
# 	...    check_log_with_au2anlysis    ini_path=${CURDIR}/log_check/G2_case02_tti_step2.ini    log_need_to_check=i
#     ...    save_log_directory=${save_log}
# 
#     run keyword and continue on failure    split_value_of_bwv_response    ${save_log}/tti_dl.csv    ${save_log}/target_dl_bwv.csv
#     run keyword and continue on failure
# 	...    check_log_with_au2anlysis    ini_path=${CURDIR}/log_check/G2_case02_tti_step2_2.ini    log_need_to_check=i
#     ...    save_log_directory=${save_log}
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
