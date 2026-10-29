*** Settings ***
Resource        ../../../../cloud_common_resources/connections/connections.robot
Resource        ../../../../cloud_common_resources/alarms/alarms.robot
Resource        taf/rfrl/cbts/utilities/init_variables.robot
Resource        ../../../../cloud_common_resources/pods_and_containers/pods.robot
Resource        ../../../../cloud_common_resources/mantaray/mantaray.robot
Resource        taf/rfrl/cbts/robot/vcu/vcu_operations.robot
Resource        taf/rfrl/cbts/robot/vdu/vdu_operations.robot
Resource        ../../../resources/common.robot
Resource        ../../../../cloud_common_resources/logs/logs.robot

Library         taf.ul.vdu.helm.interface.helm   WITH NAME    helm
Library         taf.gnb.oam.coam.cu     WITH NAME    vcu_admin
Library         Collections

Documentation
...  TEST NAME:     UUF_CLOUD.25_ST_vCU_cell_lock_unlock
...  AUTHORS:       anna.niedzwiecka@nokia.com
...  MAINTAINER:    VRF_WRO3_T03
...  *****************
...  Basic information
...  *****************
...  Test case verifies cell lock and unlock on vCU.
...  *****************
...  RAN PZ3 WRO1 TEMPLATE
...  ******************
...  History of changes
...  ******************
...  09-01-2026 - https://jiradc.ext.net.nokia.com/browse/FCA_VRF_OAM-33966 - TC Creation

*** Keywords ***
UUF_CLOUD.25_ST_vCU_cell_lock_unlock
    UUF_CLOUD.25_ST_vCU_cell_lock_unlock:0 Test Preparation
    UUF_CLOUD.25_ST_vCU_cell_lock_unlock:1 Perform cell lock
    UUF_CLOUD.25_ST_vCU_cell_lock_unlock:2 Perform cell unlock

UUF_CLOUD.25_ST_vCU_cell_lock_unlock:0 Test Preparation
    Decorate Print  Step: 0 Test Preparation
    ${get_cells_info}=  vcu_admin.get_cells_statuses     connection=${admin_connection}
    ${cells_list}=  Create List
    FOR  ${ITEM}  IN  @{get_cells_info}
        Append To List  ${cells_list}  ${ITEM['id']}
    END
    Run Keyword And Return Status  vcu_admin.unlock_cells    cell_ids=${cells_list}    connection=${admin_connection}
    SLeep    30s
    ${selected_cell_list}=    Create List
    ${selected_cell}=     Evaluate    random.choice(${cells_list})    modules=random
    Append To List    ${selected_cell_list}   ${selected_cell}
    Set Test Variable    ${selected_cell_list}
    Set Test Variable    ${selected_cell}
    Log     SELECTED CELL:${selected_cell}      console=True

UUF_CLOUD.25_ST_vCU_cell_lock_unlock:1 Perform cell lock
    Decorate Print  Step: 1 Perform cell lock
    Run Keyword And Return Status  vcu_admin.lock_cells   cell_ids=${selected_cell_list}    connection=${admin_connection}
    Sleep     20s
    Verify Operational State Of Selected Cell On VCU    ${admin_connection}    ${selected_cell}    disabled

UUF_CLOUD.25_ST_vCU_cell_lock_unlock:2 Perform cell unlock
    Decorate Print  Step: 2 Perform cell unlock
    Run Keyword And Return Status  vcu_admin.unlock_cells    cell_ids=${selected_cell_list}    connection=${admin_connection}
    Sleep    30s
    Wait Until Keyword Succeeds  5min  30s  Check If All Cells On Air  hw_type=${hw}  connection=${admin_connection}
    Check Alarm List On vCU/vDU  ${hw}
    Check Alarm List On vCU/vDU  ${non_upgraded_cnf}