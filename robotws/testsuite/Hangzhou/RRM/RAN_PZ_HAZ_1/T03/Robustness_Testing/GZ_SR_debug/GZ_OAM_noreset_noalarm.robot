*** Settings ***
Documentation
...   Author: zhuo.1.gao@nokia-sbell.com
...   Contact: zhuo.1.gao@nokia-sbell.com
...   Description: This user scenario describes

Resource          ../../Resources/common_resource.robot
Suite Setup       Common MultiBTS Suite Setup For RRM
Suite Teardown      Common MutliBTS Suite Teardown For RRM



*** Variables ***
${DEBUG_MODE}        ${TRUE}

*** Test Cases ***
# step1_reset_BTSsite
#     FOR    ${index}    IN RANGE    2
#         reset_BTSsite
#         Sleep    5s
#     END

# step2_block_unblock_BTSsite
#     FOR    ${index}    IN RANGE    2
#         block_unblock_BTSsite
#         Sleep    5s
#     END

# step3_reset_rat
#     FOR    ${index}    IN RANGE    2
#         reset_rat
#         Sleep    5s
#     END

step4_block_unblock_NRrat
    FOR    ${index}    IN RANGE    2
        ${percentage}=    Evaluate    round((${index}+1)/2*100, 1)
        Log To Console    \r当前进度: ${index+1}/2 (${percentage}%)    no_newline=True
        block_unblock_NRrat
        Sleep    5s
    END
    Log To Console    \nblock_unblock_NRrat操作已完成!
step5_block_unblock_LNrat
    FOR    ${index}    IN RANGE    2
        ${percentage}=    Evaluate    round((${index}+1)/2*100, 1)
        Log To Console    \r当前进度: ${index+1}/2 (${percentage}%)    no_newline=True
        block_unblock_LNrat
        Sleep    5s
    END
    Log To Console    \nblock_unblock_LNrat操作已完成!

step6_block_unblock_all_NRcells
    FOR    ${index}    IN RANGE    3
        ${percentage}=    Evaluate    round((${index}+1)/3*100, 1)
        Log To Console    \r当前进度: ${index+1}/3 (${percentage}%)    no_newline=True
        block_unblock_all_NRcells
        Sleep    5s
    END
    Log To Console    \nblock_unblock_all_NRcells操作已完成!
step7_block_unblock_all_LNcells
    FOR    ${index}    IN RANGE    3
        ${percentage}=    Evaluate    round((${index}+1)/3*100, 1)
        Log To Console    \r当前进度: ${index+1}/3 (${percentage}%)    no_newline=True
        block_unblock_all_LNcells
        Sleep    5s
    END
    Log To Console    \nunblock_all_LNcells操作已完成!

step8_reset_all_NRcells
    FOR    ${index}    IN RANGE    3
        ${percentage}=    Evaluate    round((${index}+1)/3*100, 1)
        Log To Console    \r当前进度: ${index+1}/3 (${percentage}%)    no_newline=True
        reset_all_NRcells
        Sleep    5s
    END
    Log To Console    \nreset_all_NRcells操作已完成!
step9_reset_all_LNcells
    FOR    ${index}    IN RANGE    3
        ${percentage}=    Evaluate    round((${index}+1)/3*100, 1)
        Log To Console    \r当前进度: ${index+1}/3 (${percentage}%)    no_newline=True
        reset_all_LNcells
        Sleep    5s
    END
    Log To Console    \nreset_all_LNcells操作已完成!
step10_lock_unlock_all_rru
    FOR    ${index}    IN RANGE    2
        ${percentage}=    Evaluate    round((${index}+1)/2*100, 1)
        Log To Console    \r当前进度: ${index+1}/2 (${percentage}%)    no_newline=True
        lock_unlock_all_rru
        Sleep    5s
    END
    Log To Console    \nlock_unlock_all_rru操作已完成!
step11_reset_all_rru
    FOR    ${index}    IN RANGE    2
        ${percentage}=    Evaluate    round((${index}+1)/2*100, 1)
        Log To Console    \r当前进度: ${index+1}/2 (${percentage}%)    no_newline=True
        reset_all_rru
        Sleep    5s
    END
    Log To Console    \nreset_all_rru操作已完成!
step12_lock_unlock_all_bbmods
    FOR    ${index}    IN RANGE    3
        ${percentage}=    Evaluate    round((${index}+1)/3*100, 1)
        Log To Console    \r当前进度: ${index+1}/3 (${percentage}%)    no_newline=True
        lock_unlock_all_bbmods
        Sleep    5s
    END
    Log To Console    \nlock_unlock_all_bbmods操作已完成!

