# *** Settings ***
# Documentation
# ...   author: zheyuan.chen@nokia-sbell.com
# ...   contact: zheyuan.chen@nokia-sbell.com
# ...   Sync
# 
# Force Tags      5G_RAN_TDD     STATE_GNB_NOT_COMMISSIONED    CLOUD_5G_ASIKL_ABILB1_AEUD_ENB_HZIV    master_classicalbts_all    UTE_CRT    5G_RAN
# ...    PY36
# ...    master_pDU
# Suite Setup       Suite Setup
# Suite Teardown    Suite Teardown
# 
# 
# Resource    resources/trans_comm.robot
# Resource    ../common/robot/common_keyword_2377HB_1913_HA.robot
# Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/CI_Operations/CI_interface.robot
# 
# *** Variables ***
# ${host}    ${tl.gnbs[0].dus[0].airscale.common_units[0].lmp_connection1.addr}
# ${name}    ${tl.gnbs[0].dus[0].airscale.common_units[0].lmp_connection1.username}
# ${psd}    ${tl.gnbs[0].dus[0].airscale.common_units[0].lmp_connection1.password}
# 
# *** Test Cases ***
# [1]5GC001577-SA_5GC000320_A_110_1PPS-TOD_holdover_very_short_failure_(less_than_5s)
#     [Documentation]
#     ...    The purpose of this test is to check the behavior of the system when 5gNB face as very short lost of
#     ...    1PPS-TOD signal (less than 5s)
#     ...    -11.11.2020,zheyuan.chen@nokia-sbell.com,case draft
#     [Tags]    CRT_20B    CRT_TRUNK    5GC001577_320   CRT_21B
#     [Setup]    case setup
#     Check BTS Should Be Normal
#     Check Sync Status    expect_syncInputType=TOPP
#     Start Catch BTS Log
#     Disconnect Sync Connector less than 5s
#     sleep    1min
#     Check Sync Status    expect_syncInputType=TOPP
#     Stop BTS Log and Check Phase Error
#     [Teardown]    case teardown
# 
# *** Keywords ***
# case setup
#     Log To Console    case setup:change sync to topp
#     Change Sync Input Type    synctype=TOPP
# 
# case teardown
#     Log To Console    case teardown:change sync to GNSS
#     Change Sync Input Type    synctype=1pps/ToD from external GNSS receiver
#     Check Sync Status    expect_syncInputType=1pps/ToD from external GNSS receiver
#     CI_interface.Common Case Teardown
# 
# Stop BTS Log and Check Phase Error
#     Log To Console    Stop and collect btslog on local machine
#     Stop and collect btslog on local machine
#     Check Phase Error
# 
# Suite Setup
#     TRANS Common Setup
# 
# 
# Suite Teardown
#     TRANS Common Teardown
# 
# Commission_CU_DU
#     [Documentation]    Author: Wu Jerry
#     ...                Description: do cu and du commission
#     Cloud DU connect to gnb coam via ssl    bts_host=${host}    username=${name}    password=${psd}
#     COAM Commission with scf file
#     ...    scf_file_path=${CURDIR}/../../../commissionings/HGZ/7_5_UTE5G401T701/SCF_10.1100_DU.xml
#     ...    is_pdl_checking_needed=${False}
#     CU Full Commission
#     ...    path_of_commission_file=${CURDIR}/../../../commissionings/HGZ/7_5_UTE5G401T701/SCF_0.190_CU.xml
#     wait until keyword succeeds    25 min    10 sec    COAM Check GNB cell on air
#     COAM Teardown gnb connections