*** Settings ***
Documentation  FHGW operations keywords.
...  Author: slawomir.jastrzebski@nokia.com
...  Maintainer: slawomir.jastrzebski@nokia.com

Library    BuiltIn
Library    taf.hw.fhgw.cli  WITH NAME  issh

Resource    ./common_resources.robot
Resource    ../../../resources/Robot/common_kw.robot

*** Keywords ***
Connect to FHGW
    [Arguments]  ${gnb_index}=0  ${vdu_index}=0  ${fhgw_index}=0  ${timeout}=150  ${alias}=default
    [Documentation]
    ...  Description:
    ...  Keyword connects to FHGW.
    ...
    ...  Arguments:
    ...  +========================+======+============================================================================+
    ...  | Argument               | Man. | Description                                                                |
    ...  +========================+======+============================================================================+
    ...  | gnb_index              |  No  | Index of gnb object list.                                                  |
    ...  +------------------------+------+----------------------------------------------------------------------------+
    ...  | vdu_index              |  No  | Index of DU (Distributed Unit) class instance objects list.                |
    ...  +------------------------+------+----------------------------------------------------------------------------+
    ...  | fhgw_index             |  No  | Index of FHGW class instance object list.                                  |
    ...  +------------------------+------+----------------------------------------------------------------------------+
    ...  | timeout                |  No  | Timeout for the ssh connect operation.                                     |
    ...  +------------------------+------+----------------------------------------------------------------------------+
    ...  | alias                  |  No  | Alias of ssh connection. If not specified, default alias is used.          |
    ...  +------------------------+------+----------------------------------------------------------------------------+
    ...
    ...  Return:
    ...  Connection alias.

    ${fhgw_connection_params}=  Get FHGW Ssh Connection Parameters From Init File
    ...  gnb_index=${gnb_index}  vdu_index=${vdu_index}  fhgw_index=${fhgw_index}
    ${ip_addr}=  Set Variable  ${fhgw_connection_params['ip_addr']}
    ${username}=  Set Variable  ${fhgw_connection_params['username']}
    ${password}=  Set Variable  ${fhgw_connection_params['password']}
    ${port}=  Set Variable  ${fhgw_connection_params['port']}
    ${alias}=  issh.Connect To  ip=${ip_addr}  username=${username}  password=${password}
    ...  port=${port}  timeout=${timeout}  alias=${alias}
    [Return]  ${alias}

Reset FHGW
    [Arguments]  ${gnb_index}=0  ${vdu_index}=0  ${fhgw_index}=0  ${alias}=default
    [Documentation]
    ...  Description:
    ...  Keyword resets FHGW.
    ...
    ...  Arguments:
    ...  +========================+======+============================================================================+
    ...  | Argument               | Man. | Description                                                                |
    ...  +========================+======+============================================================================+
    ...  | gnb_index              |  No  | Index of gnb object list.                                                  |
    ...  +------------------------+------+----------------------------------------------------------------------------+
    ...  | vdu_index              |  No  | Index of DU (Distributed Unit) class instance objects list.                |
    ...  +------------------------+------+----------------------------------------------------------------------------+
    ...  | fhgw_index             |  No  | Index of FHGW class instance object list.                                  |
    ...  +------------------------+------+----------------------------------------------------------------------------+
    ...  | alias                  |  No  | Alias of ssh connection. If not specified, default alias is used.          |
    ...  +------------------------+------+----------------------------------------------------------------------------+
    ...
    ...  Author: slawomir.jastrzebski@nokia.com
    ...  Maintainer: slawomir.jastrzebski@nokia.com

    ${fhgw_connection_params}=  Get FHGW Ssh Connection Parameters From Init File
    ...  gnb_index=${gnb_index}  vdu_index=${vdu_index}  fhgw_index=${fhgw_index}
    ${ip_addr}=  Set Variable  ${fhgw_connection_params['ip_addr']}
    Connect to FHGW  alias=${alias}
    issh.Execute  command=sudo reboot  check_result=${False}  alias=${alias}
    Ip Address Is Unavailable  ip_addr=${ip_addr}
    Ip Address Is Available  ip_addr=${ip_addr}
    FHGW Wait For Connection Success  alias=${alias}_1

FHGW Wait For Connection Success
    [Arguments]  ${timeout}=300s  ${alias}=default
    [Documentation]
    ...  Description:
    ...  Keyword waits for success connection to FHGW.
    ...
    ...  Arguments:
    ...  +========================+======+============================================================================+
    ...  | Argument               | Man. | Description                                                                |
    ...  +========================+======+============================================================================+
    ...  | timeout                |  No  | Waiting time for a successful connection to FHGW.                          |
    ...  +------------------------+------+----------------------------------------------------------------------------+
    ...  | alias                  |  No  | Alias of ssh connection.                                                   |
    ...  +------------------------+------+----------------------------------------------------------------------------+
    ...
    ...  Author: slawomir.jastrzebski@nokia.com
    ...  Maintainer: slawomir.jastrzebski@nokia.com

    Wait Until Keyword Succeeds  ${timeout}  10s
    ...  Connect to FHGW  alias=${alias}

