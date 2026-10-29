*** Settings ***
Documentation     [PURPOSE] setting window gui keywords
#Library           RemoteSwingLibrary


*** Variables ***
${generalTabName}               General
${securityTabName}              Security
${networkTabName}               Network

${generalTabOptions}       GENERAL_TAB_OPTIONS
${securityTabOptions}      SECURITY_TAB_OPTIONS
${networkTabOptions}       NETWORK_TAB_OPTIONS


*** Keywords ***
Open Settings Window
    [Documentation]    Short description.
    wait until keyword succeeds    60s    2s    Select Window    regexp=^TraceViewer.*
    wait until keyword succeeds    60s    2s    Select From Main Menu    Options|Settings
    wait until keyword succeeds    60s    2s    Select Dialog    regexp=^Settings.*

Select Setting Option
    [Documentation]    Short description.
    ...
    ...    Args:
    ...        ${tabName}: <description>
    ...        ${tabOption}: <description>
    ...        ${index}: <description>
    [Arguments]  ${tabName}    ${tabOption}    ${index}
    wait until keyword succeeds    20s    2s    Select Tab            ${tabName}
    wait until keyword succeeds    20s    2s    Click On List Item    ${tabOption}    ${index}
