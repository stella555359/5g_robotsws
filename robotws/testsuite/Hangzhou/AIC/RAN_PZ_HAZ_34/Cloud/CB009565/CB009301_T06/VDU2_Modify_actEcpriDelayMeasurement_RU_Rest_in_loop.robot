*** Settings ***
Documentation
...  author: Han Ruiyu
...  contact: ruiyu.han@nokia-sbell.com

Resource   testsuite/Hangzhou/AIC/RAN_PZ_HAZ_34/Cloud/CB009565/siso_common_case/Resource/common.robot


*** Variables ***
${times}    50
${gnb_index}    ${0}
${vdu_index}    ${1}
${egen_exist}   ${False}
${btslog_pc_addr}    ${tl.test_pcs[3].default_ssh_connection_details.addr}
${btslog_pc_username}    ${tl.test_pcs[3].default_ssh_connection_details.username}
${btslog_pc_password}    ${tl.test_pcs[3].default_ssh_connection_details.password}

*** Test Cases ***
Modify actEcpriDelayMeasurement with RU Rest in loop
    [Documentation]  Modify actEcpriDelayMeasurement in loop
    [Tags]
    [Setup]    Case Setup for CB009301


    FOR    ${time}    IN RANGE    ${times}
        Log To Console    this is ${time} time Modify actEcpriDelayMeasurement!
        Single_Cloud_Modify_actEcpriDelayMeasurement_with_RU_Rest
    END

    [Teardown]   Run Keyword And Ignore Error   VDU Siso Common Save Logs

