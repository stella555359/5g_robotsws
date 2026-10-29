*** Settings ***
Documentation     author: Ruiyu Han
...               contact: ruiyu.han@nokia-sbell.com
...               Upgrade and Rollback UUF case.
Resource           testsuite/Hangzhou/OAM/RAN_PZ_HAZ_34/UUF/Resource/common.robot
Resource    testsuite/Hangzhou/OAM/RAN_PZ_HAZ_34/UUF/Resource/upgrade_rollback.robot

Force Tags    SG_08    CA_5G_OAM    AUTHOR_ruiyu.han@nokia-sbell.com
...    PY36

Suite Setup    test suite setup    webui_tool=COAM    upgrade_tool=netact
Suite Teardown    test suite teardown    webui_tool=COAM



*** Test Cases ***
NMS_UUF_Upgrade
    [Setup]    Test setup    upgrade_tool=netact    webui_tool=COAM   action=provision
    run keyword if   '${bts_id}' in @{Concurrent_BTS_ID}   Concurrent NetAct Upgrade
    ...   ELSE IF   '${bts_id}' in @{Multi_BTS_ID}  MultiGnb NetAct Upgrade
    ...   ELSE IF   ${if_moran}   Moran NetAct Upgrade
    ...    ELSE    COAM NetAct Upgrade
    [Teardown]    Test UUF Teardown     dir=provision    upgrade_tool=netact

NMS_UUF_Rollback
    [Setup]    run keywords    Check If Active Software Version Updated
    ...   AND   run keyword if    ${if_moran}    Check If Active Software Version Updated    provision    ${Peer_WEBUI_ADDR}
    ...   ${enb_target_version}    ${enb_source_version}
    ...   AND   Test setup    upgrade_tool=netact    webui_tool=COAM   action=rollback
    run keyword if   '${bts_id}' in @{Concurrent_BTS_ID}   Concurrent NetAct Rollback
    ...   ELSE IF   '${bts_id}' in @{Multi_BTS_ID}  MutiGnb NetAct Rollback
    ...   ELSE IF   ${if_moran}   Moran NetAct Rollback
    ...    ELSE    COAM NetAct Rollback
    [Teardown]    Test UUF Teardown     dir=rollback    upgrade_tool=netact



