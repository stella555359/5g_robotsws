*** Settings ***
Documentation
...   author: winnie he
...   contact: winnie.he@nokia-sbell.com
...   Description: this is one reference case template, purpose for unified style.

Resource           ../../Resources/Classical/RRM_MultiBTS_Common_Resource.robot
Resource           ../../../../resources/RAN_PZ_HAZ_1/Module/BTS_Operation.robot
Resource           ../../../../resources/RAN_PZ_HAZ_1/Module/BTS_Operation.robot
Resource           ../../../../resources/RAN_PZ_HAZ_1/Module/Counter_Operation.robot
Resource           ../../../../resources/RAN_PZ_HAZ_1/Module/Log_Collection.robot
Resource           ../../../../resources/RAN_PZ_HAZ_1/Module/AT_Operation.robot
Resource           ../../../../resources/RAN_PZ_HAZ_1/Module/Airphone_Operation.robot
Resource           ../../../../resources/RAN_PZ_HAZ_1/Module/KPI_Operation.robot
Library            ../../../../resources/RAN_PZ_HAZ_1/Module/Traffic_UEBox_Operation.py
Resource           ../../../../resources/RAN_PZ_HAZ_1/Module/Log_Analysis.robot
Resource           ../../../../resources/RAN_PZ_HAZ_1/CERTA_Module/Traffic_Module_For_ET.robot
Resource           ../Resources/log_resource.robot
# Resource           ../../Resources/Classical/RRM_BTS.robot
# Resource           ../../Resources/Classical/RRM_Common_Setup_Teardown.robot
Resource           ../../Resources/Common/Airphone.robot
# Resource           ../../Resources/RRM_Custom_Config.robot
# Resource          ../Resources/top50_resource.robot
# Suite Setup       Common MultiBTS Suite Setup For RRM
# # Suite Setup       Common Suite Setup For RRM
# Test Setup        Common MultiBTS Test Setup For RRM    other_method=Return From Keyword
# # Test Setup          Common Test Setup For RRM
# Test Teardown     Common MultiBTS Test Teardown For RRM
# # Test Teardown    Common Test Teardown For RRM
# Suite Teardown    Common MutliBTS Suite Teardown For RRM
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


Test Timeout    240 minutes

*** Variables ***
#reduce global paramter as possilbe and automatically got from gNB or __init__
@{Ohter_Allow_Alarms}
${APC_Index}    -1
${PA_MinValue}           ${0}
${PA_MaxValue}           ${93}
${DEBUG_MODE}            ${TRUE}
# ${REMOTE_MODE}           ${TRUE}
&{dcap_info}    host=127.0.0.1    port=9443    username=${None}    password=${None}
*** Test Cases ***
KW for module until test
    ${ret}    get_site_info    product_type=gnb    info_type=oam    backhaul_site_oam_ip=${True}
    Log    ${ret.addr}
    ${ret}    get_site_info    product_type=gnb    info_type=oam
    Log    ${ret.addr}
    ${ret}    get_site_info    product_type=gnb    info_type=oam    backhaul_site_oam_ip=${False}
    Log    ${ret.addr}
