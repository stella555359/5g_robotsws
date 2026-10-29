*** Settings ***
Documentation     Author: xuemin.ma@nokia-sbell.com
...

Suite Setup       Common Suite Setup
#Suite Teardown    Common Suite Teardown
Test Setup        Common Test Setup
Test Teardown     Common Test Teardown
Force Tags        CLOUD_5G_I_LO_AP_LO_SANSA_FS_ECPRI_CMWV_TDD    AP    CRT    SBTS00    RAN_5G_TDD    RAN_5G    owner_xueminm
Test Timeout      120 minutes
Resource          ../../resources/sg11/internal_resource/robot/modify_configuration.robot
Resource          ../../resources/sg11/internal_resource/robot/internal_ap_operate.robot
Resource          ../../resources/sg11/internal_resource/robot/internal_gnb_operate.robot
Resource          ../../resources/sg11/internal_resource/robot/internal_capture_log.robot
Library           taf.transport.ssh    WITH NAME    TAF_SSH
Library           ta_a2a

*** Variables ***
${CONFIG_DIR_PATH}    ${CURDIR}/../../resources/sg11/internal_resource/config/
${SCFC_NAME}          gNB_scf_ASIL_ABIO_TDD_eCPRI_cmwv_SANSA_FS_1S_1CC_8D4U.xml
${AIRPHONE_NAME}      AP_iphy_AQQL_ASIL_ABIO_TDD_eCPRI_cmwv_SANSA_FS_1S_1CC_8D4U_9496.xml
${WTS_NAME}           wts_config_ASIL_ABIO_TDD_eCPRI_cmwv_SANSA_FS_1S_1CC.cfg
@{LOG_NAME_LIST}      egatelog\    gnb_snapshot
#    ap_snapshot    sosreport
${cellDepType}                    text|SA+NSA|//*[@name\="cellDepType"]
${chBw}                           text|80MHz|//*[@name\="chBw"]
${dlMimoMode}                     text|8x4 Closed Loop Spatial Multiplexing|//*[@name\="dlMimoMode"]
${nrCellType}                     text|8DL4UL|//*[@name\="nrCellType"]
${actUeCsirsCoexistCellCsirs}     text|false|//*[@name\="actUeCsirsCoexistCellCsirs"]
${actCsirsMultiplexing}           text|true|//*[@name\="actCsirsMultiplexing"]
${actDlSrsBm}                     text|true|//*[@name\="actDlSrsBm"]
${actUlSrsBm}                     text|true|//*[@name\="actUlSrsBm"]
${actDlSrsSubbandBm}              text|true|//*[@name\="actDlSrsSubbandBm"]
${actUlClosedLoopPwrCtrl}         text|disabled|//*[@name\="actUlClosedLoopPwrCtrl"]
${actCDrx}                        text|false|//*[@name\="actCDrx"]
${actFdmScheduling}               text|true|//*[@name\="actFdmScheduling"]
${actDlMuMimoEnh}                 text|false|//*[@name\="actDlMuMimoEnh"]
${actDl256Qam}                    text|false|//*[@name\="actDl256Qam"]
${actUl256Qam}                    text|false|//*[@name\="actUl256Qam"]
${actIncreasedFdmUsersPerSlot}    text|true|//*[@name\="actIncreasedFdmUsersPerSlot"]
${frameStructureType}             text|tdLte|//*[@name\="frameStructureType"]
${guardPeriodLength}              text|6Symbols|//*[@name\="guardPeriodLength"]
${lteToNrFrameShift}              text|3ms|//*[@name\="lteToNrFrameShift"]
${tdLteUlDlConfig}                text|tdLteConfig2|//*[@name\="tdLteUlDlConfig"]
${ulDlDataSlotRatio}              text|3/7|//*[@name\="ulDlDataSlotRatio"]
${prachConfigurationIndex}        text|98|//*[@name\="prachConfigurationIndex"]
${srsUePeriodicity}               text|slots20|//*[@name\="srsUePeriodicity"]
${cSRS}                           text|51|//*[@name\="cSRS"]
${bSRS}                           text|2|//*[@name\="bSRS"]
${srsPowerThresholdForDlBm}       text|-1500|//*[@name\="srsPowerThresholdForDlBm"]
${srsPowerThreshold}              text|-1500|//*[@name\="srsPowerThreshold"]
${wbSrsPowerThreshold}            text|-1300|//*[@name\="wbSrsPowerThreshold"]
${srsSinrThreshold}               text|-400|//*[@name\="srsSinrThreshold"]
${srsTypeAllocForDlBm}            text|antenna switching or codebook|//*[@name\="srsTypeAllocForDlBm"]
${bfSubbandSize}                  text|16 PRBs|//*[@name\="bfSubbandSize"]
${maxNumUeSrs}                    text|4|//*[@name\="maxNumUeSrs"]
${seHysteresis}                   text|60|//*[@name\="seHysteresis"]
${actCustomBsr}                   text|true|//*[@name\="actCustomBsr"]
${customBeamSetName}              text|BSR_AQQL_6_H6_ALN60_ARP60_P11_COVERAGE_00776_00001|//*[@name\="customBeamSetName"]
${tiltOffset}                     text|0|//*[@name\="tiltOffset"]
${nrBtsBeamRefinementP2}          text|true|//*[@name\="nrBtsBeamRefinementP2"]
${maxCsirsNumber}                 text|2|//*[@name\="maxCsirsNumber"]
${csirsPower}                     text|3|//*[@name\="csirsPower"]
${miNrSrsQuality}                 text|5min|//*[@name\="miNrSrsQuality"]
${miNrBeamforming2}               text|5min|//*[@name\="miNrBeamforming2"]
${csirsNumberWithinReportPeriod_Set1}                     text|2|//*[@name\="csirsNumberWithinReportPeriod_Set1"]
${bwp_profile8}                   text|MRBTS-1/NRBTS-1/BWP_PROFILE-8|//*[@name\="cellBwpList"]/item[1]/*[@name\="bwpDN"]
${bwp_profile85}                  text|MRBTS-1/NRBTS-1/BWP_PROFILE-85|//*[@name\="cellBwpList"]/item[2]/*[@name\="bwpDN"]

