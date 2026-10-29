*** Settings ***
Documentation  LTEvDU OAM operations keywords.
...  Author: slawomir.jastrzebski@nokia.com
...  Maintainer: slawomir.jastrzebski@nokia.com

Library    BuiltIn
Library    Collections
Library    DateTime
Library    taf.vran.vdu.enb.rest.interface.LTEvDU    WITH NAME    ltevdu

Resource    ../../../resources/Robot/tl_init.robot

*** Keywords ***
#LTEvDU Login Operations
LTEvDU Rest Login
    [Arguments]  ${enb_index}=0  ${vdu_index}=0  ${release}=${None}  ${timeout}=30s  ${lte_vdu_connection}=default_lte
    [Documentation]
    ...  Description:
    ...  Keyword provides connection and authorization to 4GvDU.
    ...
    ...  Arguments:
    ...  +========================+======+============================================================================+
    ...  | Argument               | Man. | Description                                                                |
    ...  +========================+======+============================================================================+
    ...  | enb_index              |  No  | Index of eNB object list.                                                  |
    ...  +------------------------+------+----------------------------------------------------------------------------+
    ...  | vdu_index              |  No  | Index of DU (Distributed Unit) class instance objects list.                |
    ...  +------------------------+------+----------------------------------------------------------------------------+
    ...  | release                |  No  | 4G vDU release.                                                            |
    ...  +------------------------+------+----------------------------------------------------------------------------+
    ...  | timeout                |  No  | Timeout for the operation to vDU.                                          |
    ...  +------------------------+------+----------------------------------------------------------------------------+
    ...  | lte_vdu_connection     |  No  | LTEvDU connection object or string name alias if used.                     |
    ...  +------------------------+------+----------------------------------------------------------------------------+
    ...
    ...  Author: slawomir.jastrzebski@nokia.com
    ...  Maintainer: slawomir.jastrzebski@nokia.com

    Run Keyword And Ignore Error  LTEvDU Rest Logout  connection=${lte_vdu_connection}
    ${oam_http_connection}=  Get vDU Oam Http Connection Parameters From Init File
    ...  gnb_index=${enb_index}  vdu_index=${vdu_index}
    ${http_password}=  Set Variable  Nokia@123
    ${ip_addr}=  Set Variable  ${oam_http_connection["ip_addr"]}
    ${port}=  Set Variable  ${oam_http_connection["port"]}
    ${username}=  Set Variable  ${oam_http_connection["username"]}
    ${password}=  Set Variable  ${http_password}
    ${secure}=  Set Variable  ${True}
    ${connection}=  ltevdu.Connect To  host=${ip_addr}  port=${port}  username=${username}
    ...  password=${password}  release=${release}  secure=${secure}
    ...  connection_name=${lte_vdu_connection}  timeout=${timeout}
    [Return]  ${lte_vdu_connection}

LTEvDU Rest Logout
    [Arguments]  ${lte_vdu_connection}=default_lte
    [Documentation]
    ...  Description:
    ...  Keyword allows to logout of 4GvDU.
    ...
    ...  Arguments:
    ...  +========================+======+============================================================================+
    ...  | Argument               | Man. | Description                                                                |
    ...  +========================+======+============================================================================+
    ...  | lte_vdu_connection     |  No  | LTEvDU connection object or string name alias if used.                        |
    ...  +------------------------+------+----------------------------------------------------------------------------+
    ...
    ...  Author: slawomir.jastrzebski@nokia.com
    ...  Maintainer: slawomir.jastrzebski@nokia.com

    ltevdu.Disconnect  connection=${lte_vdu_connection}

