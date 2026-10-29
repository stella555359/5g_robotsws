*** Settings ***
Documentation
...   author: winnie he
...   contact: winnie.he@nokia-sbell.com
...   Description: this is one reference case template, purpose for unified style.

Resource           ../Resources/common_resource.robot
# Resource           ../../Resources/RRM_Custom_Config.robot
# Resource          ../Resources/top50_resource.robot
Suite Setup       Common MultiBTS Suite Setup For RRM
# Suite Setup       Common Suite Setup For RRM
# Test Setup        Common MultiBTS Test Setup For RRM
# Test Setup          Common Test Setup For RRM
# Test Teardown     Common MultiBTS Test Teardown For RRM
# Test Teardown    Common Test Teardown For RRM
# Suite Teardown    Common MutliBTS Suite Teardown For RRM
# Suite Teardown    Common Suite Teardown For RRM
# Force Tags        CRT/CIT/CDRT     #Tag Item
# # ...   PY27
# ...      RAN_5G                    #Product [RAN_5G]
# # ...      CLOUD_5G_CLASSICAL_2xANDROID_ASIBL_ABIAB1_ASIBR_ABILB1_AEQE_ENB   #TLtype, it is for auto trigger by ute cloud
# ...      SBTS00/SBTS21B           # it is for auto trigger by ute cloud with the release
# # ...      STATE_SKIP_AGENT         # it is for auto trigger by ute cloud with gnb state
# ...      RAN_PZ_HAZ_1             #Competence Area
# ...      RAN_PZ_HAZ1_SG07_ST_RRM  #Organization
# ...      TA_LEVEL_22              #Detailed Automation Level[TA_LEVEL_20，TA_LEVEL_21， TA_LEVEL_22]


# Test Timeout    30 minutes

*** Variables ***
# #reduce global paramter as possilbe and automatically got from gNB or __init__
${DEBUG_MODE}            ${TRUE}
# ${REMOTE_MODE}           ${TRUE}
*** Test Cases ***
# #test case name should be same with qc case name without space and special characters
Case_Templatesss
    [Documentation]
    ...    author: winnie.he@nokia-sbell.com
    ...    history change: <date>,<who>,<what and how>
    ...    04.08.2021,winnie.he@nokia-sbell.com,case template draft
    Multi Bts Configuration Id Report
    # [Tags]    CRT    5GC001877    SCF_CB005882-C
    # [Setup]    Common MultiBTS Test Setup For RRM
    # Connect All VM

    # Log    Case Template
#     # Start Multi Bts Log
#     # Sleep    10s
#     # Stop All BTSLog And Download to Local
#     # [Teardown]    Common MultiBTS Test Teardown For RRM

# Case_Template2
#     [Tags]    configuration
#     Log    Case Template For RRM
#     Send ReP With Scf Id    qc_id=334476
#     ...    bts_id=10_5_UTESRAN001T2298
#     ...    case_name=LTE4549-A_FDD_Scell addition is triggered as one step for UE in EN-DC mode
#     ...    sw=SBTS00_ENB_9999_230412_000003
#     ...    testline=10_5_UTESRAN001T2298

# Case_Template3
#     [Tags]    configuration
#     Log    Case Template For RRM
#     Send ReP With Scf Id    qc_id=334476
#     ...    bts_id=10_5_UTESRAN001T2298
#     ...    case_name=LTE4549-A_FDD_Scell addition is triggered as one step for UE in EN-DC mode
#     ...    sw=SBTS00_ENB_9999_230412_000003
#     ...    testline=10_5_UTESRAN001T2298

