*** Settings ***
Documentation
...   author: cheng xianbiao
...   contact: xianbiao.cheng@nokia-sbell.com




#*** Variables ***


*** Keyword ***
CU Reset
    #[Arguments]     ${gnb_index}=0
    [Documentation]    Reset CU via rest
    ...  author:             fen.huang@nokia-sbell.com
    ...    history change: 1.2.2021, chris.l.cao@nokia-sbell.com,add real code to reset cu .
    ...
    ...    | Input Parameters | Man. | Description |
    ...    |  gnb_index  | No |  gnb index to indicate which gnb will be used, 0 in default |
    ...    |  reset_solution | Yes |  Can be rest or webui |
    ...
    ...    *RETURN VALUE*
    ...    None
    ...
    ...    Example
    ...    | CU Reset |
    ${out}   cu.reset_cu


CU Get Status
    [Arguments]     ${gnb_index}=0
    [Documentation]      Return CU status.
    ...  author:             fen.huang@nokia-sbell.com
    ...  modified by:        <19-Nov-2019>, <f2huang>, <initial created>
    ...    | Input Parameters | Man. | Description |
    ...    |  gnb_index  | No |  gnb index to indicate which gnb will be used, 0 in default |
    ...
    ...    *RETURN VALUE*
    ...    None
    ...    Example
    ...    | ${bts_status}= |  CU Get CU Status  |
   CU Login    ${gnb_index}
   ${cu_info}=  cu.get_cu_state
   [Return]   ${cu_info["operational_state"]}
   [Teardown]  run keyword and continue on failure    CU Logout

#CU Reboot VNF
#   [Arguments]    ${vm_type}  ${vm_index}=0
#   [Documentation]      Verify specified VM operationalState and availabilityStatus by vm name.
#    ...  author:             fen.huang@nokia-sbell.com
#    ...  modified by:        <19-Nov-2019>, <f2huang>, <initial created>
#    ...    | Input Parameters | Man. | Description |
#    ...    |  vm_type  | Yes |  VM name string  |
#    ...   |  vm_index  | No |  VM index, 0 in default  |
#    ...    *RETURN VALUE*
#    ...    None
#    ...    Example
#    ...    |  CU Reset VM  |   OAM  |  0  |
#    CU SSH To ${vm_type} VM
#    tafssh.execute   command=sudo reboot   connection=${vm_type}
#    sleep  3
##    CU SSH To OAM
##    ${hostname}=   Set Variable     ${vm_type}-${vm_index}.local
##    ${output}=   tafssh.execute   command=ping ${hostname} -c 5    connection=OAM
##    should contain   ${output}   Name or service not known    ${vm_type} reboots failed!

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
    ...
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
    ...
    ...    *RETURN VALUE*
    ...    [administrativeState,operationalState]
    ...    Example
    ...    |  ${cell_administrativeState}  ${cell_operationalState}= |  CU Get Specified Cell Status  |  111  |
    ...     [{“id”: “211”,
    ...   “administrativeState”: “locked”, “operationalState”: “enabled”}]
    ${alias}=   get unique id
    CU Login   ${gnb_index}   alias=${alias}
    ${cells_info}=  cu.get_cells_statuses  connection=${alias}
   FOR    ${cell_info}    IN    @{cells_info}
     ${administrative_state}=    Convert To Lowercase   ${cell_info["administrative_state"]}
     ${operational_state}=    Convert To Lowercase     ${cell_info["operational_state"]}
      Return From Keyword If    '${cell_info["id"]}' == '${cell_id}'     ${administrative_state}    ${operational_state}
   END
   [Teardown]   run keyword and ignore error    CU Logout   connection=${alias}

CU Verify Specified Cell Status Is Onair
   [Arguments]   ${cell_id}  ${gnb_index}=0
   [Documentation]      Verify cell administrative state and operational state by cell id.
    ...  author:             fen.huang@nokia-sbell.com
    ...  modified by:        <19-Nov-2019>, <f2huang>, <initial created>
    ...    | Input Parameters | Man. | Description |
    ...	   |  cell_id  | Yes |  cell id   |
    ...    |  gnb_index  | No |  gnb index to indicate which gnb will be used, 0 in default |
    ...
    ...    *RETURN VALUE*
    ...    None
    ...    Example
    ...    |  CU Verify Specified Cell Status Is Onair |   111   |
    ...     [{“id”: “211”,
    ...   “administrativeState”: “locked”, “operationalState”: “enabled”}]
    ${cell_administrativeState}  ${cell_operationalState}=    CU Get Specified Cell Status    ${cell_id}    ${gnb_index}
    run keyword and continue on failure   should be equal as strings
    ...    ${cell_administrativeState}   unlocked   Administrative state of cell ${cell_id} is not unlocked!
    run keyword and continue on failure   should be equal as strings
    ...    ${cell_operationalState}      enabled    Operational state of cell ${cell_id} is not enabled!

CU Verify All Cells Status Are Onair
    [Arguments]  ${gnb_index}=0
    [Documentation]      Check all cells operational state are operational and unlocked.
    ...  author:             fen.huang@nokia-sbell.com
    ...  modified by:        <19-Nov-2019>, <f2huang>, <initial created>
    ...    | Input Parameters | Man. | Description |
    ...    |  gnb_index  | No |  gnb index to indicate which gnb will be used, 0 in default |
    ...
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

CU Check Cells Status Should Be As Expected
    [Arguments]   ${cell_id_list}=${ALL_CELLS_ID_LIST}    ${gnb_index}=0
    ...    ${expected_administrative_state}=unlocked
    ...    ${expected_operational_state}=enabled
    [Documentation]      Check specified cell status should be as expected.
    ...  author:             fen.huang@nokia-sbell.com
    ...  modified by:        <16-Dec-2019>, <f2huang>, <initial created>
    ...    | Input Parameters | Man. | Description |
    ...	   |  cell_id_list  | No |  cell id  list, all cells id list in default   |
    ...	   |  expected_administrative_state  | Yes |  Expected administrative state for cell  |
    ...	   |  expected_operational_state  | Yes |  Expected operational state for cell |

    ...    *RETURN VALUE*
    ...    None
    ...    Example
    ...    |  CU Check Cells Status Should Be As Expected |  [1,2,3]  |   unlocked  |  enabled  |
    FOR    ${cell_id}    IN    @{cell_id_list}
        run keyword and continue on failure    CU Check Specified Cell Status Should Be As Expected
     ...    ${cell_id}   ${expected_administrative_state}   ${expected_operational_state}   ${gnb_index}
    END

CU Get Cells ID list
   [Arguments]  ${gnb_index}=0
   [Documentation]      Get all avaiable cells id list.
    ...  author:             fen.huang@nokia-sbell.com
    ...  modified by:        <19-Nov-2019>, <f2huang>, <initial created>
    ...    | Input Parameters | Man. | Description |
    ...    |  gnb_index  | No |  gnb index to indicate which gnb will be used, 0 in default |
    ...
    ...    *RETURN VALUE*
    ...    cell id list
    ...    Example
    ...    |  CU Get Cell ID list  |   |
    ${alias}=   get unique id
    CU Login  ${gnb_index}  alias=${alias}
    ${all_cells_id_list}=   create list
    ${cells_info}=  cu.get_cells_statuses  connection=${alias}
   FOR    ${cell_info}    IN    @{cells_info}
      append to list    ${all_cells_id_list}    ${cell_info["id"]}
   END
   [Return]   ${all_cells_id_list}
   [Teardown]  run keyword and ignore error    CU Logout   connection=${alias}

