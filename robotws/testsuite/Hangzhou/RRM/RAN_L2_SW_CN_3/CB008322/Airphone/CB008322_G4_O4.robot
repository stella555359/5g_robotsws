*** Settings ***
Documentation     Author: mao.qin@nokia-sbell.com
...
...               QC case full name:
...               CB008322_G4_case003_beam_fallback_basedon_SINR_measurement
...               CB008322_O4_case001_performance_Monitor_for_high_percentage_of_BWV_failure
...               CB008322_O4_case003_performance_Monitor_for_WB_SB_SRS_Toggle
...

Suite Setup       Common Suite Setup
Suite Teardown    Common Suite Teardown
Test Setup        Common Test Setup
Test Teardown     Common Test Teardown
Force Tags        CLOUD_5G_I_LO_AP_LO    AP    CRT    SBTS00    RAN_5G_TDD    RAN_5G    owner_mqin
Test Timeout      120 minutes
Resource          ../../resources/sg11/internal_resource/robot/modify_configuration.robot
Resource          ../../resources/sg11/internal_resource/robot/internal_ap_operate.robot
Resource          ../../resources/sg11/internal_resource/robot/internal_gnb_operate.robot
Resource          ../../resources/sg11/internal_resource/robot/internal_capture_log.robot
Library           taf.transport.ssh    WITH NAME    TAF_SSH
Library           ta_a2a

*** Variables ***
${CONFIG_DIR_PATH}    ${CURDIR}/../../resources/sg11/internal_resource/config/
${SCFC_NAME}          scfc_CB008322_G4_O4.xml
${AIRPHONE_NAME}      AP_iphy_AQQL_ASIL_ABIO_TDD_eCPRI_cmwv_SANSA_FS_1S_1CC_BOAM.xml
${WTS_NAME}           wts_config_ASIL_ABIO_TDD_eCPRI_cmwv_SANSA_FS_1S_1CC_UEs.cfg
@{LOG_NAME_LIST}      egatelog\    ap_snapshot    gnb_snapshot
#sosreport
${chBw}                           text|40MHz|//*[@name\="chBw"]
${prbRatioThreshold}              text|10|//*[@name\="prbRatioThreshold"]
${srsPowerThresholdForDlBm}       text|-1320|//*[@name\="srsPowerThresholdForDlBm"]
${par_of_bsr_name}                BSR_AQQL_6_H6_ALN60_ARP60_P11_COVERAGE_00776_00001
${pattern1}                       CA_P2_8x4_t2r4_n2
${pattern2}                       CA_P2_8x4_t1r4_n1
${pattern3}                       CA_P2_8x4_t4r4_n4
${pattern4}                       CA_P2_8x4_noTas_n2
${PROFILE1}    ul_mimo_srs_beam_pos_nr profile_id=1 mode=fixed init_quad_pos=1 init_sub_quad_pos=1 test_type=SRS
...        multi_path_config=true num_of_nlos_paths=1 azimuth=30 zenith=0 srs_transmit_power_per_port=-200,-200,-200,-200
${PROFILE2}    ul_mimo_srs_beam_pos_nr profile_id=2 mode=fixed init_quad_pos=1 init_sub_quad_pos=1 test_type=SRS
...        multi_path_config=true num_of_nlos_paths=1 azimuth=30 zenith=0 srs_transmit_power_per_port=-300,-300,-300,-300
${PROFILE3}    ul_mimo_srs_beam_pos_nr profile_id=3 mode=fixed init_quad_pos=1 init_sub_quad_pos=1 test_type=SRS
...        multi_path_config=true num_of_nlos_paths=1 azimuth=30 zenith=0 srs_transmit_power_per_port=-550,-550,-550,-550

${SET_PROFILE1}    ue_testmode_set_nr id=1 testmode=ul_mimo_srs_beam_pos action=activate profile_id=1

*** Test Cases ***
CB008322_G4_case003_beam_fallback_basedon_SINR_measurement
    Step1:Commission the above configuration on WebUI
    Step2:UEs attach to cell1 and send data
    Step3:UE1 swith to SBSRS due to BWV failures
    Step4:UE2 switch to SBSRS due to maxWbSbSwitch
    Step5:Set SINR lower than srsSinrThreshold add 2dB
    Step6:Check PM counters
    Step7:Detach UEs
    Step8:Change combPolicy

