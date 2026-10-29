*** Settings ***
Documentation     author: Wang Sujuan
...               contact: sujuan.wang@nokia-sbell.com
...               squad group: SG_01
...               feature : 5GC002219
#Library         taf.collectors.core   WITH NAME   core
Library         taf.collectors.btslog  WITH NAME   btslog
Resource    ../../5GC000496_C/Resources/L3Call.robot
Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/power_ue/power_ue.robot
#Variables         ${CFGFILE_ON_GIT}/TLDelta.py

*** Variables ***
#If GNB1 is used
#${CFGFILE_ON_GIT}        /opt/transformers.dynamic.nsn-net.net/gnb_configuration/Hangzhou/${testline_name}/
#${GoldenSCF_PATH}        /opt/transformers.dynamic.nsn-net.net/gnb_configuration/Hangzhou/5G_PZ_HZ_1_SG/
#${TestLineSCF}            ${CFGFILE_PATH}/TestLineSCF1Cell_Both.xml
#${GoldenSCF}        ${CFGFILE_PATH}/GoldenSCF1Cell_both.xml
${LOG_PATH}             ${OUTPUT DIR}/Logs
${ALIAS_ASIK}               asik
${ALIAS_ASIK_SLAVE}         asik_slave
${ALIAS_UTE}                ute
${ASIK_LMP_IP}       ${tl.gnbs[0].dus[0].airscale.common_units[0].lmp_connection.addr}
${ASIK_IP}           ${tl.gnbs[0].cu.oam_ssh_connection_details.addr}
${WEBUI_IP}                 ${tl.gnbs[0].cu.oam_http_connection_details.addr}
${WEBUI_USERNAME}           ${tl.gnbs[0].cu.oam_http_connection_details.username}
${WEBUI_PASSWORD}           ${tl.gnbs[0].cu.oam_http_connection_details.password}
${WEBUI_URL}                https://${tl.gnbs[0].cu.oam_http_connection_details.addr}
${PB_ASIK_IP}       ${tl.gnbs[0].dus[0].airscale.common_units[0].pdu_port.pdu.addr}
${PB_ASIK_PORT}     ${tl.gnbs[0].dus[0].airscale.common_units[0].pdu_port.port_no}
${PB_5GRU_IP}       ${tl.gnbs[0].dus[0].rus[0].pdu_port.pdu.addr}
${PB_5GRU_PORT}     ${tl.gnbs[0].dus[0].rus[0].pdu_port.port_no}
#${PB_5GRU_2_IP}     ${tl.gnbs[0].dus[0].rus[1].pdu_port.pdu.addr}
#${PB_5GRU_2_PORT}    ${tl.gnbs[0].dus[0].rus[1].pdu_port.port_no}
${ALIAS_ENBCTLPC}    ENB_PC
${ALIAS_SHP}      SHP
${ALIAS_E500}     E500
${ALIAS_PRISMA}    Prisma
${QC_IP}          ${tl.ues[0].ssh_connection_details.addr}
${QC_USERNAME}    ${tl.ues[0].ssh_connection_details.username}
${QC_PASSWORD}    ${tl.ues[0].ssh_connection_details.password}
${AlIAS_QC}       Qualcomm
${QC_UE_alias}       QC_UE
${UE_alias}                 UE_0
${device_model}    ${tl.ues[0].serial_number}
${distname_id_1}     ${tl.gnbs[0].instance_id}/${tl.gnbs[0].global_bts_id}
${MRBTS_ID}        ${tl.gnbs[0].instance_id}
${NRBTS_ID}        ${tl.gnbs[0].global_bts_id}
# BBU_TYPE = asik/asib
${BBU_TYPE}        asik
${SST}       129
${SD}        1
${tac}      210
*** Keywords ***
TC.5GC002219_K_04_PDU_Session_Setup_pass_Counter_Update
    Run Keyword And Ignore error    spark.restartapp    index=${0}
    ${status}   Run Keyword And Return Status    gNB.VerifyOnAirViaOAMUntilReady
    Run Keyword If  '${status}' == 'False'    Run Keywords    Commission GNB

    wait until keyword succeeds   10min   10s    Conn.ConnectWithTimeout  alias=${ALIAS_ASIK}
    Run Keyword And Ignore error    Wireshark.StartCaptureLogFromContainer    filename=cpif_attach.pacp    nodename=CPIF
    ${ue_type}    ue.translate_power_ue_type_from_testline
    ${status}   Run Keyword And Return Status   5GC002219_Resources.UE Attach   ue_type=${ue_type}
    Run Keyword And Ignore error    Start L3 Traffic    ue_type=${ue_type}
    sleep    10s
    Run Keyword And Ignore error    Wireshark.StopCapturinglogFromContainer    nodename=CPIF
    Run Keyword And Ignore error    wireshark.DownloadLogToUTEFromContainer    filename=cpif_attach.pacp    nodename=CPIF
    Conn.Disconnect  alias=${ALIAS_ASIK}
    Run Keyword If  '${status}' == 'False'    Run Keywords    Commission GNB
    ...        AND    5GC002219_Resources.UE Attach   ue_type=${ue_type}
    ...        AND    Run Keyword And Ignore error    Start L3 Traffic    ue_type=${ue_type}

    sleep    10s
    Run Keyword And Ignore error    Start UE Detach    ue_type=${ue_type}
    Wait until keyword succeeds   5x   3min    Check Counter Update

