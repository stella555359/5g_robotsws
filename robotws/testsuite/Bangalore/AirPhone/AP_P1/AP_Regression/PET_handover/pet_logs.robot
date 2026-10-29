*** Settings ***
Documentation     This contains common keywords which are needed to run PET Log collection.
Resource    ../../../AP_P1Perf/resources/Variables/p1perf_variables.robot
Resource    variables.robot

*** Keywords ***
Collect EM Traces and Stats
    [Arguments]    ${count}
    Run Keyword And Ignore Error    Get L2RT container ID
    Run Keyword If    '${count}' == '4' and '${EM_TRACES}' == 'True'   Run Keyword And Ignore Error    Collect EM Traces
    ...    ${TEST_NAME}    ${L2RT_container_ID}
    Run Keyword If    '${count}' == '5' and '${EM_PERF_STATS}' == 'True'   Run Keyword And Ignore Error    Collect EM Stats
    ...    ${TEST_NAME}    ${L2RT_container}

Collect EM Traces
    [Arguments]    ${tcname}    ${L2RT_container_ID}
    ${tcname}=    Replace String    ${tcname}    ${SPACE}    _
    Run    chmod +x ${EXECDIR}/${em_trace_stream}
    ${cmd}    catenate    ${EXECDIR}/${em_trace_stream} - -p ${em_trace_stream_port}
    ...       -c ${L2RT_container_ID} -t ${em_trace_type}
    ...       -n ${AP_ASIK.Ip}
    Run Process    ${cmd}    shell=True   timeout=60s
    Collect Traces Logs    ${tcname}

Collect Traces Logs
    [Arguments]    ${tcname}
    ${tcname}=    Remove String    ${tcname}    &
    Run    killall EmTraceHistoryBufferStreamReceiver64
    Run    ls -lrt
    Run    mkdir -p ${vm_logdir}/${execution_logs_path}/em_traces
    ${em_traces_dir}=    Set Variable    ${execution_logs_path}/em_traces
    Run    mv ${EXECDIR}/${L2RT_container_ID}_* ${vm_logdir}/${execution_logs_path}/em_traces
    Run    cd ${vm_logdir}/${execution_logs_path}/em_traces && ls -lrt
    Run    tar -czvf ${vm_logdir}/${em_traces_dir}/${tcname}.tar.gz ${vm_logdir}/${em_traces_dir}/${L2RT_container_ID}_*
    Run    rm -rf ${vm_logdir}/${execution_logs_path}/em_traces/${L2RT_container_ID}_*

Collect EM Stats
    [Arguments]    ${tcname}    ${L2RT_container}
    SSH.Connect To    ${AP_ASIK.Ip}    ${AP_ASIK.Username}    ${AP_ASIK.Password}
    ...    alias=${AP_ASIK.Connection}
    ${tcname}=    Replace String    ${tcname}    ${SPACE}    _
    SSH.Send Command
    ...    command=bsh 1:0 lxc-attach --name ${L2RT_container} -- /opt/CCS_RT/em_perf_monitor -pq > /ffs/run/logs/stats.log
    ...               timeout=30    connection=${AP_ASIK.Connection}
    sleep    10s
    ssh.Disconnect    ${AP_ASIK.Connection}
    Cleanup EM Stats process    ${tcname}    ${L2RT_container}

Cleanup EM Stats process
    [Arguments]    ${tcname}    ${L2RT_container_ID}
    SSH.Connect To    ${AP_ASIK.Ip}    ${AP_ASIK.Username}    ${AP_ASIK.Password}
    ...    alias=${AP_ASIK.Connection}
    SSH.Send Command    command=bsh 1:0 lxc-attach --name ${L2RT_container_ID} -- pgrep perf
    ...               timeout=60    connection=${AP_ASIK.Connection}
    SSH.Send Command    command=bsh 1:0 lxc-attach --name ${L2RT_container_ID} -- pkill -f perf
    ...               timeout=60    connection=${AP_ASIK.Connection}

    ssh.Disconnect    ${AP_ASIK.Connection}
    Collect Stats Logs    ${tcname}

