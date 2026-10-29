*** Settings ***
Documentation    Common keywords for ALD testing
...    Author:        daniel.bartkowiak@nokia.com
...    Maintainer:    Daniel Bartkowiak

*** Keywords ***
Cloud ALD Check Cells According To Impact
    [Arguments]  ${impacted_cells}  ${not_impacted_cells}  ${impacted_state_dict}  ${not_impacted_state_dict}
    ...  ${vdu_connection}=default
    [Documentation]  KW checks states of cells according to impact.
    ...  impacted/not_impacted check can be skipped when providing @{EMPTY} list.
    ...  Arguments:
    ...  +=========================+======+============================================================================+
    ...  | Argument                | Man. | Description                                                                |
    ...  +=========================+======+============================================================================+
    ...  | impacted_cells          |  Yes | cells ids list under tested rets                                           |
    ...  +-------------------------+------+----------------------------------------------------------------------------+
    ...  | not_impacted_cells      |  Yes | cells ids list not impacted by tested rets                                 |
    ...  +-------------------------+------+----------------------------------------------------------------------------+
    ...  | impacted_state_dict /   | Yes  | Dictionary of cell states or statuses and expected values e.g.             |
    ...  | not_impacted_state_dict |      | e.g. {'availabilityStatus': 'on line', 'operationalState': 'enabled'}      |
    ...  +-------------------------+------+----------------------------------------------------------------------------+
    ...  | vdu_connection          |  No  | vDU connection object or string name alias if used.                        |
    ...  +-------------------------+------+----------------------------------------------------------------------------+
# Check impacted cells
    FOR  ${impacted_cell}  IN  @{impacted_cells}
      ${cell_id}=  Fetch From Right  string=${impacted_cell}  marker=-
      Cell Wait For Expected States Or Statuses
      ...  cell_id=${cell_id}
      ...  state_status_dict=${impacted_state_dict}
      ...  timeout=10s
      ...  time_interval=2s
      ...  vdu_connection=${vdu_connection}
      Log  ${info_prefix}NR cell ${impacted_cell} has ${impacted_state_dict} as expected  console=${log_to_console}
    END
# Check not impacted cells
    FOR  ${not_impacted_cell}  IN  @{not_impacted_cells}
      ${cell_id}=  Fetch From Right  string=${not_impacted_cell}  marker=-
      Cell Wait For Expected States Or Statuses
      ...  cell_id=${cell_id}
      ...  state_status_dict=${not_impacted_state_dict}
      ...  timeout=10s
      ...  time_interval=2s
      ...  vdu_connection=${vdu_connection}
      Log  ${info_prefix}NR cell ${not_impacted_cell} has ${not_impacted_state_dict} as expected  console=${log_to_console}
    END
