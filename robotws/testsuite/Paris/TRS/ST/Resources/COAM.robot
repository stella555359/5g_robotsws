*** Settings ***
Documentation
...                 Keywords Purpose:
...                 keywords relative to coam
...
...                 AUTHOR (I&V-2):
...                 Claude Gourdon    claude.gourdon@nokia.com
...                 David Jollivet    david.jollivet@nokia.com

Library             taf.gnb.oam.coam.admin    WITH NAME    coam
Library             taf.transport.ssh    WITH NAME    ssh
Library             Collections
Library             String


*** Keywords ***
COAM Get bts status enabled
    [Documentation]    Get bts status
    [Arguments]    ${bts_addr}
    coam.connect_to    bts_host=${bts_addr}    name=coam_admin
    &{status}=    coam.get_bts_statuses    connection=coam_admin
    Should be equal as strings    ${status.proceduralState}    OnAir
    [Teardown]    coam.teardown    connection=coam_admin

COAM Get bts status disabled
    [Documentation]    Get bts status
    [Arguments]    ${bts_addr}
    coam.connect_to    bts_host=${bts_addr}    name=coam_admin
    &{status}=    coam.get_bts_statuses    connection=coam_admin
    Should not be equal as strings    ${status.proceduralState}    OnAir
    [Teardown]    coam.teardown    connection=coam_admin

COAM Check startup completed
    [Arguments]    ${bts_addr}
    wait until keyword succeeds    20 min    10s    COAM Get bts status enabled    ${bts_addr}

COAM Check Fault Displayed in WebEM
    [Documentation]    Check Fault id is displayed on WebEM
    [Arguments]    ${bts_addr}    ${fault_id}
    coam.connect_to    bts_host=${bts_addr}    name=coam_admin
    ${getfaultlist}=    coam.get_active_alarms    connection=coam_admin
    log    faultlist:${getfaultlist}
    ${activefaultlist}=    convert to string    ${getfaultlist}
    log    activefaultlist:${activefaultlist}
    should contain    ${activefaultlist}    'faultId': ${fault_id},
    [Teardown]    coam.teardown    connection=coam_admin

COAM Check Fault not Displayed in WebEM
    [Documentation]    Check Fault id is not displayed on WebEM
    [Arguments]    ${bts_addr}    ${fault_id}
    coam.connect_to    bts_host=${bts_addr}    name=coam_admin
    ${getfaultlist}=    coam.get_active_alarms    connection=coam_admin
    log    faultlist:${getfaultlist}
    ${activefaultlist}=    convert to string    ${getfaultlist}
    log    activefaultlist:${activefaultlist}
    should not contain    ${activefaultlist}    'faultId': ${fault_id},
    [Teardown]    coam.teardown    connection=coam_admin

COAM gNB Reset site
    [Documentation]    Reset site
    [Arguments]    ${bts_addr}
    coam.connect_to    bts_host=${bts_addr}    name=coam_admin
    coam.reset_site    connection=coam_admin
    [Teardown]    coam.teardown    connection=coam_admin

COAM get bts snapshot
    [Documentation]    Perform Snapshot on BTS
    [Arguments]    ${bts_addr}    ${path}

    # Name of the SnapShot file
    ${timestamp}=    Get Current Date    result_format=%Y%m%d-%H%M
    ${filename}=    Set Variable    SnapShot_${bts_addr}_${timestamp}.zip

    # SnapShot command
    coam.connect_to    bts_host=${bts_addr}    name=coam_admin
    coam.get_snapshot    target_file_name=${path}/${filename}
    ...    coverage=Full    timeout=600    connection=coam_admin

COAM Get Object
    [Documentation]    Get object full name
    [Arguments]    ${bts_addr}    ${object}
    Wait Until Keyword Succeeds    1min    10s    coam.connect to    bts_host=${bts_addr}    name=coam_admin
    ${object_value}=    coam.get_managed_objects    ${object}    connection=coam_admin
    Log To Console    object full name is
    Log To Console    ${object_value}
    [Teardown]    coam.teardown    connection=coam_admin

COAM Get Parameter Value
    [Documentation]    Get parameter
    [Arguments]    ${bts_addr}    ${dist_name}    ${parameter}=.*
    Wait Until Keyword Succeeds    1min    10s    coam.connect to    bts_host=${bts_addr}    name=coam_admin
    ${param_value}=    coam.get_parameters    dist_name=${dist_name}    pattern=${parameter}    connection=coam_admin
    Log To Console    ${param_value}
    [Teardown]    coam.teardown    connection=coam_admin
    [Return]    ${param_value}
    RETURN    ${param_value}

