*** Settings ***
Documentation     Author: xuemin.ma@nokia-sbell.com
...
...               QC case full name:
...               CB008360_C_B1_case_134_IWK with power saving BWP
...               UL MU-MIMO only applies to UE which use larger BWP as active BWP

Suite Setup       Common Suite Setup
#Suite Teardown    Common Suite Teardown
Test Setup        Common Test Setup
Test Teardown     Common Test Teardown
Force Tags        CLOUD_5G_I_BOO_AP_KLLL_SANSA_L1B_ECPRI_CMWV_TDD    AP    CRT    SBTS00    SBTS23R1    
   ...    RAN_5G_TDD    RAN_5G    owner_xueminm
Test Timeout      120 minutes
Resource          ../../resources/sg11/internal_resource/robot/modify_configuration.robot
Resource          ../../resources/sg11/internal_resource/robot/internal_ap_operate.robot
Resource          ../../resources/sg11/internal_resource/robot/internal_gnb_operate.robot
Resource    ../../resources/KISS/robot/common_resource.robot
Resource    ../../resources/sg10/internal_resource/internal_resource.robot
Library     taf.transport.ssh    WITH NAME    TAF_SSH
Library           ta_a2a

*** Variables ***
${CONFIG_DIR_PATH}    ${CURDIR}/../../resources/sg11/internal_resource/config/
${SCFC_NAME}      8360_112_8d8u.xml
${AIRPHONE_NAME}    AP_iphy_AEQE_LO_AP_LO_TDD_eCPRI_cmwv_SANSA_L1b_1S_1CC_srs_B.xml
${WTS_NAME}       wts_config_ASIL_ABIO_TDD_eCPRI_cmwv_SANSA_L1b_1S_1CC.cfg
${COMAVALUE}    ${CURDIR}/../../resources/sg11/internal_resource/config/AP/ap_coma.txt
@{LOG_NAME_LIST}    gnb_snapshot    egatelog
${cellDepType}                                  text|SA+NSA|//*[@name\="cellDepType"]
${chBw}                                         text|100MHz|//*[@name\="chBw"]
${nrarfcn}                                      text|636666|//*[@name\="nrarfcn"]
${gscnOrSsPbchArfcn}                            text|7880|//*[@name\="gscnOrSsPbchArfcn"]
${msg1FrequencyStart}                           text|14|//*[@name\="msg1FrequencyStart"]
${dlMimoMode}                                   text|8x4 Closed Loop Spatial Multiplexing|//*[@name\="dlMimoMode"]
#${dlMimoMode}                                   text|4x4 or 4x2 Closed Loop Spatial Multiplexing|//*[@name\="dlMimoMode"]
${nrCellType}                                   text|8DL8UL|//*[@name\="nrCellType"]
${actUlSrsBm}                                   text|true|//*[@name\="actUlSrsBm"]
${actUlMuMimo}                                  text|true|//*[@name\="actUlMuMimo"]
${ulMaxMuMimoLayer}                             text|4|//*[@name\="ulMaxMuMimoLayer"]
${actUlMuMimoTapering}                          text|false|//*[@name\="actUlMuMimoTapering"]
${ulMinPrbThreshold}                            text|50|//*[@name\="ulMinPrbThreshold"]
${ulMuMimoPrbThresholdAbsolute}                 text|15|//*[@name\="ulMuMimoPrbThresholdAbsolute"]
${ulMuMimoCorrThd}                              text|50|//*[@name\="ulMuMimoCorrThd"]
${ulMuMimoCorrThd2}                              text|45|//*[@name\="ulMuMimoCorrThd2"]
${ulMuMimoSinrThd}                              text|10|//*[@name\="ulMuMimoSinrThd"]
${ulMuMimoSpectralEffThd}                       text|1|//*[@name\="ulMuMimoSpectralEffThd"]
${ulMuMimoLinkAdaptionSwitch}                   text|MU-SINR estimation|//*[@name\="ulMuMimoLinkAdaptionSwitch"]
${frameStructureType}                           text|semiStatic|//*[@name\="frameStructureType"]
${guardPeriodLength}                            text|2Symbols|//*[@name\="guardPeriodLength"]
${ulDlDataSlotRatio}                            text|3/7|//*[@name\="ulDlDataSlotRatio"]
${prachConfigurationIndex}                      text|98|//*[@name\="prachConfigurationIndex"]
${srsUePeriodicity}                             text|slots40|//*[@name\="srsUePeriodicity"]
${cSRS}                                         text|51|//*[@name\="cSRS"]
${bSRS}                                         text|2|//*[@name\="bSRS"]
${actBeamforming}                               text|true|//*[@name\="actBeamforming"]
${basicBeamSet}                                 text|beamSet_6|//*[@name\="basicBeamSet"]
${actPowerSavingBWP}                            text|true|//*[@name\="actPowerSavingBWP"]
${actDynPdcchTdMode}                                text|false|//*[@name\="actDynPdcchTdMode"]
${tiltOffset}                                   text|0|//*[@name\="tiltOffset"]
${ulSinrDiffThreshold}                          text|30|//*[@name\="ulSinrDiffThreshold"]

