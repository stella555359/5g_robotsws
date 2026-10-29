*** Settings ***
Documentation   Keywords regarding ADMIN API connections and procedures.
...             Author:     Tomasz Stawowczyk
...             Contact:    tomasz.stawowczyk@nokia.com

Library         SSHLibrary
Library         taf.sbts.oam.coam.admin  WITH NAME   coam_admin
Library         taf.collectors.pmcounters
Library         taf.analyzer.pmcounter
Resource        ./admin.robot
Resource        ../alarms/alarm.robot

*** Keywords ***

Check if TL have BB
    [Arguments]      ${connection}=${connection}
    ${sm_type}=    coam_admin.get_parameter_by_distname    MRBTS-${BTS_ID}/EQM_R-1/APEQM_R-1/CABINET_R-1/SMOD_R-1
    ...            ${System_Module_parameter_on_Webem}     connection=${connection}
    ${match_result}=   Run Keyword And Return Status       Should Match Regexp    '${sm_type}'    ASO[A-Z]
    [Return]       ${match_result}

Check That The BTS Is Fully Operational
    [Arguments]      ${connection}=${NONE}    ${ignored_alarms}=@{EMPTY}
    Log              \nChecking of BTS components underway...    console=${TRUE}
    ${onair_states}=  Catenate  SEPARATOR=
    ...                                           operationalState=regex"[Ee]nabled",
    ...                                           administrativeState=regex"[Uu]nlocked"
    ${has_bbmod} =    Check if TL have BB    connection=${connection}
    IF  ${has_bbmod}
        ${bbmods_onair}    Set Variable    True
        Log      This SM doesn't have BB       console=True
    ELSE
        ${bbmods_onair}    Run Keyword And Return Status    Assert Every    BBMOD    ${onair_states}    connection=${connection}
    END
    ${smods_onair}=     Run Keyword And Return Status    Assert Every    SMOD     ${onair_states}    connection=${connection}
    ${rmods_onair}=     Run Keyword And Return Status    Assert Every    RMOD     ${onair_states}    connection=${connection}    timeout=60s
    ${cells_onair}=     Run Keyword And Return Status    Check If All Cells Are OnAir    ${connection}

    Add Standard Allowed Alarms    connection=${connection}
    FOR  ${alarm}  IN  @{IGNORED_ALARMS}
        coam_admin.Add Allowed Alarm  ${alarm}  connection=${connection}
    END
    ${alarms_status}    Run Keyword And Return Status    Assert No Unexpected Active Alarms    connection=${connection}
    Run Keyword If  ${IGNORED_ALARMS}  Run Keywords
    ...  coam_admin.Clear Allowed Alarms List  connection=${connection}
    ...  AND  Add Standard Allowed Alarms  connection=${connection}
    ${statuses_dictionary}=  Create Dictionary
    ...  smods_onair=${smods_onair}    rmods_onair=${rmods_onair}    bbmods_onair=${bbmods_onair}
    ...  cells_onair=${cells_onair}    alarms_status=${alarms_status}
    ${pprint_statuses}=  Evaluate  pprint.pformat(${statuses_dictionary}, indent=4)  modules=pprint

    Wait Until Keyword Succeeds    5 min    30 sec
    ...    Should Be True    ${smods_onair} and ${rmods_onair} and ${bbmods_onair} and ${cells_onair} and ${alarms_status}
    ...    msg=BTS verification failed. Details:\n${pprint_statuses}
    Log    \nEach component has a corresponding status!    console=${TRUE}

Omit Items From The List
    [Arguments]    ${sign}=${none}    ${numb}=${none}
    ${non_shared}    Evaluate    int(${RMOD_INDEX}) ${sign} ${numb}
    Run Keyword If    ${non_shared}    Append To list    ${RMODS_DISTNAMES}    ${ELEMENT['id']['configuration']}

