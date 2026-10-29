*** Settings ***
Documentation
...                 author: David Jollivet
...                 contact: david.jollivet@nokia.com
...                 CB007935: Deep Sleep Mode Support for RF6.1 TDD RRH


*** Keywords ***
Check All Cells Enabled
    [Documentation]    Get 4G&5G cells status
    [Arguments]    ${enb_addr}    ${gnb_addr}

    COAM Get 4g status enabled    ${enb_addr}
    COAM Get 5g status enabled    ${gnb_addr}

Get Number Of energySaving Cells
    [Documentation]    Return number of nr cell in energySaving mode
    [Arguments]    ${gnb_addr}

    Wait Until Keyword Succeeds    1min    10s    coam.connect to    bts_host=${gnb_addr}    name=coam_admin

    ${value}=    coam.get_cell_list    connection=coam_admin    detailed_output=False
    ${cells}=    Get From Dictionary    ${value}    cells
    ${nrcells}=    Get From Dictionary    ${cells}    nr

    ${count}=    Convert To Integer    0
    FOR    ${nrcell}    IN    @{nrcells}
        ${energySavingState}=    Get From Dictionary    ${nrcell}    energySavingState
        ${count}=    Set Variable if    "${energySavingState}" == "energySaving"
        ...    ${count+1}    ${count}
    END

    [Teardown]    coam.teardown    connection=coam_admin
    [Return]    ${count}
    RETURN    ${count}

Get AZQJ PowerState
    [Documentation]    Return powerState of AZQJ
    [Arguments]    ${gnb_addr}

    Wait Until Keyword Succeeds    1min    10s    coam.connect to    bts_host=${gnb_addr}    name=coam_admin

    ${RUS}=    coam.get_frm    connection=coam_admin
    FOR    ${RU}    IN    @{RUS}
        ${product}=    Get From Dictionary    ${RU}    productName
        ${AZQJ}=    Set Variable If    "${product}" == "AZQJ"    ${RU}
        IF    '''${AZQJ}''' != '''None'''    BREAK
    END
    ${status}=    Get From Dictionary    ${AZQJ}    status
    ${powerState}=    Get From Dictionary    ${status}    powerState

    [Teardown]    coam.teardown    connection=coam_admin
    [Return]    ${powerState}
    RETURN    ${powerState}

Get AVQL PowerState
    [Documentation]    Return powerState of AVQL
    [Arguments]    ${gnb_addr}

    Wait Until Keyword Succeeds    1min    10s    coam.connect to    bts_host=${gnb_addr}    name=coam_admin

    ${RUS}=    coam.get_frm    connection=coam_admin
    FOR    ${RU}    IN    @{RUS}
        ${product}=    Get From Dictionary    ${RU}    productName
        ${AVQL}=    Set Variable If    "${product}" == "AVQL"    ${RU}
        IF    '''${AVQL}''' != '''None'''    BREAK
    END
    ${status}=    Get From Dictionary    ${AVQL}    status
    ${powerState}=    Get From Dictionary    ${status}    powerState

    [Teardown]    coam.teardown    connection=coam_admin
    [Return]    ${powerState}
    RETURN    ${powerState}

Check TOPP Status
    [Documentation]    Check that all TOPP are locked
    [Arguments]    ${gnb_addr}

    Wait Until Keyword Succeeds    1min    10s    coam.connect to    bts_host=${gnb_addr}    name=coam_admin
    ${object_value}=    coam.get_managed_objects    TOPP_R    connection=coam_admin

    FOR    ${sync}    IN    @{object_value}
        ${param}=    Get From Dictionary    ${sync}    parameters
        ${lockState}=    Get From Dictionary    ${param}    lockState
        Should Be Equal    ${lockState}    Locked
    END

    [Teardown]    coam.teardown    connection=coam_admin

Check synceStatus is OK
    [Documentation]    Check that RU SYNCE status is OK
    [Arguments]    ${gnb_addr}

    Wait Until Keyword Succeeds    1min    10s    coam.connect to    bts_host=${gnb_addr}    name=coam_admin
    ${object_value}=    coam.get_managed_objects    SYNCE_R    connection=coam_admin

    FOR    ${sync}    IN    @{object_value}
        ${param}=    Get From Dictionary    ${sync}    parameters
        ${lockState}=    Get From Dictionary    ${param}    synceStatus
        Should Be Equal    ${lockState}    OK
    END

    [Teardown]    coam.teardown    connection=coam_admin

Check synceStatus is NOK
    [Documentation]    Check that RU SYNCE status is NOK
    [Arguments]    ${gnb_addr}

    Wait Until Keyword Succeeds    1min    10s    coam.connect to    bts_host=${gnb_addr}    name=coam_admin
    ${object_value}=    coam.get_managed_objects    SYNCE_R    connection=coam_admin

    FOR    ${sync}    IN    @{object_value}
        ${param}=    Get From Dictionary    ${sync}    parameters
        ${lockState}=    Get From Dictionary    ${param}    synceStatus
        Should Be Equal    ${lockState}    NOK
    END

    [Teardown]    coam.teardown    connection=coam_admin