# Check Latest Two PM File Of Counter M8006C254
#     PM_counters_collector
#     ${pi_list}    Create List    M55324C00000
#     ${value1}    Get_PM_counters_values    ${pi_list}
#     Log to console    ${value1}
#     Change Latest PM File Name
#     ${status}    ${value2}    Run Keyword And Ignore Error    Get_PM_counters_values    ${pi_list}
#     Log to console    ${value2}
#     Log to console    ${status}
#     ${sum_value1}    Sum Counter Value Of Pi Value List    ${value1}    M55324C00000
#     Return From Keyword If    '${status}'!='PASS'    ${sum_value}
#     ${sum_value2}    Sum Counter Value Of Pi Value List    ${value2}    M55324C00000
#     ${sum_value}    evaluate    ${sum_value1}+${sum_value2}
# Restart PA By APC
#     # ${status}    Run Keyword And Return Status    Ping Check     ip=${tl.pdus[${APC_Index}].addr}
#     # Return From Keyword If    ${status}
#     pdu.setup_pdu    model=${tl.pdus[${APC_Index}].vendor}    host=${tl.pdus[${APC_Index}].addr}
#     ...    alias=apc
#     pdu.power_off    port=${tl.pdus[${APC_Index}].pdu_ports[1].port_no}    pdu_device=apc
#     pdu.power_on     port=${tl.pdus[${APC_Index}].pdu_ports[1].port_no}    pdu_device=apc

# Kw Test
#     Wait All GNB Status
# Kw Test2
#     [Tags]    SCF_10_5_UTESRAN001T2298_LTE4549
#     Commission Full SCF For One GNB     bts_index=${0}
#     Commission Full SCF For One GNB     bts_index=${1}

# Kw Test For Kpi
#     COAM_Admin.Login
#     # COAM_Admin.ResetSite
#     # Wait One GNB Status    bts_index=${0}
#     # ${site_reset_list}    Create List    kpi1a    kpi1b    kpi1c
#     # Calculate KPI    kpi_list=${site_reset_list}    connection=COAM

# Kw Test For upgrade
#     COAM_Admin.Login    log_dir=${TEST_LOG_DIRECTORY}
#     ...    alias=COAM_0
#     # coam.update_software    sw_package=/home/ute/Downloads/SBTS00_ENB_9999_220802_000003.zip
#     # ...                     should_activate=${True}
#     # ...                     timeout=${3600}
#     # ...                     connection=COAM_0
#     # Wait All GNB Status    expect_status=OnAir
#     ${disconnect_ims_file}    _Get Disconnect IMS Before Upgrade
#     ...    connection=COAM_0
#     ...    last_connected_ims_path=/home/ute/test_results
#     ${all_ims}    Create List    ${disconnect_ims_file}
#     ${site_reset_list}    Create List    kpi2a    kpi2b    kpi2c    kpi2d
#     Calculate KPI    kpi_list=${site_reset_list}    connection=COAM_0
#     ...    all_ims=${all_ims}
# kw test For ADB
#     ADB.Prepare UE
#     ADB.UE Detach
#     ADB.UE Attach
#     ADB.Restart ADB
#     ADB.Make A Call    number=6688
#     Sleep    5s
#     ADB.UE Detach
#     ADB.UE Attach
#     ADB.Make Emergency Call    number=911
#     ADB.Click By Point    point_x=${Qualcomm_Point}[END_Call][0]
#     ...    point_y=${Qualcomm_Point}[END_Call][1]
#     ADB.Reboot UE
#     ADB.Make Emergency Call    number=911
#     ADB.Click By Point    point_x=${Qualcomm_Point}[END_Call][0]
#     ...    point_y=${Qualcomm_Point}[END_Call][1]
#     ADB.Teardown All
# kw test For AT
#     # Get Iperf Info
#     AT.Prepare UE
#     # AT.UE Detach
#     # AT.Reboot UE
#     AT.UE Attach
#     AT.Get UE IP
#     AT.Get UE IP
#     # AT Operation    operation=start_traffic    IperfOptions=-u -i 1 -t 300 -b 10M -p 50001
#     # ...    direction=ul
#     # AT Operation    operation=start_traffic    IperfOptions=-u -i 1 -t 300 -b 10M -p 50001
#     # ...    direction=dl
#     # AT Operation    operation=stop_traffic    direction=ul
#     # AT Operation    operation=stop_traffic    direction=dl
#     # #
#     # AT.Get IPV4 APN
#     # AT.Voice Call
#     # AT.End Call
#     # AT.Get UE IP
#     AT Operation    operation=get    item=ueip    intf_name=ims
#     AT Operation    operation=exec_at_command    command=AT
#     # AT.UE Emergency Call
#     # AT.End Call
#     # Start DL traffic By Iperf    time=200
#     # sleep    5s

