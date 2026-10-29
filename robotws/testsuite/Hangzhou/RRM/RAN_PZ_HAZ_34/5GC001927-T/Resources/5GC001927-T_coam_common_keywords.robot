*** Settings ***
Resource    ./5GC000738_common_keywords.robot
#Resource    ./../../../../OAM/Krakow/Resources/robot/UE_keywords.robot
#Resource    ./../../../../OAM/Krakow/Resources/robot/Common.robot
#Resource    ./../../../../OAM/Krakow/Resources/robot/OAM5G_keywords.robot
Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/Commercial_mobile_phone_adb_common_keywords.robot
Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/android_common_keyword.robot
Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/traffic_via_iperf.robot
Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/power_ue/power_ue.robot
Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/CI_Operations/CI_interface.robot
#Resource    ./../../5GC002177/Resources/5GC002177_cobham_common_keywords.robot
Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/tm500_hangzhou.robot
Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/coam_gnb_classical.robot
Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/lines/SG3/robot/Atten.robot
Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/robot_common_operations/interface.robot
Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/lines/SG3/robot/Common_setup_and_teardown.robot
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
${enbx2_dist_347}    MRBTS-${enb_instance}/LNBTS-${enb_instance}/LNADJGNB-2
${enbmme_dist}    MRBTS-${enb_instance}/LNBTS-${enb_instance}/LNMME-0
${enbmme_para}    ipAddrPrim
${enbmme_para2}    administrativeState
${actMultiSCGSplitwoeLcId_dist}    MRBTS-${enb_instance}/LNBTS-${enb_instance}
${actMultiSCGSplitwoeLcId_para}    actMultiSCGSplitwoeLcId
${actStepAddBearENDC_para}    actStepAddBearENDC
${actMultiSCGSplit_para}    actMultiSCGSplit
${epcsim_ip_cloud}    ${tl.ues[0].imsi}
${epcsim_ip}    ${tl.core.default_ssh_connection_details.addr}
${realepc_ip_cloud}    ${tl.ues[0].dmc_path}
${realepc_ip}    ${tl.core.mme_ip}
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
${asik_addr}    ${tl.gnbs[0].dus[0].airscale.common_units[0].lmp_connection.addr}
${asik_username}    ${tl.gnbs[0].dus[0].airscale.common_units[0].lmp_connection.username}
${asik_password}    ${tl.gnbs[0].dus[0].airscale.common_units[0].lmp_connection.password}
${TS_LOG_PATH_BASE_classical}    /opt/workspace/CRT/Master/Case_Logs/
${TS_CASE_LOG_PATH_classical}    /opt/workspace/CRT/Master/Case_Logs/
${tl_scf_dir_path_classical}    /opt/workspace/SCF/
${TS_LOG_PATH_BASE_cloud}    /home/ute/workspace/CRT/Master/Case_Logs/
${TS_CASE_LOG_PATH_cloud}    /home/ute/test_results/Logs/
${ute_log_path_cloud}    /home/ute/test_results/
${tl_scf_dir_path_cloud}    /home/ute/Auto5G/commissionings/HGZ/
${enb_scf_dir_path}    /opt/workspace/SCF/
${testline_name}      null
${CONFIGURATION}      null
@{diffTL_gnb_ID}    356111    34711    23311