COAM Get Value From First Object
    [Documentation]    Get value from object without fullname
    [Arguments]    ${bts_addr}    ${object}
    Wait Until Keyword Succeeds    1min    10s    coam.connect to    bts_host=${bts_addr}    name=coam_admin
    ${object_value}=    coam.get_managed_objects    ${object}    connection=coam_admin
    ${first_value}=    Get From List    ${object_value}    0
    ${param_value}=    Get From Dictionary    ${first_value}    parameters
    Log To Console    ${param_value}
    [Teardown]    coam.teardown    connection=coam_admin
    [Return]    ${param_value}
    RETURN    ${param_value}

COAM Get Phase Error
    [Documentation]    Get Phase error from SYNC_R
    [Arguments]    ${bts_addr}
    ${value}=    COAM Get Value From First Object    ${bts_addr}    SYNC_R
    ${phase_error}=    Get From Dictionary    ${value}    localTimeError
    Log To Console    phaseError is ${phase_error}
    [Return]    ${phase_error}
    RETURN    ${phase_error}

COAM Check Phase Error Lower Than
    [Documentation]    Get Phase error from SYNC_R
    [Arguments]    ${bts_addr}    ${maxValue}
    ${phase_error}=    COAM Get Phase Error    ${bts_addr}
    Should Be True    ${phase_error} < ${maxValue}

COAM Get BtsId
    [Documentation]    Get BtsId from LNBTS
    [Arguments]    ${bts_addr}
    ${value}=    COAM Get Value From First Object    ${bts_addr}    LNBTS
    ${bts_id}=    Get From Dictionary    ${value}    btsId
    Log To Console    BtsId is ${bts_id}
    [Return]    ${bts_id}
    RETURN    ${bts_id}

COAM Get Estimated Time To Disable App
    [Documentation]    Get duration of estimatedTimeToDisableApp
    [Arguments]    ${bts_addr}
    ${temp}=    COAM Get Value From First Object    ${bts_addr}    SYNCTEMPLATE_R
    ${estimated}=    Get From Dictionary    ${temp}    estimatedTimeToDisableApp
    ${duration}=    Get From Dictionary    ${estimated}    duration
    Log To Console    estimatedTimeToDisableApp is ${duration}
    [Return]    ${duration}
    RETURN    ${duration}

COAM SCF load
    [Documentation]    load new SCF on BTS
    [Arguments]    ${bts_addr}    ${scf}
    Wait Until Keyword Succeeds    1min    10s    coam.connect to    bts_host=${bts_addr}    name=coam_admin
    ${result}=    coam.perform_commissioning    scf_file=${scf}    connection=coam_admin    timeout=900
    Log To Console    SCF load status is ${result}
    [Teardown]    coam.teardown    connection=coam_admin
    [Return]    ${result}
    RETURN    ${result}

COAM Parameter Online update
    [Documentation]    change parameter value
    [Arguments]
    ...    ${bts_addr}
    ...    ${dist_name}
    ...    ${parameter}
    ...    ${new_value}
    ...    ${activation}=true
    ...    ${skip_parameter_relation_errors}=true
    Wait Until Keyword Succeeds    1min    10s    coam.connect to    bts_host=${bts_addr}    name=coam_admin
    ${res}=    coam.perform_parameter_recommissioning
    ...    dist_name=${dist_name}
    ...    parameter=${parameter}
    ...    operation=update
    ...    value=${new_value}
    ...    skip_parameter_relation_errors=${skip_parameter_relation_errors}
    ...    should_activate=${activation}
    ...    timeout=${600}
    ...    connection=coam_admin
    Log To Console    Change ${dist_name}/${parameter} to ${new_value}
    [Teardown]    coam.teardown    connection=coam_admin

COAM Parameter Online delete
    [Documentation]    delete parameter value
    [Arguments]
    ...    ${bts_addr}
    ...    ${dist_name}
    ...    ${parameter}
    ...    ${activation}=true
    ...    ${skip_parameter_relation_errors}=true
    Wait Until Keyword Succeeds    1min    10s    coam.connect to    bts_host=${bts_addr}    name=coam_admin
    ${res}=    coam.perform_parameter_recommissioning
    ...    dist_name=${dist_name}
    ...    parameter=${parameter}
    ...    operation=delete
    ...    value=0
    ...    skip_parameter_relation_errors=${skip_parameter_relation_errors}
    ...    should_activate=${activation}
    ...    timeout=${600}
    ...    connection=coam_admin
    Log To Console    Remove ${dist_name}/${parameter}
    [Teardown]    coam.teardown    connection=coam_admin

