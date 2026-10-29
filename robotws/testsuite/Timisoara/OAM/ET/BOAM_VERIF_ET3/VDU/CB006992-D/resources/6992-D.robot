*** Settings ***
Documentation
...    Author: Raluca Ciobanu / Adrian Cretu (raluca.ciobanu@nokia.com/adrian.1.cretu@nokia.com)
...    Maintainer: Raluca Ciobanu / Adrian Cretu (raluca.ciobanu@nokia.com/adrian.1.cretu@nokia.com)
...    RF diagnostic and RF statistics diagnostic tests. All cells shoud be up for this test.

Library    SeleniumLibrary
Library    OperatingSystem
Library    SSHLibrary
Library    String
Library    Collections

Resource    xpath_6992-D.robot

*** Keywords ***
Login WebEM
    Open Browser   ${WEBEM}   Chrome
    Sleep    5
    ${condition}=  run keyword and return status  page should contain  Advanced
        run keyword if   ${condition}==True  run keywords
        ...     click button  details-button  AND  click link  proceed-link
    Input Text    login-username    Nemuadmin
    Input Text    login-password    Nokia@123
    Click Button   Login
    sleep  10

    ${condition}=  run keyword and return status  page should contain  Confirm
    run keyword if   ${condition}==True  Click Element  //*[contains(text(),'Confirm')]
    Maximize Browser Window
    Sleep   10

Check status of radio or cells
    [Arguments]   ${Shortcut}   ${COUNT}  ${VIEW}   ${Search}

    Press Keys   xpath=//body   ${Shortcut}
    Sleep  5s

    ${status_count}=  Get Element Count   ${COUNT}
    Log to console    I've counted ${status_count} elements

    ${info}=  Get Text   ${VIEW}
    ${lines}=  Get Lines Containing String  ${info}  ${Search}
    ${list}=   Split To Lines  ${lines}

    FOR    ${i}    IN   @{list}
        ${string}=       Convert to string     ${i}
        ${header}=       Replace String     ${string}   '   ${EMPTY}
        ${NAME}=     Fetch From Left    ${header}    ${SPACE}
        Log To Console    ${NAME}
        Mouse Over   xpath://*[contains(text(),"${NAME}")]
        Sleep  2s
        Page should contain    Enabled
        Page Should Contain    On line
        Page Should Contain    Unlocked
    END
    Set Global Variable    ${NAME}

Sign Out
    Sleep  3s
    Click Element  ${LOGOUT}
    Sleep  3s
    Click Element  ${SIGNOUT}
    Sleep  2s
    Close Browser

Start Test
    [Arguments]   ${RFDropdown}   ${DropdownSelect}  ${StartTest}   ${SearchMO}  ${Parameter}
    Click Element    ${Sidebar}
    Sleep    5s
    Click Element    //*[contains(text(),'Test Setup')]
    Wait Until Page Contains    RF Diagnostic Test Setup   timeout=10s
    Scroll Element Into View    ${RFDropdown}
    Click Element    ${RFDropdown}
    Sleep    5s
    Click Element    //*[contains(text(),'${DropdownSelect}')]
    Click Element    //*[contains(text(),'${StartTest}')]
    Page Should Contain Element    //*[contains(text(),'Ongoing')]
    Wait Until Page Contains    Success   timeout=660s
    Press Keys  xpath=//body  ps
    Sleep    5s
    Wait Until Element Is Visible    ${ParameterSearch}
    Input Text    ${ParameterSearch}    ${SearchMO}
    Click Element    ${SearchButton}
    Sleep    5s
    Page Should Contain    ${Parameter}

