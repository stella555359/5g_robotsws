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

*** Test Cases ***
[1]CB009453_1_Activation of NR CBRS with two CBSD cells on one AEQM_40MHz+40MHz
   [Tags]    CRT_TRUNK
   CB009453_1_Activation of NR CBRS with two CBSD cells on one AEQM_40MHz+40MHz

[1]CB009453_2_Activation of NR CBRS with two CBSD cells on one AEQM_30MHz+20MHz
   [Tags]    CRT_TRUNK
   CB009453_2_Activation of NR CBRS with two CBSD cells on one AEQM_30MHz+20MHz

[1]CB009453_3_Online_add_one_higher_priority_CBRS_cell_when_only_40MHz_channel_block_available
   [Tags]    CRT_TRUNK
   CB009453_3_Online_add_one_higher_priority_CBRS_cell_when_only_40MHz_channel_block_available

[1]CB009453_12_expand_V2_upgrade_combination_from 20MHz+20MHz_to_40MHz+40MHz
   [Tags]    CRT_TRUNK
  CB009453_12_expand_V2_upgrade_combination_from 20MHz+20MHz_to_40MHz+40MHz

[1]CB009453_19_Frequency Selection Algorithm_desiredChBw_40+40_channelblock_70MHz_available
   [Tags]    CRT_TRUNK
   CB009453_19_Frequency Selection Algorithm_desiredChBw_40+40_channelblock_70MHz_available

[1]CB009453_20_MaxEIRP_check_celltype_from_4DL4UL_to_8DL4UL
   [Tags]    CRT_TRUNK
   CB009453_20_MaxEIRP_check_celltype_from_4DL4UL_to_8DL4UL

[1]CB009453_6_Verify_CBSD_cells_behavior_when_online_modify_cbrsFreqPriority
   [Tags]    CRT_TRUNK
   CB009453_6_Verify_CBSD_cells_behavior_when_online_modify_cbrsFreqPriority

[1]CB009453_14_CBSD_behavior_check_when_gNB_reset
   [Tags]    CRT_TRUNK
   CB009453_14_CBSD_behavior_check_when_gNB_reset

[1]CB009453_15_CBSD_behavior_check_when_RU_reset
   [Tags]    CRT_TRUNK
   CB009453_15_CBSD_behavior_check_when_RU_reset

[1]load_scf
   [Tags]    CRT_TRUNK
  load_scf

[1]CB005763-DC_Dying_Gasp_alarm_check_ecpri_AQQJ
    [Tags]    CRT_TRUNK
    CB005763-DC_Dying_Gasp_alarm_check_ecpri_AQQJ
