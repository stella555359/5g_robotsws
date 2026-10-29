*** Settings ***
#Resource    ./../../5GC000738/Resources/5GC000749A_common_keywords.robot
#Resource    ./../../../../OAM/Krakow/Resources/robot/UE_keywords.robot
#Resource    ./../../../../OAM/Krakow/Resources/robot/Common.robot
#Resource    ./../../../../OAM/Krakow/Resources/robot/OAM5G_keywords.robot
#Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/Commercial_mobile_phone_adb_common_keywords.robot
Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/android_common_keyword.robot
Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/traffic_via_iperf.robot
Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/power_ue/power_ue.robot
Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/CI_Operations/CI_interface.robot
#Resource    ./../../../../../resources/common/tm500.robot
Library     taf.ue.tm500.asc      WITH NAME    asc

Documentation
...   author: Shi Ming
...   contact: ming.shi@nokia-sbell.com
...   squad group: SG_03
...   feature : 5GC0001927-T

*** Variables ***
${enb_instance}     ${tl.enbs[0].instance_id}
${enbx2_dist}    MRBTS-${enb_instance}/LNBTS-${enb_instance}/LNADJGNB-0
${enbx2_dist_349}    MRBTS-${enb_instance}/LNBTS-${enb_instance}/LNADJGNB-1
${enbmme_dist}    MRBTS-${enb_instance}/LNBTS-${enb_instance}/LNMME-0
${enbmme_para}    ipAddrPrim
${enbmme_para2}    administrativeState
${actMultiSCGSplitwoeLcId_dist}    MRBTS-${enb_instance}/LNBTS-${enb_instance}
${actMultiSCGSplitwoeLcId_para}    actMultiSCGSplitwoeLcId
${epcsim_ip}    ${tl.core.default_ssh_connection_details.addr}
${realepc_ip_30}    10.107.182.164
${realepc_ip_233}    10.107.182.164
${realepc_ip_38}    10.107.245.164
${realepc_ip_349}    10.107.245.164
${realepc_ip_32}    10.107.182.164
${EPCsim_DL_port}    5501
${EPCsim_UL_port}    5502

#####viavi relate variable#####
${TMA_APP_PATH}    ${tl.ues[0].tma_path}
${E500_IP}    ${tl.ues[0].tma_host.addr}
${E500_USER}    ${tl.ues[0].tma_host.username}
${E500_PW}    ${tl.ues[0].tma_host.password}
${E500_SCRIPTS_BASE}    ${CURDIR}/E500_scripts
${LUA_SCRIPT_PATH}     /home/ute/luashark/generated_luashark/luashark.lua
${TMA_SSH_ALIAS}    tma_ssh
${TMA_TELNET_ALIAS}    tma
${TMA_APP_ALIAS}    e500
${TMA_ASC_ALIAS}    ASC
${E500_ASC_USER}    switch
${E500_ASC_PW}    switch
${E500_ASC_PORT}    10011

*** Keywords ***
set e1ap variable
    run keyword if    '${enb_instance}'=='233'    set e1ap variable on TL233
    run keyword if    '${enb_instance}'=='38'    set e1ap variable on TL38
    run keyword if    '${enb_instance}'=='30'    set e1ap variable on TL30
    run keyword if    '${enb_instance}'=='37'    set e1ap variable on TL349
    run keyword if    '${enb_instance}'=='32'    set e1ap variable on TL32
    run keyword if    '${enb_instance}'=='39'    set e1ap variable on TL32

set e1ap variable on TL233
    Set Suite Variable    ${e1ap_filter}    e1ap
    Set Suite Variable    ${e1ap}    e1ap

set e1ap variable on TL38
    Set Suite Variable    ${e1ap_filter}    e1ap
    Set Suite Variable    ${e1ap}    e1ap

set e1ap variable on TL30
    Set Suite Variable    ${e1ap_filter}    e1ap
    Set Suite Variable    ${e1ap}    e1ap

set e1ap variable on TL349
    Set Suite Variable    ${e1ap_filter}    e1ap
    Set Suite Variable    ${e1ap}    e1ap

set e1ap variable on TL32
    Set Suite Variable    ${e1ap_filter}    e1ap
    Set Suite Variable    ${e1ap}    e1ap

get QPM path
    run keyword if    '${enb_instance}'=='233'    get QPM path on TL233
    run keyword if    '${enb_instance}'=='38'    get QPM path on TL38
    run keyword if    '${enb_instance}'=='37'    get QPM path on TL349
    run keyword if    '${enb_instance}'=='39'    get QPM path on TL349

