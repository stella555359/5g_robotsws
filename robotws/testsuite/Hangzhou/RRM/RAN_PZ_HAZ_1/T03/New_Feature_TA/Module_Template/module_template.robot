*** Settings ***
Documentation
...   author: winnie he
...   contact: winnie.he@nokia-sbell.com
...   Description: this is one reference case template, purpose for unified style.

Resource           ../../Resources/common_resource.robot
# Resource          ../Resources/top50_resource.robot
Suite Setup       Common MultiBTS Suite Setup For RRM
# Suite Setup       Common Suite Setup For RRM
Test Setup            Common MultiBTS Test Setup For RRM
# Test Setup          Common Test Setup For RRM
Test Teardown     Common MultiBTS Test Teardown For RRM
# Test Teardown    Common Test Teardown For RRM
Suite Teardown    Common MutliBTS Suite Teardown For RRM
# Suite Teardown    Common Suite Teardown For RRM
Force Tags        CRT/CIT/CDRT     #Tag Item
# ...   PY27
...      RAN_5G                    #Product [RAN_5G]
# ...      CLOUD_5G_CLASSICAL_2xANDROID_ASIBL_ABIAB1_ASIBR_ABILB1_AEQE_ENB   #TLtype, it is for auto trigger by ute cloud
...      SBTS00/SBTS21B           # it is for auto trigger by ute cloud with the release
# ...      STATE_SKIP_AGENT         # it is for auto trigger by ute cloud with gnb state
...      RAN_PZ_HAZ_1             #Competence Area
...      RAN_PZ_HAZ1_SG07_ST_RRM  #Organization
...      TA_LEVEL_22              #Detailed Automation Level[TA_LEVEL_20，TA_LEVEL_21， TA_LEVEL_22]


Test Timeout    30 minutes

*** Variables ***
#reduce global paramter as possilbe and automatically got from gNB or __init__
@{Ohter_Allow_Alarms}
${APC_Index}    -1
${PA_MinValue}           ${0}
${PA_MaxValue}           ${93}
${DEBUG_MODE}            ${TRUE}
# ${REMOTE_MODE}           ${TRUE}
${SAVE_EGATE_AFTER_DOWN}    ${True}
*** Test Cases ***
KW for Bts Operation
    Log To Console    \nStart to test the BTS Operation module ...\n
    BTS Operation    operation=bts_unlock
    # ...    distname_id=NRCELL-71
    ...    bts_index=${1}
    BTS Operation    operation=bts_lock
    ...    distname_id=NRCELL-71
    ...    bts_index=${1}
    BTS Operation    operation=bts_unlock
    # ...    distname_id=NRCELL-71 NRCELL-7
    ...    bts_index=${1}
    BTS Operation    operation=cell_unlock
    ...    distname_id=NRCELL-ALL
    ...    bts_index=${0}
    ${conn}    coam.connect_to    bts_host=192.168.255.129
    ...    admin_api_log_dir=${RESULT_DIR}
    ...    use_ssl=${True}
    ...    update_interval=${5000}
    ...    name=abc
    BTS Operation    operation=ru_reset    need_verify=${False}
    ...    bts_index=${0}    distname_id=RMOD-1    product_type=gnb
    BTS Operation    operation=verify    verify_status=RRU_RESET_CHECK
    ...    bts_index=${0}    distname_id=RMOD-ALL    product_type=gnb
    ...    timeout=5 min
    BTS Operation    operation=cell_lock
    ...    distname_id=NRCELL-12 NRCELL-21 NRCELL-22
    ...    bts_index=${0}
    BTS Operation    operation=cell_unlock
    ...    distname_id=NRCELL-ALL
    ...    bts_index=${0}
    BTS Operation    operation=cell_unlock
    ...    distname_id=NRCELL-ALL
    ...    bts_index=${0}
    BTS Operation    operation=cell_block
    ...    distname_id=NRCELL-12 NRCELL-21 NRCELL-22
    ...    bts_index=${0}
    BTS Operation    operation=cell_unblock
    ...    distname_id=NRCELL-12 NRCELL-21 NRCELL-22
    ...    bts_index=${0}
    BTS Operation    operation=cell_block
    ...    distname_id=NRCELL-ALL
    ...    bts_index=${0}
    BTS Operation    operation=cell_unblock
    ...    distname_id=NRCELL-ALL
    ...    bts_index=${0}
    BTS Operation    operation=cell_reset
    ...    distname_id=NRCELL-ALL
    ...    bts_index=${0}
    BTS Operation    operation=cell_reset
    ...    distname_id=NRCELL-12 NRCELL-21 NRCELL-22
    ...    bts_index=${0}
    # # _bts.get_cell_type_by_distname_id    distname_id=NRCELL-1
    BTS Operation    operation=cell_group_unlock    distname_id=NRCELLGRP-0
    ...    bts_index=${1}
    BTS Operation    operation=bts_reset
    ...    bts_index=${0}
    BTS Operation    operation=ru_lock    distname_id=RMOD-1
    ...    bts_index=${0}
    BTS Operation    operation=ru_unlock    distname_id=RMOD-1
    ...    bts_index=${0}
    BTS Operation    operation=bbmod_lock    distname_id=BBMOD-1
    ...    bts_index=${0}
    BTS Operation    operation=bbmod_unlock    distname_id=BBMOD-1
    ...    bts_index=${0}
    BTS Operation    operation=bbmod_reset    distname_id=BBMOD-1
    ...    bts_index=${0}
     BTS Operation    operation=ru_reset    distname_id=RMOD-2
    ...    bts_index=${0}
    BTS Operation    operation=ru_reset    distname_id=RMOD-1
    ...    bts_index=${0}
    BTS Operation    operation=rat_block    distname_id=NRCELL-ALL
    ...    bts_index=${0}
    BTS Operation    operation=rat_unblock    distname_id=LNCEL-ALL
    ...    bts_index=${0}
    BTS Operation    operation=rat_reset    distname_id=NRCELL-ALL
    ...    bts_index=${0}
    BTS Operation    operation=verify    verify_status=SITE_ONAIR+CELL_ONAIR
    ...    bts_index=${0}
    BTS Operation    operation=x2link_lock    distname_id=LNBTS-6141/LNADJGNB-1
    ...    bts_index=${0}
    BTS Operation    operation=x2link_unlock    distname_id=LNBTS-6141/LNADJGNB-1
    ...    bts_index=${0}
    BTS Operation    operation=nglink_lock    distname_id=NRBTS-6142/SERVEDAMF-1
    ...    bts_index=${1}
    BTS Operation    operation=nglink_unlock    distname_id=NRBTS-6142/SERVEDAMF-1
    ...    bts_index=${1}

