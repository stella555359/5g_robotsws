*** Settings ***

Library    taf.transport.ssh                     WITH NAME      ssh
Library    taf.config.testline.info              WITH NAME      testlineInfo
Library    taf.gnb.oam.coam.admin                WITH NAME      coam
Resource   ../scf.robot


*** Keywords ***
Get gNBCuType
    [Arguments]         ${alias}=cOAM
    [Documentation]   Get the gNB CU Type i.e NSA or SA
    ...     alias:   AdminConnection object or if used, string name alias
    ${type}   Get Single Parameter Value     parameter=gNbCuType    dist_name=NRBTS-1    alias=${alias}
    [Return]  ${type}

BTS PreCheck for Cell_setup
    [Arguments]       ${gnb_id}=0    ${du_id}=0   ${alias}=cOAM
    [Documentation]   Verify BTS F1 setup and x2link listening port status
    Connect to gNB OAM    gnb_index=${gnb_id}    alias=${alias}
    ${cmd_output}     ssh.execute       command=netstat -na | grep -i :38472    connection=${alias}
    should contain    ${cmd_output}     LISTEN
    ${gNBCuType}    Get gNBCuType    alias=${alias}
    ${port_id}    set variable if  '${gNBCuType}' == 'NSA'    36422     38462
    ${cmd_output}     ssh.execute       command=netstat -na | grep -i :${port_id}    connection=${alias}
    should contain    ${cmd_output}     LISTEN

Verify BTS Procedural State
    [Arguments]      ${alias}=cOAM    ${proceduralStates}=Configured    ${timeout}=30
    [Documentation]  Verify BTS Procedural State and blocking State
    ...     alias:   AdminConnection object or if used, string name alias
    ...     timeout: Time to wait for positive procedure result
    ...     proceduralStates: (string or list) BTS procedural States, opetions=Configured or OnAir/Commissioned
    ${bts_status}=      coam.get_bts_statuses            timeout=${timeout}   connection=${alias}
    List Should Contain Value    ${proceduralStates}    ${bts_status['proceduralState']}
    should be equal   ${bts_status['blockingState']}    Unblocked            ignore_case=true

Verify BTS Configuration State
    [Arguments]      ${alias}=cOAM    ${timeout}=30
    [Documentation]  Verify BTS is commissioned state or not
    ...     alias:   AdminConnection object or if used, string name alias
    ...     timeout: Time to wait for positive procedure result
    @{proceduralStates}=    Create List    Configured    OnAir   Commissioned   IntegratedToRan
    Verify BTS Procedural State   alias=${alias}    proceduralStates=${proceduralStates}   timeout=${timeout}

Verify VirtualNodes status
    [Arguments]             ${alias}=cOAM
    [Documentation]         Used to verify all node status are in RUNNING state or not
    ...     alias:          AdminConnection object or if used, string name alias
    ${virtualnodes}=        ssh.execute    command=lxc-ls     connection=${alias}
    @{virtualnode_list}=    Split String   ${virtualnodes}
    ${virtualnode_status}=  ssh.execute      command=lxc-ls --active   connection=${alias}
    :FOR    ${node}    IN   @{virtualnode_list}
    \   Should Contain      ${virtualnode_status}     ${node}

Check testline DU Availability
    [Arguments]      ${gnb_id}=0   ${alias}=cOAM     ${timeout}=30
    [Documentation]                To Check Testline DU availabilty
    ...     gnb_id:                BTS gnb id in Testline configuration i.e ${tl.gnbs[]}
    ...     alias:                 AdminConnection object or if used, string name alias
    ...     timeout:               Time to wait for positive procedure result
    Verify Common Unit State       alias=${alias}    timeout=${timeout}
    Verify Capacity Unit State     alias=${alias}    timeout=${timeout}
    ${bts_sync_status}             coam.get_bts_sync_source_status      connection=${alias}
    should be equal as strings     ${bts_sync_status['tuningMode']}    Normal     ignore_case=true
    Connect to gNB OAM    gnb_index=${gnb_id}    alias=${alias}
    Verify VirtualNodes status     alias=${alias}

Check testline Availability
    [Arguments]      ${gnb_id}=0   ${du_id}=0   ${alias}=cOAM    ${timeout}=30
    [Documentation]  To Check Testline availabilty
    ...     gnb_id:  BTS gnb id in Testline configuration i.e ${tl.gnbs[]}
    ...     alias:   AdminConnection object or if used, string name alias
    ...     timeout: Time to wait for positive procedure result
    wait until keyword succeeds  ${MAX_WAIT_TIME_COAM_CONFIGURED}   30s     Verify BTS Procedural State   alias=${alias}
    ...   proceduralStates=${BTS_PROCEDURAL_STATES}       timeout=${timeout}
    Check testline DU Availability    gnb_id=${gnb_id}    alias=${alias}     timeout=${timeout}
    BTS PreCheck for Cell_setup       gnb_id=${gnb_id}    du_id=${du_id}     alias=${alias}