Collect Stats Logs
    [Arguments]    ${tcname}
    SSH.Connect To    ${AP_ASIK.Ip}    ${AP_ASIK.Username}    ${AP_ASIK.Password}
    ...    alias=${AP_ASIK.Connection}
    Download File    /ffs/run/logs/stats.log    ${vm_logdir}/stats.log
    ...    ${AP_ASIK.Connection}
    SSH.Send Command    command=rm -rf /ffs/run/logs/stats.log
    ...               timeout=60    connection=${AP_ASIK.Connection}
    ssh.Disconnect    ${AP_ASIK.Connection}
    Run    mkdir ${vm_logdir}/${execution_logs_path}/em_perf_Stats
    Run    mv ${vm_logdir}/stats.log ${vm_logdir}/${execution_logs_path}/em_perf_Stats
    Run    mv ${vm_logdir}/${execution_logs_path}/em_perf_Stats/stats.log ${vm_logdir}/${execution_logs_path}/em_perf_Stats/${tcname}.log

Collect Logs
   Get Coam SCF
   Collect UTE Files For AP And GNB
   Run Keyword If    '${CONDITIONAL_LOGGING}' == 'False' or '${SUITE STATUS}' == 'FAIL'    Collect SosReport for PET
   Collect gnb PM Counter Logs PET

Collect UTE Files For AP And GNB
    Copy Files       ${WTS_DIR}/${SUITE_WTS_CFG}
    ...              ${TL_INIT_DIR}/DEBUG_log.txt    ${TL_INIT_DIR}/INFO_log.txt    ${vm_logdir}/
    Collect AP Files
    Collect GNB Files

Collect AP Files
    FOR    ${ap_index}    IN RANGE    1    ${AP_COUNT}+1
        ${ap_ip}    Set Variable    192.168.200.${ap_index}
        ${ap_connection}    Set Variable    AP${ap_index}
        SSH.Connect To   ${ap_ip}    ${ASIK_USERNAME}    ${ASIK_PASSWORD}
        ...              alias=${ap_connection}
        SSH.Download File    /rom/simmode/iphy.xml    ${vm_logdir}/iphy_${ap_connection}.xml    ${ap_connection}
        SSH.Download File    /ffs/run/swconfig.txt    ${vm_logdir}/swconfig_${ap_connection}.txt    ${ap_connection}
        SSH.Disconnect       ${ap_connection}
    END

Collect GNB Files
    FOR    ${gnb_index}    IN RANGE    1    ${GNB_COUNT}+1
        ${gnb_ip}    Set Variable    ${gNB_IP_Prefix}.${gnb_index}
        ${gnb_connection}    Set Variable    gnb${gnb_index}
        SSH.Connect To   ${gnb_ip}    ${ASIK_USERNAME}    ${ASIK_PASSWORD}
        ...              alias=${gnb_connection}
        SSH.Download File    /ffs/run/swconfig.txt    ${vm_logdir}/swconfig_${gnb_connection}.txt    ${gnb_connection}
        SSH.Disconnect       ${gnb_connection}
    END

Collect SosReport for PET
    Run Keyword If    '${L2L3_BIPLOG}' == 'True' or '${TRF_PERF_BIP_LOGS}' == 'True'
    ...    Stop and Collect SosReport with Tcpdump for PET
    ...    ELSE IF    '${SYSLOG}' == 'True' and '${L2L3_BIPLOG}' != 'True' and '${TRF_PERF_BIP_LOGS}' != 'True'
    ...    Collect SosReport Parallel
    ...    ELSE    Collect UTE SosReport