${par_of_bsr_name}                BSR_AQQL_6_H6_ALN60_ARP60_P11_COVERAGE_00776_00001
${PROFILE1}    ul_mimo_srs_beam_pos_nr profile_id=1 mode=fixed init_quad_pos=1 init_sub_quad_pos=1 test_type=SRS
...        multi_path_config=true num_of_nlos_paths=1 azimuth=15 zenith=0 srs_transmit_power_per_port=-300,-300,-300,-300
${PROFILE2}    ul_mimo_srs_beam_pos_nr profile_id=2 mode=fixed init_quad_pos=1 init_sub_quad_pos=1 test_type=SRS
...        multi_path_config=true num_of_nlos_paths=1 azimuth=15 zenith=0 srs_transmit_power_per_port=-670,-670,-670,-670
${PROFILE3}    ul_mimo_srs_beam_pos_nr profile_id=2 mode=fixed init_quad_pos=1 init_sub_quad_pos=1 test_type=SRS
...        multi_path_config=true num_of_nlos_paths=1 azimuth=15 zenith=0 srs_transmit_power_per_port=-130,-130,-130,-130
${PROFILE4}    ul_mimo_srs_beam_pos_nr profile_id=2 mode=fixed init_quad_pos=1 init_sub_quad_pos=1 test_type=SRS
...        multi_path_config=true num_of_nlos_paths=1 azimuth=15 zenith=0 srs_transmit_power_per_port=-670,-670,-670,-300