Commission GNB
    COAM_WebEM.Login
    COAM_WEBEM.LockAllCell
    #Modify SNSSAI Administrative state Parameters
    COAM_WebEM.Logout
    Run Keyword And Continue On Failure    Commission GNB with retry for 1RU    scf_file=${TestLineSCF}
    wait until keyword succeeds   15min   1min    gNB.VerifyOnAirViaOAMUntilReady

COAM_WEBEM.LockAllCell
    [Arguments]   ${timeout}=120
    ${cell_count}=    selenium_coam.get_number_of_cells
    FOR    ${i}    IN RANGE    ${cell_count}
        ${cell_info}=    selenium_coam.get_cell_info    cell_idx=${i+1}
        run keyword if    ${cell_info}!="None"and'${cell_info['Status']['Administrative state']}'=="Unlocked"
        ...                selenium_coam.lock_cell    cell_idx=${i+1}    timeout=${timeout}
        Sleep  2 mins
    END

Check Counter Update
    wait until keyword succeeds    3x    1min    COAM_WebEM.Login
    COAM_WEBEM.CheckBTSConutersWithConditioanalTraget    counter_id=M55135C00501    target_value=1
    COAM_WEBEM.CheckBTSConutersWithConditioanalTraget    counter_id=M55135C00502    target_value=1
    COAM_WEBEM.CheckBTSConutersWithConditioanalTraget    counter_id=M55135C00505    target_value=1
    COAM_WEBEM.CheckBTSConutersWithConditioanalTraget    counter_id=M55135C00506    target_value=1

    COAM_WEBEM.CheckBTSConutersWithConditioanalTraget    counter_id=M55133C01001    target_value=1
    COAM_WEBEM.CheckBTSConutersWithConditioanalTraget    counter_id=M55133C01002    target_value=1
    COAM_WEBEM.CheckBTSConutersWithConditioanalTraget    counter_id=M55133C01004    target_value=1
    COAM_WEBEM.CheckBTSConutersWithConditioanalTraget    counter_id=M55133C01005    target_value=1
    COAM_WebEM.Logout
COAM_WEBEM.CheckBTSConutersWithConditioanalTraget
    [Arguments]    ${counter_id}   ${target_value}
    ${date}   Get Current Date   exclude_millis=True
    ${res}   selenium_coam.get_bts_counters_info   counter_id=${counter_id}
    ${values}    get dictionary values   ${res}
    log  The latest one is: ${values[-1]}
    should be true     ${values[-1]}>=${target_value}

Setup case suite
    TestSuite.Start
    Create Directory    ${LOG_PATH}
    set suite variable     ${TestLineSCF}            ${CFGFILE_PATH}/TestLineSCF1Cell_Both.xml
    #set suite variable     ${GoldenSCF}        ${CFGFILE_PATH}/GoldenSCF1Cell_both.xml
    set suite variable      ${Log_PATH_Artifactory}    /root/workspace/CIT/Master/Case_Logs/
    set suite variable   ${OAM_TYPE}    COAM
    Conn.ResetCache
    ${outputfile}    gNB.Generate TL SCF    GoldenSCF_PATH=${GoldenSCF_ON_GIT}/${GoldenSCF}
    ...             TLDelta_PATH=${CFGFILE_PATH}
    ...             TestLineSCF_cell_num=${1}   cell_type=Both
    ...            MRBTSID=${MRBTS_ID}    NRBTSID=${NRBTS_ID}
    set suite variable   ${TestLineSCF}    ${outputfile}

Teardown Suite
    TestSuite.Stop
Setup Case
    [Arguments]
    TestCase.Start
    Run Keyword And Ignore Error    Start BTSlogs Collection
