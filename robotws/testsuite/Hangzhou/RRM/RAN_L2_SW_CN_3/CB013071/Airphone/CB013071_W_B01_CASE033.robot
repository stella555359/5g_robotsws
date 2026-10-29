*** Settings ***
Documentation     Author: mao.qin@nokia-sbell.com
...
...               QC case full name:
...               CB013071_W_B01_CASE033_32TRX_single_band_SubbandBm_3CC_peak
...

Suite Setup       Common Suite Setup
#Suite Teardown    Common Suite Teardown
Test Setup        Common Test Setup
Test Teardown     Common Test Teardown
Force Tags        CLOUD_5G_I_MP_AP_LO    AP    CRT    SBTS00    RAN_5G_TDD    RAN_5G    owner_mqin
Test Timeout      360 minutes
Resource          ../../resources/sg11/internal_resource/robot/modify_configuration.robot
Resource          ../../resources/sg11/internal_resource/robot/internal_ap_operate.robot
Resource          ../../resources/sg11/internal_resource/robot/internal_gnb_operate.robot
Resource          ../../resources/sg11/internal_resource/robot/internal_capture_log.robot
Library           taf.transport.ssh    WITH NAME    TAF_SSH
Library           ta_a2a

*** Variables ***
${CONFIG_DIR_PATH}    ${CURDIR}/../../resources/sg11/internal_resource/config/
${SCFC_NAME}          gNB_scf_ASIL_ABIO_3cell_8D4U_4D4U_CB013071_case033.xml
${AIRPHONE_NAME}      AP_iphy_AVQC_CB013071_case033.xml
${WTS_NAME}           wts_config_CB013071_case033.lua
@{LOG_NAME_LIST}      egatelog\    gnb_snapshot
#    ap_snapshot    sosreport
${cellDepType}                    text|SA+NSA|//*[@name\="cellDepType"]
${par_of_bsr_name}                BSR_AVQC_6_H6_ALN60_ARP60_P00_COVERAGE_00424_00001
${pattern1}                       CA_P2_8x4_t2r4_n2
${pattern2}                       CA_P2_8x4_t1r4_n1
${pattern3}                       CA_P2_8x4_t2r4_n2_60MHz
${pattern4}                       CA_P2_8x4_t2r4_n2_40MHz
${PROFILE1}    ul_mimo_srs_beam_pos_nr profile_id=1 mode=fixed init_quad_pos=0 init_sub_quad_pos=0 test_type=SRS
...        multi_path_config=true num_of_nlos_paths=1 azimuth=30 zenith=0 srs_transmit_power_per_port=-200,-200,-200,-200
${PROFILE2}    ul_mimo_srs_beam_pos_nr profile_id=1 mode=fixed init_quad_pos=1 init_sub_quad_pos=1 test_type=SRS
...        multi_path_config=true num_of_nlos_paths=1 azimuth=20 zenith=0 srs_transmit_power_per_port=-200,-200,-200,-200
${PROFILE3}    ul_mimo_srs_beam_pos_nr profile_id=1 mode=fixed init_quad_pos=2 init_sub_quad_pos=2 test_type=SRS
...        multi_path_config=true num_of_nlos_paths=1 azimuth=10 zenith=0 srs_transmit_power_per_port=-200,-200,-200,-200
${PROFILE4}    ul_mimo_srs_beam_pos_nr profile_id=1 mode=fixed init_quad_pos=3 init_sub_quad_pos=3 test_type=SRS
...        multi_path_config=true num_of_nlos_paths=1 azimuth=0 zenith=0 srs_transmit_power_per_port=-200,-200,-200,-200
${PROFILE5}    ul_mimo_srs_beam_pos_nr profile_id=5 mode=fixed init_quad_pos=3 init_sub_quad_pos=0 test_type=UL_MIMO
...        multi_path_config=0
${PROFILE6}    ul_mimo_srs_beam_pos_nr profile_id=6 mode=fixed init_quad_pos=3 init_sub_quad_pos=1 test_type=UL_MIMO
...        multi_path_config=0
${PROFILE7}    ul_mimo_srs_beam_pos_nr profile_id=7 mode=fixed init_quad_pos=3 init_sub_quad_pos=2 test_type=UL_MIMO
...        multi_path_config=0
${PROFILE8}    ul_mimo_srs_beam_pos_nr profile_id=8 mode=fixed init_quad_pos=3 init_sub_quad_pos=3 test_type=UL_MIMO
...        multi_path_config=0
${PROFILE11}    ul_mimo_srs_beam_pos_nr profile_id=11 mode=fixed init_quad_pos=1 init_sub_quad_pos=1 test_type=SRS
...        multi_path_config=true num_of_nlos_paths=1 azimuth=30 zenith=0 srs_transmit_power_per_port=-550,-550,-550,-550
${PROFILE12}    ul_mimo_srs_beam_pos_nr profile_id=12 mode=fixed init_quad_pos=1 init_sub_quad_pos=1 test_type=SRS
...        multi_path_config=true num_of_nlos_paths=1 azimuth=30 zenith=0 srs_transmit_power_per_port=-690,-690,-690,-690
${SET_PROFILE1}    ue_testmode_set_nr id=1 testmode=ul_mimo_srs_beam_pos action=activate profile_id=1