KW for module test
    Log To Console    \nStart to test the BTS Operation module ...\n
    # BTS Operation    operation=bts_unlock
    # # ...    distname_id=NRCELL-71
    # ...    bts_index=${1}
    # BTS Operation    operation=bts_lock
    # ...    distname_id=NRCELL-71
    # ...    bts_index=${1}
    # BTS Operation    operation=bts_unlock
    # # ...    distname_id=NRCELL-71 NRCELL-7
    # ...    bts_index=${1}
    # BTS Operation    operation=cell_unlock
    # ...    distname_id=NRCELL-ALL
    # ...    bts_index=${0}
    # ${conn}    coam.connect_to    bts_host=192.168.255.129
    # ...    admin_api_log_dir=${RESULT_DIR}
    # ...    use_ssl=${True}
    # ...    update_interval=${5000}
    # ...    name=abc
    # BTS Operation    operation=ru_reset    need_verify=${False}
    # ...    bts_index=${0}    distname_id=RMOD-1    product_type=gnb
    # BTS Operation    operation=verify    verify_status=SITE_ONAIR+CELL_ONAIR+RRU_ONAIR+BBU_ONAIR
    # ...    bts_index=${0}    product_type=gnb
    # ${info}    get_site_info    product_type=vcu    info_type=oam
    # Log To Console    ${info.addr}    ${info.username}     ${info.password}
    # ${info}    get_site_info    product_type=vcu    info_type=oam    du_index=${1}
    # Log To Console    ${info.addr}    ${info.username}     ${info.password}
    # ${info}    get_site_info    product_type=vcu    info_type=ssh
    # Log To Console    ${info.addr}    ${info.username}     ${info.password}
    # ${info}    get_site_info    product_type=vcu    info_type=rru
    # ${info}    get_site_info    product_type=vcu    info_type=smod
    # ...    oam_ip=10.xxx
    # ...    connection=${conn}
    BTS Operation    operation=cell_lock
    ...    distname_id=NRCELL-301 NRCELL-302
    ...    bts_index=${0}
    BTS Operation    operation=cell_unlock
    ...    distname_id=NRCELL-301
    ...    bts_index=${0}
    # BTS Operation    operation=cell_unlock
    # ...    distname_id=NRCELL-ALL
    # ...    bts_index=${0}
    # BTS Operation    operation=cell_block
    # ...    distname_id=NRCELL-12 NRCELL-21 NRCELL-22
    # ...    bts_index=${0}
    # BTS Operation    operation=cell_unblock
    # ...    distname_id=NRCELL-12 NRCELL-21 NRCELL-22
    # ...    bts_index=${0}
    # BTS Operation    operation=cell_block
    # ...    distname_id=NRCELL-ALL
    # ...    bts_index=${0}
    # BTS Operation    operation=cell_unblock
    # ...    distname_id=NRCELL-ALL
    # ...    bts_index=${0}
    # BTS Operation    operation=cell_reset
    # ...    distname_id=NRCELL-ALL
    # ...    bts_index=${0}
    # BTS Operation    operation=cell_reset
    # ...    distname_id=NRCELL-12 NRCELL-21
    # ...    reset_type=hard
    # ...    bts_index=${0}
    # # _bts.get_cell_type_by_distname_id    distname_id=NRCELL-1
    # BTS Operation    operation=cell_group_unlock    distname_id=NRCELLGRP-0
    # ...    bts_index=${1}
    # BTS Operation    operation=bts_reset
    # ...    bts_index=${0}
    # ...    reset_without_ru=${True}
    # BTS Operation    operation=ru_lock    distname_id=RMOD-1 RMOD-2
    # ...    bts_index=${0}
    # BTS Operation    operation=ru_unlock    distname_id=RMOD-1 RMOD-2
    # ...    bts_index=${0}
    # BTS Operation    operation=ru_reset    distname_id=RMOD-1 RMOD-2
    # ...    bts_index=${0}
    # BTS Operation    operation=bbmod_lock    distname_id=BBMOD-1 BBMOD-2
    # ...    bts_index=${0}
    # BTS Operation    operation=bbmod_unlock    distname_id=BBMOD-1 BBMOD-2
    # ...    bts_index=${0}
    # BTS Operation    operation=bbmod_reset    distname_id=BBMOD-1 BBMOD-2
    # ...    bts_index=${0}
    #  BTS Operation    operation=ru_reset    distname_id=RMOD-2
    # ...    bts_index=${0}
    # BTS Operation    operation=ru_reset    distname_id=RMOD-1
    # ...    bts_index=${0}
    # BTS Operation    operation=rat_block    distname_id=NRCELL-ALL
    # ...    bts_index=${0}
    # BTS Operation    operation=rat_unblock    distname_id=LNCEL-ALL
    # ...    bts_index=${0}
    # BTS Operation    operation=rat_reset    distname_id=NRCELL-ALL
    # ...    reset_type=hard
    # ...    bts_index=${0}
    # BTS Operation    operation=verify    verify_status=SITE_ONAIR+CELL_ONAIR
    # ...    bts_index=${0}
    # BTS Operation    operation=x2link_lock    distname_id=LNBTS-6141/LNADJGNB-1
    # ...    bts_index=${0}
    # BTS Operation    operation=x2link_unlock    distname_id=LNBTS-6141/LNADJGNB-1
    # ...    bts_index=${0}
    # BTS Operation    operation=nglink_lock    distname_id=NRBTS-6142/SERVEDAMF-1
    # ...    bts_index=${1}
    # BTS Operation    operation=nglink_unlock    distname_id=NRBTS-6142/SERVEDAMF-1
    # ...    bts_index=${1}
Kw For Counter Module Test2
    ${rule1}    Catenate
    ...    Distname: MRBTS-37668/NRBTS-37668/NRCELL-7;
    ...    Counter: M55142C00524;
    ...    Counter rule: max(M55142C00524)==1;
    ...    Comment: latest
    ${rule_list1}    Create List    ${rule1}
    Counter Operation    operation=start_collect_counter
    ...    counter_rule=${rule_list1}
    ...    product_type=vcu
    Sleep    3 minutes
    ${value1}    Counter Operation    operation=collect_counter_and_check_rule
    ...    product_type=vcu

