*** Settings ***
Documentation     author: Yuan Hongyan
...               contact: hongyan.1.yuan@nokia-sbell.com
...               Common KWs for 5GC000900 feature.

Library           taf.transport.ssh		WITH NAME	csn
Library           taf.collectors.core   WITH NAME   core
Library           taf.collectors.btslog  WITH NAME   btslog
Library           ../../5GC000638/Resources/coam_close.py
Library           taf.hw.rf_attenuator    WITH NAME    PA
Resource          ../../5GC000496_C/Resources/L3Call.robot
#Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/Throughput_checking_from_GNB.robot
Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/aasyslog.robot
Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/power_ue/power_ue.robot
Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/traffic_via_iperf.robot



*** Variables ***
#${UE_TYPE}                  huawei_sigspark
${UE_TYPE}                   ${tl.ues[0].capabilities[-1]}

## Attenuator parameter ##
${PA_INFO}            ${tl.attenuator}

####GNB1####
${5GRU1_ANT1}    ${1}
${5GRU1_ANT2}    ${2}
${5GRU2_ANT1}    ${3}
${5GRU2_ANT2}    ${4}
${5GRU3_ANT1}    ${5}
${5GRU3_ANT2}    ${6}

####GNB2####
${5GGNB2_RU1_ANT1}    ${7}
${5GGNB2_RU1_ANT2}    ${8}

*** Keywords ***
Refine PA Port
#    ${PORTS}    Get Dictionary Keys    ${tl.attenuator.attenuator_ports}
#    ${PORTS}    Get Dictionary Keys    ${tl.attenuator.attenuation_port_numbers}
    Set Suite Variable     ${5GRU1_ANT1}    ${PA_PORT[0]}
    Set Suite Variable     ${5GRU1_ANT2}    ${PA_PORT[1]}
    Set Suite Variable     ${5GRU2_ANT1}    ${PA_PORT[2]}
    Set Suite Variable     ${5GRU2_ANT2}    ${PA_PORT[3]}
    Run Keyword And Ignore Error    Set Suite Variable     ${5GRU3_ANT1}    ${PA_PORT[4]}
    Run Keyword And Ignore Error    Set Suite Variable     ${5GRU3_ANT2}    ${PA_PORT[5]}
    Set Suite Variable     ${5GGNB2_RU1_ANT1}    ${PA_PORT[6]}
    Set Suite Variable     ${5GGNB2_RU1_ANT2}    ${PA_PORT[7]}
    log to console  ${PA_PORT[0]}
    log to console  ${PA_PORT[7]}

## PA side operation ##
Adjust ${RU} Attenuation to ${value}
    Adjust the Attenuation Value    ports=${5G${RU}_ANT1}    value=${value}
    Adjust the Attenuation Value    ports=${5G${RU}_ANT2}    value=${value}

Adjust the Attenuation Value
    [Arguments]    ${ports}    ${value}
    PA.setup_attenuator    attenuator=${PA_INFO}
    PA.set_attenuation     port=${ports}    value=${value}
    PA.read_attenuation    port=${ports}

#  ### gNB side operation ###
Get rid of loner ssh fingerprint change issue
    gNB.Connect
    ssh.execute    command=ssh-keygen -R 192.168.253.22 -f /user/toor4nsn/.ssh/known_hosts   connection=${ALIAS_ASIK}
    ${wa_presence}    ssh.execute    command=cat /etc/ssh/ssh_config| grep "Host 192.168.253.22"    connection=${ALIAS_ASIK}
    run keyword if  not '${wa_presence.replace('\r','\\r').replace('\n','\\n')}'=='${EMPTY}'    run keywords
    ...    ssh.execute    command=sed -i "1i\\Host 192.168.253.22" /etc/ssh/ssh_config    connection=${ALIAS_ASIK}
    ...    AND    ssh.execute    command=sed -i "2i\\${SPACE*3}StrictHostKeyChecking no" /etc/ssh/ssh_config    connection=${ALIAS_ASIK}
    ...    AND    ssh.execute    command=sed -i "3i\\${SPACE*3}UserKnownHostsFile=/dev/null" /etc/ssh/ssh_config    connection=${ALIAS_ASIK}
    gNB.Disconnect

Process.Verify gNB Readiness and Fail Case if Not After Reset
    ${gNB_on_air}    run keyword and return status    wait until keyword succeeds   6x   3min     COAM_VerifyOnAirViaFrontendAndBackend
    run keyword if  not ${gNB_on_air}   Powercycle gNB until Ready