*** Test Cases ***
CB013071_W_B01_CASE033_32TRX_single_band_SubbandBm_3CC_peak
    Step1:Commission the above configuration on WebUI
    Step2:10UEs attach to cells and send data
    #Step3:more UEs attach to cells

*** Keywords ***
Step1:Commission the above configuration on WebUI
    Start capture GNB and AP Syslog in 'Step1_before_onair' File
    ${CONFIG_DIR_PATH}    Set Variable    ${CONFIG_DIR_PATH}/${SW_BRANCH}
    #${mod_iphy}    create list     text|2|//NumberOfSubCellsDL
    #modify xml     ${CONFIG_DIR_PATH}${/}${AIRPHONE_NAME}      ${CONFIG_DIR_PATH}${/}${AIRPHONE_NAME}    ${mod_iphy}
    change_iphy_rru_version    ${CONFIG_DIR_PATH}${/}${AIRPHONE_NAME}
    #modify_swconfig_by_CB008322    ${CONFIG_DIR_PATH}${/}${SCFC_NAME}
    ${scfc_path}    Set Variable    ${TEST_LOG_DIRECTORY()}${/}scfc.xml
    copy_file    ${CONFIG_DIR_PATH}/${SCFC_NAME}    ${scfc_path}
    #add_xml_element     ${scfc_path}    ${scfc_path}     <p name="lteToNrFrameShift">3ms</p>|//*[@name\='tddFrameStructure']/item
    #add_xml_element     ${scfc_path}    ${scfc_path}     <p name="tdLteUlDlConfig">tdLteConfig2</p>|//*[@name\='tddFrameStructure']/item
    #del_elements_from_xml    xml_path=${scfc_path}    parameter=lteToNrFrameShift
    #del_elements_from_xml    xml_path=${scfc_path}    parameter=tdLteUlDlConfig
    #add_bwplist_list_in_cells_new    ${scfc_path}    key_3
    ${modify_list}    create list
    ...    ${cellDepType}
    modify_xml    ${scfc_path}    ${scfc_path}    ${modify_list}
    Modify TL VM And AP SCTP Configuration
    Get and Update BSR File    ${par_of_bsr_name}
    #Add L2PS Deubg Logs
    Perform Full Commission And Reach Onair With Log    ${scfc_path}    ${CONFIG_DIR_PATH}${/}${WTS_NAME}    reset_after_commission=${False}
    [Teardown]    Stop capture GNB and AP Syslog in 'Step1_before_onair' File