# # Kw Test For BIP Log
# #     Create BTS INFO Global Dictionary    gnb_index=1
# #     ${executor}    Get L1l2bipLogs BTS_INFO    bts_index=1    host=192.168.255.129
# #     Start L1l2bipLogs Internal Collect    ${executor}
# #     Sleep    10s
# #     Stop L1l2bipLogs Internal Collect
# #     # [Teardown]    Stop L1l2bipLogs Internal Collect

# Kw Test For BIP Log
#     Create BTS INFO Global Dictionary    gnb_index=1
#     ${executor}    Get L1l2bipLogs BTS_INFO    bts_index=1    host=192.168.255.129
#     Start L1l2bipLogs Internal Collect    ${executor}
#     Sleep    10s
#     Stop L1l2bipLogs Internal Collect
#     # [Teardown]    Stop L1l2bipLogs Internal Collect

# Kw Test For BIP Log gnbtool
#     gnb_tool.prepare_gnb_tool
#     gnb_tool.start_to_capture_bip_log_with_gnb_tool    log_dire=${TEST_LOG_DIRECTORY}
#     ...    host=${BTS0_PC_INFO.Host}
#     ...    username=${BTS0_PC_INFO.USERNAME}
#     ...    password=${BTS0_PC_INFO.PASSWORD}
#     Sleep    10s
#     gnb_tool.stop_bip_log_with_gnb_tool


# Kw Test For Scout
#     # ${qc_path}    Set Variable    ${CURDIR}${/}..${/}UTE_Case${/}${TESTLINE_NAME}.qc
#     # Get SCF Internal Id By Scout    no_ute=${False}
#     Send ReP With Scf Id    qc_id=284538    case_name=OAM_Stability_5G_Upgrade_SA_call
#     ...    sw=SBTS23R3_ENB_9999_230511_000008    bts_id=10_5_UTESRAN001T6142    testline=${TESTLINE_NAME}

# Kw Test For APN
#     AT.Prepare UE
#     ${cid}    ${apn_str}    AT.Get IPV4 APN
#     AT.Set IPV4 APN    cid=${cid}    pdp_type=${pdp_type}    apn_str=stmdrb4
#     Sleep    20s
#     AT.Set IPV4 APN    cid=${cid}    pdp_type=${pdp_type}    apn_str=${apn_str}

# Kw Test For APN by ADB
#     ADB.Prepare UE
#     Log to Console    Start to set apn
#     Sleep    10s
#     Qualcomm.Change APN    apn=mdrb.nokia.com
#     # Qualcomm.Change APN    apn=stdata1

# Kw Test For Ttitrace
#     Connect All VM
#     Prepare Ttitrace Pstools    alias=BTS0_VM

# Kw Test For Ttitrace By gnbtool
#     gnb_tool.prepare_gnb_tool
#     gnb_tool.start_to_capture_tti_log_with_gnb_tool    log_dire=${TEST_LOG_DIRECTORY}
#     # ...    dest_ip=10.0.81.7
#     # ...    username=root
#     # ...    password=winnie
#     Sleep    5s
#     gnb_tool.stop_tti_log_with_gnb_tool

# Kw Test For Traffic
#     [Documentation]    he winnie
#     Init Attenuation All Max    max_value=${PA_MaxValue}
#     # Ajust PA to ENDC
#     # Connect All VM
#     # Start Multi Bts Log
#     # ADB.Prepare UE
#     # ADB.UE Attach
#     # gnb_tool.prepare_gnb_tool
#     # ADB.Start Traffic    tput_type=DL
#     # ...    server_ip=${BTS0_PC_INFO.Host}
#     # ...    client_connection=BTS0_VM
#     # ADB.Start Traffic    tput_type=UL
#     # ...    server_ip=${BTS0_PC_INFO.Host}
#     # ...    server_connection=BTS0_VM
#     # ...    client_connection=cpc_0
#     # ...    client_iperf_path=/data/iperf
#     # ...    tput_port=50002
#     # gnb_tool.start_to_capture_tti_log_with_gnb_tool
#     # ...    log_dire=${TEST_LOG_DIRECTORY}
#     # ...    host=${BTS0_PC_INFO.Host}
#     # ...    dest_ip=10.108.231.24
#     # Sleep    60s
#     # ADB.Stop Traffic     tput_type=DL
#     # ...    iperf_port=50001
#     # ...    client_connection=BTS0_VM
#     # ADB.Stop Traffic     tput_type=UL
#     # ...    iperf_port=50002
#     # ...    server_connection=BTS0_VM
#     # ...    client_connection=cpc_0
#     # gnb_tool.stop_tti_log_with_gnb_tool
#     # Stop All Bts Log

