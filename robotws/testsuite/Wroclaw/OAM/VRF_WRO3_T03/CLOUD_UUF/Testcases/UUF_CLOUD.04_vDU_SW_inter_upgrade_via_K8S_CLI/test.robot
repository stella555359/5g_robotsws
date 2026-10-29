*** Settings ***
Resource        ../../../resources/common.robot
Resource        ../../../../cloud_common_resources/connections/connections.robot
Resource        ../../../../cloud_common_resources/alarms/alarms.robot
Resource        taf/rfrl/cbts/utilities/init_variables.robot
Resource        ../../../../cloud_common_resources/logs/logs.robot
Resource        ../../../../cloud_common_resources/pods_and_containers/pods.robot
Resource        ../../../resources/nop_default.robot
Resource        taf/rfrl/cbts/robot/vcu/vcu_operations.robot
Resource        taf/rfrl/cbts/robot/vdu/vdu_operations.robot
Library         ../../../resources/python_lib/suite_utils.py

Library         taf.ul.vdu.helm.interface.helm  WITH NAME  helm
Library         taf.gnb.oam.coam.cu  WITH NAME  vcu_admin
Library         Collections
Library         taf.transport.ssh  WITH NAME  tafssh

Documentation
...  TEST NAME:     UUF_CLOUD.04_vDU_SW_inter_upgrade_via_K8S_CLI
...  AUTHORS:       roscislaw.szuminski@nokia.com
...  MAINTAINER:    VRF_WRO3_T01
...  *****************
...  Basic information
...  *****************
...  This test verifies vCU(CNF based) inter-release upgrade from release N to release N+1 via helm CLI,
...  and it also verifies that all required configuration data(SCF) are migrated according to NIDD migration rules during upgrade
...  *****************
...  RAN PZ3 WRO1 TEMPLATE
...  ******************
...  History of changes
...  ******************
...  05.12.2024 - TC Creation

*** Variables ***
${sw_artifactory}=             https://artifactory-mn-espoo3.int.net.nokia.com/artifactory/mnp5g-central-public-local/System_Release
${sw_path}=                    /var/home/core/Downloads/

*** Keywords ***
UUF_CLOUD.04_vDU_SW_inter_upgrade_via_K8S_CLI

    UUF_CLOUD.04_vDU_SW_inter_upgrade_via_K8S_CLI:0 Test Preparation
    ${result}=    sw_ccr_sync_needed    operation_type=upgrade    ocp_ip=${SSH_VCU_IP}
    Run Keyword If    not ${result}
    ...  UUF_CLOUD.04_vDU_SW_inter_upgrade_via_K8S_CLI:1 Unpack Required Software Files And Onboard Image Script
    UUF_CLOUD.04_vDU_SW_inter_upgrade_via_K8S_CLI:2 Convert Values Override
    UUF_CLOUD.04_vDU_SW_inter_upgrade_via_K8S_CLI:3 Install Or Upgrade Charts
    UUF_CLOUD.04_vDU_SW_inter_upgrade_via_K8S_CLI:4 Final Recovery

UUF_CLOUD.04_vDU_SW_inter_upgrade_via_K8S_CLI:0 Test Preparation
    Decorate Print  Step: 0 Test Preparation
    Set Test Variable  ${du_scf}  /home/ute/testline_configuration/${hostname}/vDUCNF00/scf_du.xml
    Set Test Variable  ${sw_artifactory}  https://artifactory-mn-espoo3.int.net.nokia.com/artifactory/mnp5g-central-public-local/System_Release
    Set Test Variable  ${default_main_chart}  /home/ute/testline_configuration/${hostname}/values_override/vDU/main.yaml
    Set Test Variable  ${default_prep_chart}  /home/ute/testline_configuration/${hostname}/values_override/vDU/preparation.yaml
    Set Test Variable  ${default_prereq_chart}  /home/ute/testline_configuration/${hostname}/values_override/vDU/prerequisites.yaml
    Set Feature Under Given Object  MRBTS-${MRBTS}/MNL-1/AMGR-1/LUAC-1    jwtExpirationTime   240    ${admin_connection}
    @{charts_to_convert}=  Create List  ${default_main_chart}  ${default_prep_chart}  ${default_prereq_chart}
    Set Test Variable  ${charts_to_convert}
    ${rollback_sw}=  Get Software Version  hw_type=vDU
    ${rollback_sw}=  Set Variable    ${rollback_sw}[0]
    Set Suite Variable  ${rollback_sw}
    ${release_before_upgr}=  Fetch From Left  ${rollback_sw}  marker=_
    Set Test Variable  ${release_before_upgr}
    Log  Current SW Package: ${rollback_sw}  console=${true}

