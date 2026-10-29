*** Settings ***
Force Tags  QCD_MN_RAN  QCP_RAN_ST  SBTS00  SRAN  CLOUD_SRAN_LG_1FSMF_1FBBC_2FXDB_2FRMA_1FRHC  STATE_SKIP_AGENT
Library  XML  use_lxml=True
Library  taf.sw.scout
Library  String
Suite Setup      Set Library Search Order  coam   ute_admin   hran_frame_sbts_taf   hran_frame_sbts_siso   ca_CIT_general   ca_swm_general

Resource    ../../../test_resources/CIT/STATE__Site_reset.robot

*** Variables ***
${SCF_ID}    01
${HW_LOCATION_CODE}      Timisoara

*** Test Cases ***
[1]Mobile_Simplified_Site_View_for_ASOE
    [Tags]  QC_619945
    Setup Scout  10_18_UTESRANCLOUD1766
    Request SCF  use_scout_internal_id=True
    Log Variables
    Teardown Scout API

[1]WebEM__Show_BTS_Start-up_view_automatically
    [Tags]  QC_619946
    Setup Scout  10_18_UTESRANCLOUD1766
    Request SCF  use_scout_internal_id=True
    Log Variables
    Teardown Scout API

[1]Check_test_dedicated_state
    [Tags]  QC_619947
    Setup Scout  10_18_UTESRANCLOUD1766
    Request SCF  use_scout_internal_id=True
    Log Variables
    Teardown Scout API

[1]FM__Primary_core_power_off_on
    [Tags]  QC_619948
    Setup Scout  10_18_UTESRANCLOUD1766
    Request SCF  use_scout_internal_id=True
    Log Variables
    Teardown Scout API

[1]FM__E_Capacity_core_unit_5G_L2_RT_SW_reset_escalation
    [Tags]  QC_619950
    Setup Scout  10_18_UTESRANCLOUD1766
    Request SCF  use_scout_internal_id=True
    Log Variables
    Teardown Scout API

[1]FM__SoC_reset_criteria_if_actForceUnitAutoReset=false_and_the_same_fault_appeared_for_the_SoC_in_pas_one_hour
    [Tags]  QC_619949
    Setup Scout  10_18_UTESRANCLOUD1766
    Request SCF  use_scout_internal_id=True
    Log Variables
    Teardown Scout API

[1]FM__SoC_reset_counter_exceeded
    [Tags]  QC_619951
    Setup Scout  10_18_UTESRANCLOUD1766
    Request SCF  use_scout_internal_id=True
    Log Variables
    Teardown Scout API

[1]FM__5GC000952_ASOE_Check_if_4th_Site_recovery_reset_within_1_hour_is_not_executed
    [Tags]  QC_619953
    Setup Scout  10_18_UTESRANCLOUD1766
    Request SCF  use_scout_internal_id=True
    Log Variables
    Teardown Scout API

[1]FM__SoC_reset_counter_cleared_after_one_hour
    [Tags]  QC_619952
    Setup Scout  10_18_UTESRANCLOUD1766
    Request SCF  use_scout_internal_id=True
    Log Variables
    Teardown Scout API

[1]FM__SoC_reset_criteria_is_not_allowed_when_allowBbPoolRecoveryReset=false
    [Tags]  QC_619955
    Setup Scout  10_18_UTESRANCLOUD1766
    Request SCF  use_scout_internal_id=True
    Log Variables
    Teardown Scout API

[1]FM__SoC_reset_criteria_if_actForceUnitAutoReset=true_in_the_same_fault_appeared_for_the_same_SoC_in_past_one_hour
    [Tags]  QC_619954
    Setup Scout  10_18_UTESRANCLOUD1766
    Request SCF  use_scout_internal_id=True
    Log Variables
    Teardown Scout API

[1]Mobile_Simplified_Site_View_for_ASOE
    [Tags]  QC_619956
    Setup Scout  10_18_UTESRANCLOUD1766
    Request SCF  use_scout_internal_id=True
    Log Variables
    Teardown Scout API

[1]WebEM__Show_BTS_Start-up_view_automatically
    [Tags]  QC_619957
    Setup Scout  10_18_UTESRANCLOUD1766
    Request SCF  use_scout_internal_id=True
    Log Variables
    Teardown Scout API

[1]Check_test_dedicated_state
    [Tags]  QC_619958
    Setup Scout  10_18_UTESRANCLOUD1766
    Request SCF  use_scout_internal_id=True
    Log Variables
    Teardown Scout API

[1]FM__Primary_core_power_off_on
    [Tags]  QC_619959
    Setup Scout  10_18_UTESRANCLOUD1766
    Request SCF  use_scout_internal_id=True
    Log Variables
    Teardown Scout API

[1]FM__E_Capacity_core_unit_5G_L2_RT_SW_reset_escalation
    [Tags]  QC_619961
    Setup Scout  10_18_UTESRANCLOUD1766
    Request SCF  use_scout_internal_id=True
    Log Variables
    Teardown Scout API

