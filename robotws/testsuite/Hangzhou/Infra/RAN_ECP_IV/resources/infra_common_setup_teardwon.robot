*** Settings ***
Library           python/sshi.py

*** Keywords ***
common_suite_setup_for_infra
    ${neat_ssh}    Set Variable    ${tl.neat.ssh_details}
    Set Suite Variable    &{NEATHOST_SSH_ACCESS}    ip=${neat_ssh.addr}    username=${neat_ssh.username}    password=${neat_ssh.password}    keyfile=
    ${neat_rest}    Set Variable    ${tl.neat.api_connection_details}
    Set Suite Variable    &{NEAT_REST_ACCESS}    ip=${neat_rest.addr}    username=${neat_rest.username}    password=${neat_rest.password}
    ${nadcm_s}    Set Variable    ${tl.nadcm.ssh_details}
    Set Suite Variable    &{NADCMHOST_SSH_ACCESS}    ip=${nadcm_s.addr}    username=${nadcm_s.username}    password=${nadcm_s.password}    keyfile=
    ${nadcm_rest}    Set Variable    ${tl.nadcm.api_connection_details}
    Set Suite Variable    &{NADCM_REST_ACCESS}    ip=${nadcm_rest.addr}    username=${nadcm_rest.username}    password=${nadcm_rest.password}
    ${vcu_ssh}    Set Variable    ${tl.gnbs[0].cu.oam_ssh_connection_details}
    Set Suite Variable    &{VCU_OCP_SSH_ACCESS}    ip=${vcu_ssh.addr}    username=${vcu_ssh.username}    password=${vcu_ssh.password}    keyfile=
    ${vdu_ssh}    Set Variable    ${tl.gnbs[0].dus[0].cloud_deployment.cloud_hosting.master_node.ssh_connection_details}
    Set Suite Variable    &{VDU_OCP_SSH_ACCESS}    ip=${vdu_ssh.addr}    username=${vdu_ssh.username}    password=${vdu_ssh.password}    keyfile=

common_suite_teardown_for_infra
    log    This is a placeholder for the common phase of the suite teardown

common_test_setup_for_infra
    log    This is a placeholder for the common phase of the test setup

common_test_teardown_for_infra
    sshi.disconnect_all
