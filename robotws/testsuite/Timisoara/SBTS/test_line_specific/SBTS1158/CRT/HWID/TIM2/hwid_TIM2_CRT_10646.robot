*** Settings ***
Documentation
...    Author: mihai.rusu@nokia.com
...    Description: CSV

Force Tags  QCD_MN_RAN  QCP_RAN_VRF  SBTS00  SRAN  CLOUD_SRAN_N_10646_1ASOE_3AQQJ_2AHPB_NOVMREINSTALL  STATE_SKIP_AGENT
Library  XML  use_lxml=True
Library  taf.sw.scout
Library  String
Suite Setup      Set Library Search Order  coam   ute_admin   hran_frame_sbts_taf   hran_frame_sbts_siso   ca_CIT_general   ca_swm_general

Resource    ../../../test_resources/CIT/STATE__Site_reset.robot

*** Variables ***
${SCF_ID}    01
${HW_LOCATION_CODE}      Timisoara

*** Test Cases ***
[1]E2E_TL_Delta_Commissioning_With_Online_Parameter_Modification
    [Tags]  QC_180472
    Setup Scout  10_18_UTESRANCLOUD1646
    Request SCF  use_scout_internal_id=True
    Log Variables
    Teardown Scout API

[1]E2E_TL_SW_upgrade_rollback_with_OAM_KPI
    [Tags]  QC_180471
    Setup Scout  10_18_UTESRANCLOUD1646
    Request SCF  use_scout_internal_id=True
    Log Variables
    Teardown Scout API

[1]E2E_TL_Site_reset_without_HWF_with_OAM_KPI
    [Tags]  QC_180473
    Setup Scout  10_18_UTESRANCLOUD1646
    Request SCF  use_scout_internal_id=True
    Log Variables
    Teardown Scout API

[1]E2E_TL_Delta_Commissioning_With_Site_Reset_Required_5
    [Tags]  QC_180474
    Setup Scout  10_18_UTESRANCLOUD1646
    Request SCF  use_scout_internal_id=True
    Log Variables
    Teardown Scout API

[1]E2E_TL_Cell_Lock_Unlock_LTE_with_OAM_KPI_5
    [Tags]  QC_180476
    Setup Scout  10_18_UTESRANCLOUD1646
    Request SCF  use_scout_internal_id=True
    Log Variables
    Teardown Scout API

[1]E2E_TL_Capacity_Module_Reset_with_OAM_KPI_5
    [Tags]  QC_180479
    Setup Scout  10_18_UTESRANCLOUD1646
    Request SCF  use_scout_internal_id=True
    Log Variables
    Teardown Scout API

[1]E2E_TL_RU_Reset_with_OAM_KPI_4
    [Tags]  QC_180480
    Setup Scout  10_18_UTESRANCLOUD1646
    Request SCF  use_scout_internal_id=True
    Log Variables
    Teardown Scout API

[1]E2E_TL_Delta_Commissioning_With_LTE_Rat_Reset_4
    [Tags]  QC_180481
    Setup Scout  10_18_UTESRANCLOUD1646
    Request SCF  use_scout_internal_id=True
    Log Variables
    Teardown Scout API