Collect SosReport Parallel
    ${command}    Catenate    sed -i \'s@LOG_DIR_ON_DEVICE=.*@LOG_DIR_ON_DEVICE="/tmp/sosreport"@g\'
    ...           ${WTS_DIR}/sosReport.cfg
    Run           ${command}
    Run    chmod 777 ${WTS_DIR}/sosReport_ASIL/*
    ${sosreport_cmd}    Set Variable    cd ${WTS_DIR}/ && ${WTS_DIR}/sosReport_ASIL/sosReport_ASIL.sh -c -s -d > /dev/null 2>\&1
    Start Process    ${sosreport_cmd}    shell=yes

Stop and Collect SosReport with Tcpdump for PET
    Stop sosReport Tcpdump for PET    init    0

Collect syslog
    Run                 killall fsyslog
    Run Keyword    Check IWF fsyslog
    Run                 tar -cvf /home/ute/udpsyslog.tar.gz /home/ute/udpsyslog/*.log.*
    Run                 mv /home/ute/udpsyslog.tar.gz ${vm_logdir}/${execution_logs_path}
    Run Keyword And Ignore Error    Remove Files    /home/ute/udpsyslog/*
    Remove Directory    ${sys_log_directory}    recursive=True

Copy Config Files
    Run    rm -rf ${vm_logdir}/config_files/
    Run    mkdir ${vm_logdir}/config_files/
    Run    mv ${vm_logdir}/*.lua* ${vm_logdir}/config_files/
    Run    mv ${vm_logdir}/*capability*.cfg* ${vm_logdir}/config_files/
    Run    mv ${vm_logdir}/*iphy*.xml* ${vm_logdir}/config_files/
    Run    mv ${vm_logdir}/*scf*.xml* ${vm_logdir}/config_files/
    Run    mv ${vm_logdir}/*swconfig*.txt* ${vm_logdir}/config_files/
    ${oran_nc}=    Get Variable Value    ${NC_SNAPSHOT}
    Run Keyword If    '${oran_nc}' != 'None'    Copy ORAN NC Snapshots
    ${bsr_copy}=    Get Variable Value    ${BSR_FILE_COPY}    None
    Run Keyword If    '${BSR_TEST_FLAG}' == 'True'    Run    cp ${EXECDIR}/tools/BSR_Package/BSR* ${vm_logdir}/config_files/
    Run Keyword If    '${bsr_copy}' == 'True'    Copy Existing BSR
    Run    mv ${vm_logdir}/config_files/ ${vm_logdir}/${execution_logs_path}/config_files/

Copy ORAN NC Snapshots
    Run    mkdir ${vm_logdir}/config_files/ORAN_SNAPSHOT/
    SSH.Connect To   ${AP_ASIK.Ip}    ${AP_ASIK.Username}    ${AP_ASIK.Password}
    ...              alias=${AP_ASIK.Connection}
    FOR    ${ncs_index}    IN RANGE    1    ${NO_OF_RUs}+1    1
        Download File    /ffs/run/simmode/${NC_SNAPSHOT}_${ncs_index}_AP_1.xml
        ...    ${vm_logdir}/config_files/ORAN_SNAPSHOT/${NC_SNAPSHOT}_${ncs_index}_AP_1.xml
        ...    ${AP_ASIK.Connection}
    END
    ssh.Disconnect    ${AP_ASIK.Connection}

Collect Top and Interface stats
    Start Collecting WTS VM Statistics
    Start wts interface stats collection

Start Collecting IQ Traces
    Connect To Capture IQ Log
    FOR    ${index}    IN RANGE    0   ${NO_OF_CELLS}    1
        SSH.Send Command    command=/usr/lib64/python/antenna_snapshot_config.py --subcellid ${index}    timeout=60    connection=target
        Sleep    5s
    END
    Sleep    5s
    SSH.Send Command    command=/usr/lib64/python/antenna_snapshot_config.py --nrevent EPhyEvent_PuschTbCrcFailedWithSinrAboveThreshold
    ...    timeout=60    connection=target
    Sleep    5s
    SSH.Send Command    command=/usr/lib64/python/antenna_snapshot_config.py --query    timeout=60    connection=target
    Sleep    5s
    ssh.Disconnect    target
    ssh.Disconnect    middle

Stop And Collect IQ
    SSH.Connect To   ${GNB_ASIK.Ip}    ${GNB_ASIK.Username}    ${GNB_ASIK.Password}
    ...    alias=middle
    SSH.Connect To    ${ssh_iq_ip}    ${GNB_ASIK.Username}    ${GNB_ASIK.Password}    alias=target    proxy=middle
    SSH.Send Command    command=/usr/lib64/python/antenna_snapshot_config.py --pause    timeout=60    connection=target
    Sleep    10s
    SSH.Send Command    command=/usr/lib64/python/antenna_snapshot_config.py --collect    timeout=60    connection=target
    Sleep    20s
    ssh.execute    cd /tmp/mine;tar czvf newIQ.tgz AntennaSnapshotFiles/   connection=target
    sleep    60s
    ssh.Download File    /tmp/mine/newIQ.tgz    /home/ute/newIQ.tgz    connection=target
    Run    scp -r /home/ute/newIQ.tgz ${vm_logdir}/${execution_logs_path}
    ssh.Disconnect    target
    ssh.Disconnect    middle

Connect To Capture IQ Log
    SSH.Connect To   ${GNB_ASIK.Ip}    ${GNB_ASIK.Username}    ${GNB_ASIK.Password}
    ...    alias=middle
    ${grep_ipv6_cmd} =    Set Variable    ifconfig etha01.212 | grep inet6 | grep -i global | grep -oE '(\\w{1,4}\\:){7}(\\w{1,4})'
    SSH.Connect To    ${ssh_iq_ip}    ${GNB_ASIK.Username}    ${GNB_ASIK.Password}    proxy=middle    alias=target
    ${slave_ip}=    ssh.Execute    command=${grep_ipv6_cmd}    connection=target
    ${slave_ip}=    Strip String    ${slave_ip}
    Set Suite Variable    ${slave_ip}
    SSH.Connect To    ${GNB_ASIK.Ip}     ${GNB_ASIK.Username}    ${GNB_ASIK.Password}    alias=middle
    SSH.Force Reconnect    middle
    SSH.Connect To    ${slave_ip}    ${GNB_ASIK.Username}    ${GNB_ASIK.Password}
    ...    alias=target    proxy=middle

Conditional Logging Check for log Collection
    [Documentation]    Checking log collection
    Run Keyword If    '${SUITE STATUS}' == 'PASS' and '${CONDITIONAL_LOGGING}' == 'True'
    ...    Run Keyword and Ignore Error    Removing intermediate PET logs
    ...    ELSE    Run Keyword and Ignore Error    Common PET Teardown Log Collection

Common PET Teardown Log Collection
    Run Keyword If    '${SYSLOG}' == 'True'    Run Keyword and Ignore Error
    ...    Stop PET btslogger and collect syslogs
    Run Keyword and Ignore Error    Move Stats Logs
    Run Keyword If    '${AP_TOP_INTERFACE_STATS}' == 'True'
    ...    Run Keyword And Ignore Error    Collect and Download AP Top output
    Run Keyword If    '${WTS_WIRESHARK}' == 'True'
    ...    Run Keyword And Ignore Error    Stop WTS WireShark
    Run Keyword If    '${WTS_SCTP_STATS}' == 'True'
    ...    Run Keyword And Ignore Error    Stop and Collect WTS sctp Stats
    Run Keyword If    '${TCP_TRF_STATS}' == 'True'
    ...    Run Keyword And Ignore Error    Stop and Collect TCP traces log
    Run Keyword If    '${AP_SCTP_STATS}' == 'True'
    ...    Run Keyword And Ignore Error    Stop and Collect AP sctp Stats
    Run Keyword If    '${GNB_COUNT}' == '2'
    ...    Run Keyword And Ignore Error    gNB2 Snapshot Collection via adminAPI

Stop and Collect WTS Interface Stats and WTS VM Statistics
    Stop and Collect WTS Interface Stats
    Stop Collecting WTS VM Statistics

Removing intermediate PET logs
    Admin Cli Process Cleanup
    Run    killall EmTraceHistoryBufferStreamReceiver64
    Run    killall fsyslog
    Run    pkill -f top
    Run    pkill -f ./wts_interface_stats.sh
    Run    rm -rf ${vm_logdir}/em_perf_Stats/
    Run    rm -rf ${vm_logdir}/em_traces/
    Run    rm -rf ${vm_logdir}/IQ.tgz

Start AP Top output Collection
    SSH.Connect To    ${AP_ASIK.Ip}    ${AP_ASIK.Username}    ${AP_ASIK.Password}
    ...    alias=${AP_ASIK.Connection}
    SSH.Send Command    while [ 1 ]; do top -b |head -15 >>/user/toor4nsn/AP_top.txt; sleep 2; done &
    ...    connection=${AP_ASIK.Connection}
    ssh.Disconnect    ${AP_ASIK.Connection}

Collect and Download AP Top output
    Run    mkdir -p /home/ute/AP_TOP_STATS
    SSH.Connect To    ${AP_ASIK.Ip}    ${AP_ASIK.Username}    ${AP_ASIK.Password}
    ...    alias=${AP_ASIK.Connection}
    SSH.Send Command    pkill -f top
    ...    timeout=60    connection=${AP_ASIK.Connection}
    Download File    /user/toor4nsn/AP_top.txt    /home/ute/AP_TOP_STATS/AP_top.txt    ${AP_ASIK.Connection}
    Run    mv /home/ute/AP_TOP_STATS/AP_top.txt ${vm_logdir}/${execution_logs_path}/AP_top.txt
    Run    gzip ${vm_logdir}/${execution_logs_path}/AP_top.txt
    ssh.Disconnect    ${AP_ASIK.Connection}

Start WTS WireShark
    Run    mkdir -p /home/ute/logs/
    Run    chmod 777 /home/ute/logs/
    Start Process    sudo tcpdump -i any -p sctp -W 200 -C 200 -w /home/ute/logs/wts_wireshak.pcap    shell=yes

Stop WTS WireShark
    Run    sudo pkill tcpdump
    Run    sudo tar -czvf /home/ute/logs/WTS.pcapng.tar /home/ute/logs/wts_wireshak.pcap*
    Run    mv /home/ute/logs/WTS.pcapng.tar ${vm_logdir}/${execution_logs_path}
    Run    rm -rf /home/ute/logs/wts_wireshak.pcap*

Start wts sctp stats collection
    Run    cp ${WTS_SCTP_SCRIPT} ${EXECDIR}/
    Run    chmod 777 sctp_stats_wts.sh
    Start Process    ./sctp_stats_wts.sh    shell=yes

Stop and Collect WTS sctp Stats
    Run    pkill -f ./sctp_stats_wts.sh
    Run    mv ${EXECDIR}/sctp_assocs_wts.txt ${vm_logdir}/${execution_logs_path}
    Run    rm -rf ${EXECDIR}/sctp_assocs_wts.txt

Start AP sctp stats collection
    Run    cp ${AP_SCTP_SCRIPT} ${EXECDIR}/
    SSH.Connect To    ${AP_ASIK.Ip}    ${AP_ASIK.Username}    ${AP_ASIK.Password}
    ...    alias=${AP_ASIK.Connection}
    SSH.Upload File    ${EXECDIR}/sctp_stats_ap.sh    /user/toor4nsn/sctp_stats_ap.sh
    ...    ${AP_ASIK.Connection}
    SSH.Send Command
    ...    command=chmod +x /user/toor4nsn/sctp_stats_ap.sh
    ...               timeout=30    connection=${AP_ASIK.Connection}
    SSH.Send Command
    ...    command=sh /user/toor4nsn/sctp_stats_ap.sh
    ...               timeout=30    connection=${AP_ASIK.Connection}
    Sleep    2s
    SSH.Disconnect    ${AP_ASIK.Connection}

Start TCP Traces log collection
    [Documentation]    Start TCP trace logging by copying, enabling, and running the script for the given duration.
    Run    cp ${TCP_STATS_SCRIPT} ${EXECDIR}/
    Run    chmod 777 ${EXECDIR}/tcp_scripts.sh
    Start Process    ${EXECDIR}/tcp_scripts.sh ${TRF_DURATION}    shell=yes

Stop and Collect TCP traces log
    [Documentation]    Stop TCP trace logging, move logs to target directory, and clean up script.
    Run    pkill -f tcp_scripts.sh
    Run    mkdir ${vm_logdir}/${execution_logs_path}/TCP_STATS
    Run    mv /home/ute/logs/*.txt ${vm_logdir}/${execution_logs_path}/TCP_STATS
    Run    rm -rf ${EXECDIR}/tcp_scripts.sh

Stop and Collect AP sctp Stats
    SSH.Connect To    ${AP_ASIK.Ip}    ${AP_ASIK.Username}    ${AP_ASIK.Password}
    ...    alias=${AP_ASIK.Connection}
    Download File    /user/toor4nsn/sctp_assocs_ap.txt    ${vm_logdir}/${execution_logs_path}/sctp_assocs_ap.txt
    ...    ${AP_ASIK.Connection}
    SSH.Disconnect    ${AP_ASIK.Connection}

Check Space utilized by Rotta
    [Arguments]    ${action}
    ${res}=    Run    df -h /home/ute/logs/rotta | awk '{print $5}' | head -2 | tail -1
    Log To Console    ${action} umount: ${res}

Check Rotta Directory
    Check Space utilized by Rotta    Before
    Run    sudo umount /home/ute/logs/rotta
    Check Space utilized by Rotta    After

Move logs to Execution Directory
    FOR    ${log_file}    IN    @{EXECUTION_LOG}
        Run    mv ${vm_logdir}/${log_file} ${vm_logdir}/${execution_logs_path}
    END

Create Execution Logs Dir
    Run    mkdir ${vm_logdir}/${execution_logs_path}

Start PET syslog Service
    [Arguments]    ${host_ip}=127.0.0.1    ${user}=ute    ${password}=ute
    ${executor_test_vm}=  Create Dictionary
    ...  host=${host_ip}
    ...  user=${user}
    ...  password=${password}
    btslog.create_btslog_collector
    ...     name=${btslog_collector_name}
    ...     executor=${executor_test_vm}
    btslog.setup_collectors    names=${btslog_collector_name}
    btslog.start_collectors    names=${btslog_collector_name}
    btslog.set_suite_alias     ${btslog_collector_name}

Stop PET btslogger and collect syslogs
    [Arguments]    ${target_dir}=${vm_logdir}/${execution_logs_path}/
    btslog.stop_collectors         names=${btslog_collector_name}
    Add Timestamp and Zip syslog files
    btslog.collect_collectors      names=${btslog_collector_name}   target_dir=${target_dir}
    btslog.teardown_collectors     names=${btslog_collector_name}

Add Timestamp and Zip syslog files
    ${status_log2}=    Run Keyword And Return Status    File Should Exist    /tmp/btslog2/*.LOG
    ${status_log4}=    Run Keyword And Return Status    File Should Exist    /tmp/btslog4/*.LOG
    ${bts_init}=    Run Keyword If    '${status_log2}' == 'True'    Set Variable    ${btslog2_dir}
    ...    ELSE IF   '${status_log4}' == 'True'     Set Variable    ${btslog4_dir}
    ...    ELSE    Log To Console    No BTS logger started
    ${ini_file_status}=    Run Keyword And Return Status    File Should Exist    ${bts_init}/btslog.ini
    ${file}=    Run Keyword If    '${ini_file_status}' == 'True'    Set Variable    ${bts_init}/btslog.ini
    ...    ELSE    Log To Console    btslog.ini file not present
    ${file_format}=    Run    grep "SysLogFileTemplate" ${file} | grep -o '/.*/'
    Set Suite Variable    ${file_format}
    ${files}=    Run    ls ${file_format} | grep ".LOG"
    @{syslog_files}=    Split String    ${files}
    FOR    ${i}    IN    @{syslog_files}
         ${target_file}=    Catenate    ${file_format}${i}
         ${tim}=    Run    ls -tlr ${target_file} --time-style\="+%H:%M:%S"|awk '{print $6}'
         Run    zip -m ${target_file}"_"${tim}.zip ${target_file}
    END