Get List Of Rmods DistNames
    [Arguments]    ${omit}=False    ${sign}=${none}    ${numb}=${none}
    ${frm_info}    Get Frm    connection=${CONNECTION}
    ${rmods_distNames}    Create List
    Set Test Variable    ${RMODS_DISTNAMES}    ${rmods_distNames}
    FOR    ${element}    IN    @{frm_info}
        Set Test Variable    ${ELEMENT}    ${element}
        ${rmod_index}    Fetch From Right    ${element['id']['configuration']}    -
        Set Test Variable    ${RMOD_INDEX}    ${rmod_index}
        Run Keyword If    ${omit}    Omit Items From The List    ${sign}    ${numb}
        Run Keyword If    not ${omit}    Append To list    ${RMODS_DISTNAMES}    ${element['id']['configuration']}
    END
    [Return]    ${RMODS_DISTNAMES}

Get List Of Bbmods DistNames
    ${bts_info}    Get Bts Info    connection=${CONNECTION}
    ${baseband_info}    Get From Dictionary    ${bts_info}    basebandModules
    ${bbmods_distNames}    Create List
    FOR    ${element}    IN    @{baseband_info}
        Append To list    ${bbmods_distNames}    ${element['id']['configuration']}
    END
    [Return]    ${bbmods_distNames}

Check If Cell Has Expected Technology
    [Arguments]    ${acceptable_technologies}=${DEFAULT_TECHNOLOGIES}
    FOR    ${technology}    IN    @{acceptable_technologies}
        ${expected_cell}    Evaluate    '${ELEMENT["technology"]}' == '${technology}'
        Exit For Loop If    ${expected_cell}
    END
    [Return]    ${expected_cell}

Get List Of Lncels DistNames
    ${bts_info}    Get Bts Info    connection=${CONNECTION}
    ${cells_info}    Get From Dictionary    ${bts_info}    cells
    ${lte_cells}    Get From Dictionary    ${cells_info}    lte
    ${lte_cells_distNames}    Create List
    FOR    ${element}    IN    @{lte_cells}
        Set Test Variable     ${ELEMENT}    ${element}
        ${state}    Check If Cell Has Expected Technology
        Run Keyword If    ${state}    Append To List    ${lte_cells_distNames}    ${element['id']['configuration']}
    END
    [Return]    ${lte_cells_distNames}

Lock All Objects
    [Arguments]   ${list_of_distnames}    ${object}    ${timeout}=60
    Log    \nLockining all ${object}s is ongoing ...    console=True
    FOR    ${distname}    IN    @{list_of_distnames}
        Lock    dist_name=${distname}    timeout=${timeout}    connection=${CONNECTION}
        ${index}    Fetch From Right    ${distname}    -
        Log    \n${object}-${index} locked succesfully!    console=True
    END
    Log    \nAll ${object}s locked succesfully!    console=True

Unlock All Objects
    [Arguments]   ${list_of_distnames}    ${object}    ${timeout}=60
    Log    \nUnlockining all ${object}s is ongoing ...    console=True
    FOR    ${distname}    IN    @{list_of_distnames}
        Unlock    dist_name=${distname}    timeout=${timeout}    connection=${CONNECTION}
        ${index}    Fetch From Right    ${distname}    -
        Log    \n${object}-${index} unlocked succesfully!    console=True
    END
    Log    \nAll ${object}s unlocked succesfully!    console=True

Lock Random Objects
    [Arguments]   ${list_of_distnames}    ${object}    ${iterations}    ${timeout}=60
    ${upper_bound}    Get Length    ${list_of_distnames}
    ${locked_objects}    Create List
    Log    \nLocking ${iterations} random ${object}s    console=True
    FOR    ${i}    IN RANGE    ${iterations}
        ${random_number}    Evaluate    random.randint(0, ${upper_bound}-1)    random
        ${random_value}    Get From List    ${list_of_distnames}    ${random_number}
        ${object_index}    Fetch From Right    ${random_value}    -
        Lock    dist_name=${random_value}    timeout=${timeout}    connection=${CONNECTION}
        Append To List    ${locked_objects}    ${random_value}
        Remove From List    ${list_of_distnames}    ${random_number}
        ${upper_bound}    Evaluate    ${upper_bound}-1
        Log    \n${object}-${object_index} locked succesfully!    console=True
    END
    Log    \n${iterations} ${object}s locked succesfully!    console=True
    [Return]    ${locked_objects}