COAM Delta Commissioning
    [Documentation]    change list of parameters values
    [Arguments]    ${bts_addr}    ${params_update}

    Log To Console    Change parameters:
    Log To Console    ${params_update}

    Wait Until Keyword Succeeds    1min    10s    coam.connect to    bts_host=${bts_addr}    name=coam_admin

    # create delta
    coam.create_delta

    FOR    ${param}    IN    @{params_update}
        ${distname}    ${object}    ${value}=    Set Variable    ${param}
        coam.append_parameter_update_to_delta    ${distname}    ${object}    ${value}
    END
    ${delta_update}=    coam.get_delta
    ${res}=    coam.perform_delta_recommissioning    delta_file=${delta_update}    connection=coam_admin

    [Teardown]    coam.teardown    connection=coam_admin

COAM Get Synchronization Status
    [Documentation]    Verify synchronization
    [Arguments]    ${bts_addr}
    Wait Until Keyword Succeeds    1min    10s    coam.connect to    bts_host=${bts_addr}    name=coam_admin
    ${synchro_output}=    coam.get_synchronization_information    timeout=30    connection=coam_admin
    Log To Console    ${synchro_output}
    [Teardown]    coam.teardown    connection=coam_admin
    [Return]    ${synchro_output}
    RETURN    ${synchro_output}

COAM Get Synchronization Mode
    [Documentation]    Verify synchronization Mode
    [Arguments]    ${bts_addr}
    ${synchro}=    COAM Get Synchronization Status    ${bts_addr}
    ${synchro}=    Get From Dictionary    ${synchro}    syncMode
    Log To Console    ${synchro}
    [Return]    ${synchro}
    RETURN    ${synchro}

COAM Get Tuning Mode
    [Documentation]    Verify synchronization Mode
    [Arguments]    ${bts_addr}
    ${synchro}=    COAM Get Synchronization Status    ${bts_addr}
    ${synchro}=    Get From Dictionary    ${synchro}    tuningMode
    Log To Console    ${synchro}
    [Return]    ${synchro}
    RETURN    ${synchro}

COAM Check Tuning Mode
    [Documentation]    Verify synchronization Mode
    [Arguments]    ${bts_addr}    ${expected_tuning_mode}
    ${synchro}=    COAM Get Synchronization Status    ${bts_addr}
    ${synchro}=    Get From Dictionary    ${synchro}    tuningMode
    Should Be Equal    ${synchro}    ${expected_tuning_mode}

COAM Get TOPP Status
    [Documentation]    Get TOPP Status
    [Arguments]    ${bts_addr}
    ${synchro}=    COAM Get Synchronization Status    ${bts_addr}
    ${synchro}=    Get From Dictionary    ${synchro}    syncSourceInfo

    # Should check that first element is indeed TOPP
    ${topp}=    Get From List    ${synchro}    0
    ${topp}=    Get From Dictionary    ${topp}    status
    ${topp}=    Get From Dictionary    ${topp}    usability
    Log To Console    ${topp}
    [Return]    ${topp}
    RETURN    ${topp}

COAM Get SYNCE Status
    [Documentation]    Get SYNCE Status
    [Arguments]    ${bts_addr}
    ${synchro}=    COAM Get Synchronization Status    ${bts_addr}
    ${synchro}=    Get From Dictionary    ${synchro}    syncSourceInfo

    # Should check that second element is indeed SYNCE
    ${synce}=    Get From List    ${synchro}    1
    ${synce}=    Get From Dictionary    ${synce}    status
    ${synce}=    Get From Dictionary    ${synce}    usability
    Log To Console    ${synce}
    [Return]    ${synce}
    RETURN    ${synce}

COAM Get PM counter
    [Documentation]    Retrieve a PM counter
    [Arguments]    ${bts_addr}    ${type}    ${PM_path}    ${PM_id}

    Wait Until Keyword Succeeds    1min    10s    coam.connect to    bts_host=${bts_addr}    name=coam_admin

    # All counters from BTS
    ${res}=    coam.get_counters_info    connection=coam_admin    timeout=1min

    # Retrieve specific counter from the full list
    ${res}=    Get From Dictionary    ${res}    ${type}
    ${path}=    Split String    ${PM_path}    /
    ${len}=    Get Length    ${path}
    # Remove From List    ${path}    ${len-1}
    FOR    ${index}    IN    @{path}
        ${res}=    Get From Dictionary    ${res}    ${index}
    END
    ${values}=    Get From Dictionary    ${res}    ${PM_id}
    ${list}=    Get Dictionary Keys    ${values}

    # Get only last value
    Reverse List    ${list}
    ${latest_value}=    Get From Dictionary    ${values}    ${list[0]}
    Log To Console    Counter value is
    Log To Console    ${latest_value}

    [Teardown]    coam.teardown    connection=coam_admin
    [Return]    ${latest_value}
    RETURN    ${latest_value}