# Kw test for send_email
#     # send_email    receiver="winnie.he@nokia-sbell.com"
#     gnb_tool.stop_and_fix    receiver="winnie.he@nokia-sbell.com"
# # Kw Test For Csv
# #     csv_analysis.prepare_csv_parser    filepath=/home/ute/logs/1740_TTI.bin.19.ul__all.csv
# #     ${rows}    csv_analysis.filter_content_by_parameters    parameter=lcid
# #     ...    value=5
# #     ${result}    csv_analysis.get_value_list_of_rows    parameter=rcvdBytes
# #     ...    rows=${rows}
# #     ...    formulate=avg
# #     Log To Console    ${result}
# Kw Test command
#     ${ret}    OperatingSystem.Run    command=pip list
#     Log to Console    ${ret}

# Kw Test for Counter
#     # ${re_values}    Create Dictionary    a    v
#     # ${values}    Create Dictionary    b=${re_values}
#     # ${val}    Create Dictionary    c=${values}
#     # ${v}    Create Dictionary    d=${val}
#     # _Get Values Of Key By Recursion Dict    dict=${v}    key=a    max_deep=${2}
#     ${counters}    Create List    M8012C23
#     COAM_Admin.Login    bts_host=10.69.70.2
#     ${end_time}    Get Current Date    time_zone=UTC
#     ${start_time}    Subtract Time From Date    ${end_time}    20 minutes
#     Get Pm Counters Of Period    counters=${counters}
#     ...    start_time=${start_time}
#     ...    end_time=${end_time}
#     ...    cell_id=LNCEL-10

# Kw Test For Get_PM_counters_values_For_Period
#     # ${end_time}    Get Current Date    time_zone=UTC    result_format=%Y%m%d.%H%M%S
#     # ${start_time}    Subtract Time From Date    ${end_time}    10 minutes
#     ${pi_list}    Create List    M55363C00001
#     # # PM_counters_collector
#     # PM_counters_collector    gnb_id=${1}
#     ${end_time}    Get Current Date    time_zone=UTC    result_format=%Y%m%d.%H%M%S
#     ${start_time}    Subtract Time From Date    ${end_time}    10 minutes
#     PM_counters_collector    gnb_id=${1}
#     ${value1}    Get_PM_counters_values_For_Period    start_time=${start_time}
#     ...    end_time=${end_time}
#     ...    pi_list=${pi_list}
#     ...    bts_index=${1}
#     Sum Counter Value Of Pi Value List    ${value1}    M55363C00001
#     ...    dn=MRBTS-306/NRBTS-306/NRCELL-1/PLMN-PLMN/NRPMQAP-3
# Kw Test for Cell operation
#     # COAM_Admin.Login    bts_host=10.69.70.2
#     COAM_Admin.Login    bts_host=10.68.152.209
#     COAM_Admin.Block_CELL    global_cell_id=3 31   cell_type=lte
#     sleep    30s
#     COAM_Admin.unBlock_CELL    global_cell_id=3 31    cell_type=lte
#     COAM_Admin.Lock_CELL_By_Global_Cell_Id    global_cell_id=28 29
#     sleep    30s
#     COAM_Admin.Unlock_CELL_By_Global_Cell_Id    global_cell_id=1 28

