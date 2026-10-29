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

Get AZQO PowerState
    [Documentation]    Return powerState of AZQO
    [Arguments]    ${gnb_addr}

    Wait Until Keyword Succeeds    1min    10s    coam.connect to    bts_host=${gnb_addr}    name=coam_admin

    ${RUS}=    coam.get_frm    connection=coam_admin
    FOR    ${RU}    IN    @{RUS}
        ${product}=    Get From Dictionary    ${RU}    productName
        ${AZQO}=    Set Variable If    "${product}" == "AZQO"    ${RU}
        IF    '''${AZQO}''' != '''None'''    BREAK
    END
    ${status}=    Get From Dictionary    ${AZQO}    status
    ${powerState}=    Get From Dictionary    ${status}    powerState

    [Teardown]    coam.teardown    connection=coam_admin
    [Return]    ${powerState}
    RETURN    ${powerState}
