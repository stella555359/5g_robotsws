*** Settings ***
Documentation
...         14.03 -- solved RF5.0 issues
Library     ./sw_info.py
Resource    ../resources/admin_infomodel.robot
Resource    ../resources/admin.robot
Resource    ./swconfig.robot
Resource    ../resources/pdu.robot

*** Keywords ***
Prepare Testline
    [Documentation]  Works when tests are run from top repository of repository (like Cloud Agent does it)
    ...   Supported TLs:
    ...   TL131, TL132, TL19, TL126, TL18, TL125
    ...   Update - commissioning is performed only in case of missing OnAir state on BTS
    ...   Update 10.03.2020 - 3 steps of TL state correction:
    ...     swconfig flags -> correct scf -> SW reload in case of fault 23

    [Arguments]  ${admin_conn}=default

    Assure swconfig correctness

    ${is_bts_OnAir}    Is BTS OnAir    timeout=5min
    run keyword unless  ${is_bts_OnAir}  Assure commissioning  ${admin_conn}

    ${is_bts_OnAir}    Is BTS OnAir    timeout=10min
    run keyword unless  ${is_bts_OnAir}    Assure RMOD connectivity

    ${is_bts_OnAir}    Is BTS OnAir
    run keyword unless  ${is_bts_OnAir}    Assure SW compatibility on RMOD

    Log to console    Waiting for OnAir started
    custom_commissionings.wait for onair    timeout=10min

Assure commissioning
    [Arguments]  ${admin_conn}
    ${is_bts_NotCommissioned}    Is BTS NotCommissioned
    run keyword if    ${is_bts_NotCommissioned}    Assure commissioning correctness    ${admin_conn}

Is BTS OnAir
    [Arguments]  ${timeout}=10min
    ${status}    run keyword and return status   custom_commissionings.wait for OnAir  ${timeout}
    [Return]  ${status}

Wait for OnAir
    [Arguments]  ${timeout}=10min
    wait until keyword succeeds  ${timeout}  30 s   ADMIN INFOMODEL Check If BTS Is OnAir

Wait for Configured
    [Arguments]  ${timeout}=10min
    wait until keyword succeeds  ${timeout}  30 s   ADMIN INFOMODEL Check If BTS Is Configured

Is BTS NotCommissioned
    [Arguments]  ${timeout}=4min
    ${status}    run keyword and return status   custom_commissionings.Wait for NotCommissioned  ${timeout}
    [Return]  ${status}

Wait for NotCommissioned
    [Arguments]  ${timeout}=4min
    wait until keyword succeeds  ${timeout}  30 s   ADMIN INFOMODEL Check If BTS Is NotCommissioned

Assure commissioning correctness
    [Arguments]  ${admin_conn}=default
    Log to console    Testline not commissionned - commissionig start
    Perform commissioning    ${admin_conn}
    Log to console    Commissioning finished

Perform commissioning
    [Arguments]    ${admin_conn}
    ${scf_path}     get_path_to_scf_file

    Perform commissioning with scf    ${scf_path}    ${admin_conn}

Perform commissioning with scf
    [Arguments]    ${scf_path}    ${admin_conn}
    import library   taf.sbts.oam.coam.admin

    taf.sbts.oam.coam.admin.Perform_commissioning
        ...     scf_file=${scf_path}
        ...     skip_parameter_relation_errors=${True}
        ...     connection=${admin_conn}
        ...     timeout=900

Assure RMOD connectivity
    ${is_rmod_operational}=    ADMIN INFOMODEL Is Rmod operational    ${0}
    run keyword unless    ${is_rmod_operational}    log to console    RMOD is not opearational- rebooting
    run keyword unless    ${is_rmod_operational}    Reboot RMOD
    run keyword unless    ${is_rmod_operational}    log to console    RMOD reboot completed

Assure swconfig correctness
    Assure swconfig flags

Assure swconfig flags
    ${current_sw}=  admin get sw version
    Assure flags are in swconfig  ${current_sw}

Assure SW compatibility on RMOD
    ${is_sw_reload_needed}=    ADMIN Is alarm active    fault_id=23
    run keyword if    ${is_sw_reload_needed}    Reload software

Reload software
    log to console  Software reload start
    ADMIN Download And Update Current Software
    log to console  Software reload finished

Get Current Alarms
    @{alarms}=    ADMIN Get Active Alarms
    ${faults_id}    Create List
    FOR    ${alarm}    In    @{alarms}
        ${dict_fault_id}    Get From Dictionary    ${alarm}    faultId
        append to list    ${faults_id}    ${dict_fault_id}
    END

    Log    ${faults_id}

Reboot RMOD
    PDU Reset All Rmods With UTE Command
