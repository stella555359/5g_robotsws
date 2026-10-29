*** Settings ***

Library           taf.gnb.oam.coam.vdu.interface.Vdu    WITH NAME    vdu
Library           taf.transport.ssh                     WITH NAME    tafssh

*** Variables ***
${G_VDU_NAME}           vdu1
${CLUSTER_NAME}         cran1
${G_USER}               core



*** Keywords ***
Collect Logs
    [Arguments]    ${endswith}=${TEST NAME}
    [Documentation]  Collect Logs
    ...  author: miao.a.cao@nokia-sbell.com
    ...    | Input Parameters | Man. | Description |
    ...    | endswith    | yes | endswith, e.g, test name |
    ...
    ...    *RETURN VALUE*
    ...    datetime
    ...
    ...    Example
    ...   | Collect Logs | endswith=testname |
    ${time}=    Get Current Date
    ${datetime}=    Convert Date    ${time}    result_format=%Y%m%d%H%M%S
    ${case_name}=    Convert Case Name    ${endswith}
    Create Directory    ${CURDIR}/../results/${datetime}_${case_name}
    [Return]    ${datetime}

Collect Logs And Teardown
    [Timeout]    60s
    [Documentation]  Collect Logs And Teardown
    ...  author: miao.a.cao@nokia-sbell.com
    ...    | Input Parameters | Man. | Description |
    ...    None
    ...
    ...    *RETURN VALUE*
    ...    None
    ...
    ...    Example
    ...   | Collect Logs And Teardown |
    Run Keyword If Test Failed    Collect OAM Logs
    ${case_name}=    Convert Case Name    ${TEST NAME}
    Run Keyword If Test Passed    Run    rm -rf ${CURDIR}/../results/*${case_name}

Collect OAM Logs
    [Documentation]  Collect OAM Logs
    ...  author: miao.a.cao@nokia-sbell.com
    ...    | Input Parameters | Man. | Description |
    ...    None
    ...
    ...    *RETURN VALUE*
    ...    None
    ...
    ...    Example
    ...   | Collect OAM Logs |
    csn.Connect To   ${ncir_addr}   ${ncir_tenant}   ${ncir_password}   alias=collect_log
    ${case_name}=    Convert Case Name    ${TEST NAME}
    ${config_info}   csn.Execute   kubectl logs ${G_OAM_PODS_NAME} -c oam >> /home/core/${case_name}.${G_OAM_PODS_NAME}.log
    ...    connection=collect_log

Collect vDU Snapshot
    [Arguments]      ${SNAPSHOT}
    vdu.Get_Local_Snapshot  ${SNAPSHOT}

Collect Container Logs
    [Arguments]    ${pod_name}    ${container_name}     ${log_path}=/home/${G_USER}
    [Documentation]  Collect Container Logs
    ...  author: yingguo.ying@nokia-sbell.com
    ...    | Input Parameters | Man. | Description |
    ...    | chart_path    | yes | chart_path, e.g, HelmChart/aic-vdu |
    ...    | ns    | yes | namespace, e.g, eituser1 |
    ...
    ...    *RETURN VALUE*
    ...    None
    ...
    ...    Example
    ...   | Collect Container Logs | pod_name=po-eit1-oam-0 | container_name=oam |
    tafssh.Execute      command=mkdir ${log_path}
    wait until keyword succeeds  2min   60s   tafssh.Execute
    ...     kubectl logs ${pod_name} -c ${container_name} -n ${CLUSTER_NAME} > ${log_path}/${G_VDU_NAME}.${container_name}.log