Teardown case
    [Arguments]   ${connection}=COAM
    Run Keyword And Ignore Error    Stop BTSlogs Collection and get logs
    #Run Keyword And Ignore Error    Backup current SCF
    gNB.Connect
    Run Keyword And Ignore Error    kill GNB wireshark process
    log     ${TEST STATUS}
    Run Keyword If  '${TEST STATUS}' == 'FAIL'    Collect logs
    ...    ELSE    Pass Execution If    '${TEST STATUS}' == 'PASS'    Not collect logs
    Run Keyword And Ignore Error    Clean GNB wireshark log
    Run Keyword And Ignore Error    kill admin process
    Run Keyword And Ignore Error    run   command=killall firefox
    Conn.ResetCache
    TestCase.Stop
Start BTSlogs Collection
    run keyword and ignore error    run    command=cd /tmp/btslog2 ; rm -rf BTSLOG_TRACE_*.bin ; rm -rf SYSLOG_*.LOG
    btslog.create_btslog_collector
    ...   name=btslog
    ...   btslog_path=/opt/btslog/btslog
    ...   btslog_launcher_path=/opt/btslog/btslog_launcher
    btslog.Set Global Alias    alias=btslog
    core.setup_collectors      names=btslog
    core.start_collectors      names=btslog

Stop BTSlogs Collection and get logs
    run keyword and ignore error    core.stop_collectors      names=btslog
    run keyword and ignore error    run    command=cd /tmp/btslog2 ; ls -al ; cat SYSLOG_*.LOG > SYSLOG_combine.LOG
    run keyword and ignore error    run    command=cd /tmp/btslog2 ; tar zcvf /tmp/${TEST NAME.replace(" ", "_")}_SYSLOG.tgz SYSLOG_combine.LOG
    run keyword and ignore error    run    command=cp /tmp/${TEST NAME.replace(" ", "_")}_SYSLOG.tgz ${LOG_PATH}

Commission GNB with retry for 1RU
    [Arguments]    ${scf_file}
    ${commission_check}    run keyword and return status    gNB.Commission    scf_file=${scf_file}    oam_type=COAM    timeout=900
    Run keyword if    ${commission_check}== True    Log    continue next steps
    Run keyword if    ${commission_check}== False    run keywords     Power.ResetgNB    model=HBTE
                      ...    AND    Power.Reset5GRU    model=HBTE
                      ...    AND    Check HW status
                      ...    AND    gNB.Commission    scf_file=${scf_file}    oam_type=COAM    timeout=900

Commission GNB with retry for 2RU
    [Arguments]    ${scf_file}
    ${commission_check}    run keyword and return status    gNB.Commission    scf_file=${scf_file}    oam_type=COAM    timeout=900
    Run keyword if    ${commission_check}== True    Log    continue next steps
    Run keyword if    ${commission_check}== False    run keywords     Power.ResetgNB    model=HBTE
                      ...    AND    Power.Reset5GRU    model=HBTE
                      ...    AND    Power.Reset5G_RU2
                      ...    AND    Check HW status
                      ...    AND    gNB.Commission    scf_file=${scf_file}    oam_type=COAM    timeout=900

Power.Reset5G_RU2
    facom.PowerOnOff    pdu_ip=${PB_5GRU_2_IP}    Port_Number=${PB_5GRU_2_PORT}     Action=power_off
    facom.PowerOnOff    pdu_ip=${PB_5GRU_2_IP}    Port_Number=${PB_5GRU_2_PORT}     Action=power_on

