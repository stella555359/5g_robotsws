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
WebEM_UUF_Upgrade
    [Setup]   UUF Common Test Setup
    Log To Console   ${EMPTY}
    # UUF Pass Execution
    run keyword if  ${l3_call.count('Y')}>0 and ('${TESTLINE_IDENTITY}' in ${UUF_L3Call})   UUF Source Packge L3CALL Process
    UUF Process WebEM Upgrade
    [Teardown]   UUF Common Test Teardown

WebEM_UUF_Rollback
    [Setup]    UUF Common Test Setup
    Log To Console   ${EMPTY}
    # UUF Pass Execution
    UUF Process WebEM Rollback
    [Teardown]    UUF Common Test Teardown