[1]FM__SoC_reset_criteria_if_actForceUnitAutoReset=false_and_the_same_fault_appeared_for_the_SoC_in_pas_one_hour
    [Tags]  QC_619960
    Setup Scout  10_18_UTESRANCLOUD1766
    Request SCF  use_scout_internal_id=True
    Log Variables
    Teardown Scout API

[1]FM__SoC_reset_counter_exceeded
    [Tags]  QC_619962
    Setup Scout  10_18_UTESRANCLOUD1766
    Request SCF  use_scout_internal_id=True
    Log Variables
    Teardown Scout API

[1]FM__5GC000952_ASOE_Check_if_4th_Site_recovery_reset_within_1_hour_is_not_executed
    [Tags]  QC_619964
    Setup Scout  10_18_UTESRANCLOUD1766
    Request SCF  use_scout_internal_id=True
    Log Variables
    Teardown Scout API

[1]FM__SoC_reset_counter_cleared_after_one_hour
    [Tags]  QC_619963
    Setup Scout  10_18_UTESRANCLOUD1766
    Request SCF  use_scout_internal_id=True
    Log Variables
    Teardown Scout API

[1]FM__SoC_reset_criteria_is_not_allowed_when_allowBbPoolRecoveryReset=false
    [Tags]  QC_619963
    Setup Scout  10_18_UTESRANCLOUD1766
    Request SCF  use_scout_internal_id=True
    Log Variables
    Teardown Scout API

[1]FM__SoC_reset_criteria_if_actForceUnitAutoReset=true_in_the_same_fault_appeared_for_the_same_SoC_in_past_one_hour
    [Tags]  QC_619966
    Setup Scout  10_18_UTESRANCLOUD1766
    Request SCF  use_scout_internal_id=True
    Log Variables
    Teardown Scout API	
	
[1]Mobile_Simplified_Site_View_for_ASOE
    [Tags]  QC_619967
    Setup Scout  10_18_UTESRANCLOUD1766
    Request SCF  use_scout_internal_id=True
    Log Variables
    Teardown Scout API

[1]WebEM__Show_BTS_Start-up_view_automatically
    [Tags]  QC_619968
    Setup Scout  10_18_UTESRANCLOUD1766
    Request SCF  use_scout_internal_id=True
    Log Variables
    Teardown Scout API

[1]Check_test_dedicated_state
    [Tags]  QC_619969
    Setup Scout  10_18_UTESRANCLOUD1766
    Request SCF  use_scout_internal_id=True
    Log Variables
    Teardown Scout API

[1]FM__Primary_core_power_off_on
    [Tags]  QC_619970
    Setup Scout  10_18_UTESRANCLOUD1766
    Request SCF  use_scout_internal_id=True
    Log Variables
    Teardown Scout API

[1]FM__E_Capacity_core_unit_5G_L2_RT_SW_reset_escalation
    [Tags]  QC_619971
    Setup Scout  10_18_UTESRANCLOUD1766
    Request SCF  use_scout_internal_id=True
    Log Variables
    Teardown Scout API

[1]FM__SoC_reset_criteria_if_actForceUnitAutoReset=false_and_the_same_fault_appeared_for_the_SoC_in_pas_one_hour
    [Tags]  QC_619972
    Setup Scout  10_18_UTESRANCLOUD1766
    Request SCF  use_scout_internal_id=True
    Log Variables
    Teardown Scout API

[1]FM__SoC_reset_counter_exceeded
    [Tags]  QC_619973
    Setup Scout  10_18_UTESRANCLOUD1766
    Request SCF  use_scout_internal_id=True
    Log Variables
    Teardown Scout API

[1]FM__5GC000952_ASOE_Check_if_4th_Site_recovery_reset_within_1_hour_is_not_executed
    [Tags]  QC_619974
    Setup Scout  10_18_UTESRANCLOUD1766
    Request SCF  use_scout_internal_id=True
    Log Variables
    Teardown Scout API

[1]FM__SoC_reset_counter_cleared_after_one_hour
    [Tags]  QC_619975
    Setup Scout  10_18_UTESRANCLOUD1766
    Request SCF  use_scout_internal_id=True
    Log Variables
    Teardown Scout API

[1]FM__SoC_reset_criteria_is_not_allowed_when_allowBbPoolRecoveryReset=false
    [Tags]  QC_619976
    Setup Scout  10_18_UTESRANCLOUD1766
    Request SCF  use_scout_internal_id=True
    Log Variables
    Teardown Scout API

[1]FM__SoC_reset_criteria_if_actForceUnitAutoReset=true_in_the_same_fault_appeared_for_the_same_SoC_in_past_one_hour
    [Tags]  QC_619977
    Setup Scout  10_18_UTESRANCLOUD1766
    Request SCF  use_scout_internal_id=True
    Log Variables
    Teardown Scout API