*** Keywords ***
Step1:Commission the above configuration on WebUI
    Start capture GNB and AP Syslog in 'Step1_before_onair' File
    ${CONFIG_DIR_PATH}    Set Variable    ${CONFIG_DIR_PATH}/${SW_BRANCH}
    #${mod_iphy}    create list     text|2|//NumberOfSubCellsDL
    #modify xml     ${CONFIG_DIR_PATH}${/}${AIRPHONE_NAME}      ${CONFIG_DIR_PATH}${/}${AIRPHONE_NAME}    ${mod_iphy}
    change_iphy_rru_version    ${CONFIG_DIR_PATH}${/}${AIRPHONE_NAME}
    modify_swconfig_by_CB008322    ${CONFIG_DIR_PATH}${/}${SCFC_NAME}
    ${scfc_path}    Set Variable    ${TEST_LOG_DIRECTORY()}${/}scfc.xml
    copy_file    ${CONFIG_DIR_PATH}/${SCFC_NAME}    ${scfc_path}
    #add_xml_element     ${scfc_path}    ${scfc_path}     <p name="lteToNrFrameShift">3ms</p>|//*[@name\='tddFrameStructure']/item
    #add_xml_element     ${scfc_path}    ${scfc_path}     <p name="tdLteUlDlConfig">tdLteConfig2</p>|//*[@name\='tddFrameStructure']/item
    #del_elements_from_xml    xml_path=${scfc_path}    parameter=lteToNrFrameShift
    #del_elements_from_xml    xml_path=${scfc_path}    parameter=tdLteUlDlConfig
    #add_bwplist_list_in_cells_new    ${scfc_path}    key_3
    ${modify_list}    create list
    ...    ${chBw}
    ...    ${prbRatioThreshold}
    ...    ${srsPowerThresholdForDlBm}
    modify_xml    ${scfc_path}    ${scfc_path}    ${modify_list}
    Modify TL VM And AP SCTP Configuration
    Get and Update BSR File    ${par_of_bsr_name}
    #Add L2PS Deubg Logs
    Perform Full Commission And Reach Onair With Log    ${scfc_path}    ${CONFIG_DIR_PATH}${/}${WTS_NAME}    reset_after_commission=${False}
    [Teardown]    Stop capture GNB and AP Syslog in 'Step1_before_onair' File

Step2:UEs attach to cell1 and send data
    Start capture GNB and AP Syslog in 'Step2_attach' File
    Wait '5s' for stable running
    FOR    ${i}    IN RANGE    1    5
        Attach UE to cell    ${i}    ${pattern1}
        Set UEi position    ${i}
    END
    airphone_collect_egate_log_files      ${TEST_LOG_DIRECTORY()}${/}Step2_attach${/}   unzip=TRUE
    ${rnti_list}    file match all   ${TEST_LOG_DIRECTORY()}${/}Step2_attach${/}/egate_console.log.001   crnti: (\\d+)
    #${rnti_list}    file match all   ${TEST_LOG_DIRECTORY()}${/}Step2_attach${/}/egate_console.log.001   newUE-Identity (\\d+)
    Set test Variable	 ${rnti_1} 	${rnti_list[0]}
    Set test Variable	 ${rnti_2} 	${rnti_list[1]}
    Set test Variable	 ${rnti_3} 	${rnti_list[2]}
    Set test Variable	 ${rnti_4} 	${rnti_list[3]}
    FOR    ${i}    IN RANGE    1    5
        Send trf for UE    ${i}    dl    100M    2
        Send trf for UE    ${i}    ul    50M    1
    END
    Wait '10s' for stable running
    #Start GNB BIP Log
    ${save_log}=    Set Variable    ${TEST_LOG_DIRECTORY()}Step2_attach
    Start GNB Ttitrace With Streaming Mode
    Wait '1.5s' for stable running
    ${pacp}=    Stop GNB Ttitrace With Streaming Mode    save_path=${save_log}
    #Stop Gnb BIP Log    log_dir=${TEST_LOG_DIRECTORY()}${/}Step2_attach${/}
    Decoder Tttirace From Pcap To Csv    ${pacp}    ${save_log}/tti
    run keyword and continue on failure
    ...    check_log_with_au2anlysis    ini_path=${CURDIR}/log_check/CB008322_G4_O4_step2_tti.ini    log_need_to_check=i
    ...    save_log_directory=${save_log}
    run keyword and continue on failure    spill_value_of_srsswitchmeas    ${save_log}/tti_dl.csv    ${save_log}/target_dl.csv
    #run keyword and continue on failure    split_value_of_bwv_response  ${save_log}/target_dl.csv    ${save_log}/target_bwv.csv
    [Teardown]    Stop capture GNB and AP Syslog in 'Step2_attach' File

