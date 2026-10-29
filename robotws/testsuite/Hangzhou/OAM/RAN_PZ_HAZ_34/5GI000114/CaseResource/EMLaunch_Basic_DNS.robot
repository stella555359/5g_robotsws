*** Settings ***
Documentation
    ...    Author: yin.4.chen@nokia-sbell.com

Resource   ../Resource/NetAct_Fast_Pass_common.robot
Library    re

*** Keyword ***
EMLaunch Basic DNS Test Case
    Step1: Trigger EMLaunch Ping Combine DNS
    Step2: Check Ping Output Combine DNS
    Step3: Trigger EMLaunch Trace Route DNS
    Step4: Check Trace Route Output DNS
    Step5: Trigger EMLaunch Reset MRBTS DNS
    Step6: Check EMLaunch Reset output DNS

Step1: Trigger EMLaunch Ping Combine DNS
    Select Main Window
    Wait Until Keyword Succeeds   1m   10s   swing.Select From Main Menu And Wait   menuPath=Window|Reset Workspace
    Wait Until Keyword Succeeds   1m   10s   Menu Item Should Exist   menuPath=Tools|Managed Objects|Object Explorer
    Wait Until Keyword Succeeds   30s   5s   Select From Menu And Wait   menuPath=Tools|Managed Objects|Object Explorer
    Wait Until Keyword Succeeds   30s   5s   Click On Tree Node   Objects   PLMN-PLMN|${MO_name}   \#0
    Select From Popup Menu On Selected Tree Nodes   identifier=Objects   menuPath=Element Management|Ping

Step2: Check Ping Output Combine DNS
    Select Main Window
    List Components In Context
    Run Keyword And Ignore Error    Wait Until Keyword Succeeds   5m   10s
    ...   Text Field Should Be Disabled   identifier=Command Editor TextField
    ${stream_term_comp}=    Run Keyword And Return Status    Click on Component   identifier=StreamTerm
    ${output}    Run Keyword If    ${stream_term_comp}    Get Terminal Text   locator=StreamTerm
    ${output}    Replace String    ${output}    \n    ${EMPTY}
    Return From Keyword If   '${Dns_flag}'=='True'   Should Contain    ${output}    PING ${IP}
    ...   And   Should Contain    ${output}    64 bytes from ${IP}
    ...   And   Should Contain    ${output}    Connection Stream to Server closed.
    Should Contain    ${output}    PING ${cu_addr}
    Should Contain    ${output}    64 bytes from ${cu_addr}
    Should Contain    ${output}    Connection Stream to Server closed.

Step3: Trigger EMLaunch Trace Route DNS
    Select Main Window
    Wait Until Keyword Succeeds   1m   10s   swing.Select From Main Menu And Wait   menuPath=Window|Reset Workspace
    Wait Until Keyword Succeeds   1m   10s   Menu Item Should Exist   menuPath=Tools|Managed Objects|Object Explorer
    Wait Until Keyword Succeeds   30s   5s   Select From Menu And Wait   menuPath=Tools|Managed Objects|Object Explorer
    Wait Until Keyword Succeeds   30s   5s   Click On Tree Node   Objects   PLMN-PLMN|${MO_name}   \#0
    Select From Popup Menu On Selected Tree Nodes   identifier=Objects   menuPath=Element Management|Trace Route

Step4: Check Trace Route Output DNS
    Sleep    20s
    Select Main Window
    List Components In Context
    Run Keyword And Ignore Error    Wait Until Keyword Succeeds   5m   10s
    ...   Text Field Should Be Disabled   identifier=Command Editor TextField
    ${stream_term_comp}=    Run Keyword And Return Status    Click on Component   identifier=StreamTerm
    ${output}    Run Keyword If    ${stream_term_comp}    Get Terminal Text   locator=StreamTerm
    ${output}    Replace String    ${output}    \n    ${EMPTY}
    Return From Keyword If   '${Dns_flag}'=='True'   Should Contain    ${output}    traceroute to ${IP}
    ...   And   Should Contain    ${output}    Connection Stream to Server closed.
    Should Contain    ${output}    traceroute to ${cu_addr}
    # Should Contain    ${output}    64 bytes from ${MO_ip}
    Should Contain    ${output}    Connection Stream to Server closed.

Step5: Trigger EMLaunch Reset MRBTS DNS
    Select Main Window
    Wait Until Keyword Succeeds   1m   10s   swing.Select From Main Menu And Wait   menuPath=Window|Reset Workspace
    Wait Until Keyword Succeeds   1m   10s   Menu Item Should Exist   menuPath=Tools|Managed Objects|Object Explorer
    Wait Until Keyword Succeeds   30s   5s   Select From Menu And Wait   menuPath=Tools|Managed Objects|Object Explorer
    Wait Until Keyword Succeeds   30s   5s   Click On Tree Node   Objects   PLMN-PLMN|${MO_name}|${NO_NAME}   \#0
    Wait Until Keyword Succeeds    30s    5s
    ...   Select From Popup Menu On Selected Tree Nodes   identifier=Objects   menuPath=Element Management|State Management|Reset NRBTS
    Select Dialog   identifier=Confirm Operation
    Wait Until Keyword Succeeds   3 times   10s   Push Button   identifier=Yes

Step6: Check EMLaunch Reset output DNS
    Sleep    20s
    Select Main Window
    List Components In Context
    Run Keyword And Ignore Error    Wait Until Keyword Succeeds   10m   10s
    ...   Text Field Should Be Disabled   identifier=Command Editor TextField
    ${stream_term_comp}=    Run Keyword And Return Status    Click on Component   identifier=StreamTerm
    ${output}    Run Keyword If    ${stream_term_comp}    Get Terminal Text   locator=StreamTerm
    ${output}    Replace String    ${output}    \n    ${EMPTY}
    Should Contain    ${output}    Operation RESET
    Should Contain    ${output}    PLMN-PLMN/${MO_name}
    ${match}   Evaluate   re.findall("Resetting(.*)\\[Done\\]", "${output}")[0]   re
    Should Contain    ${output}    Connection Stream to Server closed.
    Should Not Contain    ${output}    [Warning]
    Sleep    10s
    swing.Select From Main Menu And Wait   menuPath=Window|Reset Workspace

Case Setup: EMLaunch Basic DNS
    Log To Console    \nStart To EMLaunch Basic Case Setup!
    Remove File    ${OUTPUT_DIR}/start.jnlp
    Open Netact Start Page    url=${START_PAGE}    username=${START_PAGE_USER}    password=${START_PAGE_PASSWORD}    showall=${true}
    ${remote_port}   Open Application    Monitor
    Set Test Variable    ${remote_port}

Case Teardown: EMLaunch Basic DNS
    Log To Console   Start To EMLaunch Basic Case Teardown!
    Run Keyword And Ignore Error   Close Java Application by Remote Port   ${remote_port}
    Run Keyword And Ignore Error   Close All Java Application Forced
    Run Keyword And Ignore Error   selenium_netact.Logout
    Log To Console   Wait GNB OnAir...
    All Wait GNB Startup