Step2:10UEs attach to cells and send data
    Start capture GNB and AP Syslog in 'Step2_10UEs' File

    FOR    ${i}    IN RANGE    101    201
        airphone_execute_egate_command    ue_change_location id\=${i} cell\=2
    END

    FOR    ${i}    IN RANGE    301    401
        airphone_execute_egate_command    ue_change_location id\=${i} cell\=3
    END

    FOR    ${i}    IN RANGE    401    501
        airphone_execute_egate_command    ue_change_location id\=${i} cell\=4
    END

    FOR    ${i}    IN RANGE    1    5
        airphone_execute_egate_command    ${PROFILE${i}}
    END

    FOR    ${i}    IN RANGE    1    9
        #airphone_execute_egate_command    ue_testmode_set_nr id\=${i} testmode\=ul_mimo_srs_beam_pos action\=activate profile_id\=1
        run keyword and continue on failure    Attach UE to cell    ${i}    ${pattern1}
        run keyword and continue on failure    Send trf for UE    ${i}    dl    100M    1
        run keyword and continue on failure    Send trf for UE    ${i}    ul    30M    1
        ${j}=    evaluate    ${i}%4+1
        airphone_execute_egate_command    ue_testmode_set_nr id\=${i} testmode\=ul_mimo_srs_beam_pos action\=activate profile_id\=${j}
    END

    FOR    ${i}    IN RANGE    9    11
        run keyword and continue on failure    Attach UE to cell    ${i}    ${pattern3}
        run keyword and continue on failure    Send trf for UE    ${i}    dl    100M    1
        run keyword and continue on failure    Send trf for UE    ${i}    ul    30M    1
        ${j}=    evaluate    ${i}%4+1
        airphone_execute_egate_command    ue_testmode_set_nr id\=${i} testmode\=ul_mimo_srs_beam_pos action\=activate profile_id\=${j}
    END

    FOR    ${i}    IN RANGE    11    13
        run keyword and continue on failure    Attach UE to cell    ${i}    ${pattern4}
        run keyword and continue on failure    Send trf for UE    ${i}    dl    100M    1
        run keyword and continue on failure    Send trf for UE    ${i}    ul    30M    1
        ${j}=    evaluate    ${i}%4+1
        airphone_execute_egate_command    ue_testmode_set_nr id\=${i} testmode\=ul_mimo_srs_beam_pos action\=activate profile_id\=${j}
    END

    FOR    ${i}    IN RANGE    13    15
        run keyword and continue on failure    Attach UE to cell    ${i}    ${pattern1}
        run keyword and continue on failure    Send trf for UE    ${i}    dl    100K    1
        ${j}=    evaluate    ${i}%4+1
        airphone_execute_egate_command    ue_testmode_set_nr id\=${i} testmode\=ul_mimo_srs_beam_pos action\=activate profile_id\=${j}
    END


    FOR    ${i}    IN RANGE    101    111
        run keyword and continue on failure    Attach UE to cell    ${i}    ${pattern2}
        run keyword and continue on failure    Send trf for UE    ${i}    dl    50M    1
        run keyword and continue on failure    Send trf for UE    ${i}    dl    15M    1
        ${j}=    evaluate    ${i}%4+1
        airphone_execute_egate_command    ue_testmode_set_nr id\=${i} testmode\=ul_mimo_srs_beam_pos action\=activate profile_id\=${j}
    END

    FOR    ${i}    IN RANGE    301    311
        run keyword and continue on failure    Attach UE to cell    ${i}    ${pattern1}
        run keyword and continue on failure    Send trf for UE    ${i}    dl    30M    1
        run keyword and continue on failure    Send trf for UE    ${i}    dl    10M    1
        ${j}=    evaluate    ${i}%4+1
        airphone_execute_egate_command    ue_testmode_set_nr id\=${i} testmode\=ul_mimo_srs_beam_pos action\=activate profile_id\=${j}
    END

    FOR    ${i}    IN RANGE    401    411
        run keyword and continue on failure    Attach UE to cell    ${i}    ${pattern2}
        run keyword and continue on failure    Send trf for UE    ${i}    dl    30M    1
        run keyword and continue on failure    Send trf for UE    ${i}    dl    10M    1
        ${j}=    evaluate    ${i}%4+1
        airphone_execute_egate_command    ue_testmode_set_nr id\=${i} testmode\=ul_mimo_srs_beam_pos action\=activate profile_id\=${j}
    END

    Wait '1000s' for stable

#    ${capacity_units}=  Create List    ABIO
#    Configure Bip Collection   l1_type=FS
#    ...                        gNB_common_unit=ASIL
#    ...                        gNB_capacity_units=${capacity_units}
#    ...                        use_script=True
#    ...                        script_parameters=--bb_slot_1='true' --bb_slot_2='false' --bb_slot_3='false'
#    Wait '10s' for stable

#    Start Bip Trace
#    Start GNB Ttitrace With Streaming Mode
#    Wait '1s' for stable
#    ${save_log}=    Set Variable    ${TEST_LOG_DIRECTORY()}Step2_10UEs
#    ${pacp}=    Stop GNB Ttitrace With Streaming Mode    save_path=${save_log}
#    Stop Bip Trace   target_dir=${save_log}
#     Decoder Tttirace From Pcap To Csv    ${pacp}    ${save_log}/tti
    ${CB008322_UE_num1}    ${CB008322_UE_num2}    ${CB008322_UE_num3}    ${CB008322_UE_num4}
    ...    get SUBBAND UE numbers from PM counter
    run keyword and continue on failure    should be true    ${CB008322_UE_num1}==4
    run keyword and continue on failure    should be true    ${CB008322_UE_num2}==4
    run keyword and continue on failure    should be true    ${CB008322_UE_num3}==4
    run keyword and continue on failure    should be true    ${CB008322_UE_num4}==4
    [Teardown]    Stop capture GNB and AP Syslog in 'Step2_10UEs' File

