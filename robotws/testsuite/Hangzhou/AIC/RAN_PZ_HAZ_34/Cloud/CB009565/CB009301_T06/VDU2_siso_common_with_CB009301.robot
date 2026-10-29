*** Settings ***
Documentation
...  author: Han Ruiyu
...  contact: ruiyu.han@nokia-sbell.com

Resource   testsuite/Hangzhou/AIC/RAN_PZ_HAZ_34/Cloud/CB009565/siso_common_case/Resource/common.robot


*** Variables ***
${times}    50
${gnb_index}    ${0}
${vdu_index}    ${1}
${rulog_exist}    ${False}
${egen_exist}   ${False}
${btslog_pc_addr}    ${tl.test_pcs[3].default_ssh_connection_details.addr}
${btslog_pc_username}    ${tl.test_pcs[3].default_ssh_connection_details.username}
${btslog_pc_password}    ${tl.test_pcs[3].default_ssh_connection_details.password}

*** Test Cases ***
VDU reset with actEcpriDelayMeasurement true
    [Documentation]  Modify actEcpriDelayMeasurement in loop
    [Tags]
    [Setup]    Recovery at Case Setup
    ${CASE_PROCESS_START}   DateTime.Get Current Date   result_format=epoch
    Log To Console   CASE_PROCESS_START: ${CASE_PROCESS_START}
    Set Test Variable   ${CASE_PROCESS_START}
    Single Online Modify actEcpriDelayMeasurement    actEcpriDelayMeasurement_value=true


    FOR   ${i}   IN RANGE   ${times}
        Log To Console    this is ${i} VDU Reset !
        run keyword if  ${rulog_exist}    VDU RU Log Operation Setup in Siso Common
        Cloud_SiSo_Common_vDU_Reset_Keywords
    END

RU reset with actEcpriDelayMeasurement true
    [Documentation]  Modify actEcpriDelayMeasurement in loop
    [Tags]
    [Setup]    Recovery at Case Setup
    ${CASE_PROCESS_START}   DateTime.Get Current Date   result_format=epoch
    Log To Console   CASE_PROCESS_START: ${CASE_PROCESS_START}
    Set Test Variable   ${CASE_PROCESS_START}
#    Single Online Modify actEcpriDelayMeasurement    actEcpriDelayMeasurement_value=true


    FOR   ${i}   IN RANGE   ${times}
        Log To Console    this is ${i} RU_Reset!
        run keyword if  ${rulog_exist}    VDU RU Log Operation Setup in Siso Common
        Cloud_SiSo_Common_vDU_RU_Reset_Keywords
    END

    [Teardown]   Run Keyword And Ignore Error   VDU Siso Common Save Logs

Rannic reset with actEcpriDelayMeasurement true
    [Documentation]  Modify actEcpriDelayMeasurement in loop
    [Tags]
    [Setup]    Recovery at Case Setup
    ${CASE_PROCESS_START}   DateTime.Get Current Date   result_format=epoch
    Log To Console   CASE_PROCESS_START: ${CASE_PROCESS_START}
    Set Test Variable   ${CASE_PROCESS_START}
#    Single Online Modify actEcpriDelayMeasurement    actEcpriDelayMeasurement_value=true


    FOR   ${time}    IN RANGE   ${times}
        Log To Console    this is ${time} Rannic_Reset !
        run keyword if  ${rulog_exist}    VDU RU Log Operation Setup in Siso Common
        Single_Cloud_SiSo_Common_vDU_Rannic_Reset
    END

    [Teardown]   Run Keyword And Ignore Error   VDU Siso Common Save Logs


VDU reset with actEcpriDelayMeasurement false
    [Documentation]  Modify actEcpriDelayMeasurement in loop
    [Tags]
    [Setup]    Recovery at Case Setup
    ${CASE_PROCESS_START}   DateTime.Get Current Date   result_format=epoch
    Log To Console   CASE_PROCESS_START: ${CASE_PROCESS_START}
    Set Test Variable   ${CASE_PROCESS_START}
    Single Online Modify actEcpriDelayMeasurement    actEcpriDelayMeasurement_value=false


    FOR   ${i}   IN RANGE   ${times}
        Log To Console    this is ${i} VDU Reset !
        run keyword if  ${rulog_exist}    VDU RU Log Operation Setup in Siso Common
        Cloud_SiSo_Common_vDU_Reset_Keywords
    END

RU reset with actEcpriDelayMeasurement false
    [Documentation]  Modify actEcpriDelayMeasurement in loop
    [Tags]
    [Setup]    Recovery at Case Setup
    ${CASE_PROCESS_START}   DateTime.Get Current Date   result_format=epoch
    Log To Console   CASE_PROCESS_START: ${CASE_PROCESS_START}
    Set Test Variable   ${CASE_PROCESS_START}
#    Single Online Modify actEcpriDelayMeasurement    actEcpriDelayMeasurement_value=true


    FOR   ${i}   IN RANGE   ${times}
        Log To Console    this is ${i} RU_Reset!
        run keyword if  ${rulog_exist}    VDU RU Log Operation Setup in Siso Common
        Cloud_SiSo_Common_vDU_RU_Reset_Keywords
    END

    [Teardown]   Run Keyword And Ignore Error   VDU Siso Common Save Logs

Rannic reset with actEcpriDelayMeasurement false
    [Documentation]  Modify actEcpriDelayMeasurement in loop
    [Tags]
    [Setup]    Recovery at Case Setup
    ${CASE_PROCESS_START}   DateTime.Get Current Date   result_format=epoch
    Log To Console   CASE_PROCESS_START: ${CASE_PROCESS_START}
    Set Test Variable   ${CASE_PROCESS_START}
#    Single Online Modify actEcpriDelayMeasurement    actEcpriDelayMeasurement_value=true


    FOR   ${time}    IN RANGE   ${times}
        Log To Console    this is ${time} Rannic_Reset !
        run keyword if  ${rulog_exist}    VDU RU Log Operation Setup in Siso Common
        Single_Cloud_SiSo_Common_vDU_Rannic_Reset
    END

    [Teardown]   Run Keyword And Ignore Error   VDU Siso Common Save Logs
