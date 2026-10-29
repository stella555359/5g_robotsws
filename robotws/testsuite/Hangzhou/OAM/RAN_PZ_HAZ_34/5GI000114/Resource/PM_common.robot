# *** Settings ***
# Documentation
#     ...    Author: yin.4.chen@nokia-sbell.com

# Resource   res_common_import.robot

# *** Variables ***


# *** Keywords ***
# Open Performance Manager
#     [Arguments]    ${username}    ${password}
#     [Documentation]    Open Performance Manager -application
#     [Tags]    NO_LOG
#     ${PERFORMANCE_MANAGER_ALIAS}    Open Web Application From Startpage    Performance Manager    ${username}    ${password}
#     Set Suite Variable    ${PERFORMANCE_MANAGER_ALIAS}
#     [Return]    ${PERFORMANCE_MANAGER_ALIAS}

# Open Web Application From Startpage
#     [Arguments]    ${application_name}    @{login}
#     [Documentation]    Open Web application from NetAct Start Page. application_name is
#     ...    the alt-text of the application icon. Don't use this keyword directly if it's
#     ...    not necessary. Use Open-keywords from res_netact_applications.robot instead.
#     Select Or Open NetAct Startpage    @{login}
#     Click Application Image    ${application_name}
#     Sleep    2 sec
#     Wait Until Keyword Succeeds    ${WEBAPP_LAUNCH_TIMEOUT}    5 second    Select Window With Title Containing    ${application_name}
#     ${title}    SeleniumLibrary.Get Title
#     [Return]    ${title}

# Close Performance Manager
#     [Documentation]    Close Performance Manager -application
#     [Tags]    NO_LOG
#     Close Web Application    ${PERFORMANCE_MANAGER_ALIAS}

# Open CM Application
#     [Arguments]   ${app_name}
#     ${remote_port}   Open Application    ${app_name}
#     Select Main Window
#     Wait Until Keyword Succeeds    1m    3s    Menu Item Should Exist    File
#     Run Keyword And Ignore Error   swing.Set Jemmy Timeouts   40
#     [Return]   ${remote_port}

# Close CM Application
#     [Timeout]   2m
#     [Arguments]   ${app_name}
#     swing.Switch To Application   ${app_name}
#     Sleep   10s
#     swing.Close All Dialogs
#     swing.Select From Main Menu   File|Exit
