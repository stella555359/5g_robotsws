*** Settings ***
Documentation     10781 features.
Suite Setup       Common Suite Setup
#Suite Teardown    Common Suite Teardown
Test Setup        Common Test Setup
Test Teardown     Common Test Teardown
Force Tags        QCD_MN_RAN    CRT    CLOUD_FCC_CUS_A    SBTS00    RAN_4G    RAN_4G_TDD    CLOUD_FCC_CUS
Resource          ../../resources/KISS/robot/4g_common_resource.robot

*** Variables ***
${scfc_path}    ${CURDIR}${/}config_file${/}SCFC_CB010781_FSMF_case14.xml
${yaml_config}    ${CURDIR}${/}config_file${/}CUS_CB010781_FSMF_case14.yaml
${CUS_IP}         192.168.200.1
${FCT_IP}         192.168.255.1
${FTM_IP}         192.168.255.129
${cell_onair}     ${EMPTY}
${UE_INDEX_1}     1
${UE_INDEX_2}     2
${qci}    67
${ue_num}   1
${DL_Cell_peak}    56
${UL_Cell_peak}    2
${Ho_time}    5
@{swconfig}    0x340000:15
    ...    0x10041:5
    ...    0xf000e:1
    ...    0xf000f:1
    ...    0xf0010:1
    ...    0xf0011:1
    ...    0x130020:1
    ...    0x130021:1
    ...    0x13001e:1
    ...    0x13001f:1
    ...    0x110001:1
    ...    0x110002:1
    ...    0x110003:1
    ...    0x110004:1
    ...    0x120004:1
    ...    0x120005:1
    ...    0x120006:1
    ...    0x150001:1
    ...    0x150002:1
    ...    0x150004:1
    ...    0x150003:1
@{PARAMS_IN_EMIL}
...  -n mac-cell-11-ul -e 0x2695 -e 0x2696 -e 0x26AE -e 0x26AF -e 0x26B0 -e 0x26B1
...  -n mac-cell-12-ul -e 0x2695 -e 0x2696 -e 0x26AE -e 0x26AF -e 0x26B0 -e 0x26B1
...  -n mac-cell-11-dl -e 0x2695 -e 0x2696 -e 0x3740 -e 0x26AF -e 0x26B0 -e 0x26B1
...  -n mac-cell-12-dl -e 0x2695 -e 0x2696 -e 0x3740 -e 0x26AF -e 0x26B0 -e 0x26B1

*** Test Cases ***
CB010781_A_case14_UL_and_DL_scheduling_for_E-RAB_with_QCI-67_after_HO
    step1:prepare eNB on air
    start syslog    log_dir=${TEST LOG DIRECTORY()}    log_name=enb1_btslog_startup    ip=192.168.255.126
    ...    file_limit=300000000    alias=enb1_btslog_startup
#    Start Emil Log    aashell_port=15007    extend_msg=${PARAMS_IN_EMIL}    alias=emil_attach_${qci}_69
    step2:attach UEs to cell11 with default69_${qci}
    step3:Intra-Enb Inter-Cell handover "${Ho_time}"times
#    Stop Emil Log     alias=emil_attach_${qci}_69
    step4:Reestablishment at cell11
    step5:Reestablishment at cell12
    step6:add qci7
    step7:Reestablishment at cell11 with qci7
    step8:Reestablishment at cell12
    Check UExlog
    Detach UE
    run keyword and continue on failure    collect_syslog_results    alias=enb1_btslog_startup
    run keyword and continue on failure    check err log

*** Keywords ***
Add RD
    ${enb_swconfig_modified_file}    Add ENB Swconfig    @{swconfig}
    Set Suite Variable    ${enb_swconfig_file}    ${enb_swconfig_modified_file}
    ENB Upload Swconfig    ${enb_swconfig_file}