Powercycle gNB until Ready
    Power.ResetgNB    model=HBTE
    Power.Reset5GRU    model=HBTE
    ${gNB_on_air}    run keyword and return status    wait until keyword succeeds   6x   3min   COAM_VerifyOnAirViaFrontendAndBackend
    run keyword if  not ${gNB_on_air}    fail    msg=gnb is not on air!

#  ### MTK side Operation ###
Powercycle MTK
    facom.PowerOnOff    pdu_ip=${PB_MTK_IP}    Port_Number=${PB_MTK_PORT}    Action=power_off
    sleep    5s
    facom.PowerOnOff    pdu_ip=${PB_MTK_IP}    Port_Number=${PB_MTK_PORT}    Action=power_on
    sleep    60s

Connect MTK CtrlPC
    ssh.connect to    hostname=${MTK_CtrlPC_IP}   username=${MTK_CtrlPC_USERNAME}  password=${MTK_CtrlPC_PASSWORD}  alias=MTK_CPC

Disconnect MTK CtrlPC
    ssh.disconnect    connection=MTK_CPC

Clear UE info from AMF with Retry
   [Arguments]  ${ue_imsi}=${IMSI}   ${retry_times}=2
    FOR    ${i}    IN RANGE    ${retry_times}
        Clear UE info from AMF
    END
    Log    UeAttach retry for ${i + 1} times.

Clear UE info from AMF
   [Arguments]  ${ue_imsi}=${IMSI}   ${retry_times}=2
   Connect to 5GC
   ${imsi_presence}=    csn.execute   command=cmm subscriber show --imsi ${ue_imsi} 2> /dev/null| head -n 7 | grep GENERALINFO
   ...    connection=${ALIAS_5GC}
   run keyword if  not '${imsi_presence.replace('\r','\\r').replace('\n','\\n')}'=='${EMPTY}'
   ...    csn.execute   command=cmm subscriber delete --imsi ${ue_imsi}    connection=${ALIAS_5GC}
   run keyword if  not '${imsi_presence.replace('\r','\\r').replace('\n','\\n')}'=='${EMPTY}'
   ...    sleep   2min    # WA, make IMSI clear opeation is done completely.
   Disconnect from 5GC

Verify if UE registered to AMF
   [Arguments]  ${ue_imsi}=${IMSI}
   Connect to 5GC
   ${output}=    csn.execute   command=cmm subscriber show --imsi ${ue_imsi}| grep amfRmState   connection=${ALIAS_5GC}
   should contain   ${output}   REGISTERED
   ${output}=    csn.execute   command=cmm subscriber show --imsi ${ue_imsi}| grep amfCmState  connection=${ALIAS_5GC}
   should contain   ${output}   CONNECTED
   Disconnect from 5GC

Check UE status from AMF
   [Arguments]  ${ue_imsi}=${IMSI}
   Connect to 5GC
   ${UE_Status}=    csn.execute   command=cmm subscriber show --imsi ${ue_imsi}  connection=${ALIAS_5GC}
   ${RM_Status}=    csn.execute   command=cmm subscriber show --imsi ${ue_imsi}| grep amfRmState   connection=${ALIAS_5GC}
   ${CM_Status}=    csn.execute   command=cmm subscriber show --imsi ${ue_imsi}| grep amfCmState  connection=${ALIAS_5GC}
   ${PDN_Status}=    csn.execute   command=cmm subscriber show --imsi ${ue_imsi}| grep pnd  connection=${ALIAS_5GC}
   Log   ${UE_Status}
   Log to console   ${RM_Status}
   Log to console   ${CM_Status}
   Log to console   ${PDN_Status}

   Disconnect from 5GC

Connect to 5GC
    csn.connect to    hostname=${5GC_IP}   username=${5GC_USERNAME}    password=${5GC_PASSWORD}    alias=${ALIAS_5GC}

Disconnect from 5GC
    csn.disconnect    connection=${ALIAS_5GC}



