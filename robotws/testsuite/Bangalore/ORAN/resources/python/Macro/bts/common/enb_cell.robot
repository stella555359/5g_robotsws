*** Settings ***

Library    testsuite.Bangalore.ORAN.resources.python.Macro.Python.bts.common.cell.EnbCell    WITH NAME      enbcell



*** Keywords ***
Verify eNB Cell is onAir
    [Arguments]     ${enb_id}=0    ${cell_id}=1  ${du_id}=${0}
    [Documentation]    Verify 'Operational state' is 'Enabled' and 'Availability status' is 'Online'
    ...     :param enb_id:    ID of eNB, default set to 0
    ...     :param cell_id:   ID of cell, num 1 to 8 can be used, default set to 1.
    ...     :param :param du_id: DU id(Distributed Unit) - id related to Test Line configuration - gnb.dus[]
    enbcell.verify_cell_is_onair    bts_id=${enb_id}    cell_id=${cell_id}  du_id=${du_id}

Unblock eNB Cell
    [Arguments]    ${enb_id}=0    ${cell_id}=1  ${du_id}=${0}
    [Documentation]    Unblock eNB cell.
    ...     :param enb_id:    ENB id - related to Test Line configuration.
    ...     :param cell_id:   cell id.
    ...     :param du_id: DU id(Distributed Unit) - id related to Test Line configuration - gnb.dus[]
    enbcell.unblock_cell    bts_id=${enb_id}    cell_id=${cell_id}  du_id=${du_id}

Block eNB Cell
    [Arguments]    ${enb_id}=0    ${cell_id}=1  ${du_id}=${0}
    [Documentation]    Block eNB cell.
    ...     :param enb_id:    ENB id - related to Test Line configuration.
    ...     :param cell_id:   cell id.
    ...     :param du_id: DU id(Distributed Unit) - id related to Test Line configuration - gnb.dus[]
    enbcell.block_cell    bts_id=${enb_id}    cell_id=${cell_id}  du_id=${du_id}
