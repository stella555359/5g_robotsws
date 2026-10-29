*** Settings ***
Library     Collections
Library      OperatingSystem
Library         taf.collectors.pmcounters   WITH NAME  pmcounters
Library         taf.analyzer.pmcounter
Library         ${CURDIR}/../pm_analyze.py      WITH NAME	    pm_analyze

Resource        ${CURDIR}/configuration.robot
Resource        ${CURDIR}/gnbStatus.robot
Resource        ${CURDIR}/logs.robot

*** Keywords ***
Cell Setup

    [Arguments]         ${timeout}=25 min
    ##Wait to get ip connectivity to boards (to configure traces)
    # 2019-11-18
    # Eric VG & Denis
    # OAM session creation KW added
    configuration.Create Connections
    configuration.create SSH

    #run keyword if      '${add_ip_route}' == 'True'     configuration.Add Routes

    ##Wait for cell to be online - 10 min are required, X2 setup ay take timse
    run keyword if      '${oam_type}' == 'MZ'
    ...      wait until keyword succeeds    ${timeout}     30 sec      gnbStatus.Check carrier activation for cell setup
    run keyword if      '${oam_type}' == 'COAM'
    ...      wait until keyword succeeds    ${timeout}     30 sec      gnbStatus.Check Cell Availability Status V2

    ##Get CU/DU/RU logs
    #Get Full Logs


Cell Setup TCPDump
    [Arguments]    ${board_socid}=0
    ##Wait to get ip connectivity to boards (to configure traces)
    #Different place for CPRT depending on Architecture: asikFhCnx on CLOUD - asikSlaveCnx on CLASSICAL
    configuration.Create Connections
    configuration.create SSH

    ##Start SYSCOM and S1X2 traces
    log     ******* START SYSCOM AND S1X2 TRACES FOR CELL SETUP *******

    run keyword and continue on failure     logs.Start Syscom Traces   CellSetup_syscomAsik    ${board_socid}

    ##Wait for cell to be online - 10 min are required, X2 setup ay take timse
    run keyword if      '${oam_type}' == 'MZ'
    ...      wait until keyword succeeds    15 min     30 sec      gnbStatus.Check carrier activation for cell setup
    run keyword if      '${oam_type}' == 'COAM'
    ...      wait until keyword succeeds    15 min     30 sec      gnbStatus.Check Cell Availability Status V2
    sleep    15s
    ##Stop and collect SYSCOM and S1X2 traces
    log     ******* STOP SYSCOM AND S1X2 TRACES FOR CELL SETUP *******
    run keyword and continue on failure     logs.Stop Syscom Traces    ${board_socid}

    ##Get CU/DU/RU logs
    #run keyword and continue on failure     Get Full Logs

Cell Setup TCPDump Online
    [Arguments]    ${board_socid}=0
    [Documentation]    this keyword shall be used instead of Cell Setup TCPDump when connections are already created

    ##Start SYSCOM and S1X2 traces
    log     ******* START SYSCOM AND S1X2 TRACES FOR CELL SETUP *******

    run keyword and continue on failure     logs.Start Syscom Traces   CellSetup_syscomAsik    ${board_socid}

    ##Wait for cell to be online - 10 min are required, X2 setup ay take timse
    run keyword if      '${oam_type}' == 'MZ'
    ...      wait until keyword succeeds    15 min     30 sec      gnbStatus.Check carrier activation for cell setup
    run keyword if      '${oam_type}' == 'COAM'
    ...      wait until keyword succeeds    15 min     30 sec      gnbStatus.Check Cell Availability Status V2

    ##Stop and collect SYSCOM and S1X2 traces
    log     ******* STOP SYSCOM AND S1X2 TRACES FOR CELL SETUP *******
    run keyword and continue on failure     logs.Stop Syscom Traces    ${board_socid}


    ##Get CU/DU/RU logs
    run keyword and continue on failure     Get Full Logs

Check counter
    [Documentation]  This keyword collect last generated counter file, extract requested counter and check if matched condition is respected.
    ...       AUTHOR:  Denis Verdier

    [Arguments]    ${counter_id}    ${expected_value}   ${operator}===
    [Teardown]      teardown_collectors   names=pm_counters


    ${webservice}=  Create Dictionary       host=${oam_vm}
     ...    host=${tl.gnbs[0].cu.oam_http_connection_details.addr}
     ...    user=${tl.gnbs[0].cu.oam_http_connection_details.username}
     ...    password=${tl.gnbs[0].cu.oam_http_connection_details.password}
     ...    port=${tl.gnbs[0].cu.oam_http_connection_details.port}

    create PM collector
    ...    name=pm_counters
    ...    webservice=${webservice}
    ...    oam_type=${oam_type}

    setup_collectors
    ...    names=pm_counters

    collect_collectors     names=pm_counters    target_dir=${logs_path}

    ${cmd}=   set variable if    '${oam_type}'=='mzoam'     cd "${logs_path}/pm_counters";ls -dr1 *PM_*_SRAN |head -1
    ...       cd "${logs_path}/pm_counters";ls -dr1 *PM*.xml |head -1
    ${pm_filename}     Run     ${cmd}
    Run     mv ${logs_path}/pm_counters/${pm_filename} ${logs_path}
    Remove Files    ${logs_path}/pm_counters/*
    Remove Directory    ${logs_path}/pm_counters

   ${countervalue}=  pm_analyze.report latest PIvalue
              ...  pi_dir=${logs_path}
              ...  pi_name=${counter_id}
              ...  file_name=${pm_filename}
   log      Counter ${counter_id} : ${countervalue}${operator}${expected_value} ?

   should be true     ${countervalue}${operator}${expected_value}
