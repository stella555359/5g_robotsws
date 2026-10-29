*** Settings ***
Documentation     [PURPOSE] gui activation window keywords
Library           OperatingSystem
Library           BuiltIn
#Library           RemoteSwingLibrary


*** Keywords ***
Focus On Window
    [Documentation]    Short description.
     Wait Until Keyword Succeeds    30s    1s    Select Dialog    regexp=^New.*

Focus On Main Window
    [Documentation]    Short description.
     Wait Until Keyword Succeeds    30s    1s    Select Window    regexp=^TraceViewer.*

Get Elements From First Group of Ne Tree
    [Documentation]    Short description.
    ...
    ...    Args:
    ...        ${treeName}: <description>
    ...
    ...    Returns:
    ...        ${nodeLabel}|@{Cells}: <description>
    [Arguments]    ${treeName}
    Tree Node Should Exist    ${treeName}    0
    ${nodeLabel}=    Get Tree Node Label    ${treeName}    0
    @{Cells}=  Get Tree Node Child Names    ${treeName}    ${nodeLabel}
    [Return]    ${nodeLabel}|@{Cells}

Get First Group of Ne Tree
    [Documentation]    Short description.
    ...
    ...    Args:
    ...        ${treeName}: <description>
    ...
    ...    Returns:
    ...        ${nodeLabel}: <description>
    [Arguments]    ${treeName}
    Tree Node Should Exist    ${treeName}    0
    ${nodeLabel}=    Get Tree Node Label    ${treeName}    0
    [Return]    ${nodeLabel}

Element On Tree Is Clicked And Should Be Selected
    [Documentation]    Short description.
    ...
    ...    Args:
    ...        ${neElement_fqdn}: <description>
    ...        ${treeName}: <description>
    [Arguments]    ${neElement_fqdn}    ${treeName}
    ${nodeLabel}=    Get Tree Node Label    ${treeName}    0
    @{Cells}=  Get Tree Node Child Names    ${treeName}    ${nodeLabel}
    Should Contain    ${nodeLabel}|@{Cells}[0]    ${neElement_fqdn}
    Click On Tree Node    ${treeName}    ${nodeLabel}|@{Cells}[0]
    Tree Node Should Be Selected    ${treeName}    ${nodeLabel}|@{Cells}[0]

Element On Tree Is Clicked And Should Be Deselected
    [Documentation]    Short description.
    ...
    ...    Args:
    ...        ${neElement_fqdn}: <description>
    ...        ${treeName}: <description>
    [Arguments]    ${neElement_fqdn}    ${treeName}
    ${nodeLabel}=    Get Tree Node Label    ${treeName}    0
    @{Cells}=  Get Tree Node Child Names    ${treeName}    ${nodeLabel}
    Should Contain    ${nodeLabel}|@{Cells}[0]    ${neElement_fqdn}
    Click On Tree Node    ${treeName}    ${nodeLabel}|@{Cells}[0]
    Tree Node Should Not Be Selected    ${treeName}    ${nodeLabel}|@{Cells}[0]
