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
...  TEST NAME:     UUF_CLOUD.22_ST_vCU_Software_Upgrade_with_N_plus_1_GeoRedundancy_preceded_by_switchover
...  AUTHORS:       marek.starzyk@gmail.com
...  MAINTAINER:    VRF_WRO3_T01
...  *****************
...  Basic information
...  *****************
...  This test verifies the software upgrade/rollback of the GeoRedundancy configuration with two vCUs
...  using the LCM operator and NetAct across different builds of the same release (intra-release)
...  *****************
...  RAN PZ3 WRO1 TEMPLATE
...  ******************
...  History of changes
...  ******************
...  11.12.2025 - TC Creation


*** Variables ***
&{PARAMETERS}   -feedbackLevel=parameterLevel

*** Keywords ***
UUF_CLOUD.22_ST_vCU_Software_Upgrade_with_N_plus_1_GeoRedundancy_preceded_by_switchover
    UUF_CLOUD.22_ST_vCU_Software_Upgrade_with_N_plus_1_GeoRedundancy_preceded_by_switchover:0 Test Preparation
    UUF_CLOUD.22_ST_vCU_Software_Upgrade_with_N_plus_1_GeoRedundancy_preceded_by_switchover:1 Perform Upgrade on vCU1
    UUF_CLOUD.22_ST_vCU_Software_Upgrade_with_N_plus_1_GeoRedundancy_preceded_by_switchover:2 Perform Upgrade on vCU2
    UUF_CLOUD.22_ST_vCU_Software_Upgrade_with_N_plus_1_GeoRedundancy_preceded_by_switchover:3 Perform Rollback on vCU2
    UUF_CLOUD.22_ST_vCU_Software_Upgrade_with_N_plus_1_GeoRedundancy_preceded_by_switchover:4 Perform Rollback on vCU1

UUF_CLOUD.22_ST_vCU_Software_Upgrade_with_N_plus_1_GeoRedundancy_preceded_by_switchover:0 Test Preparation
    Decorate Print  Step: 0 Test Preparation
    Upload Cloud Configuration    ${NMS_LAB_IP}    ${CLOUD_DIST_NAME}
    Set Test Variable  ${UPGRADE_PLAN_NAME_VCU1}     vCU${MRBTS_CU}_RANCNF_ONE_BUTTON_UPGRADE_auto_${CURRENT_DATE}
    Set Test Variable  ${ROLLBACK_PLAN_NAME_VCU1}    vCU${MRBTS_CU}_RANCNF_ROLLBACK_auto_${CURRENT_DATE}
    Set Test Variable  ${UPGRADE_PLAN_NAME_VCU2}     vCU${MRBTS_CU2}_RANCNF_ONE_BUTTON_UPGRADE_auto_${CURRENT_DATE}
    Set Test Variable  ${ROLLBACK_PLAN_NAME_VCU2}    vCU${MRBTS_CU2}_RANCNF_ROLLBACK_auto_${CURRENT_DATE}
#    Disable CNF  add in the separated TAW
#    Enable CNF   add in the separated TAW
#    Terminate CNF  nms_lab_ip=${NMS_LAB_IP}   nop_type=cnf-lcm-operator-vcu

