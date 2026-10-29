*** Settings ***
Documentation     Author: qianqian.ren@nokia-sbell.com...
...               QC case full name:
...               CB014094-SR-C_01_Loki_Online_modification_actUlMuMimo _with_four_RANK2_UE

Suite Setup       Common Suite Setup
Suite Teardown    Common Suite Teardown
Test Setup        Common Test Setup
Test Teardown     Common Test Teardown
Force Tags        CLOUD_5G_I_BOO_AP_LOO    AP    CRT    SBTS00    SBTS00    RAN_5G_TDD    RAN_5G    owner_qiaren
Test Timeout      90 minutes
Resource          ../../resources/KISS/robot/common_resource.robot
Resource          ../../resources/sg11/internal_resource/robot/modify_configuration.robot
Resource          ../../resources/sg11/internal_resource/robot/internal_ap_operate.robot
Resource          ../../resources/sg11/internal_resource/robot/internal_gnb_operate.robot
Resource          ../../resources/sg11/internal_resource/robot/internal_capture_log.robot

*** Variables ***
${CONFIG_DIR_PATH}    ${CURDIR}/config/
${SCFC_NAME}          CB014094_C_01_SCFC.xml
${AIRPHONE_NAME}      IPHY_CB014094_C_01.xml
${WTS_NAME}           wts_CB014094_C_01.lua

@{LOG_NAME_LIST}      gnb_snapshot    sosreport    egatelog\
${PROFILE1}    ul_mimo_srs_beam_pos_nr profile_id=1 mode=fixed init_quad_pos=3 init_sub_quad_pos=3 step=5 trigger_puxch_update=0
                   ...    multi_path_config=0 test_type=UL_MIMO
${PROFILE2}    ul_mimo_srs_beam_pos_nr profile_id=2 mode=fixed init_quad_pos=1 init_sub_quad_pos=1 step=5 trigger_puxch_update=0
                   ...    multi_path_config=0 test_type=UL_MIMO
${PROFILE3}    ul_mimo_srs_beam_pos_nr profile_id=3 mode=fixed init_quad_pos=2 init_sub_quad_pos=3 step=5 trigger_puxch_update=0
                   ...    multi_path_config=0 test_type=UL_MIMO
${PROFILE4}    ul_mimo_srs_beam_pos_nr profile_id=4 mode=fixed init_quad_pos=0 init_sub_quad_pos=1 step=5 trigger_puxch_update=0
                   ...    multi_path_config=0 test_type=UL_MIMO


*** Test Cases ***
CB014094-SR-C_01_Loki_Online_modification_actUlMuMimo _with_four_RANK2_UE
    Step1:Test Prepare For Onair
    Step2:4RANK2 UE Attach and check
    Step3:OnLine Change and check agagin
    Step4:Detach ues

*** Keywords ***
Step1:Test Prepare For Onair
    Start Collect GNB and AP Syslog in 'Step1_before_onair' File
    ${CONFIG_DIR_PATH}    Set Variable    ${CONFIG_DIR_PATH}/${SW_BRANCH}
    change_iphy_rru_version    ${CONFIG_DIR_PATH}${/}${AIRPHONE_NAME}
    ${scfc_path}    Set Variable    ${TEST_LOG_DIRECTORY()}${/}scfc.xml
    copy_file    ${CONFIG_DIR_PATH}/${SCFC_NAME}    ${scfc_path}
    Modify TL VM And AP SCTP Configuration
    Get and Update BSR File    par_of_bsr_name=BSR_AEHC_6_H6_ALN60_ARP60_P00_COVERAGE_00424_00001
    Get and Update BSR File    par_of_bsr_name=BSR_AQQL_6_H6_ALN60_ARP60_P00_COVERAGE_00424_00001
    Perform Full Commission And Reach Onair With Log    ${scfc_path}    ${CONFIG_DIR_PATH}${/}${WTS_NAME}    reset_after_commission=${False}
    [Teardown]    Stop Collect GNB and AP Syslog in 'Step1_before_onair' File

Step2:4RANK2 UE Attach and check
    Start capture gnb and ap syslog in 'Step2_attach' file
    Attach 4 SA UE
    Set UEs position
    ues send ul data
    Wait Throughput Timer    60
    get ul thp by egate nomumimo
    ${save_log}=    Set Variable    ${TEST_LOG_DIRECTORY()}Step2_attach
    ${counter_file}    download PM counter file    ${save_log}
    ${UL_thp_counter}=    get_counter_value_from_counter_file    counter_file=${counter_file}   counter_id=M55309C12002   cell_id=5
    ${PAIR_UE_PUSCH}=    get_counter_value_from_counter_file    counter_file=${counter_file}   counter_id=M55308C35010   cell_id=5
    ${ELIG_UE_PUSCH}=    get_counter_value_from_counter_file    counter_file=${counter_file}   counter_id=M55308C35011   cell_id=5
    should be true    ${UL_thp_counter} > 4000000
    should be true    ${PAIR_UE_PUSCH} == 0
    should be true    ${ELIG_UE_PUSCH} == 0
    [Teardown]    Stop capture gnb and ap syslog in 'Step2_attach' file

