*** Settings ***
Documentation
...   Author: Du Ning
...   Contact: ning.du@nokia-sbell.com
...   Description: This is the module test case

Resource          ../Module.robot
Resource          ../../../../RRM/RAN_PZ_HAZ_1/Resources/Cloud/AIC_Common_Resource.robot

Suite Setup       Common Suite Setup For AIC
Suite Teardown    Common Suite Teardown For AIC
Test Setup        Common Test Setup For AIC
Test Teardown     Common Test Teardown For AIC

Test Timeout    50 minutes




*** Test Cases ***
############################## BTS Operation VDU Part #################################
T01_BTS_Operation_Test_Single_Cell_Lock_Unlock
    BTS Operation    operation=cell_lock            product_type=vdu          bts_index=0
    ...              distname_id=NRCELL-1           need_verify=yes
    BTS Operation    operation=verify               product_type=vdu          bts_index=0
    ...              distname_id=NRCELL-1           verify_status=CELL_LOCK
    BTS Operation    operation=cell_unlock          product_type=vdu          bts_index=0
    ...              distname_id=NRCELL-1           need_verify=yes
    BTS Operation    operation=verify               product_type=vdu          bts_index=0
    ...              distname_id=NRCELL-1           verify_status=CELL_ONAIR

T02_BTS_Operation_Test_All_Cell_Lock_Unlock
    BTS Operation    operation=cell_lock            product_type=vdu          bts_index=0
    ...              distname_id=NRCELL-ALL         need_verify=yes
    BTS Operation    operation=verify               product_type=vdu          bts_index=0
    ...              distname_id=NRCELL-ALL         verify_status=CELL_LOCK
    BTS Operation    operation=cell_unlock          product_type=vdu          bts_index=0
    ...              distname_id=NRCELL-ALL         need_verify=yes
    BTS Operation    operation=verify               product_type=vdu          bts_index=0
    ...              distname_id=NRCELL-ALL         verify_status=CELL_ONAIR

T03_BTS_Operation_Test_Single_Cell_Block_Unblock
    BTS Operation    operation=cell_block           product_type=vdu          bts_index=0
    ...              distname_id=NRCELL-1           need_verify=yes
    BTS Operation    operation=verify               product_type=vdu          bts_index=0
    ...              distname_id=NRCELL-1           verify_status=CELL_BLOCK
    BTS Operation    operation=cell_unblock         product_type=vdu          bts_index=0
    ...              distname_id=NRCELL-1           need_verify=yes
    BTS Operation    operation=verify               product_type=vdu          bts_index=0
    ...              distname_id=NRCELL-1           verify_status=CELL_ONAIR

T04_BTS_Operation_Test_All_Cell_Block_Unblock
    BTS Operation    operation=cell_block           product_type=vdu          bts_index=0
    ...              distname_id=NRCELL-ALL         need_verify=yes
    BTS Operation    operation=verify               product_type=vdu          bts_index=0
    ...              distname_id=NRCELL-ALL         verify_status=CELL_BLOCK
    BTS Operation    operation=cell_unblock         product_type=vdu          bts_index=0
    ...              distname_id=NRCELL-ALL         need_verify=yes
    BTS Operation    operation=verify               product_type=vdu          bts_index=0
    ...              distname_id=NRCELL-ALL         verify_status=CELL_ONAIR

# T05_BTS_Operation_Test_Single_Cell_Reset (cell rest NOT SUPPORTED)
#     BTS Operation    operation=cell_reset           product_type=vdu          bts_index=0
#     ...              distname_id=NRCELL-1           need_verify=yes
#     BTS Operation    operation=verify               product_type=vdu          bts_index=0
#     ...              distname_id=NRCELL-1           verify_status=CELL_ONAIR

# T06_BTS_Operation_Test_All_Cell_Reset (cell rest NOT SUPPORTED)
#     BTS Operation    operation=cell_reset           product_type=vdu          bts_index=0
#     ...              distname_id=NRCELL-ALL         need_verify=yes
#     BTS Operation    operation=verify               product_type=vdu          bts_index=0
#     ...              distname_id=NRCELL-ALL         verify_status=CELL_ONAIR

T09_BTS_Operation_Test_Single_Cell_Group_Reset
    BTS Operation    operation=cell_group_reset     product_type=vdu          bts_index=0
    ...              distname_id=NRCELLGRP-1        need_verify=yes
    BTS Operation    operation=verify               product_type=vdu          bts_index=0
    ...              distname_id=NRCELL-ALL         verify_status=CELL_ONAIR