Delete Test Results
    [Arguments]   ${Results}   ${SearchMO}  ${Parameter}
    Click Element    ${Sidebar}
    Sleep    5s
    Click Element    //*[contains(text(),'Test Setup')]
    Sleep    5s
    Click Element    //*[contains(text(),'${Results}')]
    Sleep    5s
    Click Element    //*[contains(text(),'Clear Finished Results')]
    Page Should Contain Element    //*[contains(text(),'Ongoing')]
    Wait Until Page Contains    Success   timeout=60s
    Press Keys  xpath=//body  ps
    Sleep    5s
    Wait Until Element Is Visible    ${ParameterSearch}
    Input Text    ${ParameterSearch}    ${SearchMO}
    Click Element    ${SearchButton}
    Sleep    5s
    Page Should Not Contain     ${Parameter}
    Page Should Contain         No parameters matching

Save Test Results
    [Arguments]   ${Results}   ${WantedResult}   ${ReportName}
    Click Element    ${Sidebar}
    Sleep    5s
    Click Element    //*[contains(text(),'Test Setup')]
    Sleep    5s
    Click Element    //*[contains(text(),'${Results}')]
    Sleep    5s
    Click Element    //*[contains(text(),'${WantedResult}')]
    Sleep    5s
    ${testfiles}=  OperatingSystem.List Files In Directory    ${path}   *.txt
    Log To Console    ${testfiles}
    ${str}=       Convert to string     ${testfiles}
    ${str1}=    Remove String     ${str}   ['
    ${filename}=      Fetch From Left    ${str1}    '
    ${verif}=   Split String    ${filename}   _
    Should Contain Match    ${verif}    ${ReportName}
    Log To Console    The following result file ${filename} was downloaded.
    ${filepath}=  Catenate  SEPARATOR=    ${path}   ${filename}
    Remove Files   ${filepath}
    Log To Console    This file ${filepath} will be erased

M2M get token
    Open Connection    ${SSH}
    Login   core   ${SSHPASS}
    Sleep    5s
    Write  ${M2MgetToken}
    Sleep  10s
    ${login_output}  Read
    ${line}  Get Lines Containing String    ${login_output}    Token
     ${TOKEN_LINE}   Fetch From Right    ${line}    :
     Sleep    5s
     ${TOKEN_LINE1}   Fetch From Left    ${TOKEN_LINE}     ,
     ${FETCHHH}  Replace String     ${TOKEN_LINE1}   "   ${EMPTY}
     Sleep    5s
     ${TOKEN}   Remove String  ${FETCHHH}  ${SPACE}
     Log To Console    ${TOKEN}
     Set Global Variable    ${TOKEN}
     Close Connection

M2M RF Diagnostic
    [Arguments]   ${RSSI}
    Open Connection    ${SSH}
    Login   core   ${SSHPASS}
    ${command}=   catenate  SEPARATOR=   curl -k -X POST "${WEBEM}:443/api/licensed/v1/diagnostic/rf-diagnostic-test" -H
      ...  "accept: application/json" -H "Content-Type: application/json" -d "{\\"targetCellId\\":-1,\\"actRemoteRfDiag\\
      ...  ":true,\\"thresholds\\":{\\"rxAntennaRSSIHighThreshold\\":-30,\\"rxAntennaRSSILowThreshold\\":${RSSI},
      ...  \\"rfTemperatureHighThreshold\\":90,\\"rfTemperatureLowThreshold\\":-5,
      ...  \\"txAntennaVSWRHighThreshold\\":3}}" -H "Authorization: Bearer ${TOKEN}"
    Write  ${command}
    Sleep    10s
    ${RESULTS}  Read
    Sleep  5s
    Log To Console    ${RESULTS}
    Should Match Regexp    ${RESULTS}    /api/licensed/v1/diagnostic/rf-diagnostic-test/
    Close Connection

M2M RF Statistics Diagnostic
    [Arguments]   ${HighTemp}
    Open Connection    ${SSH}
    Login   core   ${SSHPASS}
    ${command}=   catenate  SEPARATOR=   curl -k -X POST "${WEBEM}:443/api/licensed/v1/diagnostic/rf-statistics-
       ...  diagnostic-test" -H "accept: application/json" -H "Content-Type: application/json" -d "{\\"targetRModId\\":-1,
       ...  \\"actRemoteRfDiag\\":true,\\"thresholds\\":{\\"rfTemperatureHighThreshold\\":${HighTemp},
       ...  \\"rfTemperatureLowThreshold\\":-5}}" -H "Authorization: Bearer ${TOKEN}"
    Write  ${command}
    Sleep    10s
    ${RESULTS}  Read
    Sleep  5s
    Log To Console    ${RESULTS}
    Should Match Regexp    ${RESULTS}    "status" : "ongoing"
    Close Connection

