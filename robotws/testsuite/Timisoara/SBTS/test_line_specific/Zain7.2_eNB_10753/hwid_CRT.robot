*** Settings ***
Force Tags  QCD_MN_RAN  QCP_RAN_VRF  SBTS00  SRAN  CLOUD_SRAN_LG_1FSMF_1FBBC_2FXDB_2FRMA_1FRHC  STATE_SKIP_AGENT
Library  XML  use_lxml=True
Library  taf.sw.scout
Library  String
Documentation  ALD and CSV

Suite Setup      Set Library Search Order  coam   ute_admin   hran_frame_sbts_taf   hran_frame_sbts_siso   ca_CIT_general   ca_swm_general

Resource    ../../../test_resources/CIT/STATE__Site_reset.robot

*** Variables ***
${SCF_ID}    01
${HW_LOCATION_CODE}      Timisoara

*** Test Cases ***
[1][1.1] ALD__Configure_Commissioned_RET_RetUAllias
    [Tags]  QC_292265
    Setup Scout  10_18_UTESRANCLOUD1649
    Request SCF  use_scout_internal_id=True
    Log Variables
    Teardown Scout API

[1][1.1] ALD_ Admin_CLI_calibrateTilt_using_RetUAllias
    [Tags]  QC_285042
    Setup Scout  10_18_UTESRANCLOUD1649
    Request SCF  use_scout_internal_id=True
    Log Variables
    Teardown Scout API

[1][1.1] Automated__ALD__Read_RAE_sensor_telemetry_on_demand_with_radio_reset
    [Tags]  QC_284325
    Setup Scout  10_18_UTESRANCLOUD1649
    Request SCF  use_scout_internal_id=True
    Log Variables
    Teardown Scout API

[1][1.0] CB013223_ALD_Software_update_HA_mode_ON
    [Tags]  QC_291350
    Setup Scout  10_18_UTESRANCLOUD1318
    Request SCF  use_scout_internal_id=True
    Log Variables
    Teardown Scout API

[1][1.0] Automated__ALD__Detect and setup__RF module reset with configured ALDs
    [Tags]  QC_284324
    Setup Scout  10_18_UTESRANCLOUD1649
    Request SCF  use_scout_internal_id=True
    Log Variables
    Teardown Scout API

[1][1.0] Automated__ALD__RAE_Reading_2D_beamforming_weight_factors
    [Tags]  QC_284328
    Setup Scout  10_18_UTESRANCLOUD1649
    Request SCF  use_scout_internal_id=True
    Log Variables
    Teardown Scout API

[1][1.0] Automated__ALD__RAE_Reading_1D_beamforming_weight_factors
    [Tags]  QC_284326
    Setup Scout  10_18_UTESRANCLOUD1649
    Request SCF  use_scout_internal_id=True
    Log Variables
    Teardown Scout API

[1][1.0] CB012840-Classical_ALD SW package in online and offline mode
    [Tags]  QC_284321
    Setup Scout  10_18_UTESRANCLOUD1649
    Request SCF  use_scout_internal_id=True
    Log Variables
    Teardown Scout API

[1][1.0] Automated__ALD__CLI support for ALD sharing
    [Tags]  QC_284322
    Setup Scout  10_18_UTESRANCLOUD1649
    Request SCF  use_scout_internal_id=True
    Log Variables
    Teardown Scout API

[1][1.1] Automated__ALD__BTS Reconfiguration with ALDs_ALD reassignment
    [Tags]  QC_284317
    Setup Scout  10_18_UTESRANCLOUD1648
    Request SCF  use_scout_internal_id=True
    Log Variables
    Teardown Scout API

[1][1.1] Automated__ALD__Manual commissioning with Nokia MHA_ALDs assigned as external units
    [Tags]  QC_284315
    Setup Scout  10_18_UTESRANCLOUD1648
    Request SCF  use_scout_internal_id=True
    Log Variables
    Teardown Scout API

[1][1.1] Automated__ALD__HDLC Communication management with reset
    [Tags]  QC_284318
    Setup Scout  10_18_UTESRANCLOUD1648
    Request SCF  use_scout_internal_id=True
    Log Variables
    Teardown Scout API

[1][1.1] Automated__ALD__Configure_Commissioned_RET_Antenna
    [Tags]  QC_284314
    Setup Scout  10_18_UTESRANCLOUD1648
    Request SCF  use_scout_internal_id=True
    Log Variables
    Teardown Scout API

[1][1.0] Automated_SFM_ALD_LTE_MHA_Alarm_id_1870_During_RF_Module_Block
    [Tags]  QC_241262
    Setup Scout  10_18_UTESRANCLOUD1649
    Request SCF  use_scout_internal_id=True
    Log Variables
    Teardown Scout API

[1][1.0] Automated_SFM_ALD_LTE_AbovecurrentAl_1834_active_during_RF-module_re-start_WMHC
    [Tags]  QC_241263
    Setup Scout  10_18_UTESRANCLOUD1649
    Request SCF  use_scout_internal_id=True
    Log Variables
    Teardown Scout API
