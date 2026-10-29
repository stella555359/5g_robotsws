*** Settings ***
Documentation     Keywords related to gNB handling

Library    Collections
Library    String
Library    DateTime
Library    OperatingSystem
Library    ta_attenuator
Library    taf.sbts.oam.coam.admin                      WITH NAME   admin

Library    taf.transport.ssh                            WITH NAME   ssh
Library    taf.config.scf                               WITH NAME   scf
Library    taf.rfrl.common_resources.python.SWConfig    WITH NAME   swconf
Library    python/gnb.py                                WITH NAME   gnb_internal
Library    python/CustomizeCollections.py               WITH NAME   data_ops_py
Library    python/testline_information.py

Resource   connect.robot
Resource   testline.robot
Resource   coam_ulm.robot
Resource   networking.robot
Resource   aashell.robot


*** Variables ***
${P_console}                ${False}  # output to console can be enabled via "Set Console Output" from testline.robot
${P_ORIG_GNB_SWCONFIG}      ${None}
@{P_INTERNAL_CELL_DIST_ID}
&{P_CACHED_CELLINFO}        &{EMPTY}

*** Keywords ***

Wait Until Node To Be Onair State For All Cells With Different Technologies
    [Documentation]  This Keyword waits until the node is onAir and all its cells are enabled
    ...
    ...     | node_id        | Id/Number of Node (eNB|gNB) |
    ...     | node_type      | Node type; possible values: (gnb|enb |
    ...     | timeout        | time till gNB must be on air |
    ...     | retry_interval | Time to wait next retry. |
    ...     | cell_types     | The types of cells to check (default are all types): nr, lte, wcdma, gsm |

    [Arguments]    ${timeout}=600s   ${retry_interval}=20s   ${node_id}=${0}   ${node_type}=gnb   ${cell_types}=${None}

    Wait Until Keyword Succeeds    ${timeout}
    ...                            ${retry_interval}
    ...                            Node Should Be Onair State For All Cells With Different Technologies   node_id=${node_id}
    ...                                                                                                   node_type=${node_type}
    ...                                                                                                   cell_types=${cell_types}


Node Should Be Onair State For All Cells With Different Technologies
    [Documentation]  This Keyword checks if the node is onAir and all its cells are enabled
    ...
    ...     | node_id        | Id/Number of Node (eNB|gNB) |
    ...     | node_type      | Node type; possible values: (gnb|enb) |
    ...     | cell_types     | The types of cells to check (default are all types): nr, lte, wcdma, gsm |

    [Arguments]   ${node_id}=${0}   ${node_type}=gnb   ${cell_types}=${None}

    ${allowed_cell_types}    Create List    nr  lte  wcdma  gsm
    IF   ${cell_types}==${None}
        ${cell_types}       Set Variable   ${allowed_cell_types}
    ELSE
        List Should Contain Sub List   ${allowed_cell_types}   ${cell_types}
        ...                            msg=Allowed cell types are: ${allowed_cell_types}
    END

    ${oam_alias}    Setup OAM Http Session   node_id=${node_id}   node_type=${node_type}
    ${cell_list}    admin.Get Cell List    connection=${oam_alias}

    FOR   ${cell_type}   IN   @{cell_types}

        ${node_supports_cell_type}    Run Keyword And Return Status   Dictionary Should Contain Key     ${cell_list['cells']}   ${cell_type}
        IF    ${node_supports_cell_type}==${False}   CONTINUE

        FOR   ${cell}   IN   @{cell_list['cells']['${cell_type}']}
            Should Be Equal As Strings   ${cell['status']['operationalState']}        enabled      ignore_case=True
            Should Be Equal As Strings   ${cell['status']['blockingState']}           Unblocked    ignore_case=True
            Should Be Equal As Strings   ${cell['status']['administrativeState']}     Unlocked     ignore_case=True
            IF   '${cell['status'].get('availabilityStatus')}' == '${None}'
                Log   ${cell['id']['configuration']}: availabilityStatus is 'not applicable (CNI-61110)'   console=${P_console}
            ELSE
                Should Be Equal As Strings     ${cell['status']['availabilityStatus']}   degraded  ignore_case=True
            END
        END
    END

    ${bts_status}    admin.Get Bts Statuses   connection=${oam_alias}
    Should Be Equal As Strings   ${bts_status['proceduralState']}       OnAir     ignore_case=True
    Should Be Equal As Strings   ${bts_status['operationalState']}      Enabled   ignore_case=True




Wait Until All GNBs To Be Onair State
    [Documentation]
    ...     Wait for all gNBs or eNBs to be onAir dependent on the given ``node_type``.
    ...     Use KW `Wait until Node to be onair state` to iterate over all
    ...     defined gNBs/enbs defined in TL init file.
    ...
    ...     *Note* works with COAM
    ...
    ...     | node_type | Node type; possible values: (gnb|enb) |
    ...     | timeout   | Time until all gNBs must be up      |
    ...
    [Arguments]    ${node_type}=gnb     ${timeout}=600s
    ${node_num}   Get Length    ${tl.${node_type}s}
    FOR    ${node_id}    IN RANGE    ${node_num}
           Wait Until Node To Be Onair State  node_type=${node_type}  node_id=${node_id}    timeout=${timeout}
    END


Wait Until Node To Be Onair State
    [Documentation]
    ...     Wait for Node to be onAir, checked via oam interface.
    ...     Currently checks cell on air for 1 DU/comu.
    ...
    ...     | node_id        | Id/Number of Node (eNB|gNB) |
    ...     | node_type      | Node type; possible values: (gnb|enb |
    ...     | timeout        | time till gNB must be on air |
    ...     | retry_interval | Time to wait next retry. |
    ...
    [Arguments]    ${node_id}=${0}   ${node_type}=gnb   ${timeout}=600s   ${retry_interval}=20s
    IF          "${node_type}"=="gnb"
        ${cell_type}    Set Variable   nr
    ELSE IF     "${node_type}"=="enb"
        ${cell_type}    Set Variable   lte
    ELSE
        Fail    Wrong node_type '${node_type}'! allowed: enb|gnb
    END

    ${class_name}   Set Variable If   '${node_type}'=='gnb'   NRCEL   LNCEL
    ${oam_alias}    connect.Setup OAM Http Session   node_id=${node_id}   node_type=${node_type}
    ${list_cells}   testline.Get All Ids Of Class   node_id=${node_id}   node_type=${node_type}   alias=${oam_alias}   class=${class_name}
    ${num_of_cells}   Get Length   ${list_cells}

    IF    ${num_of_cells} < 1   FAIL   No ${class_name} configured!
    ${status}   Run Keyword And Return Status   Wait Until Keyword Succeeds   ${timeout}   ${retry_interval}
    ...   Verify That Cells Are Onair With COAM   oam_alias=${oam_alias}   num_of_cells=${num_of_cells}   type=${cell_type}
    IF   ${status}   RETURN   ${status}

    ${active_alarms}   admin.Get Active Alarms   connection=${oam_alias}
    ${nbr_alarms}   Get Length   ${active_alarms}
    Log List   ${active_alarms}
    Log   ${node_type}_${node_id} has ${nbr_alarms} active alarm(s), check log file for further info!   console=${P_console}
    FAIL   KW 'Verify that cells are onair with COAM' failed!


Check FaultId In Node Active Alarm List
    [Documentation]
    ...     Check faultId in Node active alarm list, checked via oam interface.
    ...     Argument ``node_type`` if it is done for either gnb or enb.
    ...
    ...     | node_id   | Id/Number of Node (eNB|gNB) |
    ...     | node_type | Node type; possible values: (gnb|enb) |
    ...
    [Arguments]   ${expected_fault_number}   ${node_type}=gnb   ${node_id}=${0}
    ${oam_alias}   connect.Setup OAM Http Session   node_id=${node_id}   node_type=${node_type}
    ${active_alarms}   admin.Get Active Alarms   connection=${oam_alias}
    ${faults_objects_string}   Convert To String  ${active_alarms}
    ${resultTestDir}    testline.Get Testcase Log Directory
    Create File  path=${resultTestDir}/${node_type}_active_alarms.txt  content=${faults_objects_string}
    Should Contain  ${faults_objects_string}  ${expected_fault_number}


Get Current Alarms From Node
    [Documentation]
    ...     Get Current active alarm list from given node, checked via admin interface.
    ...     Argument ``node_type`` if it is done for either gnb or enb.
    ...     This keyword creates a log file containing the current alarms in the
    ...     test case or test suite log directory dependent on the scope the keyword
    ...     was called from.
    ...
    ...     | node_id   | Id/Number of Node (eNB|gNB) |
    ...     | node_type | Node type; possible values: (gnb|enb) |
    ...     | console | (optional) enable/disable printing of active alarms to console; possible values: (True|False); default: console=${P_console} |
    ...
    ...     *Returns*   2 values: list of active alarms and formatted alarm table string
    ...
    [Arguments]   ${node_type}=gnb   ${node_id}=${0}    ${console}=${P_console}


    ${oam_alias}   connect.Setup OAM Http Session  node_id=${node_id}  node_type=${node_type}
    ${active_alarms}   admin.Get Active Alarms   connection=${oam_alias}
    ${nbr_alarms}   Get Length   ${active_alarms}
    Log List   ${active_alarms}
    Log   ${node_type.upper()}-${node_id} has following ${nbr_alarms} active alarm(s):   console=${console}

    ${faults_table_string}=   Set Variable   ${EMPTY}
    ${faults_table_string}=   Set Variable
    ...   ${faults_table_string}\ \ | ${{'observationTime'.center(19, ' ')}} | ${{'faultId'.center(7, ' ')}} | ${{'faultName'.ljust(80, ' ')}} |${\n}
    ${faults_table_string}=   Set Variable   ${faults_table_string}\ \ |${{'-' * 21}}|${{'-' * 9}}|${{'-' * 82}}|${\n}
    Log   \ \ | ${{'observationTime'.center(19, ' ')}} | ${{'faultId'.center(7, ' ')}} | ${{'faultName'.ljust(80, ' ')}} |    console=${console}
    Log   \ \ |${{'-' * 21}}|${{'-' * 9}}|${{'-' * 82}}|   console=${console}
    FOR   ${i}   IN RANGE   ${nbr_alarms}
       ${bts_time}   Collections.Get From Dictionary   ${active_alarms[${i}]}   btsObservationTime
       ${f_id}       Collections.Get From Dictionary   ${active_alarms[${i}]}   faultId
       ${f_name}     Collections.Get From Dictionary   ${active_alarms[${i}]}   faultName
       ${bts_time_formatted}=   DateTime.Convert Date     ${bts_time[:-9]}    date_format=%Y%m%d%H%M%S    result_format=%d.%m.%Y %H:%M:%S
       ${f_id_str}=   Convert To String    ${f_id}
       ${faults_table_string}=   Set Variable
       ...   ${faults_table_string}\ \ | ${bts_time_formatted.ljust(19, ' ')} | ${f_id_str.center(7, ' ')} | ${f_name.ljust(80, ' ')} |${\n}
       Log    \ \ | ${bts_time_formatted.center(19, ' ')} | ${f_id_str.center(7, ' ')} | ${f_name.ljust(80, ' ')} |    console=${console}
    END

    ${faults_objects_string}   Convert To String   ${active_alarms}

    ${value_in_scope}    Get Variable Value    ${TEST_NAME}
    IF    '${value_in_scope}'!='${None}'
        ${resultDir}   testline.Get Testcase Log Directory
    ELSE
        ${resultDir}   testline.Get Test Suite Log Directory
    END

    ${timestamp_prefix}         DateTime.Get Current Date    result_format=%Y%m%d_%H%M%S
    OperatingSystem.Create File   path=${resultDir}/${timestamp_prefix}_${node_type.upper()}-${node_id}_current_active_alarms.txt
    ...    content=${faults_table_string}{\n}${faults_objects_string}
    RETURN   ${active_alarms}   ${faults_table_string}


Reset Node
    [Documentation]
    ...     Send RESET SITE via OAM interface and
    ...     try to reconnect the Admin API.
    ...
    ...     | node_id   | Id/Number of Node (eNB|gNB) |
    ...     | node_type | Node type; possible values: (gnb|enb) |
    ...
    [Arguments]   ${node_type}=gnb   ${node_id}=${0}
    Log   ${\n}Reset Node ${node_type}-${node_id} by admin api.   console=${P_console}
    ${oam_alias}   connect.Setup OAM Http Session  node_id=${node_id}  node_type=${node_type}
    admin.Reset Site   wait_for_reconnection=${True}   connection=${oam_alias}
    Log   ${\n}Reset Site executed, try to reconnect the Admin API...   console=${P_console}
    connect.Reconnect OAM Http Session   node_id=${node_id}   node_type=${node_type}
    Log    ${\n}Admin API reconnected.   console=${P_console}


Wait For Node State
    [Documentation]
    ...     Waits until gNB airscale is in state (configured,commissioned).
    ...
    ...     | target_proceduralState | State which is needed to be reached    |
    ...     | node_type              | gnb or enb                             |
    ...     | node_id                | Id/Number of gNB                       |
    ...     | timeout                | Time until state must be reached       |
    ...     | admin_api_log_path     | directory path to store admin api logs |
    ...
    [Arguments]   ${target_proceduralState}=configured,commissioned   ${node_type}=gnb   ${node_id}=${0}
    ...   ${timeout}=1min   ${admin_api_log_path}=${OUTPUT DIR}/admin_logs

    OperatingSystem.Create Directory   ${admin_api_log_path}
    Log    ... waiting up to ${timeout} for node ${node_type.upper()}-${node_id} to be in state {${target_proceduralState}}   console=${P_console}
    ${oam_alias}   connect.Setup OAM Http Session   node_type=${node_type}   node_id=${node_id}   timeout=${timeout}
    ...   admin_api_log_path=${admin_api_log_path}
    ${current_proceduralState}=   Wait Until Keyword Succeeds   ${timeout}   5s   Check Matching Pattern In Node State
    ...   node_admin_alias=${oam_alias}   target_proceduralState=${target_proceduralState}
    Log   Node ${node_type.upper()}-${node_id} is now in state '${current_proceduralState}'!  console=${P_console}
    RETURN   ${current_proceduralState}


Wait Until All GNBs Have First X2 Link Status Available
    [Documentation]
    ...     Wait for all gNBs to have Available X2 Link Status
    ...     onAir state is checked via OAM.
    ...
    ...     | timeout | Time until all gNBs must have Available X2 Link Status |
    ...
    [Arguments]   ${timeout}=600s
    ${gnb_num}   Get Length   ${tl.gnbs}
    FOR   ${gnb_id}   IN RANGE   ${gnb_num}
       Wait Until X2 Link Status Is Available   gnb_id=${gnb_id}   timeout=${timeout}   lteEnbId_Idx=${0}
    END


Wait Until X2 Link Status Is Available
    [Documentation]
    ...     Wait until gNB has setup the X2 link.
    ...     *Note* works with classical GNB. And will adapt for Cloud CU
    ...
    ...     | gnb_id        | Id/Number of gNB |
    ...     | timeout       | time till gNB must have Available X2 Link Status |
    ...     | lteEnbId_Idx  |    |
    ...
    [Arguments]   ${gnb_id}=${0}   ${timeout}=600s   ${lteEnbId_Idx}=${0}
    Wait Until Keyword Succeeds   ${timeout}   20s
    ...   Check GNB X2 Link Status Is Available   gnb_id=${gnb_id}   lteEnbId_Idx=${lteEnbId_Idx}
    Log   gNB${gnb_id} have Available X2 Link Status   console=${P_console}


Reset All GNBs And Wait For Availability
    [Documentation]
    ...
    ...    | timeout | timeout value |
    ...
    [Arguments]   ${timeout}=600s
    ${gnb_num}     Get Length   ${tl.gnbs}
    FOR    ${gnb_id}    IN RANGE    ${gnb_num}
        Reset GNB Via OAM And Wait For Availability    gnb_id=${gnb_id}   timeout=${timeout}
    END


Reset GNB Via OAM And Wait For Availability
    [Documentation]
    ...     Reset gNB via oam interface and check RAP, DUs, FRM to be up
    ...
    ...     | gnb_id  | Id/Number of gNB |
    ...     | timeout | time till gNB must up agin |
    ...
    [Arguments]    ${gnb_id}=${0}   ${timeout}=600s
    Perform GNB Reboot         gnb_id=${gnb_id}
    Wait Until All DUs Up      gnb_id=${gnb_id}
    Wait For Minimum Required State For Cell Setup   node_id=${gnb_id}   timeout=${timeout}


Wait Until All DUs Up
    [Documentation]
    ...   Waits till all DU of a gNB are up
    ...
    ...   | gnb_id             | Id/Number of gNB |
    ...   | timeout            | Time until DUs have to be up |
    ...   | accept_sleep_state | Boolean switch to consider unit/board/cpu state 'sleep' as synonymous to state 'ready'. Set to False by default. |
    ...
    [Arguments]    ${gnb_id}=0    ${timeout}=10 min    ${accept_sleep_state}=${False}
    ${du_num}    Get Length    ${tl.gnbs[${gnb_id}].dus}
    FOR    ${du}    IN RANGE    ${du_num}
        Wait Until DU Ready    gnb_id=${gnb_id}    du_id=${du}    timeout=${timeout}    accept_sleep_state=${accept_sleep_state}
    END


Wait Until DU Ready
    [Documentation]
    ...   Waits till all Common and Capacity Unit of a DU are up
    ...
    ...   | gnb_id             | Id/Number of gNB |
    ...   | du_id              | Id/Number of DU |
    ...   | timeout            | Time until Common+CapacityUnit have to be up |
    ...   | accept_sleep_state | Boolean switch to consider unit/board/cpu state 'sleep' as synonymous to state 'ready'. Set to False by default. |
    ...
    [Arguments]    ${gnb_id}    ${du_id}    ${timeout}=10 min    ${accept_sleep_state}=${False}

    Log    Wait until gNB${gnb_id} DU${du_id} is ready    console=${P_console}
    ${common_units}    Get Length    ${tl.gnbs[${gnb_id}].dus[${du_id}].airscale.common_units}
    FOR    ${comu}    IN RANGE    ${common_units}
       Wait For GNB Common And Capacity Unit Up    gnb_id=${gnb_id}  du_id=${du_id}  comu_id=${comu}   timeout=${timeout}
    ...     accept_sleep_state=${accept_sleep_state}
    END
    Log    gNB${gnb_id} DU${du_id} is ready!    console=${P_console}


Wait For GNB Common And Capacity Unit Up
    [Documentation]
    ...
    ...   | gnb_id             | Id of gnb [0.. ] |
    ...   | du_id              | Id of DU [0.. ] |
    ...   | comu_id            | Id of Common Unit [0..1] |
    ...   | timeout            | Time until Common+CapacityUnit have to be up |
    ...   | accept_sleep_state | Boolean switch to consider unit/board/cpu state 'sleep' as synonymous to state 'ready'. Set to False by default. |
    ...
    [Arguments]    ${gnb_id}=0    ${du_id}=0  ${comu_id}=0  ${timeout}=10min  ${accept_sleep_state}=${False}

    ${comu_ssh_alias}  Wait Until Keyword Succeeds   ${timeout}  10s
    ...     connect.Connect To Node Common Unit  node_id=${gnb_id}  du_id=${du_id}    comu_id=${comu_id}

    Wait Until Keyword Succeeds   ${timeout}   20s   gnb_internal.Check All Boards And Cpus Are Ready
    ...     connection=${comu_ssh_alias}   accept_sleep_state=${accept_sleep_state}


Wait For Minimum Required State For Cell Setup
    [Documentation]
    ...     Waits until all pre-conditions for cell setup on all or specific cell(s) are reached.
    ...     Utilizes only admin API to check, session setup must be possible within 3min!
    ...     TD 29.01.26: remove F1 link check as it is unreliable in some situations
    ...
    ...     | node_type     | either gnb or enb (gnb|enb) |
    ...     | node_id       | Id of gNB|eNB [0.. ]        |
    ...     | cell_id       | Id of cell [0..x|all]       |
    ...     | ru_id         | Id of RU [0..x|all]         |
    ...     | timeout       | TO for individual checks    |
    ...     | kw_timeout    | overall TO for the whole KW |
    ...
    [Arguments]   ${node_type}=gnb   ${node_id}=${0}   ${cell_id}=all   ${ru_id}=all   ${timeout}=5min   ${kw_timeout}=60min
    [Timeout]     ${kw_timeout}
    Log     ${\n}Waiting until node '${node_type}-${node_id}' is ready for Cell Setup ...   console=${P_console}
    ${oam_alias}    connect.Setup OAM Http Session   node_type=${node_type}   node_id=${node_id}

    Wait Until Keyword Succeeds   ${timeout}   20s   coam_ulm.Get BTS Active Sync Source   alias=${oam_alias}
    Wait Until Keyword Succeeds   ${timeout}   20s   Verify Single BTS Is Configured   connection=${oam_alias}

    IF   '${ru_id}'=='all'
        Wait Until Keyword Succeeds   ${timeout}   20s      Verify All Radios Are Online    connection=${oam_alias}
    ELSE
        Wait Until Keyword Succeeds   ${timeout}   20s      Verify Single Radio Is Online   connection=${oam_alias}    ru_id=${ru_id}
    END

    IF   '${cell_id}'=='all'
        Wait Until Keyword Succeeds   ${timeout}   20s      Verify All Cells Are Configured  node_type=${node_type}   connection=${oam_alias}

    ELSE
        Wait Until Keyword Succeeds   ${timeout}   20s
        ...    Verify Single Cell Is Configured   node_type=${node_type}   connection=${oam_alias}   cell_id=${cell_id}
    END
    Sleep   30s   reason=problems with cell setup on AP


Verify Single BTS Is Configured
    [Documentation]
    ...     Checks if gNB is Configured.
    ...
    ...     | connection | connection alias |
    ...
    [Arguments]   ${connection}={}
    ${bts_state}   admin.Get Mrbts State   connection=${connection}
    Log    [INFO] BTS STATE : ${bts_state}   console=${P_console}
    Nidd Value Should Be One Of   ${bts_state}   Configured, IntegratedToRan, onAir


Verify Single Radio Is Online
    [Documentation]
    ...     Checks if a given RU/rmod is Online.
    ...     Utilizes only coam M-plane based API to check it.
    ...     *Note* Don't forget to unset the cache container var P_CACHED_FRM_STATUS if caching is True!
    ...
    ...     | connection | connection alias |
    ...     | ru_id      | Id of RU [0.. ]  |
    ...     | use_cache  | use global cache container [False|True] |
    ...
    [Arguments]   ${connection}={}   ${ru_id}=0   ${use_cache}=${False}
    ${cache_is_filled}   Get Variable Value   ${P_CACHED_FRM_STATUS[${ru_id}]['productName']}

    IF   '${cache_is_filled}'=='${None}'
        ${frm_info}   admin.Get Frm   connection=${connection}
        ${frm_info}  Evaluate  sorted(${frm_info}, key=lambda x: natsort.natsort_keygen()(x['id']['configuration']))
        ...    modules=natsort
        Set Suite Variable   ${P_CACHED_FRM_STATUS}   ${frm_info}
    END

    ${radio_state}   Get AvailabilityStatus From Status Dictionary   ${P_CACHED_FRM_STATUS[${ru_id}]['status']}
    Log   [INFO] ${P_CACHED_FRM_STATUS[${ru_id}]['id']['configuration']} : ${radio_state}   console=${P_console}
    Nidd AvailabilityStatus Value Should Be One Of   ${P_CACHED_FRM_STATUS[${ru_id}]['status']}   Degraded, Online
    [Teardown]   Change Test Suite Variable For FRM Status    use_cache=${use_cache}   P_CACHED_FRM_STATUS=${P_CACHED_FRM_STATUS}


Change Test Suite Variable For FRM Status
    [Arguments]     ${use_cache}    ${P_CACHED_FRM_STATUS}
    IF   '${use_cache}'=='${False}'   Set Suite Variable   ${P_CACHED_FRM_STATUS}   ${None}


Verify All Radios Are Online
    [Documentation]
    ...     Checks if  all RU/rmod are Online.
    ...     Utilizes only coam M-plane based API to check it.
    ...
    ...     | connection | connection alias |
    ...
    [Arguments]   ${connection}={}
    ${number_of_radios}   Get Number Of RMOD   connection=${connection}
    FOR   ${ru_id}   IN RANGE   ${number_of_radios}
       Verify Single Radio Is Online   connection=${connection}   ru_id=${ru_id}   use_cache=${True}
    END
    Log   ${\n}----------------------------------------------------------------------   console=${P_console}
    [Teardown]   Set Suite Variable   ${P_CACHED_FRM_STATUS}   ${None}


Verify Single Cell Is Configured
    [Documentation]
    ...     Checks if a given cell is configured or 'not initialized'.
    ...     Utilizes only coam M-plane based API to check it.
    ...     As eNB/LTE cells don't support procedural status we check then availability  status instead.
    ...     *Note* Don't forget to unset the cache container var P_CACHED_CELL_STATUS if caching is True!
    ...
    ...     | connection | connection alias |
    ...     | cell_id    | Id of cell [0.. ] |
    ...     | use_cache  | use global cache container [False|True] |
    ...     | node_type  | either gnb or enb, defines the cell type [gnb|enb] |
    ...
    [Arguments]   ${connection}={}   ${cell_id}=0   ${use_cache}=${False}   ${node_type}=gnb
    ${cell_type}   Set Variable If   '${node_type}'=='gnb'   nr
    ...                              '${node_type}'=='enb'   lte
    ...                              ${True}                 unknown

    ${cache_is_filled}   Get Variable Value   ${P_CACHED_CELL_STATUS[${cell_id}]['id']['internal']}
    IF  '${cache_is_filled}'=='${None}'
        ${cell_info}   admin.Get Cells Info   connection=${connection}   cell_type=${cell_type}
        ${cell_info}  Evaluate  sorted(${cell_info}, key=lambda x: natsort.natsort_keygen()(x['id']['internal']))
        ...    modules=natsort
        Set Suite Variable    ${P_CACHED_CELL_STATUS}   ${cell_info}
    END

    IF   '${node_type}'=='gnb'
        ${check_status}     Set Variable   ${P_CACHED_CELL_STATUS[${cell_id}]['status']['proceduralStatus']}
        Log   [INFO] ${P_CACHED_CELL_STATUS[${cell_id}]['id']['configuration']} : ${check_status}   console=${P_console}
        Nidd Value Should Be One Of   ${check_status}   Configured, not initialized
    ELSE
        ${check_status}     Set Variable  ${P_CACHED_CELL_STATUS[${cell_id}]['status']}
        Log   [INFO] ${P_CACHED_CELL_STATUS[${cell_id}]['id']['configuration']} : ${check_status}   console=${P_console}
        Nidd AvailabilityStatus Value Should Be One Of   ${check_status}   Offline, Online, Degraded
    END
    [Teardown]    Set Suite Variable For Cell Status      use_cache=${use_cache}      P_CACHED_CELL_STATUS=${P_CACHED_CELL_STATUS}



Set Suite Variable For Cell Status
    [Arguments]     ${use_cache}    ${P_CACHED_CELL_STATUS}
    IF   '${use_cache}'=='${False}'   Set Suite Variable   ${P_CACHED_CELL_STATUS}   ${None}



Verify All Cells Are Configured
    [Documentation]
    ...     Checks if all cell are configured.
    ...     Utilizes only coam M-plane based API to check it.
    ...     Returns the number of configured cells of the type corresponding to given node_type.
    ...
    ...     | connection   | connection alias |
    ...     | node_type    | either gnb or enb, defines the cell type (nr or lte) |
    ...     | fail_if_zero | optional boolean flag to make keyword fail (when setting fail_if_zero=${True})
    ...                      or to not fail (fail_if_zero=${False} default), even is  number of cells is zero  |
    ...
    [Arguments]   ${connection}={}   ${node_type}=gnb   ${fail_if_zero}=${False}
    Log To Console    ${\n}Verifying that all cells of BTS node reachable via alias '${connection}' are in 'Configured' state ...

    IF          '${node_type}'=='gnb'
        ${number_of_cells}    testline.Get Number Of Cells  cell_type=NRCEL  connection=${connection}  fail_if_zero=${fail_if_zero}
    ELSE IF     '${node_type}'=='enb'
        ${number_of_cells}    testline.Get Number Of Cells  cell_type=LNCEL  connection=${connection}  fail_if_zero=${fail_if_zero}
    ELSE
        FAIL     Unsupported node_type ${node_type}!
    END

    Log         Fetch number of cells for node ${node_type}: ${number_of_cells} found.   console=${False}
    FOR     ${cell_id}      IN RANGE   ${number_of_cells}
            Verify Single Cell Is Configured   node_type=${node_type}  connection=${connection}  cell_id=${cell_id}  use_cache=${True}
    END
    Log   ----------------------------------------------------------------------   console=${P_console}
    RETURN    ${number_of_cells}
    [Teardown]  Set Suite Variable  ${P_CACHED_CELL_STATUS}  ${None}


Perform GNB Reboot
    [Documentation]
    ...     Reboot gNB via oam interface
    ...
    ...     | gnb_id  | Id/Number of gNB |
    ...
    [Arguments]   ${gnb_id}=${0}
    Log   Reboot of gNB${gnb_id} triggered    console=${P_console}

    IF   '${tl_info.deployment_type(${gnb_id})}'=='classical'
        gnb.Reset Node   node_type=gnb   node_id=${gnb_id}
    ELSE
        Fail    Unsupported Node type!
    END

    Log    Reboot of gNB${gnb_id} finished!    console=${P_console}


Perform GNB Reset Unit
    [Documentation]
    ...
    ...     | dist_name | Runtime view dist name, e.g. /MRBTS-1/RAT-1/RUNTIME_VIEW-1/MRBTS_R-1/EQM_R-1/APEQM_R-1/CABINET_R-1/SMOD_R-1/GNSSE_R-1 |
    ...     | gnb_id          | Id/Number of gNB |
    ...     | reset_type      |  can be Soft, Hard or Warm |
    ...     | timeout         |  Timeout for the operation. |
    ...     | detailed_output |  return full request response when True |
    ...
    ...     See TAF documentation: https://docs.taf.nsn-rdnet.net/taf.sbts.oam.coam.admin/#taf.sbts.oam.coam.admin.interface.admin.reset_unit
    ...
    [Arguments]   ${dist_name}   ${gnb_id}=${0}   ${reset_type}=Soft   ${timeout}=600
    ...   ${detailed_output}=False   &{kwargs}
    ${oam_alias}   connect.Setup OAM Http Session   node_type=gnb   node_id=${gnb_id}
    Log    Reboot of ${dist_name} starting!   console=${P_console}
    admin.Reset Unit   dist_name=${dist_name}   reset_type=${reset_type}
    ...   timeout=${timeout}    &{kwargs}
    ...                 detailed_output=${detailed_output}    connection=${oam_alias}
    Log    Reboot of ${dist_name} finished!    console=${P_console}


Store Current SCF From GNB
    [Documentation]
    ...
    ...    | gnb_id     | Id of gnb [0.. ] |
    ...    | target_dir | save SCF to path |
    ...
    ...    *Returns*   scf path for further usage
    ...
    [Arguments]   ${gnb_id}=${0}   ${target_dir}=${None}
    ${ORIG_SCF}   gnb.Get SCF From GNB   gnb_id=${gnb_id}   target_dir=${target_dir}
    OperatingSystem.Run   cp ${ORIG_SCF} ${ORIG_SCF}.orig
    Set Suite Variable   ${P_ORIG_SCF}   ${ORIG_SCF}.orig
    RETURN   ${P_ORIG_SCF}


Get SCF From GNB
    [Documentation]
    ...     This KW downloads the SCF from the given ``gnb_id``
    ...     to the given ``target_dir`` on the local TestPC.
    ...
    ...     | gnb_id     | Id/Number of gNB |
    ...     | target_dir | save SCF to path |
    ...     | scf_name   | save SCF with desired name |
    ...     | export_type | one of configuration, configurationAndRuntimeObjects, runtimeObjects |
    ...
    ...     *Returns*   scf path for further usage
    ...
    [Arguments]   ${gnb_id}=${0}   ${target_dir}=${None}   ${scf_name}=${None}   ${export_type}=${None}
    ${gnbScfName}   Set Variable If   '${scf_name}'=='${None}'   SCFC_gNB${gnb_id}_DU.xml   ${scf_name}

    Set Suite Variable   ${private_gnbScfName${gnb_id}}   ${gnbScfName}

    IF   '${target_dir}'=='${None}'
        ${resultConfigDir}      testline.Get Test Suite Config Directory
    ELSE
        ${resultConfigDir}      Set Variable    ${target_dir}
    END

    Get SCF From GNB With COAM   gnbScfName=${gnbScfName}   resultConfigDir=${resultConfigDir}   gnb_id=${gnb_id}   export_type=${export_type}
    RETURN   ${resultConfigDir}/${gnbScfName}


Store Current Swconfig From GNB
    [Documentation]
    ...    This KW uses the KW `Get swconfig from gNB` and stores the path to the fetched swconfig in
    ...    the suite variable P_ORIG_GNB_SWCONFIG.
    ...
    ...    | gnb_id     | Id of gnb [0.. ] |
    ...    | target_dir | save swconfig to path |
    ...
    ...    *Returns*   file path to original swconfig.txt file
    ...
    [Arguments]   ${gnb_id}=${0}   ${target_dir}=${None}

    ${ORIG_SWCONFIG}   gnb.Get Swconfig From GNB   gnb_id=${gnb_id}   target_dir=${target_dir}
    OperatingSystem.Run   mv ${ORIG_SWCONFIG} ${ORIG_SWCONFIG}.orig
    Set Suite Variable    ${P_ORIG_GNB_SWCONFIG}   ${ORIG_SWCONFIG}.orig
    RETURN   ${P_ORIG_GNB_SWCONFIG}


Get Swconfig From GNB
    [Documentation]
    ...     This KW downloads the swconfig.txt file from the given system module ``comu_id`` of
    ...     the given distributed unit ``du_id`` of the given ``gnb_id`` and stores it in the
    ...     gieven ``target_dir`` on the TestPC.
    ...
    ...     | gnb_id     | Id of gnb [0.. ] |
    ...     | du_id      | Id of DU [0.. ] |
    ...     | comu_id    | Id of Common Unit [0..1] |
    ...     | target_dir | save swconfig to path |
    ...
    ...     *Returns*   swconfig path for further usage
    ...
    [Arguments]   ${gnb_id}=${0}   ${du_id}=${0}   ${comu_id}=${0}   ${target_dir}=${None}

    IF   '${target_dir}'=='${None}'
        ${target_dir}   testline.Get Test Suite Config Directory
    END

    ${ssh_alias}   connect.Connect To Node Common Unit   node_id=${gnb_id}   du_id=${du_id}   comu_id=${comu_id}
    ssh.Download File   remote_path=/ffs/run/swconfig.txt   local_path=${target_dir}/gnb-${gnb_id}_swconfig.txt   connection=${ssh_alias}
    RETURN   ${target_dir}/gnb-${gnb_id}_swconfig.txt


Get GNB SCF Name
    [Documentation]
    ...
    ...     | gnb_id | Id/Number of gNB |
    ...
    ...     *Returns* gNB scf name stored in privat global variable private_gnbScfName${gnb_id}
    ...
    [Arguments]     ${gnb_id}=${0}
    RETURN    ${private_gnbScfName${gnb_id}}


Reload Stored Swconfig To GNB
    [Documentation]
    ...    Used for Suite Teardown or Testcase Teardown, bring back
    ...    keyword `Collect swconfig from gNB` collected swconfig.txt file.
    ...
    ...    **Example:**
    ...    | gnb.Store Current swconfig from gNB
    ...    | gnb.Reload stored swconfig to gNB
    ...
    ...    | gnb_id  | Id of gnb [0.. ] |
    ...    | du_id   | Id of DU [0.. ] |
    ...    | comu_id | Id of Common Unit [0..1] |
    ...
    [Arguments]   ${gnb_id}=${0}   ${du_id}=${0}   ${comu_id}=${0}

    ${comu_alias}   connect.Connect To Node Common Unit   node_id=${gnb_id}   du_id=${du_id}   comu_id=${comu_id}
    ssh.Upload File   local_path=${P_ORIG_GNB_SWCONFIG}   remote_path=/ffs/run/swconfig.txt   connection=${comu_alias}


Get AaShell SW Config
    [Documentation]
    ...     This keyword Prints all non default R&D parameters of RadMaster.
    ...
    ...     | rad_param | Rad Parameter [0x580017] |
    ...     | gnb_id    | Id of gnb [0.. ]         |
    ...
    ...    *Returns* IF rad_param is empty prints all non default R&D parameters of RadMaster.
    ...              Else the "Current val" of rad_param. e.g.: [u'0x0']
    ...
    [Arguments]   ${rad_param}=${EMPTY}   ${gnb_id}=${0}

    ${nonDefaultRadMaster}   Execute Aashell Command On Node   command=rad -mu \r
    ...                                                        node_id=${gnb_id}   node_type=gnb

    IF   '${rad_param}'=='${EMPTY}'
        ${radMasterValue}       Set Variable    ${nonDefaultRadMaster}
    ELSE
        ${radMasterValue}       String.Get Regexp Matches   ${nonDefaultRadMaster}    \\[${rad_param}\\] Default val = .*; Current val = (.*)   1
    END
    RETURN   ${radMasterValue}


Update SW Config File On System Module
    [Documentation]
    ...     This keyword sets the rnd params in the swconfig.txt .
    ...
    ...     | param_list     | list the update content, example input can be: ["0x4600BA=6","0x460002=6"] |
    ...     | del_param_list | list the delete content, example input can be: ["0x4600BA","0x460002"] |
    ...     | gnb_id         | Id of gnb [0.. ] |
    ...     | du_id          | Id of DU  [0.. ] |
    ...     | comu_id        | Id of Common Unit [0..1] |
    ...
    [Arguments]   ${param_list}=@{EMPTY}   ${gnb_id}=${0}   ${du_id}=${0}   ${comu_id}=${0}   ${del_param_list}=@{EMPTY}
    ${comu_alias}   connect.Connect To Node Common Unit   node_id=${gnb_id}   du_id=${du_id}   comu_id=${comu_id}
    swconf.Download SwConfig File From ASIK To Test PC    localFilePath=/tmp/swconfig_tmp.txt   asik_alias=${comu_alias}

    IF   ${del_param_list} != @{EMPTY}   swconf.Delete Parameter Of SwConfig File
    ...              parametersList=${del_param_list}   filePath=/tmp/swconfig_tmp.txt
    IF   ${param_list}!=@{EMPTY}   swconf.Modify SwConfig File
    ...              parametersList=${param_list}   filePath=/tmp/swconfig_tmp.txt

    swconf.Upload SwConfig File To ASIK And Crasign   localFilePath=/tmp/swconfig_tmp.txt   asik_alias=${comu_alias}


Get DistNames From Local SCF File
    [Documentation]
    ...
    ...     Searches for the given distname pattern in a locally stored SCF file. Together with
    ...     KW `Get SCF from gNB` it is the best choice to search for distnames if one need to search different distnames
    ...     multiple times!
    ...
    ...     *Example*
    ...     | ${scf}    | gnb.Get SCF from gNB |
    ...     | ${distnames} | Get distNames from Local SCF File | regex=MRBTS-[0-9]+ | scf_path=${scf} |
    ...     | ${distnames} | Get distNames from Local SCF File | regex=MRBTS-[0-9]+/NRBTS-[0-9]+ | scf_path=${scf} |
    ...
    ...     *Returns*   list of matching distnames
    ...
    [Arguments]   ${regex}   ${scf_path}
    ${scf_content}   OperatingSystem.Get File   ${scf_path}
    ${distNames}     gnb_internal.Get DistNames From SCF   regex=${regex}   scf_content=${scf_content}
    RETURN   ${distNames}


Get DistNames From GNB SCF
    [Documentation]
    ...
    ...     Retrieves the SCF from gNB and searches for the given distname pattern.
    ...     *Note* This KW fetches the scf file each time from the gNB. To avoid that overhead and delay
    ...     it is highly recommended to use the KW `Get distNames from Local SCF File` instead.
    ...
    ...     *Scope* Deprecated, Classical gNB only!
    ...
    ...     *Example*
    ...     | Get distNames from gNB SCF  regex=MNL-\\d+/MNLENT-\\d+/PMCADM-\\d+  gnb_id=${gnb_id}
    ...
    ...     *Returns*   list of matching distnames
    ...
    [Arguments]   ${regex}   ${gnb_id}=${0}  ${with_auto_configured_parameters}=${True}

    ${oam_alias}     connect.Setup OAM Http Session   node_type=gnb   node_id=${gnb_id}

    ${scf_content}   admin.Get Scf   parameters_save_variant=actualValues
    ...                              timeout=${20}
    ...                              connection=${oam_alias}
    ...                              with_auto_configured_parameters=${with_auto_configured_parameters}

    ${distNames}     gnb_internal.Get DistNames From SCF    regex=${regex}    scf_content=${scf_content}
    RETURN   ${distNames}


Get DistNames From GNB DU
    [Documentation]
    ...     Fetches specific distnames matching given regexp pattern from Classical GNB.
    ...     This KW could be used for specific distnames (see examples) in case the current SCF isn't locally
    ...     stored and only a single lookup must be done.
    ...     *Note* This KW can only be used for distnames shown in the 3 examples!
    ...            For all other distname pattern or in case you need to search multiple distnames sequentially
    ...            use the KW `Get distNames from Local SCF File`!
    ...
    ...     *Scope* Classical gNB !
    ...
    ...     *Example*
    ...     | Get distNames from gNB DU  regexp=MRBTS-[0-9]+
    ...     | Get distNames from gNB DU  regexp=MRBTS-[0-9]+/NRBTS-[0-9]+
    ...     | Get distNames from gNB DU  regexp=MRBTS-[0-9]+/NRBTS-[0-9]+/NRCELL-[0-9]+
    ...
    ...     | regex     | regular expression for the wanted distnames   |
    ...     | gnb_id    | gnb id from testline config                   |
    ...
    ...     *Returns*   list of matching distnames
    ...
    [Arguments]   ${regex}   ${gnb_id}=${0}
    ${oam_alias}   connect.Setup OAM Http Session   node_type=gnb   node_id=${gnb_id}
    ${content}     admin.Get Bts Info   timeout=${10}   connection=${oam_alias}
    ${distNames}   gnb_internal.Get DistNames From Json   regex=${regex}   json_obj=${content}
    RETURN   ${distNames}


Get GNB Physical Cell ID
    [Documentation]
    ...     This wrapper keyword returns a dictionary with cell name (as in SCF) as the key
    ...     and the respective physical cell id as the value. It support Classical testlines.
    ...
    ...     | gnb_id    | Id of gnb |
    ...     | du_id     | Id of du  |
    ...
    ...     *Returns*   a dictionary with key cell name and the respective physical cell id
    ...
    [Arguments]   ${gnb_id}=0
    ${oam_alias}   connect.Setup OAM Http Session   node_id=${gnb_id}
    ${cell_list}   admin.Get Cell List   connection=${oam_alias}
    ${cell_phy_cell_id}   gnb_internal.Get Phy Cell Ids   cell_info=${cell_list}
    RETURN   ${cell_phy_cell_id}


Get GNB SCF Cell Name To Cell ID Mapping
    [Documentation]
    ...     This keyword returns a dictionary with cell name (as in SCF) as the key
    ...     and the respective local cell resouce id as the value. Supports classical testline.
    ...
    ...     | gnb_id | Id of gnb [0.. ] |
    ...
    ...     *Returns*   dictionary with key cell name and the respective local cell resouce id
    ...
    [Arguments]   ${gnb_id}=0
    ${oam_alias}   connect.Setup OAM Http Session   node_id=${gnb_id}
    ${cell_info}   admin.Get Subcells Info   connection=${oam_alias}
    ${cell_lcrId_map}   gnb_internal.Get Cell Id LcrId Map   cell_info=${cell_info}
    RETURN   ${cell_lcrId_map}


Get Release Name
    [Documentation]
    ...     This keyword returns the name of the gNB SW release
    ...
    ...     | node_id | Id of gnb [0.. ] |
    ...
    ...     *Returns* release name, e.g. SBTS22R3
    ...
    [Arguments]   ${node_id}=${0}
    ${oam_alias}   connect.Setup OAM Http Session   node_id=${node_id}
    ${release}     admin.Get Sw Release Name   connection=${oam_alias}
    RETURN   ${release}


Fetch GNB Info From SCF
    [Documentation]
    ...
    ...    fetch needed gnb information to prepare Airphone keyword
    ...    If additional configuration needed, could be added into this keyword
    ...
    ...     *Scope* Internal
    ...
    ${scf_path}      gnb.Get SCF From GNB   target_dir=/tmp   gnb_id=0

    ${P_gNbCuType}   Get SCF Value From File   p_name=gNbCuType   scf_path=${scf_path}
    ${P_cellTechnology}   Get SCF Value From File By Pattern   p_name=cellTechnology   scf_path=${scf_path}   dist_name=.*NRCELL-*
    ${P_freqBandIndicatorNR}   Get SCF Value From File By Pattern   p_name=freqBandIndicatorNR   scf_path=${scf_path}   dist_name=.*NRCELL-*

    ${nrarfcn}     IF  '${P_cellTechnology}'=='TDD'   Get SCF Value From File By Pattern
    ...   p_name=nrarfcn    scf_path=${scf_path}     dist_name=.*NRCELL-*
    ${nrarfcnDl}   IF  '${P_cellTechnology}'=='FDD'   Get SCF Value From File By Pattern
    ...   p_name=nrarfcnDl   scf_path=${scf_path}   dist_name=.*NRCELL_FDD-1
    ${nrarfcnUl}   IF  '${P_cellTechnology}'=='FDD'   Get SCF Value From File By Pattern
    ...   p_name=nrarfcnUl    scf_path=${scf_path}   dist_name=.*NRCELL_FDD-1

    ${P_nrarfcn}   Set Variable If   '${P_cellTechnology}'=='TDD'   ${nrarfcn}:${nrarfcn}   ${nrarfcnUl}:${nrarfcnDl}

    FOR   ${varname}   IN   P_gNbCuType   P_cellTechnology   P_freqBandIndicatorNR   P_nrarfcn
       Set Suite Variable   ${${varname}}
    END


Get SCF Value From File
    [Documentation]
    ...
    ...    *Scope* Internal
    ...
    ...    | dist_name |  distName of a managed object   |
    ...    | p_name    |  ‘name’ attribute in <p> tage   |
    ...    | list_name |  ‘name’ attribute in <list> tag |
    ...
    ...    *Returns*    first match of given regexp
    ...
    [Arguments]   ${scf_path}   ${p_name}=${None}   ${list_name}=${None}   ${dist_name}=${None}
    scf.Load Scf   file_path=${scf_path}
    ${value}   scf.Get Value From SCF   p_name=${p_name}   list_name=${list_name}   dist_name=${dist_name}
    RETURN   ${value}


Get SCF Value From File By Pattern
    [Documentation]
    ...
    ...     *Scope* Internal
    ...
    ...    | dist_name |  expects regular expressions |
    ...    | p_name    |  expects regular expressions |
    ...    | list_name |  expects regular expressions |
    ...
    ...    *Returns*    first match of given regexp
    ...
    [Arguments]   ${scf_path}   ${p_name}=${None}   ${list_name}=${None}   ${dist_name}=${None}
    scf.Load Scf   file_path=${scf_path}
    ${value}   scf.Get All Values From Scf By Pattern   p_name=${p_name}   list_name=${list_name}   dist_name=${dist_name}
    RETURN   ${value}[0]


Get List Of Cells Onair
    [Documentation]
    ...
    ...     *Scope* Internal
    ...
    ...     *Returns* list of onair cells
    ...
    [Arguments]   ${oam_alias}   ${num_of_cells}  ${type}
    ${internal_cell_list}   Create List
    FOR   ${cell_id}   IN RANGE   ${num_of_cells}
       ${setup_state}   ${_internal_cell_dist_id}   Run Keyword And Ignore Error
       ...   coam_ulm.Verify COAM Cell Setup
       ...   alias=${oam_alias}   cell_id=${cell_id}   cell_type=${type}   use_cache=${True}
       IF  '${setup_state}'=='PASS'   Collections.Append To List   ${internal_cell_list}   ${_internal_cell_dist_id}
    END
    Log   ----------------------------------------------------------------------   console=${P_console}
    [Teardown]   Set Suite Variable  ${P_CACHED_CELL_STATUS}  ${None}
    RETURN     ${internal_cell_list}


Verify That Cells Are Onair With COAM
    [Documentation]
    ...
    ...     *Scope* Internal
    ...
    [Arguments]   ${oam_alias}   ${num_of_cells}   ${type}=nr
    ${internal_cell_list}   Get List Of Cells Onair   ${oam_alias}   ${num_of_cells}  ${type}
    ${list_length}   Get Length   ${internal_cell_list}
    Should Be Equal As Integers   ${list_length}   ${num_of_cells}   msg=${list_length} of ${num_of_cells} cell(s) onAir!


Get SCF From GNB With COAM
    [Documentation]
    ...
    ...     *Scope* Internal
    ...
    [Arguments]   ${gnbScfName}   ${resultConfigDir}   ${gnb_id}=${0}   ${with_auto_configured_parameters}=${True}   ${export_type}=${None}
    ${oam_alias}   connect.Setup OAM Http Session   node_type=gnb   node_id=${gnb_id}
    admin.Get Current Scf File   ${resultConfigDir}
    ...                          ${gnbScfName}
    ...                          timeout=${30}
    ...                          connection=${oam_alias}
    ...                          export_type=${export_type}
    ...                          with_auto_configured_parameters=${with_auto_configured_parameters}


Verify On Board SW Version
    [Documentation]
    ...     Check if GNB is updated to expected version
    ...
    ...     *Scope* Internal
    ...
    [Arguments]   ${exp_version}   ${gnb_id}=0
    ${gnb_sw_version}   testline.Fetch Current GNB SW Version   gnb_id=${gnb_id}
    Should Contain   ${gnb_sw_version}   ${exp_version}   msg=SW update Failed!


Wait For Minimum Required State For Cell Setup For All GNBs
    [Documentation]
    ...
    ...    *Scope*  Internal
    ...
    [Arguments]   ${timeout}=10min
    FOR   ${gnb_id}   ${_}   IN ENUMERATE   ${tl.gnbs}
       Wait For Minimum Required State For Cell Setup   node_id=${gnb_id}   timeout=${timeout}
    END


Check GNB X2 Link Status Is Available
    [Documentation]
    ...
    ...    Used by wrapper KW `Wait until X2 Link Status is Available`.
    ...    Tested with classical gNB.
    ...
    ...    *Scope*  Internal
    ...
    [Arguments]   ${gnb_id}=${0}   ${lteEnbId_Idx}=${0}
    ${oam_alias}   connect.Setup OAM Http Session   node_type=gnb   node_id=${gnb_id}
    FOR   ${class_name}   ${parameter}    ${value}   IN
    ...   LTEENB_A   x2LinkLock     unlocked
    ...   LTEENB_R   x2LinkStatus   available
        @{MOs_list}   admin.Get Managed Objects   class_name=${class_name}   connection=${oam_alias}
        IF   ${{ len(${MOs_list})>0 }}
            &{parameter_dict}   admin.Get Parameters
            ...   dist_name=${MOs_list[${lteEnbId_Idx}]['distName']}
            ...   pattern=${parameter}
            ...   connection=${oam_alias}
            Nidd Value Should Be Equal   ${parameter_dict['${parameter}']}
            ...   ${value}
            ...   msg='${parameter}' is not '${value}' as expected!
        ELSE
            Log   No '${class_name}' object found, probably NSA isn't configured, skip '${parameter}' check!   console=${P_console}
        END
    END


Reboot GNB System Module Via Console
    [Documentation]
    ...     soft reboot GNB
    ...
    ...     *Scope*  Internal
    ...
    ...     | gnb_id  | Id of gnb [0.. ] |
    ...     | du_id   | Id of DU [0.. ]  |
    ...     | comu_id | Id of Common Unit [0..1] |
    ...
    [Arguments]   ${gnb_id}=${0}   ${du_id}=${0}   ${comu_id}=${0}
    ${alias}   connect.Connect To Node Common Unit   node_id=${gnb_id}   du_id=${du_id}   comu_id=${comu_id}
    ssh.Execute   set -m ; ddal -s ddal_boot_set_reset_loop_count 0   connection=${alias}
    ssh.Send Command   system-module-reboot   connection=${alias}
    Wait Until Ssh Connection Is Down   connection=${alias}
    Log   SSH connection terminate, System module performs reset!   console=${P_console}
    [Teardown]    Run Keyword And Ignore Error   ssh.Disconnect   connection=${alias}


Wait Until Ssh Connection Is Down
    [Documentation]
    ...     Wait until a ssh connection is down (e.g. after reboot/reset trigger)
    ...
    ...     | connection |       connection name or alias |
    ...     | retries |          number of attempts to re-connet |
    ...     | delay |            delay between attempts |
    ...
    ...     *Returns*   PASS or FAIL
    ...
    [Arguments]   ${connection}=${None}   ${retries}=${60}   ${delay}=1s
    FOR   ${iter}   IN RANGE   ${retries}
       ${status}   Run Keyword And Return Status   ssh.Force Reconnect   connection=${connection}
       IF   not ${status}   BREAK
       Sleep   ${delay}
    END
    ${status}   Run Keyword And Ignore Error   Should Not Be Equal As Integers   ${iter+1}   ${retries}
    RETURN   ${status}


Check Matching Pattern In Node State
    [Documentation]
    ...
    ...     *Scope* Internal
    ...
    [Arguments]   ${node_admin_alias}   ${target_proceduralState}
    ${gnbBtsInfo}   admin.Get Bts Info   connection=${node_admin_alias}
    ${current_proceduralState}   Set Variable   ${gnbBtsInfo['status']['proceduralState']}
    Nidd Value Should Be One Of   ${current_proceduralState}   ${target_proceduralState}
    RETURN    ${current_proceduralState}


Get Cell Radio Module Mapping
    [Documentation]
    ...    The kw determines the RMOD mapping for a the specific cell type.
    ...    The cell type is per default derived from the `node_type' argument.
    ...    So for gnb it is NRCEL whereas for enb it is LNCEL.
    ...
    ...    For Multi RAD configurations we can have a mix of NRCEL, LNCEL and even GNCEL.
    ...    To support this one can use the optional argument `class` to specify a wanted cell type.
    ...    In this case the node_type defines only the connection we will use, so either gnb or enb.
    ...    So we do not support a standalone GSM bts!
    ...
    ...    | node_type | type of node, either gnb or enb |
    ...    | node_id   | Id/Number of node |
    ...    | class     | optional, to specify a specific cell class name (NRCEL|LNCEL|GNCEL) |
    ...
    ...    *Returns*  Dictionary with cell dist_names as keys, value is a list of RMOD dist_names
    ...
    [Arguments]   ${node_id}=0   ${node_type}=gnb   ${class}=${None}

    ${node_type}   Convert To Lower Case   ${node_type}

    IF   $class is None
       IF   '${node_type}'=='gnb'
          ${class}      Set Variable   NRCEL
       ELSE IF   '${node_type}'=='enb'
          ${class}      Set Variable   LNCEL
       ELSE
          Fail   '${node_type}' isn't supported, use gnb or enb instead!
       END
    ELSE IF  '${class}' not in ['NRCEL', 'LNCEL', 'GNCEL']
       Fail   '${class}' isn't supported, use NRCEL, LNCEL or GNCEL instead!
    END

    ${oam_alias}   connect.Setup OAM Http Session   node_type=${node_type}   node_id=${node_id}

    ${list_cells}   testline.Get All Ids Of Class   alias=${oam_alias}   class=${class}

    ${cell_radio_module_mapping}   Create Dictionary
    FOR   ${cell}   IN   @{list_cells}
        ${cell_info}     admin.Get Cell Specific Info   cell_id=${cell}   connection=${oam_alias}
        ${cell_config}   Set Variable   ${cell_info}[id][configuration]
        ${rmod_list}     Evaluate   list(set([os.path.dirname(x["antennaLineId"]["configuration"]) for x in ${cell_info}[carrierList]]))   os
        Set To Dictionary   ${cell_radio_module_mapping}   ${cell_config}   ${rmod_list}
    END
    Log    Mapping: ${\n}${cell_radio_module_mapping}    console=${P_console}
    RETURN   ${cell_radio_module_mapping}


Get Radio Module Cell Mapping
    [Documentation]
    ...    The kw determines the cell type mapping to RMODs on the given node.
    ...    The cell type is per default derived from the `node_type' argument.
    ...    So for gnb it is NRCEL whereas for enb it is LNCEL.
    ...
    ...    For Multi RAD configurations we can have a mix of NRCEL, LNCEL and even GNCEL.
    ...    To support this one can use the optional argument `class` to specify a wanted cell type.
    ...    In this case the node_type defines only the connection we will use, so either gnb or enb.
    ...    So we do not support a standalone GSM bts!
    ...
    ...    | node_type | type of node, either gnb or enb |
    ...    | node_id   | Id/Number of node |
    ...    | class     | optional, to specify a specific cell class name (NRCEL|LNCEL|GNCEL) |
    ...
    ...    *Returns*  Dictionary with RMOD dist_names as keys, value is a list of cell dist_names
    ...
    [Arguments]   ${node_id}=0   ${node_type}=gnb    ${class}=${None}

    IF   $class is not None and '${class}' not in ['NRCEL', 'LNCEL', 'GNCEL']
       Fail  '${class}' isn't supported, use NRCEL, LNCEL or GNCEL instead!
    END

    ${node_type}   Convert To Lower Case   ${node_type}

    ${cell_rmod_mapping}   Get Cell Radio Module Mapping   node_id=${node_id}   node_type=${node_type}   class=${class}

    ${unique_rmods}         Evaluate   {rmod for rmods in ${cell_rmod_mapping}.values() for rmod in rmods}

    ${rmod_cell_mapping}=    Create Dictionary
    FOR    ${rmod}   IN   @{unique_rmods}
        ${cell_list}=   Evaluate   [cell for cell, rmods in ${cell_rmod_mapping}.items() if '${rmod}' in rmods]
        Set To Dictionary   ${rmod_cell_mapping}   ${rmod}   ${cell_list}
    END
    Log    Mapping: ${\n}${rmod_cell_mapping}    console=${P_console}
    RETURN    ${rmod_cell_mapping}


Generate Cells Status Dictionary
    [Documentation]
    ...     This KW extracts from the data structure returned by TAF KW 'get_cells_info' the status dict of all cells.
    ...     It contains as keys the cell distnames and their corresponding 'status' dictionary.
    ...     You can define by `key_type` whether you want the configuration or runtime/internal distname as key.
    ...     This can be beneficial to hamonize the distname for unlock/lock, unblock/block actions.
    ...
    ...     It allows you to easily access any specific state of a cell,
    ...     e.g. for the blocking state of MRBTS-1/NRBTS-1/NRCELL-1 :
    ...     ${sorted_result['MRBTS-1/NRBTS-1/NRCELL-1']['status']['blockingState']}
    ...
    ...     | data_structure | data structure returned by get_cells_info |
    ...     | id_type        | configuration or runtime/internal dist_name,  [configuration, internal] |
    ...
    ...     *Returns*   Status dictionary for all cells
    ...
    [Arguments]    ${data_structure}   ${id_type}=internal
    ${result}    Create Dictionary
    FOR    ${item}    IN    @{data_structure}
        ${dist_name}    Set Variable    ${item['id']['${id_type}']}
        ${status}    Set Variable    ${item['status']}
        ${entry}    Create Dictionary    status=${status}
        Set To Dictionary    ${result}    ${dist_name}    ${entry}
    END
    ${sorted_result}   data_ops_py.Sort Collection Naturally   ${result}
    RETURN   ${sorted_result}

