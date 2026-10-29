*** Settings ***
Documentation     Author: mao.qin@nokia-sbell.com
...
...               QC case full name:
...               CB013071_B_B01_CASE010_64TRX_dual_band_SubbandBm_3CC_MultiBWP_EIRP
...

Suite Setup       Common Suite Setup
Suite Teardown    Common Suite Teardown
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
${SCFC_NAME}          gNB_scf_CB013071_case010.xml
${AIRPHONE_NAME}      AP_iphy_AVHQB_CB013071_case010.xml
${WTS_NAME}           wts_config_CB013071_case010.lua
@{LOG_NAME_LIST}      egatelog\    gnb_snapshot
#ap_snapshot    sosreport
${cellDepType}                    text|SA+NSA|//*[@name\="cellDepType"]
${par_of_bsr_name_1}                BSR_AVHQB_6_H6_ALN45_ARP45_N01_COVE3593_00391_00001
${par_of_bsr_name_2}                BSR_AVHQB_6_H6_ALN45_ARP45_N01_COVE2595_00391_00001
${pattern1}                       CA_P2_8x4_t2r4_n2
${pattern2}                       CA_P2_8x4_t1r4_n1
${pattern3}                       CA_P2_8x4_t4r4_n4
${pattern4}                       CA_P2_8x4_noTas_n2
${pattern5}                       CA_n38
${pattern6}                       CA_P2_8x4_t2r4_n2_60MHz
${pattern7}                       CA_P2_8x4_t2r4_n2_40MHz

${PROFILE1}    ul_mimo_srs_beam_pos_nr profile_id=1 mode=fixed init_quad_pos=0 init_sub_quad_pos=0 test_type=SRS
...        multi_path_config=true num_of_nlos_paths=1 azimuth=30 zenith=0 srs_transmit_power_per_port=-200,-200,-200,-200
${PROFILE2}    ul_mimo_srs_beam_pos_nr profile_id=1 mode=fixed init_quad_pos=1 init_sub_quad_pos=1 test_type=SRS
...        multi_path_config=true num_of_nlos_paths=1 azimuth=20 zenith=0 srs_transmit_power_per_port=-200,-200,-200,-200
${PROFILE3}    ul_mimo_srs_beam_pos_nr profile_id=1 mode=fixed init_quad_pos=2 init_sub_quad_pos=2 test_type=SRS
...        multi_path_config=true num_of_nlos_paths=1 azimuth=10 zenith=0 srs_transmit_power_per_port=-200,-200,-200,-200
${PROFILE4}    ul_mimo_srs_beam_pos_nr profile_id=1 mode=fixed init_quad_pos=3 init_sub_quad_pos=3 test_type=SRS
...        multi_path_config=true num_of_nlos_paths=1 azimuth=0 zenith=0 srs_transmit_power_per_port=-200,-200,-200,-200
${PROFILE5}    ul_mimo_srs_beam_pos_nr profile_id=5 mode=fixed init_quad_pos=3 init_sub_quad_pos=0 test_type=SRS
...        multi_path_config=true num_of_nlos_paths=1 azimuth=30 zenith=0 srs_transmit_power_per_port=-200,-200,-200,-200
${PROFILE6}    ul_mimo_srs_beam_pos_nr profile_id=6 mode=fixed init_quad_pos=3 init_sub_quad_pos=1 test_type=SRS
...        multi_path_config=true num_of_nlos_paths=1 azimuth=30 zenith=0 srs_transmit_power_per_port=-200,-200,-200,-200
${PROFILE7}    ul_mimo_srs_beam_pos_nr profile_id=7 mode=fixed init_quad_pos=3 init_sub_quad_pos=2 test_type=SRS
...        multi_path_config=true num_of_nlos_paths=1 azimuth=30 zenith=0 srs_transmit_power_per_port=-200,-200,-200,-200
${PROFILE8}    ul_mimo_srs_beam_pos_nr profile_id=8 mode=fixed init_quad_pos=3 init_sub_quad_pos=3 test_type=SRS
...        multi_path_config=true num_of_nlos_paths=1 azimuth=30 zenith=0 srs_transmit_power_per_port=-200,-200,-200,-200
${PROFILE11}    ul_mimo_srs_beam_pos_nr profile_id=11 mode=fixed init_quad_pos=1 init_sub_quad_pos=1 test_type=SRS
...        multi_path_config=true num_of_nlos_paths=1 azimuth=30 zenith=0 srs_transmit_power_per_port=-550,-550,-550,-550
${PROFILE12}    ul_mimo_srs_beam_pos_nr profile_id=12 mode=fixed init_quad_pos=1 init_sub_quad_pos=1 test_type=SRS
...        multi_path_config=true num_of_nlos_paths=1 azimuth=30 zenith=0 srs_transmit_power_per_port=-690,-690,-690,-690
${SET_PROFILE1}    ue_testmode_set_nr id=1 testmode=ul_mimo_srs_beam_pos action=activate profile_id=1