Step3:OnLine Change and check agagin
    Start capture gnb and ap syslog in 'Step3' file
    Online change actUlMuMimo to true
    Wait Throughput Timer    60
    ${save_log}=    Set Variable    ${TEST_LOG_DIRECTORY()}Step3_after_online
    Start GNB Ttitrace With Streaming Mode
    Wait Throughput Timer    2
    ${pacp}=    Stop GNB Ttitrace With Streaming Mode    save_path=${save_log}
    Decoder Tttirace From Pcap To Csv    ${pacp}    ${save_log}${/}tti
    ${save_log}=    Set Variable    ${TEST_LOG_DIRECTORY()}Step3
    get ul thp by egate mumimo
    ${counter_file}    download PM counter file    ${save_log}
    ${UL_thp_counter}=    get_counter_value_from_counter_file    counter_file=${counter_file}   counter_id=M55309C12002   cell_id=5
    ${PAIR_UE_PUSCH}=    get_counter_value_from_counter_file    counter_file=${counter_file}   counter_id=M55308C35010   cell_id=5
    ${ELIG_UE_PUSCH}=    get_counter_value_from_counter_file    counter_file=${counter_file}   counter_id=M55308C35011   cell_id=5
    should be true    ${UL_thp_counter} > 17000000
    should be true    ${PAIR_UE_PUSCH} > 140000
    should be true    ${ELIG_UE_PUSCH} > 140000
    [Teardown]    Stop capture gnb and ap syslog in 'Step3' file

Step4:Detach ues
    Detach '4'UE


Attach 4 SA UE
     FOR    ${i}    IN RANGE    1    5
       airphone_cleanup_egate_console_log
       Airphone SA Attach    ue_id=${i}
       Wait '2S' for stable running
       Airphone Set Traffic Type    ue_id=${i}    pdu_id=1    type=internal
       Wait '2S' for stable running
       Airphone Pdu Session Setup    ue_id=${i}   pdu_id=1   nwslice_id=1
       Wait '2S' for stable running
     END

Set UEs position
    airphone_execute_egate_command    ${PROFILE1}
    airphone_execute_egate_command
    ...    ue_testmode_set_nr id\=1 testmode\=ul_mimo_srs_beam_pos action\=activate profile_id\=1
    airphone_execute_egate_command    ${PROFILE2}
    airphone_execute_egate_command
    ...    ue_testmode_set_nr id\=2 testmode\=ul_mimo_srs_beam_pos action\=activate profile_id\=2
    airphone_execute_egate_command    ${PROFILE3}
    airphone_execute_egate_command
    ...    ue_testmode_set_nr id\=3 testmode\=ul_mimo_srs_beam_pos action\=activate profile_id\=3
    airphone_execute_egate_command    ${PROFILE4}
    airphone_execute_egate_command
    ...    ue_testmode_set_nr id\=4 testmode\=ul_mimo_srs_beam_pos action\=activate profile_id\=4


ues send ul data
    FOR    ${u}    IN RANGE     1    5
         Airphone SA Start Data Traffic    ${u}    UL    100M    trf_id=1    pdu_id=1    duration=${7200}
    END

get ul thp by egate nomumimo
    FOR    ${u}    IN RANGE     1    5
        ${ue_ul_tput}=    Airphone Get Throughput On Specific Scell    ${u}    0    pusch    current
        Log To Console    ue${u} thp is ${ue_ul_tput}
        should be true    ${ue_ul_tput}>9000
    END

get ul thp by egate mumimo
    FOR    ${u}    IN RANGE     1    5
        ${ue_ul_tput}=    Airphone Get Throughput On Specific Scell    ${u}    0    pusch    current
        Log To Console    ue${u} thp is ${ue_ul_tput}
        should be true    ${ue_ul_tput}>35000
    END

Online change actUlMuMimo to true
    COAM.Connect To    bts_host=192.168.255.129    bts_port=443    use_ssl=True    name=online
    COAM.perform_parameter_recommissioning    dist_name=MRBTS-1/NRBTS-1/NRCELL-5    parameter=actUlMuMimo
    ...    operation=update    value=true    skip_parameter_relation_errors=True    should_activate=True    connection=online
    Wait until keyword succeeds    600s    30s    Verify BTS Is Onair
    COAM.teardown admin    connection=online