Step3:more UEs attach to cells
    Start capture GNB and AP Syslog in 'Step3_more_UEs' File2
    FOR    ${i}    IN RANGE    15    101
        Run Keyword And Ignore Error    Attach UE to cell    ${i}    ${pattern2}
        Run Keyword And Ignore Error    Send trf for UE    ${i}    dl    1M    1
        Run Keyword And Ignore Error    Send trf for UE    ${i}    ul    1M    1
        ${j}=    evaluate    ${i}%4+1
        airphone_execute_egate_command    ue_testmode_set_nr id\=${i} testmode\=ul_mimo_srs_beam_pos action\=activate profile_id\=${j}
    END

    FOR    ${i}    IN RANGE    111    121
        Run Keyword And Ignore Error    Attach UE to cell    ${i}    ${pattern2}
        Run Keyword And Ignore Error    Send trf for UE    ${i}    dl    1M    1
        Run Keyword And Ignore Error    Send trf for UE    ${i}    ul    1M    1
        ${j}=    evaluate    ${i}%4+1
        airphone_execute_egate_command    ue_testmode_set_nr id\=${i} testmode\=ul_mimo_srs_beam_pos action\=activate profile_id\=${j}
    END

    FOR    ${i}    IN RANGE    121    141
        Run Keyword And Ignore Error    Attach UE to cell    ${i}    ${pattern3}
        Run Keyword And Ignore Error    Send trf for UE    ${i}    dl    1M    1
        Run Keyword And Ignore Error    Send trf for UE    ${i}    ul    1M    1
    END

    FOR    ${i}    IN RANGE    141    161
        Run Keyword And Ignore Error    Attach UE to cell    ${i}    ${pattern4}
        Run Keyword And Ignore Error    Send trf for UE    ${i}    dl    1M    1
        Run Keyword And Ignore Error    Send trf for UE    ${i}    ul    1M    1
    END

    FOR    ${i}    IN RANGE    161    171
        Run Keyword And Ignore Error    Attach UE to cell    ${i}    ${pattern1}
        Run Keyword And Ignore Error    Send trf for UE    ${i}    dl    100K    1
        ${j}=    evaluate    ${i}%4+1
        airphone_execute_egate_command    ue_testmode_set_nr id\=${i} testmode\=ul_mimo_srs_beam_pos action\=activate profile_id\=${j}
    END

    FOR    ${i}    IN RANGE    311    321
        Run Keyword And Ignore Error    Attach UE to cell    ${i}    ${pattern2}
        Run Keyword And Ignore Error    Send trf for UE    ${i}    dl    5M    1
        Run Keyword And Ignore Error    Send trf for UE    ${i}    ul    5M    1
        ${j}=    evaluate    ${i}%4+1
        airphone_execute_egate_command    ue_testmode_set_nr id\=${i} testmode\=ul_mimo_srs_beam_pos action\=activate profile_id\=${j}
    END

    FOR    ${i}    IN RANGE    411    421
        Run Keyword And Ignore Error    Attach UE to cell    ${i}    ${pattern1}
        Run Keyword And Ignore Error    Send trf for UE    ${i}    dl    5M    1
        Run Keyword And Ignore Error    Send trf for UE    ${i}    ul    5M    1
        ${j}=    evaluate    ${i}%4+1
        airphone_execute_egate_command    ue_testmode_set_nr id\=${i} testmode\=ul_mimo_srs_beam_pos action\=activate profile_id\=${j}
    END

    Wait '120s' for stable

