*** Settings ***
Resource        ../../../resources/common.robot
Resource        ../../../../cloud_common_resources/connections/connections.robot
Resource        ../../../../cloud_common_resources/alarms/alarms.robot
Resource        taf/rfrl/cbts/utilities/init_variables.robot
Resource        ../../../../cloud_common_resources/logs/logs.robot
Resource        ../../../../cloud_common_resources/pods_and_containers/pods.robot
Resource        taf/rfrl/cbts/robot/vcu/vcu_operations.robot


Library         taf.ul.vdu.helm.interface.helm  WITH NAME  helm
Library         taf.gnb.oam.coam.cu  WITH NAME  vcu_admin
Library         Collections
Library         taf.transport.ssh  WITH NAME  tafssh

Documentation
...  TEST NAME:     UUF_CLOUD.03_vCU_SW_inter_rollback_via_K8S_CLI
...  AUTHORS:       roscislaw.szuminski@nokia.com
...  MAINTAINER:    VRF_WRO3_T01
...  *****************
...  Basic information
...  *****************
...  This test verifies vCU(CNF based) inter-release rollback from N+1 to N via K8S CLI, and it also verifies that all required
...  configuration data(SCF) are migrated according to NIDD migration rules during upgrade.
...  *****************
...  RAN PZ3 WRO1 TEMPLATE
...  ******************
...  History of changes
...  ******************
...  23.12.2024 - TC Creation

*** Variables ***
${sw_artifactory}=             https://artifactory-mn-espoo3.int.net.nokia.com/artifactory/mnp5g-central-public-local/System_Release
${sw_path}=                    /var/home/core/Downloads/

*** Keywords ***
UUF_CLOUD.03_vCU_SW_inter_rollback_via_K8S_CLI

    UUF_CLOUD.03_vCU_SW_inter_rollback_via_K8S_CLI:0 Test Preparation
    ${result}=    sw_ccr_sync_needed    operation_type=rollback    ocp_ip=${SSH_VCU_IP}
    Run Keyword If    not ${result}
    ...  UUF_CLOUD.03_vCU_SW_inter_rollback_via_K8S_CLI:1 Unpack Required Software Files And Onboard Image Script
    UUF_CLOUD.03_vCU_SW_inter_rollback_via_K8S_CLI:2 Remove Old Charts
    UUF_CLOUD.03_vCU_SW_inter_rollback_via_K8S_CLI:3 Install Or Upgrade Charts
    UUF_CLOUD.03_vCU_SW_inter_rollback_via_K8S_CLI:4 Final Recovery

UUF_CLOUD.03_vCU_SW_inter_rollback_via_K8S_CLI:0 Test Preparation
    Decorate Print  Step: 0 Test Preparation
    Set Test Variable  ${sw_artifactory}  https://artifactory-mn-espoo3.int.net.nokia.com/artifactory/mnp5g-central-public-local/System_Release
    Set Test Variable  ${default_main_chart}  /home/ute/testline_configuration/${hostname}/values_override/vCU/main.yaml
    Set Test Variable  ${default_prep_chart}  /home/ute/testline_configuration/${hostname}/values_override/vCU/preparation.yaml
    Set Test Variable  ${default_prereq_chart}  /home/ute/testline_configuration/${hostname}/values_override/vCU/prerequisites.yaml
    Set Feature Under Given Object  MRBTS-${MRBTS_CU}/MNL-1/AMGR-1/LUAC-1    jwtExpirationTime   240    ${admin_connection}
    @{charts_to_convert}=  Create List  ${default_main_chart}  ${default_prep_chart}  ${default_prereq_chart}
    Set Test Variable  ${charts_to_convert}
#    Set Test Variable  ${rollback_sw}  vCUCNF25R2_25.250.27

UUF_CLOUD.03_vCU_SW_inter_rollback_via_K8S_CLI:1 Unpack Required Software Files And Onboard Image Script
    Decorate Print  Step: 1 Unpack Required Software Files And Onboard Image Script
    Check If SW Exist On Artifactory  vCU  ${rollback_sw}
    ${package_path}  ${conversionApp_path}  ${onboardingApp_path}  Download required software files  ${rollback_sw}  ${ssh_conn}  rollback
    Set Test Variable  ${package_path}
    Set Test Variable  ${conversionApp_path}
    Set Test Variable  ${onboardingApp_path}
    Unpack required software files
    ...  ${package_path}  ${conversionApp_path}  ${onboardingApp_path}  ${storage_dir}[rollback]  ${ssh_conn}  uprg_roll=rollaback
    Set Test Variable  ${helm_chart_dir}  ${storage_dir}[rollback]/HelmChart
    Images Onboarding  hw_type=vcu  ccr_location=${ccr_location_cli}  operation_type=rollback
    ${image_path}    get_ccr_image_path_list_variable   IMAGE_PATH_LIST
    Set Suite Variable    ${ROLLBACK_CCR_IMAGE_PATH_LIST}    ${image_path}
    ssh.Execute  cd ${storage_dir}[rollback] && mkdir defaultValues    connection=${ssh_conn}
    ${output}=  ssh.Upload File  ${charts_to_convert}  ${storage_dir}[rollback]/defaultValues   connection=${ssh_conn}
    ssh.Assert Exit Status  0  connection=${ssh_conn}