Step3:UE1 swith to SBSRS due to BWV failures
    Start capture GNB and AP Syslog in 'Step3_UE1_switch' File
    Set UEi position bad2    1
    Wait '10s' for stable running
    #Start GNB BIP Log
    ${save_log}=    Set Variable    ${TEST_LOG_DIRECTORY()}Step3_UE1_switch
    Start GNB Ttitrace With Streaming Mode
    Wait '1.5s' for stable running
    ${pacp}=    Stop GNB Ttitrace With Streaming Mode    save_path=${save_log}
    #Stop Gnb BIP Log    log_dir=${TEST_LOG_DIRECTORY()}${/}Step3_UE1_switch${/}
    Decoder Tttirace From Pcap To Csv    ${pacp}    ${save_log}/tti
    run keyword and continue on failure    spill_value_of_srsswitchmeas    ${save_log}/tti_dl.csv    ${save_log}/target_dl.csv
    #run keyword and continue on failure    split_value_of_bwv_response  ${save_log}/target_dl.csv    ${save_log}/target_bwv.csv
    run keyword and continue on failure
    ...    check_log_with_au2anlysis    ini_path=${CURDIR}/log_check/CB008322_G4_O4_step3_tti.ini    log_need_to_check=i
    ...    save_log_directory=${save_log}
    [Teardown]    Stop capture GNB and AP Syslog in 'Step3_UE1_switch' File

Step4:UE2 switch to SBSRS due to maxWbSbSwitch
    Start capture GNB and AP Syslog in 'Step4_UE2_switch' File
    Set UEi position    1
    Wait '100s' for stable running
    Override UEi to DL RANKj and CQIk     2    0    15
    Wait '1s' for stable running
    Override UEi to DL RANKj and CQIk    2    3    15
    Wait '1s' for stable running
    Override UEi to DL RANKj and CQIk     2    0    15
    Wait '1s' for stable running
    Override UEi to DL RANKj and CQIk    2    3    15
    Wait '1s' for stable running
    Override UEi to DL RANKj and CQIk     2    0    15
    Wait '1s' for stable running
    Override UEi to DL RANKj and CQIk    2    3    15
    Wait '1s' for stable running
    Override UEi to DL RANKj and CQIk     2    0    15
    Wait '1s' for stable running
    Override UEi to DL RANKj and CQIk    2    3    15
    #Start GNB BIP Log
    ${save_log}=    Set Variable    ${TEST_LOG_DIRECTORY()}Step4_UE2_switch
    Start GNB Ttitrace With Streaming Mode
    Wait '1s' for stable running
    ${pacp}=    Stop GNB Ttitrace With Streaming Mode    save_path=${save_log}
    #Stop Gnb BIP Log    log_dir=${TEST_LOG_DIRECTORY()}${/}Step4_UE2_switch${/}
    Decoder Tttirace From Pcap To Csv    ${pacp}    ${save_log}/tti
    run keyword and continue on failure    spill_value_of_srsswitchmeas    ${save_log}/tti_dl.csv    ${save_log}/target_dl.csv
    #run keyword and continue on failure    split_value_of_bwv_response  ${save_log}/target_dl.csv    ${save_log}/target_bwv.csv
    run keyword and continue on failure
    ...    check_log_with_au2anlysis    ini_path=${CURDIR}/log_check/CB008322_G4_O4_step4_tti.ini    log_need_to_check=i
    ...    save_log_directory=${save_log}
    [Teardown]    Stop capture GNB and AP Syslog in 'Step4_UE2_switch' File

