*** Settings ***
Documentation
...  author: Han Ruiyu
...  contact: ruiyu.han@nokia-sbell.com

Resource   testsuite/Hangzhou/AIC/RAN_PZ_HAZ_34/Cloud/CB009565/siso_common_case/Resource/common.robot


*** Variables ***
${times}    20
${gnb_index}    ${0}
${vdu_index}    ${0}
${egen_exist}   ${False}
${btslog_pc_addr}    ${tl.test_pcs[2].default_ssh_connection_details.addr}
${btslog_pc_username}    ${tl.test_pcs[2].default_ssh_connection_details.username}
${btslog_pc_password}    ${tl.test_pcs[2].default_ssh_connection_details.password}

*** Test Cases ***
Modify actEcpriDelayMeasurement in loop
    [Documentation]  Modify actEcpriDelayMeasurement in loop
    [Tags]
    [Setup]    Recovery at Case Setup


    FOR    ${time}    IN RANGE    ${times}
        Log To Console    this is ${time} times Modify actEcpriDelayMeasurement!
        Single_Modify_actEcpriDelayMeasurement_in_loop
    END

    [Teardown]   run keywords   VDU Siso Common Each Time Teardown
    ...   AND   Run Keyword And Ignore Error   VDU Siso Common Save Logs
