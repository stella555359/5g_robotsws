*** Settings ***
Documentation
    ...    Author: yin.4.chen@nokia-sbell.com

Resource   ../Resource/NetAct_Fast_Pass_common.robot
Library    re

*** Variables ***
${scf_file_name}   old_commission_EMLaunch_lock_and_unlock.xml

*** Keyword ***
EMLaunch Lock and unlock Test Case
    Step1: Trigger EMLaunch Lock NRCELL Combine
    Step2: Check Lock output Combine
    Step3: Trigger EMLaunch unlock NRCELL Combine
    Step4: Check unlock output Combine
    Step5: Trigger EMLaunch Lock NRCELLs under NRBTS
    Step6: Check Lock under NRBTS output
    Step7: Trigger EMLaunch unlock NRCELLs under NRBTS
    Step8: Check unlock under NRBTS output

Step1: Trigger EMLaunch Lock NRCELL Combine
    Select Main Window
    Wait Until Keyword Succeeds   1m   10s   swing.Select From Main Menu And Wait   menuPath=Window|Reset Workspace
    Wait Until Keyword Succeeds   1m   10s   Menu Item Should Exist   menuPath=Tools|Managed Objects|Object Explorer
    Wait Until Keyword Succeeds   30s   5s   Select From Menu And Wait   menuPath=Tools|Managed Objects|Object Explorer
    Wait Until Keyword Succeeds   30s   5s   Click On Tree Node   Objects   PLMN-PLMN|${MO_name}|${NO_name}|NRCELL-1   \#0
    Wait Until Keyword Succeeds   30s   5s
    ...   Select From Popup Menu On Selected Tree Nodes   identifier=Objects   menuPath=Element Management|State Management|Lock NRCELL
    List Windows
    Select Dialog   identifier=Confirm Operation
    Wait Until Keyword Succeeds   3 times   10s   Push Button   identifier=Yes

Step2: Check Lock output Combine
    Select Main Window
    List Components In Context
    Run Keyword And Ignore Error    Wait Until Keyword Succeeds   5m   10s
    ...   Text Field Should Be Disabled   identifier=Command Editor TextField
    ${stream_term_comp}=    Run Keyword And Return Status    Click on Component   identifier=StreamTerm

    ${output}    Run Keyword If    ${stream_term_comp}    Get Terminal Text   locator=StreamTerm
    ${output}    Replace String    ${output}    \n    ${EMPTY}
    Should Contain    ${output}    Operation LOCK
    #Should Contain    ${output}    Finishing operation(.*)[Done]
    ${match}   Evaluate   re.findall("Finishing operation(.*)\\[Done\\]", "${output}")[0]   re
    Should Contain    ${output}    Connection Stream to Server closed.
    Sleep    10s
    swing.Select From Main Menu And Wait   menuPath=Window|Reset Workspace
    Wait Until Keyword Succeeds   5m   30s   All Check Cell Status Expected   cell_target_status=locked

Step3: Trigger EMLaunch unlock NRCELL Combine
    Select Main Window
    Wait Until Keyword Succeeds    1m    10s    swing.Select From Main Menu And Wait   menuPath=Window|Reset Workspace
    Wait Until Keyword Succeeds    1m    10s    Menu Item Should Exist   menuPath=Tools|Managed Objects|Object Explorer
    Wait Until Keyword Succeeds    30s    5s    Select From Menu And Wait   menuPath=Tools|Managed Objects|Object Explorer
    Wait Until Keyword Succeeds    30s    5s    Click On Tree Node   Objects   PLMN-PLMN|${MO_name}|${NO_name}|NRCELL-1   \#0
    Wait Until Keyword Succeeds    30s    5s
    ...   Select From Popup Menu On Selected Tree Nodes   identifier=Objects   menuPath=Element Management|State Management|Unlock NRCELL
    Select Dialog   identifier=Confirm Operation
    Wait Until Keyword Succeeds   3 times   10s   Push Button   identifier=Yes

Step4: Check unlock output Combine
    Select Main Window
    List Components In Context
    Run Keyword And Ignore Error    Wait Until Keyword Succeeds   5m   10s
    ...   Text Field Should Be Disabled   identifier=Command Editor TextField
    ${stream_term_comp}=    Run Keyword And Return Status    Click on Component   identifier=StreamTerm

    ${output}    Run Keyword If    ${stream_term_comp}    Get Terminal Text    locator=StreamTerm
    ${output}    Replace String    ${output}    \n    ${EMPTY}
    Should Contain    ${output}    Operation UNLOCK
    ${match}   Evaluate   re.findall("Finishing operation(.*)\\[Done\\]", "${output}")[0]   re
    #Should Contain    ${output}    Finishing operation.    [Done]
    Should Contain    ${output}    Connection Stream to Server closed.
    Sleep    10s
    swing.Select From Main Menu And Wait   menuPath=Window|Reset Workspace
    Wait Until Keyword Succeeds   5m   30s   All Check Cell Status Expected   cell_target_status=unlocked