Kw For Counter Module Calculate
    ${rule1}    Catenate
    ...    Distname: All;
    ...    Counter: M55319C12005;
    ...    Counter rule: max(M55319C12005);
    ${rule2}    Catenate
    ...    Distname: All;
    ...    Counter: M55319C12006;
    ...    Counter rule: max(M55319C12006);
    Counter Operation    operation=start_collect_counter
    ...    counter_rule=${rule_list1}
    ...    product_type=gnb
    Log to Console    Add your traffic model here!
    ${value1}    Counter Operation    operation=collect_counter_and_check_rule
    ...    product_type=gnb
    ${rule1}    Catenate
    ...    Distname: All;
    ...    Counter: M55319C12007;
    ...    Counter rule: max(M55319C12007);
    ${rule2}    Catenate
    ...    Distname: All;
    ...    Counter: M55319C12008;
    ...    Counter rule: max(M55319C12008);
    Counter Operation    operation=start_collect_counter
    ...    counter_rule=${rule_list1}
    ...    product_type=gnb
    Log to Console    Add your traffic model2 here!
    ${value2}    Counter Operation    operation=collect_counter_and_check_rule
    ...    product_type=gnb

Kw For Counter Module
    ${rule1}    Catenate
    ...    Distname: All;
    ...    Counter: M55319C12005 to M55319C12007,M55319C12009 to M55319C12011;
    ...    Counter rule: max(M55319C12005 to M55319C12007) >= 0 and has_no_0_value(M55319C12009 to M55319C12011);
    ...    Comment: latest  # if you used latest, means all counter in this rule will just use the latest value
    ${rule2}    Catenate
    ...    Distname: All;
    ...    Counter: M55319C12005,M55319C12006,M55319C12007;
    ...    Counter rule: max(M55319C12005)+max(M55319C12007)/max(M55319C12006)<=max(M55319C12007);
    ${rule3}    Catenate
    ...    Distname: All;
    ...    Counter: M55319C12005;
    ...    Counter rule: latest(M55319C12005)>0;
    ${rule4}    Catenate    Distname: MRBTS-1/NRBTS-1;
    ...    Counter: M55319C16007;M55319C16008;M55319C16009;
    ...    Counter rule: (M55319C16007+M55319C16008+M55319C16009)<=320000; Comment: latest;
    ${rule_list1}    Create List    ${rule2}    ${rule3}    ${rule1}    ${rule4}
    Log To Console    \nStart to test the Counter Operation module ...\n
    Counter Operation    operation=start_collect_counter
    ...    counter_rule=${rule_list1}
    ...    product_type=gnb
    # ...    wait_for_next_counter_generate=${TRUE}   # wait for next counter generate then begin_collect_counter
    ...    interval=15    # align to your counter generate time interval
    sleep    2 min
    Log to Console    \nYou can add your traffic in here ...\n
    ${value2}    Counter Operation    operation=collect_counter_and_check_rule
    ...    product_type=gnb