get QPM path on TL233
    Set Suite Variable    ${LKC_CLIENT_PATH}    /cygdrive/c/Users/tester/Desktop/QPM_LK1.3

get QPM path on TL38
    Set Suite Variable    ${LKC_CLIENT_PATH}    /cygdrive/c/Users/nokia5G/Desktop/QPM_LK1.3.1

get QPM path on TL349
    Set Suite Variable    ${LKC_CLIENT_PATH}    /cygdrive/c/Users/nokia5G/Desktop/QPM_LK1.3.1

Preparation UE on setup
#    run keyword if    '${enb_instance}'=='32'    Set Suite Variable    ${brand}    Viavi
#    run keyword if    '${enb_instance}'=='39'    power_ue.Prepare UE    ue_type=huawei    ue_index=${2}
#    ...    ELSE    power_ue.Prepare UE    ue_type=huawei
    power_ue.Prepare UE    ue_type=huawei

Enb use Multi-DRB
#    run keyword if    '${enb_instance}'=='@{diffTL_enb_ID}[2]'    Connect and Modify the parameter on enblte
#    ...    dist_name=${actMultiSCGSplitwoeLcId_dist}    parameter=${actMultiSCGSplitwoeLcId_para}    value=true
    Connect and Modify the parameter on enblte
    ...    dist_name=${actMultiSCGSplitwoeLcId_dist}    parameter=${actMultiSCGSplitwoeLcId_para}    value=true

Enb use Single-DRB
#    run keyword if    '${enb_instance}'=='@{diffTL_enb_ID}[2]'    Connect and Modify the parameter on enblte
#    ...    dist_name=${actMultiSCGSplitwoeLcId_dist}    parameter=${actMultiSCGSplitwoeLcId_para}    value=false
    Connect and Modify the parameter on enblte
    ...    dist_name=${actMultiSCGSplitwoeLcId_dist}    parameter=${actMultiSCGSplitwoeLcId_para}    value=false

Enb use EPCsim
    Connect and Modify the parameter on enblte    dist_name=${enbmme_dist}    parameter=${enbmme_para}    value=${epcsim_ip}
    Connect and Modify the parameter on enblte    dist_name=${enbmme_dist}    parameter=${enbmme_para2}    value=locked

Enb use RealEPC
    run keyword if    '${enb_instance}'=='30'    Enb use RealEPC on TL30
    run keyword if    '${enb_instance}'=='233'    Enb use RealEPC on TL233
    run keyword if    '${enb_instance}'=='38'    Enb use RealEPC on TL38
    run keyword if    '${enb_instance}'=='37'    Enb use RealEPC on TL349
    run keyword if    '${enb_instance}'=='32'    Enb use RealEPC on TL32
    run keyword if    '${enb_instance}'=='39'    Enb use RealEPC on TL32

Enb use RealEPC on TL30
    Connect and Modify the parameter on enblte    dist_name=${enbmme_dist}    parameter=${enbmme_para}    value=${realepc_ip_30}
    Connect and Modify the parameter on enblte    dist_name=${enbmme_dist}    parameter=${enbmme_para2}    value=unlocked

Enb use RealEPC on TL233
    Connect and Modify the parameter on enblte    dist_name=${enbmme_dist}    parameter=${enbmme_para}    value=${realepc_ip_233}
    Connect and Modify the parameter on enblte    dist_name=${enbmme_dist}    parameter=${enbmme_para2}    value=unlocked

Enb use RealEPC on TL38
    Connect and Modify the parameter on enblte    dist_name=${enbmme_dist}    parameter=${enbmme_para}    value=${realepc_ip_38}
    Connect and Modify the parameter on enblte    dist_name=${enbmme_dist}    parameter=${enbmme_para2}    value=unlocked

Enb use RealEPC on TL349
    Connect and Modify the parameter on enblte    dist_name=${enbmme_dist}    parameter=${enbmme_para}    value=${realepc_ip_349}
    Connect and Modify the parameter on enblte    dist_name=${enbmme_dist}    parameter=${enbmme_para2}    value=unlocked

Enb use RealEPC on TL32
    Connect and Modify the parameter on enblte    dist_name=${enbmme_dist}    parameter=${enbmme_para}    value=${realepc_ip_32}
    Connect and Modify the parameter on enblte    dist_name=${enbmme_dist}    parameter=${enbmme_para2}    value=unlocked

Prepare the classical COAM BTS cell onair on 1927
    ${cell_status}    ${cell_value} =    Run Keyword And Ignore Error    Prepare with COMA classical BTS cell onair on 1927
    set global variable    ${cell_status}