check TP and bler with ttitrace
    [Arguments]    ${throughput}    ${time_avg}    ${tti_file}    ${ini_file}
    ${a}  get_ues_tbsize_by_sfn   ${test_log_directory()}/All/${tti_file}/tti_dl.csv
    ...        ${test_log_directory()}/All/${tti_file}/tti_dl_new.csv   ${time_avg}   filter=dlFdSchedData.ackNack\=ACK
    @{keys}  Get Dictionary Keys   ${a}
    FOR      ${key}     IN     @{keys}
        ${result}   evaluate  ${a[${key}]}/${time_avg}/1024/1000
        log to console   result is ${result}
        log to console   TP is ${throughput}
        should be true  ${result}>${throughput}
    END
    check_log_with_au2anlysis    ini_path=${CURDIR}/ini/${ini_file}.ini    log_need_to_check=i
    ...   save_log_directory=${TEST_LOG_DIRECTORY()}/All/${tti_file}/

step1:prepare eNB on air
    log to console    step1:prepare eNB on air
    Add RD
    Prepare Enb Onair   ${scfc_path}    ${yaml_config}
#    Set R&D parameter
    creat multi UEs alias    messege_id=1

step2:attach UEs to cell11 with default69_${qci}
    log to console    step2:attach UEs to cell11 with default69_${qci}
    Attach UEs to cell    Multiue_start=1    ue_num=${ue_num}    Cell_id=11    messege_id=1    qci=69    bearer_id=5
    Add GBR bear for UEs    Multiue_start=1    ue_num=${ue_num}    messege_id=1    qci=${qci}   bearer_id=6    gbr_rate=128
    Start data traffic bear for multiUEs    Multiue_start=1   ue_num=${ue_num}    bearer_id=5   dl_data=256K   ul_data=256K
    Start data traffic bear for multiUEs    Multiue_start=1   ue_num=${ue_num}    bearer_id=6   dl_data=2M    ul_data=2M
    start tti trace    file_name=tti_QCI69_${qci}    alias_tti=enb1    cell_id=ALL
    Stop tti trace to decode    file_name=tti_QCI69_${qci}    alias_tti=enb1
    Check ttitrace    file_name=tti_QCI69_${qci}    ini_file=cell11_1231_tti_dl
    Check ttitrace    file_name=tti_QCI69_${qci}    ini_file=cell11_1234_tti_ul
    Verify UEs throughput    TP_target_DL=2.2    TP_target_UL=2.2    ue_num=${ue_num}    Multiue_start=1   Cell_id=11
    check bearer TP     Multiue_start=1    ue_num=${ue_num}    QCI=69    bearer_id=5    dl_data=0.2    ul_data=0.2
    run keyword and continue on failure    check bearer TP     Multiue_start=1    ue_num=${ue_num}
    ...    QCI=${qci}    bearer_id=6    dl_data=2    ul_data=2

step3:Intra-Enb Inter-Cell handover "${Ho_time}"times
    log to console    step3:Intra-Enb Inter-Cell handover "${Ho_time}"times
    FOR    ${num}    IN RANGE    1    ${Ho_time}+1
        log to console    HO the ${num}th time
        Trigger Intra-Enb Inter-Cell handover    Multiue_start=1    ue_num=${ue_num}    messege_id=1
    ...    target_cell_id=12    source_cell_id=11    t310_safe=ms1000
        start tti trace    file_name=tti_QCI69_${qci}_ho_to_cell12_${num}th_time    alias_tti=enb1    cell_id=ALL
        Stop tti trace to decode    file_name=tti_QCI69_${qci}_ho_to_cell12_${num}th_time    alias_tti=enb1
        Check ttitrace    file_name=tti_QCI69_${qci}_ho_to_cell12_${num}th_time    ini_file=cell12_1331_tti_dl
        Check ttitrace    file_name=tti_QCI69_${qci}_ho_to_cell12_${num}th_time    ini_file=cell12_1334_tti_ul
        check bearer TP     Multiue_start=1    ue_num=${ue_num}    QCI=${qci}    bearer_id=6    dl_data=2    ul_data=2
        sleep   2s
        Trigger Intra-Enb Inter-Cell handover    Multiue_start=1    ue_num=${ue_num}    messege_id=1
    ...    target_cell_id=11    source_cell_id=12    t310_safe=ms500
        start tti trace    file_name=tti_QCI69_${qci}_ho_back_to_cell11_${num}th_time    alias_tti=enb1    cell_id=ALL
        Stop tti trace to decode   file_name=tti_QCI69_${qci}_ho_back_to_cell11_${num}th_time    alias_tti=enb1
        Check ttitrace    file_name=tti_QCI69_${qci}_ho_back_to_cell11_${num}th_time    ini_file=cell11_1231_tti_dl
        Check ttitrace    file_name=tti_QCI69_${qci}_ho_back_to_cell11_${num}th_time    ini_file=cell11_1234_tti_ul
        check bearer TP     Multiue_start=1    ue_num=${ue_num}    QCI=${qci}    bearer_id=6    dl_data=2    ul_data=2
    END