#  ### Main L3 Call Procedures ###
GNB.SwconfigReplace
    [Arguments]    ${file_path}=${CFGFILE_PATH}
    Conn.ConnectWithTimeout  alias=${ALIAS_ASIK}
    Conn.UploadFile    local_path=${file_path}/swconfig.txt    remote_path=/ffs/run/swconfig.txt    alias=${ALIAS_ASIK}
    Conn.Execute    cmd=cd /ffs/run/ && crasign swconfig.txt    alias=${ALIAS_ASIK}
    Conn.Disconnect  alias=${ALIAS_ASIK}

GNB.Commissioning
    [Arguments]    ${scf_file}    ${file_path}=${CFGFILE_PATH}   ${timeout}=${900}
    COAM_Admin.commission    scf_file=${file_path}/${scf_file}    timeout=${timeout}
    Process.Verify gNB Readiness and Fail Case if Not After Reset

X2 Should Be Ready
    [Arguments]    ${alias}=${ALIAS_ASIK_SLAVE}
#    gNB.Connect
#    gNB.CheckHWStatusUntilReady
#    gNB.CheckF1StatusUntilReady
#    gNB.CheckX2StatusUntilReady    dep_1514=Yes    alias=${alias}
    Run Keyword And Continue On Failure    WEBUI.CheckX2StatusUntilReady    X2_distname=LTEENB-0
#    gNB.Disconnect


WEBUI.CheckX2StatusUntilReady
    [Arguments]    ${X2_distname}
     Run Keyword And Continue On Failure    COAM_WebEM.Login
     Run Keyword And Continue On Failure    Wait until keyword succeeds    10x    1min    WEBUI.CheckX2Status
     ...    dist_name=${MRBTS_ID}/${NRBTS_ID}/${X2_distname}
     Run Keyword And Continue On Failure    COAM_WebEM.Logout


WEBUI.CheckX2Status
    [Arguments]    ${dist_name}
     ${X2_result}    selenium_coam.get_parameter_value    dist_name=${distname}    filter_param=X2C link status    abbr=x2LinkStatus
     Run Keyword And Continue On Failure    Should be equal    ${X2_result}    available
####  eNB side operation ####

ENB.Commissioning
    [Arguments]    ${scf_file}    ${file_path}=${CFGFILE_PATH}
    ENB_Admin.Commission    scf_file=${file_path}/${scf_file}
#    sleep    3min

ENB_Admin.Commission
    [Arguments]    ${scf_file}    ${timeout}=${600}    ${connnection}=ENB
    wait until keyword succeeds    3x    1min    ENB_Admin.Login    bts_host=${ENB_WEBUI_IP}
    coam.perform_commissioning    scf_file=${scf_file}    skip_parameter_relation_errors=True    should_activate=${true}    timeout=${timeout}
    ...    connection=${connnection}
    ENB_Admin.Logout

ENB_Admin.Login
    [Arguments]    ${bts_host}=${ENB_WEBUI_IP}    ${username}=${WEBUI_USERNAME}    ${password}=${WEBUI_PASSWORD}    ${bts_port}=${443}
    ...    ${log_dir}=${OUTPUT_DIR}    ${alias}=ENB
    coam.connect_to    bts_host=${bts_host}    bts_port=${bts_port}    username=${username}    password=${password}    use_ssl=${True}
    ...    update_interval=${5000}    admin_api_log_dir=${log_dir}    name=${alias}

ENB_Admin.Logout
    [Arguments]    ${connection}=ENB
    coam.teardown    connection=${connection}

## SigSpark Specific##
PowerUE.Reserve UE
    [Documentation]   applicalbe for Huawei SigSpark using the common-lib of PowerUE
    [Arguments]    ${ue_type}=${UE_TYPE}    ${ue_index}=${0}    ${ue_alias}=UE_${ue_index}    ${capatibility_index}=${0}
    ...            ${reset_sol}=none    ${detach_request}=${true}
    [Timeout]      10min
    power_ue.Prepare UE   ue_type=${UE_TYPE}   ue_index=${ue_index}    ue_alias=${ue_alias}    capatibility_index=${capatibility_index}
    ...            reset_sol=${reset_sol}   detach_request=${detach_request}

