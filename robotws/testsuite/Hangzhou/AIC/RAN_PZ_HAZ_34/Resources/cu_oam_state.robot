*** Settings ***
Documentation
...   author: xianbiao.cheng@nokia-sbell.com
...   contact: xianbiao.cheng@nokia-sbell.com
...   cu_oam_state.robot




*** Variables ***



*** Keywords ***
CU Oam Service Should Be Ready
    [Arguments]  ${gnb_index}=0
    [Documentation]   CU Oam Service Should Be Ready
    ...   *AUTHOR* chris.l.cao@nokia-sbell.com
    ...
    ...   | Input Parameters    | Man. | Description |
    ...   None
    ...
    ...   *RETURN VALUE*
    ...
    ...
    ...   Example
    ...  | CU Oam Service Should Be Ready |
    ...
    CU Rest Login   gnb_index=${gnb_index}


Reset CU By REST
    [Arguments]  ${need_check_on_air}=${False}   ${alias}=${None}   ${wait}=900
    [Documentation]   Reset CU By REST
    ...   *AUTHOR* chris.l.cao@nokia-sbell.com
    ...    history change: <date>,<who>,<what and how>
    ...  2.1.2021, chris.l.cao@nokia-sbell.com, initialization
    ...  14.1.2022, chris.l.cao@nokia-sbell.com, add alias parameter
    ...
    ...   | Input Parameters    | Man. | Description |
    ...   | need_check_on_air    | No | need_check_on_air, default is ${False} |
    ...   | alias               | No | alias, default is ${None} |
    ...
    ...   *RETURN VALUE*
    ...
    ...
    ...   Example
    ...  | CU rest login |
    ...  | Reset CU By REST |
    ...  | Reset CU By REST | need_check_on_air=${True} |
    ...  | Reset CU By REST | need_check_on_air=${True} | alias=myalias |
    ...
    log to console  Reset CU By REST...
    ${out}  cu.reset_cu  connection=${alias}
    ${error_msg}   set variable  ${out["error_message"]}
    Should Be True   """${error_msg}"""=="""${None}"""

    Run Keyword If    ${need_check_on_air}   Log To Console   Wait CU OAM down->up->on-air ...
    Run Keyword If    ${need_check_on_air}   Sleep   180
    Run Keyword If    ${need_check_on_air}   Wait Until Keyword Succeeds  1200   20s   CU Oam Service Should Be Ready
    Run Keyword If    ${need_check_on_air}   Log To Console   OAM is up.
    Run Keyword If    ${need_check_on_air}   Wait Until Keyword Succeeds  ${wait}  30s   OAM Precondition Cell Should Be Onair
    Run Keyword If    ${need_check_on_air}   Log To Console   OAM is on-air.



CU Verify All VMs Are Online
   [Arguments]    ${gnb_index}=0
   [Documentation]      Verify all VMs status should be online and enabled.
    ...    *Author*:        fen.huang@nokia-sbell.com
    ...    *Change History*
    ...    | date | who | what or how |
    ...    | 26-5-2022 | r3li | replace call method |
    ...    | 29-4-2020 | f2huang | initial created |
    ...    *Arguments Description*
    ...    | Input Parameters | Man. | Description |
    ...    | gnb_index | No |  gnb index to indicate which gnb will be used, 0 in default |
    ...
    ...    *RETURN VALUE*
    ...    None
    ...    *Example*
    ...    | CU Verify All VMs Are Online | 0 |
     CU Rest Login    ${gnb_index}
     ${vm_info}=   cu.get_vnfcs_states
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