${att_port_1_23311}              ${tl.attenuator[0].attenuator_ports[9]}
${att_port_2_23311}              ${tl.attenuator[0].attenuator_ports[10]}
${att_port_3_23311}              ${tl.attenuator[0].attenuator_ports[11]}
${att_port_4_23311}              ${tl.attenuator[0].attenuator_ports[12]}
${att_port_5_23311}              ${tl.attenuator[0].attenuator_ports[5]}
${att_port_6_23311}              ${tl.attenuator[0].attenuator_ports[6]}
${att_port_7_23311}              ${tl.attenuator[0].attenuator_ports[7]}
${att_port_8_23311}              ${tl.attenuator[0].attenuator_ports[8]}
${att_port_9_23311}              ${tl.attenuator[0].attenuator_ports[13]}
${att_port_10_23311}             ${tl.attenuator[0].attenuator_ports[14]}
${att_port_11_23311}             ${tl.attenuator[0].attenuator_ports[15]}
${att_port_12_23311}             ${tl.attenuator[0].attenuator_ports[16]}
${att_port_13_23311}             ${tl.attenuator[0].attenuator_ports[3]}
${att_port_14_23311}             ${tl.attenuator[0].attenuator_ports[4]}
${att_port_enb_1_23311}              ${tl.attenuator[0].attenuator_ports[1]}
${att_port_enb_2_23311}              ${tl.attenuator[0].attenuator_ports[2]}
${att_port_1_34711}              ${tl.attenuator[0].attenuator_ports[9]}
${att_port_2_34711}              ${tl.attenuator[0].attenuator_ports[10]}
${att_port_3_34711}              ${tl.attenuator[0].attenuator_ports[11]}
${att_port_4_34711}              ${tl.attenuator[0].attenuator_ports[12]}
${att_port_5_34711}              ${tl.attenuator[0].attenuator_ports[5]}
${att_port_6_34711}              ${tl.attenuator[0].attenuator_ports[6]}
${att_port_7_34711}              ${tl.attenuator[0].attenuator_ports[7]}
${att_port_8_34711}              ${tl.attenuator[0].attenuator_ports[8]}
${att_port_9_34711}              ${tl.attenuator[0].attenuator_ports[13]}
${att_port_10_34711}             ${tl.attenuator[0].attenuator_ports[14]}
${att_port_11_34711}             ${tl.attenuator[0].attenuator_ports[15]}
${att_port_12_34711}             ${tl.attenuator[0].attenuator_ports[16]}
${att_port_13_34711}             ${tl.attenuator[0].attenuator_ports[3]}
${att_port_14_34711}             ${tl.attenuator[0].attenuator_ports[4]}
${att_port_enb_1_34711}          ${tl.attenuator[0].attenuator_ports[1]}
${att_port_enb_2_34711}          ${tl.attenuator[0].attenuator_ports[2]}
${att_port_1_356111}    ${tl.attenuator[0].attenuator_ports[1]}
${att_port_2_356111}    ${tl.attenuator[0].attenuator_ports[2]}
${att_port_3_356111}    ${tl.attenuator[0].attenuator_ports[3]}
${att_port_4_356111}    ${tl.attenuator[0].attenuator_ports[4]}
${att_port_enb_1_356111}    ${tl.attenuator[0].attenuator_ports[5]}
${att_port_enb_2_356111}    ${tl.attenuator[0].attenuator_ports[6]}
${max_attenuation_value_34711}    ${127}
${max_attenuation_value_23311}    ${127}
${max_attenuation_value_356111}    ${127}
${att_connection_port_23311}    ${tl.attenuator[0].attenuator_ports[9]}
${att_connection_port_34711}    ${tl.attenuator[0].attenuator_ports[13]}
@{att_connection_port_356111}    ${tl.attenuator[0].attenuator_ports[1]}

${ue_type}    ${tl.ues[0].capabilities[0]}
${ue_type_2}    ${tl.ues[1].capabilities[0]}
@{gnb_ips}    ${tl.gnbs[0].cu.oam_ssh_connection_details.addr}

*** Keywords ***
set e1ap variable
    set e1ap variable on TL38

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

#get QPM path
#    run keyword if    '${enb_instance}'=='35921'    get QPM path on TL38
#    run keyword if    '${enb_instance}'=='35621'    get QPM path on TL349
#    run keyword if    '${enb_instance}'=='36921'    get QPM path on TL349

get QPM path on TL233
    Set Suite Variable    ${LKC_CLIENT_PATH}    /cygdrive/c/Users/tester/Desktop/QPM_LK1.3

get QPM path on TL38
    Set Suite Variable    ${LKC_CLIENT_PATH}    /cygdrive/c/Users/nokia5G/Desktop/QPM_LK1.3.1

get QPM path on TL349
    Set Suite Variable    ${LKC_CLIENT_PATH}    /cygdrive/c/Users/nokia5G/Desktop/QPM_LK1.3.1

Preparation UE on setup
    power_ue.Prepare UE    ue_type=huawei

Enb use Multi-DRB
    Connect and Modify the parameter on enblte
    ...    dist_name=${actMultiSCGSplitwoeLcId_dist}    parameter=${actMultiSCGSplit_para}    value=true
    Connect and Modify the parameter on enblte
    ...    dist_name=${actMultiSCGSplitwoeLcId_dist}    parameter=${actStepAddBearENDC_para}    value=true
    Connect and Modify the parameter on enblte
    ...    dist_name=${actMultiSCGSplitwoeLcId_dist}    parameter=${actMultiSCGSplitwoeLcId_para}    value=true


