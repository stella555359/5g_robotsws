*** Settings ***
Documentation     Author: zhaona.jiang@nokia-sbell.com
...
...               QC case full name:
...               CB010602_A_B1_case5_Rank3_8X4_Cell_CSI_RS_SRS_based_beamforming_extension_beamPowerOffsetThreshold_online_change



Suite Setup       Common Suite Setup
Suite Teardown    Common Suite Teardown
Test Setup        Common Test Setup
Test Teardown     Common Test Teardown
Force Tags        CLOUD_5G_I_BOO_AP_KLLL_SANSA_L1B_ECPRI_CMWV_TDD    AP    CRT    SBTS00    RAN_5G_TDD    RAN_5G
Test Timeout      120 minutes
Resource          ../../resources/sg11/internal_resource/robot/modify_configuration.robot
Resource          ../../resources/sg11/internal_resource/robot/internal_gnb_operate.robot
Resource          ../../resources/sg11/internal_resource/robot/internal_ap_operate.robot

*** Variables ***
${UE1_ID}          1
${PDU_ID}         1
${GW_ID}          1
${SLICE_ID}       1
${FILTER1}            ((dldata_pdschsendreql1sw)||(DlData_CsiRsResourceL1sw_t.density==1)) && !(3gpp.rnti == 65535)
${CONFIG_DIR_PATH}    ${CURDIR}/../../resources/sg11/internal_resource/config/
${SCFC_NAME}          gNB_scf_ASIM_ABIP_AEQE_TDD_eCPRI_cmwv_SANSA_1CC_FS.xml
${AIRPHONE_NAME}      AP_iphy_AEQE_LO_AP_LO_TDD_eCPRI_cmwv_SANSA_L1b_1S_1CC_srs_B.xml
${WTS_NAME}           wts_config_ASIL_ABIO_TDD_eCPRI_cmwv_SANSA_L1b_1S_1CC.cfg
@{LOG_NAME_LIST}      gnb_snapshot    sosreport    egatelog\
${actCsirsBeamPowerBalance}                     text|false|//*[@name\="actCsirsBeamPowerBalance"]
${actPdschBeamPowerBalance}                     text|true|//*[@name\="actPdschBeamPowerBalance"]
${beamPowerOffsetThreshold}                     text|6|//*[@name\="beamPowerOffsetThreshold"]
${cell_specific}                                text|false|//*[@name\="actUeCsirsCoexistCellCsirs"]
${chBw}                                         text|100MHz|//*[@name\="chBw"]
${dlMimoMode}                                   text|8x4 Closed Loop Spatial Multiplexing|//*[@name\="dlMimoMode"]
${nrCellType}                                   text|8DL8UL|//*[@name\="nrCellType"]
${actDlSrsBm}                                   text|true|//*[@name\="actDlSrsBm"]
${pucchModeSelect}                              text|longPucch|//*[@name\="pucchModeSelect"]
${frameStructureType}                           text|tdLte|//*[@name\="frameStructureType"]
${guardPeriodLength}                            text|6Symbols|//*[@name\="guardPeriodLength"]
${lteToNrFrameShift}                            text|0ms|//*[@name\="lteToNrFrameShift"]
${prachConfigurationIndex}                      text|97|//*[@name\="prachConfigurationIndex"]
${actBeamforming}                               text|true|//*[@name\="actBeamforming"]
${basicBeamSet}                                 text|beamSet_6|//*[@name\="basicBeamSet"]
${nrBtsBeamRefinementP2}                        text|false|//*[@name\="nrBtsBeamRefinementP2"]
${actDl256Qam}                                  text|true|//*[@name\="actDl256Qam"]
${pattern}    CA_P2_8x4_t2r4_n2
@{title1}    DlData_PdschGrantL1sw.bestBeamPowerOffset    DlData_PdschGrantL1sw.closedLoop3gppCodebook    DlData_PdschGrantL1sw.numOfLayers
...          DlData_PdschGrantL1sw.patternId_item    DlData_CsiRsResourceL1sw_t.patternId_item    DlData_CsiRsResourceL1sw_t.csiBestBeamPowerOffset
...          DlData_CsiRsResourceL1sw_t.csiRsConfig        DlData_CsiRsResourceL1sw_t.density    3gpp.rnti
${profile1}    ul_mimo_srs_beam_pos_nr profile_id=1 mode=fixed init_quad_pos=3 init_sub_quad_pos=0 test_type=SRS multi_path_config=1
...            num_of_nlos_paths=1 azimuth=3 zenith=0 srs_transmit_power_per_port=-400,-400,-500,-500

*** Test Cases ***
CB010602_A_B1_case5_Rank3_8X4_Cell_CSI_RS_SRS_based_beamforming_extension_beamPowerOffsetThreshold_online_change
    Step1: Commission the above configuration on WebUI
    Step2: Attach UE rank=3 send buffer and capture logs
    Step3: online change beamPowerOffsetThreshold to 15
    Step4: online change beamPowerOffsetThreshold to 0
    Step5: online change beamPowerOffsetThreshold to 1