Verify BTS Sync Mode
    [Arguments]              ${sync_mode}=PhaseSync    ${alias}=cOAM
    [Documentation]          Verify for sync_mode
    ...     sync_mode:       BTS Sync mode
    ...     alias:           AdminConnection object or if used, string name alias
    ${bts_sync}              coam.get_bts_sync_mode     connection=${alias}
    should be equal as strings      ${bts_sync}        ${sync_mode}

Get BTS Active Sync Source
    [Arguments]              ${sync_mode}=PhaseSync      ${tuning_mode}=Normal    ${alias}=cOAM
    [Documentation]          Get Active Sync source from BTS
    ...     sync_mode:       BTS Sync mode
    ...     tuning_mode:     BTS Sync status i.e Normal or Holdover
    ...     alias:           AdminConnection object or if used, string name alias
    ${bts_sync_status}       coam.get_bts_sync_source_status       connection=${alias}
    ${bts_tuningMode}        Get From Dictionary                  ${bts_sync_status}       tuningMode
    should be equal          ${bts_tuningMode}                    ${tuning_mode}
    ${bts_syncMode}          Get From Dictionary                  ${bts_sync_status}       syncMode
    should be equal          ${bts_syncMode}                      ${sync_mode}
    ${syncSourceInfo}        Get From Dictionary                  ${bts_sync_status}       syncSourceInfo
    &{active_sync_dict}      create dictionary
    :FOR    ${sync}    IN    @{syncSourceInfo}
    \   ${sync_status}       Get From Dictionary   ${sync}        isActive
    \   ${active_sync_dict}  set variable if   '${sync_status}' == 'True'      ${sync}
    \   run keyword if       '${sync_status}' == 'True'     Exit For Loop
    should not be empty      ${active_sync_dict}
    [Return]                 ${active_sync_dict}

Verify Active BTS Sync Source
    [Arguments]    ${sync_type}=1pps/ToD from external GNSS receiver   ${alias}=cOAM
    [Documentation]          Verify Active Sync source
    ...     sync_type:       BTS sync type, Ex: 1pps/ToD from external GNSS receiver or TOPP etc
    ...     alias:           AdminConnection object or if used, string name alias
    ${active_sync_dict}=     Get BTS Active Sync Source       alias=${alias}
    ${sync_output}           Get From Dictionary              ${active_sync_dict}        syncInputType
    should be equal as strings           ${sync_output}        ${sync_type}

Verify Common Unit State
    [Arguments]          ${alias}=cOAM     ${ops}=Enabled     ${avs}=online    ${admin_state}=Unlocked   ${timeout}=50
    [Documentation]      Gets ASIK(Common Unit)state and verifies against the state that tester demands
    ...     alias:       AdminConnection object or if used, string name alias
    ...     timeout:     Time to wait for positive procedure result
    ...     ops:         operationalState of Common Unit
    ...     avs:         availabilityStatus of Common Unit
    ...     admin_state: administrativeState of Common Unit
    ${buffer}                coam.get_fsm_info    timeout=${timeout}    connection=${alias}
    :FOR    ${elem}    IN    @{buffer}
    \     should be equal    ${elem['status']['operationalState']}       ${ops}            ignore_case=true
    \     should be equal    ${elem['status']['availabilityStatus']}     ${avs}            ignore_case=true
    \     should be equal    ${elem['status']['administrativeState']}    ${admin_state}    ignore_case=true

Verify Capacity Unit State
    [Arguments]          ${alias}=cOAM    ${ops}=Enabled     ${avs}=Online    ${admin_state}=Unlocked   ${timeout}=50
    [Documentation]      Gets ABIL(Capacity Unit) state and verifies against the state that tester demands
    ...     alias:       AdminConnection object or if used, string name alias
    ...     timeout:     Time to wait for positive procedure result
    ...     ops:         operationalState of Capacity Unit
    ...     avs:         availabilityStatus of Capacity Unit
    ...     admin_state: administrativeState of Capacity Unit
    ${buffer}=               coam.get_fbb_info    timeout=${timeout}    connection=${alias}
    :FOR    ${elem}    IN    @{buffer}
    \     should be equal    ${elem['status']['operationalState']}       ${ops}            ignore_case=true
    \     should be equal    ${elem['status']['availabilityStatus']}     ${avs}            ignore_case=true
    \     should be equal    ${elem['status']['administrativeState']}    ${admin_state}    ignore_case=true
