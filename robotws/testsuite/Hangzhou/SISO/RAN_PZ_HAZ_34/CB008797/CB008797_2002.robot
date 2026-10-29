# # # @Time    : 2022/2/18 13:47
# # # @Author  : Jian.1.Chen
# # # @Email   : jian.1.chen@nokia-sbell.com
# # # @File    : CB008797_2002.robot
# # # @Software: PyCharm
# # # @Doc     : Some Description
# # *** Settings ***
# # Documentation
# # ...    author: Chen Jian
# # ...    contact: jian.1.chen@nokia-sbell.com
# # ...    squad group: 5G_PZ_MMW_HZ_3_SG05
# # ...    Feature CB008797-SR-B-B32
# # 
# # Resource    CB008797_keywords.robot
# # Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/robot_common_operations/interface.robot
# # 
# # Suite Setup          Run Keywords    robot_common_operations.Common Suite Setup
# # ...    AND     SISO Coam Suite Setup
# # Suite Teardown       Run Keywords    robot_common_operations.Common Suite Teardown
# # ...    AND     SISO Coam Suite Teardown
# # Test Setup           robot_common_operations.Common Case Setup 
# # Test Teardown        robot_common_operations.Common Case Teardown
# # Force Tags        5G_SISO    5G_RAN_TDD    CRT_TRUNK    CRT_22R3    CRT_22R4
# # 
# # *** Variables ***
# # ${if_commissioning}    True
# # # case109 variables
# # ${UL_TP}    50M
# # ${UL_TP_THRESHOLD}  20
# # ${DL_TP}    300M
# # ${DL_TP_THRESHOLD}  20
# # &{ADD_CELL_INFO}    global_cell_id=5
# # ...                 lcrId=5
# # ...                 nrarfcn=632666
# # ...                 gscnOrSsPbchArfcn=1
# # ...                 physCellId=47
# # ...                 type0CoresetConfigurationIndex=10
# # ...                 cell_id_to_copy_from=4
# # @{DELETE_CELLS}    3    5
# # @{L3_CALL_CELLS}    5
# # 
# # *** Test Cases ***
# # CB008797_B_109_NSA_SA_TDD_cmw_eCPRI_ASIK_dual_core_Basic_operability
# #     [Tags]    case109
# #     # Step1: delete cells
# #     FOR    ${global_cell_id}    IN    @{DELETE_CELLS}
# #         Delete One Cell Via Webem    global_cell_id=${global_cell_id}
# #     END
# #     Wait Until Keyword Succeeds    3min    10s    Verify BTS Status Is "OnAir"
# # 
# #     # Step2: Perform L3 call
# #     ${cell_list}    Get All Cell Id
# #     FOR    ${global_cell_id}    IN    @{cell_list}
# #         Enable BTS Single NR Cell For SA Call    nr_cell_id=${global_cell_id}
# #         UE Attach And Check Throughput With Detach    global_cell_id=${global_cell_id}
# #         ...    ul_tp=${UL_TP}    ul_tp_threshold=${UL_TP_THRESHOLD}
# #         ...    dl_tp=${DL_TP}    dl_tp_threshold=${DL_TP_THRESHOLD}    attach_mode=SA    iperf_type=via_app
# #     END
# # 
# #     # Step3: Add cell
# #     Unlock BTS All 5G Cells
# #     Add One Cell Via Webem    cell_info=${ADD_CELL_INFO}
# #     Wait Until Keyword Succeeds    10min    10s    Verify BTS Status Is "OnAir"
# # 
# #     # Step4: Perform L3 call on add cell
# #     FOR    ${global_cell_id}    IN    @{L3_CALL_CELLS}
# #         Enable BTS Single NR Cell For SA Call    nr_cell_id=${global_cell_id}
# #         UE Attach And Check Throughput With Detach    global_cell_id=${global_cell_id}
# #         ...    ul_tp=${UL_TP}    ul_tp_threshold=${UL_TP_THRESHOLD}
# #         ...    dl_tp=${DL_TP}    dl_tp_threshold=${DL_TP_THRESHOLD}    attach_mode=SA    iperf_type=via_app
# #     END
# #     Unlock BTS All 5G Cells
# # 
# #     "last step" Check content of Radio Unit logs in snapshot
# # 
# # CB008797_B_110_NSA_SA_TDD_cmw_eCPRI_ASIK_dual_core_SFP_RF_monitoring
# #     [Tags]    case110
# #     Connect to gnb coam via ssl
# #     General_SiSo_Link_Diagnostic_and_Monitoring
# #     Run Keyword And Ignore Error    COAM Teardown gnb connections
# # 
# # *** Keywords ***
# # Delete One Cell Via Webem
# #     [Arguments]    ${global_cell_id}
# #     Connect to gnb coam via ssl
# #     Selenium Login With Version
# #     selenium_coam.remove_object    object_name=MRBTS-${MRBTS_ID}/NRBTS-${NRBTS_ID}/NRCELL-${global_cell_id}
# #     selenium_coam.remove_object    object_name=MRBTS-${MRBTS_ID}/MNL-1/MNLENT-1/CELLMAPPING-1/LCELNR-${global_cell_id}
# #     ${cellgrp_id}    Get Cell Group From Cell    cell_id=${global_cell_id}
# #     ${cell_list}    Get All Cell Id
# #     ${group_cell_list}    Get Cell From Cell Group    ${cellgrp_id}
# #     ${group_cell_length}    Get Length    ${group_cell_list}
# #     ${global_cell_id_int}    Convert To Integer    ${global_cell_id}
# #     ${nrdu_node_index}    Get Index From List    ${cell_list}    ${global_cell_id_int}
# #     Run Keyword If    ${group_cell_length}==1
# #     ...    selenium_coam.remove_object    object_name=MRBTS-${MRBTS_ID}/NRBTS-${NRBTS_ID}/NRCELLGRP-${cellgrp_id}
# #     selenium_coam.remove_element   dist_name=MRBTS-${MRBTS_ID}/NRBTS-${NRBTS_ID}/NRDU-1
# #     ...    filter_param=Reference to cell group    node_index=${nrdu_node_index}    abbr=refNrCellGroup
# #     Run Keyword If    ${group_cell_length}>1    selenium_coam.remove_element
# #     ...    dist_name=MRBTS-${MRBTS_ID}/NRBTS-${NRBTS_ID}/NRCELLGRP-${cellgrp_id}
# #     ...    filter_param=List of NR cells assigned to cell group
# #     ...    node_index=${node_index}
# #     selenium_coam.validate_plan
# #     selenium_coam.activate_plan    activate_plan_despite_errors=True    timeout=300
# # 
# # Add One Cell Via Webem
# #     [Arguments]    ${cell_info}    ${nrcell_include_subobject}=True
# #     Connect to gnb coam via ssl
# #     Selenium Login With Version
# # 
# #     # Step1: add cell
# #     ${cell_dist_name}    Set Variable    MRBTS-${MRBTS_ID}/NRBTS-${NRBTS_ID}/NRCELL-${cell_info['global_cell_id']}
# #     selenium_coam.add_object    object_name=MRBTS-${MRBTS_ID}/NRBTS-${NRBTS_ID}
# #     ...    object_class_name=NRCELL    plan_to_copy_from=CURRENT_BTS_CONF-1
# #     ...    copy_from=MRBTS-${MRBTS_ID}/NRBTS-${NRBTS_ID}/NRCELL-${cell_info['cell_id_to_copy_from']}
# #     ...    include_subobject=${nrcell_include_subobject}    id_value=${cell_info['global_cell_id']}
# #     selenium_coam.set_parameter_value    dist_name=${cell_dist_name}
# #     ...    filter_param=Local cell resource ID    new_value=${cell_info['lcrId']}    abbr=lcrId
# #     selenium_coam.set_parameter_value    dist_name=${cell_dist_name}
# #     ...    filter_param=Physical cell identifier   new_value=${cell_info['physCellId']}    abbr=physCellId
# #     selenium_coam.set_parameter_value    dist_name=${cell_dist_name}
# #     ...    filter_param=NR Absolute radio frequency channel number   new_value=${cell_info['nrarfcn']}    abbr=nrarfcn
# # 
# #     # Step2: add group
# #     ${cell_ids}    Get All Cell Id
# #     ${cell_count}    Get Length    ${cell_ids}
# #     ${cellgrp_id}    Set Variable    ${cell_info['global_cell_id']}
# #     selenium_coam.add_object    object_name=MRBTS-${MRBTS_ID}/NRBTS-${NRBTS_ID}
# #     ...    object_class_name=NRCELLGRP    plan_to_copy_from=CURRENT_BTS_CONF-1
# #     ...    copy_from=MRBTS-${MRBTS_ID}/NRBTS-${NRBTS_ID}/NRCELLGRP-${cell_info['cell_id_to_copy_from']}
# #     ...    include_subobject=${nrcell_include_subobject}    id_value=${cellgrp_id}
# #     selenium_coam.set_parameter_value    dist_name=MRBTS-${MRBTS_ID}/NRBTS-${NRBTS_ID}/NRCELLGRP-${cellgrp_id}
# #     ...    filter_param=List of NR cells assigned to cell group    node_index=${0}
# #     ...    new_value=${cell_info['global_cell_id']}    abbr=nrCellList
# # 
# #     # Step3: add nrdu
# #     selenium_coam.add_element   dist_name=MRBTS-${MRBTS_ID}/NRBTS-${NRBTS_ID}/NRDU-1
# #     ...    filter_param=Reference to cell group    abbr=refNrCellGroup
# #     selenium_coam.set_parameter_value    dist_name=MRBTS-${MRBTS_ID}/NRBTS-${NRBTS_ID}/NRDU-1
# #     ...    filter_param=Reference to cell group    node_index=${cell_count}
# #     ...    new_value=${cell_info['global_cell_id']}    abbr=refNrCellGroup
# # 
# #     # Step4: add cellmapping
# #     selenium_coam.add_object    object_name=MRBTS-${MRBTS_ID}/MNL-1/MNLENT-1/CELLMAPPING-1
# #     ...    object_class_name=LCELNR    plan_to_copy_from=CURRENT_BTS_CONF-1
# #     ...    copy_from=MRBTS-${MRBTS_ID}/MNL-1/MNLENT-1/CELLMAPPING-1/LCELNR-${cell_info['cell_id_to_copy_from']}
# #     ...    include_subobject=True    id_value=${cell_info['global_cell_id']}
# #     selenium_coam.validate_plan
# #     selenium_coam.activate_plan    activate_plan_despite_errors=True    timeout=300
# #     [Teardown]    Run Keywords    Run Keyword And Ignore Error    COAM Teardown gnb connections
# #     ...    AND    Run Keyword And Ignore Error    Selenium Logout And Close Browser
