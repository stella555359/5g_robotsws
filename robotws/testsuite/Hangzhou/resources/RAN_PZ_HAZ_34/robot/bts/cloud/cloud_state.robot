*** Settings ***
Documentation
...   Migrate keywords from AIC
...   author:yixiang.x.wang@nokia-sbell.com

Resource          cloud_cu.robot
Resource          cloud_vdu.robot


##*** Variables ***


*** Keyword ***
CU Get Specified VM State
   [Arguments]   ${vm_name}    ${gnb_index}=0
   [Documentation]      Return vm operational state and availability state by vm name.
    ...  author:             fen.huang@nokia-sbell.com
    ...  modified by:        <29-Apr-2020>, <f2huang>, <initial created>
    ...    | Input Parameters | Man. | Description |
    ...    |  vm_name  | Yes |  VM name string  |
    ...    |  gnb_index  | No |  gnb index to indicate which gnb will be used, 0 in default |

    ...    *RETURN VALUE*
    ...    operational state and availability state of vm
    ...    Example
    ...   | ${operational_state}  ${availability_state}=   |  CU Get Specified VM State  |   cpif-0  |
   CU login  ${gnb_index}
   ${vm_name}=  convert to lowercase   ${vm_name}
   ${vm_info}=   cu.get_vms
    FOR    ${vm}    IN    @{vm_info}
        ${name_of_vm}=   convert to lowercase   ${vm["name"]}
        ${count}=  get count   ${name_of_vm}   ${vm_name}
        Return From Keyword If    ${count}>=1     ${vm["operational_state"]}   ${vm["availability_status"]}
    END
   [Teardown]  run keyword and ignore error   CU Logout

CU Verify All VMs Are Online
   [Arguments]    ${gnb_index}=0
   [Documentation]      Verify all VMs status should be online and enabled.
    ...  author:        fen.huang@nokia-sbell.com
    ...  modified by:        <29-Apr-2020>, <f2huang>, <initial created>
    ...    | Input Parameters | Man. | Description |
    ...    |  gnb_index  | No |  gnb index to indicate which gnb will be used, 0 in default |
    ...    *RETURN VALUE*
    ...    None
    ...    Example
    ...    |  CU Verify All VMs Are Online  |     |
     CU Login    ${gnb_index}
     ${vm_info}=   cu.get_vms
     FOR    ${vm}    IN    @{vm_info}
         ${operational_state}=   set variable  ${vm["operational_state"]}
         ${availability_status}=   set variable   ${vm["availability_status"]}
         run keyword and continue on failure   should be equal as strings
         ...  ${operational_state}   enabled    ${vm} operational state is not enabled!
         run keyword and continue on failure   should be equal as strings
         ...  ${availability_status}  on line   ${vm} availability status is not online!
     END
     [Teardown]  run keyword and ignore error    CU Logout

CU Get Specified Cell Status
   [Arguments]   ${cell_id}    ${gnb_index}=0
   [Documentation]      Get cell administrative state and operational state  by cell id.
    ...  author:             fen.huang@nokia-sbell.com
    ...  modified by:        <19-Nov-2019>, <f2huang>, <initial created>
    ...    | Input Parameters | Man. | Description |
    ...	   |  cell_id  | Yes |  cell id   |
    ...    |  gnb_index  | No |  gnb index to indicate which gnb will be used, 0 in default |
    ...    *RETURN VALUE*
    ...    [administrativeState,operationalState]
    ...    Example
    ...    |  ${cell_administrativeState}  ${cell_operationalState}= |  CU Get Specified Cell Status  |  111  |
    ...     [{“id”: “211”,
    ...   “administrativeState”: “locked”, “operationalState”: “enabled”}]
    CU Login   ${gnb_index}
    ${cells_info}=  cu.get_cells_statuses
    FOR    ${cell_info}    IN    @{cells_info}
        ${administrative_state}=    Convert To Lowercase   ${cell_info["administrative_state"]}
        ${operational_state}=    Convert To Lowercase     ${cell_info["operational_state"]}
        Return From Keyword If    '${cell_info["id"]}' == '${cell_id}'     ${administrative_state}    ${operational_state}
    END
   [Teardown]   run keyword and ignore error    CU Logout

CU Verify All Cells Status Are Onair
    [Arguments]  ${gnb_index}=0
    [Documentation]      Check all cells operational state are operational and unlocked.
    ...  author:             fen.huang@nokia-sbell.com
    ...  modified by:        <19-Nov-2019>, <f2huang>, <initial created>
    ...    | Input Parameters | Man. | Description |
    ...    |  gnb_index  | No |  gnb index to indicate which gnb will be used, 0 in default |
    ...    *RETURN VALUE*
    ...    None
    ...    Example
    ...    |  CU Verify All Cells Status Are Onair  |     |
    CU Login  ${gnb_index}
    ${cells_summary}=   cu.get_cells_summary
    run keyword and continue on failure  should be equal as integers
    ...    ${cells_summary["basic_cells_summary"]["administrative_state"]["shutting_down"]}   0   Some cells are shutting down!
    run keyword and continue on failure  should be equal as integers
    ...    ${cells_summary["basic_cells_summary"]["administrative_state"]["locked"]}   0   Some cells are locked!
    run keyword and continue on failure  should be equal as integers
    ...    ${cells_summary["basic_cells_summary"]["operational_state"]["disabled"]}    0   Some cells are disabled!
    [Teardown]   run keyword and ignore error   CU Logout

