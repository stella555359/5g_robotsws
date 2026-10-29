*** Settings ***
Documentation
...    author: Ulm SQD 65
...    Team: 'MN RAN L3 SW ULM L3NRT SQD 65'
...    Description: Updates scf file in topology-configs dir. according current/running TL cfg
...                 after passing UTE Cloud Acceptance Test
...    Email: 'I_MN_RAN_L3_SW_ULM_SQD_65@internal.nsn.com'


Library           ./NIDD_update.py
Library           ./getScfNameFromConfig.py

Resource          ./UteCloudAcceptanceTest_Keywords.robot

Suite Setup       Prepare TL for Ute Cloud Acceptance Test
Suite Teardown    dcap.stop dcap container for all nodes

Test Setup        Perform Preconditions of Test Case
Test Teardown     Perform Postconditions of Test Case

*** Variables ***

@{IP_LIST_eth3_add}                   10.0.1.200  10.0.1.201
@{IP_LIST_eth4_add}                   10.0.2.90

${AUTO_MERGE}                         true
${GIT_USER_TOKEN}                     glpat-9HUivavzXeDnt5xsL2zH
${GIT_USER_NAME}                      givrf
${GIT_USER_EMAIL}                     gitulm.1.vrf@nokia.com
${GIT_SERVER}                         gitlabe2.ext.net.nokia.com
${TOPOLOGY_CONFIG_PROJECT}            ${GIT_SERVER}/uca/ran/topology-configs
${TOPOLOGY_CONFIG_PROJECT_ID}         39803
${TOPOLOGY_LABEL}                     CLOUD_5G_I_MP_AP_LOOO
${TOPOLOGY_VARIANT}                   SANSA_FS_ECPRI_CMWV_TDD
${TOPOLOGY_CONFIG_DIR}                /home/ute/topology-configs

*** Test Cases ***

Topology-Configs NIDD update
    [Documentation]   wrapper for KW Topology-Configs NIDD update
    KW Topology-Configs NIDD update

[1]CLOUD_5G_I_MP_AP_LOOO_NIDD_update
    [Documentation]   wrapper for KW Topology-Configs NIDD update
    ...               VARIANT_SANSA_FS_ECPRI_CMWV_TDD
    KW Topology-Configs NIDD update

[2]CLOUD_5G_I_MP_AP_LOOO_NIDD_update
    [Documentation]   wrapper for KW Topology-Configs NIDD update
    ...               VARIANT_SANSA_FS_CPRI_CMWV_FDD
    KW Topology-Configs NIDD update

[1]CLOUD_5G_I_[LO][LO]_AP_[LOO]_NIDD_update
    [Documentation]   wrapper for KW Topology-Configs NIDD update
    ...               VARIANT_PRIVATE_SANSA_FDD+TDD_2CC_INTER_GNB_CA_MOBILITY_CB008574
    KW Topology-Configs NIDD update

[2]CLOUD_5G_I_[LO][LO]_AP_[LOO]_NIDD_update
    [Documentation]   wrapper for KW Topology-Configs NIDD update
    ...               VARIANT_PRIVATE_CNI-88819
    KW Topology-Configs NIDD update

*** Keywords ***

KW Topology-Configs NIDD update
    [Documentation]  based on: robotws/testsuite/Bangalore/AirPhone/AP_P1/Sample_tests/NIDD_Sample_Tests.robot