UUF_CLOUD.04_vDU_SW_inter_upgrade_via_K8S_CLI:1 Unpack Required Software Files And Onboard Image Script
    Decorate Print  Step: 1 Unpack Required Software Files And Onboard Image Script
    Check If SW Exist On Artifactory  vDU  ${SW_VDU}
    ${package_path}  ${conversionApp_path}  ${onboardingApp_path}  Download required software files  ${SW_VDU}  ${ssh_conn}  upgrade
    Set Test Variable  ${package_path}
    Set Test Variable  ${conversionApp_path}
    Set Test Variable  ${onboardingApp_path}
    Set Test Variable  ${helm_chart_dir}  ${storage_dir}[upgrade]/HelmChart
    Unpack required software files  ${package_path}  ${conversionApp_path}  ${onboardingApp_path}  ${storage_dir}[upgrade]  ${ssh_conn}
#    Image Onboarding  vDU  ${target_path}  ${ssh_conn}
    Images Onboarding  hw_type=vdu  ccr_location=${ccr_location_cli}  operation_type=upgrade
    ${image_path}    get_ccr_image_path_list_variable   IMAGE_PATH_LIST
    Set Suite Variable    ${CCR_IMAGE_PATH_LIST}    ${image_path}

UUF_CLOUD.04_vDU_SW_inter_upgrade_via_K8S_CLI:2 Convert Values Override
    Decorate Print  Step: 2 Convert Values Override
    ssh.Execute  cat ${storage_dir}[upgrade]/valuesToBeConverted/conversion_done.txt  connection=${ssh_conn}
    ${status}=    ssh.Get Exit Status  connection=${ssh_conn}
    Run Keyword If    '${status}' != '0'
    ...    Convert Values Override For Different Clusters  vDU  ${ssh_conn}

UUF_CLOUD.04_vDU_SW_inter_upgrade_via_K8S_CLI:3 Install Or Upgrade Charts
    Decorate Print  Step: 3 Install Or Upgrade Charts
    ${charts_to_be_installed}=  Get Required Charts From HelmChart Directory
    ...  hw_type=vdu  helm_chart_path=${storage_dir}[upgrade]/HelmChart  connection=admin
    ${watchdog_alarms}=  Stop Cloud Watchdog And Get Faults  ${hw}
    Run Keyword If  '${watchdog_alarms}'!='[]'  Fail  Unexpected faults were detected on the ${hw_type} during test execution.
    Add Temporary Alowed Alarms To Watchdog  hw_type=${non_upgraded_cnf}
    common.Remove Existing Charts   hw_type=vdu  chart_name=all  conn=${ssh_conn}
    Run Keyword If    ${install_default_NOP}==${True}      Run Keywords
    ...    Upgrade Incompatible NOP    ${SW_VDU}    ran-nic-sw-controller    ${ccr_location_cli}
    ...    AND    Upgrade Incompatible NOP    ${SW_VDU}    nokia-sync-operator    ${ccr_location_cli}
    ...    AND    Upgrade Incompatible NOP    ${SW_VDU}    koredump-operator    ${ccr_location_cli}
    Install Or Upgrade Charts
    ...  hw=vdu
    ...  cran=${CRAN_VDU}
    ...  helm_dir_path=${storage_dir}[upgrade]/HelmChart
    ...  chart_name=${ordred_charts_all[2]}
    ...  helm_chart_path=${charts_to_be_installed[0]}
    ...  path_to_yaml_file=${storage_dir}[upgrade]/conversionApp/prep_new.yaml
    ...  conn=admin
    Install Or Upgrade Charts
    ...  hw=vdu
    ...  cran=${CRAN_VDU}
    ...  helm_dir_path=${storage_dir}[upgrade]/HelmChart
    ...  chart_name=${ordred_charts_all[1]}
    ...  helm_chart_path=${charts_to_be_installed[1]}
    ...  path_to_yaml_file=${storage_dir}[upgrade]/conversionApp/prereq_new.yaml
    ...  conn=admin
    Install Or Upgrade Charts
    ...  hw=vdu
    ...  cran=${CRAN_VDU}
    ...  helm_dir_path=${storage_dir}[upgrade]/HelmChart
    ...  chart_name=${ordred_charts_all[0]}
    ...  helm_chart_path=${charts_to_be_installed[2]}
    ...  path_to_yaml_file=${storage_dir}[upgrade]/valuesToBeConverted/main.yaml
    ...  conn=admin
    ...  timeout=660

