*** Settings ***
Documentation     CB010781 features.
Suite Setup       Common Suite Setup
Suite Teardown    Common Suite Teardown
Test Setup        Common Test Setup
Test Teardown     Common Test Teardown
Force Tags        CRT    CLOUD_FCC_CUS_A    SBTS00_FSM3    RAN_4G    RAN_4G_TDD
Library           ta_uexgate
Library           ta_messaging
Resource          ../../resources/KISS/robot/4g_common_resource.robot



*** Variables ***
${UE_CAPA}    DD80040A00007F068C4F001401828AA5640400FC440000E8080208100003FF0000016E280034452601803B5FC0A000CC00198003280010033C90000200001080
#${INPUT_SCFC_PATH}    ${CURDIR}${/}config_file${/}SCFC_CB010781_case01.xml
#${INPUT_CUS_yaml_PATH}    ${CURDIR}${/}config_file${/}CUS_CB010781_FSMF_case12.yaml
${scfc_path}    ${CURDIR}${/}config_file${/}SCFC_CB010781_case13.xml
${yaml_config}    ${CURDIR}${/}config_file${/}CUS_CB010781_FSMF_case13.yaml
${CUS_IP}         192.168.200.1
${FCT_IP}         192.168.255.1
${FTM_IP}         192.168.255.129
${cell_onair}     ${EMPTY}
${DL_THROUGHPUT_LOWER_THRESHOLD2cc}    100000
${DL_THROUGHPUT}    35
${UE_INDEX_1}     1
${UE_INDEX_2}     2

${UE_NUM_1}     1
${UE_NUM_2}     10
${QCI}     65
${UE_ID}     1
${CELL1_ID}     11
${START_UE_ID}    2
${END_UE_ID}    10
@{swconfig}         0x340000:15   0x10041:5

*** Test Cases ***
CB010781_A_case13_E-RAB_Modify_between_non-public_safety_video_GBR_with_QCI-67
     Add RD
     Prepare Enb Onair   ${scfc_path}    ${yaml_config}
#    Set R&D parameter
    Create aliases    1
    setup_enb_ttitrace    log_path=${TEST LOG DIRECTORY()}/macps_ttitrace    alias=enb1_ttitrace
    start_enb_ttitrace    node_type=ALL    cell_id=ALL    alias=enb1_ttitrace
    #step2
    Attach UEs from '${UE_ID}' to '${UE_ID}' in cell1
    Add bear '2' for UE E-RAB-ID '6'
    Start DL and UL data traffic
    Start data traffic for bear    bear_id=6
    Wait '5s' for stable
    run keyword and continue on failure    Verify throughput for one UE
    run keyword and continue on failure    Get and verify bear throughput average per ue    ue_id=1     bear_id=6
    run keyword and continue on failure    Get and verify bear throughput average per ue    ue_id=1     bear_id=6    direction=dl
    stop_and_decode_enb_ttitrace    alias=enb1_ttitrace
    teardown_all_alias_for_enb_ttitrace
    run keyword and continue on failure    Check ttitrace no bler
    run keyword and continue on failure    Check ttitrace qci9 qci2 schedule    macps_ttitrace
#
    #step3
    Add bear '69' for UE E-RAB-ID '7'
    Wait '5s' for stable
    Modify safe bear from qci2 to qci67
