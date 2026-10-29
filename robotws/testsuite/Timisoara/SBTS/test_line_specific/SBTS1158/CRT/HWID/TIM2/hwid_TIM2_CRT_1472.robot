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
[1]Automated__SWM__SBTS_SOAM_rollback_to_SBTS_SOAM
    [Tags]  QC_665015
    Setup Scout  10_18_UTESRANCLOUD1472
    Request SCF  use_scout_internal_id=True
    Log Variables
    Teardown Scout API

[1]Automated__SWM__SW_download_and_activation__SBTS_to_SBTS
    [Tags]  QC_665016
    Setup Scout  10_18_UTESRANCLOUD1472
    Request SCF  use_scout_internal_id=True
    Log Variables
    Teardown Scout API

[1]Automated__CM__Commissioning__Configuration_reset
    [Tags]  QC_665017
    Setup Scout  10_18_UTESRANCLOUD1472
    Request SCF  use_scout_internal_id=True
    Log Variables
    Teardown Scout API

[1]Site_reset_without_HWF_in_loop
    [Tags]  QC_665018
    Setup Scout  10_18_UTESRANCLOUD1472
    Request SCF  use_scout_internal_id=True
    Log Variables
    Teardown Scout API

[1]Automated__CM__Commissioning_planned_commissioning
    [Tags]  QC_665020
    Setup Scout  10_18_UTESRANCLOUD1472
    Request SCF  use_scout_internal_id=True
    Log Variables
    Teardown Scout API

[1]Automated__STATE__RF_Module_lock_unlock
    [Tags]  QC_665019
    Setup Scout  10_18_UTESRANCLOUD1472
    Request SCF  use_scout_internal_id=True
    Log Variables
    Teardown Scout API

[1]Automated__STATE__Site_reset
    [Tags]  QC_665021
    Setup Scout  10_18_UTESRANCLOUD1472
    Request SCF  use_scout_internal_id=True
    Log Variables
    Teardown Scout API

[1]Automated__STATE__Site_reset
    [Tags]  QC_665023
    Setup Scout  10_18_UTESRANCLOUD1472
    Request SCF  use_scout_internal_id=True
    Log Variables
    Teardown Scout API
	
[1]Automated__STATE__Site_reset
    [Tags]  QC_665022
    Setup Scout  10_18_UTESRANCLOUD1472
    Request SCF  use_scout_internal_id=True
    Log Variables
    Teardown Scout API
	
*** Keywords ***