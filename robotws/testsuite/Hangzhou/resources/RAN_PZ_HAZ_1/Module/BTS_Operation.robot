*** Settings ***
Documentation
...    Author: He winnie, Xiang Liangliang
...    Contact: winnie.he@nokia-sbell.com, liang.xiang@nokia-sbell.com
...    Common KWs use to operate the bts
...    All the bugs/new keyword needs/improvement should be raised in Jira and assign to the authors.
...    Jira link: https://jiradc.ext.net.nokia.com/projects/PZ1HAZTA/issues
...    Guidelines for user: https://confluence.ext.net.nokia.com/display/SRANPRODHZHTA/02.+Module+of+BTS+Operation
...    Examples: https://wrgitlab.int.net.nokia.com/RAN/robotws/-/tree/master/testsuite/Hangzhou/resources/RAN_PZ_HAZ_1/Module/Module_Test

# Resource    Base_Model.robot
Resource    ./library/_classical_bts_base.robot
# Resource    ../../../RRM/RAN_PZ_HAZ_1/Resources/Classical/RRM_MultiBTS_Common_Resource.robot
Resource    ./library/_Cloud_Bts_Operation.robot

*** Keywords ***
BTS Operation
    [Arguments]    ${operation}
    ...    ${product_type}=gnb  #enb
    ...    ${bts_index}=${0}
    ...    ${cudu_index}=${0}
    ...    ${distname_id}=${None}
    ...    ${need_verify}=${True}
    ...    ${verify_status}=${None}
    ...    ${timeout}=${None}
    ...    &{kwargs}
    [Documentation]     this keyword contain the classical BTS normal operation
    ...    operation can support:
    ...    cell_lock, cell_unlock, cell_block, cell_unblock, cell_reset
    ...    cell_group_lock, cell_group_unlock
    ...    rat_block, rat_unblock, rat_reset
    ...    bts_lock, bts_unlock, bts_block, bts_unblock, bts_reset,
    ...    ru_lock, ru_unlock, bbmod_lock, bbmod_unlock, ru_reset, bbmod_reset
    ...    nglink_lock, nglink_unlock, x2link_lock, x2link_unlock
    ...    upgrade,downgrade
    ...    verify : CELL_ONAIR CELL_BLOCK CELL_LOCK  BBU_ONAIR RRU_ONAIR BBU_LOCK RRU_LOCK
    ...    SITE_ONAIR
    ...   Author: winnie he
    ...   Contact: winnie.he@nokia-sbell.com
    ...   | Input Parameters | Man. | Description |
    ...   | operation  | yes | operation can support  |
    ...   |            |     | cell_lock, cell_unlock, cell_block, cell_unblock, cell_reset |
    ...   |            |     | cell_group_lock, cell_group_unlock |
    ...   |            |     | rat_block, rat_unblock, rat_reset |
    ...   |            |     | bts_lock, bts_unlock, bts_block, bts_unblock, bts_reset |
    ...   |            |     | ru_lock, ru_unlock, bbmod_lock, bbmod_unlock, ru_reset, bbmod_reset |
    ...   |            |     | nglink_lock, nglink_unlock, x2link_lock, x2link_unlock |
    ...   |            |     | verify : CELL_ONAIR CELL_BLOCK CELL_LOCK  BBU_ONAIR RRU_ONAIR BBU_LOCK RRU_LOCK |
    ...   |            |     | SITE_ONAIR,upgrade,downgrade,rollback |
    ...   | connection | No | you can input an existed connection or input bts id and du id, |
    ...   |            |    | kw will generate a connection and destroy it after operation done |
    ...   | bts_index | No | the index of the bts in tl's init.py, ${tl.gnbs[gnb_index]} |
    ...   | vdu_vcu_index | No |  the index of the bts du in tl's init.py, ${tl.gnbs[gnb_index].dus[vdu_vcu_index]} |
    ...   | distname_id | No | the name of the object you need to operation,  |
    ...   |             |    | just the postfix of distname id is ok,like BBMOD-1 |
    ...   | need_verify | No | After operation if you need to verify the result, default is yes,  |
    ...   |             |    | invalid when operation is verify, or some link operation like nglink_lock |
    ...   | verify_status | No | only useful for verify operation, if you need to check SITE_ONAIR and BBU_ONAIR |
    ...   |               |    | please input verify_status=${${SITE_ONAIR}+${BBU_ONAIR}} |
    ...   | timeout | No | Mostly you no need to change this value, most of operation have their own default time |
    ...   | site_type | No | default just supported the classical |
    ${product_type}    Convert To Lower Case    ${product_type}
    Run Keyword If    '${product_type}' in ["enb", "gnb"]
    ...    Classical BTS Operation    operation=${operation}
    ...    product_type=${product_type}
    ...    gnb_index=${bts_index}
    ...    cudu_index=${cudu_index}
    ...    distname_id=${distname_id}
    ...    need_verify=${need_verify}
    ...    connection=${None}
    ...    verify_status=${verify_status}
    ...    timeout=${timeout}
    ...    kwargs=${kwargs}
    ...    ELSE IF    '${product_type}'=="vcu"
    ...    Cloud BTS Operation for VCU    operation=${operation}
    ...    gnb_index=${bts_index}
    ...    cudu_index=${cudu_index}
    ...    distname_id=${distname_id}
    ...    need_verify=${need_verify}
    ...    verify_status=${verify_status}
    ...    timeout=${timeout}
    ...    kwargs=${kwargs}
    ...    ELSE IF    '${product_type}'=="vdu"
    ...    Cloud BTS Operation for VDU    operation=${operation}
    ...    gnb_index=${bts_index}
    ...    cudu_index=${cudu_index}
    ...    distname_id=${distname_id}
    ...    need_verify=${need_verify}
    ...    verify_status=${verify_status}
    ...    timeout=${timeout}
    ...    kwargs=${kwargs}