#    Start data traffic for bear    bear_id=6
#
    setup_enb_ttitrace    log_path=${TEST LOG DIRECTORY()}/ttitrace_qci9_67_69    alias=enb1_ttitrace
    start_enb_ttitrace    node_type=ALL    cell_id=ALL    alias=enb1_ttitrace
    Wait '3s' for ttitrace
    Verify throughput for one UE
    stop_and_decode_enb_ttitrace    alias=enb1_ttitrace
    teardown_all_alias_for_enb_ttitrace
    run keyword and continue on failure    Check ttitrace no bler
    run keyword and continue on failure    Check ttitrace qci9 qci67 qci69 schedule    ttitrace_qci9_67_69

    #step4
    Modify safe bear from qci67 to qci2
    setup_enb_ttitrace    log_path=${TEST LOG DIRECTORY()}/ttitrace_qci9_2_69   alias=enb1_ttitrace
    start_enb_ttitrace    node_type=ALL    cell_id=ALL    alias=enb1_ttitrace
    Wait '3s' for ttitrace
    Verify throughput for one UE
    run keyword and continue on failure    Get and verify bear throughput average per ue    ue_id=1     bear_id=6    direction=ul
    run keyword and continue on failure    Get and verify bear throughput average per ue    ue_id=1     bear_id=6    direction=dl
    stop_and_decode_enb_ttitrace    alias=enb1_ttitrace
    teardown_all_alias_for_enb_ttitrace
    run keyword and continue on failure    Check ttitrace no bler
    run keyword and continue on failure    Check ttitrace qci9 qci2 qci69 schedule    ttitrace_qci9_2_69
#
    #step6
    Del UL bler
    Wait '5s' for stable
    run keyword and continue on failure    Modify safe bear from qci2 to qci67
    setup_enb_ttitrace    log_path=${TEST LOG DIRECTORY()}/ttitrace_qci9_67_69_2    alias=enb1_ttitrace
    start_enb_ttitrace    node_type=ALL    cell_id=ALL    alias=enb1_ttitrace
    Wait '3s' for ttitrace
    stop_and_decode_enb_ttitrace    alias=enb1_ttitrace
    teardown_all_alias_for_enb_ttitrace
    Verify throughput for one UE
    run keyword and continue on failure    Get and verify bear throughput average per ue    ue_id=1     bear_id=6    direction=ul
    run keyword and continue on failure    Get and verify bear throughput average per ue    ue_id=1     bear_id=6    direction=dl
    run keyword and continue on failure    Check ttitrace no bler
    run keyword and continue on failure    Check ttitrace qci9 qci67 qci69 schedule    ttitrace_qci9_67_69_2

    #step7
    run keyword and continue on failure    Modify safe bear from qci67 to qci4 fail
    setup_enb_ttitrace    log_path=${TEST LOG DIRECTORY()}/ttitrace_qci9_67_69_3    alias=enb1_ttitrace
    start_enb_ttitrace    node_type=ALL    cell_id=ALL    alias=enb1_ttitrace
    Wait '3s' for ttitrace
    stop_and_decode_enb_ttitrace    alias=enb1_ttitrace
    teardown_all_alias_for_enb_ttitrace
#    Check ttitrace no bler    macps_ttitrace_4
    Verify throughput for one UE
    run keyword and continue on failure    Get and verify bear throughput average per ue    ue_id=1     bear_id=6    direction=ul
    run keyword and continue on failure    Get and verify bear throughput average per ue    ue_id=1     bear_id=6    direction=dl

    run keyword and continue on failure    Check ttitrace no bler
    run keyword and continue on failure    Check ttitrace qci9 qci67 qci69 schedule    ttitrace_qci9_67_69_3

    Detach UE


*** Keywords ***
Add RD
    ${enb_swconfig_modified_file}    Add ENB Swconfig    @{swconfig}
    Set Suite Variable    ${enb_swconfig_file}    ${enb_swconfig_modified_file}
    ENB Upload Swconfig    ${enb_swconfig_file}

Set R&D parameter
    runkeyword and continue on failure    Set Rad Parameter    setlog    ALL    ALL    FID_DL_CONGESTION   DEBUG
    ...    hw_ver=fsmr3
    runkeyword and continue on failure    Set Rad Parameter    setlog    ALL    ALL    FID_UL_CONGESTION   DEBUG
    ...    hw_ver=fsmr3

Attach UEs from '${low_id}' to '${high_id}' in cell1
    FOR    ${num}    IN RANGE    ${low_id}   ${high_id}+1
        log to console  attach ue ${num}
        CUS Attach    ${num}    ${CELL1_ID}    ue_eutra_capabilities=${UE_CAPA}
        sleep  1
    END