Enb use Single-DRB
    Connect and Modify the parameter on enblte
    ...    dist_name=${actMultiSCGSplitwoeLcId_dist}    parameter=${actMultiSCGSplitwoeLcId_para}    value=false
    Connect and Modify the parameter on enblte
    ...    dist_name=${actMultiSCGSplitwoeLcId_dist}    parameter=${actStepAddBearENDC_para}    value=false
    Connect and Modify the parameter on enblte
    ...    dist_name=${actMultiSCGSplitwoeLcId_dist}    parameter=${actMultiSCGSplit_para}    value=false


Enb use EPCsim
    Run keyword if    '${gnb_instance}'=='${diffTL_gnb_ID}[0]'
    ...    Connect and Modify the parameter on enblte    dist_name=${enbmme_dist}    parameter=${enbmme_para}    value=${epcsim_ip_cloud}
    ...    ELSE    Connect and Modify the parameter on enblte    dist_name=${enbmme_dist}    parameter=${enbmme_para}    value=${epcsim_ip}
    Connect and Modify the parameter on enblte    dist_name=${enbmme_dist}    parameter=${enbmme_para2}    value=locked

Enb use RealEPC
    Run keyword if    '${gnb_instance}'=='${diffTL_gnb_ID}[0]'
    ...    Connect and Modify the parameter on enblte    dist_name=${enbmme_dist}    parameter=${enbmme_para}    value=${realepc_ip_cloud}
    ...    ELSE    Connect and Modify the parameter on enblte    dist_name=${enbmme_dist}    parameter=${enbmme_para}    value=${realepc_ip}

Prepare the classical COAM BTS cell onair on 1927
    ${cell_status}    ${cell_value} =    Run keyword if    '${gnb_instance}'=='${diffTL_gnb_ID}[0]'
    ...    Run Keyword And Ignore Error    Prepare with COMA classical BTS cell onair on 1927    gnb_index=${0}
    ...    ELSE    Run Keyword And Ignore Error    Prepare with COMA classical BTS cell onair on 1927    gnb_index=${1}
    set global variable    ${cell_status}

Prepare with COMA classical BTS cell onair on 1927
    [Arguments]    ${gnb_index}=${0}
    Perform full commission for COAM gnb on 738    scf=${SCF_path}${SCF_file_name}    gnb_index=${gnb_index}
    run keyword if    '${gnb_instance}'=='${diffTL_gnb_ID}[0]'
    ...    Connect and Modify the parameter on enblte    dist_name=${enbx2_dist_349}    parameter=${enbx2_para}    value=locked
    ...    ELSE
    ...    Connect and Modify the parameter on enblte    dist_name=${enbx2_dist_347}    parameter=${enbx2_para}    value=locked
    Check gnb COAM classical start normally    gnb_index=${gnb_index}
    run keyword if    '${gnb_instance}'=='${diffTL_gnb_ID}[0]'
    ...    Connect and Modify the parameter on enblte    dist_name=${enbx2_dist_349}    parameter=${enbx2_para}    value=unlocked
    ...    ELSE
    ...    Connect and Modify the parameter on enblte    dist_name=${enbx2_dist_347}    parameter=${enbx2_para}    value=unlocked
    Check the gnb cell status onair    gnb_index=${gnb_index}

Prepare the enb cell onair on 1927
    [Arguments]    ${scf_file}=${SCF_file_name_Enb}    ${enb_index}=${0}
    5GC001927-T_coam_common_keywords.Upload SCF to eNB    scf_file=${scf_file}    enb_index=${enb_index}
    Wait the enb cell status onair

Upload SCF to eNB
    [Arguments]    ${scf_file}=${SCF_file_name_Enb}    ${tl_scf_dir_path}=${enb_scf_dir_path}     ${enb_index}=${0}
    ...   ${BTS_PORT}= 443     ${USE_SSL}= True    ${connection}=enblte
    enblte.connect_to    bts_host=${tl.enbs[${enb_index}].airscale.common_units[0].lmp_connection.addr}
    ...    bts_port=${BTS_PORT}  use_ssl=${USE_SSL}    name=${connection}
    enblte.perform_commissioning    scf_file=${tl_scf_dir_path}${scf_file}    skip_parameter_relation_errors=${True}
    ...     should_activate=${True}    connection=${connection}    timeout=300
    enblte.teardown    connection=${connection}

