# Please do not edit the existing keywords in this file without testing.
# for test case examples please refer to the below confluence page.
# https://confluence.int.net.nokia.com/display/CV/Collectors+Example

#list of available keywords in core.
#https://docs.taf.nsn-rdnet.net/taf.collectors.core/2.0.10/1/robot.collector_keywords/

*** Settings ***
Documentation    This file is used for checking PMcounters
Library    OperatingSystem
Library    Collections
Library    taf.collectors.core          WITH NAME    core
Library    taf.collectors.tcpdump       WITH NAME    tcpdump
Library    taf.collectors.tshark        WITH NAME    tshark
Library    taf.collectors.journal       WITH NAME    journal
Library    taf.collectors.btslog        WITH NAME    btslog
Library    taf.collectors.pmcounters    WITH NAME    pmcounters
Library    taf.collectors.snapshot      WITH NAME    snapshot

*** Variables ***
${yaml_file}       ${CURDIR}
#${yaml_file}      ${CURDIR}/Cloud_gNB.yaml

*** Keywords ***
Create_Btslog_log_collection_on_remote_machine
    [Arguments]    ${name}=btslog    ${btslog_path}=/opt/btslog/btslog
    ...             ${btslog_launcher_path}=/opt/btslog/btslog_launcher          ${log_dir}=/tmp/
    ...             ${host}=${tl.test_pc.default_ssh_connection_details.addr}    ${start_timeout}=${10}
    [Documentation]    create btslog log collector on testvm.
    ...                name: name of the collector. Ex: btslog
    ...                btslog_path: (optional) path of the ‘btslog’ executable default value:”/opt/btslog/btslog”
    ...                btslog_launcher_path: (optional) path of ‘btslog_launcher’
    ...                executable default value:”/opt/btslog/btslog_launcher”
    ...                log_dir: path from where to get btslog files default value: “/tmp/btslog2”
    &{executor}=    create dictionary    host=${host}
    ...                                  user=${tl.test_pc.default_ssh_connection_details.username}
    ...                                  password=${tl.test_pc.default_ssh_connection_details.password}
    btslog.create_btslog_collector       name=${name}          btslog_path=${btslog_path}
    ...                                  btslog_launcher_path=${btslog_launcher_path}
    ...                                  executor=${executor}    log_dir=${log_dir}
    ...                                  start_timeout=${start_timeout}
    btslog.Set Suite Alias               ${name}
    core.setup_collectors                names=${name}
    core.start_collectors                names=${name}

Collect coam snapshot
    [Arguments]        ${gnb_id}=0    ${name}=gnb_coam_snapshot     ${coverage}=Full    ${force}=0     ${timeout}=480
    [Documentation]    Collects the snapshot files to the default path.
    ...                gnb_id: gnb_id default value:0
    ...                name: name of the collector. Ex: gnb_coam_snapshot
    &{webservice}=    create dictionary    host=${tl.gnbs[${gnb_id}].cu.oam_http_connection_details.addr}
    ...                                    user=${tl.gnbs[${gnb_id}].cu.oam_http_connection_details.username}
    ...                                    password=${tl.gnbs[${gnb_id}].cu.oam_http_connection_details.password}
    ...                                    port=${tl.gnbs[${gnb_id}].cu.oam_http_connection_details.port}
    create_sbts_snapshot_collector         name=${name}     webservice=${webservice}   coverage=${coverage}
    ...                                    force=${force}   timeout=${timeout}
    core.setup_collectors                       names=${name}
    core.collect_collectors                     names=${name}
    core.teardown_collectors                    names=${name}

Collect_logs
    [Documentation]      keyword is used to collect the log files to default path and close the all the connections at the end.
    [Arguments]                 ${names}
    ${log_file}=                core.collect_collectors   names=${names}
	core.teardown_collectors    names=${names}
    [Return]                    ${log_file}
    [Teardown]   core.teardown_collectors    names=${names}
