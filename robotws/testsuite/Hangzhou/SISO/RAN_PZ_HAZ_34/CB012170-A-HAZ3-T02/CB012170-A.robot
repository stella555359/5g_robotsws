*** Settings ***
Documentation    author: jiangrong wang
...              Group: RAN_PZ_HAZ3_SG02
...              contact: jiangrong.wang@nokia-sbell.com

Resource          Resource/common_keywords.robot

Suite Setup    suit setup
Suite Teardown   SISO Coam Suite Teardown

*** Test Cases ***


[1]CB012170-SR-A_01_Online_feature_activation_validation_cMAAr6_2_64T64R
    [Setup]    case setup
    wait until keyword succeeds    2min    5s    Check cell EnergySaving state via COAM
    ...    expect_energySavingState=reducedEnergySaving
    #Get EIRP PM counters
    #${EIRP_counters_list_1}   get CB012170 counters value
    #Online change actSSBBoostInmMIMOMuting
    #${EIRP_counters_list_2}   get CB012170 counters value
    [TearDown]    case teardown


[1][1.0] General_SiSo_Auto_Cell_block_and_unblock_with_L3call
    [Setup]    case setup
    wait until keyword succeeds    2min    5s    Check cell EnergySaving state via COAM
    ...    expect_energySavingState=reducedEnergySaving
    Online change actSSBBoostInmMIMOMuting
    General_SiSo_Cell_block_and_unblock    with_call=False
    wait until keyword succeeds    2min    5s    Check cell EnergySaving state via COAM
    ...    expect_energySavingState=reducedEnergySaving
    [TearDown]    case teardown

[1][1.0] General_SiSo_Auto_RF_lock_unlock_with_L3call
    [Setup]    case setup
    Online change actSSBBoostInmMIMOMuting
    #Lock RU and Check Status
    #unLock RU and Check Status
    E2E_SiSo_RU_lock_and_unlock_gNB    with_call=False
    wait until keyword succeeds    2min    5s    Check cell EnergySaving state via COAM
    ...    expect_energySavingState=reducedEnergySaving
    [TearDown]    case teardown

[1]CB012170-SR-A_03_Online_feature_deactivation_validation_cMAAr6_2_64T64R
    [Setup]     case setup
    wait until keyword succeeds    2min    5s    Check cell EnergySaving state via COAM
    ...    expect_energySavingState=reducedEnergySaving
    [TearDown]    case teardown
