*** Settings ***
Resource        ../../../../cloud_common_resources/connections/connections.robot
Resource        ../../../../cloud_common_resources/alarms/alarms.robot
Resource        taf/rfrl/cbts/utilities/init_variables.robot
Resource        ../../../../cloud_common_resources/pods_and_containers/pods.robot
Resource        ../../../../cloud_common_resources/mantaray/mantaray.robot
Resource        taf/rfrl/cbts/robot/vcu/vcu_operations.robot
Resource        ../../../resources/common.robot
Resource        ../../../../cloud_common_resources/logs/logs.robot


Library         taf.ul.vdu.helm.interface.helm   WITH NAME    helm
Library         taf.gnb.oam.coam.cu     WITH NAME    vcu_admin
Library         Collections

Documentation
...  TEST NAME:     UUF_CLOUD.13_ST_vCU_blue_green_upgrade_rollback_deployment_modification_HA
...  AUTHORS:       roscislaw.szuminski@gmail.com
...  MAINTAINER:    VRF_WRO3_T01
...  *****************
...  Basic information
...  *****************

...  This test verifies software upgrade/rollback with additional values-overrite of the vCU  using
...  NetAct inside different builds of same release (intra release).
...  *****************
...  RAN PZ3 WRO1 TEMPLATE
...  ******************
...  History of changes
...  ******************
...  20.08.2025 - TC Creation

*** Keywords ***
UUF_CLOUD.13_ST_vCU_blue_green_upgrade_rollback_deployment_modification_HA
    UUF_CLOUD.13_ST_vCU_blue_green_upgrade_rollback_deployment_modification_HA:0 Test Preparation
    UUF_CLOUD.13_ST_vCU_blue_green_upgrade_rollback_deployment_modification_HA:1 Perform Upgrade
    UUF_CLOUD.13_ST_vCU_blue_green_upgrade_rollback_deployment_modification_HA:2 Verify Deployment Modification
    UUF_CLOUD.13_ST_vCU_blue_green_upgrade_rollback_deployment_modification_HA:3 Perform Rollback

UUF_CLOUD.13_ST_vCU_blue_green_upgrade_rollback_deployment_modification_HA:0 Test Preparation
    Decorate Print  Step: 0 Test Preparation
    ${watchdog_alarms}=  Stop Cloud Watchdog And Get Faults  ${hw}
    Run Keyword If  '${watchdog_alarms}'!='[]'  Fail  Unexpected faults were detected on the ${hw} during test execution.
    Add Temporary Alowed Alarms To Watchdog  hw_type=${non_upgraded_cnf}

UUF_CLOUD.13_ST_vCU_blue_green_upgrade_rollback_deployment_modification_HA:1 Perform Upgrade
    Decorate Print  Step: 2 Perform Upgrade
    Perform CNF BlueGreen Upgrade   nms_lab_ip=${NMS_LAB_IP}  sw_version=${VCU_SW_VERSION}-amd64   hw_type=vCU
    ...  additional_values=${True}
    Wait Until Keyword Succeeds  10min  30s  Check If All Cells On Air  hw_type=${hw}  connection=${admin_connection_vcu}
    Start Cloud Watchdog  hw_type=${hw}  add_temporary_allowed_faults=${True}
    Delete Temporary Allowed Alarms From Watchdog  hw_type=${hw}
    Delete Temporary Allowed Alarms From Watchdog  hw_type=${non_upgraded_cnf}

UUF_CLOUD.13_ST_vCU_blue_green_upgrade_rollback_deployment_modification_HA:2 Verify Deployment Modification
    Decorate Print  Step: 2 Verify Deployment Modification
    ${upue_amount}=  Count Upue Instances  connection=${admin_connection_vcu}
    Should Be Equal  '${upue_amount}'  '22'
    Log  Amount Of UPUE is ${upue_amount}  console=${True}
    Log to Console  Waiting for 5 minutes to verify whether any unexpected alarms appear
    Sleep  5m
    Check Alarm List On vCU/vDU  ${hw}
    Collect Logs From Passed Execution If Needed    iteration_test_name=BG_upgrade_via_MR_HA    namespace=${CRAN_VCU}99

UUF_CLOUD.13_ST_vCU_blue_green_upgrade_rollback_deployment_modification_HA:3 Perform Rollback
    Decorate Print  Step: 3 Perform Rollback
    ${watchdog_alarms}=  Stop Cloud Watchdog And Get Faults  ${hw}
    Run Keyword If  '${watchdog_alarms}'!='[]'  Fail  Unexpected faults were detected on the ${hw_type} during test execution.
    Add Temporary Alowed Alarms To Watchdog  hw_type=${non_upgraded_cnf}
    Perform CNF BlueGreen Rollback  nms_lab_ip=${NMS_LAB_IP}  rollback_plan_name=${rollback_plan_name}
    ...  gb_dist_names=${green_dist_name}    delete_rollback_plan=${True}
    ${admin_connection}=  Connect to ADMIN  password=nemuuser  hw_type=${hw}
    Set Test Variable  ${admin_connection_vcu}
    Wait Until Keyword Succeeds  10min  30s  Check If All Cells On Air  hw_type=${hw}  connection=${admin_connection_vcu}
    Start Cloud Watchdog  hw_type=${hw}  add_temporary_allowed_faults=${True}
    Delete Temporary Allowed Alarms From Watchdog  hw_type=${hw}
    Delete Temporary Allowed Alarms From Watchdog  hw_type=${non_upgraded_cnf}
    Log to Console  Waiting for 5 minutes to verify whether any unexpected alarms appear
    Sleep  5m
    Check Alarm List On vCU/vDU  ${hw}
