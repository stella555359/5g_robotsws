*** Settings ***

Documentation
...   author: T04
...   contact: T04
...   Description: Test Suite for CB007518-SR
...   Requirements: 11519591, 11519596, 11519601,11519605, 11519619, 11519622, 11679362
...   Webem representation of different predefined radios which are in different states along with radio FH make break
...   and check predefined status for radio and operational and availablity state of cells
...   along with autoInstallOfPredefinedRu set to different values.


Library     SSHLibrary
Library     BuiltIn
Library     String
Library     DateTime
Library     Collections
Library     OperatingSystem     WITH NAME    os
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
${btsid}=                  970
@{listofcellsonFJT}=       2    3    4
@{list_of_expFaults}=           4655    4654    61649    61524    61652
${TSNRMODid}=                   RMOD-1
${tsn_port_details}=            1/4/C23
${tsn_login_IP}=                10.45.150.48
${tsn_login_name}=              cli
${tsn_username}=                labuser
${tsn_password}=                BT5l@bus3rl0g1n

*** Test Cases ***

TestForPredefinedRadioWithOMoperations
    [Documentation]    CB007518-SR Test Predefine RU Configuration after FH break-make scenario via TSN
    ...    and check radio and cell status on predefined radios
    [Tags]    test

    Wait until Keyword succeeds    10m    20s    Check_BTS_State
    Log to console    \n"Test ---- Predefined True and Autoinstall False in a Detected Radio"
    Perform Parameter Recommissioning     MRBTS-${btsid}/EQM-1/APEQM-1/${TSNRMODid}    predefined    true
    Perform Parameter Recommissioning     MRBTS-${btsid}/MNL-1    autoInstallOfPredefinedRu    false
    Fetch_Predefined_state    False    True
    Wait until Keyword succeeds    5m    20s    CheckOperationalStateOfRadios    enabled
    Wait until Keyword succeeds    5m    20s    Cell_OperationalState    disabled
    Log to console    \n"Test ---- Predefined True and Autoinstall False in a Disconnected Radio"
    Simulation_FID10_via_TSNswitch    down
    ${ListofFaultsAtBTS}=    Check_FID
    List Should Not Contain Value    ${ListofFaultsAtBTS}    10
    Log to console    \n"Test ---- Predefined True and Autoinstall False in a Disconnected Radio post site reset"
    admin.reset    wait_for_reconnection=true    connection=default    timeout=2000
    ${ListofFaultsAtBTS}=    Check_FID
    List Should Not Contain Value    ${ListofFaultsAtBTS}    10
    Simulation_FID10_via_TSNswitch    up
    Wait until Keyword succeeds    10m    20s    CheckOperationalStateOfRadios    enabled
    Wait until Keyword succeeds    10m    20s    Cell_OperationalState    disabled
    ${ListofFaultsAtBTS}=    Check_FID
    List Should Not Contain Value    ${ListofFaultsAtBTS}    10
    Log to console    \n"Test ---- Predefined True and Autoinstall True in a Connected Radio"
    Perform Parameter Recommissioning    MRBTS-${btsid}/MNL-1    autoInstallOfPredefinedRu    true
    Fetch_Predefined_state    True    False
    Wait until Keyword succeeds    10m    20s    CheckOperationalStateOfRadios    enabled
    Wait until Keyword succeeds    10m    20s    Cell_OperationalState    enabled
    Simulation_FID10_via_TSNswitch    down
    Perform Parameter Recommissioning    MRBTS-${btsid}/EQM-1/APEQM-1/${TSNRMODid}    predefined    true
	Wait until Keyword succeeds    10m    60s    Cell_OperationalState    disabled
    Log to console    \n"Test ---- Predefined True and Autoinstall False in a Disconnected Radio"
    ${ListofFaultsAtBTS}=    Check_FID
    List Should Not Contain Value    ${ListofFaultsAtBTS}    10
    Fetch_Predefined_state     True    True
    Simulation_FID10_via_TSNswitch    up
    Wait until Keyword succeeds    10m    60s    CheckOperationalStateOfRadios    enabled
    Wait until Keyword succeeds    10m    60s    Cell_OperationalState    enabled
    Log to console    \n"Test ---- Predefined True and Autoinstall False in a Connected Radio, End of Predefined Test"
    ${ListofFaultsAtBTS}=    Check_FID
    List Should Not Contain Value    ${ListofFaultsAtBTS}    10
    Fetch_Predefined_state     True    False
    Check_BTS_State
    Check ActiveFaultandAlarmID     @{list_of_expFaults}


*** Keywords ***

Check_FID
    @{ListofFaults}=    Create List
    ${alr}=     admin.get_active_alarms
    ${alr_num}=     admin.get_active_alarms_number
    FOR    ${i}    IN RANGE   ${alr_num}
        ${fltstring}=    Convert To String    ${alr}[${i}][faultId]
        Append To List    ${ListofFaults}    ${fltstring}
    END
    RETURN    ${ListofFaults}

CheckOperationalStateOfRadios
    [Arguments]    ${StateofRadio}
    ${listofradios}=    admin.get_radio_list    timeout=60    detailed_output=False    connection=default
    ${numRadios}=     Get Length    ${listofradios}[radioModules][rmod]
    FOR    ${i}    IN RANGE    ${numRadios}
        Should Contain
        ...    ${listofradios}[radioModules][rmod][${i}][status][operationalState]    ${StateofRadio}    ignore_case=${TRUE}
    END

Cell_OperationalState
    [Arguments]    ${expectedoperstate}
    FOR    ${i}    IN    @{listofcellsonFJT}
        ${cellinfo}=     admin.get_cell_specific_info    cell_id=MRBTS-${btsid}/NRBTS-${btsid}/NRCELL-${i}
	...  	timeout=10    connection=None     detailed_output=False
        Should Contain     ${cellinfo}[status][operationalState]     ${expectedoperstate}     ignore_case=${TRUE}
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
    Collect Snapshot    snaptarget_file_name=${BTS_path}/${SUITE NAME}/${Date}/PostTestLogs/Snapshot.zip
    admin.collect_im_snapshot        ${BTS_path}/${SUITE NAME}/${Date}/${TEST_NAME}/PostTestLogs/imSnapshot.ims2
    Stop BTS logs
    #Make sure TSN does not affect other cases, teardown with mandatory steps#
    Simulation_FID10_via_TSNswitch    up
    Perform Parameter Recommissioning     MRBTS-${btsid}/MNL-1    autoInstallOfPredefinedRu    true
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
    ...    skip_parameter_relation_errors=true
    ...    should_activate=true
    ...    timeout=300
    Sleep    60s

Fetch_Predefined_state
    [Arguments]    ${value_autoinst}    ${value_predef}
    ${autoinstall}=    admin.get_parameter_by_distname     dist_name=MRBTS-${btsid}/MNL-1    parameter_list=None    include_children=None
    ...    timeout=60    detailed_output=False
    ${autovalue}=    Convert to String    ${autoinstall}[0][parameters][autoInstallOfPredefinedRu]
    ${predefined}=    admin.get_parameter_by_distname     dist_name=MRBTS-${btsid}/EQM-1/APEQM-1/${TSNRMODid}
    ...    timeout=60    detailed_output=False    parameter_list=None    include_children=None
    ${predvalue}=    Convert to String    ${predefined}[0][parameters][predefined]
    Should be Equal    ${autovalue}    ${value_autoinst}
    Should be Equal    ${predvalue}    ${value_predef}
