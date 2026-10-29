*** Settings ***
Documentation
...   Author: Du Ning
...   Contact: ning.du@nokia-sbell.com
...   Description: This is the module test case

Resource          ../Module.robot
Resource          ../../../../RRM/RAN_PZ_HAZ_1/Resources/Classical/RRM_MultiBTS_Common_Resource.robot

# Suite Setup       Common MultiBTS Suite Setup For RRM
# Test Setup        Common MultiBTS Test Setup For RRM    other_method=Return From Keyword
# Test Teardown     Common MultiBTS Test Teardown For RRM
# Suite Teardown    Common MutliBTS Suite Teardown For RRM

Library            taf.transport.ssh    WITH NAME    ssh

Force Tags        RAN_VRF_HAZ1

Test Timeout      30 minutes



*** Test Cases ***
TC01_BTS_Operation_Upgrade
    [Tags]    upgrade
    download SWB    SBTS00_ENB_9999_240709_000008
    BTS Operation    operation=upgrade    product_type=gnb    bts_index=0
    ...              sw_path=/home/ute/SBTS00_ENB_9999_240709_000008/SBTS00_ENB_9999_240709_000008_release_BTSSM_downloadable.zip

TC02_BTS_Operation_Downgrade
    [Tags]    downgrade
    download SWB    SBTS00_ENB_9999_240708_000001
    BTS Operation    operation=downgrade    product_type=gnb    bts_index=0
    ...              sw_path=/home/ute/SBTS00_ENB_9999_240708_000001/SBTS00_ENB_9999_240708_000001_release_BTSSM_downloadable.zip

BTS_Operation_Test_Single_Cell_Lock_Unlock
    BTS Operation    operation=cell_lock            product_type=gnb   bts_index=0
    ...              distname_id=NRCELL-1           need_verify=yes
    BTS Operation    operation=verify               product_type=gnb   bts_index=0
    ...              distname_id=NRCELL-1           verify_status=CELL_LOCK
    BTS Operation    operation=cell_unlock          product_type=gnb   bts_index=0
    ...              distname_id=NRCELL-1           need_verify=yes
    BTS Operation    operation=verify               product_type=gnb   bts_index=0
    ...              distname_id=NRCELL-1           verify_status=CELL_ONAIR

BTS_Operation_Test_All_Cell_Lock_Unlock
    BTS Operation    operation=cell_lock            product_type=gnb   bts_index=0
    ...              distname_id=NRCELL-ALL         need_verify=yes
    BTS Operation    operation=verify               product_type=gnb   bts_index=0
    ...              distname_id=NRCELL-ALL         verify_status=CELL_LOCK
    BTS Operation    operation=cell_unlock          product_type=gnb   bts_index=0
    ...              distname_id=NRCELL-ALL         need_verify=yes
    BTS Operation    operation=verify               product_type=gnb   bts_index=0
    ...              distname_id=NRCELL-ALL         verify_status=CELL_ONAIR

BTS_Operation_Test_Single_Cell_Block_Unblock
    BTS Operation    operation=cell_block           product_type=gnb   bts_index=0
    ...              distname_id=NRCELL-1           need_verify=yes
    BTS Operation    operation=verify               product_type=gnb   bts_index=0
    ...              distname_id=NRCELL-1           verify_status=CELL_BLOCK
    BTS Operation    operation=cell_unblock         product_type=gnb   bts_index=0
    ...              distname_id=NRCELL-1           need_verify=yes
    BTS Operation    operation=verify               product_type=gnb   bts_index=0
    ...              distname_id=NRCELL-1           verify_status=CELL_ONAIR

BTS_Operation_Test_All_Cell_Block_Unblock
    BTS Operation    operation=cell_block           product_type=gnb   bts_index=0
    ...              distname_id=NRCELL-ALL         need_verify=yes
    BTS Operation    operation=verify               product_type=gnb   bts_index=0
    ...              distname_id=NRCELL-ALL         verify_status=CELL_BLOCK
    BTS Operation    operation=cell_unblock         product_type=gnb   bts_index=0
    ...              distname_id=NRCELL-ALL         need_verify=yes
    BTS Operation    operation=verify               product_type=gnb   bts_index=0
    ...              distname_id=NRCELL-ALL         verify_status=CELL_ONAIR

