*** Settings ***
Documentation
...   author: zhichao.shu@nokia-sbell.com
...   contact: zhichao.shu@nokia-sbell.com
...   SISO

Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/lines/MMW_SG4/SISO_common_operation.robot

*** Variables ***
${BTS_ID}                     ${tl.gnbs[0].instance_id}
${gnb_ip}                     ${tl.gnbs[0].dus[0].f1_m_ip_addr}
@{cablink_list}    2    3
@{speed_values_list}    eCpri10    eCpri25
@{ru_serial_list}    EB2232R0689    EB2232R0703    EB2232R0707

*** Keywords ***
Case Teardown
    [Arguments]    ${bts_host}=${gNB_ip}    ${allowed_list}=${allowed_alarm_list}
    robot_common_operations.Common case Teardown
    Run Keyword if    "${TEST_STATUS}"=="FAIL"    Save Snapshot
    Run Keyword if    "${TEST_STATUS}"=="FAIL"    Capture LMI Log    ru_serial_list=${ru_serial_list}    gnb_index=${0}
#    Setup Commission SCF
    wait until keyword succeeds    10 min    20 sec    Check GNB on air And alarm    bts_host=${bts_host}
        ...    allowed_list=${allowed_list}
    ${status}    Run Keyword And Return Status    Check GNB on air And alarm    bts_host=${bts_host}
        ...    allowed_list=${allowed_list}
    Run Keyword if    ${status} == ${false}    Save Snapshot
    Run Keyword if    ${status} == ${false}    Capture LMI Log    ru_serial_list=${ru_serial_list}    gnb_index=${0}
    CI_interface.Common Case Teardown