CU Lock Specified Cell
    [Arguments]   ${cell_id}   ${gnb_index}=0
    [Documentation]      Lock specified cell by cell id.
    ...  author:             fen.huang@nokia-sbell.com
    ...  modified by:        <16-Dec-2019>, <f2huang>, <initial created>
    ...    | Input Parameters | Man. | Description |
    ...	   |  cell_id  | Yes |  cell id   |
    ...    |  gnb_index  | No |  gnb index to indicate which gnb will be used, 0 in default |
    ...
    ...    *RETURN VALUE*
    ...    None
    ...    Example
    ...    |  CU Lock Specified Cell  |   |
	 ${alias}=    get unique id
     CU Login  ${gnb_index}  alias=${alias}
     ${cell_id_list}=    create list  ${cell_id}
     ${return_info}=   cu.lock_cells   ${cell_id_list}   connection=${alias}
     ${operation_id}=   set variable    ${return_info["id"]}
     wait until keyword succeeds  60s  5s   CU Check Operation Status For Specified Cell Should Be As Expected
     ...    ${cell_id}  lock  ${operation_id}  success
     wait until keyword succeeds  60s  5s  CU Check Specified Cell Status Should Be As Expected
     ...  ${cell_id}   locked   disabled  ${gnb_index}
    [Teardown]  run keyword and ignore error    CU Logout   connection=${alias}

CU Lock Cells
    [Arguments]   ${cell_id_list}=${ALL_CELLS_ID_LIST}  ${gnb_index}=0
    [Documentation]      Lock specified cells by cell id list and it will lock all cells in default.
    ...  author:             fen.huang@nokia-sbell.com
    ...  modified by:        <16-Dec-2019>, <f2huang>, <initial created>
    ...    | Input Parameters | Man. | Description |
    ...	   |  cell_id_list  | Yes |  Cell id list thats need to be locked |
    ...    |  gnb_index  | No |  gnb index to indicate which gnb will be used, 0 in default |
    ...    *RETURN VALUE*
    ...    None
    ...    Example
    ...    |  CU Lock Cells  |     |
     CU Login  ${gnb_index}
    FOR    ${cell_id}    IN    @{cell_id_list}
        ${return_info}=  cu.lock_cell   ${cell_id}
        ${operation_id}=   set variable    ${return_info.id}
        wait until keyword succeeds  60s  5s   CU Check Operation Status For Specified Cell Should Be As Expected
    ...      ${cell_id}  lock   ${operation_id}  completed
    END
    FOR    ${cell_id}    IN    @{cell_id_list}
    CU Check Specified Cell Status Should Be As Expected      ${cell_id}   locked  disabled
    END

CU Unock Specified Cell
    [Arguments]   ${cell_id}  ${gnb_index}=0
    [Documentation]      Unlock specified cell by cell id.
    ...  author:             fen.huang@nokia-sbell.com
    ...  modified by:        <16-Dec-2019>, <f2huang>, <initial created>
    ...    | Input Parameters | Man. | Description |
    ...	   |  cell_id  | Yes |  cell id   |
    ...    |  gnb_index  | No |  gnb index to indicate which gnb will be used, 0 in default |
    ...
    ...    *RETURN VALUE*
    ...    None
    ...    Example
    ...    |  CU Unlock Specified Cell  |   |
     ${alias}=   get unique id
     CU Login  ${gnb_index}  alias=${alias}
     ${cell_id_list}=    create list  ${cell_id}
     ${return_info}=  cu.unlock_cells   ${cell_id_list}    connection=${alias}
     ${operation_id}=   set variable    ${return_info["id"]}
     wait until keyword succeeds  60s  5s   CU Check Operation Status For Specified Cell Should Be As Expected
     ...    ${cell_id}  unlock  ${operation_id}  success
     wait until keyword succeeds  60s  5s  CU Check Specified Cell Status Should Be As Expected     ${cell_id}   unlocked   enabled
	 [Teardown]  run keyword and ignore error    CU Logout  connection=${alias}

CU Unlock Cells
    [Arguments]   ${cell_id_list}=${ALL_CELLS_ID_LIST}  ${gnb_index}=0
    [Documentation]      Unlock specified cells by cell id list and it will unlock all cells in default.
    ...  author:             fen.huang@nokia-sbell.com
    ...  modified by:        <16-Dec-2019>, <f2huang>, <initial created>
    ...    | Input Parameters | Man. | Description |
    ...	   |  cell_id_list  | Yes |  Cell id list thats need to be locked |
    ...    |  gnb_index  | No |  gnb index to indicate which gnb will be used, 0 in default |
    ...
    ...    *RETURN VALUE*
    ...    None
    ...    Example
    ...    |  CU Unlock Cells  |     |
     CU Login  ${gnb_index}
    FOR    ${cell_id}    IN    @{cell_id_list}
        ${return_info}=    cu.unock_cells  ${cell_id}
        ${operation_id}=   set variable    ${return_info.id}
        wait until keyword succeeds  60s  5s   CU Check Operation Status For Specified Cell Should Be As Expected
        ...   ${cell_id}  unlock   ${operation_id}  completed
    END
    FOR    ${cell_id}    IN    @{cell_id_list}
       CU Check Specified Cell Status Should Be As Expected    ${cell_id}   unlocked    enabled
    END

CU Check Operation Status For Specified Cell Should Be As Expected
    [Arguments]     ${operation_type}  ${operation_id}  ${expected_status}=success  ${gnb_index}=0      #${cell_id}
    [Documentation]      Check specified cell operation status should be as expected.
    ...  author:             fen.huang@nokia-sbell.com
    ...  modified by:        <16-Dec-2019>, <f2huang>, <initial created>
    ...    | Input Parameters | Man. | Description |
    ...	   |  cell_id  | Yes |  cell id   |
    ...	   |  operation_id  | Yes |  Operation id for lock operation  |
    ...	   |  operation_type  | Yes |  cell operation type, lock or unlock supported |
    ...	   |  expected_status  | Yes |  Cell opertion status, can be ongoing or success. |
    ...    |  gnb_index  | No |  gnb index to indicate which gnb will be used, 0 in default |


    ...    *RETURN VALUE*
    ...    None
    ...    Example
    ...    |  CU Check Cell Operation Status Should Be As Expected  |  123  |   lock |   12345678   | success  |
    ${alias}=  get unique id
    CU Login  ${gnb_index}   alias=${alias}
    ${operation_info}=    run keyword if   "${operation_type}"=="lock"    cu.get_operation_state_of_locking_cells
    ...    ${operation_id}   connection=${alias}
    ...  ELSE IF   "${operation_type}"=="unlock"   cu.get_operation_state_of_unlocking_cells    ${operation_id}
    ...  connection=${alias}
    ...  ELSE   Log  Operation type not supported!
    run keyword and continue on failure    should be true     "${operation_info["status"]}"=="${expected_status}"
	[Teardown]  run keyword and ignore error    CU Logout   connection=${alias}

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
    run keyword and continue on failure    should be true     "${cell_administrativeState}"=="${expected_administrative_state}"
    ...    Administrative state of cell ${cell_id} is not ${expected_administrative_state}!
    run keyword and continue on failure    should be true     "${cell_operationalState}"=="${expected_operational_state}"
    ...    Operational state of cell ${cell_id} is not ${expected_operational_state}!

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
    ...
    ...    *RETURN VALUE*
    ...    None
    ...    Example
    ...    |  CU Check DU Operation Status Should Be As Expected  |  123  |   lock |   12345678   | completed  |
    CU Login  ${gnb_index}
    ${operation_info}=    run keyword if   "${operation_type}"=="lock"    cu.get_du_lock_operation_state    ${du_id}    ${operation_id}
    ...  ELSE IF   "${operation_type}"=="unlock"   cu.get_du_unlock_operation_state    ${du_id}    ${operation_id}
    ...  ELSE   Log  Operation type not supported!
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
    ...
    ...    *RETURN VALUE*
    ...    None
    ...    Example
    ...    |  CU Verify All DUs Status Are Available  |     |
    CU Login  ${gnb_index}
    ${dus_summary}=   cu.get_du_state
    run keyword and continue on failure   should be equal as integers      ${dus_summary["f1_link_status"].unavailable}   0
    ...    Some F1 links are unavailable!
    run keyword and continue on failure   should be equal as integers      ${dus_summary["administrative_state"].locked}   0
    ...    Some dus are locked!
    [Teardown]   run keyword and ignore error   CU Logout