CU Verify All Cells Status Are Onair
    [Arguments]  ${gnb_index}=0
    [Documentation]      Check all cells operational state are operational and unlocked.
    ...  author:             fen.huang@nokia-sbell.com
    ...  modified by:
    ...    | date | who | what or how |
    ...    | 19-Nov-2019 | f2huang | initial created |
    ...    | 07-Nov-2022 | r3li | add enable check |
    ...   | 2023-7-5 | r3li | correct error for CU Rest Login changed |
    ...
    ...    | Input Parameters | Man. | Description |
    ...    |  gnb_index  | No |  gnb index to indicate which gnb will be used, 0 in default |
    ...
    ...    *RETURN VALUE*
    ...    None
    ...    Example
    ...    |  CU Verify All Cells Status Are Onair  |     |
    ${cell_numbers}    Get VCU Cell Number From SCF   gnb_index=${gnb_index}
    ${alias}   CU Rest Login  ${gnb_index}
    ${cells_summary}=   cu.get_cells_summary   connection=${alias}
    run keyword and continue on failure  should be equal as integers
    ...    ${cells_summary["basic_cells_summary"]["administrative_state"]["shutting_down"]}   0   Some cells are shutting down!
    run keyword and continue on failure  should be equal as integers
    ...    ${cells_summary["basic_cells_summary"]["administrative_state"]["locked"]}   0   Some cells are locked!
    run keyword and continue on failure  should be equal as integers
    ...    ${cells_summary["basic_cells_summary"]["operational_state"]["disabled"]}    0   Some cells are disabled!
    run keyword and continue on failure  should be equal as integers
    ...    ${cells_summary["basic_cells_summary"]["operational_state"]["enabled"]}    ${cell_numbers}   Some cells are disabled!
    [Teardown]   run keyword and ignore error   CU Rest Logout   connection=${alias}   gnb_index=${gnb_index}


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
    ...    history change: <date>,<who>,<what and how>
    ...   unknown,fen.huang@nokia-sbell.com, initialization
    ...   14.1.2022,chris.l.cao@nokia-sbell.com, remove alias
    ...
    ...  modified by:        <19-Nov-2019>, <f2huang>, <initial created>
    ...    | Input Parameters | Man. | Description |
    ...    |  gnb_index  | No |  gnb index to indicate which gnb will be used, 0 in default |
    ...
    ...    *RETURN VALUE*
    ...    cell id list
    ...    Example
    ...    |  CU Get Cell ID list  |   |
   # ${alias}=   get unique id
    #CU Login  ${gnb_index}  alias=${alias}
    CU Rest Login  gnb_index=${gnb_index}
    ${all_cells_id_list}=   create list
#    ${cells_info}=  cu.get_cells_statuses  connection=${alias}
    ${cells_info}=  cu.get_cells_statuses
    FOR    ${cell_info}    IN    @{cells_info}
        append to list    ${all_cells_id_list}    ${cell_info["id"]}
    END
   [Return]   ${all_cells_id_list}
  # [Teardown]  run keyword and ignore error    CU Logout   connection=${alias}


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


CU Check Operation Status For Specified Cell Should Be As Expected
    [Arguments]   ${cell_id}  ${operation_type}  ${operation_id}  ${expected_status}=success  ${gnb_index}=0
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


CU Verify All DUs Status Are Available
    [Arguments]   ${gnb_index}=0
    [Documentation]      Check all dus status should be available and unlocked.
    ...    *Author*: fen.huang@nokia-sbell.com
    ...    *Change History*
    ...    | who | date | how and what |
    ...    | f2huang | 2020-4-27 | initial created |
    ...    | r3li | 2022-3-31 | Resolve the error that get status from dus_summary |
    ...    *Arguments Description*
    ...    | Input Parameters | Man. | Description |
    ...    | gnb_index | No | gnb index to indicate which gnb will be used, 0 in default |
    ...
    ...    *RETURN VALUE*
    ...    None
    ...    *Example*
    ...    | CU Verify All DUs Status Are Available | 0 |
    CU Login  ${gnb_index}
    ${dus_summary}=   cu.get_du_state
    run keyword and continue on failure   should be equal as integers      ${dus_summary}[f1_link_status][unavailable]  0
    ...    Some F1 links are unavailable!
    run keyword and continue on failure   should be equal as integers      ${dus_summary}[administrative_state][locked]   0
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