Kw For Counter Module Test
    # ${rule1}    Catenate
    # ...    Distname: MRBTS-37668/NRBTS-37668/NRCELL-7;
    # ...    Counter: Counter: M55142C00524;
    # ...    Counter rule: max(M55142C00524)==1;
    # ...    Comment: latest
    ${rule1}    Catenate
    ...    Distname: NRCELL-32;
    ...    Counter: X2_SGNB_MEASGP_REL_MOD_REQ;
    ...    Counter rule: max(X2_SGNB_MEASGP_REL_MOD_REQ)>=max(X2_SGNB_MEASGP_REL_MOD_REQ)
    ${rule2}    Catenate
    ...    Distname: All;
    ...    Counter: NRPPA_MEASINIT_FAIL_UNSPEC_D;
    ...    Counter rule: max(NRPPA_MEASINIT_FAIL_UNSPEC_D)>=max(NRPPA_MEASINIT_FAIL_UNSPEC_D)
    # ${rule1}    Catenate
    # ...    Distname: All;
    # ...    Counter: M55319C12005 to M55319C12007,M55319C12009 to M55319C12011;
    # ...    Counter rule: max(M55319C12005 to M55319C12007) >= 0 and has_no_0_value(M55319C12009 to M55319C12011);
    # ...    Comment: latest
    # ${rule2}    Catenate
    # ...    Distname: All;
    # ...    Counter: M55319C12005,M55319C12006,M55319C12007;
    # ...    Counter rule: max(M55319C12005)+max(M55319C12007)/max(M55319C12006)<=max(M55319C12007);
    # ${rule3}    Catenate
    # ...    Distname: All;
    # ...    Counter: M55319C12005;
    # ...    Counter rule: latest(M55319C12005)>0;
    # ${rule_list1}    Create List    ${rule2}    ${rule3}    ${rule1}
    # Log To Console    \nStart to test the Counter Operation module ...\n
    # ${rule1}    Catenate    Distname: MRBTS-10760/NRBTS-10760/NRCELL-3;
    # ...    Counter: M55350C20038 to M55350C20044;
    # ...    Counter rule: avg(M55350C20037 to M55350C20044)==0;
    ${rule_list1}    Create List    ${rule1}    ${rule2}
    # Counter Operation    operation=start_collect_counter
    # ...    counter_rule=${CURDIR}/counter_rule.txt
    # ...    product_type=gnb
    # ...    interval=15
    Counter Operation    operation=start_collect_counter
    ...    counter_rule=${rule_list1}
    ...    product_type=gnb
    ...    pm_type=rd
    # ...    wait_for_next_counter_generate=${TRUE}
    ...    interval=15
    # ${rule_list2}    Create List    ${rule2}
    # Counter Operation    operation=start_collect_counter
    # ...    counter_rule=${rule_list2}
    # ...    product_type=vdu
    # ...    wait_for_next_counter_generate=${TRUE}
    # ...    interval=15
    # sleep    5 min 10s
    sleep    15 min
    # ${value1}    Counter Operation    operation=collect_counter_and_check_rule
    # ...    product_type=vdu
    ${value1}    Counter Operation    operation=collect_counter_and_check_rule
    ...    product_type=gnb
    ...    pm_type=rd
    # ${rule2}    Catenate
    # ...    Distname: MRBTS-11074/NRBTS-11074/NRCELL-1;
    # ...    Counter: M55113C03001;
    # ...    Counter rule: max(M55113C03001)
    # ${rule_list2}    Create List    ${rule2}
    # Counter Operation    operation=start_collect_counter
    # ...    counter_rule=${rule_list2}
    # ...    product_type=vdu
    # ${value2}    Counter Operation    operation=collect_counter_and_check_rule
    # ...    product_type=vcu
    # ${result}    Evaluate    ${value2}[check_result][${rule2}]-${value1}[check_result][${rule1}]
    # sleep    15 min
    # ${value2}    Counter Operation    operation=collect_counter
    # Counter Operation    operation=compare
    # ...    before_counter_value=${value1}
    # ...    after_counter_value=${value2}
