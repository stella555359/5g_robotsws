*** Settings ***
Resource  testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/siso_common_case/step_keywords/Cloud/cloud_vdu.robot
Library           taf.rfrl.cbts.utilities.generic_utils
Resource  taf/rfrl/cbts/robot/vdu/vdu_cm.robot


*** Keywords ***
Cloud Modify 5GC000430 Status
    [Arguments]    ${actMicroDTXAdvanced}=false  ${actMicroDTX}=false
    [Documentation]    *****************
    ...    This keyword is designed to modify the status of 5GC000430.
    ...    - [Keyword Details]
    ...    It constructs the delta data for delta commissioning and creates a list of all delta data.
    ...    It performs a fast delta commission with the delta data list.
    ...    It waits until all cells are on air for all vDUs.
    ...
    ...    | =Input Parameters= | =Mandatory= | =Description= |
    ...    | actMicroDTX | Yes | The actMicroDTX status. |
    ...    | actMicroDTXAdvanced | Yes | The actMicroDTXAdvanced status. |
    ...
    ...    | =Return Values= | =Description= |
    ...    | None | This keyword does not return any value. |

    ...    *******************
    ...    History of changes
    ...    ******************
    ...    - 30.05.2024 - - Created
    ...    *******************
    ...    * Owner: kaihui.fan@nokia-sbell.com
    ...    * Group: VRF_HAZ4_04
    ...    *******************

    log to console
    ...   start set 5GC000430 actMicroDTX:${actMicroDTX},actMicroDTXAdvanced:${actMicroDTXAdvanced}
    ${actMicroDTX_delta_data}=  generic_utils.construct_delta_data_for_delta_commissioning
    ...  mo_dn=MRBTS-${mrbtsID}/NRBTS-${nrbtsID}
    ...  operation_type=update
    ...  actMicroDTX=${actMicroDTX}   actMicroDTXAdvanced=${actMicroDTXAdvanced}
    ${all_delta_data_list}=  create list   ${actMicroDTX_delta_data}
    vdu_cm.Fast Delta Commission With Delta Data List   ${all_delta_data_list}
    Wait Until Keyword Succeeds    15min    5s    All Cells Should Be Onair For All vDUs

Cloud Modify Single Paramter Online
    [Documentation]    *****************
    ...    This keyword is used to modify a single parameter online.
    ...    - [Keyword Details]
    ...    It performs a fast delta commission with the constructed delta data.
    ...    It waits until all cells are on air for all vDUs.
    ...
    ...    | =Input Parameters= | =Mandatory= | =Description= |
    ...    | mo_dn | Yes | The managed object distinguished name. |
    ...    | param_name | Yes | The name of the parameter to be modified. |
    ...    | param_value | Yes | The new value of the parameter. |
    ...    | operation_type | No | The operation type for delta commissioning. Default is 'update'. |
    ...
    ...    | =Return Values= | =Description= |
    ...    | None | This keyword does not return any value. |

    ...    *******************
    ...    History of changes
    ...    ******************
    ...    - 11.06.2024 - - Created
    ...    *******************
    ...    * Owner: kaihui.fan@nokia-sbell.com
    ...    * Group: VRF_HAZ4_04
    ...    *******************
    [Arguments]  ${mo_dn}  ${param_name}  ${param_value}  ${operation_type}=update
    ${actPowerMeter_delta_data}=  generic_utils.construct_delta_data_for_delta_commissioning
    ...  mo_dn=${mo_dn}
    ...  operation_type=${operation_type}
    ...  ${param_name}=${param_value}
    ${all_delta_data_list}=  create list   ${actPowerMeter_delta_data}
    vdu_cm.Fast Delta Commission With Delta Data List   ${all_delta_data_list}
    log to console   \nCloud Modify Single Paramter Online: ${param_name}=${param_value} completed.
    Wait Until Keyword Succeeds    15min    5s    All Cells Should Be Onair For All vDUs