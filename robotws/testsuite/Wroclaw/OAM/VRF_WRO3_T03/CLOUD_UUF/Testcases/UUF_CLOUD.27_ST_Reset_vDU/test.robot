*** Settings ***
Resource        ../../../../cloud_common_resources/connections/connections.robot
Resource        ../../../../cloud_common_resources/alarms/alarms.robot
Resource        taf/rfrl/cbts/utilities/init_variables.robot
Resource        ../../../../cloud_common_resources/pods_and_containers/pods.robot
Resource        ../../../../cloud_common_resources/mantaray/mantaray.robot
Resource        ../../../../cloud_common_resources/mantaray/mantaray.robot
Resource        taf/rfrl/cbts/robot/vcu/vcu_operations.robot
Resource        taf/rfrl/cbts/robot/vdu/vdu_operations.robot
Resource        ../../../resources/common.robot
Resource        ../../../../cloud_common_resources/resets/resets.robot

Library         taf.ul.vdu.helm.interface.helm   WITH NAME    helm
Library         taf.gnb.oam.coam.cu     WITH NAME    vcu_admin
Library         taf.gnb.oam.coam.vdu    WITH NAME    vdu_admin
Library         Collections

Documentation
...  TEST NAME:     UUF_CLOUD.27_ST_Reset_vDU
...  AUTHORS:       mateusz.gadek@gmail.com
...  MAINTAINER:    VRF_WRO3_T03
...  *****************
...  Basic information
...  *****************
...  This test verifies vCU reset operation
...  *****************
...  RAN PZ3 WRO3 TEMPLATE
...  ******************
...  History of changes
...  ******************
...  05.01.2026 - https://jiradc.ext.net.nokia.com/browse/FCA_VRF_OAM-33968 - TC Creation


*** Keywords ***
UUF_CLOUD.27_ST_Reset_vDU
    UUF_CLOUD.27_ST_Reset_vDU:0 Test Preparation
    UUF_CLOUD.27_ST_Reset_vDU:1 Perform vDU Reset
    UUF_CLOUD.27_ST_Reset_vDU:2 Check after reset

UUF_CLOUD.27_ST_Reset_vDU:0 Test Preparation
    Decorate Print  Step: 0 Test Preparation
    Delete Temporary Allowed Alarms From Watchdog  hw_type=${non_upgraded_cnf}
    ${watchdog_alarms}=  Stop Cloud Watchdog And Get Faults  ${hw}
    Run Keyword If  '${watchdog_alarms}'!='[]'  Fail  Unexpected faults were detected on the ${hw_type} during test execution.
    Add Temporary Alowed Alarms To Watchdog  hw_type=${non_upgraded_cnf}
    ${allowed_alarms_list}=   Create List  7115   4592
    Set Test Variable    ${allowed_alarms_list}
    Add Alarms To Watchdog    ${allowed_alarms_list}    ${hw}

UUF_CLOUD.27_ST_Reset_vDU:1 Perform vDU Reset
    Decorate Print  Step: 2 Perform vDU Reset
    Perform Reset and Wait for Expected State    state=onAir   hw_type=vDU

UUF_CLOUD.27_ST_Reset_vDU:2 Check after reset
    Start Cloud Watchdog  hw_type=${hw}  add_temporary_allowed_faults=${True}
    Wait Until Keyword Succeeds  10min  30s  Check If All Cells On Air  hw_type=${hw}  connection=${admin_connection}
    Check Alarm List On vCU/vDU    ${hw}
