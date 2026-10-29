*** Settings ***
Library    OperatingSystem
Library    Collections
Library    BuiltIn
Library    String

Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/siso_common_case/step_keywords/5G/ald_operation.robot
Resource    Resources/5GC000746_common_keyword.robot
Resource    testsuite/Hangzhou/SISO/RAN_PZ_HAZ_34/5GC001783/Resources/5GC001783_5GC002040_Keywords.robot
Variables    Resources/5GC000746_A_variables.py

Documentation
...   author: Chen Tong
...   contact: tong.chen@nokia-sbell.com
...   squad group: SG_02

#Force Tags    5G_SISO         master_classicalbts_all    STATE_SW_UPLOADED    SBTS00    5G_RAN    5G_RAN_TDD
#...    PY39
#...           RAN_5G    RAN_5G_TDD    CIT    CLOUD_5G_CLASSICAL_ANDROID_ASIBL_ABILB1_AEQB_ENB

#Suite Setup     Run Keywords    SG2_Common_setup_teardown.Common Suite setup    if_commissioning=${True}
#...             AND    Upgrade geckodriver workround

Suite Setup     SG2_Common_setup_teardown.Common Suite setup    if_commissioning=${True}

*** Variables ***
#${tshark_path_for_746}    /usr/bin/tshark
#${luashark_path}    /opt/luashark/luashark.lua
#${command_template}
#...    {tshark_path} -o swe.call_mac_nr:TRUE -r {pcap_file} -X lua_script:${luashark_path} -Y ${expression_cmas_sib8} -T pdml
#${command_template_sib1}
#...    {tshark_path} -o swe.call_mac_nr:TRUE -r {pcap_file} -X lua_script:${luashark_path} -Y ${expression_cmas_sib1} -T pdml
#${command_template_bip_cell1}
#...    {tshark_path} -o swe.call_mac_nr:TRUE -r {pcap_file} -X lua_script:${luashark_path} -Y ${bip_expression_cmas_cell1} -T pdml
#${command_template_bip_cell2}
#...    {tshark_path} -o swe.call_mac_nr:TRUE  -r {pcap_file} -X lua_script:${luashark_path} -Y ${bip_expression_cmas_cell2} -T pdml

${scf_dir_746}    ${CURDIR}/../../../../../commissionings/HGZ/${testline_name}
#${sib8_sfn}    DlData_PdschPayloadTbSendReq.PdschPayloadTbSendReq.sfn
#${sib8_slot}    DlData_PdschPayloadTbSendReq.PdschPayloadTbSendReq.slot
#${filter_sib8_sfn}    DlData_PdschPayloadTbSendReq.PdschPayloadTbSendReq.sfn
#${filter_sib8_slot}    DlData_PdschPayloadTbSendReq.PdschPayloadTbSendReq.slot
#${dldata_subcellid}    DlData_PdschPayloadTbSendReq.PdschPayloadTbSendReq.subcellId
${mcc_filter}    e212.5gstai.mcc
${mnc_filter}    e212.5gstai.mnc

#@{amfs}    chu_amf    han_amf    sui_amf    zhou_amf    liang_amf    tang_amf    feng_amf
@{amfs}    zheng_amf1    feng_amf    shen_amf    han_amf    sui_amf    zhou_amf    liang_amf    tang_amf    chu_amf

${default_cmas}    /home/cbctest/HZ_SG2_CIT/test_amf_cit_normal.py
${long_cmas}    /home/cbctest/HZ_SG2_CIT/test_amf_long_new.py
${short_cmas}    /home/cbctest/HZ_SG2_CIT/test_amf_short_new.py
${cmas_trigger}    /home/cbctest/HZ_SG2_CIT/testcasenew

&{fault_61524}    faultId=${61524}    source=-    #faultId:SSH_ENABLED  source:RU1
&{fault_61652}    faultId=${61652}    source=-    #faultId:R&D_SERVICE_PORT_ENABLED  source:RU1

&{feng_amf}    connect_hostname=10.110.194.163    mcc=262    mnc=03    tac=270


*** Test Cases ***
[1][1.0] 5GC000746_A_026_Verify CMAS coded 4 pages broadcast in RRC_CONNECTED state
    [Tags]    case26    CIT_TRUNK    CIT_22R3    CIT_22R2    CIT_22R4
    [Setup]    5GC000746 Case Setup    cell_group_id=${4}
