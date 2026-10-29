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
...  TEST NAME:     UUF_CLOUD.21_ST_vCU_multiple_vCU_Blue_green_SW_upgrade_with_scale_in_same_Cloud
...  AUTHORS:       anna.niedzwiecka@nokia.com
...  MAINTAINER:    VRF_WRO3_T01
...  *****************
...  Basic information
...  *****************
...  This test verifies software Blue-Green upgrade/rollback of two vCUs in the same cloud obiect
...  using the LCM operator and NetAct across different builds of the same release (intra-release)
...  *****************
...  RAN PZ3 WRO1 TEMPLATE
...  ******************
...  History of changes
...  ******************
...  19.11.2025 - TC Creation


*** Variables ***
&{PARAMETERS}   -feedbackLevel=parameterLevel

*** Keywords ***
UUF_CLOUD.21_ST_vCU_multiple_vCU_Blue_green_SW_upgrade_with_scale_in_same_Cloud
    UUF_CLOUD.21_ST_vCU_multiple_vCU_Blue_green_SW_upgrade_with_scale_in_same_Cloud:0 Test Preparation
    UUF_CLOUD.21_ST_vCU_multiple_vCU_Blue_green_SW_upgrade_with_scale_in_same_Cloud:1 Perform Blue-Green Upgrade on vCU1 and vCU2
    UUF_CLOUD.21_ST_vCU_multiple_vCU_Blue_green_SW_upgrade_with_scale_in_same_Cloud:2 Perform Blue-Green Rollback on vCU1 and vCU2

UUF_CLOUD.21_ST_vCU_multiple_vCU_Blue_green_SW_upgrade_with_scale_in_same_Cloud:0 Test Preparation
    Decorate Print  Step: 0 Test Preparation
    Set Test Variable  ${UPGRADE_PLAN_NAME_VCU}     vCU${MRBTS_CU}_vCU${MRBTS_CU2}_RANCNF_ONE_BUTTON_UPGRADE_auto_${CURRENT_DATE}
    Set Test Variable  ${ROLLBACK_PLAN_NAME_VCU}    vCU${MRBTS_CU}_vCU${MRBTS_CU2}_RANCNF_ROLLBACK_auto_${CURRENT_DATE}
    Upload Cloud Configuration    ${NMS_LAB_IP}    ${CLOUD_DIST_NAME}
    Import Configuration Plan To Lab
    ...  nms_lab_ip=${NMS_LAB_IP}    file_name=${namespace_xml_file_name}    local_dir=${lcm_config_files_path}
    ...  plan_name=${MR_NAMESPACE_PLAN_NAME}    ui_values=${True}
    Import Configuration Plan To Lab
    ...  nms_lab_ip=${NMS_LAB_IP}    file_name=${namespace_xml_file_name_vcu2}    local_dir=${lcm_config_files_path}
    ...  plan_name=${MR_NAMESPACE_PLAN_NAME_vcu2}    ui_values=${True}
    Provision Create Namespace Plan To Cloud    ${NMS_LAB_IP}    ${MR_NAMESPACE_PLAN_NAME}    ${CLOUD_DIST_NAME}
    Provision Create Namespace Plan To Cloud    ${NMS_LAB_IP}    ${MR_NAMESPACE_PLAN_NAME_vcu2}    ${CLOUD_DIST_NAME}


