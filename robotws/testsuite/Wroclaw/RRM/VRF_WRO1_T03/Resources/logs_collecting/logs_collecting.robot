*** Settings ***
Documentation
...     Suite description

Library    BuiltIn
Library    taf.collectors.tcpdump  WITH NAME  tcpdump
Library    taf.collectors.l1l2bip       WITH NAME    l1l2bip
Library    taf.collectors.core    WITH NAME    core
Library    taf.collectors.btslog    WITH NAME   btslog
Library    taf.sw.syslog    WITH NAME    syslog
Resource    ../cm_operations/cm_operations.robot

*** Keywords ***
Collect BIP
    [Arguments]
    ...     ${alias}=L1L2_BIP_Logs
    ...     ${dir_path}=${OUTPUT_DIR}/${TEST_NAME}
    ...     ${phy_cell_id}=None

    Start collecting BIP logs    ${alias}    ${phy_cell_id}
    Sleep    1s
    Stop collecting BIP logs    ${alias}    ${dir_path}

Start collecting BIP logs
    [Documentation]     Collect L1L2 BIP Logs using gnbMirroring.sh script V61
    ...     Script repository: https://gitlabe2.ext.net.nokia.com/juhakang/tools/tree/master/gnbMirroring
    ...     -   :param alias:     Alias for l1l2bip which is also a directory name (default L1L2_BIP_Logs)
    ...     -   :param interface: Interface tcpdump (default any)
    ...     -   :param options:   Addtional options for tcpdump e.g. set bip filter (default empty)
    [Arguments]
    ...     ${alias}=L1L2_BIP_Logs
    ...     ${phy_cell_id}=51

    ${webservice}=  Create Dictionary
    ...    host=10.45.173.47
    ...    user=Nemuadmin
    ...    password=nemuuser
    ...    port=443
    l1l2bip.create_interface_mirroring_l1l2bip_collector
    ...  name=${alias}
    ...  webservice=${webservice}
    ...  nr_phy_cell_ids=${phy_cell_id}
    ...  timeout=300
    l1l2bip.Set suite alias  ${alias}
    core.setup_collectors    names=${alias}
    core.start_collectors    names=${alias}
    Log to console  BIP logs collecting started

Stop collecting BIP logs
    [Documentation]     Stop collecting BIP Logs and save them at selected location
    ...     -   :param alias:       Alias for l1l2bip which is also a directory name without spaces (default L1L2_BIP_Logs)
    ...     -   :param dir_path:    Path where BIP logs should be copied (default ${OUTPUT_DIR}/${TEST_NAME})
    ...     -   :param delay:       Time to wait before collecting the logs
    [Arguments]
    ...     ${alias}=L1L2_BIP_Logs
    ...     ${dir_path}=${OUTPUT_DIR}/${TEST_NAME}

    core.Stop Collectors  names=${alias}
    Run Keyword And Ignore Error    core.Collect Collectors  names=${alias}  target_dir=${dir_path}
    core.Teardown Collectors  names=${alias}

Activate TTI collecting
    [Arguments]     ${source_ip}=10.45.173.47  ${dscp}=15  ${destination_ip}=10.42.71.33  ${destination_port}=56789
    ...    ${timeout}=30  ${trace_type}=Component  ${up_sw}=L2Ps
    Log    --- Activate internal trace ---    console=True
    Activate Internal Trace
    Log    --- Start uplane l2 trace ---    console=True
    admin.Start Uplane L2 Trace
    ...  source_ip=${source_ip}
    ...  dscp=${dscp}
    ...  destination_ip=${destination_ip}
    ...  destination_port=${destination_port}
    ...  timeout=${timeout}
    ...  trace_type=${trace_type}
    ...  up_sw=${up_sw}
    Log    --- Uplane l2 trace started ---    console=True

Collect TTI
    [Arguments]    ${tcpdump_name}=tcpdump
    Log    --- Start collecting tti with name: ${tcpdump_name} ---    console=True
    Start Tti Collector    ${tcpdump_name}
    Sleep    5s    #Run Keyword If    '${tput_time}'!='forever'    Sleep    ${tput_time}    ELSE    Sleep    10s
    [Teardown]    Run Keywords    Stop Tti Collector    ${tcpdump_name}    AND
    ...    Log    --- Tti logs ${tcpdump_name} collected ---    console=True

Start Tti Collector
    [Arguments]    ${tcpdump_name}=tcpdump
    Log    --- Starting tti collector ---    console=True
    tcpdump.Create Tcpdump Collector
    ...  name=${tcpdump_name}
    ...  options=-i eth0 -v -n port 56789 -w /tmp/${tcpdump_name}.pcap
    core.Setup Collectors  names=${tcpdump_name}
    core.Start Collectors  names=${tcpdump_name}
    core.Set Suite Alias    ${tcpdump_name}
    Log    --- Tti collector started ---    console=True