CU Get Cells ID list
   [Arguments]  ${gnb_index}=0
   [Documentation]      Get all avaiable cells id list.
    ...  author:             fen.huang@nokia-sbell.com
    ...  modified by:        <19-Nov-2019>, <f2huang>, <initial created>
    ...    | Input Parameters | Man. | Description |
    ...    |  gnb_index  | No |  gnb index to indicate which gnb will be used, 0 in default |
    ...    *RETURN VALUE*
    ...    cell id list
    ...    Example
    ...    |  CU Get Cell ID list  |   |
    CU Login  ${gnb_index}
    ${all_cells_id_list}=   create list
    ${cells_info}=  cu.get_cells_statuses
    FOR    ${cell_info}    IN    @{cells_info}
        append to list    ${all_cells_id_list}    ${cell_info["id"]}
    END
   [Return]   ${all_cells_id_list}
   [Teardown]  run keyword and ignore error    CU Logout

CU Lock Specified Cell
    [Arguments]   ${cell_id}   ${gnb_index}=0
    [Documentation]      Lock specified cell by cell id.
    ...  author:             fen.huang@nokia-sbell.com
    ...  modified by:        <16-Dec-2019>, <f2huang>, <initial created>
    ...    | Input Parameters | Man. | Description |
    ...	   |  cell_id  | Yes |  cell id   |
    ...    |  gnb_index  | No |  gnb index to indicate which gnb will be used, 0 in default |
    ...    *RETURN VALUE*
    ...    None
    ...    Example
    ...    |  CU Lock Specified Cell  |   |
     CU Login  ${gnb_index}
     ${return_info}=   cu.lock_cell   ${cell_id}
     ${operation_id}=   set variable    ${return_info.id}
     wait until keyword succeeds  60s  5s   CU Check Operation Status For Specified Cell Should Be As Expected
     ...    ${cell_id}  lock  ${operation_id}  completed
     CU Check Specified Cell Status Should Be As Expected    ${cell_id}   locked   disabled  ${gnb_index}

CU Lock Cells
    [Arguments]   ${cell_id_list}=${ALL_CELLS_ID_LIST}  ${gnb_index}=0
    [Documentation]      Lock specified cells by cell id list and it will lock all cells in default.
    ...  author:             fen.huang@nokia-sbell.com
    ...  modified by:        <16-Dec-2019>, <f2huang>, <initial created>
    ...  modified by:        <06-Oct-2024>, <jiajing.1.cheng@nokia-sbell.com>, <modify to current taf>
    ...    | Input Parameters | Man. | Description |
    ...	   |  cell_id_list  | Yes |  Cell id list thats need to be locked |
    ...    |  gnb_index  | No |  gnb index to indicate which gnb will be used, 0 in default |
    ...    *RETURN VALUE*
    ...    None
    ...    Example
    ...    |  CU Lock Cells  |     |
     CU Login  ${gnb_index}
     ${return_info}=  cu.lock_cells   ${cell_id_list}
     ${operation_id}=   set variable    ${return_info["id"]}
     wait until keyword succeeds  6min  30s   CU Check Operation Status For Specified Cell Should Be As Expected
     ...     lock   ${operation_id}  success
     FOR    ${cell_id}    IN    @{cell_id_list}
         CU Check Specified Cell Status Should Be As Expected      ${cell_id}   locked  disabled
     END
     [Teardown]   run keyword and ignore error    CU Logout

CU Unock Specified Cell
    [Arguments]   ${cell_id}  ${gnb_index}=0
    [Documentation]      Unlock specified cell by cell id.
    ...  author:             fen.huang@nokia-sbell.com
    ...  modified by:        <16-Dec-2019>, <f2huang>, <initial created>
    ...    | Input Parameters | Man. | Description |
    ...	   |  cell_id  | Yes |  cell id   |
    ...    |  gnb_index  | No |  gnb index to indicate which gnb will be used, 0 in default |
    ...    *RETURN VALUE*
    ...    None
    ...    Example
    ...    |  CU Unlock Specified Cell  |   |
     CU Login  ${gnb_index}
     ${return_info}=  cu.unlock_cell   ${cell_id}
     ${operation_id}=   set variable    ${return_info.id}
     wait until keyword succeeds  60s  5s   CU Check Operation Status For Specified Cell Should Be As Expected
     ...    ${cell_id}  unlock  ${operation_id}  completed
     CU Check Specified Cell Status Should Be As Expected     ${cell_id}   unlocked   enabled

