*** Settings ***
Resource        ../../../../cloud_common_resources/connections/connections.robot
Resource        ../../../../cloud_common_resources/alarms/alarms.robot
Resource        taf/rfrl/cbts/utilities/init_variables.robot
Resource        ../../../../cloud_common_resources/pods_and_containers/pods.robot
Resource        ../../../../cloud_common_resources/mantaray/mantaray.robot
Resource        ../../../../cloud_common_resources/certificates/certificates.robot
Resource        taf/rfrl/cbts/robot/vcu/vcu_operations.robot
Resource        ../../../resources/common.robot


Library         taf.ul.vdu.helm.interface.helm   WITH NAME    helm
Library         taf.gnb.oam.coam.cu     WITH NAME    vcu_admin
Library         Collections

Documentation
...  TEST NAME:     UUF_CLOUD.11_ST_vDU_SW_intra_upgrade_via_MantaRay_NM
...  AUTHORS:       roscislaw.szuminski@gmail.com
...  MAINTAINER:    VRF_WRO3_T01
...  *****************
...  Basic information
...  *****************
...  This test verifies vDU(CNF based) intra-release upgrade from N version to another N version via MantaRay NM,
...  and it also verifies that all required configuration data(SCF) are migrated according to NIDD migration rules during upgrade.
...  SW upgrade operation consists to delete and re-install CNF instance(s).
...  *****************
...  RAN PZ3 WRO1 TEMPLATE
...  ******************
...  History of changes
...  ******************
...  15.05.2025 - TC Creation

*** Keywords ***
UUF_CLOUD.11_ST_vDU_SW_intra_upgrade_via_MantaRay_NM
    UUF_CLOUD.11_ST_vDU_SW_intra_upgrade_via_MantaRay_NM:0 Test Preparation
    UUF_CLOUD.11_ST_vDU_SW_intra_upgrade_via_MantaRay_NM:1 Perform Upgrade

UUF_CLOUD.11_ST_vDU_SW_intra_upgrade_via_MantaRay_NM:0 Test Preparation
    Decorate Print  Step: 0 Test Preparation
    mantaray.Verify Api On Lab  ${nms_lab_ip}  hw_type=${hw}
    ${watchdog_alarms}=  Stop Cloud Watchdog And Get Faults  ${hw}
    Run Keyword If  '${watchdog_alarms}'!='[]'  Fail  Unexpected faults were detected on the ${hw} during test execution.
    Add Temporary Alowed Alarms To Watchdog  hw_type=${non_upgraded_cnf}

UUF_CLOUD.11_ST_vDU_SW_intra_upgrade_via_MantaRay_NM:1 Perform Upgrade
    Decorate Print  Step: 1 Perform Upgrade
    mantaray.Perform CNF Upgrade  nms_lab_ip=${NMS_LAB_IP}  sw_version=${VDU_SW_VERSION}-amd64   hw_type=${hw}
    Wait Until Keyword Succeeds  10min  30s  VDU Pod Status Should Be Normal
    Sleep    30s
    Wait Until Keyword Succeeds  35min  30s  Check If All Cells On Air  hw_type=${hw}  connection=${admin_connection_vdu}
    Start Cloud Watchdog  hw_type=${hw}  add_temporary_allowed_faults=${True}
    Delete Temporary Allowed Alarms From Watchdog  hw_type=${hw}
    Delete Temporary Allowed Alarms From Watchdog  hw_type=${non_upgraded_cnf}
    Log to Console  Waiting for 5 minutes to verify whether any unexpected alarms appear
    Sleep  5m
    Check Alarm List On vCU/vDU  ${hw}
