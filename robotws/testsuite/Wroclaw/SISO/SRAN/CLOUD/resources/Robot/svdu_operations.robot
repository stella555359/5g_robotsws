*** Settings ***
Documentation  Coam vdu WebEM functionalities keywords.
...  Author: slawomir.jastrzebski@nokia.com
...  Maintainer: slawomir.jastrzebski@nokia.com

Library    BuiltIn
Library    taf.selenium.gnb.oam.coam.vdu.interface.vdu  WITH NAME  svdu

Resource    ./common_resources.robot

*** Keywords ***
vDU WebEM Login
    [Arguments]  ${gnb_index}=0  ${vdu_index}=0  ${is_headless}=True  ${timeout}=120  ${vdu_logout}=False
    [Documentation]
    ...  Description:
    ...  Keyword allows login to vDU via WebEM.
    ...
    ...  Arguments:
    ...  +========================+======+============================================================================+
    ...  | Argument               | Man. | Description                                                                |
    ...  +========================+======+============================================================================+
    ...  | gnb_index              |  No  | Index of gnb object list.                                                  |
    ...  +------------------------+------+----------------------------------------------------------------------------+
    ...  | vdu_index              |  No  | Index of DU (Distributed Unit) class instance objects list.                |
    ...  +------------------------+------+----------------------------------------------------------------------------+
    ...  | is_headless            |  No  | Decide to run in browser head less mode or not.                            |
    ...  +------------------------+------+----------------------------------------------------------------------------+
    ...  | timeout                |  No  | Timeout for the element be available to click.                             |
    ...  +------------------------+------+----------------------------------------------------------------------------+
    ...  | vdu_logout             |  No  | Whether to log out first or not.                                           |
    ...  +------------------------+------+----------------------------------------------------------------------------+
    ...
    ...  Author: slawomir.jastrzebski@nokia.com
    ...  Maintainer: slawomir.jastrzebski@nokia.com

    Run Keyword If  ${vdu_logout}
    ...  Run Keyword And Ignore Error  vDU WebEM Logout
    ${status}  ${version}=  Run Keyword And Ignore Error
    ...  Get vDU Selenium Rest Api Version  gnb_index=${gnb_index}  vdu_index=${vdu_index}
    ${oam_http_connection}=  Get vDU Oam Http Connection Parameters From Init File
    ...  gnb_index=${gnb_index}  vdu_index=${vdu_index}
    ${ip_addr}=  Set Variable  ${oam_http_connection["ip_addr"]}
    ${url}=   Set Variable  https://${ip_addr}
    ${username}=  Set Variable  ${oam_http_connection["username"]}
    ${password}=  Set Variable  ${VDU_OAM_PASSWORD}
    Run Keyword If  '${status}'=='FAIL'
    ...  Wait Until Keyword Succeeds  3x  5s
    ...  svdu.Login  url=${url}  username=${username}  password=${password}
    ...  is_headless=${is_headless}  timeout=${timeout}
    ...  ELSE
    ...  Wait Until Keyword Succeeds  3x  5s
    ...  svdu.Login  url=${url}  username=${username}  password=${password}
    ...  is_headless=${is_headless}  timeout=${timeout}  version=${version}
    Set Test Variable  ${VDU_WEBEM_LOGIN_INSTANCE_ID}  vDU WebEM Login is Called.

vDU WebEM Logout
      [Documentation]
    ...  Description:
    ...  Keyword allows to log out via WebEM.
    ...
    ...  Maintainer: slawomir.jastrzebski@nokia.com

    ${result}=  Run Keyword And Return Status
    ...  Variable Should Exist  ${VDU_WEBEM_LOGIN_INSTANCE_ID}
    Return From Keyword If  '${result}'=='${False}' or '${VDU_WEBEM_LOGIN_INSTANCE_ID}'=='${None}'
    svdu.Logout
    Set Test Variable  ${VDU_WEBEM_LOGIN_INSTANCE_ID}  ${None}

vDU Rest WebEM Logout
      [Documentation]
    ...  Description:
    ...  Keyword allows to log out via Rest and WebEM.
    ...
    ...  Author: slawomir.jastrzebski@nokia.com
    ...  Maintainer: slawomir.jastrzebski@nokia.com

    Run Keyword And Ignore Error  vDU Rest Logout
    Run Keyword And Ignore Error  vDU WebEM Logout

Get vDU Selenium Rest Api Version
    [Arguments]  ${gnb_index}=0  ${vdu_index}=0  ${alias}=default
    [Documentation]
    ...  Description:
    ...  Keyword gets vDU selenium rest api version from global variables file (variables.robot).
    ...
    ...  Arguments:
    ...  +========================+======+============================================================================+
    ...  | Argument               | Man. | Description                                                                |
    ...  +========================+======+============================================================================+
    ...  | gnb_index              |  No  | Index of gnb object list.                                                  |
    ...  +------------------------+------+----------------------------------------------------------------------------+
    ...  | vdu_index              |  No  | Index of DU (Distributed Unit) class instance objects list.                |
    ...  +------------------------+------+----------------------------------------------------------------------------+
    ...  | alias                  |  No  | Alias of vDU connection.                                                   |
    ...  +------------------------+------+----------------------------------------------------------------------------+
    ...
    ...  Return:
    ...  vDU Selenium Rest Api version for example COAM25R1.
    ...
    ...  Author: slawomir.jastrzebski@nokia.com
    ...  Maintainer: slawomir.jastrzebski@nokia.com

    ${build_version}=  Get vDU Build Number  gnb_index=${gnb_index}  vdu_index=${vdu_index}  alias=${alias}
    ${build_number_list}=  Split String  string=${build_version}  separator=.
    ${built_stream}=  Set Variable  ${build_number_list[0]}.${build_number_list[1]}
    ${restapi_version}=  Set Variable  ${SVDU_RESTAPI_TAF_VERSION_SW_STREAM_MAPPING['${built_stream}']}
    [Return]  ${restapi_version}

