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
...  TEST NAME:     UUF_CLOUD.14_ST_vCU_Blue_Green_SW_intra_upgrade_rollback_via_MantaRay_NM
...  AUTHORS:       marek.starzyk@nokia.com
...  MAINTAINER:    VRF_WRO3_T01
...  *****************
...  Basic information
...  *****************
...  This test verifies software blue green upgrade/rollback of the vCU  using
...  NetAct  and LCM operator.
...  *****************
...  RAN PZ3 WRO1 TEMPLATE
...  ******************
...  History of changes
...  ******************
...  20.08.2025 - TC Creation

*** Variables ***
&{PARAMETERS}   -feedbackLevel=parameterLevel

*** Keywords ***
UUF_CLOUD.18_ST_vCU_Blue_Green_SW_upgrade_with_scale-in_option_with_max_UPUE_pods
    UUF_CLOUD.18_ST_vCU_Blue_Green_SW_upgrade_with_scale-in_option_with_max_UPUE_pods:0 Test Preparation
    UUF_CLOUD.18_ST_vCU_Blue_Green_SW_upgrade_with_scale-in_option_with_max_UPUE_pods:1 Perform Upgrade
    UUF_CLOUD.18_ST_vCU_Blue_Green_SW_upgrade_with_scale-in_option_with_max_UPUE_pods:2 Perform Rollback


UUF_CLOUD.18_ST_vCU_Blue_Green_SW_upgrade_with_scale-in_option_with_max_UPUE_pods:0 Test Preparation
    Decorate Print  Step: 0 Test Preparation
    Import Configuration Plan To Lab
    ...  nms_lab_ip=${NMS_LAB_IP}    file_name=${namespace_xml_file_name}    local_dir=${lcm_config_files_path}
    ...  plan_name=${MR_NAMESPACE_PLAN_NAME}    ui_values=${True}

    Provision Create Namespace Plan To Cloud    ${NMS_LAB_IP}    ${MR_NAMESPACE_PLAN_NAME}    ${CLOUD_DIST_NAME}
    Upload Cloud Configuration    ${NMS_LAB_IP}    ${CLOUD_DIST_NAME}
#    Terminate CNF  nms_lab_ip=${NMS_LAB_IP}   nop_type=cnf-lcm-operator-vcu


UUF_CLOUD.18_ST_vCU_Blue_Green_SW_upgrade_with_scale-in_option_with_max_UPUE_pods:1 Perform Upgrade
    Decorate Print  Step: 2 Perform Upgrade
    Set Test Variable  ${UPGRADE_PLAN_NAME}     vCU${MRBTS_CU}_RANCNF_BG_SCALE_IN_UPGRADE_auto_${CURRENT_DATE}
    Set Test Variable  ${ROLLBACK_PLAN_NAME}    vCU${MRBTS_CU}_RANCNF_BG_SCALE_IN_ROLLBACK_auto_${CURRENT_DATE}
    ${watchdog_alarms}=  Stop Cloud Watchdog And Get Faults  ${hw}
    Run Keyword If  '${watchdog_alarms}'!='[]'  Fail  Unexpected faults were detected on the ${hw} during test execution.
    Add Temporary Alowed Alarms To Watchdog  hw_type=${non_upgraded_cnf}
    Perform RANCNF BlueGreen Upgrade
    ...  nms_lab_ip=${NMS_LAB_IP}
    ...  sw_version=${VCU_SW_VERSION}-amd64
    ...  upgrade_plan_name=${UPGRADE_PLAN_NAME}
    ...  dist_names=${BLUE_DIST_NAME}
    ...  rollback_plan_name=${ROLLBACK_PLAN_NAME}
    ...  with_scale_in=${True}
    ...  delete_upgrade_plan=${True}
    Wait Until Keyword Succeeds  10min  30s  Check If All Cells On Air  hw_type=${hw}  connection=${admin_connection_vcu}
    Start Cloud Watchdog  hw_type=${hw}  add_temporary_allowed_faults=${True}
    Delete Temporary Allowed Alarms From Watchdog  hw_type=${hw}
    Delete Temporary Allowed Alarms From Watchdog  hw_type=${non_upgraded_cnf}
    Log to Console  Waiting for 5 minutes to verify whether any unexpected alarms appear
    Sleep  5m
    Check Alarm List On vCU/vDU  ${hw}
    Collect Logs    hw_type=${hw}    non_upgraded_cnf=${non_upgraded_cnf}    iteration_test_name=BlueGreen_upgrade_via_LCM
    ...             pass_logs_collection=${True}    namespace=${GREEN_NAMESPACE}

UUF_CLOUD.18_ST_vCU_Blue_Green_SW_upgrade_with_scale-in_option_with_max_UPUE_pods:2 Perform Rollback
    Decorate Print  Step: 2 Perform Rollback
    ${watchdog_alarms}=  Stop Cloud Watchdog And Get Faults  ${hw}
    Run Keyword If  '${watchdog_alarms}'!='[]'  Fail  Unexpected faults were detected on the ${hw_type} during test execution.
    Add Temporary Alowed Alarms To Watchdog  hw_type=${non_upgraded_cnf}
    Perform RANCNF BlueGreen Rollback  nms_lab_ip=${NMS_LAB_IP}  rollback_plan_name=${ROLLBACK_PLAN_NAME}
    ...  gb_dist_names=${None}    delete_rollback_plan=${True}
    ${admin_connection}=  Connect to ADMIN  password=nemuuser  hw_type=${hw}
    Set Test Variable  ${admin_connection_vcu}
    Wait Until Keyword Succeeds  10min  30s  Check If All Cells On Air  hw_type=${hw}  connection=${admin_connection_vcu}
    Start Cloud Watchdog  hw_type=${hw}  add_temporary_allowed_faults=${True}
    Delete Temporary Allowed Alarms From Watchdog  hw_type=${hw}
    Delete Temporary Allowed Alarms From Watchdog  hw_type=${non_upgraded_cnf}
    Log to Console  Waiting for 5 minutes to verify whether any unexpected alarms appear
    Sleep  5m
    Check Alarm List On vCU/vDU  ${hw}
    Collect Logs    hw_type=${hw}    non_upgraded_cnf=${non_upgraded_cnf}    iteration_test_name=BlueGreen_rollback_via_LCM
    ...             pass_logs_collection=${True}    namespace=${BLUE_NAMESPACE}