Step5: Trigger EMLaunch Lock NRCELLs under NRBTS
    Select Main Window
    Wait Until Keyword Succeeds    1m    10s    swing.Select From Main Menu And Wait   menuPath=Window|Reset Workspace
    Wait Until Keyword Succeeds    1m    10s    Menu Item Should Exist   menuPath=Tools|Managed Objects|Object Explorer
    Wait Until Keyword Succeeds    30s    5s    Select From Menu And Wait   menuPath=Tools|Managed Objects|Object Explorer
    Wait Until Keyword Succeeds    30s    5s    Click On Tree Node   Objects   PLMN-PLMN|${MO_name}|${NO_name}   \#0
    Wait Until Keyword Succeeds    30s    5s
    ...   Select From Popup Menu On Selected Tree Nodes   identifier=Objects   menuPath=Element Management|State Management|Lock NRCELLs
    Select Dialog   identifier=Confirm Operation
    Wait Until Keyword Succeeds   3 times   10s   Push Button   identifier=Yes

Step6: Check Lock under NRBTS output
    Select Main Window
    List Components In Context
    Run Keyword And Ignore Error    Wait Until Keyword Succeeds   5m   10s
    ...   Text Field Should Be Disabled   identifier=Command Editor TextField
    ${stream_term_comp}=    Run Keyword And Return Status    Click on Component   identifier=StreamTerm

    ${output}    Run Keyword If    ${stream_term_comp}    Get Terminal Text   locator=StreamTerm
    ${output}    Replace String    ${output}    \n    ${EMPTY}
    Should Contain    ${output}    Operation LOCK
    ${match}   Evaluate   re.findall("Finishing operation(.*)\\[Done\\]", "${output}")[0]   re
    #Should Contain    ${output}    Finishing operation.    [Done]
    Should Contain    ${output}    Connection Stream to Server closed.
    Sleep    10s
    swing.Select From Main Menu And Wait   menuPath=Window|Reset Workspace
    Wait Until Keyword Succeeds   5m   30s   All Check Cell Status Expected   cell_target_status=locked

Step7: Trigger EMLaunch unlock NRCELLs under NRBTS
    Select Main Window
    Wait Until Keyword Succeeds    1m    10s    swing.Select From Main Menu And Wait   menuPath=Window|Reset Workspace
    Wait Until Keyword Succeeds    1m    10s    Menu Item Should Exist   menuPath=Tools|Managed Objects|Object Explorer
    Wait Until Keyword Succeeds    30s    5s    Select From Menu And Wait   menuPath=Tools|Managed Objects|Object Explorer
    Wait Until Keyword Succeeds    30s    5s    Click On Tree Node   Objects   PLMN-PLMN|${MO_name}|${NO_name}   \#0
    Wait Until Keyword Succeeds    30s    5s
    ...   Select From Popup Menu On Selected Tree Nodes   identifier=Objects   menuPath=Element Management|State Management|Unlock NRCELLs
    Select Dialog   identifier=Confirm Operation
    Wait Until Keyword Succeeds   3 times   10s   Push Button   identifier=Yes

Step8: Check unlock under NRBTS output
    Select Main Window
    List Components In Context
    Run Keyword And Ignore Error    Wait Until Keyword Succeeds   5m   10s
    ...   Text Field Should Be Disabled   identifier=Command Editor TextField
    ${stream_term_comp}=    Run Keyword And Return Status    Click on Component   identifier=StreamTerm

    ${output}    Run Keyword If    ${stream_term_comp}    Get Terminal Text   locator=StreamTerm
    ${output}    Replace String    ${output}    \n    ${EMPTY}
    Should Contain    ${output}    Operation UNLOCK
    ${match}   Evaluate   re.findall("Finishing operation(.*)\\[Done\\]", "${output}")[0]   re
    #Should Contain    ${output}    Finishing operation.    [Done]
    Should Contain    ${output}    Connection Stream to Server closed.
    Sleep    10s
    swing.Select From Main Menu And Wait   menuPath=Window|Reset Workspace
    Wait Until Keyword Succeeds   5m   30s   All Check Cell Status Expected   cell_target_status=unlocked

Case Setup: EMLaunch Lock and unlock
    Log To Console    \nStart To EMLaunch Lock and unlock Case Setup!
    All Backup SCF   file_name=${scf_file_name}
    Remove File    ${OUTPUT_DIR}/start.jnlp
    Open Netact Start Page    url=${START_PAGE}    username=${START_PAGE_USER}    password=${START_PAGE_PASSWORD}    showall=${true}
    ${remote_port}   Open Application    app_name=Monitor
    Set Test Variable    ${remote_port}

Case Teardown: EMLaunch Lock and unlock
    Select Main Window
    List Components In Context
    Log To Console   Start To EMLaunch Lock and unlock Case Teardown!
    Run Keyword And Ignore Error   Close Java Application by Remote Port   remote_port=${remote_port}
    Run Keyword And Ignore Error   Close All Java Application Forced
    Run Keyword And Ignore Error   selenium_netact.Logout
    Run Keyword And Ignore Error   selenium_coam.Logout
    Run Keyword And Ignore Error   All Load SCF   filepath=${OUTPUT_DIR}/${scf_file_name}
    Run Keyword And Ignore Error   All Wait GNB Startup