step4:Reestablishment at cell11
    log to console    step4:Reestablishment at cell11
    Intra-Enb Reestablishment    Multiue_start=1    ue_num=${ue_num}    messege_id=1
    ...    source_cell_id=11    target_cell_id=11    maxHARQ_ul=n5    t310_safe=ms1000
    sleep   2s
    start tti trace    file_name=tti_QCI69_${qci}_Reestablishment_cell11    alias_tti=enb1    cell_id=ALL
    Stop tti trace to decode   file_name=tti_QCI69_${qci}_Reestablishment_cell11    alias_tti=enb1
    Check ttitrace    file_name=tti_QCI69_${qci}_Reestablishment_cell11    ini_file=cell11_1231_tti_dl
    Check ttitrace    file_name=tti_QCI69_${qci}_Reestablishment_cell11    ini_file=cell11_1234_tti_ul
    check bearer TP     Multiue_start=1    ue_num=${ue_num}    QCI=${qci}    bearer_id=6    dl_data=2    ul_data=2

step5:Reestablishment at cell12
    log to console    step5:Reestablishment at cell12
    Intra-Enb Reestablishment    Multiue_start=1    ue_num=${ue_num}    messege_id=1
    ...    source_cell_id=11    target_cell_id=12    maxHARQ_ul=n6    t310_safe=ms1000
    sleep   2s
    start tti trace    file_name=tti_QCI69_${qci}_Reestablishment_cell12    alias_tti=enb1    cell_id=ALL
    Stop tti trace to decode    file_name=tti_QCI69_${qci}_Reestablishment_cell12    alias_tti=enb1
    Check ttitrace    file_name=tti_QCI69_${qci}_Reestablishment_cell12    ini_file=cell12_1331_tti_dl
    Check ttitrace    file_name=tti_QCI69_${qci}_Reestablishment_cell12    ini_file=cell12_1334_tti_ul
    check bearer TP     Multiue_start=1    ue_num=${ue_num}    QCI=${qci}    bearer_id=6    dl_data=2    ul_data=1.9

step6:add qci7
    log to console    step6:add qci7
    Add nonGBR bear for UEs   Multiue_start=1    ue_num=${ue_num}    messege_id=1    qci=7    bearer_id=7
    Start data traffic bear for multiUEs    Multiue_start=1   ue_num=${ue_num}    bearer_id=7   dl_data=50M    ul_data=10M
    sleep   10s
    start tti trace    file_name=tti_QCI69_${qci}_7    alias_tti=enb1    cell_id=ALL
    Stop tti trace to decode    file_name=tti_QCI69_${qci}_7    alias_tti=enb1
    Check ttitrace    file_name=tti_QCI69_${qci}_7    ini_file=cell12_1331_tti_dl
    Check ttitrace    file_name=tti_QCI69_${qci}_7    ini_file=cell12_1334_tti_ul
    check bearer TP     Multiue_start=1    ue_num=${ue_num}    QCI=${qci}    bearer_id=6    dl_data=2    ul_data=2
    check bearer TP     Multiue_start=1    ue_num=${ue_num}    QCI=7    bearer_id=7    dl_data=50    ul_data=2.5


step7:Reestablishment at cell11 with qci7
    log to console    step7:Reestablishment at cell11 with qci7
    Intra-Enb Reestablishment    Multiue_start=1    ue_num=${ue_num}
    ...    messege_id=1    source_cell_id=12    target_cell_id=11    maxHARQ_ul=n5    t310_safe=ms1000  #zhuyizheli
    sleep   10s
    start tti trace    file_name=tti_QCI69_${qci}_7_Reestablishment_cell11    alias_tti=enb1    cell_id=ALL
    Stop tti trace to decode    file_name=tti_QCI69_${qci}_7_Reestablishment_cell11    alias_tti=enb1
    Check ttitrace    file_name=tti_QCI69_${qci}_7_Reestablishment_cell11    ini_file=cell11_1231_tti_dl
    Check ttitrace    file_name=tti_QCI69_${qci}_7_Reestablishment_cell11    ini_file=cell11_1234_tti_ul
    check bearer TP     Multiue_start=1    ue_num=${ue_num}    QCI=${qci}    bearer_id=6    dl_data=2    ul_data=2
    check bearer TP     Multiue_start=1    ue_num=${ue_num}    QCI=7    bearer_id=7    dl_data=50    ul_data=2.5