BTS_Operation_Test_Single_Cell_Group_Lock_Unlock
    BTS Operation    operation=cell_group_lock      product_type=gnb   bts_index=0
    ...              distname_id=NRCELLGRP-0        need_verify=yes
    BTS Operation    operation=cell_group_unlock    product_type=gnb   bts_index=0
    ...              distname_id=NRCELLGRP-0        need_verify=yes

BTS_Operation_Test_Single_Cell_Reset
    BTS Operation    operation=cell_reset           product_type=gnb   bts_index=0
    ...              distname_id=NRCELL-1           need_verify=yes
    BTS Operation    operation=verify               product_type=gnb   bts_index=0
    ...              distname_id=NRCELL-1           verify_status=CELL_ONAIR

BTS_Operation_Test_All_Cell_Reset
    BTS Operation    operation=cell_reset           product_type=gnb   bts_index=0
    ...              distname_id=NRCELL-ALL         need_verify=yes
    BTS Operation    operation=verify               product_type=gnb   bts_index=0
    ...              distname_id=NRCELL-ALL         verify_status=CELL_ONAIR

BTS_Operation_Test_Rat_Operation
    BTS Operation    operation=rat_block            product_type=gnb   bts_index=0
    ...              distname_id=NRCELL-ALL         need_verify=yes
    BTS Operation    operation=rat_unblock          product_type=gnb   bts_index=0
    ...              distname_id=NRCELL-ALL         need_verify=yes
    BTS Operation    operation=rat_reset            product_type=gnb   bts_index=0
    ...              distname_id=NRCELL-ALL         need_verify=yes

BTS_Operation_Test_Bts_Operation
    BTS Operation    operation=bts_lock             product_type=gnb   bts_index=0    need_verify=yes
    BTS Operation    operation=bts_unlock           product_type=gnb   bts_index=0    need_verify=yes
    BTS Operation    operation=verify               product_type=gnb   bts_index=0    verify_status=SITE_ONAIR

    BTS Operation    operation=bts_block            product_type=gnb   bts_index=0    need_verify=yes
    BTS Operation    operation=bts_unblock          product_type=gnb   bts_index=0    need_verify=yes
    BTS Operation    operation=verify               product_type=gnb   bts_index=0    verify_status=SITE_ONAIR

    BTS Operation    operation=bts_reset            product_type=gnb   bts_index=0    need_verify=yes
    BTS Operation    operation=verify               product_type=gnb   bts_index=0    verify_status=SITE_ONAIR

BTS_Operation_Test_Single_Ru_Lock_Unlock
    BTS Operation    operation=ru_lock              product_type=gnb   bts_index=0
    ...              distname_id=RMOD-1             need_verify=yes
    BTS Operation    operation=verify               product_type=gnb   bts_index=0
    ...              distname_id=RMOD-1             verify_status=RRU_LOCK
    BTS Operation    operation=ru_unlock            product_type=gnb   bts_index=0
    ...              distname_id=RMOD-1             need_verify=yes
    BTS Operation    operation=verify               product_type=gnb   bts_index=0
    ...              distname_id=RMOD-1             verify_status=RRU_ONAIR
    BTS Operation    operation=ru_reset             product_type=gnb   bts_index=0
    ...              distname_id=RMOD-1             need_verify=yes
    BTS Operation    operation=verify               product_type=gnb   bts_index=0
    ...              distname_id=RMOD-1             verify_status=RRU_ONAIR

BTS_Operation_Test_All_Ru_Lock_Unlock
    BTS Operation    operation=ru_lock              product_type=gnb   bts_index=0
    ...              distname_id=RMOD-ALL           need_verify=yes
    BTS Operation    operation=verify               product_type=gnb   bts_index=0
    ...              distname_id=RMOD-ALL           verify_status=RRU_LOCK
    BTS Operation    operation=ru_unlock            product_type=gnb   bts_index=0
    ...              distname_id=RMOD-ALL           need_verify=yes
    BTS Operation    operation=verify               product_type=gnb   bts_index=0
    ...              distname_id=RMOD-ALL           verify_status=RRU_ONAIR
    BTS Operation    operation=ru_reset             product_type=gnb   bts_index=0
    ...              distname_id=RMOD-ALL           need_verify=yes
    BTS Operation    operation=verify               product_type=gnb   bts_index=0
    ...              distname_id=RMOD-ALL           verify_status=RRU_ONAIR

