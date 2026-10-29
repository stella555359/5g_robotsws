*** Settings ***
Resource    resources/common_keywords.robot
Library     resources/common_keywords.py
Library     taf.transport.ssh    WITH NAME    ssh
Library     taf.config.wts       WITH NAME    wts
Resource  ./resources/CB008828_keyword.robot

Test Teardown    CB008828 Common Test Teardown

Suite Setup    Suite Case D Setup
Suite Teardown    Run Keyword If  '${MRBTS_ID}'=='1921'  Suite Case Teardown
...  ELSE  AP_startup.Common Suite Teardown

*** Variables ***
${RECREATE_WIRESHARK_FLAG}    ${TRUE}
${TRAFFIC_DURATION_SEC}=   20s

*** Test Cases ***
[1]CB008828_SR_023_D#B3_3_Online_modification_of_slice_configuration_in_NRPMQAP_objects_remove_SNSSAI  
  [Setup]  Test Case Setup  in_NRPMQAP_objects_add_SNSSAI
  [Teardown]  Test Case Teardown
  [Documentation]    Author: Yang Liqin
  [tags]  case23 
  Log To Console  in_NRPMQAP_objects_modify_SNSSAI
  Add SNSSAI in NRPMQAP objects
  Remove SNSSAI in NRPMQAP objects
  Move SNSSAI in NRPMQAP objects

[1]CB008828_SR_032_D_User_Scenario_SA_Admission_Control_in_DU_per_NR_PMQAP_Profile_initial_access
  [Setup]  Test Case Setup  SA_Admission_Control_initial_access
  [Teardown]  Test Case Teardown
  [tags]  case32 
  Log To Console  SA_Admission_Control_initial_access
  SA Admission Control initial access

[1]CB008828_SR_025_D#B3_5_Online_modification_of_slice_configuration_in_NRPMQAP_objects_remove_NRPMQAP
  [Setup]  Test Case Setup  Online_modification_of_slice_configuration_add_NRPMQAP
  [Teardown]  Test Case Teardown
  [tags]  case25 
  Log To Console  Online_modification_of_slice_configuration_modify_NRPMQAP
  Online modification of slice configuration add NRPMQAP
  Online modification of slice configuration delete NRPMQAP

[1]CB008828_SR_033_D_User_Scenario_SA_Admission_Control_in_DU_per_NR_PMQAP_Profile_incoming_handover
  [Setup]  Test Case Setup  SA_Admission_Control_incoming_handover
  [Teardown]  Test Case Teardown
  [tags]  case33 
  Log To Console  SA_Admission_Control_incoming_handover
  Trigger IntraFreq IntergNBHO and check Measurement

CB008828_SR_017_D_User_Scenario_SA_Admission_Control_in_CU_per_NR_PMQAP_Profile_incoming_handover
  [Setup]  Test Case Setup  SA_Admission_Control_in_CU_incoming_handover
  [Teardown]  Test Case Teardown
  [tags]  case17 
  Log To Console  SA_Admission_Control_in_CU_incoming_handover
  Trigger IntraFreq IntergNBHO and check M55161 and M55193

CB008828_SR_016_D_User_Scenario_SA_Admission_Control_in_CU_per_NR_PMQAP_Profile_initial_access
  [Setup]  Test Case Setup  SA_Admission_Control_initial_access
  [Teardown]  Test Case Teardown
  [tags]  case16 
  Log To Console  SA_Admission_Control_initial_access_in_CU
  SA Admission Control initial access in CU

CB008828_SR_005_D_User_scenario_Xn-based_Inter-frequency_successful_handover_per_NR_PMQAP_Profile 
  [Setup]  Test Case Setup  Xn-based_Inter-frequency_successful_handover
  [Teardown]  Test Case Teardown
  [tags]  case5 
  Log To Console  Xn-based_Inter-frequency_successful_handover
  Inter-frequency_successful_handover

CB008828_SR_009_D_User_scenario_NG-based_Inter-frequency_successful_handover_per_NR_PMQAP_Profile
  [Setup]  Test Case Setup  NG-based_Inter-frequency_successful_handover
  [Teardown]  Test Case Teardown
  [tags]  case9 
  Log To Console  NG-based_Inter-frequency_successful_handover
  NG-based_Inter-frequency_successful_handover

CB008828_SR_010_D_User_scenario_NG-based_Intra-frequency_successful_handover_per_NR_PMQAP_Profile
  [Setup]  Test Case Setup  NG-based_Intra-frequency_successful_handover
  [Teardown]  Test Case Teardown
  [tags]  case10 
  Log To Console  NG-based_Intra-frequency_successful_handover
  NG-based_Intra-frequency_successful_handover

CB008828_SR_001_D_User_scenario_Intra-gNB_Inter-frequency_successful_handover_per_NR_PMQAP_profile
  [Setup]  Test Case Setup  Intra-gNB_Inter-frequency_successful_handover
  [Teardown]  Test Case Teardown
  [tags]  case1 
  Log To Console  Intra-gNB_Inter-frequency_successful_handover
  Intra-gNB_Inter-frequency_successful_handover

CB008828_SR_002_D_User_scenario_Intra-gNB_Intra-frequency_successful_handover_per_NR_PMQAP_profile
  [Setup]  Test Case Setup  Intra-gNB_Intra-frequency_successful_handover
  [Teardown]  Test Case Teardown
  [tags]  case2 
  Log To Console  Intra-gNB_Intra-frequency_successful_handover
  Intra-gNB_Intra-frequency_successful_handover

CB008828_SR_006_D_User_scenario_Xn-based_Intra-frequency_successful_handover_per_NR_PMQAP_Profile
  [Setup]  Test Case Setup  Xn-based_Intra-frequency_successful_handover
  [Teardown]  Test Case Teardown
  [tags]  case6 
  Log To Console  Xn-based_Intra-frequency_successful_handover
  Intra-frequency_successful_handover