${FILTER1}    (itf_l2_ps_cell_cellsetupreq)||(ulcell_setupreq)
@{title1}    itf_l2_ps_cell_BfSetup.actDlSrsSubbandBm    itf_l2_ps_cell_DlSubbandBmConfig.bfSubbandSize
...    itf_l2_ps_cell_DlSubbandBmConfig.srsPowerThreshold
...    itf_l2_ps_cell_DlSubbandBmConfig.srsSinrThreshold       itf_l2_ps_cell_DlSubbandBmConfig.maxNumUeSrs
...    itf_l2_ps_cell_DlSubbandBmConfig.rtBeamStartPid    itf_l2_ps_cell_DlSubbandBmConfig.numOfRtBeamPid
...    itf_l2_ps_cell_DlSubbandBmConfig.dlMaxBeamsPerSlot    itf_l2_ps_cell_DlSubbandBmConfig.dlMaxBeamsPerSymbol
@{value_list_level_20}
@{value_list_level_01}
@{value_list_level_28}
@{value_list_level_17}
@{value_list_level_sb}
${PROFILE8}    csi_override_testmode_nr profile_id=8 cqi_mode=fixed cqi=15 ri_mode=fixed ri=0

*** Test Cases ***
CB008322_G5_case01_UE-related_WB_SRS_power_Counter
    Step1:Commission the above configuration on WebUI
    Step2:RANK4 UE1~4 with t2r4 capability attach to cell1
    Step3:UE1-4 send DL data with full buffer
    Step4:Override power of UE1-4 as -96dBm
	Step5:Override power of UE1-4 as -132dBm
	Step6:Override power of UE1-4 as -79dBm
	Step7:Override port power different of UE1-4 as average power as -101dBm
	Step8:Override UE1-4 to RANK1

*** Keywords ***
Step1:Commission the above configuration on WebUI
    Start capture GNB and AP Syslog in 'Step1_before_onair' File
	${CONFIG_DIR_PATH}    Set Variable    ${CONFIG_DIR_PATH}/${SW_BRANCH}
    change_iphy_rru_version    ${CONFIG_DIR_PATH}${/}${AIRPHONE_NAME}
    Wts Execute Aashell Command   
	...   confmgmtdefscli set --domain NrUeDlPhy --name radPdcchApplyToSeparateStreams_AP --value 1 --change-type persistent --timeout 5
    modify_swconfig_by_CB008322    ${CONFIG_DIR_PATH}${/}${SCFC_NAME}
    ${scfc_path}    Set Variable    ${TEST_LOG_DIRECTORY()}${/}scfc.xml
    copy_file    ${CONFIG_DIR_PATH}/${SCFC_NAME}    ${scfc_path}
	add_xml_element     ${scfc_path}    ${scfc_path}     <p name="lteToNrFrameShift">3ms</p>|//*[@name\='tddFrameStructure']/item
    add_xml_element     ${scfc_path}    ${scfc_path}     <p name="tdLteUlDlConfig">tdLteConfig2</p>|//*[@name\='tddFrameStructure']/item
    add_periodicCsiAcquisition_list_in_cells    ${scfc_path}
    ${modify_list}    create list
    ...    ${cellDepType}                       ${actCDrx}                             ${srsUePeriodicity}
    ...    ${chBw}                              ${actFdmScheduling}                    ${cSRS}
    ...    ${dlMimoMode}                        ${actDlMuMimoEnh}                      ${bSRS}
    ...    ${nrCellType}                        ${actDl256Qam}                         ${srsPowerThresholdForDlBm}
    ...    ${actUeCsirsCoexistCellCsirs}        ${actUl256Qam}                         ${srsPowerThreshold}
    ...    ${actCsirsMultiplexing}              ${actIncreasedFdmUsersPerSlot}         ${wbSrsPowerThreshold}
    ...    ${actDlSrsBm}                        ${frameStructureType}                  ${srsTypeAllocForDlBm}
    ...    ${actUlSrsBm}                        ${guardPeriodLength}                   ${bfSubbandSize}
    ...    ${actDlSrsSubbandBm}                 ${lteToNrFrameShift}                   ${maxNumUeSrs}
    ...    ${actUlClosedLoopPwrCtrl}            ${tdLteUlDlConfig}                     ${seHysteresis}
    ...    ${ulDlDataSlotRatio}                 ${customBeamSetName}                   ${actCustomBsr}
    ...    ${prachConfigurationIndex}           ${tiltOffset}                          ${csirsPower}
    ...    ${nrBtsBeamRefinementP2}             ${maxCsirsNumber}                      ${miNrSrsQuality}
    ...    ${csirsNumberWithinReportPeriod_Set1}     ${bwp_profile8}     ${bwp_profile85}
    ...    ${miNrBeamforming2}     ${srsSinrThreshold}
    modify_xml    ${scfc_path}    ${scfc_path}    ${modify_list}
    Modify TL VM And AP SCTP Configuration
    Get and Update BSR File    ${par_of_bsr_name}
	Add L2PS Deubg Logs
    Perform Full Commission And Reach Onair With Log    ${scfc_path}    ${CONFIG_DIR_PATH}${/}${WTS_NAME}    reset_after_commission=${False}
	[Teardown]    Stop capture GNB and AP Syslog in 'Step1_before_onair' File