T11_BTS_Operation_Test_Vdu_Reset
    BTS Operation    operation=vdu_reset            product_type=vdu
    BTS Operation    operation=verify               product_type=vdu
    ...                                             verify_status=CELL_ONAIR
    BTS Operation    operation=verify               product_type=vdu
    ...              distname_id=NRCELL-1           verify_status=CELL_ONAIR

T12_BTS_Operation_Test_Rannic_Reset
    BTS Operation    operation=rannic_reset          product_type=vdu
    ...              distname_id=RNICMOD_R-1        need_verify=yes

T13_BTS_Operation_Test_Single_Ru_Lock_Unlock_Reset
    BTS Operation    operation=ru_lock              product_type=vdu          bts_index=0
    ...              distname_id=RMOD-1             need_verify=yes
    BTS Operation    operation=verify               product_type=vdu          bts_index=0
    ...              distname_id=RMOD-1             verify_status=RRU_LOCK
    BTS Operation    operation=ru_unlock            product_type=vdu          bts_index=0
    ...              distname_id=RMOD-1             need_verify=yes
    BTS Operation    operation=verify               product_type=vdu          bts_index=0
    ...              distname_id=RMOD-1             verify_status=RRU_ONAIR
    BTS Operation    operation=ru_reset             product_type=vdu          bts_index=0
    ...              distname_id=RMOD-1             need_verify=yes
    BTS Operation    operation=verify               product_type=vdu          bts_index=0
    ...              distname_id=RMOD-1             verify_status=RRU_ONAIR

T14_BTS_Operation_Test_All_Ru_Lock_Unlock_Reset
    BTS Operation    operation=ru_lock              product_type=vdu          bts_index=0
    ...              distname_id=RMOD-ALL           need_verify=yes
    BTS Operation    operation=verify               product_type=vdu          bts_index=0
    ...              distname_id=RMOD-ALL           verify_status=RRU_LOCK
    BTS Operation    operation=ru_unlock            product_type=vdu          bts_index=0
    ...              distname_id=RMOD-ALL           need_verify=yes
    BTS Operation    operation=verify               product_type=vdu          bts_index=0
    ...              distname_id=RMOD-ALL           verify_status=RRU_ONAIR
    BTS Operation    operation=ru_reset             product_type=vdu          bts_index=0
    ...              distname_id=RMOD-ALL           need_verify=yes
    BTS Operation    operation=verify               product_type=vdu          bts_index=0
    ...              distname_id=RMOD-ALL           verify_status=RRU_ONAIR

T15_BTS_Operation_Test_Multiple_Ru_Lock_Unlock_Reset
    BTS Operation    operation=ru_lock              product_type=vdu          bts_index=0
    ...              distname_id=RMOD-1 RMOD-2      need_verify=yes
    BTS Operation    operation=verify               product_type=vdu          bts_index=0
    ...              distname_id=RMOD-1 RMOD-2      verify_status=RRU_LOCK
    BTS Operation    operation=ru_unlock            product_type=vdu          bts_index=0
    ...              distname_id=RMOD-1 RMOD-2      need_verify=yes
    BTS Operation    operation=verify               product_type=vdu          bts_index=0
    ...              distname_id=RMOD-1 RMOD-2      verify_status=RRU_ONAIR
    BTS Operation    operation=ru_reset             product_type=vdu          bts_index=0
    ...              distname_id=RMOD-1 RMOD-2      need_verify=yes
    BTS Operation    operation=verify               product_type=vdu          bts_index=0
    ...              distname_id=RMOD-1 RMOD-2      verify_status=RRU_ONAIR

T16_BTS_Operation_Test_Cloud BTS Operation Vdu Verify Operation
    BTS Operation    operation=verify                 product_type=vdu
    ...                                               verify_status=CELL_ONAIR
    BTS Operation    operation=verify                 product_type=vdu
    ...              distname_id=NRCELL-1             verify_status=CELL_ONAIR
    BTS Operation    operation=verify                 product_type=vdu
    ...              distname_id=NRCELL-1 NRCELL-2    verify_status=CELL_ONAIR
    BTS Operation    operation=verify                 product_type=vdu
    ...              distname_id=NRCELL-ALL           verify_status=CELL_ONAIR
    BTS Operation    operation=verify                 product_type=vdu
    ...              distname_id=RMOD-1               verify_status=RRU_ONAIR
    BTS Operation    operation=verify                 product_type=vdu
    ...              distname_id=RMOD-1 RMOD-2        verify_status=RRU_ONAIR
    BTS Operation    operation=verify                 product_type=vdu
    ...              distname_id=RMOD-ALL             verify_status=RRU_ONAIR