Check gnb COAM classical start normally on TL349
#    Check Airscale HW module status
    ${res} =    Feature 1514 Enabled
#    run keyword if    ${res}==${False}    wait until keyword succeeds    10min   30s
#    ...    5GC000738_common_keywords.Check the sctp port UP    port_num=${f1_sctp_port}
    sleep    300s
#    wait until keyword succeeds    10min    20s    Check the gnb RU status ready on TL349
#    wait until keyword succeeds    5min   30s    5GC000738_common_keywords.Check the sctp port UP    port_num=${x2_sctp_port}

Perform full commission for COAM gnb on 738
    [Arguments]    ${scf}=${epc_log_path}${tl_scf_filename}
    ...            ${gnb_index}=${0}
    Connect to gnb coam via ssl    gnb_index=${gnb_index}
    COAM Commission with scf file    scf_file_path=${scf}    timeout=500    is_pdl_checking_needed=${False}
    COAM Teardown gnb connections

lock gnb AMF1 on TL354 or TL355
    run keyword if    '${gnb_instance}'!='${diffTL_gnb_ID}[0]'
    ...    Modify NIDD parameter on gnb    parameters_to_update=${parameter_886_D13_lock_AMF}    gnb_index=${1}

unlock gnb AMF1 on TL354 or TL355
    run keyword if    '${gnb_instance}'!='${diffTL_gnb_ID}[0]'
    ...    Modify NIDD parameter on gnb    parameters_to_update=${parameter_886_D13_unlock_AMF}    gnb_index=${1}

reboot ue for TL349
    run keyword if    '${gnb_instance}'=='${diffTL_gnb_ID}[0]'    Andriod UE adb reboot
    run keyword if    '${gnb_instance}'=='${diffTL_gnb_ID}[1]'    Andriod UE adb reboot
    run keyword if    '${gnb_instance}'=='${diffTL_gnb_ID}[2]'    sleep    0.5s

Prepare ue attach on 5G
    run keyword if    '${gnb_instance}'=='${diffTL_gnb_ID}[0]'
    ...    power_ue.Prepare UE    ue_type=huawei
    ...    ELSE
    ...    power_ue.Prepare UE    ue_type=${ue_type}    ue_index=${0}    ui_version=S20UI2.5    power_reset=True

pre Qcom
    power_ue.Prepare UE    ue_type=qct_dx50

UE attach on 5G
    run keyword if    '${gnb_instance}'=='${diffTL_gnb_ID}[0]'
    ...    Attach and check power UE    ue_type=huawei
    ...    ELSE
    ...    Attach and check power UE    ue_type=${ue_type_2}    ue_index=${0}    gnb_index=${1}

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

Attach and check power UE
    [Arguments]    ${ue_type}=${ue_type}    ${ue_index}=${0}    ${4G_check}=True    ${gnb_index}=${0}
     ${5Grach_ed}    power_ue.UE Attach    ue_type=${ue_type}    ue_index=${ue_index}    gnb_index=${gnb_index}
    power_ue.Verify attach    ue_type=${ue_type}    5Grach_ed=${5Grach_ed}    ue_index=${ue_index}    4G_check=${4G_check}
    ...    gnb_index=${gnb_index}
    
start DL and UL make traffic on 5G
    run keyword if    '${brand}'=='HUAWEI'
    ...    huawei make DL and UL traffic on 5G
    run keyword if    '${brand}'=='qti'
    ...    Qualcom make DL and UL traffic on 5G

stop DL and UL make traffic on 5G
    run keyword if    '${brand}'=='HUAWEI'
    ...    huawei stop DL and UL traffic on 5G
    run keyword if    '${brand}'=='qti'
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
    5GC000738_common_keywords.gNB connections
    ${time}=    csn.execute    command=date | cut -d ':' -f 2 | cut -d ':' -f 2    connection=gNB0
    ${time}=    Convert To Integer    ${time}
    ${ret}=    Evaluate    ${time}%5
    Run Keyword And Ignore Error    Run Keyword If    ${ret}==0    sleep    0.5m
    Run Keyword And Ignore Error    Run Keyword If    ${ret}==1    sleep    0m
    Run Keyword And Ignore Error    Run Keyword If    ${ret}==2    sleep    3.5m
    Run Keyword And Ignore Error    Run Keyword If    ${ret}==3    sleep    2.5m
    Run Keyword And Ignore Error    Run Keyword If    ${ret}==4    sleep    1.5m

