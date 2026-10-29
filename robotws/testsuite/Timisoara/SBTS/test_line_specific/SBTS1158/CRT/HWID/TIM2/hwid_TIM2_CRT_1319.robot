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
[1]E2E_TL_SW_upgrade_rollback_with_OAM_KPI
    [Tags]  QC_648505
    Setup Scout  10_18_UTESRANCLOUD1319
    Request SCF  use_scout_internal_id=True
    Log Variables
    Teardown Scout API

[1]E2E_TL_RU_Reset_with_OAM_KPI
    [Tags]  QC_648513
    Setup Scout  10_18_UTESRANCLOUD1319
    Request SCF  use_scout_internal_id=True
    Log Variables
    Teardown Scout API

[1]E2E_TL_Capacity_Module_Reset_with_OAM_KPI
    [Tags]  QC_648512
    Setup Scout  10_18_UTESRANCLOUD1319
    Request SCF  use_scout_internal_id=True
    Log Variables
    Teardown Scout API

[1]E2E_TL_Delta_Commissioning_With_Site_Reset_Required
    [Tags]  QC_648507
    Setup Scout  10_18_UTESRANCLOUD1319
    Request SCF  use_scout_internal_id=True
    Log Variables
    Teardown Scout API

[1]E2E_TL_Cell_Lock_Unlock_NR_with_OAM_KPI
    [Tags]  QC_648511
    Setup Scout  10_18_UTESRANCLOUD1319
    Request SCF  use_scout_internal_id=True
    Log Variables
    Teardown Scout API

[1]E2E_TL_Site_reset_without_HWF_with_OAM_KPI
    [Tags]  QC_648506
    Setup Scout  10_18_UTESRANCLOUD1319
    Request SCF  use_scout_internal_id=True
    Log Variables
    Teardown Scout API

[1]E2E_TL_Delta_Commissioning_With_Online_Parameter_Modification
    [Tags]  QC_648519
    Setup Scout  10_18_UTESRANCLOUD1319
    Request SCF  use_scout_internal_id=True
    Log Variables
    Teardown Scout API

[1]E2E_TL_Cell_Block_Unblock_NR_with_OAM_KPI
    [Tags]  QC_648521
    Setup Scout  10_18_UTESRANCLOUD1319
    Request SCF  use_scout_internal_id=True
    Log Variables
    Teardown Scout API

[1]E2E_TL_Delta_Commissioning_With_NR_Rat_Reset
    [Tags]  QC_648515
    Setup Scout  10_18_UTESRANCLOUD1319
    Request SCF  use_scout_internal_id=True
    Log Variables
    Teardown Scout API

[1]WebEM__Troubleshooting_scripts_menu
    [Tags]  QC_380769
    Setup Scout  10_18_UTESRANCLOUD1319
    Request SCF  use_scout_internal_id=True
    Log Variables
    Teardown Scout API

[1]WebEM__Troubleshooting_scripts_cli
    [Tags]  QC_380770
    Setup Scout  10_18_UTESRANCLOUD1319
    Request SCF  use_scout_internal_id=True
    Log Variables
    Teardown Scout API

[1]WebEM__Script_naming_rule
    [Tags]  QC_380771
    Setup Scout  10_18_UTESRANCLOUD1319
    Request SCF  use_scout_internal_id=True
    Log Variables
    Teardown Scout API

[1]Automated__FM__FHNET_crash_VN_recovery_reset_AS
    [Tags]  QC_583874
    Setup Scout  10_18_UTESRANCLOUD1319
    Request SCF  use_scout_internal_id=True
    Log Variables
    Teardown Scout API

[1]FM__5G RAT reset executed as autonomous recovery action
    [Tags]  QC_583875
    Setup Scout  10_18_UTESRANCLOUD1319
    Request SCF  use_scout_internal_id=True
    Log Variables
    Teardown Scout API

[1]FM__Primary core power off-on - fault signature
    [Tags]  QC_583876
    Setup Scout  10_18_UTESRANCLOUD1319
    Request SCF  use_scout_internal_id=True
    Log Variables
    Teardown Scout API

[1]FM__Site_reset_counter_exceeded_fid_246
    [Tags]  QC_598292
    Setup Scout  10_18_UTESRANCLOUD1319
    Request SCF  use_scout_internal_id=True
    Log Variables
    Teardown Scout API

[1]Autonomous_recovery_reset_counter_with_BBMOD_fault
    [Tags]  QC_583877
    Setup Scout  10_18_UTESRANCLOUD1319
    Request SCF  use_scout_internal_id=True
    Log Variables
    Teardown Scout API

*** Keywords ***