*** Keywords ***
Step1: Commission the above configuration on WebUI
    Start Collect GNB and AP Syslog in 'Step1_before_onair' File
    ${CONFIG_DIR_PATH}    Set Variable    ${CONFIG_DIR_PATH}/${SW_BRANCH}
    ${mod_iphy}    create list     text|advancedSRS|//ulFeatures
    modify xml     ${CONFIG_DIR_PATH}${/}${AIRPHONE_NAME}      ${CONFIG_DIR_PATH}${/}${AIRPHONE_NAME}    ${mod_iphy}
    change_iphy_rru_version    ${CONFIG_DIR_PATH}${/}${AIRPHONE_NAME}
    modify_swconfig_by_CB010602    ${CONFIG_DIR_PATH}${/}${SCFC_NAME}
    ${scfc_path}    Set Variable    ${TEST_LOG_DIRECTORY()}${/}scfc.xml
    copy_file    ${CONFIG_DIR_PATH}/${SCFC_NAME}    ${scfc_path}
    ${modify_list}    create list
    ...       ${actCsirsBeamPowerBalance}    ${actPdschBeamPowerBalance}    ${beamPowerOffsetThreshold}
    ...       ${chBw}    ${dlMimoMode}    ${nrCellType}    ${actDlSrsBm}    ${prachConfigurationIndex}
    ...       ${pucchModeSelect}    ${frameStructureType}    ${guardPeriodLength}    ${lteToNrFrameShift}
    ...       ${actBeamforming}    ${basicBeamSet}    ${nrBtsBeamRefinementP2}    ${actDl256Qam}    ${cell_specific}
    modify_xml    ${scfc_path}    ${scfc_path}    ${modify_list}
    Modify TL VM And AP SCTP Configuration
    Get and Update BSR File    par_of_bsr_name=AEQE_6_H6_ALN60_ARP60_P00_COVERAGE_00424_000
    Perform Full Commission And Reach Onair With Log    ${scfc_path}    ${CONFIG_DIR_PATH}${/}${WTS_NAME}    reset_after_commission=${False}
    [Teardown]    Stop Collect GNB and AP Syslog in 'Step1_before_onair' File

Step2: Attach UE rank=3 send buffer and capture logs
    Start Collect GNB and AP Syslog in 'Step2_attach' File
    Attach SA ue with capability to 5g cell    1    CA_P2_8x4_t2r4_n2
    excute_cmd_for_multi_path
    csi_override_testmode_active    ueid=1    profile_id=1   ri=2
    SA send multiple trf data    ${UE1_ID}    DL    175M    4
    ${save_log}=    Set Variable    ${TEST_LOG_DIRECTORY()}Step2_attach
    Start GNB Ttitrace With Streaming Mode
    Wait Throughput Timer    2
    ${pacp}=    Stop GNB Ttitrace With Streaming Mode    save_path=${save_log}
    Decoder Tttirace From Pcap To Csv    ${pacp}    ${save_log}/tti
    airphone_collect_egate_log_files      ${save_log}   unzip=TRUE
	Start GNB BIP Log
    Wait Throughput Timer    2
    Stop Gnb BIP Log    log_dir=${save_log}
    Convert BIP To CSV    ${save_log}/tcpdump_L2L1_bip_filtering_off.pcap0    ${save_log}/beamPowerOffsetThreshold_6.csv    ${FILTER1}    ${title1}
    Check Log With Au2anlysis    ini_path=${CURDIR}/log_check/bip_case5_beamPowerOffsetThreshold_6.ini     log_need_to_check=i
    ...    save_log_directory=${save_log}
    ${counter_file}    download PM counter file    ${save_log}
    ${BEAM_PWR_OFFSET_RI3_INDEX6}=    get_counter_value_from_counter_file    counter_file=${counter_file}   counter_id=M55305C14007   cell_id=1
    should be true    ${BEAM_PWR_OFFSET_RI3_INDEX6} > 40000
    should be true    ${BEAM_PWR_OFFSET_RI3_INDEX6} < 84001
    [Teardown]    Stop Collect GNB and AP Syslog in 'Step2_attach' File

Step3: online change beamPowerOffsetThreshold to 15
    Start Collect GNB and AP Syslog in 'Step3_beamPowerOffsetThreshold_15' File
    Perform Online Change Parameter Value    MRBTS-1/NRBTS-2/NRCELL-1    beamPowerOffsetThreshold    15    update
    Wait Throughput Timer    10
    ${save_log}=    Set Variable    ${TEST_LOG_DIRECTORY()}Step3_beamPowerOffsetThreshold_15
    Start GNB Ttitrace With Streaming Mode
    Wait Throughput Timer    2
    ${pacp}=    Stop GNB Ttitrace With Streaming Mode    save_path=${save_log}
	Start GNB BIP Log
    Wait Throughput Timer    2
    Stop Gnb BIP Log    log_dir=${save_log}
    Decoder Tttirace From Pcap To Csv    ${pacp}    ${save_log}/tti
    airphone_collect_egate_log_files      ${save_log}   unzip=TRUE
    Convert BIP To CSV    ${save_log}/tcpdump_L2L1_bip_filtering_off.pcap0    ${save_log}/beamPowerOffsetThreshold_15.csv    ${FILTER1}    ${title1}
    Check Log With Au2anlysis    ini_path=${CURDIR}/log_check/bip_case5_beamPowerOffsetThreshold_15.ini     log_need_to_check=i
    ...    save_log_directory=${save_log}
    ${counter_file}    download PM counter file    ${save_log}
    ${BEAM_PWR_OFFSET_RI3_INDEX8}=    get_counter_value_from_counter_file    counter_file=${counter_file}   counter_id=M55305C14009   cell_id=1
    should be true    ${BEAM_PWR_OFFSET_RI3_INDEX8} > 40000
    should be true    ${BEAM_PWR_OFFSET_RI3_INDEX8} < 84001
    [Teardown]    Stop Collect GNB and AP Syslog in 'Step3_beamPowerOffsetThreshold_15' File