${pattern}    CA_P2_8x4_t2r4_n2_pusch_1layer

*** Test Cases ***
CB008360_C_B1_case_134_IWK with power saving BWP
    Step1:Commission the above configuration on WebUI
    Step2:Attach 4UEs in different HV
    Step3:Push full buffer in UL
    Step4:Stop data traffic,switch to Power Saving BWP
    Step5:Restart full buffer traffic for UEs

    #get_bip
    #get_tti
*** Keywords ***
get_bip
	Start collect bip log
    Wait for '2s' to stop bip log with name'BIP'
get_tti
	Start collect ttitrace
	Wait for '2s' to stop ttitrace with name'tti_4UE'
	run keyword and continue on failure    reorder_csv_CB008360   ${TEST_LOG_DIRECTORY()}/All/tti_4UE_ul.csv

Step1:Commission the above configuration on WebUI
    Start Collect GNB and AP Syslog in 'Step1_before_onair' File
    ${CONFIG_DIR_PATH}    Set Variable    ${CONFIG_DIR_PATH}/${SW_BRANCH}
    change_iphy_rru_version    ${CONFIG_DIR_PATH}${/}${AIRPHONE_NAME}
    #Airphone Download L1ByPTestModeConfiguration from ABIL    ${test_log_directory()}/L1ByPTestModeConfiguration.xml
    #Set Pos By Modify L1ByPTestModeConfiguration    4    0    4    0    4    0    4    0    0
    #Set Pos By Modify L1ByPTestModeConfiguration    20    0    2    0    2    0    2    0    1
    #Set Pos By Modify L1ByPTestModeConfiguration    14    0    25    0    25    0    25    0    2
    #Set Pos By Modify L1ByPTestModeConfiguration    10    0    25    0    25    0    25    0    3
    #Airphone Upload L1ByPTestModeConfiguration to ASIK    ${test_log_directory()}/L1ByPTestModeConfiguration.xml
    modify_swconfig_by_CB008360    ${CONFIG_DIR_PATH}${/}${SCFC_NAME}
    ${scfc_path}    Set Variable    ${TEST_LOG_DIRECTORY()}${/}scfc.xml
    copy_file    ${CONFIG_DIR_PATH}/${SCFC_NAME}    ${scfc_path}
    del_elements_from_xml    xml_path=${scfc_path}    parameter=lteToNrFrameShift
   add_bwplist_list_in_cells    ${scfc_path}
    add_bwplist_list_in_cells_new    ${scfc_path}    key_5
    ${modify_list}    create list
    ...       ${cellDepType}    ${chBw}    ${msg1FrequencyStart}    ${dlMimoMode}
    ...       ${nrCellType}    ${actUlSrsBm}    ${actUlMuMimo}    ${ulMaxMuMimoLayer}    ${ulMinPrbThreshold}
    ...       ${ulMuMimoPrbThresholdAbsolute}    ${ulMuMimoCorrThd}    ${ulMuMimoSinrThd}    ${ulMuMimoSpectralEffThd}
    ...       ${ulMuMimoLinkAdaptionSwitch}    ${frameStructureType}    ${guardPeriodLength}    ${ulDlDataSlotRatio}
    ...       ${prachConfigurationIndex}    ${srsUePeriodicity}    ${cSRS}    ${bSRS}    ${actBeamforming}    ${basicBeamSet}
    ...       ${actUlMuMimoTapering}    ${actPowerSavingBWP}    ${actUlMuMimoTapering}
    ...       ${tiltOffset}    ${ulSinrDiffThreshold}    ${ulMuMimoCorrThd2}    ${actDynPdcchTdMode}    
    ...       ${nrarfcn}    ${gscnOrSsPbchArfcn}
    modify_xml    ${scfc_path}    ${scfc_path}    ${modify_list}
    Modify TL VM And AP SCTP Configuration
    Get and Update BSR File    par_of_bsr_name=AEQE_6_H6_ALN60_ARP60_P00_COVERAGE_00424_00001
    Perform Full Commission And Reach Onair With Log    ${scfc_path}    ${CONFIG_DIR_PATH}${/}${WTS_NAME}    reset_after_commission=${False}
    [Teardown]    Stop Collect GNB and AP Syslog in 'Step1_before_onair' File