step13_lock_unlock_all_bbmods
    FOR    ${index}    IN RANGE    3
        ${percentage}=    Evaluate    round((${index}+1)/3*100, 1)
        Log To Console    \r当前进度: ${index+1}/3 (${percentage}%)    no_newline=True
        lock_unlock_all_bbmods
        Sleep    5s
    END
    Log To Console    \nlock_unlock_all_bbmods操作已完成!

step14_lock_unlock_all_bbmods
    FOR    ${index}    IN RANGE    3
        ${percentage}=    Evaluate    round((${index}+1)/3*100, 1)
        Log To Console    \r当前进度: ${index+1}/3 (${percentage}%)    no_newline=True
        lock_unlock_all_bbmods
        Sleep    5s
    END
    Log To Console    \nlock_unlock_all_bbmods操作已完成!

step15_lock_unlock_all_bbmods
    FOR    ${index}    IN RANGE    3
        ${percentage}=    Evaluate    round((${index}+1)/3*100, 1)
        Log To Console    \r当前进度: ${index+1}/3 (${percentage}%)    no_newline=True
        lock_unlock_all_bbmods
        Sleep    5s
    END
    Log To Console    \nlock_unlock_all_bbmods操作已完成!

step16_reset_all_bbmods_10times
    FOR    ${index}    IN RANGE    3
        ${percentage}=    Evaluate    round((${index}+1)/3*100, 1)
        Log To Console    \r当前进度: ${index+1}/3 (${percentage}%)    no_newline=True
        reset_all_bbmods
        Sleep    3s
    END
    Log To Console    \nreset_all_bbmods_10次操作已完成!
step17_reset_all_bbmods_PowerReset_10times
    FOR    ${index}    IN RANGE    3
        ${percentage}=    Evaluate    round((${index}+1)/3*100, 1)
        Log To Console    \r当前进度: ${index+1}/3 (${percentage}%)    no_newline=True
        reset_all_bbmods_PowerReset
        Sleep    3s
    END
    Log To Console    \nreset_all_bbmods_PowerReset_10次操作已完成!

step18_reset_all_bbmods_15times
    FOR    ${index}    IN RANGE    15
        ${percentage}=    Evaluate    round((${index}+1)/15*100, 1)
        Log To Console    \r当前进度: ${index+1}/15 (${percentage}%)    no_newline=True
        reset_all_bbmods
        Sleep    3s
    END
    Log To Console    \nreset_all_bbmods_15次操作已完成!
# step19_reset_all_bbmods_PowerReset_15times
#     FOR    ${index}    IN RANGE    15
#         ${percentage}=    Evaluate    round((${index}+1)/15*100, 1)
#         Log To Console    \r当前进度: ${index+1}/15 (${percentage}%)    no_newline=True
#         reset_all_bbmods_PowerReset
#         Sleep    3s
#     END
#     Log To Console    \nreset_all_bbmods_PowerReset_15次操作已完成!

step20_reset_all_bbmods_20times
    FOR    ${index}    IN RANGE    20
        ${percentage}=    Evaluate    round((${index}+1)/20*100, 1)
        Log To Console    \r当前进度: ${index+1}/20 (${percentage}%)    no_newline=True
        reset_all_bbmods
        Sleep    3s
    END
    Log To Console    \nreset_all_bbmods_20次操作已完成!
# step21_reset_all_bbmods_PowerReset_20times
#     FOR    ${index}    IN RANGE    20
#         ${percentage}=    Evaluate    round((${index}+1)/20*100, 1)
#         Log To Console    \r当前进度: ${index+1}/20 (${percentage}%)    no_newline=True
#         reset_all_bbmods_PowerReset
#         Sleep    3s
#     END
#     Log To Console    \nreset_all_bbmods_PowerReset_20次操作已完成!

step22_reset_all_bbmods_50times
    FOR    ${index}    IN RANGE    50
        ${percentage}=    Evaluate    round((${index}+1)/50*100, 1)
        Log To Console    \r当前进度: ${index+1}/50 (${percentage}%)    no_newline=True
        reset_all_bbmods
        Sleep    3s
    END
    Log To Console    \nreset_all_bbmods_50次操作已完成!
# step23_reset_all_bbmods_PowerReset_50times
#     FOR    ${index}    IN RANGE    50
#         ${percentage}=    Evaluate    round((${index}+1)/50*100, 1)
#         Log To Console    \r当前进度: ${index+1}/50 (${percentage}%)    no_newline=True
#         reset_all_bbmods_PowerReset
#         Sleep    3s
#     END
#     Log To Console    \nreset_all_bbmods_PowerReset_50次操作已完成!