Check results
    [Arguments]   ${Results}   ${WantedResultCollum}   ${WantedOutcomeCollum}   ${NOKResultCollum}   ${NOKOutcomeCollum}
    Click Element    ${Sidebar}
    Sleep    5s
    Click Element    //*[contains(text(),'Test Setup')]
    Sleep    5s
    Click Element    //*[contains(text(),'${Results}')]
    Sleep    5s
    Element Should Contain    ${ResultsTable}    ${WantedResultCollum}
    Element Should Contain    ${ResultsTable}    ${WantedOutcomeCollum}
    Element Should Not Contain    ${ResultsTable}    ${NOKResultCollum}
    Element Should Not Contain    ${ResultsTable}    ${NOKOutcomeCollum}

Stop Start FHGW port
    [Arguments]   ${operation}      ${port}
    Open Connection    ${FHGWSSH}
    Login   root   ${FHGWSSHPASS}
    Write    sudo sonic-cli
    Sleep    2s
    Write    sudo config interface ${operation} ${port}
    Close Connection

Get cell or radio ID
    [Arguments]   ${Shortcut}   ${Search}
    Press Keys   xpath=//body   ${Shortcut}
    Sleep  5s

    ${info}=  Get Text   ${VIEW}
    ${lines}=  Get Lines Containing String  ${info}  ${Search}
    ${list}=   Split To Lines  ${lines}

    FOR    ${i}    IN   @{list}
        ${string}=       Convert to string     ${i}
        ${header}=       Replace String     ${string}   '   ${EMPTY}
        ${NAME}=     Fetch From Left    ${header}    ${SPACE}
    END
    ${ID}=  Fetch From Right    ${NAME}    -
    Log To Console    ${ID}
    Set Global Variable    ${ID}

M2M lock unlock cell
    [Arguments]   ${State}
    Open Connection    ${SSH}
    Login   core   ${SSHPASS}
    ${command}=  set variable  curl -k -X POST "${WEBEM}:443/api/licensed/v1/cells/operations/${State}" -H 
        ...  ${SPACE}"accept: application/json" -H "Content-Type: application/json" -d "{\\"id\\":\\"${ID}\\"}"
        ...  ${SPACE}-H "Authorization: Bearer ${TOKEN}"
    Write  ${command}
    Sleep    10s
    ${RESULTS}  Read
    Sleep  5s
    Log To Console    ${RESULTS}
    Should Match Regexp    ${RESULTS}    "status" : "ongoing"
    Close Connection

M2M lock unlock radio
    [Arguments]   ${State}
    Open Connection    ${SSH}
    Login   core   ${SSHPASS}
    ${command}=  set variable  curl -k -X POST "${WEBEM}:443/api/licensed/v1/rmods/operations/${State}" 
        ...  ${SPACE}-H "accept: application/json"
        ...  ${SPACE}-H "Content-Type: application/json" -d "{\\"dns\\":[\\"MRBTS-1234/EQM-1/APEQM-1/RMOD-${ID}\\"]}"
        ...  ${SPACE}-H "Authorization: Bearer ${TOKEN}"
    Write  ${command}
    Sleep    10s
    ${RESULTS}  Read
    Sleep  5s
    Log To Console    ${RESULTS}
    Should Match Regexp    ${RESULTS}    "status":"ongoing"
    Close Connection

Buttons disabled without selection
    [Arguments]   ${ButtonText}
    Click Element    ${Sidebar}
    Sleep    5s
    Click Element    //*[contains(text(),'Test Setup')]
    Wait Until Page Contains    RF Diagnostic Test Setup   timeout=10s
    ${status}=  Run Keyword And Return Status   Click Element    //*[contains(text(),'${ButtonText}')]
    Log To Console    ${status}
    Should Be Equal    ${status}  ${FALSE}