CU Unlock Cells
    [Arguments]   ${cell_id_list}=${ALL_CELLS_ID_LIST}  ${gnb_index}=0
    [Documentation]      Unlock specified cells by cell id list and it will unlock all cells in default.
    ...  author:             fen.huang@nokia-sbell.com
    ...  modified by:        <16-Dec-2019>, <f2huang>, <initial created>
    ...  modified by:        <06-Oct-2024>, <jiajing.1.cheng@nokia-sbell.com>, <modify to current taf>
    ...    | Input Parameters | Man. | Description |
    ...	   |  cell_id_list  | Yes |  Cell id list thats need to be locked |
    ...    |  gnb_index  | No |  gnb index to indicate which gnb will be used, 0 in default |
    ...    *RETURN VALUE*
    ...    None
    ...    Example
    ...    |  CU Unlock Cells  |     |
     CU Login  ${gnb_index}
     ${return_info}=    cu.unlock_cells   ${cell_id_list}
     ${operation_id}=   set variable    ${return_info["id"]}
     wait until keyword succeeds  6min  30s   CU Check Operation Status For Specified Cell Should Be As Expected
     ...   unlock   ${operation_id}  success
     FOR    ${cell_id}    IN    @{cell_id_list}
        wait until keyword succeeds  5min  10s
        ...      CU Check Specified Cell Status Should Be As Expected    ${cell_id}   unlocked    enabled
     END
     [Teardown]  run keyword and ignore error    CU Logout

CU Check Operation Status For Specified Cell Should Be As Expected
    [Arguments]   ${operation_type}  ${operation_id}  ${expected_status}=success  ${gnb_index}=0
    [Documentation]      Check specified cell operation status should be as expected.
    ...  author:             fen.huang@nokia-sbell.com
    ...  modified by:        <16-Dec-2019>, <f2huang>, <initial created>
    ...  modified by:        <06-Oct-2024>, <jiajing.1.cheng@nokia-sbell.com>, <modify to current taf>
    ...    | Input Parameters | Man. | Description |
    ...	   |  cell_id  | Yes |  cell id   |
    ...	   |  operation_id  | Yes |  Operation id for lock operation  |
    ...	   |  operation_type  | Yes |  cell operation type, lock or unlock supported |
    ...	   |  expected_status  | Yes |  Cell opertion status, can be ongoing or completed. |
    ...    |  gnb_index  | No |  gnb index to indicate which gnb will be used, 0 in default |


    ...    *RETURN VALUE*
    ...    None
    ...    Example
    ...    |  CU Check Cell Operation Status Should Be As Expected  |  123  |   lock |   12345678   | completed  |
    log to console   ${gnb_index}
    ${operation_info}=    run keyword if   "${operation_type}"=="lock"    cu.get_operation_state_of_locking_cells
    ...  ${operation_id}
    ...  ELSE IF   "${operation_type}"=="unlock"   cu.get_operation_state_of_unlocking_cells    ${operation_id}
    ...  ELSE   BuiltIn.Log  Operation type not supported!
    run keyword and continue on failure    should be true     "${operation_info["status"]}"=="${expected_status}"

CU Check Specified Cell Status Should Be As Expected
    [Arguments]     ${cell_id}   ${expected_administrative_state}=unlocked    ${expected_operational_state}=enabled  ${gnb_index}=0
    [Documentation]      Check specified cell status should be as expected.
    ...  author:             fen.huang@nokia-sbell.com
    ...  modified by:        <16-Dec-2019>, <f2huang>, <initial created>
    ...    | Input Parameters | Man. | Description |
    ...	   |  cell_id  | Yes |  cell id   |
    ...	   |  expected_administrative_state  | Yes |  Expected administrative state for cell  |
    ...	   |  expected_operational_state  | Yes |  Expected operational state for cell |

    ...    *RETURN VALUE*
    ...    None
    ...    Example
    ...    | CU Check Cell Status Should Be As Expected  |  123  |   locked  |  disabled  |
    ${cell_administrativeState}  ${cell_operationalState}=    CU Get Specified Cell Status   ${cell_id}  ${gnb_index}
    run keyword and continue on failure    Should Be Equal As Strings     ${cell_administrativeState}    ${expected_administrative_state}
    ...    msg=Administrative state of cell ${cell_id} is not ${expected_administrative_state}!    ignore_case=${True}
    run keyword and continue on failure    Should Be Equal As Strings     ${cell_operationalState}    ${expected_operational_state}
    ...    msg=Operational state of cell ${cell_id} is not ${expected_operational_state}!    ignore_case=${True}

CU Check Operation Status For Specified DU Should Be As Expected
    [Arguments]   ${du_id}  ${operation_type}  ${operation_id}  ${expected_status}=completed  ${gnb_index}=0
    [Documentation]      Check specified du operation status should be as expected.
    ...  author:             fen.huang@nokia-sbell.com
    ...  modified by:        <16-Dec-2019>, <f2huang>, <initial created>
    ...    | Input Parameters | Man. | Description |
    ...	   |  cell_id  | Yes |  cell id   |
    ...	   |  operation_id  | Yes |  Operation id for lock operation  |
    ...	   |  operation_type  | Yes |  cell operation type, can be lock or unlock |
    ...	   |  expected_status  | Yes |  Cell opertion status, can be ongoing or completed. |
    ...    |  gnb_index  | No |  gnb index to indicate which gnb will be used, 0 in default |
    ...    *RETURN VALUE*
    ...    None
    ...    Example
    ...    |  CU Check DU Operation Status Should Be As Expected  |  123  |   lock |   12345678   | completed  |
    CU Login  ${gnb_index}
    ${operation_info}=    run keyword if   "${operation_type}"=="lock"    cu.get_du_lock_operation_state    ${du_id}    ${operation_id}
    ...  ELSE IF   "${operation_type}"=="unlock"   cu.get_du_unlock_operation_state    ${du_id}    ${operation_id}
    ...  ELSE   BuiltIn.Log  Operation type not supported!
    run keyword and continue on failure    should be true     "${operation_info["status"]}"=="${expected_status}"