Add L2PS Deubg Logs
    ${debuglogs}    create list    level=DBG\n    L2.L2_PS.DEBUG=1\n    L2.L2_PS.DL.SUBBAND_BEAMFORMING=1\n    L2.L2_PS.SRS_BASED_BM=1\n
	Active L2ps Feature Debug Traces    ${debuglogs}
	TAF_SSH.connect to    192.168.255.1   toor4nsn    oZPS0POrRieRtu   alias=bsh
	TAF_SSH.execute    rm /ffs/run/HashContainer*    connection=bsh

modify_swconfig_by_CB008322
    comment     https://confluence.ext.net.nokia.com/pages/viewpage.action?spaceKey=AirPhoneWTS&title=AirPhone+Alignment+to+gNB+L1L2+Interface
    [Arguments]    ${scfc_file}
	${local_save_path}=     Download All Common Config Files From Golden Server
	${path_gnb}=            Find Match GNB swconfig Golden Files    ${scfc_file}    ${local_save_path}
	${path_ap}=             Find Match AP swconfig Golden Files    ${scfc_file}     ${local_save_path}
    setup_txt    src_file=${path_gnb}    save_path=${TEST_LOG_DIRECTORY()}${/}swconfig_gnb_ini.txt
	add_txt_node    0x580477:1       #The UL CoMa log enabling flag(rdUlSrsCoMaLogEnabled)
    add_txt_node    0x580264:1          #The DL CoMa log enabling flag(rdDlSrsLogControl, bit0)
    teardown_txt
	setup_txt    src_file=${path_ap}    save_path=${TEST_LOG_DIRECTORY()}${/}swconfig_ap_ini.txt
    teardown_txt
    GNB Upload Swconfig           ${TEST_LOG_DIRECTORY()}${/}swconfig_gnb_ini.txt
    airphone_upload_swconfig      ${TEST_LOG_DIRECTORY()}${/}swconfig_ap_ini.txt

Step2:RANK4 UE1~4 with t2r4 capability attach to cell1
    Start Collect GNB and AP Syslog in 'Step2_attach' File
    ${save_log}=    Set Variable    ${TEST_LOG_DIRECTORY()}Step2_attach
    Attach SA ue with capability to 5g cell    4    CA_P2_8x4_t2r4_n2
    Wait '3s' for stable running

    [Teardown]    Stop Collect GNB and AP Syslog in 'Step2_attach' File