Display WTS Summary
    [Documentation]    WTS summary script location :
    ...    testsuite/Bangalore/AirPhone/PET/scripts/WTS_Summary
    ...    KW expects the following arguments -u TLTYPE, yes or no [yes for UTE and no for non-UTE]
    ...    -c CALLTYPE, calltype sa or nsa
    Run    cp ${WTS_Summary_script} ${WTS_DIR}
    Run    pip3 install tabulate
    ${output}    Run    python3 ${WTS_DIR}/WTS_Summary -u ${TLTYPE} -c ${CALLTYPE} -p ${WTS_DIR}/egate_console.log
    Log To Console    ${output}

Collection of DU and CU Snapshots for vRAN
    Collect Snapshot from vDU vRAN
    Collect Snapshot from vCU vRAN

Collect Snapshot from vDU vRAN
    Create Directory          /home/ute/logs/vDU_Snapshot
    vDU.connect_to    host=${vdu_host}     port=${vran_port}    secure=True
    ...    username=${vdu_username}    password=${vdu_password}    secure=True
    vDU.get_local_snapshot    directory=/home/ute/logs/vDU_Snapshot
    Run    cd /home/ute/logs/vCU_Snapshot; tar -cvf vDU_Snapshot*.tar.gz vDU_Snapshot
    Log To Console                vDU Snapshot collected successfully...
    vDU.disconnect
    Run    mv /home/ute/logs/vDU_Snapshot ${vm_logdir}/${execution_logs_path}

