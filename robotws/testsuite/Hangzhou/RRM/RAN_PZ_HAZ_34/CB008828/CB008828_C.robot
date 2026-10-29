*** Settings ***
Resource  ./resources/CB008828_C_keyword.robot
Resource    resources/common_keywords.robot

Documentation
...    author: Yang Liqin
...    maintainer: Yang Liqin (liqin.yang@nokia-sbell.com)
...    release: 24R2

Suite Setup  Suite Case C Setup

Suite Teardown    Run Keywords    Suite Case Teardown
...  AND  CI_interface.Common Suite Setup

*** Test Cases ***
[1]CB008828_SR_012_C#B4_DRB_without_configured_resource_group_CB008828_enabled
  [Setup]  Test Case Setup  DRB_without_configured_resource_group_CB008828_enabled
  [Teardown]  Test Case Teardown
  [Documentation]    Author: Yang Liqin
  [tags]  case12
  Log To Console  DRB_without_configured_resource_group_CB008828_enabled
  DRB without configured resource group CB008828 enabled

CB008828_SR_015_C#B5_Default_resource_group_online_modification
  [Setup]  Test Case Setup  Default_resource_group_online_modification
  [Teardown]  Test Case Teardown
  [Documentation]    Author: Yang Liqin
  [tags]  case15
  Log To Console  Default_resource_group_online_modification
  Default resource group online modification

CB008828_SR_016_C#B5_Default_resource_group_online_modification_CB008828_disabled
  [Setup]  Test Case Setup  Default_resource_group_online_modification_CB008828_disabled
  [Teardown]  Test Case Teardown
  [Documentation]    Author: Yang Liqin
  [tags]  case16
  Log To Console  Default_resource_group_online_modification_CB008828_disabled
  Default resource group online modification CB008828 disabled

CB008828_SR_035_C#EC2_Wrong_configuration_of_quotas_for_a_resource_group
  [Setup]  Test Case Setup  Wrong_configuration_of_quotas_for_a_resource_group
  [Teardown]  Test Case Teardown
  [Documentation]    Author: Yang Liqin
  [tags]  case35
  Log To Console  Wrong_configuration_of_quotas_for_a_resource_group
  Wrong configuration of quotas for a resource group

CB008828_SR_010_C#B3_Existing_resource_group_is_removed_CB008828_enabled
  [Setup]  Test Case Setup  Existing_resource_group_is_removed_CB008828_enabled
  [Teardown]  Test Case Teardown
  [Documentation]    Author: Yang Liqin
  [tags]  case10
  Log To Console  Existing_resource_group_is_removed_CB008828_enabled
  Existing_resource_group_is_removed_CB008828_enabled

CB008828_SR_008_C#B2_Resource_Group_Aware_Scheduler_considering_resource_group_online_modification
  [Setup]  Test Case Setup  resource_group_online_modification
  [Teardown]  Test Case Teardown
  [Documentation]    Author: Yang Liqin
  [tags]  case8
  Log To Console  Resource_group_online_modification
  Resource_group_online_modification

CB008828_SR_026_C#IWK1_Resource_Group_Aware_Scheduler_interaction_with_Intra-gNB_TDD_FDD_CA
  [Setup]  Test Case Setup  Intra_gNB_TDD_FDD_CA
  [Teardown]  Test Case Teardown
  [Documentation]    Author: Yang Liqin
  [tags]  case26
  Log To Console  Intra_gNB_TDD_FDD_CA
  Intra gNB TDD FDD CA

CB008828_SR_030_C#IWK6_Interaction_between_Micro-DTX_scheduler_with_Slice_Aware_Scheduler
  [Setup]  Test Case Setup  Micro-DTX_scheduler_and_Slice_Aware_Scheduler
  [Teardown]  Test Case Teardown
  [Documentation]    Author: Yang Liqin
  [tags]  case30
  Log To Console  Micro-DTX_scheduler_and_Slice_Aware_Scheduler
  Interaction between Micro DTX scheduler with Slice Aware Scheduler

CB008828_SR_019_C#B6_Not_configured_RG_for_NSA _CB008746_disabled_CB008828_enabled
  [Setup]  Test Case Setup  Not_configured_RG_for_NSA _CB008746_disabled_CB008828_enabled
  [Teardown]  Test Case Teardown
  [Documentation]    Author: Yang Liqin
  [tags]  case19
  Log To Console  Not_configured_RG_for_NSA _CB008746_disabled_CB008828_enabled
  Not_configured_RG_for_NSA_CB008746_disabled_CB008828_enabled

CB008828_SR_004_C#B1_Resource_Group_Aware_Scheduler_considering_different_quotas_for_each_resource_group_created_using_slices
  [Setup]  Test Case Setup  different_quotas_for_each_resource_group
  [Teardown]  Test Case Teardown
  [Documentation]    Author: Yang Liqin
  [tags]  case4
  Log To Console  different_quotas_for_each_resource_group
  different quotas for each resource group