CU Verify All F1 Links Status Are Available
    [Arguments]   ${gnb_index}=0
    [Documentation]      Check all F1 links status should be available.
    ...  author:             fen.huang@nokia-sbell.com
    ...  modified by:        <17-Apr-2020>, <f2huang>, <initial created>
    ...  modified by:        <10-Feb-2021>, <f2huang>, <cu taf interface changed>
    ...    | Input Parameters | Man. | Description |
    ...    |  gnb_index  | No |  gnb index to indicate which gnb will be used, 0 in default |
    ...
    ...    *RETURN VALUE*
    ...    None
    ...    Example
    ...    |  CU Verify All F1 Links Status Are Available  |     |
    CU Login   ${gnb_index}
    ${dus_summary}=   cu.get_du_state
    should be equal as integers      ${dus_summary["f1_link_status"]["unavailable"]}   0
    ...    Not all F1 links are available!
    [Teardown]   run keyword and ignore error   CU Logout

CU Verify All F1 Links Status Are Unavailable
    [Arguments]   ${gnb_index}=0
    [Documentation]      Check all F1 links status should be unavailable.
    ...  author:             fen.huang@nokia-sbell.com
    ...  modified by:        <10-Jun-2020>, <f2huang>, <initial created>
    ...    | Input Parameters | Man. | Description |
    ...    |  gnb_index  | No |  gnb index to indicate which gnb will be used, 0 in default |
    ...
    ...    *RETURN VALUE*
    ...    None
    ...    Example
    ...    |  CU Verify All F1 Links Status Are Unavailable  |     |
    CU Login   ${gnb_index}
    ${dus_summary}=   cu.get_du_state
    should be equal as integers      ${dus_summary["f1_link_status"]["available"]}   0
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
    ...
    ...    *RETURN VALUE*
    ...    None
    ...    Example
    ...    | CU Check F1 Links Status Should Be As Expected  |  available  |
    CU Login  ${gnb_index}
    ${dus_info_temp}=   cu.get_dus_diff
    ${dus_info}  Set Variable  ${dus_info_temp["created"]}
    FOR   ${du}  IN  @{dus_info}
       run keyword and continue on failure    Should Be True  '${du["f1_link_status"]}'=='${expected_f1link_status}'
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
    ...
    ...    *RETURN VALUE*
    ...    None
    ...    Example
    ...    |  CU Check X2 Links Status Should Be As Expected  |  unlocked  |  available  |
    CU Login  ${gnb_index}
    ${x2_links_info}=   cu.get_x2_links_info
    ${x2_links}=  set variable  ${x2_links_info["created"]}
    FOR   ${link}  IN  @{x2_links}
       run keyword and continue on failure  should be true
    ...   '${link["x2_link_lock"]}'=='${expected_x2link_lock_status}' and '${link["x2_link_status"]}'=='${expected_x2link_status}'
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