PowerUE.Attach UE
    [Documentation]   applicalbe for Huawei SigSpark using the common-lib of PowerUE.
    ...    4G_check to be specified in case.
    [Arguments]    ${ue_type}=${UE_TYPE}    ${ue_index}=${0}    ${gnb_index}=${0}    ${hwcheck_index}=${1}    ${power_reset}=False
    ...    ${ue_alias}=UE_${ue_index}   ${abil_index}=${1}    ${4G_check}=False    ${5Grach_ed}=${0}    ${5Gstatus}=PASS
    power_ue.UE Detach    ue_type=${ue_type}    ue_index=${ue_index}    power_reset=${power_reset}
    sleep    10s
    power_ue.UE Attach    ue_type=${ue_type}   ue_index=${ue_index}  gnb_index=${gnb_index}  hwcheck_index=${hwcheck_index}
    ...    ue_alias=${ue_alias}    abil_index=${abil_index}    power_reset=${power_reset}
    run keyword if     '${4G_check}'=='True'    power_ue.Verify attach    ue_type=${ue_type}   ue_index=${ue_index}    gnb_index=${gnb_index}
    ...    abil_index=${abil_index}   4G_check=${4G_check}   5Grach_ed=${5Grach_ed}    5Gstatus=${5Gstatus}

PowerUE.Detach UE
    [Documentation]   applicalbe for Huawei SigSpark using the common-lib of PowerUE
    [Arguments]    ${ue_type}=${UE_TYPE}    ${ue_index}=${0}    ${ue_alias}=UE_${ue_index}    ${power_reset}=False
    power_ue.UE Detach    ue_type=${ue_type}   ue_index=${ue_index}    ue_alias=${ue_alias}    power_reset=${power_reset}

PowerUE.Start DL Traffic
    [Documentation]   applicalbe for Huawei SigSpark using the common-lib of PowerUE
    ...    dt_name to be specified in case.
    [Arguments]    ${ue_type}=${UE_TYPE}     ${direction}=dl   ${throughput}=10MKbits/sec
    ...            ${duration}=600   ${protocol}=udp    ${ue_index}=${0}
    ...            ${cap_index}=${0}   ${dt_index}=${0}    ${iperf_port}=default
    ...            ${interval}=1    ${buffer_size}=1024B    ${dt_name}=DT_1
    ...            ${ue_alias}=UE_${ue_index}    ${multidrb_QoS_dest}=${None}
    ...            ${apn_address}=wap1nokiacom    ${ue_mode}=SA
    power_ue.Start traffic   ue_type=${ue_type}    direction=${direction}   throughput=${throughput}
    ...            duration=${duration}   protocol=${protocol}    ue_index=${ue_index}
    ...            cap_index=${cap_index}   dt_index=${dt_index}    iperf_port=${iperf_port}
    ...            interval=${interval}    buffer_size=${buffer_size}    dt_name=${dt_name}
    ...            ue_alias=${ue_alias}    multidrb_QoS_dest=${multidrb_QoS_dest}
    ...            apn_address=${apn_address}    ue_mode=${ue_mode}

PowerUE.Stop DL Traffic
    [Arguments]    ${ue_type}=${UE_TYPE}    ${direction}=dl    ${ue_index}=${0}    ${dt_index}=${0}
    ...            ${dt_name}=DT_1    ${ue_alias}=UE_${ue_index}    ${iperf_port}=default
    ...            ${apn_address}=wap1nokiacom    ${ue_mode}=SA
    power_ue.Stop traffic     ue_type=${ue_type}    direction=${direction}    ue_index=${ue_index}   dt_index=${dt_index}
    ...            dt_name=${dt_name}    ue_alias=${ue_alias}   iperf_port=${iperf_port}
    ...            apn_address=${apn_address}    ue_mode=${ue_mode}

PowerUE.Start UL Traffic
    [Documentation]   applicalbe for Huawei SigSpark using the common-lib of PowerUE
    ...    dt_name to be specified in case.
    [Arguments]    ${ue_type}=${UE_TYPE}     ${direction}=ul   ${throughput}=3MKbits/sec
    ...            ${duration}=600   ${protocol}=udp    ${ue_index}=${0}
    ...            ${cap_index}=${0}   ${dt_index}=${0}    ${iperf_port}=default
    ...            ${interval}=1    ${buffer_size}=1024B    ${dt_name}=DT_2
    ...            ${ue_alias}=UE_${ue_index}    ${multidrb_QoS_dest}=${None}
    ...            ${apn_address}=wap1nokiacom    ${ue_mode}=SA
    power_ue.Start traffic   ue_type=${ue_type}    direction=${direction}   throughput=${throughput}
    ...            duration=${duration}   protocol=${protocol}    ue_index=${ue_index}
    ...            cap_index=${cap_index}   dt_index=${dt_index}    iperf_port=${iperf_port}
    ...            interval=${interval}    buffer_size=${buffer_size}    dt_name=${dt_name}
    ...            ue_alias=${ue_alias}    multidrb_QoS_dest=${multidrb_QoS_dest}
    ...            apn_address=${apn_address}    ue_mode=${ue_mode}