CB008828_SR_001_C-PMO#1_Measure_PRB_related_counters_per_Resource_Group_level_ALT2
    [Setup]    Run Keywords     Test Case C Setup    AND    Disable actSliceNumExt
    [Tags]    001_C
    [Teardown]  Test Case C Teardown
    Change Quotas of Resource Groups
    UEs attach and Start data transfer
    Verify M55910 M55338 M55308 M55363 Counters
    Stop DL and UL data transfer
    UEs detach
    Change Quotas Json after Testing
    Change Quotas of Resource Groups    minQuota1=${20}    minQuota2=${80}
    UEs attach and Start data transfer
    Verify M55910 M55338 M55308 M55363 Counters

CB008828_SR_005_C#B1_Resource_Group_Aware_Scheduler_considering_different_quotas_for_each_resource_group_created_using_SPID
    [Setup]    Run Keywords     Test Case C Setup    AND    Enable Actslicenumext
    [Tags]    005_C
    [Teardown]  Test Case C Teardown
    Change Quotas of Resource Groups    minQuota1=${30}    minQuota2=${70}
    UEs attach and Start data transfer
    Verify M55910 M55338 M55308 M55363 Counters
    Stop DL and UL data transfer
    UEs detach
    Change Quotas Json after Testing
    Change Quotas of Resource Groups    minQuota1=${60}    minQuota2=${40}
    UEs attach and Start data transfer
    Verify M55910 M55338 M55308 M55363 Counters

CB008828_SR_017_C#B6_RG_removal_for_NSA_CB008746_enabled_CB008828_enabled
    [Setup]    Run Keywords    Test Case C Setup    AND     Change Default nrResourceGroupId    AND
    ...     Enable Actslicenumext
    [Tags]    017_C
    [Teardown]  Test Case C Teardown
    UEs attach and Start data transfer
    Verify M55910 Counter    dnid_1=PLMN-PLMN/NRRESOURCEGROUP-1    dnid_2=PLMN-PLMN/NRRESOURCEGROUP-2
    Stop DL and UL data transfer
    UEs detach
    Delete NRRESOURCEGROUP
    UEs attach and Start data transfer
    Verify M55910 Counter    dnid_1=PLMN-PLMN/NRRESOURCEGROUP-2    dnid_2=PLMN-PLMN/NRRESOURCEGROUP-3
    Stop DL and UL data transfer
    UEs detach
    Change Bandwidth
    Check NRCELL onair
    Convert BTS Mode To NSA
    UEs attach and Start data transfer
    Verify M55910 Counter    dnid_1=PLMN-PLMN/NRRESOURCEGROUP-2    dnid_2=PLMN-PLMN/NRRESOURCEGROUP-3

*** Keywords ***
Test Case C Setup
    attenuator.setup_attenuator    attenuator=${tl.attenuator[0]}    alias=HBTE
    Run Keyword And Ignore Error    Modify attenuator value by port   modify_value=${0}  port=0    ru_id=0
    Run Keyword And Ignore Error    Modify attenuator value by port   modify_value=${0}  port=1    ru_id=0
    CI_interface.Common Suite Setup
    Get Some Variables
    Commissioning 1916 Case C
    _Create Suite Log Directory
    Run Keyword And Ignore Error    Connect and Modify the parameter on enblte  dist_name=${ENB_PATH}
    ...  parameter=actEndcSpidFwd  value=true
    Connect and Modify the parameter on enblte  dist_name=${lnrel_dist}  parameter=${lnrel_para1}   value=unlocked
    Convert BTS Mode To NSA
    Enable M55910 M55308 M55363
    # Prepare env with UEs
    robot_common_operations.Common Case Setup
    AlarmWatchdog.add_allow_alarms    fault_id=7107
    Run Keyword And Ignore Error    Unexpect Alarm Should Not Exist   allowed_faults=${ALLOWED_FAULT}
    ...                                                               file_path=${SUITE_LOG_DIRECTORY}
    Run Keyword If  '${MRBTS_ID}'=='1916'  Connect and Modify the parameter on enblte
    ...  dist_name=${lnrel_dist}  parameter=defaultLnRelGnbCellId  value=1
    UE Preparation At Case Setup

Test Case C Teardown
    Change Quotas Json after Testing
    CI_interface.Common Case Teardown
    robot_common_operations.Common Case Teardown
    Run keyword and ignore error  Convert BTS Mode To SA
    Run Keyword If  '${MRBTS_ID}'=='1916'  Run keyword and ignore error  Connect and Modify the parameter on enblte
    ...  dist_name=${lnrel_dist}  parameter=defaultLnRelGnbCellId  value=4
    Stop DL and UL data transfer
    UEs detach
    Unexpect Alarm Should Not Exist   allowed_faults=${ALLOWED_FAULT}   file_path=${SUITE_LOG_DIRECTORY}

