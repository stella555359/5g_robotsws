*** Settings ***
Suite Setup       common_suite_setup_for_infra
Suite Teardown    common_suite_teardown_for_infra
Test Setup        common_test_setup_for_infra
Test Teardown     common_test_teardown_for_infra
Library           taf.sw.neat    WITH NAME    neat
Resource          ../resources/infra_common_resources.robot
Library           resources/collect_log_res.py    WITH NAME    CLR

*** Variables ***
${ENCODED_KUBECONFIG}    ${EMPTY}
${REST_CONN}      \    # restful connection
${NODE_NAME}      ${EMPTY}

*** Test Cases ***
Cloud_General_Logging_Logs from all Cloud Infra node can be collected via Neat
    [Documentation]    1. DESCRIPTION
    ...
    ...    You can collect OCP clusters’ logs, including audit logs, container logs, and journal via Neat. \ 2. TEST ENVIRONMENT AND SETTINGS
    ...    Cloud is added into Neat
    ...
    ...    2.1 Testing Tools
    ...    OpenShift CLI client
    ...    Login neat via ssh.
    ...
    ...    3. TESTING INSTRUCTIONS
    ...
    ...    3.1 Test Steps
    ...    1) Fetch OCP kubeconfig file on NEAT
    ...    2) Get the cluster node info according to fetched kubeconfig file
    ...    3) Enter the node you want to collect the logs from.
    ...    4) Check the logs including audit logs, container logs.
    ...    5) Check the audit log should larger than 0.
    ...    6) Repeat step above test steps to check all cloud infra nodes logs.
    [Setup]    Collect log test setup
    @{cloud_secretIds}    CLR.get_cloud_infra_secretIds    ${REST_CONN}
    FOR    ${secret_id}    IN    @{cloud_secretIds}
        Get encoded kubeconfig content by secret id    ${secret_id}
        Generate kubeconfig file
        Get the cluster node name
        Check the log files in node
        Get the audit log in node
    END
    [Teardown]    Collect log test teardown

*** Keywords ***
Connect to NEAT restful
    neat.connect_to    ${NEAT_REST_ACCESS}[ip]    ${NEAT_REST_ACCESS}[username]    ${NEAT_REST_ACCESS}[password]    alias=rest_conn
    Set Test Variable    ${REST_CONN}    rest_conn

Collect log test setup
    common_test_setup_for_infra
    Connect to NEAT restful
    Connect to NEAT ssh
    ${output}    CLR.prepare_oc_in_neat
    Should Not Contain    ${output}    No such file or directory    The oc file should exist!

Get the cluster node name
    ${NODE_NAME}    CLR.get_cluster_node_name
    Set Test Variable    ${NODE_NAME}

Connect to NEAT ssh
    sshi.connect_to    ${NEATHOST_SSH_ACCESS}[ip]    ${NEATHOST_SSH_ACCESS}[username]    ${NEATHOST_SSH_ACCESS}[password]

Get encoded kubeconfig content by secret id
    [Arguments]    ${secret_id}
    ${ENCODED_KUBECONFIG}    CLR.get_kubeconfig_by_secretId    ${secret_id}    ${REST_CONN}
    Set Test Variable    ${ENCODED_KUBECONFIG}

Check the log files in node
    ${output}    CLR.check_the_logs_exist_in_node    ${NODE_NAME}
    Should Contain    ${output}    audit    The audit logs should exist in node.
    Should Contain    ${output}    containers    The containers logs should exist in node.
    Should Contain    ${output}    journal    The journal logs should exist in node.

Generate kubeconfig file
    CLR.generate_decoded_kubeconfig_file    ${ENCODED_KUBECONFIG}

Get the audit log in node
    ${output}    CLR.get_audit_log_size_in_node    ${NODE_NAME}
    Should Not Contain    ${output}    No such file or directory    The audit log should exist!
    Should Be True    ${output} > 0    The size of audit log file should larger than 0.

Collect log test teardown
    ${output}    CLR.clear_collected_logs_in_neat
    Should Contain    ${output}    No such file or directory    The temp work folder should not exist!
    common_test_teardown_for_infra
