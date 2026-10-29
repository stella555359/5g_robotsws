*** Settings ***
Documentation
    ...    Author: yin.4.chen@nokia-sbell.com

Resource    ./Resource/Common.robot

Suite Setup   UUF Common Suite Setup
Suite Teardown   UUF Common Suite Teardown

*** Variables ***
${origin_version}
${upgrade_version}
${enb_source_version}
${enb_target_version}

${NETACT_IP}

${TEST_MODE}            UUF
${DEBUG}                ${False}
${l3_call}              N


*** Test Cases ***
UUF_SW_Activation_Reset_T1
    [Setup]   UUF Common Test Setup
    Log To Console   ${EMPTY}
    # UUF Pass Execution
    UUF Process WebEM Reset Activation
    run keyword if   ('${TESTLINE_IDENTITY}' in ${E2E_TL})
    ...   run keyword if  ${l3_call.count('Y')}>0 and ('${TESTLINE_IDENTITY}' in ${UUF_L3Call})
    ...   UUF Target Packge L3CALL Process
    [Teardown]   UUF Common Test Teardown

UUF_SW_Activation_Reset
    [Setup]   UUF Common Test Setup
    Log To Console   ${EMPTY}
    # UUF Pass Execution
    UUF Process WebEM Reset Activation
    run keyword if   ('${TESTLINE_IDENTITY}' in ${E2E_TL})
    ...   run keyword if  ${l3_call.count('Y')}>0 and ('${TESTLINE_IDENTITY}' in ${UUF_L3Call})
    ...   UUF Target Packge L3CALL Process
    [Teardown]   UUF Common Test Teardown