Start Capture Classical Logs
    [Arguments]    ${x2logname}    ${gnb_index}=${0}    ${interface}=any
    RUN KEYWORD AND IGNORE ERROR    5GC000738_common_keywords.gNB connections    gnb_index=${gnb_index}
    Start To Capture Wireshark Logs on gNB   filename=${x2logname}    gnb_index=${gnb_index}    interface=${interface}
    sleep    3s
    [Teardown]    csn.disconnect    connection=gNB${gnb_index}

Start To Capture Wireshark Logs on gNB
    [Arguments]     ${filename}    ${gnb_index}=${0}    ${interface}=any
    csn.send command    command=tcpdump -i ${interface} sctp -w ${gnb_path}${filename}   connection=gNB${gnb_index}

Stop and Save classical Logs
    [Arguments]    ${x2logname}    ${gnb_index}=${0}
    5GC000738_common_keywords.gNB connections    gnb_index=${gnb_index}
    Stop and download wireshark Logs    logname=${x2logname}    gnb_index=${gnb_index}

Stop and download wireshark Logs
    [Arguments]    ${logname}    ${gnb_index}=${0}
    sleep    5
    csn.send command    command=killall tcpdump     connection=gNB${gnb_index}
    sleep    3
    csn.download_file   remote_path=${gnb_path}${logname}   local_path=${epc_log_path}${logname}   connection=gNB${gnb_index}
    sleep    3

create additional drb for UE
    run keyword if    '${gnb_instance}'=='${diffTL_gnb_ID}[0]'    create additional drb for UE on TL30
    run keyword if    '${gnb_instance}'=='${diffTL_gnb_ID}[2]'    create additional drb for UE on TL233
    run keyword if    '${gnb_instance}'=='${diffTL_gnb_ID}[1]'    create additional drb for UE on TL38

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
    run keyword if    '${gnb_instance}'=='${diffTL_gnb_ID}[2]'    create second drb for UE on TL233
    run keyword if    '${gnb_instance}'=='${diffTL_gnb_ID}[1]'    create second drb for UE on TL38
    run keyword if    '${gnb_instance}'=='${diffTL_gnb_ID}[0]'    create second drb for UE on TL349

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
    run keyword if    '${gnb_instance}'=='${diffTL_gnb_ID}[0]'    delete 2nd drb for UE on TL30
    run keyword if    '${gnb_instance}'=='${diffTL_gnb_ID}[2]'    delete 2nd drb for UE on TL233
    run keyword if    '${gnb_instance}'=='${diffTL_gnb_ID}[1]'    delete 2nd drb for UE on TL38

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
    run keyword if    '${gnb_instance}'=='${diffTL_gnb_ID}[0]'
    ...    power_ue.UE Detach    ue_type=huawei   ue_index=${0}
    ...    ELSE    power_ue.UE Detach    ue_type=${ue_type}    ue_index=${1}

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
        tm500_hangzhou.Precondition_SSH   tma_alias=${TMA_TELNET_ALIAS}    TMA_PATH=${tma_path}
        wait until keyword succeeds    2 min    10 s    tm500_hangzhou.Connect    tm500_alias=${TMA_APP_ALIAS}
        sleep    30s
        ${connect_status}    ${value} =    run keyword and ignore error
        ...    TMA Connect and Initialize    hw_connect_script_path=${e500_script_path}/Init_Config.txt
        run keyword if    '${connect_status}' == 'FAIL'
        ...    Retry TMA connect    hw_connect_script_path=${e500_script_path}/Init_Config.txt
        tm500_hangzhou.Perform cell search
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
    tm500_hangzhou.Precondition_SSH    tma_alias=${TMA_TELNET_ALIAS}    TMA_PATH=${TMA_APP_PATH}
    wait until keyword succeeds    2 min    10 s    tm500_hangzhou.Connect    tm500_alias=${TMA_APP_ALIAS}
    sleep    30s
    tm500_hangzhou.Connect hw and initialize    hw_connect_script_path=${hw_connect_script_path}    tm500_alias=${TMA_APP_ALIAS}

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
    tm500_hangzhou.TM500 detach    tm500_alias=${TMA_APP_ALIAS}    detach_script_path=${e500_script_path}/NSA_5G_UEdetach.txt