KW For UE box
    Set Suite Variable    ${LogName}    Case01
    Traffic Uebox Operation    get_throughput    ue_imsi=460023100012111,460023100008884
    ...    direction=ul
    Traffic Uebox Operation    get_throughput    ue_imsi=460023100012111,460023100008884
    ...    direction=dl
    # Traffic Uebox Operation    start log    ue_imsi=460023100008866,460023100008867
    # ...    LogName=Case01
    # Traffic Uebox Operation    mtu_poweroff    ue_imsi=460023100008866
    # Traffic Uebox Operation    ueip_mapping    ue_imsi=262033100015478,262033100015479
    # Traffic Uebox Operation    start dl traffic    ue_imsi=262033100015478,262033100015479
    # ...    remote_hostname=10.69.53.52
    # ...    remote_username=ute
    # ...    remote_password=UTE.debian12
    # ...    IperfOptions=-u -t 200 -l 1024B -i 1 -b 100M -p 50020
    # sleep    3s
    # Traffic UEBox Operation    stop dl traffic
    # ...    ue_imsi=262033100015478,262033100015479
    # ...    remote_hostname=10.69.53.52
    # ...    remote_username=ute
    # ...    remote_password=UTE.debian12
    # Traffic Uebox Operation    mtu_poweron    ue_imsi=460023100008866,460023100008867
    # Traffic Uebox Operation    start voice call    ue_imsi=460023100008866    Number=6688
    # Sleep    10s
    # Traffic Uebox Operation    stop voice call    ue_imsi=460023100008866
    # Traffic Uebox Operation    operation=exec at cmd
    # ...    ue_imsi=460023100008866,460023100008867
    # ...    atcmd=AT+CIMI    SuccStr=OK    retry_times=3
    # ${task}    Create List    ping
    # Traffic Uebox Operation    operation=start testplan    ue_imsi=460023100008866
    # ...    TestPlans=${task}
    # Sleep    10s
    # Traffic Uebox Operation    operation=stop testplan    ue_imsi=460023100008866
    # Traffic Uebox Operation    detach    ue_imsi=460023100008866,460023100008867
    # Traffic Uebox Operation    operation=start ul traffic
    # ...    ue_imsi=460023100008866,460023100008867
    # ...    remote_hostname=10.70.177.57
    # ...    remote_username=ute
    # ...    remote_password=Ut3pa5s#ff97
    # ...    IperfOptions=-u -t 1000 -i 1 -b 10m -p 50001
    # Traffic Uebox Operation    operation=start dl traffic
    # ...    ue_imsi=460023100008866,460023100008867
    # ...    IperfOptions=-u -t 1000 -i 1 -b 100m -p 50001
    # ...    remote_hostname=10.70.177.57
    # ...    remote_username=ute
    # ...    remote_password=Ut3pa5s#ff97
    # Sleep    60s
    # Traffic Uebox Operation    stop ul traffic    ue_imsi=460023100008866,460023100008867
    # Traffic Uebox Operation    stop dl traffic    ue_imsi=460023100008866,460023100008867
    # ...    remote_hostname=10.70.177.57
    # ...    remote_username=ute
    # ...    remote_password=Ut3pa5s#ff97
    # Traffic Uebox Operation    stop log     ue_imsi=460023100008866,460023100008867
    # Traffic Uebox Operation    fetch log    ue_imsi=460023100008866,460023100008867
    # ...    LogPath=c:\\uelogs    LogName=Case01    LocalDire=~/

Kw For AT Module Test
    AT Operation    operation=detach
    # AT Operation    operation=reboot
    AT Operation    operation=attach
    # AT Operation    operation=attach
    # # AT Operation    operation=reboot
    # AT Operation    operation=start_traffic    IperfOptions=-u -i 1 -t 300 -b 10M -p 50001
    # ...    direction=ul
    # AT Operation    operation=start_traffic    IperfOptions=-u -i 1 -t 300 -b 10M -p 50001
    # ...    direction=dl
    # AT Operation    operation=stop_traffic    direction=ul
    # AT Operation    operation=stop_traffic    direction=dl
    # AT Operation    operation=start_traffic    IperfOptions=-i 1 -t 300 -b 10M -p 50001
    # ...    direction=ul    remote_hostname=10.108.233.142
    # ...    remote_username=spark
    # ...    remote_password=spark123
    # ...    protocol_type=tcp
    # AT Operation    operation=stop_traffic    direction=ul    protocol_type=tcp
    # ...    remote_hostname=10.108.233.142
    # ...    remote_username=spark
    # ...    remote_password=spark123
    # AT Operation    get    item=ueip
    # AT Operation    set    item=apn    before_intf_name=ststatic
    # ...    after_intf_name=ststatic
    # AT Operation    get    item=ueip
    # AT Operation    set    item=apn    before_intf_name=ststatic
    # ...    after_intf_name=ststatic
    # AT Operation    get    item=ueip    intf_name=ims
    AT Operation    operation=start_call    number=6688
    AT Operation    operation=stop_call