CU Check Specified DU Status Should Be As Expected
    [Arguments]     ${du_id}   ${expected_administrative_state}=unlocked    ${expected_f1link_state}=available    ${gnb_index}=0
    [Documentation]      Check specified du status should be as expected.
    ...  author:             fen.huang@nokia-sbell.com
    ...  modified by:        <16-Dec-2019>, <f2huang>, <initial created>
    ...    | Input Parameters | Man. | Description |
    ...	   |  du_id  | Yes |  Distributed unit instance id  |
    ...	   |  expected_administrative_state  | Yes |  Expected administrative state for the specified distributed unit  |
    ...	   |  expected_f1link_state  | Yes |  Expected F1 link for the specified distributed unit  |
    ...    |  gnb_index  | No |  gnb index to indicate which gnb will be used, 0 in default |

    ...    *RETURN VALUE*
    ...    None
    ...    Example
    ...    | CU Check DU Status Should Be As Expected  |  333  |   unlocked  |  available  |
    CU Login  ${gnb_index}
    ${du_info}=    cu.get_du_state   ${du_id}
    run keyword and continue on failure    should be true     "${du_info["administrativeState"]}"=="${expected_administrative_state}"
    ...    AdministrativeState state of DU ${du_id} is not ${expected_administrative_state}!
    run keyword and continue on failure    should be true     "${du_info["f1LinkStatus"]}"=="${expected_f1link_state}"
    ...   Operational state of DU ${du_id} is not ${expected_f1link_state}!

CU Verify All DUs Status Are Available
    [Arguments]   ${gnb_index}=0
    [Documentation]      Check all dus status should be available and unlocked.
    ...  author:             fen.huang@nokia-sbell.com
    ...  modified by:        <17-Apr-2020>, <f2huang>, <initial created>
    ...    | Input Parameters | Man. | Description |
    ...    |  gnb_index  | No |  gnb index to indicate which gnb will be used, 0 in default |
    ...    *RETURN VALUE*
    ...    None
    ...    Example
    ...    |  CU Verify All DUs Status Are Available  |     |
    CU Login  ${gnb_index}
    ${dus_summary}=   cu.get_du_state
    run keyword and continue on failure   should be equal as integers      ${dus_summary["f1_link_status"]["unavailable"]}   0
    ...    Some F1 links are unavailable!
    run keyword and continue on failure   should be equal as integers      ${dus_summary['administrative_state']["locked"]}   0
    ...    Some dus are locked!
    [Teardown]   run keyword and ignore error   CU Logout

CU Verify All F1 Links Status Are Available
    [Arguments]   ${gnb_index}=0
    [Documentation]      Check all F1 links status should be available.
    ...  author:             fen.huang@nokia-sbell.com
    ...  modified by:        <17-Apr-2020>, <f2huang>, <initial created>
    ...    | Input Parameters | Man. | Description |
    ...    |  gnb_index  | No |  gnb index to indicate which gnb will be used, 0 in default |
    ...    *RETURN VALUE*
    ...    None
    ...    Example
    ...    |  CU Verify All F1 Links Status Are Available  |     |
    CU Login   ${gnb_index}
    ${dus_summary}=   cu.get_du_state
    should be equal as integers      ${dus_summary["f1_link_status"].unavailable}   0
    ...    Not all F1 links are available!
    [Teardown]   run keyword and ignore error   CU Logout

CU Verify All F1 Links Status Are Unavailable
    [Arguments]   ${gnb_index}=0
    [Documentation]      Check all F1 links status should be unavailable.
    ...  author:             fen.huang@nokia-sbell.com
    ...  modified by:        <10-Jun-2020>, <f2huang>, <initial created>
    ...    | Input Parameters | Man. | Description |
    ...    |  gnb_index  | No |  gnb index to indicate which gnb will be used, 0 in default |
    ...    *RETURN VALUE*
    ...    None
    ...    Example
    ...    |  CU Verify All F1 Links Status Are Unavailable  |     |
    CU Login   ${gnb_index}
    ${dus_summary}=   cu.get_du_state
    should be equal as integers      ${dus_summary["f1_link_status"].available}   0
    ...    Some F1 links are available!
    [Teardown]   run keyword and ignore error   CU Logout

CU Check F1 Links Status Should Be As Expected
    [Arguments]      ${expected_f1link_status}=available    ${gnb_index}=0
    [Documentation]      Check all F1 links status should be as expected.
    ...  author:             fen.huang@nokia-sbell.com
    ...  modified by:        <19-Dec-2019>, <f2huang>, <initial created>
    ...    | Input Parameters | Man. | Description |
    ...	   |  expected_f1link_status  | Yes |  Expected F1 link for the specified distributed unit  |
    ...    |  gnb_index  | No |  gnb index to indicate which gnb will be used, 0 in default |
    ...    *RETURN VALUE*
    ...    None
    ...    Example
    ...    | CU Check F1 Links Status Should Be As Expected  |  available  |
    CU Login  ${gnb_index}
    ${dus_info}=   cu.get_dus_info
    FOR   ${du}  IN  @{dus_info}
       run keyword and continue on failure    ${du["f1LinkStatus"]}=="${expected_f1link_status}"
       ...    F1 link status is not ${expected_f1link_status}!
    END