Kw For AP Operation
   [Setup]    Common MultiBTS Test Setup For RRM    airphone_config_tag=SA_TDD_2c_1gNBSim
    ...    base_path=${CURDIR}/Airphone
    ${traffic_info_dic}    Create Dictionary    call_type=SA    ue_id=1    pdu_id=1    profile_id=1
    ...                                         gnb_id=${None}    cell_id=${None}    bearer_id=${None}
    Wait Until Keyword Succeeds     3x    1min    Airphone Operation    operation=attach
    ...                   product_type=gnb
    ...                   traffic_info_dic=${traffic_info_dic}
    ...                   timeout=30s
    Airphone Operation    operation=aplog
    ...                   product_type=gnb
    ...                   timeout=30s
    Get PhysCellId With UE Id From Egate Log    ${0}    ${0}
    ${traffic_info_dic}    Create Dictionary    call_type=SA    ue_id=1    bearer_id=2    dir=dl
    ...                                         pdu_id=1    time_len=5s    trf_id=1    mbps_dl=200m
    ...                                         qfi_id=1    time=999    type=l3    profile_id=1
    ...                                         gnb_id=0    cell_id=1    protocol=udp
    ${Tput_dict}    Airphone Operation    operation=start_traffic
    ...                                   product_type=gnb
    ...                                   traffic_info_dic=${traffic_info_dic}
    ...                                   timeout=600s
    Sleep    30s
    ${Tput_dict}    Airphone Operation    operation=stop_traffic
    ...                                   product_type=gnb
    ...                                   traffic_info_dic=${traffic_info_dic}
    ...                                   timeout=600s

KW For Downgrade
    BTS Operation    operation=downgrade    product_type=gnb    bts_index=0
    ...   indicated_sw_version=SBTS24R3_ENB_0000_000425_000044

Kw For Handover Operation
    ${source_pa_port_list}     Create List     1    2
    ${source_pa_value_list}    Create List     0    30
    ${target_pa_port_list}     Create List    3    4
    ${target_pa_value_list}    Create List    60    20
    &{source}    Create Dictionary    att_index=${0}    pa_port=${source_pa_port_list}    pa_value=${source_pa_value_list}
    ...                               step=${5}    pa_type=32*8
    &{target}    Create Dictionary    att_index=${0}    pa_port=${target_pa_port_list}    pa_value=${target_pa_value_list}
    ...                               step=${5}    pa_type=32*8
    PA Operation    source=&{source}    target=&{target}
    ${source_pa_port_list}     Create List     3    4
    ${source_pa_value_list}    Create List     0    30
    ${target_pa_port_list}     Create List    1    2
    ${target_pa_value_list}    Create List    60    20
    &{source}    Create Dictionary    att_index=${0}    pa_port=${source_pa_port_list}    pa_value=${source_pa_value_list}
    ...                               step=${5}    pa_type=32*8
    &{target}    Create Dictionary    att_index=${0}    pa_port=${target_pa_port_list}    pa_value=${target_pa_value_list}
    ...                               step=${5}    pa_type=32*8

    PA Operation    source=&{source}    target=&{target}

# Kw For return Handover
#     FOR    ${i}    IN RANGE    ${6}
#         Kw For Handover Operation
#     END

Kw For Tti Capture
    ${Cell_Index}    set variable    ${1}
    ${tti_argument}   Create Dictionary   tti_options=--ip 10.69.4.93 -t 4 -C 11
    ${dict_argument}   Create Dictionary   argument=${tti_argument}
    Log Collection    start    tti    product_type=gnb    bts_index=${0}    dict_argument=${dict_argument}
    sleep    60s
    ${local_file_path}    Log Collection    stop_and_download    tti    product_type=gnb    bts_index=${0}
    Log To Console    \nTTI log: ${local_file_path}