Prepare with COMA classical BTS cell onair on 1927
    Perform full commission for COAM gnb on 738    scf=${SCF_path}${SCF_file_name}
    run keyword if    '${enb_instance}'!='37'
    ...    Connect and Modify the parameter on enblte    dist_name=${enbx2_dist}    parameter=${enbx2_para}    value=locked
    run keyword if    '${enb_instance}'=='37'
    ...    Connect and Modify the parameter on enblte    dist_name=${enbx2_dist_349}    parameter=${enbx2_para}    value=locked
    run keyword if    '${enb_instance}'!='37' and '${enb_instance}'!='39' and '${enb_instance}'!='38'
    ...    Check gnb COAM classical start normally
    run keyword if    '${enb_instance}'=='37' or '${enb_instance}'=='39' or '${enb_instance}'=='38'
    ...    Check gnb COAM classical start normally on TL349
    run keyword if    '${enb_instance}'!='37'
    ...    Connect and Modify the parameter on enblte    dist_name=${enbx2_dist}    parameter=${enbx2_para}    value=unlocked
    run keyword if    '${enb_instance}'=='37'
    ...    Connect and Modify the parameter on enblte    dist_name=${enbx2_dist_349}    parameter=${enbx2_para}    value=unlocked
    run keyword if    '${enb_instance}'!='37' and '${enb_instance}'!='39' and '${enb_instance}'!='38'
    ...    5GC000749A_common_keywords.Check the gnb cell status onair    cell_no=2
    run keyword if    '${enb_instance}'=='37' or '${enb_instance}'=='39' or '${enb_instance}'=='38'
    ...    5GC000749A_common_keywords.Check the gnb cell status onair

Check gnb COAM classical start normally on TL349
#    Check Airscale HW module status
    ${res} =    Feature 1514 Enabled
#    run keyword if    ${res}==${False}    wait until keyword succeeds    10min   30s
#    ...    5GC000749A_common_keywords.Check the sctp port UP    port_num=${f1_sctp_port}
    sleep    300s
#    wait until keyword succeeds    10min    20s    Check the gnb RU status ready on TL349
#    wait until keyword succeeds    5min   30s    5GC000749A_common_keywords.Check the sctp port UP    port_num=${x2_sctp_port}

Perform full commission for COAM gnb on 738
    [Arguments]    ${scf}=${epc_log_path}${tl_scf_filename}
    ...            ${gnb_ip}=${tl.gnbs[0].cu.oam_ssh_connection_details.addr}
    Connect to gnb coam via ssl   bts_host=${gnb_ip}
    COAM Commission with scf file    scf_file_path=${scf}    timeout=500    is_pdl_checking_needed=${False}
    COAM Teardown gnb connections

lock gnb1 cell2 on TL369
    run keyword if    '${enb_instance}'=='${diffTL_enb_ID}[0]'    sleep    0.5s
    run keyword if    '${enb_instance}'=='${diffTL_enb_ID}[1]'    sleep    0.5s
    run keyword if    '${enb_instance}'=='${diffTL_enb_ID}[2]'    sleep    0.5s
#    ...    Lock_gnb2_Cell on TL369    url=${WEBUI_COAM}    cell_id=2    bts_host=${asik_addr}

unlock gnb1 cell2 on TL369
    run keyword if    '${enb_instance}'=='${diffTL_enb_ID}[0]'    sleep    0.5s
    run keyword if    '${enb_instance}'=='${diffTL_enb_ID}[1]'    sleep    0.5s
    run keyword if    '${enb_instance}'=='${diffTL_enb_ID}[2]'    sleep    0.5s
#    ...    unLock_gnb2_Cell on TL369    url=${WEBUI_COAM}    cell_id=2    bts_host=${asik_addr}

reboot ue for TL349
    run keyword if    '${enb_instance}'=='${diffTL_enb_ID}[0]'    Andriod UE adb reboot
    run keyword if    '${enb_instance}'=='${diffTL_enb_ID}[1]'    Andriod UE adb reboot
    run keyword if    '${enb_instance}'=='${diffTL_enb_ID}[2]'    sleep    0.5s

Prepare ue attach on 5G
    run keyword if    '${brand}'=='HUAWEI'
    ...    power_ue.Prepare UE    ue_type=huawei
    run keyword if    '${brand}'=='qti' and '${enb_instance}'!='39'
    ...    pre Qcom
    run keyword if    '${brand}'=='qti' and '${enb_instance}'=='39'