Cobham UE Recovery
    Cobham UE detach
#    Stop logging on cobham
    tm500_hangzhou.Disconnect    tm500_alias=${TMA_APP_ALIAS}
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
    run keyword if    '${gnb_instance}'=='${diffTL_gnb_ID}[0]'    Check UE device exist
    ...    ELSE    Check UE device exist    ue_index=${1}


Get gnb release info
    ${release_info}    Get sagnb release
    set suite variable    ${release}    ${release_info}

Get sagnb release
    [Arguments]   ${host}=${asik_addr}   ${username}=${asik_username}   ${password}=${asik_password}
    csn.Connect To   hostname=${host}   username=${username}   password=${password}   alias=release_info
    ${info}   csn.Execute    command=ls /ffs/run/TargetBD*xml   connection=release_info
    ${release_info}     set variable    ${info.split('_')[1]}_${info.split('_')[2]}_${info.split('_')[3]}
    [Return]    ${release_info}
    [Teardown]   csn.Disconnect   connection=release_info

Pre Condition
    [Documentation]    Author: Ren Biyao
    ...    This keyword will set the default path for scf which will be used for ute cloud or lightweight CI.
    [Timeout]    20 min
    [Arguments]
    ${SCF_PATH}     Get Substring    ${CURDIR}  0  24
    ${TL_NAME}   set variable if      '${testline_name}' == 'null'    ${CONFIGURATION}    ${testline_name}
    ${pattern}   Set Variable    7_5(.*)
    ${TLNAME}    Get Regexp Matches     ${TL_NAME}    ${pattern}    1
    ${testlinename}   Set Variable    7_5${TLNAME}[0]
    ${CONFIGURATION}    Get Variable Value    ${CONFIGURATION}
    set suite variable     ${CONFIGURATION}
    set suite variable     ${SCF_PATH}
    set suite variable     ${testlinename}
    Connect to Common Unit Master    alias=ASIK Master
    run keyword if    '${CONFIGURATION}' != '${None}' and '${CONFIGURATION}' != 'null'
    ...    Default directory for ute cloud
    ...    ELSE    Default directory for lightweight ci

Default directory for ute cloud
    [Documentation]    Author: Ren Biyao
    ...     Description: default dir scf and swconfig and log dir for ute cloud.
    ${cur_dir}    run    pwd
    set suite variable     ${TS_LOG_PATH_BASE}       ${cur_dir}/../test_results
    set suite variable     ${SWCONFIG_DEFAULT_FILE_PATH}    ${SCF_PATH}/commissionings/HGZ/${testlinename}/swconfig.txt
    set suite variable     ${luashark_path}        /opt/luashark/luashark.lua
    Set Suite Variable    ${TS_CASE_LOG_PATH}    ${TS_CASE_LOG_PATH_cloud}
    Set Suite Variable    ${SCF_path}     ${SCF_PATH}/commissionings/HGZ/${testlinename}/
    Set Suite Variable    ${SCF_file_name}    ${SCF_file_name_cloud}
    Set Suite Variable    ${ute_log_path}    ${ute_log_path_cloud}
    5GC001927-T_coam_common_keywords.Common Suite Setup for COAM

Default directory for lightweight ci
    Set Suite Variable    ${TS_LOG_PATH_BASE}    ${TS_LOG_PATH_BASE_classical}
    Set Suite Variable    ${TS_CASE_LOG_PATH}    ${TS_CASE_LOG_PATH_classical}
    Set Suite Variable    ${SCF_path}     ${tl_scf_dir_path_classical}
    Set Suite Variable    ${SCF_file_name}    ${SCF_file_name_classical_${gnb_instance}}
    Set Suite Variable    ${SCF_file_name_Enb}    ${SCF_file_name_classical_${gnb_instance}_Enb}
    Set Suite Variable    ${SCF_file_name_Enb_restore}    ${SCF_file_name_classical_${gnb_instance}_Enb_restore}
    Set Suite Variable    ${ute_log_path}    ${TS_CASE_LOG_PATH_classical}
    5GC001927-T_coam_common_keywords.Common Suite Setup for COAM