#CU Get Active Pod Name
#    [Arguments]  ${pod_name}  ${container}  ${alias}=default
#    [Documentation]    CU Get Active Pod Name
#    ...    *AUTHOR* nate_lee.li@nokia-sbell.com
#    ...    |  Input Parameters | Man. | Description |
#    ...    | pod_name          | Yes  | pod name, eg, cpif,cpcl |
#    ...    | container         | Yes  | container name, e.g. oam, oamfh, nwmgmt, cprt, rcpsdl, l2rt, l2hi, l1hi |
#    ...    | command           | Yes  | select the service to verify wheather it's active pod, e.g. cp_if, cp_cl, cp-nrt |
#    ...    | alias             | No   | connection. Default value is default |
#    ...
#    ...    *RETURN VALUE*
#    ...    return the number of active pod, e.g. cpif-0 or cpif-1
#    ...
#    ...    Example
#    ...    | CU Get Active Pod Name |
#    ...    | ${out}  | CU Get Active Pod Name |  pod_name=cpif  | container=cpif | command=cp_if |
#    ...
#    ${command}   Set Variable   ps -ef|grep logger|awk '{print $8}'
#    ${pod_name_input}    Catenate  SEPARATOR=    ${pod_name}-0
#    ${out}=  CU Kubectl Exec  pod_abbr=${pod_name_input}  container=${container}  command=${command}   alias=${alias}
#    @{list}    Split String    ${out}
#    ${get_pod_number}    run keyword if  "@{list}"=="[]"
#    ...     Catenate  SEPARATOR=    ${pod_name}-1
#    ...     ELSE    Catenate  SEPARATOR=    ${pod_name}-0
#    [return]   ${get_pod_number}


Add Georedundancy User
    [Arguments]  ${user_name}=georesiliency  ${user_password}=Nokia123!  ${new_password}=Nokia123!
    ...   ${gnb_index}=0
    [Documentation]   ssh to vnf oam and reset it
    ...    author: shouxiang.jiao@nokia-sbell.com
    ...    | Input Parameters | Man. | Description |
    ...    |  user_name   | no | georesiliency  |
    ...    |  user_password  | no |  Nokia123!  |
    ...    |  connection  | yes | connection |
    ...    *RETURN VALUE*
    ...    the status of adding the user
    ...
    ...    Example
    ...    |  Add Georedundancy User  | georesiliency | Nokia123! | ${connection}=${EMPTY}
    CU Login    ${gnb_index}
    &{result}=  cu.update_service_account_password   username=${user_name}  password=${user_password}
    ...  new_password=${new_password}
    log to console  ${result}
    Should Be True  'Success'=='${result['content']}'
    CU Logout   ${gnb_index}

_Get CU Info
    [Arguments]  ${gnb_index}=0
    [Documentation]   ssh to vnf oam and reset it
    ...    author: shouxiang.jiao@nokia-sbell.com
    ...    | Input Parameters | Man. | Description |
    ...    |  gnb_index  | no | defalut_vale is 0 |
    ...    *RETURN VALUE*
    ...    Will Return A dict like {"activityMode":"standby","alarms":[],
    ...    "peerVnf":{"ipAddress":"10.107.92.5","peerVnf":"5222",
    ...    "status":"correct"},"redundancyRole":"secondary"}
    ...    For Getting "ipAddress"       Using the "Get Peer OAM IP"
    ...    For Getting "status"          Using the "Get CU Status"
    ...    For Getting "activityMode"    Using the "Get CU ActiveMode"
    ...    For Getting "redundancyRole"  Using the "Get CU Redundancy Role"
    ...    Example
    ...    |  _Get CU Info | gnb_index=0
    log to console  Start Getting CU ${gnb_index} Info
    ${alias}   CU Login  gnb_index=${gnb_index}
    ${result}=  get_cu_vnf   connection=${alias}
    [Return]  ${result}
    [Teardown]  CU Logout  connection=${alias}

Get CU Status
    [Arguments]  ${gnb_index}=0
    [Documentation]   ssh to vnf oam and reset it
    ...    author: shouxiang.jiao@nokia-sbell.com
    ...    | Input Parameters | Man. | Description |
    ...    |  gnb_index  | no | defalut_vale is 0 |
    ...    *RETURN VALUE*
    ...    Will Return the CU Redundancy Connection Status
    ...    |  Get CU Status | gnb_index=0
    log to console  Start Getting Peer CU ${gnb_index} Connection Status
    ${result}=  _Get CU Info   ${gnb_index}
    log to console  Current CU ${gnb_index} Connection Status Is ${result['peer_vnf']['status']}
    [Return]  ${result['peer_vnf']['status']}

