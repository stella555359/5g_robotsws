# Author: Rashmi R
# Please do not edit the existing keywords in this file without testing.
# for test case examples please refer to the below confluence page.
# https://confluence.int.net.nokia.com/display/CV/Collectors+Example

#list of available keywords in core.
#https://docs.taf.nsn-rdnet.net/taf.collectors.core/2.0.10/1/robot.collector_keywords/

*** Settings ***
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
${yaml_file}      ${CURDIR}/Cloud_gNB.yaml

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

Create_Btslog_log_collection_on_testvm
    [Arguments]      ${name}=btslog     ${btslog_path}=/opt/btslog/btslog
    ...           ${btslog_launcher_path}=/opt/btslog/btslog_launcher     ${log_dir}=/tmp/btslog2
    [Documentation]    create btslog log collector on testvm.
    ...                name: name of the collector. Ex: btslog
    ...                btslog_path: (optional) path of the ‘btslog’ executable default value:”/opt/btslog/btslog”
    ...                btslog_launcher_path: (optional) path of ‘btslog_launcher’
    ...                executable default value:”/opt/btslog/btslog_launcher”
    ...                log_dir: path from where to get btslog files default value: “/tmp/btslog2”
    btslog.create_btslog_collector    name=${name}    btslog_path=${btslog_path}
    ...                               btslog_launcher_path=${btslog_launcher_path}
    ...                               executor=${executor_test_vm}      log_dir=${log_dir}
    btslog.Set Suite Alias     ${name}

Create_PM_counters_collector
    [Arguments]      ${gnb_id}=0    ${name}=gnb_pm_counters
    [Documentation]    Collects the pm counters files to the default path.
    ...                gnb_id: gnb_id default value:0
    ...                name: name of the collector. Ex: gnb_pm_counters
    &{webservice}=    create dictionary       host=${tl.gnbs[${gnb_id}].cu.oam_http_connection_details.addr}
    ...                                       user=${tl.gnbs[${gnb_id}].cu.oam_http_connection_details.username}
    ...                                       password=${tl.gnbs[${gnb_id}].cu.oam_http_connection_details.password}
    ...                                       port=${tl.gnbs[${gnb_id}].cu.oam_http_connection_details.port}
    create PM collector   name=${name}    webservice=${webservice}

Create_collectors_via_YAML
    [Arguments]        ${yaml_file}=${yaml_file}     ${names}=gnb_oam_tcpdump
    [Documentation]    create tcpdump log collection via YAML on specified VM.
    ...                names: name of the collector. Ex: gnb_pm_counters
    ${configurations}=        core.Load Configurations         ${yaml_file}
    core.Create Collectors    names=${names}                   configurations=${configurations['collectors']}
    core.Set Suite Alias      ${names}

Collect_coam_snapshot
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

########################Journal##################################

Create_Journal_log_collector_OAM
    [Arguments]         ${name}=oamJournal    ${gnb_id}=0    ${options}=-o json
    [Documentation]     create journal log collector on OAM.
    ...                 name: name of the collector. Ex: journal
    ...                 gnb_id: gnb_id default value:0
    ...                 options: (optional) “-o json” is its default value.
    &{executor_oam_vm}=    create dictionary    host=${tl.gnbs[${gnb_id}].cu.oam_ssh_connection_details.addr}
    ...                                         user=${tl.gnbs[${gnb_id}].cu.oam_ssh_connection_details.username}
    ...                                         password=${tl.gnbs[${gnb_id}].cu.oam_ssh_connection_details.password}
    journal.create_journal_collector            name=${name}    options=${options}     executor=${executor_oam_vm}
    journal.Set Suite Alias                     ${name}
    core.setup_collectors                       names=${name}
    core.start_collectors                       names=${name}

Create_Journal_log_collection_on_testvm
    [Arguments]            ${name}=Journal    ${options}=-o json    ${sudo_password}=None
    [Documentation]        create journal log collector on local testvm.
    ...                    name: name of the collector. Ex: journal
    ...                    options: (optional) “-o json” is its default value
    ...                    sudo_password:     password for sudo
    journal.create_journal_collector    name=${name}    options=${options}    sudo_password=${sudo_password}
    journal.Set Suite Alias             ${name}
    core.setup_collectors               names=${name}
    core.start_collectors               names=${name}