#    COAM commission scf and wait cell setup    scf_file_path=${scf_dir_746}/${ENB_BRANCH}_scf_SA_rf64.xml
    ${ue_type}    ue.translate_power_ue_type_from_testline    ue_index=${1}
    power_ue.Prepare UE    ue_type=${ue_type}    ue_index=${1}    reset_sol=True
    Sleep    30s
    UE attach and Check Ciphering algorithm    ue_type=${ue_type}     cipheringAlgorithm=2    ue_index=${1}    power_reset=True
    COAM Update several parameters via webUI    parameters_to_update_via_webui=${PARAM_1936_HA_543}
    ...                                         download_dir=${TS_CASE_LOG_PATH}
    ...                                         is_need_to_check_validation_errors=${False}
    UE attach and Check Ciphering algorithm    ue_type=${ue_type}     cipheringAlgorithm=0    ue_index=${1}    power_reset=True
    Prepare for Check SIB    ue_type=${ue_type}    ue_index=${1}
    Log to console    start to trigger CMAS
    ${ngap_log_1}    ${bip_log_1}    Trigger CMAS Notification and Capture Logs
    ...                                         amf=${current_amf}
    ...                                         warning_area_list_id=${warning_area_list}[warning_area_cgi_list_1cell]
    ...                                         cmas_file=${long_cmas}
    ...                                         message_identifier=4370
    ...                                         serial_number=31664
    ...                                         number_of_broadcasts_requested=${0}
    ...                                         cell_id=${4}
    ${ngap_log_2}    ${bip_log_2}    Trigger CMAS Notification and Capture Logs
    ...                                         amf=${current_amf}
    ...                                         warning_area_list_id=${warning_area_list}[warning_area_cgi_list_1cell]
    ...                                         cmas_file=${short_cmas}
    ...                                         message_identifier=4370
    ...                                         serial_number=31680
    ...                                         number_of_broadcasts_requested=${0}
    ...                                         cell_id=${4}
    spark.stop_log    ue_alias=UE_1    logname=${TS_CASE_LOG_PATH}/uelog_sigspark_RRC_CONNECTED_UE1.xml
    #power_ue.UE Detach    ue_type=${ue_type}    power_reset=True    ue_index=${1}
    ${wmc1}    ${wac1}    Check Complete Procedure for CMAS broadcasting    ngap_log=${ngap_log_1}
    ...                                                                     bip_log=${bip_log_1}
    ...                                                                     serial_number=31664
    ...                                                                     message_identifier=4370
    ...                                                                     number_of_broadcasts_requested=${0}
    ...                                                                     cellid=${17}
    ${wmc2}    ${wac2}    Check Complete Procedure for CMAS broadcasting    ngap_log=${ngap_log_2}
    ...                                                                     bip_log=${bip_log_2}
    ...                                                                     serial_number=31680
    ...                                                                     message_identifier=4370
    ...                                                                     number_of_broadcasts_requested=${0}
    ...                                                                     cellid=${17}
    ...                                                                     no_wac=${True}
    Check UE Log for SIB8    ue_type=${ue_type}    bip_log=${bip_log_1}    wmc=${wmc1}    wac=${wac1}
    ...                      message_identifier=4370    serial_number=31664    ue_index=${1}
    Check UE Log for SIB8    ue_type=${ue_type}    bip_log=${bip_log_2}    wmc=${wmc2}    wac=${wac2}
    ...                      message_identifier=4370    serial_number=31680    ue_index=${1}
    Disable Enable sim card on samsung UE    ue_index=${1}    enable=0
    ${emc_log}    EMC call and capture log    ue_index=${1}
    Prepare for Check SIB    ue_type=${ue_type}    ue_index=${1}
    Sleep    20s
    spark.stop_log    ue_alias=UE_1    logname=${TS_CASE_LOG_PATH}/uelog1_sigspark_RRC_CONNECTED_UE1.xml
    Check UE Log for SIB8    ue_type=${ue_type}    bip_log=${bip_log_1}    ue_index=${1}
    ...                      wmc=${wmc1}    wac=${wac1}    logname=${TS_CASE_LOG_PATH}/uelog1_sigspark_RRC_CONNECTED_UE1.xml
    ...                      message_identifier=4370    serial_number=31664
    Check UE Log for SIB8    ue_type=${ue_type}    bip_log=${bip_log_2}    ue_index=${1}
    ...                      wmc=${wmc2}    wac=${wac2}    logname=${TS_CASE_LOG_PATH}/uelog1_sigspark_RRC_CONNECTED_UE1.xml
    ...                      message_identifier=4370    serial_number=31680
    Disable Enable sim card on samsung UE    ue_index=${1}    enable=1
    Check EMC call in ngap log    emc_log=${emc_log}
    [Teardown]    5GC000746 Case Teardown

[1][1.0] 5GC000746_A_033_Verify counter NNGCC_WRWR_RES_SENT
    [Tags]    CIT_TRUNK    CIT_20A    CIT_21A
    [Setup]    5GC000746 Case Setup    cell_group_id=${4}
    Perform BTS Site Reset
    Sleep    5min
    COAM Wait for gnb ready and cell setup    gnb_type='SA'
    5GC000746 Case Reconnect
    FOR  ${item}  IN RANGE  5
        Trigger CMAS Notification and Capture Logs    amf=${current_amf}
        ...                                           warning_area_list_id=${warning_area_list}[warning_area_cgi_list_1cell]
        ...                                           serial_number=${item}
        ...                                           number_of_broadcasts_requested=${0}
        ...                                           cell_id=${4}
        Run Keyword And Ignore Error    coam.teardown_all_aliases_for_admin
        wait until keyword succeeds    1min    2sec    Connect to gnb coam via ssl
        Perform cell lock via rest api    cell_idx=${4}
        Wait Until Keyword Succeeds   5 min  5 sec   Cell Should Be Locked    cell_idx=${4}    cell_group_idx=${4}
        Perform cell unlock via rest api    cell_idx=${4}
        COAM Wait for gnb ready and cell setup    gnb_type='SA'
        5GC000746 Case Reconnect
        Wait Until Keyword Succeeds   5 min  5 sec   Unexpect Alarm Should Not Exist    allowed_faults=${ALLOWED_FAULT_LIST}
    END
    Sleep    8min
    ${cnt_list}    COAM Get BTS Counters via webUI    counter_id=${COUNTERS_746[0]}[counter_id]
    ${counter_sum}    Sum Value in Counter list    cnt_list=${cnt_list}
    Should Be Equal    ${counter_sum}    ${5}
    ${cnt_list}    COAM Get BTS Counters via webUI    counter_id=${COUNTERS_746[1]}[counter_id]
    ${counter_sum}    Sum Value in Counter list    cnt_list=${cnt_list}
    Should Be Equal    ${counter_sum}    ${5}
    ${cnt_list}    COAM Get BTS Counters via webUI    counter_id=${COUNTERS_746[2]}[counter_id]
    ${counter_sum}    Sum Value in Counter list    cnt_list=${cnt_list}
    Should Be Equal    ${counter_sum}    ${5}
    [Teardown]    5GC000746 Case Teardown