COAM Get sum PM counter
    [Documentation]    Retrieve the sum of a PM counter for last n periods
    [Arguments]    ${bts_addr}    ${type}    ${PM_path}    ${PM_id}    ${period_num}

    Wait Until Keyword Succeeds    1min    10s    coam.connect to    bts_host=${bts_addr}    name=coam_admin

    # All counters from BTS
    ${res}=    coam.get_counters_info    connection=coam_admin    timeout=1min

    # Retrieve specific counter from the full list
    ${res}=    Get From Dictionary    ${res}    ${type}
    ${path}=    Split String    ${PM_path}    /
    ${len}=    Get Length    ${path}
    # Remove From List    ${path}    ${len-1}
    FOR    ${index}    IN    @{path}
        ${res}=    Get From Dictionary    ${res}    ${index}
    END
    ${values}=    Get From Dictionary    ${res}    ${PM_id}
    ${list}=    Get Dictionary Keys    ${values}

    # Get last values
    Reverse List    ${list}
    ${latest_values}=    Set Variable    0
    ${period_num}=    Convert To Integer    ${period_num}

    # 0, 1, ..., period_num - 1
    FOR    ${index}    IN RANGE    0    ${period_num}
        ${temp}=    Get From Dictionary    ${values}    ${list[${index}]}
        ${latest_values}=    Evaluate    ${latest_values} + ${temp}
    END
    Log To Console    Sum of counter value is
    Log To Console    ${latest_values}

    [Teardown]    coam.teardown    connection=coam_admin
    [Return]    ${latest_values}
    RETURN    ${latest_values}

COAM Check PM counter Superior or equal
    [Documentation]    Check is PM counter value si superior or equal to a value
    [Arguments]    ${bts_addr}    ${type}    ${PM_path}    ${PM_id}    ${comparison_value}

    ${result}=    COAM Get PM counter    ${bts_addr}    ${type}    ${PM_path}    ${PM_id}
    Should Be True    ${result} >= ${comparison_value}

COAM Get 5g status enabled
    [Documentation]    Get 5G cells status
    [Arguments]    ${bts_addr}
    coam.connect_to    bts_host=${bts_addr}    name=coam_admin
    ${nrcell_list}=    coam.get_managed_objects    NRCELL_R    timeout=10    connection=coam_admin

    # All cells are enabled
    FOR    ${nrcell}    IN    @{nrcell_list}
        Run keyword and continue on failure    Should Be Equal As Strings
        ...    ${nrcell}[parameters][operationalState]    enabled
    END

COAM Get 5g status disabled
    [Documentation]    Get 5G cells status
    [Arguments]    ${bts_addr}
    coam.connect_to    bts_host=${bts_addr}    name=coam_admin
    ${nrcell_list}=    coam.get_managed_objects    NRCELL_R    timeout=10    connection=coam_admin

    # At least one NR cell is disabled
    @{status_list}=    Create List
    FOR    ${nrcell}    IN    @{nrcell_list}
        Append To List    ${status_list}    ${nrcell}[parameters][operationalState]
    END
    Run keyword and continue on failure    List Should Contain Value    ${status_list}    disabled

COAM Get 4g status enabled
    [Documentation]    Get 4G cells status
    [Arguments]    ${bts_addr}
    coam.connect_to    bts_host=${bts_addr}    name=coam_admin
    ${lncel_list}=    coam.get_managed_objects    LNCEL_R    timeout=10    connection=coam_admin

    # All cells are enabled
    FOR    ${lncel}    IN    @{lncel_list}
        Run keyword and continue on failure    Should Be Equal As Strings
        ...    ${lncel}[parameters][operationalState]    enabled
    END

COAM Block Cell
    [Documentation]    Block cell
    [Arguments]    ${bts_addr}    ${cell_distname}

    Wait Until Keyword Succeeds    1min    10s    coam.connect to    bts_host=${bts_addr}    name=coam_admin
    coam.block_cell    ${cell_distname}    timeout=120    connection=coam_admin

COAM Unblock Cell
    [Documentation]    Block cell
    [Arguments]    ${bts_addr}    ${cell_distname}

    Wait Until Keyword Succeeds    1min    10s    coam.connect to    bts_host=${bts_addr}    name=coam_admin
    coam.unblock_cell    ${cell_distname}    timeout=120    connection=coam_admin

COAM Get SW Branch
    [Documentation]    Get SW build Branch
    [Arguments]    ${bts_addr}

    Wait Until Keyword Succeeds    1min    10s    coam.connect to    bts_host=${bts_addr}    name=coam_admin
    ${sw_info}=    coam.get_software_info    connection=coam_admin
    ${sw_active}=    Get From Dictionary    ${sw_info}    Active SW version
    ${branch}    ${built}=    Split String    ${sw_active}    _    1

    [Teardown]    coam.teardown    connection=coam_admin
    [Return]    ${branch}
    RETURN    ${branch}
