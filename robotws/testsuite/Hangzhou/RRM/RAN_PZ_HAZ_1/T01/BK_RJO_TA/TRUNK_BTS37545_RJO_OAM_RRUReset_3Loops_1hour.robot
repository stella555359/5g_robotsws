*** Settings ***
Documentation
...   Author: Wu Haihua
...   Contact: haihua.wu@nokia-sbell.com
...   Description: The purpose of this test is to debug OAM
Suite Setup       Common Suite Setup For RRM
Suite Teardown    Common Suite Teardown For RRM
Test Setup        Common Test Setup For RRM
Test Teardown     Common Test Teardown For RRM

Force Tags
...                CA_RAN_PZ_HAZ_1
...                RAN_PZ_HAZ1_SG01_ST_RRM
...                TA_LEVEL_22
...                CRT
...                TRUNK

Test Timeout    1800 minutes
Resource          ../../Resources/Classical/RRM_Common_Resource.robot

*** Variables ***
${INSTALL_BUILD}    NO

*** Test Cases ***
TRUNK_BTS37545_RJO_OAM_RRUReset_3Loops_1hour
    [Tags]    QC_159342       QCD_MN_RAN      QCP_RAN_VRF
    [Documentation]
    ...    Author: haihua.wu
    ...    Contact: haihua.wu@nokia-sbell.com
    ...    2.26.2025,haihua.wu@nokia-sbell.com
    FOR   ${index}  IN RANGE    3
        RRU_Reset
        Sleep    600
        Log    Loop ${index} times (Total 3)  console=True
    END
    Sleep    180
    Collect snapshot
    [Teardown]     Single Run Update Config ID

*** Keywords ***
Single Run Update Config ID
    Get SCF Internal Id By Scout    no_ute=False     bts_id=10_5_5G-37545

RRU_Reset
    BTS Operation    operation=ru_lock         product_type=gnb    bts_index=0
    ...  distname_id=RMOD-1 RMOD-2 RMOD-3 RMOD-4 RMOD-5           need_verify=True
    BTS Operation    operation=ru_unlock       product_type=gnb    bts_index=0
    ...  distname_id=RMOD-1 RMOD-2 RMOD-3 RMOD-4 RMOD-5           need_verify=True
    BTS Operation    operation=ru_reset        product_type=gnb    bts_index=0
    ...  distname_id=RMOD-1 RMOD-2 RMOD-3 RMOD-4 RMOD-5           need_verify=True

Collect snapshot
    ${local_file_path}    Log Collection    start    snapshot    product_type=gnb    bts_index=${0}
    Log To Console    \nSnapshot log: ${local_file_path}

[Teardown]