*** Settings ***
Documentation     author: Sherry Zhang
...         contact: sherry.1.zhang@nokia-sbell.com
...         Reset GNB and ENB cases
Resource          testsuite/Hangzhou/OAM/RAN_PZ_HAZ_34/UUF/Resource/common.robot
Resource    testsuite/Hangzhou/OAM/RAN_PZ_HAZ_34/UUF/Resource/upgrade_rollback.robot

Force Tags    SG_08    CA_5G_OAM
...    PY36

Suite Setup    test suite setup reset
Suite Teardown    test suite teardown    webui_tool=COAM


*** Test Cases ***
WebEM_UUF_GNB_Reset
    [Setup]    Test Reset Setup
    COAM Webui Reset
    [Teardown]    Test Reset Teardown    GNB_reset

WebEM_UUF_ENB_Reset
    [Setup]    run keyword if    '${bts_id}' in @{Concurrent_BTS_ID} or '${bts_id}' in @{Multi_BTS_ID}    Test Reset Setup
    run keyword if    '${bts_id}' in @{Concurrent_BTS_ID} or '${bts_id}' in @{Multi_BTS_ID}    COAM Webui Reset    enb
    [Teardown]    run keyword if    '${bts_id}' in @{Concurrent_BTS_ID} or '${bts_id}' in @{Multi_BTS_ID}    Test Reset Teardown    ENB_reset