*** Test Cases ***
CB013071_B_B01_CASE010_64TRX_dual_band_SubbandBm_3CC_MultiBWP_EIRP
    Step1:Commission the above configuration on WebUI
    Step2:UEs attach to cell1 and send data
    Step3:Trigger BWPs
    Step4:Trigger EIRP control


*** Keywords ***
Step1:Commission the above configuration on WebUI
    Start capture GNB and AP Syslog in 'Step1_before_onair' File
    ${CONFIG_DIR_PATH}    Set Variable    ${CONFIG_DIR_PATH}/${SW_BRANCH}
    change_iphy_rru_version    ${CONFIG_DIR_PATH}${/}${AIRPHONE_NAME}
    modify_swconfig_by_CB008322    ${CONFIG_DIR_PATH}${/}${SCFC_NAME}
    ${scfc_path}    Set Variable    ${TEST_LOG_DIRECTORY()}${/}scfc.xml
    copy_file    ${CONFIG_DIR_PATH}/${SCFC_NAME}    ${scfc_path}
    ${modify_list}    create list
    ...    ${cellDepType}
    modify_xml    ${scfc_path}    ${scfc_path}    ${modify_list}
    Modify TL VM And AP SCTP Configuration
    Get and Update BSR File    ${par_of_bsr_name_1}
    Get and Update BSR File    ${par_of_bsr_name_2}
    #Add L2PS Deubg Logs
    Perform Full Commission And Reach Onair With Log    ${scfc_path}    ${CONFIG_DIR_PATH}${/}${WTS_NAME}    reset_after_commission=${False}
    [Teardown]    Stop capture GNB and AP Syslog in 'Step1_before_onair' File

Step2:UEs attach to cell1 and send data
    Start capture GNB and AP Syslog in 'Step2_4UEs' File

#    ${capacity_units}=  Create List    ABIO
#    Configure Bip Collection   l1_type=FS
#    ...                        gNB_common_unit=ASIL
#    ...                        gNB_capacity_units=${capacity_units}
#    ...                        use_script=True
#    ...                        script_parameters=--bb_slot_1='true' --bb_slot_2='false' --bb_slot_3='false'

    FOR    ${i}    IN RANGE    21    41
        airphone_execute_egate_command    ue_change_location id\=${i} cell\=2
    END

    FOR    ${i}    IN RANGE    41    61
        airphone_execute_egate_command    ue_change_location id\=${i} cell\=3
    END

    FOR    ${i}    IN RANGE    1    5
        airphone_execute_egate_command    ${PROFILE${i}}
    END

    FOR    ${i}    IN RANGE    1    5
        Attach UE to cell    ${i}    ${pattern1}
        Send trf for UE    ${i}    dl    100M    1
        Send trf for UE    ${i}    ul    10M    1
        #${j}=    evaluate    ${i}%4+1
        #airphone_execute_egate_command    ue_testmode_set_nr id\=${i} testmode\=ul_mimo_srs_beam_pos action\=activate profile_id\=${j}
    END

    FOR    ${i}    IN RANGE    21    25
        Attach UE to cell    ${i}    ${pattern1}
        Send trf for UE    ${i}    dl    100M    1
        Send trf for UE    ${i}    ul    10M    1
    END

    FOR    ${i}    IN RANGE    41    45
        Attach UE to cell    ${i}    ${pattern5}
        Send trf for UE    ${i}    dl    50M    1
        Send trf for UE    ${i}    ul    10M    1
    END

    Wait '60s' for stable

    #Start Bip Trace
    Start GNB Ttitrace With Streaming Mode
    Wait '0.5s' for stable
    ${save_log}=    Set Variable    ${TEST_LOG_DIRECTORY()}Step2_4UEs
    ${pacp}=    Stop GNB Ttitrace With Streaming Mode    save_path=${save_log}
    #Stop Bip Trace   target_dir=${save_log}
    Decoder Tttirace From Pcap To Csv    ${pacp}    ${save_log}/tti
    run keyword and continue on failure
    ...    check_log_with_au2anlysis    ini_path=${CURDIR}/ini/CB013071_case010_step2_tti_dl.ini    log_need_to_check=i
    ...    save_log_directory=${save_log}
    run keyword and continue on failure
    ...    check_log_with_au2anlysis    ini_path=${CURDIR}/ini/CB013071_case010_step2_tti_ul.ini    log_need_to_check=i
    ...    save_log_directory=${save_log}
    ${CB008322_UE_num1}    ${CB008322_UE_num2}    ${CB008322_UE_num3}
    ...    get SUBBAND UE numbers from PM counter
    run keyword and continue on failure    should be true    ${CB008322_UE_num1}==4
    run keyword and continue on failure    should be true    ${CB008322_UE_num2}==4
    run keyword and continue on failure    should be true    ${CB008322_UE_num3}==4
    ${DL_tput1}    ${DL_tput2}    ${DL_tput3}
    ...    get DL tput from PM counter
    run keyword and continue on failure    should be true    ${DL_tput1}>300
    run keyword and continue on failure    should be true    ${DL_tput2}>300
    run keyword and continue on failure    should be true    ${DL_tput3}>150
    [Teardown]    Stop capture GNB and AP Syslog in 'Step2_4UEs' File

