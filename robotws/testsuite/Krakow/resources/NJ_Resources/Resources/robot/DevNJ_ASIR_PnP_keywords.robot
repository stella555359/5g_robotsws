*** Settings ***
Documentation
...     author: Jingang Sun
...     contact: jingang.sun@nokia-sbell.com
...     SC ASIR PnP related keywords

Library     ../python/DevNJ_ASIR_PnP_Keywords.py
Library     ../python/DevNJ_ASIR_PnP_Rest_Keywords.py

*** Keywords ***
Prepare ASIR PnP Commission
    [Documentation]  This keyword used to prepare *ASIR PnP* commissioning file
    ...    _file_dir_: destination directory for the prepared commissioning file
    ...    Example:
    ...    Prepare ASIR PnP Commission and save in /tmp dir
    ...    | Prepare ASIR PnP Commission | /tmp |
    ...    Return value: Comm_file
    [Arguments]  ${file_dir}
    ${Comm_file}=    Collect Asir Commission File    output_dir=${file_dir}
    [Return]  ${Comm_file}

Wait For AutoConnection Start
    [Documentation]  This keyword used to wait until *Auto connection state is Start* appears in syslog
    ...    _retry_count_: wait count
    ...    _retry_interval_: time interval between two wait rounds
    ...    Example:
    ...    | Wait For AutoConnection Start | 10 | 5 |
    ...    Return value: AutoConn_status, for example Started/NotStarted
    [Arguments]     ${retry_count}      ${retry_interval}
    ${AutoConn_status}=  Multiple check autoconnection start    wait_count=${retry_count}   time_interval=${retry_interval}
    [Return]  ${AutoConn_status}

Get ASIR PnP Progress Info
    [Documentation]     This keyword used to get *ASIR PnP* status info
    ...    _status_type_: Conn for auto_connection status, Conf for auto_configuration, All for both
    ...    Example:
    ...    | Get ASIR PnP Progress Info | All |
    ...    Return value: pnp_status
    [Arguments]      ${status_type}
    ${pnp_status}=   Get ASIR PnP Status     pnp_status_type=${status_type}
    [Return]  ${pnp_status}