#    ...    power_ue.Prepare UE    ue_type=qct_dx50    ue_index=${2}
    ...    power_ue.Prepare UE    ue_type=qct_dx50
    run keyword if    '${enb_instance}'=='32'
    ...    Synchronize gNB and Viavi
    run keyword if    '${brand}'=='HONOR'
    ...    power_ue.Prepare UE    ue_type=huawei

pre Qcom
    power_ue.Prepare UE    ue_type=qct_dx50

UE attach on 5G
#    Get UE brand
    run keyword if    '${brand}'=='HUAWEI'
    ...    huawei attach on 5G
    run keyword if    '${brand}'=='qti' and '${enb_instance}'!='39'
    ...    Qualcomm attach on 5G
    run keyword if    '${brand}'=='qti' and '${enb_instance}'=='39'
#    ...    Qualcomm attach on 5G UE2 with TL39
    ...    Qualcomm attach on 5G
    run keyword if    '${enb_instance}'=='32'
    ...    Viavi UE attach
    run keyword if    '${brand}'=='HONOR'
    ...    huawei attach on 5G

#Get UE brand
#    [Arguments]    ${ue_index}=${0}
#    Connect to control pc via cygwin    ue_index=${ue_index}
#    sleep    2s
#    csn.send_command    command=adb shell getprop ro.product.brand
#    ...    connection=cygwin
#    ${brand}=    csn.Read Output    connection=cygwin
#    ${brand}=    Strip String    ${brand}
#    Set Suite Variable    ${brand}    ${brand}
#    csn.disconnect      connection=cygwin

huawei attach on 5G
    ${5Grach_ed}    power_ue.UE Attach    ue_type=huawei
    power_ue.Verify attach    ue_type=huawei    5Grach_ed=${5Grach_ed}    4G_check=True

Qualcomm attach on 5G
    ${5Grach_ed}    power_ue.UE Attach    ue_type=qct_dx50
    power_ue.Verify attach    ue_type=qct_dx50    5Grach_ed=${5Grach_ed}    4G_check=True

start DL and UL make traffic on 5G
    run keyword if    '${brand}'=='HUAWEI'
    ...    huawei make DL and UL traffic on 5G
    run keyword if    '${brand}'=='qti' and '${enb_instance}'!='39'
    ...    Qualcom make DL and UL traffic on 5G
    run keyword if    '${brand}'=='qti' and '${enb_instance}'=='39'
#    ...    Qualcom make DL and UL traffic on 5G with TL39
    ...    Qualcom make DL and UL traffic on 5G

stop DL and UL make traffic on 5G
    run keyword if    '${brand}'=='HUAWEI'
    ...    huawei stop DL and UL traffic on 5G
    run keyword if    '${brand}'=='qti' and '${enb_instance}'!='39'
    ...    Qualcom stop DL and UL traffic on 5G
    run keyword if    '${brand}'=='qti' and '${enb_instance}'=='39'
#    ...    Qualcom stop DL and UL traffic on 5G with TL39
    ...    Qualcom stop DL and UL traffic on 5G

huawei make DL and UL traffic on 5G
    huawei start DL traffic on 5G
    huawei start UL traffic on 5G

huawei start DL traffic on 5G
    power_ue.Start traffic    ue_type=huawei    direction=dl    throughput=10M    duration=20

huawei start UL traffic on 5G
    power_ue.Start traffic    ue_type=huawei    direction=ul    throughput=10M    duration=20

huawei stop DL and UL traffic on 5G
    huawei stop DL traffic on 5G
    huawei stop UL traffic on 5G

huawei stop DL traffic on 5G
    power_ue.Stop traffic    ue_type=huawei    direction=dl

huawei stop UL traffic on 5G
    power_ue.Stop traffic    ue_type=huawei    direction=ul

Qualcom make DL and UL traffic on 5G
    Qualcom start DL traffic on 5G
    Qualcom start UL traffic on 5G

Qualcom start DL traffic on 5G
    power_ue.Start traffic    ue_type=qct_dx50    direction=dl    throughput=10M    duration=5    iperf_port=${EPCsim_DL_port}
    ...    appserver=APPserversim

Qualcom start UL traffic on 5G
    power_ue.Start traffic    ue_type=qct_dx50    direction=ul    throughput=10M    duration=5    iperf_port=${EPCsim_UL_port}
    ...     appserver=APPserversim

Qualcom stop DL and UL traffic on 5G
    Qualcom stop DL traffic on 5G
    Qualcom stop UL traffic on 5G

