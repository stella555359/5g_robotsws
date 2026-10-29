*** Settings ***
Documentation
...                 Keywords Purpose:
...                 Simple TRS procedures
...
...                 AUTHOR (SyVe):
...                 David Jollivet    david.jollivet@nokia.com

Library             ${CURDIR}/SwitchManager.py


*** Keywords ***
Execute Keyword Multiple Times
    [Documentation]    Run keyword for a certain time
    [Arguments]    ${duration}    ${stepTime}    ${keywordName}    @{params}

    # Current Time
    ${currentTime}=    Get Time
    # correction 20220621 : issue if summertime
    # ${epochDate}=    Convert Date    ${currentTime}    epoch
    # end correction

    # Time to end checks
    # correction 20220621 : issue if summertime
    # ${endTimeString}=    Add Time To Date    ${duration}    ${epochDate}
    ${endTimeString}=    Add Time To Date    ${currentTime}    ${duration}
    # end correction
    ${endTime}=    Convert Date    ${endTimeString}    epoch

    # While...
    FOR    ${Index}    IN RANGE    9999
        # Check BTS status and stop checkd if it fails
        Log To Console    Check BTS status
        ${Resultat}=    Run Keyword And Return Status    ${keywordName}    @{params}
        IF    ${Resultat} == ${False}    Fail    ${keywordName}
        IF    ${Resultat} == ${False}    BREAK

        # Wait for next check
        Sleep    ${stepTime}

        # Stop if it's time to
        ${currentTime}=    Get Time
        ${epochDate}=    Convert Date    ${currentTime}    epoch
        IF    ${epochDate} > ${endTime}    BREAK
    END

Trigger lost of ptp synchro
    [Documentation]    Shutdown the port on switch to trigger lost of ptp
    [Arguments]    ${switch_conf}
    SwitchManager.get_switch    ${switch_conf}
    SwitchManager.ssh_connect_to_switch
    SwitchManager.ptp_shutdown
    [Teardown]    run keyword and ignore error    SwitchManager.ssh_disconnect_to_switch

Trigger recovery of ptp synchro
    [Documentation]    no Shutdown the port on switch to recover ptp
    [Arguments]    ${switch_conf}
    SwitchManager.get_switch    ${switch_conf}
    SwitchManager.ssh_connect_to_switch
    SwitchManager.ptp_noshutdown
    [Teardown]    run keyword and ignore error    SwitchManager.ssh_disconnect_to_switch

Trigger change of synce SSM
    [Documentation]    SSM value change on TL port
    [Arguments]    ${switch_conf}    ${ssm}
    SwitchManager.get_switch    ${switch_conf}
    SwitchManager.ssh_connect_to_switch
    SwitchManager.synce_set_ssm    ${ssm}
    [Teardown]    run keyword and ignore error    SwitchManager.ssh_disconnect_to_switch