PowerUE.Stop UL Traffic
    [Arguments]    ${ue_type}=${UE_TYPE}    ${direction}=ul    ${ue_index}=${0}    ${dt_index}=${0}
    ...            ${dt_name}=DT_2    ${ue_alias}=UE_${ue_index}    ${iperf_port}=default
    ...            ${apn_address}=wap1nokiacom    ${ue_mode}=SA
    power_ue.Stop traffic     ue_type=${ue_type}    direction=${direction}    ue_index=${ue_index}   dt_index=${dt_index}
    ...            dt_name=${dt_name}    ue_alias=${ue_alias}   iperf_port=${iperf_port}
    ...            apn_address=${apn_address}    ue_mode=${ue_mode}


UE Attach and Start data transfer with Log Capturing
    [Documentation]
    [Arguments]    ${connection}=${ALIAS_ASIK}    ${ue_index}=${0}    ${duration}=600    ${apn_address}=${SA_APN}    ${ue_mode}=SA
    [Timeout]      20min
    gNB.Connect
    Wireshark.StartCaptureNGLog   filename=${TEST NAME.replace(" ", "_").replace("(", "").replace(")", "")}_NG_DL.pcap
#    Wireshark.Start Capturing Log From Container  filename=${TEST NAME.replace(" ", "_").replace("(", "").replace(")", "")}_CPIF_DL.pcap
#    ...    container=0xe004
#    Wireshark.Start Capturing BIP Log    filename=${TEST NAME.replace(" ", "_").replace("(", "").replace(")", "")}_BIP.pcap
#    sleep    5s
    ${UE_Attach}    run keyword and return status     PowerUE.Attach UE  ue_index=${ue_index}   power_reset=True
#    Wireshark.StopCapturinglog    listen_port=etha01
    run keyword if    ${UE_Attach}    Run Keyword And Continue On Failure    PowerUE.Start DL Traffic  ue_index=${ue_index}   duration=${duration}
    ...    apn_address=${apn_address}    ue_mode=${ue_mode}
    run keyword if   ${UE_Attach}   Run Keyword And Continue On Failure   PowerUE.Start UL Traffic  ue_index=${ue_index}   duration=${duration}
    ...    apn_address=${apn_address}    ue_mode=${ue_mode}
    sleep    30s
    gNB.Connect
    Wireshark.StopCapturingAlllog
#    Run Keyword And Ignore Error    Wireshark.DownloadLogToUTE   filename=${TEST NAME.replace(" ", "_").replace("(", "").replace(")", "")}_BIP.pcap
    Wireshark.DownloadLogToUTE   filename=${TEST NAME.replace(" ", "_").replace("(", "").replace(")", "")}_NG_DL.pcap
#    Wireshark.DownloadLogFromContainerToUTE    filename=${TEST NAME.replace(" ", "_").replace("(", "").replace(")", "")}_CPIF_DL.pcap
#    ...    remote_dir=/tmp/node_0xe004/tmp
    should be true   ${UE_Attach}


UE Attach and DL data transfer with Log Capturing
    [Documentation]
    [Arguments]    ${connection}=${ALIAS_ASIK}   ${ue_index}=${0}    ${duration}=600     ${apn_address}=${SA_APN}    ${ue_mode}=SA
    [Timeout]      15min
    gNB.Connect
    Wireshark.StartCaptureNGLog   filename=${TEST NAME.replace(" ", "_").replace("(", "").replace(")", "")}_NG_DL.pcap
#    Wireshark.Start Capturing Log From Container  filename=${TEST NAME.replace(" ", "_").replace("(", "").replace(")", "")}_CPIF_DL.pcap
#    ...   container=0xe004
#    Wireshark.Start Capturing BIP Log    filename=${TEST NAME.replace(" ", "_").replace("(", "").replace(")", "")}_BIP.pcap
    ${UE_Attach}    run keyword and return status     PowerUE.Attach UE   ue_index=${ue_index}   power_reset=True
    run keyword if    ${UE_Attach}    Run Keyword And Continue On Failure    PowerUE.Start DL Traffic   ue_index=${ue_index}   duration=${duration}
    ...    apn_address=${apn_address}    ue_mode=${ue_mode}
