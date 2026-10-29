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
NMS_UUF_Upgrade
    [Setup]   UUF Common Test Setup
    Log To Console   ${EMPTY}
    # UUF Pass Execution
    IF   ${INDEPENDENT_DU_SW_UPGRADE}
        UUF Process NetAct Upgrade Independent
    ELSE
        UUF Process NetAct Upgrade
    END
    [Teardown]   UUF Common Test Teardown

NMS_UUF_Rollback
    [Setup]    UUF Common Test Setup
    Log To Console   ${EMPTY}
    # UUF Pass Execution
    UUF Process NetAct Rollback
    [Teardown]    UUF Common Test Teardown
