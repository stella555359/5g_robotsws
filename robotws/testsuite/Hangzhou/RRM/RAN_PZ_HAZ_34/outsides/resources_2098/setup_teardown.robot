*** Settings ***
Library    Collections
Library    OperatingSystem
Library    DateTime
Library    taf.analyzer.pdml
Library    taf.sbts.oam.coam.admin  WITH NAME  coam
Library    testsuite.Hangzhou.RRM.RAN_PZ_HAZ_34.outsides.resources_570.webui.WebuiInterface  WITH NAME  WebUI
Library    taf.converters.pcaptopdml   WITH NAME   pcaptopdml
Library    taf.collectors.tcpdump     WITH NAME    tcpdump
Library    taf.collectors.core        WITH NAME    core
Library    taf.analyzer.pdml          WITH NAME    pdml
Library    taf.collectors.btslog  WITH NAME   btslog
Library    taf.transport.ssh
Library    testsuite/Hangzhou/RRM/RAN_PZ_HAZ_34/outsides/resources_2098/common.py
Resource   testsuite/Hangzhou/RRM/RAN_PZ_HAZ_34/outsides/resources_2098/common_kw.robot
Resource   testsuite/Hangzhou/RRM/RAN_PZ_HAZ_34/outsides/resources_570/preconditions.robot
Resource   testsuite/Hangzhou/RRM/RAN_PZ_HAZ_34/outsides/resources_570/connections.robot
Resource   testsuite/Hangzhou/RRM/RAN_PZ_HAZ_34/outsides/resources_570/logs.robot
Resource   testsuite/Hangzhou/RRM/RAN_PZ_HAZ_34/outsides/resources_2098/testline_preparation/testline_preparation.robot

*** Variables ***
${DEFAULT_SCF_FILENAME}     ${OUTPUT DIR}/${SUITE NAME}/default_scf_file.xml
${IP_ADDR}        ${tl.gnbs[0].cu.oam_http_connection_details.addr}

*** Keywords ***
Prepare testline before test
    [Arguments]         ${required_config_type}=None
    Run keyword if      '${required_config_type}' == 'None'
    ...     Get and upload default SCF  ${required_config_type}
    ...     ELSE
    ...     Check config type and upload required SCF  ${required_config_type}
    Update sw on rmods if needed
    Verify if all cells are onair

Check config type and upload required SCF
    [Arguments]         ${required_config_type}=None
    ${current_type}  Check config type
    Run keyword if      '${required_config_type}' != '${current_type}'
    ...     Run keywords
    ...     Log to console  Current SCF (${current_type}) does not meet the required TL type (${required_config_type})
    ...     AND             Get and upload default SCF  ${required_config_type}
    ...  ELSE  Log to console  Current SCF (${current_type}) meets the TC's requirement

Get and upload default SCF
    [Arguments]         ${config_type}=None
    ${scf_path}  Get test line SCF path  ${config_type}
    Log to console  Getting a default SCF from path: '${scf_path}'
    Upload scf and perform commissioning  ${scf_path}

Set BTS and cell ids as suite variables
    Get BTS id and set as suite variable
    ${cell_dists}   Get cells distname list
    Set suite variable    ${cell_dists}

Start BTSlog
    [Arguments]         ${name}=btslog
    btslog.Create btslog collector
    ...                         name=${name}
    ...                         log_dir=/tmp/btslog2
    btslog.Setup collectors     names=${name}
    btslog.Start collectors     names=${name}
    btslog.Set suite alias      btslog

Stop BTSlog
    [Arguments]         ${name}=btslog
    btslog.Stop collectors      names=${name}
    Run Keyword And Ignore Error    btslog.Collect collectors   names=${name}
    btslog.Teardown collectors  names=${name}
    Remove tmp btslog dir

Download SCF
    [Arguments]  ${target_file}=${DEFAULT_SCF_FILENAME}
    Log to console      __Download SCF file from WebUI.
    ${content}          coam.Get current scf content
    Create file         path=${target_file}   content=${content}
    
Download SCF with connection
    [Arguments]  ${target_file}=${DEFAULT_SCF_FILENAME}
    Log to console      __Download SCF file from WebUI.
    coam.connect_to                    bts_host=${GN_OAM_ADDR}    name=coam_admin
    ${content}          coam.get_scf    connection=coam_admin
    Create file         path=${target_file}   content=${content}
    [Teardown]                         coam.teardown              connection=coam_admin    