Kw For Tti Capture By dcap
    &{dcap_info}    Create Dictionary    host=10.56.218.4    port=443    username=utfuser    password=utfadmin!
    ${tti_argument}   Create Dictionary   tti_options=-C 31
    ${dict_argument}   Create Dictionary   dcap_server=${dcap_info}    argument=${tti_argument}
    Log Collection    start    tti    product_type=gnb    bts_index=${0}    cudu_index=${0}    dict_argument=${dict_argument}
    ${local_file_path}    Log Collection    stop_and_download    tti    product_type=gnb    bts_index=${0}    cudu_index=${0}

Kw For Btslog
    Log Collection    start    syslog    product_type=gnb    bts_index=${1}
    sleep    20s
    ${local_file_path}    Log Collection    stop_and_download    syslog    product_type=gnb    bts_index=${1}
    Log To Console    \nSyslog log: ${local_file_path}
    &{syslog_filter_conditions}    Create Dictionary    line_regex=UpdateGnbCounter    element_regex=CounterId\:\\d+
    &{analysis_dict_syslog_1}    Create Dictionary    filter_conditions=${syslog_filter_conditions}
    ${result}=    Log Analysis    filter    syslog    ${local_file_path}    ${analysis_dict_syslog_1}
    Log To Console    \nSyslog log analysis result: ${result}
    FOR    ${r}    IN    @{result}
        Log To Console    \n${r}
    END

Kw For Snapshot
    ${local_file_path}    Log Collection    start    snapshot    product_type=gnb    bts_index=${1}
    Log To Console    \nSnapshot log: ${local_file_path}
    &{snapshot_filter_conditions}      Create Dictionary    filename=PM    postfix=.xml
    &{analysis_dict_snapshot_1}        Create Dictionary    filter_conditions=${snapshot_filter_conditions}
    ${result}=    Log Analysis    check    snapshot    ${local_file_path}    ${analysis_dict_snapshot_1}
    Log To Console    \nAnalyze log: ${result}
    &{snapshot_filter_conditions}      Create Dictionary    filename=PM    postfix=.xml.gz
    &{analysis_dict_snapshot_1}        Create Dictionary    filter_conditions=${snapshot_filter_conditions}
    ${result}=    Log Analysis    check    snapshot    ${local_file_path}    ${analysis_dict_snapshot_1}
    Log To Console    \nAnalyze log: ${result}
    &{snapshot_filter_conditions}      Create Dictionary    filename=BTS6091_2011_PM.BTS    postfix=.gz
    &{analysis_dict_snapshot_1}        Create Dictionary    filter_conditions=${snapshot_filter_conditions}
    ${result}=    Log Analysis    check    snapshot    ${local_file_path}    ${analysis_dict_snapshot_1}
    Log To Console    \nAnalyze log: ${result}
    &{snapshot_filter_conditions}      Create Dictionary    postfix=.xml.gz
    &{analysis_dict_snapshot_1}        Create Dictionary    filter_conditions=${snapshot_filter_conditions}
    ${result}=    Log Analysis    check    snapshot    ${local_file_path}    ${analysis_dict_snapshot_1}
    Log To Console    \nAnalyze log: ${result}

Kw For Bip Log
    [Timeout]    15 min
    ${BBMOD_Index}    set variable    ${5}
    ${bip_argument}   Create Dictionary   bip_options=-c ${BBMOD_Index}
    ${dict_argument}   Create Dictionary   argument=${bip_argument}
    Log Collection    start    bip    product_type=gnb    bts_index=${1}    dict_argument=${dict_argument}
    sleep    10s
    ${local_file_path}    Log Collection    stop_and_download    bip    product_type=gnb    bts_index=${1}
    Log To Console    \nBip log: ${local_file_path}

Kw For Alarm Check
    &{expected_alarms}        Create Dictionary
    @{expected_list}          Create List     ${expected_alarms}
    &{ignored_alarms}         Create Dictionary
    @{ignored_alarms_list}    Create List     ${ignored_alarms}
    &{CRITICAL_ALARM1}        Create Dictionary
    @{CRITICAL}               Create List     ${CRITICAL_ALARM1}
    ${res}    Alarm Operation    operation=check_active_alarms    product_type=gnb    bts_index=0
    ...                          expected_alarms=${expected_list}
    ...                          ignored_alarms=${ignored_alarms_list}
    ...                          critical_alarms=${CRITICAL}

Kw For PA Get Port
    PA Operation    operation=Get PA Port And Value
    ...             product_type=gnb
    ...             bts_index=${0}
    ...             du_index=${0}
    ...             ru_index=${0}
    ...             att_index=${5}