#    UTE Cloud Acceptance Test
    Clone and Configure topology-configs repo
    Get Topology from Common Agent File
    ${branch}=           Get gNB SW Branch

    FOR    ${gnb_id}    IN RANGE    ${GNB_NUM}
        ${scf_node}          Remove String      ${SQD_ORIG_SCF_${gnb_id}}   .orig
        Set Suite Variable   ${scf_node_${gnb_id}}    ${scf_node}
        ${scf_name_cfg}      Get Scf File From Config
        ...                  config_file=${TOPOLOGY_CONFIG_DIR}/${TOPOLOGY_LABEL}/${branch}/config.yaml
        ...                  variant_name=${TOPOLOGY_VARIANT}
        ...                  node=${gnb_id}

        ${scf_repo}          Set Variable                    ${TOPOLOGY_LABEL}/${branch}/${scf_name_cfg}
        ${nidd_scf_repo}     Get Nidd Version From SCF File  ${TOPOLOGY_CONFIG_DIR}/${scf_repo}
        IF       '${nidd_scf_repo}' == 'None'    Fail  Nidd Version not found in ${nidd_scf_repo}

        ${nidd_scf_node}     Get Nidd Version From SCF File  ${scf_node_${gnb_id}}
        IF       '${nidd_scf_node}' == 'None'    Fail  Nidd Version not found in ${scf_node_${gnb_id}}
        Set Suite Variable   ${nidd_scf_node_${gnb_id}}      ${nidd_scf_node}

        OperatingSystem.Run  echo "" >> ${scf_node_${gnb_id}}

        ${branch_name}       Replace String  ${nidd_scf_node_${gnb_id}}_${TOPOLOGY_LABEL}_${TOPOLOGY_VARIANT}_${gnb_id}  [  (
        ${branch_name}       Replace String  ${branch_name}  ]  )

        IF   '${nidd_scf_node_${gnb_id}}' != '${nidd_scf_repo}'
            Update Topologyconfig Repo    auto_merge_flag=${AUTO_MERGE}
            ...                           URL=https://${GIT_SERVER}
            ...                           private_token=${GIT_USER_TOKEN}
            ...                           project_id=${TOPOLOGY_CONFIG_PROJECT_ID}
            ...                           branch_name=${branch_name}
            ...                           repo_file_path=${scf_repo}
            ...                           tl_file_path=${scf_node_${gnb_id}}
            ...                           nidd_version=${nidd_scf_node_${gnb_id}}
            ...                           topology=${TOPOLOGY_LABEL}_${TOPOLOGY_VARIANT}
        END
    END

UTE Cloud Acceptance Test
    [Documentation]
    ...    Execute basic L3 call with traffic as acceptance test for new UTE Cloud topology
    ...    Assumptions:
    ...    Cells:   1  ... n
    ...    SA UEs:  1  ... n
    ...    NSA UEs; 11 ... 10+n
    ${UEs} =                   Get number of all configured NRCELLs
    Attach SA UEs              count=${UEs}
    Attach NSA UEs             count=${UEs}
    Start Traffic on SA UEs    count=${UEs}
    Start Traffic on NSA UEs   count=${UEs}
    Sleep                      600s          reason=Apply traffic for (at least) 10 minutes
    Check Traffic for SA UEs   count=${UEs}
    Check Traffic for NSA UEs  count=${UEs}
    Stop Traffic on SA UEs     count=${UEs}
    Stop Traffic on NSA UEs    count=${UEs}
    Detach SA UEs              count=${UEs}
    Detach NSA UEs             count=${UEs}

Clone and Configure topology-configs repo
    FOR  ${_}  IN RANGE   2
       Remove Directory     ${TOPOLOGY_CONFIG_DIR}  recursive=True
       ${rc}  ${output}     Run And Return Rc And Output
       ...                  git clone https://${GIT_USER_NAME}:${GIT_USER_TOKEN}@${TOPOLOGY_CONFIG_PROJECT} ${TOPOLOGY_CONFIG_DIR}
       IF   ${rc} == ${0}   BREAK
    END
    Should Be Equal As Integers  ${rc}   0


Get Topology from Common Agent File
#    [Arguments]    ${file_path}=/home/ute/testline_update_results/agent.log
    [Arguments]    ${file_path}=/home/ute/testline_init_results/agent.log
    ${file_content}           OperatingSystem.Get File    ${file_path}
    ${label_from_install}     Should Match Regexp         ${file_content}    LABEL:\\s+(\\S+)
    ${variant_from_install}   Should Match Regexp         ${file_content}    VARIANT:\\s+(\\S+)
    Set Suite Variable        ${TOPOLOGY_LABEL}           ${label_from_install[1]}
    Set Suite Variable        ${TOPOLOGY_VARIANT}         ${variant_from_install[1]}
