*** Settings ***
Documentation
...  contact:       pawel.1.wisniewski@nokia.com, wiktor.jarosinski@nokia.com
...  maintainer:    pawel.1.wisniewski@nokia.com, wiktor.jarosinski@nokia.com

Library         taf.sbts.oam.coam.admin  WITH NAME    coam
Library         Collections
Library         testsuite/Wroclaw/RRM/VRF_WRO2_T01/resources/legacy/common.py  WITH NAME  common
Resource        testsuite/Wroclaw/RRM/VRF_WRO2_T01/resources/legacy/common_kw.robot

*** Keywords ***
Check if BTS operational
    ${expected_status}  Create dictionary  operationalState=Enabled  blockingState=Unblocked  proceduralState=OnAir
    ${actual_status}  coam.get bts statuses  30s  coam
    should be equal  ${expected_status}   ${actual_status}

Get BBMODs dist names
    [Arguments]  ${connection}=coam
    ${bbmods_ids}  Create list
    ${bbmods}  coam.get_fbb_info  timeout=30s  connection=${connection}
    ${bbmods}  Set variable  ${bbmods}
    FOR    ${bbmod}    IN  @{bbmods}
        append to list    ${bbmods_ids}  ${bbmod['id']['internal']}
    END
    [Return]  ${bbmods_ids}

Check BBMODs state
    [Arguments]  ${operationalState}=enabled
    ...          ${administrativeState}=Unlocked
    ...          ${proceduralStatus}=configured
    ...          ${connection}=coam
    ${expected_status}  Create dictionary
    ...                 operationalState=${operationalState}
    ...                 administrativeState=${administrativeState}
    ...                 proceduralStatus=${proceduralStatus}
    ${bbmods}  coam.get_fbb_info  timeout=30s  connection=${connection}
    FOR    ${bbmod}    IN  @{bbmods}
        ${bbmod_name}  Split String  ${bbmod['id']['internal']}  /
        ${bbmod_name}  Set variable  ${bbmod_name[-1]}
        Dictionary Should Contain Sub Dictionary  ${bbmod['status']}  ${expected_status}  msg=${bbmod_name} ...FAILED
        Log to console   ${bbmod_name} ...OK
    END


Get rmods dist names
    ${hw_info}  coam.get_detected_hw_info  30s  coam
    ${rmods_ids}  Create list
    ${rmods}  Set variable  ${hw_info['radioModules']['rmod']}
    FOR    ${rmod}    IN  @{rmods}
        append to list    ${rmods_ids}  ${rmod['id']['runtime']}
    END
    [Return]  ${rmods_ids}

Lock rmod
    [Arguments]  ${rmod}
    coam.lock    dist_name=${rmod}
    ...             timeout=600    connection=coam

Unlock rmod
    [Arguments]  ${rmod}
    coam.unlock    dist_name=${rmod}
    ...             timeout=600    connection=coam

Get rmods statuses
    ${hw_info}  coam.get_detected_hw_info  30s  coam
    ${rmods_statuses}  Create dictionary
    ${rmods}  Set variable  ${hw_info['radioModules']['rmod']}
    FOR    ${rmod}    IN  @{rmods}
        Set To Dictionary  ${rmods_statuses}  ${rmod['id']['runtime']}=${rmod['status']}
    END
    [Return]  ${rmods_statuses}

Check if rmod unlocked
    [Arguments]  ${rmod}  ${rmods_statuses}
    ${rmod_name}  Split String  ${rmod}  /
    ${rmod_name}  Set variable  ${rmod_name[-1]}
    ${expected_status}  Create dictionary  administrativeState=Unlocked
    ...                                    availabilityStatus=Online
    ...                                    operationalState=Enabled
    ...                                    proceduralStatus=configured
    ...                                    usageState=Active
    ${actual_status}    Set variable  ${rmods_statuses['${rmod}']}
    BuiltIn.Should Be Equal  ${actual_status}  ${expected_status}  msg=${rmod_name} ...FAILED  values=False
    Log to console  ${rmod_name} ...OK

