*** Settings ***
Documentation
...  author: Han Ruiyu
...  contact: ruiyu.han@nokia-sbell.com

Resource   testsuite/Hangzhou/AIC/RAN_PZ_HAZ_34/Cloud/CB009565/siso_common_case/Resource/common.robot


*** Variables ***
${times}    50
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
    [Setup]    run keywords    Recovery at Case Setup
     ...   AND   Single Online Modify actEcpriDelayMeasurement    actEcpriDelayMeasurement_value=true

    FOR    ${time}    IN RANGE    ${times}
        ${CASE_PROCESS_START}   DateTime.Get Current Date   result_format=epoch
        Log To Console   CASE_PROCESS_START: ${CASE_PROCESS_START}
        Set Test Variable   ${CASE_PROCESS_START}
        Log To Console    this is ${time} time Modify actEcpriDelayMeasurement!

        Cloud_SiSo_Common_vDU_RU_Reset_Keywords

        VDU Syslog Should Not Contain    filter=SBbbMsg5DelayResult    shouldnotcontain_str=EStatus_Timeout


    END

    [Teardown]   Run Keyword And Ignore Error   VDU Siso Common Save Logs

