*** Settings ***
Library            OperatingSystem
Library            String

*** Keywords ***
DCM ET UTF Lab Controller Start
    [Documentation]    Firstly,
    ...                   check if test env has latest UTF lab version,
    ...                   if not, upgrade UTF lab to latest version.
    ...                Then,
    ...                   UTF Lab Controller Start if not started,
    ...                   UTF Lab Controller restart if service has been started.
    ...                \n Author: huijun.rong@nokia-sbell.com
    [Timeout]    40 min
    DCM ET UTF Lab Upgrade
    Log To Console      UTF Lab Controller Start
    ${output}           OperatingSystem.Run     utf_lab-controller status
    ${utf_lab_inact}    Run Keyword And Return Status
    ...     Should Contain    ${output}    is not in running state   ignore_case=True
    ${result}           Run Keyword If      ${utf_lab_inact}
    ...     OperatingSystem.Run     utf_lab-controller start
    Run Keyword And Return If      ${utf_lab_inact}    Run Keywords
    ...   Should Contain   ${result}  Lab containers started successfully   ignore_case=True
    ...   AND   Log To Console   UTF Lab containers started successfully
    ${output}           OperatingSystem.Run    utf_lab-controller restart
    Should Contain      ${output}    containers restarted successfully   ignore_case=True
    Log To Console   UTF Lab containers re-started successfully

DCM ET UTF Lab Upgrade
    [Documentation]    check latest UTF Lab version, and upgrade current UTF to latest,
    ...                the upgrade will be skipped if latest version=current version
    ...                \n Author: huijun.rong@nokia-sbell.com
    [Timeout]    30 min
    Log To Console      UTF Lab Upgrade
    ${output}           OperatingSystem.Run   utf_lab-updates
    ${cur_ver}          Get Regexp Matches    ${output}
    ...    Currently installed version\\s+:\\s+([A-Z0-9]+\.[0-9]+)    1
    ${latest_ver}       Get Regexp Matches    ${output}
    ...    Latest released version\\s+:\\s+([A-Z0-9]+\.[0-9]+)        1
    ${cur_ver}          Set Variable         ${cur_ver[0]}
    ${latest_ver}       Set Variable         ${latest_ver[0]}
    Log To Console      cur_ver:${cur_ver}, latest_ver:${latest_ver}
    ${no_need_update}   Run Keyword And Return Status
    ...    Should Be Equal As Strings     ${cur_ver}    ${latest_ver}    ignore_case=True
    Run Keyword And Return If    ${no_need_update}
    ...    Log To Console    latest version is the same as current version, need not upgrade UTE Lab
    ${upgrade_sh}       Get Regexp Matches    ${output}
    ...    has been downloaded to:\\s+(/home/ute/Downloads/utf_lab_installer\.[A-Z0-9]+\.[0-9]+\.sh)   1
    ${upgrade_sh}       Set Variable          ${upgrade_sh[0]}
    Log To Console      ${upgrade_sh}
    ${cmd1}             Set Variable          sudo UTE_CLOUD=1 bash ${upgrade_sh} 127.0.0.1
    ${cmd2}             Set Variable          &> ${TEST_LOG_DIRECTORY}${/}update.log
    ${output}           OperatingSystem.Run   ${cmd1} ${cmd2}
    Should Contain      ${output}     SUCCESS: UTF Lab ${latest_ver} installed
    ...    ignore_case=True