Check if rmod locked
    [Arguments]  ${rmod}  ${rmods_statuses}
    ${rmod_name}  Split String  ${rmod}  /
    ${rmod_name}  Set variable  ${rmod_name[-1]}
    ${expected_status}  Create dictionary  administrativeState=Locked
    ...                                    availabilityStatus=Online
    ...                                    operationalState=Enabled
    ...                                    proceduralStatus=configured
    ...                                    usageState=Idle
    ${actual_status}    Set variable  ${rmods_statuses['${rmod}']}
    BuiltIn.Should Be Equal  ${actual_status}  ${expected_status}  msg=${rmod_name} ...FAILED  values=False
    Log to console  ${rmod_name} ...OK

Get cells dist names
    ${cells_ids}  Create list
    ${cell_info}  coam.Get Cells Info  timeout=20s  connection=coam
    ${cells_number}  Get length  ${cell_info}
    FOR    ${index}    IN RANGE    ${cells_number}
        append to list   ${cells_ids}  ${cell_info[${index}]['id']['internal']}
    END
    [Return]  ${cells_ids}

Lock cell
    [Arguments]  ${cell}
    coam.lock    dist_name=${cell}
    ...             timeout=600    connection=coam

Unlock cell
    [Arguments]  ${cell}
    coam.unlock    dist_name=${cell}
    ...             timeout=600    connection=coam

Get cells statuses
    ${cells_statuses}  Create dictionary
    ${cell_info}  coam.Get Cells Info  timeout=20s  connection=coam
    ${cells_number}  Get Length  ${cell_info}
    FOR    ${index}    IN RANGE    ${cells_number}
        Set to dictionary  ${cells_statuses}  ${cell_info[${index}]['id']['internal']}=${cell_info[${index}]['status']}
    END
    [Return]  ${cells_statuses}

Check if cell unlocked
    [Arguments]  ${cell}  ${cells_statuses}
    ${cell_name}  Split String  ${cell}  /
    ${cell_name}  Set variable  ${cell_name[-1]}
    ${expected_status}  Create dictionary  usageState=Active
    ...                                    proceduralStatus=configured
    ...                                    availabilityStatus=Online
    ...                                    administrativeState=Unlocked
    ...                                    operationalState=Enabled
    ...                                    blockingState=Unblocked
    ${actual_status}    Set variable  ${cells_statuses['${cell}']}
    BuiltIn.Should Be Equal  ${actual_status}  ${expected_status}  msg=${cell_name} ...FAILED  values=False
    Log to console  ${cell_name} ...OK

Check if cell locked
    [Arguments]  ${cell}  ${cells_statuses}
    ${cell_name}  Split String  ${cell}  /
    ${cell_name}  Set variable  ${cell_name[-1]}
    ${expected_status}  Create dictionary  usageState=Idle
    ...                                    proceduralStatus=initializing
    ...                                    availabilityStatus=Offline
    ...                                    administrativeState=Locked
    ...                                    operationalState=Disabled
    ...                                    blockingState=Unblocked
    ${actual_status}    Set variable  ${cells_statuses['${cell}']}
    BuiltIn.Should Be Equal  ${actual_status}  ${expected_status}  msg=${cell_name} ...FAILED  values=False
    Log to console  ${cell_name} ...OK

Check if X2 alrams active
    ${a}  Run keyword and ignore error  Alarm active  62003
    ${b}  Run keyword and ignore error  Alarm active  7300
    Should be true  '${a}[0]' == 'PASS' or '${b}[0]' == 'PASS'

Check if X2 alrams not active
    ${a}  Run keyword and ignore error  Alarm not active  62003
    ${b}  Run keyword and ignore error  Alarm not active  7300
    Should be true  '${a}[0]' == 'PASS' or '${b}[0]' == 'PASS'

Check BBMODs state 22r2
    [Arguments]  ${operationalState}=Enabled
    ...          ${administrativeState}=Unlocked
    ...          ${proceduralStatus}=configured
    ...          ${connection}=coam
    ${expected_status}  Create dictionary
    ...                 operationalState=${operationalState}
    ...                 administrativeState=${administrativeState}
    ...                 proceduralStatus=${proceduralStatus}
    ${bbmods}  coam.get_fbb_info  timeout=30s  connection=${connection}
    FOR    ${bbmod}    IN  @{bbmods}
        ${bbmod_name}  Split String  ${bbmod['id']['internal']}  /
        ${bbmod_name}  Set variable  ${bbmod_name[-1]}
        Dictionary Should Contain Sub Dictionary  ${bbmod['status']}  ${expected_status}  msg=${bbmod_name} ...FAILED
        Log to console   ${bbmod_name} ...OK
    END
