*** Settings ***
Documentation
...   Author: zhuo.1.gao@nokia-sbell.com
...   Contact: zhuo.1.gao@nokia-sbell.com
...   Description: This user scenario describes

Resource          ../../Resources/common_resource.robot
Suite Setup       Common MultiBTS Suite Setup For RRM
Suite Teardown    Common MutliBTS Suite Teardown For RRM
Test Teardown     Run Keyword If Test Failed    Fatal Error    Test case failed, stopping execution

*** Variables ***
${DEBUG_MODE}        ${TRUE}

*** Test Cases ***
# step1_reset_BTSsite
#     [Documentation]    Reset BTS site operation
#     FOR    ${index}    IN RANGE    2
#         ${status}=    Run Keyword And Return Status    reset_BTSsite
#         Run Keyword Unless    ${status}    Fail    Failed to reset BTS site
#         Sleep    5s
#     END

# step2_block_unblock_BTSsite
#     [Documentation]    Block and unblock BTS site operation
#     FOR    ${index}    IN RANGE    2
#         ${status}=    Run Keyword And Return Status    block_unblock_BTSsite
#         Run Keyword Unless    ${status}    Fail    Failed to block/unblock BTS site
#         Sleep    5s
#     END

# step3_reset_rat
#     [Documentation]    Reset RAT operation
#     FOR    ${index}    IN RANGE    2
#         ${status}=    Run Keyword And Return Status    reset_rat
#         Run Keyword Unless    ${status}    Fail    Failed to reset RAT
#         Sleep    5s
#     END


step4_block_unblock_rat
    [Documentation]    Block and unblock RAT operation
    FOR    ${index}    IN RANGE    2
        ${status}=    Run Keyword And Return Status    block_unblock_rat
        Run Keyword Unless    ${status}    Fail    Failed to block/unblock RAT
        Sleep    5s
    END

step5_block_unblock_all_cells
    [Documentation]    Block and unblock all cells operation
    FOR    ${index}    IN RANGE    3
        ${status}=    Run Keyword And Return Status    block_unblock_all_cells
        Run Keyword Unless    ${status}    Fail    Failed to block/unblock all cells
        Sleep    5s
    END

step6_reset_all_cells
    [Documentation]    Reset all cells operation
    FOR    ${index}    IN RANGE    3
        ${status}=    Run Keyword And Return Status    reset_all_cells
        Run Keyword Unless    ${status}    Fail    Failed to reset all cells
        Sleep    5s
    END

step7_lock_unlock_all_rru
    [Documentation]    Lock and unlock all RRUs operation
    FOR    ${index}    IN RANGE    2
        ${status}=    Run Keyword And Return Status    lock_unlock_all_rru
        Run Keyword Unless    ${status}    Fail    Failed to lock/unlock all RRUs
        Sleep    5s
    END

step8_reset_all_rru
    [Documentation]    Reset all RRUs operation
    FOR    ${index}    IN RANGE    2
        ${status}=    Run Keyword And Return Status    reset_all_rru
        Run Keyword Unless    ${status}    Fail    Failed to reset all RRUs
        Sleep    5s
    END

step9_lock_unlock_all_bbmods
    [Documentation]    Lock and unlock all BB modules operation
    FOR    ${index}    IN RANGE    10
        ${status}=    Run Keyword And Return Status    lock_unlock_all_bbmods
        Run Keyword Unless    ${status}    Fail    Failed to lock/unlock all BB modules
        Sleep    5s
    END

step10_reset_all_bbmods
    [Documentation]    Reset all BB modules operation
    FOR    ${index}    IN RANGE    5000
        ${status}=    Run Keyword And Return Status    reset_all_bbmods
        Run Keyword Unless    ${status}    Fail    Failed to reset all BB modules
        Sleep    5s
    END

*** Keywords ***
reset_BTSsite
    BTS Operation    operation=bts_reset            product_type=gnb    bts_index=0    need_verify=True

block_unblock_BTSsite
    BTS Operation    operation=bts_block            product_type=gnb    bts_index=0    need_verify=True
    BTS Operation    operation=bts_unblock          product_type=gnb    bts_index=0    need_verify=True

reset_rat
    BTS Operation    operation=rat_reset            product_type=gnb    bts_index=0    distname_id=NRCELL-ALL    need_verify=True
    BTS Operation    operation=rat_reset            product_type=gnb    bts_index=0    distname_id=LNCELL-ALL    need_verify=True

block_unblock_rat
    BTS Operation    operation=rat_block            product_type=gnb    bts_index=0    distname_id=NRCELL-ALL    need_verify=True
    BTS Operation    operation=rat_block            product_type=gnb    bts_index=0    distname_id=LNCELL-ALL    need_verify=True
    BTS Operation    operation=rat_unblock          product_type=gnb    bts_index=0    distname_id=NRCELL-ALL    need_verify=True
    BTS Operation    operation=rat_unblock          product_type=gnb    bts_index=0    distname_id=LNCELL-ALL    need_verify=True
block_unblock_all_cells
    BTS Operation    operation=cell_block           product_type=gnb    bts_index=0    distname_id=NRCELL-ALL     need_verify=True
    BTS Operation    operation=cell_block           product_type=gnb    bts_index=0    distname_id=LNCELL-ALL     need_verify=True
    BTS Operation    operation=cell_unblock         product_type=gnb    bts_index=0    distname_id=NRCELL-ALL     need_verify=True
    BTS Operation    operation=cell_unblock         product_type=gnb    bts_index=0    distname_id=LNCELL-ALL     need_verify=True

reset_all_cells
    BTS Operation    operation=cell_reset           product_type=gnb    bts_index=0    distname_id=NRCELL-ALL       need_verify=True
    BTS Operation    operation=cell_reset           product_type=gnb    bts_index=0    distname_id=LNCELL-ALL       need_verify=True
lock_unlock_all_rru
    BTS Operation    operation=ru_lock              product_type=gnb    bts_index=0    distname_id=RMOD-ALL             need_verify=True
    BTS Operation    operation=ru_unlock            product_type=gnb    bts_index=0    distname_id=RMOD-ALL             need_verify=True
reset_all_rru
    BTS Operation    operation=ru_reset             product_type=gnb    bts_index=0    distname_id=RMOD-ALL             need_verify=True

lock_unlock_all_bbmods
    BTS Operation    operation=bbmod_lock           product_type=gnb    bts_index=0    distname_id=BBMOD-ALL            need_verify=True
    BTS Operation    operation=bbmod_unlock         product_type=gnb    bts_index=0    distname_id=BBMOD-ALL            need_verify=True
reset_all_bbmods
    BTS Operation    operation=bbmod_reset          product_type=gnb    bts_index=0    distname_id=BBMOD-ALL            need_verify=True