UUF_CLOUD.21_ST_vCU_multiple_vCU_Blue_green_SW_upgrade_with_scale_in_same_Cloud:1 Perform Blue-Green Upgrade on vCU1 and vCU2
    Decorate Print  Step: 1 Perform Blue-Green Upgrade on the vCU1 and vCU2: ${CRAN_VCU} and ${CRAN_VCU2}
    Start Cloud Watchdog   hw_type=${hw}
    Start Cloud Watchdog   hw_type=${non_upgraded_cnf}
    ${watchdog_alarms}=  Stop Cloud Watchdog And Get Faults  ${hw}
    Run Keyword If  '${watchdog_alarms}'!='[]'  Fail  Unexpected faults were detected on the ${hw} during test execution.
    Add Temporary Alowed Alarms To Watchdog  hw_type=${non_upgraded_cnf}
    Perform RANCNF BlueGreen Upgrade
    ...  nms_lab_ip=${NMS_LAB_IP}
    ...  sw_version=${VCU_SW_VERSION}-amd64
    ...  upgrade_plan_name=${UPGRADE_PLAN_NAME_VCU}
    ...  dist_names=${VCU1_DIST_NAME},${VCU2_DIST_NAME}
    ...  rollback_plan_name=${ROLLBACK_PLAN_NAME_VCU}
    ...  with_scale_in=${True}
    ...  delete_upgrade_plan=${True}
    sleep  30s
    Wait Until Keyword Succeeds  10min  30s  Check If All Cells On Air  hw_type=${hw}  connection=${admin_connection_vcu}
    Wait Until Keyword Succeeds  10min  30s  Check If All Cells On Air  hw_type=${hw}  connection=${admin_connection_vcu2}
    ${active_sw_version_vcu1}    vcu_admin.Get Active Software Version    connection=${admin_connection_vcu}
    ${active_sw_version_vcu2}    vcu_admin.Get Active Software Version    connection=${admin_connection_vcu2}
    Log    vCU1 active sw version: ${active_sw_version_vcu1}\nvCU2 active sw version: ${active_sw_version_vcu2}
    Should be Equal As Strings    ${active_sw_version_vcu1}    ${TARGET_SW}
    Should be Equal As Strings    ${active_sw_version_vcu2}    ${TARGET_SW}
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
    ${watchdog_alarms}  Stop Cloud Watchdog And Get Faults   hw_type=${hw}
    ${non_upgraded_cnf_alarms}  Stop Cloud Watchdog And Get Faults   hw_type=${non_upgraded_cnf}
    Run Keyword If  '${watchdog_alarms}'!='[]' or '${non_upgraded_cnf_alarms}'!='[]'
    ...  Fail  Unexpected faults were detected during test execution!
    Collect Logs    hw_type=vCU  non_upgraded_cnf=${non_upgraded_cnf}    iteration_test_name=vCU1_vCU2_upgrade_via_LCM
    ...             pass_logs_collection=${True}    second_vcu=${True}


UUF_CLOUD.21_ST_vCU_multiple_vCU_Blue_green_SW_upgrade_with_scale_in_same_Cloud:2 Perform Blue-Green Rollback on vCU1 and vCU2
    Decorate Print  Step: 4 Perform Blue-Green Rollback on the vCU1 and vCU2: ${CRAN_VCU} and ${CRAN_VCU2}
    Start Cloud Watchdog   hw_type=${hw}
    Start Cloud Watchdog   hw_type=${non_upgraded_cnf}
    sleep  30s
    ${watchdog_alarms}=  Stop Cloud Watchdog And Get Faults  ${hw}
    Run Keyword If  '${watchdog_alarms}'!='[]'  Fail  Unexpected faults were detected on the ${hw} during test execution.
    Add Temporary Alowed Alarms To Watchdog  hw_type=${non_upgraded_cnf}
    Perform RANCNF BlueGreen Rollback  nms_lab_ip=${NMS_LAB_IP}  rollback_plan_name=${ROLLBACK_PLAN_NAME_VCU}
    ...  gb_dist_names=${None}    delete_rollback_plan=${True}
    sleep  30s
    Wait Until Keyword Succeeds  10min  30s  Check If All Cells On Air  hw_type=${hw}  connection=${admin_connection_vcu}
    Wait Until Keyword Succeeds  10min  30s  Check If All Cells On Air  hw_type=${hw}  connection=${admin_connection_vcu2}
    ${active_sw_version_vcu1}    vcu_admin.Get Active Software Version    connection=${admin_connection_vcu}
    ${active_sw_version_vcu2}    vcu_admin.Get Active Software Version    connection=${admin_connection_vcu2}
    Log    vCU1 active sw version: ${active_sw_version_vcu1}\nvCU2 active sw version: ${active_sw_version_vcu2}
    Should be Equal As Strings    ${active_sw_version_vcu1}    ${VCU_DP_SW}
    Should be Equal As Strings    ${active_sw_version_vcu2}    ${VCU_DP_SW}
    Log    sw:${sw_version_vcu2}     console=${True}
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
    ${watchdog_alarms}  Stop Cloud Watchdog And Get Faults   hw_type=${hw}
    ${non_upgraded_cnf_alarms}  Stop Cloud Watchdog And Get Faults   hw_type=${non_upgraded_cnf}
    Run Keyword If  '${watchdog_alarms}'!='[]' or '${non_upgraded_cnf_alarms}'!='[]'
    ...  Fail  Unexpected faults were detected during test execution!
    Collect Logs    hw_type=vCU  non_upgraded_cnf=${non_upgraded_cnf}    iteration_test_name=vCU1_vCU2_rollback_via_LCM
    ...             pass_logs_collection=${True}    second_vcu=${True}