step24_reset_all_bbmods_100times
    FOR    ${index}    IN RANGE    100
        ${percentage}=    Evaluate    round((${index}+1)/100*100, 1)
        Log To Console    \r当前进度: ${index+1}/100 (${percentage}%)    no_newline=True
        reset_all_bbmods
        Sleep    3s
    END
    Log To Console    \nreset_all_bbmods_100次操作已完成!
# step25_reset_all_bbmods_PowerReset_50times
#     FOR    ${index}    IN RANGE    100
#         ${percentage}=    Evaluate    round((${index}+1)/100*100, 1)
#         Log To Console    \r当前进度: ${index+1}/100 (${percentage}%)    no_newline=True
#         reset_all_bbmods_PowerReset
#         Sleep    3s
#     END
#     Log To Console    \nreset_all_bbmods_PowerReset_100次操作已完成!



step26_reset_all_bbmods_10times
    FOR    ${index}    IN RANGE    10
        ${percentage}=    Evaluate    round((${index}+1)/200*100, 1)
        Log To Console    \r当前进度: ${index+1}/200 (${percentage}%)    no_newline=True
        reset_all_bbmods
        Sleep    3s
    END
    Log To Console    \nreset_all_bbmods_200次操作已完成!
step27_reset_all_bbmods_300times
    FOR    ${index}    IN RANGE    300
        ${percentage}=    Evaluate    round((${index}+1)/300*100, 1)
        Log To Console    \r当前进度: ${index+1}/300 (${percentage}%)    no_newline=True
        reset_all_bbmods_PowerReset
        Sleep    3s
    END
    Log To Console    \nreset_all_bbmods_300次操作已完成!
step28_reset_all_bbmods_200times
    FOR    ${index}    IN RANGE    200
        ${percentage}=    Evaluate    round((${index}+1)/200*100, 1)
        Log To Console    \r当前进度: ${index+1}/200 (${percentage}%)    no_newline=True
        reset_all_bbmods
        Sleep    3s
    END
    Log To Console    \nreset_all_bbmods_200次操作已完成!

# step17_reset_all_bbmods_5000times
#     FOR    ${index}    IN RANGE    10000
#         reset_all_bbmods
#         Sleep    5s
#     END

step29_reset_all_bbmods_5000times
    FOR    ${index}    IN RANGE    5000
        ${percentage}=    Evaluate    round((${index}+1)/5000*100, 1)
        Log To Console    \r当前进度: ${index+1}/5000 (${percentage}%)    no_newline=True
        reset_all_bbmods
        Sleep    5s
    END
    Log To Console    \nreset_all_bbmods_5000times操作已完成!


*** Keywords ***
reset_BTSsite
    BTS Operation    operation=bts_reset            product_type=gnb    bts_index=0    need_verify=True

block_unblock_BTSsite
    BTS Operation    operation=bts_block            product_type=gnb    bts_index=0    need_verify=True
    BTS Operation    operation=bts_unblock          product_type=gnb    bts_index=0    need_verify=True

reset_rat
    BTS Operation    operation=rat_reset            product_type=gnb    bts_index=0    distname_id=NRCELL-ALL    need_verify=True
    BTS Operation    operation=rat_reset            product_type=gnb    bts_index=0    distname_id=LNCEL-ALL    need_verify=True

block_unblock_NRrat
    BTS Operation    operation=rat_block            product_type=gnb    bts_index=0    distname_id=NRCELL-ALL    need_verify=True
    BTS Operation    operation=rat_unblock          product_type=gnb    bts_index=0    distname_id=NRCELL-ALL    need_verify=True

block_unblock_LNrat
    BTS Operation    operation=rat_block            product_type=gnb    bts_index=0    distname_id=LNCEL-ALL    need_verify=True
    BTS Operation    operation=rat_unblock          product_type=gnb    bts_index=0    distname_id=LNCEL-ALL    need_verify=True

block_unblock_all_NRcells
    BTS Operation    operation=cell_block           product_type=gnb    bts_index=0    distname_id=NRCELL-ALL     need_verify=True
    BTS Operation    operation=cell_unblock         product_type=gnb    bts_index=0    distname_id=NRCELL-ALL     need_verify=True
block_unblock_all_LNcells
    BTS Operation    operation=cell_block           product_type=gnb    bts_index=0    distname_id=LNCELL-ALL     need_verify=True
    BTS Operation    operation=cell_unblock         product_type=gnb    bts_index=0    distname_id=LNCELL-ALL     need_verify=True

reset_all_NRcells
    BTS Operation    operation=cell_reset           product_type=gnb    bts_index=0    distname_id=NRCELL-ALL       need_verify=True

reset_all_LNcells
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
reset_all_bbmods_PowerReset
    BTS Operation    operation=bbmod_reset    product_type=gnb    bts_index=0    distname_id=BBMOD-ALL    need_verify=True    reset_type=PowerReset



