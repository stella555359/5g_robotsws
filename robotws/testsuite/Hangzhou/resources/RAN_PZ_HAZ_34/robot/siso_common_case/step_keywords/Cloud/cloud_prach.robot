*** Settings ***
Library           taf.rfrl.cbts.utilities.generic_utils
Library           taf.rfrl.cbts.connections.rest_conn_vdu.GenericVDU    WITH NAME    vdu_gen
Resource          taf/rfrl/cbts/robot/vdu/vdu_cm.robot
Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/siso_common_case/step_keywords/Cloud/cloud_vdu.robot
Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/siso_common_case/step_keywords/Cloud/cloud_throughput.robot

*** Variables ***


*** Keywords ***
Get Modify Prach Cell List
    [Arguments]  ${cell_list}    ${gnb_index}=0    ${vdu_index}=0
    [Documentation]    This keyword is designed to get a list of cell IDs for a given technology type.
    ...    - [Keyword Details]
    ...    This keyword accepts the cell list, vDU index, and gNB index as arguments.
    ...    It then iterates over the list of cell IDs and checks the technology type of each cell.
    ...    If the technology type of the cell is 'tdd', it adds the cell ID to the new list.
    ...    It returns a new list of cell IDs with 'tdd' technology type.
    ...
    ...    | =Input Parameters= | =Mandatory= | =Description= |
    ...    | cell_list | Yes | The list of all cell IDs. |
    ...    | vdu_index | No | The vDU index. Default is 0. |
    ...    | gnb_index | No | The gNB index. Default is 0. |
    ...
    ...    | =Return Values= | =Description= |
    ...    | modify_prach_cell_list | The list of cell IDs with 'tdd' technology type. |

    ...    *******************
    ...    History of changes
    ...    ******************
    ...    - 21.06.2024 - - Created
    ...    *******************
    ...    * Owner: shifu.lan@nokia-sbell.com
    ...    * Group: VRF_HAZ4_04
    ...    *******************
    ${modify_prach_cell_list}    create list
    FOR    ${cell_id}    IN    @{cell_list}
        ${technology}    vDU Get Cell Technology    cell_index=${cell_id}    gnb_index=${gnb_index}    vdu_index=${vdu_index}
        run keyword if    '${technology.lower()}'=='tdd'  Append To List    ${modify_prach_cell_list}    ${cell_id}
    END
    [Return]  ${modify_prach_cell_list}

Modify Prach Index Via Webem
    [Arguments]  ${cell_list}    ${prach_index}    ${gnb_index}=${0}    ${vdu_index}=${0}
    [Documentation]    This keyword is designed to modify the PRACH index for a given cell ID via Webem.
    ...    - [Keyword Details]
    ...    This keyword accepts the cell list, PRACH index, vDU index, and gNB index as arguments.
    ...    It then generates a delta data list and uses it to update the PRACH configuration index for each cell in the cell list.
    ...    It then checks the status of each RMOD and resets it if necessary.
    ...    Finally, it ensures that all cells are on air.
    ...
    ...    | =Input Parameters= | =Mandatory= | =Description= |
    ...    | cell_list | Yes | The list of all cell IDs. |
    ...    | prach_index | Yes | The PRACH index to be updated. |
    ...    | gnb_index | No | The gNB index. Default is 0. |
    ...    | vdu_index | No | The vDU index. Default is 0. |

    ...    *******************
    ...    History of changes
    ...    ******************
    ...    - 21.06.2024 - - Created
    ...    *******************
    ...    * Owner: shifu.lan@nokia-sbell.com
    ...    * Group: VRF_HAZ4_04
    ...    *******************
    ${delta_data_list}    create list
    FOR    ${cell_id}    IN    @{cell_list}
        ${prach_delta_data_list}=  generic_utils.construct_delta_data_for_delta_commissioning
        ...  mo_dn=MRBTS-${mrbtsID}/NRBTS-${nrbtsID}/NRCELL-${cell_id}
        ...  operation_type=replace
        ...  prachConfigurationIndex=${prach_index}
        Append To List    ${delta_data_list}    ${prach_delta_data_list}
    END
    Fast Delta Commission With Delta Data List    delta_data_list=${delta_data_list}    gnb_index=${gnb_index}    vdu_index=${vdu_index}
    sleep  5
    ${ru_index_list}    create list
    FOR    ${cell_id}    IN    @{cell_list}
        ${ru_index}    Get Rmod Id Mapping Cell    cell_id=${cell_id}    gnb_index=${gnb_index}    vdu_index=${vdu_index}
        ${status}    run keyword and return status    should not contain    ${ru_index_list}    ${ru_index}
        run keyword if    ${status}    Append To List    ${ru_index_list}    ${ru_index}
    END
    FOR  ${ru_index}  IN  @{ru_index_list}
        ${rmod_id_list}    Create List    ${ru_index}
        ${ru_status}    run keyword and return status    RMOD Status Should Be As Expected    rmods_id_list=${rmod_id_list}
        ...    gnb_index=${gnb_index}    vdu_index=${vdu_index}    operational_state=enabled
        ...    availability_status=on line    administrative_state=Unlocked    procedural_status=configured
        Run Keyword If    not ${ru_status}    Reset Rmod By Rest    rmods_list=${rmod_id_list}    gnb_index=${gnb_index}    vdu_index=${vdu_index}
        Run Keyword If    not ${ru_status}    Sleep    180
    END
    Wait Until Keyword Succeeds    15min    5s    All Cells Should Be Onair For All vDUs