Get CU ActiveMode
    [Arguments]  ${gnb_index}=0
    [Documentation]   ssh to vnf oam and reset it
    ...    author: shouxiang.jiao@nokia-sbell.com
    ...    | Input Parameters | Man. | Description |
    ...    |  gnb_index  | no | defalut_vale is 0 |
    ...    *RETURN VALUE*
    ...    Will Return the CU ActiveMode
    ...    |  Get CU ActiveMode | gnb_index=0
    log to console  Start Getting Peer CU ${gnb_index} Connection ActiveMode
    ${result}=  _Get CU Info   ${gnb_index}
    log to console  Current CU ${gnb_index} ActiveMode Is ${result['activity_mode']}
    [Return]  ${result['activity_mode']}

_Active VNF Should Be Successful
    [Arguments]   ${operation_id}  ${status}=success
    [Documentation]   _Active VNF Should Be Successful
    ...  author: luofei.tug@nokia-sbell.com
    ...    | Input Parameters | Man. | Description |
    ...    | operation_id | yes | Generating Cu active action id|
    ...    *RETURN VALUE*  None
    ...    Example
    ...    | _Active VNF Should Be Successful | operation_id=xxx |
   ${res}   cu.get_activate_cu_vnf_status    ${operation_id}
   should be equal as strings  ${res['status']}  ${status}

CU Switchover
   [Arguments]   ${operation}=unforce  ${gnb_index0}=0  ${gnb_index1}=1
   [Documentation]  Create rest session to CU.
    ...    author: shouxiang.jiao@nokia-sbell.com
    ...    | Input Parameters | Man. | Description |
    ...    | gnb_index0 | no | defalut_vale is 0|
    ...    | gnb_index1 | no | defalut_vale is 1|
    ...    | operation | no | defalut_vale is unforce|
    ...    *RETURN VALUE*  None
    ...    Example
    ...    | CU Switchover | gnb_index0=x | gnb_index1=x | operation=xxx
    ${cu_active_mode}=  Get CU ActiveMode  gnb_index=${gnb_index0}
    ${gnb_standby}=  run keyword if  '${cu_active_mode}'=='standby'  Set Variable
    ...  ${gnb_index0}  ELSE  Set Variable  ${gnb_index1}
    ${gnb_active}=  run keyword if  '${gnb_standby}'=='${gnb_index0}'  Set Variable
    ...  ${gnb_index1}  ELSE  Set Variable  ${gnb_index0}
    Check Redundancy Ready
    run keyword if  '${operation}'=='force'  _Forced Switchover  ${gnb_standby}  ${gnb_active}
    ...  ELSE  _Unforced Switchover  ${gnb_standby}  ${gnb_active}

_Forced Switchover
    [Arguments]  ${gnb_index0}=0  ${gnb_index1}=1
    [Documentation]  Create rest session to CU.
    ...    author: shouxiang.jiao@nokia-sbell.com
    ...    | Input Parameters | Man. | Description |
    ...    | gnb_index0 | no | defalut_vale is 0|
    ...    | gnb_index1 | no | defalut_vale is 1|
    ...    *RETURN VALUE*  None
    ...    Example
    ...    | _Forced Switchover | gnb_index0=x | gnb_index1=x
    CU Login  gnb_index=${gnb_index0}
    log to console  Start Forced Active CU ON Standby CU  ${gnb_index0}
    ${id}=  cu.forcefully_activate_cu_vnf
    run keyword and continue on failure   Wait until keyword succeeds  3x  60s
    ...  _active vnf should be successful    ${id}[id]
    run keyword and continue on failure   Wait until keyword succeeds  5x  3m
    ...  Check Redundancy Ready
    log to console  Forced Switchover Is OK , Now Active CU Is CU ${gnb_index0}
    [Teardown]  run keyword and ignore error  CU Logout