RF Diagnostic while saving thresholds
    Click Element    ${Sidebar}
    Sleep    5s
    Click Element    //*[contains(text(),'Test Setup')]
    Wait Until Page Contains    RF Diagnostic Test Setup   timeout=10s
    Click Element    ${RFDiagDropdown}
    Click Element    //*[contains(text(),'All NR cells')]
    Input Text    ${HighTempThreshold}    100
    Click Element    //*[contains(text(),'Save Thresholds')]
    ${status}=  Run Keyword And Return Status   Click Element    //*[contains(text(),'Start RF Diagnostic Test')]
    Log To Console    ${status}
    Should Be Equal    ${status}  ${FALSE}
    Wait Until Page Contains    Success   timeout=660s

RF Diagnostic while RF Diagnostic ongoing
    Click Element    ${Sidebar}
    Sleep    5s
    Click Element    //*[contains(text(),'Test Setup')]
    Wait Until Page Contains    RF Diagnostic Test Setup   timeout=10s
    Scroll Element Into View    ${RFDiagDropdown}
    Click Element    ${RFDiagDropdown}
    Sleep    2s
    Click Element    //*[contains(text(),'All NR cells')]
    Click Element    //*[contains(text(),'Start RF Diagnostic Test')]
    Page Should Contain Element    //*[contains(text(),'Ongoing')]
    ${status}=  Run Keyword And Return Status   Click Element    //*[contains(text(),'Start RF Diagnostic Test')]
    Log To Console    ${status}
    Should Be Equal    ${status}  ${FALSE}
    Wait Until Page Contains    Success   timeout=660s

RF Diagnostic while Statistics Diagnostic ongoing
    Click Element    ${Sidebar}
    Sleep    5s
    Click Element    //*[contains(text(),'Test Setup')]
    Wait Until Page Contains    RF Diagnostic Test Setup   timeout=10s
    Scroll Element Into View    ${RFDiagDropdown}
    Click Element    ${RFDiagDropdown}
    Sleep    2s
    Click Element    //*[contains(text(),'All NR cells')]
    Scroll Element Into View    ${RFStatDropdown}
    Wait Until Element Is Visible    ${RFStatDropdown}   timeout=10s
    Click Element    ${RFStatDropdown}
    Sleep    2s
    Click Element    //*[contains(text(),'All radios')]
    Click Element    //*[contains(text(),'Start Statistics Diagnostic Test')]
    Page Should Contain Element    //*[contains(text(),'Ongoing')]
    ${status}=  Run Keyword And Return Status   Click Element    //*[contains(text(),'Start RF Diagnostic Test')]
    Log To Console    ${status}
    Should Be Equal    ${status}  ${FALSE}
    Wait Until Page Contains    Success   timeout=660s
    
RF Diagnostic while all readios reset
    Press Keys   xpath=//body   rs
    Sleep  5s

    ${info}=  Get Text   ${VIEW}
    ${lines}=  Get Lines Containing String  ${info}  RMOD-
    ${list}=   Split To Lines  ${lines}
    M2M get token
    
    FOR    ${i}    IN   @{list}
        ${string}=       Convert to string     ${i}
        ${header}=       Replace String     ${string}   '   ${EMPTY}
        ${NAME}=     Fetch From Left    ${header}    ${SPACE}
        ${ID}=  Fetch From Right    ${NAME}    -
        Log To Console    ${ID}
        Open Connection    ${SSH}
        Login   core   ${SSHPASS}
        ${command}=  set variable  curl -k -X POST "${WEBEM}:443/api/licensed/v1/rmods/operations/resets"
           ...  ${SPACE}-d '{"ids": ["${ID}"],"resetReason": "user"}' -H "Accept: application/json"
           ...  ${SPACE}-H "Authorization: Bearer ${Token}"
        Write  ${command}  
        Sleep  1s
        Close Connection
        Sleep    2s
    END

    Wait Until Page Contains     Integrated to RAN    timeout=660s
    Click Element    ${Sidebar}
    Sleep    5s
    Click Element    //*[contains(text(),'Test Setup')]
    Wait Until Page Contains    RF Diagnostic Test Setup   timeout=10s
    Scroll Element Into View    ${RFDiagDropdown}
    Click Element    ${RFDiagDropdown}
    Sleep    2s
    Page Should Contain    No results found
    Wait Until Page Contains     OnAir    timeout=660s

