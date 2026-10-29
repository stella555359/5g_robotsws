*** Settings ***
Documentation     author: Ruiyu Han
...               contact: ruiyu.han@nokia-sbell.com
...               Upgrade and Rollback UUF case.
Resource          testsuite/Hangzhou/OAM/RAN_PZ_HAZ_34/UUF/Resource/common.robot
Resource    testsuite/Hangzhou/OAM/RAN_PZ_HAZ_34/UUF/Resource/upgrade_rollback.robot

Force Tags    SG_08    CA_5G_OAM    AUTHOR_ruiyu.han@nokia-sbell.com
...    PY36

Suite Setup    test suite setup    webui_tool=COAM    upgrade_tool=webui
Suite Teardown    test suite teardown    webui_tool=COAM


*** Test Cases ***
WebEM_UUF_Upgrade
    [Setup]    Test setup   upgrade_tool=webui   webui_tool=COAM   action=provision
    run keyword if   '${bts_id}' in @{Concurrent_BTS_ID}   Concurrent Webui Upgrade
    ...   ELSE IF    '${bts_id}' in @{Multi_BTS_ID}  MultiGnb Webui Upgrade
    ...   ELSE IF   ${if_moran}   Moran Webui Upgrade
    ...    ELSE    COAM Webui Upgrade
    [Teardown]    Test UUF Teardown     dir=provision    upgrade_tool=webui

WebEM_UUF_Rollback
    [Setup]    run keywords    Check If Active Software Version Updated
    ...   AND   run keyword if    ${if_moran}    Check If Active Software Version Updated    provision    ${Peer_WEBUI_ADDR}
    ...   ${enb_target_version}    ${enb_source_version}
    ...   AND   Test setup   upgrade_tool=webui    webui_tool=COAM   action=rollback
    run keyword if   '${bts_id}' in @{Concurrent_BTS_ID}    Concurrent Webui Rollback
    ...   ELSE IF   '${bts_id}' in @{Multi_BTS_ID}  MultiGnb Webui Rollback
    ...   ELSE IF   ${if_moran}   Moran Webui Rollback
    ...    ELSE    COAM Webui Rollback
    [Teardown]    Test UUF Teardown     dir=rollback    upgrade_tool=webui