step8:Reestablishment at cell12
    log to console    step8:Reestablishment at cell12
    Intra-Enb Reestablishment    Multiue_start=1    ue_num=${ue_num}    messege_id=1
    ...    source_cell_id=11    target_cell_id=12    maxHARQ_ul=n6    t310_safe=ms1000
    sleep   10s
    start tti trace    file_name=tti_QCI69_${qci}_7_Reestablishment_cell12    alias_tti=enb1    cell_id=ALL
    Stop tti trace to decode    file_name=tti_QCI69_${qci}_7_Reestablishment_cell12    alias_tti=enb1
    Check ttitrace    file_name=tti_QCI69_${qci}_7_Reestablishment_cell12    ini_file=cell12_1331_tti_dl
    Check ttitrace    file_name=tti_QCI69_${qci}_7_Reestablishment_cell12    ini_file=cell12_1334_tti_ul
    check bearer TP     Multiue_start=1    ue_num=${ue_num}    QCI=7    bearer_id=6    dl_data=2    ul_data=1.8
    check bearer TP     Multiue_start=1    ue_num=${ue_num}    QCI=${qci}    bearer_id=7    dl_data=50    ul_data=2.5


check bearer TP
    [Arguments]    ${Multiue_start}    ${ue_num}    ${QCI}     ${bearer_id}    ${dl_data}    ${ul_data}
     ${Multiue_end}    evaluate    ${Multiue_start}+${ue_num}
    FOR    ${num}    IN RANGE    ${Multiue_start}    ${Multiue_end}
        ${QCI_TP_DL}    Cus Get Througput For Each Bearer    ue_id=${num}    direction=dl     bearer_id=${bearer_id}    tput_type=cur
        log to console  QCI_${QCI} DL_TP_result is ${QCI_TP_DL}
        log to console  QCI_${QCI} DL_TP_target is ${dl_data}
        run keyword and continue on failure    should_be_true    ${QCI_TP_DL}>${dl_data}
        ${QCI_TP_UL}    Cus Get Througput For Each Bearer    ue_id=${num}    direction=ul     bearer_id=${bearer_id}    tput_type=cur
        log to console  QCI_${QCI} UL_TP_result is ${QCI_TP_UL}
        log to console  QCI_${QCI} UL_TP_target is ${ul_data}
        run keyword and continue on failure    should_be_true    ${QCI_TP_UL}>${ul_data}
    END


Intra-Enb Reestablishment
    [Arguments]    ${Multiue_start}    ${ue_num}    ${messege_id}    ${source_cell_id}    ${target_cell_id}    ${maxHARQ_ul}    ${t310_safe}
     ${Multiue_end}    evaluate    ${Multiue_start}+${ue_num}
    FOR    ${num}    IN RANGE    ${Multiue_start}    ${Multiue_end}
        Expect Message Flow
        ...    UE_${num}:RRC_RRCConnectionReestablishmentRequest (physCellId eq ${source_cell_id})
        ...    UE_${num}:RRC_RRCConnectionReestablishment (maxHARQ-Tx eq "${maxHARQ_ul}")
        ...    UE_${num}:RRC_RRCConnectionReestablishmentComplete
        ...    alias=ho_flow1    overall_timeout=30
        Run UEx command    ue_rrc_reestablish id=${num} cell=${target_cell_id}
        Flow Occurred As Expected    alias=ho_flow1
    END

