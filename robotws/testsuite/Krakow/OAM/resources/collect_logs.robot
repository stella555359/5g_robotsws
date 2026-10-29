# File copied from: testsuite/Krakow/RRM/RAN_PZ/resources

*** Settings ***
Library        taf.transport.ssh                    WITH NAME   ssh
Resource       connections.robot
Library        Collections
Resource       taf/rfrl/bts/robot/gnb.robot
Resource       taf/rfrl/bts/robot/common/gnb_cu.robot
Resource       taf/rfrl/bts/robot/common/gnb_log.robot
Resource       ./symptom_logcollection.robot

*** Variables ***
${log_index}
${gnbMirroring_filtering}=   off
${LOG_PATH}         ${OUTPUT DIR}

*** Keywords ***

Get Logs From CPIF
  [Documentation]
  ...  The purpose of this example is to present sending command by nested connection
  ...  (through OAM to CPIF in this case).
  ...  Alias assigned in the Connect to OAM keyword is then used to serve as a proxy.
  [Arguments]     ${hostname}=cpif-0.local  ${filename}=CPIF_journal.log   ${alias}=CPIF    ${proxy}=OAM
  connections.Connect to OAM      alias=${proxy}
  ssh.connect to      hostname=${hostname}
  ...                 username=${tl.gnbs[0].cu.oam_ssh_connection_details.username}
  ...                 password=${tl.gnbs[0].cu.oam_ssh_connection_details.password}
  ...                 alias=${alias}
  ...                 proxy=${proxy}
  ssh.execute    command=journalctl -b > ${filename}   connection=CPIF
  ssh.download_file    /home/robot/${filename}   ${LOG_PATH}/${filename}  connection=CPIF


Start tcpdump on CU
    [Arguments]   ${filename}=${test_name}.pcap   ${interface}=any    ${protocol}=sctp   ${sleep_after_start_s}=3
    ${alias}=    Connect to gNB
    Run Keyword If   '${BTS_TYPE}' == 'ClassicalBts'
    ...              ssh.send_command    command=tcpdump ${protocol} -i ${interface} -w "/tmp/${filename}"   connection=${alias}
    ...              ELSE
    ...              ssh.send_command    command=sudo tcpdump ${protocol} -i ${interface} -w "/tmp/${filename}"   connection=${alias}
    sleep   ${sleep_after_start_s} s


Stop tcpdump on CU and download logs
    [Arguments]     ${filename}=${test_name}.pcap
    sleep   3 s
    ${alias}=        Connect to gNB
    Run Keyword If   '${BTS_TYPE}' == 'ClassicalBts'
    ...              ssh.execute
    ...              command=killall tcpdump
    ...              connection=${alias}
    ...              ELSE
    ...              ssh.execute
    ...              command=sudo killall tcpdump
    ...              connection=${alias}
    ssh.execute      command=chmod 777 /tmp/${filename}
    ...              connection=${alias}
    Run Keyword If   '${BTS_TYPE}' == 'ClassicalBts'
    ...              ssh.download_file
    ...              /tmp/${filename}
    ...              ${LOG_PATH}/${filename}
    ...              connection=${alias}
    ...              ELSE
    ...              ssh.download_file
    ...              /tmp/${filename}
    ...              ${LOG_PATH}/${filename}
    ...              connection=${alias}
    Run Keyword If   '${BTS_TYPE}' == 'ClassicalBts'
    ...              ssh.execute
    ...              command=rm "/tmp/${filename}"
    ...              connection=${alias}
    ...              ELSE
    ...              ssh.execute
    ...              command=sudo rm "/tmp/${filename}"
    ...              connection=${alias}
    sleep   3 s


Setup mandatory logs
    [Arguments]    ${pcap}=false   ${btslog}=false
    Run Keyword If   '${BTS_TYPE}' == 'ClassicalBts'
    ...              Setup mandatory logs on ClassicalBts     pcap=${pcap}
    ...              ELSE
    ...              Setup mandatory logs on CloudBts      pcap=${pcap}
    Run Keyword If   '${btslog}' == 'true'
    ...              collect_logs.Setup btslog


Setup mandatory logs on ClassicalBts
    [Arguments]   ${pcap}=false
    Run Keyword If   '${pcap}' == 'true'
    ...              Create_Tcpdump_log_collector_ASIK       gnb_id=0     du_id=0     name=Asik_tcpdump    options=sctp -i any


Setup mandatory logs on CloudBts
    [Arguments]   ${pcap}=false
    Run Keyword If   '${pcap}' == 'true'
    ...              Create_Tcpdump_log_collector_VMs     gnb_id=0    name=cpif_tcpdump   options=sctp -i any    vm_name=cpif-0.local


Setup btslog
    Setup gNB Btslog Collector
    Start Collecting gNB BtsLog


Teardown mandatory logs
    [Arguments]   ${pcap}=false  ${btslog}=false
    Run Keyword If   '${BTS_TYPE}' == 'ClassicalBts'
    ...              Teardown mandatory logs on ClassicalBts     pcap=${pcap}  btslog=${btslog}
    ...              ELSE
    ...              Teardown mandatory logs on CloudBts     pcap=${pcap}  btslog=${btslog}
    Run Keyword If   '${btslog}' == 'true'
    ...              Teardown gNB Btslog Collector


Teardown mandatory logs on ClassicalBts
    [Arguments]   ${pcap}=false  ${btslog}=false
    Run Keyword If   '${pcap}' == 'true'
    ...             Stop_log_collection     names=Asik_tcpdump
    Run Keyword If Test Failed       Collect mandatory logs on ClassicalBts     pcap=${pcap}  btslog=${btslog}


Teardown mandatory logs on CloudBts
    [Arguments]   ${pcap}=false  ${btslog}=false
    Run Keyword If   '${pcap}' == 'true'
    ...             Stop_log_collection    names=cpif_tcpdump
    Run Keyword If Test Failed       Collect mandatory logs on CloudBts     pcap=${pcap}  btslog=${btslog}


Collect mandatory logs on ClassicalBts
    [Arguments]         ${log_dir}=${OUTPUT DIR}  ${pcap}=false  ${btslog}=false
    Run Keyword If   '${pcap}' == 'true'
    ...                 Collect_logs      names=Asik_tcpdump
    Run Keyword If   '${btslog}' == 'true'
    ...                 Stop Collecting gNB BtsLog
    Collect Snapshot From gNB             log_dir=${log_dir}


Collect mandatory logs on CloudBts
    [Arguments]         ${log_dir}=${OUTPUT DIR}  ${pcap}=false  ${btslog}=false
    Run Keyword If   '${pcap}' == 'true'
    ...                 Collect_logs      names=cpif_tcpdump
    Run Keyword If   '${btslog}' == 'true'
    ...                 Stop Collecting gNB BtsLog
    Collect Snapshot From gNB             log_dir=${log_dir}
    gnb_cu.Download snapshot from CU             path=${log_dir}