Step3:UE1-4 send DL data with full buffer
    Start Collect GNB and AP Syslog in 'Step3_data' File
    ${save_log}=    Set Variable    ${TEST_LOG_DIRECTORY()}Step3_data
    FOR    ${u_id}    IN RANGE    1    5
        Airphone SA Start Data Traffic    ue_id=${u_id}    direction=dl    throughput=175M    trf_id=1    duration=7200
        Airphone SA Start Data Traffic    ue_id=${u_id}    direction=dl    throughput=175M    trf_id=2    duration=7200
        Airphone SA Start Data Traffic    ue_id=${u_id}    direction=dl    throughput=175M    trf_id=3    duration=7200
        Airphone Sa Start Data Traffic    ue_id=${u_id}    direction=ul    throughput=175M    trf_id=1    duration=7200
    END
    Wait '10s' for stable running
    FOR    ${u_id}    IN RANGE    1    5
        ${Dl_throughput} =    Airphone Sa Get Throughput    ue_id=${u_id}    direction=dl
        ${Ul_throughput} =    Airphone Sa Get Throughput    ue_id=${u_id}    direction=ul
    END
    Start GNB Ttitrace With Streaming Mode
    Wait '2s' for stable running
    ${pacp}=    Stop GNB Ttitrace With Streaming Mode    save_path=${save_log}
    Decoder Tttirace From Pcap To Csv    ${pacp}    ${save_log}/tti
    run keyword and continue on failure    spill_value_of_srsswitchmeas    ${save_log}/tti_dl.csv    ${save_log}/target_dl.csv
	#check RT beam works
    run keyword and continue on failure
    ...    check_log_with_au2anlysis    ini_path=${CURDIR}/log_check/G5_case01_tti.ini    log_need_to_check=i
    ...    save_log_directory=${save_log}
    [Teardown]    Stop Collect GNB and AP Syslog in 'Step3_data' File

Step4:Override power of UE1-4 as -96dBm
    Start Collect GNB and AP Syslog in 'Step4' File
    ${save_log}=    Set Variable    ${TEST_LOG_DIRECTORY()}Step4
    Set UE'1' to UE'4' power with profile'1'
	${remaining_time}=    get_counter_file_remaining_time    counter_refresh_period=5min
    Wait Throughput Timer    ${remaining_time}
    Wait Throughput Timer    600s
	${PM_counter_file}=    download_latest_pmcounter    local_path=${TEST_LOG_DIRECTORY()}Step4${/}
	FOR    ${i}    IN RANGE     40     78
	    ${index}     evaluate     "${i}".zfill(2)
	    ${value}     get_counter_value_from_counter_file    counter_file=${PM_counter_file}     counter_id=M55371C001${index}    cell_id=1
	     append to list     ${value_list_level_20}   ${value}
	END
	log    ${value_list_level_20}
	Start GNB Ttitrace With Streaming Mode
    Wait '1s' for stable running
    ${pacp}=    Stop GNB Ttitrace With Streaming Mode    save_path=${save_log}
    Decoder Tttirace From Pcap To Csv    ${pacp}    ${save_log}/tti
    run keyword and continue on failure    spill_value_of_srsswitchmeas    ${save_log}/tti_dl.csv    ${save_log}/target_dl.csv
	Set test Variable	 ${value_level_20} 	${value_list_level_20[19]}
	should be true    ${value_level_20} > 28000
    [Teardown]    Stop Collect GNB and AP Syslog in 'Step4' File

Step5:Override power of UE1-4 as -132dBm
    Start Collect GNB and AP Syslog in 'Step5' File
    ${save_log}=    Set Variable    ${TEST_LOG_DIRECTORY()}Step5
    Set UE'1' to UE'4' power with profile'2'
	${remaining_time}=    get_counter_file_remaining_time    counter_refresh_period=5min
    Wait Throughput Timer    ${remaining_time}
    Wait Throughput Timer    600s
    ${PM_counter_file}=    download_latest_pmcounter    local_path=${TEST_LOG_DIRECTORY()}Step5${/}
	FOR    ${i}    IN RANGE     40     78
	    ${index}     evaluate     "${i}".zfill(2)
	    ${value}     get_counter_value_from_counter_file    counter_file=${PM_counter_file}     counter_id=M55371C001${index}    cell_id=1
	     append to list     ${value_list_level_01}   ${value}
	END
	log    ${value_list_level_01}