BTS_Operation_Test_Single_Bbu_Lock_Unlock
    BTS Operation    operation=bbmod_lock           product_type=gnb   bts_index=0
    ...              distname_id=BBMOD-1            need_verify=yes
    BTS Operation    operation=verify               product_type=gnb   bts_index=0
    ...              distname_id=BBMOD-1            verify_status=BBU_LOCK
    BTS Operation    operation=bbmod_unlock         product_type=gnb   bts_index=0
    ...              distname_id=BBMOD-1            need_verify=yes
    BTS Operation    operation=verify               product_type=gnb   bts_index=0
    ...              distname_id=BBMOD-1            verify_status=BBU_ONAIR
    BTS Operation    operation=bbmod_reset          product_type=gnb   bts_index=0
    ...              distname_id=BBMOD-1            need_verify=yes
    BTS Operation    operation=verify               product_type=gnb   bts_index=0
    ...              distname_id=BBMOD-1            verify_status=BBU_ONAIR

BTS_Operation_Test_All_Bbu_Lock_Unlock
    BTS Operation    operation=bbmod_lock           product_type=gnb   bts_index=0
    ...              distname_id=BBMOD-ALL          need_verify=yes
    BTS Operation    operation=verify               product_type=gnb   bts_index=0
    ...              distname_id=BBMOD-ALL          verify_status=BBU_LOCK
    BTS Operation    operation=bbmod_unlock         product_type=gnb   bts_index=0
    ...              distname_id=BBMOD-ALL          need_verify=yes
    BTS Operation    operation=verify               product_type=gnb   bts_index=0
    ...              distname_id=BBMOD-ALL          verify_status=BBU_ONAIR
    BTS Operation    operation=bbmod_reset          product_type=gnb   bts_index=0
    ...              distname_id=BBMOD-ALL          need_verify=yes
    BTS Operation    operation=verify               product_type=gnb   bts_index=0
    ...              distname_id=BBMOD-ALL          verify_status=BBU_ONAIR

BTS_Operation_Test_Nglink_Lock_Unlock
    BTS Operation    operation=nglink_lock          product_type=gnb   bts_index=0
    ...              distname_id=NRBTS-1/SERVEDAMF-1    need_verify=yes
    BTS Operation    operation=nglink_unlock        product_type=gnb   bts_index=0
    ...              distname_id=NRBTS-1/SERVEDAMF-1    need_verify=yes

# BTS_Operation_Test_X2link_Lock_Unlock
#     BTS Operation    operation=x2link_lock          product_type=gnb   bts_index=0
#     ...              distname_id=LNBTS-1/LNADJGNB-1    need_verify=yes
#     BTS Operation    operation=x2link_unlock        product_type=gnb   bts_index=0
#     ...              distname_id=LNBTS-1/LNADJGNB-1    need_verify=yes

BTS_Operation_Test_Multiple_Objects_Verify_ENB
    BTS Operation    operation=verify    product_type=enb   bts_index=0    verify_status=SITE_ONAIR+CELL_ONAIR

BTS_Operation_Test_Multiple_Objects_Verify_GNB
    BTS Operation    operation=verify    product_type=gnb   bts_index=0    verify_status=SITE_ONAIR+CELL_ONAIR

*** Keywords ***
download SWB
    [Arguments]    ${indicated_sw_version}
    ssh.Connect to    hostname=127.0.0.1    username=ute    password=ute    alias=download_sbw_vm
    ${swb_cmd}=    Catenate
    ...    cd ~ &&
    ...    mkdir ${indicated_sw_version} &&
    ...    cd ${indicated_sw_version} &&
    ...    wget http://files.ute.nsn-rdnet.net/builds/enb/base/${indicated_sw_version}/${indicated_sw_version}_release_BTSSM_downloadable.zip
    ssh.execute    command=${swb_cmd}    connection=download_sbw_vm
    ssh.disconnect    connection=download_sbw_vm