CU Check X2 Links Status Should Be As Expected
    [Arguments]         ${expected_x2link_lock_status}=unlocked   ${expected_x2link_status}=available  ${gnb_index}=0
    [Documentation]      Check all X2 links status should be as expected.
    ...  author:             fen.huang@nokia-sbell.com
    ...  modified by:        <19-Dec-2019>, <f2huang>, <initial created>
    ...    | Input Parameters | Man. | Description |
    ...	   |  expected_x2link_lock_status  | Yes |  Expected X2 link lock status, can be locked or unlocked  |
    ...	   |  expected_x2link_status  | Yes |  Expected X2 link status, can be available or unavailable  |
    ...    |  gnb_index  | No |  gnb index to indicate which gnb will be used, 0 in default |
    ...    *RETURN VALUE*
    ...    None
    ...    Example
    ...    |  CU Check X2 Links Status Should Be As Expected  |  unlocked  |  available  |
    CU Login  ${gnb_index}
    ${x2_links_info}=   cu.get_x2_links_info
    ${x2_links}=  set variable  ${x2_links_info["created"]}
    FOR   ${link}  IN  @{x2_links}
       run keyword and continue on failure  should be true
       ...   "${link.x2_link_lock}"=="${expected_x2link_lock_status}" and "${link.x2_link_status}"=="${expected_x2link_status}"
       ...    X2 link status is not ${expected_x2link_lock_status} or ${expected_x2link_status}!
    END
    [Teardown]  run keyword and ignore error   CU Logout

CU Verify All X2 Links Status Are Available
    [Arguments]   ${gnb_index}=0
    [Documentation]      Check all X2 links status should be as unlocked and available.
    ...  author:             fen.huang@nokia-sbell.com
    ...  modified by:        <19-Dec-2019>, <f2huang>, <initial created>
    ...    | Input Parameters | Man. | Description |

    ...    *RETURN VALUE*
    ...    None
    ...    Example
    ...    |  CU Verify All X2 Links Status Are Available |  unlocked  |  available  |
   CU Check X2 Links Status Should Be As Expected    unlocked   available   ${gnb_index}

CU Get DU Cells Map
     [Arguments]       ${gnb_index}=0
    [Documentation]      Return distributed unit/cells map.
    ...  author:             fen.huang@nokia-sbell.com
    ...  modified by:        <19-Dec-2019>, <f2huang>, <initial created>
    ...    | Input Parameters | Man. | Description |
    ...    |  gnb_index  | No |  gnb index to indicate which gnb will be used, 0 in default |

    ...    *RETURN VALUE*
    ...    Dict  du_id:cells_list
    ...    Example
    ...    |  CU Get DU Cells Map  |    |
   ${du_cell_map}=  create dictionary
   CU Login   ${gnb_index}
   ${dus_info}=   cu.get_dus_info
   FOR   ${du}  IN  @{dus_info}
       ${cell_list}=   CU Get Cells On Specified DU     du["id"]    ${gnb_index}
       set to dictionary   ${du_cell_map}     du["id"]    ${cell_list}
   END
   [Return]   ${du_cell_map}

CU Lock Specified DU
    [Arguments]   ${du_id}  ${gnb_index}=0
    [Documentation]      Lock specified du by du id.
    ...  author:             fen.huang@nokia-sbell.com
    ...  modified by:        <11-Mar-2020>, <f2huang>, <initial created>
    ...    | Input Parameters | Man. | Description |
    ...	   |  du_id  | Yes |  DU instance id   |
    ...    |  gnb_index  | No |  gnb index to indicate which gnb will be used, 0 in default |
    ...    *RETURN VALUE*
    ...    None
    ...    Example
    ...    |  CU Lock Specified DU  |   |
     CU Login  ${gnb_index}
     ${return_info}=   cu.lock_du   ${du_id}
     ${operation_id}=   set variable    ${return_info.id}
     wait until keyword succeeds  60s  5s   CU Check Operation Status For Specified DU Should Be As Expected
     ...    ${du_id}    locked    ${operation_id}   completed   ${gnb_index}
     CU Check Specified DU Status Should Be As Expected     ${du_id}   locked   ${gnb_index}

CU Unlock Specified DU
    [Arguments]   ${du_id}  ${gnb_index}=0
    [Documentation]      Unlock specified du by du id.
    ...  author:             fen.huang@nokia-sbell.com
    ...  modified by:        <11-Mar-2020>, <f2huang>, <initial created>
    ...    | Input Parameters | Man. | Description |
    ...	   |  du_id  | Yes |  DU instance id   |
    ...    |  gnb_index  | No |  gnb index to indicate which gnb will be used, 0 in default |

    ...    *RETURN VALUE*
    ...    None
    ...    Example
    ...    |  CU Unlock Specified DU  |   |
     CU Login  ${gnb_index}
     ${return_info}=   cu.unlock_du   ${du_id}
     ${operation_id}=   set variable    ${return_info.id}
     wait until keyword succeeds  60s  5s   CU Check Operation Status For Specified DU Should Be As Expected
     ...    ${du_id}    unlocked    ${operation_id}   completed     ${gnb_index}
     CU Check Specified DU Status Should Be As Expected     ${du_id}   unlocked   available  ${gnb_index}