Start All Logs
    [Documentation]    Start all common logs for the tests

    # BTS logs 5G
    # stop already started btslog and purge directory
    Run Keyword And Continue On Failure    ssh.Connect To    hostname=${5g_vm_addr}    username=${5g_vm_username}
    ...    password=${5g_vm_password}    alias=5G_VM
    Run Keyword And Continue On Failure    ssh.Send Command    pkill -f btslog    connection=5G_VM
    Run Keyword And Continue On Failure    ssh.Send Command    rm /tmp/btslog2/*    connection=5G_VM
    Run Keyword And Continue On Failure    ssh.Disconnect    connection=5G_VM

    # Start new logs
    Run Keyword And Continue On Failure
    ...    Setup BTSLOG
    ...    ${5g_vm_addr}
    ...    ${5g_vm_username}
    ...    ${5g_vm_password}
    ...    5G_BTSLOG
    Run Keyword And Continue On Failure    Start BTSLOG    5G_BTSLOG

    # BTS logs 4G
    # stop already started btslog and purge directory
    Run Keyword And Continue On Failure    ssh.Connect To    hostname=${4g_vm_addr}    username=${4g_vm_username}
    ...    password=${4g_vm_password}    alias=4G_VM
    Run Keyword And Continue On Failure    ssh.Send Command    pkill -f btslog    connection=4G_VM
    Run Keyword And Continue On Failure    ssh.Send Command    rm /tmp/btslog2/*    connection=4G_VM
    Run Keyword And Continue On Failure    ssh.Disconnect    connection=4G_VM

    # Start new logs
    Run Keyword And Continue On Failure
    ...    Setup BTSLOG
    ...    ${4g_vm_addr}
    ...    ${4g_vm_username}
    ...    ${4g_vm_password}
    ...    4G_BTSLOG
    Run Keyword And Continue On Failure    Start BTSLOG    4G_BTSLOG

    # BTS logs RRH
    # stop already started btslog and purge directory
    # Run Keyword And Continue On Failure    ssh.Connect To    hostname=${rrh_vm_addr}    username=${rrh_vm_username}
    # ...    password=${rrh_vm_password}    alias=RRH_VM
    # Run Keyword And Continue On Failure    ssh.Send Command    pkill -f btslog    connection=RRH_VM
    # Run Keyword And Continue On Failure    ssh.Send Command    rm /tmp/btslog2/*    connection=RRH_VM
    # Run Keyword And Continue On Failure    ssh.Disconnect    connection=RRH_VM

    # Start new logs
    # Run Keyword And Continue On Failure    Setup BTSLOG    ${rrh_vm_addr}    ${rrh_vm_username}    ${rrh_vm_password}    RRH_BTSLOG
    # Run Keyword And Continue On Failure    Start BTSLOG    RRH_BTSLOG

Get All Logs
    [Documentation]    Start all common logs for the tests

    # BTS logs
    Run Keyword And Continue On Failure    Stop BTSLOG    5G_BTSLOG    ${result_path}
    Run Keyword And Continue On Failure    Stop BTSLOG    4G_BTSLOG    ${result_path}
    # Run Keyword And Continue On Failure    Stop BTSLOG    RRH_BTSLOG    ${result_path}

    # Snaphost
    Run Keyword And Continue On Failure    COAM get bts snapshot    ${bts_addr}    ${result_path}

Should Exp Be True
    [Documentation]    Check an expression
    [Arguments]    ${expression}
    IF    not(${expression})    Fail    Number does not match Expression pattern

Get 4G DSS Cell
    [Documentation]    Get Distname value of first 4G DSS Cell from eNB
    [Arguments]    ${bts_addr}

    Wait Until Keyword Succeeds    1min    10s    coam.connect to    bts_host=${bts_addr}    name=coam_admin
    ${object_value}=    coam.get_managed_objects    DSSNR_A    connection=coam_admin
    ${first_value}=    Get From List    ${object_value}    0
    ${distname_value}=    Get From Dictionary    ${first_value}    distName
    @{elts}=    Split String    ${distname_value}    /
    ${cell_dss}=    Remove String    ${distname_value}    /DSSNR_A-0
    Log To Console    ${cell_dss}

    [Return]    ${cell_dss}
    RETURN    ${cell_dss}

Get 5G DSS Cell
    [Documentation]    Get Distname value of first 4G DSS Cell from gNB
    [Arguments]    ${bts_addr}

    Wait Until Keyword Succeeds    1min    10s    coam.connect to    bts_host=${bts_addr}    name=coam_admin
    ${object_value}=    coam.get_managed_objects    NRDSSLTE_A    connection=coam_admin
    ${first_value}=    Get From List    ${object_value}    0
    ${distname_value}=    Get From Dictionary    ${first_value}    distName
    @{elts}=    Split String    ${distname_value}    /
    ${cell_dss}=    Remove String    ${distname_value}    /NRDSSLTE_A-1
    Log To Console    ${cell_dss}

    [Return]    ${cell_dss}
    RETURN    ${cell_dss}

Get RMOD VAL
    [Documentation]    Search RMOD-X of a RU type
    [Arguments]    ${gnb_addr}    ${ru_type}

    Wait Until Keyword Succeeds    1min    10s    coam.connect to    bts_host=${gnb_addr}    name=coam_admin

    ${rmod_val}=    Set Variable    None
    ${RUS}=    coam.get_frm    connection=coam_admin
    FOR    ${RU}    IN    @{RUS}
        ${product}=    Get From Dictionary    ${RU}    productName
        IF    "${product}" == "${ru_type}"
            ${rmod_val}=    Get RMOD num    ${RU}
        ELSE
            ${rmod_val}=    Set Variable    ${None}
        END
        IF    "${rmod_val}" != "None"    BREAK
    END
    [Teardown]    coam.teardown    connection=coam_admin
    [Return]    ${rmod_val}
    RETURN    ${rmod_val}

Get RMOD num
    [Documentation]    GET RU ID
    [Arguments]    ${RU}

    ${RUID}=    Get From Dictionary    ${RU}    id
    ${RUCONF}=    Get From Dictionary    ${RUID}    configuration
    ${RUVAL}=    Get Substring    ${RUCONF}    -1
    [Return]    RMOD-${RUVAL}
    RETURN    RMOD-${RUVAL}

Check Integer
    [Arguments]    ${value}
    ${is_integer}=    Run Keyword And Return Status    Convert To Integer    ${value}
    IF    ${is_integer} == True
        ${value}=    Convert To Integer    ${value}
    ELSE
        ${value}=    Set Variable    0
    END
    [Return]    ${value}
    RETURN    ${value}
