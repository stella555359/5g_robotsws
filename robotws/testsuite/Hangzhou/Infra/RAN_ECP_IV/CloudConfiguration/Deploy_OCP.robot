*** Settings ***
Documentation    Deploy OCP for any cluster type(SNO, SNO+1, MNO)
...              Author: Zhu Hongbiao
...              Contact: jacky.zhu@nokia-sbell.com
...              Squard: CP HZ 3

Suite Setup       common_suite_setup_for_infra
Suite Teardown    common_suite_teardown_for_infra
Resource          ../resources/infra_common_resources.robot

*** Variables ***
${ENVIRONMENT_NAME}           iv007
${NOKIA_OCP_RELEASE}          ocp-4.14.22-nokia.24.4.3
${CLUSTER_JSON_PATH}          ${CURDIR}/../config/cluster_json
${ADDITIONAL_CONFIG_SCRIPT}   ${CURDIR}/../files/script/ocp-additional-conf.sh

*** Test Cases ***
Cloud_General_OCP_Installation_And_Post_configuration_With_SNO
    [Documentation]    DESCRIPTION: Deploy OCP including install and configuration
    ...
    ...    TEST EXECUTION:
    ...    1. create edge data center plan file
    ...    2. start workflow ocp-full-deployment
    ...    3. do addition config for cluster
    ...    4. set SSH password of cluster
    ...    5. check OCP deployment result
    ...
    ...    EXPECTED RESULTS:
    ...    1. succeed to create plan file
    ...    2. succeed to execute workflow ocp-full-deployment
    ...    3. succeed to do addition config for cluster
    ...    4. succeed to set SSH password of cluster
    ...    5. all check items should be OK
    [Tags]    testid-175410    testid-175417    testid-175416
    [Setup]    deploy OCP setup
    Deploy OCP By Neat
    Check OCP Deployment Result
    [Teardown]    common_test_teardown_for_infra

*** Keywords ***
deploy OCP setup
    common_test_setup_for_infra
    ${CLUSTER_JSON}    neatOps.get_cluster_json    ${CLUSTER_JSON_PATH}    ${ENVIRONMENT_NAME}
    Set Test Variable    ${CLUSTER_JSON}
    ${CLUSTER_TYPE}    neatOps.get_cluster_type    ${CLUSTER_JSON}
    Set Test Variable    ${CLUSTER_TYPE}
    ${CLUSTER_IP_LIST}    neatOps.get_cluster_fixed_ip_list    ${CLUSTER_JSON}
    Set Test Variable    ${CLUSTER_IP_LIST}
    neatOps.connect_to_rest    ${NEAT_REST_ACCESS}[ip]    ${NEAT_REST_ACCESS}[username]    ${NEAT_REST_ACCESS}[password]
    neatOps.delete_cloud_instance_by_name    ${ENVIRONMENT_NAME}
    neatOps.delete_edgedc_plan_by_name    ${ENVIRONMENT_NAME}

Deploy OCP By Neat
    Install OCP by Neat Workflow
    Do Addition Config By Neat

Install OCP by Neat Workflow
    neatOps.upload_edgedc_plan_file    ${CLUSTER_JSON}    ${NOKIA_OCP_RELEASE}
    ${workflow_name}    neatOps.start_workflow    ${ENVIRONMENT_NAME}    full-ocp-deployment
    neatOps.wait_workflow_done    ${workflow_name}

Do Addition Config By Neat
    neatOps.connect_to_ssh    ${NEATHOST_SSH_ACCESS}[ip]    ${NEATHOST_SSH_ACCESS}[username]    ${NEATHOST_SSH_ACCESS}[password]
    neatOps.upload_additional_config_file    ${ADDITIONAL_CONFIG_SCRIPT}
    neatOps.run_additional_config_file    ${ENVIRONMENT_NAME}
    neatOps.set_ocp_ssh_password    ${ENVIRONMENT_NAME}

Check OCP Deployment Result
    ocpOps.connect_to_ssh    ${CLUSTER_IP_LIST}[0]    core    system123
    ocpOps.ocp_release_should_be    ${NOKIA_OCP_RELEASE}
    ocpOps.nodes_status_should_be_ready
    ocpOps.pods_status_should_be_ok
    ocpOps.operators_available_should_be_true
    ${rannic_cards}  ocpOps.get_rannic_cards_info
    IF    ${rannic_cards}
        ocpOps.rannic_driver_service_should_be_active
    END
    IF    '${CLUSTER_TYPE}' == 'MNO'
        ocpOps.cephcluster_health_should_be_ok
    END