Qualcom stop DL traffic on 5G
    power_ue.Stop traffic    ue_type=qct_dx50    direction=dl    iperf_port=${EPCsim_DL_port}    appserver=APPserversim

Qualcom stop UL traffic on 5G
    power_ue.Stop traffic    ue_type=qct_dx50    direction=ul    iperf_port=${EPCsim_UL_port}

check time to execute below steps
    5GC000749A_common_keywords.gNB connections
    ${time}=    csn.execute    command=date | cut -d ':' -f 2 | cut -d ':' -f 2    connection=gnb
    ${time}=    Convert To Integer    ${time}
    ${ret}=    Evaluate    ${time}%5
    Run Keyword And Ignore Error    Run Keyword If    ${ret}==0    sleep    0.5m
    Run Keyword And Ignore Error    Run Keyword If    ${ret}==1    sleep    0m
    Run Keyword And Ignore Error    Run Keyword If    ${ret}==2    sleep    3.5m
    Run Keyword And Ignore Error    Run Keyword If    ${ret}==3    sleep    2.5m
    Run Keyword And Ignore Error    Run Keyword If    ${ret}==4    sleep    1.5m

Start Capture Classical Logs
    [Arguments]    ${x2logname}    ${interface}
    RUN KEYWORD AND IGNORE ERROR    5GC000749A_common_keywords.gNB connections
    Start To Capture Wireshark Logs on gNB   filename=${x2logname}    connection=gnb    interface=${interface}
    sleep    3s

Start To Capture Wireshark Logs on gNB
    [Arguments]     ${filename}    ${connection}    ${interface}
    csn.send command    command=tcpdump -i ${interface} -w ${gnb_path}${filename}   connection=${connection}

Stop and Save classical Logs
    [Arguments]    ${x2logname}
    5GC000749A_common_keywords.gNB connections
    Stop and download wireshark Logs    logname=${x2logname}    connection=gnb

Stop and download wireshark Logs
    [Arguments]    ${logname}    ${connection}
    sleep    5
    csn.send command    command=killall tcpdump     connection=${connection}
    sleep    3
    csn.download_file   remote_path=${gnb_path}${logname}   local_path=${epc_log_path}${logname}   connection=${connection}
    sleep    3

create additional drb for UE
    run keyword if    '${enb_instance}'=='30'    create additional drb for UE on TL30
    run keyword if    '${enb_instance}'=='233' or '${enb_instance}'=='39'    create additional drb for UE on TL233
    run keyword if    '${enb_instance}'=='38'    create additional drb for UE on TL38
    run keyword if    '${enb_instance}'=='37' or '${enb_instance}'=='32'    create additional drb for UE on TL349

create additional drb for UE on TL30
    epc.Execute egate command                cmd=bearer_del ue=3 id=2
    ...                                      timeout=30
    ...                                      alias=EGATE
    sleep    5s
    epc.Execute egate command                cmd=bearer_add ue=3 id=2 filter=1 precedence=1 proto=17 local_port=5501
    ...                                      timeout=30
    ...                                      alias=EGATE
    sleep    5s

create additional drb for UE on TL233
    epc.Execute egate command                cmd=bearer_del ue=2 id=2
    ...                                      timeout=30
    ...                                      alias=EGATE
    sleep    5s
    epc.Execute egate command                cmd=bearer_add ue=2 id=2 filter=1 precedence=1 proto=17 local_port=5501
    ...                                      timeout=30
    ...                                      alias=EGATE
    sleep    5s

create additional drb for UE on TL38
    epc.Execute egate command                cmd=bearer_del ue=2 id=2
    ...                                      timeout=30
    ...                                      alias=EGATE
    sleep    30s
    epc.Execute egate command                cmd=bearer_add ue=2 id=2 filter=1 precedence=1 proto=17 local_port=5501
    ...                                      timeout=30
    ...                                      alias=EGATE
    sleep    5s

create additional drb for UE on TL349
    epc.Execute egate command                cmd=bearer_del ue=3 id=2
    ...                                      timeout=30
    ...                                      alias=EGATE
    sleep    5s
    epc.Execute egate command                cmd=bearer_add ue=3 id=2 filter=1 precedence=1 proto=17 local_port=5501
    ...                                      timeout=30
    ...                                      alias=EGATE
    sleep    5s

create second drb for UE
    run keyword if    '${enb_instance}'=='30'    create second drb for UE on TL30
    run keyword if    '${enb_instance}'=='233' or '${enb_instance}'=='39'    create second drb for UE on TL233
    run keyword if    '${enb_instance}'=='38'    create second drb for UE on TL38
    run keyword if    '${enb_instance}'=='37' or '${enb_instance}'=='32'    create second drb for UE on TL349