# Kw Test for Multi UE
#     # AT.Prepare UE    ue_index=${1}
#     Attach UE By AT    ue_index=${0}
#     Run Keyword    ${UE_TYPE}.Teardown UE    ue_index=${0}
#     # AT.Prepare UE    ue_index=${0}
#     Attach UE By AT    ue_index=${1}
#     Run Keyword    ${UE_TYPE}.Teardown UE    ue_index=${1}
# # Kw Test For UE IP
# #     Attach UE By AT    ue_index=${0}
# #     AT.Get UE IP
# Kw Test for Iperf UE
#     Attach UE By AT    ue_index=${0}
#     ${dl_server1}    Connect To IperfServer From Appservers    index=${0}
#     Start DL traffic By Iperf     DL_port=${tl.appservers[0].iperf_details.port}
#     ...    dl_server=${dl_server1}
#     Run Keyword    ${UE_TYPE}.Teardown UE    ue_index=${0}
#     Attach UE By AT    ue_index=${1}
#     ${dl_server2}    Connect To IperfServer From Appservers    index=${1}
#     Start DL traffic By Iperf     DL_port=${tl.appservers[1].iperf_details.port}
#     ...    dl_server=${dl_server2}    ue_index=${1}
#     Run Keyword    ${UE_TYPE}.Teardown UE    ue_index=${1}
#     sleep    20s
#     Base.__Stop Traffic    client_connection=${dl_server1}
#     Base.__Stop Traffic    client_connection=${dl_server1}

# Kw Test For Gloden Scf
#     [Tags]    SCF_10_5_UTESRAN001T887
#     sleep    5s
#     [Teardown]    Common MultiBTS Test Teardown For RRM
#     ...    other_method=Commission Golden SCF For All GNB

# Kw Test For Multi Counter
#     PM_counters_collector
#     ${pi_list}    Create List    M8012C203
#     Get_PM_counters_values    pi_list=${pi_list}
#     PM_counters_collector    gnb_id=${1}
#     ${pi_list}    Create List    M8012C203
#     Get_PM_counters_values    pi_list=${pi_list}    bts_index=${1}

# Kw Test For upgrade Choose
#     Download Package    package=SBTS00_ENB_9999_230412_000014

# Kw Test for ssh Reconnect
#     Teardown All GNB FCT Connect
#     Connect To One Site FCT
#     Connect To One Site FCT

# OAM_Stability_4G_Upgrade_ENDC_call
#     Set Test Variable    ${TESTLINE_NAME}    10_5_UTESRAN001T6142
#     UUF4ALL Send QC For Custom

# Kw Test For UE IP
#     ${ret_string_list}    Create List    +CGPADDR: 2,10.70.245.34,42.0.138.5.64.33.15.175.0.0.0.0.10.186.100.110
#     ...        +CGPADDR: 5,10.70.212.78
#     AT.__Get All IP    ${ret_string_list}
#     ${ret_string_list}    Create List    +CGPADDR: 1,"172.252.161.172","253.176.219.13.156.84.198.175.0.0.0.0.4.4.222.209"
#     ...        +CGPADDR: 5,10.70.212.78
#     AT.__Get All IP    ${ret_string_list}

# Kw Test For UE Reboot
#     # AT.Prepare UE    index_of_yaml=${0}
#     # # AT.Reboot UE
#     # AT.Teardown UE
#     ADB.Prepare UE
#     ADB.UE Attach
#     ADB.UE Detach
#     # ADB.Reboot UE
#     # ADB.Make A Call    number=10086
#     # Sleep    3s
#     # ADB.End Call
# Kw For Alarms
#     Log to console    ${ALLOWED_FAULT}