_Unforced Switchover
    [Arguments]   ${gnb_index0}=0  ${gnb_index1}=1  ${expect_status}=ongoing
    [Documentation]  Create rest session to CU.
    ...    author: shouxiang.jiao@nokia-sbell.com
    ...    | Input Parameters | Man. | Description |
    ...    | gnb_index0 | no | defalut_vale is 0|
    ...    | gnb_index1 | no | defalut_vale is 1|
    ...    *RETURN VALUE*  None
    ...    Example
    ...    | _Unforced Switchover | gnb_index0=x | gnb_index1=x
    CU Login  gnb_index=${gnb_index0}
    log to console  Start Unforced Active CU On Standby CU ${gnb_index0}
    ${id1}=  cu.activate_cu_vnf
    run keyword and continue on failure   Wait until keyword succeeds  3x  60s
    ...  _Active VNF Should Be Successful    ${id1}[id]
    CU Logout
    log to console  Trigger The CU ${gnb_index0} Change TO Active
    # CU Login  gnb_index=${gnb_index1}
    # ${id2}=  cu.deactivate_cu_vnf
    # run keyword and continue on failure   Wait until keyword succeeds  3x  60s
    # ...  _Deactive VNF Should Be Successful    ${id2}[id]
    # CU Logout
    # log to console  Trigger The CU ${gnb_index1} Change TO Deactive
    sleep  3m
    run keyword and continue on failure   Wait until keyword succeeds  5x  3m
    ...  Check Redundancy Ready
    log to console  Unforced Switchover Is OK , Now Active CU Is CU ${gnb_index0}

Check Redundancy Ready
    [Arguments]     ${gnb_index0}=0    ${gnb_index1}=1
    ${status1}=  Get CU Status  ${gnb_index0}
    log to console  Current CU ${gnb_index0} Status Is ${status1}
    ${status2}=  Get CU Status  ${gnb_index1}
    log to console  Current CU ${gnb_index1} Status Is ${status2}
    Should Be True  '${status1}'=='correct'
    Should Be True  '${status2}'=='correct'


Swtich Active To Master Node
    [Documentation]  Swtich Active To Master Node
    ...    author: shouxiang.jiao@nokia-sbell.com
    ...    this keyword help change CU role to the master node
    ...    | Input Parameters | Man. | Description |
    ...    None
    ...
    ...    *RETURN VALUE*
    ...    None
    ...
    ...    Example
    ...    | IP Spec Switch |
    ...
    ${active_gnb}=  Get Active GNB ID
    run keyword if  ${active_gnb}==0  log to console  currently CU 0 is active node
    ...  CU Switchover

CU Get Active Pod Name By Specified Pod
    [Arguments]    ${pod_abbr}    ${gnb_index}=0   ${use_m2m}=${True}
    [Documentation]    Get Pod Full Name By Vnfcs States
    ...    *Author* rui.3.li@nokia-sbell.com
    ...    *Change HisTory*
    ...    | date | who | how or what |
    ...    | 2022-4-24 | r3li | new |
    ...    | 2022-5-10 | r3li | fix string including error of pod name. |
    ...    *Arguments Description*
    ...    | Input Parameters | Man. | Description |
    ...    | pod_abbr | Yes | pod abbreviatory name |
    ...    | gnb_index | No | gnb index to indicate which gnb will be used |
    ...    *Example*
    ...    | CU Get Active Pod Name By Specified Pod | cpcl | 0 |
    ...    *Return*
    ...    - full pod name
    CU Rest Login    gnb_index=${gnb_index}
    ${vnfcs_states}    cu.Get vnfcs states   use_m2m=${use_m2m}
    FOR    ${info}     IN     @{vnfcs_states}
         Continue For Loop If    "${info}[name]"=="${EMPTY}"
         Continue For Loop If    '${info}[name]'=='${None}'
         ${flag_1}    Set Variable If   '${pod_abbr}' in '''${info}[name]'''    ${1}    ${0}
         ${flag_2}    Set Variable If   '${info}[role]'=='active'   ${1}    ${0}
         ${flag}    Evaluate     ${flag_1}+${flag_2}
         ${full_pod_name}    Set Variable If    '${flag}'=='${2}'    ${info}[name]
         Exit For Loop If    '${flag}'=='${2}'
    END
    [Return]    ${full_pod_name}
    [Teardown]    CU Rest Logout