Kw For KPI Module Test
    KPI Operation    start_kpi_collection    product_type=gnb
    ...    bts_index=${0}
    # KPI Operation    start_kpi_collection    product_type=gnb
    # ...    bts_index=${1}
    # KPI Operation    add_kpi_collection    product_type=vdu
    # ...    append_product_type=vdu    append_du_index=${1}
    Sleep    30 min
    ${zip_path0}    KPI Operation    finish_kpi_collection    product_type=gnb
    ...    bts_index=${0}
    # ${zip_path1}    KPI Operation    finish_kpi_collection    product_type=gnb
    # ...    bts_index=${1}
    # Sleep    5 min
    # KPI Operation    start_kpi_collection
    # Sleep    33 min
    # ${zip_path2}    KPI Operation    finish_kpi_collection
    # KPI Operation    benchmark_report_generate    pmfile_zip_path1=${zip_path1}
    # ...    pmfile_zip_path2=${zip_path2}

    # ${zip_path}    Set Variable    /home/ute/test_results/kpi_module/OnlyPM_Snapshot_BTS-37421_SBTS25R1_ENB_9999_240926_000007.zip
    # KPI Operation    kpi_report_generate    pmfile_zip_path=${zip_path1}
    # # ...    template=PMKPI_SBTS24R3_5G_up
    # ...    owner=winnie.he@nokia-sbell.com

Kw For Traffic Model
    Airphone Operation    operation=edaemon_egate_setup
    ...                   product_type=gnb
    ...                   traffic_info_dic=${None}
    ...                   tag=${None}
    ...                   cmd=${None}
    ...                   pass_regexp=${None}
    ...                   timeout=100s
    Log to console    use tag SA_TDD_2c_1gNBSim_A_Xn_HO
    Airphone Operation    operation=env_setup_sa
    ...    product_type=gnb
    ...    tag=SA_TDD_2c_1gNBSim_A_Xn_HO
    RRM Traffic With Airphone    traffic_module_config_path=${CURDIR}/traffic_model_inter.json
    ...    timeout=30 min
    ...    need_generate_report=${True}

Kw For Traffic Model Intra
    Airphone Operation    operation=edaemon_egate_setup
    ...                   product_type=gnb
    ...                   traffic_info_dic=${None}
    ...                   tag=${None}
    ...                   cmd=${None}
    ...                   pass_regexp=${None}
    ...                   timeout=100s
    Log to console    use tag SA_TDD_2c_1gNBSim_B_Muting
    Airphone Operation    operation=env_setup_sa
    ...    product_type=gnb
    ...    tag=SA_TDD_2c_1gNBSim_B_Muting
    RRM Traffic With Airphone    traffic_module_config_path=${CURDIR}/traffic_model_vonr.json
    ...    timeout=120 min
    ...    need_generate_report=${True}
    ...    offset_time=${10}

Kw For AP Log Capture
    Common MultiBTS Suite Setup For RRM
    _Create Test Directory
    Airphone Operation    operation=edaemon_egate_setup
    ...                   product_type=gnb
    ...                   traffic_info_dic=${None}
    ...                   tag=${None}
    ...                   cmd=${None}
    ...                   pass_regexp=${None}
    ...                   timeout=100s
    Log to console    use tag SA_TDD_2c_1gNBSim_B_Muting
    Airphone Operation    operation=env_setup_sa
    ...    product_type=gnb
    ...    tag=SA_TDD_2c_1gNBSim_B_Muting
    # Log to console     start to do traffic
    Airphone Attach    ue_id=1    call_type=SA
    Login All Coam Admin
    Start GNB Ttitrace With Streaming Mode
    Airphone Start Traffic    mbps=5m
    sleep    30s
    ${pcap_path}    Stop GNB Ttitrace With Streaming Mode
    ${tag}    Set Variable   tti
    Decoder Tttirace From Pcap To Csv     pcap_path=${pcap_path}
    ...    output_path_with_tag=${TEST_LOG_DIRECTORY}/${tag}
    ${tti_files}    get_all_files_in_dictionary    ${TEST_LOG_DIRECTORY}    ${tag}_ul
    FOR    ${tti_file}    IN    @{tti_files}
        csv_analysis.prepare_csv_parser
        ...   filepath=${tti_file}
        ${filter_values}    Create List    4
        ${rows}    csv_analysis.filter_content_by_parameters    filter_parameter=ulPduDemuxData.rcvdBearers[0].lcId
        ...    filter_value=${filter_values}    parameter=ulPduDemuxData.rcvdBearers[0].rcvdBytes
        ${max_data}    Evaluate    max(${rows})
        Should Be True    ${max_data} > 0
    END