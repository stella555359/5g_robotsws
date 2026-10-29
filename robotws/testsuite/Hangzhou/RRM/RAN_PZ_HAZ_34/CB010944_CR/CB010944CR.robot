*** Settings ***
Documentation    author：Changsheng chen
...              contact: c
...              squad group: mmw_SG_12


Resource    ./Resources/CB010944_common_keyword.robot
Resource    ./Resources/CB010944_common.robot
Variables   ./Resources/TLConfigration_10944.py
Library     ./Resources/CB010944_counter_in_logs.py

Library    taf.transport.ssh    WITH NAME    csn
Resource          testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/CI_Operations/CI_interface.robot

Library    Process
Library    taf.converters.eventdecoder    WITH NAME    ctti
Library    taf.collectors.tcpdump    WITH NAME    tcpdump
Library    taf.collectors.l2stream3    WITH NAME    l2stream3
Library    taf.collectors.core    WITH NAME    core
Library     taf.gnb.oam.coam.vdu    WITH NAME    vdu


*** Variables ***
${cell_id}     1
${DU_IP}              ${tl.gnbs[0].dus[0].cloud_deployment.cloud_hosting.master_node.ssh_connection_details.addr}
${DU_username}        ${tl.gnbs[0].dus[0].cloud_deployment.cloud_hosting.master_node.ssh_connection_details.username}
${DU_password}        ${tl.gnbs[0].dus[0].cloud_deployment.cloud_hosting.master_node.ssh_connection_details.password}
${vdu_namespace}      cranl37519


*** Test Cases ***
[1]CB010944-B_B3_3_Verify_load_generation_iwk_with_CB008247_and_5GC002200_CRAN
    [Tags]    1CC    NSA    SA
    Start Capture SYSLOG on vDU1    po_name=po-${vdu_namespace}-cprt-0    syslog_filename=CPRT_SYSLOG    module=ctr-${vdu_namespace}-cprt
    Start Capture SYSLOG on vDU1    po_name=po-${vdu_namespace}-l2rt-a-0    syslog_filename=L2RT_SYSLOG    module=ctr-${vdu_namespace}-l2rt
    VDU Online Change Parameters Activate    updated_paras_list=${case1_para}
    sleep    50s
    Stop Capture SYSLOG on vDU    po_name=po-${vdu_namespace}-cprt-0     module=ctr-${vdu_namespace}-cprt
    Verify emf info in CP log
    Stop Capture SYSLOG on vDU    po_name=po-${vdu_namespace}-l2rt-a-0     module=ctr-${vdu_namespace}-l2rt
    Verify emf info in PS log
    Log To Console    ${cell_id}

*** Keywords ***
########### about Spark Muliti UE ################
Start Capture SYSLOG on vDU1
    [Arguments]    ${po_name}=po-${vdu_namespace}-l2rt-a-0    ${syslog_filename}=L2RT_SYSLOG
    ...    ${connection}=DU    ${module}=ctr-${vdu_namespace}-l2rt
    csn.connect_to   hostname=${DU_IP}    username=${DU_username}    password=${DU_password}    alias=${connection}
    sleep    1s
    csn.send_command
    ...    command=kubectl logs -f -n cranl37519 ${po_name} --since=10s -c ${module} > /tmp/${syslog_filename}.txt &
    ...    connection=${connection}
    sleep    2s
    [Teardown]    run keyword and ignore error    csn.Disconnect    connection=${connection}


Stop Capture SYSLOG on vDU
    [Arguments]    ${po_name}=po-${vdu_namespace}-l2rt-a-0    ${module}=ctr-${vdu_namespace}-l2rt    ${connection}=DU
    ${component}    Evaluate    'cranl37519 ${po_name}'
    csn.connect_to   hostname=${DU_IP}    username=${DU_username}    password=${DU_password}    alias=${connection}
    sleep    1s
    ${output}    csn.execute
    ...    command=ps -ef | grep kubectl | grep '${component}' | grep '${module}' | awk '{print $2}'
    ...    connection=${connection}
    ${trace_id_list}    Strip String    string=${output}
    ${trace_id_list}    Split String    string=${output}    separator=\r\n
    log to console    \nfind pid: ${trace_id_list}
    FOR   ${trace_id}    IN    @{trace_id_list}
        ${output}    Run Keyword If    '${trace_id}'!=''    csn.execute    kill -9 ${trace_id.strip()}    connection=${connection}
        Run Keyword If    '${trace_id}'!=''    log to console    kill id: ${trace_id}
        sleep    1s
    END
    [Teardown]    run keyword and ignore error    csn.Disconnect    connection=${connection}