#    sleep    30s
#    Wireshark.StopCapturinglog    listen_port=etha01
    Wireshark.StopCapturingAlllog
#    Run Keyword And Ignore Error    Wireshark.DownloadLogToUTE   filename=${TEST NAME.replace(" ", "_").replace("(", "").replace(")", "")}_BIP.pcap
    Wireshark.DownloadLogToUTE   filename=${TEST NAME.replace(" ", "_").replace("(", "").replace(")", "")}_NG_DL.pcap
#    Wireshark.DownloadLogFromContainerToUTE    filename=${TEST NAME.replace(" ", "_").replace("(", "").replace(")", "")}_CPIF_DL.pcap
#    ...   remote_dir=/tmp/node_0xe004/tmp
    should be true   ${UE_Attach}

One_UE Call with DL traffic
    [Arguments]   ${ue_index}=${0}    ${apn_address}=${SA_APN}    ${ue_mode}=SA
    Run Keyword And Ignore error    PowerUE.Detach UE   ue_index=${ue_index}
    UE Attach and DL data transfer with Log Capturing   ue_index=${ue_index}    apn_address=${apn_address}    ue_mode=${ue_mode}
    PowerUE.Check DL Throughput  ue_index=${ue_index}


PowerUE.Check UL Throughput
    [Arguments]    ${ue_type}=${UE_TYPE}   ${direction}=ul    ${throughput}=1    ${deviation}=80
    ...            ${ue_index}=${0}    ${dt_index}=${0}    ${ue_alias}=UE_${ue_index}    ${du_index}=${0}
    ...            ${hw_slot}=${1}    ${sample}=${10}    ${start_offset}=${3}    ${sleep_time}=${5}    ${cellid}=${EMPTY}
    power_ue.Check throughput     ue_type=${ue_type}   direction=${direction}   throughput=${throughput}    deviation=${deviation}
    ...            ue_index=${ue_index}    dt_index=${dt_index}    ue_alias=${ue_alias}    du_index=${du_index}
    ...            hw_slot=${hw_slot}    sample=${sample}    start_offset=${start_offset}    sleep_time=${sleep_time}   cellid=${cellid}


PowerUE.Check DL Throughput
    [Arguments]    ${ue_type}=${UE_TYPE}   ${direction}=dl    ${throughput}=2    ${deviation}=80
    ...            ${ue_index}=${0}    ${dt_index}=${0}    ${ue_alias}=UE_${ue_index}    ${du_index}=${0}
    ...            ${hw_slot}=${1}    ${sample}=${10}    ${start_offset}=${3}    ${sleep_time}=${5}    ${cellid}=${EMPTY}
    power_ue.Check throughput     ue_type=${ue_type}   direction=${direction}   throughput=${throughput}    deviation=${deviation}
    ...            ue_index=${ue_index}    dt_index=${dt_index}    ue_alias=${ue_alias}    du_index=${du_index}
    ...            hw_slot=${hw_slot}    sample=${sample}    start_offset=${start_offset}    sleep_time=${sleep_time}   cellid=${cellid}

PowerUE.Check Throughput for DL and UL
    [Arguments]    ${ue_type}=${ue_type}  ${ultarget_throughput}=1   ${dltarget_throughput}=2
    ...    ${target_avg_percent}=0.9    ${min_percent}=0.7   ${cell_idx}=1    ${ue_index}=${0}    ${ue_alias}=UE_${ue_index}
    process.check_Huawei_throughput    ue_type=${ue_type}    ultarget_throughput=${ultarget_throughput}
    ...    dltarget_throughput=${dltarget_throughput}    target_avg_percent=${target_avg_percent}    min_percent=${min_percent}
    ...    cell_idx=${cell_idx}    ue_index=${ue_index}    ue_alias=${ue_alias}