Collect logs
    ${gNB_logName}=    catenate    SEPARATOR=_    ${TEST NAME.replace(" ", "_")}   gNB.log
    Run Keyword And Ignore Error    gnb.collectlog    ${gNB_logName}
    Run Keyword And Ignore Error    run    sudo mkdir -p -m 777 ${Log_PATH_Artifactory}
    Run Keyword And Ignore Error    run    sudo scp -r ${LOG_PATH}/* ${Log_PATH_Artifactory}
    Run Keyword And Ignore Error    Collect snapshot via webui

Collect snapshot via webui
    [Arguments]
    COAM_WebEM.Login
    selenium_coam.snapshot_collection_settings    coverage=All log files     save_location=Local
    ${snapshot_file}    selenium_coam.collect_snapshot    snapshot_waiting_timeout=1200
    log    ${snapshot_file}
    COAM_WebEM.Logout
    Run Keyword And Ignore Error    run    command=cp ${snapshot_file} ${LOG_PATH}

Check HW status
    gNB.Connect
    wait until keyword succeeds    11x    2min    gNB CheckHWStatus
    sleep    3min

gNB CheckHWStatus
    [Arguments]    ${alias}=${ALIAS_ASIK}
    ${fct_status}    ${fsp_status}    get_gnb_status.check_board_status_on_asik    connection=${alias}
    log  ${fct_status}
    log  ${fsp_status}
    Should Be Equal    ${fct_status}    ready
    Should Be Equal    ${fsp_status}    ready

Clean GNB wireshark log
    [Arguments]
    Conn.ConnectWithTimeout  alias=${ALIAS_ASIK}
    Conn.Execute  cmd=rm -rf /ffs/run/config/toor4nsn/1008*.pcap   alias=${ALIAS_ASIK}
    Conn.Disconnect  alias=${ALIAS_ASIK}

kill admin process
    run    command=ps xafu |grep node|grep -v grep|awk '{print $2}' | xargs kill -9

kill GNB wireshark process
    Run Keyword And Ignore Error    ssh.execute    command=killall -2 tcpdump    connection=${ALIAS_ASIK}
    ${container}    gnb.get_container_id    nodename=CPIF
    Run Keyword And Ignore Error    ssh.execute    command=lxc-attach -n ${container} -- killall -2 tcpdump    connection=${ALIAS_ASIK}

Modify SNSSAI Administrative state Parameters
    [Arguments]    ${DistName}=${distname_id_1}/SNSSAI-1    ${FilterParam}=Administrative state    ${NewValue}=Locked
    COAM_WEBEM.ModifyParameters    DistName=${DistName}    FilterParam=${FilterParam}    NewValue=${NewValue}
    Run Keyword And Ignore Error    COAM_WEBEM.ModifyParameters    DistName=${distname_id_1}/SNSSAI-2
    ...    FilterParam=Administrative state    NewValue=Locked
    COAM_WebEM.ValidateAndActiveParameters

COAM_WEBEM.ModifyParameters
    [Arguments]    ${DistName}    ${FilterParam}   ${NewValue}
    Wait Until Keyword Succeeds    3 times    30s
    ...    selenium_coam.set_parameter_value
    ...    dist_name=${DistName}    filter_param=${FilterParam}    new_value=${NewValue}
5GC002219_Resources.UE Attach
    [Arguments]    ${ue_type}=huawei_sigspark
    power_ue.Prepare UE    ue_type=${ue_type}
    Run Keyword And Ignore Error    Start UE Detach    ue_type=${ue_type}
    Start UE Attach    ue_type=${ue_type}

###  power ue specific part ####
Start UE Attach
    [Arguments]    ${ue_type}=huawei_sigspark    ${is_4G_check}=False    ${gnb_index}=${0}    ${hwcheck_index}=${1}
    ${5Grach_ed}    power_ue.UE Attach    ue_type=${ue_type}    gnb_index=${gnb_index}    hwcheck_index=${hwcheck_index}
    power_ue.Verify attach    ue_type=${ue_type}    5Grach_ed=${5Grach_ed}    4G_check=${is_4G_check}

Start L3 Traffic
    [Arguments]    ${ue_type}=huawei_sigspark    ${ul_throughput}=5Mbits/sec    ${duration}=60
    power_ue.Start traffic    ue_type=${ue_type}    direction=ul    throughput=${ul_throughput}    duration=${duration}

Stop L3 Traffic
    [Arguments]    ${ue_type}=huawei_sigspark
    Run Keyword And Continue On Failure    power_ue.Stop traffic    ue_type=${ue_type}    direction=ul

Start UE Detach
    [Arguments]    ${ue_type}=huawei_sigspark
    power_ue.UE Detach    ue_type=${ue_type}

Start DLUL Traffic
    [Arguments]    ${ue_type}=huawei_sigspark    ${ul_throughput}=80Mbits/sec    ${dl_throughput}=100Mbits/sec    ${duration}=360
    spark.enable_ue_data_service    ue_alias=${UE_alias}
    sleep    30s
    power_ue.Start traffic    ue_type=${ue_type}    direction=ul    throughput=${ul_throughput}    duration=${duration}
    power_ue.Start traffic    ue_type=${ue_type}    direction=dl    throughput=${dl_throughput}    duration=${duration}

Check Throughput
    [Arguments]    ${ue_type}=huawei_sigspark    ${dlthroughput}=80    ${ulthroughput}=30
    Run Keyword And Continue On Failure    power_ue.Check throughput     ue_type=${ue_type}    direction=ul    throughput=${ulthroughput}
    Run Keyword And Continue On Failure    power_ue.Check throughput     ue_type=${ue_type}    direction=dl    throughput=${dlthroughput}

Stop DLUL Traffic
    [Arguments]    ${ue_type}=huawei_sigspark
    Run Keyword And Continue On Failure    power_ue.Stop traffic    ue_type=${ue_type}    direction=dl
    Run Keyword And Continue On Failure    power_ue.Stop traffic    ue_type=${ue_type}    direction=ul

