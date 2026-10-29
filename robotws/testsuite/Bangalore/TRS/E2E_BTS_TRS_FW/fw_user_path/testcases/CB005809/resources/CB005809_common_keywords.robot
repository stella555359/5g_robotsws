*** Settings ***

Documentation
    ...     [Procedure]             "The test case is to verify alarms across multiple sessions and BTS behaviour"
    ...     [Date]                  "09-05-2021"
    ...     [Author]                "Pavithra C"
    ...     [QC_Path]               "QC_Path in Test Plan"
    ...     [QC_ID]                 "QC_ID in Test Lab for reporting"
    ...     [Funtion_Hash_Tags]     ""
    ...     [Feature_ID]            "CB005809"
    ...     [Validation_status]     "Not yet tested"
    ...     [Validated_TestLine]    "5G-9010"

variables       ta_e2e_bts_trs_fw
Library         Selenium2Library
Resource        ${CURDIR}/../../resources/common_keywords.robot

*** Keywords ***

Open WebUI Session
    [Arguments]      ${browser}    ${alias_name}
    open browser     https://192.168.255.129/    ${browser}    alias=${alias_name}
    Maximize Browser window
    Sleep   2
    Run Keyword And Ignore Error     Click Button        Advanced
    Sleep  2
    Run Keyword And Ignore Error    Click Link    proceed-link
    Sleep    5
    Input Text      login-username        Nemuadmin
    Input password      login-password    nemuuser
    Click Button        Login
    Sleep   300


Disable Ethernet Security port across multiple browsers
    [Arguments]      ${session_number}
    Switch Browser    ${session_number}
    Click Element    xpath=//*[@id="main-view"]/div/div[1]/app-header/main-menu/nav-item[7]/div/nav-menu-link/span
    Click Element    xpath=//*[@id="main-view"]/div/div[1]/app-header/main-menu/nav-item[7]/div/ng-transclude/div/div[2]/nav-link/a/span[1]
    Run Keyword And Ignore Error    Click Button    Disable

Verify 4654 alarm across all open sessions
    [Arguments]      ${session_number}
    Switch Browser    ${session_number}

Verify 4655 alarm across all open sessions
    [Arguments]      ${session_number}
    Switch Browser    ${session_number}

Verify for core files
    Setup Remote Access    remote_device=bts
    ${output}    Remote Command Execute      command=[ ! -d "/ffs/run/logs/0/" ] && echo "Directory /ffs/run/logs/0/ DOES NOT exists."
    Set Suite Variable     ${output}
    Should Contain    ${output}    Directory /ffs/run/logs/0/ DOES NOT exists.

Reset Ethernetport security and toor4nsn access to default
     [Documentation]     This keyword will set default value to "ethernetPortSecurityEnabled" and "systemAcctPermEnable"
     Perform Recommissioning    type=param    rat=lte    param_path=SECADM-1:ethernetPortSecurityEnabled    operation=update
     ...        value=${TRUE}     timeout=300
     Perform Recommissioning    type=param    rat=lte    param_path=FEATCADM-1:systemAcctPermEnable     operation=update
     ...        value=${FALSE}     timeout=300
     Verify Alarm    faultid=${4655_ALARM}
     Close All Browsers


Verify eNB local port connectivity
    Setup Remote Access    remote_device=bts
    Command to execute on board      ping -c 20 192.168.255.129
    Command to execute on board      ping -c 20 10.0.1.2
    Teardown remote Access


Command to execute on board
        [Arguments]      ${command}
        Remote Command Execute      command=${command}


Check SSH and SFTP
    Setup Remote Access    remote_device=bts
    Teardown remote Access


Add LSS and Remote server configuration
    Perform Recommissioning    type=delta    delta_file=${LSS_SSH_CONFIG}   skip_parameter_relation_errors=${False}  timeout=300

Check ping test for LSS server
	Setup Remote Access    remote_device=bts
    Command to execute on board      ping -c 20 10.99.99.12
    Teardown remote Access