[1]FM__SoC_reset_criteria_is_not_allowed_when_allowBbPoolRecoveryReset=false
    [Tags]  QC_619978
    Setup Scout  10_18_UTESRANCLOUD1766
    Request SCF  use_scout_internal_id=True
    Log Variables
    Teardown Scout API

[1]FM__SoC_reset_criteria_if_actForceUnitAutoReset=true_in_the_same_fault_appeared_for_the_same_SoC_in_past_one_hour
    [Tags]  QC_619979
    Setup Scout  10_18_UTESRANCLOUD1766
    Request SCF  use_scout_internal_id=True
    Log Variables
    Teardown Scout API
	
[1]FM__SoC_reset_criteria_if_actForceUnitAutoReset=true_in_the_same_fault_appeared_for_the_same_SoC_in_past_one_hour
    [Tags]  QC_753822
    Setup Scout  10_18_UTESRANCLOUD1766
    Request SCF  use_scout_internal_id=True
    Log Variables
    Teardown Scout API

[1]FM__SoC_reset_criteria_if_actForceUnitAutoReset=true_in_the_same_fault_appeared_for_the_same_SoC_in_past_one_hour
    [Tags]  QC_753824
    Setup Scout  10_18_UTESRANCLOUD1766
    Request SCF  use_scout_internal_id=True
    Log Variables
    Teardown Scout API
	
[1]FM__SoC_reset_criteria_if_actForceUnitAutoReset=true_in_the_same_fault_appeared_for_the_same_SoC_in_past_one_hour
    [Tags]  QC_753830
    Setup Scout  10_18_UTESRANCLOUD1766
    Request SCF  use_scout_internal_id=True
    Log Variables
    Teardown Scout API
	
[1]FM__SoC_reset_criteria_if_actForceUnitAutoReset=true_in_the_same_fault_appeared_for_the_same_SoC_in_past_one_hour
    [Tags]  QC_753831
    Setup Scout  10_18_UTESRANCLOUD1766
    Request SCF  use_scout_internal_id=True
    Log Variables
    Teardown Scout API
	
[1]FM__SoC_reset_criteria_if_actForceUnitAutoReset=true_in_the_same_fault_appeared_for_the_same_SoC_in_past_one_hour
    [Tags]  QC_753833
    Setup Scout  10_18_UTESRANCLOUD1766
    Request SCF  use_scout_internal_id=True
    Log Variables
    Teardown Scout API
	
[1]FM__SoC_reset_criteria_if_actForceUnitAutoReset=true_in_the_same_fault_appeared_for_the_same_SoC_in_past_one_hour
    [Tags]  QC_753834
    Setup Scout  10_18_UTESRANCLOUD1766
    Request SCF  use_scout_internal_id=True
    Log Variables
    Teardown Scout API
	
[1]FM__SoC_reset_criteria_if_actForceUnitAutoReset=true_in_the_same_fault_appeared_for_the_same_SoC_in_past_one_hour
    [Tags]  QC_753836
    Setup Scout  10_18_UTESRANCLOUD1766
    Request SCF  use_scout_internal_id=True
    Log Variables
    Teardown Scout API
	
[1]FM__SoC_reset_criteria_if_actForceUnitAutoReset=true_in_the_same_fault_appeared_for_the_same_SoC_in_past_one_hour
    [Tags]  QC_753840
    Setup Scout  10_18_UTESRANCLOUD1766
    Request SCF  use_scout_internal_id=True
    Log Variables
    Teardown Scout API
	
[1]FM__SoC_reset_criteria_if_actForceUnitAutoReset=true_in_the_same_fault_appeared_for_the_same_SoC_in_past_one_hour
    [Tags]  QC_753842
    Setup Scout  10_18_UTESRANCLOUD1766
    Request SCF  use_scout_internal_id=True
    Log Variables
    Teardown Scout API
	
[1]FM__SoC_reset_criteria_if_actForceUnitAutoReset=true_in_the_same_fault_appeared_for_the_same_SoC_in_past_one_hour
    [Tags]  QC_753844
    Setup Scout  10_18_UTESRANCLOUD1766
    Request SCF  use_scout_internal_id=True
    Log Variables
    Teardown Scout API
	
[1]FM__SoC_reset_criteria_if_actForceUnitAutoReset=true_in_the_same_fault_appeared_for_the_same_SoC_in_past_one_hour
    [Tags]  QC_6753843
    Setup Scout  10_18_UTESRANCLOUD1766
    Request SCF  use_scout_internal_id=True
    Log Variables
    Teardown Scout API
	
[1]FM__SoC_reset_criteria_if_actForceUnitAutoReset=true_in_the_same_fault_appeared_for_the_same_SoC_in_past_one_hour
    [Tags]  QC_753845
    Setup Scout  10_18_UTESRANCLOUD1766
    Request SCF  use_scout_internal_id=True
    Log Variables
    Teardown Scout API
		
	
*** Keywords ***