#    Start Bip Trace
#    Start GNB Ttitrace With Streaming Mode
#    Wait '1s' for stable
#    ${save_log}=    Set Variable    ${TEST_LOG_DIRECTORY()}Step3_more_UEs
#    ${pacp}=    Stop GNB Ttitrace With Streaming Mode    save_path=${save_log}
#    Stop Bip Trace   target_dir=${save_log}
#    Decoder Tttirace From Pcap To Csv    ${pacp}    ${save_log}/tti

    ${CB008322_UE_num1}    ${CB008322_UE_num2}    ${CB008322_UE_num3}    ${CB008322_UE_num4}
    ...    get SUBBAND UE numbers from PM counter
    ${CB008322_UE_num}    evaluate    ${CB008322_UE_num1} + ${CB008322_UE_num2} + ${CB008322_UE_num3} + ${CB008322_UE_num4}
    run keyword and continue on failure    should be true    ${CB008322_UE_num}>0

    Wait '120s' for stable
    ${dl_tput_cell1}    ${dl_tput_cell2}    ${dl_tput_cell3}    ${dl_tput_cell4}
    ...    get DL tput from PM counter
    [Teardown]    Stop capture GNB and AP Syslog in 'Step3_more_UEs' File2

Step4:Detach UEs
    Start capture GNB and AP Syslog in 'Step4_detach' File2
    FOR    ${i}    IN RANGE    1    201
        #Airphone Sa Stop Data Traffic    ${i}    dl
        Detach UE    ${i}
    END

    FOR    ${i}    IN RANGE    301    401
        #Airphone Sa Stop Data Traffic    ${i}    dl
        Detach UE    ${i}
    END

    [Teardown]    Stop capture GNB and AP Syslog in 'Step4_detach' File2

Attach UE to cell
    [Arguments]    ${ue_id}    ${pattern}
    ${ue_ability}    Obtain Ue Capability    ${pattern}
    ${attach_status}=    run keyword and return status    Airphone SA Attach    ue_id=${ue_id}    timeout=10    ue_capability=${ue_ability}
    Run Keyword If    '${attach_status}'=='False'    Airphone SA Attach    ue_id=${ue_id}    timeout=10    ue_capability=${ue_ability}
    airphone_set_traffic_type    ${ue_id}    1    internal
    ${gw_id}=    evaluate    ${ue_id}%10 + 1
    ${pdu_status}=    run keyword and return status    Airphone Pdu Session Setup    ${ue_id}    1    1    ${gw_id}
    ${newNum}=    evaluate    0 + 8
    Run Keyword If    '${pdu_status}'=='False'    Airphone Pdu Session Setup    ${ue_id}    1    1    ${newNum}
    Wait '2s' for stable running

Attach UE to cell2
    [Arguments]    ${ue_id}    ${pattern}
    ${ue_ability}    Obtain Ue Capability    ${pattern}
    ${attach_status}=    run keyword and return status    Airphone SA Attach    ue_id=${ue_id}    timeout=10    ue_capability=${ue_ability}
    Run Keyword If    '${attach_status}'=='False'    Airphone SA Attach    ue_id=${ue_id}    timeout=10    ue_capability=${ue_ability}
    airphone_set_traffic_type    ${ue_id}    2    internal
    ${gw_id}=    evaluate    ${ue_id}%10 + 1
    ${pdu_status}=    run keyword and return status    Airphone Pdu Session Setup    ${ue_id}    2    1    ${gw_id}
    ${newNum}=    evaluate    0 + 8
    Run Keyword If    '${pdu_status}'=='False'    Airphone Pdu Session Setup    ${ue_id}    2    1    ${newNum}
    Wait '2s' for stable running

Send trf for UE
    [Arguments]    ${ue_id}    ${DLorUL}    ${mbps}    ${number}
    FOR    ${num}    IN RANGE    1    ${number}+1
        Airphone SA Start Data Traffic    ${ue_id}    ${DLorUL}    ${mbps}    pdu_id=1    duration=7200s    trf_id=${num}
    END

Send trf for UE2
    [Arguments]    ${ue_id}    ${DLorUL}    ${mbps}    ${number}
    FOR    ${num}    IN RANGE    1    ${number}+1
        Airphone SA Start Data Traffic    ${ue_id}    ${DLorUL}    ${mbps}    pdu_id=2    duration=7200s    trf_id=${num}
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
   	...    csi_override_testmode_nr profile_id\=5 ri_mode\=fixed ri\=${ranki} cqi_mode\=fixed cqi\=${cqii}
    airphone_execute_egate_command
    ...    ue_testmode_set_nr id\=${ue_id} testmode\=csi_override action\=activate profile_id\=5

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
    add_txt_node    0x9D0000:15    #as PM counter period update to 15/15=1min
    #add_txt_node    0x58079e:120    #rdWbSrsConstraintTimer
    teardown_txt
    setup_txt    src_file=${path_ap}    save_path=${TEST_LOG_DIRECTORY()}${/}swconfig_ap_ini.txt
    teardown_txt
    GNB Upload Swconfig           ${TEST_LOG_DIRECTORY()}${/}swconfig_gnb_ini.txt
    airphone_upload_swconfig      ${TEST_LOG_DIRECTORY()}${/}swconfig_ap_ini.txt

