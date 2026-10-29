*** Settings ***
Documentation     author: Frank Luo
...               contact: frank.s.luo@nokia-sbell.com
...               Common KWs for 5GC001866-C feature.

Library           taf.transport.ssh		WITH NAME	csn
Library           taf.collectors.core   WITH NAME   core
Library           taf.collectors.btslog  WITH NAME   btslog
Library           taf.hw.rf_attenuator    WITH NAME    PA
Resource          ../../../..//RRM/RAN_PZ_HAZ_34/5GC000496_C/Resources/L3Call.robot
#Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/Throughput_checking_from_GNB.robot
Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/aasyslog.robot
Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/power_ue/power_ue.robot
Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/traffic_via_iperf.robot

*** Variables ***
${UE_TYPE}                  huawei
${PB_5GRU_IP}               ${tl.gnbs[0].dus[0].rus[0].pdu_port.pdu.addr}
${PB_5GRU_PORT}             ${tl.gnbs[0].dus[0].rus[0].pdu_port.port_no}
${PB_ASIK_IP}               ${tl.gnbs[0].dus[0].airscale.common_units[0].pdu_port.pdu.addr}
${PB_ASIK_PORT}             ${tl.gnbs[0].dus[0].airscale.common_units[0].pdu_port.port_no}
${5GC_IP}                   ${tl.core.default_ssh_connection_details.addr}
${5GC_USERNAME}             ${tl.core.default_ssh_connection_details.username}
${5GC_PASSWORD}             ${tl.core.default_ssh_connection_details.password}

*** Keywords ***
L3_Call
    [Arguments]     ${ue_index}=0
    PowerUE.Reserve UE    ue_index=${ue_index}
    ${attach_result}    PowerUE.Attach UE     ue_index=${ue_index}
    power_ue.Verify attach    ${UE_TYPE}    5Grach_ed=${attach_result}     ue_index=${ue_index}
    PowerUE.Start DL Traffic     ue_index=${ue_index}
    PowerUE.Check DL Throughput     ue_index=${ue_index}
    PowerUE.Stop DL Traffic     ue_index=${ue_index}
    PowerUE.Start UL Traffic     ue_index=${ue_index}
    PowerUE.Check UL Throughput     ue_index=${ue_index}
    PowerUE.Stop UL Traffic     ue_index=${ue_index}

#### gNB side operation ###
Process.Verify gNB Readiness and Fail Case if Not After Reset
    ${gNB_on_air}    run keyword and return status    wait until keyword succeeds   2x   3min     COAM_WebEM.VerifyAllCellsAreOnline
    run keyword if  not ${gNB_on_air}   Powercycle gNB until Ready

Powercycle gNB until Ready
    Power.ResetgNB    model=HBTE
    Power.Reset5GRU    model=HBTE
    ${gNB_on_air}    run keyword and return status    wait until keyword succeeds   6x   3min   COAM_WebEM.VerifyAllCellsAreOnline
    run keyword if  not ${gNB_on_air}    fail    msg=gnb is not on air!

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

GNB.Commissioning
    [Arguments]    ${scf_file}    ${file_path}=${CFGFILE_PATH}   ${timeout}=${900}
    COAM_Admin.commission    scf_file=${file_path}/${scf_file}    timeout=${timeout}
    Process.Verify gNB Readiness and Fail Case if Not After Reset

X2 Should Be Ready
    [Arguments]    ${alias}=${ALIAS_ASIK_SLAVE}
    gNB.Connect
    gNB.CheckX2StatusUntilReady    dep_1514=Yes    alias=${alias}
    gNB.Disconnect

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
    [Arguments]    ${ue_type}=${UE_TYPE}    ${ue_index}=${0}    ${gnb_index}=${0}    ${hwcheck_index}=${1}
    ...    ${ue_alias}=UE_${ue_index}   ${abil_index}=${1}    ${4G_check}=False    ${5Grach_ed}=${0}    ${5Gstatus}=PASS
    ${output}    power_ue.UE Attach    ue_type=${ue_type}   ue_index=${ue_index}  gnb_index=${gnb_index}  hwcheck_index=${hwcheck_index}
    ...    ue_alias=${ue_alias}    abil_index=${abil_index}
    run keyword if     '${4G_check}'=='True'    power_ue.Verify attach    ue_type=${ue_type}   ue_index=${ue_index}    gnb_index=${gnb_index}
    ...    abil_index=${abil_index}   4G_check=${4G_check}   5Grach_ed=${5Grach_ed}    5Gstatus=${5Gstatus}
    [Return]     ${output}

