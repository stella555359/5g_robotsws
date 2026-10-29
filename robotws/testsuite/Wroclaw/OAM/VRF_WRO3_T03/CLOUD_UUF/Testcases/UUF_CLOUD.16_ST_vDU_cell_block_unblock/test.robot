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
...  TEST NAME:     UUF_CLOUD.16_ST_vDU_cell_block_unblock
...  AUTHORS:       damian.sliwinski@gmail.com
...  MAINTAINER:    VRF_WRO3_T01
...  *****************
...  Basic information
...  *****************
...  This test verifies cell block unblock on vDU.
...  *****************
...  RAN PZ3 WRO1 TEMPLATE
...  ******************
...  History of changes
...  ******************
...  10.09.2025 - https://jiradc.ext.net.nokia.com/browse/FCA_VRF_OAM-26928 - TC Creation

*** Keywords ***
UUF_CLOUD.16_ST_vDU_cell_block_unblock
    UUF_CLOUD.16_ST_vDU_cell_block_unblock:0 Test Preparation
    UUF_CLOUD.16_ST_vDU_cell_block_unblock:1 Cell block
    UUF_CLOUD.16_ST_vDU_cell_block_unblock:2 Cell unblock

UUF_CLOUD.16_ST_vDU_cell_block_unblock:0 Test Preparation
    Decorate Print  Step: 0 Test Preparation
    ${cell_list}=  vdu_admin.get_vdu_cells_status   vdu_connection=${admin_connection}
    ${cells_list}=  Create List
    FOR  ${ITEM}  IN  @{cell_list}
        Append To List  ${cells_list}  ${ITEM['id']}
    END
    ${selected_cell}=     Evaluate    random.choice(${cells_list})    modules=random
    ${blocked_cell}=    Create List    ${selected_cell}
    Set Test Variable    ${blocked_cell}
    Log     SELECTED CELL:${blocked_cell}      console=True
    ${allowed_alarms_list}=    Create List    49
    Set Test Variable    ${selected_cell}
    Set Test Variable    ${allowed_alarms_list}
    Add Alarms To Watchdog    ${allowed_alarms_list}    ${hw}

UUF_CLOUD.16_ST_vDU_cell_block_unblock:1 Cell block
    Decorate Print  Step: 2 Perform Cell block
    Run Keyword And Return Status  vdu_admin.block_cell  vdu_connection=${admin_connection}  cell_id=${selected_cell}
    Wait Until Alarm Appears    timeout=${60}   fault_id=49   hw_type=${hw}

UUF_CLOUD.16_ST_vDU_cell_block_unblock:2 Cell unblock
    Decorate Print  Step: 2 Perform Cell unblock
    Run Keyword And Return Status  vdu_admin.unblock_cell  vdu_connection=${admin_connection}  cell_id=${selected_cell}
    Sleep    60s
    Wait Until Keyword Succeeds  5min  30s  Check If All Cells On Air  hw_type=${hw}  connection=${admin_connection}
    Delete Alarms From Watchdog    ${allowed_alarms_list}    ${hw}
    Check Alarm List On vCU/vDU  ${hw}
