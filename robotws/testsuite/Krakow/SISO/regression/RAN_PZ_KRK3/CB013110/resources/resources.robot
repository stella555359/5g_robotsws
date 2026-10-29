*** Settings ***
Documentation
...   Resources for executing cases for CB013110.
...   author: Magda Chrostek
...   contact: magda.chrostek@nokia.com

Library    SeleniumLibrary

*** Keywords ***
Run L3 call with GUI
    [Arguments]      ${ue_addr}
    ${login_url}     Set Variable     http://${ue_addr}/pub/login.html
    ${browser}       Set Variable     Chrome
    ${username}      Set Variable     superadmin
    ${password}      Set Variable     admin
    Open Browser      ${login_url}      ${browser}
    Run Keyword And Continue on Failure    Chrome privacy
    Sleep    5s
    Title Should Be    Login
    Input Text    username     ${username}
    Input Text    password     ${password}
    Click Button    login
    Sleep       5s
    Wrap select
    ${xpath}     Set Variable      //*[@id="networkWanSettingsIp"]
    ${ip_addr}=    Get Text    xpath=${xpath}
    Log to console    ${ip_addr}
    run_tput      ${ip_addr}
    Sleep    2min
    ${first_2min_tput}      Verify Tput table values
    Sleep    1min
    ${last_2min_tput}       Verify Tput table values
    Should Not Be Equal    ${first_2min_tput}    ${last_2min_tput}
    Unselect Frame
    Click Element    //*[@id="home"]
    [Teardown]      Run Keywords
    ...             Back to main menu
    ...             Close Browser

Verify Tput table values
    Unselect Frame
    Click Element    //*[@id="statistical_data"]
    Sleep     5s
    Wrap select
    ${get_tput_content}      Get Text     //*[@id="thoughput_table"]
    Log to console     ${get_tput_content}
    [Return]    ${get_tput_content}

Wrap select
    Unselect Frame
    Select Frame      //*[@id="iframe_wrap"]


Chrome privacy
    Click Button      //*[@id="details-button"]
    Click Element     //*[@id="proceed-link"]

Back to main menu
    Unselect Frame
    Click Element    //*[@id="home"]

Set Ue Variables
    ${host_name}    OperatingSystem.Run And Return Rc And Output    hostname|sed 's/-/_/g'
    ${testline_config_path}    Set Variable    /home/ute/testline_configuration/${host_name}[1]/smawave.yaml
    Import Variables    ${testline_config_path}
    Set Suite Variable      ${ue_addr}      ${smawave_addr}
    Set Suite Variable    ${ue_user}    ${smawave_user}
    Set Suite Variable    ${ue_pass}    ${smawave_password}

Set Ue Variables 089
    ${testline_config_path}    Set Variable    /home/ute/testline_configuration/10_7_UTE4G10SK089/smawave.yaml
    Import Variables    ${testline_config_path}
    Set Suite Variable      ${ue_addr}      ${smawave_addr}
    Set Suite Variable    ${ue_user}    ${smawave_user}
    Set Suite Variable    ${ue_pass}    ${smawave_password}
