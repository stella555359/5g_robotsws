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
Library         taf.gnb.oam.coam.vdu    WITH NAME    vdu_admin
Library         Collections

Documentation
...  TEST NAME:     UUF_CLOUD.30_ST_vDU_cell_reset
...  AUTHORS:       anna.niedzwiecka@nokia.com
...  MAINTAINER:    VRF_WRO3_T03
...  *****************
...  Basic information
...  *****************
...  Test case verifies cell reset on vDU.
...  *****************
...  RAN PZ3 WRO1 TEMPLATE
...  ******************
...  History of changes
...  ******************
...  06-02-2026 - https://jiradc.ext.net.nokia.com/browse/FCA_VRF_OAM-35064 - TC Creation

*** Keywords ***
UUF_CLOUD.30_ST_vDU_cell_reset
    UUF_CLOUD.30_ST_vDU_cell_reset:0 Test Preparation
    UUF_CLOUD.30_ST_vDU_cell_reset:1 Perform selected cell reset
    UUF_CLOUD.30_ST_vDU_cell_reset:2 Check after reset

UUF_CLOUD.30_ST_vDU_cell_reset:0 Test Preparation
    Decorate Print  Step: 0 Test Preparation
    ${get_cells_info}=    vdu_admin.get_vdu_cells_status   vdu_connection=${admin_connection}
    ${cells_list}=  Create List
    FOR  ${ITEM}  IN  @{get_cells_info}
        Append To List  ${cells_list}  ${ITEM['id']}
    END
    ${selected_cell}=     Evaluate    random.choice(${cells_list})    modules=random
    Set Test Variable    ${selected_cell}
    Log     SELECTED CELL ID :${selected_cell}      console=True

    ${dist_name}    Set Variable    ${None}
    FOR    ${cell}    IN    @{get_cells_info}
        ${dist_name}=    Set Variable If    '${cell["id"]}' == '${selected_cell}'    ${cell["dist_names"]["config"]}
        Run Keyword If    '${cell["id"]}' == '${selected_cell}'    Exit For Loop
    END
    Set Test Variable    ${dist_name}
    Log   DIST NAME CELL ID:${selected_cell} ${dist_name}      console=True

UUF_CLOUD.30_ST_vDU_cell_reset:1 Perform selected cell reset
    Decorate Print  Step: 1 Perform selected cell reset
    Log     SELECTED CELL DN :${dist_name} IS RESETTING     console=True
    ${reset_cell_status}=    vdu_admin.reset_cells    dist_name=${dist_name}    timeout=320    vdu_connection=${admin_connection}
    Run Keyword If     '${reset_cell_status}' == 'success'    Log   Reset ${dist_name} done  console=${true}
    ...    ELSE   Fail  msg=Reset ${dist_name} failed

UUF_CLOUD.30_ST_vDU_cell_reset:2 Check after reset
    Decorate Print  Step: 2 Check after reset
    Wait Until Keyword Succeeds  5min  30s  Check If All Cells On Air  hw_type=${hw}  connection=${admin_connection}
    Check Alarm List On vCU/vDU  ${hw}
    Check Alarm List On vCU/vDU  ${non_upgraded_cnf}