Step3:Trigger BWPs
    Start capture GNB and AP Syslog in 'Step3_BWPs' File
    FOR    ${i}    IN RANGE    6    9
        Attach UE to cell    ${i}    ${pattern1}
        Send trf for UE    ${i}    dl    100M    1
        Send trf for UE    ${i}    ul    10M    1
    END

    FOR    ${i}    IN RANGE    9    11
        Attach UE to cell    ${i}    ${pattern1}
        Send trf for UE    ${i}    dl    100K    1
    END

    FOR    ${i}    IN RANGE    11    15
        Attach UE to cell    ${i}    ${pattern6}
        Send trf for UE    ${i}    dl    50M    1
        Send trf for UE    ${i}    ul    10M    1
    END

    FOR    ${i}    IN RANGE    15    19
        Attach UE to cell    ${i}    ${pattern7}
        Send trf for UE    ${i}    dl    50M    1
        Send trf for UE    ${i}    ul    10M    1
    END

    FOR    ${i}    IN RANGE    25    27
        Attach UE to cell    ${i}    ${pattern1}
        Send trf for UE    ${i}    dl    50M    1
        Send trf for UE    ${i}    ul    10M    1
    END

    FOR    ${i}    IN RANGE    45    47
        Attach UE to cell    ${i}    ${pattern5}
        Send trf for UE    ${i}    dl    50M    1
        Send trf for UE    ${i}    ul    10M    1
    END

    Wait '60s' for stable

    #Start Bip Trace
    Start GNB Ttitrace With Streaming Mode
    Wait '0.2s' for stable
    ${save_log}=    Set Variable    ${TEST_LOG_DIRECTORY()}Step3_BWPs
    ${pacp}=    Stop GNB Ttitrace With Streaming Mode    save_path=${save_log}
    #Stop Bip Trace   target_dir=${save_log}
    Decoder Tttirace From Pcap To Csv    ${pacp}    ${save_log}/tti
    run keyword and continue on failure
    ...    check_log_with_au2anlysis    ini_path=${CURDIR}/ini/CB013071_case010_step2_tti_dl.ini    log_need_to_check=i
    ...    save_log_directory=${save_log}
    run keyword and continue on failure
    ...    check_log_with_au2anlysis    ini_path=${CURDIR}/ini/CB013071_case010_step2_tti_ul.ini    log_need_to_check=i
    ...    save_log_directory=${save_log}
    ${CB008322_UE_num1}    ${CB008322_UE_num2}    ${CB008322_UE_num3}
    ...    get SUBBAND UE numbers from PM counter
    run keyword and continue on failure    should be true    ${CB008322_UE_num1}==4
    run keyword and continue on failure    should be true    ${CB008322_UE_num2}==4
    run keyword and continue on failure    should be true    ${CB008322_UE_num3}==4
    ${DL_tput1}    ${DL_tput2}    ${DL_tput3}
    ...    get DL tput from PM counter
    run keyword and continue on failure    should be true    ${DL_tput1}>750
    run keyword and continue on failure    should be true    ${DL_tput2}>300
    run keyword and continue on failure    should be true    ${DL_tput3}>150
    ${PRB_BWP1}    ${PRB_BWP2}    ${PRB_BWP3}    ${PRB_BWP_ps}    ${PRB_used}
    ...    get BWPs PRB num from PM counter
    run keyword and continue on failure    should be true    ${PRB_BWP1}>0
    run keyword and continue on failure    should be true    ${PRB_BWP2}>0
    run keyword and continue on failure    should be true    ${PRB_BWP3}>0
    run keyword and continue on failure    should be true    ${PRB_BWP_ps}>0
    ${PRB_sum}=    evaluate    ${PRB_BWP1}+${PRB_BWP2}+${PRB_BWP3}+${PRB_BWP_ps}
    run keyword and continue on failure    should be true    ${PRB_sum}<=${PRB_used}
    [Teardown]    Stop capture GNB and AP Syslog in 'Step3_BWPs' File

