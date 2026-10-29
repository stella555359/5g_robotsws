*** Settings ***
Documentation    Keywords using RNC NWI3 interface.
...              Resource used by RF Sharing Vrf tribe
...              Author: Gabriel Stanculescu
...              Contact: gabriel.stanculescu@nokia.com

Library    taf.rnc.oms.nwi3
Library    Collections

*** Keywords ***
RNC Setup NWI3
    [Documentation]
    ...  KW used to establish the connection to OMS
    ...
    ...  *AUTHOR*
    ...  gabriel.stanculescu@nokia.com
    ...
    ...  *INPUT*
    ...  | Parameter        | Man.  | Default | Description                                 |
    ...  | rnc_number       | Yes   |         | Number of RNC which will be accessed        |
    ...  | oms_ip           | Yes   |         | IP of OMS which will be accessed            |
    ...  | oms_username     | Yes   |         | Username used for OMS login                 |
    ...  | oms_password     | Yes   |         | Password used for OMS login                 |
    ...
    [Arguments]  ${rnc_number}  ${oms_ip}  ${oms_username}  ${oms_password}
    Setup Nwi3                          rnc_number=${rnc_number}
    ...                                 oms_ip=${oms_ip}
    ...                                 oms_username=${oms_username}
    ...                                 oms_password=${oms_password}

RNC Get WBTS Active Alarms
    [Documentation]
    ...  KW used to get WBTS Active Alarms from RNC
    ...
    ...  *AUTHOR*
    ...  gabriel.stanculescu@nokia.com
    ...
    ...  *INPUT*
    ...  | Parameter        | Man.  | Default | Description                                 |
    ...  | wbts_id          | Yes   |         | WBTS ID from OMS. for example: 1,2,5        |
    ...
    ...  *RETURN*
    ...  | Parameter              | Description                               |
    ...  | active_alarms          | List of WBTS active alarms seen on RNC    |
    [Arguments]  ${wbts_id}
    ${active_alarms}=  Get Wbts Active Alarms  wbts_ids=${wbts_id}
    [Return]    ${active_alarms}

RNC Get WCEL Active Alarms
    [Documentation]
    ...  KW used to get WCEL Active Alarms from RNC
    ...
    ...  *AUTHOR*
    ...  gabriel.stanculescu@nokia.com
    ...
    ...  *INPUT*
    ...  | Parameter        | Man.  | Default | Description                                 |
    ...  | wbts_id          | Yes   |         | WBTS ID from OMS                            |
    ...  | cell_id          | Yes   |         | WCEL ID from OMS                            |
    ...
    ...  *RETURN*
    ...  | Parameter              | Description                               |
    ...  | active_alarms          | List of WBTS active alarms seen on RNC    |
    [Arguments]  ${wbts_id}  ${cell_id}
    ${active_alarms}=  Get Wcel Active Alarms  wbts_ids=${wbts_id}  cell_ids=${cell_id}
    [Return]    ${active_alarms}

RNC Get WCEL Parameter
    [Documentation]
    ...  KW used to get specific WCEL Parameter from RNC
    ...
    ...  *AUTHOR*
    ...  gabriel.stanculescu@nokia.com
    ...
    ...  *INPUT*
    ...  | Parameter        | Man.  | Default | Description                                 |
    ...  | wbts_id          | Yes   |         | WBTS ID from OMS                            |
    ...  | cell_id          | Yes   |         | WCEL ID from OMS                            |
    ...  | param_short_name | Yes   |         | Parameter short name from OMS               |
    ...
    ...  *RETURN*
    ...  | Parameter              | Description                               |
    ...  | wcel_parameters        | List of wcel parameters seen on RNC       |
    [Arguments]  ${wbts_id}  ${cell_id}  ${param_short_name}
    ${wcel_parameters}=  Get Wcel Parameter  ${wbts_id}  ${cell_id}  ${param_short_name}
    [Return]    ${wcel_parameters}

RNC Set WCEL Parameter
    [Documentation]
    ...  KW used to set specific WCEL Parameter from RNC
    ...
    ...  *AUTHOR*
    ...  gabriel.stanculescu@nokia.com
    ...
    ...  *INPUT*
    ...  | Parameter        | Man.  | Default | Description                            |
    ...  | wbts_id          | Yes   |         | WBTS ID from OMS                       |
    ...  | cell_id          | Yes   |         | WCEL ID from OMS                       |
    ...  | param_name       | Yes   |         | Parameter to be changed                |
    ...  | param_value      | Yes   |         | New value for paramter                 |
    ...  |
    ...
    [Arguments]  ${wbts_id}  ${cell_id}  ${param_name}  ${param_value}
    ${args}=  Create Dictionary
    Set To Dictionary  ${args}  ${param_name}  ${param_value}
    ${wcel_parameters}=  Set Wcel Parameters  ${wbts_id}  ${cell_id}  &{args}

RNC Set AdminCellState
    [Documentation]
    ...  KW used to set WCEL Parameter AdminCellState to locked/unlocked from RNC
    ...
    ...  *AUTHOR*
    ...  gabriel.stanculescu@nokia.com
    ...
    ...  *INPUT*
    ...  | Parameter        | Man.  | Default   | Description                                    |
    ...  | wbts_id          | Yes   |           | WBTS ID from OMS                               |
    ...  | cell_id          | Yes   |           | WCEL ID from OMS                               |
    ...  | admin_cell_state | No    | 1         | Possible values: 0 (Locked), 1 (Unlocked)      |
    ...
    [Arguments]  ${wbts_id}  ${cell_id}  ${admin_cell_state}=1
    RNC Set WCEL Parameter  ${wbts_id}  ${cell_id}  param_name=AdminCellState  param_value=${admin_cell_state}

RNC Get AdminCellState
    [Documentation]
    ...  KW used to get WCEL Parameter AdminCellState (0 for locked, 1 for unlocked)
    ...
    ...  *AUTHOR*
    ...  horea.olar@nokia.com
    ...
    ...  *INPUT*
    ...  | Parameter        | Man.  | Default   | Description                                    |
    ...  | wbts_id          | Yes   |           | WBTS ID from OMS                               |
    ...  | cell_id          | Yes   |           | WCEL ID from OMS                               |
    ...
    [Arguments]  ${wbts_id}  ${cell_id}
    ${admin_cell_state}=  RNC Get WCEL Parameter  ${wbts_id}  ${cell_id}  AdminCellState
    [Return]  ${admin_cell_state}
