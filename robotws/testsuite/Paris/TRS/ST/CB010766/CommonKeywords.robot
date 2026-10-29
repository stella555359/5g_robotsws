*** Settings ***
Documentation
...                 author: David Jollivet
...                 contact: david.jollivet@nokia.com
...                 CB010802: Deep Sleep Mode Support for RF6.1 TDD RRH


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