UUF_CLOUD.04_vDU_SW_inter_upgrade_via_K8S_CLI:4 Final Recovery
    Decorate Print  Step: 4 Final Recovery
    Wait Until Keyword Succeeds  10min  30s  VDU Pod Status Should Be Normal
    Start Cloud Watchdog  hw_type=${hw}  add_temporary_allowed_faults=${True}
    Sleep  120s
    ${admin_connection}=  Connect to ADMIN  hw_type=vDU
    Set Test Variable  ${admin_connection}
    ${status}=  Run Keyword And Return Status  Get Vdu State Data   connection=${admin_connection}
    Run Keyword If  '${status}'=='False' and '${release_before_upgr}'=='vDUCNF25R1'
    ...  vdu_admin.Perform Commissioning  scf_file=${du_scf}  vdu_connection=${admin_connection}
    Wait Until Keyword Succeeds  35min  30s  Check If All Cells On Air  hw_type=vDU  connection=${admin_connection}
    Delete Temporary Allowed Alarms From Watchdog  hw_type=${hw}
    Delete Temporary Allowed Alarms From Watchdog  hw_type=${non_upgraded_cnf}
    Log to Console  Waiting for 5 minutes to verify whether any unexpected alarms appear
    Sleep  5m
    Check Alarm List On vCU/vDU  vDU

#Set Default DockerCFG
#    [Documentation]  KW grep for Default DockerCFG and set it for vDU main values-override.yaml
#    ${output}=  ssh.Execute  kubectl get secret -n ${CRAN_VDU} | grep "kubernetes.io/dockercfg"  connection=${ssh_conn}
#    @{output}=  Split String  ${output}
#    ${default_docker}=  Evaluate  [item for item in ${output} if item.startswith('default-dockercfg')]
#    ${imagePullSecret}=  Set Variable  imagePullSecret: "${default_docker}[0]"
#    Log  ${imagePullSecret}  console=${true}
#    ${yaml_file}=  Set Variable  ${default_main_chart}
#    ${file_content}=  OperatingSystem.Get File  ${yaml_file}
#    ${new_file_content}=  Insert Under Registry  ${file_content}  ${imagePullSecret}
#    OperatingSystem.Create File  ${yaml_file}  ${new_file_content}
#
#Insert Under Registry
#    [Arguments]  ${content}  ${imagePullSecret}
#    ${lines}=  Evaluate  ${content}.splitlines()
#    ${new_lines}=  Create List
#    ${inserted}=  Set Variable  False
#    FOR  ${line}  IN  @{lines}
#        ${contains_registry}=  Evaluate  'registry: "image-registry'
#        Run Keyword If  ${contains_registry}  Append To List  ${new_lines}  ${line}
#    END
#


# ${yaml_file}=  Set Variable  ${default_main_chart}
#    ${file_content}=  OperatingSystem.Get File  ${yaml_file}
#    ${new_file_content}=  Catenate  ${file_content}\n${imagePullSecret}
#    OperatingSystem.Create File  ${yaml_file}  ${new_file_content}