Unlock Drawn Objects
    [Arguments]   ${list_of_distnames}    ${object}    ${timeout}=60
    Log    \nUnlocking random ${object}s locked before    console=True
    FOR    ${distname}    IN    @{list_of_distnames}
        ${object_index}    Fetch From Right    ${distname}    -
        Unlock    dist_name=${distname}    timeout=${timeout}    connection=${CONNECTION}
        Log    \n${object}-${object_index} unlocked succesfully!    console=True
    END
    Log    \nAll ${object}s unlocked succesfully!    console=True

Perform Random Object Reset
    [Arguments]    ${list_of_distnames}    ${object}     ${iterations}    ${timeout}=2    ${type}=Soft
    ${upper_bound}    Get Length    ${list_of_distnames}
    Log    \nReset ${iterations} random ${object}s    console=True
    FOR    ${i}    IN RANGE    ${iterations}
        ${random_number}    Evaluate    random.randint(0, ${upper_bound}-1)    random
        ${random_value}    Get From List    ${list_of_distnames}    ${random_number}
        ${object_index}    Fetch From Right    ${random_value}    -
        Log    \nReseting ${object}-${object_index} ...    console=True
        Reset Unit    dist_name=${random_value}    timeout=180    reset_type=${type}    connection=${CONNECTION}
        Wait Until Keyword Succeeds     ${timeout}m    30s    Check That The BTS Is Fully Operational
        ...    connection=${CONNECTION}    ignored_alarms=${IGNORED_ALARMS}
        Log    \n${object}-${object_index} reseted succesfully!    console=True
    END

Get Time From BTS
    [Documentation]
    ...  KW used to get time from BTS.
    ...
    ...  | **Author:** monika.ceglarek@nokia.com
    ...  | **Maintainer:** tomasz.stawowczyk@nokia.com
    ...
    ...  **Full Description:**
    ...
    ...  KW used to get time from BTS. As default values it uses variables from __init__.py file,
    ...  therefore it is recommended to have them filled. It runs command: date +\"${date_time_format}\"
    ...  and returns stdout. Argument 'date_time_format' has default value '%d.%m %H:%M:%S'.
    ...  If stderr is not empty or rc is different from 0, this KW will fail.
    ...  It closes current connection in teardown.
    ...
    ...  **Input Parameters:**
    ...
    ...  +-------------------+------+---------------------------------------------------------------------------+
    ...  | Parameter         | Man. | Description                                                               |
    ...  +===================+======+===========================================================================+
    ...  | host_ip           | No   | IP for BTS from which time is read. Default value:                        |
    ...  |                   |      | ${tl.gnbs[0].cu.oam_ssh_connection_details.addr}.                         |
    ...  +-------------------+------+---------------------------------------------------------------------------+
    ...  | user              | No   | Username for BTS from which time is read. Default value:                  |
    ...  |                   |      | ${tl.gnbs[0].cu.oam_ssh_connection_details.username}.                     |
    ...  +-------------------+------+---------------------------------------------------------------------------+
    ...  | password          | No   | Password for BTS from which time is read. Default value:                  |
    ...  |                   |      | ${tl.gnbs[0].cu.oam_ssh_connection_details.password}.                     |
    ...  +-------------------+------+---------------------------------------------------------------------------+
    ...  | date_time_format  | No   | Format for date and time fetched from BTS it should follow the same       |
    ...  |                   |      | rules as 'date' command. Default value: %d.%m %H:%M:%S.                   |
    ...  +-------------------+------+---------------------------------------------------------------------------+
    ...
    ...  **Example of simple usage:**
    ...
    ...  .. code-block:: robotframework
    ...
    ...     ${start_time} =  Get Time From BTS

    [Arguments]  ${host_ip}=${tl.gnbs[0].cu.oam_ssh_connection_details.addr}  ${user}=${tl.gnbs[0].cu.oam_ssh_connection_details.username}
    ...  ${password}=${tl.gnbs[0].cu.oam_ssh_connection_details.password}  ${date_time_format}=%d.%m %H:%M:%S

    SSHLibrary.Open Connection  ${host_ip}
    SSHLibrary.Login  ${user}  ${password}
    ${stdout}  ${stderr}  ${rc} =  SSHLibrary.Execute Command  date +\"${date_time_format}\"  return_stderr=True  return_rc=True
    Should Be Equal As Integers  ${rc}  0    msg=RC is not equal to 0.
    Should Be Empty  ${stderr}  msg=${stderr}
    [Return]  ${stdout}
    [Teardown]  SSHLibrary.Close Connection

