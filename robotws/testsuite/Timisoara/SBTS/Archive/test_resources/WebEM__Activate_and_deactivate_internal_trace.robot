*** Settings ***
Resource    ../../common_resources/ca_WebEM_general.robot

*** Keywords ***
TC__WebEM__Activate_and_deactivate_internal_trace
    [Documentation]
    ...  [CASE LINK]: https://jiradc.ext.net.nokia.com/browse/TAT-23224
    ...
    ...  *****************
    ...  Basic information
    ...  *****************
    ...  This test case is created to activate and deactivate internal trace.
    ...  In step one, WebEM will show sending succeeded if the delta scf to update TRBLCADM.actInternalTrace value to true sent and activated
    ...  successful, then operator can do debug trace.
    ...  WebEM will show sending failed if the delta scf sent or activated failed, operator cannot do debug trace.
    ...  In step two, WebEM will show sending succeeded if the delta scf to update TRBLCADM.actInternalTrace value to false sent and activated
    ...  successfully, then operator cannot do debug trace. If there are ongoing traces before deactivate, then all ongoing traces shall be not
    ...  ongoing after deactivated successfully.
    ...  WebEM will show sending failed if the delta scf sent or activated failed, operator can still do debug trace.
    ...
    ...  ******************
    ...  History of changes
    ...  ******************
    ...  - 30.08.2023 - https://jiradc.ext.net.nokia.com/browse/TAT-23224 - Initial TAT creation
    ...  - 03.10.2023 - https://jiradc.ext.net.nokia.com/browse/TAT-26205 - Wrong xpath for buttons and text changed	

    Set Tags    CA-WebEM    OWNER-george.gheban@nokia.com    AUTHOR-cristina.adam@nokia.com
    ...    MAINTAINER-cristina.adam@nokia.com    GROUP_IN_CHARGE-TIM_3_Vrf    PHASE-CRT    SW-SBTS23

    Step1: Operator click activate button
    Step2: Operator click deactivate button

Step1: Operator click activate button
    Log  \nStep1: Operator click activate button  console=true
    ${BTS_ID}  Admin Get BTS ID
    Perform Parameter Recommissioning  dist_name=MRBTS-${BTS_ID}/MNL-1/MNLENT-1/TRBLCADM-1  parameter=actInternalTrace  operation=update
    ...  value=false  skip_parameter_relation_errors=True  timeout=180
    Navigate To Debug Tracing
    Activate internal trace

Step2: Operator click deactivate button
    Log  \nStep2: Operator click deactivate button  console=true
    Click Element  xpath=//*[contains(@a-text, 'Deactivate')]
    ${release}  Fetch from left  ${active SW version}  _
    Run keyword if  '${release}' > 'SBTS23R4'
    ...  Wait Until Element Is Visible    locator=//span[contains(text(),'Send deactivate succeeded')]  timeout=120
    ...  ELSE
    ...  Wait Until Element Is Visible    locator=//span[contains(text(),'Send succeeded')]  timeout=120
    Log  \nInternal Trace is deactivated with successful.  console=true

Navigate To Debug Tracing
    Wait Until Element Is Visible   locator=//*[@id="main-view"]/div/div[1]/app-header/main-menu/nav-item[6]/div/nav-menu-link
    ...                             timeout=30
    Click Element    locator=//*[@id="main-view"]/div/div[1]/app-header/main-menu/nav-item[6]/div/nav-menu-link
    Wait Until Element Is Visible   locator=//*[@id="main-view"]/div/div[1]/app-header/main-menu/nav-item[6]/div/ng-transclude/div/div[22]/nav-link
    ...                             timeout=30
    Click Element    locator=//*[@id="main-view"]/div/div[1]/app-header/main-menu/nav-item[6]/div/ng-transclude/div/div[22]/nav-link
    Sleep  10s  This sleep is for page to appear

TC Setup
    Common Test Setup
    WebEM Setup

TC Teardown
    WebEM Teardown
    Common Test Teardown