Trigger Intra-Enb Inter-Cell handover
    [Arguments]    ${Multiue_start}    ${ue_num}    ${messege_id}    ${target_cell_id}    ${source_cell_id}    ${t310_safe}
     ${Multiue_end}    evaluate    ${Multiue_start}+${ue_num}
    FOR    ${num}    IN RANGE    ${Multiue_start}    ${Multiue_end}
        ${RRC_HO}  catenate
    ...    mobilityControlInfo contains (
    ...    targetPhysCellId eq ${target_cell_id}
    ...    )
    ...    and
    ...    radioResourceConfigDedicated contains (
    ...    t310-r9 eq "${t310_safe}"
    ...    )
        Expect Message Flow
        ...    UE_${num}:RRC_RRCConnectionReconfiguration (${RRC_HO})
        ...    UE_${num}:RRC_RRCConnectionReconfigurationComplete
        ...    alias=ho_flow1    overall_timeout=30
        Run UEx command    ue_measurement_send id=${num} event=A3
    ...    srsrp=86 srsrq=34 phycell_id=${target_cell_id} nrsrp=96 nrsrq=27 phycell_id=${source_cell_id} nrsrp=67 nrsrq=19 amount=2
        Flow Occurred As Expected    alias=ho_flow1
    END

attach and check rrclogs
    [Arguments]    ${num}    ${Cell_id}    ${messege_id}    ${qci}    ${bearer_id}
#    Expect Message Flow
#    ...   MME_${messege_id}:S1AP_InitialContextSetupRequest contains ((qCI eq "${qci}") and (e-RAB-ID eq ${bearer_id}))
#    ...   MME_${messege_id}:S1AP_InitialContextSetupResponse contains (e-RAB-ID eq ${bearer_id})
#    ...   alias=UE_${num}_flow    overall_timeout=20
    CUS Attach    ${num}    ${Cell_id}
#    Flow Occurred As Expected     alias=UE_${num}_flow



Add GBR bear for UEs
    [Arguments]    ${Multiue_start}    ${ue_num}    ${messege_id}    ${qci}    ${bearer_id}     ${gbr_rate}
     ${Multiue_end}    evaluate    ${Multiue_start}+${ue_num}
    FOR    ${num}    IN RANGE    ${Multiue_start}    ${Multiue_end}
#        Expect Message Flow
#         ...   MME_${messege_id}:S1AP_E-RABSetupRequest contains ((qCI eq "${qci}") and (e-RAB-ID eq ${bearer_id}))
#         ...   MME_${messege_id}:S1AP_E-RABSetupResponse contains (e-RAB-ID eq ${bearer_id})
#         ...   alias=UE_${num}_flow    overall_timeout=20
#        sleep  1
        Run UEx command   bearer_add ue=${num} qci=${qci} mbr_dl=${gbr_rate} mbr_ul=${gbr_rate} gbr_dl=${gbr_rate} gbr_ul=${gbr_rate}
#        Flow Occurred As Expected    alias=UE_${num}_flow
    END


Add nonGBR bear for UEs
    [Arguments]    ${Multiue_start}    ${ue_num}    ${messege_id}    ${qci}    ${bearer_id}     ${gbr_rate}=0
#    Run UEx command  bearer_add ue=${num} qci=69
     ${Multiue_end}    evaluate    ${Multiue_start}+${ue_num}
    FOR    ${num}    IN RANGE    ${Multiue_start}    ${Multiue_end}
#        Expect Message Flow
#         ...   MME_${messege_id}:S1AP_E-RABSetupRequest contains ((qCI eq "${qci}") and (e-RAB-ID eq ${bearer_id}))
#         ...   MME_${messege_id}:S1AP_E-RABSetupResponse contains (e-RAB-ID eq ${bearer_id})
#         ...   alias=UE_${num}_flow    overall_timeout=20
#        sleep  1
        Run UEx command   bearer_add ue=${num} qci=${qci}
#        Flow Occurred As Expected    alias=UE_${num}_flow
    END

delete bearer for UEs
    [Arguments]    ${Multiue_start}    ${ue_num}    ${messege_id}    ${qci}    ${bearer_id}     ${gbr_rate}=0
#    Run UEx command  bearer_add ue=${num} qci=69
     ${Multiue_end}    evaluate    ${Multiue_start}+${ue_num}
    FOR    ${num}    IN RANGE    ${Multiue_start}    ${Multiue_end}
