*** Settings ***
Resource        ../../../../cloud_common_resources/connections/connections.robot
Resource        ../../../../cloud_common_resources/alarms/alarms.robot
Resource        taf/rfrl/cbts/utilities/init_variables.robot
Resource        ../../../../cloud_common_resources/pods_and_containers/pods.robot
Resource        ../../../../cloud_common_resources/mantaray/mantaray.robot
Resource        taf/rfrl/cbts/robot/vcu/vcu_operations.robot
Resource        ../../../resources/common.robot


Library         taf.ul.vdu.helm.interface.helm   WITH NAME    helm
Library         taf.gnb.oam.coam.cu     WITH NAME    vcu_admin
Library         Collections

Documentation
...  TEST NAME:     UUF_CLOUD.10_ST_vCU_SW_intra_rollback_via_MantaRay_NM
...  AUTHORS:       roscislaw.szuminski@gmail.com
...  MAINTAINER:    VRF_WRO3_T01
...  *****************
...  Basic information
...  *****************
...  This test verifies software rollback of the vCU  using
...  NetAct inside different builds of same release (intra release).
...  *****************
...  RAN PZ3 WRO1 TEMPLATE
...  ******************
...  History of changes
...  ******************
...  13.05.2025 - TC Creation

*** Keywords ***
UUF_CLOUD.10_ST_vCU_SW_intra_rollback_via_MantaRay_NM
    UUF_CLOUD.10_ST_vCU_SW_intra_rollback_via_MantaRay_NM:0 Test Preparation
    UUF_CLOUD.10_ST_vCU_SW_intra_rollback_via_MantaRay_NM:1 Perform Rollback

UUF_CLOUD.10_ST_vCU_SW_intra_rollback_via_MantaRay_NM:0 Test Preparation
    Decorate Print  Step: 0 Test Preparation
    mantaray.Verify Api On Lab  ${nms_lab_ip}  hw_type=${hw}
    ${watchdog_alarms}=  Stop Cloud Watchdog And Get Faults  ${hw}
    Run Keyword If  '${watchdog_alarms}'!='[]'  Fail  Unexpected faults were detected on the ${hw_type} during test execution.
    Add Temporary Alowed Alarms To Watchdog  hw_type=${non_upgraded_cnf}

UUF_CLOUD.10_ST_vCU_SW_intra_rollback_via_MantaRay_NM:1 Perform Rollback
    Decorate Print  Step: 2 Start Rollback
    Perform CNF Rollback  nms_lab_ip=${NMS_LAB_IP}  hw_type=${hw}  rollback_plan_name=${rollback_plan_name}  cnf_dn=${cnf_dn}
    Wait Until Keyword Succeeds  10min  30s  VCU Pod Status Should Be Normal
    Sleep    30s
    ${admin_connection}=  Connect to ADMIN  password=nemuuser  hw_type=${hw}
    Set Test Variable  ${admin_connection_vcu}
    Wait Until Keyword Succeeds  10min  30s  Check If All Cells On Air  hw_type=${hw}  connection=${admin_connection_vcu}
    Start Cloud Watchdog  hw_type=${hw}  add_temporary_allowed_faults=${True}
    Delete Temporary Allowed Alarms From Watchdog  hw_type=${hw}
    Delete Temporary Allowed Alarms From Watchdog  hw_type=${non_upgraded_cnf}
    Log to Console  Waiting for 5 minutes to verify whether any unexpected alarms appear
    Sleep  5m
    Check Alarm List On vCU/vDU  ${hw}