Collect Snapshot from vCU vRAN
    coam_cu.connect_to    host=${vcu_host}    port=${vran_port}    username=${vdu_username}
    ...    password=${vdu_password}    secure=True
    Create Directory          /home/ute/logs/vCU_Snapshot
    coam_cu.get_local_snapshot    directory=/home/ute/logs/vCU_Snapshot
    Run                           cd /home/ute/logs/vCU_Snapshot; tar czf Snapshot_CU*.tgz*.*
    Log To Console                CU Snapshot Collected successfully...
    coam_cu.disconnect
    Run    mv /home/ute/logs/vCU_Snapshot ${vm_logdir}/${execution_logs_path}

Sos Report Collection for PET vRAN
    Run    cd /opt/wts/latest/sosReport_ASIL/; chmod 777 sosReport_ASIL.sh; ./sosReport_ASIL.sh -nr -c -s
    Wait Until Keyword Succeeds    30min    30s    File Should Exist    /opt/wts/latest/SosReport*.tgz
    Run    mv /opt/wts/latest/SosReport*.tgz ${vm_logdir}/

Get Counter XML Files for vRAN
    Get Counter XML Files for vRAN vDU
    Run    mv /home/ute/vdu_pm_counters ${vm_logdir}/${execution_logs_path}
    Get Counter XML Files for vRAN vCU
    Run    mv /home/ute/vcu_pm_counters ${vm_logdir}/${execution_logs_path}

