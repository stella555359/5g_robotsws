*** Settings ***
Documentation       Keyword file for cOAM keywords for classical

Library             OperatingSystem
Library             String
Library             Collections
Library             robot.libraries.DateTime

Library             taf.sbts.oam.coam.admin            WITH NAME      admin
Library             taf.transport.ssh                  WITH NAME      ssh
Library             taf.config.testline.info           WITH NAME      testlineInfo
Library             python/coam_parameter.py
Resource            connect.robot


*** Variables ***
${MAX_WAIT_TIME_COAM_CONFIGURED}     15 min
${BTS_PROCEDURAL_STATES}             configured, Configured, OnAir, on air, IntegratedToRan, integrated to ran, NotCommissioned
${P_console}                         ${False}
*** Keywords ***
Verify BTS Procedural State
    [Documentation]
    ...     Verify BTS Procedural State and blocking State
    ...
    ...     | alias   | AdminConnection object or if used, string name alias |
    ...     | timeout | Time to wait for positive procedure result |
    ...     | proceduralStates | csv string, state must be equal to one of them |
    ...
    ...     *Example*
    ...     | Verify BTS Procedural State | proceduralStates=Configured
    ...     | Verify BTS Procedural State | proceduralStates=Configured,OnAir,Commissioned
    ...
    [Arguments]    ${alias}=gnb-0-OAM-http-session    ${proceduralStates}=Configured    ${timeout}=30
    ${bts_status}=    admin.Get BTS Statuses    timeout=${timeout}    connection=${alias}
    Nidd Value Should Be One Of   ${bts_status['proceduralState']}   ${proceduralStates}
    Nidd Value Should Be Equal    ${bts_status['blockingState']}     unblocked


Verify BTS Configuration State
    [Documentation]
    ...     Verify BTS is commissioned state or not
    ...
    ...     | alias   | AdminConnection object or if used, string name alias |
    ...     | timeout | Time to wait for positive procedure result |
    ...
    [Arguments]    ${alias}=gnb-0-OAM-http-session    ${timeout}=30
    ${proceduralStates}=    Set Variable    Configured, OnAir, Commissioned
    Verify BTS Procedural State   alias=${alias}    proceduralStates=${proceduralStates}   timeout=${timeout}