Create_Journal_log_collector_VMs
    [Arguments]        ${gnb_id}=0   ${name}=cpif_journal    ${vm_name}=cpif-0.local    ${options}=-o json
    [Documentation]    create journal log collection on specified VM's.
    ...                name: name of the collector. Ex: cpif_journal
    ...                gnb_id: gnb_id default value:0
    ...                vm_name: vm host name
    ...                options: (optional) “-o json” is its default value.
    &{oam_config}=   create dictionary     host=${tl.gnbs[${gnb_id}].cu.oam_ssh_connection_details.addr}
    ...                                    user=${tl.gnbs[${gnb_id}].cu.oam_ssh_connection_details.username}
    ...                                    password=${tl.gnbs[${gnb_id}].cu.oam_ssh_connection_details.password}
    &{vm_config}=  create dictionary       host=${vm_name}
    ...                                    user=${tl.gnbs[${gnb_id}].cu.oam_ssh_connection_details.username}
    ...                                    password=${tl.gnbs[${gnb_id}].cu.oam_ssh_connection_details.password}
    ...                                    proxy=${oam_config}
    journal.create_journal_collector       name=${name}      options=${options}      executor=${vm_config}
    journal.Set Suite Alias                ${name}
    core.setup_collectors                  names=${name}
    core.start_collectors                  names=${name}

Create_Journal_log_collector_ASIK
    [Arguments]     ${gnb_id}=0   ${name}=asik_journal   ${options}=-o json    ${du_id}=0
    [Documentation]     create journal log collection on ASIK VM.
    ...                 name: name of the collector. Ex: asik_journal
    ...                 gnb_id: gnb_id default value:0
    ...                 options: (optional) “-o json” is its default value.
    &{ASIK}=     create dictionary    host=${tl.gnbs[${gnb_id}].dus[${du_id}].airscale.common_units[${du_id}].lmp_connection.addr}
    ...          user=${tl.gnbs[${gnb_id}].dus[${du_id}].airscale.common_units[${du_id}].lmp_connection.username}
    ...          password=${tl.gnbs[${gnb_id}].dus[${du_id}].airscale.common_units[${du_id}].lmp_connection.password}
    journal.create_journal_collector    name=${name}    options=${options}    executor=${ASIK}
    journal.Set Suite Alias             ${name}
    core.setup_collectors               names=${name}
    core.start_collectors               names=${name}

Create_journal_log_collection_on_capacity_module
    [Arguments]        ${fspa_addr}=fsp-1-1a     ${gnb_id}=0    ${du_id}=0     ${cu_id}=0    ${name}=fspa_journal
    ...    ${options}=-o json
    [Documentation]     create journal log collection in fsp-1-1a/fsp-1-1b/fsp-1-1c
    ...     fspa_addr: fspa address
    ...     gnb_id: gnb_id default value:0
    ...     du_id: gnb_id default value:0
    ...     cu_id: gnb_id default value:0
    ...     name: name of the collector. Ex: fspa_journal
    ...     options: (optional) “-o json” is its default value.
    &{ASIK}=     create dictionary    host=${tl.gnbs[${gnb_id}].dus[${du_id}].airscale.common_units[${du_id}].lmp_connection.addr}
    ...          user=${tl.gnbs[${gnb_id}].dus[${du_id}].airscale.common_units[${du_id}].lmp_connection.username}
    ...          password=${tl.gnbs[${gnb_id}].dus[${du_id}].airscale.common_units[${du_id}].lmp_connection.password}
    &{fsp_1_1a}=       create dictionary           host=${fspa_addr}
    ...            user=${tl.gnbs[${gnb_id}].dus[${du_id}].airscale.common_units[${cu_id}].lmp_connection.username}
    ...            password=${tl.gnbs[${gnb_id}].dus[${du_id}].airscale.common_units[${cu_id}].lmp_connection.password}
    ...            proxy=${ASIK}
    journal.create_journal_collector     name=${name}    options=${options}    executor=${fsp_1_1a}
    journal.Set Suite Alias              ${name}
    core.setup_collectors                names=${name}
    core.start_collectors                names=${name}

########################Journal##################################

########################Tcpdump##################################
Create_Tcpdump_log_collector_OAM
    [Arguments]      ${gnb_id}=0     ${name}=oamTcpdump    ${options}=-i internal
    [Documentation]     create tcpdump log collector on OAM.
    ...                 gnb_id: gnb_id default value:0
    ...                 name: name of the collector. Ex: oamTcpdump
    ...                 options: (optional) tcpdump options (except for “-w”), default: empty string
    &{executor_oam_vm}=    create dictionary     host=${tl.gnbs[${gnb_id}].cu.oam_ssh_connection_details.addr}
    ...                                          user=${tl.gnbs[${gnb_id}].cu.oam_ssh_connection_details.username}
    ...                                          password=${tl.gnbs[${gnb_id}].cu.oam_ssh_connection_details.password}
    tcpdump.create_tcpdump_collector     name=${name}     options=${options}     executor=${executor_oam_vm}
    tcpdump.Set Suite Alias              ${name}
    core.setup_collectors                names=${name}
    core.start_collectors                names=${name}