PowerUE.Check Peak Throughput for DL and UL
    [Arguments]    ${theory_dl_peak}    ${theory_ul_peak}   ${ue_type}=${UE_TYPE}
    ...            ${total_time}=60    ${interval}=10s    ${duration_time_for_once}=200s
    ...            ${acceptable_tput_percentage}=0.95    ${nr_cell_index}=1    ${du_index}=0
    ...            ${gnb_ssl_connection}=COAM    ${is_need_to_capture_log}=${False}
    COAM_Admin.Login
    teardown the aasyslog save progress
    power_ue.Check peak throughput    ue_type=${ue_type}    theory_dl_peak=${theory_dl_peak}    theory_ul_peak=${theory_ul_peak}
    ...    total_time=${total_time}    interval=${interval}    duration_time_for_once=${duration_time_for_once}
    ...    acceptable_tput_percentage=${acceptable_tput_percentage}    nr_cell_index=${nr_cell_index}    du_index=${du_index}
    ...    gnb_ssl_connection=${gnb_ssl_connection}    is_need_to_capture_log=${False}


Wireshark.Start Capturing BIP Log
    [Arguments]    ${filename}
    ssh.send command    command=cp /user/toor4nsn/loner_mirroring_L1R51.sh /ffs/run/    connection=${ALIAS_ASIK}
    Conn.ConnectToLoner    alias=${ALIAS_LONER}
    ssh.send command    command= cp /ffs/run/loner_mirroring_L1R51.sh /tmp/    connection=${ALIAS_LONER}
    ${output}   ssh.execute    command=sh /tmp/loner_mirroring_L1R51.sh    connection=${ALIAS_LONER}
    ssh.send command    command=dbgrrc mirror sport 25 dport 2 enable both    connection=${ALIAS_ASIK}
    Wireshark.StartCaptureLog    listen_port=etha01    log_dir=/tmp     filename=${filename}    connection=${ALIAS_ASIK}
    ssh.execute        command=ps -ef|grep -i tcpdump     connection=${ALIAS_ASIK}

Wireshark.Start Capturing Log From Container
    [Arguments]   ${filename}    ${container}=0xe004    ${listen_port}=any     ${log_dir}=/tmp   ${connection}=${ALIAS_ASIK}
    ssh.send command    command=lxc-attach -n ${container} -- tcpdump -n -i ${listen_port} -w ${log_dir}/${filename} &>/dev/null &
    ...    connection=${connection}

Wireshark.StopCapturingALLlog
    ssh.send command   command=ps -ef|grep tcpdump|grep -v grep|grep fp0|awk '{print $2}'|xargs kill -2   connection=${ALIAS_ASIK}
#    ${pid}  ssh.execute   command=lxc-attach -n 0xe004 -- ps -ef|grep tcpdump|grep -v grep|awk '{print $2}'  connection=${ALIAS_ASIK}
#    ssh.execute   command=lxc-attach -n 0xe004 -- kill -2 ${pid.replace('\r\n','')}   connection=${ALIAS_ASIK}

Wireshark.DownloadLogFromContainerToUTE
    [Arguments]    ${filename}    ${remote_dir}=/tmp
    ssh.download_file   local_path=${LOG_PATH}/${filename}    remote_path=${remote_dir}/${filename}   connection=${ALIAS_ASIK}
    sleep    20s

## for later use: ASIB##
Wireshark.ASIBDownloadLogToUTE
    [Arguments]    ${logtype}=${logtype}    ${filename}=${filename}   ${log_dir}=/tmp    ${connection}=${ALIAS_ASIK}
    [Timeout]    5min
    run keyword if    '${logtype}'=='BIP'
    ...    ssh.execute    command=scp /tmp/tcpdumpL2L1_filtering_off.pcap0 /tmp/${filename}    connection=${connection}
    ...    ELSE IF    '${logtype}'=='CPIF'
    ...    ssh.execute    command=scp /tmp/node_CPIF00/tmp/${filename} /tmp/${filename}    connection=${connection}
    ssh.download_file   local_path=${LOG_PATH}/${filename}    remote_path=${log_dir}/${filename}   connection=${connection}
    sleep    20s

###Seting up and Tearding down ###

Setup Suite
    TestSuite.Start
    Create Log Directories
    set suite variable      ${Log_PATH_Artifactory}    /opt/ute/workspace/CIT/Master/Case_Logs
    set suite variable   ${OAM_TYPE}    COAM
    Conn.ResetCache
    gNB.SetLoggingSeverity    LoggingSeverity=debug


Teardown Suite
    TestSuite.Stop

Setup Case
    [Arguments]
    TestCase.Start
    Run Keyword And Ignore Error    Start BTSlogs Collection