UUF_CLOUD.22_ST_vCU_Software_Upgrade_with_N_plus_1_GeoRedundancy_preceded_by_switchover:1 Perform Upgrade on vCU1
    Decorate Print  Step: 1 Perform Upgrade on the vCU1: ${CRAN_VCU}
    Perform Switchover    vcu_mrbts_id=${MRBTS_CU2}    operation_id=1
    Wait Until Keyword Succeeds  10min  30s  Check If All Cells On Air  hw_type=${hw}  connection=${admin_connection_vcu2}
    Check Alarm List On vCU/vDU  ${hw}
    ${vCU2_alarms}    vcu_admin.get_active_alarms  connection=${admin_connection_vcu2}
    ${vCU2_active_alarms}=  Get From Dictionary  ${vCU2_alarms}  total
    Run Keyword If  '${vCU2_active_alarms}'=='0'  Log To Console  No Visible Alarms On vCU2
    ...  ELSE  Fail  Alarm(s) Visible On vCU2

    ${vcu_1_vnf}=                    vcu_admin.get_cu_vnf    connection=${admin_connection_vcu}
    ${vcu_2_vnf}=                    vcu_admin.get_cu_vnf    connection=${admin_connection_vcu2}
    Should be Equal As Strings       ${vcu_1_vnf["activity_mode"]}    standby
    Should be Equal As Strings       ${vcu_2_vnf["activity_mode"]}    active
    Append To List   ${vCU_ALLOWED_FAULTS}    4592
    Append To List   ${vCU_ALLOWED_FAULTS}    4961
    Start Cloud Watchdog   hw_type=${hw}
    Start Cloud Watchdog   hw_type=${non_upgraded_cnf}
    ${watchdog_alarms}=  Stop Cloud Watchdog And Get Faults  ${hw}
    Run Keyword If  '${watchdog_alarms}'!='[]'  Fail  Unexpected faults were detected on the ${hw} during test execution.
    Add Temporary Alowed Alarms To Watchdog  hw_type=${non_upgraded_cnf}
    Perform RANCNF One Button Upgrade
    ...  nms_lab_ip=${NMS_LAB_IP}
    ...  sw_version=${VCU_SW_VERSION}-amd64
    ...  upgrade_plan_name=${UPGRADE_PLAN_NAME_VCU1}
    ...  dist_names=${VCU1_DIST_NAME}
    ...  rollback_plan_name=${ROLLBACK_PLAN_NAME_VCU1}
    ...  delete_upgrade_plan=${True}
    sleep  30s
    Start Cloud Watchdog  hw_type=${hw}  add_temporary_allowed_faults=${True}
    Log to Console  Waiting for 5 minutes to verify whether any unexpected alarms appear
    Sleep  5m
    Delete Temporary Allowed Alarms From Watchdog  hw_type=${hw}
    Delete Temporary Allowed Alarms From Watchdog  hw_type=${non_upgraded_cnf}
    ${vCU1_alarms}    vcu_admin.get_active_alarms  connection=${admin_connection_vcu}
    ${vCU1_active_alarms}=  Get From Dictionary  ${vCU1_alarms}  total
    ${sync_alarm}    Set Variable    ${vCU1_alarms['alarms'][0]['fault_id']}
    Should be True    "${sync_alarm}"=="4961"
    Run Keyword If  '${vCU1_active_alarms}'=='1'  Log To Console  vCU1 active alarm: ${sync_alarm}
    ...  ELSE  Fail  Alarm(s) Visible On vCU1

    ${vCU2_alarms}    vcu_admin.get_active_alarms  connection=${admin_connection_vcu2}
    ${vCU2_active_alarms}=  Get From Dictionary  ${vCU2_alarms}  total
    Run Keyword If  '${vCU2_active_alarms}'=='0'  Log To Console  No Visible Alarms On vCU2
    ...  ELSE  Fail  Alarm(s) Visible On vCU2

    ${vcu_1_vnf}=                    vcu_admin.get_cu_vnf    connection=${admin_connection_vcu}
    ${vcu_2_vnf}=                    vcu_admin.get_cu_vnf    connection=${admin_connection_vcu2}
    Should be Equal As Strings       ${vcu_1_vnf["activity_mode"]}    standby
    Should be Equal As Strings       ${vcu_2_vnf["activity_mode"]}    active
    ${watchdog_alarms}  Stop Cloud Watchdog And Get Faults   hw_type=${hw}
    ${non_upgraded_cnf_alarms}  Stop Cloud Watchdog And Get Faults   hw_type=${non_upgraded_cnf}
    Run Keyword If  '${watchdog_alarms}'!='[]' or '${non_upgraded_cnf_alarms}'!='[]'
    ...  Fail  Unexpected faults were detected during test execution!