Step4:Trigger EIRP control
    Start capture GNB and AP Syslog in 'Step4_EIRP' File
    Online recommissioning with delta json file    ${CURDIR}/ini/CB013071_case010_change_eirpControlPowerReductionFactorList.json
    Wait '300s' for stable
    #Start Bip Trace
    Start GNB Ttitrace With Streaming Mode
    Wait '0.2s' for stable
    ${save_log}=    Set Variable    ${TEST_LOG_DIRECTORY()}Step4_EIRP
    ${pacp}=    Stop GNB Ttitrace With Streaming Mode    save_path=${save_log}
    #Stop Bip Trace   target_dir=${save_log}
    Decoder Tttirace From Pcap To Csv    ${pacp}    ${save_log}/tti
    run keyword and continue on failure
    ...    check_log_with_au2anlysis    ini_path=${CURDIR}/ini/CB013071_case010_step2_tti_dl.ini    log_need_to_check=i
    ...    save_log_directory=${save_log}
    run keyword and continue on failure
    ...    check_log_with_au2anlysis    ini_path=${CURDIR}/ini/CB013071_case010_step2_tti_ul.ini    log_need_to_check=i
    ...    save_log_directory=${save_log}
    ${CB008322_UE_num1}    ${CB008322_UE_num2}    ${CB008322_UE_num3}
    ...    get SUBBAND UE numbers from PM counter
    run keyword and continue on failure    should be true    ${CB008322_UE_num1}==4
    #run keyword and continue on failure    should be true    ${CB008322_UE_num2}==4
    run keyword and continue on failure    should be true    ${CB008322_UE_num3}==4
    ${CB008247_UE_num1}    ${CB008247_UE_num2}    ${CB008247_UE_num3}
    ...    get DFT UE numbers from PM counter
    run keyword and continue on failure    should be true    ${CB008247_UE_num2}<=6
    ${DL_tput1}    ${DL_tput2}    ${DL_tput3}
    ...    get DL tput from PM counter
    run keyword and continue on failure    should be true    ${DL_tput1}>600
    run keyword and continue on failure    should be true    ${DL_tput2}>50
    run keyword and continue on failure    should be true    ${DL_tput3}>150
    ${PRB_BWP1}    ${PRB_BWP2}    ${PRB_BWP3}    ${PRB_BWP_ps}    ${PRB_used}
    ...    get BWPs PRB num from PM counter
    run keyword and continue on failure    should be true    ${PRB_BWP1}>0
    run keyword and continue on failure    should be true    ${PRB_BWP2}>0
    run keyword and continue on failure    should be true    ${PRB_BWP3}>0
    run keyword and continue on failure    should be true    ${PRB_BWP_ps}>0
    ${EIRP_control1}    ${EIRP_control2}    ${EIRP_control3}
    ...    get EIRP control num from PM counter
    run keyword and continue on failure    should be true    ${EIRP_control2}>0
    [Teardown]    Stop capture GNB and AP Syslog in 'Step4_EIRP' File