Get SCF Values From Current XML File
    [Documentation]
    ...     Gets values from current xml file.
    ...
    ...     | check_value | verify parameter values if not ${False} |
    ...     | alias       | AdminConnection object or if used, string name alias |
    ...     | config_type | configuration, configurationAndRuntimeObjects or runtimeObjects |
    ...     | parameters  | list of dicts, examples are mentioend below. |
    ...
    ...     *Example*
    ...     | parameter = [
    ...     |               {'dist_name': None, 'parameter':'btsName', 'value':'Automation_Testing'},
    ...     |               {'dist_name': 'LNBTS-40/LNCEL-11/LNRELGNBCELL-0', 'parameter':'nrCgiPlmnId',
    ...     |               'value':[{'mcc':'262','mnc':'3', "mncLength":'2'}]},
    ...     |               {'dist_name': 'LNBTS-40/LNCEL-11/LNRELGNBCELL-0', 'parameter':'nrCellId', 'value':'32765'},
    ...     |               {'dist_name': 'NRBTS-1/NRDU-1', 'parameter':'refNrCellGroup', 'value':['0']},
    ...     |               {'dist_name': 'MNL-1/MNLENT-2/SYNC-1/CLOCK-1/TOP-1/TOPP-1', 'parameter':'topMasterList',
    ...     |               value':[{'masterIpAddr':None}], p_index=1}
    ...     |              ]
    ...
    ...     *Returns*   list of dicts with current values
    ...
    [Arguments]  ${parameters}     ${check_value}=${False}     ${config_type}=configuration    ${alias}=gnb-0-OAM-http-session
    ${param_values}=     coam_parameter.Get List Values From SCF File       local_dir_path=${None}
    ...       parameters=${parameters}    check_value=${check_value}       connection=${alias}  config_type=${config_type}
    RETURN   ${param_values}


Get SCF Single Value From Current Xml File
    [Documentation]
    ...     Gets value from current xml file.
    ...
    ...     | config_type | configuration, configurationAndRuntimeObjects or runtimeObjects |
    ...     | parameter   | name of parameter, if list not having parameter , mandatory to pass list_name.Ex: nrCellList |
    ...     | list_name   | list name |
    ...     | dist_name   | Dist Name, default None indicates root Dist name Ex: MRBTS-1 |
    ...     | p_index     | optional parameter, should be castable to int. Should be used if more than one match expected. |
    ...     | alias       | AdminConnection object or if used, string name alias |
    ...
    ...     *Returns*   parameter value
    ...
    [Arguments]   ${parameter}=${None}   ${list_name}=${None}   ${dist_name}=${None}   ${p_index}=${0}  ${alias}=gnb-0-OAM-http-session
    ...           ${config_type}=configuration
    ${param_value}=     coam_parameter.Get Single Value From SCF File       local_dir_path=${None}   p_index=${p_index}
    ...       parameter=${parameter}   list_name=${list_name}   dist_name=${dist_name}     connection=${alias}
    ...      config_type=${config_type}
    RETURN   ${param_value}


Update SCF Parameter
    [Documentation]
    ...     Update single SCF parameter
    ...
    ...     | value     |  str or list, value of parameter or list parameter |
    ...     | parameter | Name of parameter, either parameter or list_name should be set. |
    ...     | list_name | list name |
    ...     | dist_name | Dist Name, default None indicates root Dist name Ex: MRBTS-1 |
    ...     | timeout   | Time to wait for positive procedure result |
    ...     | alias     | AdminConnection object or if used, string name alias |
    ...
    ...     *Returns*   PASS - online parameter update
    ...                 RESET_PASS - parameter update is successful, BTS is going to trigger reset
    ...                              and reverse delta JSON path.
    ...                 Otherwise raise exception if recommission failed.
    ...
    [Arguments]   ${value}    ${parameter}=${None}   ${list_name}=${None}   ${dist_name}=${None}
    ...           ${alias}=gnb-0-OAM-http-session       ${timeout}=60
    Wait Until Keyword Succeeds  ${MAX_WAIT_TIME_COAM_CONFIGURED}   30s     Verify BTS Procedural State   alias=${alias}
    ...   proceduralStates=${BTS_PROCEDURAL_STATES}
    ${update_results}=     coam_parameter.Perform Single Parameter Update       value=${value}
    ...       parameter=${parameter}   list_name=${list_name}   dist_name=${dist_name}
    ...    timeout=${timeout}     connection=${alias}
    Wait Until Keyword Succeeds  ${MAX_WAIT_TIME_COAM_CONFIGURED}   30s     Verify BTS Procedural State   alias=${alias}
    ...   proceduralStates=${BTS_PROCEDURAL_STATES}
    Get SCF Values From Current XML File     parameters=${update_results['parameters']}     check_value=${True}
    ...   alias=${alias}
    RETURN    ${update_results['update_status']}    ${update_results['reverse']}


Update List Of SCF Parameters
    [Documentation]
    ...     Update list of  SCF parameters
    ...
    ...     | timeout   | Time to wait for positive procedure result |
    ...     | alias     | AdminConnection object or if used, string name alias |
    ...     | parameters | List of dicts, see examples below: |
    ...
    ...     *Example*
    ...     | parameter = [
    ...     |               {'dist_name': None, 'parameter':'btsName', 'value':'Automation_Testing'},
    ...     |               {'dist_name': 'LNBTS-40/LNCEL-11/LNRELGNBCELL-0', 'parameter':'nrCgiPlmnId',
    ...     |               'value':[{'mcc':'262','mnc':'3', "mncLength":'2'}]},
    ...     |               {'dist_name': 'LNBTS-40/LNCEL-11/LNRELGNBCELL-0', 'parameter':'nrCellId', 'value':'32765'},
    ...     |               {'dist_name': 'NRBTS-1/NRDU-1', 'parameter':'refNrCellGroup', 'value':['0']}
    ...     |             ]
    ...
    ...     *Returns*   PASS - online parameter update
    ...                 RESET_PASS - parameter update is successful, BTS is going to trigger reset
    ...                              and reverse delta JSON path.
    ...                 Otherwise raise exception if recommission failed.
    ...
    [Arguments]   ${parameters}=${None}       ${timeout}=60     ${alias}=gnb-0-OAM-http-session
    Wait Until Keyword Succeeds  ${MAX_WAIT_TIME_COAM_CONFIGURED}   30s     Verify BTS Procedural State   alias=${alias}
    ...   proceduralStates=${BTS_PROCEDURAL_STATES}
    ${delta_file}=   coam_parameter.Create Update Parameters Delta  parameters=${parameters}  connection=${alias}
    ${update_status}=   coam_parameter.Perform SCF Delta Commission  delta_file=${delta_file['updated']}
    ...    timeout=${timeout}     connection=${alias}
    Wait Until Keyword Succeeds  ${MAX_WAIT_TIME_COAM_CONFIGURED}   30s     Verify BTS Procedural State   alias=${alias}
    ...   proceduralStates=${BTS_PROCEDURAL_STATES}
    Get SCF Values From Current XML File     parameters=${parameters}     check_value=${True}     alias=${alias}
    RETURN   ${update_status}       ${delta_file['reverse']}


Create List Of SCF Objects
    [Documentation]
    ...     Create list of  SCF objects
    ...
    ...     | timeout    | Time to wait for positive procedure result |
    ...     | alias      | AdminConnection object or if used, string name alias |
    ...     | parameters | List of dicts which should contains required list of parameters to create an object |
    ...
    ...     *Example*
    ...     | parameter = [
    ...     |               {'dist_name': 'TNLSVC-1/TNL-1/ETHSVC-1/ETHIF-1/VLANIF-100', 'parameter':'vlanId',
    ...     |               'value':'601'},
    ...     |               {'dist_name': 'TNLSVC-1/TNL-1/ETHSVC-1/ETHIF-1/VLANIF-200', 'parameter':'vlanId',
    ...     |               'value':'701'},
    ...     |             ]
    ...
    ...     *Returns*   PASS - online parameter update
    ...                 RESET_PASS - parameter update is successful, BTS is going to trigger reset
    ...                              and reverse delta JSON path.
    ...                 Otherwise raise exception if recommission failed.
    ...
    [Arguments]   ${parameters}=${None}       ${timeout}=60       ${alias}=gnb-0-OAM-http-session
    Wait Until Keyword Succeeds  ${MAX_WAIT_TIME_COAM_CONFIGURED}   30s     Verify BTS Procedural State   alias=${alias}
    ...   proceduralStates=${BTS_PROCEDURAL_STATES}
    ${delta_file}=   coam_parameter.Create Objects Delta  parameters=${parameters}  connection=${alias}
    ${commission_status}=   coam_parameter.Perform SCF Delta Commission  delta_file=${delta_file['updated']}
    ...    timeout=${timeout}     connection=${alias}
    Wait Until Keyword Succeeds  ${MAX_WAIT_TIME_COAM_CONFIGURED}   30s     Verify BTS Procedural State   alias=${alias}
    ...   proceduralStates=${BTS_PROCEDURAL_STATES}
    Get SCF Values From Current XML File     parameters=${parameters}     check_value=${True}     alias=${alias}
    RETURN   ${commission_status}             ${delta_file['reverse']}


Delete List Of SCF Objects
    [Documentation]
    ...     Delete list of  SCF objects
    ...
    ...     | alias      | AdminConnection object or if used, string name alias |
    ...     | timeout    | Time to wait for positive procedure result |
    ...     | parameters | List of dicts |
    ...
    ...     *Example*
    ...     | parameter = [
    ...     |               {'dist_name': 'TNLSVC-1/TNL-1/ETHSVC-1/ETHIF-1/VLANIF-100', 'parameter':'vlanId',
    ...     |                'value':'601'},
    ...     |                {'dist_name': 'TNLSVC-1/TNL-1/ETHSVC-1/ETHIF-1/VLANIF-200', 'parameter':'vlanId',
    ...     |                'value':'701'},
    ...     |             ]
    ...
    ...     *Returns*   PASS - online parameter update
    ...                 RESET_PASS - parameter update is successful, BTS is going to trigger reset
    ...                 Otherwise raise exception if recommission failed.
    ...
    [Arguments]   ${parameters}=${None}       ${timeout}=60    ${alias}=gnb-0-OAM-http-session
    Wait Until Keyword Succeeds  ${MAX_WAIT_TIME_COAM_CONFIGURED}   30s     Verify BTS Procedural State   alias=${alias}
    ...   proceduralStates=${BTS_PROCEDURAL_STATES}
    ${delta_file}=   coam_parameter.Create Delete Objects Delta  parameters=${parameters}  connection=${alias}
    ${commission_status}=   coam_parameter.Perform SCF Delta Commission  delta_file=${delta_file['updated']}
    ...    timeout=${timeout}     connection=${alias}
    Wait Until Keyword Succeeds  ${MAX_WAIT_TIME_COAM_CONFIGURED}   30s     Verify BTS Procedural State   alias=${alias}
    ...   proceduralStates=${BTS_PROCEDURAL_STATES}
    RETURN   ${commission_status}


Perform Delta SCF XML Recommission
    [Documentation]
    ...     This keyword is used to Perform Delta SCF XML Recommission.
    ...     and reverse delta JSON path(not available for delete delta operation, it will return None).
    ...
    ...     | delta_scf_path                        | Delta SCF xml file path |
    ...     | delta_operation                       | Delta SCF xml operation, options: update, create, delete |
    ...     | param skip_parameter_relation_errors  | whether or not to ignore relation errors (True|False) |
    ...     | timeout                               | Time to wait for positive procedure result |
    ...     | alias                                 | connection alias used for the session |
    ...
    ...     *Returns*   PASS - online parameter update
    ...                 RESET_PASS - parameter update is successful, BTS is going to trigger reset
    ...                 Otherwise raise exception if recommission failed.
    ...
    [Arguments]   ${delta_scf_path}=${None}   ${delta_operation}=update   ${skip_parameter_relation_errors}=False   ${timeout}=60
    ...           ${alias}=gnb-0-OAM-http-session
    Wait Until Keyword Succeeds  ${MAX_WAIT_TIME_COAM_CONFIGURED}   30s     Verify BTS Procedural State   alias=${alias}
    ...   proceduralStates=${BTS_PROCEDURAL_STATES}
    ${convert_status}=   coam_parameter.Convert Delta SCF XML   delta_xml_path=${delta_scf_path}   delta_operation=${delta_operation}
    ...    connection=${alias}
    ${update_status}=   coam_parameter.Perform SCF Delta Commission  delta_file=${convert_status['updated']}
    ...    skip_parameter_relation_errors=${skip_parameter_relation_errors}    timeout=${timeout}     connection=${alias}
    Wait Until Keyword Succeeds  ${MAX_WAIT_TIME_COAM_CONFIGURED}   30s     Verify BTS Procedural State   alias=${alias}
    ...   proceduralStates=${BTS_PROCEDURAL_STATES}
    Get SCF Values From Current XML File    parameters=${convert_status['parameters']}   check_value=${True}    alias=${alias}
    RETURN   ${update_status}     ${convert_status['reverse']}


Verify BTS Sync Mode
    [Documentation]
    ...     Verify for sync_mode
    ...
    ...     | sync_mode | BTS Sync mode |
    ...     | alias     | AdminConnection object or if used, string name alias |
    ...
    [Arguments]              ${sync_mode}=PhaseSync,FreqSync    ${alias}=gnb-0-OAM-http-session
    ${bts_sync}              admin.Get BTS Sync Mode              connection=${alias}
    Nidd Value Should Be One Of      ${bts_sync}        ${sync_mode}


Get BTS Active Sync Source
    [Documentation]
    ...     Get Active Sync source from BTS
    ...
    ...     | sync_mode   | BTS Sync mode |
    ...     | tuning_mode | BTS Sync status i.e Normal or Holdover |
    ...     | alias       | AdminConnection object or if used, string name alias |
    ...
    ...     *Returns*   active synchronisation status dictionary
    ...
    [Arguments]              ${sync_mode}=PhaseSync,FreqSync      ${tuning_mode}=Normal tuning    ${alias}=gnb-0-OAM-http-session
    ${bts_sync_status}       admin.Get BTS Sync Source Status     connection=${alias}
    ${bts_tuningMode}        Get From Dictionary                  ${bts_sync_status}         tuningMode
    Nidd Value Should Be Equal  ${bts_tuningMode}                 ${tuning_mode}
    ${bts_syncMode}          Get From Dictionary                  ${bts_sync_status}         syncMode
    Nidd Value Should Be One Of   ${bts_syncMode}                 ${sync_mode}
    ${syncSourceInfo}        Get From Dictionary                  ${bts_sync_status}         syncSourceInfo
    ${active_sync_dict}      Create Dictionary
    FOR    ${sync}    IN    @{syncSourceInfo}
        ${sync_status}          Get From Dictionary   ${sync}        isActive
        ${active_sync_dict}     Set Variable If   '${sync_status}' == 'True'      ${sync}
        IF    '${sync_status}' == 'True'
            BREAK
        ELSE
            Log  ${\n}BTS sync status isActive: ${sync_status}   console=${P_console}
        END
    END
    Should Not Be Empty      ${active_sync_dict}
    RETURN                 ${active_sync_dict}


Verify Active BTS Sync Source
    [Documentation]
    ...     Verify Active Sync source
    ...
    ...     | sync_type | BTS sync type, Ex: 1pps/ToD from external GNSS receiver or TOPP ..etc |
    ...     | alias     | AdminConnection object or if used, string name alias |
    ...
    [Arguments]    ${sync_type}=1pps/ToD from external GNSS receiver,1pps/ToD from Sync Hub Master
    ...            ${alias}=gnb-0-OAM-http-session
    ${active_sync_dict}   Get BTS Active Sync Source   alias=${alias}
    ${sync_output}        Collections.Get From Dictionary          ${active_sync_dict}   syncInputType
    Nidd Value Should Be One Of   ${sync_output}       ${sync_type}


Nidd Value Should Be Equal
    [Documentation]
    ...     Verifies, if the given nidd value is same as expected value.
    ...     The check is case insensitive and ignores spaces.
    ...
    ...     *Scope* Internal
    ...
    ...     | nidd      | the nidd value to verify |
    ...     | expected  | the expected nidd value |
    ...     | msg       | error message to be diaplayed if check fails |
    ...
    [Arguments]   ${nidd}   ${expected}   ${msg}={Nidd Value '${nidd}' should be '${expected}'}
    ${is_equal}=    Evaluate   "${nidd}".replace(' ', '').lower() == "${expected}".replace(' ', '').lower()
    Should Be True   ${is_equal}   ${msg}


Nidd Value Should Be One Of
    [Documentation]
    ...     Verifies, if the given nidd value is fitting to one of the given nidd values.
    ...     The check is case insensitive and ignores spaces.
    ...
    ...     *Scope* Internal
    ...
    ...     | nidd                     | the nidd value to verify |
    ...     | expected_nidd_values_csv | is a string with all expected values in a comma separated description |
    ...     | msg                      | error message to be diaplayed if check fails |
    ...
    [Arguments]   ${nidd}   ${expected_nidd_values_csv}     ${msg}={Nidd Value '${nidd}' should be one of '${expected_nidd_values_csv}'}
    ${expected_nidd_values}=   Split String   ${expected_nidd_values_csv}  separator=,
    ${equal_elements}=    Create List
    FOR    ${expected_nidd_value}   IN   @{expected_nidd_values}
        ${nidd_is_equal}=    Evaluate   "${nidd}".replace(' ', '').lower() == "${expected_nidd_value}".replace(' ', '').lower()
        Append To List    ${equal_elements}    ${nidd_is_equal}
    END
    List Should Contain Value  ${equal_elements}  ${True}   ${msg}


Nidd AvailabilityStatus Value Should Be One Of
    [Documentation]
    ...     Verifies, if the given nidd value is fitting to one of the given nidd values.
    ...     The check is case insensitive and ignores spaces. Special handling is needed if the expected
    ...     status is Online. With CNI-61110 the 'Online' state has to be implied of no value/key is
    ...     available in the dictionary. For backward compatibility reasons a check for key with
    ...     expected value 'online' will pass even it isn't found.
    ...
    ...     *Scope* Internal
    ...
    ...     | nidd_status_dict         | the dictionary holding status info to verify |
    ...     | expected_nidd_values_csv | is a string with all expected values in a comma separated description. |
    ...     | msg                      | error message to be diaplayed if check fails |
    ...
    [Arguments]   ${nidd_status_dict}   ${expected_nidd_values_csv}
    ...           ${msg}={Nidd availabilityStatus should be one of '${expected_nidd_values_csv}'}
    ${key_exists}=    Run Keyword And Return Status   Dictionary Should Contain Key   ${nidd_status_dict}     availabilityStatus
    ${expected_is_online}=    Run Keyword And Return Status
    ...     Should Match    ${expected_nidd_values_csv}     *online*    ignore_case=True
    IF      ${key_exists}==${False} and ${expected_is_online}==${True}   RETURN
    Nidd Value Should Be One Of     ${nidd_status_dict['availabilityStatus']}   ${expected_nidd_values_csv}   ${msg}


Detected HW Info
    [Documentation]
    ...     Gets Detected hardware info
    ...
    ...     | alias | AdminConnection object or if used, string name alias |
    ...
    ...     *Returns*   bts HW info dictionary
    ...
    [Arguments]          ${alias}=gnb-0-OAM-http-session
    ${output}=           admin.Get Detected HW Info      connection=${alias}
    RETURN             ${output}


Get Software Version
    [Documentation]
    ...     Get active software version
    ...
    ...     | alias | AdminConnection object or if used, string name alias |
    ...
    ...     *Returns*   active SW version string
    ...
    [Arguments]          ${alias}=gnb-0-OAM-http-session
    ${software_info}=    admin.Get Software Info     connection=${alias}
    ${sw_version}=       Set Variable    ${software_info['Active SW version']}
    RETURN             ${sw_version}


Get COAM Bts Info
    [Documentation]
    ...     Gets BTS info
    ...
    ...     | alias   | AdminConnection object or if used, string name alias |
    ...     | timeout | Time to wait for positive procedure result |
    ...
    ...     *Returns*   bts info dictionary
    ...
    [Arguments]          ${alias}=gnb-0-OAM-http-session   ${timeout}=30
    ${bts_info}=         admin.Get BTS Info     connection=${alias}   timeout=${timeout}
    RETURN             ${bts_info}


Verify COAM Cell Setup
    [Documentation]
    ...     Verify Specific Cell status and BTS Cell setup status
    ...
    ...     *Scope* Internal
    ...
    ...     | alias     | AdminConnection object or if used, string name alias |
    ...     | cell_id   | Id of cell |
    ...     | cell_type | possible values: nr for 5G, lte for 4G |
    ...     | timeout   | Time to wait for positive procedure result |
    ...     | use_cache | if false the cell info is fetched otherwise use info from previous call |
    ...
    ...     *Note*  This KW is often used inside a loop over all cells. As the cell order in the response is not fix,
    ...     it could be needed to use the cached response within the loop. Don't forget to unset the cache container
    ...     variable P_CACHED_CELL_STATUS if caching is True!
    ...
    ...     *Returns*   distname of the given cell if cell setup passed otherwise raises exception
    ...
    [Arguments]    ${alias}=gnb-0-OAM-http-session    ${cell_id}=0   ${cell_type}=nr  ${timeout}=30   ${use_cache}=${False}
    ${cache_is_filled}   Get Variable Value  ${P_CACHED_CELL_STATUS[${cell_id}]['id']['internal']}
    IF    '${cache_is_filled}' == '${None}'
        ${cell_info}    admin.Get Cells Info    cell_type=${cell_type}     timeout=${timeout}    connection=${alias}
        ${cell_info}  Evaluate  sorted(${cell_info}, key=lambda x: natsort.natsort_keygen()(x['id']['internal']))
        ...    modules=natsort
        Set Suite Variable    ${P_CACHED_CELL_STATUS}    ${cell_info}
    END

    ${internal_cell_dist_id}=  Set Variable   ${P_CACHED_CELL_STATUS[${cell_id}]['id']['configuration']}
    Log  [INFO] ${internal_cell_dist_id} CELL STATUS: ${P_CACHED_CELL_STATUS[${cell_id}]['status']['operationalState']}
    ...     console=${P_console}
    ${cell_status}=   Set Variable  ${P_CACHED_CELL_STATUS[${cell_id}]['status']}
    Nidd Value Should Be Equal    ${cell_status['operationalState']}       Enabled
    Nidd Value Should Be Equal    ${cell_status['blockingState']}          Unblocked
    Nidd AvailabilityStatus Value Should Be One Of   ${cell_status}        Degraded,Online
    Nidd Value Should Be Equal    ${cell_status['administrativeState']}    Unlocked
    ${bts_status}=    admin.Get Bts Statuses    timeout=${timeout}      connection=${alias}
    Nidd Value Should Be Equal    ${bts_status['operationalState']}        Enabled
    Nidd Value Should Be Equal    ${bts_status['proceduralState']}         OnAir
    Nidd Value Should Be Equal    ${bts_status['blockingState']}           Unblocked
    [Teardown]
    IF   '${use_cache}' == '${False}'    Set Suite Variable  ${P_CACHED_CELL_STATUS}  ${None}
    RETURN  ${internal_cell_dist_id}


Get AvailabilityStatus From Status Dictionary
    [Documentation]
    ...     Returns the availabilityStatus from a state dictionary
    ...     if this key exists. With CNI-61110 this state is omitted
    ...     in cases it was set to Online prior to this CNI.
    ...     So this KW should avoid key errors in case of direct access!
    ...
    ...     *Scope* Internal
    ...
    ...     | status_dict | dictionary holding current state information |
    ...
    ...     *Returns*  current availabilityStatus or 'not applicable (CNI-61110)' to indicate Online
    ...
    [Arguments]     ${status_dict}
    ${key_exists}   Run Keyword And Return Status
    ...     Dictionary Should Contain Key   ${status_dict}  availabilityStatus
    ${availability_state}   Set Variable If  ${key_exists}==${True}
    ...     ${status_dict['availabilityStatus']}    not applicable (CNI-61110)
    RETURN    ${availability_state}