Common Suite Setup for COAM
    COAM Create log directory    is_set_to_test_case_level=${False}
    ${time_stamp}    Get current date    result_format=%Y%m%d%H%M%S
    Set Suite Variable    ${epc_log_path}    ${LOG_PATH}/${time_stamp}/
    Create directory    ${epc_log_path}

Modify NIDD parameter on gnb
    [Arguments]    ${parameters_to_update}    ${gnb_index}=${0}
    Connect to gnb coam via ssl   connection=gNB${gnb_index}    bts_host=${tl.gnbs[${gnb_index}].cu.oam_ssh_connection_details.addr}
    COAM Update several parameters via rest api    parameters_to_update_via_api=${parameters_to_update}    connection=gNB${gnb_index}
    [Teardown]  Run keyword and ignore error    COAM Teardown gnb connections    connection=gNB${gnb_index}

Adjust the tl HBTE attenuation value
     [Arguments]     ${tl}=${tl}    ${gnb_cell1_value}=${0}    ${enb_cell1_value}=${0}
    ####create cell list#####
    @{att_ports_gnb_cell1}    Create List    ${att_port_1_${tl}}    ${att_port_2_${tl}}
    ...    ${att_port_3_${tl}}    ${att_port_4_${tl}}
    @{att_ports_enb_cell1}    Create List    ${att_port_enb_1_${tl}}    ${att_port_enb_2_${tl}}

    ###create value list####
    @{values_gnb_cell1}    Create List    ${gnb_cell1_value}    ${gnb_cell1_value}    ${gnb_cell1_value}    ${gnb_cell1_value}
    @{values_enb_cell1}    Create List    ${enb_cell1_value}    ${enb_cell1_value}

    ###Adjust the HBTE attenuation value###
    Set the attenuation value    att_ports=${att_ports_gnb_cell1}    values=${values_gnb_cell1}
    ...    att_connection_port=${att_connection_port_${tl}}    att_ipaddr=${att_ipaddr}
    ...    max_attenuation_value=${max_attenuation_value_${tl}}
    Set the attenuation value    att_ports=${att_ports_enb_cell1}    values=${values_enb_cell1}
    ...    att_connection_port=${att_connection_port_${tl}}    att_ipaddr=${att_ipaddr}
    ...    max_attenuation_value=${max_attenuation_value_${tl}}

Adjust the tl enb HBTE attenuation value
    [Arguments]     ${tl}=${tl}    ${enb_cell1_value}=${0}
    ####create cell list#####
    @{att_ports_enb_cell1}    Create List    ${att_port_5_${tl}}    ${att_port_6_${tl}}

    ###create value list####
    @{values_enb_cell1}    Create List    ${enb_cell1_value}    ${enb_cell1_value}

    ###Adjust the HBTE attenuation value###
    Set the attenuation value    att_ports=${att_ports_enb_cell1}    values=${values_enb_cell1}
    ...    att_connection_port=${att_connection_port_${tl}}    att_ipaddr=${att_ipaddr}
    ...    max_attenuation_value=${max_attenuation_value_${tl}}

Adjust the tl other port HBTE attenuation value
     [Arguments]     ${tl}=${gnb_instance}    ${gnb_other_value}=${127}
    ####create cell list#####
    @{att_ports_gnb_cell1}    Create List    ${att_port_5_${tl}}    ${att_port_6_${tl}}
    ...    ${att_port_7_${tl}}    ${att_port_8_${tl}}    ${att_port_9_${tl}}    ${att_port_10_${tl}}
    ...    ${att_port_11_${tl}}    ${att_port_12_${tl}}    ${att_port_13_${tl}}    ${att_port_14_${tl}}

    ###create value list####
    @{values_gnb_cell1}    Create List    ${gnb_other_value}    ${gnb_other_value}
    ...    ${gnb_other_value}    ${gnb_other_value}    ${gnb_other_value}    ${gnb_other_value}
    ...    ${gnb_other_value}    ${gnb_other_value}    ${gnb_other_value}    ${gnb_other_value}

    ###Adjust the HBTE attenuation value###
    Set the attenuation value    att_ports=${att_ports_gnb_cell1}    values=${values_gnb_cell1}
    ...    att_connection_port=${att_connection_port_${tl}}    att_ipaddr=${att_ipaddr}
    ...    max_attenuation_value=${max_attenuation_value_${tl}}