CU Get Standby Pod Name By Specified Pod
    [Arguments]    ${pod_abbr}    ${gnb_index}=0   ${use_m2m}=${True}
    [Documentation]    Get Pod Full Name By Vnfcs States
    ...    *Author* rui.3.li@nokia-sbell.com
    ...    *Change HisTory*
    ...    | date | who | how or what |
    ...    | 2022-4-24 | r3li | new |
    ...    | 2022-5-10 | r3li | fix string including error of pod name. |
    ...    *Arguments Description*
    ...    | Input Parameters | Man. | Description |
    ...    | pod_abbr | Yes | pod abbreviatory name |
    ...    | gnb_index | No | gnb index to indicate which gnb will be used |
    ...    *Example*
    ...    | CU Get Active Pod Name By Specified Pod | cpcl | 0 |
    ...    *Return*
    ...    - full pod name
    CU Rest Login    gnb_index=${gnb_index}
    ${vnfcs_states}    cu.Get vnfcs states   use_m2m=${use_m2m}
    FOR    ${info}     IN     @{vnfcs_states}
         Continue For Loop If    "${info}[name]"=="${EMPTY}"
         Continue For Loop If    '${info}[name]'=='${None}'
         ${flag_1}    Set Variable If   '${pod_abbr}' in '''${info}[name]'''    ${1}    ${0}
         ${flag_2}    Set Variable If   '${info}[role]'=='standby'   ${1}    ${0}
         ${flag}    Evaluate     ${flag_1}+${flag_2}
         ${full_pod_name}    Set Variable If    '${flag}'=='${2}'    ${info}[name]
         Exit For Loop If    '${flag}'=='${2}'
    END
    [Return]    ${full_pod_name}
    [Teardown]    CU Rest Logout

Get CU Specified Interface IP
    [Arguments]    ${interface_name}    ${plane_type}=${None}    ${ip_type}=${None}    ${gnb_index}=0
    [Documentation]    Get Interface Ip From Cu State
    ...    *Author* rui.3.li@nokia-sbell.com
    ...    *Change HisTory*
    ...    | date | who | how or what |
    ...    | 2022-5-7 | r3li@nokia-sbell.com | new |
    ...    | 2022-6-9 | chris.l.cao@nokia-sbell.com | remove 'CU Rest Logout' while exiting KW |
    ...    | 2022-6-9 | chris.l.cao@nokia-sbell.com | change layout of description to improve readibility in RFDoc |
    ...
    ...    *Arguments Description*
    ...    | Input Parameters | Man. | Description |
    ...    | interface_name | Yes | interface name, f1_interface, m_plane_ip_address, ng_interface, vnf_ip_address, x2_interface or xn_interface |
    ...    | plane_type | No | plane_type, c_plane_ip_address or u_plane_ip_address, default ${None} means to return all info about interface |
    ...    | ip_type | No | ip type, v4, v6 or ${None}, default ${None} will return all info about this interface and plane type |
    ...    | gnb_index | No | gnb index to indicate which gnb will be used, default is 0 |
    ...
    ...    *Example*
    ...    | ${ip_info} | Get CU Specified Interface IP | interface_name=f1_interface | plane_type=c_plane_ip_address | ip_type=v4 |
    ...    | #${ip_info} is a list, like ['1.1.1.1', '2.2.2.2'] |
    ...
    ...    | ${ip_info} | Get CU Specified Interface IP | interface_name=f1_interface | plane_type=c_plane_ip_address |
    ...    | #${ip_info} is a list, like [{'v4': '10.107.90.147', 'v6': None}] |
    ...
    ...    | ${ip_info} | Get CU Specified Interface IP | interface_name=f1_interface |
    ...    | #${ip_info} is a dictionary, like {'c_plane_ip_address': [{'v4': '10.107.90.147', 'v6': None}],
    ...                               'u_plane_ip_address': [{'v4': '10.107.90.112', 'v6': None}]} |
    ...    *Return*
    ...    - interface ip info
    ...
    ${all_interface_name}   create list    f1_interface    m_plane_ip_address    ng_interface    vnf_ip_address
    ...    x2_interface     xn_interface
    List Should Contain Value    ${all_interface_name}    ${interface_name}    interface name should in ${all_interface_name}
    ${all_plane_name}    create list   c_plane_ip_address    u_plane_ip_address    ${None}
    List Should Contain Value    ${all_plane_name}     ${plane_type}    plane type should in ${all_plane_name}
    ${all_ip_type}    create list   v4    v6    ${None}
    List Should Contain Value    ${all_ip_type}     ${ip_type}    plane type should in ${all_ip_type}

    CU Rest Login    gnb_index=${gnb_index}
    ${cu_state_info}    cu.get_cu_state

    ${key_path}    Set Variable If    '${plane_type}'!='${None}'     ip_addresses.${interface_name}.${plane_type}
    ...    ip_addresses.${interface_name}
    ${result}    get_info_from_multiple_dictionary     ${cu_state_info}   ${key_path}
    Return From Keyword If    '${plane_type}'=='${None}'    ${result}
    Return From Keyword If    '${ip_type}'=='${None}'    ${result}

    ${ip_list}    Create List
    FOR    ${re}    IN    @{result}
        ${ip_address}    Set variable    ${re}[${ip_type}]
        Append To List     ${ip_list}     ${ip_address}
    END
    [Return]    ${ip_list}
