*** Settings ***
Documentation     Keywords related to gNB handling

Library    Collections
Library    String
Library    OperatingSystem
Library    ta_attenuator
Library    taf.sbts.oam.coam.admin                      WITH NAME   admin
Library    taf.transport.ssh                            WITH NAME   ssh
Library    taf.config.scf                               WITH NAME   scf
Library    taf.rfrl.common_resources.python.SWConfig    WITH NAME   swconf
Library    python/gnb.py                                WITH NAME   gnb_internal
Library    python/testline_information.py

Resource   connect.robot
Resource   testline.robot
Resource   coam_ulm.robot
Resource   aic_cu.robot
Resource   aic_vdu.robot
Resource   networking.robot
Resource   aashell.robot


*** Variables ***
${P_console}                ${False}  # output to console can be enabled via "Set Console Output" from testline.robot
${P_ORIG_GNB_SWCONFIG}      ${None}
@{P_INTERNAL_CELL_DIST_ID}


*** Keywords ***
Wait until all gNBs to be onair state
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
           Wait until Node to be onair state  node_type=${node_type}  node_id=${node_id}    timeout=${timeout}
    END


Wait until Node to be onair state
    [Documentation]
    ...     Wait for Node to be onAir, checked via oam interface.
    ...     Currently checks cell on air for 1 DU/comu.
    ...
    ...     | node_id        | Id/Number of Node (eNB|gNB) |
    ...     | unit_id        | Id/Number of unit (DU in case of gNB, comu in case of eNB) |
    ...     | node_type      | Node type; possible values: (gnb|enb |
    ...     | timeout        | time till gNB must be on air |
    ...     | retry_interval | Time to wait next retry. |
    ...
    [Arguments]    ${node_id}=${0}  ${unit_id}=${0}  ${node_type}=gnb  ${timeout}=600s   ${retry_interval}=20s
    Run Keyword If   '${tl_info.deployment_type(${node_id})}'=='aic'
    ...   Run Keywords
    ...         Log   KW <Wait until Node to be onair state> not supported with AIC! Doing nothing!>   WARN
    ...   AND   Return From Keyword  ${None}

    ${cell_type}   Run Keyword If   "${node_type}"=="gnb"   Set Variable   nr
    ...   ELSE IF   "${node_type}"=="enb"                   Set Variable  lte
    ...   ELSE      Fail    Wrong node_type '${node_type}'! allowed: enb|gnb

    ${class_name}   Set Variable If   '${node_type}'=='gnb'   NRCEL   LNCEL
    ${oam_alias}    connect.Setup OAM http session   node_id=${node_id}   node_type=${node_type}
    ${list_cells}   testline.Get All Ids Of Class   alias=${oam_alias}   class=${class_name}
    ${num_of_cells}   Get Length   ${list_cells}
    Run Keyword If    ${num_of_cells} < 1   FAIL   No ${class_name} configured!
    ${status}   Run Keyword And Return Status   Wait Until Keyword Succeeds   ${timeout}   ${retry_interval}
    ...   Verify that cells are onair with COAM   oam_alias=${oam_alias}   num_of_cells=${num_of_cells}   type=${cell_type}
    Return From Keyword If   ${status}   ${status}

    ${active_alarms}   admin.get active alarms   connection=${oam_alias}
    ${nbr_alarms}   Get Length   ${active_alarms}
    Log List   ${active_alarms}
    BuiltIn.Log   ${node_type}_${node_id} has ${nbr_alarms} active alarm(s), check log file for further info!   console=${P_console}
    FAIL   KW 'Verify that cells are onair with COAM' failed!


Check faultId in Node active alarm list
    [Documentation]
    ...     Check faultId in Node active alarm list, checked via oam interface.
    ...     Argument ``node_type`` if it is done for either gnb or enb.
    ...
    ...     | node_id   | Id/Number of Node (eNB|gNB) |
    ...     | node_type | Node type; possible values: (gnb|enb) |
    ...
    [Arguments]   ${expected_fault_number}   ${node_type}=gnb   ${node_id}=${0}
    ${oam_alias}   connect.Setup OAM http session   node_id=${node_id}   node_type=${node_type}
    ${active_alarms}   admin.get active alarms   connection=${oam_alias}
    ${convertAlarmListToString}   Convert To String  ${active_alarms}
    ${resultTestDir}    testline.Get testcase log directory
    Create File  path=${resultTestDir}/${node_type}_active_alarms.txt  content=${convertAlarmListToString}
    Should Contain  ${convertAlarmListToString}  ${expected_fault_number}


Get Current Alarms From Node
    [Documentation]
    ...     Get Current (in Node) active alarm list, checked via oam interface.
    ...     Argument ``node_type`` if it is done for either gnb or enb.
    ...
    ...     | node_id   | Id/Number of Node (eNB|gNB) |
    ...     | node_type | Node type; possible values: (gnb|enb) |
    ...
    [Arguments]   ${node_type}=gnb   ${node_id}=${0}

    ${oam_alias}   connect.Setup OAM http session  node_id=${node_id}  node_type=${node_type}
    ${active_alarms}   admin.get active alarms   connection=${oam_alias}
    ${nbr_alarms}   Get Length   ${active_alarms}
    Log List   ${active_alarms}
    BuiltIn.Log   ${\n}${node_type}_${node_id} has ${nbr_alarms} active alarm(s), check log file for further info!   console=${P_console}

    ${fault_alarms_list}   Create List
    FOR   ${i}   IN RANGE   ${nbr_alarms}
       ${bts_time}   Collections.Get From Dictionary   ${active_alarms[${i}]}   btsObservationTime
       ${f_id}       Collections.Get From Dictionary   ${active_alarms[${i}]}   faultId
       ${f_name}     Collections.Get From Dictionary   ${active_alarms[${i}]}   faultName
       Append To List   ${fault_alarms_list}   ${bts_time} faultId:${f_id} ${f_name}
       BuiltIn.Log   ${bts_time} faultId:${f_id} ${f_name}   console=${P_console}
    END

    ${convertAlarmListToString}   Convert To String   ${active_alarms}
    ${resultTestDir}   testline.Get testcase log directory
    OperatingSystem.Create File   path=${resultTestDir}/${node_type}_Current_active_alarms.txt   content=${convertAlarmListToString}


Reset Node
    [Documentation]
    ...     Send RESET SITE via OAM interface and
    ...     try to reconnect the Admin API.
    ...
    ...     | node_id   | Id/Number of Node (eNB|gNB) |
    ...     | node_type | Node type; possible values: (gnb|enb) |
    ...
    [Arguments]   ${node_type}=gnb   ${node_id}=${0}
    BuiltIn.Log   ${\n}Reset Node ${node_type}-${node_id} by admin api.   console=${P_console}
    ${oam_alias}   connect.Setup OAM http session  node_id=${node_id}  node_type=${node_type}
    admin.reset_site   wait_for_reconnection=${True}   connection=${oam_alias}
    BuiltIn.Log   ${\n}Reset Site executed, try to reconnect the Admin API...   console=${P_console}
    ${oam_alias}   connect.Reconnect OAM http session   node_id=${node_id}   node_type=${node_type}
    BuiltIn.Log    ${\n}Admin API reconnected.   console=${P_console}


Wait for Node state
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

    Run Keyword If   '${tl_info.deployment_type(${node_id})}'=='aic'
    ...   Run Keywords
    ...         Log  KW <Wait for Node state> not supported with AIC! Doing nothing!>  WARN
    ...   AND   Return From Keyword   ${None}

    OperatingSystem.Create Directory   ${admin_api_log_path}
    BuiltIn.Log    Wait for ${node_type}_${node_id} state ${target_proceduralState}   console=${P_console}
    ${oam_alias}   connect.Setup OAM Http session   node_type=${node_type}   node_id=${node_id}
    Wait Until Keyword Succeeds   ${timeout}   5s   Check Matching Pattern In Node State
    ...   node_admin_alias=${oam_alias}   target_proceduralState=${target_proceduralState}
    BuiltIn.Log   ${node_type}_${node_id} state is ${target_proceduralState}!   console=${P_console}


Wait until all gNBs have first X2 Link Status Available
    [Documentation]
    ...     Wait for all gNBs to have Available X2 Link Status
    ...     onAir state is checked via OAM.
    ...
    ...     | timeout | Time until all gNBs must have Available X2 Link Status |
    ...
    [Arguments]   ${timeout}=600s
    ${gnb_num}   Get Length   ${tl.gnbs}
    FOR   ${gnb_id}   IN RANGE   ${gnb_num}
       Wait until X2 Link Status is Available   gnb_id=${gnb_id}   timeout=${timeout}   lteEnbId_Idx=${0}
    END


Wait until X2 Link Status is Available
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
    ...   Check gNB X2 Link Status is Available   gnb_id=${gnb_id}   lteEnbId_Idx=${lteEnbId_Idx}
    BuiltIn.Log   gNB${gnb_id} have Available X2 Link Status   console=${P_console}


Reset all gNBs and wait for availability
    [Documentation]
    ...
    ...    | timeout | timeout value |
    ...
    [Arguments]   ${timeout}=600s
    ${gnb_num}     Get length   ${tl.gnbs}
    FOR    ${gnb_id}    IN RANGE    ${gnb_num}
        Reset gNB via OAM and wait for availability    gnb_id=${gnb_id}   timeout=${timeout}
    END


Reset gNB via OAM and wait for availability
    [Documentation]
    ...     Reset gNB via oam interface and check RAP, DUs, FRM to be up
    ...
    ...     | gnb_id  | Id/Number of gNB |
    ...     | timeout | time till gNB must up agin |
    ...
    [Arguments]    ${gnb_id}=${0}   ${timeout}=600s
    Perform gNB reboot         gnb_id=${gnb_id}
    Wait until all DUs up      gnb_id=${gnb_id}
    Check FRMs status          gnb_id=${gnb_id}


Wait until all DUs up
    [Documentation]
    ...     Waits till all DU of a gNB are up
    ...
    ...     | gnb_id  | Id/Number of gNB |
    ...     | timeout | Time until DUs have to be up |
    ...
    [Arguments]    ${gnb_id}=0  ${timeout}=10 min
    ${du_num}    Get length    ${tl.gnbs[${gnb_id}].dus}
    FOR    ${du}    IN RANGE    ${du_num}
        Wait until DU ready    gnb_id=${gnb_id}    du_id=${du}     timeout=${timeout}
    END


Wait until DU ready
    [Documentation]
    ...     Waits till all Common and Capacity Unit of a DU are up
    ...
    ...     | gnb_id  | Id/Number of gNB |
    ...     | du_id   | Id/Number of DU |
    ...     | timeout | Time until Common+CapacityUnit have to be up |
    ...
    [Arguments]    ${gnb_id}    ${du_id}    ${timeout}=10 min

    Run Keyword If   '${tl_info.deployment_type(${gnb_id})}'=='aic'
    ...   Run Keywords
    ...         Log  KW <Wait until DU ready> not supported with AIC! Doing nothing!>  WARN
    ...   AND   Return From Keyword  ${None}

    BuiltIn.Log    Wait until gNB${gnb_id} DU${du_id} is ready    console=${P_console}
    ${common_units}    Get length    ${tl.gnbs[${gnb_id}].dus[${du_id}].airscale.common_units}
    FOR    ${comu}    IN RANGE    ${common_units}
       Wait for gNB Common and Capacity unit up    gnb_id=${gnb_id}  du_id=${du_id}  comu_id=${comu}   timeout=${timeout}
    END
    BuiltIn.Log    gNB${gnb_id} DU${du_id} is ready!    console=${P_console}


Wait for gNB Common and Capacity unit up
    [Documentation]
    ...
    ...     | gnb_id  | Id of gnb [0.. ] |
    ...     | du_id   | Id of DU [0.. ] |
    ...     | comu_id | Id of Common Unit [0..1] |
    ...     | timeout | Time until Common+CapacityUnit have to be up |
    ...
    [Arguments]    ${gnb_id}=0    ${du_id}=0  ${comu_id}=0  ${timeout}=10min
    #WA AIC
    Run Keyword If   '${tl_info.deployment_type(${gnb_id})}'=='aic'
    ...   Run Keywords
    ...         Log  KW <Wait for gNB Common and Capacity unit up> not supported with AIC! Doing nothing!>  WARN
    ...   AND   Return From Keyword  ${None}
    #end WA
    ${capu_num}    Get Length    ${tl.gnbs[${gnb_id}].dus[${du_id}].airscale.common_units[${comu_id}].capacity_units}
    ${comu_ssh_alias}  Wait Until Keyword Succeeds   ${timeout}  10s
    ...     connect.Connect to Node Common Unit  node_id=${gnb_id}  du_id=${du_id}    comu_id=${comu_id}

    @{existing_boards_ids}    gnb_internal.get board ids   ${comu_ssh_alias}

    FOR   ${board_id}   IN   @{existing_boards_ids}
        Wait Until Keyword Succeeds   ${timeout}   20s   Check Airscale Board Status
        ...     alias=${comu_ssh_alias}   board_id=${board_id}
    END


Wait For Minimum Required State For Cell Setup
    [Documentation]
    ...     Waits until all pre-conditions for cell setup on all or specific cell(s) are reached.
    ...     Utilizes only admin API to check, session setup must be possible within 3min!
    ...
    ...     | node_type  | either gnb or enb (gnb|enb) |
    ...     | node_id    | Id of gNB|eNB [0.. ]        |
    ...     | cell_id    | Id of cell [0..x|all]       |
    ...     | ru_id      | Id of RU [0..x|all]         |
    ...     | timeout    | TO for individual checks    |
    ...     | kw_timeout | overall TO for the whole KW |
    ...
    [Arguments]   ${node_type}=gnb   ${node_id}=${0}   ${cell_id}=all   ${ru_id}=all   ${timeout}=5min   ${kw_timeout}=60min
    [Timeout]     ${kw_timeout}
    BuiltIn.Log     ${\n}Waiting until node ${node_type}_${node_id} is ready for Cell Setup ...   console=${P_console}
    ${oam_alias}    connect.Setup OAM Http session   node_type=${node_type}   node_id=${node_id}

    ${status}       Wait Until Keyword Succeeds   ${timeout}   20s   Verify Single BTS is Configured   connection=${oam_alias}
    ${sync_dict}    Wait Until Keyword Succeeds   ${timeout}   20s   coam_ulm.Get BTS Active Sync Source   alias=${oam_alias}

    Run Keyword If  '${ru_id}'=='all'   Wait Until Keyword Succeeds   ${timeout}   20s
    ...             Verify All Radios are Online    connection=${oam_alias}
    ...   ELSE      Wait Until Keyword Succeeds   ${timeout}   20s
    ...             Verify Single Radio is Online   connection=${oam_alias}    ru_id=${ru_id}

    Run Keyword If  '${cell_id}'=='all'   Wait Until Keyword Succeeds   ${timeout}   20s
    ...             Verify All Cells are Configured  node_type=${node_type}   connection=${oam_alias}
    ...   ELSE      Wait Until Keyword Succeeds   ${timeout}   20s
    ...             Verify Single Cell is Configured   node_type=${node_type}   connection=${oam_alias}   cell_id=${cell_id}

    Sleep   30s   reason=problems with cell setup on AP


Verify Single BTS is Configured
    [Documentation]
    ...     Checks if gNB is Configured.
    ...
    ...     | connection | connection alias |
    ...
    [Arguments]   ${connection}={}
    ${bts_state}   admin.Get Mrbts State   connection=${connection}
    BuiltIn.Log    [INFO] BTS STATE : ${bts_state}   console=${P_console}
    Nidd Value Should be One Of   ${bts_state}   Configured, IntegratedToRan, onAir


Verify Single Radio is Online
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

    ${frm_info}   Run Keyword If   '${cache_is_filled}'=='${None}'
    ...   admin.Get Frm   connection=${connection}

    Run Keyword If   '${cache_is_filled}'=='${None}'
    ...   Set Suite Variable   ${P_CACHED_FRM_STATUS}   ${frm_info}

    ${radio_state}   Get avaiabilityStatus from Status Dictionary   ${P_CACHED_FRM_STATUS[${ru_id}]['status']}
    BuiltIn.Log   [INFO] ${P_CACHED_FRM_STATUS[${ru_id}]['id']['configuration']} : ${radio_state}   console=${P_console}
    Nidd availabilityStatus Value Should Be One Of   ${P_CACHED_FRM_STATUS[${ru_id}]['status']}   Degraded, Online
    [Teardown]   Run keyword If   '${use_cache}'=='${False}'   Set Suite Variable   ${P_CACHED_FRM_STATUS}   ${None}


Verify All Radios are Online
    [Documentation]
    ...     Checks if  all RU/rmod are Online.
    ...     Utilizes only coam M-plane based API to check it.
    ...
    ...     | connection | connection alias |
    ...
    [Arguments]   ${connection}={}
    ${number_of_radios}   Get Number of RMOD   connection=${connection}
    FOR   ${ru_id}   IN RANGE   ${number_of_radios}
       Verify Single Radio is Online   connection=${connection}   ru_id=${ru_id}   use_cache=${True}
    END
    [Teardown]   Set Suite Variable   ${P_CACHED_FRM_STATUS}   ${None}


Verify Single Cell is Configured
    [Documentation]
    ...     Checks if a given cell is configured.
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
    ${cell_type}   Set Variable If   '${node_type}'=='gnb'                            nr
    ...                              '${node_type}'=='enb'                            lte
    ...                              '${node_type}'!='gnb' and '${node_type}'!='enb'  unknown

    ${cache_is_filled}   Get Variable Value   ${P_CACHED_CELL_STATUS[${cell_id}]['id']['internal']}
    ${cell_info}   Run Keyword If   '${cache_is_filled}'=='${None}'
    ...   admin.Get Cells Info   connection=${connection}   cell_type=${cell_type}

    Run Keyword If   '${cache_is_filled}'=='${None}'
    ...   Set Suite Variable    ${P_CACHED_CELL_STATUS}   ${cell_info}

    ${check_status}   Run Keyword If   '${node_type}'=='gnb'
    ...               Set Variable   ${P_CACHED_CELL_STATUS[${cell_id}]['status']['proceduralStatus']}
    ...   ELSE        Set Variable  ${P_CACHED_CELL_STATUS[${cell_id}]['status']}

    BuiltIn.Log   [INFO] ${P_CACHED_CELL_STATUS[${cell_id}]['id']['configuration']} : ${check_status}   console=${P_console}
    Run Keyword If   '${node_type}'=='gnb'   Nidd Value Should be One Of   ${check_status}   Configured
    ...   ELSE       Nidd availabilityStatus Value Should Be One Of   ${check_status}   Offline, Online, Degraded
    [Teardown]   Run keyword If   '${use_cache}'=='${False}'   Set Suite Variable   ${P_CACHED_CELL_STATUS}   ${None}


Verify All Cells are Configured
    [Documentation]
    ...     Checks if all cell are configured.
    ...     Utilizes only coam M-plane based API to check it.
    ...
    ...     | connection | connection alias |
    ...     | node_type  | either gnb or enb, defines the cell type (nr or lte) |
    ...
    [Arguments]   ${connection}={}   ${node_type}=gnb
    ${number_of_cells}  Run Keyword If  '${node_type}'=='gnb'  testline.Get Number of Cells  cell_type=NRCEL  connection=${connection}
    ...                 ELSE IF         '${node_type}'=='enb'  testline.Get Number of Cells  cell_type=LNCEL  connection=${connection}
    ...                 ELSE                                   FAIL     Unsupported node_type ${node_type}!
    BuiltIn.Log         Fetch number of cells for node ${node_type}: ${number_of_cells} found.   console=${False}
    FOR     ${cell_id}      IN RANGE   ${number_of_cells}
            Verify Single Cell is Configured   node_type=${node_type}  connection=${connection}  cell_id=${cell_id}  use_cache=${True}
    END
    [Teardown]  Set Suite Variable  ${P_CACHED_CELL_STATUS}  ${None}


Check FRMs status
    [Documentation]
    ...     This is the wrapper KW to check the FRMs. Currently only classical TL is supported.
    ...     AiC to be added if needed. Usually this KW shouldn't be used directly in user tests
    ...     but in other wrapper KW providing higher level abstraction.
    ...
    [Arguments]   ${gnb_id}=${0}   ${timeout}=${60}   ${target_status}=Online
    BuiltIn.Log   Wait until gNB${gnb_id} FRMs are ${target_status}   console=${P_console}
    Run Keyword If   '${tl_info.deployment_type(${gnb_id})}'=='classical'   Check FRMs status with COAM
    ...          gnb_id=${gnb_id}    target_status=${target_status}   timeout=${timeout}
    ...   ELSE   Fail    Unsupported Node type!
    BuiltIn.Log   gNB${gnb_id} FRMs are ${target_status}!    console=${P_console}


Perform gNB reboot
    [Documentation]
    ...     Reboot gNB via oam interface
    ...
    ...     | gnb_id  | Id/Number of gNB |
    ...
    [Arguments]   ${gnb_id}=${0}
    BuiltIn.Log   Reboot of gNB${gnb_id} triggered    console=${P_console}
    Run Keyword If   '${tl_info.deployment_type(${gnb_id})}'=='classical'
    ...              gnb.Reset Node   node_type=gnb   node_id=${gnb_id}
    ...    ELSE      Fail    Unsupported Node type!
    BuiltIn.Log    Reboot of gNB${gnb_id} finished!    console=${P_console}


Perform gNB reset unit
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
    ${oam_alias}   connect.Setup OAM Http session   node_type=gnb   node_id=${gnb_id}
    BuiltIn.Log    Reboot of ${dist_name} starting!   console=${P_console}
    admin.reset_unit   dist_name=${dist_name}   reset_type=${reset_type}
    ...   timeout=${timeout}    &{kwargs}
    ...                 detailed_output=${detailed_output}    connection=${oam_alias}
    BuiltIn.Log    Reboot of ${dist_name} finished!    console=${P_console}


Store Current SCF from gNB
    [Documentation]
    ...
    ...    | gnb_id     | Id of gnb [0.. ] |
    ...    | target_dir | save SCF to path |
    ...    | component  | either (DU|CU)   |
    ...
    ...    *Returns*   scf path for further usage
    ...
    [Arguments]   ${gnb_id}=${0}   ${target_dir}=${None}   ${component}=DU
    ${ORIG_SCF}   gnb.Get SCF from gNB   gnb_id=${gnb_id}   target_dir=${target_dir}   component=${component}
    OperatingSystem.Run   cp ${ORIG_SCF} ${ORIG_SCF}.orig
    Set Suite Variable   ${P_ORIG_SCF}   ${ORIG_SCF}.orig
    [Return]   ${P_ORIG_SCF}


Get SCF from gNB
    [Documentation]
    ...     This KW downloads the SCF from the given ``component`` of the given ``gnb_id``
    ...     to the given ``target_dir`` on the local TestPC.
    ...
    ...     | gnb_id     | Id/Number of gNB |
    ...     | target_dir | save SCF to path |
    ...     | component  | either (DU|CU)   |
    ...     | scf_name   | save SCF with desired name |
    ...
    ...     *Returns*   scf path for further usage
    ...
    [Arguments]   ${gnb_id}=${0}   ${target_dir}=${None}   ${component}=DU   ${scf_name}=${None}
    ${NodeType}   Set Variable   ${tl_info.deployment_type(${gnb_id})}
    ${gnbScfName}   Set variable If   '${scf_name}'=='${None}'   SCFC_gNB${gnb_id}_${component}.xml   ${scf_name}

    Set Suite Variable   ${private_gnbScfName${gnb_id}}   ${gnbScfName}
    ${resultConfigDir}   Run Keyword If   '${target_dir}'=='${None}'   testline.Get Test Suite Config Directory
    ...   ELSE           Set Variable    ${target_dir}

    Run Keyword If   '${NodeType}'=='classical'   Get SCF from gNB with cOAM
    ...              gnbScfName=${gnbScfName}   resultConfigDir=${resultConfigDir}   gnb_id=${gnb_id}
    ...   ELSE IF    '${NodeType}'=='aic' and '${component}'=='CU'   aic_cu.Get CU current plan file
    ...              gnbScfName=${gnbScfName}   resultConfigDir=${resultConfigDir}   gnb_id=${gnb_id}
    ...   ELSE IF    '${NodeType}'=='aic' and '${component}'=='DU'  aic_vdu.Get DU current plan file
    ...              gnbScfName=${gnbScfName}   resultConfigDir=${resultConfigDir}   gnb_id=${gnb_id}
    ...   ELSE       Fail   Unknown Node Type ${NodeType}
    [Return]   ${resultConfigDir}/${gnbScfName}


Store Current swconfig from gNB
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

    Run Keyword If   '${tl_info.deployment_type(${gnb_id})}'=='aic'
    ...   Run Keywords
    ...         Log  KW <Store Current swconfig from gNB> not supported with AIC! Doing nothing!>  WARN
    ...   AND   Return From Keyword  ${None}

    ${ORIG_SWCONFIG}   gnb.Get swconfig from gNB   gnb_id=${gnb_id}   target_dir=${target_dir}
    OperatingSystem.Run   mv ${ORIG_SWCONFIG} ${ORIG_SWCONFIG}.orig
    Set Suite Variable    ${P_ORIG_GNB_SWCONFIG}   ${ORIG_SWCONFIG}.orig
    [Return]   ${P_ORIG_GNB_SWCONFIG}


Get swconfig from gNB
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

    Run Keyword If   '${tl_info.deployment_type(${gnb_id})}'=='aic'
    ...   Run Keywords
    ...         Log  KW <Get swconfig from gNB> not supported with AIC! Doing nothing!>  WARN
    ...   AND   Return From Keyword  ${None}

    ${target_dir}   Run Keyword If   '${target_dir}'=='${None}'   testline.Get Test Suite Config Directory
    ...   ELSE      Set Variable   ${target_dir}
    ${asik_alias}   connect.Connect to Node Common Unit   node_id=${gnb_id}   du_id=${du_id}   comu_id=${comu_id}
    ssh.Download File   remote_path=/ffs/run/swconfig.txt   local_path=${target_dir}/gnb-${gnb_id}_swconfig.txt   connection=${asik_alias}
    [Return]   ${target_dir}/gnb-${gnb_id}_swconfig.txt


Get gNB SCF Name
    [Documentation]
    ...
    ...     | gnb_id | Id/Number of gNB |
    ...
    ...     *Returns* gNB scf name stored in privat global variable private_gnbScfName${gnb_id}
    ...
    [Arguments]     ${gnb_id}=${0}
    [Return]    ${private_gnbScfName${gnb_id}}


Reload stored swconfig to gNB
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

    Run Keyword If   '${tl_info.deployment_type(${gnb_id})}'=='aic'
    ...   Run Keywords
    ...         Log  KW <Reload stored swconfig to gNB> not supported with AIC! Doing nothing!>  WARN
    ...   AND   Return From Keyword  ${None}

    ${comu_alias}   connect.Connect to Node Common Unit   node_id=${gnb_id}   du_id=${du_id}   comu_id=${comu_id}
    ssh.Upload File   local_path=${P_ORIG_GNB_SWCONFIG}   remote_path=/ffs/run/swconfig.txt   connection=${comu_alias}


Set SW Config on Common Module
    [Documentation]
    ...     This keyword sets the rnd params in the common module.
    ...
    ...     | rad_param       | rad param to set |
    ...     | rad_param_value | value for rad param |
    ...     | gnb_id          | Id of gnb [0.. ] |
    ...     | du_id           | Id of DU [0.. ] |
    ...     | comu_id         | Id of Common Unit [0..1] |
    ...
    [Arguments]   ${rad_param}   ${rad_param_value}   ${gnb_id}=${0}   ${du_id}=${0}   ${comu_id}=${0}

    Execute Aashell Command on Node     command=rad -mw ${rad_param} ${rad_param_value}\r
    ...                                 node_id=${gnb_id}   node_type=gnb


Get AaShell SW Config
    [Documentation]
    ...     This keyword Prints all non default R&D parameters of RadMaster.
    ...
    ...     | rad_param | Rad Parameter [0x580017] |
    ...     | gnb_id    | Id of gnb [0.. ]         |
    ...     | du_id     | Id of DU [0.. ]          |
    ...     | comu_id   | Id of Common Unit [0..1] |
    ...
    ...    *Returns* IF rad_param is empty prints all non default R&D parameters of RadMaster.
    ...              Else the "Current val" of rad_param. e.g.: [u'0x0']
    ...
    [Arguments]   ${rad_param}=${EMPTY}   ${gnb_id}=${0}   ${du_id}=${0}   ${comu_id}=${0}

    ${nonDefaultRadMaster}   Execute Aashell Command on Node   command=rad -mu \r
    ...                                                        node_id=${gnb_id}   node_type=gnb

    ${radMasterValue}   Run Keyword If   '${rad_param}'=='${EMPTY}'
    ...                 Set Variable    ${nonDefaultRadMaster}
    ...   ELSE          String.Get regexp matches   ${nonDefaultRadMaster}
    ...                 \\[${rad_param}\\] Default val = .*; Current val = (.*)   1
    [Return]   ${radMasterValue}


Update SW Config file on System Module
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
    ${comu_alias}   connect.Connect to Node Common Unit   node_id=${gnb_id}   du_id=${du_id}   comu_id=${comu_id}
    swconf.download_swConfig_file_from_asik_to_test_pc    localFilePath=/tmp/swconfig_tmp.txt   asik_alias=${comu_alias}

    Run Keyword If   ${del_param_list} != @{EMPTY}   swconf.delete_parameter_of_swConfig_file
    ...              parametersList=${del_param_list}   filePath=/tmp/swconfig_tmp.txt
    Run Keyword If   ${param_list}!=@{EMPTY}   swconf.modify_swConfig_file
    ...              parametersList=${param_list}   filePath=/tmp/swconfig_tmp.txt

    swconf.upload_swConfig_file_to_asik_and_crasign   localFilePath=/tmp/swconfig_tmp.txt   asik_alias=${comu_alias}


Get gNB Common Unit Port Status
    [Documentation]
    ...     Retrieve the status of the given ``port`` of the switch of the ASIK from the given system module ``comu_id`` of
    ...     the given distributed unit ``du_id`` of the given ``gnb_id``.
    ...
    ...     *Note*  ASIK only, candidate for removal!
    ...
    ...    | port    |  port on ASXX |
    ...    | gnb_id  |  id of the gnb |
    ...    | du_id   |  if of the du |
    ...    | comu_id |  id of the common unit |
    ...
    ...    *Returns* True if port is up, False if port is down
    ...
    [Arguments]   ${port}   ${gnb_id}=0   ${du_id}=0   ${comu_id}=0
    ${tmp_alias}   connect.Connect to Node Common Unit   node_id=${gnb_id}   du_id=${du_id}   comu_id=${comu_id}
    ${port_status}   ssh.execute   dbgrrc show port ${port}   connection=${tmp_alias}   timeout=30s
    ${status}   Run Keyword And Return Status   Should Contain X Times   ${port_status}   up   2
    [Return]   ${status}


Get distNames from Local SCF File
    [Documentation]
    ...
    ...     Searches for the given distname pattern in a locally stored SCF file. Together with
    ...     KW `Get SCF from gNB` it is the best choice to search for distnames in a common way from
    ...     classical, AiC DU or AiC CU scf file especially if one need to search different distnames
    ...     multiple times!
    ...
    ...     *Example*
    ...     | ${du_scf}    | gnb.Get SCF from gNB |
    ...     | ${distnames} | Get distNames from Local SCF File | regex=MRBTS-[0-9]+ | scf_path=${du_scf} |
    ...     | ${distnames} | Get distNames from Local SCF File | regex=MRBTS-[0-9]+/NRBTS-[0-9]+ | scf_path=${du_scf} |
    ...     | ${cu_scf}    | gnb.Get SCF from gNB | component=CU |
    ...     | ${distnames} | Get distNames from Local SCF File | regex=MRBTS-[0-9]+/NRBTS-[0-9]+ | scf_path=${cu_scf} |
    ...
    ...     *Returns*   list of matching distnames
    ...
    [Arguments]   ${regex}   ${scf_path}
    ${scf_content}   OperatingSystem.Get File   ${scf_path}
    ${distNames}     gnb_internal.get_distNames_from_scf   regex=${regex}   scf_content=${scf_content}
    [Return]   ${distNames}


Get distNames from gNB SCF
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
    [Arguments]   ${regex}   ${gnb_id}=${0}
    ${oam_alias}     connect.Setup OAM Http session   node_type=gnb   node_id=${gnb_id}
    ${scf_content}   admin.get_scf   parameters_save_variant=actualValues   timeout=${10}   connection=${oam_alias}
    ${distNames}     gnb_internal.get_distNames_from_scf    regex=${regex}    scf_content=${scf_content}
    [Return]   ${distNames}


Get distNames from gNB DU
    [Documentation]
    ...     Fetches specific distnames matching given regexp pattern from Classical or AiC DU.
    ...     This KW could be used for specific distnames (see examples) in case the current SCF isn't locally
    ...     stored and only a single lookup must be done.
    ...     *Note* This KW can only be used for distnames shown in the 3 examples!
    ...            For all other distname pattern or in case you need to search multiple distnames sequentially
    ...            use the KW `Get distNames from Local SCF File`!
    ...
    ...     *Scope* Classical gNB and AiC DU only!
    ...
    ...     *Example*
    ...     | Get distNames from gNB DU  regexp=MRBTS-[0-9]+
    ...     | Get distNames from gNB DU  regexp=MRBTS-[0-9]+/NRBTS-[0-9]+
    ...     | Get distNames from gNB DU  regexp=MRBTS-[0-9]+/NRBTS-[0-9]+/NRCELL-[0-9]+
    ...
    ...     | regex     | regular expression for the wanted distnames   |
    ...     | gnb_id    | gnb id from testline config                   |
    ...     | du_id     | Id of du                                      |
    ...
    ...     *Returns*   list of matching distnames
    ...
    [Arguments]   ${regex}   ${du_id}=${0}   ${gnb_id}=${0}
    ${distNames}   Run Keyword If   '${tl_info.deployment_type(${gnb_id})}'=='aic'
    ...            aic_vdu.Get distNames from aic VDU   gnb_id=${gnb_id}   du_id=${du_id}   regex=${regex}
    ...   ELSE     Get distNames from classical gNB     gnb_id=${gnb_id}   regex=${regex}
    [Return]    ${distNames}


Get distNames from classical gNB
    [Documentation]
    ...     Use wrapper KW `Get distNames from gNB DU`
    ...
    ...     *Scope* Internal
    ...
    ...     *Returns* list of matching distNames
    ...
    [Arguments]   ${regex}   ${gnb_id}=${0}
    ${oam_alias}   connect.Setup OAM Http session   node_type=gnb   node_id=${gnb_id}
    ${content}     admin.get_bts_info   timeout=${10}   connection=${oam_alias}
    ${distNames}   gnb_internal.get_distNames_from_json   regex=${regex}   json_obj=${content}
    [Return]   ${distNames}


Get gNB Physical Cell ID
    [Documentation]
    ...     This wrapper keyword returns a dictionary with cell name (as in SCF) as the key
    ...     and the respective physical cell id as the value. It support Classical as well
    ...     as AiC testlines.
    ...
    ...     | gnb_id    | Id of gnb |
    ...     | du_id     | Id of du  |
    ...
    ...     *Returns*   a dictionary with key cell name and the respective physical cell id
    ...
    [Arguments]   ${gnb_id}=0   ${du_id}=0
    ${_cell_phy_cell_id}   Run Keyword If   '${tl_info.deployment_type(${gnb_id})}'=='aic'
    ...          Get gNB Physical Cell ID From AiC  gnb_id=${gnb_id}  du_id=${du_id}
    ...   ELSE   Get gNB Physical Cell ID From Classical   gnb_id=${gnb_id}  du_id=${du_id}
    [Return]   ${_cell_phy_cell_id}


Get gNB Physical Cell ID From Classical
    [Documentation]
    ...
    ...     *Scope*  Internal
    ...
    ...     This TL specific keyword returns a dictionary with cell name (as in SCF) as the key
    ...     and the respective physical cell id as the value. It is recommended to use the dedicated
    ...     wrapper KW in the test suite `Get gNB Physical Cell ID`.
    ...
    ...     | gnb_id    | Id of gnb |
    ...     | du_id     | Id of du  |
    ...
    ...     *Returns*   a dictionary with key cell name and the respective physical cell id
    ...
    [Arguments]   ${gnb_id}=0   ${du_id}=0
    ${oam_alias}   connect.Setup OAM http session   node_id=${gnb_id}
    ${cell_list}   admin.get_cell_list   connection=${oam_alias}
    ${_cell_phy_cell_id}   gnb_internal.get_phy_cell_ids   cell_info=${cell_list}
    [Return]   ${_cell_phy_cell_id}


Get gNB Local Cell Resource ID
    [Documentation]
    ...     This keyword returns a dictionary with cell name (as in SCF) as the key
    ...     and the respective local cell resouce id as the value.
    ...
    ...     | gnb_id | Id of gnb [0.. ] |
    ...     | du_id  | Id of du [0.. ] |
    ...
    ...     *Returns*   dictionary with key cell name and the respective local cell resouce id
    ...
    [Arguments]   ${gnb_id}=0
    ${oam_alias}   connect.Setup OAM http session   node_id=${gnb_id}
    ${cell_info}   admin.get_subcells_info   connection=${oam_alias}
    ${cell_lcrId_map}   gnb_internal.get_cell_id_lcrId_map   cell_info=${cell_info}
    [Return]   ${cell_lcrId_map}


Get Release Name
    [Documentation]
    ...     This keyword returns the name of the gNB SW release
    ...
    ...     | node_id | Id of gnb [0.. ] |
    ...
    ...     *Returns* release name, e.g. SBTS22R3
    ...
    [Arguments]   ${node_id}=${0}
    ${oam_alias}   connect.Setup OAM http session   node_id=${node_id}
    ${release}     admin.get_sw_release_name   connection=${oam_alias}
    [Return]   ${release}


Fetch gNB Info From SCF
    [Documentation]
    ...
    ...    fetch needed gnb information to prepare Airphone keyword
    ...    If additional configuration needed, could be added into this keyword
    ...
    ...     *Scope* Internal
    ...

    ${scf_path}   Run Keyword If   '${tl_info.deployment_type()}'=='classical'
    ...             gnb.Get SCF from gNB   target_dir=/tmp   gnb_id=0
    ...   ELSE IF   '${tl_info.deployment_type()}'=='aic'
    ...             aic_cu.Get CU current plan file   gnb_id=0

    ${P_gNbCuType}   Get SCF Value from file   p_name=gNbCuType   scf_path=${scf_path}
    ${P_cellTechnology}   Get SCF Value from file by pattern   p_name=cellTechnology   scf_path=${scf_path}   dist_name=.*NRCELL-*
    ${P_freqBandIndicatorNR}   Get SCF Value from file by pattern   p_name=freqBandIndicatorNR   scf_path=${scf_path}   dist_name=.*NRCELL-*

    ${nrarfcn}     Run Keyword If  '${P_cellTechnology}'=='TDD'   Get SCF Value from file by pattern
    ...   p_name=nrarfcn    scf_path=${scf_path}     dist_name=.*NRCELL-*
    ${nrarfcnDl}   Run Keyword If  '${P_cellTechnology}'=='FDD'   Get SCF Value from file by pattern
    ...   p_name=nrarfcnDl   scf_path=${scf_path}   dist_name=.*NRCELL_FDD-1
    ${nrarfcnUl}   Run Keyword If  '${P_cellTechnology}'=='FDD'   Get SCF Value from file by pattern
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
    ${value}   scf.Get Value from SCF   p_name=${p_name}   list_name=${list_name}   dist_name=${dist_name}
    [Return]   ${value}


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
    ${value}   scf.Get all values from scf by pattern   p_name=${p_name}   list_name=${list_name}   dist_name=${dist_name}
    [Return]   ${value}[0]


Check FRMs Status With COAM
    [Documentation]
    ...     Specific KW for classical gNB. It is recommended to use the wrapper KW
    ...     `Check FRMs status` instead!
    ...
    ...     *Scope* Internal
    ...
    [Arguments]   ${gnb_id}   ${target_status}   ${timeout}
    ${oam_alias}   connect.Setup OAM Http session   node_type=gnb   node_id=${gnb_id}
    ${num_of_frms_dict}   gnb_internal.get_num_of_frms_per_gnb
    ${gnb_str}   Convert To String   ${gnb_id}
    ${num_of_frms_str}   Collections.Get From Dictionary   ${num_of_frms_dict}   ${gnb_str}
    ${num_of_frms}   Convert To Integer   ${num_of_frms_str}
    Wait Until Keyword Succeeds   ${timeout}   5s   Compare online with available FRMs with COAM
    ...   ${num_of_frms}   ${oam_alias}   ${target_status}


Compare online with available FRMs with COAM
    [Documentation]
    ...     Specific KW for classical gNB. It is recommended to use the wrapper KW
    ...     `Check FRMs status` instead!
    ...
    ...     *Scope* Internal
    ...
    [Arguments]   ${num_of_frms}   ${oam_alias}   ${target_status}
    ${frms}   admin.get_frm   timeout=${60}   connection=${oam_alias}
    ${num_of_frms_in_gnb}   Get Length   ${frms}
    # do we have same amount of FRMS
    Run keyword If   '${num_of_frms_in_gnb}'!='${num_of_frms}'   Fail
    # check status for each
    FOR   ${frm}   IN RANGE   ${num_of_frms_in_gnb}
       Nidd availabilityStatus Value Should Be One Of   ${frms[${frm}]['status']}   ${target_status}
       ...   msg=FRM is in unexpected status (Should be: ${target_status})
    END


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
       ...   coam_ulm.Verify cOAM Cell Setup
       ...   alias=${oam_alias}   cell_id=${cell_id}   cell_type=${type}   use_cache=${True}
       Run keyword If   '${setup_state}'=='PASS'   Collections.Append To List   ${internal_cell_list}   ${_internal_cell_dist_id}
    END
    [Teardown]   Set Suite Variable  ${P_CACHED_CELL_STATUS}  ${None}
    [Return]     ${internal_cell_list}


Verify That Cells Are Onair With COAM
    [Documentation]
    ...
    ...     *Scope* Internal
    ...
    [Arguments]   ${oam_alias}   ${num_of_cells}   ${type}=nr
    ${internal_cell_list}   Get list of cells onair   ${oam_alias}   ${num_of_cells}  ${type}
    ${list_length}   Get Length   ${internal_cell_list}
    Should Be Equal As Integers   ${list_length}   ${num_of_cells}   msg=${list_length} of ${num_of_cells} cell(s) onAir!


Get SCF From gNB With cOAM
    [Documentation]
    ...
    ...     *Scope* Internal
    ...
    [Arguments]   ${gnbScfName}   ${resultConfigDir}   ${gnb_id}=${0}
    ${oam_alias}   connect.Setup OAM Http session   node_type=gnb   node_id=${gnb_id}
    admin.get_current_scf_file   ${resultConfigDir}   ${gnbScfName}   timeout=${30}   connection=${oam_alias}


Check Airscale Board Status
    [Documentation]
    ...     Evaluates the result of Adet script running on system module.
    ...
    ...     *Scope* Internal
    ...
    ...     | alias              | ssh connnection alias to common unit board |
    ...     | board_id           | Board ID |
    ...     | CCS_Daemon_node_id | CC&S Node Id |
    ...
    [Arguments]   ${alias}  ${board_id}
    ssh.Force Reconnect   ${alias}
    ${sys_result}   gnb_internal.Get Adet State for Board   connection=${alias}   board_id=${board_id}
    Should Contain   ${sys_result}   ready[0]


Verify On Board SW Version
    [Documentation]
    ...     Check if GNB is updated to expected version
    ...
    ...     *Scope* Internal
    ...
    [Arguments]   ${exp_version}   ${gnb_id}=0   ${du_id}=0   ${comu_id}=0
    ${asik_alias}   connect.Connect to Node Common Unit   node_id=${gnb_id}   du_id=${du_id}   comu_id=${comu_id}
    ${gnb_sw_version}   testline.Fetch Current gNB SW Version   gnb_id=${gnb_id}
    Should Contain   ${gnb_sw_version}   ${exp_version}   msg=SW update Failed!


Wait Until F1 Link Up For All gNBs
    [Documentation]
    ...
    ...    *Scope*  Internal
    ...
    [Arguments]   ${timeout}=10min
    ${GNB_NUM}   Get Length   ${tl.gnbs}
    FOR   ${gnb_id}   IN RANGE   ${GNB_NUM}
       Wait For Minimum Required State For Cell Setup   node_id=${gnb_id}   timeout=${timeout}
       gnb.Wait until F1 link up   gnb_id=${gnb_id}   timeout=${timeout}
    END


Wait Until F1 Link Up
    [Documentation]
    ...
    ...     *Scope* Internal
    ...
    [Arguments]   ${gnb_id}=0   ${timeout}=5min
    Wait Until Keyword Succeeds   ${timeout}   10s   Verify F1 Status   gnb_id=${gnb_id}


Verify F1 Status
    [Documentation]
    ...     check F1 link on GNB
    ...
    ...     *Scope* Internal
    ...
    [Arguments]   ${gnb_id}=0
    ${asik_alias}   connect.Connect to Node Common Unit   node_id=${gnb_id}
    ${common_unit_type}   Get Common Unit Type

    ${cpif_log}     Run Keyword If   '${common_unit_type}'=='ASIK'
    ...             Verify F1 on ASIK  ${asik_alias}
    ...   ELSE IF   'ASI' in '${common_unit_type}' or 'ASO' in '${common_unit_type}'
    ...             Verify F1 on ASIx ASOx  ${asik_alias}
    ...   ELSE      FAIL    Unsupported Controller board!

    ${files_exsit}   Run Keyword And Return Status   Should Not Contain   ${cpif_log}   No such file or directory

    ${cpif_log}   Run Keyword If   ${files_exsit}
    ...           Set Variable   ${cpif_log}
    ...   ELSE    ssh.execute  echo "grep -i 'f1 setup successful' /tmp/node_CPRT00/tmp/startup_cp_rt.log" | bsh 0
    ...           connection=${asik_alias}   timeout=30s

    Should Contain   ${cpif_log}   f1 setup successful   ignore_case=True
    [Teardown]   Run Keyword And Ignore Error   ssh.Disconnect   connection=${asik_alias}


Verify F1 On ASIK
    [Documentation]
    ...
    ...     *Node*   KW will be removed if ASIK support is dropped!
    ...
    ...     *Scope*  Internal
    ...
    ...     *Returns*   Returns the line in log matching 'f1 setup successful'
    ...
    [Arguments]   ${asik_alias}
    ${cpif_log}   ssh.execute   echo "xz --force --stdout -d /tmp/node_CPRT00/tmp/startup_cp_rt.log.xz" | bsh 1 | grep -i 'f1 setup successful'
    ...   connection=${asik_alias}   timeout=60s

    ${not_found_in_xz}   Run Keyword And Return Status   Should Not Contain   ${cpif_log}   f1 setup successful   ignore_case=True
    ${cpif_log}   Run Keyword If   ${not_found_in_xz}
    ...           Verify F1 with log on ASIK  ${asik_alias}
    ...   ELSE    Set Variable    ${cpif_log}
    [Return]   ${cpif_log}


Verify F1 with Log On ASIK
    [Documentation]
    ...
    ...     *Node*   KW will be removed if ASIK support is dropped!
    ...
    ...     *Scope*  Internal
    ...
    ...     *Returns*   Returns the line in log matching 'f1 setup successful'
    ...
    [Arguments]   ${asik_alias}
    ${cpif_log}   ssh.execute   echo "grep -i 'f1 setup successful' /tmp/node_CPRT00/tmp/startup_cp_rt.log" | bsh 1
    ...   connection=${asik_alias}   timeout=30s
    [Return]   ${cpif_log}


Verify F1 on ASIx ASOx
    [Documentation]
    ...
    ...    *Scope*  Internal
    ...
    ...     *Returns*   Returns the line in log matching 'f1 setup successful'
    ...
    [Arguments]   ${asik_alias}
    ${cpif_log}   ssh.execute   xz --force --stdout -d /tmp/node_CPRT00/tmp/startup_cp_rt.log.xz | grep -i 'f1 setup successful'
    ...   connection=${asik_alias}   timeout=30s

    ${not_found_in_xz}   Run Keyword And Return Status   Should Not Contain   ${cpif_log}   f1 setup successful   ignore_case=True

    ${cpif_log}   Run Keyword If   ${not_found_in_xz}
    ...           Verify F1 with log on ASIB ASIL ASOx   ${asik_alias}
    ...   ELSE    Set Variable   ${cpif_log}
    [Return]   ${cpif_log}


Verify F1 with log on ASIB ASIL ASOx
    [Documentation]
    ...
    ...    *Scope*  Internal
    ...
    ...     *Returns*   Returns the line in log matching 'f1 setup successful'
    ...
    [Arguments]   ${asik_alias}
    ${cpif_log}   ssh.execute   grep -i 'f1 setup successful' /tmp/node_CPRT00/tmp/startup_cp_rt.log
    ...   connection=${asik_alias}   timeout=30s
    [Return]   ${cpif_log}


Check gNB X2 Link Status is Available
    [Documentation]
    ...
    ...    Used by wrapper KW `Wait until X2 Link Status is Available`.
    ...    Tested with classical gNB.
    ...
    ...    *Scope*  Internal
    ...
    [Arguments]   ${gnb_id}=${0}   ${lteEnbId_Idx}=${0}
    ${oam_alias}   connect.Setup OAM Http session   node_type=gnb   node_id=${gnb_id}
    @{MOs_lteenb_a}   admin.get_managed_objects   class_name=LTEENB_A   connection=${oam_alias}
    @{MOs_lteenb_r}   admin.get_managed_objects   class_name=LTEENB_R   connection=${oam_alias}
    &{dict_x2LinkLock}   admin.get_parameters    dist_name=${MOs_lteenb_a[${lteEnbId_Idx}]['distName']}   pattern=x2LinkLock
    ...   connection=${oam_alias}
    &{dict_x2LinkStatus}   admin.get_parameters   dist_name=${MOs_lteenb_r[${lteEnbId_Idx}]['distName']}   pattern=x2LinkStatus
    ...   connection=${oam_alias}
    Nidd Value Should be Equal   ${dict_x2LinkLock['x2LinkLock']}       unlocked    msg=x2LinkLock is Locked.
    Nidd Value Should be Equal   ${dict_x2LinkStatus['x2LinkStatus']}   available   msg=x2LinkStatus is not Available.


Reboot gNB System Module via Console
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
    ${alias}   connect.Connect to Node Common Unit   node_id=${gnb_id}   du_id=${du_id}   comu_id=${comu_id}
    ssh.execute   set -m ; ddal -s ddal_boot_set_reset_loop_count 0   connection=${alias}
    ssh.send command   system-module-reboot   connection=${alias}
    Wait Until Ssh Connection Is Down   connection=${alias}
    BuiltIn.Log   SSH connection terminate, System module performs reset!   console=${P_console}
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
       Exit For Loop If   not ${status}
       Sleep   ${delay}
    END
    ${status}   Run Keyword And Ignore Error   Should Not Be Equal As Integers   ${iter+1}   ${retries}
    [Return]   ${status}


Check Matching Pattern In Node State
    [Documentation]
    ...
    ...     *Scope* Internal
    ...
    [Arguments]   ${node_admin_alias}   ${target_proceduralState}
    ${gnbBtsInfo}   admin.get_bts_info   connection=${node_admin_alias}
    ${current_proceduralState}   Set Variable   ${gnbBtsInfo['status']['proceduralState']}
    Nidd Value Should be One Of   ${current_proceduralState}   ${target_proceduralState}