Step4: online change beamPowerOffsetThreshold to 0
    Start Collect GNB and AP Syslog in 'Step4_beamPowerOffsetThreshold_0' File
    Perform Online Change Parameter Value    MRBTS-1/NRBTS-2/NRCELL-1    beamPowerOffsetThreshold    0    update
    Wait Throughput Timer    10
    ${save_log}=    Set Variable    ${TEST_LOG_DIRECTORY()}Step4_beamPowerOffsetThreshold_0
    Start GNB Ttitrace With Streaming Mode
    Wait Throughput Timer    2
    ${pacp}=    Stop GNB Ttitrace With Streaming Mode    save_path=${save_log}
    Decoder Tttirace From Pcap To Csv    ${pacp}    ${save_log}/tti
    airphone_collect_egate_log_files      ${save_log}   unzip=TRUE
	Start GNB BIP Log
    Wait Throughput Timer    2
    Stop Gnb BIP Log    log_dir=${save_log}
    Convert BIP To CSV    ${save_log}/tcpdump_L2L1_bip_filtering_off.pcap0    ${save_log}/beamPowerOffsetThreshold_0.csv    ${FILTER1}    ${title1}
    Check Log With Au2anlysis    ini_path=${CURDIR}/log_check/bip_case5_beamPowerOffsetThreshold_0.ini     log_need_to_check=i
    ...    save_log_directory=${save_log}
    ${counter_file}    download PM counter file    ${save_log}
    ${BEAM_PWR_OFFSET_RI3_INDEX0}=    get_counter_value_from_counter_file    counter_file=${counter_file}   counter_id=M55305C14001   cell_id=1
    should be true    ${BEAM_PWR_OFFSET_RI3_INDEX0} > 40000
    should be true    ${BEAM_PWR_OFFSET_RI3_INDEX0} < 84001
    [Teardown]    Stop Collect GNB and AP Syslog in 'Step4_beamPowerOffsetThreshold_0' File

Step5: online change beamPowerOffsetThreshold to 1
    Start Collect GNB and AP Syslog in 'Step5_beamPowerOffsetThreshold_1' File
    Perform Online Change Parameter Value    MRBTS-1/NRBTS-2/NRCELL-1    beamPowerOffsetThreshold    1    update
    Wait Throughput Timer    10
    ${save_log}=    Set Variable    ${TEST_LOG_DIRECTORY()}Step5_beamPowerOffsetThreshold_1
    Start GNB Ttitrace With Streaming Mode
    Wait Throughput Timer    2
    ${pacp}=    Stop GNB Ttitrace With Streaming Mode    save_path=${save_log}
    Decoder Tttirace From Pcap To Csv    ${pacp}    ${save_log}/tti
    airphone_collect_egate_log_files      ${save_log}   unzip=TRUE
	Start GNB BIP Log
    Wait Throughput Timer    2
    Stop Gnb BIP Log    log_dir=${save_log}
    Convert BIP To CSV    ${save_log}/tcpdump_L2L1_bip_filtering_off.pcap0    ${save_log}/beamPowerOffsetThreshold_1.csv    ${FILTER1}    ${title1}
    Check Log With Au2anlysis    ini_path=${CURDIR}/log_check/bip_case5_beamPowerOffsetThreshold_1.ini     log_need_to_check=i
    ...    save_log_directory=${save_log}
    ${counter_file}    download PM counter file    ${save_log}
    ${BEAM_PWR_OFFSET_RI3_INDEX1}=    get_counter_value_from_counter_file    counter_file=${counter_file}   counter_id=M55305C14002   cell_id=1
    should be true    ${BEAM_PWR_OFFSET_RI3_INDEX1} > 40000
    should be true    ${BEAM_PWR_OFFSET_RI3_INDEX1} < 84001
#    ${trace_id}    DCAP start collect log      10.0.1.2        enb_trace_profile=dcap-lite-default      bts_trace_profile=dcap-lite-default
#    DCAP stop collect log    ${trace_id}
    [Teardown]    Stop Collect GNB and AP Syslog in 'Step5_beamPowerOffsetThreshold_1' File


excute_cmd_for_multi_path
    airphone_execute_egate_command    ${profile1}
    airphone_execute_egate_command    ue_testmode_set_nr id\=1 testmode\=ul_mimo_srs_beam_pos action\=activate profile_id\=1