#        run keyword and ignore error    Add safe bears for UEs    ${num}
#        log to console  add safe bear for ue ${num}
#        sleep  1


Add bear '${qci}' for UE E-RAB-ID '${eRAB_ID}'
    Expect Message Flow
    ...   MME_1:S1AP_E-RABSetupRequest (E-RABSetupRequest contains ((qCI eq ${QCI}) and (e-RAB-ID eq ${eRAB_ID})))
    ...   MME_1:S1AP_E-RABSetupResponse (E-RABSetupResponse contains (e-RAB-ID eq ${eRAB_ID}))
    ...   alias=UE_1_flow    overall_timeout=20
    sleep    1
    Run UEx command  bearer_add ue=1 qci=${qci} mbr_dl=128 mbr_ul=128 gbr_dl=128 gbr_ul=128

Add safe bears for UEs
    [Arguments]    ${UE_ID}
    Run UEx command  bearer_add ue=${UE_ID} qci=69
    Expect Message Flow
    ...   MME_1:S1AP_E-RABSetupRequest (E-RABSetupRequest contains ((qCI eq ${QCI}) and (e-RAB-ID eq 7)))
    ...   MME_1:S1AP_E-RABSetupResponse (E-RABSetupResponse contains (e-RAB-ID eq 7))
    ...   alias=UE_${UE_ID}_flow    overall_timeout=20
    sleep  1
    Run UEx command    bearer_add ue=${UE_ID} qci=${QCI} mbr_dl=31 mbr_ul=31 gbr_dl=31 gbr_ul=31
    Flow Occurred As Expected     alias=UE_${UE_ID}_flow

Start data traffic for '${bearer_id}' UE '${UE_ID}'
    log to console  send bear 5 ul_dl for ue${UE_ID}
    CUS Start UL Udp Data Traffic    ${UE_ID}    1M    bearer=${bearer_id}
    Sleep    1
    CUS Start DL Udp Data Traffic    ${UE_ID}    5M    bearer=${bearer_id}
    Sleep    1

Start data traffic for QCI2 and QCI9 '${low_id}' to '${high_id}' UEs
    FOR    ${num}    IN RANGE    ${low_id}    ${high_id}+1
        log to console  send bear 5 ul_dl for ue${num}
        CUS Start UL Udp Data Traffic    ${num}    1M    bearer=5
        Sleep    1
        CUS Start DL Udp Data Traffic    ${num}    5M    bearer=5
        Sleep    1
        log to console  send bear 7 ul_dl for ue${num}
        run keyword and ignore error    CUS Start UL Udp Data Traffic    ${num}    1M    bearer=6
        Sleep    1
        run keyword and ignore error    CUS Start DL Udp Data Traffic    ${num}    5M    bearer=6
    END

Start data traffic for QCI9 and QCI69 '${low_id}' to '${high_id}' UEs
    FOR    ${num}    IN RANGE    ${low_id}    ${high_id}+1
        log to console  send bear 5 ul_dl for ue${num}
        CUS Start UL Udp Data Traffic    ${num}    1M    bearer=5
        Sleep    1
        CUS Start DL Udp Data Traffic    ${num}    5M    bearer=5
        Sleep    1
        log to console  send bear 7 ul_dl for ue${num}
        run keyword and ignore error    CUS Start UL Udp Data Traffic    ${num}    1M    bearer=7
        Sleep    1
        run keyword and ignore error    CUS Start DL Udp Data Traffic    ${num}    5M    bearer=7
    END

Start DL and UL data traffic
    CUS Start UL Udp Data Traffic    1    10M
    CUS Start DL Udp Data Traffic    1    150M
    Sleep    10

Start data traffic for bear
    [Arguments]   ${bear_id}=5    ${ue_id}=1
    CUS Start UL Udp Data Traffic    1    1M    bearer=${bear_id}
    CUS Start DL Udp Data Traffic    1    5M    bearer=${bear_id}
    Sleep    10