Count Measurement Period
    [Documentation]
    ...  KW used to calculate measurement period for counters.
    ...
    ...  | **Author:** monika.ceglarek@nokia.com
    ...
    ...  **Full Description:**
    ...
    ...  KW used to calculate measurement period for counters.
    ...  It gets time from BTS and counts number of seconds left until next counter period.
    ...  It is possible to add delta to the value counted by this KW with parameter 'delta'.
    ...
    ...  **Input Parameters:**
    ...
    ...  +------------------------+------+-----------------------------------------------------------------------+
    ...  | Parameter              | Man. | Description                                                           |
    ...  +========================+======+=======================================================================+
    ...  | ip                     | Yes  | IP used for connecting with BTS.                                      |
    ...  +------------------------+------+-----------------------------------------------------------------------+
    ...  | counter_period         | Yes  | Absolute path for modified SCF.                                       |
    ...  +------------------------+------+-----------------------------------------------------------------------+
    ...  | user                   | No   | Username for connecting with BTS. Default value:                      |
    ...  |                        |      | ${tl.enbs[0].system_module.common_units[0].lmp_connection.username}.  |                     |
    ...  +------------------------+------+-----------------------------------------------------------------------+
    ...  | password               | No   | Username for connecting with BTS. Default value:                      |
    ...  |                        |      | ${tl.enbs[0].system_module.common_units[0].lmp_connection.password}.  |
    ...  +------------------------+------+-----------------------------------------------------------------------+
    ...  | delta                  | No   | Additional value added to waiting period. Default value: 0.           |
    ...  +------------------------+------+-----------------------------------------------------------------------+
    ...
    ...  **Example of simple usage:**
    ...
    ...  .. code-block:: robotframework
    ...
    ...     Count Measurement Period  12.123.123.123  15

    [Arguments]  ${ip}
    ...          ${counter_period}
    ...          ${user}=${tl.enbs[0].system_module.common_units[0].lmp_connection.username}
    ...          ${password}=${tl.enbs[0].system_module.common_units[0].lmp_connection.password}
    ...          ${delta}=0

    ${current_time_on_sbts} =  Get Time From BTS  host_ip=${ip}
    ...                                           user=${user}
    ...                                           password=${password}
    ...                                           date_time_format=%M:%S
    ${minutes_now}  ${seconds_now} =  Split String  ${current_time_on_sbts}  separator=:
    ${waiting_time} =  Evaluate
    ...  ${counter_period} * 60 - ( int("${minutes_now}") % ${counter_period} * 60 + int("${seconds_now}") ) + ${delta}

    [Return]  ${waiting_time}