#    ${RD_counter_file}   download_latest_pmcounter      ${save_log}/rdcounter.xml.gz     prefix=RD
#    FOR    ${i}    IN RANGE     1     39
#        ${index}     evaluate     "${i}".zfill(2)
#        ${value}     get_counter_value_from_counter_file    ${RD_counter_file}     POWER_WB_SRS_LEVEL_${index}
#         append to list     ${value_list_level_01}   ${value}
#    END
#    log    ${value_list_level_01}
	Capture 2s ttitrace    ${save_log}
	Set test Variable	 ${value_level_01} 	${value_list_level_01[0]}
	should be true    ${value_level_01} > 28000
    [Teardown]    Stop Collect GNB and AP Syslog in 'Step5' File

Step6:Override power of UE1-4 as -79dBm
    Start Collect GNB and AP Syslog in 'Step6' File
    ${save_log}=    Set Variable    ${TEST_LOG_DIRECTORY()}Step6
    Set UE'1' to UE'4' power with profile'3'
	${remaining_time}=    get_counter_file_remaining_time    counter_refresh_period=5min
    Wait Throughput Timer    ${remaining_time}
    Wait Throughput Timer    600s
    ${PM_counter_file}=    download_latest_pmcounter    local_path=${TEST_LOG_DIRECTORY()}Step6${/}
	FOR    ${i}    IN RANGE     40     78
	    ${index}     evaluate     "${i}".zfill(2)
	    ${value}     get_counter_value_from_counter_file    counter_file=${PM_counter_file}     counter_id=M55371C001${index}    cell_id=1
	     append to list     ${value_list_level_28}   ${value}
	END
	log    ${value_list_level_28}
#    ${RD_counter_file}   download_latest_pmcounter      ${save_log}/rdcounter.xml.gz     prefix=RD
#    FOR    ${i}    IN RANGE     1     39
#        ${index}     evaluate     "${i}".zfill(2)
#        ${value}     get_counter_value_from_counter_file    ${RD_counter_file}     POWER_WB_SRS_LEVEL_${index}
#         append to list     ${value_list_level_28}   ${value}
#    END
#    log    ${value_list_level_28}
	Capture 2s ttitrace    ${save_log}
	Set test Variable	 ${value_level_28} 	${value_list_level_28[27]}
	should be true    ${value_level_28} > 28000
    [Teardown]    Stop Collect GNB and AP Syslog in 'Step6' File

Step7:Override port power different of UE1-4 as average power as -101dBm
    Start Collect GNB and AP Syslog in 'Step7' File
    ${save_log}=    Set Variable    ${TEST_LOG_DIRECTORY()}Step7
    Set UE'1' to UE'4' power with profile'4'
	${remaining_time}=    get_counter_file_remaining_time    counter_refresh_period=5min
    Wait Throughput Timer    ${remaining_time}
    Wait Throughput Timer    600s
    ${PM_counter_file}=    download_latest_pmcounter    local_path=${TEST_LOG_DIRECTORY()}Step7${/}
	FOR    ${i}    IN RANGE     40     78
	    ${index}     evaluate     "${i}".zfill(2)
	    ${value}     get_counter_value_from_counter_file    counter_file=${PM_counter_file}     counter_id=M55371C001${index}    cell_id=1
	     append to list     ${value_list_level_17}   ${value}
	END
	log    ${value_list_level_17}