Attach'${UE_NUM}'UEs and send full data
    FOR    ${num}    IN RANGE    ${START_UE_ID}    ${UE_NUM}+1
        log to console  attach ue ${num}
        CUS Attach    ${num}    ${CELL1_ID}
        Sleep    10
        Start non-GBR data traffic for'${num}'
    END

Start non-GBR data traffic for'${UE_ID}'
    CUS Start UL Udp Data Traffic    ${UE_ID}    100M
    CUS Start DL Udp Data Traffic    ${UE_ID}    100M
    Sleep    10

Verify throughput
    ${ul_tput_ave}=    CUS Get UL Throughput Ave    1    dl_mac    Mbps
    ${dl_tput_ave}=    CUS Get DL Throughput Ave    1    dl_mac    Mbps
    ${dl_throughput_pcell}    CUS Get Throughput On Specific Scell    1    dl_mac    scell_id=0    tput_type=avg
    should_be_true    ${ul_tput_ave}>5
    should_be_true    ${dl_tput_ave}>70
    should_be_true    ${dl_throughput_pcell}>100000

Verify UEs throughput‘${UE_NUM}’
     ${UEs_TP_DL_list}   create list
     ${UEs_TP_UL_list}   create list
    FOR    ${num}    IN RANGE    1    ${UE_NUM}+1
        ${ul_tput_ave}=    CUS Get UL Throughput Ave    ${num}    ul_mac
        ${dl_tput_ave}=    CUS Get DL Throughput Ave    ${num}    dl_mac
        append to list    ${UEs_TP_DL_list}    ${dl_tput_ave}
        append to list    ${UEs_TP_UL_list}    ${ul_tput_ave}
    END
    log to console    ${UEs_TP_DL_list}
    log to console    ${UEs_TP_UL_list}

Stop bear data traffic
   CUS Stop UL Udp Data Traffic    1
   CUS Stop DL Udp Data Traffic    1


Detach UE
    Comment    CUS Detach    1
    Comment    Sleep    1
    CUS All Detach

clear uex logs
    run    cd /home/cus/logs/uex/;rm -rf *

Start UE2 data traffic
    CUS Start UL Udp Data Traffic    2    10M    bearer=5
    CUS Start DL Udp Data Traffic    2    150M
    Sleep    10

Verify throughput for one UE
    Get and verify DL and UL throughput average per ue    ${UE_INDEX_1}    ${DL_THROUGHPUT}


Get and verify DL and UL throughput average per ue
    [Arguments]    ${ue_id}=1    ${dl_tput}=1
    ${ul_tput_ave}=    CUS Get UL Throughput Ave    ${ue_id}    ul_mac    Mbps
    ${dl_tput_ave}=    CUS Get DL Throughput Ave    ${ue_id}    dl_mac    Mbps
    should_be_true    ${dl_tput_ave}>${dl_tput}

Get and verify bear throughput average per ue
    [Arguments]    ${ue_id}=1    ${bear_id}=5    ${direction}=ul    ${expect_tput}=0.1
    ${tput_cur}    Cus Get Througput For Each Bearer    ${ue_id}    ${direction}    ${bear_id}    tput_type=cur
    log to console    ue=${ue_id} bear=${bear_id} ${direction} tput=${tput_cur}
#    should_be_true    ${tput_cur}>=${expect_tput}