WebEM RMODs Should Be Online
    [Arguments]  ${rmod_name}
    [Documentation]
    ...  Description:
    ...  Keyword checks if the radio module given by name (e.g. RMOD-1) is online.
    ...  Radio module expected states:  Administrative state = Unlocked
    ...                                 Operational state = Enabled
    ...                                 Availability status = On line
    ...
    ...  Arguments:
    ...  +========================+======+============================================================================+
    ...  | Argument               | Man. | Description                                                                |
    ...  +========================+======+============================================================================+
    ...  | rmod_name              | Yes  | Radio module name e.g. RMOD-1 (default RMOD-1).                            |
    ...  +------------------------+------+----------------------------------------------------------------------------+
    ...
    ...  Author: slawomir.jastrzebski@nokia.com
    ...  Maintainer: slawomir.jastrzebski@nokia.com

    ${rmod_status}=  svdu.Get Radio Status Info  radio_module=${rmod_name}
    Should Be Equal As Strings  first=${rmod_status['Operational state']}  second=Enabled
    Should Be Equal As Strings  first=${rmod_status['Availability status']}  second=On line
    Should Be Equal As Strings  first=${rmod_status['Administrative state']}  second=Unlocked

WebEM RMOD Wait For Online
    [Arguments]  ${rmod_name}  ${timeout}=10min
    [Documentation]
    ...  Description:
    ...  Keyword waits until radio module is on line.
    ...
    ...  Arguments:
    ...  +========================+======+============================================================================+
    ...  | Argument               | Man. | Description                                                                |
    ...  +========================+======+============================================================================+
    ...  | rmod_name              | Yes  | Radio module name e.g. RMOD-1 (default RMOD-1).                            |
    ...  +------------------------+------+----------------------------------------------------------------------------+
    ...  | timeout                |  No  | Wait until radio module is on line.                                        |
    ...  +------------------------+------+----------------------------------------------------------------------------+
    ...
    ...
    ...  Author: slawomir.jastrzebski@nokia.com
    ...  Maintainer: slawomir.jastrzebski@nokia.com

    Wait Until Keyword Succeeds  ${timeout}  20
    ...  WebEM RMODs Should Be Online  rmod_name=${rmod_name}

WebEM RMODs Should Be Offline
    [Arguments]  ${rmod_name}
    [Documentation]
    ...  Description:
    ...  Keyword checks if the radio module given by name (e.g. RMOD-1) is offline.
    ...  Radio module expected states:  Administrative state = Unlocked
    ...                                 Operational state = Disabled
    ...                                 Availability status = Not installed
    ...
    ...  Arguments:
    ...  +========================+======+============================================================================+
    ...  | Argument               | Man. | Description                                                                |
    ...  +========================+======+============================================================================+
    ...  | rmod_name              | Yes  | Radio module name e.g. RMOD-1 (default RMOD-1).                            |
    ...  +------------------------+------+----------------------------------------------------------------------------+
    ...
    ...  Author: slawomir.jastrzebski@nokia.com
    ...  Maintainer: slawomir.jastrzebski@nokia.com

    ${rmod_status}=  svdu.Get Radio Status Info  radio_module=${rmod_name}
    Should Be Equal As Strings  first=${rmod_status['Operational state']}  second=Disabled
    Should Be Equal As Strings  first=${rmod_status['Availability status']}  second=Not installed
    Should Be Equal As Strings  first=${rmod_status['Administrative state']}  second=Unlocked

WebEM RMOD Wait For Offline
    [Arguments]  ${rmod_name}  ${timeout}=60s
    [Documentation]
    ...  Description:
    ...  Keyword waits until radio module is on line.
    ...
    ...  Arguments:
    ...  +========================+======+============================================================================+
    ...  | Argument               | Man. | Description                                                                |
    ...  +========================+======+============================================================================+
    ...  | rmod_name              | Yes  | Radio module name e.g. RMOD-1 (default RMOD-1).                            |
    ...  +------------------------+------+----------------------------------------------------------------------------+
    ...  | timeout                |  No  | Wait until radio module is off line.                                       |
    ...  +------------------------+------+----------------------------------------------------------------------------+
    ...
    ...
    ...  Author: slawomir.jastrzebski@nokia.com
    ...  Maintainer: slawomir.jastrzebski@nokia.com

    Wait Until Keyword Succeeds  ${timeout}  10
    ...  WebEM RMODs Should Be Offline  rmod_name=${rmod_name}