Start capture gnb and ap syslog in '${file_name}' file2
    ute_syslog.Start Syslog    file_limit=${GNB_SYSLOG.file_limit}    log_dir=${TEST_LOG_DIRECTORY()}/${file_name}/syslog_${file_name}
    ...    log_name=${file_name}_gnb    ip=${GNB_SYSLOG.ip}    alias=collect_gnb
    ute_syslog.Start Syslog    file_limit=${AP_SYSLOG.file_limit}    log_dir=${TEST_LOG_DIRECTORY()}/${file_name}/syslog_${file_name}
    ...    log_name=${file_name}_ap    ip=${AP_SYSLOG.ip}    alias=collect_ap

Stop capture gnb and ap syslog in '${file_name}' file2
    #check_err_wrn_in_btslog    ${TEST_LOG_DIRECTORY()}${/}${file_name}${/}syslog_${file_name}${/}    syslog_${file_name}
    airphone_collect_egate_log_files      ${TEST_LOG_DIRECTORY()}${/}${file_name}   unzip=TRUE
    ute_syslog.Collect Syslog Results    alias=collect_gnb    unzip=${False}
    ...    destination=${TEST_LOG_DIRECTORY()}${/}${file_name}${/}syslog_${file_name}${/}${file_name}_gnb.tar.gz
    ute_syslog.Collect Syslog Results    alias=collect_ap    unzip=${False}
    ...    destination=${TEST_LOG_DIRECTORY()}${/}${file_name}${/}syslog_${file_name}${/}${file_name}_ap.tar.gz

get SUBBAND UE numbers from PM counter
    ${PM_counter_file}=    download_latest_pmcounter    local_path=${TEST_LOG_DIRECTORY()}conter_files${/}
    ${CB008322_UE_cell1}=           get_counter_value_from_counter_file    counter_file=${PM_counter_file}    counter_id=M55196C00012    cell_id=1
    ${CB008322_UE_cell2}=           get_counter_value_from_counter_file    counter_file=${PM_counter_file}    counter_id=M55196C00012    cell_id=2
    ${CB008322_UE_cell3}=           get_counter_value_from_counter_file    counter_file=${PM_counter_file}    counter_id=M55196C00012    cell_id=3
    ${CB008322_UE_cell4}=           get_counter_value_from_counter_file    counter_file=${PM_counter_file}    counter_id=M55196C00012    cell_id=4
    [Return]    ${CB008322_UE_cell1}    ${CB008322_UE_cell2}    ${CB008322_UE_cell3}    ${CB008322_UE_cell4}

get DL tput from PM counter
    ${PM_counter_file}=    download_latest_pmcounter    local_path=${TEST_LOG_DIRECTORY()}conter_files${/}
    ${dl_tput_cell1}=           get_counter_value_from_counter_file    counter_file=${PM_counter_file}    counter_id=M55309C12001    cell_id=1
    ${dl_tput_cell2}=           get_counter_value_from_counter_file    counter_file=${PM_counter_file}    counter_id=M55309C12001    cell_id=2
    ${dl_tput_cell3}=           get_counter_value_from_counter_file    counter_file=${PM_counter_file}    counter_id=M55309C12001    cell_id=3
    ${dl_tput_cell4}=           get_counter_value_from_counter_file    counter_file=${PM_counter_file}    counter_id=M55309C12001    cell_id=4
    ${dl_tput_cell1}    evaluate    ${dl_tput_cell1}*8/1024/1024
    ${dl_tput_cell2}    evaluate    ${dl_tput_cell2}*8/1024/1024
    ${dl_tput_cell3}    evaluate    ${dl_tput_cell3}*8/1024/1024
    ${dl_tput_cell4}    evaluate    ${dl_tput_cell4}*8/1024/1024
    [Return]    ${dl_tput_cell1}    ${dl_tput_cell2}    ${dl_tput_cell3}    ${dl_tput_cell4}