Get Counter XML Files for vRAN vDU
    ${oam_vm}=  Create Dictionary    host=${vdu_host}    user=${vdu_username}    password=${vdu_password}
    gnb_pmcounters.create Coam VDU PM collector    name=vdu_pm_counters    webservice=${oam_vm}
    ...    for_last=${vran_counter_duration}
    gnb_pmcounters.setup_collectors    names=vdu_pm_counters
    gnb_pmcounters.collect_collectors    names=vdu_pm_counters    target_dir=/home/ute
    [Teardown]    gnb_pmcounters.teardown_collectors    names=vdu_pm_counters

Get Counter XML Files for vRAN vCU
    ${oam_vm}=  Create Dictionary    host=${vcu_host}    user=${vdu_username}    password=${vdu_password}
    gnb_pmcounters.create Coam VCU PM collector    name=vcu_pm_counters    webservice=${oam_vm}
    ...    for_last=${vran_counter_duration}
    gnb_pmcounters.setup_collectors    names=vcu_pm_counters
    gnb_pmcounters.collect_collectors    names=vcu_pm_counters    target_dir=/home/ute
    [Teardown]    gnb_pmcounters.teardown_collectors    names=vcu_pm_counters

Copy vRAN custom Configs to Exec logs
    Run    mv ${EXECDIR}/custom_configs/ ${vm_logdir}/${execution_logs_path}