UUF_CLOUD.03_vCU_SW_inter_rollback_via_K8S_CLI:2 Remove Old Charts
    Decorate Print  Step: 2 Remove Old Charts
    ${charts_to_be_installed}=  Get Required Charts From HelmChart Directory
    ...  hw_type=vcu  helm_chart_path=${storage_dir}[rollback]/HelmChart  connection=admin
    ${watchdog_alarms}=  Stop Cloud Watchdog And Get Faults  ${hw}
    Run Keyword If  '${watchdog_alarms}'!='[]'  Fail  Unexpected faults were detected on the ${hw_type} during test execution.
    Add Temporary Alowed Alarms To Watchdog  hw_type=${non_upgraded_cnf}
    common.Remove Existing Charts  hw_type=vcu  chart_name=all  conn=${ssh_conn}

UUF_CLOUD.03_vCU_SW_inter_rollback_via_K8S_CLI:3 Install Or Upgrade Charts
    Decorate Print  Step: 3 Install Or Upgrade Charts
    Set Test Variable  ${main_chart}    ${storage_dir}[rollback]/defaultValues/main.yaml
    Set Test Variable  ${prep_chart}    ${storage_dir}[rollback]/defaultValues/preparation.yaml
    Set Test Variable  ${prereq_chart}  ${storage_dir}[rollback]/defaultValues/prerequisites.yaml
    Install Or Upgrade Charts
    ...  hw=vcu
    ...  cran=${CRAN_VCU}
    ...  helm_dir_path=${storage_dir}[rollback]/HelmChart
    ...  chart_name=${ordred_charts_all[2]}
    ...  helm_chart_path=${charts_to_be_installed[0]}
    ...  path_to_yaml_file=${prep_chart}
    ...  conn=admin
    Install Or Upgrade Charts
    ...  hw=vcu
    ...  cran=${CRAN_VCU}
    ...  helm_dir_path=${storage_dir}[rollback]/HelmChart
    ...  chart_name=${ordred_charts_all[1]}
    ...  helm_chart_path=${charts_to_be_installed[1]}
    ...  path_to_yaml_file=${prereq_chart}
    ...  conn=admin
    Install Or Upgrade Charts
    ...  hw=vcu
    ...  cran=${CRAN_VCU}
    ...  helm_dir_path=${storage_dir}[rollback]/HelmChart
    ...  chart_name=${ordred_charts_all[0]}
    ...  helm_chart_path=${charts_to_be_installed[2]}
    ...  path_to_yaml_file=${main_chart}
    ...  conn=admin
    ...  timeout=660

UUF_CLOUD.03_vCU_SW_inter_rollback_via_K8S_CLI:4 Final Recovery
    Decorate Print  Step: 4 Final Recovery
    Wait Until Keyword Succeeds  10min  30s  VCU Pod Status Should Be Normal
    Start Cloud Watchdog  hw_type=${hw}  add_temporary_allowed_faults=${True}
    Wait Until Keyword Succeeds  10min  30s  Check If All Cells On Air  hw_type=vCU  connection=${admin_connection}
    Run Keyword If  ${cells_summary}==[]  Run Keywords
    ...  Sleep  180s
    ...  AND  Wait Until Keyword Succeeds  10min  30s  Check If All Cells On Air  hw_type=vCU  connection=${admin_connection}
    ...  ELSE  Wait Until Keyword Succeeds  10min  30s  Check If All Cells On Air  hw_type=vCU  connection=${admin_connection}
    Delete Temporary Allowed Alarms From Watchdog  hw_type=${hw}
    Delete Temporary Allowed Alarms From Watchdog  hw_type=${non_upgraded_cnf}
    Log to Console  Waiting for 5 minutes to verify whether any unexpected alarms appear
    Sleep  5m
    Check Alarm List On vCU/vDU  vCU
