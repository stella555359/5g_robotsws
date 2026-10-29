*** Settings ***

Documentation
...   author: Rubina Nath
...   contact: rubina.nath@nokia.com
...   Description: Test Suite
...   "Test Case coverage in Documentation section for each case respectively"

Library     SSHLibrary
Library     BuiltIn
Library     String
Library     DateTime
Library     Collections
Library     OperatingSystem     WITH NAME    os
Library     taf.nms.netact    WITH NAME    netact
Library     taf.sbts.oam.coam.admin    WITH NAME    admin
Library     taf.collectors.core   WITH NAME   core
Library     taf.collectors.btslog  WITH NAME   btslog
Suite Setup		   		Suite_Setup
Test Setup	       	    Test Setup
Test Teardown           Test_Teardown
Suite Teardown		    Suite Teardown

*** Variables ***

${BTS_ADDRESS} =           192.168.255.129
${BTS_path}=               /home/ute/logs
${btsid}=                  1757
@{ListofFaults}=
@{list_of_expFaults}=      4655    4654    61649    61524
${predef_moc}=             MRBTS-${btsid}/EQM-1/APEQM-1/RMOD-1
${predef_param}=           predefined
${autoinstall_moc}=        MRBTS-${btsid}/MNL-1
${autoins_param}=          autoInstallOfPredefinedRu
${tsn_port_details}=            1/4/C17
${tsn_login_IP}=                10.53.188.169
${tsn_login_name}=              cli
${tsn_username}=                admin
${tsn_password}=                Admin@1830
${actualserialnum}=             00436
${falseserialnum}=              00437
${value_true}=     true
${connection}=     default

*** Test Cases ***

TestForPredefinedRadioWithOMoperations
    [Documentation]    Test Predefine RU Configuration after FH break-make scenario and throughput check on all cells
    [Tags]    test2

    Perform Parameter Recommissioning     ${predef_moc}    ${predef_param}    true
    Perform Parameter Recommissioning     ${autoinstall_moc}    ${autoins_param}    false
    Wait until Keyword succeeds    10m    20s    CheckOperationalStateOfRadios    enabled
    Perform Parameter Recommissioning     ${predef_moc}    serialNumberPlanned    ${falseserialnum}
    ${ListofFaultsAtBTS}=    Check_FID
    List Should Contain Value    ${ListofFaultsAtBTS}    4282
    Perform Parameter Recommissioning     ${predef_moc}    serialNumberPlanned    ${actualserialnum}
    ${ListofFaultsAtBTS}=    Check_FID
    List Should Not Contain Value    @{ListofFaultsAtBTS}    4282
    Wait until Keyword succeeds    10m    20s    CheckOperationalStateOfRadios    enabled
    Simulation_FID10_via_TSNswitch    down
    ${ListofFaultsAtBTS}=    Check_FID
    List Should Not Contain Value    @{ListofFaultsAtBTS}    10
    admin.reset_site    wait_for_reconnection=${value_true}    connection=${connection}    timeout=600
    ${ListofFaultsAtBTS}=    Check_FID
    List Should Not Contain Value    ${ListofFaultsAtBTS}    10
    Simulation_FID10_via_TSNswitch    up
    Wait until Keyword succeeds    10m    20s    CheckOperationalStateOfRadios    enabled
    ${ListofFaultsAtBTS}=    Check_FID
    List Should Not Contain Value    ${ListofFaultsAtBTS}    10
    Perform Parameter Recommissioning    ${autoinstall_moc}    ${autoins_param}    true
    Wait until Keyword succeeds    10m    20s    CheckOperationalStateOfRadios    enabled
    Simulation_FID10_via_TSNswitch    down
    ${ListofFaultsAtBTS}=    Check_FID
    List Should Contain Value    ${ListofFaultsAtBTS}    10
    Simulation_FID10_via_TSNswitch    up
    ${ListofFaultsAtBTS}=    Check_FID
    List Should Not Contain Value    ${ListofFaultsAtBTS}    10
    Simulation_FID10_via_TSNswitch    down
    Perform Parameter Recommissioning    ${predef_moc}    ${predef_param}    true
    Perform Parameter Recommissioning    ${autoinstall_moc}    ${autoins_param}    true
    Wait until Keyword succeeds    10m    20s    CheckOperationalStateOfRadios    enabled
    Simulation_FID10_via_TSNswitch    up
    ${ListofFaultsAtBTS}=    Check_FID
    List Should Not Contain Value    ${ListofFaultsAtBTS}    10
    Check_BTS_State
    Wait until Keyword succeeds    10m    20s    CheckOperationalStateOfRadios    enabled
    #Checkcalls
    Check ActiveFaultandAlarmID

*** Keywords ***

Check_FID
    ${alr}=     admin.get_active_alarms
    ${alr_num}=     admin.get_active_alarms_number
    FOR    ${i}    IN RANGE   ${alr_num}
        ${fltstring}=    Convert To String    ${alr}[${i}][faultId]
        Append To List    ${ListofFaults}    ${fltstring}
    END
    RETURN    ${ListofFaults}