CU Verify ALL VMs SSH Connection
    [Documentation]    Verify all VMs SSH connection is working.
    ...  author:             fen.huang@nokia-sbell.com
    ...  modified by:        <19-Nov-2019>, <f2huang>, <initial created>
    ...    | Input Parameters | Man. | Description |
    ...    *RETURN VALUE*
    ...    None
    ...    Example
    ...    |  CU Verify ALL VMs SSH Connection  |    |
    log to console   \n*** Verify OAM VM SSH Connection ***
    ${alias}=  CU SSH To OAM
    log to console   \n*** Verify CPCL VM SSH Connection ***
    CU SSH To CPCL
    Disconnect Interactive Connection
    log to console   \n*** Verify CPIF VM SSH Connection ***
    CU SSH To CPIF
    Disconnect Interactive Connection
    log to console   \n*** Verify CPNB VM SSH Connection ***
    CU SSH To CPNB
   Disconnect Interactive Connection
    log to console   \n*** Verify CPUE VM SSH Connection ***
    CU SSH To CPUE
    Disconnect Interactive Connection
    log to console   \n*** Verify UPUE VM SSH Connection ***
    CU SSH To UPUE
    Disconnect Interactive Connection
    log to console   \n*** Verify CPNRT VM SSH Connection ***
    CU SSH To CPNRT
    Disconnect Interactive Connection
    log to console   \n*** Verify DB VM SSH Connection ***
    CU SSH To DB
    [Teardown]   Disconnect Interactive Connection   ${alias}

CU Get Active OAM
    [Arguments]     ${gnb_index}=0
    [Documentation]    Return host name of active oam.
    ...  author:             fen.huang@nokia-sbell.com
    ...  modified by:        <14-May-2020>, <f2huang>, <initial created>
    ...    | Input Parameters | Man. | Description |
    ...    |  gnb_index  | No |  Indicate which gnb/cu will be used, 0 in default |
    ...    *RETURN VALUE*
    ...    active oam host name
    ...    Example
    ...    | CU Get Active OAM |    |
    ${alias}=   run keyword   CU SSH To OAM   ${gnb_index}
    ${output}=  issh.execute  hostname  check_result=${False}  alias=${alias}
    ${output}=  strip String    ${output}
    ${active_host}=    Split String    ${output}    \r\n
    log to console   \n***  Active OAM : ${active_host[0]}  ***
    [Return]    ${active_host[0]}
    [Teardown]   Disconnect Interactive Connection    ${alias}

CU Get Active Alarms
    [Arguments]  ${gnb_index}=0
    [Documentation]  Gets active alarms including faults from BTS and alarms from RCP.
        ...    author: fen.huang@nokia-sbell.com
        ...    modified by:   <19-Nov-2019>, <f2huang>, <e.g. PR-Number, feature number>
        ...    | Input Parameters | Man. | Description |
        ...    |  gnb_index  | No |  gnb index to indicate which gnb will be used, 0 in default  |
        ...
        ...    *RETURN VALUE*
        ...    Active alarm list
        ...    Example
        ...    |  Get CU Active Alarm	 |    |
     CU Rest Login  ${gnb_index}
     ${active_alarm_list}=  cu.get_active_alarms    page_number=${1}     items_per_page=${1000}
     ${num_of_alarms}=   get length     ${active_alarm_list["alarms"]}
     run keyword and continue on failure   should be equal as integers    ${num_of_alarms}    ${active_alarm_list["total"]}
     ...    There should be ${active_alarm_list["total"]} active alarms, but actually got ${num_of_alarms}
     [Return]     ${active_alarm_list["alarms"]}

CU Get Historical Alarms
    [Arguments]  ${gnb_index}=0
    [Documentation]   Gets historic alarms including faults from BTS and alarms from RCP.
        ...    author: fen.huang@nokia-sbell.com
        ...    modified by:   <19-Nov-2019>, <f2huang>, <e.g. PR-Number, feature number>
        ...    | Input Parameters | Man. | Description |
        ...    |  gnb_index  | No |  gnb index to indicate which gnb will be used, 0 in default  |

        ...    *RETURN VALUE*
        ...    History alarm list
        ...    Example
        ...    |  Get CU History Alarm	 |    |
    CU Login  ${gnb_index}
    ${historical_alarm_list}=  cu.get_historical_alarms    page_number=${1}     items_per_page=${10000}
    ${num_of_alarms}=   get length     ${historical_alarm_list["alarms"]}
    run keyword and continue on failure   should be equal as integers    ${num_of_alarms}    ${historical_alarm_list["total"]}
     ...    There should be ${historical_alarm_list["total"]} historical alarms, but actually got ${num_of_alarms}
    [Return]    ${historical_alarm_list["alarms"]}