# Kw Test For UE Voice Call
#     AT.Prepare UE    ue_index=${0}    index_of_yaml=${1}
#     AT.UE Attach
#     AT.Get UE IP
#     AT.Prepare UE    ue_index=${0}
#     AT.UE Attach
#     AT.Get UE IP
#     # AT.UE Detach
#     # AT.Reboot UE
#     # AT.UE Attach
#     # ADB.Reboot UE
#     # ADB.Make A Call
#     # Sleep    3s
#     # ADB.End Call
# Kw For Btslog
#     Connect All VM
#     Start Multi Bts Log
#     Sleep    10s
#     Stop All BTSLog And Download to Local
# Kw For Rep Tags
#     Set Tags    QCD_MN_RAN    QCP_RAN_ST    QC_284537
#     [Teardown]    TL Test Teardown
# Kw For Connect To Emil
#     Login All Coam Admin
#     ${enb_custom_profile_list}    Create List    cp_4g
#     ${gnb_custom_profile_list}    Create List    cp_5g
#     Connect To DCAP And Start Trace
#     ...    enb_custom_profile_list=${enb_custom_profile_list}
#     ...    gnb_custom_profile_list=${gnb_custom_profile_list}
#     sleep    1min
#     Run Keyword And Ignore Error
#     ...    L3 Call    cell_used_in_test=${Space}    bts_index=${0}
#     ...        pre_attach_kw=Lock Band
#     ${site_type_list}    Create List    5g
#     Stop Trace In DCAP and Convert It To CSV    site_type_list=${site_type_list}
#     [Teardown]    Run Keyword And Ignore Error
#     ...    Run Keyword If    '${${bts_ip}_dcap_trace_stop}'=='${False}'
#     ...    Stop Trace In DCAP    btsip=${host}
# Keyword For Get team name
#     _Create Test Directory
#     Log To console    ${SUITE SOURCE}
#     Collect Coam Snapshot
#     Collect Coam Snapshot For One GNB
#     # Start Multi Bts Log
#     # Start tcpdump by command For Remote
#     # sleep    1min
#     # Stop tcpdump And download by command For Remote
#     # Download wireshark log to testvm For Remote
#     # Stop All BTSLog And Download to Local

# KW For Gloden Scf
#     Log to console    Teardown
# Kw For APN uiauto
#     Log To Console    set apn
#     ADB.Prepare UE
#     Qualcomm.Set APN By Uiauto    apn=stdata1
#     Qualcomm.Get APN By Uiauto

# Kw For Site Commission By Python
#     [Tags]    SCF_10_5_UTESRAN001T887
#     Connect All VM
#     ${commission_scf_path}    Set Variable    ${CURDIR}/../Resources/python/SiteOperation.py
#     ${release}    Get Release By Sw Version    sw=${BTS0_ACTIVE_SW_VERSION}
#     ${scf_file_path1}    Get Golden Scf Path    scf_posttag=BTS0    release=${release}
#     ${scf_file_path2}    Get Golden Scf Path    scf_posttag=BTS1    release=${release}
#     ${cmd1}    Catenate    python ${commission_scf_path} --host ${BTS0_INFO.IP} --action commission
#     ...    --params ${scf_file_path1}
#     ${cmd2}    Catenate    python ${commission_scf_path} --host ${BTS1_INFO.IP} --action commission
#     ...    --params ${scf_file_path2}
#     ${ret2}    csn.send command    command=${cmd2} &    connection=BTS0_VM
#     ${ret1}    csn.send command    command=${cmd1} &    connection=BTS0_VM
#     Sleep    5min
# KW for pcmd wireshark
#     Prepare Wireshark For PCMD
#     Log to Console     Prepare Wireshark For PCMD

# KW for PCF
#     ${pcf_simulator}=  Pet PCF Simulator Setup
#     ...    host=10.56.218.70    username=ute    password=Nokia123!
#     ...    appname=sim-5g-new
#     Run Script File On PCF Simulator    ${pcf_simulator}    ${CURDIR}/5QI9.pcf
#     Pet PCF Simulator Teardown    ${pcf_simulator}
#     # ${connection}    PCF Setup    host=10.56.218.70
#     # ...    username=ute
#     # ...    password=Nokia123!
#     # ...    cmd_path=${CURDIR}/../Resources/config/CB008126_PCF_simulator.txt
#     # PCF Send Command    cmd_start_string=add one Qos rule -5QI     connection=${connection}

# KW For Collect Pm
#     Connect All VM
#     Classical Collect Pm Files And Post To BenchMark

# KW for UE TYPE
#     translate_power_ue_type_from_testline

# # Kw For Wireshark Test
# #     Parse Pcap To Get The Lcid
# Kw Run Cmd Of File In Remote Server
#     gnb_tool.send_email    content=abctest    receiver=winnie.he@nokia-sbell.com

# KW For Magic Iperf
#     ADB.Prepare UE
#     Qualcomm.Start UL Traffic By Uiauto
#     ...    server_ip=10.70.177.52
#     Qualcomm.Stop UL Traffic By Uiauto

# Kw For Upgrade
#     COAM_Admin.Upgrade From Console Mode
#     ...    package_path=/home/ute/Downloads/SBTS00_ENB_9999_240714_000007_release_BTSSM_downloadable_A54.zip
#     ...    scf_path=/home/ute/test_results/old_commission.xml

