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
    [Tags]  QC_172802
    Setup Scout  10_18_UTESRANCLOUD1317
    Request SCF  use_scout_internal_id=True
    Log Variables
    Teardown Scout API

[1]WebEM__Show_BTS_Start-up_view_automatically
    [Tags]  QC_178967
    Setup Scout  10_18_UTESRANCLOUD1317
    Request SCF  use_scout_internal_id=True
    Log Variables
    Teardown Scout API

[1]Check_test_dedicated_state
    [Tags]  QC_195768
    Setup Scout  10_18_UTESRANCLOUD1317
    Request SCF  use_scout_internal_id=True
    Log Variables
    Teardown Scout API

[1]FM__Primary_core_power_off_on
    [Tags]  QC_452446
    Setup Scout  10_18_UTESRANCLOUD1317
    Request SCF  use_scout_internal_id=True
    Log Variables
    Teardown Scout API

[1]FM__E_Capacity_core_unit_5G_L2_RT_SW_reset_escalation
    [Tags]  QC_454531
    Setup Scout  10_18_UTESRANCLOUD1317
    Request SCF  use_scout_internal_id=True
    Log Variables
    Teardown Scout API

[1]FM__SoC_reset_criteria_if_actForceUnitAutoReset=false_and_the_same_fault_appeared_for_the_SoC_in_pas_one_hour
    [Tags]  QC_467209
    Setup Scout  10_18_UTESRANCLOUD1317
    Request SCF  use_scout_internal_id=True
    Log Variables
    Teardown Scout API

[1]FM__SoC_reset_counter_exceeded
    [Tags]  QC_467207
    Setup Scout  10_18_UTESRANCLOUD1317
    Request SCF  use_scout_internal_id=True
    Log Variables
    Teardown Scout API

[1]FM__5GC000952_ASOE_Check_if_4th_Site_recovery_reset_within_1_hour_is_not_executed
    [Tags]  QC_467206
    Setup Scout  10_18_UTESRANCLOUD1317
    Request SCF  use_scout_internal_id=True
    Log Variables
    Teardown Scout API

[1]FM__SoC_reset_counter_cleared_after_one_hour
    [Tags]  QC_467208
    Setup Scout  10_18_UTESRANCLOUD1317
    Request SCF  use_scout_internal_id=True
    Log Variables
    Teardown Scout API

[1]FM__SoC_reset_criteria_is_not_allowed_when_allowBbPoolRecoveryReset=false
    [Tags]  QC_467211
    Setup Scout  10_18_UTESRANCLOUD1317
    Request SCF  use_scout_internal_id=True
    Log Variables
    Teardown Scout API

[1]FM__SoC_reset_criteria_if_actForceUnitAutoReset=true_in_the_same_fault_appeared_for_the_same_SoC_in_past_one_hour
    [Tags]  QC_467210
    Setup Scout  10_18_UTESRANCLOUD1317
    Request SCF  use_scout_internal_id=True
    Log Variables
    Teardown Scout API
	
*** Keywords ***