Step5:Set SINR lower than srsSinrThreshold add 2dB
    Start capture GNB and AP Syslog in 'Step5_UE3_DFT_used' File
    Set UEi position    2
    Wait '100s' for stable running
    airphone_execute_egate_command    ul_cell_noise_testmode_nr profile_id\=1 noise_srs\=-300
    airphone_execute_egate_command    cell_testmode_set_nr cell_id\=1 gnb\=2 testmode\=ul_cell_noise profile_id\=1 action\=activate
    Set UEi position bad    3
    Wait '5s' for stable running
    #Start GNB BIP Log
    ${save_log}=    Set Variable    ${TEST_LOG_DIRECTORY()}Step5_UE3_DFT_used
    Start GNB Ttitrace With Streaming Mode
    Wait '1.5s' for stable running
    ${pacp}=    Stop GNB Ttitrace With Streaming Mode    save_path=${save_log}
    #Stop Gnb BIP Log    log_dir=${TEST_LOG_DIRECTORY()}${/}Step5_UE3_DFT_used${/}
    Decoder Tttirace From Pcap To Csv    ${pacp}    ${save_log}/tti
	run keyword and continue on failure    spill_value_of_srsswitchmeas    ${save_log}/tti_dl.csv    ${save_log}/target_dl.csv
	run keyword and continue on failure
    ...    check_log_with_au2anlysis    ini_path=${CURDIR}/log_check/CB008322_G4_O4_step5_tti.ini    log_need_to_check=i
    ...    save_log_directory=${save_log}
    [Teardown]    Stop capture GNB and AP Syslog in 'Step5_UE3_DFT_used' File

Step6:Check PM counters
    Start capture GNB and AP Syslog in 'Step6_Check_counters' File
    airphone_execute_egate_command    cell_testmode_set_nr cell_id\=1 gnb\=2 testmode\=ul_cell_noise profile_id\=1 action\=deactivate
    Set UEi position    3
    Wait '100s' for stable running
    ${PM_counter_file}=    download_latest_pmcounter    local_path=${TEST_LOG_DIRECTORY()}conter_files${/}
    ${PM_counter_DL_value}=    get_counter_value_from_counter_file
    ...   counter_file=${PM_counter_file}
    ...   counter_id=M55309C12001
    ...   cell_id=1
    ${DL_throughput}    evaluate    ${PM_counter_DL_value}*8/1024/1024
    ${PM_counter_UL_value}=    get_counter_value_from_counter_file
    ...   counter_file=${PM_counter_file}
    ...   counter_id=M55309C12002
    ...   cell_id=1
    ${UL_throughput}    evaluate    ${PM_counter_UL_value}*8/1024/1024
    ${PM_counter_DFT_UEs_value}=    get_counter_value_from_counter_file
    ...   counter_file=${PM_counter_file}
    ...   counter_id=M55196C00011
    ...   cell_id=1
    ${PM_counter_SUBBAND_UEs_value}=    get_counter_value_from_counter_file
    ...   counter_file=${PM_counter_file}
    ...   counter_id=M55196C00012
    ...   cell_id=1
    run keyword and continue on failure    should be true    ${DL_throughput}>350
    run keyword and continue on failure    should be true    ${UL_throughput}>80
    #run keyword and continue on failure    should be true    ${PM_counter_DFT_UEs_value}==0
    run keyword and continue on failure    should be true    ${PM_counter_SUBBAND_UEs_value}==4
    #Start GNB BIP Log
    ${save_log}=    Set Variable    ${TEST_LOG_DIRECTORY()}Step6_Check_counters
    Start GNB Ttitrace With Streaming Mode
    Wait '1.5s' for stable running
    ${pacp}=    Stop GNB Ttitrace With Streaming Mode    save_path=${save_log}
    #Stop Gnb BIP Log    log_dir=${TEST_LOG_DIRECTORY()}${/}Step6_Check_counters${/}
    Decoder Tttirace From Pcap To Csv    ${pacp}    ${save_log}/tti
    [Teardown]    Stop capture GNB and AP Syslog in 'Step6_Check_counters' File


Step7:Detach UEs
    Start capture GNB and AP Syslog in 'Step7_detach' File
    FOR    ${i}    IN RANGE    1    5
        Airphone Sa Stop Data Traffic    ${i}    dl
        Detach UE    ${i}
    END
    [Teardown]    Stop capture GNB and AP Syslog in 'Step7_detach' File