#    Reset gNB until Ready

Teardown Case
    [Arguments]
    TestCase.Stop
#    Run Keyword And Ignore error    PowerUE.Stop DL Traffic   ue_index=${0}
#    Run Keyword And Ignore error    PowerUE.Stop UL Traffic   ue_index=${0}
#    Run Keyword And Ignore error    PowerUE.Stop DL Traffic   ue_index=${1}
#    Run Keyword And Ignore error    PowerUE.Stop UL Traffic   ue_index=${1}
#    Run Keyword And Ignore error    PowerUE.Detach UE   ue_index=${0}
#    Run Keyword And Ignore error    PowerUE.Detach UE    ue_index=${1}

    gNB.Connect
    Run Keyword And Ignore Error     Wireshark.StopCapturingALLlog     # to be combined with the following two
    Run Keyword And Ignore Error     ssh.execute   command=killall -2 tcpdump   connection=${ALIAS_ASIK}
    Run Keyword And Ignore Error     ssh.execute   command=killall -2 tcpdump   connection=${ALIAS_ASIK_SLAVE}
#    Run Keyword And Ignore Error     Check UE status from AMF
#    Run Keyword If Test Failed    Run Keyword And Ignore Error     Collect Snapshot
    Run Keyword And Ignore Error     Stop BTSlogs Collection and get logs
    Run Keyword And Ignore Error    run    sudo mkdir -p -m 777 ${Log_PATH_Artifactory}
    Run Keyword And Ignore Error    run    sudo scp -r ${LOG_PATH}/* ${Log_PATH_Artifactory}
#    Run Keyword If Test Failed    Run Keyword And Ignore Error     Collect gNB Logs
    Run Keyword And Ignore error     selenium_coam.disable_virtual_display
    Run Keyword And Ignore error     Kill Xvfb in UTE
    Run Keyword And Ignore error     force_close_coam_webdriver
    Run Keyword And Ignore error     run    command=killall firefox
    Run Keyword And Ignore error     run    command=killall geckodriver
#    Run Keyword And Ignore error     Clear UE info from AMF with Retry
    Conn.ResetCache
    TestCase.Stop


Kill Xvfb in UTE
    ${Xvfb_Cnt}  run  command=ps -ef | grep -i Xvfb |grep -v grep|awk '{print$2}'|awk 'END{print NR}'
    FOR    ${i}    IN RANGE    ${Xvfb_Cnt}
        ${PID1}  run  command=ps -ef|grep -i Xvfb|awk '{{print $2}}'|head -n 1
        Log  message=Killing ${i+1}st Xvfb process with PID ${PID1}.
        run  command=/bin/kill -9 ${PID1.strip()}
    END
    run  command=ps -ef | grep -i Xvfb |grep -v grep

Collect Snapshot
    [Arguments]
    COAM_WebEM.Login
    selenium_coam.snapshot_collection_settings    coverage=All log files     save_location=Local
    ${snapshot_file}    selenium_coam.collect_snapshot    snapshot_waiting_timeout=1200
    log    ${snapshot_file}
    COAM_WebEM.Logout
    Run Keyword And Ignore Error    run    command=cp ${snapshot_file} ${LOG_PATH}

Start BTSlogs Collection
    [Documentation]    collect syslogs from ute VM.
    run keyword and ignore error    run    command=cd /tmp/btslog2 ; rm -rf TRACE_*.bin ; rm -rf SYSLOG_*.LOG
    btslog.create_btslog_collector
    ...   name=btslog
    ...   btslog_path=/home/ute/btslog/btslog
    ...   btslog_launcher_path=/home/ute/btslog/btslog_launcher
    ...   log_dir=/tmp/btslog2
    core.setup_collectors      names=btslog
    core.start_collectors      names=btslog

Stop BTSlogs Collection and get logs
    core.teardown_collectors      names=btslog
    run    command=cd /tmp/btslog2 ; ls -al ; cat SYSLOG_*.LOG > SYSLOG_combine.LOG
    run    command=cd /tmp/btslog2 ; tar zcvf /tmp/${TEST NAME.replace(" ", "_").replace("(", "").replace(")", "")}_SYSLOG.tgz SYSLOG_combine.LOG
    run    command=cp /tmp/${TEST NAME.replace(" ", "_").replace("(", "").replace(")", "")}_SYSLOG.tgz ${LOG_PATH}