Copy Existing BSR
    ${packages}=    Split String    ${BSR_TEST_DATA}    ,
    FOR    ${pkg}    IN    @{packages}
        ${path}=    Set Variable    tools/BSR_Package/${pkg}.zip
        Clone Entitytest Repo    ${path}
    END
    Run    cp ${EXECDIR}/tools/BSR_Package/BSR* ${vm_logdir}/config_files/

Enable Sosreport For Multi APs
    FOR    ${ap_index}    IN RANGE    2    ${AP_COUNT}+1    1
        Run Keyword If    '${ap_index}' == '2'
        ...    Run    sed -i 's/#${filter}_${ap_index}\\=${opt_iphy}*/${filter}_${ap_index}\\=${opt_latest}*/g' ${WTS_DIR}/sosReport.cfg
        ...    ELSE IF    '${ap_index}' > '2'
        ...    Run    sed -i 's/#${filter}_${ap_index}\\=${pre_opt_latest}*/${filter}_${ap_index}\\=${opt_latest}*/g' ${WTS_DIR}/sosReport.cfg
        Run    sed -i 's/#${fct_ip}_${ap_index}=${AP_IP}.${ap_index}/${fct_ip}_${ap_index}=${AP_IP}.${ap_index}/g' ${WTS_DIR}/sosReport.cfg
    END

Start Top Stats of All components
    Start AMF Top Stats of All components
    Start UPF Top Stats of All components
    Start UEC Top Stats of All components
    Start ENB Top Stats of All components
    Start EGATE Top Stats of All components
    Start All Top Stats of All components
    Start L3 Top Stats of All components

Start AMF Top Stats of All components
    Start Process    top -b -c -w 512 -d 2 -p $(pgrep -d, -f sim_amf) >> amf_top.txt    shell=yes

Start UPF Top Stats of All components
    Start Process    top -b -c -w 512 -d 2 -p $(pgrep -d, -f sim_upf) >> upf_top.txt    shell=yes

Start UEC Top Stats of All components
    Start Process    top -b -c -w 512 -d 2 -p $(pgrep -d, -f sim_uec) >> uec_top.txt    shell=yes

Start ENB Top Stats of All components
    Start Process    top -b -c -w 512 -d 2 -p $(pgrep -d, -f sim_enb) >> enb_top.txt    shell=yes