Connect to RU with Type
    [Documentation]    Open SSH connection to RU through CPRI/eCPRI with its type
    [Arguments]
    ...    ${bts_addr}
    ...    ${bts_smod_username}
    ...    ${bts_smod_password}
    ...    ${ru_username}
    ...    ${ru_password}
    ...    ${ru_type}

    # connection to SMOD
    ${MyRU}=    SSHLibrary.Open Connection    host=${bts_addr}
    SSHLibrary.Login    username=${bts_smod_username}    password=${bts_smod_password}

    # remove ssh known hosts
    ${command}=    Set Variable    rm -f /user/toor4nsn/.ssh/known_hosts
    SSHLibrary.Write    text=${command}
    Sleep    5s
    ${output}=    SSHLibrary.Read

    # connection to FHNET
    ${command}=    Set Variable    ls -ld /tmp/* |grep FHNET|grep node_0x|awk '{print $9}'|awk -F_ '{print $2}'
    SSHLibrary.Write    text=${command}
    ${fhnet}=    SSHLibrary.Read
    SSHLibrary.Write    text=lxc-attach -n ${fhnet}
    Sleep    5s

    # connection to RU
    ${command}=    Set Variable    cat /rom/config/FRIps.txt | grep ${ru_type} | awk -F\\; '{print $3}'
    SSHLibrary.Write    text=${command}
    ${result}=    SSHLibrary.Read
    ${ru_ip}=    Get Line    ${result}    0
    ${command}=    Set Variable    ssh -o StrictHostKeyChecking=no ${ru_username}@${ru_ip}

    SSHLibrary.Write    text=${command}
    Sleep    5s
    ${output}=    SSHLibrary.Read

    ${command}=    Set Variable    ${ru_password}
    SSHLibrary.Write    text=${command}
    Sleep    5s
    ${output}=    SSHLibrary.Read

    [Return]    ${MyRU}
    RETURN    ${MyRU}

Get RU MTIE line number
    [Documentation]    Connect to RU and returns SyncE_MTIE_measurements.txt number of lines or zero
    [Arguments]
    ...    ${bts_addr}
    ...    ${bts_smod_username}
    ...    ${bts_smod_password}
    ...    ${ru_username}
    ...    ${ru_password}
    ...    ${ru_type}

    TRY
        ${RU_shell}=    Connect to RU with Type
        ...    ${bts_addr}
        ...    ${bts_smod_username}
        ...    ${bts_smod_password}
        ...    ${ru_username}
        ...    ${ru_password}
        ...    ${ru_type}
    EXCEPT
        Log To Console    can't connect to RU
        RETURN    0
    END

    Switch Connection    ${RU_shell}
    ${thor}=    Set Variable    ssh 192.168.101.17
    TRY
        SSHLibrary.Write    text=${thor}
    EXCEPT
        Log To Console    can't connect to Thor
        RETURN    0
    END

    Sleep    10s
    ${banner}=    SSHLibrary.Read

    ${check}=    Set Variable    wc -l /var/volatile/log/hwapi/sync/SyncE_MTIE_measurements.txt

    SSHLibrary.Write    text=${check}
    Sleep    10s
    ${result}=    SSHLibrary.Read

    ${taille}=    Get Length    ${result}

    ${first}=    Get Line    ${result}    0
    @{word}=    Split String    ${first}
    ${value}=    Get From List    ${word}    0
    Log To Console    ${value}

    ${mtie_nb_lines}=    Check Integer    ${value}

    [Return]    ${mtie_nb_lines}
    RETURN    ${mtie_nb_lines}

Check X2 Status
    [Documentation]    Check that all X2 are available
    [Arguments]    ${gnb_addr}

    Wait Until Keyword Succeeds    1min    10s    coam.connect to    bts_host=${gnb_addr}    name=coam_admin
    ${object_value}=    coam.get_managed_objects    LTEENB_R    connection=coam_admin

    FOR    ${ENB}    IN    @{object_value}
        ${param}=    Get From Dictionary    ${ENB}    parameters
        ${status}=    Get From Dictionary    ${param}    x2LinkStatus
        Should Be Equal    ${status}    available
    END

    [Teardown]    coam.teardown    connection=coam_admin

Check eCPRI Status
    [Documentation]    Check eCPRI status
    [Arguments]    ${gnb_addr}

    Wait Until Keyword Succeeds    1min    10s    coam.connect to    bts_host=${gnb_addr}    name=coam_admin
    ${links}=    coam.get_managed_objects    CABLINK_R    connection=coam_admin
    FOR    ${link}    IN    @{links}
        ${object}=    Get From Dictionary    ${link}    parameters
        ${link}=    Get From Dictionary    ${object}    linkSpeed
        IF    "${link}" == "eCpri25"    Check eCPRI_LinkMode    ${object}
    END

Check eCPRI_LinkMode
    [Documentation]    Check LinkMode of eCPRI Link
    [Arguments]    ${ecpri}

    ${linkModeSynchronization}=    Get From Dictionary    ${ecpri}    linkModeSynchronization
    ${linkModeConfiguration}=    Get From Dictionary    ${ecpri}    linkModeConfiguration
    Should Be Equal As Strings    ${linkModeSynchronization}    True
    Should Be Equal As Strings    ${linkModeConfiguration}    True