Step8:Change combPolicy
    Start capture GNB and AP Syslog in 'Step8_combPolicy2' File
    Online recommissioning with delta json file    ${CURDIR}/JSON/CB008322_G4_O4_combPolicy.json
    Wait '300s' for stable running
    FOR    ${i}    IN RANGE    1    5
        Attach UE to cell    ${i}    ${pattern1}
        Set UEi position    ${i}
        Send trf for UE    ${i}    dl    100M    2
        Send trf for UE    ${i}    ul    50M    1
    END
    Wait '300s' for stable running
    ${save_log}=    Set Variable    ${TEST_LOG_DIRECTORY()}Step8_combPolicy2
    Start GNB Ttitrace With Streaming Mode
    Wait '1.5s' for stable running
    ${pacp}=    Stop GNB Ttitrace With Streaming Mode    save_path=${save_log}
    Decoder Tttirace From Pcap To Csv    ${pacp}    ${save_log}/tti
    run keyword and continue on failure
    ...    check_log_with_au2anlysis    ini_path=${CURDIR}/log_check/CB008322_G4_O4_step2_tti.ini    log_need_to_check=i
    ...    save_log_directory=${save_log}
    [Teardown]    Stop capture GNB and AP Syslog in 'Step8_combPolicy2' File

Attach UE to cell
    [Arguments]    ${ue_id}    ${pattern}
    ${ue_ability}    Obtain Ue Capability    ${pattern}
    ${attach_status}=    run keyword and return status    Airphone SA Attach    ue_id=${ue_id}    timeout=60    ue_capability=${ue_ability}
    Run Keyword If    '${attach_status}'=='False'    Airphone SA Attach    ue_id=${ue_id}    timeout=60    ue_capability=${ue_ability}
    airphone_set_traffic_type    ${ue_id}    1    internal
    ${pdu_status}=    run keyword and return status    Airphone Pdu Session Setup    ${ue_id}    1    1    ${ue_id}
    ${newNum}=    evaluate    ${ue_id}+8
    Run Keyword If    '${pdu_status}'=='False'    Airphone Pdu Session Setup    ${ue_id}    1    1    ${ue_id}
    Wait '2s' for stable running

Send trf for UE
    [Arguments]    ${ue_id}    ${DLorUL}    ${mbps}    ${number}
    FOR    ${num}    IN RANGE    1    ${number}+1
        Airphone SA Start Data Traffic    ${ue_id}    ${DLorUL}    ${mbps}    pdu_id=1    duration=3600s    trf_id=${num}
    END

Stop UE DL Traffic
    [Arguments]    ${ue_id}
    airphone_sa_stop_data_traffic    ${ue_id}    DL

Detach UE
    [Arguments]    ${ue_id}
    airphone_sa_detach    ue_id=${ue_id}    timeout=30

Override UEi to DL RANKj and CQIk
    [Arguments]    ${ue_id}    ${ranki}    ${cqii}
    airphone_execute_egate_command
   	...    csi_override_testmode_nr profile_id\=${ue_id} ri_mode\=fixed ri\=${ranki} cqi_mode\=fixed cqi\=${cqii}
    airphone_execute_egate_command
    ...    ue_testmode_set_nr id\=${ue_id} testmode\=csi_override action\=activate profile_id\=${ue_id}

Set UEi position
    [Arguments]    ${ue_id}
    airphone_execute_egate_command    ${PROFILE1}
    airphone_execute_egate_command
    ...    ue_testmode_set_nr id\=${ue_id} testmode\=ul_mimo_srs_beam_pos action\=activate profile_id\=1

Set UEi position bad
    [Arguments]    ${ue_id}
    airphone_execute_egate_command    ${PROFILE2}
    airphone_execute_egate_command
    ...    ue_testmode_set_nr id\=${ue_id} testmode\=ul_mimo_srs_beam_pos action\=activate profile_id\=2

Set UEi position bad2
    [Arguments]    ${ue_id}
    airphone_execute_egate_command    ${PROFILE3}
    airphone_execute_egate_command
    ...    ue_testmode_set_nr id\=${ue_id} testmode\=ul_mimo_srs_beam_pos action\=activate profile_id\=3

Change Cell SRS SINR
    [Arguments]    ${noise_num}
    airphone_execute_egate_command    ul_cell_noise_testmode_nr profile_id\=1 noise_srs\=${noise_num}
    airphone_execute_egate_command    cell_testmode_set_nr cell_id\=1 gnb\=2 testmode\=ul_cell_noise profile_id\=1 action\=activate