UUF_CLOUD.22_ST_vCU_Software_Upgrade_with_N_plus_1_GeoRedundancy_preceded_by_switchover:2 Perform Upgrade on vCU2
    Decorate Print  Step: 2 Perform Upgrade on the vCU2: ${CRAN_VCU2}
    Perform Switchover     vcu_mrbts_id=${MRBTS_CU}    operation_id=2
    Wait Until Keyword Succeeds  10min  30s  Check If All Cells On Air  hw_type=${hw}  connection=${admin_connection_vcu}
    Check Alarm List On vCU/vDU  ${hw}
    ${vCU2_alarms}    vcu_admin.get_active_alarms  connection=${admin_connection_vcu2}
    ${vCU2_active_alarms}=  Get From Dictionary  ${vCU2_alarms}  total
    ${sync_alarm}    Set Variable    ${vCU2_alarms['alarms'][0]['fault_id']}
    Should be True    "${sync_alarm}"=="4961"
    Run Keyword If  '${vCU2_active_alarms}'=='1'  Log To Console  vCU2 active alarm: ${sync_alarm}
    ...  ELSE  Fail  Alarm(s) Visible On vCU1

    ${vcu_1_vnf}=                    vcu_admin.get_cu_vnf    connection=${admin_connection_vcu}
    ${vcu_2_vnf}=                    vcu_admin.get_cu_vnf    connection=${admin_connection_vcu2}
    Should be Equal As Strings       ${vcu_1_vnf["activity_mode"]}    active
    Should be Equal As Strings       ${vcu_2_vnf["activity_mode"]}    standby
    Start Cloud Watchdog   hw_type=${hw}
    Start Cloud Watchdog   hw_type=${non_upgraded_cnf}
#    Append To List    ${vCU_TEMPORARY_ALLOWED_FAULTS}    4557
    Add Temporary Alowed Alarms To Watchdog  hw_type=${hw}
    Perform RANCNF One Button Upgrade
    ...  nms_lab_ip=${NMS_LAB_IP}
    ...  sw_version=${VCU_SW_VERSION}-amd64
    ...  upgrade_plan_name=${UPGRADE_PLAN_NAME_VCU2}
    ...  dist_names=${VCU2_DIST_NAME}
    ...  rollback_plan_name=${ROLLBACK_PLAN_NAME_VCU2}
    ...  delete_upgrade_plan=${True}
    Log to Console  Waiting for 5 minutes to verify whether any unexpected alarms appear
    Sleep  5m
    Delete Temporary Allowed Alarms From Watchdog  hw_type=${hw}
    ${vCU2_alarms}    vcu_admin.get_active_alarms  connection=${admin_connection_vcu2}
    ${vCU2_active_alarms}=  Get From Dictionary  ${vCU2_alarms}  total
    Run Keyword If  '${vCU2_active_alarms}'=='0'  Log To Console  No Visible Alarms On vCU2
    ...  ELSE  Fail  Alarm(s) Visible On vCU2
    Check Alarm List On vCU/vDU  ${hw}
    ${vcu_1_vnf}=                    vcu_admin.get_cu_vnf    connection=${admin_connection_vcu}
    ${vcu_2_vnf}=                    vcu_admin.get_cu_vnf    connection=${admin_connection_vcu2}
    Should be Equal As Strings       ${vcu_1_vnf["activity_mode"]}    active
    Should be Equal As Strings       ${vcu_2_vnf["activity_mode"]}    standby
    ${watchdog_alarms}  Stop Cloud Watchdog And Get Faults   hw_type=${hw}
    ${non_upgraded_cnf_alarms}  Stop Cloud Watchdog And Get Faults   hw_type=${non_upgraded_cnf}
    Run Keyword If  '${watchdog_alarms}'!='[]' or '${non_upgraded_cnf_alarms}'!='[]'
    ...  Fail  Unexpected faults were detected during test execution!
    Collect Logs    hw_type=vCU  non_upgraded_cnf=${non_upgraded_cnf}    iteration_test_name=vCU1_vCU2_upgrade_via_LCM
    ...             pass_logs_collection=${True}    second_vcu=${True}