#        Expect Message Flow
#         ...   MME_${messege_id}:S1AP_E-RABReleaseCommand contains (e-RAB-ID eq ${bearer_id})
#         ...   MME_${messege_id}:S1AP_E-RABReleaseResponse contains (e-RAB-ID eq ${bearer_id})
#         ...   alias=UE_${num}_flow    overall_timeout=20
#        sleep  1
        Run UEx command   bearer_del ue=${num} qci=${qci}
#        Flow Occurred As Expected    alias=UE_${num}_flow
    END

Verify UEs throughput
    [Arguments]    ${TP_target_DL}    ${TP_target_UL}    ${ue_num}    ${Multiue_start}    ${Cell_id}
    ${DL_UE_peak_target}     evaluate    float(${TP_target_DL})/float(${ue_num})
    ${UL_UE_peak_target}     evaluate    float(${TP_target_UL})/float(${ue_num})
    ${UEs_TP_DL_list}   create list
    ${UEs_TP_UL_list}   create list
    ${Multiue_end}    evaluate    ${Multiue_start}+${ue_num}
    FOR    ${num}    IN RANGE    ${Multiue_start}    ${Multiue_end}
        ${ue_dl_tput_ave_result}=    CUS Get DL Throughput Ave    ${num}    dl_mac    Mbps
        ${ue_ul_tput_ave_result}=    CUS Get UL Throughput Ave    ${num}    ul_mac    Mbps
        append to list    ${UEs_TP_DL_list}    ${ue_dl_tput_ave_result}
        append to list    ${UEs_TP_UL_list}    ${ue_ul_tput_ave_result}
    END
    log to console    cellid${Cell_id} UEs_TP_DL_list result are ${UEs_TP_DL_list}
    log to console    cellid${Cell_id} UE DL target is ${DL_UE_peak_target}
    log to console    cellid${Cell_id} UEs_TP_UL_list result are ${UEs_TP_UL_list}
    log to console    cellid${Cell_id} UE UL target is ${UL_UE_peak_target}
    run keyword and continue on failure     should_be_true    ${ue_dl_tput_ave_result}>${DL_UE_peak_target}
    run keyword and continue on failure     should_be_true    ${ue_ul_tput_ave_result}>${UL_UE_peak_target}

Start data traffic bear for multiUEs
    [Arguments]    ${Multiue_start}    ${ue_num}    ${bearer_id}    ${dl_data}    ${ul_data}
    ${Multiue_end}    evaluate    ${Multiue_start}+${ue_num}
    ${DL_UE_peak_target}     evaluate    float(${DL_Cell_peak})/float(${ue_num})
    ${UL_UE_peak_target}     evaluate    float(${UL_Cell_peak})/float(${ue_num})
    FOR    ${num}    IN RANGE    ${Multiue_start}    ${Multiue_end}
        log to console  send bear ${bearer_id} ul_dl for ue${num}
       CUS Start DL Udp Data Traffic    ${num}    ${dl_data}    bearer=${bearer_id}
       CUS Start UL Udp Data Traffic    ${num}    ${ul_data}    bearer=${bearer_id}
        Sleep    1
    END

Attach UEs to cell
    [Arguments]    ${Multiue_start}    ${ue_num}    ${messege_id}   ${Cell_id}    ${qci}    ${bearer_id}
    ${Multiue_end}    evaluate    ${Multiue_start}+${ue_num}
    FOR    ${num}    IN RANGE    ${Multiue_start}    ${Multiue_end}
        log to console  attach ue ${num}
        attach and check rrclogs    ${num}    ${Cell_id}    ${messege_id}    ${qci}    ${bearer_id}
        sleep  1
    END


Attach '${ue_num}'UEs to cell11 and '${ue_num}'UEs to cell12
    FOR    ${num}    IN RANGE    1    ${ue_num}+1
        log to console  attach ue ${num}
        CUS Attach    ${num}    11
        sleep  1
        Add safe bears for UEs    ${num}
        log to console  add safe bear for ue ${num}
        sleep  1
    FOR    ${num}    IN RANGE    11    ${ue_num}+11
        CUS Attach    ${num}    12
        log to console  attach ue ${num}
        sleep  1
        Add safe bears for UEs    ${num}
        log to console  add safe bear for ue ${num}
        sleep  1
    END