#    ${RD_counter_file}   download_latest_pmcounter      ${save_log}/rdcounter.xml.gz     prefix=RD
#    FOR    ${i}    IN RANGE     1     39
#        ${index}     evaluate     "${i}".zfill(2)
#        ${value}     get_counter_value_from_counter_file    ${RD_counter_file}     POWER_WB_SRS_LEVEL_${index}
#         append to list     ${value_list_level_17}   ${value}
#    END
#    log    ${value_list_level_17}
	Capture 2s ttitrace    ${save_log}
	Set test Variable	 ${value_level_17} 	${value_list_level_17[16]}
	should be true    ${value_level_17} > 28000
    [Teardown]    Stop Collect GNB and AP Syslog in 'Step7' File

Set UE'${ue_id}' to UE'${ue_id_end}' power with profile'${p_id}'
    FOR    ${u_id}    IN RANGE    ${ue_id}    ${ue_id_end}+1
        Run Keyword If  ${p_id}==1   Airphone Execute Egate Command    ${PROFILE1}
        Run Keyword If  ${p_id}==2   Airphone Execute Egate Command    ${PROFILE2}
        Run Keyword If  ${p_id}==3   Airphone Execute Egate Command    ${PROFILE3}
        Run Keyword If  ${p_id}==4   Airphone Execute Egate Command    ${PROFILE4}
        Run Keyword If  ${p_id}==5   Airphone Execute Egate Command    ${PROFILE5}
        Airphone Execute Egate Command    ue_testmode_set_nr id\=${u_id} testmode\=ul_mimo_srs_beam_pos action\=activate profile_id\=${p_id}
        Wait '2s' for stable running
    END

Capture 2s ttitrace
    [Arguments]    ${save_log}
    Start GNB Ttitrace With Streaming Mode
    Wait '1s' for stable running
    ${pacp}=    Stop GNB Ttitrace With Streaming Mode    save_path=${save_log}
    Decoder Tttirace From Pcap To Csv    ${pacp}    ${save_log}/tti
    run keyword and continue on failure    spill_value_of_srsswitchmeas    ${save_log}/tti_dl.csv    ${save_log}/target_dl.csv

Step8:Override UE1-4 to RANK1
    Start Collect GNB and AP Syslog in 'Step8_rank1' File
    ${save_log}=    Set Variable    ${TEST_LOG_DIRECTORY()}Step8_rank1
	FOR    ${u_id}    IN RANGE    1    5
	    airphone_execute_egate_command    ${PROFILE8}
	    airphone_execute_egate_command    ue_testmode_set_nr id\=${u_id} testmode\=csi_override profile_id\=8 action\=activate
	END
	Start GNB Ttitrace With Streaming Mode
    Wait '1s' for stable running
    ${pacp}=    Stop GNB Ttitrace With Streaming Mode    save_path=${save_log}
    Decoder Tttirace From Pcap To Csv    ${pacp}    ${save_log}/tti
    run keyword and continue on failure    spill_value_of_srsswitchmeas    ${save_log}/tti_dl.csv    ${save_log}/target_dl.csv
	${remaining_time}=    get_counter_file_remaining_time    counter_refresh_period=5min
    Wait Throughput Timer    ${remaining_time}
    Wait Throughput Timer    300s
	${PM_counter_file}=    download_latest_pmcounter    local_path=${TEST_LOG_DIRECTORY()}Step8_rank1${/}
	FOR    ${i}    IN RANGE     40     78
	    ${index}     evaluate     "${i}".zfill(2)
	    ${value}     get_counter_value_from_counter_file    counter_file=${PM_counter_file}     counter_id=M55371C001${index}    cell_id=1
	     append to list     ${value_list_level_sb}   ${value}
	END
	log    ${value_list_level_sb}
	run keyword and continue on failure
    ...    check_log_with_au2anlysis    ini_path=${CURDIR}/log_check/G5_case01_tti_sb.ini    log_need_to_check=i
    ...    save_log_directory=${save_log}
    [Teardown]    Stop Collect GNB and AP Syslog in 'Step8_rank1' File