UUF_CLOUD.22_ST_vCU_Software_Upgrade_with_N_plus_1_GeoRedundancy_preceded_by_switchover:3 Perform Rollback on vCU2
    Decorate Print  Step: 3 Perform Rollback on the vCU2: ${CRAN_VCU2}
    Start Cloud Watchdog   hw_type=${hw}
    Start Cloud Watchdog   hw_type=${non_upgraded_cnf}
    Add Temporary Alowed Alarms To Watchdog  hw_type=${hw}
    Add Temporary Alowed Alarms To Watchdog  hw_type=${non_upgraded_cnf}
    Perform RANCNF Rollback  nms_lab_ip=${NMS_LAB_IP}  rollback_plan_name=${ROLLBACK_PLAN_NAME_VCU2}  delete_rollback_plan=${True}
    Log to Console  Waiting for 5 minutes to verify whether any unexpected alarms appear
    Sleep  5m
    Delete Temporary Allowed Alarms From Watchdog  hw_type=${hw}
    Delete Temporary Allowed Alarms From Watchdog  hw_type=${non_upgraded_cnf}
    Check Alarm List On vCU/vDU  ${hw}
    ${vCU2_alarms}    vcu_admin.get_active_alarms  connection=${admin_connection_vcu2}
    ${vCU2_active_alarms}=  Get From Dictionary  ${vCU2_alarms}  total
    ${sync_alarm}    Set Variable    ${vCU2_alarms['alarms'][0]['fault_id']}
    Should be True    "${sync_alarm}"=="4961"
    Run Keyword If  '${vCU2_active_alarms}'=='1'  Log To Console  vCU2 active alarm: ${sync_alarm}
    ...  ELSE  Fail  Alarm(s) Visible On vCU2

    ${vcu_1_vnf}=                    vcu_admin.get_cu_vnf    connection=${admin_connection_vcu}
    ${vcu_2_vnf}=                    vcu_admin.get_cu_vnf    connection=${admin_connection_vcu2}
    Should be Equal As Strings       ${vcu_1_vnf["activity_mode"]}    active
    Should be Equal As Strings       ${vcu_2_vnf["activity_mode"]}    standby
    ${watchdog_alarms}  Stop Cloud Watchdog And Get Faults   hw_type=${hw}
    ${non_upgraded_cnf_alarms}  Stop Cloud Watchdog And Get Faults   hw_type=${non_upgraded_cnf}
    Run Keyword If  '${watchdog_alarms}'!='[]' or '${non_upgraded_cnf_alarms}'!='[]'
    ...  Fail  Unexpected faults were detected during test execution!