Start EGATE Top Stats of All components
    Start Process    top -b -c -w 512 -d 2 -p $(pgrep -d, -f egate) >> egate_top.txt    shell=yes

Start All Top Stats of All components
    Start Process    top -c -b -H -d 5 >> AP_all_top.txt    shell=yes

Start L3 Top Stats of All components
    Start Process    top -c -p $(pgrep -d',' -f l3) -b -H -d 2 >> AP_l3_top.txt    shell=yes

Move Stats Logs
    Run    sudo pkill top
    Run    mkdir ${vm_logdir}/${execution_logs_path}/TOP_STATS
    Run    mv ${EXECDIR}/*_top.txt ${vm_logdir}/${execution_logs_path}/TOP_STATS

Collect wts cores logs for PET
    Run    sudo mv /opt/wts/latest/core* ${vm_logdir}/${execution_logs_path}
    Run    sudo chown ute ${vm_logdir}/${execution_logs_path}/core*

gNB2 Snapshot Collection via adminAPI
    [Timeout]    25 minutes
    Log To Console    Collecting gNB Snapshot via admin API
    FOR    ${index}    IN RANGE    1    ${GNB_COUNT}+1    1
        ${timestamp}                  Get Current Date    result_format=%d.%m_%H-%M
        CoamAdmin.Connect To    bts_host=${gNB_IP_Prefix}.${index}
        CoamAdmin.Get Snapshot
        ...    target_file_name=${vm_logdir}/${execution_logs_path}/gNB_${index}/Snapshot_MRBTS-1_${timestamp}.zip
        ...                       timeout=20 mins
        File Should Exist         ${vm_logdir}/${execution_logs_path}/gNB_${index}/Snapshot_MRBTS-1_${timestamp}.zip
    END
    [Teardown]    CoamAdmin.Teardown

Collect gnb PM Counter Logs PET
    ${end_time}   Run Keyword And Ignore Error    Get Current DateTime
    ${duration}   Run Keyword And Ignore Error    Get Execution Duration
    ...    ${start_time[1]}    ${end_time[1]}
    FOR    ${id}    ${ip}    IN ZIP    ${GNB_COUNT_LIST}    ${gNB_IP_list}
        Run Keyword And Ignore Error    Collect Multi gNB PM Counter Logs    duration=${duration[1]}
        ...    target_dir=${EXECDIR}/logs/${execution_logs_path}/gNB_${id}    IP=${ip}
    END

Collect Multi gNB PM Counter Logs
    [Documentation]   Collect gNB PM Counters Data
    [Arguments]      ${name}=gnb_pm_counters   ${duration}=${EMPTY}    ${intervals}=${EMPTY}    ${target_dir}=${EXECDIR}/logs
    ...    ${IP}=${EMPTY}

    ${webservice}=  Create Dictionary    host=${ip}    user=${GNB_BTS.Username}    password=${GNB_BTS.Password}    port=${GNB_BTS.Port}
    Run Keyword If    '${duration}' and '${intervals}' == '${EMPTY}'
    ...     create PM collector   name=${name}    webservice=${webservice}   for_last=${duration}
    Run Keyword If    '${intervals}' and '${duration}'=='${EMPTY}'
    ...     create PM collector   name=${name}    webservice=${webservice}   intervals=${intervals}
    Run Keyword If    '${intervals}' != '${EMPTY}' and '${duration}' != '${EMPTY}'
    ...     create PM collector   name=gnb_pm_counters    webservice=${webservice}   for_last=${duration}    intervals=${intervals}
    Run Keyword If    '${duration}' == '${EMPTY}' and '${intervals}' == '${EMPTY}'
    ...     create PM collector   name=${name}    webservice=${webservice}
    gnb_pmcounters.setup_collectors    names=${name}
    gnb_pmcounters.collect_collectors    names=${name}    target_dir=${target_dir}
    gnb_pmcounters.teardown_collectors    names=${name}

Get Multi Coam SCF
    FOR    ${id}   IN RANGE    1    ${GNB_COUNT}+1    1
        Set Suite Variable    ${coamSCF}    ${vm_logdir}/gnb_coam_scf_${id}.xml
        ${path}_${id}                           ${file}    Split Path    ${coamSCF}
        CoamAdmin.Connect To    bts_host=${gNB_IP_list[${id}-1]}
        CoamAdmin.Get Current Scf File    ${path}    ${file}    timeout=300
        File Should Exist                 ${coamSCF}
    END
    [Teardown]    CoamAdmin.Teardown