Step2:Attach 4UEs in different HV
    Start Collect GNB and AP Syslog in 'Step2_attach' File
    #Start GNB BIP Log
    FOR    ${u_id}    IN RANGE   1    5
        ${ue_capability}    Obtain Ue Capability    ${pattern}
        airphone_execute_egate_command    ue_register id\=${u_id} ue_nr_capabilities\=${ue_capability}
        Wait Throughput Timer    3
        airphone_execute_egate_command    set_pdu_param ue\=${u_id} pdu\=1 trf_type\=internal
        Wait Throughput Timer    3
        airphone_execute_egate_command    ue_pdu_session_setup pdu\=1 ue\=${u_id} nwslice\=1 gw\=${u_id}
        Wait Throughput Timer    5
    END	
    airphone_execute_egate_command
    ...    ul_mimo_srs_beam_pos_nr profile_id\=1 mode\=fixed init_quad_pos\=3 init_sub_quad_pos\=2 step\=10 trigger_puxch_update\=0
    airphone_execute_egate_command    ue_testmode_set_nr id\=1 testmode\=ul_mimo_srs_beam_pos action\=activate profile_id\=1 scell\=0
    airphone_execute_egate_command
    ...    ul_mimo_srs_beam_pos_nr profile_id\=2 mode\=fixed init_quad_pos\=2 init_sub_quad_pos\=2 step\=10 trigger_puxch_update\=0
    airphone_execute_egate_command    ue_testmode_set_nr id\=2 testmode\=ul_mimo_srs_beam_pos action\=activate profile_id\=2 scell\=0
    airphone_execute_egate_command
    ...    ul_mimo_srs_beam_pos_nr profile_id\=5 mode\=fixed init_quad_pos\=0 init_sub_quad_pos\=0 step\=10 trigger_puxch_update\=0
    airphone_execute_egate_command    ue_testmode_set_nr id\=4 testmode\=ul_mimo_srs_beam_pos action\=activate profile_id\=5 scell\=0
    airphone_execute_egate_command
    ...    ul_mimo_srs_beam_pos_nr profile_id\=10 mode\=fixed init_quad_pos\=1 init_sub_quad_pos\=0 step\=10 trigger_puxch_update\=0
    airphone_execute_egate_command    ue_testmode_set_nr id\=3 testmode\=ul_mimo_srs_beam_pos action\=activate profile_id\=10 scell\=0
    #Stop Gnb BIP Log    log_dir=${TEST_LOG_DIRECTORY()}${/}Step2_attach${/}
    airphone_collect_egate_log_files      ${TEST_LOG_DIRECTORY()}${/}Step2_attach${/}   unzip=TRUE
    check_log_with_au2anlysis    ini_path=${CURDIR}/log_check/case134_rrc_Attach_PS_bwp.ini    log_need_to_check=u
    ...    save_log_directory=${TEST_LOG_DIRECTORY()}${/}Step2_attach${/}
    ${rnti_list}    file match all   ${TEST_LOG_DIRECTORY()}${/}Step2_attach${/}/egate_console.log.001   crnti: (\\d+)
    Set test Variable    ${rnti_1}    ${rnti_list[0]}
    Set test Variable    ${rnti_2}    ${rnti_list[1]}
    Set test Variable    ${rnti_3}    ${rnti_list[2]}
    Set test Variable    ${rnti_4}    ${rnti_list[3]}
    [Teardown]    Stop Collect GNB and AP Syslog in 'Step2_attach' File

Step3:Push full buffer in UL
    Start Collect GNB and AP Syslog in 'Step3_data' File
    #Start GNB BIP Log
    FOR    ${u_id}    IN RANGE   1    5
        Airphone SA Start Data Traffic    ${u_id}    UL    170M    trf_id=1    pdu_id=1    duration=${3600}
        Airphone SA Start Data Traffic    ${u_id}    UL    170M    trf_id=2    pdu_id=1    duration=${3600}
    END
    Wait Throughput Timer    5
    #Stop Gnb BIP Log    log_dir=${TEST_LOG_DIRECTORY()}${/}Step3_data${/}
    Start GNB Ttitrace With Streaming Mode
    Wait Throughput Timer    5
    ${pacp}=    Stop GNB Ttitrace With Streaming Mode    save_path=${TEST_LOG_DIRECTORY()}${/}Step3_data${/}
    Decoder Tttirace From Pcap To Csv    ${pacp}    ${TEST_LOG_DIRECTORY()}${/}Step3_data${/}tti
    run keyword and continue on failure    check_log_with_au2anlysis    ini_path=${CURDIR}/log_check/case134_tti_paired_FS.ini    
    ...    log_need_to_check=i
    ...    save_log_directory=${TEST_LOG_DIRECTORY()}${/}Step3_data${/}
    [Teardown]    Stop Collect GNB and AP Syslog in 'Step3_data' File