create second drb for UE on TL30
    epc.Execute egate command                cmd=bearer_add ue=3 id=2 filter=1 precedence=1 proto=17 local_port=5501
    ...                                      timeout=30
    ...                                      alias=EGATE
    sleep    5s

create second drb for UE on TL233
    epc.Execute egate command                cmd=bearer_add ue=2 id=2 filter=1 precedence=1 proto=17 local_port=5501
    ...                                      timeout=30
    ...                                      alias=EGATE
    sleep    5s

create second drb for UE on TL38
    epc.Execute egate command                cmd=bearer_add ue=2 id=2 filter=1 precedence=1 proto=17 local_port=5501
    ...                                      timeout=30
    ...                                      alias=EGATE
    sleep    5s

create second drb for UE on TL349
    epc.Execute egate command                cmd=bearer_add ue=3 id=2 filter=1 precedence=1 proto=17 local_port=5501
    ...                                      timeout=30
    ...                                      alias=EGATE
    sleep    5s

delete 2nd drb for UE
    run keyword if    '${enb_instance}'=='30'    delete 2nd drb for UE on TL30
    run keyword if    '${enb_instance}'=='233' or '${enb_instance}'=='39'    delete 2nd drb for UE on TL233
    run keyword if    '${enb_instance}'=='38'    delete 2nd drb for UE on TL38
    run keyword if    '${enb_instance}'=='37' or '${enb_instance}'=='32'    delete 2nd drb for UE on TL349

delete 2nd drb for UE on TL30
    epc.Execute egate command                cmd=bearer_del ue=3 id=2
    ...                                      timeout=30
    ...                                      alias=EGATE
    sleep    5s

delete 2nd drb for UE on TL233
    epc.Execute egate command                cmd=bearer_del ue=2 id=2
    ...                                      timeout=30
    ...                                      alias=EGATE
    sleep    5s

delete 2nd drb for UE on TL38
    epc.Execute egate command                cmd=bearer_del ue=2 id=2
    ...                                      timeout=30
    ...                                      alias=EGATE
    sleep    5s

delete 2nd drb for UE on TL349
    epc.Execute egate command                cmd=bearer_del ue=3 id=2
    ...                                      timeout=30
    ...                                      alias=EGATE
    sleep    5s

Get counter1
    ${res0}=    selenium_coam.get_bts_counters_info    counter_id=${counter_id}[0]     full_path=${full_path}[0]
    ${res0}=    Set Test Variable    ${res0}

Get counter2
    ${res1}=    selenium_coam.get_bts_counters_info    counter_id=${counter_id}[1]    full_path=${full_path}[1]
    ${res1}=    Set Test Variable    ${res1}

Get counter3
    ${res2}=    selenium_coam.get_bts_counters_info    counter_id=${counter_id}[2]    full_path=${full_path}[2]
    ${res2}=    Set Test Variable    ${res2}

Get couter value
    [Arguments]    ${counter_result}
    ${length}    Get Length    ${counter_result}
    ${index}    Evaluate    ${length} - 1
    ${counter_value}=    Set Variable    ${counter_result[${index}]}
    Set Test Variable    ${counter_value}    ${counter_value}
    [Return]    ${counter_value}

Disconnect connections
    Run Keyword And Ignore Error    csn.Disconnect    connection=gnb
    Run Keyword And Ignore Error    csn.Disconnect    connection=cygwin
    Run Keyword And Ignore Error    csn.Disconnect    connection=EPCAPP
    Run Keyword And Ignore Error    csn.Disconnect    connection=enb
    Run Keyword And Ignore Error    selenium_coam.enable_virtual_display
    Run Keyword And Ignore Error    selenium_coam.logout
    Run Keyword And Ignore Error    selenium_coam.disable_virtual_display

teardown for UE detach
    run keyword if    '${brand}'=='HUAWEI'
    ...    huawei detach
    run keyword if    '${brand}'=='qti' and '${enb_instance}'!='39'
    ...    sleep    1s
    ...    qct_dx50 detach
    run keyword if    '${brand}'=='qti' and '${enb_instance}'=='39'
    ...    sleep    1s
    ...    qct_dx50 detach with TL39
    run keyword if    '${enb_instance}'=='32'    Cobham UE Recovery
    run keyword if    '${brand}'=='HONOR'
    ...    huawei detach

huawei detach
    power_ue.UE Detach    ue_type=huawei