Check UExlog
    run    mkdir ${TEST LOG DIRECTORY()}/uex_logs
    run    cp -rf /home/cus/logs/uex/latest/* \ ${TEST LOG DIRECTORY()}/uex_logs/
    ${cmd}    Set Variable    uesim-dump ${TEST LOG DIRECTORY()}/uex_logs/cell-11.log > ${TEST LOG DIRECTORY()}/uex_logs/cell-11_decode.log
    OperatingSystem.Run    ${cmd}

creat multi UEs alias
    [Arguments]     ${messege_id}
    FOR    ${num}    IN RANGE    1    ${ue_num}+11
	    Create UE Alias    UE_${num}    ue_id=${num}    id_type=cus
    END
    Create Enb Alias    ENB_${messege_id}    enb_id=1    id_type=wts
	Create MME alias    MME_${messege_id}    mme_id=1    id_type=wts

Add safe bears
    Run UEx command  bearer_add ue=1 qci=69
    Expect Message Flow
    ...   MME_1:S1AP_E-RABSetupRequest contains ((qCI eq "${qci}") and (e-RAB-ID eq 7))
    ...   MME_1:S1AP_E-RABSetupResponse contains (e-RAB-ID eq 7)
    ...   alias=UE_1_flow    overall_timeout=20
    Run UEx command   bearer_add ue=1 qci=${qci} mbr_dl=31 mbr_ul=31 gbr_dl=31 gbr_ul=31
    Flow Occurred As Expected     alias=UE_1_flow

start tti trace
    [Arguments]     ${file_name}     ${alias_tti}    ${cell_id}=ALL
    setup_enb_ttitrace    log_path=${TEST LOG DIRECTORY()}/${file_name}    alias=${alias_tti}
    start_enb_ttitrace    node_type=ALL    cell_id=${cell_id}    filesize=5m    alias=${alias_tti}

Stop tti trace to decode
    [Arguments]     ${file_name}    ${alias_tti}
    sleep  1s
    stop_and_decode_enb_ttitrace    alias=${alias_tti}
    teardown_all_alias_for_enb_ttitrace

Check ttitrace
    [Arguments]     ${file_name}     ${ini_file}
    check_log_with_au2anlysis    ini_path=${CURDIR}/ini/${ini_file}.ini    log_need_to_check=i
    ...    save_log_directory=${TEST LOG DIRECTORY()}/${file_name}

Stop all bearers data traffic
    FOR    ${num}    IN RANGE    1    ${ue_num}+11
        log to console    CUS Stop UL Udp Data Traffic for UE${num}
        CUS Stop UL Udp Data Traffic    ${num}
        CUS Stop DL Udp Data Traffic    ${num}
        Sleep    1
    END
    sleep  15s

Stop single bearer data traffic
    [Arguments]     ${bearer_id}=5
    FOR    ${num}    IN RANGE    1    ${ue_num}+11
        CUS Stop UL Udp Data Traffic    ${num}    bearer=${bearer_id}
        CUS Stop DL Udp Data Traffic    ${num}    bearer=${bearer_id}
        Sleep    1
    END

Detach UE
    FOR    ${num}    IN RANGE    1    ${ue_num}+1
        CUS Detach    ${num}
        Sleep    1
    END

Set R&D parameter
    runkeyword and continue on failure    Set Rad Parameter    setlog    ALL    ALL    FID_DL_CONGESTION   DEBUG
    ...    hw_ver=fsmr3
    runkeyword and continue on failure    Set Rad Parameter    setlog    ALL    ALL    FID_UL_CONGESTION   DEBUG
    ...    hw_ver=fsmr3

check err log
    ${enb1_btslog_error_check1}=    run_process_and_get_output    grep -w "ERR/TDDPS" ${TEST LOG DIRECTORY()}enb1_btslog* | wc -l
    should_be_true    ${enb1_btslog_error_check1}<=2
    ${enb1_btslog_WRN_check1}=    run_process_and_get_output    grep -w "WRN/TDDPS" ${TEST LOG DIRECTORY()}enb1_btslog* | wc -l
    should_be_true    ${enb1_btslog_WRN_check1}<=5

run_process_and_get_output
    [Arguments]    ${command}
    ${result}    run_process    ${command}    shell=True
    [Return]    ${result.stdout}


