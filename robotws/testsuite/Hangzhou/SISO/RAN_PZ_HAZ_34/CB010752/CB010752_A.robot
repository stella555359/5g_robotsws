*** Settings ***
Documentation
Resource    ./Resources/CB010752_common_keyword.robot


Suite Setup    Suite Setup
Suite Teardown    Suite Teardown

*** Test Cases ***
[1]CB010752-SR-A_005_L3_call_on_band_combination_5_configurationg_NRFDD_NRTDD_cells_simultaneously
    [Setup]    Case Setup
      Log to console    [1]CB010752-SR-A_001
#    Make CPE L3 Call And Check Peak Tput    dl_tp=1500   ul_tp=83
#    ...    target_avg_percent_UL=0.90    target_avg_percent_DL=0.90
#    ...    ue_list=${ALL_UE_INFO_LIST[0:1]}
#    Make CPE L3 Call And Check Peak Tput    dl_tp=100  ul_tp=100
#    ...    target_avg_percent_UL=0.50  target_avg_percent_DL=0.50
#    ...    ue_list=${ALL_UE_INFO_LIST[1:2]}
    [Teardown]    Case Teardown


[1]CB010752-SR-A_001_L3_call_on_band_combination_1_configurationg_NRFDD_NRTDD_cells_simultaneously
    [Setup]    Case Setup
    modify the parameter case A01
#    Make CPE L3 Call And Check Peak Tput    dl_tp=1500   ul_tp=83
#    ...    target_avg_percent_UL=0.90    target_avg_percent_DL=0.90
#    ...    ue_list=${ALL_UE_INFO_LIST[0:1]}
#    Make CPE L3 Call And Check Peak Tput    dl_tp=100  ul_tp=100
#    ...    target_avg_percent_UL=0.50  target_avg_percent_DL=0.50
#    ...    ue_list=${ALL_UE_INFO_LIST[1:2]}
    modify the parameter case A04
#    Make CPE L3 Call And Check Peak Tput    dl_tp=1500   ul_tp=83
#    ...    target_avg_percent_UL=0.90    target_avg_percent_DL=0.90
#    ...    ue_list=${ALL_UE_INFO_LIST[0:1]}
#    Make CPE L3 Call And Check Peak Tput    dl_tp=100  ul_tp=100
#    ...    target_avg_percent_UL=0.50  target_avg_percent_DL=0.50
#    ...    ue_list=${ALL_UE_INFO_LIST[1:2]}
    [Teardown]    Case Teardown

[1]CB010752-SR-A_004_L3_call_on_band_combination_4_configurationg_NRFDD_NRTDD_cells_simultaneously
    [Documentation]  case004 step in case003 cover
    [Setup]    robot_common_operations.Common case Setup    allowed_faults_ids=61675
      Log to console    pass
    [Teardown]    Case Teardown


[1]CB010752-SR-A_006_NRTDD_recommission_between_supercell_and_normal_cells
    [Setup]    Case Setup
    configuration 1super3sub to 3nom
    configuration 3nom to 1super3sub
    [Teardown]    Case Teardown