#LTEvDU cells operations
LTEvDU All Lte Cells Should Be OnAir
    [Arguments]  ${lcells_count}  ${lte_vdu_connection}=default_lte
    [Documentation]
    ...  Description:
    ...  Keyword checks if all LTE cells are onAir.
    ...  Keyword checks the following status:   operationalState = enabled
    ...                                         administrativeState = unlocked
    ...                                         availabilityStatus = on line
    ...
    ...  Arguments:
    ...  +========================+======+============================================================================+
    ...  | Argument               | Man. | Description                                                                |
    ...  +========================+======+============================================================================+
    ...  | lcells_count           | Yes  | Number of all LTE cells.                                                   |
    ...  +------------------------+------+----------------------------------------------------------------------------+
    ...  | lte_vdu_connection     |  No  | LTEvDU connection object or string name alias if used.                     |
    ...  +------------------------+------+----------------------------------------------------------------------------+
    ...
    ...  Author: slawomir.jastrzebski@nokia.com
    ...  Maintainer: slawomir.jastrzebski@nokia.com

    ${vdu_lcells_summary}=  ltevdu.Get Cells Summary  connection=${lte_vdu_connection}
    Should Be Equal As Numbers
    ...  first=${vdu_lcells_summary['lncel']['basicCellsSummary']['operationalState']['enabled']}  second=${lcells_count}
    Should Be Equal As Numbers
    ...  first=${vdu_lcells_summary['lncel']['basicCellsSummary']['administrativeState']['unlocked']}  second=${lcells_count}
    Should Be Equal As Numbers
    ...  first=${vdu_lcells_summary['lncel']['availabilityStatus']['on line']}  second=${lcells_count}

#vDU operations
LTEvDU Get Operational State
    [Arguments]  ${lte_vdu_connection}=default_lte
    [Documentation]
    ...  Description:
    ...  Keyword returns LTE vDU operational state value.
    ...
    ...  Arguments:
    ...  +========================+======+============================================================================+
    ...  | Argument               | Man. | Description                                                                |
    ...  +========================+======+============================================================================+
    ...  | log_to_console         |  No  | Show or not the information on the console.                                |
    ...  +------------------------+------+----------------------------------------------------------------------------+
    ...  | lte_vdu_connection     |  No  | LTEvDU connection object or string name alias if used.                     |
    ...  +------------------------+------+----------------------------------------------------------------------------+
    ...
    ...  Return:
    ...  LTEvDU operational state value.
    ...
    ...  Author: slawomir.jastrzebski@nokia.com
    ...  Maintainer: slawomir.jastrzebski@nokia.com

    ${vdu_params}=  ltevdu.Get Vdu State Data  connection=${lte_vdu_connection}
    ${vdu_state_value}=  Set Variable  ${vdu_params['operationalState']}
    [Return]  ${vdu_state_value}

#Radio modules operations
LTEvDU Radio Modules Should Be Online
    [Arguments]  ${rmods_count}  ${lte_vdu_connection}=default_lte
    [Documentation]
    ...  Description:
    ...  Keyword checks if all radio modules are on line if 4G vDU is used.
    ...  Radio module expected states:  administrativeState = unlocked
    ...                                 operationalState = enabled
    ...                                 availabilityStatus = on line
    ...
    ...  Arguments:
    ...  +========================+======+============================================================================+
    ...  | Argument               | Man. | Description                                                                |
    ...  +========================+======+============================================================================+
    ...  | rmods_count            | Yes  | Number of all radio modules if 4G vDU is used.                             |
    ...  +------------------------+------+----------------------------------------------------------------------------+
    ...  | lte_vdu_connection     |  No  | LTEvDU connection object or string name alias if used.                     |
    ...  +------------------------+------+----------------------------------------------------------------------------+
    ...
    ...  Author: slawomir.jastrzebski@nokia.com
    ...  Maintainer: slawomir.jastrzebski@nokia.com

    ${all_rmods_params}=  ltevdu.Get Rmods Summary  connection=${lte_vdu_connection}
    Should Be Equal As Numbers
    ...  first=${all_rmods_params['operationalState']['enabled']}  second=${rmods_count}
    Should Be Equal As Numbers
    ...  first=${all_rmods_params['administrativeState']['unlocked']}  second=${rmods_count}
    Should Be Equal As Numbers
    ...  first=${all_rmods_params['availabilityStatus']['on line']}  second=${rmods_count}