Collect PM Counters
    [Documentation]
    ...  This KW collects PM files from BTS.
    ...
    ...  | **Author:** monika.ceglarek@nokia.com
    ...  | **Maintainer:** tomasz.stawowczyk@nokia.com
    ...
    ...  **Full Description:**
    ...
    ...  This KW collects PM files from BTS. All files are saved at first and based on
    ...  xml_files_left parameter the amount of .xml files that will not be removed
    ...  is determined. Additionally all saved .raw files are not removed from disc.
    ...
    ...  **Input Parameters:**
    ...
    ...  +---------------------+------+-------------------------------------------------------------------------+
    ...  | Parameter           | Man. | Description                                                             |
    ...  +=====================+======+=========================================================================+
    ...  | target_dir_path     | No   | Path where directory with PM files will be saved. Last directory        |
    ...  |                     |      | name will also be alias name for counters collector.                    |
    ...  |                     |      | Default value: LOG_PATH/pm_counters.                                    |
    ...  +---------------------+------+-------------------------------------------------------------------------+
    ...  | xml_files_left      | No   | Number of .xml PM files that will not be removed from disc              |
    ...  |                     |      | Default value: 1.                                                       |
    ...  +---------------------+------+-------------------------------------------------------------------------+
    ...  | host                | No   | IP of host for webservice. Default value: 192.168.255.129.              |
    ...  +---------------------+------+-------------------------------------------------------------------------+
    ...  | user                | No   | Username for webservice. Default value: Nemuadmin.                      |
    ...  +---------------------+------+-------------------------------------------------------------------------+
    ...  | password            | No   | Password for webservice. Default value: nemuuser.                       |
    ...  +---------------------+------+-------------------------------------------------------------------------+
    ...  | port                | No   | Port for webservice. Default value: 443.                                |
    ...  +---------------------+------+-------------------------------------------------------------------------+
    ...  | intervals           | No   | Counters intervals. Default value: 1,2,4                                |
    ...  +---------------------+------+-------------------------------------------------------------------------+
    ...  | bts_type            | No   | Type of BTS. Currently possible values: classical, vcu, vdu.            |
    ...  |                     |      |  Default value: classical.                                              |
    ...  +---------------------+------+-------------------------------------------------------------------------+
    ...
    ...  **Example of simple usage:**
    ...
    ...  .. code-block:: robotframework
    ...
    ...     Collect PM Counters

    [Arguments]  ${target_dir_path}=${LOG_PATH}/pm_counters  ${xml_files_left}=1  ${host}=192.168.255.129
    ...          ${user}=Nemuadmin  ${password}=nemuuser  ${port}=443  ${time_interval}=3 min  ${intervals}=1,2,4
    ...          ${bts_type}=classical

    ${target_dir}  ${name}=  Split String From Right  ${target_dir_path}  separator=/  max_split=1
    &{webservice} =  Create Dictionary
    ...  host=${host}
    ...  user=${user}
    ...  password=${password}
    ...  port=${port}
    Run Keyword If  '${bts_type}' == 'classical'
    ...  taf.collectors.pmcounters.Create PM Collector
    ...  name=${name}
    ...  webservice=${webservice}
    ...  for_last=${time_interval}
    ...  intervals=${intervals}
    ...  ELSE IF  '${bts_type}' == 'vdu'
    ...  taf.collectors.pmcounters.Create COAM VDU PM collector
    ...  name=${name}
    ...  webservice=${webservice}
    ...  for_last=${time_interval}
    ...  intervals=${intervals}
    ...  ELSE IF  '${bts_type}' == 'vcu'
    ...  taf.collectors.pmcounters.Create COAM VCU PM collector
    ...  name=${name}
    ...  webservice=${webservice}
    ...  for_last=${time_interval}
    ...  intervals=${intervals}
    taf.collectors.pmcounters.Setup Collectors
    ...  names=${name}
    taf.collectors.pmcounters.Collect Collectors
    ...  names=${name}
    ...  target_dir=${target_dir}
    Directory Should Not Be Empty  ${target_dir}/${name}  msg=No counter files were collected.
    ${xml_files_left} =  Run Keyword If  '${bts_type}' == 'vdu'  Evaluate  ${xml_files_left} * 8
    ...  ELSE IF  '${bts_type}' == 'vcu'  Evaluate  ${xml_files_left} * 18
    ...  ELSE  Set Variable  ${xml_files_left}
    Run  find ${target_dir}/${name} -name '*.xml' | sort -nk1 | head -n -${xml_files_left}| xargs rm -rf
    [Teardown]  taf.collectors.pmcounters.Teardown Collectors  names=${name}