Step4:Stop data traffic,switch to Power Saving BWP
    Start Collect GNB and AP Syslog in 'Step4_stop_buffer' File
    FOR    ${u_id}    IN RANGE   1    5
        airphone_execute_egate_command    trf_data_stop ue\=${u_id} pdu\=1 qfi\=1 dir\=ul
    END
    Wait Throughput Timer    3
    Start GNB Ttitrace With Streaming Mode
    Wait Throughput Timer    2
    ${pacp}=    Stop GNB Ttitrace With Streaming Mode    save_path=${TEST_LOG_DIRECTORY()}${/}Step4_stop_buffer${/}
    Decoder Tttirace From Pcap To Csv    ${pacp}    ${TEST_LOG_DIRECTORY()}${/}Step4_stop_buffer${/}tti_stop_data
    run keyword and continue on failure    check_log_with_au2anlysis    ini_path=${CURDIR}/log_check/case134_tti_PS_BWP_pairneedless_FS.ini
    ...    log_need_to_check=i    save_log_directory=${TEST_LOG_DIRECTORY()}${/}Step4_stop_buffer${/}
    [Teardown]    Stop Collect GNB and AP Syslog in 'Step4_stop_buffer' File

Step5:Restart full buffer traffic for UEs
    Start Collect GNB and AP Syslog in 'Step5_restart_data' File
    #Start GNB BIP Log
    airphone_execute_egate_command
    ...    ul_mimo_srs_beam_pos_nr profile_id\=1 mode\=fixed init_quad_pos\=3 init_sub_quad_pos\=2 step\=10 trigger_puxch_update\=0
    airphone_execute_egate_command    ue_testmode_set_nr id\=1 testmode\=ul_mimo_srs_beam_pos action\=activate profile_id\=1 scell\=0
    airphone_execute_egate_command
    ...    ul_mimo_srs_beam_pos_nr profile_id\=2 mode\=fixed init_quad_pos\=2 init_sub_quad_pos\=2 step\=10 trigger_puxch_update\=0
    airphone_execute_egate_command    ue_testmode_set_nr id\=2 testmode\=ul_mimo_srs_beam_pos action\=activate profile_id\=2 scell\=0
    airphone_execute_egate_command
    ...    ul_mimo_srs_beam_pos_nr profile_id\=5 mode\=fixed init_quad_pos\=0 init_sub_quad_pos\=0 step\=10 trigger_puxch_update\=0
    airphone_execute_egate_command    ue_testmode_set_nr id\=4 testmode\=ul_mimo_srs_beam_pos action\=activate profile_id\=5 scell\=0
    airphone_execute_egate_command
    ...    ul_mimo_srs_beam_pos_nr profile_id\=10 mode\=fixed init_quad_pos\=1 init_sub_quad_pos\=0 step\=10 trigger_puxch_update\=0
    airphone_execute_egate_command    ue_testmode_set_nr id\=3 testmode\=ul_mimo_srs_beam_pos action\=activate profile_id\=10 scell\=0
    FOR    ${u_id}    IN RANGE   1    5
        Airphone SA Start Data Traffic    ${u_id}    UL    170M    trf_id=1    pdu_id=1    duration=${3600}
        Airphone SA Start Data Traffic    ${u_id}    UL    170M    trf_id=2    pdu_id=1    duration=${3600}
    END
    Wait Throughput Timer    5
    #Stop Gnb BIP Log    log_dir=${TEST_LOG_DIRECTORY()}${/}Step5_restart_data${/}
    Start GNB Ttitrace With Streaming Mode
    Wait Throughput Timer    5
    ${pacp}=    Stop GNB Ttitrace With Streaming Mode    save_path=${TEST_LOG_DIRECTORY()}${/}Step5_restart_data${/}
    Decoder Tttirace From Pcap To Csv    ${pacp}    ${TEST_LOG_DIRECTORY()}${/}Step5_restart_data${/}tti
    run keyword and continue on failure    check_log_with_au2anlysis    ini_path=${CURDIR}/log_check/case134_tti_paired_FS.ini    
    ...    log_need_to_check=i
    ...    save_log_directory=${TEST_LOG_DIRECTORY()}${/}Step5_restart_data${/}
    [Teardown]    Stop Collect GNB and AP Syslog in 'Step5_restart_data' File