vDU Special Pod Status And Container Number Should Be Expected
    [Arguments]  ${pod_abbr}    ${status}   ${vdu_index}=0   ${alias}=${EMPTY}   ${is_check_number}=true  ${gnb_index}=0
    [Teardown]  run keyword and ignore error  Run Keyword If   "${alias}"=="${EMPTY}"   fast_disconnect  alias=${real_alias}
    [Documentation]   vDU Special Pod Status And Container Number Should Be Expected
    ...    *AUTHOR* chris.l.cao@nokia-sbell.com
    ...  modified by:        <25-Mar-2020>, <huilxu>, <is_check_number added>
    ...    |  Input Parameters | Man. | Description |
    ...    | pod_abbr          |  Yes | pod abbreviation, eg, oamcp, up |
    ...    | status          | yes | expected status, it is not case-sensitive, e.g, RUNNING, Running, etc. |
    ...    | vdu_index       | No | vdu_index, default is 0 |
    ...    | is_check_number | No | is_check_number, default is true |
    ...
    ...    *RETURN VALUE*
    ...    None
    ...
    ...    Example
    ...    | vDU Special Pod Status And Container Number Should Be Expected | pod_abbr=oamcp | status=Running |
    ...    | vDU Special Pod Status And Container Number Should Be Expected | pod_abbr=up    | status=Running |
    ...    | vDU Special Pod Status And Container Number Should Be Expected | pod_abbr=securestorage    | status=Running |
    ...
    ${real_alias}   Run Keyword If   "${alias}"=="${EMPTY}"   get unique id
    ...    ELSE   Set Variable   ${alias}

    Run Keyword If   "${alias}"=="${EMPTY}"     fast_connect_to_k8s_master
      ...   alias=${alias}  vdu_index=${vdu_index}  alias=${real_alias}

    ${full_pod_name}   Get Full Pod Name By Pod Abbreviation Interactively In Python
      ...  pod_abbr=${pod_abbr}   vdu_index=${vdu_index}   alias=${real_alias}

    ${command}  Set Variable  kubectl get pod ${full_pod_name}
    ${with_pipeline_command}  Set Variable   |awk '{print $2}'|grep -v READY
    ${actual_ready}  fast_execute   command=${command}  with_pipeline_command=${with_pipeline_command}
     ...   gnb_index=${gnb_index}  vdu_index=${vdu_index}  alias=${real_alias}
    ${actual_ready}   Set Variable  ${actual_ready.strip()}
    Should Not Be Empty   ${actual_ready}

    ${command}  Set Variable  kubectl get pod ${full_pod_name}
    ${with_pipeline_command}  Set Variable   |awk '{print $3}'|grep -v STATUS
    ${actual_status}  fast_execute   command=${command}  with_pipeline_command=${with_pipeline_command}
     ...   gnb_index=${gnb_index}  vdu_index=${vdu_index}  alias=${real_alias}

    ${actual_status}   Set Variable  ${actual_status.strip()}
    Should Not Be Empty   ${actual_status}

    ${matches}   split string  ${actual_ready}   /
    should be true  ${matches.__len__()}==2
    ${running_num}  set variable   ${matches[0]}
    ${total_num}    set variable  ${matches[1]}
    Run keyword if  "${is_check_number}"=="${True}"   should be true   ${running_num}==${total_num}

    ${actual_status}   Set Variable  ${actual_status.strip()}
    Should Be True   "${actual_status}"=="${status}"


vDU Verify All Cells Status Should Be Onair
    [Arguments]  ${vdu_index}=0    ${gnb_index}=0
    [Documentation]    Check the number of cells which are in ubnormal status should be 0.
    ...    the keyword only support rest api v2.
    ...    the checked status are operational_state--disabled
    ...                           administrative_state--locked
    ...                           administrative_state--shutting_down
    ...    author:  calla.wang@nokia-sbell.com
    ...    | Input Parameters | Man. | Description |
    ...    | vdu_index | Yes. |specify which vdu needs to be check if the testline configed multi vdus |
    ...    *RETURN VALUE*
    ...    None
    ...    Example
    ...    |  vDU Verify All Cells Status Should Be Onair  | 0 |
    vDU Rest Login    vdu_index=${vdu_index}    gnb_index=${gnb_index}
    ${vdu_cells_summary}=  vdu.get_vdu_cells_summary
    Should Be Equal As Numbers  ${vdu_cells_summary['basic_cells_summary']['operational_state']['disabled']}  0
    Should Be Equal As Numbers  ${vdu_cells_summary['basic_cells_summary']['administrative_state']['locked']}  0
#    should be true       '${vdu_cells_summary['basic_cells_summary']['administrative_state']['shutting_down']}'=='None'
    Should Be Equal As Numbers  ${vdu_cells_summary['basic_cells_summary']['administrative_state']['shutting_down']}  0
    [Teardown]  vDU Logout

vDU Verify All Rmods Status Should Be Normal
    [Arguments]  ${vdu_index}=0
    [Documentation]    Check the number of rmods which are in ubnormal status should be 0.
    ...    the keyword only support rest api v2.
    ...    the checked status are operational_state--disabled
    ...                           administrative_state--locked
    ...    author:  calla.wang@nokia-sbell.com
    ...    | Input Parameters | Man. | Description |
    ...    | vdu_index | Yes. |specify which vdu needs to be check if the testline configed multi vdus |
    ...    *RETURN VALUE*
    ...    None
    ...    Example
    ...    |  vDU Verify All Rmods Status Should Be Normal  | 0 |
    vDU Rest Login    vdu_index=${vdu_index}
    ${vdu_rmods_summary}=  vdu.get_rmods_summary
    Should Be Equal As Numbers  ${vdu_rmods_summary['operational_state']['disabled']}  0
    Should Be Equal As Numbers  ${vdu_rmods_summary['administrative_state']['locked']}  0
    [Teardown]  vDU Logout