PowerUE.Detach UE
    [Documentation]   applicalbe for Huawei SigSpark using the common-lib of PowerUE
    [Arguments]    ${ue_type}=${UE_TYPE}    ${ue_index}=${0}    ${ue_alias}=UE_${ue_index}
    power_ue.UE Detach    ue_type=${ue_type}   ue_index=${ue_index}    ue_alias=${ue_alias}

PowerUE.Start DL Traffic
    [Documentation]   applicalbe for Huawei SigSpark using the common-lib of PowerUE
    ...    dt_name to be specified in case.
    [Arguments]    ${ue_type}=${UE_TYPE}     ${direction}=dl   ${throughput}=100MKbits/sec
    ...            ${duration}=600   ${protocol}=udp    ${ue_index}=${0}
    ...            ${cap_index}=${0}   ${dt_index}=${0}    ${iperf_port}=default
    ...            ${interval}=1    ${buffer_size}=1024B    ${dt_name}=DT_1
    ...            ${ue_alias}=UE_${ue_index}    ${multidrb_QoS_dest}=${None}
    power_ue.Start traffic   ue_type=${ue_type}    direction=${direction}   throughput=${throughput}
    ...            duration=${duration}   protocol=${protocol}    ue_index=${ue_index}
    ...            cap_index=${cap_index}   dt_index=${dt_index}    iperf_port=${iperf_port}
    ...            interval=${interval}    buffer_size=${buffer_size}    dt_name=${dt_name}
    ...            ue_alias=${ue_alias}    multidrb_QoS_dest=${multidrb_QoS_dest}

PowerUE.Stop DL Traffic
    [Arguments]    ${ue_type}=${UE_TYPE}    ${direction}=dl    ${ue_index}=${0}    ${dt_index}=${0}
    ...            ${dt_name}=DT_1    ${ue_alias}=UE_${ue_index}    ${iperf_port}=default
    power_ue.Stop traffic     ue_type=${ue_type}    direction=${direction}    ue_index=${ue_index}   dt_index=${dt_index}
    ...            dt_name=${dt_name}    ue_alias=${ue_alias}   iperf_port=${iperf_port}

PowerUE.Start UL Traffic
    [Documentation]   applicalbe for Huawei SigSpark using the common-lib of PowerUE
    ...    dt_name to be specified in case.
    [Arguments]    ${ue_type}=${UE_TYPE}     ${direction}=ul   ${throughput}=30MKbits/sec
    ...            ${duration}=600   ${protocol}=udp    ${ue_index}=${0}
    ...            ${cap_index}=${0}   ${dt_index}=${0}    ${iperf_port}=default
    ...            ${interval}=1    ${buffer_size}=1024B    ${dt_name}=DT_2
    ...            ${ue_alias}=UE_${ue_index}    ${multidrb_QoS_dest}=${None}
    power_ue.Start traffic   ue_type=${ue_type}    direction=${direction}   throughput=${throughput}
    ...            duration=${duration}   protocol=${protocol}    ue_index=${ue_index}
    ...            cap_index=${cap_index}   dt_index=${dt_index}    iperf_port=${iperf_port}
    ...            interval=${interval}    buffer_size=${buffer_size}    dt_name=${dt_name}
    ...            ue_alias=${ue_alias}    multidrb_QoS_dest=${multidrb_QoS_dest}

PowerUE.Stop UL Traffic
    [Arguments]    ${ue_type}=${UE_TYPE}    ${direction}=ul    ${ue_index}=${0}    ${dt_index}=${0}
    ...            ${dt_name}=DT_2    ${ue_alias}=UE_${ue_index}    ${iperf_port}=default
    power_ue.Stop traffic     ue_type=${ue_type}    direction=${direction}    ue_index=${ue_index}   dt_index=${dt_index}
    ...            dt_name=${dt_name}    ue_alias=${ue_alias}   iperf_port=${iperf_port}

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

Check if Cell On Air
    ${gNB_on_air}    run keyword and return status    wait until keyword succeeds   10x   2min   COAM_WebEM.VerifyAllCellsAreOnline
    run keyword if  not ${gNB_on_air}    fail    msg=gnb is not on air!

Wireshark.StopCapturingALLlog
    ssh.send command   command=ps -ef|grep tcpdump|grep -v grep|grep fp0|awk '{print $2}'|xargs kill -2   connection=${ALIAS_ASIK}
    ${pid}  ssh.execute   command=lxc-attach -n 0xe004 -- ps -ef|grep tcpdump|grep -v grep|awk '{print $2}'  connection=${ALIAS_ASIK}
    ssh.execute   command=lxc-attach -n 0xe004 -- kill -2 ${pid.replace('\r\n','')}   connection=${ALIAS_ASIK}


###Seting up and Tearding down ###
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