Check UExlog
    run    mkdir ${TEST LOG DIRECTORY()}/uex_logs
    run    cp -rf /home/cus/logs/uex/latest/* \ ${TEST LOG DIRECTORY()}/uex_logs/
    ${cmd}    Set Variable    uesim-dump ${TEST LOG DIRECTORY()}/uex_logs/cell-11.log > ${TEST LOG DIRECTORY()}/uex_logs/cell-11_decode.log
    OperatingSystem.Run    ${cmd}
    check_log_with_au2anlysis    ini_path=${CURDIR}/ini/case01.ini    log_need_to_check=p    save_log_directory=${TEST LOG DIRECTORY()}/uex_logs/
#     check_log_with_au2anlysis    ini_path=${CURDIR}/ini/test1.ini    log_need_to_check=p    save_log_directory=${file_path}


Add bear6965
    Run UEx command  bearer_add ue=1 qci=69
    Expect Message Flow
    ...  MME_1:S1AP_E-RABSetupRequest (E-RABSetupRequest contains ((qCI eq 65) and (e-RAB-ID eq 6)))
    ...  MME_1:S1AP_E-RABSetupResponse (E-RABSetupResponse contains (e-RAB-ID eq 6))
    ...  alias=UE_1_flow    overall_timeout=20
	Run UEx command  bearer_add ue=1 qci=65 mbr_dl=31 mbr_ul=31 gbr_dl=31 gbr_ul=31
	Flow Occurred As Expected    alias=UE_1_flow

Add safe bears for UE
    [Arguments]    ${UE_ID}    ${rate}=31
    Expect Message Flow
    ...   MME_1:S1AP_E-RABSetupRequest (E-RABSetupRequest contains ((qCI eq ${QCI}) and (e-RAB-ID eq 7)))
    ...   MME_1:S1AP_E-RABSetupResponse (E-RABSetupResponse contains (e-RAB-ID eq 7))
    ...   alias=UE_${UE_ID}_flow    overall_timeout=20
    sleep  1
    Run UEx command    bearer_add ue=${UE_ID} qci=${QCI} mbr_dl=${rate} mbr_ul=${rate} gbr_dl=${rate} gbr_ul=${rate}
    Flow Occurred As Expected     alias=UE_${UE_ID}_flow

Del safe bears for UE
    [Arguments]    ${UE_ID}
#    Expect Message Flow
##    ...  MME_1:S1AP_E-RABSetupRequest contains ((qCI eq "65"));
#    ...  MME_1:S1AP_E-RABReleaseCommand contains ((qCI eq "${QCI}") and (e-RAB-ID eq 7))
#    ...   MME_1:S1AP_E-RABSetupResponse contains (e-RAB-ID eq 7)
#    ...   alias=UE_${UE_ID}_flow    overall_timeout=20
#    sleep  1
    cus_execute_uex_command   bearer_del ue=${UE_ID} qci=${QCI}
#    Flow Occurred As Expected     alias=UE_${UE_ID}_flow


Modify safe bear from qci2 to qci67
    Expect Message Flow
    ...   MME_1:S1AP_E-RABModifyRequest (E-RABModifyRequest contains ((qCI eq 67)))
    ...   MME_1:S1AP_E-RABModifyResponse (E-RABModifyListBearerModRes contains (e-RAB-ID eq 6))
    ...   alias=UE_${UE_ID}_flow    overall_timeout=20
    sleep  1
    iphy_execute_egate_command    bearer_mod ue\=1 id\=2 qci\=67
    Flow Occurred As Expected     alias=UE_${UE_ID}_flow

Modify safe bear from qci2 to qci67 fail
    Expect Message Flow
    ...   MME_1:S1AP_E-RABModifyRequest (E-RABModifyRequest contains ((qCI eq 67)))
    ...   MME_1:S1AP_E-RABModifyResponse (E-RABModifyResponse contains (radioNetwork eq 'interaction-with-other-procedure'))
    ...   alias=UE_${UE_ID}_flow    overall_timeout=20
    sleep  1
    iphy_execute_egate_command    bearer_mod ue\=1 id\=2 qci\=67
    Flow Occurred As Expected     alias=UE_${UE_ID}_flow



Modify safe bear from qci67 to qci2
    Expect Message Flow
    ...   MME_1:S1AP_E-RABModifyRequest (E-RABModifyRequest contains (qCI eq 2))
    ...   MME_1:S1AP_E-RABModifyResponse (E-RABModifyListBearerModRes contains (e-RAB-ID eq 6))
    ...   alias=UE_${UE_ID}_flow    overall_timeout=20
    sleep  1
    iphy_execute_egate_command    bearer_mod ue\=1 id\=2 qci\=2
    Flow Occurred As Expected     alias=UE_${UE_ID}_flow

Modify safe bear from qci67 to qci4 fail
     Expect Message Flow
    ...   MME_1:S1AP_E-RABModifyRequest (E-RABModifyRequest contains (qCI eq 4))
    ...   MME_1:S1AP_E-RABModifyResponse (E-RABModifyResponse contains (radioNetwork eq 'unspecified'))
    ...   alias=UE_${UE_ID}_flow    overall_timeout=20
    sleep  1
    iphy_execute_egate_command    bearer_mod ue\=1 id\=2 qci\=4
    Flow Occurred As Expected     alias=UE_${UE_ID}_flow


Add UL bler
	Run UEx command  ue_ul_power_control id=1 pathloss=120
	Run UEx command  ue_harq_error id=1 scell=primary ul_err_ratio=1-7:1000:500:0

Del UL bler
	Run UEx command  ue_ul_power_control id=1 pathloss=0
    Run UEx command  ue_harq_error id=1 scell=primary ul_err_ratio=1-7:1000:0:0

Online change parameter of blockTtiBundling to true
#    Start enb and cus syslog'5'
    setup admin                          bts_host=192.168.255.129       bts_port=443        use_ssl=True           alias=delta_commission
    perform_delta_recommissioning    delta_file=${CURDIR}/config_file/cell1_blockTtiBundling_true.json        skip_parameter_relation_errors=true
    ...    alias=delta_commission
    teardown admin                       alias=delta_commission
    sleep    30



Check ttitrace no bler
    [Arguments]    ${tti_dir}=macps_ttitrace
    check_log_with_au2anlysis    ini_path=${CURDIR}/ini/tti_no_dl_bler_case13.ini    log_need_to_check=i
    ...    save_log_directory=${TEST LOG DIRECTORY()}/${tti_dir}
    check_log_with_au2anlysis    ini_path=${CURDIR}/ini/tti_no_ul_bler_case13.ini    log_need_to_check=i
    ...    save_log_directory=${TEST LOG DIRECTORY()}/${tti_dir}

Check ttitrace qci9 qci2 schedule
    [Arguments]    ${tti_dir}=macps_ttitrace
    check_log_with_au2anlysis    ini_path=${CURDIR}/ini/tti_qci9_qci2_schedule_case13.ini    log_need_to_check=i    
    ...    save_log_directory=${TEST LOG DIRECTORY()}/${tti_dir}

Check ttitrace qci9 qci67 qci69 schedule
    [Arguments]    ${tti_dir}=macps_ttitrace
    check_log_with_au2anlysis    ini_path=${CURDIR}/ini/tti_qci9_qci67_qci69_schedule_case13.ini    log_need_to_check=i    
    ...    save_log_directory=${TEST LOG DIRECTORY()}/${tti_dir}

Check ttitrace qci9 qci2 qci69 schedule
    [Arguments]    ${tti_dir}=macps_ttitrace
    check_log_with_au2anlysis    ini_path=${CURDIR}/ini/tti_qci9_qci2_qci69_schedule_case13.ini    log_need_to_check=i    
    ...    save_log_directory=${TEST LOG DIRECTORY()}/${tti_dir}


Check ttitrace qci67 no schedule
    [Arguments]    ${tti_dir}=macps_ttitrace_2
    check_log_with_au2anlysis    ini_path=${CURDIR}/ini/tti_qci67_no_schedule.ini    log_need_to_check=i    
    ...    save_log_directory=${TEST LOG DIRECTORY()}/${tti_dir}

Check ttitrace bundling
    [Arguments]    ${tti_dir}=macps_ttitrace
    check_log_with_au2anlysis    ini_path=${CURDIR}/ini/tti_ul_bundling_case13.ini    log_need_to_check=i    
    ...    save_log_directory=${TEST LOG DIRECTORY()}/${tti_dir}

Wait '${time}' for stable
    sleep    ${time}

Wait '${time}' for ttitrace
    sleep    ${time}