CU Get Cells List On Specified DU
    [Arguments]          ${gnb_index}=0     #${du_id}
    [Documentation]      Return cell list on specified distributed unit.
    ...  author:             fen.huang@nokia-sbell.com
    ...  modified by:        <19-Dec-2019>, <f2huang>, <initial created>
    ...    | Input Parameters | Man. | Description |
    ...	   |  du_id  | Yes |  Distributed unit instance id  |
    ...    |  gnb_index  | No |  gnb index to indicate which gnb will be used, 0 in default |
    ...
    ...    *RETURN VALUE*
    ...    Cell ID list
    ...    Example
    ...    | CU Get Cells On Specified DU   |  1   |
    CU Login  ${gnb_index}
    ${dus_info_temp}=   cu.get_dus_diff
	${dus_info}  Set Variable  ${dus_info_temp["created"]}
    FOR   ${du}  IN  @{dus_info}
       ${cell_groups}=  run keyword if    '${du["id"]'=='${du_id}'  set variable     ${du["cell_groups"]
    END
    ${cell_list}=   create list
    FOR   ${cell_group}  IN   @{cell_groups}
       append to list    ${cell_list}    ${cell_group["cell_ids"]
    END
    [Return]  list(set( ${cell_list}))

CU Get DU Cells Map
     [Arguments]       ${gnb_index}=0
    [Documentation]      Return distributed unit/cells map.
    ...  author:             fen.huang@nokia-sbell.com
    ...  modified by:        <19-Dec-2019>, <f2huang>, <initial created>
    ...    | Input Parameters | Man. | Description |
    ...    |  gnb_index  | No |  gnb index to indicate which gnb will be used, 0 in default |
    ...

    ...    *RETURN VALUE*
    ...    Dict  du_id:cells_list
    ...    Example
    ...    |  CU Get DU Cells Map  |    |
   ${du_cell_map}=  create dictionary
   CU Login   ${gnb_index}
   ${dus_info_temp}=   cu.get_dus_diff
   ${dus_info}=  set variable  ${dus_info_temp["created"]}
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
    ...
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
    ...
    ...    *RETURN VALUE*
    ...    None
    ...
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


CU Get VM Full Name List
    [Arguments]     ${gnb_index}=0
    [Teardown]   Disconnect Interactive Connection    alias=${alias}
    [Documentation]    Return full vm name list
    ...    *AUTHOR* chris.l.cao@nokia-sbell.com
    ...    | Input Parameters | Man. | Description |
    ...    | gnb_index        | no | gnb_index, default is 0 |
    ...
    ...    *RETURN VALUE*
    ...    full vm name list
    ...
    ...    Example
    ...   | ${vm_fullname_list}   | CU Get VM Full Name List |
    ...
    ${alias}  get unique id
    CU SSH To OAM   gnb_index=${gnb_index}   alias=${alias}
    ${out}   issh.execute  command=sudo dvmcli -n    check_result=${False}   alias=${alias}
    ${out}   strip prompt  ${out}
    ${out}   convert to lowercase   ${out}

    ${full_name_list}    Split To Lines   ${out}
    [Return]  ${full_name_list}


Get FQDN Name From VM Full Name
    [Arguments]  ${vm_full_name}
    [Documentation]   Get FQDN Name From VM Full Name
    ...    *AUTHOR* chris.l.cao@nokia-sbell.com
    ...    | Input Parameters | Man. | Description |
    ...    | vm_full_name        | yes | vm_full_name, e.g, 5240-5gbts-1-cpcl-000 |
    ...
    ...    *RETURN VALUE*
    ...    FQDN name, e.g, 5240-5gbts-1-cpcl-000.local
    ...
    ...    Example
    ...   | ${vm_fqdn_name}   | Get FQDN Name From VM Full Name | 5240-5gbts-1-cpcl-000 |
    ...
    ${sufix}  Get VNF Hostname Suffix
    [Return]   ${vm_full_name}${sufix}


Get VNF Hostname Suffix
    [Documentation]   Get VNF Hostname Suffix
    ...    *AUTHOR* chris.l.cao@nokia-sbell.com
    ...    | Input Parameters | Man. | Description |
    ...    None
    ...
    ...    *RETURN VALUE*
    ...    .local
    ...
    ...    Example
    ...   | ${sufix}  | Get VNF Hostname Suffix |
    ...
    [Return]   .local


CU Get Active OAM
    [Arguments]     ${gnb_index}=0
    [Documentation]    Return host name of active oam.
    ...  author:             fen.huang@nokia-sbell.com
    ...  modified by:        <14-May-2020>, <f2huang>, <initial created>
    ...    | Input Parameters | Man. | Description |
    ...    |  gnb_index  | No |  Indicate which gnb/cu will be used, 0 in default |
    ...
    ...    *RETURN VALUE*
    ...    active oam host name
    ...
    ...    Example
    ...    | CU Get Active OAM |    |
    ${alias}=   run keyword   CU SSH To OAM   ${gnb_index}
    ${output}=  issh.execute  hostname  check_result=${False}  alias=${alias}
    ${output}=  strip String    ${output}
    ${active_host}=    Split String    ${output}    \r\n
    log to console   \n***  Active OAM : ${active_host[0]}  ***
    [Return]    ${active_host[0]}
    [Teardown]   Disconnect Interactive Connection    ${alias}


#CU Get Passive OAM
#    [Arguments]     ${active}
#    ${getvm}=    Set Variable    sudo dvmcli -n|grep OAM|grep -v ${active}
#    ssh.send command    command=${get_vm}   connection=OAM
#    ${stdout}=    ssh.read_output   connection=OAM
#    ${standbyvm}=    Split String    ${stdout}    \n
#    log to console     --- Standby OAM: ${standbyvm[0]}
#    [return]    ${standbyvm[0]}

#CU Get Online Parameter Value
#   [Arguments]   ${dn}    ${parameter_path}    ${gnb_index}=${0}
#    [Documentation]    Get online parameter via rest api.
#    ...  author:             fen.huang@nokia-sbell.com
#    ...  modified by:        <17-July-2020>, <f2huang>, <initial created>
#    ...    | Input Parameters | Man. | Description |
#    ...    |  dn   | Yes |  Distname of parameter  |
#    ...    |  parameter_path |  Yes  |  simple and simple list parameter given like btsName or nrCellList |
#    ...                              |  complex parameter given the struncture like a2MeasRedirectSsbRsrp/0/a2ThresholdRedirectSsbRsrp
#    ...
#    ...    *RETURN VALUE*
#    ...    parameter value, if it's simple or complex parameter, returns string type
#    ...    if it's a simple list type parameter, it will return a list.
#    ...
#    ...    Example
#    ...    | CU Get Online Parameter Value  |   MRBTS-5248     |   btsName  |
#    ...    | CU Get Online Parameter Value  | MRBTS-5247/NRBTS-5247/NRCELLGRP-0 | nrCellList |
#    ...    | CU Get Online Parameter Value  | MRBTS-52/NRBTS-1/NRCELL-1 | a2MeasRedirectSsbRsrp/0/a2ThresholdRedirectSsbRsrp |
#    CU Login    ${gnb_index}
#    ${expected_dn}=  set variable   ${dn.strip()}
#    ${expected_para_name}=    set variable   ${parameter_path.strip()}
#    @{para_list}  Split String  ${expected_para_name}  /
#    ${paras_info}=   cu.search_parameters_of_current_plan   parameter_name=${para_list[-1]}
#    ${value}=   get_online_parameter_value  ${paras_info}  ${expected_dn}  ${parameter_path}
#    [Return]  ${value}
#    [Teardown]   CU Logout


CU Get Online Parameter Value with gnbindex
   [Arguments]   ${dn}    ${parameter_path}  ${gnb_index}=0
    [Documentation]    Get online parameter via rest api.
    ...  author:             fen.huang@nokia-sbell.com
    ...  modified by:        <17-July-2020>, <f2huang>, <initial created>
    ...    | Input Parameters | Man. | Description |
    ...    |  dn   | Yes |  Distname of parameter  |
    ...    |  parameter_path |  Yes  |  simple and simple list parameter given like btsName or nrCellList |
    ...                              |  complex parameter given the struncture like a2MeasRedirectSsbRsrp/0/a2ThresholdRedirectSsbRsrp
    ...
    ...    *RETURN VALUE*
    ...    parameter value, if it's simple or complex parameter, returns string type
    ...    if it's a simple list type parameter, it will return a list.
    ...
    ...    Example
    ...    | CU Get Online Parameter Value  |   MRBTS-5248     |   btsName  |
    ...    | CU Get Online Parameter Value  | MRBTS-5247/NRBTS-5247/NRCELLGRP-0 | nrCellList |
    ...    | CU Get Online Parameter Value  | MRBTS-52/NRBTS-1/NRCELL-1 | a2MeasRedirectSsbRsrp/0/a2ThresholdRedirectSsbRsrp |
    CU Login   gnb_index=${gnb_index}
    ${expected_dn}=  set variable   ${dn.strip()}
    ${expected_para_name}=    set variable   ${parameter_path.strip()}
    @{para_list}  Split String  ${expected_para_name}  /
    ${paras_info}=   cu.search_parameters_of_current_plan   parameter_name=${para_list[-1]}
    ${value}=   get_online_parameter_value  ${paras_info}  ${expected_dn}  ${parameter_path}
    [Return]  ${value}
    [Teardown]   CU Logout


CU get active pod in 2N CNF
    [Arguments]  ${pod_name}  ${container}  ${alias}=default
    [Documentation]    CU get active pod in 2N CNF
    ...    *AUTHOR* nate_lee.li@nokia-sbell.com
    ...    |  Input Parameters | Man. | Description |
    ...    | pod_name          | Yes  | pod name, eg, cpif,cpcl |
    ...    | container         | Yes  | container name, e.g. oam, oamfh, nwmgmt, cprt, rcpsdl, l2rt, l2hi, l1hi |
    ...    | command           | Yes  | select the service to verify wheather it's active pod, e.g. cp_if, cp_cl, cp-nrt |
    ...    | alias             | No   | connection. Default value is default |
    ...
    ...    *RETURN VALUE*
    ...    return the number of active pod, e.g. cpif-0 or cpif-1
    ...
    ...    Example
    ...    | CU get active pod in 2N CNF |
    ...    | ${out}  | CU get active pod in 2N CNF |  pod_name=cpif  | container=cpif | command=cp_if |
    ...
    ${command}   Set Variable   ps -ef|grep logger|awk '{print $8}'
    ${pod_name_input}    Catenate  SEPARATOR=    ${pod_name}-0
    ${out}=  CU Kubectl Exec  pod_abbr=${pod_name_input}  container=${container}  command=${command}   alias=${alias}
    @{list}    Split String    ${out}
    ${get_pod_number}    run keyword if  "@{list}"=="[]"
    ...     Catenate  SEPARATOR=    ${pod_name}-1
    ...     ELSE    Catenate  SEPARATOR=    ${pod_name}-0
    [return]   ${get_pod_number}

====== End of CU keywords ======
     log to console  \n*** End of CU keywords  ***

====== VDU Start ======
     Log To Console  \n*** only used for readable ***

#vDU Special Pod Status And Container Number Should Be Expected
#    [Arguments]  ${pod_abbr}    ${status}   ${vdu_index}=0   ${alias}=${EMPTY}   ${is_check_number}=true
#    [Teardown]  run keyword and ignore error  Run Keyword If   "${alias}"=="${EMPTY}"   disconnect interactive connection  alias=${real_alias}
#    [Documentation]   vDU Special Pod Status And Container Number Should Be Expected
#    ...    *AUTHOR* chris.l.cao@nokia-sbell.com
#    ...  modified by:        <25-Mar-2020>, <huilxu>, <is_check_number added>
#    ...    |  Input Parameters | Man. | Description |
#    ...    | pod_abbr          |  Yes | pod abbreviation, eg, oamcp, up |
#    ...    | status          | yes | expected status, it is not case-sensitive, e.g, RUNNING, Running, etc. |
#    ...    | vdu_index       | No | vdu_index, default is 0 |
#    ...    | is_check_number | No | is_check_number, default is true |
#    ...
#    ...    *RETURN VALUE*
#    ...    None
#    ...
#    ...    Example
#    ...    | vDU Special Pod Status And Container Number Should Be Expected | pod_abbr=oamcp | status=Running |
#    ...    | vDU Special Pod Status And Container Number Should Be Expected | pod_abbr=up    | status=Running |
#    ...    | vDU Special Pod Status And Container Number Should Be Expected | pod_abbr=securestorage    | status=Running |
#    ...
#    ${real_alias}   Run Keyword If   "${alias}"=="${EMPTY}"   get unique id
#    ...    ELSE   Set Variable   ${alias}
#    #${master_ip}   Get VDU K8s Master Node Ip
#    #wait until keyword succeeds   30s   3s    Host Should Be Pingable  target_ip=${master_ip}
#
#    Run Keyword If   "${alias}"=="${EMPTY}"     Connect To K8s Master Interactively   vdu_index=${vdu_index}  alias=${real_alias}
#
#    ${ns}   Get vDU Namespace From TestLine
#    ${full_pod_name}   Get Full Pod Name By Pod Abbreviation Interactively   pod_abbr=${pod_abbr}   vdu_index=${vdu_index}   alias=${real_alias}
#
#    ${actual_ready}   issh.Execute  kubectl get pod ${full_pod_name} -n ${ns}|awk '{print $2}'|grep -v READY    alias=${real_alias}
#    ${actual_ready}   strip prompt  ${actual_ready}
#    ${actual_ready}   Set Variable  ${actual_ready.strip()}
#
#    ${actual_status}   issh.Execute  kubectl get pod ${full_pod_name} -n ${ns}|awk '{print $3}'|grep -v STATUS    alias=${real_alias}
#    ${actual_status}   strip prompt  ${actual_status}
#    ${actual_status}   Set Variable  ${actual_status.strip()}
#
#    ${matches}   split string  ${actual_ready}   /
#    should be true  ${matches.__len__()}==2
#    ${running_num}  set variable   ${matches[0]}
#    ${total_num}    set variable  ${matches[1]}
#    Run keyword if  "${is_check_number}"=="${True}"   should be true   ${running_num}==${total_num}
#
#    ${actual_status}   Set Variable  ${actual_status.strip()}
#    Should Be True   "${actual_status}"=="${status}"

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


vDU Get Special Pod Status
    [Arguments]  ${pod_abbr}    ${vdu_index}=0
    [Teardown]  run keyword and ignore error  disconnect interactive connection  alias=${alias}
    [Documentation]   vDU Get Special Pod Status
    ...    *AUTHOR* chris.l.cao@nokia-sbell.com
    ...    |  Input Parameters | Man. | Description |
    ...    | pod_abbr          |  Yes | pod abbreviation, eg, oamcp, up |
    ...    | vdu_index       | No | vdu_index, default is 0 |
    ...
    ...    *RETURN VALUE*
    ...    None
    ...
    ...    Example
    ...    | ${state} | vDU Get Special Pod Status | pod_abbr=oamcp |
    ...
    ${alias}  get unique id
    Connect To K8s Master Interactively   vdu_index=${vdu_index}  alias=${alias}

    ${ns}   Get vDU Namespace From TestLine
    ${full_pod_name}   Get Full Pod Name By Pod Abbreviation Interactively   pod_abbr=${pod_abbr}   vdu_index=${vdu_index}   alias=${alias}

    ${actual_status}   issh.Execute  kubectl get pod ${full_pod_name} -n ${ns}|awk '{print $3}'|grep -v STATUS    alias=${alias}
    ${actual_status}   strip prompt  ${actual_status}
    ${actual_status}   Set Variable  ${actual_status.strip()}

    [Return]  ${actual_status}


Check Whether All DUs Container Status Has Error
    [Arguments]   ${state_error_keywords}=err   ${vdu_index}=0
    [Documentation]   Check Whether All DUs Container Status Has Error
    ...    *AUTHOR* chris.l.cao@nokia-sbell.com
    ...    |  Input Parameters | Man. | Description |
    ...    | pod_abbr          |  Yes | pod abbreviation, eg, oamcp, up |
    ...    | vdu_index       | No | vdu_index, default is 0 |
    ...
    ...    *RETURN VALUE*
    ...    ${True} if has error, otherwise return ${False}
    ...
    ...    Example
    ...    | ${result} | Check Whether All DUs Container Status Has Error |
    ...
    log to console   Check Whether All DUs Container Status Has Error
    ${state_error_keywords}   set variable  ${state_error_keywords.upper()}
    ${list_state_error_keywords}   split string    ${state_error_keywords}

    ${pod_abbr_list}   set variable  ${AIC_VDU_PODS.keys()}
    FOR   ${pod_abbr}  IN  @{pod_abbr_list}
        ${state}   vDU Get Special Pod Status   pod_abbr=${pod_abbr}    vdu_index=${vdu_index}
        ${state}   set variable   ${state.upper()}
        ${r}  List Member Appears In Content    ${list_state_error_keywords}    ${state}
        run keyword if   "${r}"=="${True}"   log to console  POD(${pod_abbr}) has error(keywords:${state_error_keywords})!
        ${pod_description}   run keyword if   "${r}"=="${True}"   vDU Descript Pod   pod_abbr=${pod_abbr}   vdu_index=${vdu_index}
        run keyword if   "${r}"=="${True}"   log to console   ${pod_description}
        return from keyword if  "${r}"=="${True}"   ${True}
    END
    [Return]  ${False}


vDU Descript Pod
    [Arguments]  ${pod_abbr}    ${vdu_index}=0
    [Teardown]  run keyword and ignore error  disconnect interactive connection  alias=${alias}
    [Documentation]   vDU Descript Pod
    ...    *AUTHOR* chris.l.cao@nokia-sbell.com
    ...    |  Input Parameters | Man. | Description |
    ...    | pod_abbr          |  Yes | pod abbreviation, eg, oamcp, up |
    ...    | vdu_index       | No | vdu_index, default is 0 |
    ...
    ...    *RETURN VALUE*
    ...    None
    ...
    ...    Example
    ...    | ${state} | vDU Get Special Pod Status | pod_abbr=oamcp |
    ...
    ${alias}  get unique id
    Connect To K8s Master Interactively   vdu_index=${vdu_index}  alias=${alias}

    ${ns}   Get vDU Namespace From TestLine
    ${full_pod_name}   Get Full Pod Name By Pod Abbreviation Interactively   pod_abbr=${pod_abbr}   vdu_index=${vdu_index}   alias=${alias}

    ${out}   issh.Execute  kubectl describe pod ${full_pod_name} -n ${ns}   alias=${alias}

    [Return]  ${out}


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
    ${alias}=  get unique id
    vDU Rest Login   vdu_index=${vdu_index}   gnb_index=${gnb_index}  alias=${alias}
    ${vdu_cells_summary}=  vdu.get_vdu_cells_summary  vdu_connection=${alias}
    Should Be Equal As Numbers  ${vdu_cells_summary['basic_cells_summary']['operational_state']['disabled']}  0
    Should Be Equal As Numbers  ${vdu_cells_summary['basic_cells_summary']['administrative_state']['locked']}  0
    Should Be Equal As Numbers  ${vdu_cells_summary['basic_cells_summary']['administrative_state']['shutting_down']}  0
    ${on_line}   set variable   ${vdu_cells_summary['availability_status']['on_line']}
    should be true  ${on_line}==${expected_cell_number}
    #should be true  ${on_line}>=1

    [Teardown]  vdu.disconnect   ${alias}


vDU Verify All Cells Status Should Be Onair
    [Arguments]  ${vdu_index}=0     ${gnb_index}=0
    [Documentation]    Check the number of cells which are in ubnormal status should be 0.
    ...    the keyword only support rest api v2.
    ...    the checked status are operational_state--disabled
    ...                           administrative_state--locked
    ...                           administrative_state--shutting_down
    ...    history change: <date>,<who>,<what and how>
    ...    Initialized by calla.wang@nokia-sbell.com,add support container.
    ...    26.11.2020, chris.l.cao@nokia-sbell.com,add check for ${on_line}>=1
    ...    7.6.2021, chris.l.cao@nokia-sbell.com, exactly check all cells are on-air
    ...
    ...    | Input Parameters | Man. | Description |
    ...    | vdu_index | Yes. |specify which vdu needs to be check if the testline configed multi vdus |
    ...    *RETURN VALUE*
    ...    None
    ...    Example
    ...    |  vDU Verify All Cells Status Should Be Onair  | 0 |

    #${cell_number}   Get VCU Cell Number From TestLine    gnb_index=${gnb_index}
    ${cell_number}   vdu_oam_cm.Get VDU Cell Number From SCF    gnb_index=${gnb_index}

    vDU Verify Cells Status Should Be Onair With Expected Cell Number    gnb_index=${gnb_index}    vdu_index=${vdu_index}
     ...   expected_cell_number=${cell_number}


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
       vDU Verify All Cells Status Should Be Onair    vdu_index=${i}   gnb_index=${gnb_index}
    END


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
   # [Teardown]  vDU Logout


vDU Get Specified Cell Status
   [Arguments]   ${cell_id}    ${vdu_index}=0
   [Documentation]      Get cell administrative state and operational state  by cell id.
    ...  author:             calla.wang@nokia-sbell.com
    ...    | Input Parameters | Man. | Description |
    ...	   |  cell_id  | Yes |  cell id   |
    ...    | vdu_index | Yes. |specify which vdu needs to be check if the testline configed multi vdus |
    ...    *RETURN VALUE*
    ...    [administrativeState,operationalState]
    ...    Example
    ...    |  ${cell_administrativeState}  ${cell_operationalState}= |  CU Get Specified Cell Status  |  111  |
    ...     [{"id": "211",
    ...   "administrativeState": "locked", "operationalState": "enabled"}]
    vDU Rest Login    vdu_index=${vdu_index}
    ${cells_info}=  vdu.get_vdu_cells_status
   FOR    ${cell_info}    IN    @{cells_info}
     ${administrative_state}=    Convert To Lowercase   ${cell_info["administrative_state"]}
     ${operational_state}=    Convert To Lowercase     ${cell_info["operational_state"]}
      Return From Keyword If    '${cell_info["id"]}' == '${cell_id}'     ${administrative_state}    ${operational_state}
   END
   [Teardown]   vDU Logout

vDU Verify Specified Cell Status Is Onair
   [Arguments]   ${cell_id}   ${vdu_index}=0
   [Documentation]    Verify cell administrative state and operational state should be normal by cell id.
    ...    author:  calla.wang@nokia-sbell.com
    ...    | Input Parameters | Man. | Description |
    ...	   |  cell_id  | Yes |  cell id   |
    ...    | vdu_index | Yes. |specify which vdu needs to be check if the testline configed multi vdus |
    ...    *RETURN VALUE*
    ...    None
    ...    Example
    ...    |  CU Verify Specified Cell Status Is Onair |   111   |
    ...     [{"id": "211",
    ...   "administrativeState": "locked", "operationalState": "enabled"}]
    ${cell_administrativeState}  ${cell_operationalState}=   vDU Get Specified Cell Status   ${cell_id}  ${vdu_index}
    run keyword and continue on failure   should be equal as strings
    ...    ${cell_administrativeState}   unlocked   Administrative state of cell ${cell_id} is not unlocked!
    run keyword and continue on failure   should be equal as strings
    ...    ${cell_operationalState}      enabled    Operational state of cell ${cell_id} is not enabled!

vDU Check Specified Cell Status Should Be As Expected
    [Arguments]     ${cell_id}   ${expected_administrative_state}=unlocked
    ...    ${expected_operational_state}=enabled    ${vdu_index}=0
    [Documentation]      Check specified cell status should be as expected.
    ...  author:  calla.wang@nokia-sbell.com
    ...    | Input Parameters | Man. | Description |
    ...	   |  cell_id  | Yes |  cell id   |
    ...	   |  expected_administrative_state  | Yes |  Expected administrative state for cell  |
    ...	   |  expected_operational_state  | Yes |  Expected operational state for cell |
    ...    | vdu_index | Yes. |specify which vdu needs to be check if the testline configed multi vdus |

    ...    *RETURN VALUE*
    ...    None
    ...    Example
    ...    | vDU Check Cell Status Should Be As Expected  |  123  |   locked  |  disabled  | 0 |
    ${cell_administrativeState}  ${cell_operationalState}=    vDU Get Specified Cell Status   ${cell_id}  ${vdu_index}
    run keyword and continue on failure    should be true     "${cell_administrativeState}"=="${expected_administrative_state}"
    ...    Administrative state of cell ${cell_id} is not ${expected_administrative_state}!
    run keyword and continue on failure    should be true     "${cell_operationalState}"=="${expected_operational_state}"
    ...    Operational state of cell ${cell_id} is not ${expected_operational_state}!

Should be Multiple Cell
    [Documentation]      Should be Multiple Cell
    ...  author:  winnie.su@nokia-sbell.com
    ...    it will check cell numbers
    ...    2021-3-17 first version
    ...    Example
    ...    | Should be Multiple Cell  |
    log to console    check If cell is multiple cells
    VDU Rest Login
    ${scf_path}  Get A Directory  scf
    ${scf_file_with_fullpath}   vdu.Get_Current_Plan_File  local_dir_path=${scf_path}  filename=scf.xml  include_runtime_data=${False}
    scf.Load_Scf  file_path=${scf_file_with_fullpath}
    ${cell_id_list}    Get CELL ID List From vDU SCF    scf_path=${scf_file_with_fullpath}
    should be true   ${cell_id_list.__len__()>1}


Get CELL ID List From vDU SCF
    [Arguments]  ${scf_path}
    [Documentation]      Get CELL ID List From vDU SCF
    ...  author:  winnie.su@nokia-sbell.com
    ...    it will check cell numbers
    ...    2021-3-17 first version
    ...    Example
    ...   |  ${cell_id_list}  | Get CELL ID List From vDU SCF  |  scf_path |  ${scf_file_with_fullpath}  |
    ${scf_content}   OperatingSystem.Get File   ${scf_path}
    ${result}     Get Regexp Matches    ${scf_content}   .*MRBTS-(\\d+)/NRBTS-(\\d+)/NRCELL-(\\d+)"   1  2  3
    log to console    ${result}
    @{cell_list}   Evaluate    [i[2] for i in @{result}]
    log to console    @{cell_list}
    [Return]   @{cell_list}


VDU Lock Cell By REST
    [Documentation]    VDU Ulock Cell By REST
    ...    the keyword only unlock cell.
    ...    author:  wei.7.chen@nokia-sbell.com
    ...    2021-7-16 first version
    ...    *RETURN VALUE*
    ...    None
    ...    Example
    ...    |  VDU Lock Cell By REST  |
    vDU Rest Login
    ${scf_path}  Get A Directory  scf
    ${scf_file_with_fullpath}   vdu.Get_Current_Plan_File  local_dir_path=${scf_path}  filename=scf.xml  include_runtime_data=${False}
    scf.Load_Scf  file_path=${scf_file_with_fullpath}
    ${cell_id}    Get CELL ID From vDU SCF    scf_path=${scf_file_with_fullpath}
    ${all_BTS_ID}    Get BTS ID From vDU SCF    scf_path=${scf_file_with_fullpath}
    set test variable    ${MRBTS_ID}    ${all_BTS_ID[0]}
    set test variable    ${cell_id}
    Log To Console  ${cell_id}
    ${list_cell_id}   create list  ${cell_id[0]}
    vdu.lock_cells     ${list_cell_id}
    sleep   60s


VDU Ulock Cell By REST
    [Documentation]    VDU Ulock Cell By REST
    ...    the keyword only unlock cell.
    ...    author:  wei.7.chen@nokia-sbell.com
    ...    2021-7-16 first version
    ...    *RETURN VALUE*
    ...    None
    ...    Example
    ...    |  VDU Ulock Cell By REST  |
    vDU Rest Login
    ${scf_path}  Get A Directory  scf
    ${scf_file_with_fullpath}   vdu.Get_Current_Plan_File  local_dir_path=${scf_path}  filename=scf.xml  include_runtime_data=${False}
    scf.Load_Scf  file_path=${scf_file_with_fullpath}
    ${cell_id}    Get CELL ID From vDU SCF    scf_path=${scf_file_with_fullpath}
    ${all_BTS_ID}    Get BTS ID From vDU SCF    scf_path=${scf_file_with_fullpath}
    set test variable    ${MRBTS_ID}    ${all_BTS_ID[0]}
    set test variable    ${cell_id}
    Log To Console  ${cell_id}
    ${list_cell_id}   create list  ${cell_id[0]}
    vdu.unlock_cells     ${list_cell_id}
    wait until keyword succeeds    10min    60s     OAM Precondition Cell Should Be Onair


====== RU Start ======
     Log To Console  \n*** only used for readable ***

Wait For RU Operational State Is Enabled
    [Arguments]  ${detection_time}=400
    [Documentation]   Wait For RU Operational State Is Enabled
    ...    author: chris.l.cao@nokia-sbell.com
    ...    | Input Parameters | Man. | Description |
    ...    | detection_time  | no | detection_time, default is 120s |
    ...
    ...    *RETURN VALUE*
    ...    None
    ...
    ...    Example
    ...    | Wait For RU Operational State Is Enabled |
    wait until keyword succeeds   ${detection_time}   10s   _Wait For RU Operational State Is Enabled Check Once


_Wait For RU Operational State Is Enabled Check Once
    ${operational_state}    Get RU Operational State via REST
    log to console   operational_state:${operational_state}
    should be true  "${operational_state}"=="enabled"


Should Have Power On All RUs
    [Documentation]   Check there is power on all RUs (include TDD and FDD)defined in init config.
    ...    author: fen.huang@nokia-sbell.com
    ...    modified by:  lingting.sun@nokia-sbell.com  <16-09-2021>, <lingtsun>, <Add TDD RF check>
    ...    | Input Parameters | Man. | Description |
    ...
    ...    *RETURN VALUE*
    ...    None
    ...
    ...    Example
    ...    |  Should Have Power On All RUs  |
    ${rf_type}=    Get RF Type From Testline
    ${quantity_of_cu}   get length   ${tl.gnbs}
    log to console    Check power on ${rf_type} RF
    FOR  ${gnb_index}   IN RANGE    ${quantity_of_cu}
        run keyword if    '${rf_type}'=='TDD'   Should Have Power On TDD RUs Under Specified CU  ${gnb_index}
    ...  ELSE    Should Have Power On RUs Under Specified CU  ${gnb_index}
    END


Should Have Power On RUs Under Specified CU
   [Arguments]   ${gnb_index}
   [Documentation]   Check there is power on all RUs under to a specified CU.
    ...    author: fen.huang@nokia-sbell.com
    ...    | Input Parameters | Man. | Description |
    ...    | gnb_index  | no |  gnb index  |
    ...
    ...    *RETURN VALUE*
    ...    None
    ...
    ...    Example
    ...    |  Should Have Power On RUs Under Specified CU  |
    ${quantity_of_vdu_for_specified_cu}=   Get vDU Number    gnb_index=${gnb_index}
    FOR   ${vdu_index}   IN RANGE   ${quantity_of_vdu_for_specified_cu}
        Should Have Power On RUs Under Specified CU And VDU    ${gnb_index}     ${vdu_index}
    END

Should Have Power On RUs Under Specified CU And VDU
   [Arguments]    ${gnb_index}   ${vdu_index}
   [Documentation]   Check there is power on all RUs Under to a specified CU/vDU.
    ...    author: fen.huang@nokia-sbell.com
    ...    | Input Parameters | Man. | Description |
    ...    | gnb_index  | no |  gnb index  |
    ...    | vdu_index  | no |  vdu index  |
    ...
    ...    *RETURN VALUE*
    ...    None
    ...
    ...    Example
    ...    |  Should Have Power On RUs Under Specified CU And VDU   |
   ${quantity_of_fhgw_for_specified_vdu}   get length   ${tl.gnbs[${gnb_index}].dus[${vdu_index}].fhgws}
    FOR   ${fhgw_index}   IN RANGE   ${quantity_of_fhgw_for_specified_vdu}
        Should Have Power On RUs Under Specified CU And VDU And FHGW     ${gnb_index}   ${vdu_index}   ${fhgw_index}
    END

Should Have Power On RUs Under Specified CU And VDU And FHGW
   [Arguments]    ${gnb_index}   ${vdu_index}   ${fhgw_index}
   [Documentation]   Check there is power on all RUs Under to a specified CU/vDU/FHGW.
    ...    author: fen.huang@nokia-sbell.com
    ...    | Input Parameters | Man. | Description |
    ...    |  gnb_index   | no |  gnb index  |
    ...    |  vdu_index   | no |  vdu index  |
    ...    |  fhgw_index  | no |  fhgw index  |
    ...
    ...    *RETURN VALUE*
    ...    None
    ...
    ...    Example
    ...    |  Should Have Power On RUs Under Specified CU And VDU And FHGW  |
   ${quantity_of_rus_for_specified_fhgw}=   get length    ${tl.gnbs[${gnb_index}].dus[${vdu_index}].fhgws[${fhgw_index}].rus}
   FOR   ${ru_index}   IN RANGE   1   ${quantity_of_rus_for_specified_fhgw}+1
       ${alias}=  get unique id
       ${alias}=   Connect to Radio Unit    ${alias}   ${ru_index}   timeout=60
       ${AHBCCresult}=  issh.execute   command=xzcat /run/startup_DEFAULT.log.xz |grep AHBCC   alias=${alias}      check_result=${False}
       ${port0}   set variable if   'AHBCC' in '''${AHBCCresult}'''   2   0
       ${port1}   set variable if   'AHBCC' in '''${AHBCCresult}'''   3   1
       ${result_0}=  issh.execute   command=/usr/bin/dapd -pwr ${port0}  check_result=${False}   alias=${alias}
       ${result_1}=  issh.execute   command=/usr/bin/dapd -pwr ${port1}  check_result=${False}   alias=${alias}
       Log To Console   RU Power result_0:${result_0}
       Log To Console   RU Power result_1:${result_1}
       ${matched_0}=  get regexp matches   ${result_0}   TX=(\(-?\\d+\)\(\\.\\d+).*FB=\(-?\\d+\)\(\\.\\d+\))
       ${matched_1}=  get regexp matches   ${result_1}   TX=(\(-?\\d+\)\(\\.\\d+).*FB=\(-?\\d+\)\(\\.\\d+\))
       ${len_0}=  get length   ${matched_0}
       ${len_1}=  get length   ${matched_1}
       run keyword and continue on failure      Should be true    ${len_0}>=1
   ...   No power detected on cu${gnb_index}_vdu${vdu_index}_fhgw${fhgw_index}_ru${ru_index}:/usr/bin/dapd -pwr 0
       run keyword and continue on failure      Should be true    ${len_1}>=1
   ...   No power detected on cu${gnb_index}_vdu${vdu_index}_fhgw${fhgw_index}_ru${ru_index}:/usr/bin/dapd -pwr 1
       Disconnect Interactive Connection    ${alias}
    END


Should Have Power On TDD RUs Under Specified CU
   [Arguments]   ${gnb_index}
   [Documentation]   Check there is power on all TDD RUs under to a specified CU.
    ...    author: lingting.sun@nokia-sbell.com
    ...    | Input Parameters | Man. | Description |
    ...    | gnb_index  | no |  gnb index  |
    ...
    ...    *RETURN VALUE*
    ...    None
    ...
    ...    Example
    ...    |  Should Have Power On TDD RUs Under Specified CU |
    ${quantity_of_vdu_for_specified_cu}=   Get vDU Number    gnb_index=${gnb_index}
    FOR   ${vdu_index}   IN RANGE   ${quantity_of_vdu_for_specified_cu}
        _Should Have Power On TDD RUs Under Specified CU And VDU   ${gnb_index}     ${vdu_index}
    END


_Should Have Power On TDD RUs Under Specified CU And VDU
   [Arguments]    ${vdu_index}=0    ${gnb_index}=0
   [Documentation]   Check there is power on all TDD RUs Under to a specified CU/vDU
    ...    author: lingting.sun@nokia-sbell.com
    ...    | Input Parameters | Man. | Description |
    ...    |  gnb_index   | no |  gnb index  |
    ...    |  vdu_index   | no |  vdu index  |
    ...
    ...    *RETURN VALUE*
    ...    None
    ...
    ...    Example
    ...    |  _Should Have Power On TDD RUs Under Specified CU And VDU |
    ${RF_ip_list}    create list
    ${alias}  get unique id
    Connect To K8s Master Interactively  vdu_index=${vdu_index}  alias=${alias}
    ${oamfh_container}     Get Full Container Name By Container Abbreviation  ctr_abbr=oamfh  vdu_index=${vdu_index}
    set test variable    ${oamfh_container}
    ${power_check_ns}  Get vDU Namespace From TestLine   vdu_index=${vdu_index}
    set test variable    ${power_check_ns}
    ${oam_pod_full_name}   Get Full Pod Name By Container Abbreviation Interactively    oamfh
    ...   vdu_index=${vdu_index}    gnb_index=${gnb_index}
    set test variable    ${oam_pod_full_name}
    ${cmd}    Catenate    SEPARATOR=   kubectl exec -n ${power_check_ns} ${oam_pod_full_name} -c ${oamfh_container} -- b
    ...  ash -c "{ echo \\"aasyscomgw -r\\";sleep 1;echo \\"quit\\"; } | telnet 0 15067;" | grep UDPCP | grep 192.168.25
    ...  4 |awk '{print $7}'
    ${output}=   issh.execute   command=${cmd}   check_result=False    alias=${alias}
    ${pattern}  set variable    ((2(5[0-5]|[0-4]\\d))|[0-1]?\\d{1,2})(\\.((2(5[0-5]|[0-4]\\d))|[0-1]?\\d{1,2})){3}
    ${RF_ip_list}=   Get Regexp Matches    ${output}   ${pattern}
    Should Not Be Empty    ${RF_ip_list}    Can't get RF ip, pls check the env or check the command is still in use
    ${password}  set variable    bobuWrUHk7Xq7WPpY9ZcjEi8zNdX3plZ+/y420RZ7W4=
    FOR    ${RF_ip}    IN    @{RF_ip_list}
        _RF check power TDD     RF_ip=${RF_ip}   alias=${alias}   password=${password}  vdu_index=${vdu_index}
    END


Get RF Type From Testline
   [Documentation]   get the rf type from testline, tl.tl_cloud_topology
    ...    author: lingting.sun@nokia-sbell.com
    ...
    ...    *RETURN VALUE*
    ...    TDD or FDD
    ...
    ...    Example
    ...    |  Get RF Type From Testline |
    log    ${tl.tl_cloud_topology}
    ${matches_tdd_rf}=    Get Regexp Matches    ${tl.tl_cloud_topology}    AEQP|AEQY|AEQE|AZQI|AZQJ
    ${length}=   get length    ${matches_tdd_rf}
    ${rf_type}=   run keyword if   ${length} > 0   set variable   TDD
    ...   ELSE   set variable     FDD
    [return]    ${rf_type}


_RF Check Power TDD
    [Arguments]    ${RF_ip}    ${alias}   ${password}   ${vdu_index}
    FOR    ${i}    IN RANGE    0    8
       _RF Check Power On Specific Att TDD    RF_ip=${RF_ip}   index=${i}   alias=${alias}
    ...    password=${password}  vdu_index=${vdu_index}
    END


_RF Check Power On Specific Att TDD
    [Arguments]    ${RF_ip}    ${index}    ${alias}   ${password}   ${vdu_index}
    ${cmd}    Catenate    SEPARATOR=  kubectl exec -it -n ${power_check_ns} ${oam_pod_full_name} -c ${oamfh_container} -
    ...  - ssh serviceuser@${RF_ip} -o StrictHostKeyChecking=no -- ssh root@192.168.101.2 -- "dapd -pwr ${index};"
    ${old_prompt}  issh.set prompt   assword:    alias=${alias}
    ${output}=   issh.execute   command=${cmd}    check_result=False    alias=${alias}
    issh.set prompt    ${old_prompt}   alias=${alias}
    ${power}=   run keyword if   "assword:" in """${output}"""   issh.Execute
    ...   command=${password}   check_result=False    alias=${alias}

    Log To Console   RU Power result:${power}

    ${matched}=  get regexp matches   ${power}   TX=(\(-?\\d+\)\(\\.\\d+).*FB=\(-?\\d+\)\(\\.\\d+\))
    ${len}=  get length   ${matched}
    run keyword and continue on failure      Should be true    ${len}>=1
    ...   No power detected on vdu${vdu_index}_ru_${RF_ip}+att_${index}


Reset RUs By REST
    [Arguments]   ${rmods_list}   ${vdu_index}=0   ${gnb_index}=0
    [Documentation]   Reset RUs by rmod id list.
    ...   *AUTHOR* fen.huang@nokia-sbell.com
    ...   | Input Parameters    | Man. | Description |
    ...   None
    ...
    ...   *RETURN VALUE*
    ...
    ...
    ...   Example
    ...  | vdu rest login |
    ...  |  Reset RUs By REST  |
    ...
    log to console   Reset RUs ${rmods_list} by REST...
    vdu login  vdu_index=${vdu_index}    gnb_index=${gnb_index}
    ${out}   vdu.reset_rmods     ${rmods_list}
    Reset RUs Operation Should Be Successful   operation_id=${out["operation_id"]}
    [Teardown]  vdu logout

Reset RUs Operation Should Be Successful
    [Arguments]  ${operation_id}
    [Documentation]   Reset RUs operation should Be successful
    ...   *AUTHOR* fen.huang@nokia-sbell.com
    ...   | Input Parameters    | Man. | Description |
    ...   |  operation_id    | yes |  operation_id  |
    ...
    ...   *RETURN VALUE*
    ...    None
    ...
    ...   Example
    ...  | vdu rest login |
    ...  |  Reset RUs Operation Should Be Successful  | operation_id=1 |
    ...
    Wait Until Keyword Succeeds  60   3   _Reset RUs Status Should Be Expected   operation_id=${operation_id}    expected_status=ongoing


_Reset RUs Status Should Be Expected
    [Arguments]  ${operation_id}   ${expected_status}
    ${out}   vdu.get_reset_rmods_operation_status   operation_id=${operation_id}
    Should Be True  "${out["status"]}"=="${expected_status}"

Reset VNF ON CU
    [Arguments]  ${vm_type}   ${gnb_index}=0
    [Documentation]   ssh to vnf oam and reset it
    ...    author: jie.8.liu@nokia-sbell.com
    ...    | Input Parameters | Man. | Description |
    ...    |  vm_type   | no | OAM-000/OAM-001  |
    ...    |  gnb_index  | no |  cbts number 0/1/...  |
    ...
    ...    *RETURN VALUE*
    ...    NO
    ...
    ...    Example
    ...    |  ssh to OAM-000.local ,and use command:dvmcli -r cluster  restart it  |
    ${cmd} =  set variable   ssh ${vm_type}.local
    ${random}=    Evaluate    random.randint(0, 300)    random
    log to console   ${random}
    sleep    ${random}s
    ${alias}  get unique id
    ${oam_conn}=    CU SSH To OAM   gnb_index=${gnb_index}   alias=${alias}
    ${out}   issh.execute  command=${cmd}      check_result=${False}   alias=${alias}
    log to console     ${out}
    ${out}   issh.execute  command=dvmcli -r cluster    check_result=${False}   alias=${alias}
    log to console     ${out}

Set SWM password
    [Arguments]    ${password}    ${gnb_index}=0
    [Documentation]   ssh to vnf and change the password
    ...    author: jie.8.liu@nokia-sbell.com
    ...    | Input Parameters | Man. | Description |
    ...    |  password   | no | Nokia@123 |
    ...    |  gnb_index  | no |  cbts number 0/1/...  |
    ...
    ...    *RETURN VALUE*
    ...    NO
    ...
    ...    Example
    ...    |  ssh to VNF change the password to Nokia@123, otherwise CBAM replace will failed  |
    ${cmd} =  set variable   set user-management passwd set-user-passwd user-name _nokrcpswmmanage
    ${alias}  get unique id
    ${oam_conn}=    CU SSH To OAM   gnb_index=${gnb_index}   alias=${alias}
    issh.set prompt     >    alias=${alias}
    ${out}   issh.execute  command=fsclish   check_result=${False}   alias=${alias}
    log to console    ${out}
    issh.set prompt     password:     alias=${alias}
    ${out}   issh.execute  command=${cmd}   check_result=${False}   alias=${alias}
    log to console    ${out}
    ${out}   issh.execute  command=${password}     check_result=${False}   alias=${alias}
    log to console    ${out}
    issh.set prompt     Password updated successfully     alias=${alias}
    ${out}   issh.execute  command=${password}     check_result=${False}   alias=${alias}
    Should contain  ${out}  successfully

    [Return]  ${out}