qct_dx50 detach
    power_ue.UE Detach    ue_type=qct_dx50

qct_dx50 detach with TL39
#    power_ue.UE Detach    ue_type=qct_dx50    ue_index=${2}
    power_ue.UE Detach    ue_type=qct_dx50



## Viavi UE Attach ###
Viavi UE attach
    [Timeout]  20 min
    Viavi UE attach and retry if failed

Viavi UE attach and retry if failed
    [Arguments]    ${e500_script_path}=${E500_SCRIPTS_BASE}
    ...            ${tma_path}=${TMA_APP_PATH}    ${retry_time}=2
    ...            ${cell_search_script}=NSA_cell_config_MUE1.txt
    ${time}    Set variable    ${0}
    FOR    ${i}    IN RANGE    ${retry_time}
        Postcondition_SSH    tma_alias=${TMA_TELNET_ALIAS}
        tm500.Precondition_SSH   tma_alias=${TMA_TELNET_ALIAS}    TMA_PATH=${tma_path}
        wait until keyword succeeds    2 min    10 s    tm500.Connect    tm500_alias=${TMA_APP_ALIAS}
        sleep    30s
        ${connect_status}    ${value} =    run keyword and ignore error
        ...    TMA Connect and Initialize    hw_connect_script_path=${e500_script_path}/Init_Config.txt
        run keyword if    '${connect_status}' == 'FAIL'
        ...    Retry TMA connect    hw_connect_script_path=${e500_script_path}/Init_Config.txt
        tm500.Perform cell search
        ...    cell_search_script_path=${e500_script_path}/${cell_search_script}    tm500_alias=${TMA_APP_ALIAS}
        ${attach_status}    ${value} =    run keyword and ignore error    E500 attach and verify
        ...    attach_script_path=${e500_script_path}/UE2_attach.txt    e500_alias=${TMA_APP_ALIAS}
        Exit for loop if    '${attach_status}' == 'PASS'
        wait until keyword succeeds    5 min    10 s    Reset Viavi via ASC    tma_asc_alias=${TMA_ASC_ALIAS}_${i}
        sleep    1 min
        ${time}    Evaluate    ${time}+1
        Log to console    RA failed, retry time ${time}
    END
    Should be true    ${time} < ${retry_time}    msg=Retry UE Random access with ${retry_time} times and still failed


TMA Connect and Initialize
    [Arguments]   ${hw_connect_script_path}      ${timeout}=5 minutes    ${tm500_alias}=${TMA_APP_ALIAS}
    ${response}=  tm500_remote.send script  filename=${hw_connect_script_path}  timeout=${timeout}    alias=${tm500_alias}
    Should Not Contain    ${response}    Failure
    sleep   10s

Retry TMA connect
    [Arguments]   ${hw_connect_script_path}
    Postcondition_SSH    tma_alias=${TMA_TELNET_ALIAS}
    wait until keyword succeeds    5 min    10 s    Reset Viavi via ASC    tma_asc_alias=TMA_ASC
    sleep    1 min
    tm500.Precondition_SSH    tma_alias=${TMA_TELNET_ALIAS}    TMA_PATH=${TMA_APP_PATH}
    wait until keyword succeeds    2 min    10 s    tm500.Connect    tm500_alias=${TMA_APP_ALIAS}
    sleep    30s
    tm500.Connect hw and initialize    hw_connect_script_path=${hw_connect_script_path}    tm500_alias=${TMA_APP_ALIAS}

E500 attach and verify
    [Documentation]    Author: Ding Binmei
    [Arguments]    ${attach_script_path}    ${e500_script_path}=${E500_SCRIPTS_BASE}    ${e500_alias}=${TMA_APP_ALIAS}
    Log to console    Sending attach_script from ${attach_script_path}
    ${response1}=  tm500_remote.send script  filename=${attach_script_path}  alias=${e500_alias}
    Sleep    1min
    ${response2}=  tm500_remote.read_responses    alias=${e500_alias}
    ${response}=  Catenate    ${response1}    ${response2}
    Should contain    ${response}    Random Access Complete    msg=UE attach failed, string "Random Access Complete" is not found
    Should contain    ${response}    Attach Result: EPS Only    msg=UE attach failed, string "Attach Result: EPS Only" is not found
    Should contain    ${response}    NR-RRCReconfigurationComplete    msg=UE attach failed, string "NR-RRCReconfigurationComplete" is not found
    ${e500_ue_ip}    Get ue ip address    attach_response=${response}
    Set test variable    ${UE_IP}    ${e500_ue_ip}