Get Values Of Counters From List
    [Documentation]
    ...  This KW returns dictionary of counters (keys) and list of their values (value).
    ...
    ...  | **Author:** monika.ceglarek@nokia.com
    ...  | **Maintainer:** tomasz.stawowczyk@nokia.com
    ...
    ...  **Full Description:**
    ...
    ...  This KW returns dictionary of counters (keys) and list of their values (value).
    ...  All counters must be under the same managed object (the same value in 'dist_name' argument).
    ...
    ...  **Input Parameters:**
    ...
    ...  +---------------------+------+-------------------------------------------------------------------------+
    ...  | Parameter           | Man. | Description                                                             |
    ...  +=====================+======+=========================================================================+
    ...  | files_path          | Yes  | Path to saved PM files.                                                 |
    ...  +---------------------+------+-------------------------------------------------------------------------+
    ...  | counter_list        | Yes  | List of counter's IDs.                                                  |
    ...  +---------------------+------+-------------------------------------------------------------------------+
    ...  | dist_name           | Yes  | Dist name under which counters from 'counter_list' can be found.        |
    ...  +---------------------+------+-------------------------------------------------------------------------+
    ...  | counters_amount     | No   | Number of last periods for which counter values should                  |
    ...  |                     |      | be comparised. Default value 'all' means all values of specified        |
    ...  |                     |      | counter will be verified.                                               |
    ...  +---------------------+------+-------------------------------------------------------------------------+
    ...
    ...  **Example of simple usage:**
    ...
    ...  .. code-block:: robotframework
    ...
    ...     ${counter_list} =  Create List  M8029C217  M8029C225  M8029C238  M8029C210
    ...     Get Values Of Counters From List  ${LOG_PATH}/pm_counters  ${counter_list}
    ...     ...  MRBTS-12345/LNBTS-12345/LNCEL-111222  5

    [Arguments]  ${files_path}  ${counter_list}  ${dist_name}  ${counters_amount}=all
    Log  Getting values for counters: ${counter_list}  console=True

    ${counters_dict} =  Create Dictionary
    FOR  ${counter}  IN  @{counter_list}
        ${counter_in_list} =  Create List  ${counter}
        ${pi_dict} =  Get PI Value
        ...  pi_list=${counter_in_list}
        ...  pi_dir=${files_path}
        ...  pi_file_pattern=PM*

        ${pi_dict} =  Set Variable If  '${counters_amount}'.lower() == 'all'
        ...                             ${pi_dict}
        ...                             ${pi_dict[-${counters_amount}:]}
        ${all_counters_dicts} =  Evaluate  [list(x.values())[0] for x in ${pi_dict}]
        Log  Getting values for counter: ${counter}  console=True
        ${counter_values} =  Evaluate  [x['${counter}']['${dist_name}'] for x in ${all_counters_dicts} if '${counter}' in x.keys()]
        _counter_check_helper  counters_amount=${counters_amount}  counter_values=${counter_values}
        Set To Dictionary  ${counters_dict}  ${counter}=${counter_values}
        Log  Values: ${counter_values}  console=True
    END
    [Return]  ${counters_dict}

_counter_check_helper
    [Arguments]  ${counters_amount}  ${counter_values}
    ${list_length} =  Get Length  ${counter_values}
    Run Keyword If  '${counters_amount}' == 'all'  Run Keyword And Continue On Failure
    ...  Should Be True  ${list_length} > 0  msg=Counter list is empty. Check if there are any counters.
    ...  ELSE  Run Keyword And Continue On Failure  Should Be True  ${list_length} == ${counters_amount}
    ...  msg=List length (${list_length}) is different from requested counters amount (${counters_amount}).