#    [Teardown]    CU Rest Logout

start amf ip connectivity test
    [Arguments]  ${gnb_index}=0
    ${ngcip}  ${amf_ip}    CU Get AMF And NGC IP  gnb_index=${gnb_index}
	${namespace}=    Get CU Namespace From Testline  gnb_index=${gnb_index}
    ${cpif_act_pod}=  CU Get Active Pod Name   pod_name=cpif  container=cpif
    ${alias}  Get Unique Id
    ${alias}  CU Login    gnb_index=${gnb_index}  alias=${alias}
	${operation_id}     cu.start_ip_connectivity_test
	...                 destination_ip=${amf_ip}
	...                 payload_size=16
	...                 dscp=10
	...                 source_ip=${ngcip}
	...                 source_interface_name=CPIF_po-${namespace}-${cpif_act_pod}_bhc_NG-C
    ...                 connection=${alias}
    [Return]   ${operation_id}
    [Teardown]  run keyword and ignore error  CU Logout


CU Get AMF And NGC IP
   [Arguments]  ${gnb_index}=0
    ${alias}  Get Unique Id
    ${alias}  CU Login    gnb_index=${gnb_index}  alias=${alias}
	${out}   cu.get_cu_state   connection=${alias}
	${ngcip}     set variable    ${out['ip_addresses']['ng_interface']['c_plane_ip_address'][0]['v4']}
	${amf_ip}    set variable    ${out['amfs'][0]['ip_address']}
	[Return]   ${ngcip}  ${amf_ip}
	[Teardown]  run keyword and ignore error  CU Logout   connection=${alias}


check ping result should be successful
     [Arguments]  ${operation_id}  ${gnb_index}=0
    ${alias}  Get Unique Id
    ${alias}  CU Login    gnb_index=${gnb_index}  alias=${alias}
    ${ping_result}      cu.get_ip_connectivity_test_result   operation_id=${operation_id}   connection=${alias}
	should be equal as strings    ${ping_result}[status]    Successful
	[Teardown]  run keyword and ignore error  CU Logout   connection=${alias}


vCU Pods Should Be Start Up In Parallel
    [Arguments]  ${pod_abbr}   ${gnb_index}=0
    [Documentation]    vCU Pods Should Be Start Up In Parallel
    ...    *Author* lingting.sun@nokia-sbell.com
    ...    *Change HisTory*
    ...    | date | who | how or what |
    ...    | 2023-4-28 | lingting.sun@nokia-sbell.com | new |
    ...
    ...    *Arguments Description*
    ...    | Input Parameters | Man. | Description |
    ...    | pod_abbr  | YES | pod name abbr, such as upue |
    ...    | gnb_index | No | gnb index to indicate which gnb will be used, default is 0 |
    ...
    ...    *Example*
    ...    | vCU Pods Should Be Start Up In Parallel | pod_name=upue  |

    ...    *Return*
    ...
    ${vcu_pod_info_dict}   vCU Get Pod Info   gnb_index=${gnb_index}   pod_abbr=${pod_abbr}
    ${vcu_pod_info_list}   Get Dictionary Values  ${vcu_pod_info_dict}
    ${pod_length}   Get Length    ${vcu_pod_info_list}
    Should Be True   '${pod_length}'>'1'  msg=Only ${pod_length} ${pod_abbr} pod founded in this environment
    ${pod_age_list}  create list
    FOR  ${vcu_pod_info}  IN  @{vcu_pod_info_list}
        ${age}    Convert Time    ${vcu_pod_info['age']}
        append to list  ${pod_age_list}  ${age}
    END
    ${pod_age_list}  Remove Duplicates   ${pod_age_list}
    ${length}  Get Length  ${pod_age_list}
    Should Be True   '${length}'=='1'  msg=${pod_abbr} pods did not start up in parallel, the age list is ${pod_age_list}
