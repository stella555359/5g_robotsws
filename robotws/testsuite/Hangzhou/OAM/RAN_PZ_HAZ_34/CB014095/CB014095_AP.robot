*** Settings ***

Library     ute_wtssim
Documentation
...    author: Han Ruiyu
...    contact: ruiyu.han@nokia.com
...    squad group: T04
...    feature : CB014095

Library     OperatingSystem
Library     String
Force Tags    CRT_TRUNK
Resource    testsuite/Hangzhou/OAM/RAN_PZ_HAZ_34/CB014095/Resource/CB014095_AP_common.robot
Resource    testsuite/Hangzhou/OAM/RAN_PZ_HAZ_34/common/taf_coam.robot
Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/robot_common_operations/interface.robot
Variables         testsuite/Hangzhou/OAM/RAN_PZ_HAZ_34/libraries/global_vars.py

Suite Setup      robot_common_operations.Common Suite Setup
# Suite Setup      run keywords    Install AP packge and wts   AND   robot_common_operations.Common Suite Setup
Suite Teardown   robot_common_operations.Common Suite Teardown

*** Variables ***
${scf_relative_dir}    commissionings/HGZ
# ${TEST_PC_IP}          10.57.155.139
# ${TEST_PC_USERNAME}    ute
# ${TEST_PC_PASSWORD}    iW_K#8.ute%A10h0m0ra
# ${UTE_PASSWORD}         ${tl.test_pc.default_ssh_connection_details.password}
${tl_id}    ${tl.gnbs[0].global_bts_id}
*** Test Cases ***
[1]CB014095-SR-A-B3_22_CB014095-SR-A-B3_22_B5_Massive_Bulk_SCell_Release_intra_gNB_CA_main
    [Setup]
    # FOR    ${retry}    IN RANGE    1    4
    #     Run Keyword And Continue On Failure
    #     ...    Blind_Massive_Bulk_SCell_Release_intra_gNB_CA
    #     IF    not ${IDLE_UE}    BREAK
    #     Log    IDLE UE detected, retrying Blind_Massive_Bulk_SCell_Release (attempt ${retry}/3)...    console=True
    # END

    # FOR    ${retry}    IN RANGE    1    4
    #     Run Keyword And Continue On Failure
    #     ...    A1_Oneshot_Massive_Bulk_SCell_Release_intra_gNB_CA
    #     IF    not ${IDLE_UE}    BREAK
    #     Log    IDLE UE detected, retrying A1_Oneshot_Massive_Bulk_SCell_Release (attempt ${retry}/3)...    console=True
    # END

    # FOR    ${retry}    IN RANGE    1    4
    #     Run Keyword And Continue On Failure
    #     ...    A4_Oneshot_Massive_Bulk_SCell_Release_intra_gNB_CA
    #     IF    not ${IDLE_UE}    BREAK
    #     Log    IDLE UE detected, retrying A4_Oneshot_Massive_Bulk_SCell_Release (attempt ${retry}/3)...    console=True
    # END

    # FOR    ${retry}    IN RANGE    1    4
    #     Run Keyword And Continue On Failure
    #     ...    A1_STEPWISE_Massive_Bulk_SCell_Release_intra_gNB_CA_50times
    #     IF    not ${IDLE_UE}    BREAK
    #     Log    IDLE UE detected, retrying A1_STEPWISE_Massive_Bulk_SCell_Release (attempt ${retry}/3)...    console=True
    # END

    run keyword and continue on failure    wait until keyword succeeds    3x    10s
    ...   Blind_Massive_Bulk_SCell_Release_intra_gNB_CA
    run keyword and continue on failure    wait until keyword succeeds    3x    10s
    ...   A1_Oneshot_Massive_Bulk_SCell_Release_intra_gNB_CA
    run keyword and continue on failure    wait until keyword succeeds    3x    10s
    ...   A4_Oneshot_Massive_Bulk_SCell_Release_intra_gNB_CA
    run keyword and continue on failure    wait until keyword succeeds    3x    10s
    ...   A4_Stepwise_Massive_Bulk_SCell_Release_intra_gNB_CA
    run keyword and continue on failure    wait until keyword succeeds    3x    10s
    ...   A1_STEPWISE_Massive_Bulk_SCell_Release_intra_gNB_CA_50times
    [Teardown]    robot_common_operations.Common Case Teardown


