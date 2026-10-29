*** Settings ***
Documentation    Resource file contains keywords for NetAct operations
Library          testsuite.Krakow.SISO.resources.netact_operations.NetActOperations    WITH NAME    netact


*** Keywords ***
NetAct Test Case Teardown
    [Documentation]    Obligatory keyword for netact NetAct test cases. It removes draft plan after test.
    netact.teardown

Lock RU via NetAct
    [Documentation]    Perform lock operation via NetAct for RMOD with given ID
    ...    If activate_plan is set to False only preactivation and validation are performed.
    [Arguments]    ${ru_id}    ${activate_plan}=${True}
    netact.perform_rmod_operation_via_netact    operation=lock    rmod_id=${ru_id}    activate_plan=${activate_plan}

Unlock RU via NetAct
    [Documentation]    Perform unlock operation via NetAct for RMOD with given ID.
    ...    If activate_plan is set to False only preactivation and validation are performed.
    [Arguments]    ${ru_id}    ${activate_plan}=${True}
    netact.perform_rmod_operation_via_netact    operation=unlock    rmod_id=${ru_id}    activate_plan=${activate_plan}

Lock RU Cells via NetAct
    [Documentation]    Perform cells lock operation via NetAct for RMOD with given ID
    ...    If activate_plan is set to False only preactivation and validation are performed.
    [Arguments]    ${ru_id}    ${activate_plan}=${True}
    netact.perform_cell_operation_via_netact    operation=lock    rmod_id=${ru_id}    activate_plan=${activate_plan}

Unlock RU Cells via NetAct
    [Documentation]    Perform cells unlock operation via NetAct for RMOD with given ID.
    ...    If activate_plan is set to False only preactivation and validation are performed.
    [Arguments]    ${ru_id}    ${activate_plan}=${True}
    netact.perform_cell_operation_via_netact    operation=unlock    rmod_id=${ru_id}    activate_plan=${activate_plan}