# KW For LMI Log Fetch
#     # Prepare BTSLite For Btslog
#     Run Keyword And Ignore Error    Run keyword If
#     ...    '${MoveLog_to_Logserver}'=='${True}' and "_AP_" not in '${TESTLINE_TYPE}'
#     ...    Move All Test Result To Log Server
#     # ${name}    Start tcpdump by command For Local VM    append_str=host 10.69.4.93
#     # sleep    5s
#     # Stop tcpdump And download by command For Local VM    log_name=${name}
#     # Reboot RRU By LMI
#     # LMI Log Collection
# Kw For tti Capture
#     Start Capture Tti Log By VM dcap    cell_index=111
#     Stop Tti Log Collection
# KW For Emil
#     Start Capture Emil Log By VM dcap    bts_index=${0}
#     # # to do something
#     AT.Prepare UE    ue_index=${0}
#     AT.UE Attach
#     ${log_path}    Stop Emil Log Collection    bts_index=${0}
#     ${filter}    Create List    ECAUSE_RESUME
#     Analysis Emil Log    ${log_path}    ${filter}
# Kw For csv analysis
#     csv_analysis.Filter Content By Parameters
#     ...    filter_parameter=lcId
#     ...    filter_value=6
#     ...    parameter=scheduledBytesPerBearer
#     ...    filepath=/home/ute/logs/1740_TTI.bin.19.ul__all.csv
# Kw For upgrade ute-ca
#     Upgrade ute-ca
# Scout share
#     Start Scout Cli
# *** Keywords ***
# struce parameter change
#     COAM_Admin.Login    bts_host=10.69.64.131
#     ${value_test1}    Create dictionary    accessCategory=3    uacBarringInfoSetIndex=1
#     ${value_test2}    Create dictionary    accessCategory=7    uacBarringInfoSetIndex=2
#     ${list}    Create List    ${value_test1}    ${value_test2}
#     ${dict}=    create dictionary    parameterName=uacAcCatList
#     ...                              operation=update
#     ...                              value=${list}
#     @{parameter_list}    Create List    ${dict}
#     coam.perform_object_recommissioning    dist_name=MRBTS-302/NRBTS-302/NRCELL-3
#     ...                                    parameter=${parameter_list}
#     ...                                    operation=update
#     ...                                    skip_parameter_relation_errors=${true}
#     ...                                    should_activate=${true}
#     ...                                    connection=COAM
# Lock Band
#     AT.Lock Frequency    lock_parameter=1,1,0,627264,345,1,5078
#     AT.Variable UE Set

# Ajust PA to ENDC
#     # Modify Attenuation For One RRU Of One Site    ru_id=${1}    gnb_id=${0}    value=${PA_MinValue}
#     # Modify Attenuation For One RRU Of One Site    ru_id=${2}    gnb_id=${0}    value=${PA_MinValue}
#     # Modify Attenuation For One RRU Of One Site    ru_id=${3}    gnb_id=${0}    value=${PA_MinValue}
#     Modify Attenuation For One RRU Of One Site    ru_id=${0}    gnb_id=${1}    value=${PA_MinValue}
#     # Modify Attenuation For One RRU Of One Site    ru_id=${0}    gnb_id=${0}    value=${PA_MinValue}
# # Start Multi Bts Log
# #     Prepare BTSLite For Btslog
# #     ${log_start_time}    Get TimeStamp With Date
# #     Start BTSLite For Btslog On VM    vm_index=0    btslog_name=syslog_${log_start_time}.log
# #     Start BTSLite For Btslog On VM    vm_index=1    btslog_path=/home/ute
# #     ...    btslog_name=remote_syslog_${log_start_time}.log
# #     Start BTSLite For Btslog On VM    vm_index=2    btslog_path=/home/ute
# #     ...    btslog_name=remote_syslog_${log_start_time}.log
# #     Start BTSLite For Btslog On VM    vm_index=3    btslog_path=/home/ute
# #     ...    btslog_name=remote_syslog_${log_start_time}.log
# Stop All Bts Log
#     Stop All BTSLog And Download to Local