Attach UE to cell
    [Arguments]    ${ue_id}    ${pattern}
    ${ue_ability}    Obtain Ue Capability    ${pattern}
    ${attach_status}=    run keyword and return status    Airphone SA Attach    ue_id=${ue_id}    timeout=60    ue_capability=${ue_ability}
    Run Keyword If    '${attach_status}'=='False'    Airphone SA Attach    ue_id=${ue_id}    timeout=60    ue_capability=${ue_ability}
    airphone_set_traffic_type    ${ue_id}    1    internal
    ${gw_id}=    evaluate    ${ue_id}%10 + 1
    ${pdu_status}=    run keyword and return status    Airphone Pdu Session Setup    ${ue_id}    1    1    ${gw_id}
    ${newNum}=    evaluate    0 + 8
    Run Keyword If    '${pdu_status}'=='False'    Airphone Pdu Session Setup    ${ue_id}    1    1    ${newNum}
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
    [Return]    ${CB008322_UE_cell1}    ${CB008322_UE_cell2}    ${CB008322_UE_cell3}

get DL tput from PM counter
    ${PM_counter_file}=    download_latest_pmcounter    local_path=${TEST_LOG_DIRECTORY()}conter_files${/}
    ${dl_tput_cell1}=           get_counter_value_from_counter_file    counter_file=${PM_counter_file}    counter_id=M55309C12001    cell_id=1
    ${dl_tput_cell2}=           get_counter_value_from_counter_file    counter_file=${PM_counter_file}    counter_id=M55309C12001    cell_id=2
    ${dl_tput_cell3}=           get_counter_value_from_counter_file    counter_file=${PM_counter_file}    counter_id=M55309C12001    cell_id=3
    ${dl_tput_cell1}    evaluate    ${dl_tput_cell1}*8/1024/1024
    ${dl_tput_cell2}    evaluate    ${dl_tput_cell2}*8/1024/1024
    ${dl_tput_cell3}    evaluate    ${dl_tput_cell3}*8/1024/1024
    [Return]    ${dl_tput_cell1}    ${dl_tput_cell2}    ${dl_tput_cell3}

get BWPs PRB num from PM counter
    ${PM_counter_file}=    download_latest_pmcounter    local_path=${TEST_LOG_DIRECTORY()}conter_files${/}
    ${PRB_BWP1}=      get_counter_value_from_counter_file    counter_file=${PM_counter_file}    counter_id=M55308C29001    cell_id=1
    ${PRB_BWP2}=      get_counter_value_from_counter_file    counter_file=${PM_counter_file}    counter_id=M55308C29003    cell_id=1
    ${PRB_BWP3}=      get_counter_value_from_counter_file    counter_file=${PM_counter_file}    counter_id=M55308C00085    cell_id=1
    ${PRB_BWP_PS}=    get_counter_value_from_counter_file    counter_file=${PM_counter_file}    counter_id=M55308C29005    cell_id=1
    ${PRB_used}=      get_counter_value_from_counter_file    counter_file=${PM_counter_file}    counter_id=M55308C10001    cell_id=1
    [Return]    ${PRB_BWP1}    ${PRB_BWP2}    ${PRB_BWP3}   ${PRB_BWP_PS}    ${PRB_used}

get EIRP control num from PM counter
    ${PM_counter_file}=    download_latest_pmcounter    local_path=${TEST_LOG_DIRECTORY()}conter_files${/}
    ${EIRP_control1}=      get_counter_value_from_counter_file    counter_file=${PM_counter_file}    counter_id=M55324C00301    cell_id=1
    ${EIRP_control2}=      get_counter_value_from_counter_file    counter_file=${PM_counter_file}    counter_id=M55324C00301    cell_id=2
    ${EIRP_control3}=      get_counter_value_from_counter_file    counter_file=${PM_counter_file}    counter_id=M55324C00301    cell_id=3
    [Return]    ${EIRP_control1}    ${EIRP_control2}    ${EIRP_control3}

get DFT UE numbers from PM counter
    ${PM_counter_file}=    download_latest_pmcounter    local_path=${TEST_LOG_DIRECTORY()}conter_files${/}
    ${CB008247_UE_cell1}=           get_counter_value_from_counter_file    counter_file=${PM_counter_file}    counter_id=M55196C00011    cell_id=1
    ${CB008247_UE_cell2}=           get_counter_value_from_counter_file    counter_file=${PM_counter_file}    counter_id=M55196C00011    cell_id=2
    ${CB008247_UE_cell3}=           get_counter_value_from_counter_file    counter_file=${PM_counter_file}    counter_id=M55196C00011    cell_id=3
    [Return]    ${CB008247_UE_cell1}    ${CB008247_UE_cell2}    ${CB008247_UE_cell3}