CheckOperationalStateOfRadios
    [Arguments]    ${StateofRadio}
    ${listofradios}=    admin.get_radio_list    timeout=60    detailed_output=False    connection=${connection}
    ${a}=     Get Length    ${listofradios}[radioModules][rmod]
    FOR    ${i}    IN RANGE    ${a}
        Should Contain Any
        ...    ${listofradios}[radioModules][rmod][${i}][status][operationalState]    ${StateofRadio}    ignore_case=${TRUE}
    END

Simulation_FID10_via_TSNswitch
    [Arguments]    ${StateOfPort}
    SSHLibrary.Open Connection    host=${tsn_login_IP}
    SSHLibrary.Login    ${tsn_login_name}   delay=2
    SSHLibrary.Write    ${tsn_username}
    SSHLibrary.read     delay=2s
    SSHLibrary.Write    ${tsn_password}
    SSHLibrary.read     delay=2s
    SSHLibrary.Write    Y
    SSHLibrary.read     delay=2s
    SSHLibrary.Write    config interface t24ps2 ${tsn_port_details} state ${StateOfPort}
    SSHLibrary.read     delay=2s
    SSHLibrary.Close All Connections

Test Setup
    Log to console  \n--Start test--\n
    admin.setup_admin    bts_host=${BTS_ADDRESS}
    os.run    chmod 777 ${BTS_path}/${SUITE NAME}/${Date}/${TEST_NAME}
    Start BTS logs

Test Teardown
    Log to console  --End test--\n
    Get ActiveAlarms
    Collect Snapshot    snaptarget_file_name=${BTS_path}/${SUITE NAME}/${Date}/PostTestLogs/Snapshot.zip
    admin.collect_im_snapshot        ${BTS_path}/${SUITE NAME}/${Date}/${TEST_NAME}/PostTestLogs/imSnapshot.ims2
    Stop BTS logs
    #Make sure TSN does not affect other cases, teardown with mandatory steps#
    Simulation_FID10_via_TSNswitch    up
    Perform Parameter Recommissioning     ${autoinstall_moc}    ${autoins_param}    true
    Perform Parameter Recommissioning     ${predef_moc}    serialNumberPlanned    ${actualserialnum}
    admin.reset_site    wait_for_reconnection=${value_true}    connection=${connection}    timeout=600
    Wait until Keyword succeeds    10m    20s    Check_BTS_State
    admin.teardown_all_aliases_for_admin
    SSHLibrary.Close All Connections

Suite Setup
    log    "Test Started"
    ${CurrentDate}=    Get Current Date    result_format=%d_%m_%Y_%H%M
    ${CurrentDate}=    Convert to String     ${CurrentDate}
    os.Create Directory    ${BTS_path}/${SUITE NAME}/${CurrentDate}/SoftwareUpdateLogs
    Set global variable    ${Date}    ${CurrentDate}

Suite Teardown
	log    "Test END"

Start BTS logs
    [Documentation]     Starts BTS logs
    Run     killall btslog
    btslog.create_btslog_collector    name=btslog
    core.setup_collectors    names=btslog
    core.set_suite_alias    btslog
    core.start_collectors    names=btslog

Stop BTS logs
    [Arguments]    ${btslog_target_dir}=${BTS_path}/${SUITE NAME}/${Date}/${TEST_NAME}
    [Documentation]     Stops BTS logs
    core.stop_collectors    names=btslog
    core.collect_collectors    names=btslog     target_dir=${btslog_target_dir}
    core.teardown_collectors    names=btslog

Collect Snapshot
    [Arguments]     ${snaptarget_file_name}=${BTS_path}/${SUITE NAME}/${Date}/${TEST_NAME}/Snapshotfile.zip
	admin.collect_snapshot    target_file_name=${snaptarget_file_name}

Check_BTS_State
    ${bts_state}=    admin.get_mrbts_state
    BuiltIn.Log                   [INFO] BTS STATE : ${bts_state}
    Should Contain Any            ${bts_state}    onAir    ignore_case=${TRUE}

Check ActiveFaultandAlarmID
    [Arguments]    @{fault_list}
    ${alr}=     admin.get_active_alarms
    log     ${alr}
    ${alr_num}=     admin.get_active_alarms_number
    Log    ${alr_num}
    FOR    ${i}    IN RANGE   ${alr_num}
        Log    ${alr}[${i}][faultName]
        ${Alrstring}=    Convert To String    ${alr}[${i}][alarmId]
        ${fltstring}=    Convert To String    ${alr}[${i}][faultId]
        ${affectedobj}=    Convert To String    ${alr}[${i}][configObjectName]
        run keyword and continue on failure    should contain any    ${fltstring}    @{fault_list}
        Run Keyword If    "${fltstring}" == "10"
        ...    Log to console    \nFID 10 is reported on ${affectedobj}, Please collect radio logs.
    END

Perform Parameter Recommissioning
    [Arguments]    ${parameter_dist_name}    ${parameter_name}     ${value}
    admin.perform_parameter_recommissioning
    ...    dist_name=${parameter_dist_name}
    ...    parameter=${parameter_name}
    ...    operation=update
    ...    value=${value}
    ...    skip_parameter_relation_errors=${value_true}
    ...    should_activate=${value_true}
    ...    timeout=300
    Sleep    60s