UUF_CLOUD.22_ST_vCU_Software_Upgrade_with_N_plus_1_GeoRedundancy_preceded_by_switchover:4 Perform Rollback on vCU1
    Decorate Print  Step: 4 Perform Rollback on the vCU1: ${CRAN_VCU}
    Perform Switchover     vcu_mrbts_id=${MRBTS_CU2}    operation_id=3
    Wait Until Keyword Succeeds  10min  30s  Check If All Cells On Air  hw_type=${hw}  connection=${admin_connection_vcu2}
    ${vCU1_alarms}    vcu_admin.get_active_alarms  connection=${admin_connection_vcu}
    ${vCU1_active_alarms}=  Get From Dictionary  ${vCU1_alarms}  total
    ${sync_alarm}    Set Variable    ${vCU1_alarms['alarms'][0]['fault_id']}
    Should be True    "${sync_alarm}"=="4961"
    Run Keyword If  '${vCU1_active_alarms}'=='1'  Log To Console  vCU1 active alarm: ${sync_alarm}
    ...  ELSE  Fail  Alarm(s) Visible On vCU1

    ${vCU2_alarms}    vcu_admin.get_active_alarms  connection=${admin_connection_vcu2}
    ${vCU2_active_alarms}=  Get From Dictionary  ${vCU2_alarms}  total
    Run Keyword If  '${vCU2_active_alarms}'=='0'  Log To Console  No Visible Alarms On vCU2
    ...  ELSE  Fail  Alarm(s) Visible On vCU2

    ${vcu_1_vnf}=                    vcu_admin.get_cu_vnf    connection=${admin_connection_vcu}
    ${vcu_2_vnf}=                    vcu_admin.get_cu_vnf    connection=${admin_connection_vcu2}
    Should be Equal As Strings       ${vcu_1_vnf["activity_mode"]}    standby
    Should be Equal As Strings       ${vcu_2_vnf["activity_mode"]}    active
    Start Cloud Watchdog   hw_type=${hw}
    Start Cloud Watchdog   hw_type=${non_upgraded_cnf}
    sleep  30s
    ${watchdog_alarms}=  Stop Cloud Watchdog And Get Faults  ${hw}
    Run Keyword If  '${watchdog_alarms}'!='[]'  Fail  Unexpected faults were detected on the ${hw} during test execution.
    Add Temporary Alowed Alarms To Watchdog  hw_type=${non_upgraded_cnf}
    Perform RANCNF Rollback  nms_lab_ip=${NMS_LAB_IP}  rollback_plan_name=${ROLLBACK_PLAN_NAME_VCU1}  delete_rollback_plan=${True}
    sleep  30s
    Wait Until Keyword Succeeds  10min  30s  Check If All Cells On Air  hw_type=${hw}  connection=${admin_connection_vcu2}
    Start Cloud Watchdog  hw_type=${hw}  add_temporary_allowed_faults=${True}
    Log to Console  Waiting for 5 minutes to verify whether any unexpected alarms appear
    Sleep  5m
    Delete Temporary Allowed Alarms From Watchdog  hw_type=${hw}
    Delete Temporary Allowed Alarms From Watchdog  hw_type=${non_upgraded_cnf}
    Check Alarm List On vCU/vDU  ${hw}
    ${vCU2_alarms}    vcu_admin.get_active_alarms  connection=${admin_connection_vcu2}
    ${vCU2_active_alarms}=  Get From Dictionary  ${vCU2_alarms}  total
    Run Keyword If  '${vCU2_active_alarms}'=='0'  Log To Console  No Visible Alarms On vCU2
    ...  ELSE  Fail  Alarm(s) Visible On vCU2
    ${vcu_1_vnf}=                    vcu_admin.get_cu_vnf    connection=${admin_connection_vcu}
    ${vcu_2_vnf}=                    vcu_admin.get_cu_vnf    connection=${admin_connection_vcu2}
    Should be Equal As Strings       ${vcu_1_vnf["activity_mode"]}    standby
    Should be Equal As Strings       ${vcu_2_vnf["activity_mode"]}    active
    ${watchdog_alarms}  Stop Cloud Watchdog And Get Faults   hw_type=${hw}
    ${non_upgraded_cnf_alarms}  Stop Cloud Watchdog And Get Faults   hw_type=${non_upgraded_cnf}
    Run Keyword If  '${watchdog_alarms}'!='[]' or '${non_upgraded_cnf_alarms}'!='[]'
    ...  Fail  Unexpected faults were detected during test execution!
    Perform Switchover     vcu_mrbts_id=${MRBTS_CU}    operation_id=4
    Wait Until Keyword Succeeds  10min  30s  Check If All Cells On Air  hw_type=${hw}  connection=${admin_connection_vcu}
    Check Alarm List On vCU/vDU  ${hw}
    ${vCU2_alarms}    vcu_admin.get_active_alarms  connection=${admin_connection_vcu2}
    ${vCU2_active_alarms}=  Get From Dictionary  ${vCU2_alarms}  total
    Run Keyword If  '${vCU2_active_alarms}'=='0'  Log To Console  No Visible Alarms On vCU2
    ...  ELSE  Fail  Alarm(s) Visible On vCU1

    ${vcu_1_vnf}=                    vcu_admin.get_cu_vnf    connection=${admin_connection_vcu}
    ${vcu_2_vnf}=                    vcu_admin.get_cu_vnf    connection=${admin_connection_vcu2}
    Should be Equal As Strings       ${vcu_1_vnf["activity_mode"]}    active
    Should be Equal As Strings       ${vcu_2_vnf["activity_mode"]}    standby
    Collect Logs    hw_type=vCU  non_upgraded_cnf=${non_upgraded_cnf}    iteration_test_name=vCU1_vCU2_rollback_via_LCM
    ...             pass_logs_collection=${True}    second_vcu=${True}