Reset Viavi via ASC
    [Documentation]    Description: cycle cobham via ASC
    [Arguments]    ${username}=tm500    ${group}=Units-1    ${tma_asc_alias}=${TMA_ASC_ALIAS}
    csn.Connect to    hostname=${E500_IP}    username=${E500_ASC_USER}    password=${E500_ASC_PW}    port=${E500_ASC_PORT}
    ...            alias=${tma_asc_alias}
    asc.set username    name=${username}    connection=${tma_asc_alias}
    asc.set power off    group_name=${group}    connection=${tma_asc_alias}
    sleep    10s
    asc.set power on    group_name=${group}    connection=${tma_asc_alias}
    sleep    10s
    wait until keyword succeeds    5min    5sec    Ping cobham asc ip
    sleep    10s
    csn.disconnect    connection=${tma_asc_alias}

Get ue ip address
    [Arguments]    ${attach_response}
    @{ue_ip_list}    Get regexp matches    ${attach_response}    IPv4 Address:(.*)    1
    ${ue_ip}    strip_string    ${ue_ip_list}[0]
    [Return]    ${ue_ip}

Ping cobham asc ip
    [Arguments]    ${cobham_asc_ip}=192.168.10.9        ${tma_ssh_alias}=${TMA_SSH_ALIAS}
    Connect to cobham control pc via ssh    tma_ssh_alias=${tma_ssh_alias}
    ${response}    csn.execute    command=ping ${cobham_asc_ip}    connection=${tma_ssh_alias}
    Should Contain    ${response}    Reply from ${cobham_asc_ip}: bytes=32
    csn.disconnect    connection=${tma_ssh_alias}

Synchronize gNB and Viavi
    [Arguments]    ${alias}=asik
    Connect to Common Unit Master    alias=asik
    ${cmd_export_pylib}    Evaluate    'export PYTHONPATH=/opt/hwmt/python:/opt/hwmt/lib/python2.7/site-packages'
    ${cmd_sync_clock}    Catenate    /opt/hwmt/python/sendommessage.sh -s 0x04dc -d HWASYNC-1/CLOCKOUTPUTS-1/SYNCOUT-1 --proto SYNC/sync_out
    ...                             -t execute --action setClock10MHz --args clock10MHz=1
    ${cmd_sync_frame_clock}    Catenate    /opt/hwmt/python/sendommessage.sh -s 0x04dc -d HWASYNC-1/CLOCKOUTPUTS-1/SYNCOUT-1 --proto SYNC/sync_out
    csn.send command    command=${cmd_export_pylib}    connection=${alias}
    ${output_sync_clock}    csn.execute    command=${cmd_sync_clock}    connection=${alias}
#    Should Contain    ${output_sync_clock}    MitAaSysComFinalize ok
    ${output_sync_frame_clock}    csn.execute    command=${cmd_sync_frame_clock}    connection=${alias}
#    Should Contain    ${output_sync_frame_clock}    MitAaSysComFinalize ok

Cobham UE detach
    [Arguments]  ${e500_script_path}=${E500_SCRIPTS_BASE}
    tm500.TM500 detach    tm500_alias=${TMA_APP_ALIAS}    detach_script_path=${e500_script_path}/NSA_5G_UEdetach.txt

Cobham UE Recovery
    Cobham UE detach
#    Stop logging on cobham
    tm500.Disconnect    tm500_alias=${TMA_APP_ALIAS}
    Postcondition_SSH    tma_alias=${TMA_TELNET_ALIAS}

check type of system board on gnb1
    gNB connections
    ${output}=    csn.execute    command=ifconfig |grep fp0    connection=gnb
    ${status}=    Run Keyword And Return Status    Should Be Empty    ${output}
    Run Keyword If    '${status}' == 'True'    Set variable br1 for interface name on gnb1
    Run Keyword If    '${status}' == 'False'    Set variable fp0 for interface name on gnb1
    csn.disconnect      connection=gnb

Set variable br1 for interface name on gnb1
    Set Suite Variable    ${gnb1_interface_name}    br1
    Log    The system board of gnb1 is ASIB
    Log To Console    The system board of gnb1 is ASIB

Set variable fp0 for interface name on gnb1
    Set Suite Variable    ${gnb1_interface_name}    fp0
    Log    The system board of gnb1 is ASIK
    Log To Console    The system board of gnb1 is ASIK

Check device exist with UE
#    run keyword if    '${enb_instance}'=='39'    Check UE device exist    ue_index=${2}
#    ...    ELSE    Check UE device exist
    Check UE device exist