############################### BTS Operation VCU Part #################################
T07_BTS_Operation_Test_Single_Cell_Group_Lock_Unlock
    BTS Operation    operation=cell_group_lock      product_type=vcu          bts_index=0
    ...              distname_id=NRCELLGRP-1        need_verify=yes
    BTS Operation    operation=cell_group_unlock    product_type=vcu          bts_index=0
    ...              distname_id=NRCELLGRP-1        need_verify=yes
    BTS Operation    operation=verify               product_type=vcu          bts_index=0
    ...              distname_id=NRCELL-ALL         verify_status=CELL_ONAIR

# T08_BTS_Operation_Test_All_Cell_Group_Lock_Unlock (cell group with distname id=ALL NOT SUPPORTED)
#     BTS Operation    operation=cell_group_lock      product_type=vcu          bts_index=0
#     ...              distname_id=NRCELLGRP-ALL      need_verify=yes
#     BTS Operation    operation=cell_group_unlock    product_type=vcu          bts_index=0
#     ...              distname_id=NRCELLGRP-ALL      need_verify=yes
#     BTS Operation    operation=verify               product_type=vcu          bts_index=0
#     ...              distname_id=NRCELL-ALL         verify_status=CELL_ONAIR

# T10_BTS_Operation_Test_All_Cell_Group_Reset (cell group with distname id=ALL NOT SUPPORTED)
#     BTS Operation    operation=cell_group_reset     product_type=vcu          bts_index=0
#     ...              distname_id=NRCELLGRP-ALL      need_verify=yes
#     BTS Operation    operation=verify               product_type=vcu          bts_index=0
#     ...              distname_id=NRCELL-ALL         verify_status=CELL_ONAIR

T51_BTS_Operation_Test_Single_Cell_Lock_Unlock
    BTS Operation    operation=cell_lock            product_type=vcu          bts_index=0
    ...              distname_id=NRCELL-1           need_verify=yes
    BTS Operation    operation=verify               product_type=vcu          bts_index=0
    ...              distname_id=NRCELL-1           verify_status=CELL_LOCK
    BTS Operation    operation=cell_unlock          product_type=vcu          bts_index=0
    ...              distname_id=NRCELL-1           need_verify=yes
    BTS Operation    operation=verify               product_type=vcu          bts_index=0
    ...              distname_id=NRCELL-1           verify_status=CELL_ONAIR

T52_BTS_Operation_Test_All_Cell_Lock_Unlock
    BTS Operation    operation=cell_lock            product_type=vcu          bts_index=0
    ...              distname_id=NRCELL-ALL         need_verify=yes
    BTS Operation    operation=verify               product_type=vcu          bts_index=0
    ...              distname_id=NRCELL-ALL         verify_status=CELL_LOCK
    BTS Operation    operation=cell_unlock          product_type=vcu          bts_index=0
    ...              distname_id=NRCELL-ALL         need_verify=yes
    BTS Operation    operation=verify               product_type=vcu          bts_index=0
    ...              distname_id=NRCELL-ALL         verify_status=CELL_ONAIR

T53_BTS_Operation_Test_Single_Nglink_Lock_Unlock
    BTS Operation    operation=nglink_lock          product_type=vcu          bts_index=0
    ...              distname_id=nglink-1           need_verify=yes
    BTS Operation    operation=nglink_unlock        product_type=vcu          bts_index=0
    ...              distname_id=nglink-1           need_verify=yes
    BTS Operation    operation=verify               product_type=vcu          bts_index=0
    ...              distname_id=NRCELL-ALL         verify_status=CELL_ONAIR

T54_BTS_Operation_Test_All_Nglink_Lock_Unlock
    BTS Operation    operation=nglink_lock          product_type=vcu          bts_index=0
    ...              distname_id=nglink-ALL         need_verify=yes
    BTS Operation    operation=nglink_unlock        product_type=vcu          bts_index=0
    ...              distname_id=nglink-ALL         need_verify=yes
    BTS Operation    operation=verify               product_type=vcu          bts_index=0
    ...              distname_id=NRCELL-ALL         verify_status=CELL_ONAIR

T55_BTS_Operation_Test_Cu_Verify
    BTS Operation    operation=verify               product_type=vcu          bts_index=0
    ...              distname_id=NRCELL-1           verify_status=CELL_ONAIR
    BTS Operation    operation=verify               product_type=vcu          bts_index=0
    ...              distname_id=NRCELL-ALL         verify_status=CELL_ONAIR
    BTS Operation    operation=verify               product_type=vcu          bts_index=0
    ...                                             verify_status=CELL_ONAIR

T56_BTS_Operation_Test_Cu_Reset
    BTS Operation    operation=vcu_reset            product_type=vcu          bts_index=0