Create_Tcpdump_collector_on_test_vm
    [Arguments]        ${name}=testVM_Tcpdump   ${options}=-i eth0   ${sudo_password}=None
    [Documentation]    create tcpdump log collector on local testvm.
    ...                name: name of the collector. Ex: oamTcpdump
    ...                options: (optional) tcpdump options (except for “-w”), default: empty string
    ...                sudo_password: password for sudo
    tcpdump.create_tcpdump_collector     name=${name}    options=${options}    sudo_password=${sudo_password}
    tcpdump.Set Suite Alias              ${name}
    core.setup_collectors                names=${name}
    core.start_collectors                names=${name}

Stop_log_collection
    [Documentation]           stop log collection on all VM's
    [Arguments]               ${names}
    core.stop_collectors      names=${names}

Collect_logs
    [Documentation]      keyword is used to collect the log files to default path and close the all the connections at the end.
    [Arguments]                 ${names}
    ${log_file}=                core.collect_collectors   names=${names}
	core.teardown_collectors    names=${names}
    [Return]                    ${log_file}

Create_Tcpdump_log_collector_VMs
    [Arguments]      ${gnb_id}=0    ${name}=cpif_tcpdump    ${options}=-i internal    ${vm_name}=cpif-0.local
    [Documentation]    create journal log collection on specified VM's
    ...                gnb_id: gnb_id default value:0
    ...                name: name of the collector. Ex: cpif_tcpdump
    ...                options: (optional) tcpdump options (except for “-w”), default: empty string
    ...                vm_name: vm host name
    &{oam_config}=   create dictionary     host=${tl.gnbs[${gnb_id}].cu.oam_ssh_connection_details.addr}
    ...                                    user=${tl.gnbs[${gnb_id}].cu.oam_ssh_connection_details.username}
    ...                                    password=${tl.gnbs[${gnb_id}].cu.oam_ssh_connection_details.password}
    &{vm_config}=    create dictionary     host=${vm_name}
    ...                                    user=${tl.gnbs[${gnb_id}].cu.oam_ssh_connection_details.username}
    ...                                    password=${tl.gnbs[${gnb_id}].cu.oam_ssh_connection_details.password}
    ...                                    proxy=${oam_config}
    tcpdump.create_tcpdump_collector       name=${name}   options=${options}   executor=${vm_config}
    tcpdump.Set Suite Alias                ${name}
    core.setup_collectors                  names=${name}
    core.start_collectors                  names=${name}

Create_Tcpdump_log_collector_ASIK
    [Arguments]         ${gnb_id}=0       ${du_id}=0    ${name}=Asik_tcpdump    ${options}=-i internal
    [Documentation]     create tcpdump log collection on ASIK VM.
    ...                 gnb_id: gnb_id default value:0
    ...                 name: name of the collector. Ex: Asik_tcpdump
    ...                 options: (optional) tcpdump options (except for “-w”), default: empty string
    &{ASIK}=     create dictionary    host=${tl.gnbs[${gnb_id}].dus[${du_id}].airscale.common_units[${du_id}].lmp_connection.addr}
    ...          user=${tl.gnbs[${gnb_id}].dus[${du_id}].airscale.common_units[${du_id}].lmp_connection.username}
    ...          password=${tl.gnbs[${gnb_id}].dus[${du_id}].airscale.common_units[${du_id}].lmp_connection.password}
    tcpdump.create_tcpdump_collector    name=${name}   options=${options}   executor=${ASIK}
    tcpdump.Set Suite Alias             ${name}
    core.setup_collectors               names=${name}
    core.start_collectors               names=${name}

########################Tcpdump##################################
########################Tshark##################################

Create_Tsharklog_collection_on_testvm
    [Arguments]               ${name}=oamTshark    ${options}=-i internal    ${sudo_password}=None
    [Documentation]    create tshark log collector on local testvm.
    ...     name: name of the collector. Ex: oamTshark
    ...     options: (optional) Path of tshark path executable, default value is “tshark”
    ...              To collect prisma logs value is “prisma”
    ...     sudo_password: password for sudo
    tshark.create_tshark_collector      name=${name}    options=${options}    sudo_password=${sudo_password}
    tshark.Set Suite Alias              ${name}
    core.setup_collectors               names=${name}
    core.start_collectors               names=${name}

########################Tshark##################################