Saving thresholds with value out of range
    Click Element    ${Sidebar}
    Sleep    5s
    Click Element    //*[contains(text(),'Test Setup')]
    Wait Until Page Contains    RF Diagnostic Test Setup   timeout=10s
    Input Text    ${HighTempThreshold}    160
    Sleep   2s
    ${status}=  Run Keyword And Return Status    Click Element    //*[contains(text(),'Save Thresholds')]
    Should Be Equal    ${status}  ${FALSE}
    Input Text    ${HighTempThreshold}    80
    Click Element    //*[contains(text(),'Save Thresholds')]
    Wait Until Page Contains    Success   timeout=660s

RF Diagnostic while clearing results
    Click Element    ${Sidebar}
    Sleep    5s
    Click Element    //*[contains(text(),'Test Setup')]
    Wait Until Page Contains    RF Diagnostic Test Setup   timeout=10s
    Scroll Element Into View    ${RFDiagDropdown}
    Click Element    ${RFDiagDropdown}
    Click Element    //*[contains(text(),'All NR cells')]
    Click Element    //*[contains(text(),'Start RF Diagnostic Test')]
    Wait Until Page Contains    Success   timeout=660s

    Click Element    //*[contains(text(),'RF Diagnostic Test Results')]
    Sleep    5s
    Click Element    //*[contains(text(),'Clear Finished Results')]
    Click Element    //*[contains(text(),'Test Setup')]
    Scroll Element Into View    ${RFDiagDropdown}
    Click Element    ${RFDiagDropdown}
    Click Element    //*[contains(text(),'All NR cells')]
    ${status}=  Run Keyword And Return Status   Click Element    //*[contains(text(),'Start RF Diagnostic Test')]
    Log To Console    ${status}
    Should Be Equal    ${status}  ${FALSE}

RF Diagnostic flag is set to false
    Press Keys  xpath=//body  ps
    Sleep    5s
    Click Element    //*[contains(text(),'Create Delta Plan')]
    Sleep    2s
    Click Element     ${DeltaPlanOK}
    Sleep    2s
    Wait Until Element Is Visible    ${ParameterSearch}
    Input Text    ${ParameterSearch}    actRemoteRfDiag
    Click Element    ${SearchButton}
    Sleep    5s
    Click Element    ${FlagDropdown}
    Sleep    5s
    Click Element    xpath=//li[@aria-selected="false"]
    Sleep    2s
    Click Element    //*[contains(text(),'Validate Plan')]
    Wait Until Page Contains    Validate plan operation finished   timeout=660s
    Click Element    //*[contains(text(),'Activate Plan')]
    Sleep    2s
    Click Element    //*[contains(text(),'Execute')]
    Wait Until Page Contains    Plan activation has finished successfully   timeout=660s
    Click Element    //*[contains(text(),'Done')]

    Click Element    ${Sidebar}
    Sleep    5s
    Click Element    //*[contains(text(),'Test Setup')]
    Wait Until Page Contains    RF Diagnostic Test Setup   timeout=10s
    Sleep    10s
    Scroll Element Into View    ${RFDiagDropdown}
    Click Element    ${RFDiagDropdown}
    Click Element    //*[contains(text(),'All NR cells')]
    ${status}=  Run Keyword And Return Status   Click Element    //*[contains(text(),'Start RF Diagnostic Test')]
    Log To Console    ${status}
    Should Be Equal    ${status}  ${FALSE}