Replace swconfig
    [Arguments]     ${feature}=5GC000000
    ...             ${swconfig_remote_path}=/rom/swconfig.txt
    ...             ${asik_connection}=asik
    ${swconfig_local_path}  Set variable  ${CURDIR}/${feature}/swconfig.txt
    Log to console      __Swap swconfig.txt on ASIB.
    OperatingSystem.File should exist    ${swconfig_local_path}
    ${flags}    Run    cat ${swconfig_local_path}
    Connect to asik     ${asik_connection}
    ${ssh_command}    Set variable    echo "${flags}" > ${swconfig_remote_path}
    ssh.Execute     command=${ssh_command}    connection=${asik_connection}
    coam.Connect to     bts_host=${IP_ADDR}
    coam.Reset Site
    Wait until keyword succeeds    20min    1min    Verify all cells are onair with admin
    [Teardown]   run keywords    Run Keyword And Ignore Error    coam.Teardown     AND
    ...          ssh.Disconnect  connection=${asik_connection}

Remove tmp btslog dir
    [Arguments]     ${path}=/tmp/btslog2
    Remove directory    ${path}    recursive=${True}

Enable eirp trace
    [Arguments]         ${local_path}=testsuite/Hangzhou/RRM/resources/set_feature_traces.sh
    ...                 ${remote_path}=/home/set_feature_traces.sh
    ...                 ${alias}=ASIK
    [Documentation]     Enable eirp trace using .sh file and reset site
    ...                 local_path     |    path to set_feature_traces.sh file
    ...                 remote_path    |    path to ASIK's home
    ...                 alias          |    connection type
    ssh.Connect_to      hostname=${tl.gnbs[0].cu.oam_ssh_connection_details.addr}
    ...                 username=${tl.gnbs[0].cu.oam_ssh_connection_details.username}
    ...                 password=${tl.gnbs[0].cu.oam_ssh_connection_details.password}
    ...                 alias=${alias}
    ssh.Upload_file     local_path=${local_path}    remote_path=${remote_path}    connection=${alias}
    ssh.Execute         chmod 755 ${remote_path}    connection=${alias}
    ${out}              ssh.Execute    ${remote_path}    connection=${alias}
    ${contains}         Evaluate   "level=DBG" in """${out}"""
    Run keyword if      ${contains}    Should contain    ${out}    L2.L2_PS.EIRP=1
    ...                 ELSE    Should contain    ${out}    Already Done
    Log to console      __Perform site reset to enable EIRP trace.
    coam.Connect_to     name=${alias}
    coam.Reset_site     connection=${alias}
    Verify if all cells are onair
    [Teardown]          Run keywords
    ...                 ssh.Disconnect     connection=${alias}    AND
    ...                 coam.Teardown      connection=${alias}

Recommission to default
    [Arguments]         ${alias}=coam_recommissioning
    Log to console      __Perform recommissioning to default state.
    coam.Connect to     bts_host=${IP_ADDR}     name=${alias}
    coam.Perform commissioning
    ...                 scf_file=${DEFAULT_SCF_FILENAME}
    ...                 skip_parameter_relation_errors=${TRUE}
    ...                 should_activate=${TRUE}
    ...                 timeout=600sec
    ...                 connection=${alias}
    OperatingSystem.Remove file         path=${DEFAULT_SCF_FILENAME}
    Verify if all cells are onair
    [Teardown]          coam.Teardown  connection=${alias}

Collect snapshot
    [Arguments]         ${alias}=coam
    ...                 ${snap_coverage}=Full
    ...                 ${force}=${TRUE}
    ...                 ${timeout_value}=600sec
    Log to console      __Collect snapshot.
    coam.Connect to     bts_host=${IP_ADDR}     name=${alias}
    ${software_info}    coam.Get software info  connection=${alias}
    ${sw_version}       Set variable  ${software_info['Active SW version']}
    ${timestamp}        DateTime.Get Current Date  result_format=%Y%m%d-%H%M%S
    ${snapshot_path}    Set variable  ${OUTPUT DIR}/${SUITE NAME}/${TEST NAME}/Snapshot_${sw_version}_${timestamp}.zip
    coam.Get snapshot   ${snapshot_path}
    ...                 ${snap_coverage}
    ...                 ${force}
    ...                 ${timeout_value}
    ...                 ${alias}
    [Teardown]          coam.Teardown  connection=${alias}

Suite cOAM Teradown
    Teardown cOAM session

Teardown cOAM session
    [Arguments]         ${alias}=default
    [Documentation]  Disconnects and destroy node.js daemon
    ...     alias:   AdminConnection object or if used, string name alias
    run keyword and ignore error        coam.teardown          connection=${alias}
