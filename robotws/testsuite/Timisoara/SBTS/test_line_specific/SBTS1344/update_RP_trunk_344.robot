*** Settings ***
Force Tags  QCD_MN_RAN  QCP_RAN_VRF  SBTS00  SRAN  CLOUD_SRAN_LG_10344_1ASIA_2ABIA_3AHEGC_2FXDB_1ARMA  STATE_SKIP_AGENT
Library  XML  use_lxml=True
Library  taf.sw.scout
Library  String
Suite Setup      Set Library Search Order  coam   ute_admin   hran_frame_sbts_taf   hran_frame_sbts_siso   ca_CIT_general   ca_swm_general

*** Variables ***
${SCF_ID}    01
${HW_LOCATION_CODE}      Timisoara

*** Test Cases ***
[1]E2E_TL_Site_reset_without_HWF_with_OAM_KPI
    [Tags]  QC_37464
    Setup Scout  10_18_UTESRANCLOUD1344
    Request SCF  use_scout_internal_id=True
    Log Variables
    Teardown Scout API

[1]E2E_TL_SW_upgrade_rollback_with_OAM_KPI
    [Tags]  QC_46704
    Setup Scout  10_18_UTESRANCLOUD1344
    Request SCF  use_scout_internal_id=True
    Log Variables
    Teardown Scout API

[1]E2E_TL_Cell_Block_Unblock_GSM_with_OAM_KPI
    [Tags]  QC_37470
    Setup Scout  10_18_UTESRANCLOUD1344
    Request SCF  use_scout_internal_id=True
    Log Variables
    Teardown Scout API

[1]E2E_TL_Delta_Commissioning_With_Site_Reset_Required
    [Tags]  QC_37472
    Setup Scout  10_18_UTESRANCLOUD1344
    Request SCF  use_scout_internal_id=True
    Log Variables
    Teardown Scout API

[1]E2E_TL_Cell_Lock_Unlock_LTE_with_OAM_KPI
    [Tags]  QC_37463
    Setup Scout  10_18_UTESRANCLOUD1344
    Request SCF  use_scout_internal_id=True
    Log Variables
    Teardown Scout API

[1]E2E_TL_Capacity_Module_Reset_with_OAM_KPI
    [Tags]  QC_37469
    Setup Scout  10_18_UTESRANCLOUD1344
    Request SCF  use_scout_internal_id=True
    Log Variables
    Teardown Scout API

[1]E2E_TL_RU_Reset_with_OAM_KPI
    [Tags]  QC_37457
    Setup Scout  10_18_UTESRANCLOUD1344
    Request SCF  use_scout_internal_id=True
    Log Variables
    Teardown Scout API

[1]E2E_TL_Delta_Commissioning_With_LTE_Rat_Reset
    [Tags]  QC_37466
    Setup Scout  10_18_UTESRANCLOUD1344
    Request SCF  use_scout_internal_id=True
    Log Variables
    Teardown Scout API

[1]E2E_TL_Delta_Commissioning_With_GSM_Rat_Reset
    [Tags]  QC_37467
    Setup Scout  10_18_UTESRANCLOUD1344
    Request SCF  use_scout_internal_id=True
    Log Variables
    Teardown Scout API

[1]E2E_TL_SW_upgrade_rollback_with_OAM_KPI_and_L3_Call
    [Tags]  QC_37458
    Setup Scout  10_18_UTESRANCLOUD1344
    Request SCF  use_scout_internal_id=True
    Log Variables
    Teardown Scout API

[1]E2E_TL_Delta_Commissioning_With_Online_Parameter_Modification
    [Tags]  QC_37471
    Setup Scout  10_18_UTESRANCLOUD1344
    Request SCF  use_scout_internal_id=True
    Log Variables
    Teardown Scout API


[1]E2E_TL_Cell_Block_Unblock_LTE_with_OAM_KPI
    [Tags]  QC_37468
    Setup Scout  10_18_UTESRANCLOUD1344
    Request SCF  use_scout_internal_id=True
    Log Variables
    Teardown Scout API


[1]Automated__FM__link_break_Abis_long
    [Tags]  QC_37459
    Setup Scout  10_18_UTESRANCLOUD1344
    Request SCF  use_scout_internal_id=True
    Log Variables
    Teardown Scout API


[1]Automated__FM__link_break_Abis_short
    [Tags]  QC_37460
    Setup Scout  10_18_UTESRANCLOUD1344
    Request SCF  use_scout_internal_id=True
    Log Variables
    Teardown Scout API


[1]Automated__FM__link_break_Abis_startup
    [Tags]  QC_37461
    Setup Scout  10_18_UTESRANCLOUD1344
    Request SCF  use_scout_internal_id=True
    Log Variables
    Teardown Scout API


[1]Automated__FM__link_break_SBTS_short
    [Tags]  QC_37462
    Setup Scout  10_18_UTESRANCLOUD1344
    Request SCF  use_scout_internal_id=True
    Log Variables
    Teardown Scout API


*** Keywords ***