vDU Get Cells ID list
   [Arguments]  ${vdu_index}=0
   [Documentation]      Get all avaiable cells id list.
    ...  author:   calla.wang@nokia-sbell.com
    ...    | Input Parameters | Man. | Description |
    ...	   | vdu_index | Yes. |specify which vdu needs to be check if the testline configed multi vdus |
    ...    *RETURN VALUE*
    ...    cell id list
    ...    Example
    ...    |  vDU Get Cells ID list  | 0 |
    vDU Rest Login    vdu_index=${vdu_index}
    ${all_cells_id_list}=   create list
    ${cells_info}=  vdu.get_vdu_cells_status
   FOR    ${cell_info}    IN    @{cells_info}
      append to list    ${all_cells_id_list}    ${cell_info["id"]}
    END
   [Return]   ${all_cells_id_list}
   [Teardown]  vDU Logout


vDU Verify Cells Status Should Be Onair With Expected Cell Number
    [Arguments]  ${vdu_index}=0     ${gnb_index}=0   ${expected_cell_number}=1
    [Documentation]    vDU Verify Cells Status Should Be Onair With Expected Cell Number
    ...    the keyword only support rest api v2.
    ...    the checked status are operational_state--disabled
    ...                           administrative_state--locked
    ...                           administrative_state--shutting_down
    ...    history change: <date>,<who>,<what and how>
    ...    Initialized by calla.wang@nokia-sbell.com,add support container.
    ...    26.11.2020, chris.l.cao@nokia-sbell.com,add check for ${on_line}>=1
    ...    7.6.2021, chris.l.cao@nokia-sbell.com,add parameter expected_cell_number
    ...
    ...    | Input Parameters | Man. | Description |
    ...    | vdu_index | No. | specify which vdu needs to be check if the testline configed multi vdus |
    ...    | gnb_index | No. | specify which vdu needs to be check if the testline configed multi vdus |
    ...    | expected_cell_number | No. | expected_cell_number |
    ...
    ...    *RETURN VALUE*
    ...    None
    ...
    ...    Example
    ...    | vDU Verify Cells Status Should Be Onair With Expected Cell Number  |
    ...
    log to console      ${gnb_index}
    ${alias}=  get unique id
    vDU Rest Login   vdu_index=${vdu_index}
    ${vdu_cells_summary}=  vdu.get_vdu_cells_summary  vdu_connection=${alias}
    Should Be Equal As Numbers  ${vdu_cells_summary['basic_cells_summary']['operational_state']['disabled']}  0
    Should Be Equal As Numbers  ${vdu_cells_summary['basic_cells_summary']['administrative_state']['locked']}  0
    Should Be Equal As Numbers  ${vdu_cells_summary['basic_cells_summary']['administrative_state']['shutting_down']}  0
    ${on_line}   set variable   ${vdu_cells_summary['availability_status']['on_line']}
    should be true  ${on_line}==${expected_cell_number}

vDU Verify All Cells Status Should Be Onair For All DUs
    [Arguments]   ${gnb_index}=0
    [Documentation]    vDU Verify All Cells Status Should Be Onair For All DUs
    ...    the keyword only support rest api v2.
    ...    the checked status are operational_state--disabled
    ...                           administrative_state--locked
    ...                           administrative_state--shutting_down
    ...    history change: <date>,<who>,<what and how>
    ...    10.6.2021, chris.l.cao@nokia-sbell.com, exactly check all cells are on-air
    ...
    ...    | Input Parameters | Man. | Description |
    ...    | gnb_index | Yes. | gnb_index, default is 0 |
    ...
    ...    *RETURN VALUE*
    ...    None
    ...
    ...    Example
    ...    |  vDU Verify All Cells Status Should Be Onair For All DUs |
    ...
    ${du_number}   Get vDU Number   gnb_index=${gnb_index}
    FOR   ${i}  IN RANGE   ${du_number}
       vDU Verify All Cells Status Should Be Onair    vdu_index=${i}
    END

Get Max Plan Number And Delete One If Reach Max Number
    [Documentation]   this kw is used to Get Max Plan Number And Delete One If Reach Max Number
    ...    Author: mengli yang
    ...    Contact: mengli.yang@nokia-sbell.com
    ...    | Input Parameters    | Man. | Description |
    ...    | None | NA |
    ...    | Return Value | Description |
    ...    | None | NA |
    ...
    ...   Example
    ...  | Get Max Plan Number And Delete One If Reach Max Number |
    ...
    ${all_plans}   vdu.Get_Staged_Plans_Info_List
    Should Be True  ${all_plans.__len__()}<=3
    Run Keyword If  ${all_plans.__len__()}==3   Log To Console  ${all_plans[0]["plan_name"]}/${all_plans[0]["plan_id"]} will be deleted!
    Run Keyword If  ${all_plans.__len__()}==3   vdu.Delete_Staged_Plan_File   plan_id=${all_plans[0]["plan_id"]}