Stop Tti Collector
    [Arguments]    ${tcpdump_name}=tcpdump
    Log    --- Stopping tti collector ---    console=True
    Run Keywords
    ...     core.Stop Collectors  names=${tcpdump_name}     AND
    ...     core.Collect Collectors  names=${tcpdump_name}  target_dir=/home/ute/test_tti/    AND
    ...     core.Teardown Collectors  names=${tcpdump_name}
    Log    --- Tti collector stopped ---    console=True

Deactivate Tti Collecting
    Log    --- Deactivate internal trace ---    console=True
    Deactivate Internal Trace
    Log    --- Stop uplane l2 trace ---    console=True
    admin.Stop Uplane L2 Trace  up_sw=L2Ps  trace_type=Component
    Log    --- Uplane l2 trace stopped ---    console=True

Remove Old Logs From Tmp
    [Arguments]    ${logs}
    Log    --- Removing old logs with name ${logs} ---    console=True
    Run    cd /tmp && sudo rm -f ${logs}.pcap
    Log    --- ${logs} logs removed ---    console=True

Rapid Check Status
    [Arguments]    ${parameter}    ${expected_value}    ${message}    ${tolerance}=None    ${log_name}=logs_name
    Remove Old Logs From Tmp    ${log_name}
    Collect TTI    ${log_name}
    ${sw}=  admin.get_sw_version
    ${cell_1}=    Create Dictionary    lcrId=1
    setup tti    input_file=/tmp/${log_name}.pcap    output_folder=${LOG_PATH}/
    ...    output_format=legacyCsv    sw_version=${sw}  message_filter=dlFdSchedData    alias=${log_name}
    Check Status  ${parameter}    ${expected_value}    ${message}    ${tolerance}  alias=${log_name}
    [Teardown]    delete_alias    ${log_name}

Rapid Average Tput Check
    [Arguments]    ${log_name}
    Remove Old Logs From Tmp    ${log_name}
    Collect TTI    ${log_name}
    ${sw}=  admin.get_sw_version
    ${cell_1}=    Create Dictionary    lcrId=1
    setup tti    input_file=/tmp/${log_name}.pcap    output_folder=${LOG_PATH}/
    ...    output_format=legacyCsv    sw_version=${sw}  message_filter=dlFdSchedData    alias=${log_name}
    Count Average Tput    group_by=${cell_1}    alias=${log_name}

#########################
### BTSLOG Collecting ###
#########################
Start Btslog On Local Machine
    [Arguments]   ${bts_logs_dir}=/tmp/btslog2    ${name}=btslog
    Log    --- Start btslog ---    console=True
    Run  if [ ! -d ${bts_logs_dir} ]; then mkdir ${bts_logs_dir}; else rm ${bts_logs_dir}/*; fi
    Log    --- Create btslog collector ---    console=True
    btslog.Create Btslog Collector
    ...    name=${name}
    ...    log_dir=${bts_logs_dir}
    Log    --- Setup btslog collectors ---    console=True
    core.Setup Collectors    names=${name}
    Log    --- Start collectors ---    console=True
    core.Start Collectors    names=${name}
    btslog.Set Suite Alias    ${name}
    Log    --- Btslog started ---    console=True

Collect Btslog
    [Arguments]    ${target_dir}=${OUTPUTDIR}  ${bts_logs_dir}=/tmp/btslog2  ${name}=btslog
    Log    --- Stopping and collecting btslog ---    console=True
    Run Keyword And Ignore Error    Stop And Collect Btslog On Local Machine    ${name}    ${target_dir}
    Run  rm ${bts_logs_dir}/*
    Log    --- Btslog stopped and collected ---    console=True

Stop And Collect Btslog On Local Machine
    [Arguments]   ${name}=btslog    ${target_dir}=${OUTPUTDIR}
    Log    --- Start stopping btslog collectors ---    console=True
    core.Stop Collectors         names=${name}
    Log    --- Collecting btslog ---    console=True
    core.Collect Collectors      names=${name}    target_dir=${target_dir}
    core.Teardown Collectors     names=${name}
    ${output}   Run  zcat ${target_dir}/*/*.tgz | head -1
    Log    --- Btslog stopped, logs collected: ${target_dir}-->${output} ---    console=True

Start Syslog
    [Arguments]    ${logs_path}
    Log    --- Start syslog ---    console=True
    syslog.Start Syslog    ${logs_path}    syslog_logs    ip=192.168.255.126    alias=syslog
    Log    --- Syslog started ---    console=True

Stop Syslog
    Log    --- Stop syslog ---    console=True
    syslog.Stop Syslog    syslog
    Log    --- Syslog stpped ---    console=True

Collect Snapshot
    [Arguments]    ${logs_path}=${False}
    ${logs_path}=    Run Keyword If    not ${logs_path}    Set Variable    ${OUTPUT_DIR}
    ...    ELSE    Set Variable    ${logs_path}
    Log    --- Start collect snapshot ---    console=True
    admin.Collect Snapshot  target_file_name=${logs_path}  timeout=1h   connection=default
    Log    --- Snapshot collected ---    console=True
