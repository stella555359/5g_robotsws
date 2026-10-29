*** Settings ***
Suite Setup          CB009453 CBRS Suite Setup
Suite Teardown       CBRS Suite Teardown
Test Setup    Run keywords    CBRS Test Setup    AND    CBRS Get BTS Info
Test Teardown        CBRS Test Teardown

Resource    ../resources/CB009453_common_keywords.robot

Documentation
...    Author:wangqingqing
...    contact:qingqing.wang@nokia-sbell.com
...    squad group:SG_08
...    Feature CB009453

Force Tags    SBTS00   
...   PY36

*** Variables ***

*** Test Cases ***
[1]CB010459_Verify_online_modification_desiredPmax_maxEIRP_same_as_before
  [Tags]    CRT_TRUNK
  CB010459_Verify_online_modification_desiredPmax_maxEIRP_same_as_before

[1]CB010459_11_General_SiSo_RU_lock_unlock
    [Tags]    CRT_TRUNK
    TL30 Commission SCF According btsname    btsName=${bts_name}    config_id=10459_common
    CB010459_11_General_SiSo_RU_lock_unlock

[1]CB010459_13_data_transfer_3x20MHz_C1_C3_above_110MHz
    [Tags]    CRT_TRUNK
    TL30 Commission SCF According btsname    btsName=${bts_name}    config_id=10459_common
    CB010459_13_data_transfer_3x20MHz_C1_C3_above_110MHz

[1]CB010459_7_Online_Reconfigure_3x20MHz_4D4U_to_2x20MHz_8D4U
   [Tags]    CRT_TRUNK
   TL30 Commission SCF According btsname    btsName=${bts_name}    config_id=10459_common
   CB010459_7_Online_Reconfigure_3x20MHz_4D4U_to_2x20MHz_8D4U

[1]CB010459_27_Verify_HW_BandWidth_Limitation_when_C2_blocked_till_grant_relinquished
    [Tags]    CRT_TRUNK
    TL30 Commission SCF According btsname    btsName=${bts_name}    config_id=10459_common
    CB010459_27_Verify_HW_BandWidth_Limitation_when_C2_blocked_till_grant_relinquished

[1]CB010459_29_Online_add_one_new_cell_to_satify_HW_BandWidth_limitation
    [Tags]    CRT_TRUNK
    TL30 Commission SCF According btsname    btsName=${bts_name}    config_id=10459_case29
    CB010459_29_Online_add_one_new_cell_to_satify_HW_BandWidth_limitation

[1]CB010459_10_Online_add_higher_priority_cell_when_only_20MHz_PAL_available
    [Tags]    CRT_TRUNK
    TL30 Commission SCF According btsname    btsName=${bts_name}    config_id=10459_case10
    CB010459_10_Online_add_higher_priority_cell_when_only_20MHz_PAL_available

[1]CB010459_30_Verify_HW_BandWidth_Limitation_consider_deactive_cell_which_has_grant
    [Tags]    CRT_TRUNK
    TL30 Commission SCF According btsname    btsName=${bts_name}    config_id=10459_common
    CB010459_30_Verify_HW_BandWidth_Limitation_consider_deactive_cell_which_has_grant

*** Keywords ***