Add L2PS Deubg Logs
    ${debuglogs}    create list    level=DBG\n    L2.L2_PS.DEBUG=1\n    L2.L2_PS.DL.SUBBAND_BEAMFORMING=1\n    L2.L2_PS.SRS_BASED_BM=1\n
    Active L2ps Feature Debug Traces    ${debuglogs}
    TAF_SSH.connect to    192.168.255.1   toor4nsn    oZPS0POrRieRtu   alias=bsh
    TAF_SSH.execute    rm /ffs/run/HashContainer*    connection=bsh

Block Cell1
    COAM.Connect To    bts_host=192.168.255.129    bts_port=443    use_ssl=True    name=online
    COAM.perform_parameter_recommissioning    dist_name=MRBTS-1/NRBTS-1/NRCELL-1    parameter=administrativeState
    ...    operation=update    value=Locked    skip_parameter_relation_errors=True    should_activate=True    connection=online
    #Wait until keyword succeeds    600s    30s    Verify BTS Is Onair
    COAM.teardown admin    connection=online

Unlock Cell1
    COAM.Connect To    bts_host=192.168.255.129    bts_port=443    use_ssl=True    name=online
    COAM.perform_parameter_recommissioning    dist_name=MRBTS-1/NRBTS-1/NRCELL-1    parameter=administrativeState
    ...    operation=update    value=Unlocked    skip_parameter_relation_errors=True    should_activate=True    connection=online
    Wait until keyword succeeds    600s    30s    Verify BTS Is Onair
    COAM.teardown admin    connection=online

get tput from PM counter
    ${remaining_time}=    get_counter_file_remaining_time    counter_refresh_period=5min
    ${remaining_time}     evaluate    ${remaining_time}+300
    Wait Throughput Timer    ${remaining_time}
    ${PM_counter_file}=    download_latest_pmcounter    local_path=${TEST_LOG_DIRECTORY()}conter_files${/}
    ${PM_counter_DL_value}=    get_counter_value_from_counter_file
    ...   counter_file=${PM_counter_file}
    ...   counter_id=M55309C12001
    ...   cell_id=1
    ${DL_throughput}    evaluate    ${PM_counter_DL_value}*8/1024/1024
    ${PM_counter_UL_value}=    get_counter_value_from_counter_file
    ...   counter_file=${PM_counter_file}
    ...   counter_id=M55309C12002
    ...   cell_id=1
    ${UL_throughput}    evaluate    ${PM_counter_UL_value}*8/1024/1024
    [Return]    ${DL_throughput}    ${UL_throughput}

modify_swconfig_by_CB008322
    comment     https://confluence.ext.net.nokia.com/pages/viewpage.action?spaceKey=AirPhoneWTS&title=AirPhone+Alignment+to+gNB+L1L2+Interface
    [Arguments]    ${scfc_file}
    ${local_save_path}=     Download All Common Config Files From Golden Server
    ${path_gnb}=            Find Match GNB swconfig Golden Files    ${scfc_file}    ${local_save_path}
    ${path_ap}=             Find Match AP swconfig Golden Files    ${scfc_file}     ${local_save_path}
    setup_txt    src_file=${path_gnb}    save_path=${TEST_LOG_DIRECTORY()}${/}swconfig_gnb_ini.txt
    add_txt_node    0x9D0000:15        #as PM counter period update to 15/15=1min
    #add_txt_node    0x58076a:5        #rdNumWbSrsMeas(Default Value is 5, [1,200])
    #add_txt_node    0x800070:1        #rdRtBwvDowngradeMethod(default is 1,[0,4])
    #add_txt_node    0x58077f:0        #rdHighVolatileUeFallbackTStep(default is 0, [0,400])
    #add_txt_node    0x580717:0        #rdPdcchApplyToSeparateStreams
    #add_txt_node    0x600018:0       #rdUlUpFragmentationEnable
    #add_txt_node    0x580860:1       #rdMonitorSe
    teardown_txt
    setup_txt    src_file=${path_ap}    save_path=${TEST_LOG_DIRECTORY()}${/}swconfig_ap_ini.txt
    teardown_txt
    GNB Upload Swconfig           ${TEST_LOG_DIRECTORY()}${/}swconfig_gnb_ini.txt
    airphone_upload_swconfig      ${TEST_LOG_DIRECTORY()}${/}swconfig_ap_ini.txt