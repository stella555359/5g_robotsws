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
...  TEST NAME:     UUF_CLOUD.15_ST_vDU_RMOD_reset
...  AUTHORS:       damian.sliwinski@gmail.com
...  MAINTAINER:    VRF_WRO3_T01
...  *****************
...  Basic information
...  *****************
...  This test verifies RMOD reset operation on vDU.
...  *****************
...  RAN PZ3 WRO1 TEMPLATE
...  ******************
...  History of changes
...  ******************
...  10.09.2025 - https://jiradc.ext.net.nokia.com/browse/FCA_VRF_OAM-26927 - TC Creation
...  05.12.2025 - https://jiradc.ext.net.nokia.com/browse/FCA_VRF_OAM-32804 - Modify TC

*** Keywords ***
UUF_CLOUD.15_ST_vDU_RMOD_reset
    UUF_CLOUD.15_ST_vDU_RMOD_reset:0 Test Preparation
    UUF_CLOUD.15_ST_vDU_RMOD_reset:1 Perform Reset
    UUF_CLOUD.15_ST_vDU_RMOD_reset:2 Check after reset

UUF_CLOUD.15_ST_vDU_RMOD_reset:0 Test Preparation
    Decorate Print  Step: 0 Test Preparation
    ${rmod_listed}=    vdu_admin.Get Rmods Status    vdu_connection=${admin_connection}
    Set Test Variable    ${rmod_listed}
    ${ids}=    Create List
    Set Test Variable     ${ids}
    FOR    ${item}    IN    @{rmod_listed}
        ${id}=    Get From Dictionary    ${item}    id
        Append To List    ${ids}    ${id}
    END
    ${selected_id}=     Evaluate    random.choice(${ids})    modules=random
    ${selected_rmod_list}=    Create List    ${selected_id}
    Set Test Variable   ${selected_rmod_list}
    Log     SELECTED RMOD:${selected_id}     console=True
    ${allowed_alarms_list}=    Create List   7108    4675
    ${allowed_alarms_list_vcu}=   Create List    7104
    Set Test Variable    ${allowed_alarms_list}
    Set Test Variable    ${allowed_alarms_list_vcu}
    Add Alarms To Watchdog    ${allowed_alarms_list}    ${hw}
    Add Alarms To Watchdog    ${allowed_alarms_list_vcu}    ${non_upgraded_cnf}

UUF_CLOUD.15_ST_vDU_RMOD_reset:1 Perform Reset
    Decorate Print  Step: 2 Perform Reset
    Run Keyword And Return Status    vdu_admin.reset_rmods    vdu_connection=${admin_connection}    rmods_list=${selected_rmod_list}
    ...    wait_for_completion=True     timeout=270

UUF_CLOUD.15_ST_vDU_RMOD_reset:2 Check after reset
    Sleep    60s
    Wait Until Keyword Succeeds  10min  30s  Check If All Cells On Air  hw_type=${hw}  connection=${admin_connection}
    Delete Alarms From Watchdog    ${allowed_alarms_list}    ${hw}
    Delete Alarms From Watchdog    ${allowed_alarms_list_vcu}    ${non_upgraded_cnf}
    Check Alarm List On vCU/vDU    ${hw}